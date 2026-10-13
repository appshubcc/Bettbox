// [Gamebox] 面板站点常量。state 注入 TUN 直连规则时也引用这里，避免和 panel_auth 循环依赖。
// 策略：API/订阅一律反代优先；源站（CF）仅作最后兜底。反代机可随时更换 DNS/IP。
const panelSiteBase = 'https://mini.aicn.plus';
const panelApiRelayBase = 'https://wegame.com.api.aicn.plus:1699';
const panelSubRelayBase = 'https://wegame.com.sub.aicn.plus:1688';

String? _hostOf(String base) {
  final host = Uri.tryParse(base)?.host.trim();
  if (host == null || host.isEmpty) return null;
  return host;
}

String? get panelSiteHost => _hostOf(panelSiteBase);

/// 源站 + API 反代 + 订阅反代主机名（TUN DIRECT / fake-ip-filter）。
List<String> panelAllHosts() {
  final hosts = <String>[];
  for (final base in [panelSiteBase, panelApiRelayBase, panelSubRelayBase]) {
    final host = _hostOf(base);
    if (host != null && !hosts.contains(host)) {
      hosts.add(host);
    }
  }
  return hosts;
}

// [Gamebox] TUN 下强制面板相关域名走 DIRECT，心跳/登录/反代不经代理节点。
List<String> panelTunDirectRules() {
  return [for (final host in panelAllHosts()) 'DOMAIN,$host,DIRECT'];
}
