package mitm

import (
	"regexp"
	"sort"
	"strings"

	"github.com/metacubex/http"
)

type RewriteAction int

const (
	ActionNone RewriteAction = iota
	ActionReject
	ActionRejectDict
	ActionRejectImg
	ActionReject200
	ActionRejectTinyGIF
)

func (a RewriteAction) String() string {
	switch a {
	case ActionReject:
		return "reject"
	case ActionRejectDict:
		return "reject-dict"
	case ActionRejectImg:
		return "reject-img"
	case ActionReject200:
		return "reject-200"
	case ActionRejectTinyGIF:
		return "reject-tinygif"
	default:
		return ""
	}
}

type RewriteRule struct {
	Raw     string
	Pattern *regexp.Regexp
	Action  RewriteAction
}

var rewriteActions = []string{
	"reject-tinygif",
	"reject-dict",
	"reject-img",
	"reject-200",
	"reject",
}

func init() {
	sort.Slice(rewriteActions, func(i, j int) bool {
		return len(rewriteActions[i]) > len(rewriteActions[j])
	})
}

func parseRewriteLine(line string) (pattern string, action RewriteAction, ok bool) {
	line = strings.TrimSpace(line)
	if line == "" || strings.HasPrefix(line, "#") {
		return "", ActionNone, false
	}
	for _, name := range rewriteActions {
		for _, sep := range []string{" - ", " "} {
			suffix := sep + name
			if strings.HasSuffix(line, suffix) {
				pat := strings.TrimSpace(line[:len(line)-len(suffix)])
				if pat == "" {
					continue
				}
				return pat, actionFromName(name), true
			}
		}
	}
	return "", ActionNone, false
}

func actionFromName(name string) RewriteAction {
	switch name {
	case "reject":
		return ActionReject
	case "reject-dict":
		return ActionRejectDict
	case "reject-img":
		return ActionRejectImg
	case "reject-200":
		return ActionReject200
	case "reject-tinygif":
		return ActionRejectTinyGIF
	default:
		return ActionNone
	}
}

func ParseRewriteRules(lines []string) []RewriteRule {
	var rules []RewriteRule
	for _, line := range lines {
		pat, action, ok := parseRewriteLine(line)
		if !ok {
			continue
		}
		re, err := regexp.Compile(pat)
		if err != nil {
			continue
		}
		rules = append(rules, RewriteRule{Raw: line, Pattern: re, Action: action})
	}
	return rules
}

func matchRewrite(rules []RewriteRule, method, url string) RewriteAction {
	_ = method
	for _, rule := range rules {
		if rule.Pattern.MatchString(url) {
			return rule.Action
		}
	}
	return ActionNone
}

func requestURL(r *http.Request) string {
	if r == nil {
		return ""
	}
	if r.URL != nil && r.URL.IsAbs() {
		return r.URL.String()
	}
	scheme := "https"
	if r.TLS == nil {
		scheme = "http"
	}
	host := r.Host
	if host == "" && r.URL != nil {
		host = r.URL.Host
	}
	path := "/"
	if r.URL != nil {
		if r.URL.Opaque != "" {
			return r.URL.Opaque
		}
		path = r.URL.RequestURI()
		if path == "" {
			path = r.URL.Path
		}
	}
	if !strings.HasPrefix(path, "/") {
		path = "/" + path
	}
	return scheme + "://" + host + path
}

var pixelPNG = []byte{
	0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d,
	0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
	0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
	0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
	0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
	0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
}

var pixelGIF = []byte{
	0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
	0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x21, 0xf9, 0x04, 0x01, 0x00,
	0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
	0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b,
}

func writeReject(w http.ResponseWriter, action RewriteAction) {
	switch action {
	case ActionRejectDict:
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("{}"))
	case ActionRejectImg:
		w.Header().Set("Content-Type", "image/png")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(pixelPNG)
	case ActionRejectTinyGIF:
		w.Header().Set("Content-Type", "image/gif")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(pixelGIF)
	case ActionReject200:
		w.WriteHeader(http.StatusOK)
	default:
		w.WriteHeader(http.StatusForbidden)
	}
}
