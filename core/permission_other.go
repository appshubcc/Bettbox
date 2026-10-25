//go:build !(darwin || linux) || android

package main

func initPermissionGuard(homeDir string) {}

func schedulePermissionSync() {}

func syncFileOwner(path string) {}
