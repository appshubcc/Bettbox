package router

import (
	"os"
	"path/filepath"
	"runtime"
	"testing"
)

func flatTestDomains() []*Domain {
	return []*Domain{
		{Type: Domain_Domain, Value: "example.com"},
		{Type: Domain_Domain, Value: "google.cn"},
		{Type: Domain_Full, Value: "full.test.org"},
		{Type: Domain_Plain, Value: "keyword"},
		{Type: Domain_Regex, Value: `^ad[0-9]+\.net$`},
	}
}

var flatTestInputs = []string{
	"example.com", "a.example.com", "A.B.Example.COM", "notexample.com",
	"google.cn", "www.google.cn", "full.test.org", "x.full.test.org",
	"has-keyword.io", "ad12.net", "adx.net", "", "com", "测试.example.com",
}

func TestFlatMatcherRoundTrip(t *testing.T) {
	domains := flatTestDomains()
	origin, err := NewSuccinctMatcherGroup(domains)
	if err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(t.TempDir(), "cn.bin")
	if err := WriteFlatMatcher(path, "cn", origin, domains); err != nil {
		t.Fatal(err)
	}
	flat, err := OpenFlatMatcher(path, "cn")
	if err != nil {
		t.Fatal(err)
	}
	if flat.Count() != origin.Count() {
		t.Fatalf("count %d != %d", flat.Count(), origin.Count())
	}
	for _, input := range flatTestInputs {
		if got, want := flat.ApplyDomain(input), origin.ApplyDomain(input); got != want {
			t.Errorf("%q: got %v want %v", input, got, want)
		}
	}
	if _, err := OpenFlatMatcher(path, "other"); err == nil {
		t.Fatal("name mismatch accepted")
	}
	flat = nil
	runtime.GC()
	runtime.GC()
}

func TestFlatMatcherWithoutDomainSet(t *testing.T) {
	domains := []*Domain{{Type: Domain_Plain, Value: "keyword"}}
	origin, err := NewSuccinctMatcherGroup(domains)
	if err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(t.TempDir(), "k.bin")
	if err := WriteFlatMatcher(path, "k", origin, domains); err != nil {
		t.Fatal(err)
	}
	flat, err := OpenFlatMatcher(path, "k")
	if err != nil {
		t.Fatal(err)
	}
	if !flat.ApplyDomain("a-keyword.com") || flat.ApplyDomain("example.com") {
		t.Fatal("unexpected match result")
	}
}

func TestFlatMatcherRejectsDamagedFile(t *testing.T) {
	domains := flatTestDomains()
	origin, err := NewSuccinctMatcherGroup(domains)
	if err != nil {
		t.Fatal(err)
	}
	dir := t.TempDir()
	path := filepath.Join(dir, "cn.bin")
	if err := WriteFlatMatcher(path, "cn", origin, domains); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	cases := map[string][]byte{
		"truncated": data[:len(data)-3],
		"short":     data[:10],
		"magic":     append([]byte("XXXXXXXX"), data[8:]...),
		"empty":     {},
	}
	for name, content := range cases {
		damaged := filepath.Join(dir, name)
		if err := os.WriteFile(damaged, content, 0o644); err != nil {
			t.Fatal(err)
		}
		if _, err := OpenFlatMatcher(damaged, "cn"); err == nil {
			t.Errorf("%s accepted", name)
		}
	}
	if _, err := OpenFlatMatcher(filepath.Join(dir, "missing"), "cn"); err == nil {
		t.Error("missing file accepted")
	}
	if entries, _ := os.ReadDir(dir); len(entries) != 1+len(cases) {
		t.Errorf("unexpected leftover files: %d", len(entries))
	}
}
