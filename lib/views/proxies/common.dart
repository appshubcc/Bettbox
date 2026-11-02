import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';

import 'package:flutter/foundation.dart';

class DelayTestCoordinator extends ChangeNotifier {
  String? _testingGroupName;
  int _epoch = 0;

  String? get testingGroupName => _testingGroupName;

  int get epoch => _epoch;

  bool get isTesting => _testingGroupName != null;

  bool isTestingGroup(String groupName) => _testingGroupName == groupName;

  Future<bool> run(String groupName, Future<void> Function() action) async {
    if (isTesting) {
      return false;
    }

    final epoch = _epoch;
    _testingGroupName = groupName;
    notifyListeners();
    try {
      await action();
      return true;
    } finally {
      if (epoch == _epoch) {
        _testingGroupName = null;
        notifyListeners();
      }
    }
  }

  void cancel() {
    _epoch++;
    if (_testingGroupName == null) return;
    _testingGroupName = null;
    notifyListeners();
  }
}

final delayTestCoordinator = DelayTestCoordinator();

@immutable
class DelayTestTarget {
  final String name;
  final String url;

  const DelayTestTarget({required this.name, required this.url});

  @override
  bool operator ==(Object other) {
    return other is DelayTestTarget && other.name == name && other.url == url;
  }

  @override
  int get hashCode => Object.hash(name, url);
}

class DelayTestRequestPool {
  final Map<DelayTestTarget, Future<Delay>> _pendingRequests = {};

  int get pendingCount => _pendingRequests.length;

  Future<Delay>? pendingRequest(DelayTestTarget target) =>
      _pendingRequests[target];

  Future<Delay> run(DelayTestTarget target, Future<Delay> Function() action) {
    final pendingRequest = _pendingRequests[target];
    if (pendingRequest != null) {
      return pendingRequest;
    }

    final request = action();
    _pendingRequests[target] = request;
    return request.whenComplete(() {
      if (identical(_pendingRequests[target], request)) {
        _pendingRequests.remove(target);
      }
    });
  }

  void clear() => _pendingRequests.clear();
}

final _delayTestRequestPool = DelayTestRequestPool();

void cancelDelayTests() {
  delayTestCoordinator.cancel();
  _delayTestRequestPool.clear();
}

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand =>
      baseHeight - measure.bodySmallHeight + measure.labelSmallHeight * 2 + 4,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  if (_isNonTestableProxy(proxy)) return;
  final appController = globalState.appController;
  final state = appController.getProxyCardState(proxy.name);
  final url = appController.getRealTestUrl(
    state.testUrl.getSafeValue(testUrl ?? ''),
  );
  if (state.proxyName.isEmpty) {
    return;
  }
  await _testProxyDelay(DelayTestTarget(name: state.proxyName, url: url));
  appController.addSortNum();
}

Future<Delay> _testProxyDelay(DelayTestTarget target) {
  final epoch = delayTestCoordinator.epoch;
  return _delayTestRequestPool.run(target, () async {
    final appController = globalState.appController;
    appController.setDelay(Delay(url: target.url, name: target.name, value: 0));
    final delay = await clashCore.getDelay(target.url, target.name);
    if (epoch == delayTestCoordinator.epoch) {
      appController.setDelay(delay);
    }
    return delay;
  });
}

class _DelayProgressListener with AppMessageListener {
  final Future<void> Function() onDelayUpdated;

  _DelayProgressListener(this.onDelayUpdated);

  @override
  void onDelays(List<Delay> delays) {
    unawaited(onDelayUpdated());
  }
}

Future<void> _testProxyDelays(
  Iterable<DelayTestTarget> targets, {
  Future<void> Function()? onDelayUpdated,
}) async {
  final appController = globalState.appController;
  final epoch = delayTestCoordinator.epoch;
  final pending = <Future<Delay>>[];
  final batch = <DelayTestTarget>[];
  for (final target in targets) {
    final request = _delayTestRequestPool.pendingRequest(target);
    if (request != null) {
      pending.add(request);
    } else {
      batch.add(target);
    }
  }
  final listener = batch.isNotEmpty && onDelayUpdated != null
      ? _DelayProgressListener(onDelayUpdated)
      : null;
  if (listener != null) clashMessage.addListener(listener);
  try {
    if (batch.isNotEmpty) {
      for (final target in batch) {
        appController.setDelay(
          Delay(url: target.url, name: target.name, value: 0),
        );
      }
      final results = clashCore
          .getDelays([
            for (final target in batch) (name: target.name, url: target.url),
          ], concurrency: globalState.config.proxiesStyle.concurrencyLimit)
          .then(
            (delays) => {
              for (final delay in delays)
                DelayTestTarget(name: delay.name, url: delay.url): delay,
            },
            onError: (Object e) {
              commonPrint.warn('Batch delay test failed: $e');
              return <DelayTestTarget, Delay>{};
            },
          );
      for (final target in batch) {
        pending.add(
          _delayTestRequestPool.run(target, () async {
            final delay =
                (await results)[target] ??
                Delay(name: target.name, url: target.url, value: -1);
            if (epoch == delayTestCoordinator.epoch) {
              appController.setDelay(delay);
            }
            return delay;
          }),
        );
      }
    }
    await Future.wait(pending);
  } finally {
    if (listener != null) clashMessage.removeListener(listener);
  }
  await onDelayUpdated?.call();
}

bool _isNonTestableProxyName(String proxyName) {
  final name = proxyName.toUpperCase();
  return name == 'REJECT' || name == 'REJECT-DROP' || name == 'PASS';
}

bool _isNonTestableProxyType(String proxyType) {
  return proxyType.toUpperCase() == 'REMATCH';
}

bool _isNonTestableProxy(Proxy proxy) {
  return _isNonTestableProxyName(proxy.name) ||
      _isNonTestableProxyType(proxy.type);
}

Future<void> delayTest(
  List<Proxy> proxies, {
  String? testUrl,
  String? groupName,
  Future<void> Function()? onDelayUpdated,
}) async {
  Future<void> runTest() async {
    final appController = globalState.appController;
    final currentGroups = appController.getCurrentGroups();
    final targets = <DelayTestTarget>{};
    for (final proxy in proxies) {
      if (_isNonTestableProxy(proxy)) {
        continue;
      }
      final state = appController.getProxyCardState(proxy.name);
      final url = appController.getRealTestUrl(
        state.testUrl.getSafeValue(testUrl ?? ''),
      );
      final name = state.proxyName;
      if (name.isEmpty ||
          _isNonTestableProxyName(name) ||
          (currentGroups.getGroup(name) == null &&
              currentGroups.getRematchProxy(name) != null)) {
        continue;
      }
      targets.add(DelayTestTarget(name: name, url: url));
    }
    await _testProxyDelays(targets, onDelayUpdated: onDelayUpdated);
    appController.addSortNum();
  }

  if (groupName == null || groupName.isEmpty) {
    await runTest();
    return;
  }
  await delayTestCoordinator.run(groupName, runTest);
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
