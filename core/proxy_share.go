package main

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"maps"
	"net/url"
	"slices"
	"sort"
	"strconv"
	"strings"

	"github.com/metacubex/mihomo/common/structure"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	yamlv3 "go.yaml.in/yaml/v3"
)

type ProxyConfigParams struct {
	Setup *SetupParams `json:"setup"`
	Name  string       `json:"name"`
}

type ProxyConfigResult struct {
	Yaml string `json:"yaml"`
	Uri  string `json:"uri"`
}

func handleGetProxyConfig(params *ProxyConfigParams) (string, error) {
	result, err := getProxyConfig(params)
	if err != nil {
		return "", err
	}
	data, err := json.Marshal(result)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

func getProxyConfig(params *ProxyConfigParams) (*ProxyConfigResult, error) {
	if params.Setup == nil || params.Name == "" {
		return nil, errors.New("invalid params")
	}
	raw, _, err := loadPatchedConfig(params.Setup)
	if err != nil {
		return nil, err
	}
	mapping, err := findProxyMapping(raw, params.Name)
	if err != nil {
		return nil, err
	}
	delete(mapping, "dialer-proxy")
	content, err := proxyMappingYaml(mapping)
	if err != nil {
		return nil, err
	}
	return &ProxyConfigResult{Yaml: content, Uri: proxyShareLink(mapping)}, nil
}

func findProxyMapping(raw *config.RawConfig, name string) (map[string]any, error) {
	for _, item := range raw.Proxy {
		if item["name"] == name {
			return maps.Clone(item), nil
		}
	}
	decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
	for _, providerName := range proxyProviderOrder(raw, name) {
		schema := &expandProviderSchema{}
		if err := decoder.Decode(raw.ProxyProvider[providerName], schema); err != nil {
			continue
		}
		if schema.Type == "http" {
			if schema.Path == "" {
				schema.Path = C.Path.GetPathByHash("proxies", schema.URL)
			}
			schema.Type = "file"
		}
		proxies, err := loadProviderProxies(schema, expandOptions{AgeSecretKey: schema.AgeSecretKey})
		if err != nil {
			continue
		}
		for _, item := range proxies {
			if item["name"] == name {
				return item, nil
			}
		}
	}
	return nil, fmt.Errorf("proxy %s not found", name)
}

func proxyProviderOrder(raw *config.RawConfig, name string) []string {
	names := make([]string, 0, len(raw.ProxyProvider))
	for providerName := range raw.ProxyProvider {
		names = append(names, providerName)
	}
	sort.Strings(names)
	for providerName, provider := range tunnel.Providers() {
		if !slices.Contains(names, providerName) {
			continue
		}
		for _, proxy := range provider.Proxies() {
			if proxy.Name() == name {
				index := slices.Index(names, providerName)
				names = append([]string{providerName}, slices.Delete(names, index, index+1)...)
				return names
			}
		}
	}
	return names
}

var proxyLeadingKeys = []string{"name", "type", "server", "port"}

func proxyMappingYaml(mapping map[string]any) (string, error) {
	normalized, err := plainYamlValue(mapping)
	if err != nil {
		return "", err
	}
	values, _ := normalized.(map[string]any)
	keys := make([]string, 0, len(values))
	for key := range values {
		if !slices.Contains(proxyLeadingKeys, key) {
			keys = append(keys, key)
		}
	}
	sort.Strings(keys)
	ordered := make([]string, 0, len(values))
	for _, key := range proxyLeadingKeys {
		if _, ok := values[key]; ok {
			ordered = append(ordered, key)
		}
	}
	ordered = append(ordered, keys...)
	root := &yamlv3.Node{Kind: yamlv3.MappingNode}
	for _, key := range ordered {
		var value yamlv3.Node
		if err := value.Encode(values[key]); err != nil {
			return "", err
		}
		root.Content = append(root.Content, &yamlv3.Node{Kind: yamlv3.ScalarNode, Value: key}, &value)
	}
	out, err := marshalYamlNode(root)
	if err != nil {
		return "", err
	}
	return strings.TrimRight(string(out), "\n"), nil
}

func plainYamlValue(value any) (any, error) {
	data, err := json.Marshal(value)
	if err != nil {
		return nil, err
	}
	var result any
	decoder := json.NewDecoder(strings.NewReader(string(data)))
	decoder.UseNumber()
	if err := decoder.Decode(&result); err != nil {
		return nil, err
	}
	return jsonNumbers(result), nil
}

func jsonNumbers(value any) any {
	switch typed := value.(type) {
	case map[string]any:
		for key, item := range typed {
			typed[key] = jsonNumbers(item)
		}
	case []any:
		for index, item := range typed {
			typed[index] = jsonNumbers(item)
		}
	case json.Number:
		if number, err := typed.Int64(); err == nil {
			return number
		}
		if number, err := typed.Float64(); err == nil {
			return number
		}
	}
	return value
}

type shareMapping map[string]any

func (m shareMapping) str(key string) string {
	switch value := m[key].(type) {
	case string:
		return value
	case nil:
		return ""
	case float64:
		return strconv.FormatFloat(value, 'f', -1, 64)
	default:
		return fmt.Sprint(value)
	}
}

func (m shareMapping) boolean(key string) bool {
	switch value := m[key].(type) {
	case bool:
		return value
	case string:
		parsed, _ := strconv.ParseBool(value)
		return parsed
	}
	return false
}

func (m shareMapping) strings(key string) []string {
	switch value := m[key].(type) {
	case []string:
		return value
	case []any:
		result := make([]string, 0, len(value))
		for _, item := range value {
			result = append(result, fmt.Sprint(item))
		}
		return result
	case string:
		if value != "" {
			return []string{value}
		}
	}
	return nil
}

func (m shareMapping) sub(key string) shareMapping {
	switch value := m[key].(type) {
	case map[string]any:
		return value
	case shareMapping:
		return value
	}
	return shareMapping{}
}

func (m shareMapping) first(key string) string {
	if values := m.strings(key); len(values) > 0 {
		return values[0]
	}
	return ""
}

func (m shareMapping) hostPort() string {
	return joinShareHost(m.str("server"), m.str("port"))
}

func joinShareHost(server, port string) string {
	if strings.Contains(server, ":") && !strings.HasPrefix(server, "[") {
		server = "[" + server + "]"
	}
	return server + ":" + port
}

func shareFragment(name string) string {
	return (&url.URL{Fragment: name}).EscapedFragment()
}

func setQuery(query url.Values, key, value string) {
	if value != "" {
		query.Set(key, value)
	}
}

func shareURL(scheme string, user *url.Userinfo, host string, query url.Values, name string) string {
	link := url.URL{Scheme: scheme, User: user, Host: host, RawQuery: query.Encode()}
	if len(query) == 0 {
		link.RawQuery = ""
	}
	return link.String() + "#" + shareFragment(name)
}

func proxyShareLink(mapping map[string]any) string {
	m := shareMapping(mapping)
	if m.str("server") == "" {
		return ""
	}
	switch strings.ToLower(m.str("type")) {
	case "ss":
		return ssShareLink(m)
	case "ssr":
		return ssrShareLink(m)
	case "vmess":
		return vmessShareLink(m)
	case "vless":
		return vlessShareLink(m)
	case "trojan":
		return trojanShareLink(m)
	case "hysteria":
		return hysteriaShareLink(m)
	case "hysteria2":
		return hysteria2ShareLink(m)
	case "tuic":
		return tuicShareLink(m)
	case "anytls":
		return anytlsShareLink(m)
	case "socks5", "http":
		return socksShareLink(m)
	case "mieru":
		return mieruShareLink(m)
	}
	return ""
}

func ssShareLink(m shareMapping) string {
	cipher, password := m.str("cipher"), m.str("password")
	var user *url.Userinfo
	if strings.HasPrefix(cipher, "2022-") {
		user = url.UserPassword(cipher, password)
	} else {
		user = url.User(base64.RawURLEncoding.EncodeToString([]byte(cipher + ":" + password)))
	}
	query := url.Values{}
	if m.boolean("udp-over-tcp") {
		query.Set("uot", "1")
	}
	opts := m.sub("plugin-opts")
	switch m.str("plugin") {
	case "":
	case "obfs":
		plugin := "obfs-local;obfs=" + opts.str("mode")
		if host := opts.str("host"); host != "" {
			plugin += ";obfs-host=" + host
		}
		query.Set("plugin", plugin)
	case "v2ray-plugin":
		plugin := "v2ray-plugin;mode=" + opts.str("mode")
		if host := opts.str("host"); host != "" {
			plugin += ";host=" + host
		}
		if path := opts.str("path"); path != "" {
			plugin += ";path=" + path
		}
		if opts.boolean("tls") {
			plugin += ";tls"
		}
		query.Set("plugin", plugin)
	default:
		return ""
	}
	return shareURL("ss", user, m.hostPort(), query, m.str("name"))
}

func ssrShareLink(m shareMapping) string {
	encode := func(value string) string {
		return base64.RawURLEncoding.EncodeToString([]byte(value))
	}
	body := strings.Join([]string{
		m.str("server"), m.str("port"), m.str("protocol"), m.str("cipher"), m.str("obfs"),
		encode(m.str("password")),
	}, ":")
	query := []string{"remarks=" + encode(m.str("name"))}
	if value := m.str("obfs-param"); value != "" {
		query = append(query, "obfsparam="+encode(value))
	}
	if value := m.str("protocol-param"); value != "" {
		query = append(query, "protoparam="+encode(value))
	}
	return "ssr://" + encode(body+"/?"+strings.Join(query, "&"))
}

func vmessShareLink(m shareMapping) string {
	values := map[string]any{
		"v":    "2",
		"ps":   m.str("name"),
		"add":  m.str("server"),
		"port": m.str("port"),
		"id":   m.str("uuid"),
		"aid":  m.str("alterId"),
		"scy":  m.str("cipher"),
		"net":  "tcp",
		"type": "none",
		"tls":  "",
	}
	if values["aid"] == "" {
		values["aid"] = "0"
	}
	if values["scy"] == "" {
		values["scy"] = "auto"
	}
	if m.boolean("tls") {
		values["tls"] = "tls"
		if sni := m.str("servername"); sni != "" {
			values["sni"] = sni
		}
		if alpn := m.strings("alpn"); len(alpn) > 0 {
			values["alpn"] = strings.Join(alpn, ",")
		}
		if fp := m.str("client-fingerprint"); fp != "" {
			values["fp"] = fp
		}
	}
	switch network := m.str("network"); network {
	case "", "tcp":
	case "http":
		opts := m.sub("http-opts")
		values["type"] = "http"
		values["host"] = opts.sub("headers").first("Host")
		values["path"] = opts.first("path")
	case "h2":
		opts := m.sub("h2-opts")
		values["net"] = "h2"
		values["host"] = opts.first("host")
		values["path"] = opts.str("path")
	case "ws":
		opts := m.sub("ws-opts")
		values["net"] = "ws"
		if opts.boolean("v2ray-http-upgrade") {
			values["net"] = "httpupgrade"
		}
		values["host"] = opts.sub("headers").str("Host")
		values["path"] = wsSharePath(opts)
	case "grpc":
		values["net"] = "grpc"
		values["path"] = m.sub("grpc-opts").str("grpc-service-name")
	default:
		return ""
	}
	data, err := json.Marshal(values)
	if err != nil {
		return ""
	}
	return "vmess://" + base64.StdEncoding.EncodeToString(data)
}

func wsSharePath(opts shareMapping) string {
	path := opts.str("path")
	early := opts.str("max-early-data")
	if early == "" || early == "0" || opts.str("early-data-header-name") != "Sec-WebSocket-Protocol" {
		return path
	}
	separator := "?"
	if strings.Contains(path, "?") {
		separator = "&"
	}
	return path + separator + "ed=" + early
}

func vlessShareLink(m shareMapping) string {
	query := url.Values{}
	setQuery(query, "encryption", m.str("encryption"))
	setQuery(query, "flow", m.str("flow"))
	if !applyVShareTransport(m, query) {
		return ""
	}
	if m.boolean("packet-addr") {
		query.Set("packetEncoding", "packet")
	}
	return shareURL("vless", url.User(m.str("uuid")), m.hostPort(), query, m.str("name"))
}

func applyVShareTransport(m shareMapping, query url.Values) bool {
	reality := m.sub("reality-opts")
	switch {
	case reality.str("public-key") != "":
		query.Set("security", "reality")
		query.Set("pbk", reality.str("public-key"))
		setQuery(query, "sid", reality.str("short-id"))
	case m.boolean("tls"):
		query.Set("security", "tls")
	default:
		query.Set("security", "none")
	}
	setQuery(query, "sni", m.str("servername"))
	if m.boolean("tls") {
		setQuery(query, "fp", m.str("client-fingerprint"))
		setQuery(query, "pcs", m.str("fingerprint"))
		if alpn := m.strings("alpn"); len(alpn) > 0 {
			query.Set("alpn", strings.Join(alpn, ","))
		}
		if m.boolean("skip-cert-verify") {
			query.Set("allowInsecure", "1")
		}
	}
	switch network := m.str("network"); network {
	case "", "tcp":
		query.Set("type", "tcp")
	case "http":
		opts := m.sub("http-opts")
		query.Set("type", "tcp")
		query.Set("headerType", "http")
		setQuery(query, "host", opts.sub("headers").first("Host"))
		setQuery(query, "path", opts.first("path"))
		setQuery(query, "method", opts.str("method"))
	case "h2":
		opts := m.sub("h2-opts")
		query.Set("type", "http")
		setQuery(query, "host", opts.first("host"))
		setQuery(query, "path", opts.str("path"))
	case "ws":
		opts := m.sub("ws-opts")
		query.Set("type", "ws")
		if opts.boolean("v2ray-http-upgrade") {
			query.Set("type", "httpupgrade")
		}
		setQuery(query, "host", opts.sub("headers").str("Host"))
		setQuery(query, "path", opts.str("path"))
		if early := opts.str("max-early-data"); early != "" && early != "0" {
			query.Set("ed", early)
		}
	case "grpc":
		query.Set("type", "grpc")
		setQuery(query, "serviceName", m.sub("grpc-opts").str("grpc-service-name"))
	case "xhttp":
		opts := m.sub("xhttp-opts")
		query.Set("type", "xhttp")
		setQuery(query, "host", opts.str("host"))
		setQuery(query, "path", opts.str("path"))
		setQuery(query, "mode", opts.str("mode"))
	default:
		return false
	}
	return true
}

func trojanShareLink(m shareMapping) string {
	query := url.Values{}
	setQuery(query, "sni", m.str("sni"))
	if alpn := m.strings("alpn"); len(alpn) > 0 {
		query.Set("alpn", strings.Join(alpn, ","))
	}
	setQuery(query, "fp", m.str("client-fingerprint"))
	setQuery(query, "pcs", m.str("fingerprint"))
	if m.boolean("skip-cert-verify") {
		query.Set("allowInsecure", "1")
	}
	switch network := m.str("network"); network {
	case "", "tcp":
	case "ws":
		opts := m.sub("ws-opts")
		query.Set("type", "ws")
		if opts.boolean("v2ray-http-upgrade") {
			query.Set("type", "httpupgrade")
		}
		setQuery(query, "host", opts.sub("headers").str("Host"))
		setQuery(query, "path", opts.str("path"))
	case "grpc":
		query.Set("type", "grpc")
		setQuery(query, "serviceName", m.sub("grpc-opts").str("grpc-service-name"))
	default:
		return ""
	}
	return shareURL("trojan", url.User(m.str("password")), m.hostPort(), query, m.str("name"))
}

func hysteriaShareLink(m shareMapping) string {
	query := url.Values{}
	setQuery(query, "peer", m.str("sni"))
	setQuery(query, "obfs", m.str("obfs"))
	if alpn := m.strings("alpn"); len(alpn) > 0 {
		query.Set("alpn", strings.Join(alpn, ","))
	}
	auth := m.str("auth-str")
	if auth == "" {
		auth = m.str("auth_str")
	}
	setQuery(query, "auth", auth)
	setQuery(query, "protocol", m.str("protocol"))
	setQuery(query, "upmbps", m.str("up"))
	setQuery(query, "downmbps", m.str("down"))
	if m.boolean("skip-cert-verify") {
		query.Set("insecure", "1")
	}
	return shareURL("hysteria", nil, m.hostPort(), query, m.str("name"))
}

func hysteria2ShareLink(m shareMapping) string {
	query := url.Values{}
	setQuery(query, "sni", m.str("sni"))
	setQuery(query, "obfs", m.str("obfs"))
	setQuery(query, "obfs-password", m.str("obfs-password"))
	if alpn := m.strings("alpn"); len(alpn) > 0 {
		query.Set("alpn", strings.Join(alpn, ","))
	}
	setQuery(query, "pinSHA256", m.str("fingerprint"))
	setQuery(query, "up", m.str("up"))
	setQuery(query, "down", m.str("down"))
	if m.boolean("skip-cert-verify") {
		query.Set("insecure", "1")
	}
	port := m.str("port")
	if ports := m.str("ports"); ports != "" {
		port = ports
	}
	var user *url.Userinfo
	if password := m.str("password"); password != "" {
		user = url.User(password)
	}
	return shareURL("hysteria2", user, joinShareHost(m.str("server"), port), query, m.str("name"))
}

func tuicShareLink(m shareMapping) string {
	user := url.User(m.str("token"))
	if uuid := m.str("uuid"); uuid != "" {
		user = url.UserPassword(uuid, m.str("password"))
	}
	query := url.Values{}
	setQuery(query, "congestion_control", m.str("congestion-controller"))
	if alpn := m.strings("alpn"); len(alpn) > 0 {
		query.Set("alpn", strings.Join(alpn, ","))
	}
	setQuery(query, "sni", m.str("sni"))
	if m.boolean("disable-sni") {
		query.Set("disable_sni", "1")
	}
	setQuery(query, "udp_relay_mode", m.str("udp-relay-mode"))
	return shareURL("tuic", user, m.hostPort(), query, m.str("name"))
}

func anytlsShareLink(m shareMapping) string {
	query := url.Values{}
	setQuery(query, "sni", m.str("sni"))
	setQuery(query, "hpkp", m.str("fingerprint"))
	if m.boolean("skip-cert-verify") {
		query.Set("insecure", "1")
	}
	return shareURL("anytls", url.User(m.str("password")), m.hostPort(), query, m.str("name"))
}

func socksShareLink(m shareMapping) string {
	scheme := "socks5"
	if m.str("type") == "http" {
		scheme = "http"
		if m.boolean("tls") {
			scheme = "https"
		}
	}
	var user *url.Userinfo
	username, password := m.str("username"), m.str("password")
	if username != "" || password != "" {
		credential := base64.RawStdEncoding.EncodeToString([]byte(username + ":" + password))
		if strings.Contains(credential, "/") {
			return ""
		}
		user = url.User(credential)
	}
	return shareURL(scheme, user, m.hostPort(), url.Values{}, m.str("name"))
}

func mieruShareLink(m shareMapping) string {
	port := m.str("port")
	if port == "" {
		port = m.str("port-range")
	}
	transport := m.str("transport")
	if port == "" || transport == "" {
		return ""
	}
	query := url.Values{}
	query.Set("profile", m.str("name"))
	query.Set("port", port)
	query.Set("protocol", transport)
	setQuery(query, "multiplexing", m.str("multiplexing"))
	setQuery(query, "handshake-mode", m.str("handshake-mode"))
	setQuery(query, "traffic-pattern", m.str("traffic-pattern"))
	user := url.UserPassword(m.str("username"), m.str("password"))
	return shareURL("mierus", user, m.str("server"), query, m.str("name"))
}
