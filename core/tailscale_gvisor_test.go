//go:build with_gvisor && !no_tailscale

package main

import (
	"os"
	"path/filepath"
	"reflect"
	"testing"

	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/constant"
)

func useTempHome(t *testing.T) string {
	t.Helper()
	previousHome := constant.Path.HomeDir()
	home := t.TempDir()
	constant.SetHomeDir(home)
	t.Cleanup(func() { constant.SetHomeDir(previousHome) })
	return home
}

func writeProfile(t *testing.T, content string) string {
	t.Helper()
	profile := filepath.Join(t.TempDir(), "profile.yaml")
	if err := os.WriteFile(profile, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	return profile
}

func tailscaleSetup(t *testing.T, profile, patch string) *SetupParams {
	t.Helper()
	setup := defaultSetupParams()
	setup.ProfilePath = profile
	setup.Patch = patchParams(t, patch)
	return setup
}

func closeTailscale(proxies map[string]constant.Proxy) {
	for _, p := range proxies {
		if p.Type() == constant.Tailscale {
			_ = p.Close()
		}
	}
}

func TestTailscaleSetupReusesValidation(t *testing.T) {
	useTempHome(t)
	profile := writeProfile(t, "proxy-groups:\n  - {name: Main, type: select, proxies: [DIRECT]}\nrules:\n  - MATCH,Main\n")
	validated, err := prepareSetup(tailscaleSetup(t, profile, tailscalePatch))
	if err != nil {
		t.Fatal(err)
	}
	if validated.tailscale != tailscaleProxyName || !reflect.DeepEqual(validated.tailscaleDnsDomains, []string{"home.arpa"}) {
		t.Errorf("tailscale = %q %v", validated.tailscale, validated.tailscaleDnsDomains)
	}
	if validated.tailscaleDns == nil {
		t.Errorf("the parse should stage the node's tailscale:// client")
	}
	storePreparedSetup(validated)
	applied, err := prepareSetup(tailscaleSetup(t, profile, tailscalePatch))
	if err != nil {
		t.Fatal(err)
	}
	defer closeTailscale(applied.cfg.Proxies)
	if applied != validated || !applied.reused {
		t.Errorf("setup should reuse the validated config")
	}
	if p := applied.cfg.Proxies[tailscaleProxyName]; p == nil || p.Type() != constant.Tailscale {
		t.Fatalf("setup should hold the tailscale proxy: %v", p)
	}
}

func TestTailscaleSetupKeepsGroupOrder(t *testing.T) {
	useTempHome(t)
	profile := writeProfile(t, `
proxy-groups:
  - {name: Z, type: select, proxies: [Y, X]}
  - {name: Y, type: select, proxies: [DIRECT]}
  - {name: X, type: select, proxies: [DIRECT]}
  - {name: A, type: select, proxies: [DIRECT]}
  - {name: B, type: select, proxies: [DIRECT]}
rules:
  - MATCH,Z
`)
	order := func(patch string, reuse bool) []string {
		if reuse {
			validated, err := prepareSetup(tailscaleSetup(t, profile, patch))
			if err != nil {
				t.Fatal(err)
			}
			storePreparedSetup(validated)
		}
		prepared, err := prepareSetup(tailscaleSetup(t, profile, patch))
		if err != nil {
			t.Fatal(err)
		}
		defer closeTailscale(prepared.cfg.Proxies)
		var names []string
		for _, p := range prepared.cfg.Proxies["GLOBAL"].Adapter().(outboundgroup.ProxyGroup).Proxies() {
			if _, isGroup := p.Adapter().(outboundgroup.ProxyGroup); isGroup {
				names = append(names, p.Name())
			}
		}
		return names
	}
	want := order(`{}`, false)
	for i := 0; i < 4; i++ {
		if got := order(tailscalePatch, i%2 == 1); !reflect.DeepEqual(got, want) {
			t.Fatalf("GLOBAL order with tailscale = %v, want %v", got, want)
		}
	}
}

func TestTailscaleValidationRejectsBrokenNode(t *testing.T) {
	useTempHome(t)
	profile := writeProfile(t, "rules:\n  - MATCH,DIRECT\n")
	for _, proxy := range []string{
		`{"type":"tailscale","state-dir":"bettbox-tailscale/home","dialer-proxy":"Missing"}`,
		`{"type":"tailscale","state-dir":"../outside"}`,
	} {
		if _, err := prepareSetup(tailscaleSetup(t, profile, `{"tailscale":{"proxy":`+proxy+`}}`)); err == nil {
			t.Errorf("validation should reject %s", proxy)
		}
	}
}
