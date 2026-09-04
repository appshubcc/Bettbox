package mitm

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/md5"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	C "github.com/metacubex/mihomo/constant"
)

const (
	caFileName  = "ca.crt"
	keyFileName = "ca.key"
	caCN        = "Bettbox MITM CA"
	caOrg       = "Bettbox"
)

// Authority is a persistent MITM root CA plus a leaf-certificate cache.
type Authority struct {
	cert     *x509.Certificate
	certPEM  []byte
	key      *ecdsa.PrivateKey
	keyPEM   []byte
	leafKey  *ecdsa.PrivateKey
	mu       sync.RWMutex
	leafs    map[string]*tls.Certificate
}

func mitmDir() string {
	return filepath.Join(C.Path.HomeDir(), "mitm")
}

func caPaths() (certPath, keyPath string) {
	dir := mitmDir()
	return filepath.Join(dir, caFileName), filepath.Join(dir, keyFileName)
}

// LoadOrCreate loads the on-disk MITM CA, or creates one if missing.
func LoadOrCreate() (*Authority, error) {
	certPath, keyPath := caPaths()
	certPEM, certErr := os.ReadFile(certPath)
	keyPEM, keyErr := os.ReadFile(keyPath)
	if certErr == nil && keyErr == nil {
		auth, err := parseAuthority(certPEM, keyPEM)
		if err == nil {
			return auth, nil
		}
	}
	return Create()
}

// Create generates a new CA and overwrites any existing files.
func Create() (*Authority, error) {
	auth, err := generateAuthority()
	if err != nil {
		return nil, err
	}
	if err := auth.persist(); err != nil {
		return nil, err
	}
	return auth, nil
}

func generateAuthority() (*Authority, error) {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, err
	}
	leafKey, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, err
	}
	serial, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return nil, err
	}
	now := time.Now()
	template := &x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   caCN,
			Organization: []string{caOrg},
		},
		NotBefore:             now.Add(-time.Hour),
		NotAfter:              now.Add(10 * 365 * 24 * time.Hour),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign | x509.KeyUsageDigitalSignature,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth, x509.ExtKeyUsageClientAuth},
		BasicConstraintsValid: true,
		IsCA:                  true,
		MaxPathLen:            1,
	}
	der, err := x509.CreateCertificate(rand.Reader, template, template, &key.PublicKey, key)
	if err != nil {
		return nil, err
	}
	cert, err := x509.ParseCertificate(der)
	if err != nil {
		return nil, err
	}
	keyBytes, err := x509.MarshalPKCS8PrivateKey(key)
	if err != nil {
		return nil, err
	}
	auth := &Authority{
		cert:    cert,
		certPEM: pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: der}),
		key:     key,
		keyPEM:  pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyBytes}),
		leafKey: leafKey,
		leafs:   make(map[string]*tls.Certificate),
	}
	return auth, nil
}

func parseAuthority(certPEM, keyPEM []byte) (*Authority, error) {
	certBlock, _ := pem.Decode(certPEM)
	if certBlock == nil {
		return nil, fmt.Errorf("invalid CA certificate PEM")
	}
	cert, err := x509.ParseCertificate(certBlock.Bytes)
	if err != nil {
		return nil, err
	}
	keyBlock, _ := pem.Decode(keyPEM)
	if keyBlock == nil {
		return nil, fmt.Errorf("invalid CA key PEM")
	}
	parsed, err := x509.ParsePKCS8PrivateKey(keyBlock.Bytes)
	if err != nil {
		return nil, err
	}
	key, ok := parsed.(*ecdsa.PrivateKey)
	if !ok {
		return nil, fmt.Errorf("CA key is not ECDSA")
	}
	leafKey, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, err
	}
	return &Authority{
		cert:    cert,
		certPEM: certPEM,
		key:     key,
		keyPEM:  keyPEM,
		leafKey: leafKey,
		leafs:   make(map[string]*tls.Certificate),
	}, nil
}

func (a *Authority) persist() error {
	dir := mitmDir()
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return err
	}
	certPath, keyPath := caPaths()
	if err := os.WriteFile(certPath, a.certPEM, 0o600); err != nil {
		return err
	}
	return os.WriteFile(keyPath, a.keyPEM, 0o600)
}

func (a *Authority) CertPEM() []byte { return a.certPEM }
func (a *Authority) KeyPEM() []byte  { return a.keyPEM }

func (a *Authority) Certificate() *x509.Certificate { return a.cert }

func (a *Authority) Fingerprint() string {
	sum := sha256.Sum256(a.cert.Raw)
	return hex.EncodeToString(sum[:])
}

// SubjectHashOld is the OpenSSL subject_hash_old value used as the Android CA filename.
func (a *Authority) SubjectHashOld() string {
	return SubjectHashOld(a.cert)
}

func SubjectHashOld(cert *x509.Certificate) string {
	sum := md5.Sum(cert.RawSubject)
	hash := uint32(sum[0]) | uint32(sum[1])<<8 | uint32(sum[2])<<16 | uint32(sum[3])<<24
	return fmt.Sprintf("%08x", hash)
}

func (a *Authority) NotBefore() time.Time { return a.cert.NotBefore }
func (a *Authority) NotAfter() time.Time  { return a.cert.NotAfter }

func (a *Authority) Info() map[string]string {
	return map[string]string{
		"fingerprint":  a.Fingerprint(),
		"subject-hash": a.SubjectHashOld(),
		"not-before":   a.cert.NotBefore.UTC().Format(time.RFC3339),
		"not-after":    a.cert.NotAfter.UTC().Format(time.RFC3339),
		"cert-pem":     string(a.certPEM),
	}
}

// Leaf returns a cached server certificate for name, signed by this CA.
func (a *Authority) Leaf(name string) (*tls.Certificate, error) {
	name = strings.TrimSpace(strings.ToLower(name))
	if name == "" {
		name = "localhost"
	}
	a.mu.RLock()
	if cert, ok := a.leafs[name]; ok {
		a.mu.RUnlock()
		return cert, nil
	}
	a.mu.RUnlock()

	a.mu.Lock()
	defer a.mu.Unlock()
	if cert, ok := a.leafs[name]; ok {
		return cert, nil
	}
	cert, err := a.issueLeaf(name)
	if err != nil {
		return nil, err
	}
	a.leafs[name] = cert
	return cert, nil
}

func (a *Authority) issueLeaf(name string) (*tls.Certificate, error) {
	serial, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return nil, err
	}
	now := time.Now()
	template := &x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   name,
			Organization: []string{caOrg},
		},
		NotBefore:             now.Add(-time.Hour),
		NotAfter:              now.Add(365 * 24 * time.Hour),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
	}
	if ip := net.ParseIP(name); ip != nil {
		template.IPAddresses = []net.IP{ip}
	} else {
		template.DNSNames = []string{name}
	}
	der, err := x509.CreateCertificate(rand.Reader, template, a.cert, &a.leafKey.PublicKey, a.key)
	if err != nil {
		return nil, err
	}
	return &tls.Certificate{
		Certificate: [][]byte{der, a.cert.Raw},
		PrivateKey:  a.leafKey,
		Leaf:        nil,
	}, nil
}
