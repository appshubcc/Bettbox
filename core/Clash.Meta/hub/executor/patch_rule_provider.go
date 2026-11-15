package executor

import (
	"os"

	P "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/log"
)

type vehicleProvider interface {
	Vehicle() P.Vehicle
}

func ruleProviderCached(pv P.RuleProvider) bool {
	holder, ok := pv.(vehicleProvider)
	if !ok {
		return true
	}
	vehicle := holder.Vehicle()
	if vehicle.Type() != P.HTTP {
		return true
	}
	_, err := os.Stat(vehicle.Path())
	return err == nil
}

func loadRuleProviders(providers map[string]P.RuleProvider) {
	cached := make(map[string]P.RuleProvider, len(providers))
	var pending []P.RuleProvider
	for name, pv := range providers {
		if ruleProviderCached(pv) {
			cached[name] = pv
			continue
		}
		pending = append(pending, pv)
	}
	loadProvider(cached)
	if len(pending) == 0 {
		return
	}
	ch := make(chan struct{}, concurrentCount)
	go func() {
		for _, pv := range pending {
			pv := pv
			ch <- struct{}{}
			go func() {
				defer func() { <-ch }()
				log.Infoln("Start initial provider %s in background", pv.Name())
				if err := pv.Initial(); err != nil {
					log.Warnln("initial rule provider %s error: %v", pv.Name(), err)
				}
			}()
		}
	}()
}
