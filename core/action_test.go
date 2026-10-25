package main

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"
)

func splitActionResult(t *testing.T, frame []byte) (actionResultHeader, string) {
	t.Helper()
	head, payload, ok := strings.Cut(string(frame), "\n")
	if !ok {
		t.Fatalf("frame has no header: %q", frame)
	}
	var header actionResultHeader
	if err := json.Unmarshal([]byte(head), &header); err != nil {
		t.Fatal(err)
	}
	return header, payload
}

func TestActionResultJson(t *testing.T) {
	cases := []struct {
		name    string
		data    any
		code    int
		raw     bool
		payload string
	}{
		{"raw string", `{"connections":[{"id":"a\nb"}]}`, 0, true, `{"connections":[{"id":"a\nb"}]}`},
		{"empty string", "", 0, true, ""},
		{"bool", true, 0, false, "true"},
		{"map", map[string]string{"k": "v"}, 0, false, `{"k":"v"}`},
		{"nil", nil, 0, false, "null"},
		{"error", errors.New("boom"), -1, true, "boom"},
		{"invalid utf8", "a\xffb", 0, false, `"a\ufffdb"`},
		{"nul byte", "a\x00b", 0, false, `"a\u0000b"`},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			frame, err := ActionResult{Id: "getConnections#1", Method: getConnectionsMethod, Code: c.code, Data: c.data}.Json()
			if err != nil {
				t.Fatal(err)
			}
			header, payload := splitActionResult(t, frame)
			if header.Id != "getConnections#1" || header.Method != getConnectionsMethod || header.Code != c.code {
				t.Fatalf("header = %+v", header)
			}
			if header.Raw != c.raw {
				t.Fatalf("raw = %v, want %v", header.Raw, c.raw)
			}
			if payload != c.payload {
				t.Fatalf("payload = %q, want %q", payload, c.payload)
			}
		})
	}
}
