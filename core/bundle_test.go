package main

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/metacubex/mihomo/constant"
)

func TestPreloadBundledRuleSets(t *testing.T) {
	previousHome := constant.Path.HomeDir()
	home := t.TempDir()
	constant.SetHomeDir(home)
	defer constant.SetHomeDir(previousHome)

	bundleFile, err := os.ReadFile(filepath.Join("testdata", "BundleMRS.7z"))
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(home, "BundleMRS.7z"), bundleFile, 0o644); err != nil {
		t.Fatal(err)
	}

	existing := filepath.Join(home, "rules", "existing")
	if err := os.MkdirAll(filepath.Dir(existing), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(existing, []byte("downloaded"), 0o644); err != nil {
		t.Fatal(err)
	}
	outside := filepath.Join(t.TempDir(), "outside")

	rawCfg := parsePatchProfile(t, "mixed-port: 7890\n")
	rawCfg.RuleProvider = map[string]map[string]any{
		"private":  {"type": "http", "url": "https://example.com/private.mrs", "path": filepath.Join(home, "rules", "private"), "path-in-bundle": "geo/geosite/private.mrs"},
		"shared":   {"type": "http", "url": "https://example.com/shared.mrs", "path": filepath.Join(home, "rules", "shared"), "path-in-bundle": "./geo/geosite/private.mrs"},
		"cn":       {"type": "file", "path": filepath.Join(home, "rules", "cn"), "path-in-bundle": "geo/geoip/cn.mrs"},
		"existing": {"type": "http", "url": "https://example.com/existing.mrs", "path": existing, "path-in-bundle": "geo/geosite/unused.mrs"},
		"missing":  {"type": "http", "url": "https://example.com/missing.mrs", "path": filepath.Join(home, "rules", "missing"), "path-in-bundle": "geo/geosite/none.mrs"},
		"remote":   {"type": "http", "url": "https://example.com/remote.mrs", "path": filepath.Join(home, "rules", "remote")},
		"unsafe":   {"type": "http", "url": "https://example.com/unsafe.mrs", "path": outside, "path-in-bundle": "geo/geoip/cn.mrs"},
		"inline":   {"type": "inline", "path-in-bundle": "geo/geoip/cn.mrs"},
	}

	started := time.Now().Add(-time.Minute)
	preloadBundledRuleSets(rawCfg)

	for name, want := range map[string]string{"private": "private-rules", "shared": "private-rules", "cn": "cn-ip-rules"} {
		path := filepath.Join(home, "rules", name)
		got, err := os.ReadFile(path)
		if err != nil || string(got) != want {
			t.Errorf("%s = %q (%v), want %q", name, got, err, want)
			continue
		}
		if stat, _ := os.Stat(path); stat.ModTime().Before(started) {
			t.Errorf("%s keeps the archive time %v instead of the extraction time", name, stat.ModTime())
		}
	}
	if got, _ := os.ReadFile(existing); string(got) != "downloaded" {
		t.Errorf("an existing rule set must be kept, got %q", got)
	}
	for _, path := range []string{filepath.Join(home, "rules", "missing"), filepath.Join(home, "rules", "remote"), outside} {
		if _, err := os.Stat(path); err == nil {
			t.Errorf("%s should not be created", path)
		}
	}
	if left := bundledRuleSetTargets(rawCfg); len(left) != 1 {
		t.Errorf("only the entry missing from the bundle should remain, got %v", left)
	}
}
