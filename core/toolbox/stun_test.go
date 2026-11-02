package toolbox

import (
	"context"
	"encoding/binary"
	"net"
	"net/netip"
	"testing"
	"time"
)

type fakeStunServer struct {
	primary    *net.UDPConn
	secondary  *net.UDPConn
	noOther    bool
	ignoreFlag bool
	silent     bool
}

func newFakeStunServer(t *testing.T, options ...func(*fakeStunServer)) *fakeStunServer {
	t.Helper()
	listen := func() *net.UDPConn {
		conn, err := net.ListenUDP("udp4", &net.UDPAddr{IP: net.IPv4(127, 0, 0, 1)})
		if err != nil {
			t.Fatal(err)
		}
		t.Cleanup(func() { conn.Close() })
		return conn
	}
	server := &fakeStunServer{primary: listen(), secondary: listen()}
	for _, option := range options {
		option(server)
	}
	go server.serve()
	return server
}

func (s *fakeStunServer) addr() string { return s.primary.LocalAddr().String() }

func stunAddressAttr(kind uint16, addr netip.AddrPort, xor bool) []byte {
	attr := make([]byte, 12)
	binary.BigEndian.PutUint16(attr[0:], kind)
	binary.BigEndian.PutUint16(attr[2:], 8)
	attr[5] = 0x01
	port := addr.Port()
	ip := addr.Addr().As4()
	if xor {
		port ^= 0x2112
		ip[0] ^= 0x21
		ip[1] ^= 0x12
		ip[2] ^= 0xA4
		ip[3] ^= 0x42
	}
	binary.BigEndian.PutUint16(attr[6:], port)
	copy(attr[8:], ip[:])
	return attr
}

func (s *fakeStunServer) serve() {
	buf := make([]byte, 1500)
	for {
		n, from, err := s.primary.ReadFromUDP(buf)
		if err != nil {
			return
		}
		if s.silent || n < 20 {
			continue
		}
		var flags byte
		if n >= 28 && binary.BigEndian.Uint16(buf[20:]) == stunAttrChangeRequest {
			flags = buf[27]
		}
		if flags != 0 && s.ignoreFlag {
			continue
		}
		var body []byte
		body = append(body, stunAddressAttr(stunAttrXorMapped, from.AddrPort(), true)...)
		if !s.noOther {
			body = append(body, stunAddressAttr(stunAttrOther, s.secondary.LocalAddr().(*net.UDPAddr).AddrPort(), false)...)
		}
		reply := make([]byte, 20, 20+len(body))
		reply[0], reply[1] = 0x01, 0x01
		binary.BigEndian.PutUint16(reply[2:], uint16(len(body)))
		copy(reply[4:], buf[4:20])
		reply = append(reply, body...)
		out := s.primary
		if flags != 0 {
			out = s.secondary
		}
		_, _ = out.WriteToUDP(reply, from)
	}
}

func runNat(t *testing.T, server *fakeStunServer) StunTestState {
	t.Helper()
	tester := newNatTester(StunTestParams{Server: server.addr()}, true)
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	tester.run(ctx)
	return tester.snapshot()
}

func TestNatDetectsBehaviour(t *testing.T) {
	state := runNat(t, newFakeStunServer(t))
	if state.Error != "" || state.Phase != stunPhaseDone {
		t.Fatalf("unexpected %+v", state)
	}
	if state.ExternalIP != "127.0.0.1" || state.ExternalPort == 0 || !state.Supported {
		t.Fatalf("binding wrong %+v", state)
	}
	if state.Mapping != natMappingIndependent || state.Filtering != natMappingIndependent {
		t.Fatalf("behaviour wrong %+v", state)
	}
	if !state.Public || state.NatType != natTypeOpen || state.PortPreserved != 1 {
		t.Fatalf("expected open internet %+v", state)
	}
	if state.Latency < 0 || state.PacketLoss != 0 {
		t.Fatalf("quality wrong %+v", state)
	}
}

func TestNatFilteringAndUnsupportedServer(t *testing.T) {
	server := newFakeStunServer(t, func(s *fakeStunServer) { s.ignoreFlag = true })
	state := runNat(t, server)
	if state.Filtering != natMappingAddressPort || state.Mapping != natMappingIndependent {
		t.Fatalf("filtering wrong %+v", state)
	}

	plain := newFakeStunServer(t, func(s *fakeStunServer) { s.noOther = true })
	state = runNat(t, plain)
	if state.Supported || state.Error != "" || state.Phase != stunPhaseDone || state.ExternalPort == 0 {
		t.Fatalf("plain server wrong %+v", state)
	}
}

func TestNatBlockedAndCancelled(t *testing.T) {
	server := newFakeStunServer(t, func(s *fakeStunServer) { s.silent = true })
	state := runNat(t, server)
	if state.NatType != natTypeBlocked || state.Error != "" {
		t.Fatalf("expected blocked %+v", state)
	}

	live := newFakeStunServer(t)
	tester := newNatTester(StunTestParams{Server: live.addr()}, true)
	ctx, cancel := context.WithCancel(context.Background())
	time.AfterFunc(150*time.Millisecond, cancel)
	tester.run(ctx)
	if got := tester.snapshot().Error; got != stunErrorCancelled {
		t.Fatalf("expected cancelled, got %q", got)
	}
}

func TestClassifyNat(t *testing.T) {
	cases := []struct {
		public          bool
		mapping, filter string
		want            string
	}{
		{true, "", "", natTypeOpen},
		{false, natMappingIndependent, natMappingIndependent, natTypeFullCone},
		{false, natMappingIndependent, natMappingAddress, natTypeRestricted},
		{false, natMappingIndependent, natMappingAddressPort, natTypePortRestricted},
		{false, natMappingAddressPort, natMappingAddressPort, natTypeSymmetric},
		{false, natMappingDependent, "", natTypeSymmetric},
		{false, natMappingIndependent, "", natTypeCone},
		{false, "", "", natTypeUnknown},
	}
	for _, item := range cases {
		if got := classifyNat(item.public, item.mapping, item.filter); got != item.want {
			t.Fatalf("%+v got %s", item, got)
		}
	}
}

func TestNatReleasesResources(t *testing.T) {
	server := newFakeStunServer(t)
	baseline := collectSpeedTestResources()
	for range 3 {
		runNat(t, server)
	}
	after := waitSpeedTestReleased(baseline)
	if after.goroutines > baseline.goroutines {
		t.Fatalf("goroutines leaked %d -> %d", baseline.goroutines, after.goroutines)
	}
}

func TestStunRoundTrip(t *testing.T) {
	packet, id := newStunRequestFlags(0)
	if len(packet) != 20 || packet[0] != 0 || packet[1] != 1 {
		t.Fatalf("unexpected request %x", packet)
	}
	response := append([]byte{}, packet...)
	response[0] = 0x01
	got, ok := parseStunResponse(response)
	if !ok || got != id {
		t.Fatalf("parseStunResponse = %x %v", got, ok)
	}
	if _, ok := parseStunResponse(packet); ok {
		t.Fatal("request should not parse as response")
	}
}
