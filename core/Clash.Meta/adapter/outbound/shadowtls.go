package outbound

import "github.com/metacubex/mihomo/transport/shadowtls"

type ShadowTLSOptions struct {
	Password string `proxy:"password,omitempty"`
	Version  int    `proxy:"version,omitempty"`
}

func (o ShadowTLSOptions) Parse() (*shadowtls.Config, error) {
	if o.Password == "" && o.Version == 0 {
		return nil, nil
	}
	return shadowtls.NewConfig(o.Password, o.Version)
}
