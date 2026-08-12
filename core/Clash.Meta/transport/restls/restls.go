package restls

import (
	"context"
	"net"

	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/ntp"

	tls "github.com/metacubex/restls-client-go"
)

const (
	Mode string = "restls"
)

type Restls struct {
	*tls.UConn
}

func (r *Restls) Upstream() any {
	return r.UConn.NetConn()
}

type Config = tls.Config

func NewRestlsConfig(serverName, password, versionHint, restlsScript, clientID string) (*Config, error) {
	config, err := tls.NewRestlsConfig(serverName, password, versionHint, restlsScript, clientID)
	if err != nil {
		return nil, err
	}
	config.RootCAs = ca.GetCertPool()
	config.Time = ntp.Now
	return config, nil
}

type ServerConfig = tls.RestlsServerConfig

var Server = tls.RestlsServer

func SetFingerprint(config *Config, fingerprint string, nameCertVerify string) (err error) {
	verifier, err := ca.NewFingerprintVerifier(fingerprint, ntp.Now)
	if err != nil {
		return err
	}
	config.InsecureSkipVerify = true
	config.VerifyConnection = func(state tls.ConnectionState) error {
		serverName := state.ServerName
		if nameCertVerify != "" {
			serverName = nameCertVerify
		}
		return verifier(state.PeerCertificates, serverName)
	}
	return nil
}

func SetNameCertVerify(config *Config, dnsName string) {
	verifier := ca.NewNameCertVerifier(dnsName, config.RootCAs, config.Time)
	config.InsecureSkipVerify = true
	config.VerifyConnection = func(state tls.ConnectionState) error {
		return verifier(state.PeerCertificates)
	}
}

// NewRestls return a Restls Connection
func NewRestls(ctx context.Context, conn net.Conn, config *Config) (net.Conn, error) {
	clientHellowID := tls.HelloChrome_Auto
	if config != nil {
		clientIDPtr := config.ClientID.Load()
		if clientIDPtr != nil {
			clientHellowID = *clientIDPtr
		}
		config = config.Clone() // avoid race condition in HandshakeContext
	}
	restls := &Restls{
		UConn: tls.UClient(conn, config, clientHellowID),
	}
	if err := restls.HandshakeContext(ctx); err != nil {
		return nil, err
	}

	return restls, nil
}
