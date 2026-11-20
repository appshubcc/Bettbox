package main

import (
	"os"
	"path/filepath"
	"reflect"
	"testing"

	yamlv3 "go.yaml.in/yaml/v3"
)

const tailscalePatch = `{
	"prepend-rules": ["DST-PORT,853,REJECT"],
	"disabled-groups": ["Tailscale-2"],
	"tailscale": {
		"proxy": {"type": "tailscale", "hostname": "bettbox", "state-dir": "bettbox-tailscale/home"},
		"rules": [
			"IP-CIDR,100.64.0.0/10,Tailscale,no-resolve",
			"AND,((DOMAIN-SUFFIX,corp.example.com),(NOT,((DOMAIN,hs.corp.example.com)))),Tailscale"
		],
		"nameserver-policy": {
			"+.corp.example.com": "tailscale://Tailscale",
			"+.home.arpa": ["10.1.0.53#Tailscale"]
		},
		"skip-dst-address": ["100.64.0.0/10"],
		"control-host": "hs.corp.example.com",
		"dns-domains": ["home.arpa"]
	}
}`

func TestPatchTailscale(t *testing.T) {
	rawCfg := parsePatchProfile(t, `
proxies:
  - {name: Tailscale, type: ss, server: a.example.com, port: 1, cipher: aes-128-gcm, password: p}
proxy-providers:
  renamed:
    type: inline
    override: {proxy-name: [{pattern: "^ts-office$", target: Tailscale-3}]}
    payload:
      - {name: ts-office, type: ss, server: b.example.com, port: 1, cipher: aes-128-gcm, password: p}
  prefixed:
    type: inline
    override: {additional-prefix: "Home-"}
    payload:
      - {name: Tailscale-4, type: ss, server: c.example.com, port: 1, cipher: aes-128-gcm, password: p}
  remote: {type: http, url: "https://sub.example.com", exclude-filter: Expired}
proxy-groups:
  - {name: All, type: select, include-all: true}
  - {name: HK, type: select, include-all-proxies: true, filter: HK, exclude-filter: Expired}
  - {name: Main, type: select, proxies: [Tailscale]}
dns:
  enable: true
  nameserver: [1.1.1.1]
  nameserver-policy:
    +.corp.example.com: 8.8.8.8
    +.other.example.com: 9.9.9.9
sniffer:
  skip-dst-address: [10.0.0.0/8]
rules:
  - MATCH,Main
`)
	if _, err := applyPatch(rawCfg, patchParams(t, tailscalePatch)); err != nil {
		t.Fatal(err)
	}

	// "Tailscale" is a profile proxy, "Tailscale-2" a disabled group,
	// "Tailscale-3" a provider proxy after its rename and "Tailscale-4" one
	// before its prefix.
	const name = "Tailscale-5"
	proxy := rawCfg.Proxy[len(rawCfg.Proxy)-1]
	if proxy["name"] != name || proxy["type"] != "tailscale" || proxy["state-dir"] != "bettbox-tailscale/home" {
		t.Errorf("proxy = %v", proxy)
	}
	wantRules := []string{
		"DST-PORT,853,REJECT",
		"IP-CIDR,100.64.0.0/10," + name + ",no-resolve",
		"AND,((DOMAIN-SUFFIX,corp.example.com),(NOT,((DOMAIN,hs.corp.example.com))))," + name,
		"MATCH,Main",
	}
	if !reflect.DeepEqual(rawCfg.Rule, wantRules) {
		t.Errorf("rules = %v, want %v", rawCfg.Rule, wantRules)
	}
	if got := rawCfg.ProxyGroup[0]["filter"]; got != "^(?!"+name+"$)" {
		t.Errorf("include-all filter = %v", got)
	}
	if got := rawCfg.ProxyGroup[1]["exclude-filter"]; got != "Expired`^"+name+"$" {
		t.Errorf("include-all exclude-filter = %v", got)
	}
	if _, exist := rawCfg.ProxyGroup[2]["filter"]; exist {
		t.Errorf("groups without include-all should be kept")
	}
	if got := rawCfg.ProxyProvider["remote"]["exclude-filter"]; got != "Expired" {
		t.Errorf("provider exclude-filter = %v", got)
	}
	if want := []string{"10.0.0.0/8", "100.64.0.0/10"}; !reflect.DeepEqual(rawCfg.Sniffer.SkipDstAddress, want) {
		t.Errorf("skip-dst-address = %v", rawCfg.Sniffer.SkipDstAddress)
	}

	var keys []string
	for pair := rawCfg.DNS.NameServerPolicy.Oldest(); pair != nil; pair = pair.Next() {
		keys = append(keys, pair.Key)
	}
	wantKeys := []string{"+.corp.example.com", "+.home.arpa", "hs.corp.example.com", "+.other.example.com"}
	if !reflect.DeepEqual(keys, wantKeys) {
		t.Errorf("policy keys = %v, want %v", keys, wantKeys)
	}
	policy := rawCfg.DNS.NameServerPolicy
	if got := policy.Value("+.corp.example.com"); got != "tailscale://"+name {
		t.Errorf("routed domain policy = %v", got)
	}
	if got := policy.Value("+.home.arpa"); !reflect.DeepEqual(got, []any{"10.1.0.53#" + name}) {
		t.Errorf("tailnet dns policy = %v", got)
	}
	if got := policy.Value("hs.corp.example.com"); !reflect.DeepEqual(got, []string{"1.1.1.1"}) {
		t.Errorf("control host policy = %v", got)
	}
}

func TestRuntimeConfigKeepsTailscalePolicyOrder(t *testing.T) {
	profile := filepath.Join(t.TempDir(), "profile.yaml")
	content := "dns:\n  enable: true\n  nameserver: [1.1.1.1]\n  nameserver-policy:\n    rule-set:corp: 8.8.8.8\n    +.other.example.com: 9.9.9.9\nrules:\n  - MATCH,DIRECT\n"
	if err := os.WriteFile(profile, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	setup := defaultSetupParams()
	setup.ProfilePath = profile
	setup.Patch = patchParams(t, tailscalePatch)
	out, err := handleGetRuntimeConfig(setup)
	if err != nil {
		t.Fatal(err)
	}
	var runtime struct {
		DNS struct {
			Policy yamlv3.Node `yaml:"nameserver-policy"`
		} `yaml:"dns"`
	}
	if err := yamlv3.Unmarshal([]byte(out), &runtime); err != nil {
		t.Fatal(err)
	}
	var keys []string
	for i := 0; i+1 < len(runtime.DNS.Policy.Content); i += 2 {
		keys = append(keys, runtime.DNS.Policy.Content[i].Value)
	}
	want := []string{"+.corp.example.com", "+.home.arpa", "hs.corp.example.com", "rule-set:corp", "+.other.example.com"}
	if !reflect.DeepEqual(keys, want) {
		t.Errorf("runtime config policy keys = %v, want %v", keys, want)
	}
}

func TestPatchWithoutTailscale(t *testing.T) {
	rawCfg := parsePatchProfile(t, "proxy-groups:\n  - {name: All, type: select, include-all: true}\nrules:\n  - MATCH,All\n")
	if _, err := applyPatch(rawCfg, patchParams(t, `{"tailscale":null}`)); err != nil {
		t.Fatal(err)
	}
	if len(rawCfg.Proxy) != 0 || rawCfg.ProxyGroup[0]["filter"] != nil || !reflect.DeepEqual(rawCfg.Rule, []string{"MATCH,All"}) {
		t.Errorf("config changed without a tailscale patch: %v %v %v", rawCfg.Proxy, rawCfg.ProxyGroup, rawCfg.Rule)
	}
}
