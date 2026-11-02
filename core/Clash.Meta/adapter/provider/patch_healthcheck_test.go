package provider

import (
	"net/http"
	"net/http/httptest"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
)

type testServer struct {
	url     string
	hits    atomic.Int32
	current atomic.Int32
	peak    atomic.Int32
}

func newTestServer(t *testing.T, delay time.Duration) *testServer {
	server := &testServer{}
	httpServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		server.hits.Add(1)
		current := server.current.Add(1)
		for {
			peak := server.peak.Load()
			if current <= peak || server.peak.CompareAndSwap(peak, current) {
				break
			}
		}
		time.Sleep(delay)
		server.current.Add(-1)
		w.WriteHeader(http.StatusNoContent)
	}))
	t.Cleanup(httpServer.Close)
	server.url = httpServer.URL
	return server
}

func newTestProxies(n int) []C.Proxy {
	proxies := make([]C.Proxy, n)
	for i := range proxies {
		proxies[i] = adapter.NewProxy(outbound.NewDirect())
	}
	return proxies
}

func newTestHealthCheck(t *testing.T, proxies []C.Proxy, url string) *HealthCheck {
	hc := NewHealthCheck(proxies, url, 5000, 300, true, nil)
	t.Cleanup(hc.close)
	return hc
}

func runConcurrently(checks ...func()) {
	var wg sync.WaitGroup
	for _, check := range checks {
		wg.Add(1)
		go func(check func()) {
			defer wg.Done()
			check()
		}(check)
	}
	wg.Wait()
}

func TestHealthCheckSharesOverlappingProxies(t *testing.T) {
	server := newTestServer(t, 20*time.Millisecond)
	proxies := newTestProxies(20)
	all := newTestHealthCheck(t, proxies, server.url)
	region := newTestHealthCheck(t, proxies[:10], server.url)

	runConcurrently(
		func() { all.checkWith(all.periodicReuse()) },
		func() { region.checkWith(region.periodicReuse()) },
	)
	if got := server.hits.Load(); got != 20 {
		t.Fatalf("hits = %d, want 20", got)
	}
	for _, proxy := range proxies {
		if proxy.LastDelayForTestUrl(server.url) == 0xffff {
			t.Fatalf("proxy %p has no result", proxy)
		}
	}

	region.checkWith(region.periodicReuse())
	if got := server.hits.Load(); got != 20 {
		t.Fatalf("periodic recheck hits = %d, want 20", got)
	}

	time.Sleep(1100 * time.Millisecond)
	region.check()
	if got := server.hits.Load(); got != 30 {
		t.Fatalf("forced recheck hits = %d, want 30", got)
	}
	sharedTestLock.Lock()
	pending := len(sharedTests)
	sharedTestLock.Unlock()
	if pending != 0 {
		t.Fatalf("pending = %d, want 0", pending)
	}
}

func TestHealthCheckGlobalConcurrency(t *testing.T) {
	server := newTestServer(t, 50*time.Millisecond)
	var checks []func()
	for i := 0; i < 6; i++ {
		hc := newTestHealthCheck(t, newTestProxies(20), server.url)
		checks = append(checks, hc.check)
	}
	runConcurrently(checks...)
	if got := server.hits.Load(); got != 120 {
		t.Fatalf("hits = %d, want 120", got)
	}
	if got := server.peak.Load(); got > healthCheckConcurrency {
		t.Fatalf("peak = %d, want <= %d", got, healthCheckConcurrency)
	}
}
