package sing_tun

import (
	"bytes"
	"encoding/binary"
	"net/netip"
	"testing"
)

func TestBuildICMPUnreachableIPv4(t *testing.T) {
	src := netip.MustParseAddrPort("198.18.0.1:54321")
	dst := netip.MustParseAddrPort("198.18.0.2:443")
	pkt := buildICMPUnreachableIPv4(src, dst, 100)

	if len(pkt) != 56 {
		t.Fatalf("expected 56 bytes, got %d", len(pkt))
	}
	if pkt[0] != 0x45 {
		t.Errorf("expected IPv4 version 4, got 0x%x", pkt[0])
	}
	if pkt[9] != 1 {
		t.Errorf("expected protocol ICMP(1), got %d", pkt[9])
	}
	if pkt[20] != 3 || pkt[21] != 3 {
		t.Errorf("expected ICMP type 3 code 3, got type %d code %d", pkt[20], pkt[21])
	}
	if binary.BigEndian.Uint16(pkt[48:50]) != 54321 {
		t.Errorf("expected orig src port 54321, got %d", binary.BigEndian.Uint16(pkt[48:50]))
	}
	if binary.BigEndian.Uint16(pkt[50:52]) != 443 {
		t.Errorf("expected orig dst port 443, got %d", binary.BigEndian.Uint16(pkt[50:52]))
	}
	if c := checksum(0, pkt[:20]); c != 0 {
		t.Errorf("ip checksum verification failed, got 0x%x", c)
	}
	if c := checksum(0, pkt[20:56]); c != 0 {
		t.Errorf("icmp checksum verification failed, got 0x%x", c)
	}
}

func TestBuildICMPUnreachableIPv6(t *testing.T) {
	src := netip.MustParseAddrPort("[fd00::1]:54321")
	dst := netip.MustParseAddrPort("[fd00::2]:443")
	pkt := buildICMPUnreachableIPv6(src, dst, 100)

	if len(pkt) != 96 {
		t.Fatalf("expected 96 bytes, got %d", len(pkt))
	}
	if pkt[0] != 0x60 {
		t.Errorf("expected IPv6 version 6, got 0x%x", pkt[0])
	}
	if pkt[6] != 58 {
		t.Errorf("expected next header ICMPv6(58), got %d", pkt[6])
	}
	if pkt[40] != 1 || pkt[41] != 4 {
		t.Errorf("expected ICMPv6 type 1 code 4, got type %d code %d", pkt[40], pkt[41])
	}
	if binary.BigEndian.Uint16(pkt[88:90]) != 54321 {
		t.Errorf("expected orig src port 54321, got %d", binary.BigEndian.Uint16(pkt[88:90]))
	}
	if binary.BigEndian.Uint16(pkt[90:92]) != 443 {
		t.Errorf("expected orig dst port 443, got %d", binary.BigEndian.Uint16(pkt[90:92]))
	}
}

func TestSendICMPUnreachable(t *testing.T) {
	var buf bytes.Buffer
	src := netip.MustParseAddrPort("198.18.0.1:12345")
	dst := netip.MustParseAddrPort("198.18.0.2:443")
	err := sendICMPUnreachable(&buf, src, dst, 64)
	if err != nil {
		t.Fatal(err)
	}
	if buf.Len() != 56 {
		t.Fatalf("expected 56 bytes written, got %d", buf.Len())
	}
}
