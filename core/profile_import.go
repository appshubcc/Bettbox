package main

import (
	"bytes"
	"compress/flate"
	"compress/gzip"
	"compress/zlib"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/metacubex/mihomo/component/age"
	"github.com/metacubex/mihomo/config"
)

type ImportProfileParams struct {
	Source       string       `json:"source"`
	Output       string       `json:"output"`
	Decompress   bool         `json:"decompress"`
	Encodings    []string     `json:"encodings"`
	AgeSecretKey string       `json:"age-secret-key"`
	Validate     bool         `json:"validate"`
	Setup        *SetupParams `json:"setup"`
}

const maxDecompressedProfileBytes = 64 << 20

var errInvalidProfileEncoding = errors.New("profile is not valid UTF-8")

func readAllAndClose(reader io.ReadCloser) ([]byte, error) {
	defer reader.Close()
	data, err := io.ReadAll(io.LimitReader(reader, maxDecompressedProfileBytes+1))
	if err != nil {
		return nil, err
	}
	if len(data) > maxDecompressedProfileBytes {
		return nil, errors.New("decompressed profile exceeds maximum size")
	}
	return data, nil
}

func gunzipProfile(data []byte) ([]byte, error) {
	reader, err := gzip.NewReader(bytes.NewReader(data))
	if err != nil {
		return nil, err
	}
	reader.Multistream(false)
	return readAllAndClose(reader)
}

func inflateProfile(data []byte) ([]byte, error) {
	if reader, err := zlib.NewReader(bytes.NewReader(data)); err == nil {
		if decoded, err := readAllAndClose(reader); err == nil {
			return decoded, nil
		}
	}
	return readAllAndClose(flate.NewReader(bytes.NewReader(data)))
}

func decompressProfile(data []byte, encodings []string) []byte {
	lowered := make([]string, len(encodings))
	for i, encoding := range encodings {
		lowered[i] = strings.ToLower(encoding)
	}
	joined := strings.Join(lowered, ", ")
	wantGzip := strings.Contains(joined, "gzip")
	wantDeflate := strings.Contains(joined, "deflate")
	current := data
	for range 4 {
		isGzipMagic := len(current) >= 2 && current[0] == 0x1f && current[1] == 0x8b
		if wantGzip || isGzipMagic {
			if !isGzipMagic {
				break
			}
			decoded, err := gunzipProfile(current)
			if err != nil {
				break
			}
			current = decoded
			wantGzip = false
			continue
		}
		if wantDeflate {
			decoded, err := inflateProfile(current)
			if err != nil {
				break
			}
			current = decoded
			wantDeflate = false
			continue
		}
		break
	}
	return current
}

func replaceInvalidUTF8(data []byte) []byte {
	if utf8.Valid(data) {
		return data
	}
	result := make([]byte, 0, len(data)+8)
	for len(data) > 0 {
		r, size := utf8.DecodeRune(data)
		if r == utf8.RuneError && size == 1 {
			result = append(result, "�"...)
		} else {
			result = append(result, data[:size]...)
		}
		data = data[size:]
	}
	return result
}

func decryptProfile(data []byte, ageSecretKey string) []byte {
	ageMutex.Lock()
	defer ageMutex.Unlock()
	decrypted, err := age.DecryptBytes(data, ageSecretKey)
	if err != nil {
		return nil
	}
	return replaceInvalidUTF8(decrypted)
}

func lineTerminatorSize(data []byte, i int) int {
	switch data[i] {
	case '\n', '\r':
		return 1
	case 0xE2:
		if i+2 < len(data) && data[i+1] == 0x80 && (data[i+2] == 0xA8 || data[i+2] == 0xA9) {
			return 3
		}
	}
	return 0
}

func patchYamlTabs(data []byte) []byte {
	if bytes.IndexByte(data, '\t') < 0 {
		return data
	}
	var result []byte
	copied := 0
	lineStart := true
	for i := 0; i < len(data); {
		if lineStart {
			lineStart = false
			end := i
			hasTab := false
			for end < len(data) && (data[end] == ' ' || data[end] == '\t') {
				hasTab = hasTab || data[end] == '\t'
				end++
			}
			if hasTab {
				if result == nil {
					result = make([]byte, 0, len(data)+64)
				}
				result = append(result, data[copied:i]...)
				for _, c := range data[i:end] {
					if c == '\t' {
						result = append(result, ' ', ' ')
					} else {
						result = append(result, c)
					}
				}
				copied = end
			}
			i = end
			continue
		}
		if size := lineTerminatorSize(data, i); size > 0 {
			i += size
			lineStart = true
			continue
		}
		i++
	}
	if result == nil {
		return data
	}
	return append(result, data[copied:]...)
}

func jsWhitespaceSize(data []byte, i int) int {
	switch data[i] {
	case '\t', '\n', '\v', '\f', '\r', ' ':
		return 1
	}
	if data[i] < utf8.RuneSelf {
		return 0
	}
	r, size := utf8.DecodeRune(data[i:])
	switch {
	case r == 0x00A0, r == 0x1680, r >= 0x2000 && r <= 0x200A, r == 0x2028, r == 0x2029,
		r == 0x202F, r == 0x205F, r == 0x3000, r == 0xFEFF:
		return size
	}
	return 0
}

func skipJsWhitespace(data []byte, i int) int {
	for i < len(data) {
		size := jsWhitespaceSize(data, i)
		if size == 0 {
			break
		}
		i += size
	}
	return i
}

func hasFoldPrefix(data []byte, i int, prefix string) bool {
	return len(data)-i >= len(prefix) && strings.EqualFold(string(data[i:i+len(prefix)]), prefix)
}

func matchGeodataMode(data []byte, start int) (int, int, bool) {
	i := skipJsWhitespace(data, start)
	if !hasFoldPrefix(data, i, "geodata-mode") {
		return 0, 0, false
	}
	i = skipJsWhitespace(data, i+len("geodata-mode"))
	if i >= len(data) || data[i] != ':' {
		return 0, 0, false
	}
	i = skipJsWhitespace(data, i+1)
	for _, value := range []string{"true", "'true'", `"true"`} {
		if hasFoldPrefix(data, i, value) {
			return i, i + len(value), true
		}
	}
	return 0, 0, false
}

func patchGeodataMode(data []byte) []byte {
	var result []byte
	copied := 0
	lineStart := true
	for i := 0; i <= len(data); {
		if lineStart {
			lineStart = false
			if valueStart, valueEnd, ok := matchGeodataMode(data, i); ok {
				if result == nil {
					result = make([]byte, 0, len(data))
				}
				result = append(result, data[copied:valueStart]...)
				result = append(result, "false"...)
				copied = valueEnd
				i = valueEnd
				for i < len(data) && lineTerminatorSize(data, i) == 0 {
					i++
				}
				continue
			}
		}
		if i == len(data) {
			break
		}
		if size := lineTerminatorSize(data, i); size > 0 {
			i += size
			lineStart = true
			continue
		}
		i++
	}
	if result == nil {
		return data
	}
	return append(result, data[copied:]...)
}

func tempProfilePath(output string) string {
	return fmt.Sprintf("%s.%d.tmp", output, time.Now().UnixMicro())
}

func writeProfileFile(path string, data []byte, sync bool) error {
	file, err := openOutputFile(path)
	if err != nil {
		return err
	}
	_, err = file.Write(data)
	if err == nil && sync {
		err = file.Sync()
	}
	if closeErr := file.Close(); err == nil {
		err = closeErr
	}
	return err
}

func writeTempProfile(output string, data []byte) (string, error) {
	if err := os.MkdirAll(filepath.Dir(output), 0o777); err != nil {
		return "", err
	}
	temp := tempProfilePath(output)
	if err := writeProfileFile(temp, data, true); err != nil {
		_ = os.Remove(temp)
		return "", err
	}
	return temp, nil
}

func copyProfileFile(source, target string) error {
	data, err := os.ReadFile(source)
	if err != nil {
		return err
	}
	return writeProfileFile(target, data, false)
}

func commitTempProfile(temp, output string) error {
	if err := os.Rename(temp, output); err == nil {
		return nil
	}
	return copyProfileFile(temp, output)
}

func validateProfileContent(data []byte, ageSecretKey string) string {
	ageMutex.Lock()
	defer ageMutex.Unlock()
	if ageSecretKey != "" {
		age.SetGlobalSecretKeys(ageSecretKey)
		defer age.SetGlobalSecretKeys()
	}
	if _, err := config.Parse(patchYamlShortID(data)); err != nil {
		return err.Error()
	}
	return ""
}

func importValidatedProfile(data []byte, output string, params *SetupParams) string {
	temp, err := writeTempProfile(output, data)
	if err != nil {
		return err.Error()
	}
	defer os.Remove(temp)
	setup := *params
	setup.ProfilePath = temp
	if message := handleValidateConfig(&ValidateConfigParams{Setup: &setup}); message != "" {
		return message
	}
	if err := commitTempProfile(temp, output); err != nil {
		return err.Error()
	}
	return ""
}

func writeProfile(output string, data []byte) string {
	if existing, err := os.ReadFile(output); err == nil && bytes.Equal(existing, data) {
		return ""
	}
	temp, err := writeTempProfile(output, data)
	if err != nil {
		return err.Error()
	}
	defer os.Remove(temp)
	if err := commitTempProfile(temp, output); err != nil {
		return err.Error()
	}
	return ""
}

func handleImportProfile(params *ImportProfileParams) string {
	data, err := readFile(params.Source)
	if err != nil {
		return err.Error()
	}
	if params.Decompress {
		data = decompressProfile(data, params.Encodings)
	}
	if !utf8.Valid(data) {
		return errInvalidProfileEncoding.Error()
	}
	if params.AgeSecretKey != "" {
		if decrypted := decryptProfile(data, params.AgeSecretKey); len(decrypted) > 0 {
			data = decrypted
		}
	}
	data = patchYamlTabs(data)
	if existing, err := os.ReadFile(params.Output); err == nil && bytes.Equal(existing, data) {
		return ""
	}
	if params.Setup != nil {
		return importValidatedProfile(data, params.Output, params.Setup)
	}
	if params.Validate {
		if message := validateProfileContent(data, params.AgeSecretKey); message != "" {
			patched := patchGeodataMode(data)
			if bytes.Equal(patched, data) || validateProfileContent(patched, params.AgeSecretKey) != "" {
				return message
			}
			data = patched
		}
	}
	return writeProfile(params.Output, data)
}
