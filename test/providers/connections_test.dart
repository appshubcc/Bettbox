import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TrackerInfo _info(
  String id,
  int startSeconds, {
  int traffic = 0,
  int? speed,
  String host = '',
  String network = '',
}) {
  return TrackerInfo(
    id: id,
    upload: traffic,
    start: DateTime.fromMillisecondsSinceEpoch(startSeconds * 1000),
    uploadSpeed: speed,
    metadata: Metadata(host: host, network: network),
    chains: const [],
    rule: '',
    rulePayload: '',
  );
}

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

  List<String> activeIds() =>
      container.read(filteredConnectionsProvider).map((e) => e.id).toList();

  List<String> allIds() => container
      .read(filteredAllConnectionsProvider)
      .map((e) => '${e.info.id}${e.closed ? '*' : ''}')
      .toList();

  test('只看 UDP 时筛选活动、已关闭与全部', () {
    container.read(connectionsProvider.notifier).state = [
      _info('a', 1, speed: 0, network: 'udp'),
      _info('b', 2, speed: 0, network: 'tcp'),
      _info('c', 3, speed: 0, network: 'udp'),
    ];
    container.read(requestsProvider.notifier).addRequests([
      _info('d', 4, network: 'udp'),
      _info('e', 5, network: 'tcp'),
    ]);
    container.read(connectionsUdpOnlyProvider.notifier).toggle();

    expect(activeIds(), ['c', 'a']);
    expect(container.read(filteredRequestsProvider).map((e) => e.id).toList(), [
      'd',
    ]);
    expect(allIds(), ['d*', 'c', 'a']);

    container.read(connectionsUdpOnlyProvider.notifier).toggle();
    expect(activeIds(), ['c', 'b', 'a']);
  });

  test('已关闭的连接不再出现在活动列表中', () {
    container.read(connectionsProvider.notifier).state = [
      _info('a', 1, speed: 0),
      _info('b', 2, speed: 0),
    ];
    container.read(requestsProvider.notifier).addRequests([_info('a', 1)]);

    expect(activeIds(), ['b']);
    expect(allIds(), ['b', 'a*']);
  });

  test('全部默认按创建时间排列，连接关闭后位置不变', () {
    container.read(connectionsProvider.notifier).state = [
      _info('a', 1, speed: 0),
      _info('b', 2, speed: 0),
      _info('c', 3, speed: 0),
    ];
    expect(allIds(), ['c', 'b', 'a']);

    container.read(requestsProvider.notifier).addRequests([
      _info('c', 3),
      _info('a', 1),
    ]);
    container.read(connectionsProvider.notifier).state = [
      _info('b', 2, speed: 0),
    ];

    expect(allIds(), ['c*', 'b', 'a*']);
  });

  test('按速度排序时同速连接按创建时间稳定排列', () {
    container.read(connectionsSortProvider.notifier).state =
        ConnectionsSortType.realTimeSpeed;
    container.read(connectionsProvider.notifier).state = [
      _info('a', 1, speed: 0),
      _info('b', 2, speed: 50),
      _info('c', 3, speed: 0),
    ];
    container.read(requestsProvider.notifier).addRequests([_info('d', 4)]);

    expect(allIds(), ['b', 'd*', 'c', 'a']);
  });

  test('搜索同时作用于活动与已关闭', () {
    container.read(connectionsProvider.notifier).state = [
      _info('a', 1, speed: 0, host: 'github.com'),
      _info('b', 2, speed: 0, host: 'google.com'),
    ];
    container.read(requestsProvider.notifier).addRequests([
      _info('c', 3, host: 'api.github.com'),
    ]);
    container.read(connectionsSearchProvider.notifier).state = 'github';

    expect(activeIds(), ['a']);
    expect(container.read(filteredRequestsProvider).map((e) => e.id).toList(), [
      'c',
    ]);
    expect(allIds(), ['c*', 'a']);
  });
}
