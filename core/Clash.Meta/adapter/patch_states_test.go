package adapter

import (
	"strconv"
	"sync"
	"testing"

	"github.com/metacubex/mihomo/common/atomic"
	"github.com/metacubex/mihomo/common/queue"
	C "github.com/metacubex/mihomo/constant"
)

func newTestState() *internalProxyState {
	return &internalProxyState{
		history: queue.New[C.DelayHistory](defaultHistoriesNum),
		alive:   atomic.NewBool(true),
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
