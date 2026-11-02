package main

import (
	"encoding/json"
	"reflect"
	"strings"
	"testing"

	"github.com/metacubex/mihomo/common/yaml"
	"github.com/metacubex/mihomo/log"
	yamlv3 "go.yaml.in/yaml/v3"
)

func TestPatchYamlShortID(t *testing.T) {
	cases := map[string]string{
		"    short-id: 0123abcd\n":                    "    short-id: \"0123abcd\"\n",
		"    short-id: 1e5\n":                         "    short-id: \"1e5\"\n",
		"    short-id: 12345678 # note\n":             "    short-id: \"12345678\" # note\n",
		"    short-id:   ABCDEF\n":                    "    short-id:   \"ABCDEF\"\n",
		"reality-opts: {public-key: k, short-id: 01}": "reality-opts: {public-key: k, short-id: \"01\"}",
		"{short-id: 01, public-key: k}":               "{short-id: \"01\", public-key: k}",
		"    short-id: \"0123abcd\"\n":                "    short-id: \"0123abcd\"\n",
		"    short-id: '0123abcd'\n":                  "    short-id: '0123abcd'\n",
		"    short-id: xyz\n":                         "    short-id: xyz\n",
		"    short-id: 0123abcdxyz\n":                 "    short-id: 0123abcdxyz\n",
		"    short-id:\n":                             "    short-id:\n",
		"    short-id: 0123abcd":                      "    short-id: \"0123abcd\"",
	}
	for input, want := range cases {
		if got := string(patchYamlShortID([]byte(input))); got != want {
			t.Errorf("patchYamlShortID(%q) = %q, want %q", input, got, want)
		}
	}
}

func TestLogHistoryCarriesTime(t *testing.T) {
	handleClearLogs()
	t.Cleanup(func() { handleClearLogs() })
	recordLogHistory(logEntry{
		Event: log.Event{LogLevel: log.WARNING, Payload: "[DNS] timeout"},
		Time:  1760000000123,
	})
	var items []map[string]any
	if err := json.Unmarshal([]byte(handleGetLogs()), &items); err != nil {
		t.Fatal(err)
	}
	if len(items) != 1 {
		t.Fatalf("len = %d, want 1", len(items))
	}
	want := map[string]any{
		"LogLevel": "warning",
		"Payload":  "[DNS] timeout",
		"time":     float64(1760000000123),
	}
	if !reflect.DeepEqual(items[0], want) {
		t.Errorf("entry = %v, want %v", items[0], want)
	}
}

func TestMarshalYamlNodeKeepingSupplementary(t *testing.T) {
	type entry struct {
		Name  string `yaml:"name"`
		Value string `yaml:"value"`
	}
	entries := []entry{
		{"🇭🇰 香港 01 ⭐", "0123"},
		{"🚀 节点选择", "true"},
		{`literal \U0001F680 text`, "line one\nline two 🚀\n"},
		{"☁️ plain \ue000", "quoted \"🚀\" \\U0001F680"},
	}
	var root yamlv3.Node
	if err := root.Encode(map[string]any{"entries": entries}); err != nil {
		t.Fatal(err)
	}
	out, err := marshalYamlNode(&root)
	if err != nil {
		t.Fatal(err)
	}
	content := string(out)
	for _, shown := range []string{"🇭🇰 香港 01 ⭐", "🚀 节点选择", "line two 🚀"} {
		if !strings.Contains(content, shown) {
			t.Fatalf("%q is escaped in: %s", shown, content)
		}
	}
	var parsed map[string][]entry
	if err := yaml.Unmarshal(out, &parsed); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(parsed["entries"], entries) {
		t.Fatalf("entries changed: %#v", parsed["entries"])
	}
}

func TestResidentRawConfigDropsProxiesAndGroups(t *testing.T) {
	raw, err := parseProfile([]byte(`proxies:
  - {name: a, type: ss, server: 1.1.1.1, port: 1, cipher: aes-128-gcm, password: p}
proxy-groups:
  - {name: g, type: select, proxies: [a]}
proxy-providers:
  inline: {type: inline, payload: [{name: b, type: ss, server: 1.1.1.1, port: 2, cipher: aes-128-gcm, password: p}]}
rule-providers:
  ads: {type: http, behavior: domain, url: https://example.com/ads.mrs, format: mrs}
dns:
  enable: true
  enhanced-mode: fake-ip
rules:
  - GEOSITE,google,g
  - MATCH,g
`), "")
	if err != nil {
		t.Fatal(err)
	}
	resident := residentRawConfig(raw)
	if resident.Proxy != nil || resident.ProxyGroup != nil {
		t.Fatalf("proxies or groups kept: %d %d", len(resident.Proxy), len(resident.ProxyGroup))
	}
	if len(raw.Proxy) != 1 || len(raw.ProxyGroup) != 1 {
		t.Fatalf("source changed: %d %d", len(raw.Proxy), len(raw.ProxyGroup))
	}
	if !resident.DNS.Enable || len(resident.Rule) != 2 || len(resident.RuleProvider) != 1 {
		t.Fatalf("resident lost fields: %+v", resident.DNS.Enable)
	}
	if _, err := marshalInlineProviderContent(resident, "inline"); err != nil {
		t.Fatal(err)
	}
	if residentRawConfig(nil) != nil {
		t.Fatal("nil config should stay nil")
	}
}
