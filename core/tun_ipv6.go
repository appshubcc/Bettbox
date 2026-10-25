package main

import (
	"net"
	"net/netip"
	"sync"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/sing-tun"
)

var (
	ipv6MonitorOnce sync.Once
	ipv6CheckChan   = make(chan struct{}, 1)
)

var hasGlobalIPv6 = func() bool {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return false
	}
	for _, addr := range addrs {
		if prefix, err := netip.ParsePrefix(addr.String()); err == nil {
			if ip := prefix.Addr().Unmap(); ip.Is6() && ip.IsGlobalUnicast() {
				return true
			}
		}
	}
	return false
}

func ensureTunInet6(cfg *config.Config) {
	if patchForAndroid || len(cfg.General.Tun.Inet6Address) > 0 || !hasGlobalIPv6() {
		return
	}
	cfg.General.Tun.Inet6Address = config.DefaultRawConfig().Tun.Inet6Address
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
		monitor.RegisterCallback(func() {
			select {
			case ipv6CheckChan <- struct{}{}:
			default:
			}
		})
		if err = monitor.Start(); err != nil {
			log.Warnln("[APP] IPv6 monitor start failed: %v", err)
			return
		}
		go func() {
			for range ipv6CheckChan {
				ensureRunningTunInet6()
			}
		}()
	})
}

func ensureRunningTunInet6() {
	runLock.Lock()
	defer runLock.Unlock()
	if !isRunning || currentConfig == nil {
		return
	}
	general := currentConfig.General
	if !general.Tun.Enable || len(general.Tun.Inet6Address) > 0 {
		return
	}
	ensureTunInet6(currentConfig)
	if len(general.Tun.Inet6Address) == 0 {
		return
	}
	log.Infoln("[APP] Global IPv6 became available, recreating TUN")
	listener.ReCreateTun(general.Tun, tunnel.Tunnel)
}
