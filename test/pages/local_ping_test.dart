import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/toolbox/local_ping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() => AppLocalizations.load(const Locale('zh', 'CN')));

  const replies = [
    LocalPingReply(
      seq: 1,
      status: LocalPingStatus.ok,
      rtt: 10,
      ttl: 51,
      bytes: 56,
    ),
    LocalPingReply(seq: 2, status: LocalPingStatus.timeout),
    LocalPingReply(
      seq: 3,
      status: LocalPingStatus.ok,
      rtt: 14,
      ttl: 52,
      bytes: 56,
    ),
    LocalPingReply(seq: 4, status: LocalPingStatus.closed, rtt: 12),
  ];

  test('统计最短、最长、平均、抖动与丢包', () {
    final stats = LocalPingStats.of(5, replies);
    expect(stats.sent, 5);
    expect(stats.completed, 4);
    expect(stats.received, 3);
    expect(stats.lost, 1);
    expect(stats.loss, 0.25);
    expect(stats.min, 10);
    expect(stats.max, 14);
    expect(stats.avg, 12);
    expect(stats.jitter, 3);
    expect(stats.ttl, 52);
    final empty = LocalPingStats.of(2, const [
      LocalPingReply(seq: 1, status: LocalPingStatus.timeout),
    ]);
    expect(empty.avg, isNull);
    expect(empty.loss, 1);
  });

  test('解析内核推送的状态', () {
    final state = LocalPingState.fromJson({
      'session': 2,
      'phase': 'running',
      'target': 'example.com',
      'address': '93.184.216.34',
      'protocol': 'tcp',
      'port': 443,
      'count': 10,
      'interval': 1000,
      'sent': 3,
      'reply': {
        'seq': 3,
        'status': 'closed',
        'rtt': 21.5,
        'ttl': 0,
        'bytes': 0,
      },
      'error': '',
    });
    expect(state.protocol, LocalPingProtocol.tcp);
    expect(state.reply?.status, LocalPingStatus.closed);
    expect(state.reply?.reachable, isTrue);
    expect(
      LocalPingReply.fromJson({'status': 'weird'}).status,
      LocalPingStatus.error,
    );
  });

  test('参数与报告', () {
    const tcp = LocalPingOptions(protocol: LocalPingProtocol.tcp, tcpPort: 80);
    expect(tcp.port, 80);
    expect(tcp.usesSize, isFalse);
    expect(
      const LocalPingOptions(protocol: LocalPingProtocol.udp).usesSize,
      isFalse,
    );
    expect(
      const LocalPingOptions(
        protocol: LocalPingProtocol.udp,
        udpPort: 5000,
      ).usesSize,
      isTrue,
    );
    expect(const LocalPingOptions().port, 0);

    const state = LocalPingState(
      phase: LocalPingPhase.done,
      target: 'dns.local',
      address: '192.168.1.1',
      size: 56,
      sent: 4,
    );
    final report = localPingReport(state, replies).split('\n');
    expect(report.first, 'Ping dns.local (192.168.1.1) · ICMP · 56 字节');
    expect(report[1], '#1 来自 192.168.1.1 · 10.0 ms · TTL 51 · 56 字节');
    expect(report[2], '#2 请求超时');
    expect(report[4], '#4 来自 192.168.1.1 · 端口关闭 · 12.0 ms');
    expect(report, contains('已发送 4，已接收 3，丢失 1（25.0% 丢失）'));
    expect(report.last, '往返时间：最短 10.0 / 平均 12.0 / 最长 14.0 / 抖动 3.0 ms');
    expect(localPingErrorText('denied'), appLocalizations.localPingErrorDenied);
    expect(formatPingMillis(0.256), '0.26');
    expect(formatPingMillis(123.4), '123');
  });

  testWidgets('结果卡片与快捷目标', (tester) async {
    final controller = TextEditingController(text: '192.168.1.1');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: buildLocalPingPreviewForTesting(
              controller: controller,
              state: const LocalPingState(
                phase: LocalPingPhase.done,
                target: '192.168.1.1',
                address: '192.168.1.1',
                size: 56,
                count: 4,
                sent: 4,
              ),
              replies: replies,
              network: const NetworkInfo(
                gateway: '192.168.1.1',
                dns: ['fe80::1', '223.5.5.5', '223.5.5.5'],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('网关 192.168.1.1'), findsOneWidget);
    expect(find.text('DNS 223.5.5.5'), findsOneWidget);
    expect(find.text('DNS fe80::1'), findsOneWidget);
    expect(find.text('Ping 完成'), findsOneWidget);
    expect(find.text('4 / 4'), findsOneWidget);
    expect(find.text('12.0'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('14.0 ms · TTL 52 · 56 字节'), findsOneWidget);
    expect(find.byType(LocalPingChart), findsOneWidget);
  });
}
