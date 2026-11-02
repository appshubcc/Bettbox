package toolbox

import (
	"context"
	"encoding/json"
	"net"
	"strconv"
	"sync"
	"syscall"
	"time"

	iperf3 "github.com/appshubcc/go-iperf3"

	"github.com/metacubex/mihomo/component/dialer"
)

const (
	iperfErrorPortInUse = "port-in-use"
	iperfErrorListen    = "listen"
)

type IperfClientParams struct {
	Hosts     []string `json:"hosts"`
	Port      int      `json:"port"`
	Protocol  string   `json:"protocol"`
	Direction string   `json:"direction"`
	Parallel  int      `json:"parallel"`
	Duration  int      `json:"duration"`
	Bandwidth float64  `json:"bandwidth"`
}

type IperfServerParams struct {
	Port int `json:"port"`
}

type IperfServerInfo struct {
	Port  int    `json:"port"`
	UDP   bool   `json:"udp"`
	Error string `json:"error"`
}

var (
	iperfClientLock   sync.Mutex
	iperfClientCancel context.CancelFunc
	iperfClientSerial int

	iperfServerLock    sync.Mutex
	iperfServerCurrent *iperf3.Server
)

func iperfNotify(state iperf3.State) {
	notify(MessageIperf, state)
}

func iperfSocketControl(network, address string, c syscall.RawConn) error {
	if hook := dialer.DefaultSocketHook; hook != nil {
		_ = hook(network, address, c)
	}
	return nil
}

func HandleStartIperfClient(paramsString string) string {
	params := IperfClientParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	ctx, cancel := context.WithCancel(context.Background())
	iperfClientLock.Lock()
	if iperfClientCancel != nil {
		iperfClientCancel()
	}
	iperfClientCancel = cancel
	iperfClientSerial++
	serial := iperfClientSerial
	iperfClientLock.Unlock()
	defer func() {
		iperfClientLock.Lock()
		if iperfClientSerial == serial {
			iperfClientCancel = nil
		}
		iperfClientLock.Unlock()
		cancel()
		releaseToolMemory()
	}()
	duration := min(params.Duration, 3600)
	state := iperf3.RunClient(ctx, iperf3.ClientConfig{
		Hosts:     params.Hosts,
		Port:      params.Port,
		Protocol:  iperf3.Protocol(params.Protocol),
		Direction: iperf3.Direction(params.Direction),
		Parallel:  params.Parallel,
		Duration:  time.Duration(duration) * time.Second,
		Bandwidth: params.Bandwidth,
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			return dialer.DialContext(ctx, network, address)
		},
		OnUpdate: iperfNotify,
	})
	data, _ := json.Marshal(state)
	return string(data)
}

func HandleCancelIperfClient() bool {
	iperfClientLock.Lock()
	defer iperfClientLock.Unlock()
	if iperfClientCancel != nil {
		iperfClientCancel()
		iperfClientCancel = nil
	}
	return true
}

func iperfListenError(err error) string {
	if iperf3.IsAddrInUse(err) {
		return iperfErrorPortInUse
	}
	return iperfErrorListen
}

func HandleStartIperfServer(paramsString string) string {
	params := IperfServerParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	port := params.Port
	if port <= 0 || port > 65535 {
		port = iperf3.DefaultPort
	}
	iperfServerLock.Lock()
	defer iperfServerLock.Unlock()
	if current := iperfServerCurrent; current != nil {
		_ = current.Close()
		iperfServerCurrent = nil
	}
	info := IperfServerInfo{Port: port}
	server, err := iperf3.Listen(iperf3.ServerConfig{
		Addr:    net.JoinHostPort("", strconv.Itoa(port)),
		Control: iperfSocketControl,
		OnUpdate: func(state iperf3.State) {
			iperfNotify(state)
			if state.Phase == iperf3.PhaseDone {
				releaseToolMemory()
			}
		},
	})
	if err != nil {
		info.Error = iperfListenError(err)
	} else {
		iperfServerCurrent = server
		info.Port = server.Port()
		info.UDP = server.UDP()
	}
	data, _ := json.Marshal(info)
	return string(data)
}

func HandleStopIperfServer() bool {
	iperfServerLock.Lock()
	defer iperfServerLock.Unlock()
	if current := iperfServerCurrent; current != nil {
		_ = current.Close()
		iperfServerCurrent = nil
		releaseToolMemory()
	}
	return true
}
