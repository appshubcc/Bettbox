package config

import (
	"encoding/json"

	"github.com/metacubex/mihomo/listener/reality"
	"github.com/metacubex/mihomo/listener/sing"
)

type VlessUser struct {
	Username string
	UUID     string
	Flow     string
}

type VlessServer struct {
	Enable          bool
	Listen          string
	Users           []VlessUser
	Decryption      string
	WsPath          string
	XHTTPConfig     XHTTPConfig
	GrpcServiceName string
	Certificate     string
	PrivateKey      string
	ClientAuthType  string
	ClientAuthCert  string
	EchKey          string
	AllowInsecure   bool
	RealityConfig   reality.Config
	MuxOption       sing.MuxOption `yaml:"mux-option" json:"mux-option,omitempty"`
}

type XHTTPConfig struct {
	Path                 string
	Host                 string
	Mode                 string
	XPaddingBytes        string
	XPaddingObfsMode     bool
	XPaddingKey          string
	XPaddingHeader       string
	XPaddingPlacement    string
	XPaddingMethod       string
	UplinkHTTPMethod     string
	SessionPlacement     string
	SessionKey           string
	SeqPlacement         string
	SeqKey               string
	UplinkDataPlacement  string
	UplinkDataKey        string
	UplinkChunkSize      string
	NoSSEHeader          bool
	ScStreamUpServerSecs string
	ScMaxBufferedPosts   string
	ScMaxEachPostBytes   string
}

func (t VlessServer) String() string {
	b, _ := json.Marshal(t)
	return string(b)
}
