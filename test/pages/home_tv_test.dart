import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/home.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() => AppLocalizations.load(const Locale('zh', 'CN')));
  tearDown(() => globalState.isAndroidTV = false);

  testWidgets('电视端遥控器向下移动焦点时卡片不被底部导航栏遮挡', (tester) async {
    globalState.isAndroidTV = true;
    globalState.config = Config(themeProps: defaultThemeProps);
    globalState.appState = AppState(
      brightness: Brightness.dark,
      version: 0,
      viewSize: const Size(960, 540),
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    tester.view.physicalSize = const Size(960, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final nodes = List.generate(12, (index) => FocusNode());
    addTearDown(() {
      for (final node in nodes) {
        node.dispose();
      }
    });
    final items = [
      NavigationItem(
        icon: const Icon(Icons.home),
        label: PageLabel.dashboard,
        builder: (_) => ListView(
          children: [
            for (final (index, node) in nodes.indexed)
              SizedBox(
                height: 80,
                child: InkWell(
                  focusNode: node,
                  onTap: () {},
                  child: Text('item $index'),
                ),
              ),
          ],
        ),
      ),
      for (final label in [
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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentNavigationItemsStateProvider.overrideWith(
            (ref) => NavigationItemsState(value: items),
          ),
          navigationStateProvider.overrideWith(
            (ref) => NavigationState(
              pageLabel: PageLabel.dashboard,
              navigationItems: items,
              viewMode: ViewMode.mobile,
              locale: null,
              currentIndex: 0,
            ),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    final navTop = tester
        .getRect(
          find
              .ancestor(
                of: find.text(PageLabel.proxies.localizedName),
                matching: find.byType(SafeArea),
              )
              .first,
        )
        .top;

    nodes.first.requestFocus();
    await tester.pumpAndSettle();
    for (var i = 1; i < nodes.length; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(nodes[i].hasFocus, isTrue, reason: 'item $i');
      expect(
        nodes[i].rect.bottom,
        lessThanOrEqualTo(navTop),
        reason: 'item $i',
      );
    }
  });
}
