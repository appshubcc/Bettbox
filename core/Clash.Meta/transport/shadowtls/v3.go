package shadowtls

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"crypto/sha256"
	"encoding/binary"
	"errors"
	"fmt"
	"hash"
	"io"
	"net"
	"sync"
)

func generateSessionID(password string) TLSSessionIDGeneratorFunc {
	return func(clientHello []byte, sessionID []byte) error {
		const sessionIDStart = 1 + 3 + 2 + tlsRandomSize + 1
		if len(clientHello) < sessionIDStart+tlsSessionIDSize || len(sessionID) < tlsSessionIDSize {
			return errors.New("shadow-tls: unexpected ClientHello length")
		}
		if _, err := rand.Read(sessionID[:tlsSessionIDSize-hmacSize]); err != nil {
			return err
		}
		for i := tlsSessionIDSize - hmacSize; i < tlsSessionIDSize; i++ {
			sessionID[i] = 0
		}
		h := hmac.New(sha1.New, []byte(password))
		_, _ = h.Write(clientHello[:sessionIDStart])
		_, _ = h.Write(sessionID[:tlsSessionIDSize])
		_, _ = h.Write(clientHello[sessionIDStart+tlsSessionIDSize:])
		copy(sessionID[tlsSessionIDSize-hmacSize:], h.Sum(nil)[:hmacSize])
		return nil
	}
}

type streamWrapper struct {
	net.Conn
	password     string
	pending      []byte
	serverRandom []byte
	readHMAC     hash.Hash
	readHMACKey  []byte
	isTLS13      bool
	authorized   bool
}

func newStreamWrapper(conn net.Conn, password string) *streamWrapper {
	return &streamWrapper{Conn: conn, password: password}
}

func (c *streamWrapper) Authorized() (bool, bool, []byte, hash.Hash) {
	return c.isTLS13, c.authorized, c.serverRandom, c.readHMAC
}

func (c *streamWrapper) Read(p []byte) (int, error) {
	if len(c.pending) > 0 {
		return c.readPending(p), nil
	}
	frame, err := readFrame(c.Conn)
	if err != nil {
		return 0, err
	}
	switch frame[0] {
	case handshake:
		// Mirror the server's one-shot seed: only initialize the HMAC chain on the first
		// ServerHello so a TLS 1.3 HelloRetryRequest (RFC 8446 section 4.1.4) aligns both peers.
		if len(frame) >= serverRandomIndex+tlsRandomSize && frame[tlsHeaderSize] == serverHello && c.readHMAC == nil {
			c.serverRandom = append([]byte(nil), frame[serverRandomIndex:serverRandomIndex+tlsRandomSize]...)
			c.readHMAC = hmac.New(sha1.New, []byte(c.password))
			_, _ = c.readHMAC.Write(c.serverRandom)
			c.readHMACKey = kdf(c.password, c.serverRandom)
			c.isTLS13 = isServerHelloSupportTLS13(frame)
			c.authorized = !c.isTLS13
		}
	case applicationData:
		c.authorized = false
		if len(frame) > tlsHMACHeaderSize && c.readHMAC != nil {
			_, _ = c.readHMAC.Write(frame[tlsHMACHeaderSize:])
			if !hmac.Equal(c.readHMAC.Sum(nil)[:hmacSize], frame[tlsHeaderSize:tlsHMACHeaderSize]) {
				return 0, errors.New("shadow-tls v3: HMAC mismatch, possible data corruption")
			}
			xorSlice(frame[tlsHMACHeaderSize:], c.readHMACKey)
			copy(frame[hmacSize:hmacSize+tlsHeaderSize], frame[:tlsHeaderSize])
			frame = frame[hmacSize:]
			binary.BigEndian.PutUint16(frame[3:5], uint16(len(frame)-tlsHeaderSize))
			c.authorized = true
		}
	}
	c.pending = frame
	return c.readPending(p), nil
}

func (c *streamWrapper) readPending(p []byte) int {
	n := copy(p, c.pending)
	c.pending = c.pending[n:]
	return n
}

type verifiedConn struct {
	net.Conn
	writeMu    sync.Mutex
	hmacAdd    hash.Hash
	hmacVerify hash.Hash
	hmacIgnore hash.Hash
	pending    []byte
	readBuffer []byte
	readOffset int
}

func newVerifiedConn(conn net.Conn, hmacAdd, hmacVerify, hmacIgnore hash.Hash) *verifiedConn {
	return &verifiedConn{
		Conn:       conn,
		hmacAdd:    hmacAdd,
		hmacVerify: hmacVerify,
		hmacIgnore: hmacIgnore,
	}
}

func (c *verifiedConn) Read(p []byte) (int, error) {
	if len(c.pending) > 0 {
		return c.readPending(p), nil
	}
	for {
		frame, err := c.readRecord()
		if err != nil {
			var netErr net.Error
			if errors.As(err, &netErr) && netErr.Timeout() {
				return 0, err
			}
			sendAlert(c.Conn)
			return 0, err
		}
		switch frame[0] {
		case alert:
			return 0, fmt.Errorf("shadow-tls: remote alert: %w", net.ErrClosed)
		case applicationData:
			if c.hmacIgnore != nil {
				if verifyApplicationData(frame, c.hmacIgnore, false) {
					continue
				}
				c.hmacIgnore = nil
			}
			if !verifyApplicationData(frame, c.hmacVerify, true) {
				sendAlert(c.Conn)
				return 0, errors.New("shadow-tls: application data verification failed")
			}
			c.pending = frame[tlsHMACHeaderSize:]
			return c.readPending(p), nil
		default:
			sendAlert(c.Conn)
			return 0, fmt.Errorf("shadow-tls: unexpected TLS record type: %d", frame[0])
		}
	}
}

func (c *verifiedConn) readRecord() ([]byte, error) {
	// Keep an incomplete record so a read deadline only interrupts the current Read.
	if c.readBuffer == nil {
		c.readBuffer = make([]byte, tlsHeaderSize)
	}
	if c.readOffset < tlsHeaderSize {
		n, err := io.ReadFull(c.Conn, c.readBuffer[c.readOffset:tlsHeaderSize])
		c.readOffset += n
		if err != nil {
			return nil, err
		}
		length := int(binary.BigEndian.Uint16(c.readBuffer[3:]))
		c.readBuffer = append(c.readBuffer, make([]byte, length)...)
	}
	if c.readOffset < len(c.readBuffer) {
		n, err := io.ReadFull(c.Conn, c.readBuffer[c.readOffset:])
		c.readOffset += n
		if err != nil {
			return nil, err
		}
	}
	frame := c.readBuffer
	c.readBuffer = nil
	c.readOffset = 0
	return frame, nil
}

func (c *verifiedConn) readPending(p []byte) int {
	n := copy(p, c.pending)
	c.pending = c.pending[n:]
	return n
}

func (c *verifiedConn) Write(p []byte) (int, error) {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	total := len(p)
	for len(p) > 0 {
		length := len(p)
		if length > maxTLSPlaintext {
			length = maxTLSPlaintext
		}
		if err := c.writeRecord(p[:length]); err != nil {
			return total - len(p), err
		}
		p = p[length:]
	}
	return total, nil
}

func (c *verifiedConn) writeRecord(p []byte) error {
	var header [tlsHMACHeaderSize]byte
	header[0] = applicationData
	header[1] = 3
	header[2] = 3
	binary.BigEndian.PutUint16(header[3:tlsHeaderSize], uint16(hmacSize+len(p)))
	_, _ = c.hmacAdd.Write(p)
	hmacHash := c.hmacAdd.Sum(nil)[:hmacSize]
	_, _ = c.hmacAdd.Write(hmacHash)
	copy(header[tlsHeaderSize:], hmacHash)
	return writeBuffers(c.Conn, header[:], p)
}

func (c *verifiedConn) Upstream() any { return c.Conn }

func verifyApplicationData(frame []byte, h hash.Hash, update bool) bool {
	if len(frame) < tlsHMACHeaderSize || frame[0] != applicationData || frame[1] != 3 || frame[2] != 3 {
		return false
	}
	_, _ = h.Write(frame[tlsHMACHeaderSize:])
	hmacHash := h.Sum(nil)[:hmacSize]
	if update {
		_, _ = h.Write(hmacHash)
	}
	return hmac.Equal(frame[tlsHeaderSize:tlsHMACHeaderSize], hmacHash)
}

func verifyClientHello(frame []byte, users []User) (*User, error) {
	const minLength = tlsHeaderSize + 1 + 3 + 2 + tlsRandomSize + 1 + tlsSessionIDSize
	const hmacIndex = sessionIDLengthIndex + 1 + tlsSessionIDSize - hmacSize
	if len(frame) < minLength {
		return nil, io.ErrUnexpectedEOF
	}
	if frame[0] != handshake || frame[tlsHeaderSize] != clientHello {
		return nil, errors.New("shadow-tls: unexpected ClientHello record")
	}
	if frame[sessionIDLengthIndex] != tlsSessionIDSize {
		return nil, errors.New("shadow-tls: unexpected session ID length")
	}
	for i := range users {
		user := &users[i]
		h := hmac.New(sha1.New, []byte(user.Password))
		_, _ = h.Write(frame[tlsHeaderSize:hmacIndex])
		_, _ = h.Write([]byte{0, 0, 0, 0})
		_, _ = h.Write(frame[hmacIndex+hmacSize:])
		if hmac.Equal(frame[hmacIndex:hmacIndex+hmacSize], h.Sum(nil)[:hmacSize]) {
			return user, nil
		}
	}
	return nil, errors.New("shadow-tls: ClientHello HMAC mismatch")
}

func copyByFrameUntilHMACMatches(conn, handshakeConn net.Conn, hmacVerify hash.Hash, hmacReset func()) ([]byte, error) {
	for {
		frame, err := readFrame(conn)
		if err != nil {
			return nil, fmt.Errorf("shadow-tls: read client record: %w", err)
		}
		if len(frame) > tlsHMACHeaderSize && frame[0] == applicationData {
			hmacReset()
			_, _ = hmacVerify.Write(frame[tlsHMACHeaderSize:])
			hmacHash := hmacVerify.Sum(nil)[:hmacSize]
			if hmac.Equal(hmacHash, frame[tlsHeaderSize:tlsHMACHeaderSize]) {
				hmacReset()
				_, _ = hmacVerify.Write(frame[tlsHMACHeaderSize:])
				_, _ = hmacVerify.Write(frame[tlsHeaderSize:tlsHMACHeaderSize])
				return append([]byte(nil), frame[tlsHMACHeaderSize:]...), nil
			}
		}
		if _, err = handshakeConn.Write(frame); err != nil {
			return nil, fmt.Errorf("shadow-tls: write client record: %w", err)
		}
	}
}

func copyByFrameWithModification(conn, handshakeConn net.Conn, password string, serverRandom []byte, hmacWrite hash.Hash) error {
	writeKey := kdf(password, serverRandom)
	for {
		frame, err := readFrame(conn)
		if err != nil {
			return fmt.Errorf("shadow-tls: read server record: %w", err)
		}
		if frame[0] != applicationData {
			if _, err = handshakeConn.Write(frame); err != nil {
				return fmt.Errorf("shadow-tls: write server record: %w", err)
			}
			continue
		}
		xorSlice(frame[tlsHeaderSize:], writeKey)
		_, _ = hmacWrite.Write(frame[tlsHeaderSize:])
		binary.BigEndian.PutUint16(frame[3:5], uint16(len(frame)-tlsHeaderSize+hmacSize))
		hmacHash := hmacWrite.Sum(nil)[:hmacSize]
		if err = writeBuffers(handshakeConn, frame[:tlsHeaderSize], hmacHash, frame[tlsHeaderSize:]); err != nil {
			return fmt.Errorf("shadow-tls: write modified server record: %w", err)
		}
	}
}

func kdf(password string, serverRandom []byte) []byte {
	hasher := sha256.New()
	_, _ = hasher.Write([]byte(password))
	_, _ = hasher.Write(serverRandom)
	return hasher.Sum(nil)
}

func xorSlice(data, key []byte) {
	for i := range data {
		data[i] ^= key[i%len(key)]
	}
}

func sendAlert(writer io.Writer) {
	const recordSize = 31
	record := [recordSize]byte{alert, 3, 3, 0, recordSize - tlsHeaderSize}
	if _, err := rand.Read(record[tlsHeaderSize:]); err == nil {
		_, _ = writer.Write(record[:])
	}
}

func hmacReset(h hash.Hash, serverRandom []byte, side byte) {
	h.Reset()
	_, _ = h.Write(serverRandom)
	_, _ = h.Write([]byte{side})
}
