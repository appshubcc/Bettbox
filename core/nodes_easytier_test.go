//go:build !no_easytier

package main

import (
	"context"
	"net"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/dns"
	D "github.com/miekg/dns"
)

const easyTierNode = `name: live
type: easytier
network-name: net
network-secret: s
peers: [tcp://192.0.2.1:11010]
`

func TestParseNodesMeshKeepsName(t *testing.T) {
	proxies, _, err := parseNodes(easyTierNode)
	if err != nil {
		t.Fatal(err)
	}
	if len(proxies) != 1 || proxies[0]["name"] != "live" {
		t.Errorf("validation must keep the saved name: %v", proxies)
	}
}

type fakeEasyTierDNSClient struct {
	calls atomic.Int32
}

func (*fakeEasyTierDNSClient) Address() string  { return "easytier://live" }
func (*fakeEasyTierDNSClient) ResetConnection() {}

func (c *fakeEasyTierDNSClient) ExchangeContext(_ context.Context, query *D.Msg) (*D.Msg, error) {
	c.calls.Add(1)
	reply := new(D.Msg).SetReply(query)
	reply.Answer = []D.RR{&D.A{
		Hdr: D.RR_Header{Name: query.Question[0].Name, Rrtype: D.TypeA, Class: D.ClassINET, Ttl: 60},
		A:   net.IPv4(192, 0, 2, 42),
	}}
	return reply, nil
}

func TestParseNodeProxyDoesNotReplaceLiveDNSClient(t *testing.T) {
	client := new(fakeEasyTierDNSClient)
	t.Cleanup(dns.RegisterEasyTierDnsClient("live", client))
	if _, _, err := parseNodes(easyTierNode); err != nil {
		t.Fatal(err)
	}

	resolver := dns.NewResolver(dns.Config{Main: []dns.NameServer{{Net: "easytier", Addr: "live"}}})
	query := new(D.Msg).SetQuestion("host.example.", D.TypeA)
	ctx, cancel := context.WithTimeout(t.Context(), time.Second)
	defer cancel()
	reply, err := resolver.ExchangeContext(ctx, query)
	if err != nil {
		t.Fatal(err)
	}
	if calls := client.calls.Load(); calls != 1 {
		t.Errorf("live DNS client received %d requests, want 1", calls)
	}
	if reply == nil || len(reply.Answer) != 1 {
		t.Fatalf("expected one DNS answer, got %v", reply)
	}
	if answer, ok := reply.Answer[0].(*D.A); !ok || !answer.A.Equal(net.IPv4(192, 0, 2, 42)) || answer.Hdr.Name != query.Question[0].Name {
		t.Errorf("unexpected DNS answer: %v", reply.Answer[0])
	}
}
