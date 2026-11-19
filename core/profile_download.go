package main

import (
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

type DownloadProfileParams struct {
	URL     string            `json:"url"`
	Output  string            `json:"output"`
	Headers map[string]string `json:"headers"`
	Proxy   string            `json:"proxy"`
}

func handleDownloadProfile(params *DownloadProfileParams) (string, error) {
	req, err := http.NewRequest(http.MethodGet, params.URL, nil)
	if err != nil {
		return "", err
	}
	for key, value := range params.Headers {
		if strings.EqualFold(key, "connection") {
			continue
		}
		req.Header.Set(key, value)
	}
	req.Close = true
	transport := &http.Transport{
		ForceAttemptHTTP2:   true,
		TLSHandshakeTimeout: 30 * time.Second,
		TLSClientConfig:     &tls.Config{InsecureSkipVerify: true},
	}
	if params.Proxy != "" {
		transport.Proxy = http.ProxyURL(&url.URL{Scheme: "http", Host: params.Proxy})
	}
	defer transport.CloseIdleConnections()
	client := &http.Client{Transport: transport, Timeout: 2 * time.Minute}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("HTTP %d", resp.StatusCode)
	}
	if err := writeDownloadedProfile(params.Output, resp.Body); err != nil {
		return "", err
	}
	headers := make(map[string][]string, len(resp.Header))
	for key, values := range resp.Header {
		headers[strings.ToLower(key)] = values
	}
	data, err := json.Marshal(headers)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

func writeDownloadedProfile(output string, body io.Reader) error {
	file, err := os.Create(output)
	if err != nil {
		return err
	}
	written, err := io.Copy(file, io.LimitReader(body, maxDecompressedProfileBytes+1))
	if closeErr := file.Close(); err == nil {
		err = closeErr
	}
	if err == nil && written > maxDecompressedProfileBytes {
		err = errors.New("profile exceeds maximum size")
	}
	if err != nil {
		_ = os.Remove(output)
	}
	return err
}
