package outbound

import (
	"errors"
	"net"
	"sync"
	"time"

	N "github.com/metacubex/mihomo/common/net"
	"github.com/metacubex/mihomo/common/net/packet"

	"github.com/metacubex/sing/common/buf"
	M "github.com/metacubex/sing/common/metadata"
)

const quicIdleTimeout = 60 * time.Second

var errQuicIdle = errors.New("idle timeout")

type IdleCloser interface {
	CloseIdle()
}

type idleCloser struct {
	mu      sync.Mutex
	timeout time.Duration
	close   func()
	active  int
	gen     uint64
	opened  bool
	timer   *time.Timer
}

func newIdleCloser(timeout time.Duration, close func()) *idleCloser {
	return &idleCloser{timeout: timeout, close: close}
}

func (c *idleCloser) acquire() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.active++
	c.opened = true
	c.stopLocked()
}

func (c *idleCloser) release() {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.active > 0 {
		c.active--
	}
	if c.active > 0 {
		return
	}
	c.stopLocked()
	gen := c.gen
	c.timer = time.AfterFunc(c.timeout, func() {
		c.expire(gen)
	})
}

func (c *idleCloser) expire(gen uint64) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if gen != c.gen || c.active > 0 {
		return
	}
	c.closeLocked()
}

func (c *idleCloser) closeIdle() {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.active > 0 {
		return
	}
	c.closeLocked()
}

func (c *idleCloser) stopLocked() {
	c.gen++
	if c.timer != nil {
		c.timer.Stop()
		c.timer = nil
	}
}

func (c *idleCloser) closeLocked() {
	c.stopLocked()
	if !c.opened {
		return
	}
	c.opened = false
	c.close()
}

func (c *idleCloser) trackConn(conn net.Conn) net.Conn {
	return &idleConn{ExtendedConn: N.NewExtendedConn(conn), idle: c}
}

func (c *idleCloser) trackPacketConn(pc net.PacketConn) net.PacketConn {
	tracked := &idlePacketConn{EnhancePacketConn: N.NewEnhancePacketConn(pc), idle: c}
	if singPC, ok := pc.(packet.SingPacketConn); ok {
		return &idleSingPacketConn{idlePacketConn: tracked, singPacketConn: singPC}
	}
	return tracked
}

type idleConn struct {
	N.ExtendedConn
	idle *idleCloser
	once sync.Once
}

func (c *idleConn) Close() error {
	err := c.ExtendedConn.Close()
	c.once.Do(c.idle.release)
	return err
}

func (c *idleConn) Upstream() any {
	return c.ExtendedConn
}

func (c *idleConn) ReaderReplaceable() bool {
	return true
}

func (c *idleConn) WriterReplaceable() bool {
	return true
}

type idlePacketConn struct {
	N.EnhancePacketConn
	idle *idleCloser
	once sync.Once
}

func (c *idlePacketConn) Close() error {
	err := c.EnhancePacketConn.Close()
	c.once.Do(c.idle.release)
	return err
}

func (c *idlePacketConn) Upstream() any {
	return c.EnhancePacketConn
}

func (c *idlePacketConn) ReaderReplaceable() bool {
	return true
}

func (c *idlePacketConn) WriterReplaceable() bool {
	return true
}

type idleSingPacketConn struct {
	*idlePacketConn
	singPacketConn packet.SingPacketConn
}

func (c *idleSingPacketConn) WritePacket(buffer *buf.Buffer, destination M.Socksaddr) error {
	return c.singPacketConn.WritePacket(buffer, destination)
}

func (c *idleSingPacketConn) ReadPacket(buffer *buf.Buffer) (M.Socksaddr, error) {
	return c.singPacketConn.ReadPacket(buffer)
}

func (p *autoCloseProxyAdapter) CloseIdle() {
	if closer, ok := p.ProxyAdapter.(IdleCloser); ok {
		closer.CloseIdle()
	}
}

func (h *Hysteria2) CloseIdle() {
	h.idle.closeIdle()
}

func (h *Hysteria) CloseIdle() {
	h.idle.closeIdle()
}

func (t *Tuic) CloseIdle() {
	t.idle.closeIdle()
}

func (t *Trojan) CloseIdle() {
	if t.gunClient != nil {
		t.gunClient.CloseIdle()
	}
}

func (v *Vmess) CloseIdle() {
	if v.gunClient != nil {
		v.gunClient.CloseIdle()
	}
}

func (v *Vless) CloseIdle() {
	if v.gunClient != nil {
		v.gunClient.CloseIdle()
	}
}

func (t *Tuic) Close() error {
	return t.client.Close()
}
