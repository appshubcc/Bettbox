package main

import (
	"encoding/json"

	"github.com/metacubex/mihomo/config"
	yamlv3 "go.yaml.in/yaml/v3"
)

func buildRuntimeConfigNode(
	source []byte,
	before *config.RawConfig,
	after *config.RawConfig,
	forced map[string]json.RawMessage,
) (*yamlv3.Node, error) {
	var document yamlv3.Node
	if err := yamlv3.Unmarshal(source, &document); err != nil {
		return nil, err
	}
	origin := &yamlv3.Node{Kind: yamlv3.MappingNode}
	if document.Kind == yamlv3.DocumentNode && len(document.Content) > 0 &&
		document.Content[0].Kind == yamlv3.MappingNode {
		origin = expandYamlAliases(document.Content[0])
	}
	var beforeNode, afterNode yamlv3.Node
	if err := beforeNode.Encode(before); err != nil {
		return nil, err
	}
	if err := afterNode.Encode(after); err != nil {
		return nil, err
	}
	root := mergeRuntimeMapping(origin, &beforeNode, &afterNode, forced)
	normalizeYamlNode(root)
	return root, nil
}

func mergeRuntimeNode(origin, before, after *yamlv3.Node) *yamlv3.Node {
	if origin == nil {
		return after
	}
	if before != nil && yamlNodeEqual(before, after) {
		return origin
	}
	switch {
	case origin.Kind == yamlv3.MappingNode && after.Kind == yamlv3.MappingNode:
		return mergeRuntimeMapping(origin, before, after, nil)
	case origin.Kind == yamlv3.SequenceNode && after.Kind == yamlv3.SequenceNode:
		return mergeRuntimeSequence(origin, before, after)
	}
	return after
}

// Mappings whose key order matters: mihomo uses the first matching
// nameserver-policy entry, so a patched one keeps the patched order.
var orderedRuntimeMappings = map[string]bool{
	"nameserver-policy":              true,
	"proxy-server-nameserver-policy": true,
}

func mergeRuntimeMapping(
	origin, before, after *yamlv3.Node,
	forced map[string]json.RawMessage,
) *yamlv3.Node {
	result := &yamlv3.Node{Kind: yamlv3.MappingNode, Tag: after.Tag}
	seen := map[string]bool{}
	for i := 0; i+1 < len(origin.Content); i += 2 {
		key, value := origin.Content[i], origin.Content[i+1]
		seen[key.Value] = true
		previous := yamlMappingValue(before, key.Value)
		next := yamlMappingValue(after, key.Value)
		if next == nil {
			if previous == nil {
				result.Content = append(result.Content, key, value)
			}
			continue
		}
		if orderedRuntimeMappings[key.Value] && (previous == nil || !yamlNodeEqual(previous, next)) {
			result.Content = append(result.Content, key, next)
			continue
		}
		result.Content = append(
			result.Content,
			key,
			mergeRuntimeNode(value, previous, next),
		)
	}
	for i := 0; i+1 < len(after.Content); i += 2 {
		key, value := after.Content[i], after.Content[i+1]
		if seen[key.Value] {
			continue
		}
		previous := yamlMappingValue(before, key.Value)
		_, isForced := forced[key.Value]
		if !isForced && previous != nil && yamlNodeEqual(previous, value) {
			continue
		}
		result.Content = append(result.Content, key, value)
	}
	return result
}

func mergeRuntimeSequence(origin, before, after *yamlv3.Node) *yamlv3.Node {
	result := &yamlv3.Node{Kind: yamlv3.SequenceNode, Tag: after.Tag}
	aligned := before != nil &&
		len(origin.Content) == len(after.Content) &&
		len(before.Content) == len(after.Content)
	for i, value := range after.Content {
		var originItem, beforeItem *yamlv3.Node
		if aligned {
			originItem, beforeItem = origin.Content[i], before.Content[i]
		} else if name := yamlMappingValue(value, "name"); name != nil &&
			name.Kind == yamlv3.ScalarNode {
			originItem = findYamlItemByName(origin, name.Value)
			beforeItem = findYamlItemByName(before, name.Value)
		}
		result.Content = append(
			result.Content,
			mergeRuntimeNode(originItem, beforeItem, value),
		)
	}
	return result
}

func findYamlItemByName(sequence *yamlv3.Node, name string) *yamlv3.Node {
	if sequence == nil {
		return nil
	}
	for _, item := range sequence.Content {
		value := yamlMappingValue(item, "name")
		if value != nil && value.Kind == yamlv3.ScalarNode && value.Value == name {
			return item
		}
	}
	return nil
}

func yamlMappingValue(node *yamlv3.Node, key string) *yamlv3.Node {
	if node == nil || node.Kind != yamlv3.MappingNode {
		return nil
	}
	for i := 0; i+1 < len(node.Content); i += 2 {
		if node.Content[i].Value == key {
			return node.Content[i+1]
		}
	}
	return nil
}

func yamlNodeEqual(a, b *yamlv3.Node) bool {
	if a.Kind != b.Kind || len(a.Content) != len(b.Content) {
		return false
	}
	if a.Kind == yamlv3.ScalarNode && (a.Tag != b.Tag || a.Value != b.Value) {
		return false
	}
	for i := range a.Content {
		if !yamlNodeEqual(a.Content[i], b.Content[i]) {
			return false
		}
	}
	return true
}

func isYamlMergeKey(node *yamlv3.Node) bool {
	return node.Kind == yamlv3.ScalarNode &&
		(node.Tag == "!!merge" || (node.Tag == "" && node.Value == "<<"))
}

func expandYamlAliases(node *yamlv3.Node) *yamlv3.Node {
	if node.Kind == yamlv3.AliasNode && node.Alias != nil {
		return expandYamlAliases(node.Alias)
	}
	copied := *node
	copied.Content = nil
	if node.Kind != yamlv3.MappingNode {
		for _, child := range node.Content {
			copied.Content = append(copied.Content, expandYamlAliases(child))
		}
		return &copied
	}
	explicit := map[string]bool{}
	for i := 0; i+1 < len(node.Content); i += 2 {
		if !isYamlMergeKey(node.Content[i]) {
			explicit[node.Content[i].Value] = true
		}
	}
	added := map[string]bool{}
	for i := 0; i+1 < len(node.Content); i += 2 {
		key, value := node.Content[i], node.Content[i+1]
		if !isYamlMergeKey(key) {
			copied.Content = append(
				copied.Content,
				expandYamlAliases(key),
				expandYamlAliases(value),
			)
			continue
		}
		sources := []*yamlv3.Node{expandYamlAliases(value)}
		if sources[0].Kind == yamlv3.SequenceNode {
			sources = sources[0].Content
		}
		for _, source := range sources {
			if source.Kind != yamlv3.MappingNode {
				continue
			}
			for j := 0; j+1 < len(source.Content); j += 2 {
				name := source.Content[j].Value
				if explicit[name] || added[name] {
					continue
				}
				added[name] = true
				copied.Content = append(
					copied.Content,
					source.Content[j],
					source.Content[j+1],
				)
			}
		}
	}
	return &copied
}

func normalizeYamlNode(node *yamlv3.Node) {
	node.Anchor = ""
	node.HeadComment = ""
	node.LineComment = ""
	node.FootComment = ""
	switch node.Style {
	case yamlv3.FlowStyle, yamlv3.DoubleQuotedStyle, yamlv3.SingleQuotedStyle:
		node.Style = 0
	}
	for _, child := range node.Content {
		normalizeYamlNode(child)
	}
}
