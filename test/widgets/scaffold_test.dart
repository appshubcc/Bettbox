import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/scaffold.dart';
import 'package:bett_box/widgets/slide_pages.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _list() {
  return ListView.builder(
    itemCount: 100,
    itemExtent: 48,
    itemBuilder: (_, index) => Text('item $index'),
  );
}

Widget _buildApp({
  required Widget body,
  bool mobile = true,
  bool scrollEdgeFade = true,
}) {
  return ProviderScope(
    overrides: [isMobileViewProvider.overrideWith((ref) => mobile)],
    child: MaterialApp(
      home: CommonScaffold(
        title: 'title',
        scrollEdgeFade: scrollEdgeFade,
        body: body,
      ),
    ),
  );
}

Finder _overlay() {
  return find.descendant(
    of: find.byType(CommonScaffold),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient is LinearGradient,
    ),
  );
}

bool _hasMaskLayer(WidgetTester tester) {
  bool visit(Layer? layer) {
    if (layer == null) return false;
    if (layer is ShaderMaskLayer) return true;
    if (layer is! ContainerLayer) return false;
    for (
      var child = layer.firstChild;
      child != null;
      child = child.nextSibling
    ) {
      if (visit(child)) return true;
    }
    return false;
  }

  return visit(tester.binding.renderViews.first.debugLayer);
}

void main() {
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
  });

  testWidgets('纯色背景下只在内容滚离顶部时叠加渐隐，且不改变布局', (tester) async {
    await tester.pumpWidget(_buildApp(body: _list()));
    await tester.pumpAndSettle();
    final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    expect(tester.getTopLeft(find.byType(ListView)).dy, appBarBottom);
    expect(_overlay(), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_overlay(), findsOneWidget);
    expect(tester.getTopLeft(_overlay()).dy, appBarBottom);
    expect(tester.getSize(_overlay()).height, 24);
    expect(_hasMaskLayer(tester), isFalse);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(_overlay(), findsNothing);
  });

  testWidgets('透明背景下改用内容遮罩，回到顶部后不保留图层', (tester) async {
    await tester.pumpWidget(_buildApp(body: _list(), mobile: false));
    await tester.pumpAndSettle();
    expect(_hasMaskLayer(tester), isFalse);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_overlay(), findsNothing);
    expect(_hasMaskLayer(tester), isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(_hasMaskLayer(tester), isFalse);
  });

  testWidgets('滚动区域上方有固定内容或嵌套在其他滚动里时不渐隐', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        body: Column(
          children: [
            const SizedBox(height: 40, child: Text('header')),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_overlay(), findsNothing);

    await tester.pumpWidget(_buildApp(body: PageView(children: [_list()])));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_overlay(), findsNothing);
  });

  testWidgets('左右切换页面里的列表照常渐隐', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        body: SlidePages(
          index: 0,
          onChanged: (_) {},
          children: [_list(), const SizedBox()],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_overlay(), findsOneWidget);
  });

  testWidgets('接入上移的列表静止位置不变，渐隐整体上移且高度不变', (tester) async {
    Widget risen() {
      return ScrollEdgeRise(
        builder: (_, rise) => ListView.builder(
          padding: EdgeInsets.only(top: 8 + rise),
          itemCount: 100,
          itemExtent: 48,
          itemBuilder: (_, index) => Text('item $index'),
        ),
      );
    }

    await tester.pumpWidget(
      _buildApp(
        body: ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: 100,
          itemExtent: 48,
          itemBuilder: (_, index) => Text('item $index'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    final plainTop = tester.getTopLeft(find.text('item 0')).dy;

    await tester.pumpWidget(_buildApp(body: risen()));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('item 0')).dy, plainTop);
    expect(
      tester.getTopLeft(find.byType(ListView)).dy,
      appBarBottom - ScrollEdgeRise.extent,
    );
    expect(tester.getBottomLeft(find.byType(ListView)).dy, 600);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(_overlay()).dy,
      appBarBottom - ScrollEdgeRise.extent,
    );
    expect(tester.getSize(_overlay()).height, 24);
  });

  testWidgets('上移只对占满页面的滚动区域生效', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        body: Column(
          children: [
            const SizedBox(height: 40, child: Text('header')),
            Expanded(
              child: ScrollEdgeRise(
                builder: (_, rise) => ListView(
                  padding: EdgeInsets.only(top: rise),
                  children: const [Text('item')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byType(ListView)).dy,
      tester.getBottomLeft(find.byType(AppBar)).dy + 40,
    );
    expect(
      tester.getTopLeft(find.text('item')).dy,
      tester.getTopLeft(find.byType(ListView)).dy,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollEdgeRise(builder: (_, rise) => Text('rise $rise')),
      ),
    );
    expect(find.text('rise 0.0'), findsOneWidget);
  });

  testWidgets('关闭后滚动不产生渐隐', (tester) async {
    await tester.pumpWidget(_buildApp(body: _list(), scrollEdgeFade: false));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_overlay(), findsNothing);
    expect(_hasMaskLayer(tester), isFalse);
  });

  testWidgets('键盘升起改变高度时不重建内容，依赖或父级变化时才重建', (tester) async {
    addTearDown(tester.view.reset);
    var builds = 0;
    var label = 'a';
    late StateSetter rebuild;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (_, setState) {
          rebuild = setState;
          return _buildApp(
            body: ScrollEdgeRise(
              builder: (context, rise) {
                builds++;
                return ListView(
                  padding: EdgeInsets.only(
                    top: 8 + rise,
                    bottom: MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [Text(label)],
                );
              },
            ),
          );
        },
      ),
    );
    await tester.pump();
    final initial = builds;
    final height = tester.getSize(find.byType(ListView)).height;

    for (var i = 1; i <= 5; i++) {
      tester.view.viewInsets = FakeViewPadding(bottom: 60.0 * i);
      await tester.pump();
    }
    expect(builds, initial);
    expect(tester.getSize(find.byType(ListView)).height, lessThan(height - 90));

    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.padding = const FakeViewPadding(bottom: 24);
    await tester.pump();
    expect(builds, initial + 1);

    rebuild(() => label = 'b');
    await tester.pump();
    expect(builds, initial + 2);
    expect(find.text('b'), findsOneWidget);
  });
}
