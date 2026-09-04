package main

import (
	"github.com/metacubex/mihomo/component/mitm"
)

func handleGetMitmCA() (map[string]string, error) {
	auth, err := mitm.LoadOrCreate()
	if err != nil {
		return nil, err
	}
	return auth.Info(), nil
}

func handleRegenerateMitmCA() (map[string]string, error) {
	auth, err := mitm.Create()
	if err != nil {
		return nil, err
	}
	return auth.Info(), nil
}

func handleExportMitmModule() (map[string]string, error) {
	auth, err := mitm.LoadOrCreate()
	if err != nil {
		return nil, err
	}
	path := auth.DefaultModuleZipPath()
	if err := auth.WriteModuleZip(path); err != nil {
		return nil, err
	}
	info := auth.Info()
	info["path"] = path
	info["filename"] = "bettbox-ca-" + auth.SubjectHashOld() + ".zip"
	return info, nil
}
