import 'package:bett_box/common/identity.dart';
import 'package:bett_box/models/common.dart';

enum LanInterfaceKind { physical, virtualAdapter, tunnel }

final _tunnel = RegExp(
  r'\b(wintun|wireguard|tunnel|openvpn|tailscale|zerotier|vpn)\b|'
  r'^(?:utun|tun|tap|wg|ppp|tailscale|zt)(?:\d|[-_. ]|$)',
  caseSensitive: false,
);
final _virtual = RegExp(
  r'\b(virtual|hyper-v|vmware|virtualbox|virtio|docker)\b|'
  r'^(?:vethernet|veth|vmnet|vboxnet|virbr|br-|bridge|docker|awdl|llw)',
  caseSensitive: false,
);

LanInterfaceKind classifyLanInterface(
  String name, {
  String description = '',
  bool isTunnel = false,
  bool isVirtual = false,
}) {
  if (isTunnel || _tunnel.hasMatch(description)) return LanInterfaceKind.tunnel;
  if (_virtual.hasMatch(description)) return LanInterfaceKind.virtualAdapter;
  if (name.toLowerCase() == AppIdentity.tunDeviceName.toLowerCase() ||
      _tunnel.hasMatch(name)) {
    return LanInterfaceKind.tunnel;
  }
  if (isVirtual || _virtual.hasMatch(name)) {
    return LanInterfaceKind.virtualAdapter;
  }
  return LanInterfaceKind.physical;
}

List<CoreInterface> sortLanInterfaces(
  List<CoreInterface> interfaces, {
  Map<String, LanInterfaceKind> kinds = const {},
}) {
  LanInterfaceKind kind(String name) =>
      kinds[name] ?? classifyLanInterface(name);
  return interfaces..sort((a, b) {
    final byKind = kind(a.name).index.compareTo(kind(b.name).index);
    return byKind != 0 ? byKind : a.name.compareTo(b.name);
  });
}
