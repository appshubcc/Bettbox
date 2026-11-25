import 'package:bett_box/common/common.dart';
import 'package:bett_box/helper/helper.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/config/general.dart';
import 'package:bett_box/views/config/lan_addresses.dart';
import 'package:bett_box/views/config/lan_firewall.dart';
import 'package:bett_box/views/config/user_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _corePath = r'C:\Program Files\Bettbox\BettboxCore.exe';

class _Firewall extends Fake implements HelperClient {
  bool legacy = true;
  int? allowedPort;
  final grants = <int>[];
  int disables = 0;

  @override
  Future<LanFirewallStatus> lanFirewallStatus(int port) async {
    if (legacy) return LanFirewallStatus.legacy;
    if (allowedPort == null) return LanFirewallStatus.inactive;
    return allowedPort == port
        ? LanFirewallStatus.scoped
        : LanFirewallStatus.needsReview;
  }

  @override
  Future<void> allowLanFirewall(int port, String corePath) async {
    expect(corePath, _corePath);
    legacy = false;
    allowedPort = port;
    grants.add(port);
  }

  @override
  Future<void> disableLanFirewall() async {
    legacy = false;
    allowedPort = null;
    disables++;
  }
}

void main() {
  testWidgets(
    'firewall changes are independent of LAN sharing and require consent for the current port',
    (tester) async {
      await AppLocalizations.load(const Locale('zh', 'CN'));
      globalState.config = Config(themeProps: defaultThemeProps);
      final firewall = _Firewall();
      final container = ProviderContainer(
        overrides: [
          lanFirewallClientProvider.overrideWithValue(firewall),
          lanFirewallCorePathProvider.overrideWithValue(_corePath),
          viewSizeProvider.overrideWithBuild((ref, _) => const Size(800, 600)),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: globalState.navigatorKey,
            home: const Scaffold(body: LanFirewallItem()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final config = container.read(patchClashConfigProvider.notifier);
      final allow = find.text(appLocalizations.lanFirewallAllow);
      final allowButton = find.widgetWithText(
        OutlinedButton,
        appLocalizations.lanFirewallAllow,
      );
      final disable = find.text(appLocalizations.lanFirewallDisable);
      expect(find.text(appLocalizations.lanFirewallLegacy), findsOneWidget);
      expect(tester.widget<OutlinedButton>(allowButton).onPressed, isNotNull);
      expect(disable, findsOneWidget);

      config.updateState((s) => s.copyWith(allowLan: false, mixedPort: 7890));
      await tester.pumpAndSettle();
      await tester.tap(allow);
      await tester.pumpAndSettle();
      expect(find.text(appLocalizations.lanFirewallConfirm), findsOneWidget);
      double previousY = 0;
      for (final (label, value) in [
        (appLocalizations.port, '7890'),
        (appLocalizations.protocol, 'TCP/UDP'),
        (appLocalizations.networkType, appLocalizations.lanFirewallNetworks),
        (appLocalizations.source, appLocalizations.lanFirewallSources),
        (appLocalizations.program, _corePath),
        (
          appLocalizations.lanFirewallOldRule,
          appLocalizations.lanFirewallDisableLegacy,
        ),
      ]) {
        final y = tester.getCenter(find.text(label)).dy;
        expect(y, greaterThan(previousY));
        expect(tester.getCenter(find.text(value)).dy, closeTo(y, 1));
        previousY = y;
      }
      await tester.tap(find.text(appLocalizations.cancel));
      await tester.pumpAndSettle();
      expect(firewall.grants, isEmpty);
      expect(firewall.disables, 0);

      await tester.tap(allow);
      await tester.pumpAndSettle();
      config.updateState((s) => s.copyWith(mixedPort: 7891));
      await tester.pumpAndSettle();
      await tester.tap(find.text(appLocalizations.confirm));
      await tester.pumpAndSettle();
      expect(firewall.grants, isEmpty);

      await tester.tap(allow);
      await tester.pumpAndSettle();
      await tester.tap(find.text(appLocalizations.confirm));
      await tester.pumpAndSettle();
      expect(firewall.grants, [7891]);
      expect(find.text('规则已启用'), findsOneWidget);
      expect(find.text('停用防火墙策略'), findsOneWidget);
      expect(allow, findsNothing);

      config.updateState((s) => s.copyWith(mixedPort: 7892));
      await tester.pumpAndSettle();
      await tester.tap(allow);
      await tester.pumpAndSettle();
      expect(find.text(appLocalizations.lanFirewallOldRule), findsNothing);
      expect(
        find.text(appLocalizations.lanFirewallDisableLegacy),
        findsNothing,
      );
      await tester.tap(find.text(appLocalizations.cancel));
      await tester.pumpAndSettle();

      config.updateState((s) => s.copyWith(allowLan: false, mixedPort: 0));
      await tester.pumpAndSettle();
      expect(find.text(appLocalizations.lanFirewallReview), findsOneWidget);
      expect(tester.widget<OutlinedButton>(allowButton).onPressed, isNull);
      await tester.tap(disable);
      await tester.pumpAndSettle();
      expect(firewall.disables, 1);
      expect(find.text('规则已停用'), findsOneWidget);
      expect(find.text('启用防火墙策略'), findsOneWidget);
      expect(disable, findsNothing);
      config.updateState((s) => s.copyWith(mixedPort: 7890));
      await tester.pumpAndSettle();
      await tester.tap(allow);
      await tester.pumpAndSettle();
      await tester.tap(find.text(appLocalizations.confirm));
      await tester.pumpAndSettle();
      expect(find.text('规则已启用'), findsOneWidget);
      await tester.tap(disable);
      await tester.pumpAndSettle();
      expect(find.text('规则已停用'), findsOneWidget);
      expect(firewall.disables, 2);
      expect(container.read(patchClashConfigProvider).allowLan, isFalse);
    },
  );

  testWidgets(
    'the LAN settings button opens addresses and authentication in one dialog',
    (tester) async {
      await AppLocalizations.load(const Locale('en'));
      final initial = Config(themeProps: defaultThemeProps);
      globalState.config = initial.copyWith(
        patchClashConfig: initial.patchClashConfig.copyWith(
          allowLan: true,
          mixedPort: 8080,
          authentication: ['alice:secret'],
        ),
      );
      var interfaces = const [
        CoreInterface(
          name: 'Ethernet',
          addresses: ['192.168.1.20', 'fd00::20', 'fd00::20', 'fe80::20%7'],
        ),
        CoreInterface(name: 'vEthernet', addresses: ['172.20.0.1']),
      ];
      final firewall = _Firewall();
      final container = ProviderContainer(
        overrides: [
          lanInterfacesProvider.overrideWith((_) async => interfaces),
          lanFirewallClientProvider.overrideWithValue(firewall),
          lanFirewallCorePathProvider.overrideWithValue(_corePath),
          viewSizeProvider.overrideWithBuild((ref, _) => const Size(800, 600)),
        ],
      );
      addTearDown(container.dispose);
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
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: globalState.navigatorKey,
            home: const Scaffold(body: AllowLanItem()),
          ),
        ),
      );
      await tester.tap(find.byType(LanSettingsButton));
      await tester.pumpAndSettle();
      expect(find.byType(UserAuthDialog), findsOneWidget);
      expect(
        find.byType(LanFirewallItem),
        system.isWindows ? findsOneWidget : findsNothing,
      );
      expect(find.text('172.20.0.1:8080'), findsOneWidget);
      expect(find.text('192.168.1.20:8080'), findsOneWidget);
      expect(find.text('[fd00::20]:8080'), findsOneWidget);
      final ipv6 = find.text('[fe80::20]:8080');
      expect(ipv6, findsOneWidget);
      expect(
        find.ancestor(of: ipv6, matching: find.byType(Tooltip)),
        findsNothing,
      );
      final copy = find.descendant(
        of: find.ancestor(of: ipv6, matching: find.byType(Row)).first,
        matching: find.byTooltip(appLocalizations.copy),
      );
      await tester.ensureVisible(copy);
      await tester.tap(copy);
      await tester.pumpAndSettle();
      expect(copied, '[fe80::20]:8080');

      final username = find.byType(TextFormField).first;
      await tester.ensureVisible(username);
      await tester.enterText(username, 'unsaved');
      interfaces = const [
        CoreInterface(name: 'Wi-Fi', addresses: ['10.0.0.2']),
      ];
      final refresh = find.byTooltip(
        MaterialLocalizations.of(tester.element(find.byType(LanAddresses)))
            .refreshIndicatorSemanticLabel,
      );
      await tester.ensureVisible(refresh);
      await tester.tap(refresh);
      await tester.pumpAndSettle();
      expect(find.text('10.0.0.2:8080'), findsOneWidget);
      expect(ipv6, findsNothing);
      container
          .read(patchClashConfigProvider.notifier)
          .updateState((state) => state.copyWith(allowLan: false));
      await tester.pumpAndSettle();
      expect(find.text('10.0.0.2'), findsOneWidget);
      expect(
        find.text(
          '${appLocalizations.lanSharing} · ${appLocalizations.disabled}',
        ),
        findsNothing,
      );
      container
          .read(patchClashConfigProvider.notifier)
          .updateState((state) => state.copyWith(mixedPort: 0));
      await tester.pumpAndSettle();
      expect(find.text('10.0.0.2'), findsOneWidget);
      expect(find.text('10.0.0.2:0'), findsNothing);
      expect(
        tester.widget<TextFormField>(username).controller!.text,
        'unsaved',
      );
      await tester.tap(find.text(appLocalizations.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(UserAuthDialog), findsNothing);
      expect(container.read(patchClashConfigProvider).authentication, [
        'alice:secret',
      ]);
      expect(firewall.grants, isEmpty);
      expect(firewall.disables, 0);
    },
  );
}
