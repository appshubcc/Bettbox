//go:build android && cgo

package main

import "C"
import (
	"context"
	bridge "core/dart-bridge"
	"core/platform"
	"core/state"
	"core/toolbox"
	t "core/tun"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/listener/sing_tun"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
	"golang.org/x/sync/semaphore"
	"net"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
	"unsafe"
)

type TunHandler struct {
	listener *sing_tun.Listener
	callback unsafe.Pointer

	limit *semaphore.Weighted
}

func (t *TunHandler) close() {
	_ = t.limit.Acquire(context.TODO(), 4)
	defer t.limit.Release(4)
	removeTunHook()
	if t.listener != nil {
		_ = t.listener.Close()
	}

	if t.callback != nil {
		releaseObject(t.callback)
	}
	t.callback = nil
	t.listener = nil
}

func (t *TunHandler) handleProtect(fd int) {
	_ = t.limit.Acquire(context.Background(), 1)
	defer t.limit.Release(1)

	cb := t.callback
	if cb == nil {
		return
	}

	Protect(cb, fd)
}

func (t *TunHandler) handleResolveProcess(source, target net.Addr) string {
	_ = t.limit.Acquire(context.Background(), 1)
	defer t.limit.Release(1)

	if t.listener == nil {
		return ""
	}
	var protocol int
	uid := -1
	switch source.Network() {
	case "udp", "udp4", "udp6":
		protocol = syscall.IPPROTO_UDP
	case "tcp", "tcp4", "tcp6":
		protocol = syscall.IPPROTO_TCP
	}
	if version < 29 {
		uid = platform.QuerySocketUidFromProcFs(source, target)
	}
	return ResolveProcess(t.callback, protocol, source.String(), target.String(), uid)
}

var (
	tunLock    sync.Mutex
	runTime    *time.Time
	errBlocked = errors.New("blocked")
	tunHandler atomic.Pointer[TunHandler]
)

func init() {
	dialer.DefaultSocketHook = func(network, address string, conn syscall.RawConn) error {
		if platform.ShouldBlockConnection() {
			return errBlocked
		}
		handler := tunHandler.Load()
		if handler != nil {
			return conn.Control(func(fd uintptr) {
				handler.handleProtect(int(fd))
			})
		}
		return nil
	}
}

func handleStopTun() {
	tunLock.Lock()
	defer tunLock.Unlock()
	runTime = nil
	handler := tunHandler.Swap(nil)
	if handler != nil {
		handler.close()
	}
	toolbox.FlushTrafficStats()
}

func handleStartTun(fd int, callback unsafe.Pointer) bool {
	handleStopTun()
	tunLock.Lock()
	defer tunLock.Unlock()
	now := time.Now()
	runTime = &now
	if fd != 0 {
		if currentConfig == nil {
			log.Warnln("[APP] handleStartTun called before setupConfig")
			runTime = nil
			releaseObject(callback)
			return false
		}
		handler := &TunHandler{
			callback: callback,
			limit:    semaphore.NewWeighted(4),
		}
		tunHandler.Store(handler)
		initTunHook()
		tunListener, _ := t.Start(fd, currentConfig.General.Tun.Device, currentConfig.General.Tun.Stack, currentConfig.General.Tun.DisableICMPForwarding, uint32(currentConfig.General.Tun.MTU), currentConfig.General.IPv6, currentConfig.General.Tun.CongestionController)
		if tunListener == nil {
			tunHandler.Store(nil)
			handler.close()
			runTime = nil
			return false
		}
		log.Infoln("TUN address: %v", tunListener.Address())
		handler.listener = tunListener
		closeConnections()
		closeIdleOutbounds(tunnel.Proxies(), tunnel.Providers())
		resolver.ResetConnection()
	}
	return true
}

func handleGetRunTime() string {
	if runTime == nil {
		return ""
	}
	return strconv.FormatInt(runTime.UnixMilli(), 10)
}

func initTunHook() {
	process.DefaultPackageNameResolver = func(metadata *constant.Metadata) (string, error) {
		src, dst := metadata.RawSrcAddr, metadata.RawDstAddr
		if src == nil || dst == nil {
			return "", process.ErrInvalidNetwork
		}
		handler := tunHandler.Load()
		if handler == nil {
			return "", errors.New("tun is closed")
		}
		return handler.handleResolveProcess(src, dst), nil
	}
}

func removeTunHook() {
	process.DefaultPackageNameResolver = nil
}

func handleGetAndroidVpnOptions() string {
	tunLock.Lock()
	defer tunLock.Unlock()
	if currentConfig == nil {
		log.Warnln("[APP] handleGetAndroidVpnOptions called before setupConfig")
		return ""
	}
	ipv6Address := ""
	if currentConfig.General.IPv6 {
		ipv6Address = state.DefaultIpv6Address
	}
	options := state.AndroidVpnOptions{
		Enable:                state.CurrentState.VpnProps.Enable,
		Port:                  currentConfig.General.MixedPort,
		Ipv4Address:           state.DefaultIpv4Address,
		Ipv6Address:           ipv6Address,
		AccessControl:         state.CurrentState.VpnProps.AccessControl,
		SystemProxy:           state.CurrentState.VpnProps.SystemProxy,
		AllowBypass:           state.CurrentState.VpnProps.AllowBypass,
		RouteAddress:          currentConfig.General.Tun.RouteAddress,
		RouteMode:             state.CurrentState.VpnProps.RouteMode,
		BypassDomain:          state.CurrentState.BypassDomain,
		DnsServerAddress:      state.GetDnsServerAddress(),
		DozeSuspend:           state.CurrentState.VpnProps.DozeSuspend,
		DisableIcmpForwarding: currentConfig.General.Tun.DisableICMPForwarding,
		Mtu:                   uint32(currentConfig.General.Tun.MTU),
	}
	data, err := json.Marshal(options)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleUpdateDns(value string) {
	go func() {
		defer func() {
			_ = recover()
		}()
		log.Infoln("[DNS] updateDns %s", value)
		dns.UpdateSystemDNS(strings.Split(value, ","))
		resolver.ResetConnection()
	}()
}

func handleGetCurrentProfileName() string {
	if state.CurrentState == nil {
		return ""
	}
	return state.CurrentState.CurrentProfileName
}

func nextHandle(action *Action, result ActionResult) bool {
	switch action.Method {
	case getAndroidVpnOptionsMethod:
		result.success(handleGetAndroidVpnOptions())
		return true
	case updateDnsMethod:
		data := action.Data.(string)
		handleUpdateDns(data)
		result.success(true)
		return true
	case getRunTimeMethod:
		result.success(handleGetRunTime())
		return true
	case getCurrentProfileNameMethod:
		result.success(handleGetCurrentProfileName())
		return true
	}
	return false
}

//export quickStart
func quickStart(initParamsChar *C.char, paramsChar *C.char, stateParamsChar *C.char, port C.longlong) {
	i := int64(port)
	paramsString := C.GoString(initParamsChar)
	bytes := []byte(C.GoString(paramsChar))
	stateParams := C.GoString(stateParamsChar)
	go func() {
		defer func() {
			if r := recover(); r != nil {
				bridge.SendToPort(i, fmt.Sprintf("panic: %v", r))
			}
		}()
		res := handleInitClash(paramsString)
		if res == false {
			bridge.SendToPort(i, "init error")
			return
		}
		handleSetState(stateParams)
		result, _ := json.Marshal(handleSetupConfig(bytes))
		bridge.SendToPort(i, string(result))
	}()
}

//export startTUN
func startTUN(fd C.int, callback unsafe.Pointer) (ok bool) {
	defer func() {
		if r := recover(); r != nil {
			log.Errorln("[APP] startTUN panic: %v", r)
			ok = false
		}
	}()
	return handleStartTun(int(fd), callback)
}

//export getRunTime
func getRunTime() *C.char {
	return C.CString(handleGetRunTime())
}

//export stopTun
func stopTun() {
	defer func() {
		_ = recover()
	}()
	handleStopTun()
}

//export getCurrentProfileName
func getCurrentProfileName() *C.char {
	return C.CString(handleGetCurrentProfileName())
}

//export getAndroidVpnOptions
func getAndroidVpnOptions() *C.char {
	return C.CString(handleGetAndroidVpnOptions())
}

//export setScreenState
func setScreenState(on C.int) {
	toolbox.SetTrafficScreenOn(on != 0)
}

//export setState
func setState(s *C.char) {
	defer func() {
		_ = recover()
	}()
	paramsString := C.GoString(s)
	handleSetState(paramsString)
}

//export updateDns
func updateDns(s *C.char) {
	dnsList := C.GoString(s)
	handleUpdateDns(dnsList)
}

//export networkChanged
func networkChanged() {
	defer func() {
		_ = recover()
	}()
	handleNetworkChanged()
}

func handleNetworkChanged() {
	if !isInit || !state.CurrentState.VpnProps.QuickResponse {
		return
	}
	log.Infoln("[APP] Network changed, resetting connections")
	closeConnections()
	closeIdleOutbounds(tunnel.Proxies(), tunnel.Providers())
	resolver.ResetConnection()
}
