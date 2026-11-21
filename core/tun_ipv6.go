package main

import (
	"cmp"
	"net"
	"net/netip"
	"os"
	"slices"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/sing-tun"
	"github.com/metacubex/sing/common/control"
)

var (
	ipv6MonitorOnce   sync.Once
	ipv6CheckChan     = make(chan struct{}, 1)
	ipv6FallbackLock  sync.Mutex
	ipv6FallbackTimer *time.Timer
	ipv6IfaceMonitor  atomic.Pointer[tun.DefaultInterfaceMonitor]
	currentTunInet6   []netip.Prefix
	ipv6FallbackDelay = 1500 * time.Millisecond
)

func isPublicIPv6(ip netip.Addr) bool {
	ip = ip.Unmap()
	return ip.Is6() && ip.IsGlobalUnicast() && !ip.IsPrivate()
}

func interfaceHasPublicIPv6(iface net.Interface) bool {
	if iface.Flags&net.FlagUp == 0 || iface.Flags&net.FlagLoopback != 0 {
		return false
	}
	addrs, err := iface.Addrs()
	if err != nil {
		return false
	}
	for _, addr := range addrs {
		if prefix, err := netip.ParsePrefix(addr.String()); err == nil && isPublicIPv6(prefix.Addr()) {
			return true
		}
	}
	return false
}

var hasOutboundIPv6 = func(interfaceName, tunDevice string) bool {
	if skip, _ := strconv.ParseBool(os.Getenv("SKIP_SYSTEM_IPV6_CHECK")); skip {
		return true
	}
	if interfaceName != "" {
		iface, err := net.InterfaceByName(interfaceName)
		if err != nil {
			return false
		}
		return interfaceHasPublicIPv6(*iface)
	}
	if monitorPtr := ipv6IfaceMonitor.Load(); monitorPtr != nil {
		if defaultIface := (*monitorPtr).DefaultInterface(); defaultIface != nil {
			iface, err := net.InterfaceByIndex(defaultIface.Index)
			if err != nil {
				return false
			}
			return interfaceHasPublicIPv6(*iface)
		}
	}
	ifaces, err := net.Interfaces()
	if err != nil {
		return false
	}
	for _, iface := range ifaces {
		if tunDevice != "" && iface.Name == tunDevice {
			continue
		}
		if interfaceHasPublicIPv6(iface) {
			return true
		}
	}
	return false
}

func cloneSortedPrefixes(prefixes []netip.Prefix) []netip.Prefix {
	if len(prefixes) == 0 {
		return nil
	}
	cloned := slices.Clone(prefixes)
	slices.SortFunc(cloned, func(a, b netip.Prefix) int {
		if c := a.Addr().Compare(b.Addr()); c != 0 {
			return c
		}
		return cmp.Compare(a.Bits(), b.Bits())
	})
	return cloned
}

func prepareRawTunIPv6(rawCfg *config.RawConfig) []netip.Prefix {
	if patchForAndroid || rawCfg == nil {
		return nil
	}
	tunInet6 := cloneSortedPrefixes(rawCfg.Tun.Inet6Address)
	if !rawCfg.IPv6 || !hasOutboundIPv6(rawCfg.Interface, rawCfg.Tun.Device) {
		rawCfg.DNS.FakeIPRange6 = ""
		rawCfg.Tun.Inet6Address = nil
	}
	return tunInet6
}

func syncTunInet6(cfg *config.Config, tunInet6 []netip.Prefix) bool {
	if patchForAndroid || cfg == nil {
		return false
	}
	var want []netip.Prefix
	if cfg.General.IPv6 && len(tunInet6) > 0 && hasOutboundIPv6(cfg.General.Interface, cfg.General.Tun.Device) {
		want = slices.Clone(tunInet6)
	}
	if slices.Equal(cloneSortedPrefixes(cfg.General.Tun.Inet6Address), want) {
		return false
	}
	cfg.General.Tun.Inet6Address = want
	return true
}

func notifyIPv6Check() {
	select {
	case ipv6CheckChan <- struct{}{}:
	default:
	}
}

func scheduleIPv6FallbackCheck() {
	ipv6FallbackLock.Lock()
	defer ipv6FallbackLock.Unlock()
	if ipv6FallbackTimer == nil {
		ipv6FallbackTimer = time.AfterFunc(ipv6FallbackDelay, notifyIPv6Check)
		return
	}
	ipv6FallbackTimer.Reset(ipv6FallbackDelay)
}

func startIPv6Monitor() {
	if patchForAndroid {
		return
	}
	ipv6MonitorOnce.Do(func() {
		monitor, err := tun.NewNetworkUpdateMonitor(log.SingLogger)
		if err != nil {
			log.Warnln("[APP] IPv6 monitor unavailable: %v", err)
			return
		}
		ifMonitor, err := tun.NewDefaultInterfaceMonitor(monitor, log.SingLogger, tun.DefaultInterfaceMonitorOptions{
			InterfaceFinder: sing_tun.DefaultInterfaceFinder,
		})
		if err != nil {
			log.Warnln("[APP] IPv6 interface monitor unavailable: %v", err)
			return
		}
		if err = monitor.Start(); err != nil {
			log.Warnln("[APP] IPv6 monitor start failed: %v", err)
			return
		}
		if err = ifMonitor.Start(); err != nil {
			_ = monitor.Close()
			log.Warnln("[APP] IPv6 interface monitor start failed: %v", err)
			return
		}
		ipv6IfaceMonitor.Store(&ifMonitor)
		ifMonitor.RegisterCallback(func(_ *control.Interface, _ int) {
			notifyIPv6Check()
		})
		monitor.RegisterCallback(scheduleIPv6FallbackCheck)
		go func() {
			for range ipv6CheckChan {
				syncRunningTunInet6()
			}
		}()
	})
}

func syncRunningTunInet6() {
	runLock.Lock()
	defer runLock.Unlock()
	if !isRunning || currentConfig == nil || !currentConfig.General.Tun.Enable {
		return
	}
	if !syncTunInet6(currentConfig, currentTunInet6) {
		return
	}
	if len(currentConfig.General.Tun.Inet6Address) > 0 {
		log.Infoln("[APP] Outbound IPv6 became available, recreating TUN")
	} else {
		log.Infoln("[APP] Outbound IPv6 became unavailable, recreating TUN")
	}
	listener.ReCreateTun(currentConfig.General.Tun, tunnel.Tunnel)
}
