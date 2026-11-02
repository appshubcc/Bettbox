package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strconv"
	"testing"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

func parsePatchProfile(t *testing.T, content string) *config.RawConfig {
	t.Helper()
	rawCfg, err := config.UnmarshalRawConfig([]byte(content))
	if err != nil {
		t.Fatal(err)
	}
	return rawCfg
}

func patchParams(t *testing.T, content string) *PatchParams {
	t.Helper()
	params := &PatchParams{HealthCheckTimeout: defaultHealthCheckTimeout}
	if err := UnmarshalJson([]byte(content), params); err != nil {
		t.Fatal(err)
	}
	return params
}

func TestParseRule(t *testing.T) {
	cases := []struct {
		rule   string
		target string
		pass   string
	}{
		{"DOMAIN-SUFFIX,netflix.com,Streaming", "Streaming", "DOMAIN-SUFFIX,netflix.com,PASS"},
		{" IP-CIDR, 10.0.0.0/8 , Streaming ,no-resolve", "Streaming", "IP-CIDR,10.0.0.0/8,PASS,no-resolve"},
		{"RULE-SET,inline,Streaming,src,no-resolve", "Streaming", "RULE-SET,inline,PASS,src,no-resolve"},
		{"DOMAIN,a.com,Streaming,no-resolve", "Streaming", "DOMAIN,a.com,PASS"},
		{"AND,((NETWORK,UDP),(DST-PORT,443)),Streaming", "Streaming", "AND,((NETWORK,UDP),(DST-PORT,443)),PASS"},
		{"MATCH,Streaming", "Streaming", "MATCH,PASS"},
		{"DOMAIN-WILDCARD,*.a.com,Streaming", "Streaming", "DOMAIN-WILDCARD,*.a.com,PASS"},
		{"SUB-RULE,(NETWORK,tcp),sub1", "", ""},
		{"MATCH", "", ""},
	}
	for _, item := range cases {
		parsed := parseRule(item.rule)
		if parsed.target != item.target {
			t.Errorf("parseRule(%q).target = %q, want %q", item.rule, parsed.target, item.target)
		}
		if item.pass == "" {
			if parsed.hasTarget {
				t.Errorf("parseRule(%q) should not have a target", item.rule)
			}
			continue
		}
		parsed.target = "PASS"
		if got := parsed.String(); got != item.pass {
			t.Errorf("parseRule(%q) with PASS = %q, want %q", item.rule, got, item.pass)
		}
	}
}

func TestApplyPatchGeneral(t *testing.T) {
	rawCfg := parsePatchProfile(t, "mode: direct\nglobal-ua: profile-ua\nsecret: keep\ntun:\n  device: utun9\n  mtu: 1400\n")
	params := patchParams(t, `{"general":{"mode":"global","log-level":"debug","find-process-mode":"always","mixed-port":7891,"authentication":[],"skip-auth-prefixes":null,"global-ua":null,"tun":{"enable":true,"stack":"system","dns-hijack":["any:53"],"route-address":["0.0.0.0/1"]}}}`)
	if _, err := applyPatch(rawCfg, params); err != nil {
		t.Fatal(err)
	}
	defaults := config.DefaultRawConfig()
	if rawCfg.Mode != tunnel.Global || rawCfg.LogLevel != log.DEBUG || rawCfg.MixedPort != 7891 {
		t.Errorf("general values were not applied: %v %v %d", rawCfg.Mode, rawCfg.LogLevel, rawCfg.MixedPort)
	}
	if rawCfg.GlobalUA != defaults.GlobalUA {
		t.Errorf("null global-ua should fall back to the default, got %q", rawCfg.GlobalUA)
	}
	if rawCfg.Secret != "keep" {
		t.Errorf("secret should be kept, got %q", rawCfg.Secret)
	}
	if !rawCfg.Tun.Enable || rawCfg.Tun.Device != "utun9" || rawCfg.Tun.MTU != 1400 || len(rawCfg.Tun.RouteAddress) != 1 {
		t.Errorf("tun should be merged: %+v", rawCfg.Tun)
	}
}

func TestApplyPatchInterfaceName(t *testing.T) {
	rawCfg := parsePatchProfile(t, "interface-name: profile0\n")
	if _, err := applyPatch(rawCfg, patchParams(t, `{"general":{"mode":"rule"}}`)); err != nil {
		t.Fatal(err)
	}
	if rawCfg.Interface != "profile0" {
		t.Errorf("profile interface-name should be kept, got %q", rawCfg.Interface)
	}
	if _, err := applyPatch(rawCfg, patchParams(t, `{"general":{"interface-name":"en0"}}`)); err != nil {
		t.Fatal(err)
	}
	if rawCfg.Interface != "en0" {
		t.Errorf("patched interface-name should override, got %q", rawCfg.Interface)
	}
}

func TestApplyPatchTunDNSMode(t *testing.T) {
	rawCfg := parsePatchProfile(t, "tun:\n  dns-mode: native\n")
	if _, err := applyPatch(rawCfg, patchParams(t, `{"general":{"tun":{"enable":true,"stack":"system"}}}`)); err != nil {
		t.Fatal(err)
	}
	if rawCfg.Tun.DNSMode != "native" {
		t.Errorf("profile dns-mode should be kept, got %q", rawCfg.Tun.DNSMode)
	}
	if _, err := applyPatch(rawCfg, patchParams(t, `{"general":{"tun":{"enable":true,"stack":"system","dns-mode":"hijack"}}}`)); err != nil {
		t.Fatal(err)
	}
	if rawCfg.Tun.DNSMode != "hijack" {
		t.Errorf("patched dns-mode should override, got %q", rawCfg.Tun.DNSMode)
	}
}

func TestApplyPatchTunCongestionController(t *testing.T) {
	general := `{"general":{"tun":{"enable":true,"stack":"mips"}}}`
	cases := map[string]string{
		"tun:\n  congestion-controller: bbr\n": "bbr",
		"mode: rule\n":                         "",
	}
	for profile, want := range cases {
		rawCfg := parsePatchProfile(t, profile)
		if _, err := applyPatch(rawCfg, patchParams(t, general)); err != nil {
			t.Fatal(err)
		}
		if rawCfg.Tun.CongestionController != want {
			t.Errorf("congestion-controller = %q, want %q", rawCfg.Tun.CongestionController, want)
		}
	}
}

func TestApplyPatchProvidersAndGroups(t *testing.T) {
	rawCfg := parsePatchProfile(t, `
proxy-providers:
  remote: {type: http, url: "https://example.com/sub", path: ./a.yaml}
  local: {type: file, path: ./b.yaml}
proxies:
  - {name: A, type: trojan, server: a.example.com, port: 443, password: p}
  - {name: B, type: vless, server: b.example.com, port: 443, uuid: u, tls: true, reality-opts: {public-key: k, short-id: 123}}
proxy-groups:
  - {name: GLOBAL, type: select, proxies: [Main]}
  - {name: Main, type: select, proxies: [A, B, DIRECT], tolerance: 50.0}
  - {name: Off, type: select, proxies: [A]}
rules:
  - DOMAIN,a.com,Off
  - MATCH,Main
`)
	base := filepath.Join("data", "providers", "p1")
	params := patchParams(t, `{"node-exclude-filter":"^A$","disabled-groups":["Off"],"select-global":true,"prepend-rules":["DOMAIN,q.com,REJECT"]}`)
	params.ProvidersPath = base
	global, err := applyPatch(rawCfg, params)
	if err != nil {
		t.Fatal(err)
	}
	if global != "Main" {
		t.Errorf("global = %q, want Main", global)
	}
	wantPath := filepath.Join(base, "proxies", "3dd403f32a12bab6123243ae838133fb")
	if got := rawCfg.ProxyProvider["remote"]["path"]; got != wantPath {
		t.Errorf("remote path = %v, want %s", got, wantPath)
	}
	if rawCfg.ProxyProvider["local"]["path"] != "./b.yaml" {
		t.Errorf("file provider path should be kept")
	}
	if got := rawCfg.ProxyProvider["remote"]["exclude-filter"]; got != "^A$" {
		t.Errorf("provider exclude-filter = %v", got)
	}
	if len(rawCfg.ProxyGroup) != 1 || rawCfg.ProxyGroup[0]["name"] != "Main" {
		t.Fatalf("groups = %v", rawCfg.ProxyGroup)
	}
	if got := rawCfg.ProxyGroup[0]["proxies"]; !reflect.DeepEqual(got, []any{"B", "DIRECT"}) {
		t.Errorf("filtered proxies = %v", got)
	}
	if got := rawCfg.ProxyGroup[0]["tolerance"]; got != 50 {
		t.Errorf("tolerance = %v (%T)", got, got)
	}
	wantRules := []string{"DOMAIN,q.com,REJECT", "DOMAIN,a.com,PASS", "MATCH,Main"}
	if !reflect.DeepEqual(rawCfg.Rule, wantRules) {
		t.Errorf("rules = %v", rawCfg.Rule)
	}
	if got := rawCfg.Proxy[1]["reality-opts"].(map[string]any)["short-id"]; got != "123" {
		t.Errorf("short-id = %v (%T)", got, got)
	}
	if _, exist := rawCfg.Proxy[0]["client-fingerprint"]; !exist {
		t.Errorf("client-fingerprint should be filled for trojan")
	}
}

func TestApplyPatchAndroidDns(t *testing.T) {
	previous := patchForAndroid
	patchForAndroid = true
	defer func() { patchForAndroid = previous }()

	cases := []struct {
		dns    string
		listen string
	}{
		{"dns: {enable: true, listen: '0.0.0.0:53'}", "127.0.0.1:10053"},
		{"dns: {enable: true, listen: '0.0.0.0:1053'}", "127.0.0.1:1053"},
		{"dns: {enable: true, listen: '0.0.0.0:53', proxy-server-nameserver: ['127.0.0.1:5353']}", "127.0.0.1:53"},
		{"dns: {enable: true, listen: '0.0.0.0:1053', proxy-server-nameserver: ['127.0.0.1:5353']}\nrule-providers: {}", "127.0.0.1:1053"},
	}
	for _, item := range cases {
		rawCfg := parsePatchProfile(t, item.dns+"\nntp: {enable: true, write-to-system: true}\n")
		if _, err := applyPatch(rawCfg, patchParams(t, `{}`)); err != nil {
			t.Fatal(err)
		}
		if rawCfg.DNS.Listen != item.listen {
			t.Errorf("%s: listen = %q, want %q", item.dns, rawCfg.DNS.Listen, item.listen)
		}
		if rawCfg.NTP.WriteToSystem {
			t.Errorf("write-to-system should be disabled on Android")
		}
	}
}

func TestApplyPatchProfileServices(t *testing.T) {
	previous := patchForAndroid
	patchForAndroid = false
	defer func() { patchForAndroid = previous }()

	profile := `
external-controller-tls: 0.0.0.0:19443
external-controller-unix: x.sock
external-controller-pipe: \\.\pipe\x
external-doh-server: /dns-query
ss-config: ss://aes-128-gcm:pass@:17891
tuic-server: {enable: true, listen: 0.0.0.0:17892}
listeners:
  - {name: socks, type: socks, port: 17890}
  - {name: tun, type: tun, stack: system}
tunnels:
  - tcp,0.0.0.0:16553,1.1.1.1:53,DIRECT
dns: {enable: true, listen: 0.0.0.0:1053, nameserver: [223.5.5.5]}
`
	cases := []struct {
		allowLan bool
		address  string
	}{
		{false, "127.0.0.1"},
		{true, "0.0.0.0"},
	}
	for _, item := range cases {
		rawCfg := parsePatchProfile(t, profile)
		params := patchParams(t, `{"general":{"allow-lan":`+strconv.FormatBool(item.allowLan)+`},"tunnels":["tcp,0.0.0.0:17000,1.1.1.1:53,DIRECT"]}`)
		if _, err := applyPatch(rawCfg, params); err != nil {
			t.Fatal(err)
		}
		if rawCfg.ExternalControllerTLS != "" || rawCfg.ExternalControllerUnix != "" || rawCfg.ExternalControllerPipe != "" || rawCfg.ExternalDohServer != "" {
			t.Errorf("allow-lan=%t: profile controllers should be removed", item.allowLan)
		}
		if rawCfg.ShadowSocksConfig != "" || rawCfg.VmessConfig != "" || rawCfg.TuicServer.Enable {
			t.Errorf("allow-lan=%t: profile inbound servers should be removed", item.allowLan)
		}
		if len(rawCfg.Listeners) != 1 || rawCfg.Listeners[0]["name"] != "socks" {
			t.Fatalf("allow-lan=%t: tun listener should be removed: %v", item.allowLan, rawCfg.Listeners)
		}
		listen, _ := rawCfg.Listeners[0]["listen"].(string)
		if item.allowLan && listen != "" || !item.allowLan && listen != item.address {
			t.Errorf("allow-lan=%t: listener listen = %q", item.allowLan, listen)
		}
		if len(rawCfg.Tunnels) != 2 || rawCfg.Tunnels[0].Address != item.address+":16553" || rawCfg.Tunnels[1].Address != "0.0.0.0:17000" {
			t.Errorf("allow-lan=%t: tunnels = %+v", item.allowLan, rawCfg.Tunnels)
		}
		if rawCfg.DNS.Listen != item.address+":1053" {
			t.Errorf("allow-lan=%t: dns listen = %q", item.allowLan, rawCfg.DNS.Listen)
		}
	}
}

func TestApplyPatchDnsInjection(t *testing.T) {
	rawCfg := parsePatchProfile(t, "dns: {enable: false, nameserver: ['10.0.0.1']}\n")
	dns, _ := json.Marshal(map[string]any{
		"enable":            true,
		"nameserver":        []string{"1.1.1.1"},
		"nameserver-policy": map[string]any{"+.a.com": []string{"8.8.8.8", "8.8.4.4"}},
	})
	params := patchParams(t, `{}`)
	params.Dns = dns
	if _, err := applyPatch(rawCfg, params); err != nil {
		t.Fatal(err)
	}
	if !rawCfg.DNS.Enable || !reflect.DeepEqual(rawCfg.DNS.NameServer, []string{"1.1.1.1", "system://"}) {
		t.Errorf("dns = %+v", rawCfg.DNS.NameServer)
	}
	if len(rawCfg.DNS.ProxyServerNameserver) != 0 {
		t.Errorf("original dns should not leak into proxy-server-nameserver: %v", rawCfg.DNS.ProxyServerNameserver)
	}

	for _, item := range []struct {
		allowLan bool
		listen   string
	}{
		{false, "127.0.0.1:10053"},
		{true, "0.0.0.0:10053"},
	} {
		injected := parsePatchProfile(t, "dns: {enable: false}\n")
		dns, _ := json.Marshal(map[string]any{"enable": true, "listen": "0.0.0.0:10053"})
		params := patchParams(t, `{"general":{"allow-lan":`+strconv.FormatBool(item.allowLan)+`}}`)
		params.Dns = dns
		if _, err := applyPatch(injected, params); err != nil {
			t.Fatal(err)
		}
		if injected.DNS.Listen != item.listen {
			t.Errorf("allow-lan=%t: injected dns listen = %q, want %q", item.allowLan, injected.DNS.Listen, item.listen)
		}
	}

	enabled := parsePatchProfile(t, "dns: {enable: true, nameserver: ['10.0.0.1']}\n")
	if _, err := applyPatch(enabled, params); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(enabled.DNS.NameServer, []string{"10.0.0.1"}) {
		t.Errorf("enabled dns without override should be kept: %v", enabled.DNS.NameServer)
	}
}

func TestApplyPatchDnsIPv6(t *testing.T) {
	for _, item := range []struct {
		general string
		want    bool
	}{
		{`{"ipv6": false}`, false},
		{`{"ipv6": true}`, true},
	} {
		rawCfg := parsePatchProfile(t, "dns: {enable: true, ipv6: true, nameserver: ['10.0.0.1']}\n")
		params := patchParams(t, `{}`)
		params.General = json.RawMessage(item.general)
		if _, err := applyPatch(rawCfg, params); err != nil {
			t.Fatal(err)
		}
		if rawCfg.DNS.IPv6 != item.want {
			t.Errorf("general %s: dns.ipv6 = %t, want %t", item.general, rawCfg.DNS.IPv6, item.want)
		}
	}
}

func TestApplyPatchDnsFallbackFilter(t *testing.T) {
	rawCfg := parsePatchProfile(t, "dns: {enable: true, nameserver: ['10.0.0.1'], fallback: ['1.1.1.1'], fallback-filter: {geoip: true, ipcidr: ['240.0.0.0/4'], domain: ['+.google.com'], geosite: ['gfw']}}\n")
	if _, err := applyPatch(rawCfg, patchParams(t, `{}`)); err != nil {
		t.Fatal(err)
	}
	filter := rawCfg.DNS.FallbackFilter
	if len(filter.Domain) != 0 || len(filter.GeoSite) != 0 {
		t.Errorf("fallback-filter domain = %v, geosite = %v, want empty", filter.Domain, filter.GeoSite)
	}
	if !filter.GeoIP || len(filter.IPCIDR) != 1 {
		t.Errorf("fallback-filter geoip = %t, ipcidr = %v, want kept", filter.GeoIP, filter.IPCIDR)
	}
}

func TestApplyPatchBettboxRuleSets(t *testing.T) {
	rawCfg := parsePatchProfile(t, "dns: {enable: false}\nrule-providers:\n  cn: {type: http, behavior: domain, format: mrs, url: 'https://example.com/cn.mrs'}\n  private_bettbox: {type: http, behavior: domain, format: mrs, url: 'https://example.com/private.mrs'}\nrules:\n  - RULE-SET,cn,DIRECT\n  - MATCH,DIRECT\n")
	dns, _ := json.Marshal(map[string]any{
		"enable":            true,
		"fake-ip-filter":    []string{"*", "rule-set:private_bettbox", "rule-set:fakeip-filter_bettbox", "RULE-SET:category-ntp_bettbox,cn_bettbox"},
		"nameserver-policy": map[string]any{"rule-set:cn_bettbox": "119.29.29.29"},
	})
	params := patchParams(t, `{"providers-path": "/data/providers", "prepend-rules": ["AND,((NETWORK,UDP),(DST-PORT,443),(NOT,((OR,((RULE-SET,cn_bettbox),(RULE-SET,cn_ip_bettbox,no-resolve)))))),REJECT"]}`)
	params.Dns = dns
	if _, err := applyPatch(rawCfg, params); err != nil {
		t.Fatal(err)
	}
	if got := rawCfg.RuleProvider["private_bettbox"]["url"]; got != "https://example.com/private.mrs" {
		t.Errorf("existing provider overwritten: %v", got)
	}
	if got := rawCfg.RuleProvider["cn"]["url"]; got != "https://example.com/cn.mrs" {
		t.Errorf("user provider changed: %v", got)
	}
	cases := map[string][2]string{
		"cn_bettbox":            {"domain", "geosite/cn.mrs"},
		"cn_ip_bettbox":         {"ipcidr", "geoip/cn.mrs"},
		"category-ntp_bettbox":  {"domain", "geosite/category-ntp.mrs"},
		"fakeip-filter_bettbox": {"domain", "geosite/fakeip-filter.mrs"},
	}
	for name, want := range cases {
		provider := rawCfg.RuleProvider[name]
		url := bettboxRuleSetBaseURL + want[1]
		if provider == nil || provider["behavior"] != want[0] || provider["url"] != url || provider["format"] != "mrs" || provider["path-in-bundle"] != "geo/"+want[1] || provider["path"] != providerFilePath("/data/providers", "rules", url) {
			t.Errorf("%s = %v", name, provider)
		}
	}
	if len(rawCfg.RuleProvider) != 6 {
		t.Errorf("providers = %v", rawCfg.RuleProvider)
	}

	plain := parsePatchProfile(t, "dns: {enable: true, nameserver: ['10.0.0.1']}\nrules:\n  - MATCH,DIRECT\n")
	if _, err := applyPatch(plain, patchParams(t, `{}`)); err != nil {
		t.Fatal(err)
	}
	if len(plain.RuleProvider) != 0 {
		t.Errorf("unreferenced providers added: %v", plain.RuleProvider)
	}
}

func TestPrepareSetupReuse(t *testing.T) {
	dir := t.TempDir()
	profile := filepath.Join(dir, "profile.yaml")
	content := "proxies:\n  - {name: A, type: ss, server: a.example.com, port: 1, cipher: aes-128-gcm, password: p}\nproxy-groups:\n  - {name: Main, type: select, proxies: [A]}\nrules:\n  - MATCH,Main\n"
	if err := os.WriteFile(profile, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	params := func(patch string) *SetupParams {
		setup := defaultSetupParams()
		setup.ProfilePath = profile
		setup.Patch = patchParams(t, patch)
		return setup
	}

	validated, err := prepareSetup(params(`{"select-global":true}`))
	if err != nil {
		t.Fatal(err)
	}
	if validated.reused || validated.global != "Main" {
		t.Fatalf("first prepare: reused=%t global=%q", validated.reused, validated.global)
	}
	storePreparedSetup(validated)

	applied, err := prepareSetup(params(`{"select-global":true}`))
	if err != nil {
		t.Fatal(err)
	}
	if applied != validated || !applied.reused {
		t.Errorf("identical params should reuse the validated config")
	}

	storePreparedSetup(validated)
	changed, err := prepareSetup(params(`{"select-global":false}`))
	if err != nil {
		t.Fatal(err)
	}
	if changed == validated || changed.reused {
		t.Errorf("different params must not reuse the validated config")
	}
	if again, _ := prepareSetup(params(`{"select-global":true}`)); again == validated {
		t.Errorf("a missed lookup should clear the cached config")
	}

	storePreparedSetup(validated)
	if err := os.WriteFile(profile, []byte(content+"\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if edited, _ := prepareSetup(params(`{"select-global":true}`)); edited == validated {
		t.Errorf("a changed profile must not reuse the validated config")
	}
}

func TestMarshalProxies(t *testing.T) {
	previousHome := constant.Path.HomeDir()
	constant.SetHomeDir(t.TempDir())
	defer constant.SetHomeDir(previousHome)
	rawCfg := parsePatchProfile(t, `
proxies:
  - {name: A, type: ss, server: a.example.com, port: 1, cipher: aes-128-gcm, password: p}
  - {name: B, type: ss, server: b.example.com, port: 1, cipher: aes-128-gcm, password: p}
proxy-providers:
  inline:
    type: inline
    payload:
      - {name: C, type: trojan, server: c.example.com, port: 443, password: p}
proxy-groups:
  - {name: Main, type: select, proxies: [Auto, Balance, A, DIRECT], icon: main.png}
  - {name: Auto, type: url-test, proxies: [A, B], use: [inline], url: "https://example.com/204", interval: 300, lazy: true, hidden: true}
  - {name: Balance, type: load-balance, proxies: [A, B], url: "https://example.com/204", interval: 300, lazy: true}
rules:
  - MATCH,Main
`)
	cfg, err := config.ParseRawConfig(rawCfg)
	if err != nil {
		t.Fatal(err)
	}
	for _, pd := range cfg.Providers {
		if err := pd.Initial(); err != nil {
			t.Fatal(err)
		}
	}
	compact, err := marshalProxies(cfg.Proxies)
	if err != nil {
		t.Fatal(err)
	}
	payload := struct {
		Names  []string         `json:"names"`
		Types  []string         `json:"types"`
		Groups []map[string]any `json:"groups"`
	}{}
	if err := json.Unmarshal(compact, &payload); err != nil {
		t.Fatal(err)
	}
	if len(payload.Names) != len(payload.Types) {
		t.Fatalf("names %d, types %d", len(payload.Names), len(payload.Types))
	}
	full, _ := json.Marshal(cfg.Proxies)
	expected := map[string]map[string]any{}
	_ = json.Unmarshal(full, &expected)
	order := make([]string, 0, len(payload.Groups))
	for _, group := range payload.Groups {
		name := group["name"].(string)
		order = append(order, name)
		item := expected[name]
		if item == nil {
			t.Fatalf("unexpected group %s", name)
		}
		var members []any
		for _, member := range group["all"].([]any) {
			index := int(member.(float64))
			members = append(members, payload.Names[index])
			if top := expected[payload.Names[index]]; top != nil && top["type"] != payload.Types[index] {
				t.Errorf("%s type = %s, want %v", payload.Names[index], payload.Types[index], top["type"])
			}
		}
		if !reflect.DeepEqual(members, item["all"]) {
			t.Errorf("%s members = %v, want %v", name, members, item["all"])
		}
		for _, key := range []string{"name", "type", "now", "testUrl", "hidden", "icon"} {
			if !reflect.DeepEqual(group[key], item[key]) {
				t.Errorf("%s.%s = %v, want %v", name, key, group[key], item[key])
			}
		}
	}
	if !reflect.DeepEqual(order, []string{"GLOBAL", "Main", "Auto", "Balance"}) {
		t.Errorf("group order = %v", order)
	}
	for i, name := range payload.Names {
		if name == "C" && payload.Types[i] != "Trojan" {
			t.Errorf("provider proxy type = %s", payload.Types[i])
		}
	}
	nows := map[string]string{}
	for _, group := range payload.Groups {
		if now, ok := group["now"].(string); ok {
			nows[group["name"].(string)] = now
		}
	}
	groupNowsLock.Lock()
	remembered := lastGroupNows
	groupNowsLock.Unlock()
	if !reflect.DeepEqual(remembered, nows) {
		t.Errorf("remembered nows = %v, want %v", remembered, nows)
	}
}

func TestDecodeScriptedConfig(t *testing.T) {
	rawCfg, err := decodeScriptedConfig([]byte(`{"mixed-port":7891,"mode":"global","rules":["MATCH,Main"],"proxies":[{"name":"A","type":"ss","port":443,"ratio":1.5,"opts":{"mtu":1400,"ids":[1,2]}}],"proxy-groups":[{"name":"Main","type":"select","proxies":["A"],"tolerance":50}],"proxy-providers":{},"dns":{"enable":true,"nameserver-policy":{"+.b.com":"1.1.1.1","+.a.com":["8.8.8.8"]}}}`))
	if err != nil {
		t.Fatal(err)
	}
	if rawCfg.MixedPort != 7891 || rawCfg.Mode != tunnel.Global || !reflect.DeepEqual(rawCfg.Rule, []string{"MATCH,Main"}) {
		t.Errorf("typed fields: %d %v %v", rawCfg.MixedPort, rawCfg.Mode, rawCfg.Rule)
	}
	proxy := rawCfg.Proxy[0]
	if proxy["port"] != 443 || proxy["ratio"] != 1.5 {
		t.Errorf("numbers: port %v (%T), ratio %v (%T)", proxy["port"], proxy["port"], proxy["ratio"], proxy["ratio"])
	}
	opts := proxy["opts"].(map[string]any)
	if opts["mtu"] != 1400 || !reflect.DeepEqual(opts["ids"], []any{1, 2}) {
		t.Errorf("nested numbers: %v", opts)
	}
	if rawCfg.ProxyGroup[0]["tolerance"] != 50 {
		t.Errorf("group number: %v", rawCfg.ProxyGroup[0]["tolerance"])
	}
	if rawCfg.ProxyProvider == nil {
		t.Errorf("an empty proxy-providers object should stay non-nil")
	}
	policy := rawCfg.DNS.NameServerPolicy
	if policy == nil || policy.Oldest().Key != "+.b.com" {
		t.Errorf("nameserver-policy order should be kept")
	}
	if !rawCfg.DNS.UseHosts {
		t.Errorf("defaults should apply to keys the script left out")
	}
}

func TestDisabledGroupsCascade(t *testing.T) {
	rawCfg, err := config.UnmarshalRawConfig([]byte(`proxies:
  - {name: A, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: x}
proxy-providers:
  p1: {type: http, url: "https://example.com/p1", path: ./p1.yaml}
proxy-groups:
  - {name: Main, type: select, proxies: [HK, Media, A, DIRECT]}
  - {name: Media, type: select, proxies: [HK]}
  - {name: Stream, type: select, proxies: [Media], use: [p1]}
  - {name: Auto, type: url-test, proxies: [HK], include-all: true}
  - {name: HK, type: select, proxies: [A]}
rules:
  - DOMAIN,hk.com,HK
  - DOMAIN,media.com,Media
  - DOMAIN,stream.com,Stream
  - MATCH,Main
`))
	if err != nil {
		t.Fatal(err)
	}
	params := patchParams(t, `{"disabled-groups":["HK"]}`)
	if _, err := applyPatch(rawCfg, params); err != nil {
		t.Fatal(err)
	}
	groups := map[string][]any{}
	for _, group := range rawCfg.ProxyGroup {
		name, _ := groupName(group)
		proxies, _ := group["proxies"].([]any)
		groups[name] = proxies
	}
	if _, ok := groups["HK"]; ok {
		t.Fatal("HK should be removed")
	}
	if _, ok := groups["Media"]; ok {
		t.Fatal("Media should cascade off")
	}
	if !reflect.DeepEqual(groups["Main"], []any{"A", "DIRECT"}) {
		t.Fatalf("Main proxies: %v", groups["Main"])
	}
	if _, ok := groups["Stream"]; !ok || len(groups["Auto"]) != 0 {
		t.Fatalf("source groups should stay: %v", groups)
	}
	want := []string{"DOMAIN,hk.com,PASS", "DOMAIN,media.com,PASS", "DOMAIN,stream.com,Stream", "MATCH,Main"}
	if !reflect.DeepEqual(rawCfg.Rule, want) {
		t.Fatalf("rules: %v", rawCfg.Rule)
	}
	if _, err := config.ParseRawConfig(rawCfg); err != nil {
		t.Fatal(err)
	}
}

func TestGetConfigDisabledGroups(t *testing.T) {
	path := filepath.Join(t.TempDir(), "p.yaml")
	if err := os.WriteFile(path, []byte(`proxies:
  - {name: A, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: x}
proxy-groups:
  - {name: Main, type: select, proxies: [Media, A]}
  - {name: Media, type: select, proxies: [HK]}
  - {name: HK, type: select, proxies: [A]}
rules:
  - MATCH,Main
`), 0o644); err != nil {
		t.Fatal(err)
	}
	params := &GetConfigParams{Path: path, DisabledGroups: []string{"HK"}}
	result, err := handleGetConfig(params)
	if err != nil {
		t.Fatal(err)
	}
	rawCfg := result.(*config.RawConfig)
	if len(rawCfg.ProxyGroup) != 1 || !reflect.DeepEqual(rawCfg.ProxyGroup[0]["proxies"], []any{"A"}) {
		t.Fatalf("groups: %v", rawCfg.ProxyGroup)
	}
	if !reflect.DeepEqual(rawCfg.Rule, []string{"MATCH,Main"}) {
		t.Fatalf("rules: %v", rawCfg.Rule)
	}
	params.Snippet = true
	snippet, err := handleGetConfig(params)
	if err != nil {
		t.Fatal(err)
	}
	decode := func(value any) map[string]any {
		data, err := json.Marshal(value)
		if err != nil {
			t.Fatal(err)
		}
		decoded := map[string]any{}
		if err := json.Unmarshal(data, &decoded); err != nil {
			t.Fatal(err)
		}
		return decoded
	}
	full := decode(rawCfg)
	want := map[string]any{
		"proxy-groups":   full["proxy-groups"],
		"rules":          full["rule"],
		"rule-providers": full["rule-providers"],
		"sub-rules":      full["sub-rules"],
	}
	if got := decode(snippet); !reflect.DeepEqual(got, want) {
		t.Fatalf("snippet = %v, want %v", got, want)
	}
}

func TestEnsureTunInet6(t *testing.T) {
	previousHome := constant.Path.HomeDir()
	constant.SetHomeDir(t.TempDir())
	defer constant.SetHomeDir(previousHome)
	previousAndroid, previousCheck := patchForAndroid, hasGlobalIPv6
	defer func() { patchForAndroid, hasGlobalIPv6 = previousAndroid, previousCheck }()

	cases := []struct {
		android bool
		global  bool
		want    int
	}{
		{false, true, 1},
		{false, false, 0},
		{true, true, 0},
	}
	for _, item := range cases {
		patchForAndroid = item.android
		hasGlobalIPv6 = func() bool { return item.global }
		cfg, err := config.ParseRawConfig(parsePatchProfile(t, "ipv6: false\n"))
		if err != nil {
			t.Fatal(err)
		}
		if len(cfg.General.Tun.Inet6Address) != 0 {
			t.Fatalf("ipv6: false should clear inet6-address")
		}
		ensureTunInet6(cfg)
		if got := len(cfg.General.Tun.Inet6Address); got != item.want {
			t.Errorf("android=%t global=%t: inet6-address count = %d, want %d", item.android, item.global, got, item.want)
		}
	}
}
