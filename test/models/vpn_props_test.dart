import 'dart:convert';

import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VpnProps tray click behavior', () {
    test('defaults left click to panel and right click to menu', () {
      final props = VpnProps.fromJson({});

      expect(props.trayClickBehavior, TrayClickBehavior.showPanel);
      expect(props.trayRightClickBehavior, TrayClickBehavior.showMenu);
    });

    test('persists independent left and right click behaviors', () {
      const props = VpnProps(
        trayClickBehavior: TrayClickBehavior.showMenu,
        trayRightClickBehavior: TrayClickBehavior.showPanel,
      );
      final json = props.toJson()..remove('accessControl');

      expect(json['trayClickBehavior'], TrayClickBehavior.showMenu.name);
      expect(json['trayRightClickBehavior'], TrayClickBehavior.showPanel.name);
      final restored = VpnProps.fromJson(json);
      expect(restored.trayClickBehavior, TrayClickBehavior.showMenu);
      expect(restored.trayRightClickBehavior, TrayClickBehavior.showPanel);
    });

    test('keeps the removed enhancement migration compatible', () {
      final props = VpnProps.safeFromJson({
        'trayEnhancement': false,
        'trayClickBehavior': TrayClickBehavior.showMenu.name,
      });

      expect(props.trayClickBehavior, TrayClickBehavior.showPanel);
      expect(props.trayRightClickBehavior, TrayClickBehavior.showMenu);
    });

    test('round-trips left and right fields through backup config JSON', () {
      const vpnProps = VpnProps(
        trayClickBehavior: TrayClickBehavior.showMenu,
        trayRightClickBehavior: TrayClickBehavior.showPanel,
      );
      final config = Config(themeProps: defaultThemeProps, vpnProps: vpnProps);
      final backupJson =
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>;
      final vpnJson = backupJson['vpnProps'] as Map<String, dynamic>;

      expect(vpnJson['trayClickBehavior'], TrayClickBehavior.showMenu.name);
      expect(
        vpnJson['trayRightClickBehavior'],
        TrayClickBehavior.showPanel.name,
      );

      final restored = Config.fromJson(backupJson).vpnProps;
      expect(restored.trayClickBehavior, TrayClickBehavior.showMenu);
      expect(restored.trayRightClickBehavior, TrayClickBehavior.showPanel);
    });
  });
}
