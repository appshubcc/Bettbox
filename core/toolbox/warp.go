package toolbox

import (
	"bytes"
	"context"
	"crypto/ecdh"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/netip"
	"strconv"
	"strings"
	"time"

	mihomoHttp "github.com/metacubex/mihomo/component/http"
)

const (
	warpApiUrl      = "https://api.cloudflareclient.com/v0a4471/reg"
	warpDefaultHost = "engage.cloudflareclient.com"
	warpDefaultPort = 2408
	warpTimeout     = 30 * time.Second
)

var warpHeaders = map[string][]string{
	"User-Agent":        {"WARP for Android"},
	"CF-Client-Version": {"a-6.35-4471"},
	"Content-Type":      {"application/json; charset=UTF-8"},
}

type warpAccount struct {
	ID     string `json:"id"`
	Token  string `json:"token"`
	Config struct {
		ClientID string `json:"client_id"`
		Peers    []struct {
			PublicKey string `json:"public_key"`
			Endpoint  struct {
				V4    string `json:"v4"`
				Host  string `json:"host"`
				Ports []int  `json:"ports"`
			} `json:"endpoint"`
		} `json:"peers"`
		Interface struct {
			Addresses struct {
				V4 string `json:"v4"`
				V6 string `json:"v6"`
			} `json:"addresses"`
		} `json:"interface"`
	} `json:"config"`
}

type warpResult struct {
	Proxy map[string]any `json:"proxy"`
	ID    string         `json:"id"`
	Token string         `json:"token"`
	Error string         `json:"error"`
}

func warpRequest(ctx context.Context, method, url, token string, payload any) (*warpAccount, error) {
	body, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}
	header := make(map[string][]string, len(warpHeaders)+1)
	for key, value := range warpHeaders {
		header[key] = value
	}
	if token != "" {
		header["Authorization"] = []string{"Bearer " + token}
	}
	resp, err := mihomoHttp.HttpRequest(ctx, url, method, header, bytes.NewReader(body))
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	data, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("cloudflare api: %s %s", resp.Status, bytes.TrimSpace(data))
	}
	account := &warpAccount{}
	if err := json.Unmarshal(data, account); err != nil {
		return nil, err
	}
	return account, nil
}

func createWarpDevice(ctx context.Context) (*warpAccount, *ecdh.PrivateKey, error) {
	privateKey, err := ecdh.X25519().GenerateKey(rand.Reader)
	if err != nil {
		return nil, nil, err
	}
	serial := make([]byte, 8)
	if _, err := rand.Read(serial); err != nil {
		return nil, nil, err
	}
	account, err := warpRequest(ctx, http.MethodPost, warpApiUrl, "", map[string]string{
		"key":           base64.StdEncoding.EncodeToString(privateKey.PublicKey().Bytes()),
		"install_id":    "",
		"fcm_token":     "",
		"tos":           time.Now().Format("2006-01-02T15:04:05.000-07:00"),
		"model":         "PC",
		"serial_number": hex.EncodeToString(serial),
		"os_version":    "",
		"key_type":      "curve25519",
		"tunnel_type":   "wireguard",
		"locale":        "en_US",
	})
	if err != nil {
		return nil, nil, err
	}
	if account.ID == "" || account.Token == "" {
		return nil, nil, errors.New("cloudflare api: incomplete registration")
	}
	return account, privateKey, nil
}

func registerWarp(ctx context.Context) (*warpResult, error) {
	account, privateKey, err := createWarpDevice(ctx)
	if err != nil {
		return nil, err
	}
	if len(account.Config.Peers) == 0 {
		return nil, errors.New("cloudflare api: missing endpoint")
	}
	peer := account.Config.Peers[0]
	server, port := warpEndpoint(peer.Endpoint.V4, peer.Endpoint.Host, peer.Endpoint.Ports)
	addresses := account.Config.Interface.Addresses
	proxy, err := warpProxy(
		privateKey.Bytes(),
		peer.PublicKey,
		account.Config.ClientID,
		server,
		port,
		addresses.V4,
		addresses.V6,
	)
	if err != nil {
		return nil, err
	}
	return &warpResult{Proxy: proxy, ID: account.ID, Token: account.Token}, nil
}

func warpEndpoint(v4, host string, ports []int) (string, int) {
	server := ""
	if ip := splitHost(v4); ip != "" {
		if addr, err := netip.ParseAddr(ip); err == nil {
			server = addr.String()
		}
	}
	hostName, hostPort := splitHostPort(host)
	if server == "" {
		server = hostName
	}
	if server == "" {
		server = warpDefaultHost
	}
	port := hostPort
	if port <= 0 && len(ports) > 0 && ports[0] > 0 {
		port = ports[0]
	}
	if port <= 0 {
		port = warpDefaultPort
	}
	return server, port
}

func splitHost(value string) string {
	host, _ := splitHostPort(value)
	return host
}

func splitHostPort(value string) (string, int) {
	trimmed := strings.TrimSpace(value)
	if trimmed == "" {
		return "", 0
	}
	host, portText, err := net.SplitHostPort(trimmed)
	if err != nil {
		return trimmed, 0
	}
	port, _ := strconv.Atoi(portText)
	return host, port
}

func warpReserved(clientID string) []int {
	raw, err := base64.StdEncoding.DecodeString(strings.TrimSpace(clientID))
	if err != nil || len(raw) != 3 {
		return nil
	}
	return []int{int(raw[0]), int(raw[1]), int(raw[2])}
}

func warpProxy(privateKey []byte, peerPublicKey, clientID, server string, port int, v4, v6 string) (map[string]any, error) {
	if len(privateKey) != 32 {
		return nil, errors.New("cloudflare api: invalid private key")
	}
	peerKey, err := base64.StdEncoding.DecodeString(strings.TrimSpace(peerPublicKey))
	if err != nil || len(peerKey) != 32 {
		return nil, errors.New("cloudflare api: invalid peer public key")
	}
	if v4 == "" && v6 == "" {
		return nil, errors.New("cloudflare api: missing interface address")
	}
	if server == "" {
		server = warpDefaultHost
	}
	if port <= 0 {
		port = warpDefaultPort
	}
	proxy := map[string]any{
		"name":               "Cloudflare WARP",
		"type":               "wireguard",
		"server":             server,
		"port":               port,
		"private-key":        base64.StdEncoding.EncodeToString(privateKey),
		"public-key":         base64.StdEncoding.EncodeToString(peerKey),
		"mtu":                1280,
		"udp":                true,
		"remote-dns-resolve": true,
		"dns":                []string{"1.1.1.1", "1.0.0.1"},
	}
	if reserved := warpReserved(clientID); reserved != nil {
		proxy["reserved"] = reserved
	}
	if v4 != "" {
		proxy["ip"] = v4
	}
	if v6 != "" {
		proxy["ipv6"] = v6
	}
	return proxy, nil
}

func HandleRegisterWarp() string {
	ctx, cancel := context.WithTimeout(context.Background(), warpTimeout)
	defer cancel()
	result, err := registerWarp(ctx)
	if err != nil {
		result = &warpResult{Error: err.Error()}
	}
	data, _ := json.Marshal(result)
	return string(data)
}
