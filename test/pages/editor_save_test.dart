import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/theme.dart';
import 'package:bett_box/controller.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/profiles/nodes.dart';
import 'package:code_forge/code_forge.dart' show CodeForge;
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

  // Cached asset futures belong to the fake-async zone that loaded them.
  setUp(rootBundle.clear);

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
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
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
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

  void testEditor(String description, WidgetTesterCallback callback) {
    testWidgets(description, (tester) async {
      try {
        await callback(tester);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      }
    });
  }

  final saveButton = find.byWidgetPredicate(
    (widget) => widget is IconButton && widget.tooltip == appLocalizations.save,
  );

  testEditor('a prefilled template can save its original content', (
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

  testEditor('ordinary editors require changes for both Save and Ctrl+S', (
    tester,
  ) async {
    final saved = <String>[];
    final saving = Completer<void>();
    await pumpPage(
      tester,
      EditorPage(
        title: 'Original',
        content: 'name: example',
        titleEditable: true,
        onSave: (_, title, _) {
          saved.add(title);
          return saving.future;
        },
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
    await shortcut();
    await tester.pump();
    expect(saved, ['Renamed']);
    expect(tester.widget<IconButton>(saveButton).onPressed, isNull);
    saving.complete();
    await tester.pump();
    expect(tester.widget<IconButton>(saveButton).onPressed, isNotNull);
  });

  for (final cancel in [true, false]) {
    testEditor(
      cancel
          ? 'Back during parsing keeps the picker open after the result arrives'
          : 'repeated launches and saves return one editor result to the picker',
      (tester) async {
        final parser = _DelayedParser();
        globalState.appController = parser;
        await pumpPage(tester, const Scaffold());
        final host = tester.element(find.byType(Scaffold));
        final results = <List<ProxyNode>?>[];
        unawaited(showAddNodeSheet(host).then(results.add));
        await tester.pumpAndSettle();
        final sheet = ModalRoute.of(tester.element(find.byType(AddNodeView)))!;
        final label = AppIdentity.isStandard
            ? meshTemplates.first.title
            : appLocalizations.manualInput;
        final launch = tester
            .widget<ListTile>(find.widgetWithText(ListTile, label))
            .onTap!;
        launch();
        launch();
        await settle(tester, 12);
        expect(find.byType(EditorPage, skipOffstage: false), findsOneWidget);
        if (!AppIdentity.isStandard) {
          tester.widget<CodeForge>(find.byType(CodeForge)).controller.text =
              'name: sample';
          await tester.pump();
        }
        final editor = ModalRoute.of(tester.element(find.byType(EditorPage)))!;
        final editorResults = <Object?>[];
        unawaited(editor.popped.then(editorResults.add));
        final save = tester.widget<IconButton>(saveButton).onPressed!;
        save();
        save();
        expect(parser.calls, 1);
        if (cancel) {
          await tester.binding.handlePopRoute();
          await tester.pump();
          expect(sheet.isCurrent, isTrue);
        }
        const nodes = [
          ProxyNode(id: 'sample', proxy: {'name': 'sample'}),
        ];
        parser.result.complete(nodes);
        await settle(tester, 8);
        if (cancel) {
          expect(editorResults, [null]);
          expect(results, isEmpty);
          expect(sheet.isCurrent, isTrue);
        } else {
          expect(editorResults, [nodes]);
          expect(results, [nodes]);
          expect(ModalRoute.of(host)!.isCurrent, isTrue);
        }
      },
    );
  }
}

class _DelayedParser extends Fake implements AppController {
  final result = Completer<List<ProxyNode>>();
  int calls = 0;

  @override
  Future<T?> safeRun<T>(
    FutureOr<T> Function() action, {
    String? title,
    bool needLoading = false,
    bool silence = true,
  }) async => await action();

  @override
  Future<({List<ProxyNode> nodes, int invalid})> parseNodes(String text) async {
    calls++;
    return (nodes: await result.future, invalid: 0);
  }
}
