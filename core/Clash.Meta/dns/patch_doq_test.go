package dns

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/binary"
	"fmt"
	"io"
	"math/big"
	"net"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/quic-go"
	"github.com/metacubex/tls"
	D "github.com/miekg/dns"
)

const doqTestReplyDelay = 30 * time.Millisecond

type doqTestServer struct {
	addr      string
	accepted  atomic.Int64
	live      atomic.Int64
	cancelled atomic.Int64
	mu        sync.Mutex
	conns     []*quic.Conn
}

func (s *doqTestServer) closeConns() {
	s.mu.Lock()
	conns := s.conns
	s.conns = nil
	s.mu.Unlock()
	for _, conn := range conns {
		_ = conn.CloseWithError(QUICCodeNoError, "")
	}
}

func (s *doqTestServer) serveStream(stream *quic.Stream) {
	defer stream.Close()
	var size uint16
	if binary.Read(stream, binary.BigEndian, &size) != nil {
		return
	}
	buf := make([]byte, size)
	if _, err := io.ReadFull(stream, buf); err != nil {
		return
	}
	query := new(D.Msg)
	if query.Unpack(buf) != nil {
		return
	}
	reply := new(D.Msg)
	reply.SetReply(query)
	out, _ := reply.Pack()
	select {
	case <-time.After(doqTestReplyDelay):
	case <-stream.Context().Done():
		s.cancelled.Add(1)
		return
	}
	_ = binary.Write(stream, binary.BigEndian, uint16(len(out)))
	_, _ = stream.Write(out)
}

func doqTestCert(t *testing.T) tls.Certificate {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	template := &x509.Certificate{
		SerialNumber: big.NewInt(1),
		Subject:      pkix.Name{CommonName: "localhost"},
		NotBefore:    time.Now().Add(-time.Hour),
		NotAfter:     time.Now().Add(time.Hour),
		IPAddresses:  []net.IP{net.ParseIP("127.0.0.1")},
	}
	der, err := x509.CreateCertificate(rand.Reader, template, template, &key.PublicKey, key)
	if err != nil {
		t.Fatal(err)
	}
	return tls.Certificate{Certificate: [][]byte{der}, PrivateKey: key}
}

func newDoQTestServer(t *testing.T) *doqTestServer {
	listener, err := quic.ListenAddr("127.0.0.1:0", &tls.Config{
		Certificates: []tls.Certificate{doqTestCert(t)},
		NextProtos:   []string{NextProtoDQ},
	}, &quic.Config{MaxIdleTimeout: 30 * time.Second})
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = listener.Close() })

	server := &doqTestServer{addr: listener.Addr().String()}
	go func() {
		for {
			conn, err := listener.Accept(context.Background())
			if err != nil {
				return
			}
			server.accepted.Add(1)
			server.live.Add(1)
			server.mu.Lock()
			server.conns = append(server.conns, conn)
			server.mu.Unlock()
			go func() {
				<-conn.Context().Done()
				server.live.Add(-1)
			}()
			go func() {
				for {
					stream, err := conn.AcceptStream(context.Background())
					if err != nil {
						return
					}
					go server.serveStream(stream)
				}
			}()
		}
	}()
	return server
}

func newDoQTestClient(t *testing.T, server *doqTestServer) *dnsOverQUIC {
	client := newDoQ(server.addr, nil, map[string]string{"skip-cert-verify": "true"}, nil, "")
	t.Cleanup(func() { _ = client.Close() })
	return client
}

func doqTestQuery(index int) *D.Msg {
	msg := new(D.Msg)
	msg.SetQuestion(fmt.Sprintf("q%d.example.com.", index), D.TypeA)
	return msg
}

func doqTestBurst(client dnsClient, count int, ctxFor func(index int) (context.Context, context.CancelFunc)) (failed int, firstErr error) {
	var wg sync.WaitGroup
	var mu sync.Mutex
	for i := 0; i < count; i++ {
		i := i
		wg.Add(1)
		go func() {
			defer wg.Done()
			ctx, cancel := context.WithTimeout(context.Background(), DefaultTimeout)
			special := false
			if ctxFor != nil {
				if specialCtx, specialCancel := ctxFor(i); specialCtx != nil {
					cancel()
					ctx, cancel, special = specialCtx, specialCancel, true
				}
			}
			defer cancel()
			_, err := client.ExchangeContext(ctx, doqTestQuery(i))
			if err != nil && !special {
				mu.Lock()
				failed++
				if firstErr == nil {
					firstErr = err
				}
				mu.Unlock()
			}
		}()
	}
	wg.Wait()
	return
}

func doqTestWait(t *testing.T, what string, cond func() bool) {
	t.Helper()
	deadline := time.Now().Add(3 * time.Second)
	for !cond() {
		if time.Now().After(deadline) {
			t.Fatalf("timeout waiting for %s", what)
		}
		time.Sleep(5 * time.Millisecond)
	}
}

func TestDoQColdBurstSharesOneConnection(t *testing.T) {
	server := newDoQTestServer(t)
	const rounds = 30
	for i := 0; i < rounds; i++ {
		client := newDoQ(server.addr, nil, map[string]string{"skip-cert-verify": "true"}, nil, "")
		failed, err := doqTestBurst(client, 50, nil)
		_ = client.Close()
		if failed != 0 {
			t.Fatalf("round %d: %d queries failed: %v", i, failed, err)
		}
	}
	if got := server.accepted.Load(); got != rounds {
		t.Fatalf("connections opened = %d, want %d", got, rounds)
	}
	doqTestWait(t, "connections to close", func() bool { return server.live.Load() == 0 })
}

func TestDoQCancelKeepsConnection(t *testing.T) {
	server := newDoQTestServer(t)
	client := newDoQTestClient(t, server)
	if failed, err := doqTestBurst(client, 1, nil); failed != 0 {
		t.Fatal(err)
	}
	for round := 0; round < 20; round++ {
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
	doqTestWait(t, "server to see cancelled streams", func() bool { return server.cancelled.Load() == 20 })
}

type doqTestFastClient struct{}

func (doqTestFastClient) Address() string  { return "fast" }
func (doqTestFastClient) ResetConnection() {}
func (doqTestFastClient) ExchangeContext(ctx context.Context, m *D.Msg) (*D.Msg, error) {
	reply := new(D.Msg)
	reply.SetReply(m)
	return reply, nil
}

func TestDoQLosingRaceKeepsConnection(t *testing.T) {
	server := newDoQTestServer(t)
	client := newDoQTestClient(t, server)
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

func TestDoQTimeoutReconnectsSiblings(t *testing.T) {
	server := newDoQTestServer(t)
	client := newDoQTestClient(t, server)
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

func TestDoQServerCloseReconnectsOnce(t *testing.T) {
	server := newDoQTestServer(t)
	client := newDoQTestClient(t, server)
	for round := 1; round <= 10; round++ {
		if failed, err := doqTestBurst(client, 50, nil); failed != 0 {
			t.Fatalf("round %d: %d queries failed: %v", round, failed, err)
		}
		if got := server.accepted.Load(); got != int64(round) {
			t.Fatalf("round %d: connections opened = %d", round, got)
		}
		server.closeConns()
		doqTestWait(t, "server close", func() bool { return server.live.Load() == 0 })
		time.Sleep(20 * time.Millisecond)
	}
}

func TestDoQResetAndCloseLeaveNoConnection(t *testing.T) {
	server := newDoQTestServer(t)
	client := newDoQTestClient(t, server)
	for round := 0; round < 30; round++ {
		done := make(chan struct{})
		go func() {
			defer close(done)
			doqTestBurst(client, 20, nil)
		}()
		for i := 0; i < 5; i++ {
			client.ResetConnection()
			time.Sleep(time.Millisecond)
		}
		<-done
	}
	if failed, err := doqTestBurst(client, 20, nil); failed != 0 {
		t.Fatalf("%d queries failed after resets: %v", failed, err)
	}
	doqTestWait(t, "single live connection", func() bool { return server.live.Load() == 1 })

	_ = client.Close()
	doqTestWait(t, "connections to close", func() bool { return server.live.Load() == 0 })
	accepted := server.accepted.Load()
	if _, err := client.ExchangeContext(context.Background(), doqTestQuery(0)); err == nil {
		t.Fatal("query succeeded after Close")
	}
	time.Sleep(50 * time.Millisecond)
	if got := server.accepted.Load(); got != accepted {
		t.Fatalf("connection opened after Close: %d -> %d", accepted, got)
	}
}
