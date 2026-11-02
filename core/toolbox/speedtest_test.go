package toolbox

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	mhttp "github.com/metacubex/http"
	"github.com/metacubex/quic-go/http3"
	mtls "github.com/metacubex/tls"
)

func TestStableSpeedSkipsRampUp(t *testing.T) {
	samples := []speedSample{
		{at: 0, bytes: 0},
		{at: 1 * time.Second, bytes: 10},
		{at: 2 * time.Second, bytes: 20},
		{at: 3 * time.Second, bytes: 1_000_020},
		{at: 4 * time.Second, bytes: 2_000_020},
		{at: 10 * time.Second, bytes: 8_000_020},
	}
	got := stableSpeed(samples)
	want := float64(8_000_020-20) * 8 / 8
	if got != want {
		t.Fatalf("stableSpeed = %v, want %v", got, want)
	}
	if stableSpeed(samples[:1]) != 0 {
		t.Fatal("stableSpeed with one sample should be 0")
	}
}

func TestWindowSpeed(t *testing.T) {
	samples := []speedSample{
		{at: 0, bytes: 0},
		{at: 500 * time.Millisecond, bytes: 100},
		{at: 1500 * time.Millisecond, bytes: 1100},
		{at: 2000 * time.Millisecond, bytes: 1600},
	}
	if got, want := windowSpeed(samples, time.Second), float64(1500*8)/1.5; got != want {
		t.Fatalf("windowSpeed = %v, want %v", got, want)
	}
}

func TestLatencyStats(t *testing.T) {
	latency, jitter := latencyStats([]float64{10, 14, 12, 20})
	if latency != 13 || jitter != (4.0+2+8)/3 {
		t.Fatalf("latencyStats = %v, %v", latency, jitter)
	}
}

func TestSpeedTestParsers(t *testing.T) {
	if country, colo := parseAppleEndpoint("twtpe2-edge-fx-005.aaplimg.com"); country != "TW" || colo != "TPE" {
		t.Fatalf("parseAppleEndpoint = %s %s", country, colo)
	}
	if country, colo := parseAppleEndpoint("edge.example.com"); country != "" || colo != "" {
		t.Fatalf("parseAppleEndpoint should reject %s %s", country, colo)
	}
	trace := parseCloudflareTrace("fl=1\nip=1.2.3.4\nloc=HK\ncolo=HKG\n")
	if trace["ip"] != "1.2.3.4" || trace["loc"] != "HK" || trace["colo"] != "HKG" {
		t.Fatalf("parseCloudflareTrace = %v", trace)
	}
	if got := parseServerTiming("cfRequestDuration;dur=12.5"); got != 12.5 {
		t.Fatalf("parseServerTiming = %v", got)
	}
}

type speedTestRoundTripFunc func(*mhttp.Request) (*mhttp.Response, error)

func (f speedTestRoundTripFunc) RoundTrip(req *mhttp.Request) (*mhttp.Response, error) {
	return f(req)
}

func TestCloudflareCountryFromColo(t *testing.T) {
	for _, tc := range []struct{ colo, country string }{
		{"tpe", "TW"},
		{"HKG", "HK"},
		{"ZZZ", ""},
	} {
		tester := newSpeedTester(SpeedTestParams{Provider: "cloudflare", Duration: 1}, true)
		tester.client = &mhttp.Client{Transport: speedTestRoundTripFunc(func(req *mhttp.Request) (*mhttp.Response, error) {
			header := mhttp.Header{}
			header.Set("cf-ray", "1-TPE")
			return &mhttp.Response{
				StatusCode: mhttp.StatusOK,
				Header:     header,
				Body:       io.NopCloser(strings.NewReader("ip=1.2.3.4\nloc=T1\ncolo=" + tc.colo + "\n")),
				Request:    req,
			}, nil
		})}
		target, err := prepareCloudflareSpeedTest(context.Background(), tester)
		if err != nil {
			t.Fatal(err)
		}
		if target.server.Country != tc.country || target.server.Colo != strings.ToUpper(tc.colo) {
			t.Fatalf("colo %s: server = %+v", tc.colo, target.server)
		}
	}
}

func newSpeedTestServer(t *testing.T) *httptest.Server {
	chunk := make([]byte, 32*1024)
	mux := http.NewServeMux()
	mux.HandleFunc("/latency", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("server-timing", "cfRequestDuration;dur=0.1")
		w.Header().Set("cf-meta-city", "Hong Kong")
	})
	mux.HandleFunc("/download", func(w http.ResponseWriter, r *http.Request) {
		for range 64 {
			if _, err := w.Write(chunk); err != nil {
				return
			}
		}
	})
	mux.HandleFunc("/upload", func(w http.ResponseWriter, r *http.Request) {
		_, _ = io.Copy(io.Discard, r.Body)
	})
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	return server
}

func newTestSpeedTester(server *httptest.Server) *speedTester {
	tester := newSpeedTester(SpeedTestParams{Provider: "cloudflare", Duration: 1}, true)
	tester.prepare = func(ctx context.Context, t *speedTester) (*speedTestTarget, error) {
		if _, _, err := t.fetch(ctx, t.client, server.URL+"/latency", 1024); err != nil {
			return nil, err
		}
		return &speedTestTarget{
			latencyURL:  server.URL + "/latency",
			downloadURL: server.URL + "/download",
			uploadURL:   server.URL + "/upload",
			server:      &SpeedTestServer{Colo: "HKG"},
		}, nil
	}
	return tester
}

func TestSpeedTesterRunsAllPhases(t *testing.T) {
	tester := newTestSpeedTester(newSpeedTestServer(t))
	pushed := 0
	tester.run(context.Background(), func(SpeedTestState) { pushed++ })
	state := tester.snapshot()
	if state.Error != "" || state.Phase != speedTestPhaseDone {
		t.Fatalf("unexpected state %+v", state)
	}
	if state.Download <= 0 || state.Upload <= 0 || state.Latency <= 0 {
		t.Fatalf("missing metrics %+v", state)
	}
	if !state.Direct || state.Outbound == nil || state.Outbound.Chains[0] != "DIRECT" {
		t.Fatalf("direct outbound expected %+v", state.Outbound)
	}
	if state.Server == nil || state.Server.City != "Hong Kong" || state.Bytes <= 0 || pushed == 0 {
		t.Fatalf("unexpected server or bytes %+v %d", state.Server, pushed)
	}
}

func TestSpeedTesterReportsBlocked(t *testing.T) {
	tester := newTestSpeedTester(newSpeedTestServer(t))
	tester.prepare = func(context.Context, *speedTester) (*speedTestTarget, error) {
		return nil, errSpeedTestBlocked
	}
	tester.run(context.Background(), func(SpeedTestState) {})
	if state := tester.snapshot(); state.Error != speedTestErrorBlocked {
		t.Fatalf("error = %q, want blocked", state.Error)
	}
}

func TestSpeedTesterCancelled(t *testing.T) {
	tester := newTestSpeedTester(newSpeedTestServer(t))
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	tester.run(ctx, func(SpeedTestState) {})
	if state := tester.snapshot(); state.Error != speedTestErrorCancelled {
		t.Fatalf("error = %q, want cancelled", state.Error)
	}
}

func TestSpeedTesterFallsBackWhenQuicUnavailable(t *testing.T) {
	tester := newTestSpeedTester(newSpeedTestServer(t))
	tester.params.Protocol = speedTestProtocolQuic
	tester.run(context.Background(), func(SpeedTestState) {})
	state := tester.snapshot()
	if state.Error != "" || !state.Fallback || state.Protocol != speedTestProtocolTCP {
		t.Fatalf("expected fallback through h2 to h1 %+v", state)
	}
	if state.Download <= 0 {
		t.Fatalf("download missing after fallback %+v", state)
	}
}

func newQuicTestServer(t *testing.T) string {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	template := &x509.Certificate{
		SerialNumber: big.NewInt(1),
		NotBefore:    time.Now().Add(-time.Hour),
		NotAfter:     time.Now().Add(time.Hour),
		IPAddresses:  []net.IP{net.IPv4(127, 0, 0, 1)},
	}
	der, err := x509.CreateCertificate(rand.Reader, template, template, &key.PublicKey, key)
	if err != nil {
		t.Fatal(err)
	}
	conn, err := net.ListenPacket("udp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	chunk := make([]byte, 32*1024)
	server := &http3.Server{
		TLSConfig: http3.ConfigureTLSConfig(&mtls.Config{
			Certificates: []mtls.Certificate{{Certificate: [][]byte{der}, PrivateKey: key}},
		}),
		Handler: mhttp.HandlerFunc(func(w mhttp.ResponseWriter, r *mhttp.Request) {
			if r.URL.Path == "/download" {
				for range 32 {
					if _, err := w.Write(chunk); err != nil {
						return
					}
				}
				return
			}
			_, _ = w.Write([]byte("ok"))
		}),
	}
	go func() { _ = server.Serve(conn) }()
	t.Cleanup(func() {
		_ = server.Close()
		_ = conn.Close()
	})
	return "https://" + conn.LocalAddr().String()
}

func newInsecureQuicClient(tester *speedTester) *mhttp.Client {
	client := tester.newQuicClient(nil)
	client.Transport.(*http3.Transport).TLSClientConfig.InsecureSkipVerify = true
	return client
}

func TestQuicClientRoundTrip(t *testing.T) {
	url := newQuicTestServer(t)
	tester := newSpeedTester(SpeedTestParams{Protocol: speedTestProtocolQuic}, true)
	client := newInsecureQuicClient(tester)
	t.Cleanup(func() {
		for _, closer := range tester.closers {
			closer()
		}
	})
	rtt, resp, err := tester.latencyOnce(context.Background(), client, url+"/")
	if err != nil || rtt <= 0 || resp.ProtoMajor != 3 {
		t.Fatalf("quic round trip failed: rtt=%v err=%v resp=%v", rtt, err, resp)
	}
}

func TestSpeedTesterNormalizesParams(t *testing.T) {
	tester := newSpeedTester(SpeedTestParams{Provider: "x", Duration: 99, Streams: 99, Protocol: "h9", Proxy: "A"}, true)
	state := tester.snapshot()
	if state.Provider != "apple" || state.Duration != 30 || state.Streams != speedTestMaxStreams || tester.params.Protocol != speedTestProtocolTCP || tester.params.Proxy != "" {
		t.Fatalf("params not normalized %+v %+v", tester.params, state)
	}
}

func TestSpeedTesterProbeOnly(t *testing.T) {
	tester := newTestSpeedTester(newSpeedTestServer(t))
	tester.probeOnly(context.Background())
	state := tester.snapshot()
	if state.Error != "" || state.Phase != speedTestPhaseConnecting || state.Download != 0 {
		t.Fatalf("probe should only resolve target %+v", state)
	}
	if state.Outbound == nil || state.Outbound.Chains[0] != "DIRECT" || state.Server == nil || state.Server.Colo != "HKG" {
		t.Fatalf("probe did not resolve outbound %+v %+v", state.Outbound, state.Server)
	}
}

func TestSpeedTestProbeSharesCancel(t *testing.T) {
	ctx, finish := beginSpeedTest()
	defer finish()
	HandleCancelSpeedTest()
	select {
	case <-ctx.Done():
	case <-time.After(time.Second):
		t.Fatal("cancel should stop the probe")
	}
	next, finishNext := beginSpeedTest()
	_, finishLast := beginSpeedTest()
	defer finishLast()
	finishNext()
	if next.Err() == nil {
		t.Fatal("new probe should cancel the previous one")
	}
	speedTestLock.Lock()
	active := speedTestCancel != nil
	speedTestLock.Unlock()
	if !active {
		t.Fatal("finishing a stale probe must keep the newer cancel")
	}
}

func TestSpeedTesterFallsBackWhenH2Unavailable(t *testing.T) {
	tester := newTestSpeedTester(newSpeedTestServer(t))
	tester.params.Protocol = speedTestProtocolH2
	tester.run(context.Background(), func(SpeedTestState) {})
	state := tester.snapshot()
	if state.Error != "" || !state.Fallback || state.Protocol != speedTestProtocolTCP {
		t.Fatalf("expected h1 fallback %+v", state)
	}
}

func TestH2ClientRoundTrip(t *testing.T) {
	server := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("ok"))
	}))
	server.EnableHTTP2 = true
	server.StartTLS()
	t.Cleanup(server.Close)
	tester := newSpeedTester(SpeedTestParams{Protocol: speedTestProtocolH2}, true)
	client := tester.newH2Client()
	client.Transport.(*mhttp.Transport).TLSClientConfig.InsecureSkipVerify = true
	t.Cleanup(tester.release)
	_, resp, err := tester.latencyOnce(context.Background(), client, server.URL)
	if err != nil || resp.ProtoMajor != 2 {
		t.Fatalf("h2 round trip failed: err=%v resp=%v", err, resp)
	}
}

func TestPrepareSpeedtestNetPicksFastestHealthyServer(t *testing.T) {
	slowMux := http.NewServeMux()
	slowMux.HandleFunc("/latency.txt", func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(300 * time.Millisecond)
		_, _ = w.Write([]byte("test=test\n"))
	})
	slow := httptest.NewServer(slowMux)
	t.Cleanup(slow.Close)
	broken := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	t.Cleanup(broken.Close)
	healthyMux := http.NewServeMux()
	healthyMux.HandleFunc("/latency.txt", func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("test=test\n"))
	})
	fast := httptest.NewServer(healthyMux)
	t.Cleanup(fast.Close)
	host := func(server *httptest.Server) string { return strings.TrimPrefix(server.URL, "http://") }
	list := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = fmt.Fprintf(w, `[{"host":"%s","name":"Slow","cc":"tw","sponsor":"A"},{"host":"%s","name":"Broken","cc":"tw","sponsor":"B"},{"host":"%s","name":"Taipei","cc":"tw","sponsor":"Fast ISP"}]`, host(slow), host(broken), host(fast))
	}))
	t.Cleanup(list.Close)

	oldURL, oldScheme := speedtestNetServersURL, speedtestNetScheme
	speedtestNetServersURL, speedtestNetScheme = list.URL, "http"
	t.Cleanup(func() { speedtestNetServersURL, speedtestNetScheme = oldURL, oldScheme })

	tester := newSpeedTester(SpeedTestParams{Provider: "speedtest"}, true)
	t.Cleanup(tester.release)
	target, err := tester.prepare(context.Background(), tester)
	if err != nil {
		t.Fatal(err)
	}
	if target.server.Sponsor != "Fast ISP" || target.server.Country != "TW" || target.uploadURL != fast.URL+"/upload" {
		t.Fatalf("unexpected target %+v %+v", target, target.server)
	}
}

func TestPrepareSpeedtestNetReportsBlockedWhenNoServerResponds(t *testing.T) {
	broken := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	t.Cleanup(broken.Close)
	list := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = fmt.Fprintf(w, `[{"host":"%s"}]`, strings.TrimPrefix(broken.URL, "http://"))
	}))
	t.Cleanup(list.Close)
	oldURL, oldScheme := speedtestNetServersURL, speedtestNetScheme
	speedtestNetServersURL, speedtestNetScheme = list.URL, "http"
	t.Cleanup(func() { speedtestNetServersURL, speedtestNetScheme = oldURL, oldScheme })

	tester := newSpeedTester(SpeedTestParams{Provider: "speedtest"}, true)
	t.Cleanup(tester.release)
	if _, err := tester.prepare(context.Background(), tester); err != errSpeedTestBlocked {
		t.Fatalf("expected blocked, got %v", err)
	}
}

func TestPrepareSpeedtestNetUsesManualServer(t *testing.T) {
	mux := http.NewServeMux()
	mux.HandleFunc("/latency.txt", func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("test=test\n"))
	})
	manual := httptest.NewServer(mux)
	t.Cleanup(manual.Close)
	listCalled := false
	list := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		listCalled = true
		_, _ = w.Write([]byte(`[]`))
	}))
	t.Cleanup(list.Close)
	oldURL, oldScheme := speedtestNetServersURL, speedtestNetScheme
	speedtestNetServersURL, speedtestNetScheme = list.URL, "http"
	t.Cleanup(func() { speedtestNetServersURL, speedtestNetScheme = oldURL, oldScheme })

	host := strings.TrimPrefix(manual.URL, "http://")
	tester := newSpeedTester(SpeedTestParams{Provider: "speedtest", Server: &speedtestNetServer{Host: host, Name: "Tokyo", Cc: "jp", Sponsor: "Manual"}}, true)
	t.Cleanup(tester.release)
	target, err := tester.prepare(context.Background(), tester)
	if err != nil {
		t.Fatal(err)
	}
	if listCalled || target.server.Sponsor != "Manual" || target.server.Country != "JP" || target.uploadURL != manual.URL+"/upload" {
		t.Fatalf("unexpected target %+v %+v", target, target.server)
	}
}

func TestHandleSpeedTestServersSearchesAndSortsByLatency(t *testing.T) {
	slowMux := http.NewServeMux()
	slowMux.HandleFunc("/latency.txt", func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(200 * time.Millisecond)
		_, _ = w.Write([]byte("test=test\n"))
	})
	slow := httptest.NewServer(slowMux)
	t.Cleanup(slow.Close)
	fastMux := http.NewServeMux()
	fastMux.HandleFunc("/latency.txt", func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("test=test\n"))
	})
	fast := httptest.NewServer(fastMux)
	t.Cleanup(fast.Close)
	broken := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	t.Cleanup(broken.Close)
	host := func(server *httptest.Server) string { return strings.TrimPrefix(server.URL, "http://") }
	var search string
	list := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		search = r.URL.Query().Get("search")
		_, _ = fmt.Fprintf(w, `[{"host":"%s","name":"Broken"},{"host":"%s","name":"Slow"},{"host":"%s","name":"Fast"},{"host":""}]`, host(broken), host(slow), host(fast))
	}))
	t.Cleanup(list.Close)
	oldURL, oldScheme := speedtestNetServersURL, speedtestNetScheme
	speedtestNetServersURL, speedtestNetScheme = list.URL+"?engine=js", "http"
	t.Cleanup(func() { speedtestNetServersURL, speedtestNetScheme = oldURL, oldScheme })

	var servers []speedtestNetServer
	if err := json.Unmarshal([]byte(HandleSpeedTestServers(`{"search":"New York"}`)), &servers); err != nil {
		t.Fatal(err)
	}
	if search != "New York" {
		t.Fatalf("search = %q", search)
	}
	if len(servers) != 3 || servers[0].Name != "Fast" || servers[1].Name != "Slow" || servers[2].Name != "Broken" || servers[0].Latency <= 0 || servers[2].Latency != 0 {
		t.Fatalf("unexpected servers %+v", servers)
	}
}

func TestSpeedTesterResolvesExitIP(t *testing.T) {
	echo := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("fl=1\nip=203.0.113.9\nloc=HK\n"))
	}))
	t.Cleanup(echo.Close)
	oldURLs := speedTestExitIPURLs
	speedTestExitIPURLs = []string{echo.URL}
	t.Cleanup(func() { speedTestExitIPURLs = oldURLs })

	tester := newTestSpeedTester(newSpeedTestServer(t))
	tester.probeOnly(context.Background())
	if ip := tester.snapshot().ExitIp; ip != "203.0.113.9" {
		t.Fatalf("exit ip = %q", ip)
	}

	cloudflare := newTestSpeedTester(newSpeedTestServer(t))
	cloudflare.prepare = func(context.Context, *speedTester) (*speedTestTarget, error) {
		return &speedTestTarget{server: &SpeedTestServer{Ip: "198.51.100.7"}}, nil
	}
	cloudflare.probeOnly(context.Background())
	if ip := cloudflare.snapshot().ExitIp; ip != "198.51.100.7" {
		t.Fatalf("cloudflare exit ip = %q", ip)
	}

	speedTestExitIPURLs = []string{"http://127.0.0.1:1/unreachable"}
	failing := newTestSpeedTester(newSpeedTestServer(t))
	failing.probeOnly(context.Background())
	if state := failing.snapshot(); state.ExitIp != "" || state.Error != "" {
		t.Fatalf("unreachable echo must not fail the probe: %+v", state)
	}
}

func TestSpeedTesterProbeFetchesExitInfo(t *testing.T) {
	var gotQuery string
	api := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotQuery = r.URL.RawQuery
		_, _ = w.Write([]byte(`{"status":"success","country":"Hong Kong","countryCode":"HK","city":"Central","isp":"HKT","query":"203.0.113.9"}`))
	}))
	t.Cleanup(api.Close)
	old := speedTestExitInfoURL
	speedTestExitInfoURL = api.URL + "/json/"
	t.Cleanup(func() { speedTestExitInfoURL = old })

	tester := newTestSpeedTester(newSpeedTestServer(t))
	tester.params.Lang = "zh-CN"
	tester.probeOnly(context.Background())
	state := tester.snapshot()
	if gotQuery != "lang=zh-CN" || !strings.Contains(string(state.ExitInfo), "203.0.113.9") {
		t.Fatalf("exit info not fetched: query=%q info=%s", gotQuery, state.ExitInfo)
	}

	speedTestExitInfoURL = "http://127.0.0.1:1/json/"
	failing := newTestSpeedTester(newSpeedTestServer(t))
	failing.probeOnly(context.Background())
	if state := failing.snapshot(); state.ExitInfo != nil || state.Error != "" {
		t.Fatalf("unreachable api must not fail the probe: %+v", state)
	}
}
