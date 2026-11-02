package main

import (
	"encoding/json"
	"reflect"
	"testing"
	"time"

	"core/state"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

type fakeTracker struct {
	info *statistic.TrackerInfo
}

func (f *fakeTracker) ID() string                           { return f.info.UUID.String() }
func (f *fakeTracker) Close() error                         { return nil }
func (f *fakeTracker) Info() *statistic.TrackerInfo         { return f.info }
func (f *fakeTracker) Chains() constant.Chain               { return nil }
func (f *fakeTracker) ProviderChains() constant.Chain       { return nil }
func (f *fakeTracker) AppendToChains(constant.ProxyAdapter) {}
func (f *fakeTracker) RemoteDestination() string            { return "" }

var fakeTrackerSeq byte

func joinFakeTracker(t *testing.T, metadata *constant.Metadata, start time.Time) *statistic.TrackerInfo {
	t.Helper()
	fakeTrackerSeq++
	info := &statistic.TrackerInfo{
		UUID:     [16]byte{fakeTrackerSeq},
		Metadata: metadata,
		Start:    start,
	}
	tracker := &fakeTracker{info: info}
	statistic.DefaultManager.Join(tracker)
	t.Cleanup(func() { statistic.DefaultManager.Leave(tracker) })
	return info
}

func TestCollectConnectionsSpeed(t *testing.T) {
	resetConnectionRates()
	info := joinFakeTracker(t, &constant.Metadata{NetWork: constant.TCP}, time.Now())
	base := time.Now()
	first := collectConnections(base)
	if len(first) != 1 || first[0].UploadSpeed != 0 || first[0].DownloadSpeed != 0 {
		t.Fatalf("first = %+v", first)
	}
	info.UploadTotal.Store(2000)
	info.DownloadTotal.Store(8000)
	early := collectConnections(base.Add(100 * time.Millisecond))
	if early[0].UploadSpeed != 0 {
		t.Fatalf("speed inside the window = %d", early[0].UploadSpeed)
	}
	second := collectConnections(base.Add(2 * time.Second))
	if second[0].UploadSpeed != 1000 || second[0].DownloadSpeed != 4000 {
		t.Fatalf("second = %d/%d", second[0].UploadSpeed, second[0].DownloadSpeed)
	}
	data, err := json.Marshal(second)
	if err != nil {
		t.Fatal(err)
	}
	var decoded []map[string]any
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded[0]["upload"] != float64(2000) || decoded[0]["uploadSpeed"] != float64(1000) || decoded[0]["id"] != info.UUID.String() {
		t.Fatalf("json = %v", decoded[0])
	}
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		statistic.DefaultManager.Leave(c)
		return true
	})
	collectConnections(base.Add(3 * time.Second))
	connectionRatesLock.Lock()
	remaining := len(connectionRates)
	connectionRatesLock.Unlock()
	if remaining != 0 {
		t.Fatalf("stale rates = %d", remaining)
	}
}

func TestSummarizeConnections(t *testing.T) {
	start := time.Now().Add(-10 * time.Minute)
	joinFakeTracker(t, &constant.Metadata{NetWork: constant.TCP, Host: "mtalk.Google.com", DstPort: 5228}, start.Add(time.Minute))
	joinFakeTracker(t, &constant.Metadata{NetWork: constant.TCP, Host: "alt1-mtalk.google.com", DstPort: 5230}, start)
	joinFakeTracker(t, &constant.Metadata{NetWork: constant.TCP, Host: "www.google.com", DstPort: 443}, start.Add(-time.Hour))
	joinFakeTracker(t, &constant.Metadata{NetWork: constant.UDP, Host: "example.com", DstPort: 5228}, start.Add(-time.Hour))
	joinFakeTracker(t, &constant.Metadata{NetWork: constant.TCP, Host: "mtalk.google.com", DstPort: 443}, start.Add(-30*time.Minute))
	summary := summarizeConnections()
	if summary.Total != 5 || summary.TCP != 4 || summary.UDP != 1 {
		t.Fatalf("summary = %+v", summary)
	}
	want := start.Add(-30 * time.Minute).UnixMilli()
	if summary.FcmStart != want {
		t.Fatalf("fcm start = %d, want %d", summary.FcmStart, want)
	}
}

func TestIsFcmConnection(t *testing.T) {
	for _, c := range []struct {
		host string
		port uint16
		want bool
	}{
		{"mtalk.google.com", 5228, true},
		{"alt3-mtalk.google.com", 5229, true},
		{"mtalk.google.com", 443, true},
		{"alt1-mtalk.google.com", 443, true},
		{"www.google.com", 443, false},
		{"example-mtalk.google.com.evil.com", 443, false},
		{"example.com", 5228, false},
		{"mtalk.google.com", 80, false},
	} {
		got := isFcmConnection(&constant.Metadata{Host: c.host, DstPort: c.port})
		if got != c.want {
			t.Errorf("%s:%d = %v, want %v", c.host, c.port, got, c.want)
		}
	}
}

func TestTrafficSnapshotMatchesSeparateReads(t *testing.T) {
	statistic.DefaultManager.ResetStatistic()
	previous := state.CurrentState.OnlyStatisticsProxy
	defer func() {
		state.CurrentState.OnlyStatisticsProxy = previous
		statistic.DefaultManager.ResetStatistic()
	}()
	statistic.DefaultManager.PushUploaded(false, 1500)
	statistic.DefaultManager.PushDownloaded(true, 4200)
	for _, c := range []struct {
		onlyProxy bool
		up, down  int64
	}{
		{false, 1500, 4200},
		{true, 1500, 0},
	} {
		state.CurrentState.OnlyStatisticsProxy = c.onlyProxy
		var snapshot struct {
			Now   map[string]int64 `json:"now"`
			Total map[string]int64 `json:"total"`
		}
		if err := json.Unmarshal([]byte(handleGetTrafficSnapshot()), &snapshot); err != nil {
			t.Fatal(err)
		}
		var now, total map[string]int64
		if err := json.Unmarshal([]byte(handleGetTraffic()), &now); err != nil {
			t.Fatal(err)
		}
		if err := json.Unmarshal([]byte(handleGetTotalTraffic()), &total); err != nil {
			t.Fatal(err)
		}
		if snapshot.Total["up"] != c.up || snapshot.Total["down"] != c.down {
			t.Fatalf("onlyProxy=%v total = %v", c.onlyProxy, snapshot.Total)
		}
		if !reflect.DeepEqual(snapshot.Total, total) || !reflect.DeepEqual(snapshot.Now, now) {
			t.Fatalf("onlyProxy=%v snapshot = %+v, separate = %v / %v", c.onlyProxy, snapshot, now, total)
		}
	}
}
