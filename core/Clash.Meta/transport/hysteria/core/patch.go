package core

func (c *Client) CloseSession() {
	c.reconnectMutex.Lock()
	defer c.reconnectMutex.Unlock()
	if c.quicSession != nil {
		_ = c.quicSession.CloseWithError(closeErrorCodeGeneric, "")
		c.quicSession = nil
	}
}
