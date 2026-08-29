//go:build (android || ohos) && cgo

package tun

import "C"
import (
	"core/state"
	"github.com/metacubex/mihomo/constant"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"net"
	"net/netip"
)

type Props struct {
	Fd       int    `json:"fd"`
	Gateway  string `json:"gateway"`
	Gateway6 string `json:"gateway6"`
	Portal   string `json:"portal"`
	Portal6  string `json:"portal6"`
	Dns      string `json:"dns"`
	Dns6     string `json:"dns6"`
}

func Start(fd int, device string, stack constant.TUNStack, disableIcmpForwarding bool, mtu uint32, ipv6Enabled bool) (*sing_tun.Listener, error) {
	var prefix4 []netip.Prefix
	tempPrefix4, err := netip.ParsePrefix(state.DefaultIpv4Address)
	if err != nil {
		log.Errorln("startTUN error:", err)
		return nil, err
	}
	prefix4 = append(prefix4, tempPrefix4)
	var prefix6 []netip.Prefix
	if ipv6Enabled {
		tempPrefix6, err := netip.ParsePrefix(state.DefaultIpv6Address)
		if err != nil {
			log.Errorln("startTUN error:", err)
			return nil, err
		}
		prefix6 = append(prefix6, tempPrefix6)
	}

	var dnsHijack []string
	dnsHijack = append(dnsHijack, net.JoinHostPort(state.GetDnsServerAddress(), "53"))

	validMtu := mtu
	if validMtu < 1280 || validMtu > 65535 {
		validMtu = 1480
	}

	options := LC.Tun{
		Enable:                true,
		Device:                device,
		Stack:                 stack,
		DNSHijack:             dnsHijack,
		AutoRoute:             false,
		AutoDetectInterface:   false,
		Inet4Address:          prefix4,
		Inet6Address:          prefix6,
		MTU:                   validMtu,
		FileDescriptor:        fd,
		DisableICMPForwarding: disableIcmpForwarding,
	}

	listener, err := sing_tun.New(options, tunnel.Tunnel)

	if err != nil {
		log.Errorln("startTUN error:", err)
		return nil, err
	}

	return listener, nil
}
