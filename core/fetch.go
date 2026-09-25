package main

import (
	"bytes"
	"compress/gzip"
	"context"
	"errors"
	"io"
	"net"
	"os"
	"path/filepath"
	"strings"
	"time"

	mhttp "github.com/metacubex/http"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/listener/inner"
	"github.com/metacubex/quic-go/http3"
	mtls "github.com/metacubex/tls"
)

func handleFetchSubscription(params *FetchSubscriptionParams, fn func(*FetchSubscriptionResult)) {
	go func() {
		res := &FetchSubscriptionResult{
			Headers: make(map[string]string),
		}

		timeout := time.Duration(params.Timeout) * time.Second
		if timeout <= 0 {
			timeout = 30 * time.Second
		}

		ctx, cancel := context.WithTimeout(context.Background(), timeout)
		defer cancel()

		resp, err := fetchRace(ctx, params)
		if err != nil {
			res.Error = err.Error()
			fn(res)
			return
		}
		defer resp.Body.Close()

		res.StatusCode = resp.StatusCode
		for k, v := range resp.Header {
			if len(v) > 0 {
				res.Headers[strings.ToLower(k)] = v[0]
			}
		}

		res.ContentDisposition = resp.Header.Get("Content-Disposition")
		if res.ContentDisposition == "" {
			res.ContentDisposition = resp.Header.Get("content-disposition")
		}

		res.SubscriptionUserInfo = resp.Header.Get("Subscription-Userinfo")
		if res.SubscriptionUserInfo == "" {
			res.SubscriptionUserInfo = resp.Header.Get("subscription-userinfo")
		}

		if params.SavePath != "" {
			dir := filepath.Dir(params.SavePath)
			if err := os.MkdirAll(dir, 0755); err != nil {
				res.Error = err.Error()
				fn(res)
				return
			}

			tempPath := params.SavePath + ".downloading"
			file, err := os.Create(tempPath)
			if err != nil {
				res.Error = err.Error()
				fn(res)
				return
			}

			bodyReader := resp.Body
			contentEncoding := strings.ToLower(resp.Header.Get("Content-Encoding"))
			headerBytes := make([]byte, 2)
			n, _ := io.ReadFull(resp.Body, headerBytes)
			combinedReader := io.MultiReader(bytes.NewReader(headerBytes[:n]), bodyReader)

			var finalReader io.Reader = combinedReader
			isGzip := (n == 2 && headerBytes[0] == 0x1f && headerBytes[1] == 0x8b) || strings.Contains(contentEncoding, "gzip")
			if isGzip {
				gzReader, gzErr := gzip.NewReader(combinedReader)
				if gzErr == nil {
					defer gzReader.Close()
					finalReader = gzReader
				}
			}

			_, copyErr := io.Copy(file, finalReader)
			_ = file.Close()

			if copyErr != nil {
				_ = os.Remove(tempPath)
				res.Error = copyErr.Error()
				fn(res)
				return
			}

			if err := os.Rename(tempPath, params.SavePath); err != nil {
				_ = os.Remove(params.SavePath)
				if err := os.Rename(tempPath, params.SavePath); err != nil {
					_ = os.Remove(tempPath)
					res.Error = err.Error()
					fn(res)
					return
				}
			}

			res.SavedPath = params.SavePath
		}

		fn(res)
	}()
}

func doRequestH3(ctx context.Context, params *FetchSubscriptionParams) (*mhttp.Response, error) {
	tr := &http3.Transport{
		TLSClientConfig: &mtls.Config{
			InsecureSkipVerify: true,
		},
	}
	defer tr.Close()

	client := &mhttp.Client{
		Transport: tr,
	}

	req, err := mhttp.NewRequestWithContext(ctx, mhttp.MethodGet, params.Url, nil)
	if err != nil {
		return nil, err
	}

	for k, v := range params.Headers {
		req.Header.Set(k, v)
	}
	if req.Header.Get("User-Agent") == "" {
		req.Header.Set("User-Agent", "ClashMeta;Bettbox")
	}

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	return resp, nil
}

func doRequestH2H1(ctx context.Context, params *FetchSubscriptionParams) (*mhttp.Response, error) {
	tr := &mhttp.Transport{
		ForceAttemptHTTP2: true,
		TLSClientConfig: &mtls.Config{
			InsecureSkipVerify: true,
		},
		DialContext: func(ctx context.Context, network, address string) (net.Conn, error) {
			if conn, err := inner.HandleTcp(inner.GetTunnel(), address, ""); err == nil {
				return conn, nil
			}
			return dialer.DialContext(ctx, network, address)
		},
	}
	defer tr.CloseIdleConnections()

	client := &mhttp.Client{
		Transport: tr,
	}

	req, err := mhttp.NewRequestWithContext(ctx, mhttp.MethodGet, params.Url, nil)
	if err != nil {
		return nil, err
	}

	for k, v := range params.Headers {
		req.Header.Set(k, v)
	}
	if req.Header.Get("User-Agent") == "" {
		req.Header.Set("User-Agent", "ClashMeta;Bettbox")
	}

	return client.Do(req)
}

func fetchRace(ctx context.Context, params *FetchSubscriptionParams) (*mhttp.Response, error) {
	isHttps := strings.HasPrefix(strings.ToLower(params.Url), "https://")
	if !isHttps {
		return doRequestH2H1(ctx, params)
	}

	h3Ctx, cancelH3 := context.WithCancel(ctx)
	defer cancelH3()
	h2Ctx, cancelH2 := context.WithCancel(ctx)
	defer cancelH2()

	type raceResult struct {
		resp *mhttp.Response
		err  error
		isH3 bool
	}

	resultChan := make(chan raceResult, 2)

	go func() {
		resp, err := doRequestH3(h3Ctx, params)
		resultChan <- raceResult{resp: resp, err: err, isH3: true}
	}()

	go func() {
		resp, err := doRequestH2H1(h2Ctx, params)
		resultChan <- raceResult{resp: resp, err: err, isH3: false}
	}()

	var firstErr error
	completed := 0

	for completed < 2 {
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		case res := <-resultChan:
			completed++
			if res.err == nil && res.resp != nil && res.resp.StatusCode >= 200 && res.resp.StatusCode < 400 {
				if res.isH3 {
					cancelH2()
				} else {
					cancelH3()
				}
				go func() {
					for completed < 2 {
						select {
						case other := <-resultChan:
							completed++
							if other.resp != nil {
								_ = other.resp.Body.Close()
							}
						case <-time.After(5 * time.Second):
							return
						}
					}
				}()
				return res.resp, nil
			}

			if res.resp != nil {
				_ = res.resp.Body.Close()
			}
			if firstErr == nil && res.err != nil {
				firstErr = res.err
			}
		}
	}

	if firstErr != nil {
		return nil, firstErr
	}
	return nil, errors.New("request failed")
}

