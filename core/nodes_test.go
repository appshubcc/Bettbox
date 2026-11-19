package main

import (
	"context"
	"encoding/base64"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"reflect"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
)

const nodesProfile = `
proxies:
  - {name: hk1, type: ss, server: 1.1.1.1, port: 443, cipher: aes-128-gcm, password: p}
  - {name: us1, type: ss, server: 2.2.2.2, port: 443, cipher: aes-128-gcm, password: p}
proxy-groups:
  - {name: 默认代理, type: select, proxies: [香港, 手动选择]}
  - {name: 手动选择, type: select, proxies: [hk1, us1]}
  - {name: 香港, type: select, proxies: [hk1]}
  - {name: 全部, type: select, include-all: true}
  - {name: 嵌套, type: select, proxies: [香港]}
rules:
  - MATCH,默认代理
`

func nodeProxy(name string) map[string]any {
	return map[string]any{
		"name": name, "type": "socks5", "server": "9.9.9.9", "port": 1080,
	}
}

func patchedGroup(t *testing.T, groups []map[string]any, name string) map[string]any {
	t.Helper()
	for _, group := range groups {
		if group["name"] == name {
			return group
		}
	}
	t.Fatalf("group %s not found", name)
	return nil
}

func TestPatchNodesLanding(t *testing.T) {
	raw := parsePatchProfile(t, nodesProfile)
	patchNodes(raw, []PatchNode{{
		Proxy:  nodeProxy("land"),
		Dialer: "香港",
		Groups: []string{"默认代理", "香港", "嵌套", "缺失"},
	}})
	node := raw.Proxy[len(raw.Proxy)-1]
	if node["name"] != "land" || node["dialer-proxy"] != "香港" {
		t.Fatalf("unexpected node: %v", node)
	}
	if got := groupMembers(patchedGroup(t, raw.ProxyGroup, "默认代理")); !reflect.DeepEqual(got, []string{"香港", "手动选择", "land"}) {
		t.Errorf("默认代理 = %v", got)
	}
	if got := groupMembers(patchedGroup(t, raw.ProxyGroup, "香港")); !reflect.DeepEqual(got, []string{"hk1"}) {
		t.Errorf("front group must stay untouched: %v", got)
	}
	if got := groupMembers(patchedGroup(t, raw.ProxyGroup, "嵌套")); !reflect.DeepEqual(got, []string{"香港", "land"}) {
		t.Errorf("嵌套 = %v", got)
	}
	if got := patchedGroup(t, raw.ProxyGroup, "全部")["exclude-filter"]; got != "^land$" {
		t.Errorf("include-all group exclude-filter = %v", got)
	}
	if _, err := applyPatch(raw, &PatchParams{HealthCheckTimeout: defaultHealthCheckTimeout}); err != nil {
		t.Fatal(err)
	}
	cfg, err := config.ParseRawConfig(raw)
	if err != nil {
		t.Fatal(err)
	}
	if got := cfg.Proxies["land"].ProxyInfo().DialerProxy; got != "香港" {
		t.Errorf("parsed dialer-proxy = %q", got)
	}
}

func TestPatchNodesFallbackAndRename(t *testing.T) {
	raw := parsePatchProfile(t, nodesProfile)
	proxy := nodeProxy("hk1")
	proxy["dialer-proxy"] = "stale"
	patchNodes(raw, []PatchNode{{
		Proxy:  proxy,
		Dialer: "日本",
		Groups: []string{"手动选择", "全部"},
	}})
	node := raw.Proxy[len(raw.Proxy)-1]
	if node["name"] != "hk1 2" {
		t.Fatalf("name = %v", node["name"])
	}
	if _, exist := node["dialer-proxy"]; exist {
		t.Errorf("missing front must drop dialer-proxy: %v", node)
	}
	if got := groupMembers(patchedGroup(t, raw.ProxyGroup, "手动选择")); !reflect.DeepEqual(got, []string{"hk1", "us1", "hk1 2"}) {
		t.Errorf("手动选择 = %v", got)
	}
	if _, exist := patchedGroup(t, raw.ProxyGroup, "全部")["exclude-filter"]; exist {
		t.Errorf("targeted include-all group must not exclude the node")
	}
	if proxy["name"] != "hk1" || proxy["dialer-proxy"] != "stale" {
		t.Errorf("source proxy mutated: %v", proxy)
	}
}

func TestPatchNodesChainedCycle(t *testing.T) {
	raw := parsePatchProfile(t, nodesProfile)
	patchNodes(raw, []PatchNode{
		{Proxy: nodeProxy("a"), Dialer: "香港", Groups: []string{"手动选择"}},
		{Proxy: nodeProxy("b"), Dialer: "手动选择", Groups: []string{"香港", "默认代理"}},
	})
	if got := groupMembers(patchedGroup(t, raw.ProxyGroup, "香港")); !reflect.DeepEqual(got, []string{"hk1"}) {
		t.Errorf("香港 = %v", got)
	}
	if got := groupMembers(patchedGroup(t, raw.ProxyGroup, "默认代理")); !reflect.DeepEqual(got, []string{"香港", "手动选择", "b"}) {
		t.Errorf("默认代理 = %v", got)
	}
}

const managedLikeProfile = `
proxies:
  - {name: hk1, type: ss, server: 1.1.1.1, port: 443, cipher: aes-128-gcm, password: p}
  - {name: chained, type: ss, server: 3.3.3.3, port: 443, cipher: aes-128-gcm, password: p, dialer-proxy: hk1}
  - {name: 直连 IPv4, type: direct}
proxy-providers:
  remote: {type: inline, payload: [{name: r1, type: socks5, server: 4.4.4.4, port: 1080}]}
  pinned: {type: inline, payload: [{name: p1, type: socks5, server: 5.5.5.5, port: 1080}], override: {dialer-proxy: hk1}}
proxy-groups:
  - {name: 默认代理, type: select, proxies: [香港, 手动选择]}
  - {name: 手动选择, type: select, include-all: true}
  - {name: 自动选择, type: url-test, include-all: true}
  - {name: AI, type: select, proxies: [默认代理, 手动选择, 香港]}
  - {name: AdBlock, type: select, proxies: [REJECT, PASS, 直连, 默认代理]}
  - {name: 直连, type: select, proxies: [直连 IPv4]}
  - {name: 香港, type: select, proxies: [hk1]}
  - {name: 低倍率节点, type: select, proxies: [hk1]}
rules:
  - MATCH,默认代理
`

func TestPatchNodesBeside(t *testing.T) {
	raw := parsePatchProfile(t, managedLikeProfile)
	patchNodes(raw, []PatchNode{{
		Proxy:  nodeProxy("land"),
		Dialer: "香港",
		Groups: []string{"默认代理", "手动选择"},
		Beside: "默认代理",
	}})
	joined := map[string]bool{"默认代理": true, "AI": true}
	for _, name := range []string{"默认代理", "AI", "AdBlock", "直连", "香港", "低倍率节点"} {
		members := groupMembers(patchedGroup(t, raw.ProxyGroup, name))
		has := len(members) > 0 && members[len(members)-1] == "land"
		if has != joined[name] {
			t.Errorf("%s members = %v", name, members)
		}
	}
	if _, exist := patchedGroup(t, raw.ProxyGroup, "手动选择")["exclude-filter"]; exist {
		t.Errorf("手动选择 must keep the node")
	}
	if got := patchedGroup(t, raw.ProxyGroup, "自动选择")["exclude-filter"]; got != "^land$" {
		t.Errorf("自动选择 exclude-filter = %v", got)
	}
	if _, err := config.ParseRawConfig(raw); err != nil {
		t.Fatal(err)
	}
}

func TestPatchNodesLibraryCycle(t *testing.T) {
	raw := parsePatchProfile(t, nodesProfile)
	patchNodes(raw, []PatchNode{
		{Proxy: nodeProxy("a"), Dialer: "b"},
		{Proxy: nodeProxy("b"), Dialer: "a"},
		{Proxy: nodeProxy("hk1"), Dialer: "us1"},
		{Proxy: nodeProxy("c"), Dialer: "hk1"},
	})
	dialers := map[string]any{}
	for _, proxy := range raw.Proxy[2:] {
		dialers[proxy["name"].(string)] = proxy["dialer-proxy"]
	}
	want := map[string]any{"a": "b", "b": nil, "hk1 2": "us1", "c": "hk1"}
	if !reflect.DeepEqual(dialers, want) {
		t.Errorf("dialers = %v", dialers)
	}
	if _, err := config.ParseRawConfig(raw); err != nil {
		t.Fatal(err)
	}
}

func TestParseNodes(t *testing.T) {
	uri := "ss://" + base64.StdEncoding.EncodeToString([]byte("aes-128-gcm:pass")) + "@1.2.3.4:8388#uri-node"
	cases := []struct {
		name  string
		text  string
		names []string
	}{
		{"uri", uri, []string{"uri-node"}},
		{"base64", base64.StdEncoding.EncodeToString([]byte(uri + "\n")), []string{"uri-node"}},
		{"single", "name: one\ntype: socks5\nserver: 1.1.1.1\nport: 1080\ndialer-proxy: x", []string{"one"}},
		{"flow", "- {name: two, type: http, server: 1.1.1.1, port: 80}", []string{"two"}},
		{"full", "mixed-port: 7890\nproxies:\n  - {name: three, type: socks5, server: 1.1.1.1, port: 1}\n  - {name: bad, type: nope}", []string{"three"}},
	}
	for _, item := range cases {
		proxies, _, err := parseNodes(item.text)
		if err != nil {
			t.Errorf("%s: %v", item.name, err)
			continue
		}
		names := make([]string, 0, len(proxies))
		for _, proxy := range proxies {
			names = append(names, proxy["name"].(string))
			if _, exist := proxy["dialer-proxy"]; exist {
				t.Errorf("%s: dialer-proxy must be stripped", item.name)
			}
		}
		if !reflect.DeepEqual(names, item.names) {
			t.Errorf("%s: names = %v, want %v", item.name, names, item.names)
		}
	}
	if _, _, err := parseNodes("hello world"); err == nil {
		t.Errorf("plain text must fail")
	}
}

type socksRelay struct {
	listener net.Listener
	mu       sync.Mutex
	targets  []string
}

func newSocksRelay(t *testing.T) *socksRelay {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	relay := &socksRelay{listener: listener}
	t.Cleanup(func() { _ = listener.Close() })
	go func() {
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			go relay.serve(conn)
		}
	}()
	return relay
}

func (r *socksRelay) port() int {
	return r.listener.Addr().(*net.TCPAddr).Port
}

func (r *socksRelay) seen() []string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([]string(nil), r.targets...)
}

func (r *socksRelay) serve(conn net.Conn) {
	defer func() { _ = conn.Close() }()
	head := make([]byte, 2)
	if _, err := io.ReadFull(conn, head); err != nil {
		return
	}
	if _, err := io.ReadFull(conn, make([]byte, head[1])); err != nil {
		return
	}
	if _, err := conn.Write([]byte{5, 0}); err != nil {
		return
	}
	request := make([]byte, 4)
	if _, err := io.ReadFull(conn, request); err != nil {
		return
	}
	var host string
	switch request[3] {
	case 1:
		addr := make([]byte, 4)
		if _, err := io.ReadFull(conn, addr); err != nil {
			return
		}
		host = net.IP(addr).String()
	case 3:
		size := make([]byte, 1)
		if _, err := io.ReadFull(conn, size); err != nil {
			return
		}
		name := make([]byte, size[0])
		if _, err := io.ReadFull(conn, name); err != nil {
			return
		}
		host = string(name)
	default:
		return
	}
	portBytes := make([]byte, 2)
	if _, err := io.ReadFull(conn, portBytes); err != nil {
		return
	}
	target := net.JoinHostPort(host, strconv.Itoa(int(portBytes[0])<<8|int(portBytes[1])))
	r.mu.Lock()
	r.targets = append(r.targets, target)
	r.mu.Unlock()
	upstream, err := net.Dial("tcp", target)
	if err != nil {
		_, _ = conn.Write([]byte{5, 5, 0, 1, 0, 0, 0, 0, 0, 0})
		return
	}
	defer func() { _ = upstream.Close() }()
	if _, err := conn.Write([]byte{5, 0, 0, 1, 0, 0, 0, 0, 0, 0}); err != nil {
		return
	}
	go func() { _, _ = io.Copy(upstream, conn) }()
	_, _ = io.Copy(conn, upstream)
}

func TestPatchNodesChainTraffic(t *testing.T) {
	target := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = io.WriteString(w, "landed")
	}))
	t.Cleanup(target.Close)
	targetAddr := target.Listener.Addr().(*net.TCPAddr)
	front := newSocksRelay(t)
	landing := newSocksRelay(t)

	raw := parsePatchProfile(t, fmt.Sprintf(`
proxies:
  - {name: hk1, type: socks5, server: 127.0.0.1, port: %d}
proxy-groups:
  - {name: 默认代理, type: select, proxies: [香港]}
  - {name: 香港, type: select, proxies: [hk1]}
rules:
  - MATCH,默认代理
`, front.port()))
	patchNodes(raw, []PatchNode{{
		Proxy:  map[string]any{"name": "land", "type": "socks5", "server": "127.0.0.1", "port": landing.port()},
		Dialer: "香港",
		Groups: []string{"默认代理"},
	}})
	cfg, err := config.ParseRawConfig(raw)
	if err != nil {
		t.Fatal(err)
	}
	tunnel.UpdateProxies(cfg.Proxies, cfg.Providers)
	t.Cleanup(func() { tunnel.UpdateProxies(map[string]constant.Proxy{}, map[string]provider.ProxyProvider{}) })

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	conn, err := cfg.Proxies["land"].DialContext(ctx, &constant.Metadata{
		NetWork: constant.TCP,
		Type:    constant.INNER,
		DstIP:   netip.MustParseAddr("127.0.0.1"),
		DstPort: uint16(targetAddr.Port),
	})
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = conn.Close() }()
	_ = conn.SetDeadline(time.Now().Add(10 * time.Second))
	if _, err := io.WriteString(conn, "GET / HTTP/1.0\r\nHost: target\r\n\r\n"); err != nil {
		t.Fatal(err)
	}
	body, err := io.ReadAll(conn)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasSuffix(string(body), "landed") {
		t.Fatalf("unexpected response: %q", body)
	}
	if got, want := front.seen(), []string{net.JoinHostPort("127.0.0.1", strconv.Itoa(landing.port()))}; !reflect.DeepEqual(got, want) {
		t.Errorf("front relay targets = %v, want %v", got, want)
	}
	if got, want := landing.seen(), []string{targetAddr.String()}; !reflect.DeepEqual(got, want) {
		t.Errorf("landing relay targets = %v, want %v", got, want)
	}
}

func TestDialerDependents(t *testing.T) {
	raw := parsePatchProfile(t, `
proxies:
  - {name: hk1, type: socks5, server: 127.0.0.1, port: 1, udp: true}
  - {name: jp1, type: ss, server: 127.0.0.1, port: 2, cipher: aes-128-gcm, password: x}
proxy-groups:
  - {name: 香港, type: select, proxies: [hk1]}
  - {name: 前置, type: select, proxies: [香港, jp1]}
  - {name: 默认代理, type: select, proxies: [前置]}
rules:
  - MATCH,默认代理
`)
	patchNodes(raw, []PatchNode{
		{Proxy: nodeProxy("land"), Dialer: "前置", Groups: []string{"默认代理"}},
		{Proxy: nodeProxy("relay"), Dialer: "land"},
		{Proxy: nodeProxy("plain"), Groups: []string{"默认代理"}},
	})
	cfg, err := config.ParseRawConfig(raw)
	if err != nil {
		t.Fatal(err)
	}
	tunnel.UpdateProxies(cfg.Proxies, cfg.Providers)
	t.Cleanup(func() { tunnel.UpdateProxies(map[string]constant.Proxy{}, map[string]provider.ProxyProvider{}) })

	for group, want := range map[string][]string{
		"前置":   {"land", "relay"},
		"香港":   {"land", "relay"},
		"默认代理": {},
	} {
		if got := dialerDependents(group); !reflect.DeepEqual(got, want) {
			t.Errorf("dialerDependents(%s) = %v, want %v", group, got, want)
		}
	}
	if !dialerSupportsUDP("前置") {
		t.Errorf("hk1 supports UDP")
	}
	if err := cfg.Proxies["前置"].(*adapter.Proxy).ProxyAdapter.(outboundgroup.SelectAble).Set("jp1"); err != nil {
		t.Fatal(err)
	}
	if got := dialerDependents("香港"); len(got) != 0 {
		t.Errorf("香港 is no longer on the chain: %v", got)
	}
	if dialerSupportsUDP("前置") || dialerSupportsUDP("relay") {
		t.Errorf("jp1 has no UDP, so the chain through it must report no UDP")
	}
	if !dialerSupportsUDP("absent") {
		t.Errorf("unknown dialers must not warn")
	}
}

const regionMarkedProfile = `
proxies:
  - {name: hk1, type: ss, server: 1.1.1.1, port: 443, cipher: aes-128-gcm, password: p}
  - {name: us1, type: ss, server: 2.2.2.2, port: 443, cipher: aes-128-gcm, password: p}
proxy-groups:
  - {name: 默认代理, type: select, proxies: [香港, 美国, 手动选择]}
  - {name: 手动选择, type: select, include-all: true}
  - {name: AI, type: select, proxies: [默认代理, 手动选择, 香港, 美国]}
  - {name: 香港-自动选择, type: url-test, x-region: 香港, proxies: [hk1]}
  - {name: 香港, type: select, x-region: 香港, x-region-nodes: [HK Home, HK Land], proxies: [香港-自动选择, hk1]}
  - {name: 美国-自动选择, type: url-test, x-region: 美国, proxies: [us1]}
  - {name: 美国, type: select, x-region: 美国, x-region-nodes: [US Home], proxies: [美国-自动选择, us1]}
  - {name: 其他节点, type: select, proxies: [hk1]}
rules:
  - MATCH,默认代理
`

func TestPatchNodesRegions(t *testing.T) {
	raw := parsePatchProfile(t, regionMarkedProfile)
	defaults := []string{"默认代理", "手动选择"}
	patchNodes(raw, []PatchNode{
		{Proxy: nodeProxy("HK Home"), Groups: defaults, Beside: "默认代理", Regions: true},
		{Proxy: nodeProxy("HK Land"), Dialer: "香港", Groups: defaults, Beside: "默认代理", Landing: true},
		{Proxy: nodeProxy("US Pick"), Dialer: "香港", Groups: []string{"美国"}, Landing: true},
		{Proxy: nodeProxy("US Manual"), Groups: []string{"美国"}},
	})
	want := map[string][]string{
		"默认代理":    {"香港", "美国", "手动选择", "HK Home", "HK Land"},
		"AI":      {"默认代理", "手动选择", "香港", "美国", "HK Home", "HK Land"},
		"香港-自动选择": {"hk1", "HK Home"},
		"香港":      {"香港-自动选择", "hk1", "HK Home"},
		"美国-自动选择": {"us1", "US Manual"},
		"美国":      {"美国-自动选择", "us1", "US Pick", "US Manual"},
		"其他节点":    {"hk1"},
	}
	for name, members := range want {
		group := patchedGroup(t, raw.ProxyGroup, name)
		if got := groupMembers(group); !reflect.DeepEqual(got, members) {
			t.Errorf("%s members = %v", name, got)
		}
		if _, exist := group[regionMarker]; exist {
			t.Errorf("%s keeps %s", name, regionMarker)
		}
		if _, exist := group[regionNodesMarker]; exist {
			t.Errorf("%s keeps %s", name, regionNodesMarker)
		}
	}
	if _, err := config.ParseRawConfig(raw); err != nil {
		t.Fatal(err)
	}
}

func TestPatchNodesStripsRegionMarkersWithoutNodes(t *testing.T) {
	raw := parsePatchProfile(t, regionMarkedProfile)
	patchNodes(raw, nil)
	for _, group := range raw.ProxyGroup {
		if _, exist := group[regionMarker]; exist {
			t.Errorf("%v keeps %s", group["name"], regionMarker)
		}
	}
}
