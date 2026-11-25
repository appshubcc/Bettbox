//go:build !windows && !(linux && !android) && !(android && cgo)

package main

func purgeNativeMemory() {}
