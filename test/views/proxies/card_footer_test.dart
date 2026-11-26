import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/card.dart';
import 'package:bett_box/views/proxies/unlock_tags.dart';
import 'package:bett_box/widgets/sheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() {
    globalState.appState = AppState(
      brightness: Brightness.light,
      version: 0,
      viewSize: const Size(400, 800),
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    globalState.config = Config(themeProps: defaultThemeProps);
  });

  testWidgets('settings use aligned rows and apply changes on save', (
    tester,
  ) async {
    globalState.appState = globalState.appState.copyWith(
      viewSize: const Size(1000, 800),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [AppLocalizations.delegate],
          home: const Scaffold(body: ProxyUnlockTagsSetting()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final title = appLocalizations.proxyUnlockTags;
    final sheet = find.byType(AdaptiveSheetScaffold);
    final back = find.byType(BackButton);
    final save = find.byTooltip(appLocalizations.save);
    Finder option(String label) => find.descendant(
      of: sheet,
      matching: find.widgetWithText(ListTile, label),
    );
    Finder toggle(Finder tile) =>
        find.descendant(of: tile, matching: find.byType(Switch));

    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    expect(tester.getCenter(back).dx, lessThan(tester.getCenter(save).dx));
    final master = option(title);
    final claude = option('Claude');
    expect(
      tester
          .getTopLeft(find.descendant(of: master, matching: find.text(title)))
          .dx,
      tester
          .getTopLeft(
            find.descendant(of: claude, matching: find.text('Claude')),
          )
          .dx,
    );

    await tester.tap(toggle(master));
    await tester.pumpAndSettle();
    await tester.tap(toggle(claude));
    await tester.pumpAndSettle();
    expect(globalState.config.appSetting.showProxyUnlockTags, isFalse);
    expect(globalState.config.appSetting.proxyUnlockPlatforms, isEmpty);

    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(globalState.config.appSetting.showProxyUnlockTags, isTrue);
    expect(globalState.config.appSetting.proxyUnlockPlatforms, [
      MediaPlatform.claude,
    ]);

    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(toggle(master));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(toggle(claude)).value, isTrue);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text(appLocalizations.saveChanges), findsOneWidget);
    await tester.tap(find.text(appLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(globalState.config.appSetting.showProxyUnlockTags, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final type in ProxyCardType.values) {
    testWidgets(
      'shows selected unlock icons without moving the delay ($type)',
      (tester) async {
        if (type != ProxyCardType.min) {
          globalState.appState = globalState.appState.copyWith(
            viewSize: const Size(1000, 800),
          );
        }
        const proxy = Proxy(name: 'Singapore', type: 'AnyTLS');
        final previousStatuses = mediaUnlockStore.results.value;
        mediaUnlockStore.results.value = {};
        addTearDown(() => mediaUnlockStore.results.value = previousStatuses);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              getDelayProvider(proxyName: proxy.name).overrideWith((ref) => -1),
            ],
            child: MaterialApp(
              navigatorKey: globalState.navigatorKey,
              localizationsDelegates: const [AppLocalizations.delegate],
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 224,
                    child: Builder(
                      builder: (context) {
                        globalState.measure = Measure.of(context, 1);
                        return ProxyCard(
                          groupName: 'Manual',
                          testUrl: null,
                          proxy: proxy,
                          groupType: GroupType.Selector,
                          type: type,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        final cardFinder = find.byType(ProxyCard);
        final card = tester.getRect(cardFinder);
        final title = find.text('Singapore');
        final initialTitle = tester.getRect(title);
        final protocol = find.text('AnyTLS');
        final initialProtocol = tester.getRect(protocol);
        final timeout = find.text('Timeout');
        final initialDelay = tester.getRect(timeout);
        expect(initialDelay.right, card.right - 12);
        expect(find.byType(SingleChildScrollView), findsNothing);

        final settings = ProviderScope.containerOf(tester.element(cardFinder))
            .read(appSettingProvider.notifier);
        settings.updateState(
          (state) => state.copyWith(
            showProxyUnlockTags: true,
            proxyUnlockPlatforms: const [
              MediaPlatform.claude,
              MediaPlatform.youtube,
            ],
          ),
        );
        await tester.pumpAndSettle();

        final claude = find.byTooltip('Claude');
        final youtube = find.byTooltip('YouTube');
        expect(claude, findsOneWidget);
        expect(youtube, findsOneWidget);
        expect(find.byTooltip('Netflix'), findsNothing);
        Finder grayscaleIcon(Finder platform) =>
            find.descendant(of: platform, matching: find.byType(ColorFiltered));
        expect(grayscaleIcon(claude), findsOneWidget);
        expect(grayscaleIcon(youtube), findsOneWidget);

        if (type == ProxyCardType.min) {
          await tester.tap(youtube);
          await tester.pumpAndSettle();
          expect(
            find.text(appLocalizations.proxyUnlockNotTested),
            findsOneWidget,
          );
          await tester.tap(find.text(appLocalizations.confirm));
          await tester.pumpAndSettle();
        }

        mediaUnlockStore.results.value = {
          proxy.name: {
            MediaPlatform.claude: const MediaUnlockResult(
              platform: MediaPlatform.claude,
              status: MediaUnlockStatus.unlocked,
              region: 'SG',
              latency: 95,
            ),
            MediaPlatform.youtube: const MediaUnlockResult(
              platform: MediaPlatform.youtube,
              status: MediaUnlockStatus.blocked,
            ),
          },
        };
        await tester.pumpAndSettle();

        expect(grayscaleIcon(claude), findsNothing);
        expect(grayscaleIcon(youtube), findsOneWidget);
        final badges = tester.getRect(find.byType(SingleChildScrollView));
        final firstIcon = find.descendant(
          of: claude,
          matching: find.byType(SvgPicture),
        );
        expect(badges.left, initialTitle.left);
        expect(tester.getRect(firstIcon).left, badges.left);
        expect(tester.getSize(claude).width, 13);
        expect(badges.top, greaterThanOrEqualTo(initialTitle.bottom));
        expect(badges.bottom, lessThan(initialDelay.top));
        expect(tester.getRect(cardFinder), card);
        expect(tester.getRect(title), initialTitle);
        expect(tester.getRect(protocol), initialProtocol);
        expect(tester.getRect(timeout), initialDelay);

        await tester.tap(claude);
        await tester.pumpAndSettle();
        expect(find.text(appLocalizations.unlocked), findsOneWidget);
        expect(find.text('SG'), findsOneWidget);
        expect(find.text('95 ms'), findsOneWidget);
        final country = find.text(appLocalizations.countryOrRegion);
        final delayLabel = find.text(appLocalizations.delay);
        expect(tester.getTopLeft(country).dx, tester.getTopLeft(delayLabel).dx);
        expect(
          tester.getTopRight(find.text('SG')).dx,
          tester.getTopRight(find.text('95 ms')).dx,
        );

        await tester.tap(find.text(appLocalizations.confirm));
        await tester.pumpAndSettle();

        settings.updateState(
          (state) => state.copyWith(showProxyUnlockTags: false),
        );
        await tester.pumpAndSettle();
        expect(claude, findsNothing);
        expect(youtube, findsNothing);
        expect(tester.getRect(timeout), initialDelay);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
