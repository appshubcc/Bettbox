package state

import "net/netip"

var DefaultIpv4Address = "198.51.100.1/30"
var DefaultDnsAddress = "198.51.100.2"
var DefaultIpv6Address = "fdfe:dcba:9876::1/126"

type AndroidVpnOptions struct {
	Enable                bool           `json:"enable"`
	Port                  int            `json:"port"`
	AccessControl         *AccessControl `json:"accessControl"`
	AllowBypass           bool           `json:"allowBypass"`
	SystemProxy           bool           `json:"systemProxy"`
	BypassDomain          []string       `json:"bypassDomain"`
	RouteAddress          []netip.Prefix `json:"routeAddress"`
	RouteMode             string         `json:"routeMode"`
	Ipv4Address           string         `json:"ipv4Address"`
	Ipv6Address           string         `json:"ipv6Address"`
	DnsServerAddress      string         `json:"dnsServerAddress"`
	DozeSuspend           bool           `json:"dozeSuspend"`
	DisableIcmpForwarding bool           `json:"disableIcmpForwarding"`
	Mtu                   uint32         `json:"mtu"`
}

type AccessControl struct {
	Enable     bool     `json:"enable"`
	Mode       string   `json:"mode"`
	AcceptList []string `json:"acceptList"`
	RejectList []string `json:"rejectList"`
}

type AndroidVpnRawOptions struct {
	Enable        bool           `json:"enable"`
	AccessControl *AccessControl `json:"accessControl"`
	AllowBypass   bool           `json:"allowBypass"`
	SystemProxy   bool           `json:"systemProxy"`
	RouteMode     string         `json:"routeMode"`
	DozeSuspend   bool           `json:"dozeSuspend"`
}

type State struct {
	VpnProps            AndroidVpnRawOptions `json:"vpn-props"`
	CurrentProfileName  string               `json:"current-profile-name"`
	OnlyStatisticsProxy bool                 `json:"only-statistics-proxy"`
	BypassDomain        []string             `json:"bypass-domain"`
}

var CurrentState = &State{
	OnlyStatisticsProxy: false,
	CurrentProfileName:  "",
}

func GetDnsServerAddress() string {
	return DefaultDnsAddress
}
