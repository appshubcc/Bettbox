package adapter

import (
	"sync"
	"time"
)

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
		if items := state.history.Copy(); len(items) > 0 {
			return items[len(items)-1].Time
		}
	}
	return time.Time{}
}
