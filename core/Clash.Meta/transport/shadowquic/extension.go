package shadowquic

import (
	"encoding/binary"
	"io"
	"math"
	"time"

	"github.com/metacubex/jls-quic-go"
)

const (
	extensionOpcodeConn uint64 = 0x01
	extensionOpcodeUser uint64 = 0x02

	extensionConnGetStats byte = 0x00

	extensionResultOK  byte = 0x00
	extensionResultErr byte = 0x01

	extensionErrNotAvailable     byte = 0x00
	extensionErrPermissionDenied byte = 0x01
	extensionErrNotFound         byte = 0x02
	extensionErrOther            byte = 0xff

	extensionConnStatsLen uint32 = 8 + 8 + 8 + 2
)

type ExtensionConnStats struct {
	LostPackets uint64
	SentPackets uint64
	RTT         float64
	CurrentMTU  uint16
}

func ReadExtensionOpcode(r io.Reader) (uint64, error) {
	var buf [8]byte
	if _, err := io.ReadFull(r, buf[:]); err != nil {
		return 0, err
	}
	return binary.BigEndian.Uint64(buf[:]), nil
}

func readExtensionSubcommand(r io.Reader) (byte, error) {
	var buf [1]byte
	if _, err := io.ReadFull(r, buf[:]); err != nil {
		return 0, err
	}
	return buf[0], nil
}

func WriteExtensionConnStatsResult(w io.Writer, stats ExtensionConnStats) error {
	var buf [1 + 4 + extensionConnStatsLen]byte
	buf[0] = extensionResultOK
	binary.BigEndian.PutUint32(buf[1:5], extensionConnStatsLen)
	binary.BigEndian.PutUint64(buf[5:13], stats.LostPackets)
	binary.BigEndian.PutUint64(buf[13:21], stats.SentPackets)
	binary.BigEndian.PutUint64(buf[21:29], math.Float64bits(stats.RTT))
	binary.BigEndian.PutUint16(buf[29:31], stats.CurrentMTU)
	_, err := w.Write(buf[:])
	return err
}

func WriteExtensionErrorResult(w io.Writer, code byte, message string) error {
	if _, err := w.Write([]byte{extensionResultErr, code}); err != nil {
		return err
	}
	if code != extensionErrOther {
		return nil
	}
	msg := []byte(message)
	var lenBuf [4]byte
	binary.BigEndian.PutUint32(lenBuf[:], uint32(len(msg)))
	if _, err := w.Write(lenBuf[:]); err != nil {
		return err
	}
	_, err := w.Write(msg)
	return err
}

func shadowQUICConnStats(conn *quic.Conn) ExtensionConnStats {
	stats := conn.ConnectionStats()
	rtt := stats.SmoothedRTT
	if rtt == 0 {
		rtt = stats.LatestRTT
	}
	return ExtensionConnStats{
		LostPackets: stats.PacketsLost,
		SentPackets: stats.PacketsSent,
		RTT:         float64(rtt) / float64(time.Millisecond),
		CurrentMTU:  stats.CurrentMTU,
	}
}
