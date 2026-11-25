package anytls

func (c *Client) CloseIdle() {
	c.sessionClient.CloseIdle()
}
