package listener

import (
	"net"
	"testing"

	LC "github.com/metacubex/mihomo/listener/config"
)

func TestStopListenerClosesTunnels(t *testing.T) {
	probe, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	addr := probe.Addr().String()
	_ = probe.Close()

	tunnels := []LC.Tunnel{{
		Network: []string{"tcp", "udp"},
		Address: addr,
		Target:  "127.0.0.1:9",
		Proxy:   "DIRECT",
	}}
	PatchTunnel(tunnels, nil)
	if len(tunnelTCPListeners) != 1 || len(tunnelUDPListeners) != 1 {
		t.Fatalf("tunnels not started: tcp=%d udp=%d", len(tunnelTCPListeners), len(tunnelUDPListeners))
	}
	LastTunConf = LC.Tun{Enable: true, Device: "test"}

	StopListener()

	if len(tunnelTCPListeners) != 0 || len(tunnelUDPListeners) != 0 {
		t.Fatalf("tunnels left open: tcp=%d udp=%d", len(tunnelTCPListeners), len(tunnelUDPListeners))
	}
	if LastTunConf.Enable {
		t.Fatal("LastTunConf not reset")
	}
	rebind, err := net.Listen("tcp", addr)
	if err != nil {
		t.Fatalf("port still in use: %s", err)
	}
	_ = rebind.Close()

	PatchTunnel(tunnels, nil)
	if len(tunnelTCPListeners) != 1 || len(tunnelUDPListeners) != 1 {
		t.Fatal("tunnels not restarted")
	}
	StopListener()
}
