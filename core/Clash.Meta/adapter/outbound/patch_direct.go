package outbound

import (
	"context"
	"net"
	"sync"

	"github.com/metacubex/mihomo/common/callback"
	"github.com/metacubex/mihomo/component/dialer"
	C "github.com/metacubex/mihomo/constant"
)

var activeDirectSrcPorts = struct {
	sync.Mutex
	counts map[uint16]int
}{counts: make(map[uint16]int)}

func (d *Direct) listenPacket(ctx context.Context, metadata *C.Metadata) (C.PacketConn, error) {
	packetDialer := dialer.NewDialer(d.DialOptions()...)
	addrPort := metadata.AddrPort()
	pc, err := listenPacketAvoidSrcPort(func() (net.PacketConn, error) {
		return packetDialer.ListenPacket(ctx, "udp", "", addrPort)
	}, metadata.SrcPort)
	if err != nil {
		return nil, err
	}
	conn := NewPacketConn(pc, d)
	srcPort := metadata.SrcPort
	if srcPort == 0 {
		return conn, nil
	}
	acquireDirectSrcPort(srcPort)
	return callback.NewCloseCallbackPacketConn(conn, func() {
		releaseDirectSrcPort(srcPort)
	}), nil
}

func acquireDirectSrcPort(port uint16) {
	activeDirectSrcPorts.Lock()
	activeDirectSrcPorts.counts[port]++
	activeDirectSrcPorts.Unlock()
}

func releaseDirectSrcPort(port uint16) {
	activeDirectSrcPorts.Lock()
	if activeDirectSrcPorts.counts[port] <= 1 {
		delete(activeDirectSrcPorts.counts, port)
	} else {
		activeDirectSrcPorts.counts[port]--
	}
	activeDirectSrcPorts.Unlock()
}

func isDirectSrcPortActive(port uint16) bool {
	activeDirectSrcPorts.Lock()
	active := activeDirectSrcPorts.counts[port] > 0
	activeDirectSrcPorts.Unlock()
	return active
}

func listenPacketAvoidSrcPort(listen func() (net.PacketConn, error), srcPort uint16) (net.PacketConn, error) {
	for attempt := 0; attempt < 4; attempt++ {
		pc, err := listen()
		if err != nil {
			return nil, err
		}
		addr, ok := pc.LocalAddr().(*net.UDPAddr)
		if !ok || addr.Port <= 0 || addr.Port > 65535 {
			return pc, nil
		}
		port := uint16(addr.Port)
		if port != srcPort && !isDirectSrcPortActive(port) {
			return pc, nil
		}
		defer pc.Close()
	}
	return listen()
}
