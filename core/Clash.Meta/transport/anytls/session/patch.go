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
