package shadowquic

import (
	"bytes"
	"encoding/binary"
	"io"
	"math"
	"net"
	"testing"
)

func TestWriteExtensionConnStatsResult(t *testing.T) {
	var buf bytes.Buffer
	err := WriteExtensionConnStatsResult(&buf, ExtensionConnStats{
		LostPackets: 3,
		SentPackets: 5,
		RTT:         12.5,
		CurrentMTU:  1400,
	})
	if err != nil {
		t.Fatal(err)
	}

	data := buf.Bytes()
	if len(data) != 31 {
		t.Fatalf("encoded length = %d, want 31", len(data))
	}
	if data[0] != extensionResultOK {
		t.Fatalf("result tag = %#x, want OK", data[0])
	}
	if got := binary.BigEndian.Uint32(data[1:5]); got != extensionConnStatsLen {
		t.Fatalf("stats length = %d, want %d", got, extensionConnStatsLen)
	}
	if got := binary.BigEndian.Uint64(data[5:13]); got != 3 {
		t.Fatalf("lost packets = %d, want 3", got)
	}
	if got := binary.BigEndian.Uint64(data[13:21]); got != 5 {
		t.Fatalf("sent packets = %d, want 5", got)
	}
	if got := math.Float64frombits(binary.BigEndian.Uint64(data[21:29])); got != 12.5 {
		t.Fatalf("rtt = %f, want 12.5", got)
	}
	if got := binary.BigEndian.Uint16(data[29:31]); got != 1400 {
		t.Fatalf("mtu = %d, want 1400", got)
	}
}

func TestWriteExtensionErrorResult(t *testing.T) {
	var buf bytes.Buffer
	err := WriteExtensionErrorResult(&buf, extensionErrPermissionDenied, "")
	if err != nil {
		t.Fatal(err)
	}
	if got, want := buf.Bytes(), []byte{extensionResultErr, extensionErrPermissionDenied}; !bytes.Equal(got, want) {
		t.Fatalf("encoded error = %v, want %v", got, want)
	}
}

func TestUserExtensionIsUnavailable(t *testing.T) {
	client, server := net.Pipe()
	done := make(chan struct{})
	go func() {
		(&Server{}).handleExtension(nil, server)
		close(done)
	}()

	var request [9]byte
	binary.BigEndian.PutUint64(request[:8], extensionOpcodeUser)
	if _, err := client.Write(request[:]); err != nil {
		t.Fatal(err)
	}
	var response [2]byte
	if _, err := io.ReadFull(client, response[:]); err != nil {
		t.Fatal(err)
	}
	if want := [2]byte{extensionResultErr, extensionErrNotAvailable}; response != want {
		t.Fatalf("response = %v, want %v", response, want)
	}
	_ = client.Close()
	<-done
}
