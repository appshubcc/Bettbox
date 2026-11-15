package geodata

import (
	"fmt"
	"hash/fnv"
	"os"
	"path/filepath"
	"strings"

	"github.com/metacubex/mihomo/component/geodata/router"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
)

const siteCacheDir = "geosite-cache"

type siteCache struct {
	name   string
	dir    string
	prefix string
	path   string
}

func newSiteCache(matcherName string) *siteCache {
	if geoSiteMatcher == "mph" {
		return nil
	}
	info, err := os.Stat(C.Path.GetAssetLocation(C.GeositeName))
	if err != nil {
		return nil
	}
	hash := fnv.New64a()
	_, _ = hash.Write([]byte(matcherName))
	dir := filepath.Join(C.Path.HomeDir(), siteCacheDir)
	prefix := fmt.Sprintf("%x-%x-", info.Size(), info.ModTime().UnixNano())
	return &siteCache{
		name:   matcherName,
		dir:    dir,
		prefix: prefix,
		path:   filepath.Join(dir, fmt.Sprintf("%s%016x.bin", prefix, hash.Sum64())),
	}
}

func (c *siteCache) load() router.DomainMatcher {
	if c == nil {
		return nil
	}
	matcher, err := router.OpenFlatMatcher(c.path, c.name)
	if err != nil {
		return nil
	}
	return matcher
}

func (c *siteCache) build(domains []*router.Domain) (router.DomainMatcher, error) {
	matcher, err := router.NewSuccinctMatcherGroup(domains)
	if err != nil || c == nil {
		return matcher, err
	}
	if err := os.MkdirAll(c.dir, 0o755); err != nil {
		return matcher, nil
	}
	if err := router.WriteFlatMatcher(c.path, c.name, matcher, domains); err != nil {
		log.Debugln("save GeoSite cache %s failed: %s", c.name, err)
		return matcher, nil
	}
	c.prune()
	if flat, err := router.OpenFlatMatcher(c.path, c.name); err == nil {
		return flat, nil
	}
	return matcher, nil
}

func (c *siteCache) prune() {
	entries, err := os.ReadDir(c.dir)
	if err != nil {
		return
	}
	for _, entry := range entries {
		if !strings.HasPrefix(entry.Name(), c.prefix) {
			_ = os.Remove(filepath.Join(c.dir, entry.Name()))
		}
	}
}

func verifyGeoSite() error {
	if geoSiteMatcher != "mph" {
		_, err := LoadGeoSiteMatcher("CN")
		return err
	}
	geoLoader, err := GetGeoDataLoader(geoLoaderName)
	if err != nil {
		return err
	}
	_, err = geoLoader.LoadGeoSite("cn")
	return err
}
