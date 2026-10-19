package main

import (
	b "bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/inbound"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/batch"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/geodata"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/route"
	"github.com/metacubex/mihomo/listener"
	LC "github.com/metacubex/mihomo/listener/config"
	"github.com/metacubex/mihomo/log"
	rp "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
	"go4.org/netipx"
	"net"
	"net/netip"
	"os"
	"runtime"
	"runtime/debug"
	"strings"
	"sync"
	"time"
)

var (
	currentConfig    *config.Config
	currentRawConfig *config.RawConfig
	version          = 0
	isRunning        = false
	runLock          sync.Mutex
	mBatch, _        = batch.New[bool](context.Background(), batch.WithConcurrencyNum[bool](50))
)

type ExternalProviders []ExternalProvider

func (a ExternalProviders) Len() int           { return len(a) }
func (a ExternalProviders) Less(i, j int) bool { return a[i].Name < a[j].Name }
func (a ExternalProviders) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }

func getExternalProvidersRaw() map[string]cp.Provider {
	eps := make(map[string]cp.Provider)
	for n, p := range tunnel.Providers() {
		eps[n] = p
	}
	for n, p := range tunnel.RuleProviders() {
		eps[n] = p
	}
	return eps
}

func toExternalProvider(p cp.Provider) (*ExternalProvider, error) {
	switch p := p.(type) {
	case *provider.ProxySetProvider:
		return &ExternalProvider{
			Name:             p.Name(),
			Type:             p.Type().String(),
			VehicleType:      p.VehicleType().String(),
			Count:            p.Count(),
			UpdateAt:         p.UpdatedAt(),
			Path:             p.Vehicle().Path(),
			SubscriptionInfo: p.GetSubscriptionInfo(),
			Proxies:          p.Proxies(),
		}, nil
	case *provider.InlineProvider:
		return &ExternalProvider{
			Name:             p.Name(),
			Type:             p.Type().String(),
			VehicleType:      p.VehicleType().String(),
			Count:            p.Count(),
			UpdateAt:         time.Now(),
			Path:             "",
			SubscriptionInfo: nil,
			Proxies:          p.Proxies(),
		}, nil
	case *rp.RuleSetProvider:
		return &ExternalProvider{
			Name:        p.Name(),
			Type:        p.Type().String(),
			VehicleType: p.VehicleType().String(),
			Count:       p.Count(),
			UpdateAt:    p.UpdatedAt(),
			Path:        p.Vehicle().Path(),
		}, nil
	default:
		return nil, errors.New("not external provider")
	}
}

func sideUpdateExternalProvider(p cp.Provider, bytes []byte) error {
	switch p := p.(type) {
	case *provider.ProxySetProvider:
		_, _, err := p.SideUpdate(bytes)
		return err
	case *provider.InlineProvider:
		return nil
	case *rp.RuleSetProvider:
		_, _, err := p.SideUpdate(bytes)
		return err
	default:
		return errors.New("not external provider")
	}
}

func updateListeners() {
	if !isRunning {
		return
	}
	if currentConfig == nil {
		return
	}
	listeners := currentConfig.Listeners
	general := currentConfig.General
	listener.PatchInboundListeners(listeners, tunnel.Tunnel, true)
	listener.SetAllowLan(general.AllowLan)
	inbound.SetSkipAuthPrefixes(general.SkipAuthPrefixes)
	inbound.SetAllowedIPs(general.LanAllowedIPs)
	inbound.SetDisAllowedIPs(general.LanDisAllowedIPs)
	listener.SetBindAddress(general.BindAddress)
	listener.ReCreateHTTP(general.Port, tunnel.Tunnel)
	listener.ReCreateSocks(general.SocksPort, tunnel.Tunnel)
	listener.ReCreateRedir(general.RedirPort, tunnel.Tunnel)
	listener.ReCreateTProxy(general.TProxyPort, tunnel.Tunnel)
	listener.ReCreateMixed(general.MixedPort, tunnel.Tunnel)
	listener.ReCreateShadowSocks(general.ShadowSocksConfig, tunnel.Tunnel)
	listener.ReCreateVmess(general.VmessConfig, tunnel.Tunnel)
	listener.ReCreateTuic(general.TuicServer, tunnel.Tunnel)
	if !features.Android {
		listener.ReCreateTun(keepConnectedSubnetsExcluded(general.Tun), tunnel.Tunnel)
	}
}

// keepConnectedSubnetsExcluded stops macOS TUN from installing a route equal
// to a connected subnet (e.g. a Tailscale subnet route while on that LAN): the
// darwin route add fails with EEXIST and takes TUN down. It mirrors sing-tun's
// BuildAutoRouteRanges and only re-excludes such exact matches.
func keepConnectedSubnetsExcluded(tun LC.Tun) LC.Tun {
	if runtime.GOOS != "darwin" || !tun.Enable || !tun.AutoRoute || len(tun.RouteExcludeAddress) == 0 {
		return tun
	}
	var builder netipx.IPSetBuilder
	if len(tun.RouteAddress) > 0 {
		for _, prefix := range tun.RouteAddress {
			builder.AddPrefix(prefix)
		}
	} else {
		builder.AddPrefix(netip.MustParsePrefix("0.0.0.0/0"))
		builder.RemovePrefix(netip.MustParsePrefix("0.0.0.0/8"))
		builder.AddPrefix(netip.MustParsePrefix("::/0"))
		builder.RemovePrefix(netip.MustParsePrefix("::/8"))
	}
	for _, prefix := range tun.RouteExcludeAddress {
		builder.RemovePrefix(prefix)
	}
	routeSet, err := builder.IPSet()
	if err != nil {
		return tun
	}
	routes := map[netip.Prefix]bool{}
	for _, prefix := range routeSet.Prefixes() {
		routes[prefix] = true
	}
	ifaces, err := net.Interfaces()
	if err != nil {
		return tun
	}
	exclude := append([]netip.Prefix(nil), tun.RouteExcludeAddress...)
	for _, iface := range ifaces {
		if iface.Flags&net.FlagUp == 0 || iface.Flags&net.FlagLoopback != 0 {
			continue
		}
		addrs, _ := iface.Addrs()
		for _, addr := range addrs {
			ipNet, ok := addr.(*net.IPNet)
			if !ok {
				continue
			}
			ip, ok := netip.AddrFromSlice(ipNet.IP)
			if !ok {
				continue
			}
			ones, bits := ipNet.Mask.Size()
			if bits == 128 && ip.Unmap().Is4() {
				ones -= 96
			}
			prefix := netip.PrefixFrom(ip.Unmap(), ones).Masked()
			if routes[prefix] {
				exclude = append(exclude, prefix)
				delete(routes, prefix)
			}
		}
	}
	tun.RouteExcludeAddress = exclude
	return tun
}

func stopListeners() {
	listener.StopListener()
}

func patchSelectGroup(mapping map[string]string) {
	for name, proxy := range tunnel.Proxies() {
		outbound, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}

		selector, ok := outbound.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			continue
		}

		selected, exist := mapping[name]
		if !exist {
			continue
		}

		selector.ForceSet(selected)
	}
}

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		TestURL:     "https://g.cn/generate_204",
		SelectedMap: map[string]string{},
	}
}

func readFile(path string) ([]byte, error) {
	return os.ReadFile(path)
}

func updateConfig(params *UpdateParams) {
	runLock.Lock()
	defer runLock.Unlock()
	if currentConfig == nil {
		log.Infoln("[APP] updateConfig called before setupConfig")
		return
	}
	general := currentConfig.General
	wasDebug := general.LogLevel == log.DEBUG
	if params.MixedPort != nil {
		general.MixedPort = *params.MixedPort
	}
	if params.Sniffing != nil {
		general.Sniffing = *params.Sniffing
		tunnel.SetSniffing(general.Sniffing)
	}
	if params.FindProcessMode != nil {
		general.FindProcessMode = *params.FindProcessMode
		tunnel.SetFindProcessMode(general.FindProcessMode)
	}
	if params.TCPConcurrent != nil {
		general.TCPConcurrent = *params.TCPConcurrent
		dialer.SetTcpConcurrent(general.TCPConcurrent)
	}
	if params.Interface != nil {
		general.Interface = *params.Interface
		dialer.DefaultInterface.Store(general.Interface)
	}
	if params.UnifiedDelay != nil {
		general.UnifiedDelay = *params.UnifiedDelay
		adapter.UnifiedDelay.Store(general.UnifiedDelay)
	}
	if params.Mode != nil {
		general.Mode = *params.Mode
		tunnel.SetMode(general.Mode)
	}
	if params.LogLevel != nil {
		general.LogLevel = *params.LogLevel
		log.SetLevel(general.LogLevel)
	}
	if params.IPv6 != nil {
		general.IPv6 = *params.IPv6
		resolver.DisableIPv6 = !general.IPv6
	}
	if params.ExternalController != nil {
		currentConfig.Controller.ExternalController = *params.ExternalController
	}

	isDebug := general.LogLevel == log.DEBUG
	needRecreateServer := params.ExternalController != nil ||
		(params.LogLevel != nil && isDebug != wasDebug)

	if needRecreateServer {
		route.ReCreateServer(&route.Config{
			Addr:           currentConfig.Controller.ExternalController,
			TLSAddr:        currentConfig.Controller.ExternalControllerTLS,
			UnixAddr:       currentConfig.Controller.ExternalControllerUnix,
			PipeAddr:       currentConfig.Controller.ExternalControllerPipe,
			Secret:         currentConfig.Controller.Secret,
			Certificate:    currentConfig.TLS.Certificate,
			PrivateKey:     currentConfig.TLS.PrivateKey,
			ClientAuthType: currentConfig.TLS.ClientAuthType,
			ClientAuthCert: currentConfig.TLS.ClientAuthCert,
			EchKey:         currentConfig.TLS.EchKey,
			DohServer:      currentConfig.Controller.ExternalDohServer,
			IsDebug:        isDebug,
			Cors: route.Cors{
				AllowOrigins:        currentConfig.Controller.Cors.AllowOrigins,
				AllowPrivateNetwork: currentConfig.Controller.Cors.AllowPrivateNetwork,
			},
		})
	}

	if params.Tun != nil {
		general.Tun.Enable = params.Tun.Enable
		general.Tun.AutoRoute = *params.Tun.AutoRoute
		if params.Tun.AutoRedirect != nil {
			general.Tun.AutoRedirect = *params.Tun.AutoRedirect
		}
		general.Tun.Device = *params.Tun.Device
		general.Tun.RouteAddress = *params.Tun.RouteAddress
		if params.Tun.RouteExcludeAddress != nil {
			general.Tun.RouteExcludeAddress = *params.Tun.RouteExcludeAddress
		}
		if params.Tun.StrictRoute != nil {
			general.Tun.StrictRoute = *params.Tun.StrictRoute
		}
		general.Tun.DNSHijack = *params.Tun.DNSHijack
		general.Tun.Stack = *params.Tun.Stack
		general.Tun.DisableICMPForwarding = *params.Tun.DisableICMPForwarding
		if params.Tun.CongestionController != nil {
			general.Tun.CongestionController = *params.Tun.CongestionController
		}
	}

	updateListeners()
}

var (
	mmdbUnloaded bool
	asnUnloaded  bool
)

func checkActiveGeoUsage() (hasMMDB, hasSite, hasASN bool) {
	for _, r := range tunnel.Rules() {
		if r == nil {
			continue
		}
		switch r.RuleType() {
		case constant.GEOIP, constant.SrcGEOIP:
			hasMMDB = true
		case constant.GEOSITE:
			hasSite = true
		case constant.IPASN, constant.SrcIPASN:
			hasASN = true
		case constant.AND, constant.OR, constant.NOT, constant.SubRules:
			payload := strings.ToUpper(r.Payload())
			if strings.Contains(payload, "(GEOIP,") || strings.Contains(payload, "(SRCGEOIP,") {
				hasMMDB = true
			}
			if strings.Contains(payload, "(GEOSITE,") {
				hasSite = true
			}
			if strings.Contains(payload, "(IPASN,") || strings.Contains(payload, "(SRCIPASN,") {
				hasASN = true
			}
		}
		if hasMMDB && hasSite && hasASN {
			return
		}
	}

	if currentRawConfig != nil {
		if !hasSite && currentRawConfig.DNS.Enable && currentRawConfig.DNS.NameServerPolicy != nil {
			for pair := currentRawConfig.DNS.NameServerPolicy.Oldest(); pair != nil; pair = pair.Next() {
				if strings.HasPrefix(strings.ToLower(pair.Key), "geosite:") {
					hasSite = true
					break
				}
			}
		}
		if !hasMMDB && currentRawConfig.DNS.Enable && len(currentRawConfig.DNS.Fallback) > 0 && currentRawConfig.DNS.FallbackFilter.GeoIP {
			hasMMDB = true
		}
		if !hasSite && currentRawConfig.DNS.Enable && len(currentRawConfig.DNS.Fallback) > 0 && len(currentRawConfig.DNS.FallbackFilter.GeoSite) > 0 {
			hasSite = true
		}
		if !hasSite && currentRawConfig.Sniffer.Enable {
			for _, d := range currentRawConfig.Sniffer.ForceDomain {
				if strings.HasPrefix(strings.ToLower(d), "geosite:") {
					hasSite = true
					break
				}
			}
			if !hasSite {
				for _, d := range currentRawConfig.Sniffer.SkipDomain {
					if strings.HasPrefix(strings.ToLower(d), "geosite:") {
						hasSite = true
						break
					}
				}
			}
		}
	}
	return
}

func tryUnloadGeoData() {
	hasMMDB, _, hasASN := checkActiveGeoUsage()

	if hasMMDB {
		mmdbUnloaded = false
	} else if !mmdbUnloaded && geodata.GeoIpEnable() {
		if _, err := os.Stat(constant.Path.MMDB()); err == nil {
			if reader := mmdb.IPInstance().Reader; reader != nil {
				_ = reader.Close()
			}
			mmdb.ReloadIP()
			mmdbUnloaded = true
		}
	}

	if hasASN {
		asnUnloaded = false
	} else if !asnUnloaded && geodata.ASNEnable() {
		if _, err := os.Stat(constant.Path.ASN()); err == nil {
			if reader := mmdb.ASNInstance().Reader; reader != nil {
				_ = reader.Close()
			}
			mmdb.ReloadASN()
			asnUnloaded = true
		}
	}
}

type preparedSetup struct {
	key    string
	rawCfg *config.RawConfig
	cfg    *config.Config
	global string
	expire time.Time
	reused bool
	// The app's Tailscale proxy and its tailnet DNS domains, and the
	// tailscale:// clients the parse registered (see parseRawConfigStaged).
	tailscale           string
	tailscaleDnsDomains []string
	tailscaleDns        *dns.TailscaleStage
}

var (
	preparedSetupLock  sync.Mutex
	lastPreparedSetup  *preparedSetup
	preparedSetupLimit = time.Minute
)

func storePreparedSetup(prepared *preparedSetup) {
	if prepared.key == "" {
		return
	}
	prepared.expire = time.Now().Add(preparedSetupLimit)
	preparedSetupLock.Lock()
	lastPreparedSetup = prepared
	preparedSetupLock.Unlock()
}

func takePreparedSetup(key string) *preparedSetup {
	preparedSetupLock.Lock()
	defer preparedSetupLock.Unlock()
	prepared := lastPreparedSetup
	lastPreparedSetup = nil
	if prepared == nil || prepared.key != key || time.Now().After(prepared.expire) {
		return nil
	}
	prepared.reused = true
	return prepared
}

func setupKey(params *SetupParams, profile []byte) string {
	patch, err := json.Marshal(params.Patch)
	if err != nil {
		return ""
	}
	hash := sha256.New()
	hash.Write(profile)
	hash.Write([]byte{0})
	hash.Write(patch)
	hash.Write([]byte{0})
	hash.Write([]byte(params.AgeSecretKey))
	hash.Write([]byte{0})
	hash.Write([]byte(params.TestURL))
	if params.OverrideTestUrl {
		hash.Write([]byte{1})
	}
	return hex.EncodeToString(hash.Sum(nil))
}

func loadSetupConfig(params *SetupParams) (*config.RawConfig, string, string, error) {
	if params.ScriptedConfig != "" {
		rawCfg, global, err := loadPatchedConfig(params)
		return rawCfg, global, "", err
	}
	if params.ProfilePath == "" {
		return nil, "", "", errors.New("profile path is empty")
	}
	buf, err := readFile(params.ProfilePath)
	if err != nil {
		return nil, "", "", err
	}
	key := setupKey(params, buf)
	rawCfg, err := parseProfile(buf, params.AgeSecretKey)
	if err != nil || params.Patch == nil {
		return rawCfg, "", key, err
	}
	global, err := applyPatch(rawCfg, params.Patch)
	return rawCfg, global, key, err
}

func prepareSetup(params *SetupParams) (*preparedSetup, error) {
	if params.ScriptedConfig == "" && params.ProfilePath != "" {
		buf, err := readFile(params.ProfilePath)
		if err != nil {
			return nil, err
		}
		if prepared := takePreparedSetup(setupKey(params, buf)); prepared != nil {
			return prepared, nil
		}
	} else {
		takePreparedSetup("")
	}
	rawCfg, global, key, err := loadSetupConfig(params)
	if err != nil {
		return nil, err
	}

	if params.OverrideTestUrl && rawCfg.ProxyGroup != nil {
		for _, group := range rawCfg.ProxyGroup {
			group["url"] = params.TestURL
		}
	}

	cfg, tailscaleDns, err := parseRawConfigStaged(rawCfg)
	if err != nil {
		return nil, err
	}
	prepared := &preparedSetup{key: key, rawCfg: rawCfg, cfg: cfg, global: global, tailscaleDns: tailscaleDns}
	if params.Patch != nil && params.Patch.Tailscale != nil {
		prepared.tailscale = params.Patch.Tailscale.name
		prepared.tailscaleDnsDomains = params.Patch.Tailscale.DnsDomains
	}
	return prepared, nil
}

func setupConfig(params *SetupParams) (string, error) {
	runLock.Lock()
	defer runLock.Unlock()

	constant.DefaultTestURL = params.TestURL

	prepareStart := time.Now()
	prepared, err := prepareSetup(params)
	if err != nil {
		return "", err
	}
	preloadBundledRuleSets(prepared.rawCfg)
	applyStart := time.Now()
	// The new tailscale nodes become reachable only once the old ones,
	// which may use the same state dirs, are closed.
	closeTailscaleProxies()
	prepared.tailscaleDns.Commit()
	// No network uses these any more, and their old nodes are closed now.
	for _, dir := range params.ResetTailscaleDirs {
		resetTailscaleState(dir)
	}
	resolveTailscaleByPolicy(prepared.cfg.Proxies, prepared.tailscale, prepared.tailscaleDnsDomains)
	storeAppTailscale(prepared.tailscale, prepared.cfg.Proxies)
	currentConfig = prepared.cfg
	currentRawConfig = prepared.rawCfg
	hub.ApplyConfig(currentConfig)
	if prepared.tailscale != "" {
		requestTailscaleAuthCheck()
	}
	resetGroupShapes()
	selectedMap := params.SelectedMap
	if prepared.global != "" {
		selectedMap = make(map[string]string, len(params.SelectedMap)+1)
		for name, proxy := range params.SelectedMap {
			selectedMap[name] = proxy
		}
		selectedMap["GLOBAL"] = prepared.global
	}
	patchSelectGroup(selectedMap)
	updateListeners()
	tryUnloadGeoData()
	runtime.GC()
	debug.FreeOSMemory()
	schedulePermissionSync()
	log.Infoln(
		"[APP] setup config: prepare %s (reused: %t), apply %s",
		applyStart.Sub(prepareStart).Round(time.Millisecond),
		prepared.reused,
		time.Since(applyStart).Round(time.Millisecond),
	)
	return prepared.global, nil
}

func UnmarshalJson(data []byte, v any) error {
	decoder := json.NewDecoder(b.NewReader(data))
	decoder.UseNumber()
	err := decoder.Decode(v)
	return err
}
