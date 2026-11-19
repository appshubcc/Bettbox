package toolbox

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/proxydialer"
)

const (
	nodeTestURL     = "http://www.msftncsi.com/ncsi.txt"
	nodeTestTimeout = 10 * time.Second
)

type nodeTestResult struct {
	Delay int    `json:"delay"`
	Error string `json:"error"`
}

type nodeTestParams struct {
	Proxy  map[string]any `json:"proxy"`
	Dialer string         `json:"dialer"`
}

func testNode(ctx context.Context, mapping map[string]any, dialer string) (int, error) {
	delete(mapping, "dialer-proxy")
	var options []adapter.ProxyOption
	if dialer != "" {
		front, ok := FindProxy(dialer)
		if !ok {
			return 0, fmt.Errorf("front %s not found", dialer)
		}
		mapping["dialer-proxy"] = dialer
		options = append(options, adapter.WithDialerForAPI(proxydialer.New(front, true)))
	}
	proxy, err := adapter.ParseProxy(mapping, options...)
	if err != nil {
		return 0, err
	}
	defer func() { _ = proxy.Close() }()
	expected, err := utils.NewUnsignedRanges[uint16]("200")
	if err != nil {
		return 0, err
	}
	delay, err := proxy.URLTest(ctx, nodeTestURL, expected)
	return int(delay), err
}

func HandleTestNode(data string) string {
	result := nodeTestResult{}
	var params nodeTestParams
	if err := json.Unmarshal([]byte(data), &params); err != nil {
		result.Error = err.Error()
	} else if params.Proxy == nil {
		result.Error = "missing proxy"
	} else {
		ctx, cancel := context.WithTimeout(context.Background(), nodeTestTimeout)
		defer cancel()
		delay, err := testNode(ctx, params.Proxy, params.Dialer)
		result.Delay = delay
		if err != nil {
			result.Error = err.Error()
		}
	}
	encoded, _ := json.Marshal(result)
	return string(encoded)
}
