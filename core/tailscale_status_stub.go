//go:build !with_gvisor || no_tailscale

package main

func handleGetTailscaleStatus(fn func(value string)) {
	fn("")
}

func appTailscaleLogin() (gen uint64, auth tailscaleAuth, wait bool) {
	return 0, tailscaleAuth{}, false
}
