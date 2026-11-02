package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
	"time"

	"github.com/metacubex/mihomo/config"
)

func mergeProxy(name string, server string) map[string]any {
	return map[string]any{"name": name, "type": "ss", "server": server, "port": 443, "cipher": "aes-128-gcm", "password": "pw"}
}

func mergeGroup(name string, proxies ...string) map[string]any {
	list := make([]any, 0, len(proxies))
	for _, proxy := range proxies {
		list = append(list, proxy)
	}
	return map[string]any{"name": name, "type": "select", "proxies": list}
}

func mergeConfig(proxies []map[string]any, groups ...map[string]any) map[string]any {
	proxyList := make([]any, 0, len(proxies))
	for _, proxy := range proxies {
		proxyList = append(proxyList, proxy)
	}
	groupList := make([]any, 0, len(groups))
	for _, group := range groups {
		groupList = append(groupList, group)
	}
	return map[string]any{"proxies": proxyList, "proxy-groups": groupList, "rules": []any{"MATCH,默认代理"}}
}

func mergedNames(merged map[string]any) []string {
	var names []string
	for _, proxy := range mapItems(merged["proxies"]) {
		names = append(names, stringValue(proxy["name"]))
	}
	return names
}

func mergedGroups(merged map[string]any) map[string][]string {
	result := map[string][]string{}
	for _, group := range mapItems(merged["proxy-groups"]) {
		var refs []string
		for _, item := range listValue(group["proxies"]) {
			refs = append(refs, item.(string))
		}
		result[stringValue(group["name"])] = refs
	}
	return result
}

func mergedGroupOrder(merged map[string]any) []string {
	var names []string
	for _, group := range mapItems(merged["proxy-groups"]) {
		names = append(names, stringValue(group["name"]))
	}
	return names
}

func TestMergeDeduplicatesByContent(t *testing.T) {
	shared := mergeProxy("共用", "shared.example.com")
	merged, report := mergeProfileConfigs([]mergeInput{
		{config: mergeConfig([]map[string]any{shared, mergeProxy("HK 01", "hk.a.com")}, mergeGroup("默认代理", "共用", "HK 01")), prefix: "A"},
		{config: mergeConfig([]map[string]any{mergeProxy("同款", "shared.example.com"), mergeProxy("JP 01", "jp.b.com")}, mergeGroup("默认代理", "同款", "JP 01")), prefix: "B"},
	})
	if got, want := mergedNames(merged), []string{"[ A ] - 共用", "[ A ] - HK 01", "[ B ] - JP 01"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("names = %v, want %v", got, want)
	}
	if got, want := mergedGroups(merged)["默认代理"], []string{"[ A ] - 共用", "[ A ] - HK 01", "[ B ] - JP 01"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("group = %v, want %v", got, want)
	}
	if report.Proxies != 3 || report.Duplicates != 1 || report.Groups != 1 {
		t.Fatalf("report = %+v", report)
	}
}

func TestMergePrefixCollisionsAndSanitize(t *testing.T) {
	merged, _ := mergeProfileConfigs([]mergeInput{
		{config: mergeConfig([]map[string]any{mergeProxy("HK, 01", "a.com")}), prefix: "云"},
		{config: mergeConfig([]map[string]any{mergeProxy("HK, 01", "b.com")}), prefix: "云"},
		{config: mergeConfig([]map[string]any{mergeProxy("DIRECT", "c.com")}), prefix: ""},
		{config: mergeConfig([]map[string]any{mergeProxy("line\none", "d.com")}), prefix: ""},
	})
	want := []string{"[ 云 ] - HK， 01", "[ 云 ] - HK， 01-2", "DIRECT-2", "line one"}
	if got := mergedNames(merged); !reflect.DeepEqual(got, want) {
		t.Fatalf("names = %v, want %v", got, want)
	}
}

func TestMergeAvoidsGroupNames(t *testing.T) {
	merged, _ := mergeProfileConfigs([]mergeInput{
		{config: mergeConfig([]map[string]any{mergeProxy("香港", "a.com")}, mergeGroup("香港", "香港")), prefix: ""},
	})
	if got := mergedNames(merged); !reflect.DeepEqual(got, []string{"香港-2"}) {
		t.Fatalf("names = %v", got)
	}
	if got := mergedGroups(merged)["香港"]; !reflect.DeepEqual(got, []string{"香港-2"}) {
		t.Fatalf("group = %v", got)
	}
}

func TestMergeRewritesDialerProxy(t *testing.T) {
	relay := mergeProxy("中转", "relay.com")
	landing := mergeProxy("落地", "land.com")
	landing["dialer-proxy"] = "中转"
	chained := mergeProxy("链式", "chain.com")
	chained["dialer-proxy"] = "链式中转"
	merged, _ := mergeProfileConfigs([]mergeInput{
		{config: mergeConfig([]map[string]any{relay, landing, chained}, mergeGroup("链式中转", "中转")), prefix: "A"},
	})
	proxies := mapItems(merged["proxies"])
	if got := proxies[1]["dialer-proxy"]; got != "[ A ] - 中转" {
		t.Fatalf("dialer-proxy = %v", got)
	}
	if got := proxies[2]["dialer-proxy"]; got != "链式中转" {
		t.Fatalf("group dialer-proxy = %v", got)
	}
}

func TestMergeKeepsGeneratedProxies(t *testing.T) {
	direct := map[string]any{"name": "🇨🇳 直连 | 双栈", "type": "direct"}
	merged, report := mergeProfileConfigs([]mergeInput{
		{config: mergeConfig([]map[string]any{mergeProxy("HK", "a.com"), direct}, mergeGroup("直连", "🇨🇳 直连 | 双栈")), prefix: "A"},
		{config: mergeConfig([]map[string]any{mergeProxy("JP", "b.com"), copyMap(direct)}, mergeGroup("直连", "🇨🇳 直连 | 双栈")), prefix: "B"},
	})
	if got, want := mergedNames(merged), []string{"[ A ] - HK", "🇨🇳 直连 | 双栈", "[ B ] - JP"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("names = %v, want %v", got, want)
	}
	if got := mergedGroups(merged)["直连"]; !reflect.DeepEqual(got, []string{"🇨🇳 直连 | 双栈"}) {
		t.Fatalf("group = %v", got)
	}
	if report.Proxies != 2 || report.Duplicates != 0 {
		t.Fatalf("report = %+v", report)
	}
}

func TestMergeRestoresGroupOrder(t *testing.T) {
	merged, _ := mergeProfileConfigs([]mergeInput{
		{config: mergeConfig([]map[string]any{mergeProxy("HK 01", "hk.com")},
			mergeGroup("默认代理", "手动选择"),
			mergeGroup("手动选择", "HK 01"),
			mergeGroup("漏网之鱼", "默认代理"),
			mergeGroup("直连", "DIRECT"),
			mergeGroup("香港", "HK 01"),
			mergeGroup("日本", "HK 01"),
			mergeGroup("美国", "HK 01"),
		), prefix: "A"},
		{config: mergeConfig([]map[string]any{mergeProxy("JP 01", "jp.com")},
			mergeGroup("默认代理", "手动选择"),
			mergeGroup("手动选择", "JP 01"),
			mergeGroup("低倍率", "JP 01"),
			mergeGroup("高倍率", "JP 01"),
			mergeGroup("漏网之鱼", "默认代理"),
			mergeGroup("直连", "DIRECT"),
		), prefix: "B"},
	})
	want := []string{"默认代理", "手动选择", "低倍率", "高倍率", "漏网之鱼", "直连", "香港", "日本", "美国"}
	if got := mergedGroupOrder(merged); !reflect.DeepEqual(got, want) {
		t.Fatalf("order = %v, want %v", got, want)
	}
	if got := mergedGroups(merged)["手动选择"]; !reflect.DeepEqual(got, []string{"[ A ] - HK 01", "[ B ] - JP 01"}) {
		t.Fatalf("group = %v", got)
	}
}

func TestMergeKeepsFirstGlobalsAndUnionsProviders(t *testing.T) {
	first := mergeConfig([]map[string]any{mergeProxy("HK", "a.com")})
	first["mode"] = "rule"
	first["rule-providers"] = map[string]any{"cn": map[string]any{"type": "http"}}
	second := mergeConfig([]map[string]any{mergeProxy("JP", "b.com")})
	second["mode"] = "global"
	second["rules"] = []any{"MATCH,DIRECT"}
	second["rule-providers"] = map[string]any{"cn": map[string]any{"type": "file"}, "ai": map[string]any{"type": "http"}}
	merged, _ := mergeProfileConfigs([]mergeInput{{config: first, prefix: "A"}, {config: second, prefix: "B"}})
	if merged["mode"] != "rule" || !reflect.DeepEqual(merged["rules"], []any{"MATCH,默认代理"}) {
		t.Fatalf("globals = %v %v", merged["mode"], merged["rules"])
	}
	providers := mapValue(merged["rule-providers"])
	if len(providers) != 2 || mapValue(providers["cn"])["type"] != "http" {
		t.Fatalf("providers = %v", providers)
	}
}

func TestMergeNameserverPolicy(t *testing.T) {
	first := mergeConfig([]map[string]any{mergeProxy("A1", "n1.a.com"), mergeProxy("A2", "n2.a.com"), mergeProxy("S1", "x.shared.net")})
	first["dns"] = map[string]any{
		"enable":                         true,
		"proxy-server-nameserver-policy": map[string]any{"+.a.com": []any{"1.1.1.1"}, "+.shared.net": []any{"9.9.9.9"}, "geosite:cn": "system"},
		"fake-ip-filter":                 []any{"rule-set:private", "+.a.com"},
	}
	second := mergeConfig([]map[string]any{mergeProxy("B1", "n3.a.com"), mergeProxy("S2", "y.shared.net")})
	second["dns"] = map[string]any{
		"enable":                         false,
		"proxy-server-nameserver-policy": map[string]any{"+.a.com": []any{"1.1.1.1"}, "+.shared.net": []any{"8.8.8.8"}},
		"fake-ip-filter":                 []any{"rule-set:private", "+.shared.net"},
	}
	merged, _ := mergeProfileConfigs([]mergeInput{{config: first, prefix: "A"}, {config: second, prefix: "B"}})
	dns := mapValue(merged["dns"])
	if dns["enable"] != true {
		t.Fatalf("dns template should come from the first member: %v", dns)
	}
	want := map[string]any{
		"+.a.com":      []any{"1.1.1.1"},
		"x.shared.net": []any{"9.9.9.9"},
		"y.shared.net": []any{"8.8.8.8"},
		"geosite:cn":   "system",
	}
	if got := dns["proxy-server-nameserver-policy"]; !reflect.DeepEqual(got, want) {
		t.Fatalf("policy = %v, want %v", got, want)
	}
	if got := dns["fake-ip-filter"]; !reflect.DeepEqual(got, []any{"rule-set:private", "+.a.com", "+.shared.net"}) {
		t.Fatalf("fake-ip-filter = %v", got)
	}
}

func TestExpandNameserverPolicyPrefersSpecificPatterns(t *testing.T) {
	policy := map[string]any{
		"+.a.com":       "wide",
		"*.a.com":       "wildcard",
		"exact.a.com":   "exact",
		"x.b.com,c.com": "listed",
	}
	got := expandNameserverPolicy(policy, []string{"exact.a.com", "n.a.com", "deep.n.a.com", "x.b.com", "c.com"})
	want := map[string]any{
		"exact.a.com":  "exact",
		"n.a.com":      "wildcard",
		"deep.n.a.com": "wide",
		"x.b.com":      "listed",
		"c.com":        "listed",
	}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("expanded = %v, want %v", got, want)
	}
}

func TestMergeHostsKeepFirst(t *testing.T) {
	first := mergeConfig(nil)
	first["hosts"] = map[string]any{"a.com": "1.1.1.1"}
	second := mergeConfig(nil)
	second["hosts"] = map[string]any{"a.com": "2.2.2.2", "b.com": "3.3.3.3"}
	merged, _ := mergeProfileConfigs([]mergeInput{{config: first}, {config: second}})
	if got := mapValue(merged["hosts"]); !reflect.DeepEqual(got, map[string]any{"a.com": "1.1.1.1", "b.com": "3.3.3.3"}) {
		t.Fatalf("hosts = %v", got)
	}
}

func TestHandleMergeProfilesWritesValidProfile(t *testing.T) {
	dir := t.TempDir()
	write := func(name string, value map[string]any) string {
		data, err := json.Marshal(value)
		if err != nil {
			t.Fatal(err)
		}
		path := filepath.Join(dir, name)
		if err := os.WriteFile(path, data, 0o600); err != nil {
			t.Fatal(err)
		}
		return path
	}
	first := write("a.json", mergeConfig([]map[string]any{mergeProxy("🇭🇰 HK", "hk.a.com")}, mergeGroup("默认代理", "🇭🇰 HK", "DIRECT")))
	second := write("b.json", mergeConfig([]map[string]any{mergeProxy("🇯🇵 JP", "jp.b.com")}, mergeGroup("默认代理", "🇯🇵 JP", "DIRECT")))
	output := filepath.Join(dir, "bundle.yaml")
	result, err := handleMergeProfiles(&MergeProfilesParams{
		Output:  output,
		Members: []MergeMember{{Prefix: "A", Path: first}, {Prefix: "B", Path: second}},
	})
	if err != nil {
		t.Fatal(err)
	}
	var report MergeReport
	if err := json.Unmarshal([]byte(result), &report); err != nil {
		t.Fatal(err)
	}
	if report.Proxies != 2 || report.Groups != 1 {
		t.Fatalf("report = %+v", report)
	}
	data, err := os.ReadFile(output)
	if err != nil {
		t.Fatal(err)
	}
	text := string(data)
	if !strings.HasPrefix(text, "proxies:\n") || !strings.Contains(text, "  - name: \"[ A ] - 🇭🇰 HK\"\n    type: ss\n    server: hk.a.com\n    port: 443\n") {
		t.Fatalf("unexpected yaml:\n%s", text)
	}
	if _, err := config.Parse(data); err != nil {
		t.Fatal(err)
	}
	stamp := time.Now().Add(-time.Hour).Truncate(time.Second)
	if err := os.Chtimes(output, stamp, stamp); err != nil {
		t.Fatal(err)
	}
	if _, err := handleMergeProfiles(&MergeProfilesParams{
		Output:  output,
		Members: []MergeMember{{Prefix: "A", Path: first}, {Prefix: "B", Path: second}},
	}); err != nil {
		t.Fatal(err)
	}
	if info, err := os.Stat(output); err != nil || !info.ModTime().Equal(stamp) {
		t.Fatal("an unchanged merge result must not rewrite the profile")
	}
	if err := os.WriteFile(first, []byte(`{"proxies":[{"name":"bad","type":"ss"}]}`), 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := handleMergeProfiles(&MergeProfilesParams{
		Output:  output,
		Members: []MergeMember{{Prefix: "A", Path: first}},
	}); err == nil {
		t.Fatal("an invalid merge result must be rejected")
	}
	if kept, _ := os.ReadFile(output); string(kept) != text {
		t.Fatal("a rejected merge must keep the previous profile")
	}
	if _, err := handleMergeProfiles(&MergeProfilesParams{Output: output}); err == nil {
		t.Fatal("expected an error without members")
	}
}
