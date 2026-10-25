package main

import (
	"bytes"
	"compress/flate"
	"compress/gzip"
	"compress/zlib"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/metacubex/mihomo/component/age"
)

func TestPatchYamlTabs(t *testing.T) {
	plain := []byte("proxies:\n  - name: a\n    short-id: 0123abcd\n")
	if got := patchYamlTabs(plain); &got[0] != &plain[0] {
		t.Fatal("content without tabs was copied")
	}
	cases := map[string]string{
		"proxies:\n\t- name: \"a\tb\"\n \t  server: x\n": "proxies:\n  - name: \"a\tb\"\n     server: x\n",
		"a\r\tb \tc  \td":                                "a\r  b   c    d",
		"\t\n\t":                                         "  \n  ",
		"key: a\tb":                                      "key: a\tb",
	}
	for input, want := range cases {
		if got := string(patchYamlTabs([]byte(input))); got != want {
			t.Errorf("%q: got %q, want %q", input, got, want)
		}
	}
}

func TestPatchGeodataMode(t *testing.T) {
	cases := map[string]string{
		"geodata-mode: true\nmode: rule\n":       "geodata-mode: false\nmode: rule\n",
		"GEODATA-MODE : 'TRUE' # c\r\nx: y":      "GEODATA-MODE : false # c\r\nx: y",
		"a: b\n\n  geodata-mode:\n  \"true\"\n":  "a: b\n\n  geodata-mode:\n  false\n",
		"geodata-mode: false\n":                  "geodata-mode: false\n",
		"x geodata-mode: true\n":                 "x geodata-mode: true\n",
		"geodata-mode: true\rgeodata-mode: true": "geodata-mode: false\rgeodata-mode: false",
	}
	for input, want := range cases {
		if got := string(patchGeodataMode([]byte(input))); got != want {
			t.Errorf("%q: got %q, want %q", input, got, want)
		}
	}
}

func compress(t *testing.T, kind string, data []byte) []byte {
	t.Helper()
	var buffer bytes.Buffer
	var writer interface {
		Write([]byte) (int, error)
		Close() error
	}
	switch kind {
	case "gzip":
		writer = gzip.NewWriter(&buffer)
	case "zlib":
		writer = zlib.NewWriter(&buffer)
	default:
		writer, _ = flate.NewWriter(&buffer, flate.DefaultCompression)
	}
	if _, err := writer.Write(data); err != nil {
		t.Fatal(err)
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}
	return buffer.Bytes()
}

func TestDecompressProfile(t *testing.T) {
	content := []byte("proxies: []\n")
	gzipped := compress(t, "gzip", content)
	cases := []struct {
		name      string
		data      []byte
		encodings []string
		want      []byte
	}{
		{"gzip header", gzipped, []string{"GZIP"}, content},
		{"gzip magic only", gzipped, nil, content},
		{"double gzip", compress(t, "gzip", gzipped), []string{"gzip"}, content},
		{"zlib deflate", compress(t, "zlib", content), []string{"deflate"}, content},
		{"raw deflate", compress(t, "raw", content), []string{"x, Deflate"}, content},
		{"gzip header on plain text", content, []string{"gzip"}, content},
		{"broken deflate", []byte("not deflate"), []string{"deflate"}, []byte("not deflate")},
		{"broken gzip", append([]byte{0x1f, 0x8b}, "xx"...), nil, append([]byte{0x1f, 0x8b}, "xx"...)},
	}
	for _, c := range cases {
		if got := decompressProfile(c.data, c.encodings); !bytes.Equal(got, c.want) {
			t.Errorf("%s: got %q", c.name, got)
		}
	}
}

func importProfileForTest(t *testing.T, params ImportProfileParams, data []byte) string {
	t.Helper()
	source := filepath.Join(t.TempDir(), "source")
	if err := os.WriteFile(source, data, 0o600); err != nil {
		t.Fatal(err)
	}
	params.Source = source
	return handleImportProfile(&params)
}

func TestImportProfileKeepsUnchangedFile(t *testing.T) {
	output := filepath.Join(t.TempDir(), "profiles", "p.yaml")
	params := ImportProfileParams{Output: output}
	first := []byte("proxies: []\n")
	if message := importProfileForTest(t, params, first); message != "" {
		t.Fatal(message)
	}
	stamp := time.Date(2020, 1, 1, 0, 0, 0, 0, time.UTC)
	if err := os.Chtimes(output, stamp, stamp); err != nil {
		t.Fatal(err)
	}
	if message := importProfileForTest(t, params, first); message != "" {
		t.Fatal(message)
	}
	if info, _ := os.Stat(output); !info.ModTime().Equal(stamp) {
		t.Fatalf("unchanged content rewrote the file: %v", info.ModTime())
	}
	if message := importProfileForTest(t, params, []byte("proxies: []\n\trules: []\n")); message != "" {
		t.Fatal(message)
	}
	if data, _ := os.ReadFile(output); string(data) != "proxies: []\n  rules: []\n" {
		t.Fatalf("content = %q", data)
	}
	if matches, _ := filepath.Glob(output + ".*.tmp"); len(matches) != 0 {
		t.Fatalf("temp files left: %v", matches)
	}
}

func TestImportProfileSkipsValidationForUnchangedFile(t *testing.T) {
	output := filepath.Join(t.TempDir(), "profiles", "p.yaml")
	content := []byte("proxies: []\n")
	if message := importProfileForTest(t, ImportProfileParams{Output: output}, content); message != "" {
		t.Fatal(message)
	}
	stamp := time.Date(2020, 1, 1, 0, 0, 0, 0, time.UTC)
	if err := os.Chtimes(output, stamp, stamp); err != nil {
		t.Fatal(err)
	}
	params := ImportProfileParams{Output: output, Validate: true, Setup: &SetupParams{ProfilePath: "missing"}}
	if message := importProfileForTest(t, params, content); message != "" {
		t.Fatalf("unchanged content should not be validated again: %s", message)
	}
	if info, _ := os.Stat(output); !info.ModTime().Equal(stamp) {
		t.Fatalf("unchanged content rewrote the file: %v", info.ModTime())
	}
}

func TestImportProfileRejectsInvalidInput(t *testing.T) {
	output := filepath.Join(t.TempDir(), "p.yaml")
	if message := importProfileForTest(t, ImportProfileParams{Output: output}, []byte{'a', 0xff}); message != errInvalidProfileEncoding.Error() {
		t.Fatalf("message = %q", message)
	}
	if message := importProfileForTest(t, ImportProfileParams{Output: output, Validate: true}, []byte("proxies: [")); message == "" {
		t.Fatal("broken yaml passed validation")
	}
	if _, err := os.Stat(output); !os.IsNotExist(err) {
		t.Fatal("rejected profile was written")
	}
	if message := handleImportProfile(&ImportProfileParams{Source: filepath.Join(t.TempDir(), "missing"), Output: output}); message == "" {
		t.Fatal("missing source accepted")
	}
}

func TestImportProfileDecryptsAndDecompresses(t *testing.T) {
	secretKey, publicKey, err := age.GenX25519KeyPair()
	if err != nil {
		t.Fatal(err)
	}
	encrypted, err := age.EncryptBytes([]byte("mode: rule\n\tproxies: []\n"), publicKey)
	if err != nil {
		t.Fatal(err)
	}
	output := filepath.Join(t.TempDir(), "p.yaml")
	params := ImportProfileParams{Output: output, Decompress: true, Encodings: []string{"gzip"}, AgeSecretKey: secretKey}
	if message := importProfileForTest(t, params, compress(t, "gzip", encrypted)); message != "" {
		t.Fatal(message)
	}
	if data, _ := os.ReadFile(output); string(data) != "mode: rule\n  proxies: []\n" {
		t.Fatalf("content = %q", data)
	}
	params.AgeSecretKey = "AGE-SECRET-KEY-1INVALID"
	if message := importProfileForTest(t, params, compress(t, "gzip", []byte("mode: global\n"))); message != "" {
		t.Fatal(message)
	}
	if data, _ := os.ReadFile(output); string(data) != "mode: global\n" {
		t.Fatalf("undecryptable content = %q", data)
	}
}
