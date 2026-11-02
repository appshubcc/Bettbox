package provider

import (
	"context"
	"sync"
	"time"

	"github.com/metacubex/mihomo/common/utils"
	C "github.com/metacubex/mihomo/constant"
)

const (
	healthCheckConcurrency = 32
	healthCheckReuseWindow = time.Minute
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
