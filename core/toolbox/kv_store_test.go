package toolbox

import (
	"bytes"
	"fmt"
	"os"
	"testing"
	"time"
)

func newTestKvStore(t *testing.T) {
	t.Helper()
	InitKvStore(t.TempDir())
	t.Cleanup(func() {
		for _, store := range kvStoreList() {
			store.clear()
			store.mu.Lock()
			if store.idleTimer != nil {
				store.idleTimer.Stop()
				store.idleTimer = nil
			}
			store.mu.Unlock()
		}
	})
}

func TestKvStoreRoundTripAndReload(t *testing.T) {
	useTrafficNow(t, time.Date(2026, 11, 2, 0, 0, 0, 0, time.UTC))
	newTestKvStore(t)
	if !HandleStoreSet(`{"ns":"ip","key":"risk_1.2.3.4","data":{"ip":"1.2.3.4","score":88}}`) {
		t.Fatal("set should succeed")
	}
	if got := HandleStoreGet(`{"ns":"ip","key":"risk_1.2.3.4"}`); got != `{"ip":"1.2.3.4","score":88}` {
		t.Fatalf("unexpected value: %s", got)
	}
	if got := HandleStoreGet(`{"ns":"ip","key":"risk_5.6.7.8"}`); got != "" {
		t.Fatalf("missing key should be empty: %s", got)
	}
	FlushKvStore()
	store := kvStoreOf("ip")
	content, err := os.ReadFile(store.path)
	if err != nil {
		t.Fatal(err)
	}
	if bytes.Contains(content, []byte("1.2.3.4")) {
		t.Fatal("store file should not be plain text")
	}
	store.mu.Lock()
	store.entries = nil
	store.mu.Unlock()
	if got := HandleStoreGet(`{"ns":"ip","key":"risk_1.2.3.4"}`); got != `{"ip":"1.2.3.4","score":88}` {
		t.Fatalf("store should reload from disk: %s", got)
	}
}

func TestKvStoreExpireAndLimit(t *testing.T) {
	now := time.Date(2026, 11, 2, 0, 0, 0, 0, time.UTC)
	useTrafficNow(t, now)
	newTestKvStore(t)
	HandleStoreSet(`{"ns":"ip","key":"old","data":{}}`)
	trafficNow = func() time.Time { return now.Add(30*24*time.Hour + time.Second) }
	if got := HandleStoreGet(`{"ns":"ip","key":"old"}`); got != "" {
		t.Fatalf("expired entry should be dropped: %s", got)
	}
	limit := kvSpaces["ip"].limit
	for i := range limit + 5 {
		HandleStoreSet(fmt.Sprintf(`{"ns":"ip","key":"ip_%d","data":{"i":%d},"time":%d}`, i, i, trafficNow().UnixMilli()+int64(i)))
	}
	if HandleStoreGet(`{"ns":"ip","key":"ip_0"}`) != "" || HandleStoreGet(`{"ns":"ip","key":"ip_4"}`) != "" {
		t.Fatal("oldest entries should be evicted")
	}
	if HandleStoreGet(`{"ns":"ip","key":"ip_5"}`) == "" || HandleStoreGet(fmt.Sprintf(`{"ns":"ip","key":"ip_%d"}`, limit+4)) == "" {
		t.Fatal("newest entries should stay")
	}
	if size := len(kvStoreOf("ip").entries); size != limit {
		t.Fatalf("unexpected size: %d", size)
	}
}

func TestKvStoreListOrderAndExplicitTime(t *testing.T) {
	now := time.Date(2026, 11, 2, 0, 0, 0, 0, time.UTC)
	useTrafficNow(t, now)
	newTestKvStore(t)
	day := int64(24 * time.Hour / time.Millisecond)
	base := now.UnixMilli()
	HandleStoreSet(fmt.Sprintf(`{"ns":"speedTest","key":"a","data":{"n":1},"time":%d}`, base-2*day))
	HandleStoreSet(fmt.Sprintf(`{"ns":"speedTest","key":"b","data":{"n":2},"time":%d}`, base))
	HandleStoreSet(fmt.Sprintf(`{"ns":"speedTest","key":"c","data":{"n":3},"time":%d}`, base-day))
	HandleStoreSet(fmt.Sprintf(`{"ns":"speedTest","key":"stale","data":{"n":0},"time":%d}`, base-15*day))
	if got := HandleStoreList("speedTest"); got != `[{"n":2},{"n":3},{"n":1}]` {
		t.Fatalf("unexpected list: %s", got)
	}
	if got := HandleStoreList("toolbox"); got != "[]" {
		t.Fatalf("empty list expected: %s", got)
	}
	HandleStoreSet(`{"ns":"toolbox","key":"history:dns","data":["a.com"]}`)
	trafficNow = func() time.Time { return now.Add(400 * 24 * time.Hour) }
	if got := HandleStoreGet(`{"ns":"toolbox","key":"history:dns"}`); got != `["a.com"]` {
		t.Fatalf("toolbox space should not expire: %s", got)
	}
}

func TestKvStoreClearAndRejectInvalid(t *testing.T) {
	newTestKvStore(t)
	if HandleStoreSet(`{"ns":"ip","key":"","data":{}}`) || HandleStoreSet(`not json`) || HandleStoreSet(`{"ns":"unknown","key":"a","data":{}}`) || HandleStoreSet(`{"ns":"ip","key":"a"}`) {
		t.Fatal("invalid params should be rejected")
	}
	if HandleStoreList("unknown") != "[]" || HandleStoreClear("unknown") {
		t.Fatal("unknown space should be rejected")
	}
	HandleStoreSet(`{"ns":"ip","key":"a","data":[1]}`)
	HandleStoreSet(`{"ns":"toolbox","key":"a","data":[2]}`)
	FlushKvStore()
	if !HandleStoreClear("ip") {
		t.Fatal("clear should succeed")
	}
	if _, err := os.Stat(kvStoreOf("ip").path); !os.IsNotExist(err) {
		t.Fatal("store file should be removed")
	}
	if HandleStoreGet(`{"ns":"ip","key":"a"}`) != "" {
		t.Fatal("space should be empty after clear")
	}
	if HandleStoreGet(`{"ns":"toolbox","key":"a"}`) != "[2]" {
		t.Fatal("other spaces should be untouched")
	}
}
