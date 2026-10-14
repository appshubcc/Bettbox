package main

import (
	"os"
	"path/filepath"
	"reflect"
	"testing"

	"github.com/metacubex/mihomo/constant"
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

	// "Tailscale" is a profile proxy and "Tailscale-2" a disabled group.
	const name = "Tailscale-3"
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

func TestPatchWithoutTailscale(t *testing.T) {
	rawCfg := parsePatchProfile(t, "proxy-groups:\n  - {name: All, type: select, include-all: true}\nrules:\n  - MATCH,All\n")
	if _, err := applyPatch(rawCfg, patchParams(t, `{"tailscale":null}`)); err != nil {
		t.Fatal(err)
	}
	if len(rawCfg.Proxy) != 0 || rawCfg.ProxyGroup[0]["filter"] != nil || !reflect.DeepEqual(rawCfg.Rule, []string{"MATCH,All"}) {
		t.Errorf("config changed without a tailscale patch: %v %v %v", rawCfg.Proxy, rawCfg.ProxyGroup, rawCfg.Rule)
	}
}

func TestValidateTailscaleSetup(t *testing.T) {
	previousHome := constant.Path.HomeDir()
	constant.SetHomeDir(t.TempDir())
	defer constant.SetHomeDir(previousHome)
	profile := filepath.Join(t.TempDir(), "profile.yaml")
	content := "proxy-groups:\n  - {name: Main, type: select, proxies: [DIRECT]}\nrules:\n  - MATCH,Main\n"
	if err := os.WriteFile(profile, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	setup := defaultSetupParams()
	setup.ProfilePath = profile
	setup.Patch = patchParams(t, tailscalePatch)
	setup.validating = true

	prepared, err := prepareSetup(setup)
	if err != nil {
		t.Fatal(err)
	}
	if prepared.key != "" {
		t.Errorf("a config validated with a placeholder must not be reused")
	}
	if prepared.tailscale != tailscaleProxyName || !reflect.DeepEqual(prepared.tailscaleDnsDomains, []string{"home.arpa"}) {
		t.Errorf("tailscale = %q %v", prepared.tailscale, prepared.tailscaleDnsDomains)
	}
	if p := prepared.cfg.Proxies[tailscaleProxyName]; p == nil || p.Type() != constant.Direct {
		t.Errorf("validated tailscale proxy should be a placeholder: %v", p)
	}

	setup.Patch = patchParams(t, `{"tailscale":{"proxy":{"type":"tailscale","state-dir":"../outside"}}}`)
	if _, err := prepareSetup(setup); err == nil {
		t.Errorf("a state dir outside the home dir should fail validation")
	}
}
