package provider

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	P "github.com/metacubex/mihomo/constant/provider"
)

func setupRuleCacheTestDir(t *testing.T) string {
	t.Helper()
	homeDir := C.Path.HomeDir()
	tempDir := t.TempDir()
	C.SetHomeDir(tempDir)
	t.Cleanup(func() {
		C.SetHomeDir(homeDir)
	})
	return tempDir
}

func TestDomainRuleCacheLifecycle(t *testing.T) {
	tempDir := setupRuleCacheTestDir(t)
	source := "https://example.com/ads.yaml"

	rawV1 := []byte("payload:\n  - '+.example.com'\n  - 'sub.test.org'\n")
	strategyV1, err := parseStrategy("ads", source, P.Domain, P.YamlRule, nil, rawV1)
	if err != nil {
		t.Fatalf("parseStrategy v1 failed: %v", err)
	}
	if preferMappedReload {
		if _, ok := strategyV1.(*flatDomainStrategy); !ok {
			t.Fatalf("expected *flatDomainStrategy, got %T", strategyV1)
		}
	}
	mrsV1, ok := strategyV1.(mrsRuleStrategy)
	if !ok {
		t.Fatalf("expected mrsRuleStrategy, got %T", strategyV1)
	}
	if mrsV1.Count() != 2 {
		t.Fatalf("count = %d, want 2", mrsV1.Count())
	}
	if !mrsV1.Match(&C.Metadata{Host: "a.example.com"}, C.RuleMatchHelper{}) {
		t.Fatal("expected a.example.com to match")
	}
	if !mrsV1.Match(&C.Metadata{Host: "sub.test.org"}, C.RuleMatchHelper{}) {
		t.Fatal("expected sub.test.org to match")
	}
	if mrsV1.Match(&C.Metadata{Host: "other.org"}, C.RuleMatchHelper{}) {
		t.Fatal("expected other.org not to match")
	}

	var mrsBuf bytes.Buffer
	if err := mrsV1.WriteMrs(&mrsBuf); err != nil {
		t.Fatalf("WriteMrs failed: %v", err)
	}
	var dumped []string
	mrsV1.DumpMrs(func(key string) bool {
		dumped = append(dumped, key)
		return true
	})
	if len(dumped) != 2 {
		t.Fatalf("dumped = %v, want 2 items", dumped)
	}

	cacheDir := filepath.Join(tempDir, ruleCacheDir)
	entries, err := os.ReadDir(cacheDir)
	if err != nil || len(entries) != 1 {
		t.Fatalf("cache entries = %d, err = %v", len(entries), err)
	}
	firstFile := entries[0].Name()

	cacheV1 := newDomainRuleCache("ads", source, P.YamlRule, rawV1)
	staleTime := time.Now().Add(-48 * time.Hour)
	if err := os.Chtimes(cacheV1.path, staleTime, staleTime); err != nil {
		t.Fatal(err)
	}

	reloaded, err := parseStrategy("ads", source, P.Domain, P.YamlRule, nil, rawV1)
	if err != nil {
		t.Fatalf("reload failed: %v", err)
	}
	if _, ok := reloaded.(*flatDomainStrategy); !ok {
		t.Fatalf("expected cache hit to return *flatDomainStrategy, got %T", reloaded)
	}
	if !reloaded.Match(&C.Metadata{Host: "example.com"}, C.RuleMatchHelper{}) {
		t.Fatal("reloaded strategy failed to match example.com")
	}
	if info, statErr := os.Stat(cacheV1.path); statErr != nil || time.Since(info.ModTime()) > time.Minute {
		t.Fatalf("expected cache hit to touch mtime, statErr=%v modTime=%v", statErr, info.ModTime())
	}

	otherRaw := []byte("payload:\n  - '+.another.net'\n")
	if _, err := parseStrategy("direct", "https://example.com/direct.yaml", P.Domain, P.YamlRule, nil, otherRaw); err != nil {
		t.Fatalf("other provider failed: %v", err)
	}

	rawV2 := []byte("payload:\n  - '+.updated.com'\n")
	strategyV2, err := parseStrategy("ads", source, P.Domain, P.YamlRule, nil, rawV2)
	if err != nil {
		t.Fatalf("parseStrategy v2 failed: %v", err)
	}
	if !strategyV2.Match(&C.Metadata{Host: "a.updated.com"}, C.RuleMatchHelper{}) {
		t.Fatal("expected a.updated.com to match in v2")
	}
	if strategyV2.Match(&C.Metadata{Host: "example.com"}, C.RuleMatchHelper{}) {
		t.Fatal("expected example.com not to match in v2")
	}

	entries, err = os.ReadDir(cacheDir)
	if err != nil || len(entries) != 2 {
		t.Fatalf("cache entries after update = %d, want 2", len(entries))
	}
	for _, entry := range entries {
		if entry.Name() == firstFile {
			t.Fatalf("stale cache file %s was not pruned", firstFile)
		}
	}

	cacheV2 := newDomainRuleCache("ads", source, P.YamlRule, rawV2)
	if err := os.WriteFile(cacheV2.path, []byte("corrupted"), 0o644); err != nil {
		t.Fatal(err)
	}
	recovered, err := parseStrategy("ads", source, P.Domain, P.YamlRule, nil, rawV2)
	if err != nil {
		t.Fatalf("recovery from corrupted cache failed: %v", err)
	}
	if !recovered.Match(&C.Metadata{Host: "updated.com"}, C.RuleMatchHelper{}) {
		t.Fatal("recovered strategy failed to match")
	}
}

func TestDomainRuleCacheSourceIsolationAndOrphanPrune(t *testing.T) {
	tempDir := setupRuleCacheTestDir(t)
	cacheDir := filepath.Join(tempDir, ruleCacheDir)

	sourceA := "https://a.example.com/reject.yaml"
	sourceB := "https://b.example.com/reject.yaml"
	rawA := []byte("payload:\n  - '+.alpha.example'\n")
	rawB := []byte("payload:\n  - '+.beta.example'\n")

	if _, err := parseStrategy("reject", sourceA, P.Domain, P.YamlRule, nil, rawA); err != nil {
		t.Fatalf("profile A parseStrategy failed: %v", err)
	}
	if _, err := parseStrategy("reject", sourceB, P.Domain, P.YamlRule, nil, rawB); err != nil {
		t.Fatalf("profile B parseStrategy failed: %v", err)
	}

	entries, err := os.ReadDir(cacheDir)
	if err != nil || len(entries) != 2 {
		t.Fatalf("expected both sources to keep separate caches, got %d (err=%v)", len(entries), err)
	}

	reloadedA, err := parseStrategy("reject", sourceA, P.Domain, P.YamlRule, nil, rawA)
	if err != nil {
		t.Fatalf("reload A failed: %v", err)
	}
	if !reloadedA.Match(&C.Metadata{Host: "x.alpha.example"}, C.RuleMatchHelper{}) || reloadedA.Match(&C.Metadata{Host: "x.beta.example"}, C.RuleMatchHelper{}) {
		t.Fatal("source A cache returned wrong domains")
	}

	recentOther := newDomainRuleCache("other", "https://other.example.com/list.yaml", P.YamlRule, rawB)
	if recentOther.prefix == "" {
		t.Fatal("empty prefix")
	}
	threeDaysAgo := time.Now().Add(-3 * 24 * time.Hour)
	recentPath := filepath.Join(cacheDir, recentOther.file)
	if err := os.WriteFile(recentPath, []byte("recent"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Chtimes(recentPath, threeDaysAgo, threeDaysAgo); err != nil {
		t.Fatal(err)
	}

	expiredPath := filepath.Join(cacheDir, "0000000000000000-dead.bin")
	eightDaysAgo := time.Now().Add(-8 * 24 * time.Hour)
	if err := os.WriteFile(expiredPath, []byte("expired"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Chtimes(expiredPath, eightDaysAgo, eightDaysAgo); err != nil {
		t.Fatal(err)
	}

	tempPath := filepath.Join(cacheDir, "in-progress.tmp")
	if err := os.WriteFile(tempPath, []byte("temp"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Chtimes(tempPath, eightDaysAgo, eightDaysAgo); err != nil {
		t.Fatal(err)
	}

	rawAUpdated := []byte("payload:\n  - '+.alpha-v2.example'\n")
	if _, err := parseStrategy("reject", sourceA, P.Domain, P.YamlRule, nil, rawAUpdated); err != nil {
		t.Fatalf("update A failed: %v", err)
	}

	if _, err := os.Stat(expiredPath); !os.IsNotExist(err) {
		t.Fatalf("expected expired orphan file to be removed, stat err = %v", err)
	}
	if _, err := os.Stat(recentPath); err != nil {
		t.Fatalf("expected recent other cache to be preserved, stat err = %v", err)
	}
	if _, err := os.Stat(tempPath); err != nil {
		t.Fatalf("expected non-.bin temp file to be preserved, stat err = %v", err)
	}
	if _, err := os.Stat(newDomainRuleCache("reject", sourceB, P.YamlRule, rawB).path); err != nil {
		t.Fatalf("expected profile B cache to survive profile A update, stat err = %v", err)
	}
}
