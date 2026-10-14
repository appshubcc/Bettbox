package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/common/orderedmap"
	"github.com/metacubex/mihomo/common/structure"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

// Parent of the per-network node state dirs; must match tailscaleStateDir in
// lib/common/tailscale.dart.
const tailscaleStateDir = "bettbox-tailscale"

// Default proxy name, which the app's rules and DNS policy target; must match
// tailscaleProxyName in lib/common/tailscale.dart.
const tailscaleProxyName = "Tailscale"

// PatchTailscale is the app's Tailscale node: its proxy options, and the rules
// and DNS policy sending the user's entries to it.
type PatchTailscale struct {
	Proxy            map[string]any                      `json:"proxy"`
	Rules            []string                            `json:"rules"`
	NameserverPolicy *orderedmap.OrderedMap[string, any] `json:"nameserver-policy"`
	SkipDstAddress   []string                            `json:"skip-dst-address"`
	// The control server when a routed domain covers it; it must resolve via
	// the nameservers, as the node cannot ask itself for it.
	ControlHost string `json:"control-host"`
	// Domains resolved by DNS servers inside the tailnet.
	DnsDomains []string `json:"dns-domains"`

	// The proxy name patchTailscale chose.
	name string
}

// patchTailscale adds the app's Tailscale proxy and DNS policy, and returns
// its rules. They target tailscaleProxyName unless the profile already uses
// that name.
func patchTailscale(raw *config.RawConfig, params *PatchParams) []string {
	t := params.Tailscale
	if t == nil || len(t.Proxy) == 0 {
		return nil
	}
	taken := map[string]bool{"GLOBAL": true}
	for _, name := range protectedProxyNames {
		taken[name] = true
	}
	for _, item := range append(append([]map[string]any{}, raw.Proxy...), raw.ProxyGroup...) {
		if name, exist := item["name"]; exist && name != nil {
			taken[fmt.Sprint(name)] = true
		}
	}
	// Rules targeting a disabled group are rewritten to PASS.
	for _, name := range params.DisabledGroups {
		taken[name] = true
	}
	name := tailscaleProxyName
	for i := 2; taken[name]; i++ {
		name = fmt.Sprintf("%s-%d", tailscaleProxyName, i)
	}
	t.name = name

	proxy := make(map[string]any, len(t.Proxy)+1)
	for key, value := range t.Proxy {
		proxy[key] = value
	}
	proxy["name"] = name
	raw.Proxy = append(raw.Proxy, proxy)

	// Keep the node out of include-all groups so only its rules use it.
	// `filter` also skips health checks; a group with its own filter rarely
	// matches the name, so `exclude-filter` covers that case.
	for _, group := range raw.ProxyGroup {
		if group["include-all"] != true && group["include-all-proxies"] != true {
			continue
		}
		if filter, _ := group["filter"].(string); filter == "" {
			group["filter"] = "^(?!" + name + "$)"
		} else if exclude, _ := group["exclude-filter"].(string); exclude == "" {
			group["exclude-filter"] = "^" + name + "$"
		} else {
			group["exclude-filter"] = exclude + "`^" + name + "$"
		}
	}

	raw.Sniffer.SkipDstAddress = append(raw.Sniffer.SkipDstAddress, t.SkipDstAddress...)

	retarget := func(server string) string {
		if server == "tailscale://"+tailscaleProxyName {
			return "tailscale://" + name
		}
		if address, ok := strings.CutSuffix(server, "#"+tailscaleProxyName); ok {
			return address + "#" + name
		}
		return server
	}
	policy := orderedmap.New[string, any]()
	if t.NameserverPolicy != nil {
		for pair := t.NameserverPolicy.Oldest(); pair != nil; pair = pair.Next() {
			switch value := pair.Value.(type) {
			case string:
				policy.Set(pair.Key, retarget(value))
			case []any:
				servers := make([]any, len(value))
				for i, server := range value {
					servers[i] = retarget(fmt.Sprint(server))
				}
				policy.Set(pair.Key, servers)
			}
		}
	}
	ours := policy.Len()
	// An exact entry beats a routed `+.domain`. It goes after the `+.` keys:
	// inserting `+.x` also overwrites a bare `x`.
	controlHost := ""
	if t.ControlHost != "" && len(raw.DNS.NameServer) > 0 {
		controlHost = t.ControlHost
		policy.Set(controlHost, append([]string{}, raw.DNS.NameServer...))
	}
	if existing := raw.DNS.NameServerPolicy; existing != nil {
		for pair := existing.Oldest(); pair != nil; pair = pair.Next() {
			if _, exist := policy.Get(pair.Key); !exist {
				policy.Set(pair.Key, pair.Value)
			}
		}
	}
	if ours > 0 || controlHost != "" {
		raw.DNS.NameServerPolicy = policy
	}

	rules := make([]string, len(t.Rules))
	for i, rule := range t.Rules {
		parsed := parseRule(rule)
		if parsed.hasTarget && parsed.target == tailscaleProxyName {
			parsed.target = name
			rule = parsed.String()
		}
		rules[i] = rule
	}
	return rules
}

// stubTailscaleProxies swaps tailscale proxies for placeholders after checking
// their options. Building one registers its DNS client process-wide, which
// would replace the live node's, so configs that are only validated use this.
func stubTailscaleProxies(rawCfg *config.RawConfig) (bool, error) {
	decoder := structure.NewDecoder(structure.Option{TagName: "proxy", WeaklyTypedInput: true, KeyReplacer: structure.DefaultKeyReplacer})
	stubbed := false
	stub := func(proxy map[string]any) (map[string]any, error) {
		if proxy["type"] != "tailscale" {
			return proxy, nil
		}
		var option outbound.TailscaleOption
		if err := decoder.Decode(proxy, &option); err != nil {
			return nil, err
		}
		if option.StateDir != "" && !constant.Path.IsSafePath(constant.Path.Resolve(option.StateDir)) {
			return nil, constant.Path.ErrNotSafePath(option.StateDir)
		}
		stubbed = true
		return map[string]any{"name": proxy["name"], "type": "direct"}, nil
	}
	var err error
	for i, proxy := range rawCfg.Proxy {
		if rawCfg.Proxy[i], err = stub(proxy); err != nil {
			return false, fmt.Errorf("proxy %d: %w", i, err)
		}
	}
	for name, provider := range rawCfg.ProxyProvider {
		payload, _ := provider["payload"].([]any)
		for i, item := range payload {
			if proxy, ok := item.(map[string]any); ok {
				if payload[i], err = stub(proxy); err != nil {
					return false, fmt.Errorf("proxy provider %s: proxy %d: %w", name, i, err)
				}
			}
		}
	}
	return stubbed, nil
}

// handleStartTailscale starts the app's node, a no-op if it is running, by
// dialing through it; a login URL then arrives as a TailscaleAuthMessage.
func handleStartTailscale() {
	name, _ := appTailscaleProxy.Load().(string)
	proxy := tunnel.Proxies()[name]
	if name == "" || proxy == nil {
		return
	}
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
		defer cancel()
		_, _ = proxy.URLTest(ctx, constant.DefaultTestURL, nil)
	}()
}

// Name of the app's Tailscale proxy in the applied config ("" if none).
var appTailscaleProxy atomic.Value

// closeTailscaleProxies stops the running tsnet nodes. Replaced proxies are
// otherwise only closed by GC finalizers, so a reload could run two nodes on
// the same state dir.
func closeTailscaleProxies() {
	seen := map[constant.Proxy]struct{}{}
	closeProxy := func(p constant.Proxy) {
		if p == nil || p.Type() != constant.Tailscale {
			return
		}
		if _, ok := seen[p]; ok {
			return
		}
		seen[p] = struct{}{}
		_ = p.Close()
	}
	for _, p := range tunnel.Proxies() {
		closeProxy(p)
	}
	for _, pd := range tunnel.Providers() {
		for _, p := range pd.Proxies() {
			closeProxy(p)
		}
	}
}

// resetTailscaleState forgets a node identity by deleting its state dir,
// which must be inside tailscaleStateDir.
func resetTailscaleState(dir string) {
	root := constant.Path.Resolve(tailscaleStateDir)
	dir = constant.Path.Resolve(dir)
	if !strings.HasPrefix(dir, root+string(filepath.Separator)) {
		log.Warnln("[Tailscale] refusing to reset %s", dir)
		return
	}
	closeTailscaleProxies()
	if err := os.RemoveAll(dir); err != nil {
		log.Warnln("[Tailscale] reset state: %v", err)
	}
}

// notifyTailscaleAuth forwards tsnet's login URL, which it only logs at info
// level, so the app can show it whatever the log level is.
func notifyTailscaleAuth(payload string) {
	name, _ := appTailscaleProxy.Load().(string)
	if name == "" || !strings.HasPrefix(payload, "[Tailscale]("+name+") ") {
		return // not the app's node, e.g. a profile's own tailscale proxy
	}
	url := ""
	if _, after, ok := strings.Cut(payload, " go to: "); ok {
		url = strings.TrimSpace(after)
	} else if !strings.Contains(payload, "AuthLoop: state is ") {
		return
	}
	sendMessage(Message{Type: TailscaleAuthMessage, Data: url})
}

// resolveTailscaleByPolicy makes the app's Tailscale proxy resolve hosts under
// the tailnet DNS domains with mihomo's DNS, whose nameserver-policy sends
// them to DNS servers inside the tailnet (<ip>#<name>). The native outbound
// would re-resolve them via MagicDNS only; other hosts keep that path.
func resolveTailscaleByPolicy(proxies map[string]constant.Proxy, name string, domains []string) {
	if p, ok := proxies[name]; ok && p.Type() == constant.Tailscale && len(domains) > 0 {
		proxies[name] = adapter.NewProxy(policyResolving{p.Adapter(), domains})
	}
}

type policyResolving struct {
	constant.ProxyAdapter
	domains []string
}

func (p policyResolving) DialContext(ctx context.Context, metadata *constant.Metadata) (constant.Conn, error) {
	metadata, err := p.resolveHost(ctx, metadata)
	if err != nil {
		return nil, err
	}
	return p.ProxyAdapter.DialContext(ctx, metadata)
}

func (p policyResolving) ListenPacketContext(ctx context.Context, metadata *constant.Metadata) (constant.PacketConn, error) {
	metadata, err := p.resolveHost(ctx, metadata)
	if err != nil {
		return nil, err
	}
	pc, err := p.ProxyAdapter.ListenPacketContext(ctx, metadata)
	if err != nil {
		return nil, err
	}
	return policyResolvingPacketConn{pc, p}, nil
}

func (p policyResolving) covers(host string) bool {
	for _, domain := range p.domains {
		if host == domain || strings.HasSuffix(host, "."+domain) {
			return true
		}
	}
	return false
}

// resolveHost returns IP-addressed metadata for covered hosts, resolving them
// through mihomo's DNS if needed, so the outbound does not re-resolve them.
func (p policyResolving) resolveHost(ctx context.Context, metadata *constant.Metadata) (*constant.Metadata, error) {
	if metadata.Host == "" || !p.covers(metadata.Host) {
		return metadata, nil
	}
	resolved := metadata.Clone()
	if !resolved.Resolved() {
		ip, err := resolver.ResolveIP(ctx, resolved.Host)
		if err != nil {
			return nil, err
		}
		resolved.DstIP = ip
	}
	resolved.Host = ""
	return resolved, nil
}

type policyResolvingPacketConn struct {
	constant.PacketConn
	policy policyResolving
}

func (pc policyResolvingPacketConn) ResolveUDP(ctx context.Context, metadata *constant.Metadata) error {
	if !pc.policy.covers(metadata.Host) {
		return pc.PacketConn.ResolveUDP(ctx, metadata)
	}
	if metadata.Resolved() {
		return nil
	}
	ip, err := resolver.ResolveIP(ctx, metadata.Host)
	if err != nil {
		return err
	}
	metadata.DstIP = ip
	return nil
}
