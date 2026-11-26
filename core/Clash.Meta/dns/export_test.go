//go:build !no_easytier

package dns

func HasEasyTierDNSClientForTest(name string) bool {
	easyTierResolverMu.RLock()
	defer easyTierResolverMu.RUnlock()
	_, exists := easyTierResolvers[name]
	return exists
}
