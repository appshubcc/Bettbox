package mitm

import (
	"crypto/x509"
	"encoding/pem"
	"strings"
	"testing"
)

func TestSubjectHashOldStable(t *testing.T) {
	auth, err := generateAuthority()
	if err != nil {
		t.Fatal(err)
	}
	h1 := auth.SubjectHashOld()
	h2 := SubjectHashOld(auth.cert)
	if h1 != h2 {
		t.Fatalf("hash mismatch %s vs %s", h1, h2)
	}
	if len(h1) != 8 {
		t.Fatalf("hash length %d", len(h1))
	}
	for _, c := range h1 {
		if !((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')) {
			t.Fatalf("hash not hex: %s", h1)
		}
	}
	block, _ := pem.Decode(auth.certPEM)
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		t.Fatal(err)
	}
	if SubjectHashOld(cert) != h1 {
		t.Fatal("reparsed cert hash differs")
	}
}

func TestLeafSAN(t *testing.T) {
	auth, err := generateAuthority()
	if err != nil {
		t.Fatal(err)
	}
	leaf, err := auth.Leaf("app.bilibili.com")
	if err != nil {
		t.Fatal(err)
	}
	if len(leaf.Certificate) < 1 {
		t.Fatal("missing leaf der")
	}
	parsed, err := x509.ParseCertificate(leaf.Certificate[0])
	if err != nil {
		t.Fatal(err)
	}
	found := false
	for _, n := range parsed.DNSNames {
		if n == "app.bilibili.com" {
			found = true
		}
	}
	if !found {
		t.Fatalf("SAN missing, got %v", parsed.DNSNames)
	}
	leaf2, err := auth.Leaf("app.bilibili.com")
	if err != nil {
		t.Fatal(err)
	}
	if leaf != leaf2 {
		t.Fatal("leaf cache miss")
	}
}

func TestModuleZipContainsCA(t *testing.T) {
	auth, err := generateAuthority()
	if err != nil {
		t.Fatal(err)
	}
	data, err := auth.ModuleZipBytes()
	if err != nil {
		t.Fatal(err)
	}
	if len(data) < 100 {
		t.Fatal("zip too small")
	}
	s := string(data)
	if strings.Contains(s, "metamodule=") {
		t.Fatal("zip must not be a KernelSU metamodule")
	}
	if !strings.Contains(s, "module.prop") && !bytesContains(data, []byte("module.prop")) {
		t.Fatal("missing module.prop")
	}
	if !bytesContains(data, []byte("service.sh")) {
		t.Fatal("missing service.sh")
	}
	if !bytesContains(data, []byte(auth.SubjectHashOld()+".0")) {
		t.Fatal("missing hashed CA file")
	}
	if !bytesContains(data, []byte("skip_mount")) {
		t.Fatal("missing skip_mount")
	}
}

func bytesContains(b, sub []byte) bool {
	return strings.Contains(string(b), string(sub))
}

func TestHostMatcher(t *testing.T) {
	m := NewHostMatcher([]string{
		"app.bilibili.com",
		"*.biliapi.net",
		"-broadcast.chat.bilibili.com",
		"*.bilibili.com",
	})
	if !m.Match("app.bilibili.com") {
		t.Fatal("exact host")
	}
	if !m.Match("grpc.biliapi.net") {
		t.Fatal("wildcard host")
	}
	if m.Match("broadcast.chat.bilibili.com") {
		t.Fatal("excluded host matched")
	}
	if m.Match("example.com") {
		t.Fatal("unlisted host matched")
	}
	if !m.Match("www.bilibili.com") {
		t.Fatal("parent wildcard")
	}
}

func TestParseRewrite(t *testing.T) {
	rules := ParseRewriteRules([]string{
		"^https://app.bilibili.com/x/v2/splash/show - reject-dict",
		"^https://example.com/ad reject",
		"# comment",
		"not-a-rule",
	})
	if len(rules) != 2 {
		t.Fatalf("rules=%d", len(rules))
	}
	if matchRewrite(rules, "GET", "https://app.bilibili.com/x/v2/splash/show") != ActionRejectDict {
		t.Fatal("reject-dict")
	}
	if matchRewrite(rules, "GET", "https://example.com/ad") != ActionReject {
		t.Fatal("reject")
	}
	if matchRewrite(rules, "GET", "https://example.com/ok") != ActionNone {
		t.Fatal("no match")
	}
}
