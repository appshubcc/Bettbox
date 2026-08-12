package tlsmirror

import (
	"context"
	"fmt"
	"net"
	"sync"

	"github.com/metacubex/mihomo/component/ca"
	tlsC "github.com/metacubex/mihomo/component/tls"

	"github.com/metacubex/tls"
)

func Dial(ctx context.Context, rawConn net.Conn, cfg ClientConfig) (*Conn, error) {
	key, err := DecodePrimaryKey(cfg.PrimaryKey)
	if err != nil {
		return nil, err
	}
	if cfg.ConnectionEnrolment != nil {
		serverID, err := deriveEnrollmentServerIdentifier(key)
		if err != nil {
			_ = rawConn.Close()
			return nil, err
		}
		if IsLoopbackProtectionEnabled(ctx, serverID) {
			_ = rawConn.Close()
			return nil, fmt.Errorf("tlsmirror: loopback protection refused dialing to self")
		}
	}
	serverName := cfg.ServerName
	if serverName == "" {
		serverName = cfg.ForwardAddressHint
	}
	if serverName == "" && !cfg.SkipCertVerify {
		return nil, fmt.Errorf("tlsmirror: server-name is required when certificate verification is enabled")
	}

	tlsSide, mirrorSide := net.Pipe()
	lifetimeCtx := context.Background()
	var hidden *Conn
	mirror := newMirrorConn(lifetimeCtx, mirrorSide, rawConn,
		cfg.Config,
		nil,
		func(rec *record) (bool, error) {
			return hidden.handleInboundRecord(rec)
		},
		nil,
		nil,
	)
	hidden, err = newHiddenConn(lifetimeCtx, mirror, key, false, cfg.Config)
	if err != nil {
		_ = mirror.Close()
		return nil, err
	}
	mirror.onC2SMessageTx = hidden.handleOutboundRecordTx
	mirror.start()

	tlsConfig, err := ca.GetTLSConfig(ca.Option{
		TLSConfig: &tls.Config{
			ServerName:         serverName,
			InsecureSkipVerify: cfg.SkipCertVerify,
			NextProtos:         cfg.ALPN,
		},
		Fingerprint:    cfg.Fingerprint,
		NameCertVerify: cfg.NameCertVerify,
		Certificate:    cfg.Certificate,
		PrivateKey:     cfg.PrivateKey,
	})
	if err != nil {
		_ = hidden.Close()
		return nil, err
	}

	var carrierTLS net.Conn
	if clientFingerprint, ok := tlsC.GetFingerprint(cfg.ClientFingerprint); ok {
		uConfig := tlsC.UConfig(tlsConfig)
		if cfg.ECH != nil {
			err = cfg.ECH.ClientHandleUTLS(ctx, uConfig)
			if err != nil {
				_ = hidden.Close()
				return nil, err
			}
		}
		uConn := tlsC.UClient(tlsSide, uConfig, clientFingerprint)
		if err := uConn.HandshakeContext(ctx); err != nil {
			_ = hidden.Close()
			return nil, fmt.Errorf("%w: %w", errCarrierHandshake, err)
		}
		carrierTLS = uConn
	} else {
		if cfg.ECH != nil {
			err = cfg.ECH.ClientHandle(ctx, tlsConfig)
			if err != nil {
				_ = hidden.Close()
				return nil, err
			}
		}
		tlsConn := tls.Client(tlsSide, tlsConfig)
		if err := tlsConn.HandshakeContext(ctx); err != nil {
			_ = hidden.Close()
			return nil, fmt.Errorf("%w: %w", errCarrierHandshake, err)
		}
		carrierTLS = tlsConn
	}
	carrierALPN := tlsC.GetTLSConnectionState(carrierTLS).NegotiatedProtocol

	ready := make(chan struct{})
	recall := make(chan struct{})
	var recallOnce sync.Once
	hidden.recallTrafficGenerator = func() {
		recallOnce.Do(func() {
			close(recall)
		})
	}
	done := make(chan struct{})
	go func() {
		defer close(done)
		runTrafficGenerator(hidden.ctx, carrierTLS, cfg.EmbeddedTrafficGenerator, carrierALPN, func() {
			close(ready)
		}, recall)
	}()
	if trafficGeneratorWaitsForReady(cfg.EmbeddedTrafficGenerator) {
		select {
		case <-ready:
		case <-done:
			_ = hidden.Close()
			return nil, fmt.Errorf("tlsmirror: carrier traffic generator exited before ready")
		case <-hidden.ctx.Done():
			return nil, hidden.ctx.Err()
		case <-ctx.Done():
			_ = hidden.Close()
			return nil, ctx.Err()
		}
	}
	if cfg.ConnectionEnrolment != nil && !isConnectionEnrollmentBypassed(ctx) {
		if err := hidden.verifyConnectionEnrollment(ctx, cfg); err != nil {
			_ = hidden.Close()
			return nil, err
		}
	}
	return hidden, nil
}
