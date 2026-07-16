package torstate

import "sync/atomic"

type config struct {
	enabled  bool
	packages map[string]struct{}
}

var current atomic.Value

func init() {
	current.Store(config{})
}

func Update(enabled bool, packages []string) {
	next := config{
		enabled:  enabled,
		packages: make(map[string]struct{}, len(packages)),
	}
	for _, pkg := range packages {
		if pkg == "" {
			continue
		}
		next.packages[pkg] = struct{}{}
	}
	current.Store(next)
}

func ContainsPackage(pkg string) bool {
	if pkg == "" {
		return false
	}
	cfg, ok := current.Load().(config)
	if !ok || !cfg.enabled {
		return false
	}
	_, ok = cfg.packages[pkg]
	return ok
}

func Enabled() bool {
	cfg, ok := current.Load().(config)
	return ok && cfg.enabled
}
