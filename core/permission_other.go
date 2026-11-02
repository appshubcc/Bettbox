//go:build !(darwin || linux) || android

package main

import "os"

func isAllowedHomeDir(homeDir string) bool {
	return homeDir != ""
}

func openInputFile(path string) (*os.File, error) {
	return os.Open(path)
}

func openOutputFile(path string) (*os.File, error) {
	return os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0o600)
}

func initPermissionGuard(homeDir string) {}

func schedulePermissionSync() {}
