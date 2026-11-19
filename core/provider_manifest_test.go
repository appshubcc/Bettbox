package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"testing"
)

const manifestNodes = `proxies:
  - {name: HK 01, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: p}
  - {name: JP 01, type: ss, server: b.com, port: 1, cipher: aes-128-gcm, password: p}
`

func readManifest(t *testing.T, dir string) []expandedProvider {
	t.Helper()
	data, err := os.ReadFile(expandedManifestPath(dir))
	if err != nil {
		t.Fatal(err)
	}
	var entries []expandedProvider
	if err := json.Unmarshal(data, &entries); err != nil {
		t.Fatal(err)
	}
	return entries
}

func manifestServer(t *testing.T, body *atomic.Value) *httptest.Server {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("subscription-userinfo", "upload=1; download=2; total=10; expire=99")
		_, _ = w.Write([]byte(body.Load().(string)))
	}))
	t.Cleanup(server.Close)
	return server
}

func TestExpandWritesManifest(t *testing.T) {
	var body atomic.Value
	body.Store(manifestNodes)
	server := manifestServer(t, &body)
	dir := t.TempDir()
	raw := parsePatchProfile(t, `
proxy-providers:
  sub:
    type: http
    url: `+server.URL+`
    interval: 3600
    filter: HK
  local:
    type: inline
    payload:
      - {name: Inline, type: ss, server: c.com, port: 1, cipher: aes-128-gcm, password: p}
`)
	if err := expandProxyProviders(raw, expandOptions{ProvidersPath: dir, Refresh: true}); err != nil {
		t.Fatal(err)
	}
	entries := readManifest(t, dir)
	if len(entries) != 2 || entries[0].Name != "local" || entries[1].Name != "sub" {
		t.Fatalf("entries = %+v", entries)
	}
	sub := entries[1]
	if !sub.Expanded || sub.Type != "Proxy" || sub.VehicleType != "HTTP" || sub.Count != 1 || sub.Interval != 3600 {
		t.Fatalf("sub = %+v", sub)
	}
	info := sub.SubscriptionInfo
	if info == nil || info.Upload != 1 || info.Download != 2 || info.Total != 10 || info.Expire != 99 {
		t.Fatalf("subscription info = %+v", info)
	}
	if entries[0].VehicleType != "Inline" || entries[0].Count != 1 {
		t.Fatalf("local = %+v", entries[0])
	}
	if err := expandProxyProviders(parsePatchProfile(t, "proxies: []"), expandOptions{ProvidersPath: dir}); err != nil {
		t.Fatal(err)
	}
	if entries := readManifest(t, dir); len(entries) != 0 {
		t.Fatalf("stale entries = %+v", entries)
	}
}

func TestUpdateExpandedProvider(t *testing.T) {
	var body atomic.Value
	body.Store(manifestNodes)
	server := manifestServer(t, &body)
	dir := t.TempDir()
	profile := filepath.Join(dir, "profile.yaml")
	if err := os.WriteFile(profile, []byte(`
proxy-providers:
  sub:
    type: http
    url: `+server.URL+`
`), 0o600); err != nil {
		t.Fatal(err)
	}
	providers := filepath.Join(dir, "providers")
	params := &UpdateExpandedProviderParams{Path: profile, ProvidersPath: providers, Name: "sub"}
	changed, err := handleUpdateExpandedProvider(params)
	if err != nil || !changed {
		t.Fatalf("first update: %v %v", changed, err)
	}
	if changed, err := handleUpdateExpandedProvider(params); err != nil || changed {
		t.Fatalf("unchanged update: %v %v", changed, err)
	}
	body.Store(manifestNodes + "  - {name: SG 01, type: ss, server: d.com, port: 1, cipher: aes-128-gcm, password: p}\n")
	if changed, err := handleUpdateExpandedProvider(params); err != nil || !changed {
		t.Fatalf("changed update: %v %v", changed, err)
	}
	entries := readManifest(t, providers)
	if len(entries) != 1 || entries[0].Count != 3 || entries[0].SubscriptionInfo == nil {
		t.Fatalf("entries = %+v", entries)
	}
	invalid := "not a provider"
	if _, err := handleUpdateExpandedProvider(&UpdateExpandedProviderParams{
		Path: profile, ProvidersPath: providers, Name: "sub", Content: &invalid,
	}); err == nil {
		t.Fatal("expected invalid content error")
	}
	if entries := readManifest(t, providers); entries[0].Count != 3 {
		t.Fatalf("invalid content changed manifest: %+v", entries)
	}
	sideLoad := manifestNodes
	if changed, err := handleUpdateExpandedProvider(&UpdateExpandedProviderParams{
		Path: profile, ProvidersPath: providers, Name: "sub", Content: &sideLoad,
	}); err != nil || !changed {
		t.Fatalf("side load: %v %v", changed, err)
	}
	entries = readManifest(t, providers)
	if entries[0].Count != 2 || entries[0].SubscriptionInfo == nil || entries[0].SubscriptionInfo.Total != 10 {
		t.Fatalf("side load entries = %+v", entries)
	}
	if _, err := handleUpdateExpandedProvider(&UpdateExpandedProviderParams{
		Path: profile, ProvidersPath: providers, Name: "missing",
	}); err == nil {
		t.Fatal("expected missing provider error")
	}
}
