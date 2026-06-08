import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight - measure.bodySmallHeight + measure.labelSmallHeight * 2 + 4,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final appController = globalState.appController;
  final state = appController.getProxyCardState(proxy.name);
  final url = appController.getRealTestUrl(state.testUrl.getSafeValue(testUrl ?? ''));
  if (state.proxyName.isEmpty) {
    return;
  }
  appController.setDelay(Delay(url: url, name: state.proxyName, value: 0));
  appController.setDelay(await clashCore.getDelay(url, state.proxyName));
}

bool _isNonTestableProxy(String proxyName) {
  final name = proxyName.toUpperCase();
  return name == 'REJECT' || name == 'REJECT-DROP' || name == 'PASS';
}

int _delayTestSessionId = 0;

void cancelDelayTest() {
  _delayTestSessionId++;
}

Future<void> delayTest(
  List<Proxy> proxies, [
  String? testUrl,
  Future<void> Function()? onDelayUpdated,
]) async {
  final sessionId = ++_delayTestSessionId;
  final appController = globalState.appController;
  final proxyNames = proxies
      .map((proxy) => proxy.name)
      .where((name) => !_isNonTestableProxy(name))
      .toSet()
      .toList();
  final concurrencyLimit = globalState.config.proxiesStyle.concurrencyLimit;

  final delayTasks = proxyNames.map((proxyName) {
    return () async {
      final state = appController.getProxyCardState(proxyName);
      final url = appController.getRealTestUrl(
        state.testUrl.getSafeValue(testUrl ?? ''),
      );
      final name = state.proxyName;
      if (name.isEmpty || _isNonTestableProxy(name)) {
        return;
      }
      if (sessionId != _delayTestSessionId) return;
      appController.setDelay(Delay(url: url, name: name, value: 0));
      final delay = await clashCore.getDelay(url, name);
      if (sessionId != _delayTestSessionId) return;
      appController.setDelay(delay);
      await onDelayUpdated?.call();
    };
  }).toList();

  final batchedTasks = delayTasks.batch(concurrencyLimit);
  for (final batchTasks in batchedTasks) {
    if (sessionId != _delayTestSessionId) break;
    await Future.wait(batchTasks.map((task) => task()));
  }
  if (sessionId == _delayTestSessionId) {
    appController.addSortNum();
  }
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final appController = globalState.appController;
  final columns = appController.getProxiesColumns();
  final proxyCardType = globalState.config.proxiesStyle.cardType;
  final selectedProxyName = appController.getSelectedProxyName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedProxyName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
