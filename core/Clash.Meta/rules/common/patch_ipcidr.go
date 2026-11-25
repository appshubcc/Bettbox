package common

import "net/netip"

func (i *IPCIDR) Options() (prefix netip.Prefix, isSourceIP bool, noResolveIP bool) {
	return i.ipnet, i.isSourceIP, i.noResolveIP
}
