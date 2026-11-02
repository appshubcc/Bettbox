import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/toolbox/mrs_lookup.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _result = MrsLookupResult(
  target: 'telegram.org',
  host: 'telegram.org',
  matches: [
    MrsMatch(
      kind: 'geosite',
      name: 'telegram',
      file: 'geo/geosite/telegram.mrs',
      count: 12,
    ),
  ],
);

Future<String?> _tap(WidgetTester tester, MrsTapAction action) async {
  String? copied;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  globalState.config = Config(
    themeProps: defaultThemeProps,
    appSetting: AppSettingProps(mrsTapAction: action),
  );
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        home: Scaffold(
          body: SingleChildScrollView(child: buildMrsResultForTesting(_result)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(
    find.text('path-in-bundle: "geo/geosite/telegram.mrs"'),
    findsOneWidget,
  );
  await tester.tap(find.text('GEOSITE,telegram'));
  await tester.pump();
  return copied;
}

void main() {
  test('默认点击查看规则列表', () {
    expect(const AppSettingProps().mrsTapAction, MrsTapAction.viewRules);
  });

  testWidgets('选择复制链接时复制 GitHub Raw 链接', (tester) async {
    expect(
      await _tap(tester, MrsTapAction.copyUrl),
      'https://raw.githubusercontent.com/appshubcc/bett-rules/meta/geo/geosite/telegram.mrs',
    );
  });
}
