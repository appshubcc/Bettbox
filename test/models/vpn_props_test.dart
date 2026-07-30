import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VpnProps tray click behavior', () {
    test('defaults to showing the panel for existing configurations', () {
      final props = VpnProps.fromJson({});

      expect(props.trayClickBehavior, TrayClickBehavior.showPanel);
    });

    test('persists showing the tray menu', () {
      const props = VpnProps(trayClickBehavior: TrayClickBehavior.showMenu);
      final json = props.toJson()..remove('accessControl');

      expect(json['trayClickBehavior'], TrayClickBehavior.showMenu.name);
      expect(
        VpnProps.fromJson(json).trayClickBehavior,
        TrayClickBehavior.showMenu,
      );
    });

    test('migrates the removed enhancement switch to showing the panel', () {
      final props = VpnProps.safeFromJson({
        'trayEnhancement': false,
        'trayClickBehavior': TrayClickBehavior.showMenu.name,
      });

      expect(props.trayClickBehavior, TrayClickBehavior.showPanel);
    });
  });
}
