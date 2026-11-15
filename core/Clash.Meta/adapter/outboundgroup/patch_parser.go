package outboundgroup

import (
	"strings"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/common/utils"
	C "github.com/metacubex/mihomo/constant"
)

func filterAllProxies(allProxies []string, proxyMap map[string]C.Proxy, filter string, excludeFilter string, excludeType string) []string {
	if filter == "" && excludeFilter == "" && excludeType == "" {
		return allProxies
	}

	var filterRegs []*regexp2.Regexp
	if filter != "" {
		for _, part := range strings.Split(filter, "`") {
			filterRegs = append(filterRegs, utils.MustCompileRegexp(part, regexp2.None))
		}
	}

	var excludeFilterRegs []*regexp2.Regexp
	if excludeFilter != "" {
		for _, part := range strings.Split(excludeFilter, "`") {
			excludeFilterRegs = append(excludeFilterRegs, utils.MustCompileRegexp(part, regexp2.None))
		}
	}

	var excludeTypes []string
	if excludeType != "" {
		excludeTypes = strings.Split(excludeType, "|")
	}

	var matched []string
	for _, name := range allProxies {
		if len(filterRegs) > 0 {
			hit := false
			for _, reg := range filterRegs {
				if ok, _ := reg.MatchString(name); ok {
					hit = true
					break
				}
			}
			if !hit {
				continue
			}
		}
		if len(excludeFilterRegs) > 0 {
			excluded := false
			for _, reg := range excludeFilterRegs {
				if ok, _ := reg.MatchString(name); ok {
					excluded = true
					break
				}
			}
			if excluded {
				continue
			}
		}
		if len(excludeTypes) > 0 {
			if proxy, ok := proxyMap[name]; ok {
				mType := proxy.Type().String()
				excluded := false
				for _, et := range excludeTypes {
					if strings.EqualFold(mType, et) {
						excluded = true
						break
					}
				}
				if excluded {
					continue
				}
			}
		}
		matched = append(matched, name)
	}
	return matched
}
