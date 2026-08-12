package inbound_test

import (
	"net"
	"net/netip"
	"testing"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/listener/inbound"
	"github.com/stretchr/testify/assert"
)

func testInboundTrojan(t *testing.T, inboundOptions inbound.TrojanOption, outboundOptions outbound.TrojanOption) {
	t.Parallel()
	inboundOptions.BaseOption = inbound.BaseOption{
		NameStr: "trojan_inbound",
		Listen:  "127.0.0.1",
		Port:    "0",
	}
	inboundOptions.Users = []inbound.TrojanUser{
		{Username: "test", Password: userUUID},
	}
	in, err := inbound.NewTrojan(&inboundOptions)
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

	outboundOptions.Name = "trojan_outbound"
	outboundOptions.Server = addrPort.Addr().String()
	outboundOptions.Port = int(addrPort.Port())
	outboundOptions.Password = userUUID
	outboundOptions.DialerForAPI = tunnel.NewDialer()
	outboundOptions.TunnelForAPI = tunnel

	out, err := outbound.NewTrojan(outboundOptions)
	if !assert.NoError(t, err) {
		return
	}
	defer out.Close()

	tunnel.DoTest(t, out)

	if outboundOptions.Network == "grpc" { // don't test sing-mux over grpc
		return
	}
	testSingMux(t, tunnel, out)
}

func testInboundTrojanTLS(t *testing.T, inboundOptions inbound.TrojanOption, outboundOptions outbound.TrojanOption) {
	testInboundTrojan(t, inboundOptions, outboundOptions)
	t.Run("ECH", func(t *testing.T) {
		inboundOptions := inboundOptions
		outboundOptions := outboundOptions
		inboundOptions.EchKey = echKeyPem
		outboundOptions.ECHOpts = outbound.ECHOptions{
			Enable: true,
			Config: echConfigBase64,
		}
		testInboundTrojan(t, inboundOptions, outboundOptions)
	})
	t.Run("mTLS", func(t *testing.T) {
		inboundOptions := inboundOptions
		outboundOptions := outboundOptions
		inboundOptions.ClientAuthCert = tlsAuthCertificate
		outboundOptions.Certificate = tlsAuthCertificate
		outboundOptions.PrivateKey = tlsAuthPrivateKey
		testInboundTrojan(t, inboundOptions, outboundOptions)
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
		testInboundTrojan(t, inboundOptions, outboundOptions)
	})
}

func TestInboundTrojan_TLS(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate: tlsCertificate,
		PrivateKey:  tlsPrivateKey,
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Wss1(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate: tlsCertificate,
		PrivateKey:  tlsPrivateKey,
		WsPath:      "/ws",
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
		Network:     "ws",
		WSOpts: outbound.WSOptions{
			Path: "/ws",
		},
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Wss2(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate:     tlsCertificate,
		PrivateKey:      tlsPrivateKey,
		WsPath:          "/ws",
		GrpcServiceName: "GunService",
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
		Network:     "ws",
		WSOpts: outbound.WSOptions{
			Path: "/ws",
		},
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Grpc1(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate:     tlsCertificate,
		PrivateKey:      tlsPrivateKey,
		GrpcServiceName: "GunService",
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
		Network:     "grpc",
		GrpcOpts:    outbound.GrpcOptions{GrpcServiceName: "GunService"},
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Grpc2(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate:     tlsCertificate,
		PrivateKey:      tlsPrivateKey,
		WsPath:          "/ws",
		GrpcServiceName: "GunService",
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
		Network:     "grpc",
		GrpcOpts:    outbound.GrpcOptions{GrpcServiceName: "GunService"},
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}

func testInboundTrojanUTLS(t *testing.T, inboundOptions inbound.TrojanOption, outboundOptions outbound.TrojanOption) {
	t.Parallel()
	t.Run("Conn", func(t *testing.T) {
		inboundOptions, outboundOptions := inboundOptions, outboundOptions // don't modify outside options value
		testInboundTrojan(t, inboundOptions, outboundOptions)
	})
	t.Run("UConn", func(t *testing.T) {
		inboundOptions, outboundOptions := inboundOptions, outboundOptions // don't modify outside options value
		outboundOptions.ClientFingerprint = "chrome"
		testInboundTrojan(t, inboundOptions, outboundOptions)
	})
}

func TestInboundTrojan_ShadowTLS(t *testing.T) {
	const password = "shadow-tls-password"
	inboundOptions := inbound.TrojanOption{
		ShadowTLS: inbound.ShadowTLS{
			Enable:    true,
			Version:   3,
			Users:     []inbound.ShadowTLSUser{{Name: "test", Password: password}},
			Handshake: inbound.ShadowTLSHandshakeOptions{Dest: net.JoinHostPort(realityDest, "443")},
		},
	}
	outboundOptions := outbound.TrojanOption{
		SNI:           realityDest,
		Fingerprint:   tlsFingerprint,
		ShadowTLSOpts: outbound.ShadowTLSOptions{Password: password, Version: 3},
	}
	testInboundTrojanUTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Restls(t *testing.T) {
	const password = "restls-password"
	inboundOptions := inbound.TrojanOption{
		ResTLS: inbound.ResTLS{
			Enable:   true,
			Dest:     net.JoinHostPort(realityDest, "443"),
			Password: password,
		},
	}
	outboundOptions := outbound.TrojanOption{
		SNI:         realityDest,
		Fingerprint: tlsFingerprint,
		RestlsOpts:  outbound.RestlsOptions{Password: password, VersionHint: "tls13"},
	}
	testInboundTrojanUTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_JLS(t *testing.T) {
	const username = "jls-user"
	const password = "jls-password"
	inboundOptions := inbound.TrojanOption{
		JLSConfig: inbound.JLSConfig{
			Enable: true,
			Users:  []inbound.JLSUser{{Username: username, Password: password}},
			SNI:    realityDest,
			Dest:   net.JoinHostPort(realityDest, "443"),
		},
	}
	outboundOptions := outbound.TrojanOption{
		SNI:     realityDest,
		JLSOpts: outbound.JLSOptions{Username: username, Password: password},
	}
	testInboundTrojanUTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Reality(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		RealityConfig: inbound.RealityConfig{
			Dest:        net.JoinHostPort(realityDest, "443"),
			PrivateKey:  realityPrivateKey,
			ShortID:     []string{realityShortid},
			ServerNames: []string{realityDest},
		},
	}
	outboundOptions := outbound.TrojanOption{
		SNI: realityDest,
		RealityOpts: outbound.RealityOptions{
			PublicKey: realityPublickey,
			ShortID:   realityShortid,
		},
		ClientFingerprint: "chrome",
	}
	testInboundTrojan(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Reality_Grpc(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		RealityConfig: inbound.RealityConfig{
			Dest:        net.JoinHostPort(realityDest, "443"),
			PrivateKey:  realityPrivateKey,
			ShortID:     []string{realityShortid},
			ServerNames: []string{realityDest},
		},
		GrpcServiceName: "GunService",
	}
	outboundOptions := outbound.TrojanOption{
		SNI: realityDest,
		RealityOpts: outbound.RealityOptions{
			PublicKey: realityPublickey,
			ShortID:   realityShortid,
		},
		ClientFingerprint: "chrome",
		Network:           "grpc",
		GrpcOpts:          outbound.GrpcOptions{GrpcServiceName: "GunService"},
	}
	testInboundTrojan(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_TLS_TrojanSS(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate: tlsCertificate,
		PrivateKey:  tlsPrivateKey,
		SSOption: inbound.TrojanSSOption{
			Enabled:  true,
			Method:   "",
			Password: "password",
		},
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
		SSOpts: outbound.TrojanSSOption{
			Enabled:  true,
			Method:   "",
			Password: "password",
		},
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}

func TestInboundTrojan_Wss_TrojanSS(t *testing.T) {
	inboundOptions := inbound.TrojanOption{
		Certificate: tlsCertificate,
		PrivateKey:  tlsPrivateKey,
		SSOption: inbound.TrojanSSOption{
			Enabled:  true,
			Method:   "",
			Password: "password",
		},
		WsPath: "/ws",
	}
	outboundOptions := outbound.TrojanOption{
		Fingerprint: tlsFingerprint,
		SSOpts: outbound.TrojanSSOption{
			Enabled:  true,
			Method:   "",
			Password: "password",
		},
		Network: "ws",
		WSOpts: outbound.WSOptions{
			Path: "/ws",
		},
	}
	testInboundTrojanTLS(t, inboundOptions, outboundOptions)
}
