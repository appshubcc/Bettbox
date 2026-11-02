package main

import (
	"encoding/json"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const (
	connectionRateWindow = 500 * time.Millisecond
	connectionRateTTL    = 10 * time.Second
)

type connectionRate struct {
	upload        int64
	download      int64
	at            time.Time
	uploadSpeed   int64
	downloadSpeed int64
}

type connectionItem struct {
	*statistic.TrackerInfo
	UploadSpeed   int64 `json:"uploadSpeed"`
	DownloadSpeed int64 `json:"downloadSpeed"`
}

type connectionsSummary struct {
	Total    int   `json:"total"`
	TCP      int   `json:"tcp"`
	UDP      int   `json:"udp"`
	FcmStart int64 `json:"fcm-start"`
}

var (
	connectionRatesLock  sync.Mutex
	connectionRates      = map[[16]byte]*connectionRate{}
	connectionRatesTimer *time.Timer
)

func bytesPerSecond(delta int64, elapsed time.Duration) int64 {
	if delta <= 0 || elapsed <= 0 {
		return 0
	}
	return int64(float64(delta) / elapsed.Seconds())
}

func resetConnectionRates() {
	connectionRatesLock.Lock()
	connectionRates = map[[16]byte]*connectionRate{}
	connectionRatesLock.Unlock()
}

func collectConnections(now time.Time) []connectionItem {
	connectionRatesLock.Lock()
	defer connectionRatesLock.Unlock()
	items := make([]connectionItem, 0, len(connectionRates))
	next := make(map[[16]byte]*connectionRate, len(connectionRates))
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		info := c.Info()
		key := [16]byte(info.UUID)
		upload := info.UploadTotal.Load()
		download := info.DownloadTotal.Load()
		rate := connectionRates[key]
		if rate == nil {
			rate = &connectionRate{upload: upload, download: download, at: now}
		} else if elapsed := now.Sub(rate.at); elapsed >= connectionRateWindow {
			rate.uploadSpeed = bytesPerSecond(upload-rate.upload, elapsed)
			rate.downloadSpeed = bytesPerSecond(download-rate.download, elapsed)
			rate.upload, rate.download, rate.at = upload, download, now
		}
		next[key] = rate
		items = append(items, connectionItem{
			TrackerInfo:   info,
			UploadSpeed:   rate.uploadSpeed,
			DownloadSpeed: rate.downloadSpeed,
		})
		return true
	})
	connectionRates = next
	if connectionRatesTimer == nil {
		connectionRatesTimer = time.AfterFunc(connectionRateTTL, resetConnectionRates)
	} else {
		connectionRatesTimer.Reset(connectionRateTTL)
	}
	return items
}

func handleGetConnections() string {
	data, err := json.Marshal(collectConnections(time.Now()))
	if err != nil {
		return "[]"
	}
	return string(data)
}

func isFcmConnection(metadata *constant.Metadata) bool {
	host := strings.ToLower(metadata.Host)
	switch {
	case metadata.DstPort >= 5228 && metadata.DstPort <= 5230:
		return strings.Contains(host, "google.com")
	case metadata.DstPort == 443:
		return host == "mtalk.google.com" || strings.HasSuffix(host, "-mtalk.google.com")
	}
	return false
}

func summarizeConnections() connectionsSummary {
	var summary connectionsSummary
	var fcmStart time.Time
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		info := c.Info()
		summary.Total++
		metadata := info.Metadata
		if metadata != nil && metadata.NetWork == constant.UDP {
			summary.UDP++
		} else {
			summary.TCP++
		}
		if metadata != nil && isFcmConnection(metadata) &&
			(fcmStart.IsZero() || info.Start.Before(fcmStart)) {
			fcmStart = info.Start
		}
		return true
	})
	if !fcmStart.IsZero() {
		summary.FcmStart = fcmStart.UnixMilli()
	}
	return summary
}

func handleGetConnectionsSummary() string {
	data, err := json.Marshal(summarizeConnections())
	if err != nil {
		return ""
	}
	return string(data)
}
