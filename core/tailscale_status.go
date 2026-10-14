//go:build with_gvisor && !no_tailscale

package main

import (
	"context"
	"encoding/json"
	"reflect"
	"sort"
	"strings"
	"time"
	"unsafe"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/tailscale/ipn/ipnstate"
	"github.com/metacubex/tailscale/tsnet"
)

type tailscalePeer struct {
	Name           string   `json:"name"`
	DNSName        string   `json:"dnsName,omitempty"`
	OS             string   `json:"os,omitempty"`
	IPs            []string `json:"ips,omitempty"`
	Routes         []string `json:"routes,omitempty"` // subnet routes it serves
	Online         bool     `json:"online"`
	ExitNode       bool     `json:"exitNode,omitempty"` // the exit node in use
	ExitNodeOption bool     `json:"exitNodeOption,omitempty"`
	Direct         bool     `json:"direct,omitempty"`
	Relay          string   `json:"relay,omitempty"` // DERP region
	RxBytes        int64    `json:"rxBytes,omitempty"`
	TxBytes        int64    `json:"txBytes,omitempty"`
}

type tailscaleStatus struct {
	State   string          `json:"state"`
	Dir     string          `json:"dir,omitempty"` // node state dir: which network
	Tailnet string          `json:"tailnet,omitempty"`
	Self    *tailscalePeer  `json:"self,omitempty"`
	Peers   []tailscalePeer `json:"peers,omitempty"`
	Health  []string        `json:"health,omitempty"`
}

// handleGetTailscaleStatus summarizes the app's node, "" if there is none.
// The node only starts on first use, so before that the state is NotStarted.
func handleGetTailscaleStatus(fn func(value string)) {
	go func() {
		name, _ := appTailscaleProxy.Load().(string)
		if name == "" {
			fn("")
			return
		}
		status := tailscaleStatus{State: "NotStarted"}
		server, startErr := appTailscaleNode(name)
		if startErr != nil {
			status = tailscaleStatus{State: "Error", Health: []string{startErr.Error()}}
		} else if server != nil {
			st, err := queryTailscaleStatus(server)
			if err != nil {
				status = tailscaleStatus{State: "Error", Health: []string{err.Error()}}
			} else {
				status = summarizeTailscaleStatus(st)
			}
			status.Dir = server.Dir
		}
		data, _ := json.Marshal(status)
		fn(string(data))
	}()
}

// appTailscaleNode inspects the app node through the kernel outbound's
// private fields. It returns the tsnet server once the outbound has started
// it (starting it here would bypass the outbound, which then could not close
// it on reload), or the error if starting failed. A closed node (an old
// config being replaced) counts as not running.
func appTailscaleNode(name string) (*tsnet.Server, error) {
	p := tunnel.Proxies()[name]
	if p == nil || p.Type() != constant.Tailscale {
		return nil, nil
	}
	field := func(name string) any {
		f := findFieldByName(reflect.ValueOf(p), name)
		if !f.IsValid() || !f.CanAddr() {
			return nil
		}
		return reflect.NewAt(f.Type(), unsafe.Pointer(f.UnsafeAddr())).Elem().Interface()
	}
	if ctx, ok := field("ctx").(context.Context); !ok || ctx.Err() != nil {
		return nil, nil
	}
	if started, _ := field("serverStarted").(bool); started {
		server, _ := field("server").(*tsnet.Server)
		return server, nil
	}
	// A failed start closes backendInitCh after recording its error.
	if ch, ok := field("backendInitCh").(chan struct{}); ok {
		select {
		case <-ch:
			err, _ := field("backendInitErr").(error)
			return nil, err
		default:
		}
	}
	return nil, nil
}

func queryTailscaleStatus(server *tsnet.Server) (*ipnstate.Status, error) {
	lc, err := server.LocalClient()
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	return lc.Status(ctx)
}

func summarizeTailscaleStatus(st *ipnstate.Status) tailscaleStatus {
	status := tailscaleStatus{State: st.BackendState, Health: st.Health}
	if st.CurrentTailnet != nil {
		status.Tailnet = st.CurrentTailnet.Name
	}
	if st.Self != nil {
		self := tailscalePeerOf(st.Self)
		status.Self = &self
	}
	for _, p := range st.Peer {
		status.Peers = append(status.Peers, tailscalePeerOf(p))
	}
	sort.Slice(status.Peers, func(i, j int) bool {
		a, b := status.Peers[i], status.Peers[j]
		if a.Online != b.Online {
			return a.Online
		}
		return a.Name < b.Name
	})
	return status
}

func tailscalePeerOf(p *ipnstate.PeerStatus) tailscalePeer {
	// The machine name (MagicDNS label) is unique; OS hostnames often are not.
	name, _, _ := strings.Cut(p.DNSName, ".")
	if name == "" {
		name = p.HostName
	}
	peer := tailscalePeer{
		Name:           name,
		DNSName:        strings.TrimSuffix(p.DNSName, "."),
		OS:             p.OS,
		Online:         p.Online,
		ExitNode:       p.ExitNode,
		ExitNodeOption: p.ExitNodeOption,
		Direct:         p.CurAddr != "",
		Relay:          p.Relay,
		RxBytes:        p.RxBytes,
		TxBytes:        p.TxBytes,
	}
	for _, ip := range p.TailscaleIPs {
		peer.IPs = append(peer.IPs, ip.String())
	}
	if p.PrimaryRoutes != nil {
		for i := 0; i < p.PrimaryRoutes.Len(); i++ {
			// Default routes mean "exit node" (ExitNodeOption), not a subnet.
			if route := p.PrimaryRoutes.At(i); route.Bits() > 0 {
				peer.Routes = append(peer.Routes, route.String())
			}
		}
	}
	return peer
}
