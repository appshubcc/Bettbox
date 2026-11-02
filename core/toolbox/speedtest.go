package toolbox

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"errors"
	"io"
	"math"
	"net"
	"net/netip"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/http/httptrace"
	N "github.com/metacubex/mihomo/common/net"
	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"github.com/metacubex/quic-go"
	"github.com/metacubex/quic-go/http3"
	mtls "github.com/metacubex/tls"
)

const (
	speedTestInbound        = "SpeedTest"
	speedTestStreams        = 8
	speedTestMaxStreams     = 16
	speedTestLatencyCount   = 20
	speedTestRequestTimeout = 8 * time.Second
	speedTestSampleInterval = 100 * time.Millisecond
	speedTestPushInterval   = 200 * time.Millisecond
	speedTestLoadedInterval = 400 * time.Millisecond
	speedTestRampUp         = 0.3
	speedTestDownloadBytes  = 25_000_000
	speedTestUploadBytes    = 25_000_000
	appleSpeedTestConfigURL = "https://mensura.cdn-apple.com/api/v1/gm/config"
	cloudflareSpeedTestHost = "https://speed.cloudflare.com"
)

const (
	speedTestPhaseConnecting = "connecting"
	speedTestPhaseLatency    = "latency"
	speedTestPhaseDownload   = "download"
	speedTestPhaseUpload     = "upload"
	speedTestPhaseDone       = "done"
)

const (
	speedTestProtocolTCP  = "h1"
	speedTestProtocolH2   = "h2"
	speedTestProtocolQuic = "h3"
)

const (
	speedTestErrorRejected    = "rejected"
	speedTestErrorBlocked     = "blocked"
	speedTestErrorUnavailable = "unavailable"
	speedTestErrorTimeout     = "timeout"
	speedTestErrorCancelled   = "cancelled"
)

var speedTestExitIPURLs = []string{
	"https://cloudflare.com/cdn-cgi/trace",
	"https://api.ip.sb/cdn-cgi/trace",
}

var speedTestExitInfoURL = "http://ip-api.com/json/"

var (
	speedtestNetServersURL = "https://www.speedtest.net/api/js/servers?engine=js&limit=10&https_functional=true"
	speedtestNetScheme     = "https"
)

var (
	errSpeedTestBlocked       = errors.New("speed test blocked")
	errSpeedTestProxyNotFound = errors.New("speed test proxy not found")
)

var (
	speedBufferPool = sync.Pool{
		New: func() any {
			buf := make([]byte, 64*1024)
			return &buf
		},
	}
	speedCounterPool = sync.Pool{
		New: func() any {
			return &speedCounter{}
		},
	}
	speedUploadPayloadOnce sync.Once
	speedUploadPayload     []byte
)

func getSpeedUploadPayload() []byte {
	speedUploadPayloadOnce.Do(func() {
		speedUploadPayload = make([]byte, 64*1024)
		_, _ = rand.Read(speedUploadPayload)
	})
	return speedUploadPayload
}

type SpeedTestParams struct {
	Provider     string              `json:"provider"`
	Lang         string              `json:"lang"`
	Proxy        string              `json:"proxy"`
	Duration     int                 `json:"duration"`
	Protocol     string              `json:"protocol"`
	Streams      int                 `json:"streams"`
	UseSystemDns bool                `json:"use-system-dns"`
	Server       *speedtestNetServer `json:"server"`
}

type SpeedTestOutbound struct {
	Chains      []string `json:"chains"`
	Rule        string   `json:"rule"`
	RulePayload string   `json:"rule-payload"`
}

type SpeedTestServer struct {
	Ip      string `json:"ip"`
	Country string `json:"country"`
	City    string `json:"city"`
	Colo    string `json:"colo"`
	Host    string `json:"host"`
	Sponsor string `json:"sponsor"`
}

type SpeedTestState struct {
	Provider        string             `json:"provider"`
	Protocol        string             `json:"protocol"`
	Fallback        bool               `json:"fallback"`
	ExitIp          string             `json:"exit-ip"`
	ExitInfo        json.RawMessage    `json:"exit-info"`
	Streams         int                `json:"streams"`
	Duration        int                `json:"duration"`
	Phase           string             `json:"phase"`
	Progress        float64            `json:"progress"`
	Speed           float64            `json:"speed"`
	Direct          bool               `json:"direct"`
	Outbound        *SpeedTestOutbound `json:"outbound"`
	Server          *SpeedTestServer   `json:"server"`
	Latency         float64            `json:"latency"`
	Jitter          float64            `json:"jitter"`
	Download        float64            `json:"download"`
	Upload          float64            `json:"upload"`
	DownloadLatency float64            `json:"download-latency"`
	UploadLatency   float64            `json:"upload-latency"`
	Rpm             int                `json:"rpm"`
	Bytes           int64              `json:"bytes"`
	Error           string             `json:"error"`
}

type speedTestTarget struct {
	latencyURL  string
	downloadURL string
	uploadURL   string
	server      *SpeedTestServer
}

type speedSample struct {
	at    time.Duration
	bytes int64
}

type speedTester struct {
	params    SpeedTestParams
	direct    bool
	client    *http.Client
	probe     *http.Client
	latency   *http.Client
	load      []*http.Client
	closers   []func()
	firstMeta atomic.Pointer[constant.Metadata]
	firstInfo atomic.Pointer[statistic.TrackerInfo]
	bytes     atomic.Int64
	mu        sync.RWMutex
	state     SpeedTestState
	prepare   func(ctx context.Context, t *speedTester) (*speedTestTarget, error)
}

var (
	speedTestLock    sync.Mutex
	speedTestCancel  context.CancelFunc
	speedTestSerial  uint64
	speedTestWatched atomic.Pointer[speedTester]
)

func beginSpeedTest() (context.Context, func()) {
	ctx, cancel := context.WithCancel(context.Background())
	speedTestLock.Lock()
	if speedTestCancel != nil {
		speedTestCancel()
	}
	speedTestCancel = cancel
	speedTestSerial++
	serial := speedTestSerial
	speedTestLock.Unlock()
	return ctx, func() {
		speedTestLock.Lock()
		if speedTestSerial == serial {
			speedTestCancel = nil
		}
		speedTestLock.Unlock()
		cancel()
	}
}

func HandleStartSpeedTest(paramsString string) string {
	params := SpeedTestParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	ctx, finish := beginSpeedTest()
	defer func() {
		finish()
		releaseToolMemory()
	}()

	direct := !coreRunning()

	tester := newSpeedTester(params, direct)
	tester.run(ctx, func(state SpeedTestState) {
		notify(MessageSpeedTest, state)
	})
	data, _ := json.Marshal(tester.snapshot())
	return string(data)
}

func HandleProbeSpeedTest(paramsString string) string {
	params := SpeedTestParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	direct := !coreRunning()
	ctx, finish := beginSpeedTest()
	defer finish()
	tester := newSpeedTester(params, direct)
	tester.probeOnly(ctx)
	data, _ := json.Marshal(tester.snapshot())
	return string(data)
}

func HandleCancelSpeedTest() bool {
	speedTestLock.Lock()
	defer speedTestLock.Unlock()
	if speedTestCancel != nil {
		speedTestCancel()
		speedTestCancel = nil
	}
	return true
}

func ObserveSpeedTestTracker(info *statistic.TrackerInfo) {
	if info.Metadata == nil || info.Metadata.InName != speedTestInbound {
		return
	}
	if tester := speedTestWatched.Load(); tester != nil && tester.firstMeta.Load() == info.Metadata {
		tester.firstInfo.Store(info)
	}
}

func newSpeedTester(params SpeedTestParams, direct bool) *speedTester {
	switch params.Provider {
	case "cloudflare", "speedtest":
	default:
		params.Provider = "apple"
	}
	if params.Duration <= 0 {
		params.Duration = 10
	}
	if params.Duration > 30 {
		params.Duration = 30
	}
	if params.Streams <= 0 {
		params.Streams = speedTestStreams
	}
	if params.Streams > speedTestMaxStreams {
		params.Streams = speedTestMaxStreams
	}
	switch params.Protocol {
	case speedTestProtocolH2, speedTestProtocolQuic:
	default:
		params.Protocol = speedTestProtocolTCP
	}
	if direct {
		params.Proxy = ""
	}
	t := &speedTester{
		params: params,
		direct: direct,
		state: SpeedTestState{
			Provider: params.Provider,
			Protocol: speedTestProtocolTCP,
			Streams:  params.Streams,
			Duration: params.Duration,
			Phase:    speedTestPhaseConnecting,
			Direct:   direct,
		},
	}
	switch params.Provider {
	case "cloudflare":
		t.prepare = prepareCloudflareSpeedTest
	case "speedtest":
		t.prepare = prepareSpeedtestNet
	default:
		t.prepare = prepareAppleSpeedTest
	}
	t.client = t.newClient()
	t.probe = t.newClient()
	t.latency = t.client
	t.load = []*http.Client{t.client}
	return t
}

func (t *speedTester) newClient() *http.Client {
	tlsConfig, _ := ca.GetTLSConfig(ca.Option{})
	return &http.Client{
		Transport: &http.Transport{
			DialContext:         t.dial,
			TLSClientConfig:     tlsConfig,
			TLSNextProto:        map[string]func(string, http.TLSConn) http.RoundTripper{},
			MaxIdleConnsPerHost: speedTestMaxStreams * 2,
			DisableCompression:  true,
			TLSHandshakeTimeout: speedTestRequestTimeout,
		},
	}
}

func (t *speedTester) newH2Client() *http.Client {
	tlsConfig, _ := ca.GetTLSConfig(ca.Option{})
	transport := &http.Transport{
		DialContext:         t.dial,
		TLSClientConfig:     tlsConfig,
		ForceAttemptHTTP2:   true,
		DisableCompression:  true,
		TLSHandshakeTimeout: speedTestRequestTimeout,
	}
	t.closers = append(t.closers, transport.CloseIdleConnections)
	return &http.Client{Transport: transport}
}

func (t *speedTester) setupH2(ctx context.Context, target *speedTestTarget) bool {
	latency := t.newH2Client()
	_, resp, err := t.latencyOnce(ctx, latency, target.latencyURL)
	if err != nil || resp.ProtoMajor != 2 {
		return false
	}
	load := make([]*http.Client, t.params.Streams)
	for i := range load {
		load[i] = t.newH2Client()
	}
	t.latency = latency
	t.probe = t.newH2Client()
	t.load = load
	return true
}

func (t *speedTester) newQuicClient(proxy constant.Proxy) *http.Client {
	tlsConfig, _ := ca.GetTLSConfig(ca.Option{})
	transport := &http3.Transport{
		TLSClientConfig: tlsConfig,
		Dial: func(ctx context.Context, address string, tlsCfg *mtls.Config, cfg *quic.Config) (*quic.Conn, error) {
			pc, remote, err := t.listenUDP(ctx, proxy, address)
			if err != nil {
				return nil, err
			}
			conn, err := quic.DialEarly(ctx, pc, remote, tlsCfg, cfg)
			if err != nil {
				pc.Close()
				return nil, err
			}
			go func() {
				<-conn.Context().Done()
				pc.Close()
			}()
			return conn, nil
		},
	}
	t.closers = append(t.closers, func() { _ = transport.Close() })
	return &http.Client{Transport: transport}
}

func (t *speedTester) setupQuic(ctx context.Context, target *speedTestTarget) bool {
	proxy, ok := t.udpOutbound()
	if !ok {
		return false
	}
	latency := t.newQuicClient(proxy)
	if _, _, err := t.latencyOnce(ctx, latency, target.latencyURL); err != nil {
		return false
	}
	load := make([]*http.Client, t.params.Streams)
	for i := range load {
		load[i] = t.newQuicClient(proxy)
	}
	t.latency = latency
	t.probe = t.newQuicClient(proxy)
	t.load = load
	return true
}

func (t *speedTester) dial(ctx context.Context, network, address string) (net.Conn, error) {
	if t.direct {
		return dialer.DialContext(ctx, network, address)
	}
	metadata := &constant.Metadata{
		NetWork: constant.TCP,
		Type:    constant.INNER,
		DNSMode: constant.DNSNormal,
		Process: constant.MihomoName,
		InName:  speedTestInbound,
	}
	if err := metadata.SetRemoteAddress(address); err != nil {
		return nil, err
	}
	t.firstMeta.CompareAndSwap(nil, metadata)
	if t.params.Proxy != "" {
		proxy, ok := FindProxy(t.params.Proxy)
		if !ok {
			return nil, errSpeedTestProxyNotFound
		}
		conn, err := proxy.DialContext(ctx, metadata)
		if err != nil {
			return nil, err
		}
		return statistic.NewTCPTracker(conn, statistic.DefaultManager, metadata, nil, 0, 0, true), nil
	}
	conn, peer := N.Pipe()
	go tunnel.Tunnel.HandleTCPConn(peer, metadata)
	return conn, nil
}

func (t *speedTester) update(fn func(state *SpeedTestState)) {
	t.mu.Lock()
	fn(&t.state)
	t.mu.Unlock()
}

func (t *speedTester) snapshot() SpeedTestState {
	t.mu.RLock()
	defer t.mu.RUnlock()
	state := t.state
	state.Bytes = t.bytes.Load()
	return state
}

func (t *speedTester) setPhase(phase string) {
	t.update(func(state *SpeedTestState) {
		state.Phase = phase
		state.Progress = 0
		state.Speed = 0
	})
}

func (t *speedTester) release() {
	speedTestWatched.CompareAndSwap(t, nil)
	t.client.CloseIdleConnections()
	t.probe.CloseIdleConnections()
	for _, closer := range t.closers {
		closer()
	}
}

func (t *speedTester) probeOnly(ctx context.Context) {
	speedTestWatched.CompareAndSwap(nil, t)
	defer t.release()
	if _, err := t.resolveTarget(ctx); err != nil {
		errorCode := t.classify(ctx, err)
		t.update(func(state *SpeedTestState) {
			state.Error = errorCode
		})
		return
	}
	if info := t.fetchExitInfo(ctx); info != nil {
		t.update(func(state *SpeedTestState) {
			state.ExitInfo = info
		})
	}
}

func (t *speedTester) fetchExitInfo(ctx context.Context) json.RawMessage {
	url := speedTestExitInfoURL
	if t.params.Lang != "" {
		url += "?lang=" + t.params.Lang
	}
	fetchCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	resp, body, err := t.fetch(fetchCtx, t.probe, url, 16*1024)
	if err != nil || resp.StatusCode != http.StatusOK {
		return nil
	}
	var info struct {
		Status string `json:"status"`
		Query  string `json:"query"`
	}
	if json.Unmarshal(body, &info) != nil || info.Status == "fail" || info.Query == "" {
		return nil
	}
	return json.RawMessage(body)
}

func (t *speedTester) run(ctx context.Context, push func(SpeedTestState)) {
	speedTestWatched.Store(t)
	defer t.release()

	pushCtx, stopPush := context.WithCancel(ctx)
	pushDone := make(chan struct{})
	go func() {
		defer close(pushDone)
		ticker := time.NewTicker(speedTestPushInterval)
		defer ticker.Stop()
		for {
			select {
			case <-pushCtx.Done():
				return
			case <-ticker.C:
				push(t.snapshot())
			}
		}
	}()
	defer func() {
		stopPush()
		<-pushDone
	}()

	errorCode := ""
	if err := t.execute(ctx); err != nil {
		errorCode = t.classify(ctx, err)
	}
	t.update(func(state *SpeedTestState) {
		state.Speed = 0
		state.Progress = 1
		state.Error = errorCode
		if errorCode == "" {
			state.Phase = speedTestPhaseDone
		}
	})
}

func (t *speedTester) resolveTarget(ctx context.Context) (*speedTestTarget, error) {
	target, err := t.prepare(ctx, t)
	outbound := t.resolveOutbound()
	t.update(func(state *SpeedTestState) {
		state.Outbound = outbound
		if target != nil {
			state.Server = target.server
		}
	})
	if ip := t.fetchExitIP(ctx, target); ip != "" {
		t.update(func(state *SpeedTestState) {
			state.ExitIp = ip
		})
	}
	return target, err
}

func (t *speedTester) fetchExitIP(ctx context.Context, target *speedTestTarget) string {
	if target != nil && target.server != nil && target.server.Ip != "" {
		return target.server.Ip
	}
	if ctx.Err() != nil || (target == nil && t.snapshot().Outbound == nil) {
		return ""
	}
	for _, url := range speedTestExitIPURLs {
		fetchCtx, cancel := context.WithTimeout(ctx, 4*time.Second)
		resp, body, err := t.fetch(fetchCtx, t.probe, url, 4096)
		cancel()
		if ctx.Err() != nil {
			return ""
		}
		if err != nil || resp.StatusCode != http.StatusOK {
			continue
		}
		if ip := parseCloudflareTrace(string(body))["ip"]; net.ParseIP(ip) != nil {
			return ip
		}
	}
	return ""
}

func (t *speedTester) execute(ctx context.Context) error {
	target, err := t.resolveTarget(ctx)
	if err != nil {
		return err
	}

	if t.params.Protocol != speedTestProtocolTCP {
		protocol := speedTestProtocolTCP
		if t.params.Protocol == speedTestProtocolQuic && t.setupQuic(ctx, target) {
			protocol = speedTestProtocolQuic
		} else if ctx.Err() == nil && t.setupH2(ctx, target) {
			protocol = speedTestProtocolH2
		}
		if ctx.Err() != nil {
			return ctx.Err()
		}
		t.update(func(state *SpeedTestState) {
			state.Protocol = protocol
			state.Fallback = protocol != t.params.Protocol
		})
	}

	t.setPhase(speedTestPhaseLatency)
	samples := t.measureLatency(ctx, target, speedTestLatencyCount, func(done int) {
		t.update(func(state *SpeedTestState) {
			state.Progress = float64(done) / speedTestLatencyCount
		})
	})
	if ctx.Err() != nil {
		return ctx.Err()
	}
	if len(samples) == 0 {
		return errSpeedTestBlocked
	}
	latency, jitter := latencyStats(samples)
	t.update(func(state *SpeedTestState) {
		state.Latency = latency
		state.Jitter = jitter
	})

	t.setPhase(speedTestPhaseDownload)
	download, downloadLoaded := t.measureLoad(ctx, target, t.downloadWorker(target.downloadURL))
	if ctx.Err() != nil {
		return ctx.Err()
	}
	if download <= 0 {
		return errSpeedTestBlocked
	}
	t.update(func(state *SpeedTestState) {
		state.Download = download
		state.DownloadLatency = median(downloadLoaded)
	})

	t.setPhase(speedTestPhaseUpload)
	upload, uploadLoaded := t.measureLoad(ctx, target, t.uploadWorker(target.uploadURL))
	if ctx.Err() != nil {
		return ctx.Err()
	}
	loaded := append(append([]float64{}, downloadLoaded...), uploadLoaded...)
	t.update(func(state *SpeedTestState) {
		state.Upload = upload
		if upload <= 0 {
			state.Upload = -1
		}
		state.UploadLatency = median(uploadLoaded)
		if value := median(loaded); value > 0 {
			state.Rpm = int(60000 / value)
		}
	})
	return nil
}

func (t *speedTester) classify(ctx context.Context, err error) string {
	if errors.Is(ctx.Err(), context.Canceled) {
		return speedTestErrorCancelled
	}
	if outbound := t.snapshot().Outbound; outbound != nil && len(outbound.Chains) > 0 {
		if strings.HasPrefix(strings.ToUpper(outbound.Chains[len(outbound.Chains)-1]), "REJECT") {
			return speedTestErrorRejected
		}
	}
	if errors.Is(err, errSpeedTestBlocked) {
		return speedTestErrorBlocked
	}
	var netErr net.Error
	if errors.Is(err, context.DeadlineExceeded) || (errors.As(err, &netErr) && netErr.Timeout()) {
		return speedTestErrorTimeout
	}
	return speedTestErrorUnavailable
}

func (t *speedTester) resolveOutbound() *SpeedTestOutbound {
	if t.direct {
		return &SpeedTestOutbound{Chains: []string{"DIRECT"}}
	}
	metadata := t.firstMeta.Load()
	if metadata == nil {
		return nil
	}
	for range 5 {
		var info *statistic.TrackerInfo
		statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
			if current := c.Info(); current.Metadata == metadata {
				info = current
				return false
			}
			return true
		})
		if info == nil {
			info = t.firstInfo.Load()
		}
		if info != nil {
			chains := make([]string, len(info.Chain))
			for index, name := range info.Chain {
				chains[len(chains)-1-index] = name
			}
			return &SpeedTestOutbound{Chains: chains, Rule: info.Rule, RulePayload: info.RulePayload}
		}
		time.Sleep(50 * time.Millisecond)
	}
	return nil
}

func (t *speedTester) fetch(ctx context.Context, client *http.Client, url string, limit int64) (*http.Response, []byte, error) {
	reqCtx, cancel := context.WithTimeout(ctx, speedTestRequestTimeout)
	defer cancel()
	req, err := http.NewRequestWithContext(reqCtx, http.MethodGet, url, nil)
	if err != nil {
		return nil, nil, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, nil, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, limit))
	t.bytes.Add(int64(len(body)))
	return resp, body, err
}

func prepareCloudflareSpeedTest(ctx context.Context, t *speedTester) (*speedTestTarget, error) {
	resp, body, err := t.fetch(ctx, t.client, cloudflareSpeedTestHost+"/cdn-cgi/trace", 4096)
	if err != nil {
		return nil, err
	}
	trace := parseCloudflareTrace(string(body))
	if resp.StatusCode != http.StatusOK || resp.Header.Get("cf-ray") == "" || trace["ip"] == "" {
		return nil, errSpeedTestBlocked
	}
	colo := strings.ToUpper(trace["colo"])
	return &speedTestTarget{
		latencyURL:  cloudflareSpeedTestHost + "/__down?bytes=0",
		downloadURL: cloudflareSpeedTestHost + "/__down?bytes=" + strconv.Itoa(speedTestDownloadBytes),
		uploadURL:   cloudflareSpeedTestHost + "/__up",
		server: &SpeedTestServer{
			Ip:      trace["ip"],
			Country: cloudflareColoCountry[colo],
			Colo:    colo,
			Host:    "speed.cloudflare.com",
		},
	}, nil
}

func parseCloudflareTrace(body string) map[string]string {
	result := make(map[string]string, 16)
	rem := body
	for len(rem) > 0 {
		var line string
		line, rem, _ = strings.Cut(rem, "\n")
		key, value, ok := strings.Cut(strings.TrimSpace(line), "=")
		if ok {
			result[key] = value
		}
	}
	return result
}

func prepareAppleSpeedTest(ctx context.Context, t *speedTester) (*speedTestTarget, error) {
	resp, body, err := t.fetch(ctx, t.client, appleSpeedTestConfigURL, 64*1024)
	if err != nil {
		return nil, err
	}
	var config struct {
		TestEndpoint string `json:"test_endpoint"`
		Urls         struct {
			Small  string `json:"small_https_download_url"`
			Large  string `json:"large_https_download_url"`
			Upload string `json:"https_upload_url"`
		} `json:"urls"`
	}
	if resp.StatusCode != http.StatusOK || json.Unmarshal(body, &config) != nil || config.Urls.Large == "" || config.Urls.Upload == "" {
		return nil, errSpeedTestBlocked
	}
	latencyURL := config.Urls.Small
	if latencyURL == "" {
		latencyURL = config.Urls.Large
	}
	country, colo := parseAppleEndpoint(config.TestEndpoint)
	var serverIP string
	if t.params.UseSystemDns {
		if resolver.SystemResolver != nil {
			if ips, err := resolver.SystemResolver.LookupIPv4(ctx, "mensura.cdn-apple.com"); err == nil && len(ips) > 0 {
				serverIP = ips[0].String()
			}
		}
		if serverIP == "" {
			if addrs, err := net.LookupIP("mensura.cdn-apple.com"); err == nil {
				for _, addr := range addrs {
					if ipv4 := addr.To4(); ipv4 != nil && !ipv4.IsPrivate() && !ipv4.IsLoopback() {
						serverIP = ipv4.String()
						break
					}
				}
			}
		}
		if serverIP == "" {
			r := &net.Resolver{
				PreferGo: true,
				Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
					d := net.Dialer{Timeout: 3 * time.Second}
					return d.DialContext(ctx, "udp", "223.5.5.5:53")
				},
			}
			if ips, err := r.LookupIP(ctx, "ip4", "mensura.cdn-apple.com"); err == nil && len(ips) > 0 {
				serverIP = ips[0].String()
			}
		}
	} else {
		r := resolver.DefaultResolver
		if t.direct || t.params.Proxy == "DIRECT" {
			if resolver.DirectHostResolver != nil {
				r = resolver.DirectHostResolver
			}
		}
		if r != nil {
			if ips, err := r.LookupIPv4(ctx, "mensura.cdn-apple.com"); err == nil && len(ips) > 0 {
				serverIP = ips[0].String()
			}
		}
		if serverIP == "" {
			if addrs, err := net.LookupIP("mensura.cdn-apple.com"); err == nil {
				for _, addr := range addrs {
					if ipv4 := addr.To4(); ipv4 != nil {
						serverIP = ipv4.String()
						break
					}
				}
			}
		}
	}
	return &speedTestTarget{
		latencyURL:  latencyURL,
		downloadURL: config.Urls.Large,
		uploadURL:   config.Urls.Upload,
		server: &SpeedTestServer{
			Ip:      serverIP,
			Country: country,
			Colo:    colo,
			Host:    config.TestEndpoint,
		},
	}, nil
}

type speedtestNetServer struct {
	Host    string  `json:"host"`
	Name    string  `json:"name"`
	Cc      string  `json:"cc"`
	Sponsor string  `json:"sponsor"`
	Latency float64 `json:"latency"`
}

type speedtestNetServersParams struct {
	Proxy  string `json:"proxy"`
	Search string `json:"search"`
}

func HandleSpeedTestServers(paramsString string) string {
	params := speedtestNetServersParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	tester := newSpeedTester(SpeedTestParams{Provider: "speedtest", Proxy: params.Proxy}, !coreRunning())
	defer tester.release()
	servers, err := tester.fetchSpeedtestNetServers(ctx, params.Search)
	if err != nil {
		return "[]"
	}
	tester.measureSpeedtestNetServers(ctx, servers)
	slices.SortStableFunc(servers, func(a, b speedtestNetServer) int {
		switch {
		case a.Latency == b.Latency:
			return 0
		case a.Latency <= 0:
			return 1
		case b.Latency <= 0:
			return -1
		case a.Latency < b.Latency:
			return -1
		default:
			return 1
		}
	})
	data, _ := json.Marshal(servers)
	return string(data)
}

func prepareSpeedtestNet(ctx context.Context, t *speedTester) (*speedTestTarget, error) {
	if server := t.params.Server; server != nil && server.Host != "" {
		_, resp, err := t.latencyOnce(ctx, t.client, speedtestNetScheme+"://"+server.Host+"/latency.txt")
		if err != nil {
			return nil, err
		}
		if resp.StatusCode != http.StatusOK {
			return nil, errSpeedTestBlocked
		}
		return speedtestNetTarget(*server), nil
	}
	target, err := prepareSpeedtestNetOnce(ctx, t)
	if err == nil || ctx.Err() != nil {
		return target, err
	}
	return prepareSpeedtestNetOnce(ctx, t)
}

func prepareSpeedtestNetOnce(ctx context.Context, t *speedTester) (*speedTestTarget, error) {
	servers, err := t.fetchSpeedtestNetServers(ctx, "")
	if err != nil {
		return nil, err
	}
	server, ok := t.pickSpeedtestNetServer(ctx, servers)
	if !ok {
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
		return nil, errSpeedTestBlocked
	}
	return speedtestNetTarget(server), nil
}

func speedtestNetTarget(server speedtestNetServer) *speedTestTarget {
	base := speedtestNetScheme + "://" + server.Host
	return &speedTestTarget{
		latencyURL:  base + "/latency.txt",
		downloadURL: base + "/download?size=" + strconv.Itoa(speedTestDownloadBytes),
		uploadURL:   base + "/upload",
		server: &SpeedTestServer{
			Country: strings.ToUpper(server.Cc),
			City:    server.Name,
			Host:    server.Host,
			Sponsor: server.Sponsor,
		},
	}
}

func (t *speedTester) fetchSpeedtestNetServers(ctx context.Context, search string) ([]speedtestNetServer, error) {
	listURL := speedtestNetServersURL
	if search = strings.TrimSpace(search); search != "" {
		listURL += "&search=" + url.QueryEscape(search)
	}
	resp, body, err := t.fetch(ctx, t.client, listURL, 256*1024)
	if err != nil {
		return nil, err
	}
	var servers []speedtestNetServer
	if resp.StatusCode != http.StatusOK || json.Unmarshal(body, &servers) != nil {
		return nil, errSpeedTestBlocked
	}
	servers = slices.DeleteFunc(servers, func(server speedtestNetServer) bool {
		return server.Host == ""
	})
	if len(servers) == 0 && search == "" {
		return nil, errSpeedTestBlocked
	}
	return servers, nil
}

func (t *speedTester) measureSpeedtestNetServers(ctx context.Context, servers []speedtestNetServer) {
	var wg sync.WaitGroup
	for index := range servers {
		servers[index].Latency = 0
		wg.Add(1)
		go func(server *speedtestNetServer) {
			defer wg.Done()
			rtt, resp, err := t.latencyOnce(ctx, t.client, speedtestNetScheme+"://"+server.Host+"/latency.txt")
			if err == nil && resp.StatusCode == http.StatusOK {
				server.Latency = math.Max(rtt, 0.001)
			}
		}(&servers[index])
	}
	wg.Wait()
}

func (t *speedTester) pickSpeedtestNetServer(ctx context.Context, servers []speedtestNetServer) (speedtestNetServer, bool) {
	t.measureSpeedtestNetServers(ctx, servers)
	best := -1
	for index, server := range servers {
		if server.Latency > 0 && (best < 0 || server.Latency < servers[best].Latency) {
			best = index
		}
	}
	if best < 0 {
		return speedtestNetServer{}, false
	}
	return servers[best], true
}

func parseAppleEndpoint(host string) (string, string) {
	label, _, _ := strings.Cut(host, "-")
	if len(label) < 5 {
		return "", ""
	}
	for _, r := range label[:5] {
		if r < 'a' || r > 'z' {
			return "", ""
		}
	}
	return strings.ToUpper(label[:2]), strings.ToUpper(label[2:5])
}

func (t *speedTester) latencyOnce(ctx context.Context, client *http.Client, url string) (float64, *http.Response, error) {
	reqCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var wrote, first time.Time
	trace := &httptrace.ClientTrace{
		WroteRequest:         func(httptrace.WroteRequestInfo) { wrote = time.Now() },
		GotFirstResponseByte: func() { first = time.Now() },
	}
	req, err := http.NewRequestWithContext(httptrace.WithClientTrace(reqCtx, trace), http.MethodGet, url, nil)
	if err != nil {
		return 0, nil, err
	}
	start := time.Now()
	resp, err := client.Do(req)
	if err != nil {
		return 0, nil, err
	}
	headers := time.Now()
	n, _ := io.Copy(io.Discard, resp.Body)
	resp.Body.Close()
	t.bytes.Add(n)
	if wrote.IsZero() {
		wrote = start
	}
	if first.IsZero() {
		first = headers
	}
	rtt := float64(first.Sub(wrote).Microseconds())/1000 - parseServerTiming(resp.Header.Get("server-timing"))
	if rtt <= 0 {
		rtt = float64(first.Sub(wrote).Microseconds()) / 1000
	}
	return rtt, resp, nil
}

func parseServerTiming(header string) float64 {
	rem := header
	for len(rem) > 0 {
		var part string
		part, rem, _ = strings.Cut(rem, ";")
		key, value, ok := strings.Cut(strings.TrimSpace(part), "=")
		if ok && key == "dur" {
			if dur, err := strconv.ParseFloat(value, 64); err == nil {
				return dur
			}
		}
	}
	return 0
}

func (t *speedTester) measureLatency(ctx context.Context, target *speedTestTarget, count int, progress func(int)) []float64 {
	samples := make([]float64, 0, count)
	for i := range count {
		if ctx.Err() != nil {
			break
		}
		rtt, resp, err := t.latencyOnce(ctx, t.latency, target.latencyURL)
		if err == nil {
			samples = append(samples, rtt)
			if city := resp.Header.Get("cf-meta-city"); city != "" && target.server != nil && target.server.City == "" {
				server := *target.server
				server.City = city
				target.server = &server
				t.update(func(state *SpeedTestState) {
					state.Server = &server
				})
			}
		}
		progress(i + 1)
	}
	return samples
}

func (t *speedTester) downloadWorker(url string) func(context.Context, *http.Client, *atomic.Int64) error {
	return func(ctx context.Context, client *http.Client, counter *atomic.Int64) error {
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
		if err != nil {
			return err
		}
		resp, err := client.Do(req)
		if err != nil {
			return err
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			return errSpeedTestBlocked
		}
		bufPtr := speedBufferPool.Get().(*[]byte)
		defer speedBufferPool.Put(bufPtr)
		c := speedCounterPool.Get().(*speedCounter)
		c.counter = counter
		c.total = &t.bytes
		defer speedCounterPool.Put(c)
		_, err = io.CopyBuffer(c, resp.Body, *bufPtr)
		return err
	}
}

func (t *speedTester) uploadWorker(url string) func(context.Context, *http.Client, *atomic.Int64) error {
	payload := getSpeedUploadPayload()
	return func(ctx context.Context, client *http.Client, counter *atomic.Int64) error {
		body := &speedUploadReader{payload: payload, remaining: speedTestUploadBytes, counter: counter, total: &t.bytes}
		req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, body)
		if err != nil {
			return err
		}
		req.ContentLength = speedTestUploadBytes
		req.Header.Set("Content-Type", "application/octet-stream")
		resp, err := client.Do(req)
		if err != nil {
			return err
		}
		_, _ = io.Copy(io.Discard, resp.Body)
		resp.Body.Close()
		if resp.StatusCode >= http.StatusBadRequest {
			return errSpeedTestBlocked
		}
		return nil
	}
}

func (t *speedTester) measureLoad(ctx context.Context, target *speedTestTarget, worker func(context.Context, *http.Client, *atomic.Int64) error) (float64, []float64) {
	_, _, _ = t.latencyOnce(ctx, t.probe, target.latencyURL)
	duration := time.Duration(t.params.Duration) * time.Second
	loadCtx, cancel := context.WithTimeout(ctx, duration)
	defer cancel()

	counter := &atomic.Int64{}
	var wg sync.WaitGroup
	var failures atomic.Int32
	for i := 0; i < t.params.Streams; i++ {
		client := t.load[i%len(t.load)]
		wg.Add(1)
		go func() {
			defer wg.Done()
			for loadCtx.Err() == nil {
				if err := worker(loadCtx, client, counter); err != nil && loadCtx.Err() == nil {
					if failures.Add(1) > int32(t.params.Streams*3) {
						return
					}
					time.Sleep(200 * time.Millisecond)
				}
			}
		}()
	}

	expectedLoaded := int(duration/speedTestLoadedInterval) + 4
	loaded := make([]float64, 0, expectedLoaded)
	wg.Add(1)
	go func() {
		defer wg.Done()
		ticker := time.NewTicker(speedTestLoadedInterval)
		defer ticker.Stop()
		for {
			select {
			case <-loadCtx.Done():
				return
			case <-ticker.C:
				if rtt, _, err := t.latencyOnce(loadCtx, t.probe, target.latencyURL); err == nil {
					loaded = append(loaded, rtt)
				}
			}
		}
	}()

	start := time.Now()
	expectedSamples := int(duration/speedTestSampleInterval) + 4
	samples := make([]speedSample, 0, expectedSamples)
	samples = append(samples, speedSample{at: 0, bytes: 0})
	ticker := time.NewTicker(speedTestSampleInterval)
sampling:
	for {
		select {
		case <-loadCtx.Done():
			break sampling
		case <-ticker.C:
			sample := speedSample{at: time.Since(start), bytes: counter.Load()}
			samples = append(samples, sample)
			speed := windowSpeed(samples, time.Second)
			progress := float64(sample.at) / float64(duration)
			t.update(func(state *SpeedTestState) {
				state.Speed = speed
				state.Progress = progress
			})
		}
	}
	ticker.Stop()
	samples = append(samples, speedSample{at: time.Since(start), bytes: counter.Load()})
	cancel()
	wg.Wait()

	return stableSpeed(samples), loaded
}

type speedCounter struct {
	counter *atomic.Int64
	total   *atomic.Int64
}

func (c *speedCounter) Write(p []byte) (int, error) {
	c.counter.Add(int64(len(p)))
	c.total.Add(int64(len(p)))
	return len(p), nil
}

type speedUploadReader struct {
	payload   []byte
	offset    int
	remaining int64
	counter   *atomic.Int64
	total     *atomic.Int64
}

func (r *speedUploadReader) Read(p []byte) (int, error) {
	if r.remaining <= 0 {
		return 0, io.EOF
	}
	toRead := len(p)
	if int64(toRead) > r.remaining {
		toRead = int(r.remaining)
	}
	n := 0
	for n < toRead {
		chunk := copy(p[n:toRead], r.payload[r.offset:])
		r.offset += chunk
		if r.offset >= len(r.payload) {
			r.offset = 0
		}
		n += chunk
	}
	r.remaining -= int64(n)
	r.counter.Add(int64(n))
	r.total.Add(int64(n))
	return n, nil
}

func (r *speedUploadReader) Close() error {
	return nil
}

func windowSpeed(samples []speedSample, window time.Duration) float64 {
	if len(samples) < 2 {
		return 0
	}
	last := samples[len(samples)-1]
	first := samples[0]
	for i := len(samples) - 2; i >= 0; i-- {
		first = samples[i]
		if last.at-samples[i].at >= window {
			break
		}
	}
	elapsed := (last.at - first.at).Seconds()
	if elapsed <= 0 {
		return 0
	}
	return float64(last.bytes-first.bytes) * 8 / elapsed
}

func stableSpeed(samples []speedSample) float64 {
	if len(samples) < 2 {
		return 0
	}
	last := samples[len(samples)-1]
	cut := time.Duration(float64(last.at) * speedTestRampUp)
	first := samples[0]
	for _, sample := range samples {
		if sample.at >= cut {
			first = sample
			break
		}
	}
	elapsed := (last.at - first.at).Seconds()
	if elapsed <= 0 {
		return 0
	}
	return float64(last.bytes-first.bytes) * 8 / elapsed
}

func median(values []float64) float64 {
	n := len(values)
	if n == 0 {
		return 0
	}
	if n == 1 {
		return values[0]
	}
	if n == 2 {
		return (values[0] + values[1]) / 2
	}
	var sorted []float64
	var stackBuf [64]float64
	if n <= len(stackBuf) {
		sorted = stackBuf[:n]
		copy(sorted, values)
	} else {
		sorted = append([]float64(nil), values...)
	}
	slices.Sort(sorted)
	middle := n / 2
	if n%2 == 0 {
		return (sorted[middle-1] + sorted[middle]) / 2
	}
	return sorted[middle]
}

func latencyStats(samples []float64) (float64, float64) {
	if len(samples) < 2 {
		return median(samples), 0
	}
	var total float64
	for i := 1; i < len(samples); i++ {
		diff := samples[i] - samples[i-1]
		if diff < 0 {
			diff = -diff
		}
		total += diff
	}
	return median(samples), total / float64(len(samples)-1)
}

func (t *speedTester) udpOutbound() (constant.Proxy, bool) {
	if t.direct {
		return nil, true
	}
	name := t.params.Proxy
	if name == "" {
		outbound := t.snapshot().Outbound
		if outbound == nil || len(outbound.Chains) == 0 {
			return nil, false
		}
		name = outbound.Chains[0]
	}
	proxy, ok := FindProxy(name)
	if !ok || !proxy.SupportUDP() {
		return nil, false
	}
	switch proxy.Type() {
	case constant.Reject, constant.RejectDrop:
		return nil, false
	}
	return proxy, true
}

func (t *speedTester) listenUDP(ctx context.Context, proxy constant.Proxy, server string) (net.PacketConn, net.Addr, error) {
	return listenUDPVia(ctx, proxy, server, speedTestInbound)
}

func listenUDPVia(ctx context.Context, proxy constant.Proxy, server string, inbound string) (net.PacketConn, net.Addr, error) {
	host, portText, err := net.SplitHostPort(server)
	if err != nil {
		return nil, nil, err
	}
	port, err := strconv.ParseUint(portText, 10, 16)
	if err != nil {
		return nil, nil, err
	}
	ip, err := resolver.ResolveIPv4(ctx, host)
	if err != nil {
		return nil, nil, err
	}
	addrPort := netip.AddrPortFrom(ip, uint16(port))
	addr := net.UDPAddrFromAddrPort(addrPort)
	if proxy == nil {
		pc, err := dialer.ListenPacket(ctx, "udp", "", addrPort)
		return pc, addr, err
	}
	metadata := &constant.Metadata{
		NetWork: constant.UDP,
		Type:    constant.INNER,
		DNSMode: constant.DNSNormal,
		Process: constant.MihomoName,
		InName:  inbound,
		Host:    host,
		DstIP:   ip,
		DstPort: uint16(port),
	}
	pc, err := proxy.ListenPacketContext(ctx, metadata)
	return pc, addr, err
}
