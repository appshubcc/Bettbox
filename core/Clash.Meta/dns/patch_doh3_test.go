package dns

import (
	"context"
	"encoding/base64"
	"strings"
	"testing"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/quic-go"
	"github.com/metacubex/quic-go/http3"
	"github.com/metacubex/tls"
	D "github.com/miekg/dns"
)

type doh3TestListener struct {
	*quic.EarlyListener
	server *doqTestServer
}

func (l doh3TestListener) Accept(ctx context.Context) (*quic.Conn, error) {
	conn, err := l.EarlyListener.Accept(ctx)
	if err != nil {
		return nil, err
	}
	l.server.accepted.Add(1)
	l.server.live.Add(1)
	go func() {
		<-conn.Context().Done()
		l.server.live.Add(-1)
	}()
	return conn, nil
}

func newDoH3TestServer(t *testing.T) *doqTestServer {
	listener, err := quic.ListenAddrEarly("127.0.0.1:0", http3.ConfigureTLSConfig(&tls.Config{
		Certificates: []tls.Certificate{doqTestCert(t)},
	}), &quic.Config{MaxIdleTimeout: 30 * time.Second})
	if err != nil {
		t.Fatal(err)
	}
	server := &doqTestServer{addr: listener.Addr().String()}
	httpServer := &http3.Server{Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		buf, _ := base64.RawURLEncoding.DecodeString(r.URL.Query().Get("dns"))
		query := new(D.Msg)
		if query.Unpack(buf) != nil || len(query.Question) == 0 {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		reply := new(D.Msg)
		reply.SetReply(query)
		out, _ := reply.Pack()
		delay := doqTestReplyDelay
		if strings.HasPrefix(query.Question[0].Name, "hang") {
			delay = time.Hour
		}
		select {
		case <-time.After(delay):
		case <-r.Context().Done():
			server.cancelled.Add(1)
			return
		}
		_, _ = w.Write(out)
	})}
	go func() { _ = httpServer.ServeListener(doh3TestListener{listener, server}) }()
	t.Cleanup(func() {
		_ = httpServer.Close()
		_ = listener.Close()
	})
	return server
}

func newDoH3TestClient(t *testing.T, server *doqTestServer) *dnsOverHTTPS {
	client := newDoHClient("https://"+server.addr+"/dns-query", nil, false, map[string]string{"skip-cert-verify": "true", "h3": "true"}, nil, "").(*dnsOverHTTPS)
	t.Cleanup(func() { _ = client.Close() })
	return client
}

func TestDoH3ColdCancelKeepsSiblings(t *testing.T) {
	for round := 0; round < 20; round++ {
		server := newDoH3TestServer(t)
		client := newDoH3TestClient(t, server)
		ctx, cancel := context.WithCancel(context.Background())
		done := make(chan struct{})
		go func() {
			defer close(done)
			_, _ = client.ExchangeContext(ctx, doqTestQuery(999))
		}()
		time.Sleep(300 * time.Microsecond)
		time.AfterFunc(700*time.Microsecond, cancel)
		failed, err := doqTestBurst(client, 10, nil)
		<-done
		if failed != 0 {
			t.Fatalf("round %d: %d sibling queries failed: %v", round, failed, err)
		}
		if got := server.accepted.Load(); got != 1 {
			t.Fatalf("round %d: connections opened = %d, want 1", round, got)
		}
	}
}

func TestDoH3LosingRaceEstablishesConnection(t *testing.T) {
	server := newDoH3TestServer(t)
	client := newDoH3TestClient(t, server)
	for i := 0; i < 30; i++ {
		if _, _, err := batchExchange(context.Background(), []dnsClient{client, doqTestFastClient{}}, doqTestQuery(i)); err != nil {
			t.Fatal(err)
		}
		time.Sleep(10 * time.Millisecond)
	}
	doqTestWait(t, "connection", func() bool { return server.accepted.Load() == 1 })
	if failed, err := doqTestBurst(client, 20, nil); failed != 0 {
		t.Fatal(err)
	}
	if got := server.accepted.Load(); got != 1 {
		t.Fatalf("connections opened = %d, want 1", got)
	}
}

func TestDoH3CancelKeepsConnection(t *testing.T) {
	server := newDoH3TestServer(t)
	client := newDoH3TestClient(t, server)
	if failed, err := doqTestBurst(client, 1, nil); failed != 0 {
		t.Fatal(err)
	}
	for round := 0; round < 10; round++ {
		failed, err := doqTestBurst(client, 20, func(index int) (context.Context, context.CancelFunc) {
			if index != 0 {
				return nil, nil
			}
			ctx, cancel := context.WithCancel(context.Background())
			time.AfterFunc(doqTestReplyDelay/3, cancel)
			return ctx, cancel
		})
		if failed != 0 {
			t.Fatalf("round %d: %d sibling queries failed: %v", round, failed, err)
		}
	}
	if got := server.accepted.Load(); got != 1 {
		t.Fatalf("connections opened = %d, want 1", got)
	}
}

func TestDoH3TimeoutDoesNotStall(t *testing.T) {
	server := newDoH3TestServer(t)
	client := newDoH3TestClient(t, server)
	if _, err := client.ExchangeContext(context.Background(), doqTestQuery(1)); err != nil {
		t.Fatal(err)
	}
	hang := func(name string, timeout time.Duration) {
		ctx, cancel := context.WithTimeout(context.Background(), timeout)
		defer cancel()
		msg := new(D.Msg)
		msg.SetQuestion(name, D.TypeA)
		_, _ = client.ExchangeContext(ctx, msg)
	}
	go hang("hang1.example.com.", 3*time.Second)
	time.Sleep(20 * time.Millisecond)
	hang("hang2.example.com.", doqTestReplyDelay)

	start := time.Now()
	failed, err := doqTestBurst(client, 20, nil)
	if failed != 0 {
		t.Fatalf("%d queries failed after a timeout: %v accepted=%d live=%d", failed, err, server.accepted.Load(), server.live.Load())
	}
	if elapsed := time.Since(start); elapsed > time.Second {
		t.Fatalf("queries after a timeout took %v", elapsed)
	}
	if got := server.accepted.Load(); got != 2 {
		t.Fatalf("connections opened = %d, want 2", got)
	}
}

func TestDoH3TimeoutRetriesSiblings(t *testing.T) {
	server := newDoH3TestServer(t)
	client := newDoH3TestClient(t, server)
	if failed, err := doqTestBurst(client, 1, nil); failed != 0 {
		t.Fatal(err)
	}
	failed, err := doqTestBurst(client, 20, func(index int) (context.Context, context.CancelFunc) {
		if index != 0 {
			return nil, nil
		}
		return context.WithTimeout(context.Background(), doqTestReplyDelay/3)
	})
	if failed != 0 {
		t.Fatalf("%d sibling queries failed: %v", failed, err)
	}
	if got := server.accepted.Load(); got != 2 {
		t.Fatalf("connections opened = %d, want 2", got)
	}
	doqTestWait(t, "old connection to close", func() bool { return server.live.Load() == 1 })
}
