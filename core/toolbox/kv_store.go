package toolbox

import (
	"bytes"
	"cmp"
	"encoding/json"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"sync"
	"time"
)

const (
	kvFlushDelay  = 2 * time.Second
	kvIdleRelease = 3 * time.Minute
)

type kvSpace struct {
	file  string
	ttl   time.Duration
	limit int
}

var kvSpaces = map[string]kvSpace{
	"ip":        {file: "ip_cache.dat", ttl: 30 * 24 * time.Hour, limit: 1024},
	"speedTest": {file: "speed_test.dat", ttl: 14 * 24 * time.Hour, limit: 200},
	"toolbox":   {file: "toolbox.dat", limit: 256},
}

type kvEntry struct {
	Time int64
	Data []byte
}

type kvStore struct {
	space      kvSpace
	mu         sync.Mutex
	writeMu    sync.Mutex
	path       string
	entries    map[string]kvEntry
	dirty      bool
	lastAccess time.Time
	flushTimer *time.Timer
	idleTimer  *time.Timer
}

type kvParams struct {
	Space string          `json:"ns"`
	Key   string          `json:"key"`
	Data  json.RawMessage `json:"data"`
	Time  int64           `json:"time"`
}

var (
	kvLock   sync.Mutex
	kvStores = map[string]*kvStore{}
)

func InitKvStore(homeDir string) {
	kvLock.Lock()
	defer kvLock.Unlock()
	for name, space := range kvSpaces {
		store := kvStores[name]
		if store == nil {
			store = &kvStore{space: space}
			kvStores[name] = store
		}
		store.mu.Lock()
		store.path = filepath.Join(homeDir, space.file)
		store.entries = nil
		store.dirty = false
		store.mu.Unlock()
	}
}

func FlushKvStore() {
	for _, store := range kvStoreList() {
		store.flush()
	}
}

func kvStoreList() []*kvStore {
	kvLock.Lock()
	defer kvLock.Unlock()
	return slices.Collect(maps.Values(kvStores))
}

func kvStoreOf(name string) *kvStore {
	kvLock.Lock()
	defer kvLock.Unlock()
	return kvStores[name]
}

func parseKvParams(paramsString string) (kvParams, *kvStore) {
	var params kvParams
	if json.Unmarshal([]byte(paramsString), &params) != nil || params.Key == "" {
		return params, nil
	}
	return params, kvStoreOf(params.Space)
}

func HandleStoreGet(paramsString string) string {
	params, store := parseKvParams(paramsString)
	if store == nil {
		return ""
	}
	return store.get(params.Key)
}

func HandleStoreSet(paramsString string) bool {
	params, store := parseKvParams(paramsString)
	if store == nil || len(params.Data) == 0 {
		return false
	}
	return store.set(params.Key, params.Data, params.Time)
}

func HandleStoreList(space string) string {
	store := kvStoreOf(space)
	if store == nil {
		return "[]"
	}
	return store.list()
}

func HandleStoreClear(space string) bool {
	store := kvStoreOf(space)
	if store == nil {
		return false
	}
	store.clear()
	return true
}

func (s *kvStore) expiredLocked(entry kvEntry, now time.Time) bool {
	return s.space.ttl > 0 && entry.Time < now.Add(-s.space.ttl).UnixMilli()
}

func (s *kvStore) loadLocked() bool {
	if s.path == "" {
		return false
	}
	now := trafficNow()
	s.lastAccess = now
	if s.idleTimer == nil {
		s.idleTimer = time.AfterFunc(kvIdleRelease, s.release)
	}
	if s.entries != nil {
		return true
	}
	entries := map[string]kvEntry{}
	readStoreFile(s.path, &entries)
	s.entries = entries
	for key, entry := range entries {
		if s.expiredLocked(entry, now) {
			delete(entries, key)
			s.markDirtyLocked()
		}
	}
	return true
}

func (s *kvStore) markDirtyLocked() {
	s.dirty = true
	if s.flushTimer == nil {
		s.flushTimer = time.AfterFunc(kvFlushDelay, s.flush)
	}
}

func (s *kvStore) get(key string) string {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.loadLocked() {
		return ""
	}
	entry, ok := s.entries[key]
	if !ok {
		return ""
	}
	if s.expiredLocked(entry, trafficNow()) {
		delete(s.entries, key)
		s.markDirtyLocked()
		return ""
	}
	return string(entry.Data)
}

func (s *kvStore) set(key string, data []byte, at int64) bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.loadLocked() {
		return false
	}
	now := trafficNow()
	if at <= 0 {
		at = now.UnixMilli()
	}
	entry := kvEntry{Time: at, Data: data}
	if s.expiredLocked(entry, now) {
		return true
	}
	s.entries[key] = entry
	for s.space.limit > 0 && len(s.entries) > s.space.limit {
		oldest, oldestTime := "", int64(0)
		for name, item := range s.entries {
			if oldest == "" || item.Time < oldestTime {
				oldest, oldestTime = name, item.Time
			}
		}
		delete(s.entries, oldest)
	}
	s.markDirtyLocked()
	return true
}

func (s *kvStore) list() string {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.loadLocked() {
		return "[]"
	}
	now := trafficNow()
	keys := make([]string, 0, len(s.entries))
	for key, entry := range s.entries {
		if s.expiredLocked(entry, now) {
			delete(s.entries, key)
			s.markDirtyLocked()
			continue
		}
		keys = append(keys, key)
	}
	slices.SortFunc(keys, func(a, b string) int {
		if c := cmp.Compare(s.entries[b].Time, s.entries[a].Time); c != 0 {
			return c
		}
		return cmp.Compare(b, a)
	})
	var buf bytes.Buffer
	buf.WriteByte('[')
	for i, key := range keys {
		if i > 0 {
			buf.WriteByte(',')
		}
		buf.Write(s.entries[key].Data)
	}
	buf.WriteByte(']')
	return buf.String()
}

func (s *kvStore) flush() {
	s.writeMu.Lock()
	defer s.writeMu.Unlock()
	s.mu.Lock()
	if s.flushTimer != nil {
		s.flushTimer.Stop()
		s.flushTimer = nil
	}
	if !s.dirty || s.entries == nil || s.path == "" {
		s.mu.Unlock()
		return
	}
	path := s.path
	snapshot := maps.Clone(s.entries)
	s.dirty = false
	s.mu.Unlock()
	if err := writeStoreFile(path, snapshot); err != nil {
		s.mu.Lock()
		s.markDirtyLocked()
		s.mu.Unlock()
	}
}

func (s *kvStore) release() {
	s.flush()
	s.mu.Lock()
	defer s.mu.Unlock()
	s.idleTimer = nil
	if remain := kvIdleRelease - trafficNow().Sub(s.lastAccess); remain > 0 || s.dirty {
		s.idleTimer = time.AfterFunc(max(remain, kvFlushDelay), s.release)
		return
	}
	s.entries = nil
}

func (s *kvStore) clear() {
	s.writeMu.Lock()
	defer s.writeMu.Unlock()
	s.mu.Lock()
	path := s.path
	if s.flushTimer != nil {
		s.flushTimer.Stop()
		s.flushTimer = nil
	}
	s.entries = nil
	s.dirty = false
	s.mu.Unlock()
	if path != "" {
		_ = os.Remove(path)
	}
}
