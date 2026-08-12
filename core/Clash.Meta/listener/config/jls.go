package config

type JLSConfig struct {
	Enable    bool
	Users     []JLSUser
	SNI       string
	Dest      string
	ALPN      []string
	Proxy     string
	RateLimit uint64
}

type JLSUser struct {
	Username string
	Password string
}
