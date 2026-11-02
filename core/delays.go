package main

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

const (
	delayFlushInterval  = 300 * time.Millisecond
	groupRecheckDelay   = 11 * time.Second
	maxDelayConcurrency = 100
)

type delayKey struct {
	url  string
	name string
}

type delayTarget struct {
	Name string `json:"name"`
	Url  string `json:"url"`
}

type testDelaysParams struct {
	Targets     []delayTarget `json:"targets"`
	Timeout     int64         `json:"timeout"`
	Concurrency int           `json:"concurrency"`
}

var (
	delayPushLock   sync.Mutex
	pendingDelays   = map[delayKey]Delay{}
	delayFlushTimer *time.Timer
	pushForeground  = true
	forcedDelayPush = 0

	groupNowsLock     sync.Mutex
	lastGroupNows     map[string]string
	groupsChangedSent bool
	groupRecheckTimer *time.Timer

	delayBatchLock sync.Mutex
	delayBatches   = map[*delayBatch]struct{}{}
	staleDelays    = map[delayKey]int{}
)

type delayBatch struct {
	keys   []delayKey
	cancel context.CancelFunc
	stale  bool
}

func startDelayBatch(targets []delayTarget) (context.Context, *delayBatch) {
	ctx, cancel := context.WithCancel(context.Background())
	batch := &delayBatch{keys: make([]delayKey, len(targets)), cancel: cancel}
	for i, target := range targets {
		batch.keys[i] = delayKey{url: target.Url, name: target.Name}
	}
	delayBatchLock.Lock()
	delayBatches[batch] = struct{}{}
	delayBatchLock.Unlock()
	return ctx, batch
}

func finishDelayBatch(batch *delayBatch) {
	batch.cancel()
	delayBatchLock.Lock()
	delete(delayBatches, batch)
	if batch.stale {
		for _, key := range batch.keys {
			staleDelays[key]--
			if staleDelays[key] <= 0 {
				delete(staleDelays, key)
			}
		}
	}
	delayBatchLock.Unlock()
}

func cancelDelayBatches() {
	delayBatchLock.Lock()
	for batch := range delayBatches {
		if batch.stale {
			continue
		}
		batch.stale = true
		batch.cancel()
		for _, key := range batch.keys {
			staleDelays[key]++
		}
	}
	delayBatchLock.Unlock()
}

func isStaleDelay(key delayKey) bool {
	delayBatchLock.Lock()
	defer delayBatchLock.Unlock()
	return staleDelays[key] > 0
}

func delayTestURL(url string) string {
	if url == "" {
		return constant.DefaultTestURL
	}
	return url
}

func delayPushEnabledLocked() bool {
	return pushForeground || forcedDelayPush > 0
}

func scheduleDelayFlushLocked() {
	if delayFlushTimer != nil || len(pendingDelays) == 0 || !delayPushEnabledLocked() {
		return
	}
	delayFlushTimer = time.AfterFunc(delayFlushInterval, flushDelays)
}

func pushDelay(delay Delay) {
	key := delayKey{url: delay.Url, name: delay.Name}
	if isStaleDelay(key) {
		return
	}
	delayPushLock.Lock()
	pendingDelays[key] = delay
	scheduleDelayFlushLocked()
	delayPushLock.Unlock()
}

func flushDelays() {
	delayPushLock.Lock()
	if delayFlushTimer != nil {
		delayFlushTimer.Stop()
		delayFlushTimer = nil
	}
	if !delayPushEnabledLocked() {
		delayPushLock.Unlock()
		return
	}
	delays := make([]Delay, 0, len(pendingDelays))
	for _, delay := range pendingDelays {
		delays = append(delays, delay)
	}
	if len(delays) > 0 {
		pendingDelays = map[delayKey]Delay{}
	}
	delayPushLock.Unlock()
	if len(delays) > 0 {
		sendMessage(Message{Type: DelaysMessage, Data: delays})
	}
	if !checkGroupsChanged() && len(delays) > 0 {
		scheduleGroupRecheck()
	}
}

func scheduleGroupRecheck() {
	groupNowsLock.Lock()
	defer groupNowsLock.Unlock()
	if groupRecheckTimer != nil {
		groupRecheckTimer.Reset(groupRecheckDelay)
		return
	}
	groupRecheckTimer = time.AfterFunc(groupRecheckDelay, func() {
		delayPushLock.Lock()
		enabled := delayPushEnabledLocked()
		delayPushLock.Unlock()
		if enabled {
			checkGroupsChanged()
		}
	})
}

func handleSetForeground(value bool) {
	delayPushLock.Lock()
	pushForeground = value
	delayPushLock.Unlock()
	if value {
		flushDelays()
	}
}

func rememberGroupNows(nows map[string]string) {
	groupNowsLock.Lock()
	lastGroupNows = nows
	groupsChangedSent = false
	groupNowsLock.Unlock()
}

func resetDelayState() {
	delayPushLock.Lock()
	pendingDelays = map[delayKey]Delay{}
	delayPushLock.Unlock()
	rememberGroupNows(nil)
}

func groupNowsChanged(nows map[string]string) bool {
	proxies := tunnel.Proxies()
	for name, now := range nows {
		_, group, ok := proxyGroupOf(proxies[name])
		if !ok || group.Now() != now {
			return true
		}
	}
	return false
}

func checkGroupsChanged() bool {
	groupNowsLock.Lock()
	changed := !groupsChangedSent && lastGroupNows != nil && groupNowsChanged(lastGroupNows)
	if changed {
		groupsChangedSent = true
	}
	groupNowsLock.Unlock()
	if changed {
		sendMessage(Message{Type: GroupsChangedMessage})
	}
	return changed
}

func testDelays(ctx context.Context, params testDelaysParams) []Delay {
	concurrency := params.Concurrency
	if concurrency < 1 {
		concurrency = 1
	} else if concurrency > maxDelayConcurrency {
		concurrency = maxDelayConcurrency
	}
	results := make([]Delay, len(params.Targets))
	for i, target := range params.Targets {
		results[i] = Delay{Name: target.Name, Url: target.Url, Value: -1}
	}
	semaphore := make(chan struct{}, concurrency)
	var wg sync.WaitGroup
	for i, target := range params.Targets {
		select {
		case semaphore <- struct{}{}:
		case <-ctx.Done():
		}
		if ctx.Err() != nil {
			break
		}
		wg.Add(1)
		go func(i int, target delayTarget) {
			defer wg.Done()
			defer func() { <-semaphore }()
			results[i] = testProxyDelay(ctx, target.Name, target.Url, params.Timeout)
		}(i, target)
	}
	wg.Wait()
	return results
}

func handleAsyncTestDelays(paramsString string, fn func(string)) {
	var params testDelaysParams
	if err := json.Unmarshal([]byte(paramsString), &params); err != nil {
		fn("[]")
		return
	}
	for i := range params.Targets {
		params.Targets[i].Url = delayTestURL(params.Targets[i].Url)
	}
	ctx, batch := startDelayBatch(params.Targets)
	go func() {
		delayPushLock.Lock()
		forcedDelayPush++
		delayPushLock.Unlock()
		results := testDelays(ctx, params)
		finishDelayBatch(batch)
		delayPushLock.Lock()
		forcedDelayPush--
		delayPushLock.Unlock()
		flushDelays()
		data, err := json.Marshal(results)
		if err != nil {
			fn("[]")
			return
		}
		fn(string(data))
	}()
}
