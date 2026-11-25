package mmdb

import (
	"net"
	"sync"
)

var (
	ipLock  sync.RWMutex
	asnLock sync.RWMutex
)

func LookupCode(ip net.IP) []string {
	ipLock.RLock()
	defer ipLock.RUnlock()
	return IPInstance().LookupCode(ip)
}

func LookupASN(ip net.IP) (string, string) {
	asnLock.RLock()
	defer asnLock.RUnlock()
	return ASNInstance().LookupASN(ip)
}

func ReplaceIP(write func() error) error {
	ipLock.Lock()
	defer ipLock.Unlock()
	if ipReader.Reader != nil {
		_ = ipReader.Reader.Close()
		ipReader = IPReader{}
	}
	ReloadIP()
	if write == nil {
		return nil
	}
	return write()
}

func ReplaceASN(write func() error) error {
	asnLock.Lock()
	defer asnLock.Unlock()
	if asnReader.Reader != nil {
		_ = asnReader.Reader.Close()
		asnReader = ASNReader{}
	}
	ReloadASN()
	if write == nil {
		return nil
	}
	return write()
}
