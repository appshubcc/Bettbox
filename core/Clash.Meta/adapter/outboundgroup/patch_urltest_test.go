package outboundgroup

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
	P "github.com/metacubex/mihomo/constant/provider"

	"github.com/stretchr/testify/require"
)

type urlTestFakeProvider struct {
	P.ProxyProvider
	proxies []C.Proxy
}

func (f *urlTestFakeProvider) Name() string               { return "p" }
func (f *urlTestFakeProvider) VehicleType() P.VehicleType { return P.File }
func (f *urlTestFakeProvider) Proxies() []C.Proxy         { return f.proxies }
func (f *urlTestFakeProvider) Version() uint32            { return 1 }
func (f *urlTestFakeProvider) Touch()                     {}
func (f *urlTestFakeProvider) HealthCheckURL() string     { return "" }

func urlTestProxy(name string) C.Proxy {
	return adapter.NewProxy(outbound.NewDirectWithOption(outbound.DirectOption{Name: name}))
}

func TestURLTestLeavesAnUnmeasuredPickOnceAMemberIsMeasured(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	defer server.Close()

	first, measured := urlTestProxy("first"), urlTestProxy("measured")
	group, err := NewURLTest(
		GroupCommonOption{Name: "auto", URL: server.URL},
		URLTestOption{},
		urlTestProxy("COMPATIBLE"),
		[]P.ProxyProvider{&urlTestFakeProvider{proxies: []C.Proxy{first, measured}}},
	)
	require.NoError(t, err)
	require.Equal(t, "first", group.Now())

	_, err = measured.URLTest(context.Background(), server.URL, nil)
	require.NoError(t, err)
	require.Equal(t, "first", group.Now())

	time.Sleep(unmeasuredPickHold)
	require.Equal(t, "measured", group.Now())
}

func TestURLTestKeepsAMeasuredPick(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	defer server.Close()

	first, second := urlTestProxy("first"), urlTestProxy("second")
	_, err := first.URLTest(context.Background(), server.URL, nil)
	require.NoError(t, err)
	group, err := NewURLTest(
		GroupCommonOption{Name: "auto", URL: server.URL},
		URLTestOption{},
		urlTestProxy("COMPATIBLE"),
		[]P.ProxyProvider{&urlTestFakeProvider{proxies: []C.Proxy{first, second}}},
	)
	require.NoError(t, err)
	require.Equal(t, "first", group.Now())

	_, err = second.URLTest(context.Background(), server.URL, nil)
	require.NoError(t, err)
	time.Sleep(unmeasuredPickHold)
	require.Equal(t, "first", group.Now())
}
