package main

import (
	"context"
	"errors"
	"net"
	"testing"
)

func TestDelayFailureCode(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want string
	}{
		{name: "zero delay without error", want: "failed"},
		{name: "deadline", err: context.DeadlineExceeded, want: "timeout"},
		{name: "cancelled", err: context.Canceled, want: "cancelled"},
		{name: "dns", err: &net.DNSError{}, want: "dns"},
		{name: "network", err: &net.OpError{}, want: "network"},
		{name: "unknown", err: errors.New("unexpected"), want: "failed"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := delayFailureCode(test.err); got != test.want {
				t.Fatalf("delayFailureCode() = %q, want %q", got, test.want)
			}
		})
	}
}
