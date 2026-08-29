//go:build !android && !ohos && cgo

package main

func nextHandle(action *Action, result ActionResult) bool {
	return false
}
