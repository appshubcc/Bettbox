package main

import (
	"encoding/json"
	"errors"
	"regexp"
	"strings"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/common/convert"
	"github.com/metacubex/mihomo/common/yaml"
	"github.com/metacubex/mihomo/config"
)

type PatchNode struct {
	Proxy   map[string]any `json:"proxy"`
	Dialer  string         `json:"dialer"`
	Groups  []string       `json:"groups"`
	Beside  string         `json:"beside"`
	Regions bool           `json:"regions"`
	Landing bool           `json:"landing"`
}

const (
	regionMarker      = "x-region"
	regionNodesMarker = "x-region-nodes"
)

func stripRegionMarkers(raw *config.RawConfig) {
	for _, group := range raw.ProxyGroup {
		delete(group, regionMarker)
		delete(group, regionNodesMarker)
	}
}

func cloneMapping(source map[string]any) map[string]any {
	target := make(map[string]any, len(source)+1)
	for key, value := range source {
		target[key] = value
	}
	return target
}

type parseNodesResult struct {
	Proxies []map[string]any `json:"proxies"`
	Invalid int              `json:"invalid"`
	Error   string           `json:"error"`
}

func nodeMappings(value any) []map[string]any {
	switch typed := value.(type) {
	case map[string]any:
		if proxies, ok := typed["proxies"]; ok {
			return nodeMappings(proxies)
		}
		if _, ok := typed["type"]; ok {
			return []map[string]any{typed}
		}
	case []any:
		mappings := make([]map[string]any, 0, len(typed))
		for _, item := range typed {
			if mapping, ok := item.(map[string]any); ok {
				mappings = append(mappings, mapping)
			}
		}
		return mappings
	}
	return nil
}

func parseNodes(text string) ([]map[string]any, int, error) {
	text = strings.TrimSpace(text)
	if text == "" {
		return nil, 0, errors.New("empty content")
	}
	var mappings []map[string]any
	var decoded any
	if err := yaml.Unmarshal([]byte(text), &decoded); err == nil {
		mappings = nodeMappings(decoded)
	}
	if len(mappings) == 0 {
		converted, err := convert.ConvertsV2Ray([]byte(text))
		if err != nil {
			return nil, 0, err
		}
		mappings = converted
	}
	valid := make([]map[string]any, 0, len(mappings))
	var lastErr error
	for _, mapping := range mappings {
		name, _ := mapping["name"].(string)
		if strings.TrimSpace(name) == "" {
			lastErr = errors.New("missing name")
			continue
		}
		delete(mapping, "dialer-proxy")
		proxy, err := adapter.ParseProxy(mapping)
		if err != nil {
			lastErr = err
			continue
		}
		_ = proxy.Close()
		valid = append(valid, mapping)
	}
	if len(valid) == 0 {
		if lastErr == nil {
			lastErr = errors.New("no proxies found")
		}
		return nil, len(mappings), lastErr
	}
	return valid, len(mappings) - len(valid), nil
}

func handleParseNodes(text string) string {
	result := parseNodesResult{}
	proxies, invalid, err := parseNodes(text)
	result.Proxies = proxies
	result.Invalid = invalid
	if err != nil {
		result.Error = err.Error()
	}
	data, err := json.Marshal(result)
	if err != nil {
		data, _ = json.Marshal(parseNodesResult{Error: err.Error()})
	}
	return string(data)
}

func groupMembers(group map[string]any) []string {
	items, _ := group["proxies"].([]any)
	members := make([]string, 0, len(items))
	for _, item := range items {
		if name, ok := item.(string); ok {
			members = append(members, name)
		}
	}
	return members
}

func dialerReach(dialer string, groups map[string]map[string]any, dialers map[string]string) map[string]bool {
	reached := map[string]bool{}
	queue := []string{dialer}
	visit := func(name string) {
		if name != "" && !reached[name] {
			reached[name] = true
			queue = append(queue, name)
		}
	}
	reached[dialer] = true
	for len(queue) > 0 {
		name := queue[0]
		queue = queue[1:]
		group, isGroup := groups[name]
		if !isGroup {
			visit(dialers[name])
			continue
		}
		for _, member := range groupMembers(group) {
			visit(member)
		}
		if includesAllProxies(group) {
			for _, target := range dialers {
				visit(target)
			}
		}
	}
	return reached
}

func groupHasMember(group map[string]any, names ...string) bool {
	for _, member := range groupMembers(group) {
		for _, name := range names {
			if member == name {
				return true
			}
		}
	}
	return false
}

func isSelectGroup(group map[string]any) bool {
	kind, _ := group["type"].(string)
	return strings.EqualFold(kind, "select")
}

func patchNodes(raw *config.RawConfig, nodes []PatchNode) {
	defer stripRegionMarkers(raw)
	if len(nodes) == 0 {
		return
	}
	used := make(map[string]bool, len(raw.Proxy)+len(raw.ProxyGroup)+len(protectedProxyNames)+len(nodes))
	for _, name := range protectedProxyNames {
		used[name] = true
	}
	used["GLOBAL"] = true
	dialers := map[string]string{}
	proxyNames := make(map[string]bool, len(raw.Proxy)+len(nodes))
	for _, proxy := range raw.Proxy {
		name, ok := proxy["name"].(string)
		if !ok {
			continue
		}
		used[name] = true
		proxyNames[name] = true
		if dialer, ok := proxy["dialer-proxy"].(string); ok && dialer != "" {
			dialers[name] = dialer
		}
	}
	groups := make(map[string]map[string]any, len(raw.ProxyGroup))
	regionOf := map[string]string{}
	regionGroups := map[string][]string{}
	nodeRegions := map[string][]string{}
	for _, group := range raw.ProxyGroup {
		name, ok := groupName(group)
		if !ok {
			continue
		}
		used[name] = true
		groups[name] = group
		region, _ := group[regionMarker].(string)
		if region == "" {
			continue
		}
		regionOf[name] = region
		regionGroups[region] = append(regionGroups[region], name)
		if !isSelectGroup(group) {
			continue
		}
		members, _ := group[regionNodesMarker].([]any)
		for _, member := range members {
			if node, ok := member.(string); ok {
				nodeRegions[node] = append(nodeRegions[node], name)
			}
		}
	}
	names := make([]string, len(nodes))
	renamed := make(map[string]string, len(nodes))
	for index, node := range nodes {
		name, _ := node.Proxy["name"].(string)
		if name == "" {
			continue
		}
		names[index] = uniqueProxyName(name, used)
		if _, ok := renamed[name]; !ok {
			renamed[name] = names[index]
		}
	}
	isNode := make(map[string]bool, len(nodes))
	for _, name := range names {
		isNode[name] = true
	}
	for index, node := range nodes {
		name := names[index]
		if name == "" {
			continue
		}
		original, _ := node.Proxy["name"].(string)
		proxy := cloneMapping(node.Proxy)
		proxy["name"] = name
		delete(proxy, "dialer-proxy")
		dialer := ""
		if node.Dialer != "" {
			_, isGroup := groups[node.Dialer]
			switch {
			case isGroup || proxyNames[node.Dialer]:
				dialer = node.Dialer
			case isNode[renamed[node.Dialer]]:
				dialer = renamed[node.Dialer]
			}
		}
		var blocked map[string]bool
		if dialer != "" {
			blocked = dialerReach(dialer, groups, dialers)
			if blocked[name] {
				dialer = ""
				blocked = nil
			}
		}
		if dialer != "" {
			proxy["dialer-proxy"] = dialer
			dialers[name] = dialer
		}
		targets := map[string]bool{}
		for _, target := range node.Groups {
			if _, ok := groups[target]; ok && !blocked[target] {
				targets[target] = true
			}
		}
		if node.Beside != "" {
			for current, candidate := range groups {
				if blocked[current] || !isSelectGroup(candidate) {
					continue
				}
				if groupHasMember(candidate, node.Beside) && !groupHasMember(candidate, "REJECT", "REJECT-DROP") {
					targets[current] = true
				}
			}
		}
		if node.Regions {
			for _, current := range nodeRegions[original] {
				if !blocked[current] {
					targets[current] = true
				}
			}
		}
		if !node.Landing {
			for current := range targets {
				region := regionOf[current]
				if region == "" || !isSelectGroup(groups[current]) {
					continue
				}
				for _, peer := range regionGroups[region] {
					if !blocked[peer] {
						targets[peer] = true
					}
				}
			}
		}
		exclude := "^" + regexp.QuoteMeta(name) + "$"
		for _, group := range raw.ProxyGroup {
			current, ok := groupName(group)
			if !ok {
				continue
			}
			includeAll := includesAllProxies(group)
			switch {
			case targets[current] && !includeAll:
				members, _ := group["proxies"].([]any)
				group["proxies"] = append(members, name)
			case !targets[current] && includeAll:
				combineExcludeFilter(group, exclude)
			}
		}
		proxyNames[name] = true
		raw.Proxy = append(raw.Proxy, proxy)
	}
}
