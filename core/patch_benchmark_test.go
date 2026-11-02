package main

import (
	"fmt"
	"strconv"
	"strings"
	"testing"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/config"
)

type parsedRuleOld struct {
	action    string
	content   string
	target    string
	hasTarget bool
	subRule   string
	noResolve bool
	src       bool
}

func parseRuleOld(value string) parsedRuleOld {
	raw := strings.TrimSpace(value)
	rule := parsedRuleOld{}
	for {
		if strings.HasSuffix(raw, ",no-resolve") {
			rule.noResolve = true
			raw = strings.TrimSpace(strings.TrimSuffix(raw, ",no-resolve"))
		} else if strings.HasSuffix(raw, ",src") {
			rule.src = true
			raw = strings.TrimSpace(strings.TrimSuffix(raw, ",src"))
		} else {
			break
		}
	}
	firstComma := strings.Index(raw, ",")
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
	lastComma := strings.LastIndex(rest, ",")
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

func (r parsedRuleOld) StringOld() string {
	parts := []string{r.action}
	if r.action == "MATCH" {
		if r.target != "" {
			parts = append(parts, r.target)
		}
		return strings.Join(parts, ",")
	}
	if r.content != "" {
		parts = append(parts, r.content)
	}
	target := r.target
	if r.action == "SUB-RULE" {
		target = r.subRule
	}
	if target != "" {
		parts = append(parts, target)
	}
	if ruleActionsWithParams[r.action] {
		if r.src {
			parts = append(parts, "src")
		}
		if r.noResolve {
			parts = append(parts, "no-resolve")
		}
	}
	return strings.Join(parts, ",")
}

func patchProxyGroupsOld(raw *config.RawConfig, params *PatchParams) {
	filter := params.NodeExcludeFilter
	if raw.ProxyGroup != nil && (filter != "" || params.HealthCheckTimeout != defaultHealthCheckTimeout) {
		var filterRegex *regexp2.Regexp
		if filter != "" {
			filterRegex, _ = regexp2.Compile(filter, regexp2.ECMAScript)
		}
		protected := map[string]bool{}
		for _, name := range protectedProxyNames {
			protected[name] = true
		}
		for _, group := range raw.ProxyGroup {
			if name, ok := groupName(group); ok {
				protected[name] = true
			}
		}
		excluded := map[string]bool{}
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
				filtered := make([]any, 0, len(proxies))
				for _, item := range proxies {
					name, isString := item.(string)
					if isString && !protected[name] && isExcluded(name) {
						continue
					}
					filtered = append(filtered, item)
				}
				useList, useIsList := use.([]any)
				if len(filtered) == 0 && (!hasUse || (useIsList && len(useList) == 0)) {
					filtered = append(filtered, "DIRECT")
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

func selectGlobalTargetOld(groups []map[string]any, rules []string) string {
	for _, group := range groups {
		name, ok := groupName(group)
		if ok && name != "GLOBAL" && name != "DIRECT" && name != "REJECT" {
			return name
		}
	}
	names := map[string]bool{}
	for _, group := range groups {
		value, exist := group["name"]
		if !exist || value == nil {
			continue
		}
		name := fmt.Sprint(value)
		if name != "GLOBAL" && name != "DIRECT" && name != "REJECT" {
			names[name] = true
		}
	}
	for _, rule := range rules {
		parsed := parseRuleOld(rule)
		if parsed.action == "MATCH" && parsed.hasTarget && parsed.target != "" &&
			parsed.target != "DIRECT" && parsed.target != "REJECT" && names[parsed.target] {
			return parsed.target
		}
	}
	return ""
}

func applyPatchRulesMergeOld(rules []string, overrideRules *PatchRules, prependRules []string) []string {
	if overrideRules != nil {
		if overrideRules.Override {
			rules = overrideRules.Rules
		} else {
			rules = append(append([]string{}, overrideRules.Rules...), rules...)
		}
	}
	if len(prependRules) > 0 {
		rules = append(append([]string{}, prependRules...), rules...)
	}
	return rules
}

func applyPatchRulesMergeNew(rules []string, overrideRules *PatchRules, prependRules []string) []string {
	hasOverride := overrideRules != nil
	hasPrepend := len(prependRules) > 0
	if hasOverride || hasPrepend {
		if hasOverride && overrideRules.Override {
			total := len(prependRules) + len(overrideRules.Rules)
			merged := make([]string, 0, total)
			merged = append(merged, prependRules...)
			merged = append(merged, overrideRules.Rules...)
			return merged
		} else {
			var overrideSlice []string
			if hasOverride {
				overrideSlice = overrideRules.Rules
			}
			total := len(prependRules) + len(overrideSlice) + len(rules)
			merged := make([]string, 0, total)
			merged = append(merged, prependRules...)
			merged = append(merged, overrideSlice...)
			merged = append(merged, rules...)
			return merged
		}
	}
	return rules
}

func BenchmarkParseRule_Old(b *testing.B) {
	rule := "RULE-SET,inline-streaming-rule,ProxyGroup1,src,no-resolve"
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		p := parseRuleOld(rule)
		_ = p.StringOld()
	}
}

func BenchmarkParseRule_New(b *testing.B) {
	rule := "RULE-SET,inline-streaming-rule,ProxyGroup1,src,no-resolve"
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		p := parseRule(rule)
		_ = p.String()
	}
}

func BenchmarkPatchProxyGroups_CowNoExclude_Old(b *testing.B) {
	groups := make([]map[string]any, 20)
	for i := range groups {
		proxiesList := make([]any, 100)
		for j := range proxiesList {
			proxiesList[j] = fmt.Sprintf("Node-%d-%d", i, j)
		}
		groups[i] = map[string]any{
			"name":    fmt.Sprintf("Group-%d", i),
			"proxies": proxiesList,
		}
	}
	params := &PatchParams{
		NodeExcludeFilter:  "NeverMatchAnyNodePattern",
		HealthCheckTimeout: defaultHealthCheckTimeout,
	}
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		raw := &config.RawConfig{ProxyGroup: groups}
		patchProxyGroupsOld(raw, params)
	}
}

func BenchmarkPatchProxyGroups_CowNoExclude_New(b *testing.B) {
	groups := make([]map[string]any, 20)
	for i := range groups {
		proxiesList := make([]any, 100)
		for j := range proxiesList {
			proxiesList[j] = fmt.Sprintf("Node-%d-%d", i, j)
		}
		groups[i] = map[string]any{
			"name":    fmt.Sprintf("Group-%d", i),
			"proxies": proxiesList,
		}
	}
	params := &PatchParams{
		NodeExcludeFilter:  "NeverMatchAnyNodePattern",
		HealthCheckTimeout: defaultHealthCheckTimeout,
	}
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		raw := &config.RawConfig{ProxyGroup: groups}
		patchProxyGroups(raw, params)
	}
}

func BenchmarkSelectGlobalTarget_Fallback_Old(b *testing.B) {
	groups := []map[string]any{
		{"name": 1},
		{"name": 2},
	}
	rules := make([]string, 5000)
	for i := range 4999 {
		rules[i] = fmt.Sprintf("DOMAIN-SUFFIX,domain-%d.com,AutoGroup", i)
	}
	rules[4999] = "MATCH,ProxyGroup"
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		_ = selectGlobalTargetOld(groups, rules)
	}
}

func BenchmarkSelectGlobalTarget_Fallback_New(b *testing.B) {
	groups := []map[string]any{
		{"name": 1},
		{"name": 2},
	}
	rules := make([]string, 5000)
	for i := range 4999 {
		rules[i] = fmt.Sprintf("DOMAIN-SUFFIX,domain-%d.com,AutoGroup", i)
	}
	rules[4999] = "MATCH,ProxyGroup"
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		_ = selectGlobalTarget(groups, rules)
	}
}

func BenchmarkApplyPatch_RuleMerge_Old(b *testing.B) {
	rules := make([]string, 20000)
	for i := range rules {
		rules[i] = fmt.Sprintf("DOMAIN-SUFFIX,site-%d.com,DIRECT", i)
	}
	prepend := []string{"DOMAIN,vip.com,PROXY", "DOMAIN,cdn.com,DIRECT"}
	override := &PatchRules{
		Override: false,
		Rules:    []string{"DOMAIN-KEYWORD,google,PROXY", "DOMAIN-KEYWORD,youtube,PROXY"},
	}
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		_ = applyPatchRulesMergeOld(rules, override, prepend)
	}
}

func BenchmarkApplyPatch_RuleMerge_New(b *testing.B) {
	rules := make([]string, 20000)
	for i := range rules {
		rules[i] = fmt.Sprintf("DOMAIN-SUFFIX,site-%d.com,DIRECT", i)
	}
	prepend := []string{"DOMAIN,vip.com,PROXY", "DOMAIN,cdn.com,DIRECT"}
	override := &PatchRules{
		Override: false,
		Rules:    []string{"DOMAIN-KEYWORD,google,PROXY", "DOMAIN-KEYWORD,youtube,PROXY"},
	}
	b.ResetTimer()
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		_ = applyPatchRulesMergeNew(rules, override, prepend)
	}
}
