//go:build !cgo

package main

import (
	"fmt"
	"os"
	"os/signal"
	"runtime"
	"syscall"
)

func main() {
	args := os.Args
	if len(args) <= 1 {
		fmt.Println("Arguments error")
		os.Exit(1)
	}
	// On stop, hand files a privileged core wrote late (e.g. lazily started
	// tsnet state) back to the user. The app closes the socket, then sends
	// SIGTERM; either may arrive first, so both paths sync. Not on Windows:
	// there the sync is a no-op and SIGTERM also means "a user logged off".
	if runtime.GOOS != "windows" {
		signals := make(chan os.Signal, 1)
		signal.Notify(signals, syscall.SIGTERM, os.Interrupt)
		go func() {
			<-signals
			syncPermissionsNow()
			os.Exit(0)
		}()
	}
	startServer(args[1])
	syncPermissionsNow()
}
