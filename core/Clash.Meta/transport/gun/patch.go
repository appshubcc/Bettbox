package gun

func (c *Client) CloseIdle() {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	kept := c.transports[:0]
	for _, t := range c.transports {
		if t.count.Load() > 0 {
			kept = append(kept, t)
			continue
		}
		_ = t.Close()
	}
	for i := len(kept); i < len(c.transports); i++ {
		c.transports[i] = nil
	}
	c.transports = kept
}
