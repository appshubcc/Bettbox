//go:build !(darwin || linux) || android

package main

func initPermissionGuard(homeDir string) {}

func syncPermissionsNow() {}

func schedulePermissionSync() {}
