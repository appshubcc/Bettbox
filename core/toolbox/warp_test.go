package toolbox

import (
	"crypto/ecdh"
	"crypto/rand"
	"encoding/base64"
	"testing"

	"github.com/metacubex/mihomo/adapter"
)

func TestWarpProxy(t *testing.T) {
	device, err := ecdh.X25519().GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	endpoint, err := ecdh.X25519().GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	peerPublicKey := base64.StdEncoding.EncodeToString(endpoint.PublicKey().Bytes())
	clientID := base64.StdEncoding.EncodeToString([]byte{201, 223, 144})
	server, port := warpEndpoint("162.159.192.2:0", "engage.cloudflareclient.com:2408", []int{2408, 500})
	mapping, err := warpProxy(
		device.Bytes(),
		peerPublicKey,
		clientID,
		server,
		port,
		"172.16.0.2",
		"2606:4700:110:8a36:df92:102a:9602:fa18",
	)
	if err != nil {
		t.Fatal(err)
	}
	if mapping["type"] != "wireguard" || mapping["server"] != "162.159.192.2" || mapping["port"] != 2408 || mapping["remote-dns-resolve"] != true {
		t.Errorf("unexpected mapping: %v", mapping)
	}
	reserved, ok := mapping["reserved"].([]int)
	if !ok || len(reserved) != 3 || reserved[0] != 201 || reserved[1] != 223 || reserved[2] != 144 {
		t.Errorf("unexpected reserved: %v", mapping["reserved"])
	}
	proxy, err := adapter.ParseProxy(mapping)
	if err != nil {
		t.Fatal(err)
	}
	_ = proxy.Close()
	if _, err := warpProxy(device.Bytes(), "invalid", "", server, port, "172.16.0.2", ""); err == nil {
		t.Errorf("invalid endpoint key must fail")
	}
	if _, err := warpProxy(device.Bytes(), peerPublicKey, "", server, port, "", ""); err == nil {
		t.Errorf("missing address must fail")
	}
}
