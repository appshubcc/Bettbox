package toolbox

import (
	"cmp"
	"encoding/json"
	"net/netip"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"core/state"

	"github.com/metacubex/mihomo/tunnel/statistic"
	"golang.org/x/net/publicsuffix"
)

const (
	trafficStatsDir        = "traffic_stats"
	trafficStatsExt        = ".dat"
	trafficFlushInterval   = 5 * time.Minute
	trafficScreenOffFlush  = 15 * time.Minute
	trafficDayLayout       = "2006-01-02"
	trafficMaxRetention    = 30
	trafficHostLimit       = 200
	trafficSubLimit        = 20
	trafficProcessLimit    = 100
	trafficNodeLimit       = 100
	trafficProfileLimit    = 50
	trafficRuleLimit       = 100
	trafficMaxSeriesDays   = 400
	trafficDefaultQueryTop = 50
)

type trafficPair [2]int64

func (p *trafficPair) add(up, down int64) {
	p[0] += up
	p[1] += down
}

func (p trafficPair) sum() int64 {
	return p[0] + p[1]
}

type trafficEntry struct {
	Traffic trafficPair             `json:"t"`
	Hits    int64                   `json:"h,omitempty"`
	Path    string                  `json:"p,omitempty"`
	Subs    map[string]*trafficPair `json:"s,omitempty"`
}

type trafficDay struct {
	Total     trafficPair              `json:"total"`
	Proxy     trafficPair              `json:"proxy"`
	Hours     [24]trafficPair          `json:"hours"`
	Hosts     map[string]*trafficEntry `json:"hosts,omitempty"`
	Processes map[string]*trafficEntry `json:"processes,omitempty"`
	Nodes     map[string]*trafficEntry `json:"nodes,omitempty"`
	Profiles  map[string]*trafficEntry `json:"profiles,omitempty"`
	Rules     map[string]*trafficEntry `json:"rules,omitempty"`
}

type trafficConnKey struct {
	host    string
	domain  string
	process string
	path    string
	node    string
	profile string
	rule    string
	direct  bool
}

type trafficConn struct {
	up     int64
	down   int64
	seen   uint64
	closed bool
	key    trafficConnKey
}

type trafficCollector struct {
	mu         sync.Mutex
	writeMu    sync.Mutex
	enabled    atomic.Bool
	dir        string
	days       map[string]*trafficDay
	dirty      map[string]bool
	conns      map[string]*trafficConn
	options    state.TrafficStatsOptions
	profile    string
	generation uint64
	sampling   int
	cleaned    string
	timer      *time.Timer
	timerDue   time.Time
	screenOff  bool
	suspended  bool
}

type TrafficStatsQuery struct {
	Start string `json:"start"`
	End   string `json:"end"`
	Top   int    `json:"top"`
	Host  string `json:"host"`
}

type TrafficStatsItem struct {
	Name string             `json:"name"`
	Up   int64              `json:"up"`
	Down int64              `json:"down"`
	Hits int64              `json:"hits,omitempty"`
	Path string             `json:"path,omitempty"`
	Subs []TrafficStatsItem `json:"subs,omitempty"`
}

type TrafficStatsPoint struct {
	Label string `json:"label"`
	Up    int64  `json:"up"`
	Down  int64  `json:"down"`
}

type TrafficStatsResult struct {
	Up        int64               `json:"up"`
	Down      int64               `json:"down"`
	ProxyUp   int64               `json:"proxy-up"`
	ProxyDown int64               `json:"proxy-down"`
	Series    []TrafficStatsPoint `json:"series"`
	Hosts     []TrafficStatsItem  `json:"hosts"`
	Processes []TrafficStatsItem  `json:"processes"`
	Nodes     []TrafficStatsItem  `json:"nodes"`
	Profiles  []TrafficStatsItem  `json:"profiles"`
	Rules     []TrafficStatsItem  `json:"rules"`
	RuleHits  int64               `json:"rule-hits"`
	Since     string              `json:"since"`
}

var (
	trafficNow   = time.Now
	trafficStats = newTrafficCollector()
)

func newTrafficCollector() *trafficCollector {
	return &trafficCollector{
		days:    map[string]*trafficDay{},
		dirty:   map[string]bool{},
		conns:   map[string]*trafficConn{},
		options: state.DefaultTrafficStatsOptions(),
	}
}

func InitTrafficStats(homeDir string) {
	trafficStats.init(filepath.Join(homeDir, trafficStatsDir))
}

func ConfigureTrafficStats(options state.TrafficStatsOptions, profile string) {
	trafficStats.configure(options, profile)
	if !options.Enable {
		trafficStats.flush()
	}
}

func ObserveTrafficTracker(info *statistic.TrackerInfo) {
	if info == nil || !trafficStats.enabled.Load() {
		return
	}
	trafficStats.observe(info.UUID.String(), info, true)
}

func FlushTrafficStats() {
	trafficStats.flush()
}

func SetTrafficScreenOn(on bool) {
	trafficStats.setScreenOn(on)
}

func SuspendTrafficStats(suspended bool) {
	trafficStats.setSuspended(suspended)
}

func HandleGetTrafficStats(paramsString string) string {
	query := TrafficStatsQuery{}
	_ = json.Unmarshal([]byte(paramsString), &query)
	data, _ := json.Marshal(trafficStats.query(query))
	return string(data)
}

func HandleClearTrafficStats() bool {
	trafficStats.clear()
	return true
}

func (c *trafficCollector) init(dir string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.dir != dir {
		c.dir = dir
		c.days = map[string]*trafficDay{}
		c.dirty = map[string]bool{}
		c.cleaned = ""
	}
	c.updateTimerLocked()
}

func (c *trafficCollector) configure(options state.TrafficStatsOptions, profile string) {
	if options.RetentionDays <= 0 || options.RetentionDays > trafficMaxRetention {
		options.RetentionDays = trafficMaxRetention
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	if options.RetentionDays != c.options.RetentionDays {
		c.cleaned = ""
	}
	c.options = options
	c.profile = profile
	c.updateTimerLocked()
}

func (c *trafficCollector) updateTimerLocked() {
	enabled := c.dir != "" && c.options.Enable
	if c.enabled.Swap(enabled) == enabled {
		return
	}
	if enabled {
		c.baselineLocked()
		return
	}
	c.stopTimerLocked()
	c.conns = map[string]*trafficConn{}
}

func (c *trafficCollector) baselineLocked() {
	c.conns = map[string]*trafficConn{}
	statistic.DefaultManager.Range(func(t statistic.Tracker) bool {
		info := t.Info()
		c.conns[t.ID()] = &trafficConn{
			up:   info.UploadTotal.Load(),
			down: info.DownloadTotal.Load(),
			seen: c.generation,
			key:  c.connKey(info),
		}
		return true
	})
}

func (c *trafficCollector) intervalLocked() time.Duration {
	if c.screenOff {
		return trafficScreenOffFlush
	}
	return trafficFlushInterval
}

func (c *trafficCollector) armLocked() {
	if c.timer != nil || c.suspended || !c.enabled.Load() {
		return
	}
	interval := c.intervalLocked()
	c.timerDue = trafficNow().Add(interval)
	c.timer = time.AfterFunc(interval, c.tick)
}

func (c *trafficCollector) stopTimerLocked() {
	if c.timer != nil {
		c.timer.Stop()
		c.timer = nil
	}
}

func (c *trafficCollector) hasLiveConnLocked() bool {
	for _, conn := range c.conns {
		if !conn.closed {
			return true
		}
	}
	return false
}

func (c *trafficCollector) tick() {
	c.mu.Lock()
	c.timer = nil
	c.mu.Unlock()
	c.sample()
	c.flush()
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.hasLiveConnLocked() {
		c.armLocked()
	}
}

func (c *trafficCollector) setScreenOn(on bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.screenOff = !on
	if on && c.timer != nil && c.timerDue.Sub(trafficNow()) > trafficFlushInterval {
		c.stopTimerLocked()
		c.armLocked()
	}
}

func (c *trafficCollector) setSuspended(suspended bool) {
	c.mu.Lock()
	if suspended {
		changed := !c.suspended
		c.suspended = true
		c.stopTimerLocked()
		c.mu.Unlock()
		if changed {
			c.flush()
		}
		return
	}
	defer c.mu.Unlock()
	if !c.suspended {
		return
	}
	c.suspended = false
	if len(c.dirty) > 0 || c.hasLiveConnLocked() {
		c.armLocked()
	}
}

func (c *trafficCollector) sample() {
	if !c.enabled.Load() {
		return
	}
	type tracked struct {
		id   string
		info *statistic.TrackerInfo
	}
	var items []tracked
	c.mu.Lock()
	c.sampling++
	c.mu.Unlock()
	statistic.DefaultManager.Range(func(t statistic.Tracker) bool {
		items = append(items, tracked{id: t.ID(), info: t.Info()})
		return true
	})
	c.mu.Lock()
	defer c.mu.Unlock()
	c.sampling--
	c.generation++
	for _, item := range items {
		c.observeLocked(item.id, item.info, false)
	}
	for id, conn := range c.conns {
		if (conn.closed && c.sampling == 0) || c.generation-conn.seen > 1 {
			delete(c.conns, id)
		}
	}
	if len(c.conns) == 0 {
		c.conns = map[string]*trafficConn{}
	}
}

func (c *trafficCollector) observe(id string, info *statistic.TrackerInfo, closed bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.observeLocked(id, info, closed)
}

func (c *trafficCollector) observeLocked(id string, info *statistic.TrackerInfo, closed bool) {
	if c.dir == "" || !c.options.Enable {
		return
	}
	up, down := info.UploadTotal.Load(), info.DownloadTotal.Load()
	conn := c.conns[id]
	if conn == nil {
		conn = &trafficConn{key: c.connKey(info)}
		c.conns[id] = conn
		c.recordHitLocked(conn.key)
	}
	if conn.closed {
		return
	}
	deltaUp, deltaDown := up-conn.up, down-conn.down
	if deltaUp < 0 {
		deltaUp = 0
	}
	if deltaDown < 0 {
		deltaDown = 0
	}
	conn.up, conn.down, conn.seen, conn.closed = up, down, c.generation, closed
	if closed && c.sampling == 0 {
		delete(c.conns, id)
	}
	if deltaUp == 0 && deltaDown == 0 {
		return
	}
	c.recordLocked(conn.key, deltaUp, deltaDown)
}

func (c *trafficCollector) connKey(info *statistic.TrackerInfo) trafficConnKey {
	key := trafficConnKey{profile: c.profile, direct: info.IsDirect}
	if len(info.Chain) > 0 {
		key.node = info.Chain[0]
	}
	key.rule = trafficRuleName(info.Rule, info.RulePayload)
	metadata := info.Metadata
	if metadata == nil {
		return key
	}
	host := normalizeTrafficHost(metadata.Host)
	if host == "" {
		host = normalizeTrafficHost(metadata.SniffHost)
	}
	if host == "" && metadata.DstIP.IsValid() {
		host = metadata.DstIP.Unmap().String()
	}
	key.host = host
	key.domain = trafficDomain(host)
	key.process = metadata.Process
	key.path = metadata.ProcessPath
	return key
}

func trafficRuleName(rule, payload string) string {
	if rule == "" || payload == "" {
		return rule
	}
	return rule + "," + payload
}

func normalizeTrafficHost(host string) string {
	return strings.TrimSuffix(strings.ToLower(strings.TrimSpace(host)), ".")
}

func trafficDomain(host string) string {
	if host == "" {
		return ""
	}
	if _, err := netip.ParseAddr(host); err == nil {
		return host
	}
	if domain, err := publicsuffix.EffectiveTLDPlusOne(host); err == nil {
		return domain
	}
	return host
}

func (c *trafficCollector) localNow() time.Time {
	return trafficNow().UTC().Add(time.Duration(c.options.TzOffset) * time.Minute)
}

func (c *trafficCollector) dayFile(key string) string {
	return filepath.Join(c.dir, key+trafficStatsExt)
}

func (c *trafficCollector) dayLocked(key string) *trafficDay {
	if day := c.days[key]; day != nil {
		return day
	}
	day := readTrafficDay(c.dayFile(key))
	if day == nil {
		day = &trafficDay{}
	}
	c.days[key] = day
	return day
}

func (c *trafficCollector) touchDayLocked(now time.Time) *trafficDay {
	dayKey := now.Format(trafficDayLayout)
	day := c.dayLocked(dayKey)
	c.dirty[dayKey] = true
	c.armLocked()
	return day
}

func (c *trafficCollector) recordHitLocked(key trafficConnKey) {
	if !c.options.Detail || key.rule == "" {
		return
	}
	addTrafficRule(c.touchDayLocked(c.localNow()), key, 1, 0, 0)
}

func (c *trafficCollector) recordLocked(key trafficConnKey, up, down int64) {
	now := c.localNow()
	day := c.touchDayLocked(now)
	day.Total.add(up, down)
	if !key.direct {
		day.Proxy.add(up, down)
	}
	day.Hours[now.Hour()].add(up, down)
	if !c.options.Detail {
		return
	}
	if key.domain != "" {
		entry := addTrafficEntry(&day.Hosts, key.domain, up, down, trafficHostLimit)
		if key.host != key.domain {
			if entry.Subs == nil {
				entry.Subs = map[string]*trafficPair{}
			}
			addTrafficPair(entry.Subs, key.host, up, down)
			if len(entry.Subs) > trafficSubLimit+trafficSubLimit/4 {
				pruneTrafficPairs(entry.Subs, trafficSubLimit)
			}
		}
	}
	if key.process != "" {
		entry := addTrafficEntry(&day.Processes, key.process, up, down, trafficProcessLimit)
		if key.path != "" {
			entry.Path = key.path
		}
	}
	if key.node != "" {
		addTrafficEntry(&day.Nodes, key.node, up, down, trafficNodeLimit)
	}
	if key.profile != "" {
		addTrafficEntry(&day.Profiles, key.profile, up, down, trafficProfileLimit)
	}
	if key.rule != "" {
		addTrafficRule(day, key, 0, up, down)
	}
}

func addTrafficRule(day *trafficDay, key trafficConnKey, hits, up, down int64) {
	if day.Rules == nil {
		day.Rules = map[string]*trafficEntry{}
	}
	entry := day.Rules[key.rule]
	if entry == nil {
		entry = &trafficEntry{}
		day.Rules[key.rule] = entry
	}
	entry.Hits += hits
	entry.Traffic.add(up, down)
	if len(day.Rules) > trafficRuleLimit+trafficRuleLimit/4 {
		pruneTrafficEntriesBy(day.Rules, trafficRuleLimit, trafficEntryHits)
	}
}

func addTrafficEntry(entries *map[string]*trafficEntry, name string, up, down int64, limit int) *trafficEntry {
	if *entries == nil {
		*entries = map[string]*trafficEntry{}
	}
	entry := (*entries)[name]
	if entry == nil {
		entry = &trafficEntry{}
		(*entries)[name] = entry
	}
	entry.Traffic.add(up, down)
	if len(*entries) > limit+limit/4 {
		pruneTrafficEntriesBy(*entries, limit, trafficEntryTraffic)
		if kept := (*entries)[name]; kept != nil {
			return kept
		}
		return &trafficEntry{}
	}
	return entry
}

func addTrafficPair(pairs map[string]*trafficPair, name string, up, down int64) {
	pair := pairs[name]
	if pair == nil {
		pair = &trafficPair{}
		pairs[name] = pair
	}
	pair.add(up, down)
}

func sortedTrafficKeys[T any](values map[string]T, sum func(T) int64) []string {
	keys := make([]string, 0, len(values))
	for key := range values {
		if key != "" {
			keys = append(keys, key)
		}
	}
	slices.SortFunc(keys, func(a, b string) int {
		if c := cmp.Compare(sum(values[b]), sum(values[a])); c != 0 {
			return c
		}
		return strings.Compare(a, b)
	})
	return keys
}

func trafficEntryTraffic(entry *trafficEntry) int64 {
	return entry.Traffic.sum()
}

func trafficEntryHits(entry *trafficEntry) int64 {
	return entry.Hits
}

func pruneTrafficEntriesBy(entries map[string]*trafficEntry, limit int, weight func(*trafficEntry) int64) {
	keys := sortedTrafficKeys(entries, weight)
	if len(keys) <= limit {
		return
	}
	others := entries[""]
	if others == nil {
		others = &trafficEntry{}
	}
	for _, key := range keys[limit:] {
		others.Traffic.add(entries[key].Traffic[0], entries[key].Traffic[1])
		others.Hits += entries[key].Hits
		delete(entries, key)
	}
	entries[""] = others
}

func pruneTrafficPairs(pairs map[string]*trafficPair, limit int) {
	keys := sortedTrafficKeys(pairs, func(p *trafficPair) int64 { return p.sum() })
	if len(keys) <= limit {
		return
	}
	others := pairs[""]
	if others == nil {
		others = &trafficPair{}
	}
	for _, key := range keys[limit:] {
		others.add(pairs[key][0], pairs[key][1])
		delete(pairs, key)
	}
	pairs[""] = others
}

func pruneTrafficDay(day *trafficDay) {
	pruneTrafficEntriesBy(day.Hosts, trafficHostLimit, trafficEntryTraffic)
	for _, entry := range day.Hosts {
		if entry.Subs != nil {
			pruneTrafficPairs(entry.Subs, trafficSubLimit)
		}
	}
	pruneTrafficEntriesBy(day.Processes, trafficProcessLimit, trafficEntryTraffic)
	pruneTrafficEntriesBy(day.Nodes, trafficNodeLimit, trafficEntryTraffic)
	pruneTrafficEntriesBy(day.Profiles, trafficProfileLimit, trafficEntryTraffic)
	pruneTrafficEntriesBy(day.Rules, trafficRuleLimit, trafficEntryHits)
}

func (c *trafficCollector) flush() {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	type pending struct {
		key  string
		data []byte
	}
	c.mu.Lock()
	if c.dir == "" {
		c.mu.Unlock()
		return
	}
	dir := c.dir
	now := c.localNow()
	today := now.Format(trafficDayLayout)
	var writes []pending
	for key := range c.dirty {
		day := c.days[key]
		delete(c.dirty, key)
		if day == nil {
			continue
		}
		if key != today {
			pruneTrafficDay(day)
		}
		if data, err := encodeStore(day); err == nil {
			writes = append(writes, pending{key: key, data: data})
		}
	}
	cutoff := ""
	if c.cleaned != today {
		c.cleaned = today
		cutoff = now.AddDate(0, 0, -c.options.RetentionDays+1).Format(trafficDayLayout)
	}
	c.mu.Unlock()

	var failed []string
	if len(writes) > 0 {
		if err := os.MkdirAll(dir, 0o700); err != nil {
			for _, write := range writes {
				failed = append(failed, write.key)
			}
			writes = nil
		}
	}
	for _, write := range writes {
		if err := writeStoreBytes(filepath.Join(dir, write.key+trafficStatsExt), write.data); err != nil {
			failed = append(failed, write.key)
		}
	}
	if cutoff != "" {
		for _, key := range listTrafficDays(dir) {
			if key < cutoff {
				_ = os.Remove(filepath.Join(dir, key+trafficStatsExt))
			}
		}
	}

	c.mu.Lock()
	defer c.mu.Unlock()
	for _, key := range failed {
		c.dirty[key] = true
	}
	keepToday := c.enabled.Load()
	for key := range c.days {
		if (key != today || !keepToday) && !c.dirty[key] {
			delete(c.days, key)
		}
	}
}

func (c *trafficCollector) clear() {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	c.mu.Lock()
	dir := c.dir
	c.days = map[string]*trafficDay{}
	c.dirty = map[string]bool{}
	c.mu.Unlock()
	if dir == "" {
		return
	}
	for _, key := range listTrafficDays(dir) {
		_ = os.Remove(filepath.Join(dir, key+trafficStatsExt))
	}
}

func readTrafficDay(path string) *trafficDay {
	day := &trafficDay{}
	if !readStoreFile(path, day) {
		return nil
	}
	return day
}

func listTrafficDays(dir string) []string {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil
	}
	var keys []string
	for _, entry := range entries {
		name := entry.Name()
		if entry.IsDir() || !strings.HasSuffix(name, trafficStatsExt) {
			continue
		}
		key := strings.TrimSuffix(name, trafficStatsExt)
		if _, err := time.Parse(trafficDayLayout, key); err == nil {
			keys = append(keys, key)
		}
	}
	sort.Strings(keys)
	return keys
}

type trafficAggregate struct {
	traffic trafficPair
	hits    int64
	path    string
	subs    map[string]*trafficPair
}

func mergeTrafficEntries(target map[string]*trafficAggregate, entries map[string]*trafficEntry) {
	for name, entry := range entries {
		if name == "" {
			continue
		}
		aggregate := target[name]
		if aggregate == nil {
			aggregate = &trafficAggregate{}
			target[name] = aggregate
		}
		aggregate.traffic.add(entry.Traffic[0], entry.Traffic[1])
		aggregate.hits += entry.Hits
		if entry.Path != "" {
			aggregate.path = entry.Path
		}
		for sub, pair := range entry.Subs {
			if sub == "" {
				continue
			}
			if aggregate.subs == nil {
				aggregate.subs = map[string]*trafficPair{}
			}
			addTrafficPair(aggregate.subs, sub, pair[0], pair[1])
		}
	}
}

func trafficAggregateTraffic(aggregate *trafficAggregate) int64 {
	return aggregate.traffic.sum()
}

func trafficAggregateHits(aggregate *trafficAggregate) int64 {
	return aggregate.hits
}

func topTrafficItems(aggregates map[string]*trafficAggregate, top int, subTop int, weight func(*trafficAggregate) int64) []TrafficStatsItem {
	keys := sortedTrafficKeys(aggregates, weight)
	if top > 0 && len(keys) > top {
		keys = keys[:top]
	}
	items := make([]TrafficStatsItem, 0, len(keys))
	for _, key := range keys {
		aggregate := aggregates[key]
		item := TrafficStatsItem{
			Name: key,
			Up:   aggregate.traffic[0],
			Down: aggregate.traffic[1],
			Hits: aggregate.hits,
			Path: aggregate.path,
		}
		if subTop > 0 && len(aggregate.subs) > 0 {
			subKeys := sortedTrafficKeys(aggregate.subs, func(p *trafficPair) int64 { return p.sum() })
			if len(subKeys) > subTop {
				subKeys = subKeys[:subTop]
			}
			for _, sub := range subKeys {
				pair := aggregate.subs[sub]
				item.Subs = append(item.Subs, TrafficStatsItem{Name: sub, Up: pair[0], Down: pair[1]})
			}
		}
		items = append(items, item)
	}
	return items
}

func trafficDays(start, end string) []string {
	from, err := time.Parse(trafficDayLayout, start)
	if err != nil {
		return nil
	}
	to, err := time.Parse(trafficDayLayout, end)
	if err != nil || to.Before(from) {
		return nil
	}
	var days []string
	for day := from; !day.After(to) && len(days) < trafficMaxSeriesDays; day = day.AddDate(0, 0, 1) {
		days = append(days, day.Format(trafficDayLayout))
	}
	return days
}

func (c *trafficCollector) loadDays(keys []string) map[string]*trafficDay {
	c.mu.Lock()
	dir := c.dir
	var missing []string
	for _, key := range keys {
		if c.days[key] == nil {
			missing = append(missing, key)
		}
	}
	c.mu.Unlock()
	loaded := map[string]*trafficDay{}
	if dir == "" {
		return loaded
	}
	for _, key := range missing {
		if day := readTrafficDay(filepath.Join(dir, key+trafficStatsExt)); day != nil {
			loaded[key] = day
		}
	}
	return loaded
}

func (c *trafficCollector) query(query TrafficStatsQuery) TrafficStatsResult {
	c.sample()
	result := TrafficStatsResult{
		Series:    []TrafficStatsPoint{},
		Hosts:     []TrafficStatsItem{},
		Processes: []TrafficStatsItem{},
		Nodes:     []TrafficStatsItem{},
		Profiles:  []TrafficStatsItem{},
		Rules:     []TrafficStatsItem{},
	}
	days := trafficDays(query.Start, query.End)
	loaded := c.loadDays(days)

	c.mu.Lock()
	defer c.mu.Unlock()
	if c.dir != "" {
		if keys := listTrafficDays(c.dir); len(keys) > 0 {
			result.Since = keys[0]
		}
	}
	for key, day := range c.days {
		if day.Total.sum() > 0 && (result.Since == "" || key < result.Since) {
			result.Since = key
		}
	}
	if len(days) == 0 {
		return result
	}
	dayOf := func(key string) *trafficDay {
		if day := c.days[key]; day != nil {
			return day
		}
		if day := loaded[key]; day != nil {
			return day
		}
		return readTrafficDay(c.dayFile(key))
	}
	if query.Host != "" {
		return queryTrafficHost(result, days, query.Host, dayOf)
	}
	top := query.Top
	if top <= 0 {
		top = trafficDefaultQueryTop
	}
	hosts := map[string]*trafficAggregate{}
	processes := map[string]*trafficAggregate{}
	nodes := map[string]*trafficAggregate{}
	profiles := map[string]*trafficAggregate{}
	rules := map[string]*trafficAggregate{}
	for _, key := range days {
		day := dayOf(key)
		if day == nil {
			if len(days) > 1 {
				result.Series = append(result.Series, TrafficStatsPoint{Label: key})
			}
			continue
		}
		result.Up += day.Total[0]
		result.Down += day.Total[1]
		result.ProxyUp += day.Proxy[0]
		result.ProxyDown += day.Proxy[1]
		if len(days) > 1 {
			result.Series = append(result.Series, TrafficStatsPoint{Label: key, Up: day.Total[0], Down: day.Total[1]})
		}
		mergeTrafficEntries(hosts, day.Hosts)
		mergeTrafficEntries(processes, day.Processes)
		mergeTrafficEntries(nodes, day.Nodes)
		mergeTrafficEntries(profiles, day.Profiles)
		mergeTrafficEntries(rules, day.Rules)
		for _, entry := range day.Rules {
			result.RuleHits += entry.Hits
		}
	}
	if len(days) == 1 {
		day := dayOf(days[0])
		for hour := range 24 {
			point := TrafficStatsPoint{Label: strconv.Itoa(hour)}
			if day != nil {
				point.Up, point.Down = day.Hours[hour][0], day.Hours[hour][1]
			}
			result.Series = append(result.Series, point)
		}
	}
	result.Hosts = topTrafficItems(hosts, top, 0, trafficAggregateTraffic)
	result.Processes = topTrafficItems(processes, top, 0, trafficAggregateTraffic)
	result.Nodes = topTrafficItems(nodes, top, 0, trafficAggregateTraffic)
	result.Profiles = topTrafficItems(profiles, top, 0, trafficAggregateTraffic)
	result.Rules = topTrafficItems(rules, top, 0, trafficAggregateHits)
	return result
}

func queryTrafficHost(result TrafficStatsResult, days []string, host string, dayOf func(string) *trafficDay) TrafficStatsResult {
	aggregates := map[string]*trafficAggregate{}
	for _, key := range days {
		var entry *trafficEntry
		if day := dayOf(key); day != nil {
			entry = day.Hosts[host]
		}
		if entry != nil {
			mergeTrafficEntries(aggregates, map[string]*trafficEntry{host: entry})
		}
		if len(days) > 1 {
			point := TrafficStatsPoint{Label: key}
			if entry != nil {
				point.Up, point.Down = entry.Traffic[0], entry.Traffic[1]
			}
			result.Series = append(result.Series, point)
		}
	}
	if aggregate := aggregates[host]; aggregate != nil {
		result.Up, result.Down = aggregate.traffic[0], aggregate.traffic[1]
	}
	result.Hosts = topTrafficItems(aggregates, 1, 50, trafficAggregateTraffic)
	return result
}
