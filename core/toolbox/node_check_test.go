package toolbox

import (
	"strings"
	"testing"
)

func TestHandleTestNodeInvalid(t *testing.T) {
	if got := HandleTestNode(`{"proxy":{"name":"x","type":"nope"}}`); got == `{"delay":0,"error":""}` {
		t.Errorf("invalid proxy must report an error: %s", got)
	}
}

func TestHandleTestNodeMissingFront(t *testing.T) {
	got := HandleTestNode(`{"proxy":{"name":"x","type":"socks5","server":"127.0.0.1","port":1},"dialer":"absent"}`)
	if !strings.Contains(got, "front absent not found") {
		t.Errorf("missing front must be reported: %s", got)
	}
}
