package config

import (
	"github.com/metacubex/mihomo/listener/sing"

	"encoding/json"
)

type Hysteria2Server struct {
	Enable                bool              `yaml:"enable" json:"enable"`
	Listen                string            `yaml:"listen" json:"listen"`
	Users                 map[string]string `yaml:"users" json:"users,omitempty"`
	Obfs                  string            `yaml:"obfs" json:"obfs,omitempty"`
	ObfsPassword          string            `yaml:"obfs-password" json:"obfs-password,omitempty"`
	ObfsMinPacketSize     int               `yaml:"obfs-min-packet-size" json:"obfs-min-packet-size,omitempty"`
	ObfsMaxPacketSize     int               `yaml:"obfs-max-packet-size" json:"obfs-max-packet-size,omitempty"`
	Certificate           string            `yaml:"certificate" json:"certificate"`
	PrivateKey            string            `yaml:"private-key" json:"private-key"`
	ClientAuthType        string            `yaml:"client-auth-type" json:"client-auth-type,omitempty"`
	ClientAuthCert        string            `yaml:"client-auth-cert" json:"client-auth-cert,omitempty"`
	EchKey                string            `yaml:"ech-key" json:"ech-key,omitempty"`
	MaxIdleTime           int               `yaml:"max-idle-time" json:"max-idle-time,omitempty"`
	ALPN                  []string          `yaml:"alpn" json:"alpn,omitempty"`
	Up                    string            `yaml:"up" json:"up,omitempty"`
	Down                  string            `yaml:"down" json:"down,omitempty"`
	IgnoreClientBandwidth bool              `yaml:"ignore-client-bandwidth" json:"ignore-client-bandwidth,omitempty"`
	Masquerade            string            `yaml:"masquerade" json:"masquerade,omitempty"`
	CWND                  int               `yaml:"cwnd" json:"cwnd,omitempty"`
	BBRProfile            string            `yaml:"bbr-profile" json:"bbr-profile,omitempty"`
	UdpMTU                int               `yaml:"udp-mtu" json:"udp-mtu,omitempty"`
	MuxOption             sing.MuxOption    `yaml:"mux-option" json:"mux-option,omitempty"`

	RealmOpts Hysteria2RealmOption `yaml:"realm-opts" json:"realm-opts,omitempty"`

	// quic-go special config
	InitialStreamReceiveWindow     uint64 `yaml:"initial-stream-receive-window" json:"initial-stream-receive-window,omitempty"`
	MaxStreamReceiveWindow         uint64 `yaml:"max-stream-receive-window" json:"max-stream-receive-window,omitempty"`
	InitialConnectionReceiveWindow uint64 `yaml:"initial-connection-receive-window" json:"initial-connection-receive-window,omitempty"`
	MaxConnectionReceiveWindow     uint64 `yaml:"max-connection-receive-window" json:"max-connection-receive-window,omitempty"`
}

type Hysteria2RealmOption struct {
	Enable      bool     `yaml:"enable" json:"enable,omitempty"`
	ServerURL   string   `yaml:"server-url" json:"server-url,omitempty"`
	Token       string   `yaml:"token" json:"token,omitempty"`
	RealmID     string   `yaml:"realm-id" json:"realm-id,omitempty"`
	STUNServers []string `yaml:"stun-servers" json:"stun-servers,omitempty"`

	// for ServerURL
	SNI            string   `yaml:"sni" json:"sni,omitempty"`
	SkipCertVerify bool     `yaml:"skip-cert-verify" json:"skip-cert-verify,omitempty"`
	Fingerprint    string   `yaml:"fingerprint" json:"fingerprint,omitempty"`
	Certificate    string   `yaml:"certificate" json:"certificate,omitempty"`
	PrivateKey     string   `yaml:"private-key" json:"private-key,omitempty"`
	ALPN           []string `yaml:"alpn" json:"alpn,omitempty"`
	Proxy          string   `yaml:"proxy" json:"proxy,omitempty"`
}

func (h Hysteria2Server) String() string {
	b, _ := json.Marshal(h)
	return string(b)
}
