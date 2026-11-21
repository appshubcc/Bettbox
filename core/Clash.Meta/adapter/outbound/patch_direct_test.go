package outbound

import (
	"errors"
	"net"
	"testing"
)

func TestListenPacketAvoidSrcPort(t *testing.T) {
	first, err := net.ListenPacket("udp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	ownPort := uint16(first.LocalAddr().(*net.UDPAddr).Port)

	second, err := net.ListenPacket("udp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	otherActivePort := uint16(second.LocalAddr().(*net.UDPAddr).Port)
	acquireDirectSrcPort(otherActivePort)
	defer releaseDirectSrcPort(otherActivePort)

	calls := 0
	pc, err := listenPacketAvoidSrcPort(func() (net.PacketConn, error) {
		calls++
		switch calls {
		case 1:
			return first, nil
		case 2:
			return second, nil
		default:
			return net.ListenPacket("udp", "127.0.0.1:0")
		}
	}, ownPort)
	if err != nil {
		t.Fatal(err)
	}
	defer pc.Close()

	if calls != 3 {
		t.Fatalf("expected 3 listen calls (skipping ownPort and otherActivePort), got %d", calls)
	}
	got := uint16(pc.LocalAddr().(*net.UDPAddr).Port)
	if got == ownPort || got == otherActivePort {
		t.Fatalf("expected non-colliding port, got %d", got)
	}
	if _, err := first.WriteTo([]byte("x"), first.LocalAddr()); !errors.Is(err, net.ErrClosed) {
		t.Fatalf("expected first colliding socket to be closed, got %v", err)
	}
	if _, err := second.WriteTo([]byte("x"), second.LocalAddr()); !errors.Is(err, net.ErrClosed) {
		t.Fatalf("expected second colliding socket to be closed, got %v", err)
	}
}
