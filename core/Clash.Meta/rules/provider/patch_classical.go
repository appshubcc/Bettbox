package provider

import (
	"strings"

	"github.com/metacubex/mihomo/component/cidr"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/rules/common"
)

type classicalSegment struct {
	rule      C.Rule
	domains   map[string]struct{}
	suffixes  map[string]struct{}
	ipcidr    *cidr.IpCidrSet
	src       bool
	noResolve bool
}

func (s *classicalSegment) matchHost(host string) bool {
	if _, ok := s.domains[host]; ok {
		return true
	}
	if len(s.suffixes) == 0 {
		return false
	}
	if _, ok := s.suffixes[host]; ok {
		return true
	}
	for i := 0; i < len(host); i++ {
		if host[i] == '.' {
			if _, ok := s.suffixes[host[i+1:]]; ok {
				return true
			}
		}
	}
	return false
}

func (s *classicalSegment) matchIP(metadata *C.Metadata, helper C.RuleMatchHelper) bool {
	if !s.noResolve && !s.src && helper.ResolveIP != nil {
		helper.ResolveIP()
	}
	ip := metadata.DstIP
	if s.src {
		ip = metadata.SrcIP
	}
	return ip.IsValid() && s.ipcidr.IsContain(ip)
}

func (c *classicalStrategy) matchSegments(metadata *C.Metadata, helper C.RuleMatchHelper) bool {
	host, hostReady := "", false
	for i := range c.segments {
		s := &c.segments[i]
		switch {
		case s.rule != nil:
			if m, _ := s.rule.Match(metadata, helper); m {
				return true
			}
		case s.ipcidr != nil:
			if s.matchIP(metadata, helper) {
				return true
			}
		default:
			if !hostReady {
				host = strings.ToLower(metadata.RuleHost())
				hostReady = true
			}
			if s.matchHost(host) {
				return true
			}
		}
	}
	return false
}

func (c *classicalStrategy) hostSegment() *classicalSegment {
	if n := len(c.segments); n > 0 {
		if s := &c.segments[n-1]; s.rule == nil && s.ipcidr == nil {
			return s
		}
	}
	c.segments = append(c.segments, classicalSegment{})
	return &c.segments[len(c.segments)-1]
}

func (c *classicalStrategy) ipSegment(src, noResolve bool) *classicalSegment {
	if n := len(c.segments); n > 0 {
		if s := &c.segments[n-1]; s.ipcidr != nil && s.src == src && s.noResolve == noResolve {
			return s
		}
	}
	c.segments = append(c.segments, classicalSegment{ipcidr: cidr.NewIpCidrSet(), src: src, noResolve: noResolve})
	return &c.segments[len(c.segments)-1]
}

func (c *classicalStrategy) buildSegments() {
	for _, rule := range c.rules {
		switch r := rule.(type) {
		case *common.Domain:
			s := c.hostSegment()
			if s.domains == nil {
				s.domains = map[string]struct{}{}
			}
			s.domains[r.Payload()] = struct{}{}
		case *common.DomainSuffix:
			s := c.hostSegment()
			if s.suffixes == nil {
				s.suffixes = map[string]struct{}{}
			}
			s.suffixes[r.Payload()] = struct{}{}
		case *common.IPCIDR:
			prefix, src, noResolve := r.Options()
			_ = c.ipSegment(src, noResolve).ipcidr.AddIpCidr(prefix)
		default:
			c.segments = append(c.segments, classicalSegment{rule: rule})
		}
	}
	for i := range c.segments {
		if s := c.segments[i].ipcidr; s != nil {
			_ = s.Merge()
		}
	}
	c.rules = nil
}
