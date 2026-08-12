package sing_tun

import (
	"context"
	"net"
	"net/netip"
	"sync"
	"time"

	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/torstate"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/listener/sing"
	"github.com/metacubex/mihomo/log"

	"github.com/metacubex/sing/common/buf"
	"github.com/metacubex/sing/common/bufio"
	M "github.com/metacubex/sing/common/metadata"
	"github.com/metacubex/sing/common/network"
)

const torDNSPort = "127.0.0.1:19053"

func (h *ListenerHandler) ShouldHijackDns(targetAddr netip.AddrPort) bool {
	for _, addrPort := range h.DnsAddrPorts {
		if addrPort == targetAddr || (addrPort.Addr().IsUnspecified() && targetAddr.Port() == 53) {
			return true
		}
	}
	return false
}

func (h *ListenerHandler) NewConnection(ctx context.Context, conn net.Conn, metadata M.Metadata) error {
	if h.ShouldHijackDns(metadata.Destination.AddrPort()) {
		log.Debugln("[DNS] hijack tcp:%s", metadata.Destination.String())
		return resolver.RelayDnsConn(ctx, conn, resolver.DefaultDnsReadTimeout)
	}
	return h.ListenerHandler.NewConnection(ctx, conn, metadata)
}

func (h *ListenerHandler) NewPacket(ctx context.Context, key netip.AddrPort, buffer *buf.Buffer, metadata M.Metadata, init func(natConn network.PacketConn) network.PacketWriter) {
	if h.ShouldHijackDns(metadata.Destination.AddrPort()) {
		log.Debugln("[DNS] hijack udp:%s from %s", metadata.Destination.String(), metadata.Source.String())
		writer := init(nil)
		rwOptions := network.ReadWaitOptions{
			FrontHeadroom: network.CalculateFrontHeadroom(writer),
			RearHeadroom:  network.CalculateRearHeadroom(writer),
			MTU:           resolver.SafeDnsPacketSize,
		}
		if shouldRelayTorDns(metadata) {
			go relayTorDnsPacket(ctx, buffer, rwOptions, metadata.Destination, nil, &writer)
		} else {
			go relayDnsPacket(ctx, buffer, rwOptions, metadata.Destination, nil, &writer)
		}
		return
	}
	h.ListenerHandler.NewPacket(ctx, key, buffer, metadata, init)
}

func (h *ListenerHandler) NewPacketConnection(ctx context.Context, conn network.PacketConn, metadata M.Metadata) error {
	if h.ShouldHijackDns(metadata.Destination.AddrPort()) {
		log.Debugln("[DNS] hijack udp:%s from %s", metadata.Destination.String(), metadata.Source.String())
		defer func() { _ = conn.Close() }()
		mutex := sync.Mutex{}
		var writer network.PacketWriter = conn // a new interface to set nil in defer
		defer func() {
			mutex.Lock() // this goroutine must exit after all conn.WritePacket() is not running
			defer mutex.Unlock()
			writer = nil
		}()
		rwOptions := network.ReadWaitOptions{
			FrontHeadroom: network.CalculateFrontHeadroom(conn),
			RearHeadroom:  network.CalculateRearHeadroom(conn),
			MTU:           resolver.SafeDnsPacketSize,
		}
		readWaiter, isReadWaiter := bufio.CreatePacketReadWaiter(conn)
		if isReadWaiter {
			readWaiter.InitializeReadWaiter(rwOptions)
		}
		for {
			var (
				readBuff *buf.Buffer
				dest     M.Socksaddr
				err      error
			)
			_ = conn.SetReadDeadline(time.Now().Add(resolver.DefaultDnsReadTimeout))
			readBuff = nil // clear last loop status, avoid repeat release
			if isReadWaiter {
				readBuff, dest, err = readWaiter.WaitReadPacket()
			} else {
				readBuff = rwOptions.NewPacketBuffer()
				dest, err = conn.ReadPacket(readBuff)
				if readBuff != nil {
					rwOptions.PostReturn(readBuff)
				}
			}
			if err != nil {
				if readBuff != nil {
					readBuff.Release()
				}
				if sing.ShouldIgnorePacketError(err) {
					break
				}
				return err
			}
			if shouldRelayTorDns(metadata) {
				go relayTorDnsPacket(ctx, readBuff, rwOptions, dest, &mutex, &writer)
			} else {
				go relayDnsPacket(ctx, readBuff, rwOptions, dest, &mutex, &writer)
			}
		}
		return nil
	}
	return h.ListenerHandler.NewPacketConnection(ctx, conn, metadata)
}

func shouldRelayTorDns(metadata M.Metadata) bool {
	src := metadata.Source.Unwrap().UDPAddr()
	dst := metadata.Destination.Unwrap().UDPAddr()
	if src == nil || dst == nil {
		return false
	}
	srcAddrPort := src.AddrPort()
	dstAddrPort := dst.AddrPort()
	cMetadata := &C.Metadata{
		NetWork:    C.UDP,
		Type:       C.TUN,
		SrcIP:      srcAddrPort.Addr().Unmap(),
		SrcPort:    srcAddrPort.Port(),
		DstIP:      dstAddrPort.Addr().Unmap(),
		DstPort:    dstAddrPort.Port(),
		RawSrcAddr: src,
		RawDstAddr: dst,
	}
	pkg, err := process.FindPackageName(cMetadata)
	if err != nil || pkg == "" {
		return false
	}
	if !torstate.ContainsPackage(pkg) {
		return false
	}
	log.Debugln("[DNS] relay Tor app package %s DNS via Tor DNSPort", pkg)
	return true
}

func relayTorDnsPacket(ctx context.Context, readBuff *buf.Buffer, rwOptions network.ReadWaitOptions, dest M.Socksaddr, mutex *sync.Mutex, writer *network.PacketWriter) {
	ctx, cancel := context.WithTimeout(ctx, resolver.DefaultDnsRelayTimeout)
	defer cancel()
	inData := readBuff.Bytes()
	writeBuff := readBuff
	writeBuff.Resize(writeBuff.Start(), 0)
	if len(writeBuff.FreeBytes()) < resolver.SafeDnsPacketSize {
		writeBuff = rwOptions.NewPacketBuffer()
	}
	msg, err := relayDnsPacketToTor(ctx, inData, writeBuff.FreeBytes())
	if writeBuff != readBuff {
		readBuff.Release()
	}
	if err != nil {
		log.Debugln("[DNS] relay Tor DNS packet failed: %v", err)
		writeBuff.Release()
		return
	}
	writeBuff.Truncate(len(msg))
	if mutex != nil {
		mutex.Lock()
		defer mutex.Unlock()
	}
	conn := *writer
	if conn == nil {
		writeBuff.Release()
		return
	}
	err = conn.WritePacket(writeBuff, dest)
	if err != nil {
		writeBuff.Release()
		return
	}
}

func relayDnsPacketToTor(ctx context.Context, query []byte, response []byte) ([]byte, error) {
	var d net.Dialer
	conn, err := d.DialContext(ctx, "udp", torDNSPort)
	if err != nil {
		return nil, err
	}
	defer conn.Close()
	if deadline, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(deadline)
	}
	if _, err = conn.Write(query); err != nil {
		return nil, err
	}
	n, err := conn.Read(response)
	if err != nil {
		return nil, err
	}
	return response[:n], nil
}

func relayDnsPacket(ctx context.Context, readBuff *buf.Buffer, rwOptions network.ReadWaitOptions, dest M.Socksaddr, mutex *sync.Mutex, writer *network.PacketWriter) {
	ctx, cancel := context.WithTimeout(ctx, resolver.DefaultDnsRelayTimeout)
	defer cancel()
	inData := readBuff.Bytes()
	writeBuff := readBuff
	writeBuff.Resize(writeBuff.Start(), 0)
	if len(writeBuff.FreeBytes()) < resolver.SafeDnsPacketSize { // only create a new buffer when space don't enough
		writeBuff = rwOptions.NewPacketBuffer()
	}
	msg, err := resolver.RelayDnsPacket(ctx, inData, writeBuff.FreeBytes())
	if writeBuff != readBuff {
		readBuff.Release()
	}
	if err != nil {
		writeBuff.Release()
		return
	}
	writeBuff.Truncate(len(msg))
	if mutex != nil {
		mutex.Lock()
		defer mutex.Unlock()
	}
	conn := *writer
	if conn == nil {
		writeBuff.Release()
		return
	}
	err = conn.WritePacket(writeBuff, dest) // WritePacket will release writeBuff
	if err != nil {
		writeBuff.Release()
		return
	}
}

func (h *ListenerHandler) TypeMutation(typ C.Type) *ListenerHandler {
	handle := *h
	handle.ListenerHandler = h.ListenerHandler.TypeMutation(typ)
	return &handle
}
