package mitm

import (
	"archive/zip"
	"bytes"
	"embed"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"
)

//go:embed module/*
var moduleFS embed.FS

const moduleID = "bettbox_mitm_ca"

func (a *Authority) ModuleZipBytes() ([]byte, error) {
	if a == nil {
		return nil, fmt.Errorf("CA is not generated")
	}
	buf := new(bytes.Buffer)
	zw := zip.NewWriter(buf)
	now := time.Now()

	err := fs.WalkDir(moduleFS, "module", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		name := strings.TrimPrefix(path, "module/")
		if name == "" {
			return nil
		}
		data, err := moduleFS.ReadFile(path)
		if err != nil {
			return err
		}
		if name == "module.prop" {
			data = []byte(fmt.Sprintf(
				"id=%s\nname=Bettbox MITM CA\nversion=1.0.0\nversionCode=1\nauthor=Bettbox\ndescription=Mounts Bettbox MITM CA %s into the system trust store\n",
				moduleID,
				a.SubjectHashOld(),
			))
		}
		return writeZipFile(zw, name, data, now, zipMode(name))
	})
	if err != nil {
		_ = zw.Close()
		return nil, err
	}
	hashName := a.SubjectHashOld() + ".0"
	if err := writeZipFile(zw, "cacerts/"+hashName, a.certPEM, now, 0644); err != nil {
		_ = zw.Close()
		return nil, err
	}
	if err := zw.Close(); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func (a *Authority) WriteModuleZip(dest string) error {
	data, err := a.ModuleZipBytes()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(dest), 0o700); err != nil {
		return err
	}
	return os.WriteFile(dest, data, 0o600)
}

func (a *Authority) DefaultModuleZipPath() string {
	return filepath.Join(mitmDir(), fmt.Sprintf("bettbox-ca-%s.zip", a.SubjectHashOld()))
}

func zipMode(name string) os.FileMode {
	if strings.HasSuffix(name, ".sh") {
		return 0755
	}
	return 0644
}

func writeZipFile(zw *zip.Writer, name string, data []byte, now time.Time, mode os.FileMode) error {
	hdr := &zip.FileHeader{
		Name:     name,
		Method:   zip.Deflate,
		Modified: now,
	}
	hdr.SetMode(mode)
	w, err := zw.CreateHeader(hdr)
	if err != nil {
		return err
	}
	_, err = io.Copy(w, bytes.NewReader(data))
	return err
}
