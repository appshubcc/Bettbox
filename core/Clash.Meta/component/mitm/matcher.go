package mitm

import (
	"strings"

	"github.com/metacubex/mihomo/component/wildcard"
)

// HostMatcher matches Surge-style MITM host lists.
// A leading '-' excludes a host. Exclusion wins.
type HostMatcher struct {
	include []string
	exclude []string
}

func NewHostMatcher(hosts []string) *HostMatcher {
	m := &HostMatcher{}
	for _, raw := range hosts {
		h := strings.TrimSpace(raw)
		if h == "" || strings.HasPrefix(h, "#") {
			continue
		}
		if strings.HasPrefix(h, "-") {
			m.exclude = append(m.exclude, strings.TrimSpace(h[1:]))
			continue
		}
		m.include = append(m.include, h)
	}
	return m
}

func (m *HostMatcher) Empty() bool {
	return m == nil || len(m.include) == 0
}

func (m *HostMatcher) Match(host string) bool {
	if m == nil || host == "" {
		return false
	}
	host = strings.ToLower(strings.TrimSuffix(host, "."))
	for _, p := range m.exclude {
		if matchHostPattern(p, host) {
			return false
		}
	}
	for _, p := range m.include {
		if matchHostPattern(p, host) {
			return true
		}
	}
	return false
}

func matchHostPattern(pattern, host string) bool {
	pattern = strings.ToLower(strings.TrimSpace(pattern))
	if pattern == "" {
		return false
	}
	if pattern == host {
		return true
	}
	if wildcard.Match(pattern, host) {
		return true
	}
	// "*.example.com" should also match "example.com" for Surge-like lists.
	if strings.HasPrefix(pattern, "*.") {
		suffix := pattern[1:] // ".example.com"
		if host == strings.TrimPrefix(pattern, "*.") || strings.HasSuffix(host, suffix) {
			return true
		}
	}
	return false
}
