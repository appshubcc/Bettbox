package main

import (
	"strings"
	"testing"

	"github.com/metacubex/mihomo/config"
)

func TestMarshalInlineProviderContent(t *testing.T) {
	rawConfig := config.DefaultRawConfig()
	rawConfig.ProxyProvider = map[string]map[string]any{
		"Source-Proxies": {
			"type": "inline",
			"payload": []map[string]any{
				{
					"name":     "测试节点",
					"type":     "ss",
					"server":   "203.0.113.10",
					"port":     443,
					"cipher":   "aes-128-gcm",
					"password": "test",
				},
			},
		},
	}

	content, err := marshalInlineProviderContent(rawConfig, "Source-Proxies")
	if err != nil {
		t.Fatalf("序列化 inline provider 失败：%v", err)
	}

	text := string(content)
	for _, expected := range []string{"proxies:", "测试节点", "203.0.113.10", "aes-128-gcm"} {
		if !strings.Contains(text, expected) {
			t.Fatalf("提供者内容缺少 %q：\n%s", expected, text)
		}
	}
}

func TestMarshalInlineProviderContentRejectsMissingPayload(t *testing.T) {
	rawConfig := config.DefaultRawConfig()
	rawConfig.ProxyProvider = map[string]map[string]any{
		"Source-Proxies": {"type": "inline"},
	}

	if _, err := marshalInlineProviderContent(rawConfig, "Source-Proxies"); err == nil {
		t.Fatal("缺少 payload 时应返回错误")
	}
}
