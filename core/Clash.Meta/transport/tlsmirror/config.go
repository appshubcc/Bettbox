package tlsmirror

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"math/big"
	"net"
	"time"

	tlsC "github.com/metacubex/mihomo/component/tls"

	"github.com/metacubex/tls"
)

type ClientConfig struct {
	Config

	ServerName         string
	SkipCertVerify     bool
	NameCertVerify     string
	ALPN               []string
	Fingerprint        string
	Certificate        string
	PrivateKey         string
	ClientFingerprint  string
	ForwardAddressHint string
	ECH                ECHConfig
	EnrollmentDialer   EnrollmentDialer
}

type ServerConfig = Config

// RecommendedExplicitNonceCipherSuites is the recommended TLS 1.2 cipher suite list for explicit nonce carriers.
var RecommendedExplicitNonceCipherSuites = []uint16{
	156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
	172, 173, 49195, 49196, 49197, 49198, 49199, 49200, 49201, 49202, 49290,
	49291, 49293, 49316, 49317, 49318, 49319, 49320, 49321, 49322, 49323,
	49324, 49325, 49326, 49327, 52392, 52393, 52394, 52395, 52396, 52397,
	52398,
}

type Config struct {
	PrimaryKey                  string
	ExplicitNonceCipherSuites   []uint16
	DeferInstanceDerivedWrite   TimeSpec
	TransportLayerPadding       TransportLayerPadding
	ConnectionEnrolment         *ConnectionEnrolment
	SequenceWatermarkingEnabled bool
	EmbeddedTrafficGenerator    *TrafficGenerator
}

type ConnectionEnrolment struct {
	PrimaryIngressOutbound string
	PrimaryEgressOutbound  string
}

type EnrollmentDialer func(ctx context.Context, network, address string) (net.Conn, error)

type ECHConfig interface {
	ClientHandle(context.Context, *tls.Config) error
	ClientHandleUTLS(context.Context, *tlsC.Config) error
}

type TrafficGenerator struct {
	Steps []TrafficStep
}

type TrafficStep struct {
	Name                         string
	Host                         string
	Path                         string
	Method                       string
	Headers                      []TrafficHeader
	NextStep                     []TrafficTransferCandidate
	ConnectionReady              bool
	ConnectionRecallExit         bool
	WaitTime                     TimeSpec
	H2DoNotWaitForDownloadFinish bool
}

type TrafficHeader struct {
	Name   string
	Value  string
	Values []string
}

type TrafficTransferCandidate struct {
	Weight       int32
	GotoLocation int
}

type TimeSpec struct {
	BaseNanoseconds                    uint64
	UniformRandomMultiplierNanoseconds uint64
}

func (s TimeSpec) Duration() (time.Duration, error) {
	delay := s.BaseNanoseconds
	if s.UniformRandomMultiplierNanoseconds > 0 {
		n, err := rand.Int(rand.Reader, new(big.Int).SetUint64(s.UniformRandomMultiplierNanoseconds))
		if err != nil {
			return 0, err
		}
		delay += n.Uint64()
	}
	return time.Duration(delay), nil
}

type TransportLayerPadding struct {
	Enabled bool
}

func GeneratePrimaryKey() string {
	key := make([]byte, 32)
	_, _ = rand.Read(key)
	return base64.StdEncoding.EncodeToString(key)
}

func DecodePrimaryKey(value string) ([]byte, error) {
	if value == "" {
		return nil, errors.New("missing tlsmirror primary key")
	}
	key, err := base64.StdEncoding.DecodeString(value)
	if err == nil && len(key) == 32 {
		return key, nil
	}
	return nil, errors.New("tlsmirror primary key must be standard base64 and decode to 32 bytes")
}
