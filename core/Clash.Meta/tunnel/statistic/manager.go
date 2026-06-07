package statistic

import (
	"os"
	"runtime"
	"time"

	"github.com/metacubex/mihomo/common/atomic"
	"github.com/metacubex/mihomo/common/xsync"
)

var IsDirectFunc func(string) bool

var DefaultManager *Manager

func init() {
	DefaultManager = &Manager{
		uploadTemp:         atomic.NewInt64(0),
		downloadTemp:       atomic.NewInt64(0),
		uploadBlip:         atomic.NewInt64(0),
		downloadBlip:       atomic.NewInt64(0),
		uploadTotal:        atomic.NewInt64(0),
		downloadTotal:      atomic.NewInt64(0),
		proxyUploadTemp:    atomic.NewInt64(0),
		proxyDownloadTemp:  atomic.NewInt64(0),
		proxyUploadBlip:    atomic.NewInt64(0),
		proxyDownloadBlip:  atomic.NewInt64(0),
		proxyUploadTotal:   atomic.NewInt64(0),
		proxyDownloadTotal: atomic.NewInt64(0),
		pid:                int32(os.Getpid()),
	}

	go DefaultManager.handle()
}

type Manager struct {
	connections        xsync.Map[string, Tracker]
	uploadTemp         atomic.Int64
	downloadTemp       atomic.Int64
	uploadBlip         atomic.Int64
	downloadBlip       atomic.Int64
	uploadTotal        atomic.Int64
	downloadTotal      atomic.Int64
	proxyUploadTemp    atomic.Int64
	proxyDownloadTemp  atomic.Int64
	proxyUploadBlip    atomic.Int64
	proxyDownloadBlip  atomic.Int64
	proxyUploadTotal   atomic.Int64
	proxyDownloadTotal atomic.Int64
	pid                int32
	memory             uint64
}

func (m *Manager) Join(c Tracker) {
	m.connections.Store(c.ID(), c)
}

func (m *Manager) Leave(c Tracker) {
	m.connections.Delete(c.ID())
	if DefaultRequestNotify != nil {
		DefaultRequestNotify(c)
	}
}

func (m *Manager) Get(id string) (c Tracker) {
	if value, ok := m.connections.Load(id); ok {
		c = value
	}
	return
}

func (m *Manager) Range(f func(c Tracker) bool) {
	m.connections.Range(func(key string, value Tracker) bool {
		return f(value)
	})
}

func (m *Manager) PushUploaded(isDirect bool, size int64) {
	if !isDirect {
		m.proxyUploadTemp.Add(size)
		m.proxyUploadTotal.Add(size)
	}
	m.uploadTemp.Add(size)
	m.uploadTotal.Add(size)
}

func (m *Manager) PushDownloaded(isDirect bool, size int64) {
	if !isDirect {
		m.proxyDownloadTemp.Add(size)
		m.proxyDownloadTotal.Add(size)
	}
	m.downloadTemp.Add(size)
	m.downloadTotal.Add(size)
}

func (m *Manager) Now() (up int64, down int64) {
	return m.uploadBlip.Load(), m.downloadBlip.Load()
}

func (m *Manager) Total() (up, down int64) {
	return m.uploadTotal.Load(), m.downloadTotal.Load()
}

func (m *Manager) Memory() uint64 {
	m.updateMemory()
	return m.memory
}

func (m *Manager) ResetStatistic() {
	m.uploadTemp.Store(0)
	m.uploadBlip.Store(0)
	m.uploadTotal.Store(0)
	m.downloadTemp.Store(0)
	m.downloadBlip.Store(0)
	m.downloadTotal.Store(0)

	m.proxyUploadTemp.Store(0)
	m.proxyUploadBlip.Store(0)
	m.proxyUploadTotal.Store(0)
	m.proxyDownloadTemp.Store(0)
	m.proxyDownloadBlip.Store(0)
	m.proxyDownloadTotal.Store(0)
}

func (m *Manager) updateMemory() {
	var memStats runtime.MemStats
	runtime.ReadMemStats(&memStats)
	m.memory = memStats.StackInuse + memStats.HeapInuse
}

func (m *Manager) handle() {
	ticker := time.NewTicker(time.Second)

	for range ticker.C {
		m.uploadBlip.Store(m.uploadTemp.Swap(0))
		m.downloadBlip.Store(m.downloadTemp.Swap(0))
		m.proxyUploadBlip.Store(m.proxyUploadTemp.Swap(0))
		m.proxyDownloadBlip.Store(m.proxyDownloadTemp.Swap(0))
	}
}

type Snapshot struct {
	DownloadTotal   int64         `json:"downloadTotal"`
	UploadTotal     int64         `json:"uploadTotal"`
	Connections     []TrackerInfo `json:"connections"`
	Memory          uint64        `json:"memory"`
}

func (m *Manager) Snapshot() *Snapshot {
	m.updateMemory()

	connections := make([]TrackerInfo, 0)
	m.connections.Range(func(key string, value Tracker) bool {
		connections = append(connections, *value.Info())
		return true
	})

	return &Snapshot{
		DownloadTotal:   m.downloadTotal.Load(),
		UploadTotal:     m.uploadTotal.Load(),
		Connections:     connections,
		Memory:          m.memory,
	}
}
