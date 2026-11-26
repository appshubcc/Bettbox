//go:build !no_easytier && !no_tailscale && !no_zerotier

package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestParseNodesBundledMeshTemplates(t *testing.T) {
	readTemplate := func(t *testing.T, section, lang string) string {
		t.Helper()
		data, err := os.ReadFile(filepath.Join("..", "assets", "mesh", section+"."+lang+".yaml"))
		if err != nil {
			t.Fatal(err)
		}
		return string(data)
	}
	for _, kind := range []string{"easytier", "zerotier", "tailscale"} {
		for _, lang := range []string{"en", "zh"} {
			t.Run(kind+"/"+lang, func(t *testing.T) {
				text := readTemplate(t, kind, lang) + "\n" + readTemplate(t, "common", lang)
				nodes, invalid, err := parseNodes(text)
				if err != nil || invalid != 0 || len(nodes) != 1 || nodes[0]["type"] != kind {
					t.Fatalf("default template import: nodes=%v invalid=%d err=%v", nodes, invalid, err)
				}
			})
		}
	}
}
