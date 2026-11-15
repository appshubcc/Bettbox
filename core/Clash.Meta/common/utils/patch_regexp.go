package utils

import (
	"sync"

	"github.com/dlclark/regexp2"
)

const maxCachedRegexps = 1024

type regexpCacheKey struct {
	expr string
	opt  regexp2.RegexOptions
}

var (
	regexpCacheMu sync.RWMutex
	regexpCache   = make(map[regexpCacheKey]*regexp2.Regexp)
)

func CompileRegexp(expr string, opt regexp2.RegexOptions) (*regexp2.Regexp, error) {
	key := regexpCacheKey{expr: expr, opt: opt}
	regexpCacheMu.RLock()
	cached, ok := regexpCache[key]
	regexpCacheMu.RUnlock()
	if ok {
		return cached, nil
	}

	compiled, err := regexp2.Compile(expr, opt)
	if err != nil {
		return nil, err
	}

	regexpCacheMu.Lock()
	if existing, exists := regexpCache[key]; exists {
		regexpCacheMu.Unlock()
		return existing, nil
	}
	if len(regexpCache) >= maxCachedRegexps {
		regexpCache = make(map[regexpCacheKey]*regexp2.Regexp, maxCachedRegexps/4)
	}
	regexpCache[key] = compiled
	regexpCacheMu.Unlock()
	return compiled, nil
}

func MustCompileRegexp(expr string, opt regexp2.RegexOptions) *regexp2.Regexp {
	compiled, err := CompileRegexp(expr, opt)
	if err != nil {
		return regexp2.MustCompile(expr, opt)
	}
	return compiled
}
