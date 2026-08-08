package main

import (
	"context"
	"errors"
	"fmt"
	"testing"

	"github.com/metacubex/mihomo/config"
)

func TestDelayFailureValue(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want int32
	}{
		{name: "timeout", err: context.DeadlineExceeded, want: delayFailureTimeout},
		{name: "dns", err: errors.New("lookup host: no such host"), want: delayFailureDNS},
		{name: "tls", err: errors.New("tls handshake failed"), want: delayFailureTLS},
		{name: "http", err: errors.New("unexpected HTTP status"), want: delayFailureHTTP},
		{name: "connect", err: errors.New("connect: connection refused"), want: delayFailureConnect},
		{name: "unknown", err: fmt.Errorf("unexpected result"), want: delayFailureUnknown},
		{name: "empty response", err: nil, want: delayFailureUnknown},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := delayFailureValue(tt.err); got != tt.want {
				t.Fatalf("delayFailureValue() = %d, want %d", got, tt.want)
			}
		})
	}
}

func TestApplyTestURLOverride(t *testing.T) {
	selectedURL := "https://test.example/generate_204"
	params := &SetupParams{
		TestURL:         selectedURL,
		OverrideTestUrl: true,
		Config: &config.RawConfig{
			ProxyGroup: []map[string]any{{"url": "https://group.example"}},
			ProxyProvider: map[string]map[string]any{
				"with-health-check": {
					"health-check": map[string]any{"url": "https://provider.example"},
				},
				"without-health-check": {"type": "http"},
			},
		},
	}

	applyTestURLOverride(params)

	if got := params.Config.ProxyGroup[0]["url"]; got != selectedURL {
		t.Fatalf("group URL = %v, want %s", got, selectedURL)
	}
	healthCheck := params.Config.ProxyProvider["with-health-check"]["health-check"].(map[string]any)
	if got := healthCheck["url"]; got != selectedURL {
		t.Fatalf("provider health-check URL = %v, want %s", got, selectedURL)
	}
	if _, ok := params.Config.ProxyProvider["without-health-check"]["health-check"]; ok {
		t.Fatal("override must not create a missing provider health-check")
	}
}
