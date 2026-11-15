package executor

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	P "github.com/metacubex/mihomo/constant/provider"
)

type fakeVehicle struct {
	P.Vehicle
	path string
}

func (v fakeVehicle) Type() P.VehicleType { return P.HTTP }
func (v fakeVehicle) Path() string        { return v.path }

type fakeRuleProvider struct {
	P.RuleProvider
	name    string
	path    string
	block   chan struct{}
	started chan struct{}
}

func (p *fakeRuleProvider) Name() string               { return p.name }
func (p *fakeRuleProvider) Type() P.ProviderType       { return P.Rule }
func (p *fakeRuleProvider) VehicleType() P.VehicleType { return P.HTTP }
func (p *fakeRuleProvider) Vehicle() P.Vehicle         { return fakeVehicle{path: p.path} }
func (p *fakeRuleProvider) Initial() error {
	close(p.started)
	<-p.block
	return nil
}

func TestLoadRuleProvidersSkipsWaitingForDownloads(t *testing.T) {
	dir := t.TempDir()
	cachedPath := filepath.Join(dir, "cached.mrs")
	if err := os.WriteFile(cachedPath, []byte("x"), 0o644); err != nil {
		t.Fatal(err)
	}
	cached := &fakeRuleProvider{name: "cached", path: cachedPath, block: make(chan struct{}), started: make(chan struct{})}
	missing := &fakeRuleProvider{name: "missing", path: filepath.Join(dir, "missing.mrs"), block: make(chan struct{}), started: make(chan struct{})}
	close(cached.block)
	done := make(chan struct{})
	go func() {
		loadRuleProviders(map[string]P.RuleProvider{"cached": cached, "missing": missing})
		close(done)
	}()
	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("loadRuleProviders waited for a provider without a local file")
	}
	select {
	case <-cached.started:
	default:
		t.Fatal("cached provider was not loaded before returning")
	}
	select {
	case <-missing.started:
	case <-time.After(5 * time.Second):
		t.Fatal("missing provider was never loaded")
	}
	close(missing.block)
}
