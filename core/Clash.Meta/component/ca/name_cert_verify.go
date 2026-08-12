package ca

import (
	"crypto/x509"
	"errors"
	"time"
)

// NewNameCertVerifier returns a verifier for a certificate chain and an explicit DNSName.
func NewNameCertVerifier(dnsName string, roots *x509.CertPool, now func() time.Time) func([]*x509.Certificate) error {
	return func(certificates []*x509.Certificate) error {
		if len(certificates) == 0 {
			return errors.New("tls: no peer certificates")
		}

		intermediates := x509.NewCertPool()
		for _, certificate := range certificates[1:] {
			intermediates.AddCert(certificate)
		}
		verifyOptions := x509.VerifyOptions{
			Roots:         roots,
			Intermediates: intermediates,
			DNSName:       dnsName,
		}
		if now != nil {
			verifyOptions.CurrentTime = now()
		}
		_, err := certificates[0].Verify(verifyOptions)
		return err
	}
}
