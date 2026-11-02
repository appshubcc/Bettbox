import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/widgets/google_bottom_nav_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAppSetting extends AppSetting {
  @override
  AppSettingProps build() => const AppSettingProps();
}

class _FakeThemeSetting extends ThemeSetting {
  @override
  ThemeProps build() => const ThemeProps();
}

const _barY = 758.0;
const _slotWidth = 91.0;
const _firstCenterX = 63.5;

double _slotCenterX(num slot) => _firstCenterX + slot * _slotWidth;

List<NavigationItem> _items() => [
  for (final label in [
    PageLabel.dashboard,
    PageLabel.proxies,
    PageLabel.profiles,
    PageLabel.tools,
  ])
    NavigationItem(
      icon: const Icon(Icons.circle),
      label: label,
      builder: (_) => const SizedBox(),
    ),
];

Future<void> _pumpBar(
  WidgetTester tester, {
  required int selectedIndex,
  required ValueChanged<int> onTabChange,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingProvider.overrideWith(_FakeAppSetting.new),
        themeSettingProvider.overrideWith(_FakeThemeSetting.new),
      ],
      child: MaterialApp(
        home: Material(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GoogleBottomNavBar(
                  navigationItems: _items(),
                  selectedIndex: selectedIndex,
                  onTabChange: onTabChange,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _pillCenterX(WidgetTester tester) {
  final finder = find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is NavBarPillPainter,
  );
  final painter = tester.widget<CustomPaint>(finder).painter;
  final rect = tester.getRect(finder);
  if (painter is! NavBarPillPainter) return double.nan;
  return rect.left + painter.pillRect(rect.size).center.dx;
}

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('zh', 'CN'));
  });

  testWidgets('拖拽期间指示块 1:1 跟手，往返经过起点没有死区', (tester) async {
    await _pumpBar(tester, selectedIndex: 2, onTabChange: (_) {});

    final gesture = await tester.startGesture(Offset(_slotCenterX(2), _barY));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_pillCenterX(tester), closeTo(_slotCenterX(2), 0.5));

    var fingerX = _slotCenterX(2);
    final steps = <double>[
      for (var i = 0; i < 20; i++) -3.0,
      for (var i = 0; i < 33; i++) 3.0,
    ];
    double? previousPill;
    var dragStartedAt = -1;
    for (var i = 0; i < steps.length; i++) {
      fingerX += steps[i];
      await gesture.moveTo(Offset(fingerX, _barY));
      await tester.pump(const Duration(milliseconds: 16));
      final pill = _pillCenterX(tester);
      if (dragStartedAt < 0 && (pill - _slotCenterX(2)).abs() > 0.5) {
        dragStartedAt = i;
      }
      if (dragStartedAt >= 0) {
        expect(pill, closeTo(fingerX, 0.5), reason: 'step $i');
        if (previousPill != null) {
          expect((pill - previousPill).abs(), greaterThan(2.5));
        }
      }
      previousPill = pill;
    }
    expect(dragStartedAt, inInclusiveRange(0, 2));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('到达最左格时不会撞墙，越界为渐进阻尼', (tester) async {
    int? changedTo;
    await _pumpBar(
      tester,
      selectedIndex: 3,
      onTabChange: (index) => changedTo = index,
    );

    var fingerX = _slotCenterX(3);
    final gesture = await tester.startGesture(Offset(fingerX, _barY));
    await tester.pump(const Duration(milliseconds: 200));

    final deltas = <double>[];
    double? previousPill;
    while (fingerX > _slotCenterX(3) - 3.3 * _slotWidth) {
      fingerX -= 1.0;
      await gesture.moveTo(Offset(fingerX, _barY));
      await tester.pump(const Duration(milliseconds: 8));
      final pill = _pillCenterX(tester);
      if (previousPill != null) {
        final slot = (pill - _firstCenterX) / _slotWidth;
        if (slot > -0.03 && slot < 0.05) deltas.add(previousPill - pill);
      }
      previousPill = pill;
    }

    expect(deltas, isNotEmpty);
    for (final delta in deltas) {
      expect(delta, greaterThan(0.8));
    }
    expect(_pillCenterX(tester), lessThan(_firstCenterX));
    expect(
      _pillCenterX(tester),
      greaterThan(_firstCenterX - 0.23 * _slotWidth),
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(changedTo, 0);
    expect(_pillCenterX(tester), closeTo(_firstCenterX, 0.5));
  });

  testWidgets('点击屏幕左右边距命中首尾按钮', (tester) async {
    final changes = <int>[];
    await _pumpBar(tester, selectedIndex: 2, onTabChange: changes.add);

    await tester.tapAt(const Offset(5, _barY));
    await tester.pumpAndSettle();
    expect(changes, [0]);

    await tester.tapAt(const Offset(395, _barY));
    await tester.pumpAndSettle();
    expect(changes, [0, 3]);
  });

  testWidgets('跨多格点击时抬手不重启滑行，并立即切换页面', (tester) async {
    final changes = <int>[];
    await _pumpBar(tester, selectedIndex: 0, onTabChange: changes.add);

    final gesture = await tester.startGesture(Offset(_slotCenterX(3), _barY));
    await tester.pump();
    final steps = <double>[];
    var previous = _pillCenterX(tester);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final current = _pillCenterX(tester);
      steps.add(current - previous);
      previous = current;
    }
    await gesture.up();
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final current = _pillCenterX(tester);
      steps.add(current - previous);
      previous = current;
    }

    expect(changes, [3]);
    for (var i = 1; i < steps.length; i++) {
      expect(steps[i], greaterThan(0), reason: 'step $i');
      expect(steps[i], lessThan(steps[i - 1]), reason: 'step $i');
    }

    await tester.pumpAndSettle();
    expect(changes, [3]);
    expect(_pillCenterX(tester), closeTo(_slotCenterX(3), 0.5));
  });

  testWidgets('按下非当前格后立即拖动，指示块不会与手指错位', (tester) async {
    await _pumpBar(tester, selectedIndex: 0, onTabChange: (_) {});

    var fingerX = _slotCenterX(3);
    final gesture = await tester.startGesture(Offset(fingerX, _barY));
    await tester.pump(const Duration(milliseconds: 20));
    fingerX -= 12;
    await gesture.moveTo(Offset(fingerX, _barY));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_pillCenterX(tester), closeTo(fingerX, 0.5));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('跨项点击时中间项不产生缩放跳动', (tester) async {
    await _pumpBar(tester, selectedIndex: 0, onTabChange: (_) {});

    await tester.tapAt(Offset(_slotCenterX(3), _barY));
    await tester.pump();

    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final transforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .toList();
      if (transforms.length >= 4) {
        final scale1 = transforms[1].transform.storage[0];
        final scale2 = transforms[2].transform.storage[0];
        expect(scale1, closeTo(1.0, 0.001));
        expect(scale2, closeTo(1.0, 0.001));
      }
    }

    await tester.pumpAndSettle();
  });

  testWidgets('相邻点击时正常产生缩放连续过渡', (tester) async {
    await _pumpBar(tester, selectedIndex: 0, onTabChange: (_) {});

    await tester.tapAt(Offset(_slotCenterX(1), _barY));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final transforms = tester
        .widgetList<Transform>(find.byType(Transform))
        .toList();
    if (transforms.length >= 2) {
      final scale1 = transforms[1].transform.storage[0];
      expect(scale1, greaterThan(1.0));
    }

    await tester.pumpAndSettle();
  });
}
