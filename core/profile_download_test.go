package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestDownloadProfileWritesBodyAndHeaders(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("User-Agent") != "bettbox-test" {
			w.WriteHeader(http.StatusForbidden)
			return
		}
		w.Header().Set("Subscription-Userinfo", "upload=1; download=2")
		_, _ = w.Write([]byte("proxies: []\n"))
	}))
	defer server.Close()
	output := filepath.Join(t.TempDir(), "profile")
	result, err := handleDownloadProfile(&DownloadProfileParams{
		URL:     server.URL,
		Output:  output,
		Headers: map[string]string{"User-Agent": "bettbox-test", "Connection": "close"},
	})
	if err != nil {
		t.Fatal(err)
	}
	var headers map[string][]string
	if err := json.Unmarshal([]byte(result), &headers); err != nil {
		t.Fatal(err)
	}
	if got := headers["subscription-userinfo"]; len(got) != 1 || got[0] != "upload=1; download=2" {
		t.Fatalf("unexpected headers %v", headers)
	}
	if data, _ := os.ReadFile(output); string(data) != "proxies: []\n" {
		t.Fatalf("unexpected body %q", data)
	}
}

func TestDownloadProfileAcceptsSelfSignedCertificate(t *testing.T) {
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("proxies: []\n"))
	}))
	defer server.Close()
	output := filepath.Join(t.TempDir(), "profile")
	if _, err := handleDownloadProfile(&DownloadProfileParams{URL: server.URL, Output: output}); err != nil {
		t.Fatal(err)
	}
	if data, _ := os.ReadFile(output); string(data) != "proxies: []\n" {
		t.Fatalf("unexpected body %q", data)
	}
}

func TestDownloadProfileRejectsErrorStatus(t *testing.T) {
	server := httptest.NewServer(http.NotFoundHandler())
	defer server.Close()
	if _, err := handleDownloadProfile(&DownloadProfileParams{URL: server.URL, Output: filepath.Join(t.TempDir(), "profile")}); err == nil {
		t.Fatal("expected status error")
	}
}
