package main

import (
	"net/netip"

	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	"go4.org/netipx"
)

func fakeIPPrefixes(cfg *config.Config) []netip.Prefix {
	dns := cfg.DNS
	if dns == nil || !dns.Enable || dns.EnhancedMode != C.DNSFakeIP {
		return nil
	}
	var prefixes []netip.Prefix
	if dns.FakeIPPool != nil && dns.FakeIPRange.IsValid() {
		prefixes = append(prefixes, dns.FakeIPRange.Masked())
	}
	if cfg.General.IPv6 && dns.FakeIPPool6 != nil && dns.FakeIPRange6.IsValid() {
		prefixes = append(prefixes, dns.FakeIPRange6.Masked())
	}
	return prefixes
}

func familyRouteSet(is4 bool, lists ...[]netip.Prefix) *netipx.IPSet {
	var builder netipx.IPSetBuilder
	found := false
	for _, list := range lists {
		for _, prefix := range list {
			if prefix.IsValid() && prefix.Addr().Is4() == is4 {
				builder.AddPrefix(prefix.Masked())
				found = true
			}
		}
	}
	if !found {
		return nil
	}
	set, err := builder.IPSet()
	if err != nil {
		return nil
	}
	return set
}

func excludeWithoutFakes(excludes []netip.Prefix, fakes []netip.Prefix) []netip.Prefix {
	overlap := false
	for _, exclude := range excludes {
		for _, fake := range fakes {
			if exclude.IsValid() && exclude.Overlaps(fake) {
				overlap = true
				break
			}
		}
		if overlap {
			break
		}
	}
	if !overlap {
		return excludes
	}
	var builder netipx.IPSetBuilder
	for _, exclude := range excludes {
		if exclude.IsValid() {
			builder.AddPrefix(exclude.Masked())
		}
	}
	for _, fake := range fakes {
		builder.RemovePrefix(fake)
	}
	set, err := builder.IPSet()
	if err != nil {
		return excludes
	}
	return set.Prefixes()
}

func routeFakeIP(cfg *config.Config) {
	if cfg == nil || cfg.General == nil {
		return
	}
	fakes := fakeIPPrefixes(cfg)
	if len(fakes) == 0 {
		return
	}
	tun := &cfg.General.Tun
	routeLists := [][]netip.Prefix{tun.RouteAddress}
	if !patchForAndroid {
		routeLists = append(routeLists, tun.Inet4RouteAddress, tun.Inet6RouteAddress)
	}
	for _, fake := range fakes {
		set := familyRouteSet(fake.Addr().Is4(), routeLists...)
		if set == nil || set.ContainsPrefix(fake) {
			continue
		}
		tun.RouteAddress = append(append([]netip.Prefix(nil), tun.RouteAddress...), fake)
		routeLists[0] = tun.RouteAddress
	}
	tun.RouteExcludeAddress = excludeWithoutFakes(tun.RouteExcludeAddress, fakes)
	if !patchForAndroid {
		tun.Inet4RouteExcludeAddress = excludeWithoutFakes(tun.Inet4RouteExcludeAddress, fakes)
		tun.Inet6RouteExcludeAddress = excludeWithoutFakes(tun.Inet6RouteExcludeAddress, fakes)
	}
}
