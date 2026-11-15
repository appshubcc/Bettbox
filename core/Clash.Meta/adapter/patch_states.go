package adapter

import (
	"sync"
	"time"

	"github.com/metacubex/mihomo/common/atomic"
	C "github.com/metacubex/mihomo/constant"
)

const maxSlotMillis = (1 << 48) - 1

type delaySlot struct {
	packed atomic.Uint64
}

func decodeSlot(v uint64) C.DelayHistory {
	var t time.Time
	if ms := int64(v >> 16); ms > 0 {
		t = time.UnixMilli(ms)
	}
	return C.DelayHistory{
		Time:  t,
		Delay: uint16(v),
	}
}

func (s *delaySlot) Put(items ...C.DelayHistory) {
	if len(items) == 0 {
		return
	}
	last := items[len(items)-1]
	var ms uint64
	if !last.Time.IsZero() {
		raw := last.Time.UnixMilli()
		if raw > 0 {
			if raw > maxSlotMillis {
				raw = maxSlotMillis
			}
			ms = uint64(raw)
		}
	}
	s.packed.Store((ms << 16) | uint64(last.Delay))
}

func (s *delaySlot) Pop() C.DelayHistory {
	return s.Last()
}

func (s *delaySlot) Len() int64 {
	if s.packed.Load() == 0 {
		return 0
	}
	return 1
}

func (s *delaySlot) Last() C.DelayHistory {
	v := s.packed.Load()
	if v == 0 {
		return C.DelayHistory{}
	}
	return decodeSlot(v)
}

func (s *delaySlot) Copy() []C.DelayHistory {
	v := s.packed.Load()
	if v == 0 {
		return nil
	}
	return []C.DelayHistory{decodeSlot(v)}
}

type proxyStates struct {
	mu     sync.RWMutex
	states map[string]*internalProxyState
}

func (s *proxyStates) Load(url string) (*internalProxyState, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	state, ok := s.states[url]
	return state, ok
}

func (s *proxyStates) LoadOrStoreFn(url string, valueFn func() *internalProxyState) (*internalProxyState, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if state, ok := s.states[url]; ok {
		return state, true
	}
	if s.states == nil {
		s.states = make(map[string]*internalProxyState, 1)
	}
	state := valueFn()
	s.states[url] = state
	return state, false
}

func (s *proxyStates) Range(f func(url string, state *internalProxyState) bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for url, state := range s.states {
		if !f(url, state) {
			return
		}
	}
}

func (p *Proxy) LastTestTime(url string) time.Time {
	if state, ok := p.extra.Load(url); ok {
		return state.history.Last().Time
	}
	return time.Time{}
}
