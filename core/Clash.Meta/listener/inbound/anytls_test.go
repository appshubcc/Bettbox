package inbound_test

import (
	"net"
	"net/netip"
	"testing"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/listener/inbound"

	"github.com/stretchr/testify/assert"
)

func testInboundAnyTLS(t *testing.T, inboundOptions inbound.AnyTLSOption, outboundOptions outbound.AnyTLSOption) {
	t.Parallel()
	inboundOptions.BaseOption = inbound.BaseOption{
		NameStr: "anytls_inbound",
		Listen:  "127.0.0.1",
		Port:    "0",
	}
	inboundOptions.Users = map[string]string{"test": userUUID}
	in, err := inbound.NewAnyTLS(&inboundOptions)
	if !assert.NoError(t, err) {
		return
	}

	tunnel := NewHttpTestTunnel()
	defer tunnel.Close()

	err = in.Listen(tunnel)
	if !assert.NoError(t, err) {
		return
	}
	defer in.Close()

	addrPort, err := netip.ParseAddrPort(in.Address())
	if !assert.NoError(t, err) {
		return
	}

	outboundOptions.Name = "anytls_outbound"
	outboundOptions.Server = addrPort.Addr().String()
	outboundOptions.Port = int(addrPort.Port())
	outboundOptions.Password = userUUID
	outboundOptions.DialerForAPI = tunnel.NewDialer()
	outboundOptions.TunnelForAPI = tunnel

	out, err := outbound.NewAnyTLS(outboundOptions)
	if !assert.NoError(t, err) {
		return
	}
	defer out.Close()

	tunnel.DoTest(t, out)
}

func TestInboundAnyTLS_TLS(t *testing.T) {
	inboundOptions := inbound.AnyTLSOption{
		Certificate: tlsCertificate,
		PrivateKey:  tlsPrivateKey,
	}
	outboundOptions := outbound.AnyTLSOption{
		Fingerprint: tlsFingerprint,
	}
	testInboundAnyTLS(t, inboundOptions, outboundOptions)
	t.Run("ECH", func(t *testing.T) {
		inboundOptions := inboundOptions
		outboundOptions := outboundOptions
		inboundOptions.EchKey = echKeyPem
		outboundOptions.ECHOpts = outbound.ECHOptions{
			Enable: true,
			Config: echConfigBase64,
		}
		testInboundAnyTLS(t, inboundOptions, outboundOptions)
	})
	t.Run("mTLS", func(t *testing.T) {
		inboundOptions := inboundOptions
		outboundOptions := outboundOptions
		inboundOptions.ClientAuthCert = tlsAuthCertificate
		outboundOptions.Certificate = tlsAuthCertificate
		outboundOptions.PrivateKey = tlsAuthPrivateKey
		testInboundAnyTLS(t, inboundOptions, outboundOptions)
	})
	t.Run("mTLS+ECH", func(t *testing.T) {
		inboundOptions := inboundOptions
		outboundOptions := outboundOptions
		inboundOptions.ClientAuthCert = tlsAuthCertificate
		outboundOptions.Certificate = tlsAuthCertificate
		outboundOptions.PrivateKey = tlsAuthPrivateKey
		inboundOptions.EchKey = echKeyPem
		outboundOptions.ECHOpts = outbound.ECHOptions{
			Enable: true,
			Config: echConfigBase64,
		}
		testInboundAnyTLS(t, inboundOptions, outboundOptions)
	})
}

func testInboundAnyTLSUTLS(t *testing.T, inboundOptions inbound.AnyTLSOption, outboundOptions outbound.AnyTLSOption) {
	t.Parallel()
	t.Run("Conn", func(t *testing.T) {
		inboundOptions, outboundOptions := inboundOptions, outboundOptions // don't modify outside options value
		testInboundAnyTLS(t, inboundOptions, outboundOptions)
	})
	t.Run("UConn", func(t *testing.T) {
		inboundOptions, outboundOptions := inboundOptions, outboundOptions // don't modify outside options value
		outboundOptions.ClientFingerprint = "chrome"
		testInboundAnyTLS(t, inboundOptions, outboundOptions)
	})
}

func TestInboundAnyTLS_ShadowTLS(t *testing.T) {
	const password = "shadow-tls-password"
	inboundOptions := inbound.AnyTLSOption{
		ShadowTLS: inbound.ShadowTLS{
			Enable:    true,
			Version:   3,
			Users:     []inbound.ShadowTLSUser{{Name: "test", Password: password}},
			Handshake: inbound.ShadowTLSHandshakeOptions{Dest: net.JoinHostPort(realityDest, "443")},
		},
	}
	outboundOptions := outbound.AnyTLSOption{
		SNI:           realityDest,
		Fingerprint:   tlsFingerprint,
		ShadowTLSOpts: outbound.ShadowTLSOptions{Password: password, Version: 3},
	}
	testInboundAnyTLSUTLS(t, inboundOptions, outboundOptions)
}

func TestInboundAnyTLS_Restls(t *testing.T) {
	const password = "restls-password"
	inboundOptions := inbound.AnyTLSOption{
		ResTLS: inbound.ResTLS{
			Enable:   true,
			Dest:     net.JoinHostPort(realityDest, "443"),
			Password: password,
		},
	}
	outboundOptions := outbound.AnyTLSOption{
		SNI:         realityDest,
		Fingerprint: tlsFingerprint,
		RestlsOpts:  outbound.RestlsOptions{Password: password, VersionHint: "tls13"},
	}
	testInboundAnyTLSUTLS(t, inboundOptions, outboundOptions)
}

func TestInboundAnyTLS_JLS(t *testing.T) {
	const username = "jls-user"
	const password = "jls-password"
	inboundOptions := inbound.AnyTLSOption{
		JLSConfig: inbound.JLSConfig{
			Enable: true,
			Users:  []inbound.JLSUser{{Username: username, Password: password}},
			SNI:    realityDest,
			Dest:   net.JoinHostPort(realityDest, "443"),
		},
	}
	outboundOptions := outbound.AnyTLSOption{
		SNI:     realityDest,
		JLSOpts: outbound.JLSOptions{Username: username, Password: password},
	}
	testInboundAnyTLSUTLS(t, inboundOptions, outboundOptions)
}
