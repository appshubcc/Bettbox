package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/structure"
	C "github.com/metacubex/mihomo/constant"
)

const expandedManifestName = "expanded.json"

type providerMeta struct {
	Userinfo string    `json:"subscription-userinfo,omitempty"`
	UpdateAt time.Time `json:"update-at"`
}

type expandedProvider struct {
	Name             string                     `json:"name"`
	Type             string                     `json:"type"`
	VehicleType      string                     `json:"vehicle-type"`
	Path             string                     `json:"path,omitempty"`
	Count            int                        `json:"count"`
	UpdateAt         time.Time                  `json:"update-at"`
	SubscriptionInfo *provider.SubscriptionInfo `json:"subscription-info,omitempty"`
	Interval         int                        `json:"interval"`
	Expanded         bool                       `json:"expanded"`
}

type UpdateExpandedProviderParams struct {
	Path          string  `json:"path"`
	AgeSecretKey  string  `json:"age-secret-key"`
	ProvidersPath string  `json:"providers-path"`
	Name          string  `json:"name"`
	Content       *string `json:"content"`
}

var expandedManifestLock sync.Mutex

func providerMetaPath(cache string) string {
	return cache + ".meta"
}

func readProviderMeta(cache string) providerMeta {
	var meta providerMeta
	if data, err := os.ReadFile(providerMetaPath(cache)); err == nil {
		_ = json.Unmarshal(data, &meta)
	}
	if meta.UpdateAt.IsZero() {
		meta.UpdateAt = fileModTime(cache)
	}
	return meta
}

func fileModTime(path string) time.Time {
	if info, err := os.Stat(path); err == nil {
		return info.ModTime()
	}
	return time.Now()
}

func newExpandedProvider(name string, schema *expandProviderSchema, count int, providersPath string) expandedProvider {
	entry := expandedProvider{
		Name:     name,
		Type:     "Proxy",
		Count:    count,
		Interval: schema.Interval,
		Expanded: true,
		UpdateAt: time.Now(),
	}
	switch schema.Type {
	case "http":
		entry.VehicleType = "HTTP"
		entry.Path = providerFilePath(providersPath, "proxies", schema.URL)
		meta := readProviderMeta(entry.Path)
		entry.UpdateAt = meta.UpdateAt
		if meta.Userinfo != "" {
			entry.SubscriptionInfo = provider.NewSubscriptionInfo(meta.Userinfo)
		}
	case "file":
		entry.VehicleType = "File"
		entry.Path = C.Path.Resolve(schema.Path)
		entry.UpdateAt = fileModTime(entry.Path)
	default:
		entry.VehicleType = "Inline"
	}
	return entry
}

func expandedManifestPath(providersPath string) string {
	return filepath.Join(providersPath, expandedManifestName)
}

func writeExpandedManifest(providersPath string, entries []expandedProvider) {
	if providersPath == "" {
		return
	}
	if entries == nil {
		entries = []expandedProvider{}
	}
	data, err := json.Marshal(entries)
	if err != nil {
		return
	}
	expandedManifestLock.Lock()
	defer expandedManifestLock.Unlock()
	_ = writeProviderFile(expandedManifestPath(providersPath), data)
}

func updateExpandedManifest(providersPath string, entry expandedProvider) {
	expandedManifestLock.Lock()
	defer expandedManifestLock.Unlock()
	path := expandedManifestPath(providersPath)
	var entries []expandedProvider
	if data, err := os.ReadFile(path); err == nil {
		_ = json.Unmarshal(data, &entries)
	}
	index := slices.IndexFunc(entries, func(item expandedProvider) bool { return item.Name == entry.Name })
	if index < 0 {
		entries = append(entries, entry)
		slices.SortFunc(entries, func(a, b expandedProvider) int { return strings.Compare(a.Name, b.Name) })
	} else {
		entries[index] = entry
	}
	if data, err := json.Marshal(entries); err == nil {
		_ = writeProviderFile(path, data)
	}
}

func handleUpdateExpandedProvider(params *UpdateExpandedProviderParams) (bool, error) {
	if params.ProvidersPath == "" {
		return false, errors.New("missing providers path")
	}
	raw, err := readProfile(params.Path, params.AgeSecretKey)
	if err != nil {
		return false, err
	}
	mapping, ok := raw.ProxyProvider[params.Name]
	if !ok {
		return false, fmt.Errorf("proxy provider %s not found", params.Name)
	}
	schema := &expandProviderSchema{}
	decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
	if err := decoder.Decode(mapping, schema); err != nil {
		return false, err
	}
	var target, userinfo string
	var buf []byte
	switch schema.Type {
	case "http":
		target = providerFilePath(params.ProvidersPath, "proxies", schema.URL)
		userinfo = readProviderMeta(target).Userinfo
		if params.Content != nil {
			buf = []byte(*params.Content)
		} else if buf, userinfo, err = downloadProviderContent(schema); err != nil {
			return false, err
		}
	case "file":
		target = C.Path.Resolve(schema.Path)
		if !C.Path.IsSafePath(target) {
			return false, C.Path.ErrNotSafePath(target)
		}
		if params.Content == nil {
			return true, nil
		}
		buf = []byte(*params.Content)
	default:
		return false, fmt.Errorf("unsupported vehicle type: %s", schema.Type)
	}
	ageSecretKey := schema.AgeSecretKey
	if ageSecretKey == "" {
		ageSecretKey = params.AgeSecretKey
	}
	mappings, err := parseProviderContent(buf, ageSecretKey)
	if err != nil {
		return false, err
	}
	proxies, err := filterProviderProxies(mappings, schema)
	if err != nil {
		return false, err
	}
	previous, _ := os.ReadFile(target)
	changed := !bytes.Equal(previous, buf)
	if schema.Type == "http" {
		writeProviderCache(target, buf, userinfo)
	} else if changed {
		if err := writeProviderFile(target, buf); err != nil {
			return false, err
		}
	}
	updateExpandedManifest(params.ProvidersPath, newExpandedProvider(params.Name, schema, len(proxies), params.ProvidersPath))
	return changed, nil
}
