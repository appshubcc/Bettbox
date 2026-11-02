package main

import (
	"testing"
	"time"

	"github.com/metacubex/mihomo/constant"
)

func pendingDelayCount() int {
	delayPushLock.Lock()
	defer delayPushLock.Unlock()
	return len(pendingDelays)
}

func TestDelayPushFollowsForeground(t *testing.T) {
	defer handleSetForeground(true)
	handleSetForeground(false)
	pushDelay(Delay{Url: "u", Name: "A", Value: 10})
	pushDelay(Delay{Url: "u", Name: "A", Value: 20})
	pushDelay(Delay{Url: "u", Name: "B", Value: -1})
	time.Sleep(delayFlushInterval * 2)
	if count := pendingDelayCount(); count != 2 {
		t.Fatalf("pending in background = %d, want 2", count)
	}
	delayPushLock.Lock()
	value := pendingDelays[delayKey{url: "u", name: "A"}].Value
	timerArmed := delayFlushTimer != nil
	delayPushLock.Unlock()
	if value != 20 || timerArmed {
		t.Fatalf("latest = %d, timer armed = %v", value, timerArmed)
	}
	handleSetForeground(true)
	if count := pendingDelayCount(); count != 0 {
		t.Fatalf("pending after foreground = %d", count)
	}
	pushDelay(Delay{Url: "u", Name: "C", Value: 5})
	time.Sleep(delayFlushInterval * 3)
	if count := pendingDelayCount(); count != 0 {
		t.Fatalf("pending after flush = %d", count)
	}
}

func TestExplicitDelayTestsBypassBackground(t *testing.T) {
	defer handleSetForeground(true)
	handleSetForeground(false)
	results := make(chan string, 1)
	handleAsyncTestDelays(`{"targets":[{"name":"missing-a","url":"https://example.com/204"},{"name":"missing-b","url":""}],"timeout":100,"concurrency":4}`, func(value string) {
		results <- value
	})
	select {
	case value := <-results:
		want := `[{"url":"https://example.com/204","name":"missing-a","value":-1},{"url":"` + constant.DefaultTestURL + `","name":"missing-b","value":-1}]`
		if value != want {
			t.Fatalf("results = %s, want %s", value, want)
		}
	case <-time.After(5 * time.Second):
		t.Fatal("batch did not finish")
	}
	delayPushLock.Lock()
	forced := forcedDelayPush
	delayPushLock.Unlock()
	if forced != 0 {
		t.Fatalf("forced = %d", forced)
	}
}

func TestGroupsChangedIsSentOncePerFetch(t *testing.T) {
	defer resetDelayState()
	resetDelayState()
	if checkGroupsChanged() {
		t.Fatal("changed without a baseline")
	}
	rememberGroupNows(map[string]string{"missing": "A"})
	if !checkGroupsChanged() {
		t.Fatal("missing group not reported")
	}
	if checkGroupsChanged() {
		t.Fatal("reported twice before the next fetch")
	}
	rememberGroupNows(map[string]string{})
	if checkGroupsChanged() {
		t.Fatal("empty baseline reported a change")
	}
}

func TestResetDropsStaleBatchDelays(t *testing.T) {
	defer handleSetForeground(true)
	defer resetDelayState()
	handleSetForeground(false)
	resetDelayState()
	_, stale := startDelayBatch([]delayTarget{{Name: "A", Url: "u"}})
	cancelDelayBatches()
	_, fresh := startDelayBatch([]delayTarget{{Name: "B", Url: "u"}})
	pushDelay(Delay{Url: "u", Name: "A", Value: 10})
	pushDelay(Delay{Url: "u", Name: "B", Value: 20})
	delayPushLock.Lock()
	_, hasStale := pendingDelays[delayKey{url: "u", name: "A"}]
	_, hasFresh := pendingDelays[delayKey{url: "u", name: "B"}]
	delayPushLock.Unlock()
	if hasStale || !hasFresh {
		t.Fatalf("stale pushed = %v, fresh pushed = %v", hasStale, hasFresh)
	}
	finishDelayBatch(stale)
	finishDelayBatch(fresh)
	if isStaleDelay(delayKey{url: "u", name: "A"}) {
		t.Fatal("stale mark kept after the batch finished")
	}
}

func TestCanceledBatchStopsLaunchingTests(t *testing.T) {
	defer resetDelayState()
	ctx, batch := startDelayBatch(nil)
	cancelDelayBatches()
	results := testDelays(ctx, testDelaysParams{
		Targets:     []delayTarget{{Name: "missing-a", Url: "u"}, {Name: "missing-b", Url: "u"}},
		Timeout:     100,
		Concurrency: 1,
	})
	finishDelayBatch(batch)
	if len(results) != 2 || results[0].Value != -1 || results[1].Name != "missing-b" {
		t.Fatalf("results = %+v", results)
	}
}
