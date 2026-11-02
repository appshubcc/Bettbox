package toolbox

import (
	"bytes"
	crand "crypto/rand"
	"encoding/gob"
	"math/rand/v2"
	"os"
	"path/filepath"
)

const (
	storeVersion   byte = 1
	storeNonceSize      = 8
)

var (
	storeMagic = []byte("BBXS")
	storeSeed  = [32]byte{
		0x42, 0x65, 0x74, 0x74, 0x62, 0x6f, 0x78, 0x2d, 0x73, 0x74, 0x6f, 0x72, 0x65, 0x2d, 0x76, 0x31,
		0x9e, 0x37, 0x79, 0xb9, 0x7f, 0x4a, 0x7c, 0x15, 0xf3, 0x9c, 0xc0, 0x60, 0x5c, 0xed, 0xc8, 0x34,
	}
)

func storeMask(nonce, data []byte) {
	seed := storeSeed
	for i, b := range nonce {
		seed[i] ^= b
	}
	stream := rand.NewChaCha8(seed)
	var block [4096]byte
	for offset := 0; offset < len(data); offset += len(block) {
		chunk := data[offset:min(offset+len(block), len(data))]
		_, _ = stream.Read(block[:len(chunk)])
		for i := range chunk {
			chunk[i] ^= block[i]
		}
	}
}

func encodeStore(value any) ([]byte, error) {
	var buf bytes.Buffer
	buf.Write(storeMagic)
	buf.WriteByte(storeVersion)
	nonce := make([]byte, storeNonceSize)
	_, _ = crand.Read(nonce)
	buf.Write(nonce)
	if err := gob.NewEncoder(&buf).Encode(value); err != nil {
		return nil, err
	}
	data := buf.Bytes()
	header := len(storeMagic) + 1
	storeMask(data[header:header+storeNonceSize], data[header+storeNonceSize:])
	return data, nil
}

func writeStoreBytes(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		return err
	}
	temp := path + ".tmp"
	if err := os.WriteFile(temp, data, 0o600); err != nil {
		return err
	}
	return os.Rename(temp, path)
}

func writeStoreFile(path string, value any) error {
	data, err := encodeStore(value)
	if err != nil {
		return err
	}
	return writeStoreBytes(path, data)
}

func readStoreFile(path string, value any) bool {
	content, err := os.ReadFile(path)
	header := len(storeMagic) + 1
	if err != nil || len(content) < header+storeNonceSize || !bytes.HasPrefix(content, storeMagic) || content[header-1] != storeVersion {
		return false
	}
	body := content[header+storeNonceSize:]
	storeMask(content[header:header+storeNonceSize], body)
	return gob.NewDecoder(bytes.NewReader(body)).Decode(value) == nil
}
