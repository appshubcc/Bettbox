package main

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/common/yaml"
	"github.com/metacubex/mihomo/config"
	LC "github.com/metacubex/mihomo/listener/config"
)

type PatchHost struct {
	Key   string `json:"key"`
	Value any    `json:"value"`
}

type PatchRules struct {
	Override bool     `json:"override"`
	Rules    []string `json:"rules"`
}

type PatchParams struct {
	General            json.RawMessage `json:"general"`
	GeoXUrl            json.RawMessage `json:"geox-url"`
	Hosts              []PatchHost     `json:"hosts"`
	OverrideDns        bool            `json:"override-dns"`
	Dns                json.RawMessage `json:"dns"`
	Ntp                json.RawMessage `json:"ntp"`
	Sniffer            json.RawMessage `json:"sniffer"`
	Experimental       json.RawMessage `json:"experimental"`
	Tunnels            json.RawMessage `json:"tunnels"`
	ProvidersPath      string          `json:"providers-path"`
	NodeExcludeFilter  string          `json:"node-exclude-filter"`
	HealthCheckTimeout int             `json:"health-check-timeout"`
	OverrideRules      *PatchRules     `json:"override-rules"`
	PrependRules       []string        `json:"prepend-rules"`
	DisabledGroups     []string        `json:"disabled-groups"`
	SelectGlobal       bool            `json:"select-global"`
	Tailscale          *PatchTailscale `json:"tailscale"`
}

const defaultHealthCheckTimeout = 5000

var patchForAndroid = runtime.GOOS == "android"

var protectedProxyNames = []string{"DIRECT", "REJECT", "REJECT-DROP", "COMPATIBLE", "PASS"}

var ruleActionsWithParams = map[string]bool{
	"GEOIP": true, "IP-ASN": true, "SRC-IP-ASN": true, "IP-CIDR": true,
	"IP-CIDR6": true, "IP-SUFFIX": true, "RULE-SET": true,
}

func isRuleActionWithParams(action string) bool {
	switch action {
	case "GEOIP", "IP-ASN", "SRC-IP-ASN", "IP-CIDR", "IP-CIDR6", "IP-SUFFIX", "RULE-SET":
		return true
	default:
		return ruleActionsWithParams[action]
	}
}

func hasPatchValue(data json.RawMessage) bool {
	return len(data) > 0 && string(data) != "null"
}

func applyPatch(raw *config.RawConfig, params *PatchParams) (string, error) {
	defaults := config.DefaultRawConfig()
	if hasPatchValue(params.General) {
		if err := yaml.Unmarshal(params.General, raw); err != nil {
			return "", fmt.Errorf("patch general: %w", err)
		}
		var nullable struct {
			GlobalUA *string `json:"global-ua"`
		}
		if err := json.Unmarshal(params.General, &nullable); err == nil && nullable.GlobalUA == nil {
			raw.GlobalUA = defaults.GlobalUA
		}
	}
	if hasPatchValue(params.GeoXUrl) {
		raw.GeoXUrl = defaults.GeoXUrl
		if err := yaml.Unmarshal(params.GeoXUrl, &raw.GeoXUrl); err != nil {
			return "", fmt.Errorf("patch geox-url: %w", err)
		}
	}
	patchProviderPaths(raw.ProxyProvider, params.ProvidersPath, "proxies")
	patchProviderPaths(raw.RuleProvider, params.ProvidersPath, "rules")
	patchHosts(raw, params.Hosts)
	if err := patchDns(raw, params, defaults); err != nil {
		return "", err
	}
	if hasPatchValue(params.Ntp) {
		raw.NTP = defaults.NTP
		if err := yaml.Unmarshal(params.Ntp, &raw.NTP); err != nil {
			return "", fmt.Errorf("patch ntp: %w", err)
		}
	}
	if patchForAndroid {
		raw.NTP.WriteToSystem = false
	}
	if hasPatchValue(params.Sniffer) {
		raw.Sniffer = defaults.Sniffer
		if err := yaml.Unmarshal(params.Sniffer, &raw.Sniffer); err != nil {
			return "", fmt.Errorf("patch sniffer: %w", err)
		}
	}
	if hasPatchValue(params.Tunnels) {
		var tunnels []LC.Tunnel
		if err := yaml.Unmarshal(params.Tunnels, &tunnels); err != nil {
			return "", fmt.Errorf("patch tunnels: %w", err)
		}
		raw.Tunnels = append(raw.Tunnels, tunnels...)
	}
	if hasPatchValue(params.Experimental) {
		raw.Experimental = defaults.Experimental
		if err := yaml.Unmarshal(params.Experimental, &raw.Experimental); err != nil {
			return "", fmt.Errorf("patch experimental: %w", err)
		}
	}
	patchProxyGroups(raw, params)
	tailscaleRules := patchTailscale(raw, params)

	rules := raw.Rule
	hasOverride := params.OverrideRules != nil
	hasPrepend := len(params.PrependRules) > 0
	if hasOverride || hasPrepend {
		if hasOverride && params.OverrideRules.Override {
			total := len(params.PrependRules) + len(params.OverrideRules.Rules)
			merged := make([]string, 0, total)
			merged = append(merged, params.PrependRules...)
			merged = append(merged, params.OverrideRules.Rules...)
			rules = merged
		} else {
			var overrideSlice []string
			if hasOverride {
				overrideSlice = params.OverrideRules.Rules
			}
			total := len(params.PrependRules) + len(overrideSlice) + len(rules)
			merged := make([]string, 0, total)
			merged = append(merged, params.PrependRules...)
			merged = append(merged, overrideSlice...)
			merged = append(merged, rules...)
			rules = merged
		}
	}
	if len(tailscaleRules) > 0 {
		// After the prepended rules, before the override and profile rules.
		at := len(params.PrependRules)
		rules = append(append(append([]string{}, rules[:at]...), tailscaleRules...), rules[at:]...)
	}

	patchProxies(raw)

	if len(params.DisabledGroups) > 0 {
		disabled := make(map[string]bool, len(params.DisabledGroups)*2)
		for _, name := range params.DisabledGroups {
			disabled[name] = true
		}
		raw.ProxyGroup = disableGroups(raw.ProxyGroup, disabled)
		for i, rule := range rules {
			parsed := parseRule(rule)
			if parsed.hasTarget && disabled[parsed.target] {
				parsed.target = "PASS"
				rules[i] = parsed.String()
			}
		}
	}

	global := ""
	if params.SelectGlobal {
		global = selectGlobalTarget(raw.ProxyGroup, rules)
	}
	raw.ProxyGroup = filterGroups(raw.ProxyGroup, func(name string) bool {
		return name != "GLOBAL"
	})
	raw.Rule = rules
	return global, nil
}

func patchProviderPaths(providers map[string]map[string]any, base string, kind string) {
	if len(providers) == 0 {
		return
	}
	dir := filepath.Join(base, kind)
	for _, provider := range providers {
		if provider["type"] != "http" {
			continue
		}
		url, ok := provider["url"].(string)
		if !ok {
			continue
		}
		sum := md5.Sum([]byte(url))
		provider["path"] = filepath.Join(dir, hex.EncodeToString(sum[:]))
	}
}

func patchHosts(raw *config.RawConfig, hosts []PatchHost) {
	if raw.Hosts == nil {
		raw.Hosts = make(map[string]any, len(hosts))
	}
	for _, host := range hosts {
		raw.Hosts[host.Key] = host.Value
	}
}

func patchDns(raw *config.RawConfig, params *PatchParams, defaults *config.RawConfig) error {
	enabled := raw.DNS.Enable
	if params.OverrideDns || !enabled {
		dns := defaults.DNS
		if hasPatchValue(params.Dns) {
			if err := yaml.Unmarshal(params.Dns, &dns); err != nil {
				return fmt.Errorf("patch dns: %w", err)
			}
		}
		if !enabled {
			ns := make([]string, len(dns.NameServer)+1)
			copy(ns, dns.NameServer)
			ns[len(dns.NameServer)] = "system://"
			dns.NameServer = ns
		}
		raw.DNS = dns
	}
	raw.DNS.FallbackFilter.GeoSite = []string{}

	if !patchForAndroid {
		return nil
	}
	listen := raw.DNS.Listen
	if strings.HasSuffix(listen, ":53") {
		raw.DNS.Listen = strings.ReplaceAll(listen, ":53", ":10053")
	}
	noProviders := raw.ProxyProvider == nil && raw.RuleProvider == nil
	hasLocalNameserver := false
	for _, nameserver := range raw.DNS.ProxyServerNameserver {
		if strings.HasPrefix(nameserver, "127.0.0.1") {
			hasLocalNameserver = true
			break
		}
	}
	if noProviders && hasLocalNameserver && strings.HasPrefix(listen, "0.0.0.0") {
		raw.DNS.Listen = "127.0.0.1" + strings.TrimPrefix(listen, "0.0.0.0")
	}
	return nil
}

func groupName(group map[string]any) (string, bool) {
	name, ok := group["name"].(string)
	return name, ok
}

func filterGroups(groups []map[string]any, keep func(name string) bool) []map[string]any {
	filtered := groups[:0]
	for _, group := range groups {
		if name, ok := groupName(group); ok && !keep(name) {
			continue
		}
		filtered = append(filtered, group)
	}
	return filtered
}

func disableGroups(groups []map[string]any, disabled map[string]bool) []map[string]any {
	for changed := true; changed; {
		changed = false
		for _, group := range groups {
			name, ok := groupName(group)
			if !ok || disabled[name] {
				continue
			}
			proxies, ok := group["proxies"].([]any)
			if !ok || len(proxies) == 0 {
				continue
			}
			firstDisabled := -1
			for i, proxy := range proxies {
				if value, ok := proxy.(string); ok && disabled[value] {
					firstDisabled = i
					break
				}
			}
			if firstDisabled == -1 {
				continue
			}
			kept := make([]any, firstDisabled, len(proxies)-1)
			copy(kept, proxies[:firstDisabled])
			for _, proxy := range proxies[firstDisabled+1:] {
				if value, ok := proxy.(string); ok && disabled[value] {
					continue
				}
				kept = append(kept, proxy)
			}
			group["proxies"] = kept
			if len(kept) == 0 && !hasGroupSource(group) {
				disabled[name] = true
				changed = true
			}
		}
	}
	return filterGroups(groups, func(name string) bool {
		return !disabled[name]
	})
}

func hasGroupSource(group map[string]any) bool {
	if use, ok := group["use"].([]any); ok && len(use) > 0 {
		return true
	}
	if value, ok := group["include-all"].(bool); ok && value {
		return true
	}
	if value, ok := group["include-all-proxies"].(bool); ok && value {
		return true
	}
	if value, ok := group["include-all-providers"].(bool); ok && value {
		return true
	}
	return false
}

func combineExcludeFilter(target map[string]any, filter string) {
	if existing, ok := target["exclude-filter"].(string); ok && existing != "" {
		target["exclude-filter"] = existing + "|" + filter
		return
	}
	target["exclude-filter"] = filter
}

func patchProxyGroups(raw *config.RawConfig, params *PatchParams) {
	filter := params.NodeExcludeFilter
	if raw.ProxyGroup != nil && (filter != "" || params.HealthCheckTimeout != defaultHealthCheckTimeout) {
		var filterRegex *regexp2.Regexp
		if filter != "" {
			filterRegex, _ = regexp2.Compile(filter, regexp2.ECMAScript)
		}
		var protected map[string]bool
		var excluded map[string]bool
		if filterRegex != nil {
			protected = make(map[string]bool, len(protectedProxyNames)+len(raw.ProxyGroup))
			for _, name := range protectedProxyNames {
				protected[name] = true
			}
			for _, group := range raw.ProxyGroup {
				if name, ok := groupName(group); ok {
					protected[name] = true
				}
			}
			excluded = make(map[string]bool, len(raw.Proxy))
		}
		isExcluded := func(name string) bool {
			if result, exist := excluded[name]; exist {
				return result
			}
			matched, _ := filterRegex.MatchString(name)
			excluded[name] = matched
			return matched
		}
		for _, group := range raw.ProxyGroup {
			if group == nil {
				continue
			}
			use, hasUse := group["use"]
			hasUse = hasUse && use != nil
			if filterRegex != nil && hasUse {
				combineExcludeFilter(group, filter)
			}
			if proxies, ok := group["proxies"].([]any); ok && filterRegex != nil {
				firstExcluded := -1
				for i, item := range proxies {
					if name, isString := item.(string); isString && !protected[name] && isExcluded(name) {
						firstExcluded = i
						break
					}
				}
				var filtered []any
				if firstExcluded == -1 {
					filtered = proxies
				} else {
					filtered = make([]any, firstExcluded, len(proxies))
					copy(filtered, proxies[:firstExcluded])
					for _, item := range proxies[firstExcluded+1:] {
						if name, isString := item.(string); isString && !protected[name] && isExcluded(name) {
							continue
						}
						filtered = append(filtered, item)
					}
				}
				useList, useIsList := use.([]any)
				if len(filtered) == 0 && (!hasUse || (useIsList && len(useList) == 0)) {
					if filtered == nil || cap(filtered) == 0 {
						filtered = []any{"DIRECT"}
					} else {
						filtered = append(filtered[:0], "DIRECT")
					}
				}
				group["proxies"] = filtered
			}
			if params.HealthCheckTimeout != defaultHealthCheckTimeout {
				if timeout, exist := group["timeout"]; !exist || timeout == nil {
					group["timeout"] = params.HealthCheckTimeout
				}
			}
		}
		if filterRegex != nil {
			for _, provider := range raw.ProxyProvider {
				if provider == nil {
					continue
				}
				combineExcludeFilter(provider, filter)
			}
		}
	}

	for _, group := range raw.ProxyGroup {
		switch tolerance := group["tolerance"].(type) {
		case float64:
			group["tolerance"] = int(tolerance)
		case string:
			if value, err := strconv.Atoi(strings.TrimSpace(tolerance)); err == nil {
				group["tolerance"] = value
			}
		}
	}
}

func patchProxies(raw *config.RawConfig) {
	fingerprint := raw.GlobalClientFingerprint
	for _, proxy := range raw.Proxy {
		if proxy == nil {
			continue
		}
		proxyType := ""
		if value, exist := proxy["type"]; exist && value != nil {
			if s, ok := value.(string); ok {
				proxyType = s
			} else {
				proxyType = fmt.Sprint(value)
			}
		}
		isTls := proxy["tls"] == true
		supportFingerprint := strings.EqualFold(proxyType, "trojan") ||
			strings.EqualFold(proxyType, "anytls") ||
			(isTls && (strings.EqualFold(proxyType, "vmess") || strings.EqualFold(proxyType, "vless")))
		if supportFingerprint {
			if value, exist := proxy["client-fingerprint"]; !exist || value == nil {
				proxy["client-fingerprint"] = fingerprint
			}
		}
		realityOpts, ok := proxy["reality-opts"].(map[string]any)
		if !ok {
			continue
		}
		switch shortId := realityOpts["short-id"].(type) {
		case int:
			realityOpts["short-id"] = strconv.Itoa(shortId)
		case int64:
			realityOpts["short-id"] = strconv.FormatInt(shortId, 10)
		case uint64:
			realityOpts["short-id"] = strconv.FormatUint(shortId, 10)
		}
	}
}

func selectGlobalTarget(groups []map[string]any, rules []string) string {
	for _, group := range groups {
		name, ok := groupName(group)
		if ok && name != "GLOBAL" && name != "DIRECT" && name != "REJECT" {
			return name
		}
	}
	names := make(map[string]bool, len(groups))
	for _, group := range groups {
		value, exist := group["name"]
		if !exist || value == nil {
			continue
		}
		var name string
		if s, ok := value.(string); ok {
			name = s
		} else {
			name = fmt.Sprint(value)
		}
		if name != "GLOBAL" && name != "DIRECT" && name != "REJECT" {
			names[name] = true
		}
	}
	if len(names) == 0 {
		return ""
	}
	for _, rule := range rules {
		trimmed := strings.TrimSpace(rule)
		if !strings.HasPrefix(trimmed, "MATCH") {
			continue
		}
		parsed := parseRule(trimmed)
		if parsed.action == "MATCH" && parsed.hasTarget && parsed.target != "" &&
			parsed.target != "DIRECT" && parsed.target != "REJECT" && names[parsed.target] {
			return parsed.target
		}
	}
	return ""
}

type parsedRule struct {
	action    string
	content   string
	target    string
	hasTarget bool
	subRule   string
	noResolve bool
	src       bool
}

func parseRule(value string) parsedRule {
	raw := strings.TrimSpace(value)
	rule := parsedRule{}
	for {
		if strings.HasSuffix(raw, ",no-resolve") {
			rule.noResolve = true
			raw = strings.TrimSpace(raw[:len(raw)-len(",no-resolve")])
		} else if strings.HasSuffix(raw, ",src") {
			rule.src = true
			raw = strings.TrimSpace(raw[:len(raw)-len(",src")])
		} else {
			break
		}
	}
	firstComma := strings.IndexByte(raw, ',')
	if firstComma == -1 {
		rule.action = raw
		return rule
	}
	rule.action = strings.TrimSpace(raw[:firstComma])
	rest := strings.TrimSpace(raw[firstComma+1:])
	if rule.action == "MATCH" {
		rule.target = rest
		rule.hasTarget = true
		return rule
	}
	lastComma := strings.LastIndexByte(rest, ',')
	if lastComma == -1 {
		rule.content = rest
		return rule
	}
	rule.content = strings.TrimSpace(rest[:lastComma])
	target := strings.TrimSpace(rest[lastComma+1:])
	if rule.action == "SUB-RULE" {
		rule.subRule = target
	} else {
		rule.target = target
		rule.hasTarget = true
	}
	return rule
}

func (r parsedRule) String() string {
	if r.action == "MATCH" {
		if r.target != "" {
			return r.action + "," + r.target
		}
		return r.action
	}
	var parts [5]string
	n := 1
	parts[0] = r.action
	if r.content != "" {
		parts[n] = r.content
		n++
	}
	target := r.target
	if r.action == "SUB-RULE" {
		target = r.subRule
	}
	if target != "" {
		parts[n] = target
		n++
	}
	if isRuleActionWithParams(r.action) {
		if r.src {
			parts[n] = "src"
			n++
		}
		if r.noResolve {
			parts[n] = "no-resolve"
			n++
		}
	}
	return strings.Join(parts[:n], ",")
}
