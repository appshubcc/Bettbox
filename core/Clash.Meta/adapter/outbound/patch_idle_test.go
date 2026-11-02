package outbound

import (
	"net"
	"sync/atomic"
	"testing"
	"time"
)

func newCountingIdleCloser(timeout time.Duration) (*idleCloser, *atomic.Int32) {
	var closed atomic.Int32
	return newIdleCloser(timeout, func() {
		closed.Add(1)
	}), &closed
}

func TestIdleCloserClosesAfterTimeout(t *testing.T) {
	idle, closed := newCountingIdleCloser(20 * time.Millisecond)
	idle.acquire()
	idle.release()
	time.Sleep(80 * time.Millisecond)
	if got := closed.Load(); got != 1 {
		t.Fatalf("closed = %d, want 1", got)
	}
}

func TestIdleCloserKeepsActiveConnections(t *testing.T) {
	idle, closed := newCountingIdleCloser(20 * time.Millisecond)
	idle.acquire()
	idle.acquire()
	idle.release()
	time.Sleep(80 * time.Millisecond)
	idle.closeIdle()
	if got := closed.Load(); got != 0 {
		t.Fatalf("closed = %d, want 0", got)
	}
	idle.release()
	idle.closeIdle()
	if got := closed.Load(); got != 1 {
		t.Fatalf("closed = %d, want 1", got)
	}
}

func TestIdleCloserReuseCancelsTimer(t *testing.T) {
	idle, closed := newCountingIdleCloser(40 * time.Millisecond)
	idle.acquire()
	idle.release()
	time.Sleep(20 * time.Millisecond)
	idle.acquire()
	time.Sleep(60 * time.Millisecond)
	if got := closed.Load(); got != 0 {
		t.Fatalf("closed = %d, want 0", got)
	}
	idle.release()
	time.Sleep(80 * time.Millisecond)
	if got := closed.Load(); got != 1 {
		t.Fatalf("closed = %d, want 1", got)
	}
}

func TestIdleCloserSkipsUnusedClient(t *testing.T) {
	idle, closed := newCountingIdleCloser(time.Hour)
	idle.closeIdle()
	idle.acquire()
	idle.release()
	idle.closeIdle()
	idle.closeIdle()
	if got := closed.Load(); got != 1 {
		t.Fatalf("closed = %d, want 1", got)
	}
}

func TestIdleConnReleasesOnce(t *testing.T) {
	idle, closed := newCountingIdleCloser(time.Hour)
	left, right := net.Pipe()
	defer right.Close()
	idle.acquire()
	idle.acquire()
	conn := idle.trackConn(left)
	_ = conn.Close()
	_ = conn.Close()
	idle.closeIdle()
	if got := closed.Load(); got != 0 {
		t.Fatalf("closed = %d, want 0", got)
	}
	idle.release()
	idle.closeIdle()
	if got := closed.Load(); got != 1 {
		t.Fatalf("closed = %d, want 1", got)
	}
}

func TestIdlePacketConnReleases(t *testing.T) {
	idle, closed := newCountingIdleCloser(time.Hour)
	pc, err := net.ListenPacket("udp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	idle.acquire()
	tracked := idle.trackPacketConn(pc)
	_ = tracked.Close()
	idle.closeIdle()
	if got := closed.Load(); got != 1 {
		t.Fatalf("closed = %d, want 1", got)
	}
}
