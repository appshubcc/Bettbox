package gun

import "testing"

func newTestClient() *Client {
	return NewClient(func() *Transport {
		return NewTransport(nil, nil, &Config{})
	}, 0, 0, 0)
}

func TestClientCloseIdleDropsIdleTransports(t *testing.T) {
	c := newTestClient()
	first := c.getTransport()
	c.CloseIdle()
	if len(c.transports) != 0 {
		t.Fatalf("idle transport kept: %d", len(c.transports))
	}
	if first.ctx.Err() == nil {
		t.Fatal("idle transport not closed")
	}
	if c.getTransport() == first {
		t.Fatal("closed transport reused")
	}
}

func TestClientCloseIdleKeepsBusyTransports(t *testing.T) {
	c := newTestClient()
	busy := c.getTransport()
	busy.count.Add(1)
	c.CloseIdle()
	if len(c.transports) != 1 || c.transports[0] != busy {
		t.Fatal("busy transport dropped")
	}
	if busy.ctx.Err() != nil {
		t.Fatal("busy transport closed")
	}
}
