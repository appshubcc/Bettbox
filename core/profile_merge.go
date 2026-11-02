package main

import (
	"bytes"
	"cmp"
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"maps"
	"net/netip"
	"os"
	"regexp"
	"slices"
	"sort"
	"strconv"
	"strings"

	"github.com/metacubex/mihomo/log"
	yamlv3 "go.yaml.in/yaml/v3"
)

type MergeProfilesParams struct {
	Output  string        `json:"output"`
	Members []MergeMember `json:"members"`
	Setup   *SetupParams  `json:"setup"`
}

type MergeMember struct {
	Prefix string `json:"prefix"`
	Path   string `json:"path"`
}

type MergeReport struct {
	Proxies    int `json:"proxies"`
	Duplicates int `json:"duplicates"`
	Groups     int `json:"groups"`
}

type mergeInput struct {
	config map[string]any
	prefix string
}

var reservedProxyNames = map[string]bool{
	"DIRECT":      true,
	"REJECT":      true,
	"REJECT-DROP": true,
	"PASS":        true,
	"COMPATIBLE":  true,
	"GLOBAL":      true,
}

var mergeRebuiltKeys = map[string]bool{
	"proxies":        true,
	"proxy-groups":   true,
	"rule-providers": true,
	"dns":            true,
	"hosts":          true,
}

var proxyNameBlank = regexp.MustCompile(`[\r\n\t]+`)

var yamlLeadingKeys = []string{"name", "type", "server", "port"}

func handleMergeProfiles(params *MergeProfilesParams) (string, error) {
	if len(params.Members) == 0 {
		return "", errors.New("no profiles to merge")
	}
	inputs := make([]mergeInput, 0, len(params.Members))
	var order []string
	for index, member := range params.Members {
		data, err := readFile(member.Path)
		if err != nil {
			return "", err
		}
		var cfg map[string]any
		if err := json.Unmarshal(data, &cfg); err != nil {
			return "", err
		}
		normalizeJsonNumbers(cfg)
		if index == 0 {
			order = jsonObjectKeys(data)
		}
		inputs = append(inputs, mergeInput{config: cfg, prefix: member.Prefix})
	}
	merged, report := mergeProfileConfigs(inputs)
	data, err := marshalYamlNode(orderedYamlNode(merged, order))
	if err != nil {
		return "", err
	}
	if message := commitMergedProfile(data, params); message != "" {
		return "", errors.New(message)
	}
	result, err := json.Marshal(report)
	if err != nil {
		return "", err
	}
	return string(result), nil
}

func commitMergedProfile(data []byte, params *MergeProfilesParams) string {
	if existing, err := os.ReadFile(params.Output); err == nil && bytes.Equal(existing, data) {
		return ""
	}
	if params.Setup != nil {
		return importValidatedProfile(data, params.Output, params.Setup)
	}
	if message := validateProfileContent(data, ""); message != "" {
		return message
	}
	return writeProfile(params.Output, data)
}

func mergeProfileConfigs(inputs []mergeInput) (map[string]any, MergeReport) {
	var report MergeReport
	used := map[string]bool{}
	for _, input := range inputs {
		for _, group := range mapItems(input.config["proxy-groups"]) {
			if name := stringValue(group["name"]); name != "" {
				used[name] = true
			}
		}
	}
	fingerprints := map[string]string{}
	proxies := []any{}
	groups := map[string]map[string]any{}
	var groupOrders [][]string
	ruleProviders := map[string]any{}
	hosts := map[string]any{}
	var dns map[string]any
	policy := map[string]any{}
	var fakeIPFilter []any
	fakeIPSeen := map[string]bool{}
	conflicts := 0

	for _, input := range inputs {
		rename := map[string]string{}
		var kept []map[string]any
		var domains []string
		for _, proxy := range mapItems(input.config["proxies"]) {
			if server, ok := proxy["server"].(string); ok && isDomainName(server) {
				domains = append(domains, strings.ToLower(server))
			}
			original := strings.TrimSpace(stringValue(proxy["name"]))
			fingerprint := proxyFingerprint(proxy)
			if existing, ok := fingerprints[fingerprint]; ok {
				if !isGeneratedProxy(proxy) {
					report.Duplicates++
				}
				if original != "" {
					rename[original] = existing
				}
				continue
			}
			name := allocateProxyName(sanitizeProxyName(prefixProxyName(proxy, original, input.prefix)), used)
			fingerprints[fingerprint] = name
			if original != "" {
				rename[original] = name
			}
			copied := copyMap(proxy)
			copied["name"] = name
			kept = append(kept, copied)
		}
		for _, proxy := range kept {
			if dialer, ok := proxy["dialer-proxy"].(string); ok {
				if mapped, ok := rename[dialer]; ok {
					proxy["dialer-proxy"] = mapped
				}
			}
			if !isGeneratedProxy(proxy) {
				report.Proxies++
			}
			proxies = append(proxies, proxy)
		}

		var order []string
		ordered := map[string]bool{}
		for _, group := range mapItems(input.config["proxy-groups"]) {
			name := stringValue(group["name"])
			if name == "" {
				continue
			}
			if !ordered[name] {
				ordered[name] = true
				order = append(order, name)
			}
			references := remapReferences(group["proxies"], rename)
			existing, ok := groups[name]
			if !ok {
				copied := copyMap(group)
				if _, has := group["proxies"]; has {
					copied["proxies"] = references
				}
				groups[name] = copied
				continue
			}
			if len(references) > 0 {
				existing["proxies"] = unionReferences(existing["proxies"], references)
			}
		}
		groupOrders = append(groupOrders, order)

		for key, value := range mapValue(input.config["rule-providers"]) {
			if _, ok := ruleProviders[key]; !ok {
				ruleProviders[key] = value
			}
		}

		if memberDNS := mapValue(input.config["dns"]); memberDNS != nil {
			if dns == nil {
				dns = copyMap(memberDNS)
			}
			expanded := expandNameserverPolicy(mapValue(memberDNS["proxy-server-nameserver-policy"]), domains)
			for _, key := range sortedKeys(expanded) {
				value := expanded[key]
				if existing, ok := policy[key]; ok {
					if canonicalJSON(existing) != canonicalJSON(value) {
						conflicts++
					}
					continue
				}
				policy[key] = value
			}
			for _, pattern := range listValue(memberDNS["fake-ip-filter"]) {
				text := fmt.Sprint(pattern)
				if !fakeIPSeen[text] {
					fakeIPSeen[text] = true
					fakeIPFilter = append(fakeIPFilter, pattern)
				}
			}
		}

		for _, key := range sortedKeys(mapValue(input.config["hosts"])) {
			value := mapValue(input.config["hosts"])[key]
			if value == nil {
				continue
			}
			if existing, ok := hosts[key]; ok {
				if canonicalJSON(existing) != canonicalJSON(value) {
					conflicts++
				}
				continue
			}
			hosts[key] = value
		}
	}
	if conflicts > 0 {
		log.Warnln("[Merge] %d conflicting dns policy or hosts entries, kept the earlier members", conflicts)
	}

	merged := map[string]any{}
	for key, value := range inputs[0].config {
		if !mergeRebuiltKeys[key] {
			merged[key] = value
		}
	}
	merged["proxies"] = proxies
	order := restoreGroupOrder(groupOrders)
	if len(order) > 0 {
		list := make([]any, 0, len(order))
		for _, name := range order {
			list = append(list, groups[name])
		}
		merged["proxy-groups"] = list
	}
	if len(ruleProviders) > 0 {
		merged["rule-providers"] = ruleProviders
	}
	if dns != nil {
		if len(policy) > 0 {
			dns["proxy-server-nameserver-policy"] = simplifyDomainPolicy(policy)
		} else {
			delete(dns, "proxy-server-nameserver-policy")
		}
		if len(fakeIPFilter) > 0 {
			dns["fake-ip-filter"] = fakeIPFilter
		}
		merged["dns"] = dns
	}
	if len(hosts) > 0 {
		merged["hosts"] = hosts
	}
	report.Groups = len(order)
	return merged, report
}

func restoreGroupOrder(memberOrders [][]string) []string {
	type indexed struct {
		index int
		order []string
	}
	var orders []indexed
	for index, order := range memberOrders {
		if len(order) > 0 {
			orders = append(orders, indexed{index, order})
		}
	}
	if len(orders) == 0 {
		return nil
	}
	slices.SortStableFunc(orders, func(a, b indexed) int {
		return cmp.Compare(len(b.order), len(a.order))
	})
	result := append([]string(nil), orders[0].order...)
	placed := map[string]bool{}
	for _, name := range result {
		placed[name] = true
	}
	position := func(name string) int {
		for index, item := range result {
			if item == name {
				return index
			}
		}
		return -1
	}
	for _, entry := range orders[1:] {
		order := entry.order
		for i, name := range order {
			if placed[name] {
				continue
			}
			placed[name] = true
			insertAt := -1
			for j := i - 1; j >= 0 && insertAt == -1; j-- {
				if index := position(order[j]); index != -1 {
					insertAt = index + 1
				}
			}
			for j := i + 1; j < len(order) && insertAt == -1; j++ {
				if index := position(order[j]); index != -1 {
					insertAt = index
				}
			}
			if insertAt == -1 {
				insertAt = len(result)
			}
			result = append(result[:insertAt], append([]string{name}, result[insertAt:]...)...)
		}
	}
	return result
}

func expandNameserverPolicy(policy map[string]any, domains []string) map[string]any {
	type rule struct {
		pattern string
		value   any
	}
	result := map[string]any{}
	var rules []rule
	for _, key := range sortedKeys(policy) {
		for pattern := range strings.SplitSeq(key, ",") {
			pattern = strings.ToLower(strings.TrimSpace(pattern))
			if pattern == "" {
				continue
			}
			if strings.Contains(pattern, ":") {
				result[pattern] = policy[key]
				continue
			}
			rules = append(rules, rule{pattern, policy[key]})
		}
	}
	for _, domain := range domains {
		best, score := -1, -1
		for index, item := range rules {
			if value := domainPatternScore(item.pattern, domain); value > score {
				best, score = index, value
			}
		}
		if best >= 0 {
			result[domain] = rules[best].value
		}
	}
	return result
}

func domainPatternScore(pattern string, domain string) int {
	labels := strings.Count(pattern, ".") + 1
	switch {
	case pattern == domain:
		return 1000
	case strings.HasPrefix(pattern, "+."):
		suffix := pattern[2:]
		if domain == suffix || strings.HasSuffix(domain, "."+suffix) {
			return 100 + (labels-1)*2
		}
	case strings.HasPrefix(pattern, "."):
		if strings.HasSuffix(domain, pattern) {
			return 100 + (labels-1)*2
		}
	case strings.Contains(pattern, "*"):
		patternLabels := strings.Split(pattern, ".")
		domainLabels := strings.Split(domain, ".")
		if len(patternLabels) != len(domainLabels) {
			return -1
		}
		for index, label := range patternLabels {
			if label != "*" && label != domainLabels[index] {
				return -1
			}
		}
		return 100 + labels*2 - 1
	}
	return -1
}

func simplifyDomainPolicy(policy map[string]any) map[string]any {
	type entry struct {
		domain string
		value  any
		key    string
	}
	result := map[string]any{}
	groups := map[string][]entry{}
	var suffixes []string
	for _, domain := range sortedKeys(policy) {
		value := policy[domain]
		parts := strings.Split(domain, ".")
		if strings.HasPrefix(domain, "+.") || strings.HasPrefix(domain, ".") ||
			strings.ContainsAny(domain, "*:") || len(parts) < 3 {
			result[domain] = value
			continue
		}
		suffix := strings.Join(parts[len(parts)-2:], ".")
		if _, ok := groups[suffix]; !ok {
			suffixes = append(suffixes, suffix)
		}
		groups[suffix] = append(groups[suffix], entry{domain, value, dnsValueKey(value)})
	}
	for _, suffix := range suffixes {
		entries := groups[suffix]
		same := len(entries) >= 2
		for _, item := range entries[1:] {
			if item.key != entries[0].key {
				same = false
				break
			}
		}
		if _, taken := result["+."+suffix]; same && !taken {
			result["+."+suffix] = entries[0].value
			continue
		}
		for _, item := range entries {
			result[item.domain] = item.value
		}
	}
	return result
}

func dnsValueKey(value any) string {
	list, ok := value.([]any)
	if !ok {
		return canonicalJSON(value)
	}
	items := make([]string, 0, len(list))
	for _, item := range list {
		items = append(items, fmt.Sprint(item))
	}
	sort.Strings(items)
	return canonicalJSON(items)
}

func isDomainName(server string) bool {
	if server == "" {
		return false
	}
	_, err := netip.ParseAddr(strings.Trim(server, "[]"))
	return err != nil
}

func isGeneratedProxy(proxy map[string]any) bool {
	switch strings.ToLower(stringValue(proxy["type"])) {
	case "direct", "reject", "rematch":
		return true
	}
	return false
}

func prefixProxyName(proxy map[string]any, original string, prefix string) string {
	if prefix == "" || original == "" || isGeneratedProxy(proxy) {
		return original
	}
	return "[ " + prefix + " ] - " + original
}

func sanitizeProxyName(name string) string {
	return strings.TrimSpace(strings.ReplaceAll(proxyNameBlank.ReplaceAllString(name, " "), ",", "，"))
}

func allocateProxyName(name string, used map[string]bool) string {
	base := name
	if base == "" {
		base = "Proxy"
	}
	if !reservedProxyNames[strings.ToUpper(base)] && !used[base] {
		used[base] = true
		return base
	}
	for index := 2; ; index++ {
		candidate := base + "-" + strconv.Itoa(index)
		if !used[candidate] {
			used[candidate] = true
			return candidate
		}
	}
}

func remapReferences(value any, rename map[string]string) []any {
	list, ok := value.([]any)
	if !ok {
		return []any{}
	}
	result := make([]any, 0, len(list))
	for _, item := range list {
		if item == nil {
			continue
		}
		name := fmt.Sprint(item)
		if mapped, ok := rename[name]; ok {
			name = mapped
		}
		result = append(result, name)
	}
	return result
}

func unionReferences(current any, incoming []any) []any {
	existing, _ := current.([]any)
	result := make([]any, 0, len(existing)+len(incoming))
	seen := map[string]bool{}
	for _, item := range append(append([]any(nil), existing...), incoming...) {
		name := fmt.Sprint(item)
		if !seen[name] {
			seen[name] = true
			result = append(result, name)
		}
	}
	return result
}

func proxyFingerprint(proxy map[string]any) string {
	content := copyMap(proxy)
	delete(content, "name")
	sum := md5.Sum([]byte(canonicalJSON(content)))
	return hex.EncodeToString(sum[:])
}

func canonicalJSON(value any) string {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Sprint(value)
	}
	return string(data)
}

func jsonObjectKeys(data []byte) []string {
	decoder := json.NewDecoder(bytes.NewReader(data))
	if token, err := decoder.Token(); err != nil || token != json.Delim('{') {
		return nil
	}
	var keys []string
	for decoder.More() {
		token, err := decoder.Token()
		if err != nil {
			return keys
		}
		key, ok := token.(string)
		if !ok {
			return keys
		}
		keys = append(keys, key)
		var skip json.RawMessage
		if err := decoder.Decode(&skip); err != nil {
			return keys
		}
	}
	return keys
}

func orderedYamlNode(value any, order []string) *yamlv3.Node {
	switch typed := value.(type) {
	case map[string]any:
		node := &yamlv3.Node{Kind: yamlv3.MappingNode}
		if order == nil {
			order = yamlLeadingKeys
		}
		for _, key := range orderedKeys(typed, order) {
			keyNode := &yamlv3.Node{}
			_ = keyNode.Encode(key)
			node.Content = append(node.Content, keyNode, orderedYamlNode(typed[key], nil))
		}
		return node
	case []any:
		node := &yamlv3.Node{Kind: yamlv3.SequenceNode}
		for _, item := range typed {
			node.Content = append(node.Content, orderedYamlNode(item, nil))
		}
		return node
	}
	node := &yamlv3.Node{}
	if err := node.Encode(value); err != nil {
		_ = node.Encode(nil)
	}
	return node
}

func orderedKeys(value map[string]any, leading []string) []string {
	keys := make([]string, 0, len(value))
	taken := map[string]bool{}
	for _, key := range leading {
		if _, ok := value[key]; ok && !taken[key] {
			taken[key] = true
			keys = append(keys, key)
		}
	}
	for _, key := range sortedKeys(value) {
		if !taken[key] {
			keys = append(keys, key)
		}
	}
	return keys
}

func sortedKeys(value map[string]any) []string {
	keys := make([]string, 0, len(value))
	for key := range value {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	return keys
}

func copyMap(value map[string]any) map[string]any {
	result := make(map[string]any, len(value))
	maps.Copy(result, value)
	return result
}

func mapValue(value any) map[string]any {
	result, _ := value.(map[string]any)
	return result
}

func listValue(value any) []any {
	result, _ := value.([]any)
	return result
}

func mapItems(value any) []map[string]any {
	var result []map[string]any
	for _, item := range listValue(value) {
		if mapping, ok := item.(map[string]any); ok {
			result = append(result, mapping)
		}
	}
	return result
}

func stringValue(value any) string {
	text, _ := value.(string)
	return text
}
