package toolbox

import (
	"context"
	"crypto/rand"
	"encoding/binary"
	"encoding/json"
	"errors"
	"net"
	"net/netip"
	"sync"
	"time"

	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

const (
	stunInbound = "NatTest"

	stunAttrMapped         = 0x0001
	stunAttrChangeRequest  = 0x0003
	stunAttrChanged        = 0x0005
	stunAttrXorMapped      = 0x0020
	stunAttrSoftware       = 0x8022
	stunAttrResponseOrigin = 0x802b
	stunAttrOther          = 0x802c

	stunChangeIP   byte = 0x04
	stunChangePort byte = 0x02

	stunBurstPackets  = 50
	stunBurstInterval = 20 * time.Millisecond
	stunBurstWait     = 1500 * time.Millisecond
)

const (
	stunPhaseConnecting = "connecting"
	stunPhaseBinding    = "binding"
	stunPhaseFiltering  = "filtering"
	stunPhaseMapping    = "mapping"
	stunPhaseDone       = "done"
)

const (
	stunErrorUnsupported = "unsupported"
	stunErrorUnavailable = "unavailable"
	stunErrorCancelled   = "cancelled"
)

const (
	natMappingIndependent = "independent"
	natMappingAddress     = "address"
	natMappingAddressPort = "address-port"
	natMappingDependent   = "dependent"

	natTypeOpen           = "open"
	natTypeFullCone       = "full-cone"
	natTypeRestricted     = "restricted"
	natTypePortRestricted = "port-restricted"
	natTypeSymmetric      = "symmetric"
	natTypeCone           = "cone"
	natTypeBlocked        = "blocked"
	natTypeUnknown        = "unknown"
)

var stunFallbackServers = []string{"stun.cloudflare.com:3478", "stun.l.google.com:19302", "stun.miwifi.com:3478"}

type StunTestParams struct {
	Server string `json:"server"`
	Proxy  string `json:"proxy"`
}

type StunTestState struct {
	Phase         string             `json:"phase"`
	Progress      float64            `json:"progress"`
	Server        string             `json:"server"`
	Address       string             `json:"address"`
	Direct        bool               `json:"direct"`
	Outbound      *SpeedTestOutbound `json:"outbound,omitempty"`
	NatType       string             `json:"nat-type"`
	Mapping       string             `json:"mapping"`
	Filtering     string             `json:"filtering"`
	Public        bool               `json:"public"`
	Supported     bool               `json:"rfc5780"`
	ExternalIP    string             `json:"external-ip"`
	ExternalPort  int                `json:"external-port"`
	LocalIP       string             `json:"local-ip"`
	LocalPort     int                `json:"local-port"`
	PortPreserved int                `json:"port-preserved"`
	OtherAddress  string             `json:"other-address"`
	Software      string             `json:"software"`
	Latency       float64            `json:"latency"`
	Jitter        float64            `json:"jitter"`
	PacketLoss    float64            `json:"packet-loss"`
	Error         string             `json:"error"`
}

var (
	stunLock   sync.Mutex
	stunCancel context.CancelFunc
	stunSerial uint64
)

type stunReply struct {
	mapped   netip.AddrPort
	other    netip.AddrPort
	software string
}

type stunPacket struct {
	id   [12]byte
	data []byte
	at   time.Time
}

type stunSocket struct {
	pc      net.PacketConn
	replies chan stunPacket
	done    chan struct{}
}

func newStunSocket(pc net.PacketConn) *stunSocket {
	s := &stunSocket{pc: pc, replies: make(chan stunPacket, 64), done: make(chan struct{})}
	go func() {
		defer close(s.done)
		buf := make([]byte, 1500)
		for {
			n, _, err := pc.ReadFrom(buf)
			if err != nil {
				return
			}
			id, ok := parseStunResponse(buf[:n])
			if !ok {
				continue
			}
			packet := stunPacket{id: id, data: append([]byte{}, buf[:n]...), at: time.Now()}
			select {
			case s.replies <- packet:
			default:
			}
		}
	}()
	return s
}

func (s *stunSocket) close() {
	_ = s.pc.SetReadDeadline(time.Now())
	_ = s.pc.Close()
	<-s.done
}

var errStunNoReply = errors.New("stun: no reply")

func (s *stunSocket) exchange(ctx context.Context, dst net.Addr, flags byte, wait time.Duration, attempts int) (*stunReply, time.Duration, error) {
	pending := map[[12]byte]time.Time{}
	for range attempts {
		packet, id := newStunRequestFlags(flags)
		sentAt := time.Now()
		pending[id] = sentAt
		if _, err := s.pc.WriteTo(packet, dst); err != nil {
			return nil, 0, err
		}
		timer := time.NewTimer(wait)
	wait:
		for {
			select {
			case <-ctx.Done():
				timer.Stop()
				return nil, 0, ctx.Err()
			case <-timer.C:
				break wait
			case reply := <-s.replies:
				at, ok := pending[reply.id]
				if !ok {
					continue
				}
				timer.Stop()
				parsed, ok := parseStunReply(reply.data, reply.id)
				if !ok {
					continue
				}
				return parsed, reply.at.Sub(at), nil
			}
		}
	}
	return nil, 0, errStunNoReply
}

func (s *stunSocket) burst(ctx context.Context, dst net.Addr, onSent func(sent int)) (int, []float64) {
	pending := make(map[[12]byte]time.Time, stunBurstPackets)
	rtts := make([]float64, 0, stunBurstPackets)
	collect := func(reply stunPacket) {
		if sentAt, ok := pending[reply.id]; ok {
			delete(pending, reply.id)
			rtts = append(rtts, float64(reply.at.Sub(sentAt).Microseconds())/1000)
		}
	}
	sent := 0
	ticker := time.NewTicker(stunBurstInterval)
	defer ticker.Stop()
	for sent < stunBurstPackets {
		packet, id := newStunRequestFlags(0)
		pending[id] = time.Now()
		if _, err := s.pc.WriteTo(packet, dst); err != nil {
			delete(pending, id)
		} else {
			sent++
		}
		onSent(sent)
	tick:
		for {
			select {
			case <-ctx.Done():
				return sent, rtts
			case reply := <-s.replies:
				collect(reply)
			case <-ticker.C:
				break tick
			}
		}
	}
	wait := time.NewTimer(stunBurstWait)
	defer wait.Stop()
	for len(pending) > 0 {
		select {
		case <-ctx.Done():
			return sent, rtts
		case reply := <-s.replies:
			collect(reply)
		case <-wait.C:
			return sent, rtts
		}
	}
	return sent, rtts
}

func parseStunResponse(packet []byte) ([12]byte, bool) {
	var id [12]byte
	if len(packet) < 20 || packet[0] != 0x01 || packet[1] != 0x01 {
		return id, false
	}
	if packet[4] != 0x21 || packet[5] != 0x12 || packet[6] != 0xA4 || packet[7] != 0x42 {
		return id, false
	}
	copy(id[:], packet[8:20])
	return id, true
}

func newStunRequestFlags(flags byte) ([]byte, [12]byte) {
	var id [12]byte
	_, _ = rand.Read(id[:])
	size := 0
	if flags != 0 {
		size = 8
	}
	packet := make([]byte, 20+size)
	packet[1] = 0x01
	binary.BigEndian.PutUint16(packet[2:], uint16(size))
	packet[4], packet[5], packet[6], packet[7] = 0x21, 0x12, 0xA4, 0x42
	copy(packet[8:], id[:])
	if flags != 0 {
		binary.BigEndian.PutUint16(packet[20:], stunAttrChangeRequest)
		binary.BigEndian.PutUint16(packet[22:], 4)
		packet[27] = flags
	}
	return packet, id
}

func parseStunAddress(value []byte, xor bool) (netip.AddrPort, bool) {
	if len(value) < 8 || value[1] != 0x01 {
		return netip.AddrPort{}, false
	}
	port := binary.BigEndian.Uint16(value[2:4])
	ip := [4]byte{value[4], value[5], value[6], value[7]}
	if xor {
		port ^= 0x2112
		ip[0] ^= 0x21
		ip[1] ^= 0x12
		ip[2] ^= 0xA4
		ip[3] ^= 0x42
	}
	return netip.AddrPortFrom(netip.AddrFrom4(ip), port), true
}

func parseStunReply(packet []byte, id [12]byte) (*stunReply, bool) {
	if len(packet) < 20 {
		return nil, false
	}
	length := int(binary.BigEndian.Uint16(packet[2:4]))
	if len(packet) < 20+length {
		return nil, false
	}
	reply := &stunReply{}
	var plainMapped netip.AddrPort
	body := packet[20 : 20+length]
	for len(body) >= 4 {
		kind := binary.BigEndian.Uint16(body[0:2])
		size := int(binary.BigEndian.Uint16(body[2:4]))
		if len(body) < 4+size {
			break
		}
		value := body[4 : 4+size]
		switch kind {
		case stunAttrXorMapped:
			if addr, ok := parseStunAddress(value, true); ok {
				reply.mapped = addr
			}
		case stunAttrMapped:
			if addr, ok := parseStunAddress(value, false); ok {
				plainMapped = addr
			}
		case stunAttrOther, stunAttrChanged:
			if addr, ok := parseStunAddress(value, false); ok {
				reply.other = addr
			}
		case stunAttrSoftware:
			reply.software = string(value)
		}
		advance := 4 + (size+3)&^3
		if advance > len(body) {
			break
		}
		body = body[advance:]
	}
	if !reply.mapped.IsValid() {
		reply.mapped = plainMapped
	}
	return reply, reply.mapped.IsValid()
}

func classifyNat(public bool, mapping, filtering string) string {
	if public {
		return natTypeOpen
	}
	switch mapping {
	case natMappingAddress, natMappingAddressPort, natMappingDependent:
		return natTypeSymmetric
	case natMappingIndependent:
		switch filtering {
		case natMappingIndependent:
			return natTypeFullCone
		case natMappingAddress:
			return natTypeRestricted
		case natMappingAddressPort:
			return natTypePortRestricted
		}
		return natTypeCone
	}
	return natTypeUnknown
}

type natTester struct {
	params StunTestParams
	direct bool
	mu     sync.Mutex
	state  StunTestState
	notify func(StunTestState)
	listen func(ctx context.Context, proxy constant.Proxy, server string) (net.PacketConn, net.Addr, error)
}

func newNatTester(params StunTestParams, direct bool) *natTester {
	if params.Server == "" {
		params.Server = stunFallbackServers[0]
	}
	if params.Proxy == "DIRECT" {
		direct = true
	}
	return &natTester{
		params: params,
		direct: direct,
		state: StunTestState{
			Phase:         stunPhaseConnecting,
			Server:        params.Server,
			Direct:        direct,
			NatType:       natTypeUnknown,
			PortPreserved: -1,
			PacketLoss:    -1,
			Latency:       -1,
		},
		listen: func(ctx context.Context, proxy constant.Proxy, server string) (net.PacketConn, net.Addr, error) {
			return listenUDPVia(ctx, proxy, server, stunInbound)
		},
	}
}

func (n *natTester) update(fn func(state *StunTestState)) {
	n.mu.Lock()
	fn(&n.state)
	state := n.state
	n.mu.Unlock()
	if n.notify != nil {
		n.notify(state)
	}
}

func (n *natTester) snapshot() StunTestState {
	n.mu.Lock()
	defer n.mu.Unlock()
	return n.state
}

func (n *natTester) phase(phase string, progress float64) {
	n.update(func(state *StunTestState) {
		state.Phase = phase
		state.Progress = progress
	})
}

func (n *natTester) fail(ctx context.Context, code string) {
	if errors.Is(ctx.Err(), context.Canceled) {
		code = stunErrorCancelled
	}
	n.update(func(state *StunTestState) {
		state.Error = code
	})
}

func matchStunOutbound(host string, ip netip.Addr, port uint16) (constant.Proxy, *SpeedTestOutbound) {
	metadata := &constant.Metadata{
		NetWork: constant.UDP,
		Type:    constant.INNER,
		DNSMode: constant.DNSNormal,
		Process: constant.MihomoName,
		InName:  stunInbound,
		Host:    host,
		DstIP:   ip,
		DstPort: port,
	}
	helper := constant.RuleMatchHelper{
		ResolveIP:   func() {},
		FindProcess: func() {},
	}
	for _, rule := range tunnel.Rules() {
		matched, name := rule.Match(metadata, helper)
		if !matched {
			continue
		}
		proxy, ok := FindProxy(name)
		if !ok {
			continue
		}
		if !proxy.SupportUDP() {
			continue
		}
		return proxy, outboundOf(proxy, metadata, rule.RuleType().String(), rule.Payload())
	}
	if proxy, ok := FindProxy("DIRECT"); ok {
		return proxy, outboundOf(proxy, metadata, "Match", "")
	}
	return nil, nil
}

func outboundOf(proxy constant.Proxy, metadata *constant.Metadata, rule, payload string) *SpeedTestOutbound {
	chains := []string{}
	for current := proxy; current != nil; current = current.Unwrap(metadata, false) {
		chains = append(chains, current.Name())
		if len(chains) > 16 {
			break
		}
	}
	return &SpeedTestOutbound{Chains: chains, Rule: rule, RulePayload: payload}
}

func (n *natTester) resolveProxy(ctx context.Context) (constant.Proxy, error) {
	if n.direct {
		n.update(func(state *StunTestState) {
			state.Outbound = &SpeedTestOutbound{Chains: []string{"DIRECT"}}
		})
		return nil, nil
	}
	host, portText, err := net.SplitHostPort(n.params.Server)
	if err != nil {
		return nil, err
	}
	ip, _ := resolver.ResolveIPv4(ctx, host)
	port, _ := net.LookupPort("udp", portText)
	if n.params.Proxy != "" {
		proxy, ok := FindProxy(n.params.Proxy)
		if !ok {
			return nil, errSpeedTestProxyNotFound
		}
		metadata := &constant.Metadata{NetWork: constant.UDP, Type: constant.INNER, Host: host}
		outbound := outboundOf(proxy, metadata, "", "")
		n.update(func(state *StunTestState) {
			state.Outbound = outbound
		})
		return proxy, nil
	}
	proxy, outbound := matchStunOutbound(host, ip, uint16(port))
	if proxy == nil {
		return nil, errSpeedTestProxyNotFound
	}
	n.update(func(state *StunTestState) {
		state.Outbound = outbound
	})
	return proxy, nil
}

func (n *natTester) run(ctx context.Context) {
	n.phase(stunPhaseConnecting, 0)
	proxy, err := n.resolveProxy(ctx)
	if err != nil {
		n.fail(ctx, stunErrorUnavailable)
		return
	}
	if proxy != nil {
		if !proxy.SupportUDP() {
			n.fail(ctx, stunErrorUnsupported)
			return
		}
		switch proxy.Type() {
		case constant.Reject, constant.RejectDrop:
			n.fail(ctx, stunErrorUnsupported)
			return
		}
	}
	dialCtx, cancel := context.WithTimeout(ctx, 6*time.Second)
	pc, server, err := n.listen(dialCtx, proxy, n.params.Server)
	cancel()
	if err != nil {
		n.fail(ctx, stunErrorUnavailable)
		return
	}
	socket := newStunSocket(pc)
	defer socket.close()
	serverAddr := server.(*net.UDPAddr).AddrPort()
	n.update(func(state *StunTestState) {
		state.Address = serverAddr.String()
	})

	n.phase(stunPhaseBinding, 0.05)
	first, rtt, err := socket.exchange(ctx, server, 0, 700*time.Millisecond, 3)
	if err != nil {
		if ctx.Err() != nil {
			n.fail(ctx, stunErrorUnavailable)
			return
		}
		n.update(func(state *StunTestState) {
			state.NatType = natTypeBlocked
			state.Phase = stunPhaseDone
			state.Progress = 1
		})
		return
	}
	sent, rtts := socket.burst(ctx, server, func(sent int) {
		n.phase(stunPhaseBinding, 0.05+0.35*float64(sent)/stunBurstPackets)
	})
	if ctx.Err() != nil {
		n.fail(ctx, stunErrorUnavailable)
		return
	}
	if len(rtts) == 0 {
		rtts = []float64{float64(rtt.Microseconds()) / 1000}
	}
	var jitter float64
	for i := 1; i < len(rtts); i++ {
		diff := rtts[i] - rtts[i-1]
		if diff < 0 {
			diff = -diff
		}
		jitter += diff
	}
	if len(rtts) > 1 {
		jitter /= float64(len(rtts) - 1)
	}
	mapped := first.mapped
	localIP, localPort := n.localAddress(pc, serverAddr)
	public := n.direct && localIP != "" && localIP == mapped.Addr().String()
	portPreserved := -1
	if n.direct && localPort > 0 {
		portPreserved = 0
		if localPort == int(mapped.Port()) {
			portPreserved = 1
		}
	}
	other := first.other
	supported := other.IsValid() && other.Addr() != netip.IPv4Unspecified()
	n.update(func(state *StunTestState) {
		state.ExternalIP = mapped.Addr().String()
		state.ExternalPort = int(mapped.Port())
		state.LocalIP = localIP
		state.LocalPort = localPort
		state.PortPreserved = portPreserved
		state.Public = public
		state.Software = first.software
		state.Supported = supported
		if supported {
			state.OtherAddress = other.String()
		}
		state.Latency = median(rtts)
		state.Jitter = jitter
		if sent > 0 {
			state.PacketLoss = 1 - float64(len(rtts))/float64(sent)
		}
		state.NatType = classifyNat(public, "", "")
	})

	filtering := ""
	mapping := ""
	if supported {
		n.phase(stunPhaseFiltering, 0.4)
		if _, _, err := socket.exchange(ctx, server, stunChangeIP|stunChangePort, 700*time.Millisecond, 2); err == nil {
			filtering = natMappingIndependent
		} else if ctx.Err() == nil {
			n.phase(stunPhaseFiltering, 0.55)
			if _, _, err := socket.exchange(ctx, server, stunChangePort, 700*time.Millisecond, 2); err == nil {
				filtering = natMappingAddress
			} else if ctx.Err() == nil {
				filtering = natMappingAddressPort
			}
		}
		if ctx.Err() != nil {
			n.fail(ctx, stunErrorUnavailable)
			return
		}
		n.update(func(state *StunTestState) { state.Filtering = filtering })

		n.phase(stunPhaseMapping, 0.7)
		sameIP := net.UDPAddrFromAddrPort(netip.AddrPortFrom(other.Addr(), serverAddr.Port()))
		if second, _, err := socket.exchange(ctx, sameIP, 0, 700*time.Millisecond, 2); err == nil {
			if second.mapped == mapped {
				mapping = natMappingIndependent
			} else {
				mapping = natMappingAddress
				if third, _, err := socket.exchange(ctx, net.UDPAddrFromAddrPort(other), 0, 700*time.Millisecond, 2); err == nil && third.mapped != second.mapped {
					mapping = natMappingAddressPort
				}
			}
		}
	} else {
		n.phase(stunPhaseMapping, 0.7)
		mapping = n.mappingAgainstOtherServer(ctx, socket, proxy, mapped)
	}
	if ctx.Err() != nil {
		n.fail(ctx, stunErrorUnavailable)
		return
	}
	n.update(func(state *StunTestState) {
		state.Mapping = mapping
		state.Filtering = filtering
		state.NatType = classifyNat(public, mapping, filtering)
		state.Phase = stunPhaseDone
		state.Progress = 1
	})
}

func (n *natTester) mappingAgainstOtherServer(ctx context.Context, socket *stunSocket, proxy constant.Proxy, mapped netip.AddrPort) string {
	currentHost, _, _ := net.SplitHostPort(n.params.Server)
	for _, server := range stunFallbackServers {
		host, _, err := net.SplitHostPort(server)
		if err != nil || host == currentHost {
			continue
		}
		resolveCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
		ip, err := resolver.ResolveIPv4(resolveCtx, host)
		cancel()
		if err != nil {
			continue
		}
		port, _ := net.LookupPort("udp", server[len(host)+1:])
		dst := net.UDPAddrFromAddrPort(netip.AddrPortFrom(ip, uint16(port)))
		reply, _, err := socket.exchange(ctx, dst, 0, 800*time.Millisecond, 2)
		if err != nil {
			if ctx.Err() != nil {
				return ""
			}
			continue
		}
		if reply.mapped == mapped {
			return natMappingIndependent
		}
		return natMappingDependent
	}
	return ""
}

func (n *natTester) localAddress(pc net.PacketConn, server netip.AddrPort) (string, int) {
	if !n.direct {
		return "", 0
	}
	local, ok := pc.LocalAddr().(*net.UDPAddr)
	if !ok {
		return "", 0
	}
	ip := local.IP
	if ip == nil || ip.IsUnspecified() {
		conn, err := net.DialUDP("udp4", nil, net.UDPAddrFromAddrPort(server))
		if err != nil {
			return "", local.Port
		}
		ip = conn.LocalAddr().(*net.UDPAddr).IP
		conn.Close()
	}
	return ip.String(), local.Port
}

func HandleStartStunTest(paramsString string) string {
	params := StunTestParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	ctx, cancel := context.WithCancel(context.Background())
	stunLock.Lock()
	if stunCancel != nil {
		stunCancel()
	}
	stunCancel = cancel
	stunSerial++
	serial := stunSerial
	stunLock.Unlock()
	defer func() {
		stunLock.Lock()
		if stunSerial == serial {
			stunCancel = nil
		}
		stunLock.Unlock()
		cancel()
	}()

	direct := !coreRunning()

	tester := newNatTester(params, direct)
	tester.notify = func(state StunTestState) {
		notify(MessageStun, state)
	}
	tester.run(ctx)
	data, _ := json.Marshal(tester.snapshot())
	return string(data)
}

func HandleCancelStunTest() bool {
	stunLock.Lock()
	defer stunLock.Unlock()
	if stunCancel != nil {
		stunCancel()
		stunCancel = nil
	}
	return true
}
