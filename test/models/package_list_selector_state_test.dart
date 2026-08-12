import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Package package(String name) => Package(
    packageName: name,
    label: name,
    system: false,
    internet: true,
    lastUpdateTime: 0,
  );

  test('sorts Tor apps before VPN apps and direct apps in whitelist mode', () {
    final state = PackageListSelectorState(
      packages: [package('direct'), package('vpn'), package('tor')],
      accessControl: const AccessControl(
        enable: true,
        mode: AccessControlMode.acceptSelected,
        acceptList: ['vpn', 'tor'],
      ),
    );

    expect(state.getProxySortList(['tor']).map((item) => item.packageName), [
      'tor',
      'vpn',
      'direct',
    ]);
  });

  test('treats rejected apps as direct apps in blacklist mode', () {
    final state = PackageListSelectorState(
      packages: [package('direct'), package('vpn-a'), package('vpn-b')],
      accessControl: const AccessControl(
        enable: true,
        mode: AccessControlMode.rejectSelected,
        rejectList: ['direct'],
      ),
    );

    expect(state.getProxySortList(['vpn-b']).map((item) => item.packageName), [
      'vpn-a',
      'vpn-b',
      'direct',
    ]);
  });
}
