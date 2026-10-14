package main

import (
	"bytes"
	"context"
	"core/state"
	"encoding/json"
	"fmt"
	"math"
	"net"
	"os"
	"regexp"
	"runtime"
	"runtime/debug"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/observable"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/common/yaml"
	"github.com/metacubex/mihomo/component/age"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/log"
	mihomoNtp "github.com/metacubex/mihomo/ntp/ntp"
	rulesProvider "github.com/metacubex/mihomo/rules/provider"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"sync"
	"sync/atomic"

	yamlv3 "go.yaml.in/yaml/v3"
)

var (
	isInit              = false
	externalProviders   = map[string]cp.Provider{}
	logSubscriber       observable.Subscription[log.Event]
	ageMutex            sync.Mutex
	requestHistoryLock  sync.RWMutex
	requestHistory      []*statistic.TrackerInfo
	isStreamingRequests atomic.Bool
	logHistoryLock      sync.RWMutex
	logHistory          []logEntry
	isStreamingLogs     atomic.Bool
)

func handleInitClash(paramsString string) bool {
	var params = InitParams{}
	err := json.Unmarshal([]byte(paramsString), &params)
	if err != nil {
		return false
	}
	version = params.Version
	if !isInit {
		constant.SetHomeDir(params.HomeDir)
		isInit = true
		ensureLogSubscriber()
		initPermissionGuard(params.HomeDir)
	}
	return isInit
}

func handleStartListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = true
	updateListeners()
	resolver.ResetConnection()
	return true
}

func handleStopListener() bool {
	runLock.Lock()
	defer runLock.Unlock()
	isRunning = false
	listener.StopListener()
	return true
}

func handleGetIsInit() bool {
	return isInit
}

func handleForceGc(forceFreeOSMemory bool) {
	go func() {
		log.Infoln("[APP] Request force GC, forceFreeOSMemory=%t", forceFreeOSMemory)
		tryUnloadGeoData()
		runtime.GC()
		if forceFreeOSMemory {
			debug.FreeOSMemory()
		}
	}()
}

func handleShutdown() bool {
	stopListeners()
	closeTailscaleProxies()
	appTailscaleProxy.Store(nil)
	executor.Shutdown()
	tryUnloadGeoData()
	handleClearRequests()
	handleClearLogs()
	isStreamingRequests.Store(false)
	isStreamingLogs.Store(false)
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	runtime.GC()
	debug.FreeOSMemory()
	isInit = false
	return true
}

var shortIDRegexp = regexp.MustCompile(`(?m)(short-id\s*:\s*)([0-9a-fA-F]+)(\s*(?:$|[,\s#\}]))`)

func patchYamlShortID(data []byte) []byte {
	return shortIDRegexp.ReplaceAll(data, []byte(`${1}"${2}"${3}`))
}

func handleValidateConfig(params *ValidateConfigParams) string {
	if params.Setup != nil {
		prepared, err := prepareSetup(params.Setup)
		if err != nil {
			return err.Error()
		}
		if constant.DefaultTestURL == params.Setup.TestURL {
			storePreparedSetup(prepared)
		}
		return ""
	}
	ageMutex.Lock()
	defer ageMutex.Unlock()

	if params.AgeSecretKey != "" {
		age.SetGlobalSecretKeys(params.AgeSecretKey)
		defer age.SetGlobalSecretKeys()
	}

	data := patchYamlShortID([]byte(params.Data))
	rawCfg, err := config.UnmarshalRawConfig(data)
	if err != nil {
		return err.Error()
	}
	if _, _, err = parseRawConfigStaged(rawCfg); err != nil {
		return err.Error()
	}
	return ""
}

func handleDecryptAgeConfig(params *DecryptAgeConfigParams) string {
	ageMutex.Lock()
	defer ageMutex.Unlock()

	decrypted, err := age.DecryptBytes([]byte(params.Data), params.AgeSecretKey)
	if err != nil {
		return ""
	}
	return string(decrypted)
}

type proxiesPayload struct {
	Names  []string                   `json:"names"`
	Types  []string                   `json:"types"`
	Groups map[string]json.RawMessage `json:"groups"`
}

type groupPayload struct {
	Name    string  `json:"name"`
	Type    string  `json:"type"`
	Now     *string `json:"now,omitempty"`
	TestUrl *string `json:"testUrl,omitempty"`
	Hidden  bool    `json:"hidden"`
	Icon    string  `json:"icon"`
	All     []any   `json:"all"`
}

type groupShape struct {
	testUrl *string
	hasNow  bool
}

var (
	groupShapeLock sync.Mutex
	groupShapes    = map[*adapter.Proxy]groupShape{}
)

func resetGroupShapes() {
	groupShapeLock.Lock()
	groupShapes = map[*adapter.Proxy]groupShape{}
	groupShapeLock.Unlock()
}

func groupShapeOf(outbound *adapter.Proxy) (groupShape, error) {
	groupShapeLock.Lock()
	defer groupShapeLock.Unlock()
	if shape, exist := groupShapes[outbound]; exist {
		return shape, nil
	}
	inner, err := outbound.ProxyAdapter.MarshalJSON()
	if err != nil {
		return groupShape{}, err
	}
	fields := struct {
		TestUrl *string `json:"testUrl"`
		Now     *string `json:"now"`
	}{}
	if err := json.Unmarshal(inner, &fields); err != nil {
		return groupShape{}, err
	}
	shape := groupShape{testUrl: fields.TestUrl, hasNow: fields.Now != nil}
	groupShapes[outbound] = shape
	return shape, nil
}

func marshalGroup(outbound *adapter.Proxy, group outboundgroup.ProxyGroup, indexes map[string]int) (json.RawMessage, error) {
	shape, err := groupShapeOf(outbound)
	if err != nil {
		return nil, err
	}
	members := group.Proxies()
	payload := groupPayload{
		Name:    outbound.Name(),
		Type:    outbound.Type().String(),
		TestUrl: shape.testUrl,
		Hidden:  group.Hidden(),
		Icon:    group.Icon(),
		All:     make([]any, len(members)),
	}
	if shape.hasNow {
		now := group.Now()
		payload.Now = &now
	}
	for i, member := range members {
		name := member.Name()
		if index, exist := indexes[name]; exist {
			payload.All[i] = index
		} else {
			payload.All[i] = name
		}
	}
	return json.Marshal(payload)
}

func marshalProxies(proxies map[string]constant.Proxy) ([]byte, error) {
	payload := proxiesPayload{
		Names:  make([]string, 0, len(proxies)),
		Types:  make([]string, 0, len(proxies)),
		Groups: map[string]json.RawMessage{},
	}
	indexes := make(map[string]int, len(proxies))
	for name, proxy := range proxies {
		indexes[name] = len(payload.Names)
		payload.Names = append(payload.Names, name)
		payload.Types = append(payload.Types, proxy.Type().String())
	}
	for name, proxy := range proxies {
		outbound, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}
		group, isGroup := outbound.ProxyAdapter.(outboundgroup.ProxyGroup)
		if !isGroup {
			continue
		}
		data, err := marshalGroup(outbound, group, indexes)
		if err != nil {
			return nil, err
		}
		payload.Groups[name] = data
	}
	return json.Marshal(payload)
}

func handleGetProxies() string {
	runLock.Lock()
	defer runLock.Unlock()
	if !isInit {
		return ""
	}
	bytes, err := marshalProxies(tunnel.Proxies())
	if err != nil {
		log.Errorln("[APP] marshal proxies error: %v", err)
		return ""
	}
	return string(bytes)
}

func handleChangeProxy(data string, fn func(string string)) {
	if !isInit {
		fn("core not initialized")
		return
	}
	runLock.Lock()
	go func() {
		defer runLock.Unlock()
		var params = &ChangeProxyParams{}
		err := json.Unmarshal([]byte(data), params)
		if err != nil {
			fn(err.Error())
			return
		}
		groupName := *params.GroupName
		proxyName := *params.ProxyName
		group, ok := tunnel.Proxies()[groupName]
		if !ok {
			fn("Not found group")
			return
		}
		adapterProxy := group.(*adapter.Proxy)
		selector, ok := adapterProxy.ProxyAdapter.(outboundgroup.SelectAble)
		if !ok {
			fn("Group is not selectable")
			return
		}
		if proxyName == "" {
			selector.ForceSet(proxyName)
		} else {
			err = selector.Set(proxyName)
		}
		if err != nil {
			fn(err.Error())
			return
		}

		fn("")
	}()
}

func handleGetTraffic() string {
	up, down := statistic.DefaultManager.NowTraffic(state.CurrentState.OnlyStatisticsProxy)
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleGetTotalTraffic() string {
	up, down := statistic.DefaultManager.TotalTraffic(state.CurrentState.OnlyStatisticsProxy)
	traffic := map[string]int64{
		"up":   up,
		"down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleResetTraffic() {
	statistic.DefaultManager.ResetStatistic()
}

func handleAsyncTestDelay(paramsString string, fn func(string)) {
	mBatch.Go(paramsString, func() (bool, error) {
		var params = &TestDelayParams{}
		err := json.Unmarshal([]byte(paramsString), params)
		if err != nil {
			fn("")
			return false, nil
		}

		expectedStatus, err := utils.NewUnsignedRanges[uint16]("")
		if err != nil {
			fn("")
			return false, nil
		}

		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(params.Timeout))
		defer cancel()

		var proxy constant.Proxy
		var exist bool
		if proxy, exist = tunnel.Proxies()[params.ProxyName]; !exist {
			for _, provider := range tunnel.Providers() {
				for _, p := range provider.Proxies() {
					if p.Name() == params.ProxyName {
						proxy = p
						exist = true
						break
					}
				}
				if exist {
					break
				}
			}
		}

		delayData := &Delay{
			Name: params.ProxyName,
		}

		if proxy == nil {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))
			return false, nil
		}

		testUrl := constant.DefaultTestURL

		if params.TestUrl != "" {
			testUrl = params.TestUrl
		}
		delayData.Url = testUrl

		delay, err := proxy.URLTest(ctx, testUrl, expectedStatus)
		if err != nil || delay == 0 {
			delayData.Value = -1
			data, _ := json.Marshal(delayData)
			fn(string(data))
			return false, nil
		}

		delayData.Value = int32(delay)
		data, _ := json.Marshal(delayData)
		fn(string(data))
		return false, nil
	})
}

func handleGetConnections() string {
	runLock.Lock()
	defer runLock.Unlock()
	snapshot := statistic.DefaultManager.Snapshot()
	data, err := json.Marshal(snapshot)
	if err != nil {
		fmt.Println("Error:", err)
		return ""
	}
	return string(data)
}

func handleCloseConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	closeConnections()
	return true
}

func closeConnections() {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		_ = c.Close()
		return true
	})
}

func handleResetConnections() bool {
	runLock.Lock()
	defer runLock.Unlock()
	resolver.ResetConnection()
	return true
}

func handleCloseConnection(connectionId string) bool {
	runLock.Lock()
	defer runLock.Unlock()
	c := statistic.DefaultManager.Get(connectionId)
	if c == nil {
		return false
	}
	_ = c.Close()
	return true
}

func handleGetExternalProviders() string {
	runLock.Lock()
	defer runLock.Unlock()
	if !isInit {
		return "[]"
	}
	externalProviders = getExternalProvidersRaw()
	eps := make([]ExternalProvider, 0)
	for _, p := range externalProviders {
		externalProvider, err := toExternalProvider(p)
		if err != nil {
			continue
		}
		eps = append(eps, *externalProvider)
	}
	sort.Sort(ExternalProviders(eps))
	data, err := json.Marshal(eps)
	if err != nil {
		return ""
	}
	return string(data)
}

func handleGetExternalProvider(externalProviderName string) string {
	runLock.Lock()
	defer runLock.Unlock()
	externalProvider, exist := externalProviders[externalProviderName]
	if !exist {
		return ""
	}
	e, err := toExternalProvider(externalProvider)
	if err != nil {
		return ""
	}
	data, err := json.Marshal(e)
	if err != nil {
		return ""
	}
	return string(data)
}

func handleUpdateGeoData(geoType string, geoName string, fn func(value string)) {
	go func() {
		path := constant.Path.Resolve(geoName)
		switch geoType {
		case "MMDB":
			err := updater.UpdateMMDBWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		case "ASN":
			err := updater.UpdateASNWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		case "GeoSite":
			err := updater.UpdateGeoSiteWithPath(path)
			if err != nil {
				fn(err.Error())
				return
			}
		}
		fn("")
	}()
}

func handleUpdateExternalProvider(providerName string, fn func(value string)) {
	go func() {
		externalProvider, exist := externalProviders[providerName]
		if !exist {
			fn("external provider is not exist")
			return
		}
		err := externalProvider.Update()
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleSideLoadExternalProvider(providerName string, data []byte, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		externalProvider, exist := externalProviders[providerName]
		if !exist {
			fn("external provider is not exist")
			return
		}
		err := sideUpdateExternalProvider(externalProvider, data)
		if err != nil {
			fn(err.Error())
			return
		}
		fn("")
	}()
}

func handleParseExternalProviderContent(providerName string, fn func(value string)) {
	go func() {
		runLock.Lock()
		p, exist := getExternalProvidersRaw()[providerName]
		rawConfig := currentRawConfig
		runLock.Unlock()

		if !exist {
			fn("external provider does not exist")
			return
		}

		if p.VehicleType() == cp.Inline {
			buf, err := marshalInlineProviderContent(rawConfig, providerName)
			if err != nil {
				fn(err.Error())
				return
			}
			fn(string(buf))
			return
		}

		ep, err := toExternalProvider(p)
		if err != nil || ep.Path == "" {
			fn("provider path is empty")
			return
		}

		buf, err := os.ReadFile(ep.Path)
		if err != nil {
			fn(fmt.Sprintf("read file error: %v", err))
			return
		}

		if rp, ok := p.(cp.RuleProvider); ok {
			var out bytes.Buffer
			if err := rulesProvider.ConvertToMrs(buf, rp.Behavior(), cp.MrsRule, &out); err == nil {
				fn(out.String())
				return
			}
		}

		fn(string(buf))
	}()
}

func marshalInlineProviderContent(rawConfig *config.RawConfig, providerName string) ([]byte, error) {
	if rawConfig == nil {
		return nil, fmt.Errorf("provider content is empty")
	}

	rawProvider, exist := rawConfig.ProxyProvider[providerName]
	if !exist {
		return nil, fmt.Errorf("provider content is empty")
	}
	payload, exist := rawProvider["payload"]
	if !exist {
		return nil, fmt.Errorf("provider content is empty")
	}

	return yaml.Marshal(map[string]any{"proxies": payload})
}

const maxLogHistory = 512

type logEntry struct {
	log.Event
	Time int64 `json:"time"`
}

func recordLogHistory(entry logEntry) {
	logHistoryLock.Lock()
	defer logHistoryLock.Unlock()
	if len(logHistory) >= maxLogHistory {
		logHistory = logHistory[1:]
	}
	logHistory = append(logHistory, entry)
}

func ensureLogSubscriber() {
	if logSubscriber != nil {
		return
	}
	logSubscriber = log.Subscribe()
	go func() {
		for logData := range logSubscriber {
			notifyTailscaleAuth(logData.Payload)
			if logData.LogLevel < log.Level() {
				continue
			}
			entry := logEntry{Event: logData, Time: time.Now().UnixMilli()}
			recordLogHistory(entry)
			if !isStreamingLogs.Load() {
				if logData.LogLevel != log.ERROR {
					continue
				}
			}
			message := &Message{
				Type: LogMessage,
				Data: entry,
			}
			sendMessage(*message)
		}
	}()
}

func handleStartLog() {
	ensureLogSubscriber()
	isStreamingLogs.Store(true)
}

func handleStopLog() {
	isStreamingLogs.Store(false)
}

func handleGetLogs() string {
	logHistoryLock.RLock()
	defer logHistoryLock.RUnlock()
	if len(logHistory) == 0 {
		return "[]"
	}
	data, err := json.Marshal(logHistory)
	if err != nil {
		return "[]"
	}
	return string(data)
}

func handleClearLogs() bool {
	logHistoryLock.Lock()
	defer logHistoryLock.Unlock()
	logHistory = nil
	return true
}

func handleGetCountryCode(ip string, fn func(value string)) {
	go func() {
		runLock.Lock()
		defer runLock.Unlock()
		codes := mmdb.IPInstance().LookupCode(net.ParseIP(ip))
		if len(codes) == 0 {
			fn("")
			return
		}
		fn(codes[0])
	}()
}

func handleGetMemory(fn func(value string)) {
	go func() {
		var m runtime.MemStats
		runtime.ReadMemStats(&m)
		var retainedIdle uint64
		if m.HeapIdle > m.HeapReleased {
			retainedIdle = m.HeapIdle - m.HeapReleased
		}
		mem := m.HeapInuse + retainedIdle + m.StackInuse
		fn(strconv.FormatUint(mem, 10))
	}()
}

func handleGetCoreStatus(fn func(value string)) {
	go func() {
		var m runtime.MemStats
		runtime.ReadMemStats(&m)
		var retainedIdle uint64
		if m.HeapIdle > m.HeapReleased {
			retainedIdle = m.HeapIdle - m.HeapReleased
		}
		inUse := m.HeapInuse + m.StackInuse
		physical := inUse + retainedIdle

		var proxyGroupsCount int
		proxyNames := make(map[string]struct{})
		for _, p := range tunnel.Proxies() {
			if p == nil {
				continue
			}
			if _, ok := p.Adapter().(outboundgroup.ProxyGroup); ok {
				proxyGroupsCount++
				continue
			}
			switch p.Type() {
			case constant.Direct, constant.Reject, constant.RejectDrop, constant.Compatible, constant.Pass, constant.PassRule, constant.Rematch, constant.Dns:
				continue
			default:
				proxyNames[p.Name()] = struct{}{}
			}
		}

		for name, pr := range tunnel.Providers() {
			if pr == nil || name == "default" || pr.VehicleType() == cp.Compatible {
				continue
			}
			for _, p := range pr.Proxies() {
				if p != nil {
					proxyNames[p.Name()] = struct{}{}
				}
			}
		}

		var ruleProvidersCount int
		var proxyProvidersCount int
		if currentRawConfig != nil {
			ruleProvidersCount = len(currentRawConfig.RuleProvider)
			proxyProvidersCount = len(currentRawConfig.ProxyProvider)
		} else {
			for name, pr := range tunnel.Providers() {
				if pr == nil || name == "default" || pr.VehicleType() == cp.Compatible {
					continue
				}
				proxyProvidersCount++
			}
			ruleProvidersCount = len(tunnel.RuleProviders())
		}

		hasMMDB, hasSite, hasASN := checkActiveGeoUsage()

		var geodatas []string
		if hasMMDB {
			geodatas = append(geodatas, "MMDB")
		}
		if hasSite {
			geodatas = append(geodatas, "Site")
		}
		if hasASN {
			geodatas = append(geodatas, "ASN")
		}

		geodataUse := "None"
		if len(geodatas) > 0 {
			geodataUse = strings.Join(geodatas, ", ")
		}

		status := map[string]any{
			"physical":        physical,
			"in-use":          inUse,
			"reclaimable":     retainedIdle,
			"goroutines":      runtime.NumGoroutine(),
			"heap-objects":    m.HeapObjects,
			"last-gc":         m.LastGC / 1000000,
			"rules":           len(tunnel.Rules()),
			"proxies":         len(proxyNames),
			"proxy-groups":    proxyGroupsCount,
			"rule-providers":  ruleProvidersCount,
			"proxy-providers": proxyProvidersCount,
			"geodata-use":     geodataUse,
		}
		bytes, _ := json.Marshal(status)
		fn(string(bytes))
	}()
}

func handleGetMode() string {
	if !isInit {
		return ""
	}
	return tunnel.Mode().String()
}

func handleSetState(params string) {
	_ = json.Unmarshal([]byte(params), state.CurrentState)
}

func handleGetConfig(params *GetConfigParams) (*config.RawConfig, error) {
	rawCfg, err := readProfile(params.Path, params.AgeSecretKey)
	if err != nil || len(params.DisabledGroups) == 0 {
		return rawCfg, err
	}
	disabled := make(map[string]bool, len(params.DisabledGroups))
	for _, name := range params.DisabledGroups {
		disabled[name] = true
	}
	rawCfg.ProxyGroup = disableGroups(rawCfg.ProxyGroup, disabled)
	return rawCfg, nil
}

func handleExportConfig(params *ExportConfigParams) error {
	rawCfg, err := readProfile(params.Path, params.AgeSecretKey)
	if err != nil {
		return err
	}
	bytes, err := json.Marshal(rawCfg)
	if err != nil {
		return err
	}
	if err := os.WriteFile(params.Output, bytes, 0o600); err != nil {
		return err
	}
	_ = os.Chown(params.Output, os.Getuid(), os.Getgid())
	return nil
}

func readProfile(path string, ageSecretKey string) (*config.RawConfig, error) {
	bytes, err := readFile(path)
	if err != nil {
		return nil, err
	}
	return parseProfile(bytes, ageSecretKey)
}

func parseProfile(bytes []byte, ageSecretKey string) (*config.RawConfig, error) {
	ageMutex.Lock()
	defer ageMutex.Unlock()

	if ageSecretKey != "" {
		age.SetGlobalSecretKeys(ageSecretKey)
		defer age.SetGlobalSecretKeys()
	}
	return config.UnmarshalRawConfig(patchYamlShortID(bytes))
}

func loadPatchedConfig(params *SetupParams) (*config.RawConfig, string, error) {
	var rawCfg *config.RawConfig
	var err error
	if params.ScriptedConfig != "" {
		defer os.Remove(params.ScriptedConfig)
		var bytes []byte
		bytes, err = readFile(params.ScriptedConfig)
		if err != nil {
			return nil, "", err
		}
		rawCfg, err = decodeScriptedConfig(bytes)
	} else {
		rawCfg, err = readProfile(params.ProfilePath, params.AgeSecretKey)
	}
	if err != nil {
		return nil, "", err
	}
	if params.Patch == nil {
		return rawCfg, "", nil
	}
	global, err := applyPatch(rawCfg, params.Patch)
	if err != nil {
		return nil, "", err
	}
	return rawCfg, global, nil
}

func decodeScriptedConfig(data []byte) (*config.RawConfig, error) {
	rawCfg := config.DefaultRawConfig()
	scripted := struct {
		*config.RawConfig
		Rules []string `json:"rules"`
	}{RawConfig: rawCfg}
	if err := json.Unmarshal(data, &scripted); err != nil {
		return config.UnmarshalRawConfig(data)
	}
	if scripted.Rules != nil {
		rawCfg.Rule = scripted.Rules
	}
	for _, item := range rawCfg.Proxy {
		normalizeJsonNumbers(item)
	}
	for _, item := range rawCfg.ProxyGroup {
		normalizeJsonNumbers(item)
	}
	for _, item := range rawCfg.Listeners {
		normalizeJsonNumbers(item)
	}
	for _, item := range rawCfg.ProxyProvider {
		normalizeJsonNumbers(item)
	}
	for _, item := range rawCfg.RuleProvider {
		normalizeJsonNumbers(item)
	}
	normalizeJsonNumbers(rawCfg.Hosts)
	return rawCfg, nil
}

func normalizeJsonNumbers(value any) any {
	switch typed := value.(type) {
	case float64:
		if typed == math.Trunc(typed) && math.Abs(typed) < 1<<53 {
			return int(typed)
		}
	case map[string]any:
		for key, item := range typed {
			typed[key] = normalizeJsonNumbers(item)
		}
	case []any:
		for index, item := range typed {
			typed[index] = normalizeJsonNumbers(item)
		}
	}
	return value
}

func handleGetRuntimeConfig(params *SetupParams) (string, error) {
	scripted := params.ScriptedConfig != ""
	path := params.ProfilePath
	if scripted {
		path = params.ScriptedConfig
	}
	source, err := readFile(path)
	if err != nil {
		return "", err
	}
	var before *config.RawConfig
	if scripted {
		before, err = decodeScriptedConfig(source)
	} else {
		source = patchYamlShortID(source)
		before, err = parseProfile(source, params.AgeSecretKey)
	}
	if err != nil {
		return "", err
	}
	after, _, err := loadPatchedConfig(params)
	if err != nil {
		return "", err
	}
	var forced map[string]json.RawMessage
	if params.Patch != nil && hasPatchValue(params.Patch.General) {
		_ = json.Unmarshal(params.Patch.General, &forced)
	}
	root, err := buildRuntimeConfigNode(source, before, after, forced)
	if err != nil {
		return "", err
	}
	out, err := marshalYamlNode(root)
	if err != nil {
		return "", err
	}
	return string(out), nil
}

func walkYamlScalars(node *yamlv3.Node, visit func(*yamlv3.Node)) {
	if node.Kind == yamlv3.ScalarNode {
		visit(node)
	}
	for _, child := range node.Content {
		walkYamlScalars(child, visit)
	}
}

func encodeYamlNode(root *yamlv3.Node) ([]byte, error) {
	var out strings.Builder
	encoder := yamlv3.NewEncoder(&out)
	encoder.SetIndent(2)
	if err := encoder.Encode(root); err != nil {
		return nil, err
	}
	if err := encoder.Close(); err != nil {
		return nil, err
	}
	return []byte(out.String()), nil
}

func marshalYamlNode(root *yamlv3.Node) ([]byte, error) {
	const privateUseStart, privateUseEnd = rune(0xE000), rune(0xF8FF)
	used := map[rune]bool{}
	placeholders := map[rune]rune{}
	walkYamlScalars(root, func(node *yamlv3.Node) {
		for _, char := range node.Value {
			if char >= privateUseStart && char <= privateUseEnd {
				used[char] = true
			} else if char > 0xFFFF {
				placeholders[char] = 0
			}
		}
	})
	if len(placeholders) == 0 {
		return encodeYamlNode(root)
	}
	next := privateUseStart
	restore := make([]string, 0, len(placeholders)*2)
	for char := range placeholders {
		for used[next] {
			next++
		}
		if next > privateUseEnd {
			return encodeYamlNode(root)
		}
		placeholders[char] = next
		restore = append(restore, string(next), string(char))
		next++
	}
	walkYamlScalars(root, func(node *yamlv3.Node) {
		node.Value = strings.Map(func(char rune) rune {
			if placeholder, ok := placeholders[char]; ok {
				return placeholder
			}
			return char
		}, node.Value)
	})
	out, err := encodeYamlNode(root)
	if err != nil {
		return nil, err
	}
	return []byte(strings.NewReplacer(restore...).Replace(string(out))), nil
}

func handleFlushFakeIP() bool {
	if !isInit {
		return false
	}
	err := resolver.FlushFakeIP()
	if err != nil {
		log.Errorln("[APP] Flush FakeIP error: %v", err)
		return false
	}
	log.Infoln("[APP] FakeIP pool flushed")
	return true
}

func handleFlushDnsCache() {
	resolver.ClearCache()
	log.Infoln("[APP] DNS cache flushed")
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleUpdateConfig(bytes []byte) string {
	var params = &UpdateParams{}
	err := json.Unmarshal(bytes, params)
	if err != nil {
		return err.Error()
	}
	updateConfig(params)
	return ""
}

func handleSetupConfig(bytes []byte) *SetupResult {
	var params = defaultSetupParams()
	err := UnmarshalJson(bytes, params)
	if err != nil {
		log.Errorln("unmarshalRawConfig error %v", err)
		return &SetupResult{Message: err.Error()}
	}
	clearSuspendedHealthChecks()
	clearSuspendedWireGuard()
	suspendModeLock.Lock()
	currentSuspendMode = 0
	suspendModeLock.Unlock()
	global, err := setupConfig(params)
	if err != nil {
		return &SetupResult{Message: err.Error()}
	}
	return &SetupResult{Global: global}
}

var (
	currentSuspendMode = 0
	suspendModeLock    sync.Mutex
)

func handleSuspend(mode int) bool {
	if !isInit {
		return false
	}
	suspendModeLock.Lock()
	defer suspendModeLock.Unlock()

	switch mode {
	case 1:
		if currentSuspendMode == 1 {
			return true
		}
		log.Infoln("[APP] Suspend mode enabled")
		tunnel.OnSuspend()
		pauseHealthChecks()
		pauseWireGuard()

		mihomoNtp.ReCreateNTPService("", 0, "", nil, false)

		statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
			_ = c.Close()
			return true
		})

		runtime.GC()
		currentSuspendMode = 1

	case 2:
		if currentSuspendMode == 1 || currentSuspendMode == 2 {
			return true
		}
		log.Infoln("[APP] Doze suspend mode enabled")
		pauseHealthChecks()
		runtime.GC()
		currentSuspendMode = 2

	case 0:
		if currentSuspendMode == 0 {
			return true
		}
		log.Infoln("[APP] Resume from suspend")
		prevMode := currentSuspendMode
		currentSuspendMode = 0

		if prevMode == 1 {
			tunnel.OnRunning()
			resumeHealthChecks()
			resumeWireGuard()

			runLock.Lock()
			cfg := currentConfig
			runLock.Unlock()
			if cfg != nil && cfg.NTP != nil && cfg.NTP.Enable {
				c := cfg.NTP
				mihomoNtp.ReCreateNTPService(
					net.JoinHostPort(c.Server, strconv.Itoa(c.Port)),
					time.Duration(c.Interval),
					c.DialerProxy,
					tunnel.Tunnel,
					c.WriteToSystem,
				)
			}
		} else if prevMode == 2 {
			resumeHealthChecks()
		}

	default:
		return false
	}
	return true
}

func init() {
	adapter.UrlTestHook = func(url string, name string, delay uint16) {
		delayData := &Delay{
			Url:  url,
			Name: name,
		}
		if delay == 0 {
			delayData.Value = -1
		} else {
			delayData.Value = int32(delay)
		}
		sendMessage(Message{
			Type: DelayMessage,
			Data: delayData,
		})
	}
	statistic.DefaultRequestNotify = func(c statistic.Tracker) {
		info := c.Info()
		recordRequestHistory(info)
		if !isStreamingRequests.Load() {
			return
		}
		sendMessage(Message{
			Type: RequestMessage,
			Data: info,
		})
	}
	executor.DefaultProviderLoadedHook = func(providerName string) {
		sendMessage(Message{
			Type: LoadedMessage,
			Data: providerName,
		})
	}
}

const maxRequestHistory = 256

func recordRequestHistory(info *statistic.TrackerInfo) {
	requestHistoryLock.Lock()
	defer requestHistoryLock.Unlock()
	if len(requestHistory) >= maxRequestHistory {
		requestHistory = requestHistory[1:]
	}
	requestHistory = append(requestHistory, info)
}

func handleGetRequests() string {
	requestHistoryLock.RLock()
	defer requestHistoryLock.RUnlock()
	if len(requestHistory) == 0 {
		return "[]"
	}
	data, err := json.Marshal(requestHistory)
	if err != nil {
		return "[]"
	}
	return string(data)
}

func handleStartTrackRequests() bool {
	isStreamingRequests.Store(true)
	return true
}

func handleStopTrackRequests() bool {
	isStreamingRequests.Store(false)
	return true
}

func handleClearRequests() bool {
	requestHistoryLock.Lock()
	defer requestHistoryLock.Unlock()
	requestHistory = nil
	return true
}

