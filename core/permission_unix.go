//go:build (darwin || linux) && !android

package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sync"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
)

var (
	permGuardOnce sync.Once
	permSyncChan  chan struct{}
	activeHomeDir string
	permLock      sync.Mutex
	homeRoot      *os.Root
)

func isPrivileged() bool {
	return os.Geteuid() == 0 && os.Getuid() != 0
}

func isAllowedHomeDir(homeDir string) bool {
	if homeDir == "" {
		return false
	}
	if !isPrivileged() {
		return true
	}
	if constant.Path.IsSafePath("/") {
		return false
	}
	for _, safePath := range constant.Path.SafePaths()[1:] {
		if filepath.Clean(safePath) != filepath.Clean(homeDir) {
			return false
		}
	}
	root, err := os.OpenRoot(homeDir)
	if err != nil {
		return false
	}
	if info, err := root.Stat("."); err == nil {
		if stat, ok := info.Sys().(*syscall.Stat_t); ok && int(stat.Uid) == os.Getuid() {
			homeRoot = root
			return true
		}
	}
	_ = root.Close()
	return false
}

func openInputFile(path string) (*os.File, error) {
	file, err := os.Open(path)
	if err != nil || !isPrivileged() {
		return file, err
	}
	if info, err := file.Stat(); err == nil {
		if stat, ok := info.Sys().(*syscall.Stat_t); ok && int(stat.Uid) == os.Getuid() {
			return file, nil
		}
	}
	_ = file.Close()
	return nil, fmt.Errorf("unsafe input path: %s", path)
}

func openOutputFile(path string) (*os.File, error) {
	if !isPrivileged() {
		return os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0o600)
	}
	rel, err := filepath.Rel(constant.Path.HomeDir(), path)
	if homeRoot == nil || err != nil || !filepath.IsLocal(rel) {
		return nil, fmt.Errorf("unsafe output path: %s", path)
	}
	file, err := homeRoot.OpenFile(rel, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600)
	if err != nil {
		return nil, err
	}
	if err := file.Chown(os.Getuid(), os.Getgid()); err != nil {
		_ = file.Close()
		return nil, err
	}
	return file, nil
}

func syncDirectoryPermissions(baseDir string, targetUid, targetGid int) {
	if baseDir == "" || !isPrivileged() {
		return
	}

	baseInfo, err := os.Lstat(baseDir)
	if err != nil || !baseInfo.IsDir() {
		return
	}
	if stat, ok := baseInfo.Sys().(*syscall.Stat_t); !ok || int(stat.Uid) != targetUid {
		return
	}

	fixedCount := 0
	_ = filepath.WalkDir(baseDir, func(currentPath string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		if d.Type()&fs.ModeSymlink != 0 {
			if d.IsDir() {
				return fs.SkipDir
			}
			return nil
		}

		fd, openErr := syscall.Open(currentPath, syscall.O_RDONLY|syscall.O_NOFOLLOW|syscall.O_NONBLOCK|syscall.O_CLOEXEC, 0)
		if openErr != nil {
			return nil
		}
		defer syscall.Close(fd)

		var st syscall.Stat_t
		if err := syscall.Fstat(fd, &st); err != nil {
			return nil
		}

		if int(st.Uid) == targetUid {
			return nil
		}

		mode := st.Mode & syscall.S_IFMT
		if mode != syscall.S_IFDIR && mode != syscall.S_IFREG {
			return nil
		}
		if mode == syscall.S_IFREG && st.Nlink > 1 {
			return nil
		}

		if err := syscall.Fchown(fd, targetUid, targetGid); err == nil {
			fixedCount++
		}
		return nil
	})

	if fixedCount > 0 {
		log.Infoln("[PermGuard] synchronized permissions for %d entries in %s", fixedCount, baseDir)
	}
}

func initPermissionGuard(homeDir string) {
	if !isPrivileged() || homeDir == "" {
		return
	}

	permLock.Lock()
	activeHomeDir = homeDir
	permLock.Unlock()

	permGuardOnce.Do(func() {
		permSyncChan = make(chan struct{}, 1)
		go func() {
			uid := os.Getuid()
			gid := os.Getgid()
			for range permSyncChan {
				time.Sleep(2 * time.Second)
				permLock.Lock()
				dir := activeHomeDir
				permLock.Unlock()
				syncDirectoryPermissions(dir, uid, gid)
			}
		}()
	})

	schedulePermissionSync()
}

func schedulePermissionSync() {
	if !isPrivileged() || permSyncChan == nil {
		return
	}
	select {
	case permSyncChan <- struct{}{}:
	default:
	}
}
