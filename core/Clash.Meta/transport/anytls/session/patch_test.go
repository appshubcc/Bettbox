package session

import (
	"context"
	"errors"
	"net"
	"runtime"
	"testing"
	"time"
)

func TestClientStartsIdleCleanupLazily(t *testing.T) {
	before := runtime.NumGoroutine()
	client := NewClient(context.Background(), func(context.Context) (net.Conn, error) {
		return nil, errors.New("unused")
	}, nil, "", 0, 0, 0, false)
	defer client.Close()
	if runtime.NumGoroutine() != before {
		t.Fatal("idle cleanup started before the first session")
	}
	if client.getIdleSession() != nil {
		t.Fatal("unexpected idle session")
	}
	if _, err := client.CreateStream(context.Background()); err == nil {
		t.Fatal("expected dial error")
	}
	if client.idleSession != nil {
		t.Fatal("idle session list created after a failed dial")
	}
	client.startIdleCleanup()
	client.startIdleCleanup()
	if client.idleSession == nil {
		t.Fatal("idle session list not created")
	}
	if client.idleSessionCheckInterval != 30*time.Second {
		t.Fatalf("interval = %s, want 30s", client.idleSessionCheckInterval)
	}
	if got := runtime.NumGoroutine(); got != before+1 {
		t.Fatalf("goroutines = %d, want %d", got, before+1)
	}
}
