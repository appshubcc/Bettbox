//go:build !with_gvisor || no_tailscale

package main

func handleGetTailscaleStatus(fn func(value string)) {
	fn("")
}
