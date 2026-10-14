package dns

import (
	"context"
	"testing"

	D "github.com/miekg/dns"
)

type namedTailscaleClient string

func (c namedTailscaleClient) Address() string { return string(c) }

func (c namedTailscaleClient) ExchangeContext(context.Context, *D.Msg) (*D.Msg, error) {
	return nil, nil
}

func (c namedTailscaleClient) ResetConnection() {}

func registeredTailscaleClient(name string) dnsClient {
	tailscaleResolverMu.RLock()
	defer tailscaleResolverMu.RUnlock()
	return tailscaleResolvers[name].client
}

func TestTailscaleProviderNeverReplacesTopLevel(t *testing.T) {
	const name = "tailscale-registry-test"
	unregisterTop := RegisterTailscaleDnsClient(name, namedTailscaleClient("top"), false)
	unregisterProvider := RegisterTailscaleDnsClient(name, namedTailscaleClient("provider"), true)
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("top") {
		t.Fatalf("provider proxy replaced the top-level client: %v", got)
	}
	unregisterProvider()
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("top") {
		t.Fatalf("unregistering the provider proxy removed the top-level client: %v", got)
	}
	unregisterNext := RegisterTailscaleDnsClient(name, namedTailscaleClient("next"), false)
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("next") {
		t.Fatalf("a new top-level proxy should replace the old one: %v", got)
	}
	unregisterTop()
	unregisterNext()
	unregisterOnly := RegisterTailscaleDnsClient(name, namedTailscaleClient("provider"), true)
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("provider") {
		t.Fatalf("a provider proxy should serve a name no top-level proxy has: %v", got)
	}
	unregisterOnly()
}

func TestTailscaleStagedClients(t *testing.T) {
	const name = "tailscale-stage-test"
	unregisterLive := RegisterTailscaleDnsClient(name, namedTailscaleClient("live"), false)
	defer unregisterLive()
	var unregisterNew, unregisterClosed func()
	stage, err := StageTailscaleDnsClients(func() error {
		unregisterNew = RegisterTailscaleDnsClient(name, namedTailscaleClient("new"), false)
		unregisterClosed = RegisterTailscaleDnsClient(name+"-closed", namedTailscaleClient("closed"), false)
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	defer unregisterNew()
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("live") {
		t.Fatalf("a staged client replaced the live one before commit: %v", got)
	}
	unregisterClosed()
	stage.Commit()
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("new") {
		t.Fatalf("commit did not register the staged client: %v", got)
	}
	if got := registeredTailscaleClient(name + "-closed"); got != nil {
		t.Fatalf("commit registered a client whose proxy was closed: %v", got)
	}
	unregisterLive()
	if got := registeredTailscaleClient(name); got != namedTailscaleClient("new") {
		t.Fatalf("closing the old proxy removed the new client: %v", got)
	}
	discarded, _ := StageTailscaleDnsClients(func() error {
		RegisterTailscaleDnsClient(name+"-discarded", namedTailscaleClient("x"), false)
		return nil
	})
	_ = discarded
	if got := registeredTailscaleClient(name + "-discarded"); got != nil {
		t.Fatalf("an uncommitted stage registered its client: %v", got)
	}
}
