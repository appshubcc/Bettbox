import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/app.g.dart';

@riverpod
class RealTunEnable extends _$RealTunEnable with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.realTunEnable;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(realTunEnable: value);
  }
}

@riverpod
class Logs extends _$Logs with AutoDisposeNotifierMixin {
  @override
  FixedList<Log> build() {
    return globalState.appState.logs;
  }

  void addLog(Log value) {
    Future.microtask(() {
      state = state.copyWith()..add(value);
    });
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(logs: value);
  }

  void clearLogs() {
    state = FixedList(maxLength);
  }
}

// Search and filter providers for logs
final logsSearchProvider = StateProvider<String>((ref) => '');
final logsKeywordsProvider = StateProvider<List<String>>((ref) => []);

final filteredLogsProvider = Provider<List<Log>>((ref) {
  final logs = ref.watch(logsProvider.select((s) => s.list));
  final query = ref.watch(logsSearchProvider).toLowerCase();
  final keywords = ref.watch(logsKeywordsProvider);

  return logs.where((item) {
    if (query.isNotEmpty) {
      final matchesQuery = item.payload.toLowerCase().contains(query) ||
          item.logLevel.name.toLowerCase().contains(query) ||
          item.dateTime.toLowerCase().contains(query);
      if (!matchesQuery) return false;
    }
    if (keywords.isNotEmpty) {
      final itemStr = '${item.payload} ${item.logLevel.name} ${item.dateTime}'.toLowerCase();
      final matchesKeywords = keywords.every((keyword) => itemStr.contains(keyword.toLowerCase()));
      if (!matchesKeywords) return false;
    }
    return true;
  }).toList();
});

@riverpod
class Requests extends _$Requests with AutoDisposeNotifierMixin {
  @override
  FixedList<TrackerInfo> build() {
    return globalState.appState.requests;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(requests: value);
  }

  void addRequest(TrackerInfo value) {
    Future.microtask(() {
      state = state.copyWith()..add(value);
    });
  }

  void clearRequests() {
    state = FixedList(maxLength);
  }
}

// Search and filter providers for requests
final requestsSearchProvider = StateProvider<String>((ref) => '');
final requestsKeywordsProvider = StateProvider<List<String>>((ref) => []);

final filteredRequestsProvider = Provider<List<TrackerInfo>>((ref) {
  final requests = ref.watch(requestsProvider.select((s) => s.list));
  final query = ref.watch(requestsSearchProvider).toLowerCase().trim();
  final keywords = ref.watch(requestsKeywordsProvider);

  return requests.where((item) {
    if (query.isNotEmpty) {
      final networkText = item.metadata.network.toLowerCase();
      final hostText = item.metadata.host.toLowerCase();
      final destinationIPText = item.metadata.destinationIP.toLowerCase();
      final processText = item.metadata.process.toLowerCase();
      final chainsText = item.chains.join('').toLowerCase();
      final matchesQuery = networkText.contains(query) ||
          hostText.contains(query) ||
          destinationIPText.contains(query) ||
          processText.contains(query) ||
          chainsText.contains(query);
      if (!matchesQuery) return false;
    }
    if (keywords.isNotEmpty) {
      final chains = item.chains;
      final process = item.metadata.process;
      final matchesKeywords = {...chains, process}.containsAll(keywords);
      if (!matchesKeywords) return false;
    }
    return true;
  }).toList();
});

@riverpod
class Providers extends _$Providers with AutoDisposeNotifierMixin {
  @override
  List<ExternalProvider> build() {
    return globalState.appState.providers;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(providers: value);
  }

  void setProvider(ExternalProvider? provider) {
    if (provider == null) return;
    final index = state.indexWhere((item) => item.name == provider.name);
    if (index == -1) return;
    state = List.from(state)..[index] = provider;
  }
}

@riverpod
class Packages extends _$Packages with AutoDisposeNotifierMixin {
  @override
  List<Package> build() {
    return globalState.appState.packages;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(packages: value);
  }
}

@riverpod
class SystemBrightness extends _$SystemBrightness
    with AutoDisposeNotifierMixin {
  @override
  Brightness build() {
    return globalState.appState.brightness;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(brightness: value);
  }

  void setState(Brightness value) {
    state = value;
  }
}

@riverpod
class Traffics extends _$Traffics with AutoDisposeNotifierMixin {
  @override
  FixedList<Traffic> build() {
    return globalState.appState.traffics;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(traffics: value);
  }

  void addTraffic(Traffic value) {
    state = state.copyWith()..add(value);
  }

  void clear() {
    state = state.copyWith()..clear();
  }
}

@riverpod
class TotalTraffic extends _$TotalTraffic with AutoDisposeNotifierMixin {
  @override
  Traffic build() {
    return globalState.appState.totalTraffic;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(totalTraffic: value);
  }
}

@riverpod
class LocalIp extends _$LocalIp with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return globalState.appState.localIp;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(localIp: value);
  }

  @override
  set state(String? value) {
    super.state = value;
    globalState.appState = globalState.appState.copyWith(localIp: state);
  }
}

@riverpod
class RunTime extends _$RunTime with AutoDisposeNotifierMixin {
  @override
  int? build() {
    return globalState.appState.runTime;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(runTime: value);
  }

  bool get isStart {
    return state != null;
  }
}

@riverpod
class ViewSize extends _$ViewSize with AutoDisposeNotifierMixin {
  @override
  Size build() {
    return globalState.appState.viewSize;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(viewSize: value);
  }

  ViewMode get viewMode => utils.getViewMode(state.width);

  bool get isMobileView => viewMode == ViewMode.mobile;
}

@riverpod
double viewWidth(Ref ref) {
  return ref.watch(viewSizeProvider).width;
}

@riverpod
ViewMode viewMode(Ref ref) {
  if (globalState.isAndroidTV) {
    return ViewMode.mobile;
  }
  return utils.getViewMode(ref.watch(viewWidthProvider));
}

@riverpod
bool isMobileView(Ref ref) {
  if (globalState.isAndroidTV) {
    return true;
  }
  return ref.watch(viewModeProvider) == ViewMode.mobile;
}

@riverpod
double viewHeight(Ref ref) {
  return ref.watch(viewSizeProvider).height;
}

@riverpod
class Init extends _$Init with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.isInit;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(isInit: value);
  }
}

@riverpod
class CurrentPageLabel extends _$CurrentPageLabel
    with AutoDisposeNotifierMixin {
  @override
  PageLabel build() {
    return globalState.appState.pageLabel;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(pageLabel: value);
  }
}

@riverpod
class SortNum extends _$SortNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.sortNum;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(sortNum: value);
  }

  int add() => state++;
}

@riverpod
class CheckIpNum extends _$CheckIpNum with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.checkIpNum;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(checkIpNum: value);
  }

  int add() => state++;
}

@riverpod
class BackBlock extends _$BackBlock with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.backBlock;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(backBlock: value);
  }
}

@riverpod
class Loading extends _$Loading with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.appState.loading;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(loading: value);
  }
}

@riverpod
class Version extends _$Version with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.appState.version;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(version: value);
  }
}

@riverpod
class Groups extends _$Groups with AutoDisposeNotifierMixin {
  @override
  List<Group> build() {
    return globalState.appState.groups;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(groups: value);
  }
}

@riverpod
class DelayDataSource extends _$DelayDataSource with AutoDisposeNotifierMixin {
  @override
  DelayMap build() {
    return globalState.appState.delayMap;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(delayMap: value);
  }

  void setDelay(Delay delay) {
    if (state[delay.url]?[delay.name] != delay.value) {
      final DelayMap newDelayMap = Map.from(state);
      if (newDelayMap[delay.url] == null) {
        newDelayMap[delay.url] = {};
      }
      newDelayMap[delay.url]![delay.name] = delay.value;
      state = newDelayMap;
    }
  }
}

@riverpod
class SystemUiOverlayStyleState extends _$SystemUiOverlayStyleState
    with AutoDisposeNotifierMixin {
  @override
  SystemUiOverlayStyle build() {
    return globalState.appState.systemUiOverlayStyle;
  }

  @override
  onUpdate(value) {
    globalState.appState = globalState.appState.copyWith(
      systemUiOverlayStyle: value,
    );
  }
}

/// Provider to track if VPN was stopped by Smart Auto Stop feature.
/// This is used to show different notification content when smart-stopped.
@Riverpod(keepAlive: true)
class IsSmartStopped extends _$IsSmartStopped {
  @override
  bool build() {
    return false;
  }

  void set(bool value) {
    state = value;
  }
}

// Connections providers
final connectionsProvider = StateProvider<List<TrackerInfo>>((ref) => []);
final connectionsSearchProvider = StateProvider<String>((ref) => '');
final connectionsKeywordsProvider = StateProvider<List<String>>((ref) => []);
final connectionsSortProvider = StateProvider<ConnectionsSortType>((ref) => ConnectionsSortType.creationTime);

final filteredConnectionsProvider = Provider<List<TrackerInfo>>((ref) {
  final connections = ref.watch(connectionsProvider);
  final query = ref.watch(connectionsSearchProvider).toLowerCase().trim();
  final keywords = ref.watch(connectionsKeywordsProvider);

  final filtered = connections.where((item) {
    if (query.isNotEmpty) {
      final networkText = item.metadata.network.toLowerCase();
      final hostText = item.metadata.host.toLowerCase();
      final destinationIPText = item.metadata.destinationIP.toLowerCase();
      final processText = item.metadata.process.toLowerCase();
      final chainsText = item.chains.join('').toLowerCase();
      final matchesQuery = networkText.contains(query) ||
          hostText.contains(query) ||
          destinationIPText.contains(query) ||
          processText.contains(query) ||
          chainsText.contains(query);
      if (!matchesQuery) return false;
    }
    if (keywords.isNotEmpty) {
      final chains = item.chains;
      final process = item.metadata.process;
      final matchesKeywords = {...chains, process}.containsAll(keywords);
      if (!matchesKeywords) return false;
    }
    return true;
  }).toList();

  final sortType = ref.watch(connectionsSortProvider);
  switch (sortType) {
    case ConnectionsSortType.realTimeSpeed:
      filtered.sort((a, b) {
        final aSpeed = (a.uploadSpeed ?? 0) + (a.downloadSpeed ?? 0);
        final bSpeed = (b.uploadSpeed ?? 0) + (b.downloadSpeed ?? 0);
        return bSpeed.compareTo(aSpeed);
      });
      break;
    case ConnectionsSortType.totalTraffic:
      filtered.sort((a, b) {
        final aTraffic = a.upload + a.download;
        final bTraffic = b.upload + b.download;
        return bTraffic.compareTo(aTraffic);
      });
      break;
    case ConnectionsSortType.creationTime:
      filtered.sort((a, b) => b.start.compareTo(a.start));
      break;
    case ConnectionsSortType.defaultSort:
      break;
  }
  return filtered;
});
