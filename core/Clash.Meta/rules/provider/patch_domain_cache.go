package provider

import (
	"encoding/binary"
	"errors"
	"fmt"
	"hash/fnv"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	"github.com/metacubex/mihomo/component/trie"
	C "github.com/metacubex/mihomo/constant"
	P "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/rules/common"
)

const (
	ruleCacheDir       = "ruleset-cache"
	flatRuleMagic      = "BBRSET01"
	flatRuleHeaderSize = 24
	ruleCacheMaxAge    = 7 * 24 * time.Hour
	ruleCacheTouchAge  = 24 * time.Hour
)

var errInvalidFlatRuleSet = errors.New("invalid flat domain ruleset")

type flatDomainStrategy struct {
	domainStrategy
	release func()
}

func (d *flatDomainStrategy) Match(metadata *C.Metadata, helper C.RuleMatchHelper) bool {
	matched := d.domainStrategy.Match(metadata, helper)
	runtime.KeepAlive(d)
	return matched
}

func (d *flatDomainStrategy) WriteMrs(w io.Writer) error {
	err := d.domainStrategy.WriteMrs(w)
	runtime.KeepAlive(d)
	return err
}

func (d *flatDomainStrategy) DumpMrs(f func(key string) bool) {
	d.domainStrategy.DumpMrs(f)
	runtime.KeepAlive(d)
}

type domainRuleCache struct {
	name   string
	dir    string
	prefix string
	file   string
	path   string
}

func newDomainRuleCache(name string, source string, format P.RuleFormat, buf []byte) *domainRuleCache {
	homeDir := C.Path.HomeDir()
	if name == "" || homeDir == "" || len(buf) == 0 {
		return nil
	}
	providerHash := fnv.New64a()
	_, _ = providerHash.Write([]byte(name))
	_, _ = providerHash.Write([]byte{0})
	_, _ = providerHash.Write([]byte(format.String()))
	_, _ = providerHash.Write([]byte{0})
	_, _ = providerHash.Write([]byte(source))

	contentHash := fnv.New64a()
	_, _ = contentHash.Write(buf)

	dir := filepath.Join(homeDir, ruleCacheDir)
	prefix := fmt.Sprintf("%016x-", providerHash.Sum64())
	file := fmt.Sprintf("%s%x-%016x.bin", prefix, len(buf), contentHash.Sum64())
	return &domainRuleCache{
		name:   name,
		dir:    dir,
		prefix: prefix,
		file:   file,
		path:   filepath.Join(dir, file),
	}
}

func (c *domainRuleCache) load() ruleStrategy {
	if c == nil {
		return nil
	}
	strategy, err := openFlatDomainStrategy(c.path, c.name)
	if err != nil {
		return nil
	}
	if info, statErr := os.Stat(c.path); statErr == nil && time.Since(info.ModTime()) > ruleCacheTouchAge {
		now := time.Now()
		_ = os.Chtimes(c.path, now, now)
	}
	return strategy
}

func (c *domainRuleCache) store(strategy ruleStrategy) ruleStrategy {
	if c == nil {
		return strategy
	}
	ds, ok := strategy.(*domainStrategy)
	if !ok {
		return strategy
	}
	if err := os.MkdirAll(c.dir, 0o755); err != nil {
		return strategy
	}
	if err := writeFlatDomainStrategy(c.path, c.name, ds); err != nil {
		log.Debugln("save domain ruleset cache %s failed: %s", c.name, err)
		return strategy
	}
	c.prune()
	if !preferMappedReload {
		return strategy
	}
	if flat, err := openFlatDomainStrategy(c.path, c.name); err == nil {
		return flat
	}
	return strategy
}

func (c *domainRuleCache) prune() {
	entries, err := os.ReadDir(c.dir)
	if err != nil {
		return
	}
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		entryName := entry.Name()
		entryPath := filepath.Join(c.dir, entryName)
		if strings.HasPrefix(entryName, c.prefix) {
			if entryName != c.file {
				_ = os.Remove(entryPath)
			}
			continue
		}
		if !strings.HasSuffix(entryName, ".bin") {
			continue
		}
		if info, err := entry.Info(); err == nil && time.Since(info.ModTime()) > ruleCacheMaxAge {
			_ = os.Remove(entryPath)
		}
	}
}

func parseStrategy(name string, source string, behavior P.RuleBehavior, format P.RuleFormat, parse common.ParseRuleFunc, buf []byte) (ruleStrategy, error) {
	if behavior != P.Domain {
		return rulesParse(buf, newStrategy(behavior, parse), format)
	}
	cache := newDomainRuleCache(name, source, format, buf)
	if flat := cache.load(); flat != nil {
		return flat, nil
	}
	strategy, err := rulesParse(buf, newStrategy(behavior, parse), format)
	if err != nil {
		return nil, err
	}
	return cache.store(strategy), nil
}

func writeFlatDomainStrategy(path string, name string, ds *domainStrategy) error {
	buf := make([]byte, flatRuleHeaderSize)
	copy(buf, flatRuleMagic)
	binary.LittleEndian.PutUint64(buf[8:], uint64(ds.count))
	buf = ds.domainSet.AppendFlat(buf)
	buf = binary.AppendUvarint(buf, uint64(len(name)))
	buf = append(buf, name...)
	binary.LittleEndian.PutUint64(buf[16:], uint64(len(buf)))

	file, err := os.CreateTemp(filepath.Dir(path), filepath.Base(path)+".*")
	if err != nil {
		return err
	}
	tmp := file.Name()
	_, err = file.Write(buf)
	if err == nil {
		err = file.Sync()
	}
	if closeErr := file.Close(); err == nil {
		err = closeErr
	}
	if err == nil {
		err = os.Rename(tmp, path)
	}
	if err != nil {
		_ = os.Remove(tmp)
	}
	return err
}

func openFlatDomainStrategy(path string, name string) (*flatDomainStrategy, error) {
	data, release, err := mapFlatRuleFile(path)
	if err != nil {
		return nil, err
	}
	strategy, err := parseFlatDomainStrategy(data, name)
	if err != nil {
		if release != nil {
			release()
		}
		return nil, err
	}
	if release != nil {
		strategy.release = release
		runtime.SetFinalizer(strategy, func(s *flatDomainStrategy) {
			if s.release != nil {
				s.release()
			}
		})
	}
	return strategy, nil
}

func parseFlatDomainStrategy(data []byte, name string) (*flatDomainStrategy, error) {
	if len(data) < flatRuleHeaderSize || string(data[:8]) != flatRuleMagic {
		return nil, errInvalidFlatRuleSet
	}
	if binary.LittleEndian.Uint64(data[16:]) != uint64(len(data)) {
		return nil, errInvalidFlatRuleSet
	}
	set, n, err := trie.DomainSetFromFlat(data[flatRuleHeaderSize:])
	if err != nil {
		return nil, err
	}
	tail := data[flatRuleHeaderSize+n:]
	size, varLen := binary.Uvarint(tail)
	if varLen <= 0 || size != uint64(len(tail)-varLen) {
		return nil, errInvalidFlatRuleSet
	}
	if string(tail[varLen:]) != name {
		return nil, errInvalidFlatRuleSet
	}
	strategy := &flatDomainStrategy{}
	strategy.count = int(binary.LittleEndian.Uint64(data[8:]))
	strategy.domainSet = set
	return strategy, nil
}
