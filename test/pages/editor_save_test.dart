import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/theme.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../plugins/code_forge/support.dart';

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
    await initEditorNative();
  });

  Future<void> pumpPage(WidgetTester tester, EditorPage page) async {
    globalState.appState = AppState(
      brightness: Brightness.light,
      version: 0,
      viewSize: const Size(800, 600),
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              globalState.theme = CommonTheme.of(context, 1);
              return page;
            },
          ),
        ),
      ),
    );
    await settle(tester);
  }

  final saveButton = find.byWidgetPredicate(
    (widget) => widget is IconButton && widget.tooltip == appLocalizations.save,
  );

  testWidgets('a prefilled template can save its original content', (
    tester,
  ) async {
    final template = meshTemplates.singleWhere(
      (item) => item.title == 'Tailscale',
    );
    final initialContent = await template.load('en');
    final saved = <(String, String)>[];
    await pumpPage(
      tester,
      EditorPage(
        title: template.title,
        content: initialContent,
        allowUnchangedSave: true,
        onSave: (_, title, content) => saved.add((title, content)),
      ),
    );
    await tester.tap(saveButton);
    expect(saved, [(template.title, initialContent)]);
  });

  testWidgets('ordinary editors require changes for both Save and Ctrl+S', (
    tester,
  ) async {
    final saved = <String>[];
    await pumpPage(
      tester,
      EditorPage(
        title: 'Original',
        content: 'name: example',
        titleEditable: true,
        onSave: (_, title, _) => saved.add(title),
      ),
    );
    Future<void> shortcut() async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    }

    final title = find.byType(TextField).first;
    await tester.tap(title);
    await tester.pump();
    expect(tester.widget<IconButton>(saveButton).onPressed, isNull);
    await shortcut();
    expect(saved, isEmpty);

    await tester.enterText(title, 'Renamed');
    await tester.pump();
    expect(tester.widget<IconButton>(saveButton).onPressed, isNotNull);
    await shortcut();
    expect(saved, ['Renamed']);
  });
}
