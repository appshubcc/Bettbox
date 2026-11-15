package trie

import (
	"errors"
	"unsafe"
)

const flatSectionCount = 5

const flatHeaderSize = flatSectionCount * 8

var errInvalidFlatDomainSet = errors.New("invalid flat domain set")

func flatBytes[T uint64 | int32](s []T) []byte {
	if len(s) == 0 {
		return nil
	}
	return unsafe.Slice((*byte)(unsafe.Pointer(&s[0])), len(s)*int(unsafe.Sizeof(s[0])))
}

func flatSlice[T uint64 | int32](b []byte) []T {
	if len(b) == 0 {
		return nil
	}
	var zero T
	return unsafe.Slice((*T)(unsafe.Pointer(&b[0])), len(b)/int(unsafe.Sizeof(zero)))
}

func (ss *DomainSet) AppendFlat(dst []byte) []byte {
	if ss == nil {
		ss = &DomainSet{}
	}
	sections := [flatSectionCount][]byte{
		flatBytes(ss.leaves),
		flatBytes(ss.labelBitmap),
		ss.labels,
		flatBytes(ss.ranks),
		flatBytes(ss.selects),
	}
	var header [flatSectionCount]uint64
	for i, section := range sections {
		header[i] = uint64(len(section))
	}
	dst = append(dst, flatBytes(header[:])...)
	for _, section := range sections {
		dst = append(dst, section...)
		dst = append(dst, make([]byte, -len(section)&7)...)
	}
	return dst
}

func DomainSetFromFlat(b []byte) (*DomainSet, int, error) {
	if len(b) < flatHeaderSize || uintptr(unsafe.Pointer(&b[0]))&7 != 0 {
		return nil, 0, errInvalidFlatDomainSet
	}
	header := flatSlice[uint64](b[:flatHeaderSize])
	if header[0]&7 != 0 || header[1]&7 != 0 || header[3]&3 != 0 || header[4]&3 != 0 {
		return nil, 0, errInvalidFlatDomainSet
	}
	var sections [flatSectionCount][]byte
	offset := uint64(flatHeaderSize)
	total := uint64(len(b))
	for i, size := range header {
		if size > total-offset {
			return nil, 0, errInvalidFlatDomainSet
		}
		sections[i] = b[offset : offset+size : offset+size]
		offset += (size + 7) &^ 7
		if offset > total {
			return nil, 0, errInvalidFlatDomainSet
		}
	}
	if len(sections[1]) == 0 {
		return nil, int(offset), nil
	}
	return &DomainSet{
		leaves:      flatSlice[uint64](sections[0]),
		labelBitmap: flatSlice[uint64](sections[1]),
		labels:      sections[2],
		ranks:       flatSlice[int32](sections[3]),
		selects:     flatSlice[int32](sections[4]),
	}, int(offset), nil
}
