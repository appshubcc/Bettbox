//go:build !no_easytier

package dns_test

import (
	"strings"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/dns"
)

func TestParseProxyUnregistersEasyTierDNSOnMuxError(t *testing.T) {
	for _, tc := range []struct {
		name    string
		smux    map[string]any
		wantErr string
	}{
		{"decode", map[string]any{"enabled": "invalid"}, "enabled"},
		{"construct", map[string]any{"enabled": true, "protocol": "invalid"}, "unknown protocol"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			name := t.Name()
			proxy, err := adapter.ParseProxy(map[string]any{
				"name":         name,
				"type":         "easytier",
				"network-name": "test",
				"peers":        []string{"tcp://192.0.2.1:11010"},
				"smux":         tc.smux,
			})
			if err == nil {
				_ = proxy.Close()
				t.Fatal("expected invalid smux options to fail")
			}
			if !strings.Contains(err.Error(), tc.wantErr) {
				t.Fatalf("expected mux error containing %q, got %v", tc.wantErr, err)
			}
			if dns.HasEasyTierDNSClientForTest(name) {
				t.Error("failed parse left an EasyTier DNS client registered")
			}
		})
	}
}
