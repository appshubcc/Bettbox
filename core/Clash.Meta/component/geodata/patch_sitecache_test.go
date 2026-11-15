package geodata_test

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/geodata"
	_ "github.com/metacubex/mihomo/component/geodata/memconservative"
	"github.com/metacubex/mihomo/component/geodata/router"
	C "github.com/metacubex/mihomo/constant"

	"google.golang.org/protobuf/proto"
)

func writeGeoSite(t *testing.T, dir string, modTime time.Time, lists map[string][]*router.Domain) {
	t.Helper()
	list := &router.GeoSiteList{}
	for code, domains := range lists {
		list.Entry = append(list.Entry, &router.GeoSite{CountryCode: code, Domain: domains})
	}
	data, err := proto.Marshal(list)
	if err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(dir, C.GeositeName)
	if err := os.WriteFile(path, data, 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Chtimes(path, modTime, modTime); err != nil {
		t.Fatal(err)
	}
}

func cacheFiles(t *testing.T, dir string) []string {
	t.Helper()
	entries, err := os.ReadDir(filepath.Join(dir, "geosite-cache"))
	if err != nil {
		return nil
	}
	names := make([]string, 0, len(entries))
	for _, entry := range entries {
		names = append(names, entry.Name())
	}
	return names
}

func TestGeoSiteFlatCache(t *testing.T) {
	origin := C.Path.HomeDir()
	dir := t.TempDir()
	C.SetHomeDir(dir)
	geodata.ClearGeoSiteCache()
	t.Cleanup(func() {
		geodata.ClearGeoSiteCache()
		C.SetHomeDir(origin)
	})

	base := time.Now().Add(-time.Hour)
	writeGeoSite(t, dir, base, map[string][]*router.Domain{
		"CN": {
			{Type: router.Domain_Domain, Value: "example.cn"},
			{Type: router.Domain_Domain, Value: "ads.example.cn", Attribute: []*router.Domain_Attribute{{Key: "ads"}}},
			{Type: router.Domain_Plain, Value: "keyword"},
		},
		"GOOGLE": {{Type: router.Domain_Full, Value: "google.com"}},
	})

	for round := 0; round < 2; round++ {
		matcher, err := geodata.LoadGeoSiteMatcher("cn")
		if err != nil {
			t.Fatal(err)
		}
		if !strings.Contains(fmt.Sprintf("%T", matcher), "flat") {
			t.Fatalf("round %d: matcher %T is not flat", round, matcher)
		}
		if matcher.Count() != 3 || !matcher.ApplyDomain("www.example.cn") || !matcher.ApplyDomain("a-keyword.com") || matcher.ApplyDomain("google.com") {
			t.Fatalf("round %d: unexpected cn result", round)
		}
		ads, err := geodata.LoadGeoSiteMatcher("cn@ads")
		if err != nil {
			t.Fatal(err)
		}
		if ads.Count() != 1 || !ads.ApplyDomain("ads.example.cn") || ads.ApplyDomain("www.example.cn") {
			t.Fatalf("round %d: unexpected cn@ads result", round)
		}
		not, err := geodata.LoadGeoSiteMatcher("!google")
		if err != nil {
			t.Fatal(err)
		}
		if not.ApplyDomain("google.com") || !not.ApplyDomain("example.cn") {
			t.Fatalf("round %d: unexpected !google result", round)
		}
		if files := cacheFiles(t, dir); len(files) != 3 {
			t.Fatalf("round %d: cache files %v", round, files)
		}
		geodata.ClearGeoSiteCache()
	}

	if _, err := geodata.LoadGeoSiteMatcher("missing"); err == nil {
		t.Fatal("missing list accepted")
	}

	before := cacheFiles(t, dir)
	writeGeoSite(t, dir, base.Add(time.Minute), map[string][]*router.Domain{
		"CN": {{Type: router.Domain_Domain, Value: "changed.cn"}},
	})
	matcher, err := geodata.LoadGeoSiteMatcher("cn")
	if err != nil {
		t.Fatal(err)
	}
	if matcher.Count() != 1 || !matcher.ApplyDomain("changed.cn") || matcher.ApplyDomain("example.cn") {
		t.Fatal("updated GeoSite not applied")
	}
	after := cacheFiles(t, dir)
	if len(after) != 1 {
		t.Fatalf("stale cache not pruned: %v", after)
	}
	for _, name := range before {
		if name == after[0] {
			t.Fatalf("cache file reused after update: %s", name)
		}
	}

	geodata.SetSiteMatcher("mph")
	t.Cleanup(func() { geodata.SetSiteMatcher("succinct") })
	geodata.ClearGeoSiteCache()
	mph, err := geodata.LoadGeoSiteMatcher("cn")
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(fmt.Sprintf("%T", mph), "flat") || !mph.ApplyDomain("changed.cn") {
		t.Fatal("mph matcher should bypass the flat cache")
	}
}
