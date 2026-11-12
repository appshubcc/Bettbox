import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Log _core(String payload, {String level = 'info', int? time}) =>
    Log.core({'LogLevel': level, 'Payload': payload, 'time': ?time});

void main() {
  group('Log.core', () {
    test('提取模块并剥离前缀', () {
      final log = _core('[DNS] resolve example.com', level: 'warning');
      expect(log.module, 'DNS');
      expect(log.payload, 'resolve example.com');
      expect(log.source, LogSource.core);
      expect(log.logLevel, LogLevel.warning);
      expect(log.raw, '[DNS] resolve example.com');
    });

    test('模块名允许空格', () {
      final log = _core('[Metadata PreHandle] error: x');
      expect(log.module, 'Metadata PreHandle');
      expect(log.payload, 'error: x');
    });

    test('方括号里是整句话时不当作模块', () {
      for (final payload in [
        '[Update padding succeed] abc',
        '[Alert from server] abc',
        '[https://dns.example/dns-query] using HTTP/3',
      ]) {
        final log = _core(payload);
        expect(log.module, isNull, reason: payload);
        expect(log.payload, payload);
      }
      expect(_core('[DNS Server] x').module, 'DNS Server');
      expect(_core('[ShadowTLS] x').module, 'ShadowTLS');
    });

    test('非字母开头的方括号不当作模块', () {
      for (final payload in [
        '[0]abc',
        '[::1]:53 listen',
        '[2001:db8::1]:443',
      ]) {
        final log = _core(payload);
        expect(log.module, isNull, reason: payload);
        expect(log.payload, payload);
      }
    });

    test('去掉正文末尾的换行与空白', () {
      expect(
        _core('[Update padding succeed] ae30\n').payload,
        endsWith('ae30'),
      );
      expect(_core('[DNS] a \n').payload, 'a');
      expect(Log.app('done\n').payload, 'done');
    });

    test('无前缀时保持原样', () {
      final log = _core('load geosite.dat success');
      expect(log.module, isNull);
      expect(log.tag, 'Core');
      expect(log.raw, 'load geosite.dat success');
    });

    test('宿主的 APP 日志归入应用来源', () {
      final log = _core('[APP] FakeIP pool flushed');
      expect(log.source, LogSource.app);
      expect(log.module, isNull);
      expect(log.tag, 'APP');
      expect(log.payload, 'FakeIP pool flushed');
    });

    test('使用宿主下发的毫秒时间戳', () {
      final log = _core('x', time: 1760000000123);
      expect(log.time.millisecondsSinceEpoch, 1760000000123);
    });

    test('缺少时间戳时回退到当前时间', () {
      final before = DateTime.now();
      final log = _core('x');
      expect(log.time.isBefore(before), isFalse);
    });

    test('同一条日志从流和历史解析后相等', () {
      expect(
        _core('[TCP] a --> b', time: 1760000000123),
        _core('[TCP] a --> b', time: 1760000000123),
      );
    });
  });

  test('Log.app 带来源与等级', () {
    final log = Log.app('Failed to parse', level: LogLevel.error);
    expect(log.source, LogSource.app);
    expect(log.logLevel, LogLevel.error);
    expect(log.tag, 'APP');
  });

  test('导出行包含毫秒时间、等级与来源', () {
    final time = DateTime(2026, 10, 11, 14, 32, 1, 884);
    final log = Log(
      logLevel: LogLevel.warning,
      payload: 'timeout',
      time: time,
      module: 'DNS',
    );
    expect(log.line, '2026-10-11 14:32:01.884 [warning] [core/DNS] timeout');
    expect(
      Log.app('ready').copyWith(time: time).line,
      '2026-10-11 14:32:01.884 [info] [app] ready',
    );
  });

  group('LogsFilterState.apply', () {
    final logs = [
      _core('[DNS] resolve a error', level: 'warning'),
      _core('[DNS] resolve b', level: 'debug'),
      _core('[TCP] dial error', level: 'error'),
      _core('[TCP] a --> b mentions error'),
      Log.app('Failed', level: LogLevel.error),
      Log.app('ready'),
    ];

    test('默认不过滤并统计异常数量', () {
      final result = const LogsFilterState().apply(logs);
      expect(result.logs, logs);
      expect(result.errors, 2);
      expect(result.warnings, 1);
    });

    test('等级筛选不会命中正文里的 error', () {
      final result = const LogsFilterState(levels: {LogLevel.error})
          .apply(logs);
      expect(result.logs.map((log) => log.payload), ['dial error', 'Failed']);
    });

    test('计数不受等级筛选影响', () {
      final result = const LogsFilterState(levels: {LogLevel.warning})
          .apply(logs);
      expect(result.logs.length, 1);
      expect(result.errors, 2);
      expect(result.warnings, 1);
    });

    test('计数跟随来源、模块与搜索', () {
      final bySource = const LogsFilterState(source: LogSource.app).apply(logs);
      expect(bySource.logs.length, 2);
      expect((bySource.errors, bySource.warnings), (1, 0));

      final byModule = const LogsFilterState(module: 'DNS').apply(logs);
      expect(byModule.logs.length, 2);
      expect((byModule.errors, byModule.warnings), (0, 1));

      final byQuery = const LogsFilterState(query: 'DIAL').apply(logs);
      expect(byQuery.logs.single.payload, 'dial error');
      expect((byQuery.errors, byQuery.warnings), (1, 0));
    });

    test('搜索可以匹配模块前缀', () {
      final result = const LogsFilterState(query: '[tcp]').apply(logs);
      expect(result.logs.length, 2);
    });

    test('hasFacet 不包含搜索词', () {
      expect(const LogsFilterState(query: 'a').hasFacet, isFalse);
      expect(const LogsFilterState(module: 'DNS').hasFacet, isTrue);
    });
  });
}
