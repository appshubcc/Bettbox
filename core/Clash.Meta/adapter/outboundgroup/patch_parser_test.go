package outboundgroup

import (
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
	P "github.com/metacubex/mihomo/constant/provider"
	"github.com/stretchr/testify/require"
)

func TestParseProxyGroupIncludeAllAppliesExcludeAndDeduplicates(t *testing.T) {
	proxyMap := map[string]C.Proxy{
		"COMPATIBLE": adapter.NewProxy(outbound.NewCompatible()),
		"HK IEPL 01": urlTestProxy("HK IEPL 01"),
		"HK 过期":      urlTestProxy("HK 过期"),
		"US 01":      urlTestProxy("US 01"),
	}
	providersMap := map[string]P.ProxyProvider{}
	allProxies := []string{"HK IEPL 01", "HK 过期", "US 01"}

	group, err := ParseProxyGroup(
		map[string]any{
			"name":           "HK",
			"type":           "select",
			"include-all":    true,
			"filter":         "HK`IEPL",
			"exclude-filter": "过期",
		},
		proxyMap,
		providersMap,
		allProxies,
		nil,
	)
	require.NoError(t, err)

	var names []string
	for _, p := range group.Proxies() {
		names = append(names, p.Name())
	}
	require.Equal(t, []string{"HK IEPL 01"}, names)
	require.Equal(t, 1, providersMap["HK"].Count())
}
