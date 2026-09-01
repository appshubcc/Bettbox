import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

enum IpCategory {
  tun,
  lan,
  public,
}

class Utils {
  Color? getDelayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return Colors.red;
    if (delay < 600) return Colors.green;
    return const Color(0xFFC57F0A);
  }

  String countryCodeToEmoji(String countryCode) {
    final String code = countryCode.toUpperCase();
    if (code.length != 2) {
      return countryCode;
    }
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  bool isTunIp(String ip) {
    final address = InternetAddress.tryParse(ip.trim());
    if (address == null) return false;
    if (address.type == InternetAddressType.IPv4) {
      final parts = ip.trim().split('.').map(int.tryParse).toList();
      if (parts.length == 4 && parts.every((p) => p != null)) {
        final p0 = parts[0]!;
        final p1 = parts[1]!;
        final p2 = parts[2]!;
        // 198.51.100.0/24 (TEST-NET-2 / TUN Default)
        if (p0 == 198 && p1 == 51 && p2 == 100) return true;
        // 198.18.0.0/15 (Benchmarking / Fake-IP)
        if (p0 == 198 && (p1 == 18 || p1 == 19)) return true;
      }
    } else if (address.type == InternetAddressType.IPv6) {
      final clean = ip.trim().toLowerCase();
      // fdfe:dcba:9876::/126 (Default TUN IPv6)
      if (clean.startsWith('fdfe:dcba:9876:')) return true;
    }
    return false;
  }

  IpCategory classifyIp(String ip) {
    if (isTunIp(ip)) {
      return IpCategory.tun;
    }
    if (isPrivateOrReservedIp(ip)) {
      return IpCategory.lan;
    }
    return IpCategory.public;
  }

  bool isPrivateOrReservedIp(String ip) {
    final address = InternetAddress.tryParse(ip.trim());
    if (address == null) return false;

    if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
      return true;
    }

    if (address.type == InternetAddressType.IPv4) {
      final parts = ip.trim().split('.').map(int.tryParse).toList();
      if (parts.length == 4 && parts.every((p) => p != null)) {
        final p0 = parts[0]!;
        final p1 = parts[1]!;
        final p2 = parts[2]!;

        // 0.0.0.0/8 (Current network / RFC 1122)
        if (p0 == 0) return true;

        // 10.0.0.0/8 (Private / RFC 1918)
        if (p0 == 10) return true;

        // 100.64.0.0/10 (CGNAT / Shared / RFC 6598: 100.64.0.0 - 100.127.255.255)
        if (p0 == 100 && (p1 >= 64 && p1 <= 127)) return true;

        // 127.0.0.0/8 (Loopback / RFC 1122)
        if (p0 == 127) return true;

        // 169.254.0.0/16 (Link Local / RFC 3927)
        if (p0 == 169 && p1 == 254) return true;

        // 172.16.0.0/12 (Private / RFC 1918: 172.16.0.0 - 172.31.255.255)
        if (p0 == 172 && (p1 >= 16 && p1 <= 31)) return true;

        // 192.0.0.0/24 (IETF Protocol Assignments / RFC 6890)
        if (p0 == 192 && p1 == 0 && p2 == 0) return true;

        // 192.0.2.0/24 (TEST-NET-1 / RFC 5737)
        if (p0 == 192 && p1 == 0 && p2 == 2) return true;

        // 192.88.99.0/24 (6to4 Relay Anycast / RFC 7526)
        if (p0 == 192 && p1 == 88 && p2 == 99) return true;

        // 192.168.0.0/16 (Private / RFC 1918)
        if (p0 == 192 && p1 == 168) return true;

        // 198.18.0.0/15 (Benchmarking / Fake-IP / RFC 2544: 198.18.0.0 - 198.19.255.255)
        if (p0 == 198 && (p1 == 18 || p1 == 19)) return true;

        // 198.51.100.0/24 (TEST-NET-2 / TUN Default / RFC 5737)
        if (p0 == 198 && p1 == 51 && p2 == 100) return true;

        // 203.0.113.0/24 (TEST-NET-3 / RFC 5737)
        if (p0 == 203 && p1 == 0 && p2 == 113) return true;

        // 224.0.0.0/4 (Multicast / RFC 5771)
        if (p0 >= 224 && p0 <= 239) return true;

        // 240.0.0.0/4 (Reserved / RFC 1112)
        if (p0 >= 240) return true;
      }
    } else if (address.type == InternetAddressType.IPv6) {
      final clean = ip.trim().toLowerCase();
      // ::1 (Loopback), :: (Unspecified)
      if (clean == '::1' || clean == '::') return true;
      // fe80::/10 (Link-local)
      if (clean.startsWith('fe8') ||
          clean.startsWith('fe9') ||
          clean.startsWith('fea') ||
          clean.startsWith('feb')) {
        return true;
      }
      // fc00::/7 (Unique Local Address ULA: fc00:: ~ fdff::)
      if (clean.startsWith('fc') || clean.startsWith('fd')) {
        return true;
      }
      // ff00::/8 (Multicast)
      if (clean.startsWith('ff')) {
        return true;
      }
      // 2001:db8::/32 (Documentation)
      if (clean.startsWith('2001:db8:')) {
        return true;
      }
    }

    return false;
  }

  String get id {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random();
    final randomStr = String.fromCharCodes(
      List.generate(8, (_) => random.nextInt(26) + 97),
    );
    return '$timestamp$randomStr';
  }

  String getDateStringLast2(int value) {
    var valueRaw = '0$value';
    return valueRaw.substring(valueRaw.length - 2);
  }

  String generateRandomString({int minLength = 10, int maxLength = 100}) {
    const latinChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    int length = minLength + random.nextInt(maxLength - minLength + 1);

    String result = '';
    for (int i = 0; i < length; i++) {
      if (random.nextBool()) {
        result += String.fromCharCode(
          0x4E00 + random.nextInt(0x9FA5 - 0x4E00 + 1),
        );
      } else {
        result += latinChars[random.nextInt(latinChars.length)];
      }
    }

    return result;
  }

  String get uuidV4 {
    final Random random = Random();
    final bytes = List.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  String getTimeDifference(DateTime dateTime) {
    var currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(dateTime);
    var inHours = difference.inHours;
    var inMinutes = difference.inMinutes;
    var inSeconds = difference.inSeconds;

    return '${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
  }

  String getTimeText(int? timeStamp) {
    if (timeStamp == null) {
      return '00:00:00';
    }
    final diff = timeStamp / 1000;
    final inHours = (diff / 3600).floor();
    if (inHours > 99) {
      return '99:59:59';
    }
    final inMinutes = (diff / 60 % 60).floor();
    final inSeconds = (diff % 60).floor();

    return '${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
  }

  Locale getSystemLocale() {
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedLocales = AppLocalizations.delegate.supportedLocales;
    
    if (platformLocale.languageCode.toLowerCase() == 'zh') {
      final isTraditional = 
        (platformLocale.countryCode?.toUpperCase() == 'TW') ||
        (platformLocale.countryCode?.toUpperCase() == 'HK') ||
        (platformLocale.countryCode?.toUpperCase() == 'MO') ||
        (platformLocale.scriptCode?.toLowerCase() == 'hant');
      return isTraditional ? const Locale('zh', 'TC') : const Locale('zh', 'CN');
    }
    
    for (final locale in supportedLocales) {
      if (locale.languageCode == platformLocale.languageCode) {
        return locale;
      }
    }
    
    return const Locale('zh', 'CN');
  }

  Locale? getLocaleForString(String? localString) {
    if (localString == null) return null;
    var localSplit = localString.split('_');
    if (localSplit.length == 1) {
      return Locale(localSplit[0]);
    }
    if (localSplit.length == 2) {
      return Locale(localSplit[0], localSplit[1]);
    }
    if (localSplit.length == 3) {
      return Locale.fromSubtags(
        languageCode: localSplit[0],
        scriptCode: localSplit[1],
        countryCode: localSplit[2],
      );
    }
    return null;
  }

  int sortByChar(String a, String b) {
    if (a.isEmpty && b.isEmpty) {
      return 0;
    }
    if (a.isEmpty) {
      return -1;
    }
    if (b.isEmpty) {
      return 1;
    }
    final charA = a[0];
    final charB = b[0];

    if (charA == charB) {
      return sortByChar(a.substring(1), b.substring(1));
    } else {
      return charA.compareToLower(charB);
    }
  }

  String getOverwriteLabel(String label) {
    final reg = RegExp(r'\((\d+)\)$');
    final matches = reg.allMatches(label);
    if (matches.isNotEmpty) {
      final match = matches.last;
      final number = int.parse(match[1] ?? '0') + 1;
      return label.replaceFirst(reg, '($number)', label.length - 3 - 1);
    } else {
      return '$label(1)';
    }
  }

  String getTrayIconPath({
    required Brightness brightness,
    bool isStart = false,
    bool invertTrayIcon = false,
  }) {
    if (system.isLinux) {
      return 'assets/images/icon.png';
    }

    if (system.isMacOS && isStart) {
      return 'assets/images/icon_black.png';
    }

    final suffix = system.isWindows ? 'ico' : 'png';

    final darkPath = !isStart
        ? 'assets/images/icon_light.$suffix'
        : 'assets/images/icon_white.$suffix';
    final lightPath = !isStart
        ? 'assets/images/icon.$suffix'
        : 'assets/images/icon_black.$suffix';

    if (invertTrayIcon) {
      return brightness == Brightness.dark ? lightPath : darkPath;
    }

    return brightness == Brightness.dark ? darkPath : lightPath;
  }

  int compareVersions(String version1, String version2) {
    List<String> v1 = version1.split('+')[0].split('.');
    List<String> v2 = version2.split('+')[0].split('.');
    int major1 = int.parse(v1[0]);
    int major2 = int.parse(v2[0]);
    if (major1 != major2) {
      return major1.compareTo(major2);
    }
    int minor1 = v1.length > 1 ? int.parse(v1[1]) : 0;
    int minor2 = v2.length > 1 ? int.parse(v2[1]) : 0;
    if (minor1 != minor2) {
      return minor1.compareTo(minor2);
    }
    int patch1 = v1.length > 2 ? int.parse(v1[2]) : 0;
    int patch2 = v2.length > 2 ? int.parse(v2[2]) : 0;
    if (patch1 != patch2) {
      return patch1.compareTo(patch2);
    }
    int build1 = version1.contains('+') ? int.parse(version1.split('+')[1]) : 0;
    int build2 = version2.contains('+') ? int.parse(version2.split('+')[1]) : 0;
    return build1.compareTo(build2);
  }

  String getPinyin(String value) {
    return value.isNotEmpty
        ? PinyinHelper.getFirstWordPinyin(value.substring(0, 1))
        : '';
  }

  String? getFileNameForDisposition(String? disposition) {
    if (disposition == null) return null;
    final parseValue = HeaderValue.parse(disposition);
    final parameters = parseValue.parameters;
    final fileNamePointKey = parameters.keys.firstWhere(
      (key) => key == 'filename*',
      orElse: () => '',
    );
    if (fileNamePointKey.isNotEmpty) {
      final res = parameters[fileNamePointKey]?.split("''") ?? [];
      if (res.length >= 2) {
        return Uri.decodeComponent(res[1]);
      }
    }
    final fileNameKey = parameters.keys.firstWhere(
      (key) => key == 'filename',
      orElse: () => '',
    );
    if (fileNameKey.isEmpty) return null;
    return parameters[fileNameKey];
  }

  FlutterView getScreen() {
    return WidgetsBinding.instance.platformDispatcher.views.first;
  }

  List<String> parseReleaseBody(String? body) {
    if (body == null) return [];
    const pattern = r'^\s*-\s+(.+)';
    final regex = RegExp(pattern, multiLine: true);
    return regex
        .allMatches(body)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((item) =>
            item.isNotEmpty &&
            !item.startsWith('---') &&
            !item.startsWith(':') &&
            !item.startsWith('|') &&
            !item.startsWith('['))
        .toList();
  }

  ViewMode getViewMode(double viewWidth) {
    if (viewWidth <= maxMobileWidth) return ViewMode.mobile;
    if (viewWidth <= maxLaptopWidth) return ViewMode.laptop;
    return ViewMode.desktop;
  }

  int getProxiesColumns(double viewWidth, ProxiesLayout proxiesLayout) {
    final columns = max((viewWidth / 300).ceil(), 2);
    return switch (proxiesLayout) {
      ProxiesLayout.tight => columns + 1,
      ProxiesLayout.standard => columns,
      ProxiesLayout.loose => columns - 1,
    };
  }

  int getProfilesColumns(double viewWidth) {
    return min(max((viewWidth / 320).floor(), 1), 3);
  }

  final _indexPrimary = [50, 100, 200, 300, 400, 500, 600, 700, 800, 850, 900];

  MaterialColor _createPrimarySwatch(Color color) {
    final Map<int, Color> swatch = <int, Color>{};
    final int a = color.alpha8bit;
    final int r = color.red8bit;
    final int g = color.green8bit;
    final int b = color.blue8bit;
    for (final int strength in _indexPrimary) {
      final double ds = 0.5 - strength / 1000;
      swatch[strength] = Color.fromARGB(
        a,
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      );
    }
    swatch[50] = swatch[50]!.lighten(18);
    swatch[100] = swatch[100]!.lighten(16);
    swatch[200] = swatch[200]!.lighten(14);
    swatch[300] = swatch[300]!.lighten(10);
    swatch[400] = swatch[400]!.lighten(6);
    swatch[700] = swatch[700]!.darken(2);
    swatch[800] = swatch[800]!.darken(3);
    swatch[900] = swatch[900]!.darken(4);
    return MaterialColor(color.value32bit, swatch);
  }

  List<Color> getMaterialColorShades(Color color) {
    final swatch = _createPrimarySwatch(color);
    return <Color>[
      if (swatch[50] != null) swatch[50]!,
      if (swatch[100] != null) swatch[100]!,
      if (swatch[200] != null) swatch[200]!,
      if (swatch[300] != null) swatch[300]!,
      if (swatch[400] != null) swatch[400]!,
      if (swatch[500] != null) swatch[500]!,
      if (swatch[600] != null) swatch[600]!,
      if (swatch[700] != null) swatch[700]!,
      if (swatch[800] != null) swatch[800]!,
      if (swatch[850] != null) swatch[850]!,
      if (swatch[900] != null) swatch[900]!,
    ];
  }

  String getBackupFileName() {
    return '${appName}_backup_${DateTime.now().show}.zip';
  }

  String get logFile {
    return '${appName}_${DateTime.now().show}.log';
  }

  Future<String?> getLocalIpAddress() async {
    List<NetworkInterface> interfaces =
        await NetworkInterface.list(includeLoopback: false)
          ..sort((a, b) {
            if (a.isWifi && !b.isWifi) return -1;
            if (!a.isWifi && b.isWifi) return 1;
            if (a.includesIPv4 && !b.includesIPv4) return -1;
            if (!a.includesIPv4 && b.includesIPv4) return 1;
            return 0;
          });
    for (final interface in interfaces) {
      final nameLower = interface.name.toLowerCase();
      if (nameLower.contains('tun') ||
          nameLower.contains('vpn') ||
          nameLower.contains('tap') ||
          nameLower.contains('ppp')) {
        continue;
      }
      final addresses = interface.addresses;
      if (addresses.isEmpty) {
        continue;
      }
      addresses.sort((a, b) {
        if (a.isIPv4 && !b.isIPv4) return -1;
        if (!a.isIPv4 && b.isIPv4) return 1;
        return 0;
      });
      return addresses.first.address;
    }
    return '';
  }

  Future<List<String>> getLocalGateways() async {
    if (Platform.isLinux) {
      return _getLinuxGateways();
    }
    if (Platform.isMacOS) {
      return _getMacOSGateways();
    }
    if (Platform.isWindows) {
      return _getWindowsGateways();
    }
    return [];
  }

  Future<List<String>> _getLinuxGateways() async {
    try {
      final routeFile = File('/proc/net/route');
      if (!await routeFile.exists()) return [];

      final lines = await routeFile.readAsLines();
      final gateways = <String>[];
      // Header: Iface Destination Gateway Flags RefCnt Use Metric Mask ...
      for (final line in lines.skip(1)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 3) continue;
        if (parts[1] != '00000000') continue; // default route destination
        final gwHex = parts[2];
        if (gwHex == '00000000') continue; // no gateway
        // /proc/net/route stores IPv4 in little-endian hex
        final bytes = [
          int.parse(gwHex.substring(6, 8), radix: 16),
          int.parse(gwHex.substring(4, 6), radix: 16),
          int.parse(gwHex.substring(2, 4), radix: 16),
          int.parse(gwHex.substring(0, 2), radix: 16),
        ];
        gateways.add(bytes.join('.'));
      }
      return gateways;
    } catch (e) {
      commonPrint.log('Smart Auto Stop: Linux gateway error: $e');
      return [];
    }
  }

  Future<List<String>> _getMacOSGateways() async {
    try {
      final result = await Process.run('route', ['-n', 'get', 'default']);
      if (result.exitCode != 0) return [];

      final stdout = result.stdout.toString();
      for (final line in stdout.split('\n')) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('gateway:')) continue;
        final gateway = trimmed.substring('gateway:'.length).trim();
        // Exclude IPv6/link-local gateways
        if (gateway.isNotEmpty && !gateway.contains(':')) {
          return [gateway];
        }
      }
      return [];
    } catch (e) {
      commonPrint.log('Smart Auto Stop: macOS gateway error: $e');
      return [];
    }
  }

  Future<List<String>> _getWindowsGateways() async {
    try {
      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-Command',
          'Get-NetRoute -DestinationPrefix \'0.0.0.0/0\' '
              '| Select-Object -ExpandProperty NextHop',
        ],
      );
      if (result.exitCode != 0) return [];

      final gateways = <String>[];
      for (final line in result.stdout.toString().split('\n')) {
        final gateway = line.trim();
        if (gateway.isEmpty) continue;
        if (!RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(gateway)) continue;
        gateways.add(gateway);
      }
      return gateways;
    } catch (e) {
      commonPrint.log('Smart Auto Stop: Windows gateway error: $e');
      return [];
    }
  }

  SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {
    final control = system.isMacOS ? false : true;
    return SingleActivator(trigger, control: control, meta: !control);
  }


  FutureOr<T> handleWatch<T>(Function function) async {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      final res = await function();
      stopwatch.stop();
      commonPrint.log('Time：${stopwatch.elapsedMilliseconds} ms');
      return res;
    }
    return await function();
  }

  String generateSecret() {
    final random = Random();
    // Generate an 8-digit number (10000000 to 99999999)
    final secret = 10000000 + random.nextInt(90000000);
    return secret.toString();
  }

  String patchValidateConfig(String content) {
    final regExp = RegExp(
      r'^(\s*geodata-mode\s*:\s*)(true|\x27true\x27|\x22true\x22)(.*)$',
      multiLine: true,
      caseSensitive: false,
    );
    return content.replaceAllMapped(regExp, (match) {
      return '${match.group(1)}false${match.group(3)}';
    });
  }
}

final utils = Utils();
