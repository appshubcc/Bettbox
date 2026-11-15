//go:build unix

package provider

import (
	"os"
	"syscall"
)

const preferMappedReload = true

func mapFlatRuleFile(path string) ([]byte, func(), error) {
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
	if size < flatRuleHeaderSize || size > 1<<30 {
		return nil, nil, errInvalidFlatRuleSet
	}
	data, err := syscall.Mmap(int(file.Fd()), 0, int(size), syscall.PROT_READ, syscall.MAP_SHARED)
	if err != nil {
		return nil, nil, err
	}
	return data, func() {
		_ = syscall.Munmap(data)
	}, nil
}
