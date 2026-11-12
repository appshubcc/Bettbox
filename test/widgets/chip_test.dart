import 'dart:ui' as ui;

import 'package:bett_box/widgets/chip.dart';
import 'package:bett_box/widgets/text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _ReferenceChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final TextStyle? labelStyle;

  const _ReferenceChip({required this.label, this.avatar, this.labelStyle});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: avatar,
      side: WidgetStateBorderSide.resolveWith((_) => null),
      color: WidgetStateProperty.resolveWith((_) => null),
      clipBehavior: Clip.antiAlias,
      labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      onPressed: () {},
      labelStyle: labelStyle,
      label: EmojiText(label),
    );
  }
}

typedef _ChipBuilder = Widget Function(
  String label, {
  Widget? avatar,
  TextStyle? labelStyle,
});

Widget _reference(String label, {Widget? avatar, TextStyle? labelStyle}) =>
    _ReferenceChip(label: label, avatar: avatar, labelStyle: labelStyle);

Widget _candidate(String label, {Widget? avatar, TextStyle? labelStyle}) =>
    CommonChip(
      label: label,
      avatar: avatar,
      labelStyle: labelStyle,
      onPressed: () {},
    );

Widget _gallery(BuildContext context, _ChipBuilder chip) {
  final small = Theme.of(context).textTheme.bodySmall
      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 7,
    children: [
      chip('DIRECT'),
      chip('Proxy', labelStyle: small),
      chip('sync', avatar: const Icon(Icons.sync)),
      SizedBox(
        width: 90,
        child: Wrap(children: [chip('a very long chip label that overflows')]),
      ),
      SizedBox(
        width: 110,
        child: Wrap(
          children: [
            chip(
              'a very long chip label that overflows',
              avatar: const Icon(Icons.upload),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 36,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: [
              chip('one', labelStyle: small),
              chip('two', labelStyle: small),
            ],
          ),
        ),
      ),
    ],
  );
}

Future<(ui.Image, ByteData)> _capture(WidgetTester tester, Key key) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  final image = await boundary.toImage();
  final data = await image.toByteData();
  return (image, data!);
}

void main() {
  for (final brightness in Brightness.values) {
    for (final density in [VisualDensity.standard, VisualDensity.compact]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          '轻量 action chip 与 ActionChip 外观一致 $brightness $density x$scale',
          (tester) async {
            const referenceKey = ValueKey('reference');
            const candidateKey = ValueKey('candidate');
            final colorScheme = ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: brightness,
            );
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(
                  colorScheme: colorScheme,
                  visualDensity: density,
                  chipTheme: ChipThemeData(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: Builder(
                    builder: (context) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RepaintBoundary(
                          key: referenceKey,
                          child: SizedBox(
                            width: 300,
                            height: 400,
                            child: _gallery(context, _reference),
                          ),
                        ),
                        RepaintBoundary(
                          key: candidateKey,
                          child: SizedBox(
                            width: 300,
                            height: 400,
                            child: _gallery(context, _candidate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            final referenceSizes = [
              for (final element in find.byType(ActionChip).evaluate())
                element.size,
            ];
            final candidateSizes = [
              for (final element in find.byType(CommonChip).evaluate())
                element.size,
            ];
            expect(candidateSizes, referenceSizes);

            await tester.runAsync(() async {
              final (referenceImage, reference) = await _capture(
                tester,
                referenceKey,
              );
              final (candidateImage, candidate) = await _capture(
                tester,
                candidateKey,
              );
              expect(candidateImage.width, referenceImage.width);
              expect(candidateImage.height, referenceImage.height);
              var different = 0;
              var maxDelta = 0;
              for (var i = 0; i < reference.lengthInBytes; i++) {
                final delta = (reference.getUint8(i) - candidate.getUint8(i))
                    .abs();
                if (delta > 0) different++;
                if (delta > maxDelta) maxDelta = delta;
              }
              expect(maxDelta, lessThanOrEqualTo(10));
              expect(different, lessThan(2000));
            });
          },
        );
      }
    }
  }

  testWidgets('点击、聚焦与按键触发', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonChip(label: 'chip', onPressed: () => taps++),
        ),
      ),
    );
    await tester.tap(find.byType(CommonChip));
    await tester.pump();
    expect(taps, 1);

    final size = tester.getSize(find.byType(CommonChip));
    Focus.of(tester.element(find.byType(EmojiText))).requestFocus();
    await tester.pump();
    await tester.pump();
    expect(tester.getSize(find.byType(CommonChip)), size + const Offset(2, 2));

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(taps, 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(taps, 3);
  });
}
