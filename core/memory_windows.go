//go:build windows

package main

import "golang.org/x/sys/windows"

var (
	kernel32DLL         = windows.NewLazySystemDLL("kernel32.dll")
	procEmptyWorkingSet = kernel32DLL.NewProc("K32EmptyWorkingSet")
)

func purgeNativeMemory() {
	if err := procEmptyWorkingSet.Find(); err != nil {
		return
	}
	_, _, _ = procEmptyWorkingSet.Call(uintptr(windows.CurrentProcess()))
}
