//go:build unix

package router

import (
	"os"
	"syscall"
)

func mapFlatFile(path string) ([]byte, func(), error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, nil, err
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil {
		return nil, nil, err
	}
	size := info.Size()
	if size < flatHeaderSize || size > 1<<30 {
		return nil, nil, errInvalidFlatMatcher
	}
	data, err := syscall.Mmap(int(file.Fd()), 0, int(size), syscall.PROT_READ, syscall.MAP_SHARED)
	if err != nil {
		return nil, nil, err
	}
	return data, func() {
		_ = syscall.Munmap(data)
	}, nil
}
