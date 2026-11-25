package session

import "sync/atomic"

type dieError struct {
	err atomic.Pointer[error]
}

func (e *dieError) Store(err error) {
	e.err.Store(&err)
}

func (e *dieError) Load() error {
	if err := e.err.Load(); err != nil {
		return *err
	}
	return nil
}
