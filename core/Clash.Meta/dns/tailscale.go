package dns

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"

	D "github.com/miekg/dns"
)

type tailscaleDNSClient struct {
	name string
}

type tailscaleResolverEntry struct {
	id           uint64
	client       dnsClient
	fromProvider bool
}

var (
	tailscaleResolverID atomic.Uint64
	tailscaleResolverMu sync.RWMutex
	tailscaleResolvers  = map[string]tailscaleResolverEntry{}
	tailscaleStage      *TailscaleStage
)

var _ dnsClient = (*tailscaleDNSClient)(nil)

// TailscaleStage holds the tailscale:// clients registered while a config was
// parsed, so that parsing never takes over the names of the running proxies.
type TailscaleStage struct {
	entries []*stagedTailscaleClient
	done    bool
}

type stagedTailscaleClient struct {
	name    string
	entry   tailscaleResolverEntry
	removed bool
}

// StageTailscaleDnsClients runs parse with registrations held in the returned
// stage until its Commit. Calls must not overlap.
func StageTailscaleDnsClients(parse func() error) (*TailscaleStage, error) {
	stage := &TailscaleStage{}
	tailscaleResolverMu.Lock()
	tailscaleStage = stage
	tailscaleResolverMu.Unlock()
	defer func() {
		tailscaleResolverMu.Lock()
		tailscaleStage = nil
		tailscaleResolverMu.Unlock()
	}()
	return stage, parse()
}

// Commit registers the staged clients whose proxies are not closed yet.
func (s *TailscaleStage) Commit() {
	if s == nil {
		return
	}
	tailscaleResolverMu.Lock()
	defer tailscaleResolverMu.Unlock()
	if s.done {
		return
	}
	s.done = true
	for _, staged := range s.entries {
		if !staged.removed {
			registerTailscaleDnsClientLocked(staged.name, staged.entry)
		}
	}
}

// RegisterTailscaleDnsClient serves tailscale://name with client. A proxy from
// a proxy provider never replaces a top-level proxy's client: like rules and
// "#name" nameservers, tailscale://name means the top-level proxy.
func RegisterTailscaleDnsClient(name string, client dnsClient, fromProvider bool) func() {
	entry := tailscaleResolverEntry{
		id:           tailscaleResolverID.Add(1),
		client:       client,
		fromProvider: fromProvider,
	}
	var staged *stagedTailscaleClient
	tailscaleResolverMu.Lock()
	if tailscaleStage != nil {
		staged = &stagedTailscaleClient{name: name, entry: entry}
		tailscaleStage.entries = append(tailscaleStage.entries, staged)
	} else {
		registerTailscaleDnsClientLocked(name, entry)
	}
	tailscaleResolverMu.Unlock()

	return func() {
		tailscaleResolverMu.Lock()
		if staged != nil {
			staged.removed = true
		}
		if current, ok := tailscaleResolvers[name]; ok && current.id == entry.id {
			delete(tailscaleResolvers, name)
		}
		tailscaleResolverMu.Unlock()
	}
}

func registerTailscaleDnsClientLocked(name string, entry tailscaleResolverEntry) {
	if current, ok := tailscaleResolvers[name]; ok && entry.fromProvider && !current.fromProvider {
		return
	}
	tailscaleResolvers[name] = entry
}

func newTailscaleClient(name string) *tailscaleDNSClient {
	return &tailscaleDNSClient{name: name}
}

func (c *tailscaleDNSClient) Address() string {
	return "tailscale://" + c.name
}

func (c *tailscaleDNSClient) ExchangeContext(ctx context.Context, m *D.Msg) (*D.Msg, error) {
	tailscaleResolverMu.RLock()
	entry, ok := tailscaleResolvers[c.name]
	tailscaleResolverMu.RUnlock()
	if !ok || entry.client == nil {
		return nil, fmt.Errorf("proxy %q does not provide Tailscale DNS", c.name)
	}
	return entry.client.ExchangeContext(ctx, m)
}

func (c *tailscaleDNSClient) ResetConnection() {}
