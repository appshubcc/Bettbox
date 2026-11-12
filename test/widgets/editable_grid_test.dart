import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Harness extends StatefulWidget {
  final bool editing;
  final List<String> log;

  const _Harness({required this.editing, required this.log});

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  List<String> items = ['A', 'B', 'C', 'D'];
  final wide = <String>{};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: EditableGrid<String>(
            items: items,
            editing: widget.editing,
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 108,
            keyOf: (item) => item,
            crossAxisCellCountOf: (item) => wide.contains(item) ? 2 : 1,
            mainAxisCellCountOf: (_) => 1,
            itemBuilder: (_, item) => ColoredBox(
              color: Colors.blueGrey,
              child: Center(child: Text(item)),
            ),
            canResize: (item) => item != 'D',
            onResize: (item) {
              widget.log.add('resize $item');
              setState(
                () => wide.contains(item) ? wide.remove(item) : wide.add(item),
              );
            },
            canDelete: (item) => item != 'A',
            onDelete: (item) {
              widget.log.add('delete $item');
              setState(() => items = [...items]..remove(item));
            },
            onMove: (from, to) {
              widget.log.add('move $from>$to');
              setState(() {
                final next = [...items];
                next.insert(
                  next.indexOf(to),
                  next.removeAt(next.indexOf(from)),
                );
                items = next;
              });
            },
            onLongPress: () => widget.log.add('longPress'),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('普通模式长按触发进入编辑', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_Harness(editing: false, log: log));
    await tester.longPress(find.text('B'));
    expect(log, ['longPress']);
    expect(find.byIcon(Icons.open_in_full_rounded), findsNothing);
  });

  testWidgets('编辑模式点按切换尺寸并带过渡、删除角标仅出现在可删除项', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_Harness(editing: true, log: log));
    await tester.pump();
    expect(find.byIcon(Icons.open_in_full_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(3));

    final before = tester.getTopLeft(find.text('C'));
    await tester.tap(find.text('B'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(log, ['resize B']);
    final moving = tester.getTopLeft(find.text('C'));
    await tester.pump(const Duration(milliseconds: 600));
    final after = tester.getTopLeft(find.text('C'));
    expect(after, isNot(before));
    expect(moving, isNot(after));

    await tester.tap(
      find.byIcon(Icons.close_rounded).last,
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(log.last, 'delete D');
    expect(find.text('D'), findsNothing);
  });

  testWidgets('编辑模式拖动到其他卡片上会调整顺序', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_Harness(editing: true, log: log));
    await tester.pump();
    final gesture = await tester.startGesture(tester.getCenter(find.text('A')));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(10, 10));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('D').first));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 600));
    expect(log, contains('move A>D'));
  });

  test('仪表盘组件按组归并并提供可选尺寸', () {
    expect(
      DashboardWidget.networkSpeedSmall.family,
      DashboardWidget.networkSpeed,
    );
    expect(DashboardWidget.outboundMode.family, DashboardWidget.outboundModeV2);
    expect(DashboardWidget.networkSpeed.sizes, [
      DashboardTileSize.small,
      DashboardTileSize.wide,
      DashboardTileSize.tall,
      DashboardTileSize.large,
    ]);
    expect(
      DashboardWidget.networkSpeed.variantFor(DashboardTileSize.small),
      DashboardWidget.networkSpeedSmall,
    );
    expect(
      DashboardWidget.networkSpeed.variantFor(DashboardTileSize.wide),
      DashboardWidget.networkSpeed,
    );
    expect(DashboardWidget.trafficUsage.sizes, [
      DashboardTileSize.tall,
      DashboardTileSize.wide,
    ]);
    expect(DashboardWidget.memoryInfo.resizable, isTrue);
    expect(DashboardWidget.ipv6Switch.resizable, isFalse);
  });

  testWidgets('非编辑模式下宽度缩小时卡片立即更新网格位置无多余动画偏移', (tester) async {
    final log = <String>[];
    double width = 800;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: _Harness(editing: false, log: log),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final bInitial = tester.getTopLeft(find.text('B'));
    expect(bInitial.dx, greaterThan(300));

    width = 300;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: _Harness(editing: false, log: log),
              ),
            ),
          );
        },
      ),
    );
    await tester.pump();
    final bAfterResize = tester.getTopLeft(find.text('B'));
    expect(bAfterResize.dx, closeTo(207.8, 1.0));
  });
}
