package tunnel

import (
	"net/netip"
	"testing"

	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
)

type rejectPacket struct {
	C.PacketAdapter
	rejected int
	dropped  int
}

func (p *rejectPacket) Reject() error {
	p.rejected++
	return nil
}

func (p *rejectPacket) Drop() {
	p.dropped++
}

func TestShouldRejectIPv6UDP(t *testing.T) {
	previous := resolver.DisableIPv6
	defer func() { resolver.DisableIPv6 = previous }()

	cases := []struct {
		name    string
		disable bool
		typ     C.Type
		dst     string
		want    bool
	}{
		{"global v6 on tun", true, C.TUN, "2409:8a31:5e3::1", true},
		{"global v6 with ipv6 enabled", false, C.TUN, "2409:8a31:5e3::1", false},
		{"global v6 on other inbound", true, C.SOCKS5, "2409:8a31:5e3::1", false},
		{"ipv4", true, C.TUN, "1.1.1.1", false},
		{"ipv4 mapped", true, C.TUN, "::ffff:1.1.1.1", false},
		{"unique local", true, C.TUN, "fd12:3456::1", false},
		{"link local", true, C.TUN, "fe80::1", false},
		{"multicast", true, C.TUN, "ff02::fb", false},
		{"loopback", true, C.TUN, "::1", false},
		{"no destination ip", true, C.TUN, "", false},
	}
	for _, item := range cases {
		t.Run(item.name, func(t *testing.T) {
			resolver.DisableIPv6 = item.disable
			metadata := &C.Metadata{Type: item.typ}
			if item.dst != "" {
				metadata.DstIP = netip.MustParseAddr(item.dst)
			}
			if got := shouldRejectIPv6UDP(metadata); got != item.want {
				t.Fatalf("got %v, want %v", got, item.want)
			}
		})
	}
}

func TestRejectIPv6UDP(t *testing.T) {
	packet := &rejectPacket{}
	rejectIPv6UDP(packet)
	if packet.rejected != 1 || packet.dropped != 1 {
		t.Fatalf("rejected=%d dropped=%d, want 1 and 1", packet.rejected, packet.dropped)
	}
}
