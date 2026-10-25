import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/logs.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

var _time = 1760000000000;

Log _log(String payload, {String level = 'info'}) =>
    Log.core({'LogLevel': level, 'Payload': payload, 'time': _time++});

final _rows = find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString() == '_LogRow',
);

Finder _row(String text) => find.ancestor(
  of: find.textContaining(text, findRichText: true),
  matching: _rows,
);

RenderParagraph _paragraph(WidgetTester tester, Finder row) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(of: row, matching: find.byType(RichText)).first,
    );

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<Log> logs,
  bool mobile = true,
  Size size = const Size(360, 720),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [isMobileViewProvider.overrideWith((ref) => mobile)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(body: LogsConsole(onAdjustLevel: () {})),
      ),
    ),
  );
  container.read(logsProvider.notifier).addLogs(logs);
  await tester.pump();
  await tester.pump();
  return container;
}

Config _config(LogLevel level) {
  final config = Config(themeProps: defaultThemeProps);
  return config.copyWith(
    patchClashConfig: config.patchClashConfig.copyWith(logLevel: level),
  );
}

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('zh', 'CN'));
  });

  setUp(() {
    globalState.config = _config(LogLevel.debug);
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
  });

  testWidgets('手机上行高按实际行数取 1 到 3 行，且与渲染结果一致', (tester) async {
    await _pump(
      tester,
      logs: [
        _log('[TCP] ${List.filled(40, 'long').join(' ')}'),
        _log('[DNS] ${List.filled(6, 'mid').join(' ')}'),
        _log('short'),
      ],
    );
    expect(tester.takeException(), isNull);
    final heights = <double>[];
    for (final element in _rows.evaluate()) {
      final row = find.byWidget(element.widget);
      final paragraph = _paragraph(tester, row);
      final height = tester.getSize(row).height;
      expect(height, paragraph.size.height + 16);
      heights.add(height);
    }
    expect(heights, [34, 52, 70]);
    expect(_paragraph(tester, _row('long')).didExceedMaxLines, isTrue);
    expect(_paragraph(tester, _row('mid')).didExceedMaxLines, isFalse);
  });

  testWidgets('点击展开全文，收起后恢复', (tester) async {
    await _pump(
      tester,
      logs: [_log('[TCP] ${List.filled(40, 'long').join(' ')}'), _log('short')],
    );
    final row = _row('long');
    await tester.tap(row);
    await tester.pump();
    expect(tester.takeException(), isNull);

    final paragraph = _paragraph(tester, row);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(paragraph.size.height, greaterThan(54));
    final meta = tester.renderObject<RenderParagraph>(
      find.descendant(of: row, matching: find.byType(RichText)).at(1),
    );
    expect(
      tester.getSize(row).height,
      paragraph.size.height + meta.size.height + 16 + 4 + 40,
    );
    expect(find.text('复制'), findsOneWidget);
    expect(find.text('[ TCP ]'), findsOneWidget);
    expect(find.byTooltip('只看 TCP'), findsOneWidget);
    expect(
      find.textContaining('内核 · TCP · Info', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('收起'));
    await tester.pump();
    expect(tester.getSize(row).height, 70);
    expect(find.text('复制'), findsNothing);
  });

  testWidgets('再次点击展开行即可收起', (tester) async {
    await _pump(tester, logs: [_log('[TCP] a --> b'), _log('short')]);
    final row = _row('a --> b');
    await tester.tap(row);
    await tester.pump();
    expect(find.text('复制'), findsOneWidget);

    await tester.tapAt(tester.getTopLeft(row) + const Offset(60, 14));
    await tester.pump();
    expect(find.text('复制'), findsNothing);
    expect(tester.getSize(row).height, 34);
  });

  testWidgets('没有前缀的日志补上来源标签，并可按来源筛选', (tester) async {
    final container = await _pump(
      tester,
      logs: [_log('[APP] flushed'), _log('load geosite'), _log('[DNS] a')],
    );
    expect(_row('[Core] load geosite'), findsOneWidget);
    expect(_row('[APP] flushed'), findsOneWidget);
    expect(_row('[DNS] a'), findsOneWidget);

    await tester.tap(_row('load geosite'));
    await tester.pump();
    await tester.tap(find.text('[ Core ]'));
    await tester.pump();
    expect(container.read(logsFilterProvider).source, LogSource.core);
    expect(_rows, findsNWidgets(2));
  });

  testWidgets('搜索按当前语言拼出提示词并打开 AI 搜索', (tester) async {
    final urls = <String>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      urls.add('${(call.arguments as Map)['url']}');
      return true;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await _pump(tester, logs: [_log('Geodata Loader mode: memconservative')]);
    await tester.tap(_row('Geodata'));
    await tester.pump();
    await tester.tap(find.text('搜索'));
    await tester.pump();

    final uri = Uri.parse(urls.single);
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/search');
    expect(uri.queryParameters, {
      'q': '分析Bettbox(Mihomo)日志:Geodata Loader mode: memconservative',
      'udm': '50',
    });
  });

  testWidgets('展开时新日志不推动列表，并提示新日志数量', (tester) async {
    final container = await _pump(
      tester,
      logs: [for (var i = 0; i < 80; i++) _log('item-$i.')],
    );
    final row = _row('item-79.');
    await tester.tap(row);
    await tester.pump();
    final top = tester.getTopLeft(row).dy;

    container.read(logsProvider.notifier).addLogs([
      _log('new one'),
      _log('new two'),
      _log('new three'),
    ]);
    await tester.pump();
    await tester.pump();
    expect(tester.getTopLeft(row).dy, top);
    expect(find.text('3 条新日志'), findsOneWidget);
    expect(_row('new three'), findsNothing);

    await tester.tap(find.text('3 条新日志'));
    await tester.pumpAndSettle();
    expect(find.text('3 条新日志'), findsNothing);
    expect(find.text('复制'), findsNothing);
    expect(tester.getTopLeft(_row('new three')).dy, top);
  });

  testWidgets('列表不足一屏时新日志直接可见，不显示提示', (tester) async {
    final container = await _pump(
      tester,
      logs: [_log('first'), _log('second')],
    );
    await tester.tap(_row('first'));
    await tester.pump();

    container.read(logsProvider.notifier).addLogs([_log('new one')]);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(_row('new one'), findsOneWidget);
    expect(find.textContaining('条新日志'), findsNothing);
  });

  testWidgets('离开顶部后新日志到达时保持阅读位置', (tester) async {
    final container = await _pump(
      tester,
      logs: [for (var i = 0; i < 80; i++) _log('item-$i.')],
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    final anchor = find.byKey(
      find.byType(ContinuousListItem).evaluate().first.widget.key!,
    );
    final top = tester.getTopLeft(anchor).dy;

    container.read(logsProvider.notifier).addLogs([
      _log(List.filled(40, 'long').join(' ')),
      _log('tail'),
    ]);
    await tester.pump();
    await tester.pump();
    expect(tester.getTopLeft(anchor).dy, top);
    expect(find.text('2 条新日志'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('2 条新日志'), findsNothing);
  });

  testWidgets('桌面上固定单行并按列对齐', (tester) async {
    await _pump(
      tester,
      mobile: false,
      size: const Size(1000, 700),
      logs: [_log('[TCP] ${List.filled(60, 'long').join(' ')}'), _log('short')],
    );
    expect(tester.takeException(), isNull);
    for (final element in _rows.evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 34);
    }
    expect(find.text('[TCP]'), findsOneWidget);
    expect(find.text('[Core]'), findsOneWidget);

    final row = _row('long');
    await tester.tap(row);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(row).height, greaterThan(34 + 62));
  });

  testWidgets('异常计数胶囊按等级筛选，筛空后可清除', (tester) async {
    final container = await _pump(
      tester,
      logs: [
        _log('[DNS] timeout', level: 'warning'),
        _log('[TCP] dial failed', level: 'error'),
        _log('[TCP] a --> b'),
      ],
    );
    expect(find.text('1'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Error'));
    await tester.pump();
    expect(_rows, findsOneWidget);
    expect(_row('dial failed'), findsOneWidget);

    container.read(logsFilterProvider.notifier).setModule('DNS');
    await tester.pump();
    expect(_rows, findsNothing);
    expect(find.text('没有符合条件的日志'), findsOneWidget);
    expect(find.text('DNS'), findsOneWidget);

    await tester.tap(find.text('清除筛选'));
    await tester.pump();
    expect(_rows, findsNWidgets(3));
  });

  testWidgets('debug 等级下空列表给出提示并可调整等级', (tester) async {
    var adjusted = false;
    globalState.config = globalState.config.copyWith(
      patchClashConfig: globalState.config.patchClashConfig.copyWith(
        logLevel: LogLevel.debug,
      ),
    );
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isMobileViewProvider.overrideWith((ref) => true)],
        child: MaterialApp(
          home: Scaffold(
            body: LogsConsole(onAdjustLevel: () => adjusted = true),
          ),
        ),
      ),
    );
    expect(find.text('暂无日志'), findsOneWidget);
    expect(
      find.textContaining('模式适合网络调试，日常使用建议关闭', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('「 Debug 」'));
    expect(adjusted, isTrue);
  });

  testWidgets('debug 等级时在列表末尾提示适合网络调试', (tester) async {
    globalState.config = globalState.config.copyWith(
      patchClashConfig: globalState.config.patchClashConfig.copyWith(
        logLevel: LogLevel.debug,
      ),
    );
    await _pump(tester, logs: [_log('short')]);
    expect(
      find.textContaining('模式适合网络调试，日常使用建议关闭', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('「 Debug 」'), findsOneWidget);
  });

  testWidgets('非 debug 等级时不显示等级提示', (tester) async {
    globalState.config = _config(LogLevel.error);
    await _pump(tester, logs: [_log('short')]);
    expect(find.textContaining('」'), findsNothing);
    expect(find.textContaining('建议关闭', findRichText: true), findsNothing);
  });

  testWidgets('开启自动滚动后回到顶部并跟随新日志，手动滚动时取消', (tester) async {
    var cancelled = 0;
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [isMobileViewProvider.overrideWith((ref) => true)],
    );
    addTearDown(container.dispose);
    Widget app({required bool autoScroll}) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: LogsConsole(
            onAdjustLevel: () {},
            autoScroll: autoScroll,
            onCancelAutoScroll: () => cancelled++,
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(autoScroll: false));
    container.read(logsProvider.notifier).addLogs([
      for (var i = 0; i < 80; i++) _log('item-$i.'),
    ]);
    await tester.pump();
    await tester.pump();
    final top = tester.getTopLeft(_row('item-79.')).dy;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(cancelled, greaterThan(0));
    expect(_row('item-79.'), findsNothing);

    await tester.pumpWidget(app(autoScroll: true));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(_row('item-79.')).dy, top);

    container.read(logsProvider.notifier).addLogs([_log('fresh')]);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(_row('fresh')).dy, top);
    expect(find.textContaining('条新日志'), findsNothing);
  });

  testWidgets('debug 等级下多出 DNS 标签，并与其他标签互斥', (tester) async {
    final container = await _pump(
      tester,
      logs: [_log('[DNS] a --> 1.1.1.1'), _log('[TCP] x'), _log('[APP] y')],
    );
    final labels = ['全部', '应用', '内核', 'DNS'];
    final xs = [for (final l in labels) tester.getCenter(find.text(l)).dx];
    expect(xs, [...xs]..sort());

    await tester.tap(find.text('DNS'));
    await tester.pumpAndSettle();
    expect(_rows, findsOneWidget);
    expect(find.byTooltip('清除筛选'), findsNothing);

    await tester.tap(find.text('应用'));
    await tester.pumpAndSettle();
    expect(container.read(logsFilterProvider).module, isNull);
    expect(_row('[APP] y'), findsOneWidget);
    expect(_rows, findsOneWidget);
  });

  testWidgets('标签宽度随文字自适应，点击后切换选中项', (tester) async {
    await _pump(tester, logs: [_log('plain'), _log('[APP] y')]);
    Finder segment(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(SegmentButton),
    );
    bool selected(String label) =>
        tester.widget<SegmentButton>(segment(label)).selected;
    expect(
      tester.getSize(segment('DNS')).width,
      isNot(tester.getSize(segment('全部')).width),
    );
    expect(selected('全部'), isTrue);
    expect(selected('DNS'), isFalse);

    await tester.tap(find.text('DNS'));
    await tester.pumpAndSettle();
    expect(selected('全部'), isFalse);
    expect(selected('DNS'), isTrue);
  });

  testWidgets('非 debug 等级下没有 DNS 标签，行用更宽松的排版', (tester) async {
    globalState.config = _config(LogLevel.error);
    await _pump(
      tester,
      logs: [_log('[TCP] ${List.filled(40, 'long').join(' ')}'), _log('ok')],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('DNS'), findsNothing);
    final heights = <double>[];
    for (final element in _rows.evaluate()) {
      final row = find.byWidget(element.widget);
      final paragraph = _paragraph(tester, row);
      expect(paragraph.text.style?.fontSize, 14);
      final height = tester.getSize(row).height;
      expect(height, paragraph.size.height + 24);
      heights.add(height);
    }
    expect(heights, [45, 87]);

    await tester.tap(_row('long'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('拖动过程中新日志到达不会打断手势', (tester) async {
    final container = await _pump(
      tester,
      logs: [for (var i = 0; i < 80; i++) _log('item-$i.')],
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CustomScrollView)),
    );
    await gesture.moveBy(const Offset(0, -30));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pump();
    final anchor = find.byKey(
      find.byType(ContinuousListItem).evaluate().elementAt(12).widget.key!,
    );
    final top = tester.getTopLeft(anchor).dy;

    container.read(logsProvider.notifier).addLogs([_log('a'), _log('b')]);
    await tester.pump();
    await tester.pump();
    expect(tester.getTopLeft(anchor).dy, top);

    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();
    expect(tester.getTopLeft(anchor).dy, top - 40);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('惯性滑动过程中新日志到达不会让列表急停', (tester) async {
    final container = await _pump(
      tester,
      logs: [for (var i = 0; i < 200; i++) _log('item-$i.')],
    );
    final position = Scrollable.of(tester.element(_rows.first)).position;
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -300),
      3000,
    );
    await tester.pump(const Duration(milliseconds: 32));
    expect(position.isScrollingNotifier.value, isTrue);

    container.read(logsProvider.notifier).addLogs([_log('a'), _log('b')]);
    await tester.pump();
    final before = position.pixels;
    await tester.pump(const Duration(milliseconds: 100));
    expect(position.isScrollingNotifier.value, isTrue);
    expect(position.pixels, greaterThan(before + 20));
    expect(find.text('2 条新日志'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('新日志到达时未变化的行不重建', (tester) async {
    final container = await _pump(
      tester,
      logs: [for (var i = 0; i < 5; i++) _log('item-$i.')],
    );
    final before = _rows.evaluate().map((e) => e.widget).toList();
    container.read(logsProvider.notifier).addLogs([_log('fresh')]);
    await tester.pump();
    await tester.pump();
    final after = _rows.evaluate().map((e) => e.widget).toList();
    expect(after.length, before.length + 1);
    for (final widget in before) {
      expect(after.any((item) => identical(item, widget)), isTrue);
    }
  });
}
