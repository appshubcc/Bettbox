package main

import (
	"encoding/json"
	"fmt"
	"strings"
	"unicode/utf8"

	"core/toolbox"

	"github.com/metacubex/mihomo/component/age"
)

type Action struct {
	Id     string      `json:"id"`
	Method Method      `json:"method"`
	Data   interface{} `json:"data"`
}

type ActionResult struct {
	Id     string      `json:"id"`
	Method Method      `json:"method"`
	Data   interface{} `json:"data"`
	Code   int         `json:"code"`
	Port   int64
}

type actionResultHeader struct {
	Id     string `json:"id"`
	Method Method `json:"method"`
	Code   int    `json:"code"`
	Raw    bool   `json:"raw,omitempty"`
}

func (result ActionResult) Json() ([]byte, error) {
	data := result.Data
	if err, ok := data.(error); ok {
		data = err.Error()
	}
	text, raw := data.(string)
	raw = raw && utf8.ValidString(text) && strings.IndexByte(text, 0) < 0
	var payload []byte
	if !raw {
		var err error
		if payload, err = json.Marshal(data); err != nil {
			return nil, err
		}
	}
	header, err := json.Marshal(actionResultHeader{
		Id:     result.Id,
		Method: result.Method,
		Code:   result.Code,
		Raw:    raw,
	})
	if err != nil {
		return nil, err
	}
	frame := make([]byte, 0, len(header)+1+len(text)+len(payload))
	frame = append(frame, header...)
	frame = append(frame, '\n')
	if raw {
		return append(frame, text...), nil
	}
	return append(frame, payload...), nil
}

func (result ActionResult) success(data interface{}) {
	result.Code = 0
	result.Data = data
	result.send()
}

func (result ActionResult) error(data interface{}) {
	result.Code = -1
	result.Data = data
	result.send()
}

func handleAction(action *Action, result ActionResult) {
	defer func() {
		if r := recover(); r != nil {
			result.error(fmt.Sprintf("panic: %v", r))
		}
	}()
	switch action.Method {
	case initClashMethod:
		paramsString := action.Data.(string)
		result.success(handleInitClash(paramsString))
		return
	case getIsInitMethod:
		result.success(handleGetIsInit())
		return
	case forceGcMethod:
		var forceFreeOSMemory, purge bool
		if action.Data != nil {
			if strVal, ok := action.Data.(string); ok {
				forceFreeOSMemory = strVal == "true" || strVal == "free"
				purge = strVal == "true"
			} else if boolVal, ok := action.Data.(bool); ok {
				forceFreeOSMemory = boolVal
				purge = boolVal
			}
		}
		handleForceGc(forceFreeOSMemory, purge)
		result.success(true)
		return
	case shutdownMethod:
		result.success(handleShutdown())
		return
	case validateConfigMethod:
		paramsString := action.Data.(string)
		var params ValidateConfigParams
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			params.Data = paramsString
		}
		result.success(handleValidateConfig(&params))
		return
	case importProfileMethod:
		var params ImportProfileParams
		if err := json.Unmarshal([]byte(action.Data.(string)), &params); err != nil {
			result.success(err.Error())
			return
		}
		result.success(handleImportProfile(&params))
		return
	case decryptAgeConfigMethod:
		paramsString := action.Data.(string)
		var params DecryptAgeConfigParams
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			params.Data = paramsString
		}
		result.success(handleDecryptAgeConfig(&params))
		return
	case updateConfigMethod:
		data := []byte(action.Data.(string))
		result.success(handleUpdateConfig(data))
		return
	case setupConfigMethod:
		data := []byte(action.Data.(string))
		result.success(handleSetupConfig(data))
		return
	case getModeMethod:
		result.success(handleGetMode())
		return
	case getProxiesMethod:
		result.success(handleGetProxies())
		return
	case changeProxyMethod:
		data := action.Data.(string)
		handleChangeProxy(data, func(value string) {
			result.success(value)
		})
		return
	case getTrafficMethod:
		result.success(handleGetTraffic())
		return
	case getTrafficSnapshotMethod:
		result.success(handleGetTrafficSnapshot())
		return
	case resetTrafficMethod:
		handleResetTraffic()
		result.success(true)
		return
	case asyncTestDelayMethod:
		data := action.Data.(string)
		handleAsyncTestDelay(data, func(value string) {
			result.success(value)
		})
		return
	case asyncTestDelaysMethod:
		handleAsyncTestDelays(action.Data.(string), func(value string) {
			result.success(value)
		})
		return
	case setForegroundMethod:
		value, _ := action.Data.(string)
		handleSetForeground(value == "true")
		result.success(true)
		return
	case startSpeedTestMethod:
		data := action.Data.(string)
		result.success(toolbox.HandleStartSpeedTest(data))
		return
	case probeSpeedTestMethod:
		data := action.Data.(string)
		result.success(toolbox.HandleProbeSpeedTest(data))
		return
	case getSpeedTestServersMethod:
		data := action.Data.(string)
		result.success(toolbox.HandleSpeedTestServers(data))
		return
	case cancelSpeedTestMethod:
		result.success(toolbox.HandleCancelSpeedTest())
		return
	case startStunTestMethod:
		data := action.Data.(string)
		result.success(toolbox.HandleStartStunTest(data))
		return
	case cancelStunTestMethod:
		result.success(toolbox.HandleCancelStunTest())
		return
	case startIperfServerMethod:
		result.success(toolbox.HandleStartIperfServer(action.Data.(string)))
		return
	case stopIperfServerMethod:
		result.success(toolbox.HandleStopIperfServer())
		return
	case startIperfClientMethod:
		result.success(toolbox.HandleStartIperfClient(action.Data.(string)))
		return
	case cancelIperfClientMethod:
		result.success(toolbox.HandleCancelIperfClient())
		return
	case startLocalPingMethod:
		result.success(toolbox.HandleStartLocalPing(action.Data.(string)))
		return
	case cancelLocalPingMethod:
		result.success(toolbox.HandleCancelLocalPing())
		return
	case routeTraceMethod:
		result.success(toolbox.HandleRouteTrace(action.Data.(string)))
		return
	case dnsQueryMethod:
		result.success(toolbox.HandleDnsQuery(action.Data.(string)))
		return
	case mrsPrepareMethod:
		result.success(toolbox.HandleMrsPrepare())
		return
	case mrsLookupMethod:
		result.success(toolbox.HandleMrsLookup(action.Data.(string)))
		return
	case mrsDumpMethod:
		result.success(toolbox.HandleMrsDump(action.Data.(string)))
		return
	case cancelMrsLookupMethod:
		result.success(toolbox.HandleCancelMrsLookup())
		return
	case getTrafficStatsMethod:
		result.success(toolbox.HandleGetTrafficStats(action.Data.(string)))
		return
	case clearTrafficStatsMethod:
		result.success(toolbox.HandleClearTrafficStats())
		return
	case storeGetMethod:
		result.success(toolbox.HandleStoreGet(action.Data.(string)))
		return
	case storeSetMethod:
		result.success(toolbox.HandleStoreSet(action.Data.(string)))
		return
	case storeListMethod:
		result.success(toolbox.HandleStoreList(action.Data.(string)))
		return
	case storeClearMethod:
		result.success(toolbox.HandleStoreClear(action.Data.(string)))
		return
	case startToolProxyMethod:
		result.success(toolbox.HandleStartToolProxy())
		return
	case stopToolProxyMethod:
		toolbox.HandleStopToolProxy()
		result.success("true")
		return
	case ageCryptMethod:
		result.success(toolbox.HandleAgeCrypt(action.Data.(string)))
		return
	case getConnectionsMethod:
		result.success(handleGetConnections())
		return
	case getConnectionsSummaryMethod:
		result.success(handleGetConnectionsSummary())
		return
	case closeConnectionsMethod:
		result.success(handleCloseConnections())
		return
	case resetConnectionsMethod:
		result.success(handleResetConnections())
		return
	case getRequestsMethod:
		result.success(handleGetRequests())
		return
	case startTrackRequestsMethod:
		result.success(handleStartTrackRequests())
		return
	case stopTrackRequestsMethod:
		result.success(handleStopTrackRequests())
		return
	case clearRequestsMethod:
		result.success(handleClearRequests())
		return
	case getLogsMethod:
		result.success(handleGetLogs())
		return
	case clearLogsMethod:
		result.success(handleClearLogs())
		return
	case exportConfigMethod:
		var params ExportConfigParams
		if err := json.Unmarshal([]byte(action.Data.(string)), &params); err != nil {
			result.error(err)
			return
		}
		if err := handleExportConfig(&params); err != nil {
			result.error(err)
			return
		}
		result.success("")
		return
	case mergeProfilesMethod:
		var params MergeProfilesParams
		if err := json.Unmarshal([]byte(action.Data.(string)), &params); err != nil {
			result.error(err)
			return
		}
		report, err := handleMergeProfiles(&params)
		if err != nil {
			result.error(err)
			return
		}
		result.success(report)
		return
	case getRuntimeConfigMethod:
		params := defaultSetupParams()
		if err := UnmarshalJson([]byte(action.Data.(string)), params); err != nil {
			result.error(err)
			return
		}
		content, err := handleGetRuntimeConfig(params)
		if err != nil {
			result.error(err)
			return
		}
		result.success(content)
		return
	case getConfigMethod:
		paramsString := action.Data.(string)
		var params GetConfigParams
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			params.Path = paramsString
		}
		config, err := handleGetConfig(&params)
		if err != nil {
			result.error(err)
			return
		}
		result.success(config)
		return
	case closeConnectionMethod:
		id := action.Data.(string)
		result.success(handleCloseConnection(id))
		return
	case closeGroupConnectionsMethod:
		groupName := action.Data.(string)
		result.success(handleCloseGroupConnections(groupName))
		return
	case getExternalProvidersMethod:
		result.success(handleGetExternalProviders())
		return
	case getExternalProviderMethod:
		externalProviderName := action.Data.(string)
		result.success(handleGetExternalProvider(externalProviderName))
	case updateGeoDataMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result.success(err.Error())
			return
		}
		geoType := params["geo-type"]
		geoName := params["geo-name"]
		handleUpdateGeoData(geoType, geoName, func(value string) {
			result.success(value)
		})
		return
	case updateExternalProviderMethod:
		providerName := action.Data.(string)
		handleUpdateExternalProvider(providerName, func(value string) {
			result.success(value)
		})
		return
	case sideLoadExternalProviderMethod:
		paramsString := action.Data.(string)
		var params = map[string]string{}
		err := json.Unmarshal([]byte(paramsString), &params)
		if err != nil {
			result.success(err.Error())
			return
		}
		providerName := params["providerName"]
		data := params["data"]
		handleSideLoadExternalProvider(providerName, []byte(data), func(value string) {
			result.success(value)
		})
		return
	case parseExternalProviderContentMethod:
		providerName := action.Data.(string)
		handleParseExternalProviderContent(providerName, func(value string) {
			result.success(value)
		})
		return
	case startLogMethod:
		handleStartLog()
		result.success(true)
		return
	case stopLogMethod:
		handleStopLog()
		result.success(true)
		return
	case startListenerMethod:
		result.success(handleStartListener())
		return
	case stopListenerMethod:
		result.success(handleStopListener())
		return
	case getCountryCodeMethod:
		ip := action.Data.(string)
		handleGetCountryCode(ip, func(value string) {
			result.success(value)
		})
		return
	case getMemoryMethod:
		handleGetMemory(func(value string) {
			result.success(value)
		})
		return
	case getCoreStatusMethod:
		handleGetCoreStatus(func(value string) {
			result.success(value)
		})
		return
	case setStateMethod:
		data := action.Data.(string)
		handleSetState(data)
		result.success(true)
	case flushFakeIPMethod:
		result.success(handleFlushFakeIP())
		return
	case flushDnsCacheMethod:
		handleFlushDnsCache()
		result.success(true)
		return
	case generateAgeKeyPairMethod:
		generate := age.GenX25519KeyPair
		if kind, _ := action.Data.(string); kind == "mlkem768x25519" {
			generate = age.GenHybridKeyPair
		}
		secretKey, publicKey, err := generate()
		if err != nil {
			result.error(err.Error())
			return
		}
		result.success(map[string]string{
			"secret-key": secretKey,
			"public-key": publicKey,
		})
		return
	case convertAgeSecretKeyToPublicKeyMethod:
		secretKey := action.Data.(string)
		publicKeys, err := age.ToPublicKeys(secretKey)
		if err != nil {
			result.error(err.Error())
			return
		}
		if len(publicKeys) == 0 {
			result.error("no public keys found")
			return
		}
		result.success(publicKeys[0])
		return
	case crashMethod:
		result.success(true)
		handleCrash()
	default:
		nextHandle(action, result)
	}
}
