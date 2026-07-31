package sniffer

import (
	"net"
	"net/netip"
	"sync/atomic"
	"testing"

	N "github.com/metacubex/mihomo/common/net"
	C "github.com/metacubex/mihomo/constant"
	CS "github.com/metacubex/mihomo/constant/sniffer"
	"github.com/stretchr/testify/require"
)

type noInitialDataSniffer struct{}

func (*noInitialDataSniffer) SupportNetwork() C.NetWork { return C.TCP }
func (*noInitialDataSniffer) SniffData([]byte) (string, error) {
	return "", ErrNoClue
}
func (*noInitialDataSniffer) Protocol() string        { return "test" }
func (*noInitialDataSniffer) SupportPort(uint16) bool { return true }

type closeTrackingConn struct {
	net.Conn
	closed atomic.Bool
}

func (c *closeTrackingConn) Close() error {
	c.closed.Store(true)
	return c.Conn.Close()
}

func TestInitialReadFailureKeepsConnectionOpen(t *testing.T) {
	dispatcher, err := NewDispatcher(&Config{
		Enable:      true,
		ParsePureIp: true,
	})
	require.NoError(t, err)
	dispatcher.sniffers = map[CS.Sniffer]SnifferConfig{
		&noInitialDataSniffer{}: {},
	}

	client, server := net.Pipe()
	tracked := &closeTrackingConn{Conn: client}
	t.Cleanup(func() {
		_ = tracked.Close()
		_ = server.Close()
	})

	metadata := &C.Metadata{
		NetWork: C.TCP,
		DstIP:   netip.MustParseAddr("192.0.2.1"),
		DstPort: 80,
	}

	sniffed := dispatcher.TCPSniff(N.NewBufferedConn(tracked), metadata)

	require.False(t, sniffed)
	require.False(t, tracked.closed.Load())
	failures, cached := dispatcher.skipList.Get(metadata.AddrPort())
	require.True(t, cached)
	require.Equal(t, uint8(1), failures)
}
