package toolbox

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/netip"
	"os"
	"path/filepath"
	"testing"
	"time"

	"core/state"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func enabledTrafficOptions(offset int) state.TrafficStatsOptions {
	options := state.DefaultTrafficStatsOptions()
	options.Enable = true
	options.TzOffset = offset
	return options
}

func newTestTrafficCollector(t *testing.T, offset int) *trafficCollector {
	t.Helper()
	collector := newTrafficCollector()
	collector.init(t.TempDir())
	collector.configure(enabledTrafficOptions(offset), "Sub")
	t.Cleanup(func() {
		collector.configure(state.DefaultTrafficStatsOptions(), "")
	})
	return collector
}

func useTrafficNow(t *testing.T, now time.Time) {
	t.Helper()
	previous := trafficNow
	trafficNow = func() time.Time { return now }
	t.Cleanup(func() { trafficNow = previous })
}

func newTrafficInfo(host, process string, chain []string, direct bool, up, down int64) *statistic.TrackerInfo {
	info := &statistic.TrackerInfo{
		Metadata: &constant.Metadata{Host: host, Process: process, ProcessPath: "/bin/" + process},
		Chain:    chain,
		IsDirect: direct,
	}
	info.UploadTotal.Store(up)
	info.DownloadTotal.Store(down)
	return info
}

func TestTrafficStatsDefaultsOffWithMonthLimit(t *testing.T) {
	options := state.DefaultTrafficStatsOptions()
	if options.Enable || options.RetentionDays != 7 {
		t.Fatalf("unexpected defaults: %+v", options)
	}
	collector := newTrafficCollector()
	collector.init(t.TempDir())
	collector.observe("a", newTrafficInfo("example.com", "", nil, false, 1, 1), true)
	if collector.enabled.Load() || collector.timer != nil || len(collector.days) != 0 {
		t.Fatal("collector should stay idle while disabled")
	}
	options.Enable = true
	options.RetentionDays = 400
	collector.configure(options, "")
	if !collector.enabled.Load() || collector.options.RetentionDays != trafficMaxRetention {
		t.Fatalf("unexpected enabled state: %+v", collector.options)
	}
	if collector.timer != nil {
		t.Fatal("timer should wait for traffic")
	}
	collector.observe("b", newTrafficInfo("example.com", "", nil, false, 1, 1), true)
	if collector.timer == nil {
		t.Fatal("recorded traffic should arm the flush timer")
	}
	collector.configure(state.DefaultTrafficStatsOptions(), "")
	if collector.enabled.Load() || collector.timer != nil {
		t.Fatal("disabling should stop the timer")
	}
}

func TestTrafficStatsTimerFollowsLiveConnections(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	collector.observe("live", newTrafficInfo("example.com", "", nil, false, 1, 1), false)
	collector.mu.Lock()
	collector.timer.Stop()
	collector.timer = nil
	collector.mu.Unlock()

	collector.tick()
	if collector.timer == nil {
		t.Fatal("live connection should keep sampling")
	}
	collector.mu.Lock()
	collector.timer.Stop()
	collector.timer = nil
	collector.mu.Unlock()

	collector.tick()
	if collector.timer != nil {
		t.Fatal("timer should stop once no live connection remains")
	}
	if day := readTrafficDay(filepath.Join(collector.dir, "2026-10-24.dat")); day == nil || day.Total != (trafficPair{1, 1}) {
		t.Fatalf("tick should flush dirty data: %+v", day)
	}
}

func TestTrafficStatsCountsDeltasOnce(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	info := newTrafficInfo("rr1.googlevideo.com", "chrome", []string{"HK 01", "Proxy"}, false, 100, 1000)

	collector.observe("a", info, false)
	info.UploadTotal.Store(150)
	info.DownloadTotal.Store(1600)
	collector.observe("a", info, false)
	collector.mu.Lock()
	collector.sampling++
	collector.mu.Unlock()
	info.DownloadTotal.Store(2000)
	collector.observe("a", info, true)
	collector.observe("a", info, true)

	day := collector.days["2026-10-24"]
	if day == nil {
		t.Fatal("missing day bucket")
	}
	if day.Total != (trafficPair{150, 2000}) || day.Proxy != (trafficPair{150, 2000}) {
		t.Fatalf("unexpected totals: %v proxy %v", day.Total, day.Proxy)
	}
	host := day.Hosts["googlevideo.com"]
	if host == nil || host.Traffic != (trafficPair{150, 2000}) {
		t.Fatalf("unexpected host entry: %+v", host)
	}
	if sub := host.Subs["rr1.googlevideo.com"]; sub == nil || *sub != (trafficPair{150, 2000}) {
		t.Fatalf("unexpected sub entry: %+v", host.Subs)
	}
	if node := day.Nodes["HK 01"]; node == nil || node.Traffic.sum() != 2150 {
		t.Fatalf("unexpected node entry: %+v", day.Nodes)
	}
	if process := day.Processes["chrome"]; process == nil || process.Path != "/bin/chrome" {
		t.Fatalf("unexpected process entry: %+v", day.Processes)
	}
	if profile := day.Profiles["Sub"]; profile == nil || profile.Traffic.sum() != 2150 {
		t.Fatalf("unexpected profile entry: %+v", day.Profiles)
	}
	collector.observe("a", newTrafficInfo("rr1.googlevideo.com", "chrome", nil, false, 0, 0), false)
	if day.Total != (trafficPair{150, 2000}) {
		t.Fatalf("stale sample after close counted again: %v", day.Total)
	}
	collector.mu.Lock()
	collector.sampling--
	collector.mu.Unlock()
	collector.sample()
	if len(collector.conns) != 0 {
		t.Fatalf("closed connection should be forgotten, got %d", len(collector.conns))
	}
}

func TestTrafficStatsForgetsClosedConnectionImmediately(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	info := newTrafficInfo("example.com", "curl", nil, true, 10, 20)

	collector.observe("a", info, false)
	info.DownloadTotal.Store(50)
	collector.observe("a", info, true)

	if len(collector.conns) != 0 {
		t.Fatalf("closed connection should be removed without pending sample, got %d", len(collector.conns))
	}
	if day := collector.days["2026-10-24"]; day == nil || day.Total != (trafficPair{10, 50}) {
		t.Fatalf("unexpected totals: %+v", day)
	}
}

func TestTrafficStatsUsesLocalDayAndDirectSplit(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 17, 30, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 8*60)
	collector.observe("a", newTrafficInfo("example.com", "", []string{"DIRECT"}, true, 10, 20), true)

	day := collector.days["2026-10-25"]
	if day == nil {
		t.Fatalf("expected local day bucket, got %v", collector.days)
	}
	if day.Hours[1] != (trafficPair{10, 20}) {
		t.Fatalf("expected local hour 1, got %v", day.Hours)
	}
	if day.Proxy != (trafficPair{}) {
		t.Fatalf("direct traffic should not count as proxy: %v", day.Proxy)
	}
	if len(day.Processes) != 0 {
		t.Fatalf("empty process should be skipped: %v", day.Processes)
	}
}

func TestTrafficStatsDetailDisabledKeepsTotalsOnly(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	options := enabledTrafficOptions(0)
	options.Detail = false
	collector.configure(options, "Sub")
	collector.observe("a", newTrafficInfo("example.com", "app", []string{"Node"}, false, 1, 2), true)

	day := collector.days["2026-10-24"]
	if day.Total.sum() != 3 || day.Hosts != nil || day.Nodes != nil || day.Profiles != nil {
		t.Fatalf("unexpected day: %+v", day)
	}
}

func TestTrafficStatsDisabledIgnoresTraffic(t *testing.T) {
	collector := newTestTrafficCollector(t, 0)
	collector.configure(state.DefaultTrafficStatsOptions(), "")
	collector.observe("a", newTrafficInfo("example.com", "", nil, false, 1, 2), true)
	if len(collector.days) != 0 || len(collector.dirty) != 0 {
		t.Fatalf("disabled collector recorded traffic: %v", collector.days)
	}
}

func TestTrafficDomainGroupsByRegistrableDomain(t *testing.T) {
	cases := map[string]string{
		"rr3---sn-x.googlevideo.com": "googlevideo.com",
		"news.bbc.co.uk":             "bbc.co.uk",
		"1.1.1.1":                    "1.1.1.1",
		"localhost":                  "localhost",
		"":                           "",
	}
	for host, want := range cases {
		if got := trafficDomain(host); got != want {
			t.Errorf("trafficDomain(%q) = %q, want %q", host, got, want)
		}
	}
}

func TestTrafficStatsIPWithoutHost(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	info := newTrafficInfo("", "", nil, false, 5, 5)
	info.Metadata.DstIP = netip.MustParseAddr("::ffff:8.8.8.8")
	collector.observe("a", info, true)
	if entry := collector.days["2026-10-24"].Hosts["8.8.8.8"]; entry == nil {
		t.Fatalf("expected IP host entry: %v", collector.days["2026-10-24"].Hosts)
	}
}

func TestTrafficStatsFlushWritesDailyShards(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	options := enabledTrafficOptions(0)
	options.RetentionDays = 3
	collector.configure(options, "")
	yesterday := &trafficDay{Total: trafficPair{1, 1}, Hosts: map[string]*trafficEntry{}}
	for i := range trafficHostLimit + 5 {
		yesterday.Hosts[fmt.Sprintf("host-%03d.com", i)] = &trafficEntry{Traffic: trafficPair{int64(i), 0}}
	}
	collector.days["2026-10-23"] = yesterday
	collector.dirty["2026-10-23"] = true
	if err := os.MkdirAll(collector.dir, 0o755); err != nil {
		t.Fatal(err)
	}
	expired := filepath.Join(collector.dir, "2026-10-21.dat")
	if err := os.WriteFile(expired, []byte(`{}`), 0o644); err != nil {
		t.Fatal(err)
	}
	collector.observe("a", newTrafficInfo("example.com", "", nil, false, 3, 4), true)
	collector.flush()

	if _, err := os.Stat(expired); !os.IsNotExist(err) {
		t.Fatal("expired shard should be removed")
	}
	if _, ok := collector.days["2026-10-23"]; ok {
		t.Fatal("finished day should be released from memory")
	}
	if collector.days["2026-10-24"] == nil {
		t.Fatal("today should stay in memory")
	}
	stored := readTrafficDay(filepath.Join(collector.dir, "2026-10-23.dat"))
	if stored == nil || len(stored.Hosts) != trafficHostLimit+1 {
		t.Fatalf("expected pruned shard, got %d hosts", len(stored.Hosts))
	}
	if others := stored.Hosts[""]; others == nil || others.Traffic[0] != 0+1+2+3+4 {
		t.Fatalf("unexpected others entry: %+v", others)
	}
	today := readTrafficDay(filepath.Join(collector.dir, "2026-10-24.dat"))
	if today == nil || today.Total != (trafficPair{3, 4}) {
		t.Fatalf("today shard not written: %+v", today)
	}
	if keys := listTrafficDays(collector.dir); len(keys) != 2 {
		t.Fatalf("unexpected shards: %v", keys)
	}

	collector.observe("b", newTrafficInfo("example.com", "", nil, false, 1, 1), true)
	collector.flush()
	if day := readTrafficDay(filepath.Join(collector.dir, "2026-10-23.dat")); day == nil || day.Total != (trafficPair{1, 1}) {
		t.Fatal("finished shard should not be rewritten")
	}
}

func TestTrafficStatsQueryAggregatesRange(t *testing.T) {
	collector := newTestTrafficCollector(t, 0)
	useTrafficNow(t, time.Date(2026, 10, 20, 3, 0, 0, 0, time.UTC))
	collector.observe("a", newTrafficInfo("a.example.com", "app", []string{"N1"}, false, 10, 100), true)
	useTrafficNow(t, time.Date(2026, 10, 22, 5, 0, 0, 0, time.UTC))
	collector.observe("b", newTrafficInfo("b.example.com", "app", []string{"DIRECT"}, true, 1, 10), true)
	collector.observe("c", newTrafficInfo("other.net", "tool", []string{"N2"}, false, 0, 5), true)
	collector.flush()
	if _, ok := collector.days["2026-10-20"]; ok {
		t.Fatal("past day should be read back from its shard")
	}

	result := collector.query(TrafficStatsQuery{Start: "2026-10-20", End: "2026-10-26", Top: 10})
	if result.Up != 11 || result.Down != 115 || result.ProxyUp != 10 || result.ProxyDown != 105 {
		t.Fatalf("unexpected totals: %+v", result)
	}
	if len(result.Series) != 7 || result.Series[2].Down != 15 || result.Series[1].Down != 0 {
		t.Fatalf("unexpected series: %+v", result.Series)
	}
	if len(result.Hosts) != 2 || result.Hosts[0].Name != "example.com" || result.Hosts[0].Down != 110 {
		t.Fatalf("unexpected hosts: %+v", result.Hosts)
	}
	if result.Since != "2026-10-20" {
		t.Fatalf("unexpected since: %s", result.Since)
	}

	day := collector.query(TrafficStatsQuery{Start: "2026-10-22", End: "2026-10-22"})
	if len(day.Series) != 24 || day.Series[5].Down != 15 {
		t.Fatalf("expected hourly series: %+v", day.Series)
	}

	host := collector.query(TrafficStatsQuery{Start: "2026-10-20", End: "2026-10-22", Host: "example.com"})
	if host.Down != 110 || len(host.Series) != 3 || len(host.Hosts) != 1 || len(host.Hosts[0].Subs) != 2 {
		t.Fatalf("unexpected host detail: %+v", host)
	}
}

func TestTrafficStatsReloadAndClear(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	collector.observe("a", newTrafficInfo("example.com", "", nil, false, 3, 4), true)
	collector.flush()

	path := filepath.Join(collector.dir, "2026-10-24.dat")
	content, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if json.Valid(content) || bytes.Contains(content, []byte("example.com")) {
		t.Fatalf("shard should not be plain text: %q", content)
	}
	if stored := readTrafficDay(path); stored == nil || stored.Total != (trafficPair{3, 4}) {
		t.Fatalf("unexpected shard: %+v", stored)
	}

	reloaded := newTrafficCollector()
	reloaded.init(collector.dir)
	reloaded.configure(enabledTrafficOptions(0), "")
	t.Cleanup(func() { reloaded.configure(state.DefaultTrafficStatsOptions(), "") })
	reloaded.observe("b", newTrafficInfo("example.com", "", nil, false, 1, 1), true)
	if day := reloaded.days["2026-10-24"]; day == nil || day.Total != (trafficPair{4, 5}) {
		t.Fatalf("today shard should resume from disk: %+v", day)
	}

	collector.clear()
	if keys := listTrafficDays(collector.dir); len(keys) != 0 {
		t.Fatalf("clear should remove shards: %v", keys)
	}
	if result := collector.query(TrafficStatsQuery{Start: "2026-10-24", End: "2026-10-24"}); result.Up != 0 || result.Since != "" {
		t.Fatalf("clear did not reset data: %+v", result)
	}
}

func TestTrafficStatsScreenOffWidensFlushInterval(t *testing.T) {
	now := time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC)
	useTrafficNow(t, now)
	collector := newTestTrafficCollector(t, 0)
	collector.setScreenOn(false)
	collector.observe("a", newTrafficInfo("example.com", "", nil, false, 1, 1), true)
	if collector.timer == nil || collector.timerDue.Sub(now) != trafficScreenOffFlush {
		t.Fatalf("screen off should schedule a %v flush, got %v", trafficScreenOffFlush, collector.timerDue.Sub(now))
	}
	first := collector.timer
	collector.setScreenOn(true)
	if collector.timer == nil || collector.timer == first || collector.timerDue.Sub(now) != trafficFlushInterval {
		t.Fatalf("screen on should bring the flush back to %v, got %v", trafficFlushInterval, collector.timerDue.Sub(now))
	}
	second := collector.timer
	collector.setScreenOn(true)
	if collector.timer != second {
		t.Fatal("an already short timer should be kept")
	}
}

func TestTrafficStatsSuspendFlushesThenPauses(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	collector.observe("a", newTrafficInfo("example.com", "", nil, false, 1, 1), true)

	collector.setSuspended(true)
	if collector.timer != nil {
		t.Fatal("suspend should stop the timer")
	}
	if day := readTrafficDay(filepath.Join(collector.dir, "2026-10-24.dat")); day == nil || day.Total != (trafficPair{1, 1}) {
		t.Fatalf("suspend should flush pending data first: %+v", day)
	}

	collector.observe("b", newTrafficInfo("example.com", "", nil, false, 2, 2), true)
	if collector.timer != nil || !collector.dirty["2026-10-24"] {
		t.Fatal("traffic during suspend should stay in memory without scheduling writes")
	}
	if day := readTrafficDay(filepath.Join(collector.dir, "2026-10-24.dat")); day.Total != (trafficPair{1, 1}) {
		t.Fatal("nothing should be written while suspended")
	}

	collector.setSuspended(false)
	if collector.timer == nil {
		t.Fatal("resume should schedule the pending write")
	}
	collector.setSuspended(false)
}

func TestTrafficStatsRecordsRuleHits(t *testing.T) {
	collector := newTestTrafficCollector(t, 0)
	useTrafficNow(t, time.Date(2026, 10, 20, 3, 0, 0, 0, time.UTC))
	cn := newTrafficInfo("a.cn", "", []string{"DIRECT"}, true, 0, 0)
	cn.Rule, cn.RulePayload = "RuleSet", "cn"
	collector.observe("a", cn, false)
	cn.DownloadTotal.Store(40)
	collector.observe("a", cn, true)
	useTrafficNow(t, time.Date(2026, 10, 21, 3, 0, 0, 0, time.UTC))
	for _, id := range []string{"b", "c"} {
		info := newTrafficInfo("b.cn", "", []string{"DIRECT"}, true, 1, 2)
		info.Rule, info.RulePayload = "RuleSet", "cn"
		collector.observe(id, info, true)
	}
	match := newTrafficInfo("x.com", "", []string{"HK 01", "Proxy"}, false, 0, 500)
	match.Rule = "Match"
	collector.observe("d", match, true)
	collector.observe("e", newTrafficInfo("y.com", "", []string{"HK 01", "GLOBAL"}, false, 0, 9), true)
	collector.flush()

	result := collector.query(TrafficStatsQuery{Start: "2026-10-20", End: "2026-10-21"})
	if result.RuleHits != 4 || len(result.Rules) != 2 {
		t.Fatalf("unexpected rules: %d %+v", result.RuleHits, result.Rules)
	}
	first, second := result.Rules[0], result.Rules[1]
	if first.Name != "RuleSet,cn" || first.Hits != 3 || first.Down != 44 || first.Path != "" {
		t.Fatalf("unexpected first rule: %+v", first)
	}
	if second.Name != "Match" || second.Hits != 1 || second.Down != 500 {
		t.Fatalf("unexpected second rule: %+v", second)
	}

	options := enabledTrafficOptions(0)
	options.Detail = false
	collector.configure(options, "Sub")
	collector.observe("f", match, true)
	if day := collector.days["2026-10-21"]; day != nil && day.Rules["Match"].Hits != 1 {
		t.Fatalf("detail off should skip rule hits: %+v", day.Rules)
	}
}

func TestTrafficStatsPrunesRulesByHits(t *testing.T) {
	day := &trafficDay{Rules: map[string]*trafficEntry{}}
	for index := range trafficRuleLimit + trafficRuleLimit/4 {
		day.Rules[fmt.Sprintf("Domain,%d", index)] = &trafficEntry{Hits: int64(index + 10), Traffic: trafficPair{0, 1}}
	}
	addTrafficRule(day, trafficConnKey{rule: "Domain,big"}, 0, 0, 1<<30)
	if len(day.Rules) != trafficRuleLimit+1 || day.Rules["Domain,big"] != nil || day.Rules[""] == nil {
		t.Fatalf("expected pruning by hits, got %d rules", len(day.Rules))
	}
}

type trafficTestTracker struct {
	info *statistic.TrackerInfo
}

func (f *trafficTestTracker) ID() string                           { return f.info.UUID.String() }
func (f *trafficTestTracker) Close() error                         { return nil }
func (f *trafficTestTracker) Info() *statistic.TrackerInfo         { return f.info }
func (f *trafficTestTracker) Chains() constant.Chain               { return nil }
func (f *trafficTestTracker) ProviderChains() constant.Chain       { return nil }
func (f *trafficTestTracker) AppendToChains(constant.ProxyAdapter) {}
func (f *trafficTestTracker) RemoteDestination() string            { return "" }

func joinTrafficTracker(t *testing.T, info *statistic.TrackerInfo) {
	t.Helper()
	info.UUID = [16]byte{0xbe, 0x77}
	tracker := &trafficTestTracker{info: info}
	statistic.DefaultManager.Join(tracker)
	t.Cleanup(func() { statistic.DefaultManager.Leave(tracker) })
}

func TestTrafficStatsDisableReleasesMemory(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	collector := newTestTrafficCollector(t, 0)
	collector.observe("live", newTrafficInfo("example.com", "", nil, false, 1, 2), false)
	collector.observe("done", newTrafficInfo("example.com", "", nil, false, 3, 4), true)
	if len(collector.days) != 1 || len(collector.conns) != 1 {
		t.Fatalf("unexpected state: %d days %d conns", len(collector.days), len(collector.conns))
	}

	collector.configure(state.DefaultTrafficStatsOptions(), "")
	collector.flush()
	if len(collector.days) != 0 || len(collector.conns) != 0 || collector.timer != nil {
		t.Fatalf("disabled collector should hold nothing: %d days %d conns", len(collector.days), len(collector.conns))
	}
	result := collector.query(TrafficStatsQuery{Start: "2026-10-24", End: "2026-10-24"})
	if result.Up != 4 || result.Down != 6 {
		t.Fatalf("stored data should stay readable: %+v", result)
	}
}

func TestTrafficStatsEnableCountsOnlyNewTraffic(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 10, 24, 3, 0, 0, 0, time.UTC))
	info := newTrafficInfo("example.com", "", nil, false, 100, 1000)
	joinTrafficTracker(t, info)
	collector := newTestTrafficCollector(t, 0)

	info.UploadTotal.Store(150)
	info.DownloadTotal.Store(1600)
	collector.sample()
	if day := collector.days["2026-10-24"]; day == nil || day.Total != (trafficPair{50, 600}) {
		t.Fatalf("traffic before enabling should be skipped: %+v", day)
	}

	collector.configure(state.DefaultTrafficStatsOptions(), "")
	collector.flush()
	info.UploadTotal.Store(200)
	info.DownloadTotal.Store(2000)
	collector.configure(enabledTrafficOptions(0), "Sub")
	info.UploadTotal.Store(210)
	info.DownloadTotal.Store(2100)
	collector.sample()
	if day := collector.days["2026-10-24"]; day == nil || day.Total != (trafficPair{60, 700}) {
		t.Fatalf("re-enabling should neither recount nor count the paused period: %+v", day)
	}
}
