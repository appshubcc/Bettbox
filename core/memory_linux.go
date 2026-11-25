//go:build linux && !android

package main

import (
	"os"
	"strconv"
	"strings"

	"golang.org/x/sys/unix"
)

func purgeNativeMemory() {
	data, err := os.ReadFile("/proc/self/maps")
	if err != nil {
		return
	}
	for _, line := range strings.Split(string(data), "\n") {
		fields := strings.Fields(line)
		if len(fields) < 2 || fields[1] != "r-xp" {
			continue
		}
		pathStart := strings.IndexByte(line, '/')
		if pathStart < 0 {
			continue
		}
		path := line[pathStart:]
		if strings.HasPrefix(path, "/dev/") ||
			strings.HasPrefix(path, "/memfd:") ||
			strings.HasSuffix(path, " (deleted)") {
			continue
		}
		startHex, endHex, ok := strings.Cut(fields[0], "-")
		if !ok {
			continue
		}
		start, err1 := strconv.ParseUint(startHex, 16, 64)
		end, err2 := strconv.ParseUint(endHex, 16, 64)
		if err1 != nil || err2 != nil || end <= start {
			continue
		}
		_, _, _ = unix.Syscall(unix.SYS_MADVISE, uintptr(start), uintptr(end-start), unix.MADV_PAGEOUT)
	}
}
