package dns

import (
	"context"
	"errors"
	"net"

	"github.com/metacubex/mihomo/common/singleflight"

	"github.com/metacubex/quic-go"
	"github.com/metacubex/quic-go/http3"
)

const QUICCodeRequestCancelled = quic.StreamErrorCode(3)

type doqDialState struct {
	dialGroup singleflight.Group[*quic.Conn]
	dialEpoch uint64
	closed    bool
}

func isQUICLocalCloseError(err error) bool {
	var appErr *quic.ApplicationError
	return errors.As(err, &appErr) && !appErr.Remote
}

func isDoH3LocalCloseError(err error) bool {
	var h3Err *http3.Error
	if errors.As(err, &h3Err) && !h3Err.Remote {
		return true
	}
	return isQUICLocalCloseError(err) || errors.Is(err, net.ErrClosed) || errors.Is(err, http3.ErrTransportClosed)
}

func (doq *dnsOverQUIC) getConnection(ctx context.Context, stale *quic.Conn) (*quic.Conn, error) {
	doq.connMu.Lock()
	if doq.closed {
		doq.connMu.Unlock()
		return nil, net.ErrClosed
	}
	conn := doq.conn
	if conn != nil && conn == stale {
		doq.conn = nil
		conn = nil
	}
	doq.connMu.Unlock()
	if stale != nil {
		_ = stale.CloseWithError(QUICCodeNoError, "")
	}
	if conn != nil {
		return conn, nil
	}

	ch := doq.dialGroup.DoChan("", doq.dialConnection)
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case result := <-ch:
		return result.Val, result.Err
	}
}

func (doq *dnsOverQUIC) dialConnection() (*quic.Conn, error) {
	doq.connMu.RLock()
	conn, epoch := doq.conn, doq.dialEpoch
	doq.connMu.RUnlock()
	if conn != nil {
		return conn, nil
	}

	ctx, cancel := context.WithTimeout(context.Background(), DefaultTimeout)
	defer cancel()
	conn, err := doq.openConnection(ctx)
	if err != nil {
		return nil, err
	}

	doq.connMu.Lock()
	defer doq.connMu.Unlock()
	if doq.closed || doq.dialEpoch != epoch {
		_ = conn.CloseWithError(QUICCodeNoError, "")
		return nil, net.ErrClosed
	}
	doq.conn = conn
	return conn, nil
}
