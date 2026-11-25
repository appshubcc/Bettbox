import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:bett_box/common/lan_interface_order.dart';
import 'package:bett_box/models/common.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

Future<List<CoreInterface>> getWindowsLanAddresses() =>
    Isolate.run(_readLanAddresses);

List<CoreInterface> _readLanAddresses() => using((arena) {
  final size = arena<Uint32>()..value = 15 * 1024;
  final flags =
      GAA_FLAG_INCLUDE_PREFIX |
      GAA_FLAG_SKIP_ANYCAST |
      GAA_FLAG_SKIP_MULTICAST |
      GAA_FLAG_SKIP_DNS_SERVER;

  // Adapter changes between calls can invalidate the requested buffer size.
  for (var attempt = 0; attempt < 3; attempt++) {
    final adapters = arena<Uint8>(size.value).cast<IP_ADAPTER_ADDRESSES_LH>();
    final error = GetAdaptersAddresses(AF_UNSPEC, flags, adapters, size);
    if (error == ERROR_BUFFER_OVERFLOW) continue;
    if (error == ERROR_NO_DATA) return <CoreInterface>[];
    if (error != NO_ERROR) throw OSError('GetAdaptersAddresses', error);
    final interfaces = <CoreInterface>[];
    final kinds = <String, LanInterfaceKind>{};
    for (var ptr = adapters; ptr != nullptr; ptr = ptr.ref.Next) {
      final adapter = ptr.ref;
      const softwareLoopback = 24; // IF_TYPE_SOFTWARE_LOOPBACK
      if (adapter.OperStatus != IfOperStatusUp ||
          adapter.IfType == softwareLoopback) {
        continue;
      }
      final prefixes = <(Uint8List, int)>[];
      for (var p = adapter.FirstPrefix; p != nullptr; p = p.ref.Next) {
        final bytes = _ipBytes(p.ref.Address);
        if (bytes != null) prefixes.add((bytes, p.ref.PrefixLength));
      }
      final addresses = <String>{};
      for (var u = adapter.FirstUnicastAddress; u != nullptr; u = u.ref.Next) {
        final entry = u.ref;
        if (entry.ValidLifetime == 0 ||
            (entry.DadState != IpDadStatePreferred &&
                entry.DadState != IpDadStateDeprecated)) {
          continue;
        }
        final bytes = _ipBytes(entry.Address);
        if (bytes == null ||
            !prefixes.any((p) => isInDirectSubnet(bytes, p.$1, p.$2))) {
          continue;
        }
        final ip = InternetAddress.fromRawAddress(bytes);
        if (ip.isLoopback || ip.isMulticast || bytes.every((b) => b == 0)) {
          continue;
        }
        final scoped = ip.type == InternetAddressType.IPv6 && ip.isLinkLocal;
        addresses.add(
          scoped ? '${ip.address}%${adapter.Ipv6IfIndex}' : ip.address,
        );
      }
      if (addresses.isNotEmpty) {
        final name = adapter.FriendlyName.toDartString();
        const ifTypeTunnel = 131, ifTypePpp = 23, ifTypePropVirtual = 53;
        kinds[name] = classifyLanInterface(
          name,
          description: adapter.Description == nullptr
              ? ''
              : adapter.Description.toDartString(),
          isTunnel:
              adapter.TunnelType != TUNNEL_TYPE_NONE ||
              adapter.IfType == ifTypeTunnel ||
              adapter.IfType == ifTypePpp,
          isVirtual: adapter.IfType == ifTypePropVirtual,
        );
        interfaces.add(
          CoreInterface(name: name, addresses: addresses.toList()),
        );
      }
    }
    return sortLanInterfaces(interfaces, kinds: kinds);
  }
  throw OSError('GetAdaptersAddresses', ERROR_BUFFER_OVERFLOW);
});

// Views into the sockaddr_in.sin_addr or sockaddr_in6.sin6_addr field.
// The adapter buffer owns these bytes until all entries have been converted.
Uint8List? _ipBytes(SOCKET_ADDRESS socket) {
  final ptr = socket.lpSockaddr;
  if (ptr == nullptr) return null;
  final (offset, length) = switch (ptr.ref.sa_family) {
    AF_INET => (4, 4),
    AF_INET6 => (8, 16),
    _ => (0, 0),
  };
  if (length == 0 || socket.iSockaddrLength < offset + length) return null;
  return (ptr.cast<Uint8>() + offset).asTypedList(length);
}

// Windows also reports host, broadcast and multicast prefixes. A single host
// or a default route does not identify a directly connected subnet.
bool isInDirectSubnet(Uint8List address, Uint8List prefix, int bits) {
  if (address.length != prefix.length ||
      bits <= 0 ||
      bits >= address.length * 8) {
    return false;
  }
  final wholeBytes = bits ~/ 8;
  for (var i = 0; i < wholeBytes; i++) {
    if (address[i] != prefix[i]) return false;
  }
  final remaining = bits % 8;
  return remaining == 0 ||
      (address[wholeBytes] ^ prefix[wholeBytes]) >> (8 - remaining) == 0;
}
