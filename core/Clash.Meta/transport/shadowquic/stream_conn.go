package shadowquic

import (
	"net"
	"sync"
	"time"

	"github.com/metacubex/jls-quic-go"
)

type quicStreamConn struct {
	*quic.Stream
	lock  sync.Mutex
	lAddr net.Addr
	rAddr net.Addr

	closeDeferFn func()

	closeOnce sync.Once
	closeErr  error
}

func (q *quicStreamConn) Write(p []byte) (n int, err error) {
	q.lock.Lock()
	defer q.lock.Unlock()
	return q.Stream.Write(p)
}

func (q *quicStreamConn) Close() error {
	q.closeOnce.Do(func() {
		q.closeErr = q.close()
	})
	return q.closeErr
}

func (q *quicStreamConn) close() error {
	if q.closeDeferFn != nil {
		defer q.closeDeferFn()
	}

	_ = q.Stream.SetWriteDeadline(time.Now())

	q.lock.Lock()
	defer q.lock.Unlock()

	q.Stream.CancelRead(0)
	return q.Stream.Close()
}

func (q *quicStreamConn) LocalAddr() net.Addr {
	return q.lAddr
}

func (q *quicStreamConn) RemoteAddr() net.Addr {
	return q.rAddr
}

func NewQuicStreamConn(stream *quic.Stream, lAddr, rAddr net.Addr, closeDeferFn func()) net.Conn {
	return &quicStreamConn{Stream: stream, lAddr: lAddr, rAddr: rAddr, closeDeferFn: closeDeferFn}
}

var _ net.Conn = (*quicStreamConn)(nil)
