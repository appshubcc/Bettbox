package adapter

import (
	"strconv"
	"sync"
	"testing"
	"time"

	"github.com/metacubex/mihomo/common/atomic"
	C "github.com/metacubex/mihomo/constant"
)

func newTestState() *internalProxyState {
	return &internalProxyState{
		alive: atomic.NewBool(true),
	}
}

func TestDelaySlotLifecycle(t *testing.T) {
	var slot delaySlot
	if slot.Len() != 0 {
		t.Fatalf("empty slot Len = %d, want 0", slot.Len())
	}
	if slot.Copy() != nil {
		t.Fatal("empty slot Copy should be nil")
	}
	now := time.Now().Truncate(time.Millisecond)
	slot.Put(C.DelayHistory{Time: now, Delay: 128})
	if slot.Len() != 1 {
		t.Fatalf("slot Len = %d, want 1", slot.Len())
	}
	last := slot.Last()
	if !last.Time.Equal(now) || last.Delay != 128 {
		t.Fatalf("slot Last = %+v, want Time=%v Delay=128", last, now)
	}
	copied := slot.Copy()
	if len(copied) != 1 || copied[0].Delay != 128 {
		t.Fatalf("slot Copy = %+v", copied)
	}
	slot.Put(C.DelayHistory{Time: now, Delay: 0})
	if slot.Len() != 1 {
		t.Fatalf("failed slot Len = %d, want 1", slot.Len())
	}
	if got := slot.Last(); !got.Time.Equal(now) || got.Delay != 0 {
		t.Fatalf("failed slot Last = %+v, want Time=%v Delay=0", got, now)
	}
	slot.Put(C.DelayHistory{Delay: 64})
	if got := slot.Last(); !got.Time.IsZero() || got.Delay != 64 {
		t.Fatalf("zero-time slot Last = %+v, want zero Time Delay=64", got)
	}
}

func TestProxyStatesLoadOrStore(t *testing.T) {
	var states proxyStates
	if _, ok := states.Load("a"); ok {
		t.Fatal("empty states loaded a value")
	}
	first, loaded := states.LoadOrStoreFn("a", newTestState)
	if loaded {
		t.Fatal("first store reported loaded")
	}
	second, loaded := states.LoadOrStoreFn("a", func() *internalProxyState {
		t.Fatal("value function called for existing key")
		return nil
	})
	if !loaded || second != first {
		t.Fatal("existing state not returned")
	}
	if got, ok := states.Load("a"); !ok || got != first {
		t.Fatal("load did not return stored state")
	}
}

func TestProxyStatesRange(t *testing.T) {
	var states proxyStates
	for i := 0; i < 3; i++ {
		states.LoadOrStoreFn(strconv.Itoa(i), newTestState)
	}
	seen := 0
	states.Range(func(string, *internalProxyState) bool {
		seen++
		return true
	})
	if seen != 3 {
		t.Fatalf("seen = %d, want 3", seen)
	}
	seen = 0
	states.Range(func(string, *internalProxyState) bool {
		seen++
		return false
	})
	if seen != 1 {
		t.Fatalf("seen = %d, want 1", seen)
	}
}

func TestProxyStatesConcurrent(t *testing.T) {
	var states proxyStates
	var wg sync.WaitGroup
	for i := 0; i < 16; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			url := strconv.Itoa(i % 4)
			state, _ := states.LoadOrStoreFn(url, newTestState)
			state.alive.Store(i%2 == 0)
			state.history.Put(C.DelayHistory{Time: time.Now(), Delay: uint16(i + 1)})
			_ = state.history.Last()
			states.Load(url)
			states.Range(func(string, *internalProxyState) bool {
				return true
			})
		}(i)
	}
	wg.Wait()
	count := 0
	states.Range(func(string, *internalProxyState) bool {
		count++
		return true
	})
	if count != 4 {
		t.Fatalf("count = %d, want 4", count)
	}
}
