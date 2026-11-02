package main

import (
	"encoding/base64"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"reflect"
	"sync/atomic"
	"testing"
	"time"
)

func expandProfile(t *testing.T, content string, options expandOptions) []string {
	t.Helper()
	rawCfg := parsePatchProfile(t, content)
	if err := expandProxyProviders(rawCfg, options); err != nil {
		t.Fatal(err)
	}
	if rawCfg.ProxyProvider != nil {
		t.Fatal("proxy-providers should be removed")
	}
	var names []string
	for _, proxy := range rawCfg.Proxy {
		names = append(names, proxy["name"].(string))
	}
	return names
}

func TestExpandInlineProviderAppliesFilters(t *testing.T) {
	names := expandProfile(t, `
proxies:
  - {name: HK 01, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: p}
proxy-providers:
  inline:
    type: inline
    filter: HK|JP
    exclude-filter: 过期
    exclude-type: vmess
    override:
      additional-prefix: "[P] "
      proxy-name:
        - pattern: "HK"
          target: "香港"
    payload:
      - {name: HK 01, type: ss, server: b.com, port: 2, cipher: aes-128-gcm, password: p}
      - {name: JP 01, type: vmess, server: c.com, port: 3, uuid: 8e8a7c5f-3b6c-4c8f-9a51-8f0b5f4c2c11, cipher: auto}
      - {name: JP 02, type: ss, server: d.com, port: 4, cipher: aes-128-gcm, password: p}
      - {name: HK 过期, type: ss, server: e.com, port: 5, cipher: aes-128-gcm, password: p}
`, expandOptions{})
	want := []string{"HK 01", "[P] 香港 01", "[P] JP 02"}
	if !reflect.DeepEqual(names, want) {
		t.Fatalf("names = %v, want %v", names, want)
	}
}

func TestExpandRenamesDuplicateNames(t *testing.T) {
	names := expandProfile(t, `
proxies:
  - {name: HK, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: p}
proxy-groups:
  - {name: JP, type: select, proxies: [HK]}
proxy-providers:
  one:
    type: inline
    payload:
      - {name: HK, type: ss, server: b.com, port: 2, cipher: aes-128-gcm, password: p}
      - {name: JP, type: ss, server: c.com, port: 3, cipher: aes-128-gcm, password: p}
`, expandOptions{})
	if want := []string{"HK", "HK 2", "JP 2"}; !reflect.DeepEqual(names, want) {
		t.Fatalf("names = %v, want %v", names, want)
	}
}

func TestExpandHttpProviderReadsCache(t *testing.T) {
	dir := t.TempDir()
	url := "http://127.0.0.1:1/sub"
	cache := providerFilePath(dir, "proxies", url)
	if err := os.MkdirAll(filepath.Dir(cache), 0o755); err != nil {
		t.Fatal(err)
	}
	links := "ss://" + base64.RawURLEncoding.EncodeToString([]byte("aes-128-gcm:pass")) + "@1.2.3.4:8388#Cached"
	if err := os.WriteFile(cache, []byte(base64.StdEncoding.EncodeToString([]byte(links))), 0o600); err != nil {
		t.Fatal(err)
	}
	content := `
proxy-providers:
  sub:
    type: http
    url: ` + url + `
    dialer-proxy: relay
`
	rawCfg := parsePatchProfile(t, content)
	if err := expandProxyProviders(rawCfg, expandOptions{ProvidersPath: dir}); err != nil {
		t.Fatal(err)
	}
	if len(rawCfg.Proxy) != 1 || rawCfg.Proxy[0]["name"] != "Cached" || rawCfg.Proxy[0]["dialer-proxy"] != "relay" {
		t.Fatalf("proxies = %v", rawCfg.Proxy)
	}
	if err := expandProxyProviders(parsePatchProfile(t, content), expandOptions{ProvidersPath: dir, Refresh: true}); err != nil {
		t.Fatalf("refresh should fall back to the cache: %v", err)
	}
}

func TestExpandHttpProviderFallsBackToPayload(t *testing.T) {
	names := expandProfile(t, `
proxy-providers:
  sub:
    type: http
    url: http://127.0.0.1:1/missing
    payload:
      - {name: Seed, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: p}
`, expandOptions{ProvidersPath: t.TempDir()})
	if !reflect.DeepEqual(names, []string{"Seed"}) {
		t.Fatalf("names = %v", names)
	}
}

func TestExpandHttpProviderReportsMissingContent(t *testing.T) {
	rawCfg := parsePatchProfile(t, `
proxy-providers:
  sub:
    type: http
    url: http://127.0.0.1:1/missing
`)
	if err := expandProxyProviders(rawCfg, expandOptions{ProvidersPath: t.TempDir()}); err == nil {
		t.Fatal("expected an error")
	}
}

func TestExpandHttpProviderHonorsInterval(t *testing.T) {
	var hits atomic.Int32
	links := "ss://" + base64.RawURLEncoding.EncodeToString([]byte("aes-128-gcm:pass")) + "@1.2.3.4:8388#Fresh"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		hits.Add(1)
		_, _ = w.Write([]byte(links))
	}))
	defer server.Close()
	dir := t.TempDir()
	content := `
proxy-providers:
  sub:
    type: http
    url: ` + server.URL + `
    interval: 3600
`
	expand := func() {
		t.Helper()
		if names := expandProfile(t, content, expandOptions{ProvidersPath: dir}); !reflect.DeepEqual(names, []string{"Fresh"}) {
			t.Fatalf("names = %v", names)
		}
	}
	expand()
	cache := providerFilePath(dir, "proxies", server.URL)
	if _, err := os.Stat(cache); err != nil {
		t.Fatalf("download should be cached: %v", err)
	}
	expand()
	if got := hits.Load(); got != 1 {
		t.Fatalf("fresh cache should skip download, hits = %d", got)
	}
	stale := time.Now().Add(-2 * time.Hour)
	if err := os.Chtimes(cache, stale, stale); err != nil {
		t.Fatal(err)
	}
	expand()
	if got := hits.Load(); got != 2 {
		t.Fatalf("stale cache should download again, hits = %d", got)
	}
}
