package main

import (
	"reflect"
	"sync"
	"unsafe"

	"github.com/metacubex/mihomo/adapter/outbound"
	cProxy "github.com/metacubex/mihomo/constant"
	cp "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
)

type suspendedEntry struct {
	target *[]cProxy.Proxy
	orig   []cProxy.Proxy
}

var (
	suspendedHCLock    sync.Mutex
	suspendedEntries   []suspendedEntry
	suspendedWGLock    sync.Mutex
	suspendedWGDevices = make(map[uintptr]reflect.Value)
)

func findFieldByName(v reflect.Value, name string) reflect.Value {
	for v.Kind() == reflect.Pointer || v.Kind() == reflect.Interface {
		if v.IsNil() {
			return reflect.Value{}
		}
		v = v.Elem()
	}
	if v.Kind() != reflect.Struct {
		return reflect.Value{}
	}

	f := v.FieldByName(name)
	if f.IsValid() {
		return f
	}

	for i := 0; i < v.NumField(); i++ {
		field := v.Field(i)
		for field.Kind() == reflect.Pointer || field.Kind() == reflect.Interface {
			if field.IsNil() {
				break
			}
			field = field.Elem()
		}
		if field.Kind() == reflect.Struct {
			if found := findFieldByName(field, name); found.IsValid() {
				return found
			}
		}
	}
	return reflect.Value{}
}

func pauseHealthChecks() {
	suspendedHCLock.Lock()
	defer suspendedHCLock.Unlock()

	providers := tunnel.Providers()
	if len(providers) == 0 {
		return
	}

	for _, p := range providers {
		hcField := findFieldByName(reflect.ValueOf(p), "healthCheck")
		if !hcField.IsValid() || hcField.IsNil() {
			continue
		}

		hcElem := hcField.Elem()
		if hcElem.Kind() != reflect.Struct {
			continue
		}

		proxiesField := hcElem.FieldByName("proxies")
		if proxiesField.IsValid() && proxiesField.CanAddr() {
			ptr := (*[]cProxy.Proxy)(unsafe.Pointer(proxiesField.UnsafeAddr()))
			orig := *ptr
			if len(orig) > 0 {
				alreadySaved := false
				for _, entry := range suspendedEntries {
					if entry.target == ptr {
						alreadySaved = true
						break
					}
				}
				if !alreadySaved {
					suspendedEntries = append(suspendedEntries, suspendedEntry{
						target: ptr,
						orig:   orig,
					})
					*ptr = nil
				}
			}
		}
	}
}

func resumeHealthChecks() {
	suspendedHCLock.Lock()
	defer suspendedHCLock.Unlock()

	for _, entry := range suspendedEntries {
		*entry.target = entry.orig
	}
	suspendedEntries = nil
}

func clearSuspendedHealthChecks() {
	suspendedHCLock.Lock()
	defer suspendedHCLock.Unlock()
	for _, entry := range suspendedEntries {
		*entry.target = entry.orig
	}
	suspendedEntries = nil
}

func closeIdleOutbounds(proxies map[string]cProxy.Proxy, providers map[string]cp.ProxyProvider) {
	for _, p := range proxies {
		closeIdleOutbound(p)
	}
	for _, pr := range providers {
		for _, p := range pr.Proxies() {
			closeIdleOutbound(p)
		}
	}
}

func closeIdleOutbound(p cProxy.Proxy) {
	if closer, ok := p.Adapter().(outbound.IdleCloser); ok {
		closer.CloseIdle()
	}
}

func pauseSingleWireGuard(p cProxy.Proxy) {
	if p == nil || p.Type() != cProxy.WireGuard {
		return
	}

	initOkField := findFieldByName(reflect.ValueOf(p), "initOk")
	if initOkField.IsValid() {
		loadMethod := initOkField.MethodByName("Load")
		if loadMethod.IsValid() {
			res := loadMethod.Call(nil)
			if len(res) > 0 && !res[0].Bool() {
				return
			}
		}
	}

	devField := findFieldByName(reflect.ValueOf(p), "device")
	if !devField.IsValid() || devField.IsNil() {
		return
	}

	devVal := devField
	if devVal.Kind() == reflect.Interface {
		if devVal.IsNil() {
			return
		}
		devVal = devVal.Elem()
	}
	if devVal.Kind() != reflect.Pointer || devVal.IsNil() {
		return
	}

	ptr := devVal.Pointer()
	if _, exists := suspendedWGDevices[ptr]; exists {
		return
	}

	downMethod := devVal.MethodByName("Down")
	if !downMethod.IsValid() {
		return
	}

	_ = downMethod.Call(nil)
	suspendedWGDevices[ptr] = devVal
}

func pauseWireGuard() {
	suspendedWGLock.Lock()
	defer suspendedWGLock.Unlock()

	for _, p := range tunnel.Proxies() {
		pauseSingleWireGuard(p)
	}
	for _, pr := range tunnel.Providers() {
		for _, p := range pr.Proxies() {
			pauseSingleWireGuard(p)
		}
	}
}

func resumeWireGuard() {
	suspendedWGLock.Lock()
	defer suspendedWGLock.Unlock()

	for _, devVal := range suspendedWGDevices {
		upMethod := devVal.MethodByName("Up")
		if upMethod.IsValid() {
			_ = upMethod.Call(nil)
		}
	}
	suspendedWGDevices = make(map[uintptr]reflect.Value)
}

func clearSuspendedWireGuard() {
	suspendedWGLock.Lock()
	defer suspendedWGLock.Unlock()
	suspendedWGDevices = make(map[uintptr]reflect.Value)
}
