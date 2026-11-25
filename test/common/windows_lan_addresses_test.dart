import 'dart:io';

import 'package:bett_box/common/lan_interface_order.dart';
import 'package:bett_box/common/windows_lan_addresses.dart';
import 'package:bett_box/models/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'sorts physical, VM and tunnel adapters, including renamed adapters',
    () {
      final adapters = [
        const CoreInterface(name: 'Bettbox'),
        const CoreInterface(name: 'vEthernet (Default Switch)'),
        const CoreInterface(name: '以太网'),
      ];
      expect(sortLanInterfaces(adapters).map((a) => a.name), [
        '以太网',
        'vEthernet (Default Switch)',
        'Bettbox',
      ]);
      expect(
        classifyLanInterface('Office', description: 'Meta Tunnel'),
        LanInterfaceKind.tunnel,
      );
      expect(
        classifyLanInterface(
          'Work VPN',
          description: 'Hyper-V Virtual Ethernet Adapter',
        ),
        LanInterfaceKind.virtualAdapter,
      );
      expect(
        classifyLanInterface('Office', isTunnel: true),
        LanInterfaceKind.tunnel,
      );
      expect(
        classifyLanInterface('Office', isVirtual: true),
        LanInterfaceKind.virtualAdapter,
      );
    },
  );

  test(
    'matches directly connected prefixes by address family and bit length',
    () {
      bool matches(String address, String network, int bits) =>
          isInDirectSubnet(
            InternetAddress(address).rawAddress,
            InternetAddress(network).rawAddress,
            bits,
          );

      expect(matches('172.28.107.1', '172.28.96.0', 20), isTrue);
      expect(matches('172.28.112.1', '172.28.96.0', 20), isFalse);
      expect(matches('198.18.0.1', '198.18.0.0', 30), isTrue);
      expect(matches('10.1.0.1', '10.1.0.0', 31), isTrue);
      expect(matches('10.1.0.1', '10.1.0.1', 32), isFalse);
      expect(matches('10.1.0.1', '0.0.0.0', 0), isFalse);
      expect(matches('fe80::42', 'fe80::', 64), isTrue);
      expect(matches('fd00::1', 'fd00::', 127), isTrue);
      expect(matches('fd00::1', 'fd00::1', 128), isFalse);
      expect(matches('fd00::1', '10.0.0.0', 8), isFalse);
    },
  );

  test('Windows enumerates only local interface addresses', () async {
    final local = await NetworkInterface.list(includeLinkLocal: true);
    final localAddresses = {
      for (final iface in local)
        for (final ip in iface.addresses) ip.address.split('%').first,
    };
    final interfaces = await getWindowsLanAddresses();
    for (final iface in interfaces) {
      expect(iface.name, isNotEmpty);
      expect(iface.addresses, isNotEmpty);
      for (final addr in iface.addresses) {
        final host = addr.split('%').first;
        final ip = InternetAddress(host);
        expect(localAddresses, contains(host));
        expect(ip.isLoopback, isFalse);
        if (ip.type == InternetAddressType.IPv6 && ip.isLinkLocal) {
          expect(addr, matches(r'%[1-9][0-9]*$'));
        }
      }
    }
  }, skip: !Platform.isWindows);
}
