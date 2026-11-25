package session

import (
	"github.com/metacubex/mihomo/transport/anytls/skiplist"
	"github.com/metacubex/mihomo/transport/anytls/util"
)

func (c *Client) startIdleCleanup() {
	c.idleCleanupOnce.Do(func() {
		c.idleSessionLock.Lock()
		c.idleSession = skiplist.NewSkipList[uint64, *Session]()
		c.idleSessionLock.Unlock()
		if !c.disableReuse {
			util.StartRoutine(c.die, c.idleSessionCheckInterval, c.idleCleanup)
		}
	})
}

func (c *Client) CloseIdle() {
	c.idleSessionLock.Lock()
	if c.idleSession == nil || c.idleSession.IsEmpty() {
		c.idleSessionLock.Unlock()
		return
	}
	sessionToClose := make([]*Session, 0, c.idleSession.Len())
	c.idleSession.ForEach(func(_ uint64, session *Session) {
		sessionToClose = append(sessionToClose, session)
	})
	c.idleSession.Clear()
	c.idleSessionLock.Unlock()

	for _, session := range sessionToClose {
		session.Close()
	}
}
