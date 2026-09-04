package mitm

import (
	"context"
	"net"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/component/sniffer"
	tlsC "github.com/metacubex/mihomo/component/tls"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel/statistic"

	"github.com/metacubex/http"
	"github.com/metacubex/http/httputil"
	"github.com/metacubex/tls"
	utls "github.com/metacubex/utls"
)

// Config is the parsed MITM configuration applied to the tunnel.
type Config struct {
	Enable         bool
	SkipCertVerify bool
	QuicBlock      bool
	Hosts          *HostMatcher
	Rewrite        []RewriteRule
	Auth           *Authority
}

var current atomic.Pointer[engine]

type engine struct {
	enable         bool
	skipCertVerify bool
	quicBlock      bool
	hosts          *HostMatcher
	rewrite        []RewriteRule
	auth           *Authority
}

func Update(cfg *Config) {
	if cfg == nil || !cfg.Enable || cfg.Auth == nil {
		current.Store(nil)
		return
	}
	current.Store(&engine{
		enable:         true,
		skipCertVerify: cfg.SkipCertVerify,
		quicBlock:      cfg.QuicBlock,
		hosts:          cfg.Hosts,
		rewrite:        cfg.Rewrite,
		auth:           cfg.Auth,
	})
}

func Enabled() bool {
	e := current.Load()
	return e != nil && e.enable
}

func ShouldBlockQUIC(metadata *C.Metadata) bool {
	e := current.Load()
	if e == nil || !e.quicBlock {
		return false
	}
	if metadata.DstPort != 443 && metadata.DstPort != 8443 {
		return false
	}
	host := metadata.Host
	if host == "" {
		host = metadata.SniffHost
	}
	return e.hosts.Match(host)
}

// TryHandle intercepts a TCP connection when MITM is enabled and the host matches.
// It returns true when the connection was consumed.
func TryHandle(conn net.Conn, metadata *C.Metadata, proxy C.Proxy, rule C.Rule) bool {
	e := current.Load()
	if e == nil || !e.enable {
		return false
	}
	host := metadata.Host
	if host == "" {
		host = metadata.SniffHost
	}
	if host == "" {
		if sni := peekSNI(conn); sni != "" {
			host = sni
			metadata.Host = sni
			metadata.SniffHost = sni
		}
	}
	if !e.hosts.Match(host) {
		return false
	}
	log.Infoln("[MITM] intercept %s (%s)", host, metadata.SourceDetail())
	e.serve(conn, metadata, proxy, rule)
	return true
}

func peekSNI(conn net.Conn) string {
	bc, ok := conn.(interface {
		Peek(int) ([]byte, error)
		Buffered() int
	})
	if !ok {
		return ""
	}
	n := bc.Buffered()
	if n < 5 {
		n = 1024
	}
	if n > 16*1024 {
		n = 16 * 1024
	}
	buf, err := bc.Peek(n)
	if err != nil && len(buf) < 5 {
		return ""
	}
	name, err := sniffer.SniffTLS(buf)
	if err != nil || name == nil {
		return ""
	}
	return *name
}

func (e *engine) serve(conn net.Conn, metadata *C.Metadata, proxy C.Proxy, rule C.Rule) {
	first, ok := peekFirst(conn)
	if ok && (first == 'G' || first == 'P' || first == 'H' || first == 'D' || first == 'O' || first == 'C') {
		e.serveHTTP(conn, metadata, proxy, rule)
		return
	}
	e.serveHTTPS(conn, metadata, proxy, rule)
}

func peekFirst(conn net.Conn) (byte, bool) {
	if bc, ok := conn.(interface{ Peek(int) ([]byte, error) }); ok {
		b, err := bc.Peek(1)
		if err == nil && len(b) > 0 {
			return b[0], true
		}
	}
	return 0, false
}

func (e *engine) serveHTTPS(conn net.Conn, metadata *C.Metadata, proxy C.Proxy, rule C.Rule) {
	handler := e.newHandler(metadata, proxy, rule, true)
	httpServer := &http.Server{
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	tlsConfig := &tlsC.Config{
		MinVersion: utls.VersionTLS12,
		NextProtos: []string{"h2", "http/1.1"},
		GetCertificate: func(chi *utls.ClientHelloInfo) (*utls.Certificate, error) {
			name := chi.ServerName
			if name == "" {
				name = metadata.Host
			}
			leaf, err := e.auth.Leaf(name)
			if err != nil {
				return nil, err
			}
			u := utls.Certificate{
				Certificate: leaf.Certificate,
				PrivateKey:  leaf.PrivateKey,
				Leaf:        leaf.Leaf,
			}
			return &u, nil
		},
	}
	raw := &notifyConn{Conn: conn, done: make(chan struct{})}
	ln := newOnceListener(raw)
	httpsLn := tlsC.NewListenerForHttps(ln, httpServer, tlsConfig)
	go func() {
		<-raw.done
		_ = httpServer.Close()
	}()
	_ = httpServer.Serve(httpsLn)
}

func (e *engine) serveHTTP(conn net.Conn, metadata *C.Metadata, proxy C.Proxy, rule C.Rule) {
	handler := e.newHandler(metadata, proxy, rule, false)
	httpServer := &http.Server{
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	raw := &notifyConn{Conn: conn, done: make(chan struct{})}
	ln := newOnceListener(raw)
	go func() {
		<-raw.done
		_ = httpServer.Close()
	}()
	_ = httpServer.Serve(ln)
}

func (e *engine) newHandler(metadata *C.Metadata, proxy C.Proxy, rule C.Rule, https bool) http.Handler {
	transport := &http.Transport{
		ForceAttemptHTTP2:     true,
		MaxIdleConns:          32,
		IdleConnTimeout:       30 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: e.skipCertVerify,
			NextProtos:         []string{"h2", "http/1.1"},
		},
		DialContext: func(ctx context.Context, network, address string) (net.Conn, error) {
			md := metadata.Clone()
			host, port, err := net.SplitHostPort(address)
			if err == nil {
				md.Host = host
				if p, perr := strconv.ParseUint(port, 10, 16); perr == nil {
					md.DstPort = uint16(p)
				}
			} else {
				md.Host = address
			}
			c, err := proxy.DialContext(ctx, md)
			if err != nil {
				return nil, err
			}
			return statistic.NewTCPTracker(c, statistic.DefaultManager, md, rule, 0, 0, true), nil
		},
	}
	rp := &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			scheme := "http"
			if https {
				scheme = "https"
			}
			r.Out.URL.Scheme = scheme
			r.Out.URL.Host = r.In.Host
			r.Out.Host = r.In.Host
		},
		Transport: transport,
		ErrorHandler: func(w http.ResponseWriter, r *http.Request, err error) {
			log.Debugln("[MITM] origin error %s: %s", requestURL(r), err.Error())
			w.WriteHeader(http.StatusBadGateway)
		},
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		url := requestURL(r)
		if action := matchRewrite(e.rewrite, r.Method, url); action != ActionNone {
			log.Infoln("[MITM] %s %s", action.String(), url)
			writeReject(w, action)
			return
		}
		rp.ServeHTTP(w, r)
	})
}

type notifyConn struct {
	net.Conn
	once sync.Once
	done chan struct{}
}

func (c *notifyConn) Close() error {
	err := c.Conn.Close()
	c.once.Do(func() { close(c.done) })
	return err
}

type onceListener struct {
	conn   net.Conn
	mu     sync.Mutex
	used   bool
	closed bool
	wait   chan struct{}
}

func newOnceListener(conn net.Conn) *onceListener {
	return &onceListener{conn: conn, wait: make(chan struct{})}
}

func (l *onceListener) Accept() (net.Conn, error) {
	l.mu.Lock()
	if l.closed {
		l.mu.Unlock()
		return nil, net.ErrClosed
	}
	if !l.used {
		l.used = true
		c := l.conn
		l.mu.Unlock()
		return c, nil
	}
	l.mu.Unlock()
	<-l.wait
	return nil, net.ErrClosed
}

func (l *onceListener) Close() error {
	l.mu.Lock()
	defer l.mu.Unlock()
	if l.closed {
		return nil
	}
	l.closed = true
	close(l.wait)
	return nil
}

func (l *onceListener) Addr() net.Addr {
	if l.conn != nil {
		return l.conn.LocalAddr()
	}
	return &net.TCPAddr{IP: net.IPv4zero, Port: 0}
}

var _ net.Listener = (*onceListener)(nil)
var _ net.Conn = (*notifyConn)(nil)
