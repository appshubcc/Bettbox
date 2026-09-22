package sing_tun

import (
	"encoding/binary"
	"io"
	"net/netip"
)

func sendICMPUnreachable(writer io.Writer, srcAddr, dstAddr netip.AddrPort, payloadLen int) error {
	if writer == nil {
		return nil
	}
	var pkt []byte
	if srcAddr.Addr().Is4() && dstAddr.Addr().Is4() {
		pkt = buildICMPUnreachableIPv4(srcAddr, dstAddr, payloadLen)
	} else if srcAddr.Addr().Is6() && dstAddr.Addr().Is6() {
		pkt = buildICMPUnreachableIPv6(srcAddr, dstAddr, payloadLen)
	} else {
		return nil
	}
	_, err := writer.Write(pkt)
	return err
}

func buildICMPUnreachableIPv4(srcAddr, dstAddr netip.AddrPort, payloadLen int) []byte {
	pkt := make([]byte, 56)
	pkt[0] = 0x45
	binary.BigEndian.PutUint16(pkt[2:4], 56)
	binary.BigEndian.PutUint16(pkt[6:8], 0x4000)
	pkt[8] = 64
	pkt[9] = 1

	srcIP := dstAddr.Addr().As4()
	dstIP := srcAddr.Addr().As4()
	copy(pkt[12:16], srcIP[:])
	copy(pkt[16:20], dstIP[:])
	binary.BigEndian.PutUint16(pkt[10:12], checksum(0, pkt[:20]))

	icmpMsg := pkt[20:56]
	icmpMsg[0] = 3
	icmpMsg[1] = 3

	origIPHdr := icmpMsg[8:28]
	origIPHdr[0] = 0x45
	binary.BigEndian.PutUint16(origIPHdr[2:4], uint16(28+payloadLen))
	binary.BigEndian.PutUint16(origIPHdr[6:8], 0x4000)
	origIPHdr[8] = 64
	origIPHdr[9] = 17
	copy(origIPHdr[12:16], dstIP[:])
	copy(origIPHdr[16:20], srcIP[:])
	binary.BigEndian.PutUint16(origIPHdr[10:12], checksum(0, origIPHdr))

	binary.BigEndian.PutUint16(pkt[48:50], srcAddr.Port())
	binary.BigEndian.PutUint16(pkt[50:52], dstAddr.Port())
	binary.BigEndian.PutUint16(pkt[52:54], uint16(8+payloadLen))

	binary.BigEndian.PutUint16(icmpMsg[2:4], checksum(0, icmpMsg))
	return pkt
}

func buildICMPUnreachableIPv6(srcAddr, dstAddr netip.AddrPort, payloadLen int) []byte {
	pkt := make([]byte, 96)
	pkt[0] = 0x60
	binary.BigEndian.PutUint16(pkt[4:6], 56)
	pkt[6] = 58
	pkt[7] = 64

	srcIP := dstAddr.Addr().As16()
	dstIP := srcAddr.Addr().As16()
	copy(pkt[8:24], srcIP[:])
	copy(pkt[24:40], dstIP[:])

	icmpMsg := pkt[40:96]
	icmpMsg[0] = 1
	icmpMsg[1] = 4

	origIPHdr := icmpMsg[8:48]
	origIPHdr[0] = 0x60
	binary.BigEndian.PutUint16(origIPHdr[4:6], uint16(8+payloadLen))
	origIPHdr[6] = 17
	origIPHdr[7] = 64
	copy(origIPHdr[8:24], dstIP[:])
	copy(origIPHdr[24:40], srcIP[:])

	binary.BigEndian.PutUint16(pkt[88:90], srcAddr.Port())
	binary.BigEndian.PutUint16(pkt[90:92], dstAddr.Port())
	binary.BigEndian.PutUint16(pkt[92:94], uint16(8+payloadLen))

	binary.BigEndian.PutUint16(icmpMsg[2:4], checksum(uint32(len(icmpMsg)+58), pkt[8:]))
	return pkt
}

func checksum(sum uint32, b []byte) uint16 {
	for i := 0; i < len(b)-1; i += 2 {
		sum += uint32(binary.BigEndian.Uint16(b[i : i+2]))
	}
	if len(b)%2 == 1 {
		sum += uint32(b[len(b)-1]) << 8
	}
	for sum > 0xffff {
		sum = (sum & 0xffff) + (sum >> 16)
	}
	return ^uint16(sum)
}

