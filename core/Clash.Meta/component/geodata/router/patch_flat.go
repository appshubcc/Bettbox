package router

import (
	"encoding/binary"
	"errors"
	"os"
	"path/filepath"
	"runtime"

	"github.com/metacubex/mihomo/component/geodata/strmatcher"
	"github.com/metacubex/mihomo/component/trie"
)

const (
	flatMagic      = "BBGSITE1"
	flatHeaderSize = 24
)

var errInvalidFlatMatcher = errors.New("invalid flat geosite matcher")

type flatDomainMatcher struct {
	succinctDomainMatcher
	release func()
}

func (m *flatDomainMatcher) ApplyDomain(domain string) bool {
	matched := m.succinctDomainMatcher.ApplyDomain(domain)
	runtime.KeepAlive(m)
	return matched
}

func WriteFlatMatcher(path string, name string, matcher DomainMatcher, domains []*Domain) error {
	m, ok := matcher.(*succinctDomainMatcher)
	if !ok {
		return errInvalidFlatMatcher
	}
	buf := make([]byte, flatHeaderSize)
	copy(buf, flatMagic)
	binary.LittleEndian.PutUint64(buf[8:], uint64(m.count))
	buf = m.set.AppendFlat(buf)
	buf = binary.AppendUvarint(buf, uint64(len(name)))
	buf = append(buf, name...)
	for _, d := range domains {
		if d.Type != Domain_Plain && d.Type != Domain_Regex {
			continue
		}
		buf = append(buf, byte(d.Type))
		buf = binary.AppendUvarint(buf, uint64(len(d.Value)))
		buf = append(buf, d.Value...)
	}
	binary.LittleEndian.PutUint64(buf[16:], uint64(len(buf)))

	file, err := os.CreateTemp(filepath.Dir(path), filepath.Base(path)+".*")
	if err != nil {
		return err
	}
	tmp := file.Name()
	_, err = file.Write(buf)
	if err == nil {
		err = file.Sync()
	}
	if closeErr := file.Close(); err == nil {
		err = closeErr
	}
	if err == nil {
		err = os.Rename(tmp, path)
	}
	if err != nil {
		_ = os.Remove(tmp)
	}
	return err
}

func OpenFlatMatcher(path string, name string) (DomainMatcher, error) {
	data, release, err := mapFlatFile(path)
	if err != nil {
		return nil, err
	}
	m, err := parseFlatMatcher(data, name)
	if err != nil {
		if release != nil {
			release()
		}
		return nil, err
	}
	if release != nil {
		m.release = release
		runtime.SetFinalizer(m, func(m *flatDomainMatcher) {
			m.release()
		})
	}
	return m, nil
}

func parseFlatMatcher(data []byte, name string) (*flatDomainMatcher, error) {
	if len(data) < flatHeaderSize || string(data[:8]) != flatMagic {
		return nil, errInvalidFlatMatcher
	}
	if binary.LittleEndian.Uint64(data[16:]) != uint64(len(data)) {
		return nil, errInvalidFlatMatcher
	}
	set, n, err := trie.DomainSetFromFlat(data[flatHeaderSize:])
	if err != nil {
		return nil, err
	}
	m := &flatDomainMatcher{}
	m.set = set
	m.count = int(binary.LittleEndian.Uint64(data[8:]))

	tail := data[flatHeaderSize+n:]
	stored, tail, ok := readFlatString(tail)
	if !ok || stored != name {
		return nil, errInvalidFlatMatcher
	}
	for len(tail) > 0 {
		matcherType, ok := matcherTypeMap[Domain_Type(tail[0])]
		if !ok || (matcherType != strmatcher.Substr && matcherType != strmatcher.Regex) {
			return nil, errInvalidFlatMatcher
		}
		var value string
		value, tail, ok = readFlatString(tail[1:])
		if !ok {
			return nil, errInvalidFlatMatcher
		}
		matcher, err := matcherType.New(value)
		if err != nil {
			return nil, err
		}
		m.otherMatchers = append(m.otherMatchers, matcher)
	}
	return m, nil
}

func readFlatString(b []byte) (string, []byte, bool) {
	size, n := binary.Uvarint(b)
	if n <= 0 || size > uint64(len(b)-n) {
		return "", nil, false
	}
	end := n + int(size)
	return string(b[n:end]), b[end:], true
}
