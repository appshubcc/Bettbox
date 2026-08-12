package ca

import (
	"crypto/x509"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestNameCertVerifier(t *testing.T) {
	roots := x509.NewCertPool()
	roots.AddCert(rootCert)
	untrustedRoots := x509.NewCertPool()
	untrustedRoots.AddCert(smimeRootCert)

	tests := []struct {
		name         string
		dnsName      string
		roots        *x509.CertPool
		now          func() time.Time
		certificates []*x509.Certificate
		wantErr      bool
	}{
		{
			name:         "valid chain",
			dnsName:      leafServerName,
			roots:        roots,
			now:          certTime,
			certificates: []*x509.Certificate{leafCert, intermediateCert},
		},
		{
			name:         "valid chain with root",
			dnsName:      leafServerName,
			roots:        roots,
			now:          certTime,
			certificates: []*x509.Certificate{leafCert, intermediateCert, rootCert},
		},
		{
			name:         "wrong DNS name",
			dnsName:      wrongLeafServerName,
			roots:        roots,
			now:          certTime,
			certificates: []*x509.Certificate{leafCert, intermediateCert},
			wantErr:      true,
		},
		{
			name:    "no certificates",
			dnsName: leafServerName,
			roots:   roots,
			now:     certTime,
			wantErr: true,
		},
		{
			name:         "missing intermediate",
			dnsName:      leafServerName,
			roots:        roots,
			now:          certTime,
			certificates: []*x509.Certificate{leafCert},
			wantErr:      true,
		},
		{
			name:         "untrusted root",
			dnsName:      leafServerName,
			roots:        untrustedRoots,
			now:          certTime,
			certificates: []*x509.Certificate{leafCert, intermediateCert},
			wantErr:      true,
		},
		{
			name:         "expired certificate",
			dnsName:      leafServerName,
			roots:        roots,
			now:          func() time.Time { return leafCert.NotAfter.Add(time.Second) },
			certificates: []*x509.Certificate{leafCert, intermediateCert},
			wantErr:      true,
		},
		{
			name:         "invalid certificate signature",
			dnsName:      leafServerName,
			roots:        roots,
			now:          certTime,
			certificates: []*x509.Certificate{leafWithInvalidHashCert, intermediateCert},
			wantErr:      true,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := NewNameCertVerifier(test.dnsName, test.roots, test.now)(test.certificates)
			if test.wantErr {
				require.Error(t, err)
			} else {
				require.NoError(t, err)
			}
		})
	}
}
