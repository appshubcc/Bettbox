import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/pages/toolbox/common.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String _focused() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return 'none';
  var name = 'unknown';
  context.visitAncestorElements((element) {
    final key = element.widget.key;
    if (element.widget is KeyedSubtree && key is ValueKey<String>) {
      name = key.value;
      return false;
    }
    return true;
  });
  return name;
}

bool _focusedIsGrid() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<EditableGrid<int>>() != null;
}

Widget _tagged(String name, Widget child) =>
    KeyedSubtree(key: ValueKey(name), child: child);

Future<List<String>> _press(
  WidgetTester tester,
  LogicalKeyboardKey key,
  int times,
) async {
  final visited = <String>[];
  for (var i = 0; i < times; i++) {
    await tester.sendKeyEvent(key);
    await tester.pumpAndSettle();
    visited.add(_focused());
  }
  return visited;
}

void main() {
  setUpAll(() => AppLocalizations.load(const Locale('zh', 'CN')));
  tearDown(() => globalState.isAndroidTV = false);

  Future<TextEditingController> pumpField(
    WidgetTester tester, {
    required String text,
    int? maxLines = 1,
  }) async {
    final controller = TextEditingController(text: text);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              _tagged(
                'above',
                FilledButton(onPressed: () {}, child: const Text('above')),
              ),
              Row(
                children: [
                  Expanded(
                    child: _tagged(
                      'field',
                      ToolTvField(
                        controller: controller,
                        child: TextField(
                          controller: controller,
                          maxLines: maxLines,
                        ),
                      ),
                    ),
                  ),
                  _tagged(
                    'side',
                    IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
                  ),
                ],
              ),
              _tagged(
                'below',
                FilledButton(onPressed: () {}, child: const Text('below')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_focused(), 'above');
    return controller;
  }

  testWidgets('TV 上单行输入框可以用方向键离开', (tester) async {
    globalState.isAndroidTV = true;
    await pumpField(tester, text: 'example.com');
    expect(await _press(tester, LogicalKeyboardKey.arrowDown, 2), [
      'field',
      'below',
    ]);
    expect(await _press(tester, LogicalKeyboardKey.arrowUp, 2), [
      'field',
      'above',
    ]);
    await _press(tester, LogicalKeyboardKey.arrowDown, 1);
    expect(await _press(tester, LogicalKeyboardKey.arrowRight, 1), ['side']);
  });

  testWidgets('TV 上多行输入框先在行间移动，到边界再离开', (tester) async {
    globalState.isAndroidTV = true;
    final controller = await pumpField(
      tester,
      text: 'line1\nline2\nline3',
      maxLines: null,
    );
    await _press(tester, LogicalKeyboardKey.arrowDown, 1);
    controller.selection = const TextSelection.collapsed(offset: 0);
    await tester.pump();
    expect(await _press(tester, LogicalKeyboardKey.arrowDown, 3), [
      'field',
      'field',
      'below',
    ]);
  });

  testWidgets('非 TV 平台保持输入框原有的方向键行为', (tester) async {
    await pumpField(tester, text: 'example.com');
    expect(await _press(tester, LogicalKeyboardKey.arrowDown, 2), [
      'field',
      'field',
    ]);
  });

  testWidgets('TV 上用遥控器可以走完整个工具页', (tester) async {
    globalState.isAndroidTV = true;
    final search = TextEditingController();
    addTearDown(search.dispose);
    var count = 10;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: globalState.navigatorKey,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ToolPageBody(
              bottom: _tagged(
                'start',
                FilledButton(onPressed: () {}, child: const Text('start')),
              ),
              children: [
                _tagged(
                  'segment',
                  ToolSegmented<int>(
                    values: const [1, 2, 3],
                    value: 1,
                    labelOf: (value) => '$value',
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(height: 12),
                _tagged(
                  'search',
                  ToolSearchField(
                    controller: search,
                    hintText: 'target',
                    onSubmitted: (_) {},
                  ),
                ),
                _tagged(
                  'history',
                  ToolHistoryBar(
                    items: const ['a.com', 'b.com'],
                    onSelected: (_) {},
                    onClear: () {},
                  ),
                ),
                for (var i = 0; i < 6; i++) ...[
                  const SizedBox(height: 12),
                  _tagged(
                    'count$i',
                    ToolNumberSegmented(
                      presets: const [5, 10, 50],
                      value: count,
                      title: 'count',
                      min: 1,
                      max: 99,
                      labelOf: (value) => '$value',
                      onChanged: (value) => setState(() => count = value),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_focused(), 'segment');
    final visited = await _press(tester, LogicalKeyboardKey.arrowDown, 9);
    expect(visited, [
      'search',
      'history',
      'count0',
      'count1',
      'count2',
      'count3',
      'count4',
      'count5',
      'start',
    ]);
    expect(await _press(tester, LogicalKeyboardKey.arrowUp, 1), ['count5']);
  });

  testWidgets('TV 上分段选项和编辑中的卡片显示焦点框', (tester) async {
    globalState.isAndroidTV = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ToolSegmented<int>(
                values: const [1, 2],
                value: 1,
                labelOf: (value) => '$value',
                onChanged: (_) {},
              ),
              SizedBox(
                width: 300,
                child: EditableGrid<int>(
                  items: const [1],
                  editing: true,
                  crossAxisCount: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 80,
                  keyOf: (item) => '$item',
                  crossAxisCellCountOf: (_) => 1,
                  canResize: (_) => true,
                  onResize: (_) {},
                  itemBuilder: (_, item) => Text('tile $item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    int rings() => tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (box) =>
              box.position == DecorationPosition.foreground &&
              (box.decoration as BoxDecoration?)?.border != null,
        )
        .length;
    expect(rings(), 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump(const Duration(milliseconds: 300));
    expect(rings(), 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_focusedIsGrid(), isTrue);
    expect(rings(), 1);
    globalState.isAndroidTV = false;
  });
}
