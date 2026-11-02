import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Log _core(String payload, int time) =>
    Log.core({'LogLevel': 'info', 'Payload': payload, 'time': time});

Log _app(String payload, int time) =>
    Log.app(payload).copyWith(time: DateTime.fromMillisecondsSinceEpoch(time));

void main() {
  late ProviderContainer container;

  setUp(() {
    globalState.appState = AppState(
      brightness: Brightness.light,
      version: 0,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  List<String> payloads() =>
      container.read(logsProvider).list.map((log) => log.payload).toList();

  group('Logs.mergeHistory', () {
    test('保留应用日志并按时间与内核历史合并', () {
      final notifier = container.read(logsProvider.notifier);
      notifier.addLogs([_app('app-1', 100), _core('core-old', 150)]);
      notifier.addLogs([_app('app-2', 300)]);

      notifier.mergeHistory([_core('core-a', 50), _core('core-b', 200)]);

      expect(payloads(), ['core-a', 'app-1', 'core-b', 'app-2']);
    });

    test('宿主 APP 日志在流与历史中重复时只保留一条', () {
      final notifier = container.read(logsProvider.notifier);
      notifier.addLogs([_core('[APP] flushed', 100)]);

      notifier.mergeHistory([_core('[APP] flushed', 100), _core('x', 200)]);

      expect(payloads(), ['flushed', 'x']);
    });

    test('超出上限时丢弃最旧的日志', () {
      final notifier = container.read(logsProvider.notifier);
      notifier.addLogs([_app('app', maxLogLength + 10)]);

      notifier.mergeHistory([
        for (var i = 0; i < maxLogLength; i++) _core('core-$i', i),
      ]);

      final list = container.read(logsProvider).list;
      expect(list.length, maxLogLength);
      expect(list.first.payload, 'core-1');
      expect(list.last.payload, 'app');
    });
  });

  group('LogsFilter', () {
    test('toggleLevel 切换等级集合', () {
      final notifier = container.read(logsFilterProvider.notifier);
      notifier.toggleLevel(LogLevel.error);
      notifier.toggleLevel(LogLevel.warning);
      expect(container.read(logsFilterProvider).levels, {
        LogLevel.error,
        LogLevel.warning,
      });
      notifier.toggleLevel(LogLevel.error);
      expect(container.read(logsFilterProvider).levels, {LogLevel.warning});
    });

    test('clearFacets 保留搜索词', () {
      final notifier = container.read(logsFilterProvider.notifier);
      notifier.setQuery('dns');
      notifier.setSource(LogSource.app);
      notifier.setModule('DNS');
      notifier.clearFacets();
      expect(
        container.read(logsFilterProvider),
        const LogsFilterState(query: 'dns'),
      );
    });

    test('filteredLogsProvider 随过滤条件更新', () {
      container.read(logsProvider.notifier).addLogs([
        _core('[DNS] a', 1),
        _app('b', 2),
      ]);
      final sub = container.listen(filteredLogsProvider, (_, _) {});
      addTearDown(sub.close);
      container.listen(logsFilterProvider, (_, _) {});
      expect(sub.read().logs.length, 2);

      container.read(logsFilterProvider.notifier).setSource(LogSource.core);
      expect(sub.read().logs.single.module, 'DNS');
    });
  });
}
