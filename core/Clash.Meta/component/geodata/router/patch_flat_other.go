//go:build !unix

package router

import (
	"io"
	"os"
	"unsafe"
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
	backing := make([]uint64, (size+7)/8)
	data := unsafe.Slice((*byte)(unsafe.Pointer(&backing[0])), int(size))
	if _, err := io.ReadFull(file, data); err != nil {
		return nil, nil, err
	}
	return data, nil, nil
}
