import 'package:bett_box/common/common.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/views/icon_sets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _EmptyIconSets extends IconSets {
  @override
  Future<List<IconSet>> build() async => const [];
}

void main() {
  IconSet sampleSet() => IconSet(
    id: builtInIconSetId,
    name: 'Qure Style SVG',
    icons: [
      IconSetIcon(name: 'YouTube.svg', url: routeIconUrl('YouTube.svg')!),
      IconSetIcon(name: 'MissAV.svg', url: routeIconUrl('MissAV.svg')!),
      IconSetIcon(name: 'EHentai.svg', url: routeIconUrl('EHentai.svg')!),
      IconSetIcon(name: 'Pornhub.svg', url: routeIconUrl('Pornhub.svg')!),
    ],
  );

  Future<void> pumpPicker(
    WidgetTester tester, {
    String suggest = '',
    String? selected,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          builtInIconSetProvider.overrideWith((ref) async => sampleSet()),
          iconSetsProvider.overrideWith(_EmptyIconSets.new),
        ],
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          home: Scaffold(
            body: IconPickerBody(
              suggest: suggest,
              selected: selected,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('敏感远程图标默认不在空搜索列表展示，输入搜索词后可匹配展示', (tester) async {
    await pumpPicker(tester);
    expect(find.text('YouTube'), findsOneWidget);
    expect(find.text('MissAV'), findsNothing);
    expect(find.text('EHentai'), findsNothing);
    expect(find.text('Pornhub'), findsNothing);

    await tester.enterText(find.byType(TextField), 'missav');
    await tester.pumpAndSettle();
    expect(find.text('MissAV'), findsOneWidget);
    expect(find.text('YouTube'), findsNothing);

    await tester.enterText(find.byType(TextField), 'eh');
    await tester.pumpAndSettle();
    expect(find.text('EHentai'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'porn');
    await tester.pumpAndSettle();
    expect(find.text('Pornhub'), findsOneWidget);
  });

  testWidgets('敏感远程图标在显式建议或已选中时展示，其余保持隐藏', (tester) async {
    await pumpPicker(tester, suggest: 'Custom|MissAV.svg');
    expect(find.text('MissAV'), findsOneWidget);
    expect(find.text('EHentai'), findsNothing);
    expect(find.text('Pornhub'), findsNothing);

    await pumpPicker(tester, selected: routeIconUrl('Pornhub.svg'));
    expect(find.text('Pornhub'), findsOneWidget);
    expect(find.text('MissAV'), findsNothing);
    expect(find.text('EHentai'), findsNothing);
  });
}
