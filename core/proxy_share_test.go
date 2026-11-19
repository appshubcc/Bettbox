package main

import (
	"fmt"
	"strings"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/common/convert"
)

func convertShareLink(t *testing.T, mapping map[string]any) map[string]any {
	t.Helper()
	link := proxyShareLink(mapping)
	if link == "" {
		t.Fatalf("no link for %v", mapping["type"])
	}
	proxies, err := convert.ConvertsV2Ray([]byte(link))
	if err != nil || len(proxies) != 1 {
		t.Fatalf("convert %s: %v %d", link, err, len(proxies))
	}
	if _, err := adapter.ParseProxy(proxies[0]); err != nil {
		t.Fatalf("parse %s: %v", link, err)
	}
	return proxies[0]
}

func expectShareFields(t *testing.T, got map[string]any, want map[string]any) {
	t.Helper()
	for key, value := range want {
		if fmt.Sprint(got[key]) != fmt.Sprint(value) {
			t.Errorf("%s: got %v, want %v", key, got[key], value)
		}
	}
}

func TestShareLinkRoundTrip(t *testing.T) {
	cases := []struct {
		name    string
		mapping map[string]any
		want    map[string]any
	}{
		{
			name: "ss",
			mapping: map[string]any{
				"name": "香港 01", "type": "ss", "server": "hk.example.com", "port": 8388,
				"cipher": "aes-256-gcm", "password": "p@ss:word", "udp-over-tcp": true,
				"plugin": "obfs", "plugin-opts": map[string]any{"mode": "tls", "host": "bing.com"},
			},
			want: map[string]any{
				"name": "香港 01", "server": "hk.example.com", "port": "8388", "cipher": "aes-256-gcm",
				"password": "p@ss:word", "udp-over-tcp": true, "plugin": "obfs",
				"plugin-opts": map[string]any{"mode": "tls", "host": "bing.com"},
			},
		},
		{
			name: "ss2022",
			mapping: map[string]any{
				"name": "SS 2022", "type": "ss", "server": "1.2.3.4", "port": 443,
				"cipher": "2022-blake3-aes-128-gcm", "password": "AAAAAAAAAAAAAAAAAAAAAA==",
			},
			want: map[string]any{"cipher": "2022-blake3-aes-128-gcm", "password": "AAAAAAAAAAAAAAAAAAAAAA=="},
		},
		{
			name: "ssr",
			mapping: map[string]any{
				"name": "SSR", "type": "ssr", "server": "ssr.example.com", "port": 443,
				"cipher": "chacha20-ietf", "password": "secret", "obfs": "tls1.2_ticket_auth",
				"protocol": "auth_sha1_v4", "obfs-param": "a.com", "protocol-param": "1:2",
			},
			want: map[string]any{
				"name": "SSR", "server": "ssr.example.com", "port": "443", "cipher": "chacha20-ietf",
				"password": "secret", "obfs": "tls1.2_ticket_auth", "protocol": "auth_sha1_v4",
				"obfs-param": "a.com", "protocol-param": "1:2",
			},
		},
		{
			name: "vmess ws",
			mapping: map[string]any{
				"name": "VMess", "type": "vmess", "server": "v.example.com", "port": 443,
				"uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "cipher": "auto",
				"tls": true, "servername": "v.example.com", "network": "ws",
				"ws-opts": map[string]any{"path": "/ray", "headers": map[string]any{"Host": "v.example.com"}},
			},
			want: map[string]any{
				"name": "VMess", "server": "v.example.com", "port": "443",
				"uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "tls": true,
				"servername": "v.example.com", "network": "ws",
			},
		},
		{
			name: "vless reality",
			mapping: map[string]any{
				"name": "VLESS", "type": "vless", "server": "1.1.1.1", "port": 443,
				"uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "flow": "xtls-rprx-vision",
				"tls": true, "servername": "www.apple.com", "client-fingerprint": "safari",
				"reality-opts": map[string]any{"public-key": "SbVKOEMjK0sIlbwg4akyBg5mL5KZwwB-ed4eEE7YnRc", "short-id": "0123abcd"},
				"network":      "grpc", "grpc-opts": map[string]any{"grpc-service-name": "svc"},
			},
			want: map[string]any{
				"name": "VLESS", "uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "flow": "xtls-rprx-vision",
				"tls": true, "servername": "www.apple.com", "client-fingerprint": "safari",
				"reality-opts": map[string]any{"public-key": "SbVKOEMjK0sIlbwg4akyBg5mL5KZwwB-ed4eEE7YnRc", "short-id": "0123abcd"},
				"network":      "grpc", "grpc-opts": map[string]any{"grpc-service-name": "svc"},
			},
		},
		{
			name: "trojan",
			mapping: map[string]any{
				"name": "Trojan", "type": "trojan", "server": "t.example.com", "port": 443,
				"password": "pass word", "sni": "t.example.com", "skip-cert-verify": true,
				"alpn": []any{"h2", "http/1.1"},
			},
			want: map[string]any{
				"name": "Trojan", "password": "pass word", "sni": "t.example.com",
				"skip-cert-verify": true, "alpn": []string{"h2", "http/1.1"},
			},
		},
		{
			name: "hysteria2 ports",
			mapping: map[string]any{
				"name": "HY2", "type": "hysteria2", "server": "h.example.com", "port": 443,
				"ports": "20000-30000", "password": "secret", "sni": "h.example.com",
				"obfs": "salamander", "obfs-password": "obfs", "skip-cert-verify": true,
			},
			want: map[string]any{
				"name": "HY2", "server": "h.example.com", "port": "20000", "ports": "20000-30000",
				"password": "secret", "sni": "h.example.com", "obfs": "salamander",
				"obfs-password": "obfs", "skip-cert-verify": true,
			},
		},
		{
			name: "hysteria",
			mapping: map[string]any{
				"name": "HY", "type": "hysteria", "server": "h.example.com", "port": 443,
				"auth-str": "secret", "sni": "h.example.com", "up": "30", "down": "200",
				"protocol": "udp",
			},
			want: map[string]any{
				"name": "HY", "auth_str": "secret", "sni": "h.example.com", "up": "30", "down": "200",
			},
		},
		{
			name: "tuic",
			mapping: map[string]any{
				"name": "TUIC", "type": "tuic", "server": "t.example.com", "port": 443,
				"uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "password": "secret",
				"congestion-controller": "bbr", "alpn": []any{"h3"}, "udp-relay-mode": "native",
			},
			want: map[string]any{
				"name": "TUIC", "uuid": "b831381d-6324-4d53-ad4f-8cda48b30811", "password": "secret",
				"congestion-controller": "bbr", "alpn": []string{"h3"}, "udp-relay-mode": "native",
			},
		},
		{
			name: "anytls",
			mapping: map[string]any{
				"name": "A 03 香港 IEPL专线 1.5x", "type": "anytls", "server": "a.example.com", "port": 443,
				"password": "secret", "sni": "a.example.com", "skip-cert-verify": true,
			},
			want: map[string]any{
				"name": "A 03 香港 IEPL专线 1.5x", "server": "a.example.com", "port": "443",
				"password": "secret", "sni": "a.example.com", "skip-cert-verify": true,
			},
		},
		{
			name: "socks5",
			mapping: map[string]any{
				"name": "家宽", "type": "socks5", "server": "s.example.com", "port": 1080,
				"username": "user", "password": "pass",
			},
			want: map[string]any{"type": "socks5", "username": "user", "password": "pass", "port": "1080"},
		},
		{
			name: "https",
			mapping: map[string]any{
				"name": "HTTP", "type": "http", "server": "h.example.com", "port": 443, "tls": true,
			},
			want: map[string]any{"type": "http", "tls": true},
		},
	}
	for _, item := range cases {
		t.Run(item.name, func(t *testing.T) {
			expectShareFields(t, convertShareLink(t, item.mapping), item.want)
		})
	}
}

func TestShareLinkUnsupported(t *testing.T) {
	for _, mapping := range []map[string]any{
		{"name": "WG", "type": "wireguard", "server": "1.1.1.1", "port": 2408},
		{"name": "Snell", "type": "snell", "server": "1.1.1.1", "port": 443},
		{"name": "SS", "type": "ss", "server": "1.1.1.1", "port": 443, "cipher": "aes-128-gcm", "password": "p", "plugin": "shadow-tls"},
	} {
		if link := proxyShareLink(mapping); link != "" {
			t.Errorf("%v: unexpected link %s", mapping["type"], link)
		}
	}
}

func TestFindProxyMapping(t *testing.T) {
	raw := parsePatchProfile(t, `
proxies:
  - {name: HK 01, type: ss, server: a.com, port: 1, cipher: aes-128-gcm, password: p}
proxy-providers:
  inline:
    type: inline
    override:
      additional-prefix: "P "
    dialer-proxy: HK 01
    payload:
      - {name: JP 01, type: trojan, server: b.com, port: 443, password: q}
`)
	mapping, err := findProxyMapping(raw, "P JP 01")
	if err != nil {
		t.Fatal(err)
	}
	if mapping["server"] != "b.com" || mapping["dialer-proxy"] != "HK 01" {
		t.Fatalf("unexpected mapping %v", mapping)
	}
	if _, err := findProxyMapping(raw, "missing"); err == nil {
		t.Fatal("expected error")
	}
	content, err := proxyMappingYaml(map[string]any{
		"port": 443, "name": "🇭🇰 HK", "type": "ss", "server": "a.com", "alpn": []string{"h2"},
	})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(content, "name: \"🇭🇰 HK\"\ntype: ss\nserver: a.com\nport: 443\nalpn:") {
		t.Fatalf("unexpected yaml %q", content)
	}
}
