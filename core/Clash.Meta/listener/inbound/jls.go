package inbound

import (
	"github.com/metacubex/mihomo/common/utils"
	LC "github.com/metacubex/mihomo/listener/config"
)

type JLSConfig struct {
	Enable    bool      `inbound:"enable"`
	Users     []JLSUser `inbound:"users"`
	SNI       string    `inbound:"sni,omitempty"`
	Dest      string    `inbound:"dest"`
	ALPN      []string  `inbound:"alpn,omitempty"`
	Proxy     string    `inbound:"proxy,omitempty"`
	RateLimit uint64    `inbound:"rate-limit,omitempty"`
}

type JLSUser struct {
	Username string `inbound:"username"`
	Password string `inbound:"password"`
}

func (j JLSConfig) Build() LC.JLSConfig {
	return LC.JLSConfig{
		Enable:    j.Enable,
		Users:     utils.Map(j.Users, JLSUser.Build),
		SNI:       j.SNI,
		Dest:      j.Dest,
		ALPN:      append([]string(nil), j.ALPN...),
		Proxy:     j.Proxy,
		RateLimit: j.RateLimit,
	}
}

func (u JLSUser) Build() LC.JLSUser {
	return LC.JLSUser{
		Username: u.Username,
		Password: u.Password,
	}
}
