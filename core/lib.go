//go:build cgo

package main

/*
#include <stdlib.h>
*/
import "C"
import (
	bridge "core/dart-bridge"
	"encoding/json"
	"github.com/metacubex/mihomo/log"
	"sync"
	"time"
	"unsafe"
)

var messagePort int64 = -1

var (
	batchMutex      sync.Mutex
	batchMessages   []Message
	batchTimer      *time.Timer
	batchInterval   = 500 * time.Millisecond
)

func sendBatchMessages() {
	batchMutex.Lock()
	messages := make([]Message, len(batchMessages))
	copy(messages, batchMessages)
	batchMessages = batchMessages[:0]
	batchTimer = nil
	batchMutex.Unlock()

	if len(messages) == 0 || messagePort == -1 {
		return
	}
	result := ActionResult{
		Method: messageMethod,
		Port:   messagePort,
		Data:   messages,
	}
	result.send()
}

func shouldBatch(messageType MessageType) bool {
	if messageType != LogMessage && messageType != RequestMessage {
		return false
	}
	return log.Level() == log.DEBUG
}

//export initNativeApiBridge
func initNativeApiBridge(api unsafe.Pointer) {
	bridge.InitDartApi(api)
}

//export attachMessagePort
func attachMessagePort(mPort C.longlong) {
	messagePort = int64(mPort)
}

//export getTraffic
func getTraffic() *C.char {
	return C.CString(handleGetTraffic())
}

//export getTotalTraffic
func getTotalTraffic() *C.char {
	return C.CString(handleGetTotalTraffic())
}

//export freeCString
func freeCString(s *C.char) {
	C.free(unsafe.Pointer(s))
}

func (result ActionResult) send() {
	data, err := result.Json()
	if err != nil {
		return
	}
	bridge.SendToPort(result.Port, string(data))
}

//export invokeAction
func invokeAction(paramsChar *C.char, port C.longlong) {
	params := C.GoString(paramsChar)
	i := int64(port)
	var action = &Action{}
	err := json.Unmarshal([]byte(params), action)
	if err != nil {
		bridge.SendToPort(i, err.Error())
		return
	}
	result := ActionResult{
		Id:     action.Id,
		Method: action.Method,
		Port:   i,
	}
	go handleAction(action, result)
}

func sendMessage(message Message) {
	if messagePort == -1 {
		return
	}
	if shouldBatch(message.Type) {
		batchMutex.Lock()
		batchMessages = append(batchMessages, message)
		if batchTimer == nil {
			batchTimer = time.AfterFunc(batchInterval, sendBatchMessages)
		}
		batchMutex.Unlock()
		return
	}
	result := ActionResult{
		Method: messageMethod,
		Port:   messagePort,
		Data:   message,
	}
	result.send()
}

//export getConfig
func getConfig(s *C.char) *C.char {
	paramsString := C.GoString(s)
	var params GetConfigParams
	err := json.Unmarshal([]byte(paramsString), &params)
	if err != nil {
		params.Path = paramsString
	}
	config, err := handleGetConfig(&params)
	if err != nil {
		return C.CString("")
	}
	marshal, err := json.Marshal(config)
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(marshal))
}

//export startListener
func startListener() {
	handleStartListener()
}

//export stopListener
func stopListener() {
	handleStopListener()
}

//export suspend
func suspend(suspended C.int) {
	handleSuspend(suspended != 0)
}