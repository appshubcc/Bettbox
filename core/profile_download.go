package main

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/listener/inner"
	"github.com/metacubex/mihomo/ntp"
	"github.com/metacubex/mihomo/tunnel"
)

type DownloadProfileParams struct {
	URL            string            `json:"url"`
	Output         string            `json:"output"`
	Headers        map[string]string `json:"headers"`
	Direct         bool              `json:"direct"`
	SkipCertVerify bool              `json:"skip-cert-verify"`
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
	running := tunnel.Status() == tunnel.Running
	transport := &http.Transport{
		ForceAttemptHTTP2:   true,
		TLSHandshakeTimeout: 30 * time.Second,
		TLSClientConfig: &tls.Config{
			RootCAs:            ca.GetCertPool(),
			Time:               ntp.Now,
			InsecureSkipVerify: params.SkipCertVerify,
		},
		DialContext: func(ctx context.Context, network, address string) (net.Conn, error) {
			if !running {
				return (&net.Dialer{}).DialContext(ctx, network, address)
			}
			if params.Direct {
				return dialer.DialContext(ctx, network, address, dialer.WithResolver(resolver.DirectHostResolver))
			}
			return inner.HandleTcp(inner.GetTunnel(), address, "")
		},
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
	file, err := openOutputFile(output)
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
