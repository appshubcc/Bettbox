package provider

import (
	"context"
	"strings"
	"sync"
	"time"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/common/utils"
	C "github.com/metacubex/mihomo/constant"
	"golang.org/x/exp/slices"
)

const (
	healthCheckConcurrency = 32
	healthCheckReuseWindow = time.Minute
	healthCheckBatchLimit  = 512
	healthCheckEliteCount  = 32
)

type sharedTestKey struct {
	proxy  C.Proxy
	url    string
	status string
}

type sharedTest struct {
	done chan struct{}
}

var (
	sharedTestSlots = make(chan struct{}, healthCheckConcurrency)
	sharedTestLock  sync.Mutex
	sharedTests     = map[sharedTestKey]*sharedTest{}
)

func (hc *HealthCheck) check() {
	hc.checkWith(0)
}

func (hc *HealthCheck) periodicReuse() time.Duration {
	if reuse := hc.interval / 2; reuse < healthCheckReuseWindow {
		return reuse
	}
	return healthCheckReuseWindow
}

func (hc *HealthCheck) compileOptionFilter(option *extraOption) *regexp2.Regexp {
	if option == nil {
		return nil
	}
	hc.mu.Lock()
	if len(option.filters) == 0 {
		hc.mu.Unlock()
		return nil
	}
	filters := make([]string, 0, len(option.filters))
	for filter := range option.filters {
		filters = append(filters, filter)
	}
	hc.mu.Unlock()
	slices.Sort(filters)
	return utils.MustCompileRegexp(strings.Join(filters, "|"), regexp2.None)
}

func (hc *HealthCheck) selectBatch(url string, filterReg *regexp2.Regexp, reuse time.Duration) []C.Proxy {
	proxies := hc.proxies
	if len(proxies) == 0 {
		return nil
	}
	var matched []C.Proxy
	if filterReg == nil {
		matched = proxies
	} else {
		for _, proxy := range proxies {
			if ok, _ := filterReg.MatchString(proxy.Name()); ok {
				matched = append(matched, proxy)
			}
		}
	}
	if len(matched) <= healthCheckBatchLimit {
		return matched
	}

	var eliteIdx [healthCheckEliteCount]int
	var eliteDelay [healthCheckEliteCount]uint16
	eliteLen := 0
	for i, proxy := range matched {
		delay := proxy.LastDelayForTestUrl(url)
		if delay == 0 || delay == 0xffff || testedWithin(proxy, url, reuse) {
			continue
		}
		if eliteLen == healthCheckEliteCount && delay >= eliteDelay[eliteLen-1] {
			continue
		}
		pos := eliteLen
		if pos == healthCheckEliteCount {
			pos--
		} else {
			eliteLen++
		}
		for pos > 0 && delay < eliteDelay[pos-1] {
			eliteDelay[pos] = eliteDelay[pos-1]
			eliteIdx[pos] = eliteIdx[pos-1]
			pos--
		}
		eliteDelay[pos] = delay
		eliteIdx[pos] = i
	}

	batch := make([]C.Proxy, 0, healthCheckBatchLimit)
	for i := 0; i < eliteLen; i++ {
		batch = append(batch, matched[eliteIdx[i]])
	}

	hc.mu.Lock()
	if hc.cursors == nil {
		hc.cursors = make(map[string]int)
	}
	start := hc.cursors[url] % len(matched)
	hc.mu.Unlock()

	step := 0
	for ; step < len(matched) && len(batch) < healthCheckBatchLimit; step++ {
		idx := (start + step) % len(matched)
		if containsIndex(eliteIdx[:eliteLen], idx) {
			continue
		}
		candidate := matched[idx]
		if testedWithin(candidate, url, reuse) {
			continue
		}
		batch = append(batch, candidate)
	}

	hc.mu.Lock()
	hc.cursors[url] = (start + step) % len(matched)
	hc.mu.Unlock()

	return batch
}

func containsIndex(indices []int, target int) bool {
	for _, idx := range indices {
		if idx == target {
			return true
		}
	}
	return false
}

func testedWithin(proxy C.Proxy, url string, window time.Duration) bool {
	if window <= 0 {
		return false
	}
	tested, ok := proxy.(interface{ LastTestTime(url string) time.Time })
	if !ok {
		return false
	}
	last := tested.LastTestTime(url)
	return !last.IsZero() && time.Since(last) < window
}

func (hc *HealthCheck) urlTest(proxy C.Proxy, url string, expectedStatus utils.IntRanges[uint16], reuse time.Duration) {
	if testedWithin(proxy, url, reuse) {
		return
	}
	key := sharedTestKey{proxy: proxy, url: url, status: expectedStatus.String()}
	sharedTestLock.Lock()
	if test, ok := sharedTests[key]; ok {
		sharedTestLock.Unlock()
		select {
		case <-test.done:
		case <-hc.ctx.Done():
		}
		return
	}
	test := &sharedTest{done: make(chan struct{})}
	sharedTests[key] = test
	sharedTestLock.Unlock()

	defer func() {
		sharedTestLock.Lock()
		delete(sharedTests, key)
		sharedTestLock.Unlock()
		close(test.done)
	}()

	select {
	case sharedTestSlots <- struct{}{}:
	case <-hc.ctx.Done():
		return
	}
	defer func() {
		<-sharedTestSlots
	}()
	ctx, cancel := context.WithTimeout(hc.ctx, hc.timeout)
	defer cancel()
	_, _ = proxy.URLTest(ctx, url, expectedStatus)
}
