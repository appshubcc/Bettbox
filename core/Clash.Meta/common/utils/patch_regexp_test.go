package utils

import (
	"strconv"
	"sync"
	"testing"

	"github.com/dlclark/regexp2"
)

func TestCompileRegexpCache(t *testing.T) {
	first, err := CompileRegexp("(?i)hk|香港", regexp2.None)
	if err != nil {
		t.Fatalf("CompileRegexp failed: %v", err)
	}
	second := MustCompileRegexp("(?i)hk|香港", regexp2.None)
	if first != second {
		t.Fatal("expected cached *regexp2.Regexp pointer to match")
	}
	differentOpt, err := CompileRegexp("(?i)hk|香港", regexp2.ECMAScript)
	if err != nil {
		t.Fatalf("CompileRegexp with ECMAScript failed: %v", err)
	}
	if first == differentOpt {
		t.Fatal("expected different RegexOptions to have distinct cache entries")
	}
	if _, err := CompileRegexp("[invalid", regexp2.None); err == nil {
		t.Fatal("expected error for invalid pattern")
	}
}

func TestCompileRegexpConcurrentAndCap(t *testing.T) {
	var wg sync.WaitGroup
	for i := 0; i < 16; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			for j := 0; j < 100; j++ {
				pattern := "node-" + strconv.Itoa((id*100+j)%1200)
				re, err := CompileRegexp(pattern, regexp2.None)
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				if matched, _ := re.MatchString(pattern); !matched {
					t.Errorf("pattern %s did not match itself", pattern)
					return
				}
			}
		}(i)
	}
	wg.Wait()

	regexpCacheMu.RLock()
	size := len(regexpCache)
	regexpCacheMu.RUnlock()
	if size > maxCachedRegexps {
		t.Fatalf("cache size = %d, exceeds max %d", size, maxCachedRegexps)
	}
}
