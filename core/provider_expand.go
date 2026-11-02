package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"maps"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/convert"
	"github.com/metacubex/mihomo/common/structure"
	"github.com/metacubex/mihomo/common/yaml"
	"github.com/metacubex/mihomo/component/age"
	mihomoHttp "github.com/metacubex/mihomo/component/http"
	"github.com/metacubex/mihomo/component/resource"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
)

type expandOptions struct {
	ProvidersPath string
	AgeSecretKey  string
	Refresh       bool
}

type providerProxyName struct {
	Pattern *regexp2.Regexp `provider:"pattern"`
	Target  string          `provider:"target"`
}

type providerOverride struct {
	TFO              *bool                   `provider:"tfo,omitempty"`
	MPTcp            *bool                   `provider:"mptcp,omitempty"`
	UDP              *bool                   `provider:"udp,omitempty"`
	UDPOverTCP       *bool                   `provider:"udp-over-tcp,omitempty"`
	Up               *string                 `provider:"up,omitempty"`
	Down             *string                 `provider:"down,omitempty"`
	DialerProxy      *string                 `provider:"dialer-proxy,omitempty"`
	SkipCertVerify   *bool                   `provider:"skip-cert-verify,omitempty"`
	NameCertVerify   *string                 `provider:"name-cert-verify,omitempty"`
	Interface        *string                 `provider:"interface-name,omitempty"`
	RoutingMark      *int                    `provider:"routing-mark,omitempty"`
	IPVersion        *string                 `provider:"ip-version,omitempty"`
	AdditionalPrefix *string                 `provider:"additional-prefix,omitempty"`
	AdditionalSuffix *string                 `provider:"additional-suffix,omitempty"`
	ProxyName        []providerProxyName     `provider:"proxy-name,omitempty"`
	OverrideExpr     []provider.OverrideExpr `provider:"override-expr,omitempty"`
}

type expandProviderSchema struct {
	Type          string              `provider:"type"`
	Path          string              `provider:"path,omitempty"`
	URL           string              `provider:"url,omitempty"`
	Proxy         string              `provider:"proxy,omitempty"`
	Filter        string              `provider:"filter,omitempty"`
	ExcludeFilter string              `provider:"exclude-filter,omitempty"`
	ExcludeType   string              `provider:"exclude-type,omitempty"`
	DialerProxy   string              `provider:"dialer-proxy,omitempty"`
	SizeLimit     int64               `provider:"size-limit,omitempty"`
	Interval      int                 `provider:"interval,omitempty"`
	Payload       []map[string]any    `provider:"payload,omitempty"`
	AgeSecretKey  string              `provider:"age-secret-key,omitempty"`
	Override      providerOverride    `provider:"override,omitempty"`
	Header        map[string][]string `provider:"header,omitempty"`
}

func (o *providerOverride) apply(mapping map[string]any) error {
	if o.TFO != nil {
		mapping["tfo"] = *o.TFO
	}
	if o.MPTcp != nil {
		mapping["mptcp"] = *o.MPTcp
	}
	if o.UDP != nil {
		mapping["udp"] = *o.UDP
	}
	if o.UDPOverTCP != nil {
		mapping["udp-over-tcp"] = *o.UDPOverTCP
	}
	if o.Up != nil {
		mapping["up"] = *o.Up
	}
	if o.Down != nil {
		mapping["down"] = *o.Down
	}
	if o.DialerProxy != nil {
		mapping["dialer-proxy"] = *o.DialerProxy
	}
	if o.SkipCertVerify != nil {
		mapping["skip-cert-verify"] = *o.SkipCertVerify
	}
	if o.NameCertVerify != nil {
		mapping["name-cert-verify"] = *o.NameCertVerify
	}
	if o.Interface != nil {
		mapping["interface-name"] = *o.Interface
	}
	if o.RoutingMark != nil {
		mapping["routing-mark"] = *o.RoutingMark
	}
	if o.IPVersion != nil {
		mapping["ip-version"] = *o.IPVersion
	}
	name, _ := mapping["name"].(string)
	for _, expr := range o.ProxyName {
		if expr.Pattern == nil {
			continue
		}
		replaced, err := expr.Pattern.Replace(name, expr.Target, 0, -1)
		if err != nil {
			return fmt.Errorf("proxy name replace error: %w", err)
		}
		name = replaced
	}
	if o.AdditionalPrefix != nil {
		name = *o.AdditionalPrefix + name
	}
	if o.AdditionalSuffix != nil {
		name += *o.AdditionalSuffix
	}
	mapping["name"] = name
	for idx, expr := range o.OverrideExpr {
		if err := expr.Apply(mapping); err != nil {
			return fmt.Errorf("override-expr[%d] %q: %w", idx, expr.String(), err)
		}
	}
	return nil
}

func expandProxyProviders(raw *config.RawConfig, options expandOptions) error {
	if len(raw.ProxyProvider) == 0 {
		return nil
	}
	names := make([]string, 0, len(raw.ProxyProvider))
	for name := range raw.ProxyProvider {
		names = append(names, name)
	}
	sort.Strings(names)
	used := make(map[string]bool, len(raw.Proxy)+len(raw.ProxyGroup))
	for _, item := range raw.Proxy {
		if name, ok := item["name"].(string); ok {
			used[name] = true
		}
	}
	for _, item := range raw.ProxyGroup {
		if name, ok := item["name"].(string); ok {
			used[name] = true
		}
	}
	decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
	for _, name := range names {
		mapping := raw.ProxyProvider[name]
		if mapping == nil {
			continue
		}
		schema := &expandProviderSchema{}
		if err := decoder.Decode(mapping, schema); err != nil {
			return fmt.Errorf("proxy provider %s: %w", name, err)
		}
		proxies, err := loadProviderProxies(schema, options)
		if err != nil {
			return fmt.Errorf("proxy provider %s: %w", name, err)
		}
		for _, proxy := range proxies {
			proxy["name"] = uniqueProxyName(proxy["name"].(string), used)
			raw.Proxy = append(raw.Proxy, proxy)
		}
	}
	raw.ProxyProvider = nil
	return nil
}

func uniqueProxyName(name string, used map[string]bool) string {
	candidate := name
	for index := 2; used[candidate]; index++ {
		candidate = name + " " + strconv.Itoa(index)
	}
	used[candidate] = true
	return candidate
}

func loadProviderProxies(schema *expandProviderSchema, options expandOptions) ([]map[string]any, error) {
	var mappings []map[string]any
	switch schema.Type {
	case "inline":
		mappings = schema.Payload
	case "file", "http":
		buf, err := readProviderContent(schema, options)
		if err != nil {
			if len(schema.Payload) == 0 {
				return nil, err
			}
			mappings = schema.Payload
			break
		}
		ageSecretKey := schema.AgeSecretKey
		if ageSecretKey == "" {
			ageSecretKey = options.AgeSecretKey
		}
		mappings, err = parseProviderContent(buf, ageSecretKey)
		if err != nil {
			return nil, err
		}
	default:
		return nil, fmt.Errorf("unsupported vehicle type: %s", schema.Type)
	}
	return filterProviderProxies(mappings, schema)
}

func readProviderContent(schema *expandProviderSchema, options expandOptions) ([]byte, error) {
	if schema.Type == "file" {
		path := C.Path.Resolve(schema.Path)
		if !C.Path.IsSafePath(path) {
			return nil, C.Path.ErrNotSafePath(path)
		}
		return os.ReadFile(path)
	}
	cache := providerFilePath(options.ProvidersPath, "proxies", schema.URL)
	if !options.Refresh && providerCacheFresh(cache, schema.Interval) {
		if buf, err := os.ReadFile(cache); err == nil && len(buf) > 0 {
			return buf, nil
		}
	}
	buf, err := downloadProviderContent(schema)
	if err == nil {
		if options.ProvidersPath != "" {
			writeProviderCache(cache, buf)
		}
		return buf, nil
	}
	if cached, readErr := os.ReadFile(cache); readErr == nil && len(cached) > 0 {
		return cached, nil
	}
	return nil, err
}

func providerCacheFresh(path string, interval int) bool {
	info, err := os.Stat(path)
	if err != nil || info.Size() == 0 {
		return false
	}
	return interval <= 0 || time.Since(info.ModTime()) < time.Duration(interval)*time.Second
}

func writeProviderCache(path string, buf []byte) {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return
	}
	temp := path + ".tmp"
	if err := os.WriteFile(temp, buf, 0o644); err != nil {
		return
	}
	if err := os.Rename(temp, path); err != nil {
		_ = os.Remove(temp)
	}
}

func downloadProviderContent(schema *expandProviderSchema) ([]byte, error) {
	ctx, cancel := context.WithTimeout(context.Background(), resource.DefaultHttpTimeout)
	defer cancel()
	resp, err := mihomoHttp.HttpRequest(ctx, schema.URL, http.MethodGet, schema.Header, nil, mihomoHttp.WithSpecialProxy(schema.Proxy))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return nil, errors.New(resp.Status)
	}
	var reader io.Reader = resp.Body
	if schema.SizeLimit > 0 {
		reader = io.LimitReader(reader, schema.SizeLimit)
	}
	return io.ReadAll(reader)
}

func parseProviderContent(buf []byte, ageSecretKey string) ([]map[string]any, error) {
	var keys []string
	if ageSecretKey != "" {
		keys = append(keys, ageSecretKey)
	}
	ageMutex.Lock()
	decrypted, err := age.DecryptBytes(buf, keys...)
	ageMutex.Unlock()
	if err != nil {
		return nil, fmt.Errorf("decrypt config error: %w", err)
	}
	schema := struct {
		Proxies []map[string]any `yaml:"proxies"`
	}{}
	if err := yaml.Unmarshal(decrypted, &schema); err != nil {
		proxies, convertErr := convert.ConvertsV2Ray(decrypted)
		if convertErr != nil {
			return nil, fmt.Errorf("%w, %w", err, convertErr)
		}
		schema.Proxies = proxies
	}
	if schema.Proxies == nil {
		return nil, errors.New("file must have a `proxies` field")
	}
	return schema.Proxies, nil
}

func filterProviderProxies(mappings []map[string]any, schema *expandProviderSchema) ([]map[string]any, error) {
	var excludeTypes []string
	if schema.ExcludeType != "" {
		excludeTypes = strings.Split(schema.ExcludeType, "|")
	}
	var excludeFilters []*regexp2.Regexp
	if schema.ExcludeFilter != "" {
		for pattern := range strings.SplitSeq(schema.ExcludeFilter, "`") {
			reg, err := regexp2.Compile(pattern, regexp2.None)
			if err != nil {
				return nil, fmt.Errorf("invalid excludeFilter regex: %w", err)
			}
			excludeFilters = append(excludeFilters, reg)
		}
	}
	var filters []*regexp2.Regexp
	for pattern := range strings.SplitSeq(schema.Filter, "`") {
		reg, err := regexp2.Compile(pattern, regexp2.None)
		if err != nil {
			return nil, fmt.Errorf("invalid filter regex: %w", err)
		}
		filters = append(filters, reg)
	}
	var result []map[string]any
	seen := map[string]bool{}
	for _, filter := range filters {
	next:
		for idx, mapping := range mappings {
			if len(excludeTypes) > 0 {
				kind, ok := mapping["type"].(string)
				if !ok {
					continue
				}
				for _, excludeType := range excludeTypes {
					if strings.EqualFold(kind, excludeType) {
						continue next
					}
				}
			}
			name, ok := mapping["name"].(string)
			if !ok {
				continue
			}
			for _, exclude := range excludeFilters {
				if matched, _ := exclude.MatchString(name); matched {
					continue next
				}
			}
			if schema.Filter != "" {
				if matched, _ := filter.MatchString(name); !matched {
					continue
				}
			}
			if seen[name] {
				continue
			}
			proxy := make(map[string]any, len(mapping)+1)
			maps.Copy(proxy, mapping)
			if schema.DialerProxy != "" {
				proxy["dialer-proxy"] = schema.DialerProxy
			}
			if err := schema.Override.apply(proxy); err != nil {
				return nil, fmt.Errorf("proxy %d override error: %w", idx, err)
			}
			seen[name] = true
			result = append(result, proxy)
		}
	}
	if len(result) == 0 {
		if schema.Filter != "" {
			return nil, errors.New("doesn't match any proxy, please check your filter")
		}
		return nil, errors.New("file doesn't have any proxy")
	}
	return result, nil
}
