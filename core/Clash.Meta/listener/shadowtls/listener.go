package shadowtls

import (
	"context"
	"net"
	"runtime/debug"

	N "github.com/metacubex/mihomo/common/net"
	C "github.com/metacubex/mihomo/constant"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/listener/inner"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/transport/shadowtls"
)

type Builder struct {
	config *shadowtls.ServerConfig
}

func New(config LC.ShadowTLS, tunnel C.Tunnel) (*Builder, error) {
	buildHandshake := func(handshake LC.ShadowTLSHandshakeOptions) shadowtls.HandshakeConfig {
		return shadowtls.HandshakeConfig{
			Server: handshake.Dest,
			DialContext: func(ctx context.Context, network, address string) (net.Conn, error) {
				return inner.HandleTcp(tunnel, address, handshake.Proxy)
			},
		}
	}
	var handshakeForServerName map[string]shadowtls.HandshakeConfig
	if config.Version > 1 {
		handshakeForServerName = make(map[string]shadowtls.HandshakeConfig, len(config.HandshakeForServerName))
		for serverName, serverOptions := range config.HandshakeForServerName {
			handshakeForServerName[serverName] = buildHandshake(serverOptions)
		}
	}
	users := make([]shadowtls.User, len(config.Users))
	for i, user := range config.Users {
		users[i] = shadowtls.User{Name: user.Name, Password: user.Password}
	}
	var wildcardSNI shadowtls.WildcardSNI
	switch config.WildcardSNI {
	case "authed":
		wildcardSNI = shadowtls.WildcardSNIAuthed
	case "all":
		wildcardSNI = shadowtls.WildcardSNIAll
	default:
		wildcardSNI = shadowtls.WildcardSNIOff
	}
	serverConfig, err := shadowtls.NewServerConfig(
		config.Version,
		config.Password,
		users,
		buildHandshake(config.Handshake),
		handshakeForServerName,
		config.StrictMode,
		wildcardSNI,
	)
	if err != nil {
		return nil, err
	}
	return &Builder{config: serverConfig}, nil
}

func (b Builder) NewListener(listener net.Listener) net.Listener {
	return N.NewHandleContextListener(context.Background(), listener, func(ctx context.Context, conn net.Conn) (net.Conn, error) {
		return shadowtls.Server(ctx, conn, b.config)
	}, func(a any) {
		stack := debug.Stack()
		log.Errorln("shadowtls server panic: %s\n%s", a, stack)
	})
}

func UserFromConn(conn net.Conn) (string, bool) {
	return shadowtls.UserFromConn(conn)
}
