package shadowtls

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
)

const (
	tlsRandomSize    = 32
	tlsHeaderSize    = 5
	tlsSessionIDSize = 32

	clientHello = 1
	serverHello = 2

	changeCipherSpec = 20
	alert            = 21
	handshake        = 22
	applicationData  = 23

	serverRandomIndex    = tlsHeaderSize + 1 + 3 + 2
	sessionIDLengthIndex = tlsHeaderSize + 1 + 3 + 2 + tlsRandomSize
	tlsHMACHeaderSize    = tlsHeaderSize + hmacSize
	hmacSize             = 4
	maxTLSPlaintext      = 16384
)

func readFrame(reader io.Reader) ([]byte, error) {
	var header [tlsHeaderSize]byte
	if _, err := io.ReadFull(reader, header[:]); err != nil {
		return nil, err
	}
	length := int(binary.BigEndian.Uint16(header[3:]))
	frame := make([]byte, tlsHeaderSize+length)
	copy(frame, header[:])
	if _, err := io.ReadFull(reader, frame[tlsHeaderSize:]); err != nil {
		return nil, err
	}
	return frame, nil
}

func copyUntilHandshakeFinished(dst io.Writer, src io.Reader) error {
	seenChangeCipherSpec := false
	for {
		frame, err := readFrame(src)
		if err != nil {
			return err
		}
		if _, err = dst.Write(frame); err != nil {
			return err
		}
		if frame[0] != handshake {
			if frame[0] != changeCipherSpec {
				return fmt.Errorf("shadow-tls: unexpected TLS record type: %d", frame[0])
			}
			if !seenChangeCipherSpec {
				seenChangeCipherSpec = true
				continue
			}
		}
		if seenChangeCipherSpec {
			return nil
		}
	}
}

func extractServerName(frame []byte) (string, error) {
	if len(frame) < tlsHeaderSize+4 || frame[0] != handshake || frame[tlsHeaderSize] != clientHello {
		return "", errors.New("shadow-tls: invalid ClientHello")
	}
	helloLength := int(frame[tlsHeaderSize+1])<<16 | int(frame[tlsHeaderSize+2])<<8 | int(frame[tlsHeaderSize+3])
	hello := frame[tlsHeaderSize+4:]
	if helloLength > len(hello) {
		return "", io.ErrUnexpectedEOF
	}
	hello = hello[:helloLength]
	if len(hello) < 2+tlsRandomSize+1 {
		return "", io.ErrUnexpectedEOF
	}
	offset := 2 + tlsRandomSize
	sessionIDLength := int(hello[offset])
	offset++
	if offset+sessionIDLength+2 > len(hello) {
		return "", io.ErrUnexpectedEOF
	}
	offset += sessionIDLength
	cipherSuitesLength := int(binary.BigEndian.Uint16(hello[offset:]))
	offset += 2
	if offset+cipherSuitesLength+1 > len(hello) {
		return "", io.ErrUnexpectedEOF
	}
	offset += cipherSuitesLength
	compressionMethodsLength := int(hello[offset])
	offset++
	if offset+compressionMethodsLength == len(hello) {
		return "", errors.New("shadow-tls: ClientHello has no SNI")
	}
	if offset+compressionMethodsLength+2 > len(hello) {
		return "", io.ErrUnexpectedEOF
	}
	offset += compressionMethodsLength
	extensionsLength := int(binary.BigEndian.Uint16(hello[offset:]))
	offset += 2
	if offset+extensionsLength > len(hello) {
		return "", io.ErrUnexpectedEOF
	}
	extensions := hello[offset : offset+extensionsLength]
	for len(extensions) >= 4 {
		extensionType := binary.BigEndian.Uint16(extensions)
		extensionLength := int(binary.BigEndian.Uint16(extensions[2:]))
		extensions = extensions[4:]
		if extensionLength > len(extensions) {
			return "", io.ErrUnexpectedEOF
		}
		if extensionType == 0 {
			return parseServerNameExtension(extensions[:extensionLength])
		}
		extensions = extensions[extensionLength:]
	}
	return "", errors.New("shadow-tls: ClientHello has no SNI")
}

func parseServerNameExtension(extension []byte) (string, error) {
	if len(extension) < 2 {
		return "", io.ErrUnexpectedEOF
	}
	listLength := int(binary.BigEndian.Uint16(extension))
	if listLength > len(extension)-2 {
		return "", io.ErrUnexpectedEOF
	}
	list := extension[2 : 2+listLength]
	for len(list) >= 3 {
		nameType := list[0]
		nameLength := int(binary.BigEndian.Uint16(list[1:]))
		list = list[3:]
		if nameLength > len(list) {
			return "", io.ErrUnexpectedEOF
		}
		if nameType == 0 && nameLength > 0 {
			return string(list[:nameLength]), nil
		}
		list = list[nameLength:]
	}
	return "", errors.New("shadow-tls: ClientHello has no host name")
}

func extractServerRandom(frame []byte) []byte {
	if len(frame) < serverRandomIndex+tlsRandomSize || frame[0] != handshake || frame[tlsHeaderSize] != serverHello {
		return nil
	}
	return append([]byte(nil), frame[serverRandomIndex:serverRandomIndex+tlsRandomSize]...)
}

func isServerHelloSupportTLS13(frame []byte) bool {
	if len(frame) <= sessionIDLengthIndex || frame[0] != handshake || frame[tlsHeaderSize] != serverHello {
		return false
	}
	offset := sessionIDLengthIndex
	sessionIDLength := int(frame[offset])
	offset++
	if offset+sessionIDLength+3+2 > len(frame) {
		return false
	}
	offset += sessionIDLength + 3
	extensionsLength := int(binary.BigEndian.Uint16(frame[offset:]))
	offset += 2
	if offset+extensionsLength > len(frame) {
		return false
	}
	extensions := frame[offset : offset+extensionsLength]
	for len(extensions) >= 4 {
		extensionType := binary.BigEndian.Uint16(extensions)
		extensionLength := int(binary.BigEndian.Uint16(extensions[2:]))
		extensions = extensions[4:]
		if extensionLength > len(extensions) {
			return false
		}
		if extensionType == 43 {
			return extensionLength == 2 && binary.BigEndian.Uint16(extensions[:2]) == 0x0304
		}
		extensions = extensions[extensionLength:]
	}
	return false
}

func writeBuffers(writer io.Writer, buffers ...[]byte) error {
	netBuffers := net.Buffers(buffers)
	_, err := netBuffers.WriteTo(writer)
	return err
}
