package singledo

import "time"

func (s *Single[T]) ForgetAfter(age time.Duration, stale func(T) bool) {
	s.mux.Lock()
	defer s.mux.Unlock()
	if s.result != nil && time.Since(s.result.Time) >= age && stale(s.result.Val) {
		s.result = nil
	}
}
