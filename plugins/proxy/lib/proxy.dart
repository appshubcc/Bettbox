import 'dart:io';

import "package:path/path.dart";

import 'proxy_platform_interface.dart';

enum ProxyTypes { http, https, socks }

class Proxy extends ProxyPlatform {
  static String url = "127.0.0.1";

  @override
  Future<bool?> startProxy(
    int port, [
    List<String> bypassDomain = const [],
  ]) async {
    return switch (Platform.operatingSystem) {
      "macos" => await _startProxyWithMacos(port, bypassDomain),
      "linux" => await _startProxyWithLinux(port, bypassDomain),
      "windows" => await ProxyPlatform.instance.startProxy(port, bypassDomain),
      String() => false,
    };
  }

  @override
  Future<bool?> stopProxy() async {
    return switch (Platform.operatingSystem) {
      "macos" => await _stopProxyWithMacos(),
      "linux" => await _stopProxyWithLinux(),
      "windows" => await ProxyPlatform.instance.stopProxy(),
      String() => false,
    };
  }

  Future<String> _getKWriteConfigCmd() async {
    try {
      final res =
          await Process.run('which', ['kwriteconfig6'], runInShell: true);
      if (res.exitCode == 0) return 'kwriteconfig6';
    } catch (_) {}
    return 'kwriteconfig5';
  }

  Future<bool> _startProxyWithLinux(int port, List<String> bypassDomain) async {
    try {
      final homeDir = Platform.environment['HOME']!;
      final configDir = join(homeDir, ".config");
      final cmdList = List<List<String>>.empty(growable: true);
      final desktop = Platform.environment['XDG_CURRENT_DESKTOP'] ?? "";
      final isKDE = desktop.toUpperCase().contains("KDE");

      if (isKDE) {
        final kwriteconfig = await _getKWriteConfigCmd();
        cmdList.add(
          [
            kwriteconfig,
            "--file",
            "$configDir/kioslaverc",
            "--group",
            "Proxy Settings",
            "--key",
            "ProxyType",
            "1"
          ],
        );
        cmdList.add(
          [
            kwriteconfig,
            "--file",
            "$configDir/kioslaverc",
            "--group",
            "Proxy Settings",
            "--key",
            "NoProxyFor",
            bypassDomain.join(",")
          ],
        );
      } else {
        cmdList.add(
          ["gsettings", "set", "org.gnome.system.proxy", "mode", "manual"],
        );
        final ignoreHosts = _gnomeIgnoreHosts(bypassDomain);
        cmdList.add(
          [
            "gsettings",
            "set",
            "org.gnome.system.proxy",
            "ignore-hosts",
            ignoreHosts
          ],
        );
      }
      for (final type in ProxyTypes.values) {
        if (!isKDE) {
          cmdList.add(
            [
              "gsettings",
              "set",
              "org.gnome.system.proxy.${type.name}",
              "host",
              url
            ],
          );
          cmdList.add(
            [
              "gsettings",
              "set",
              "org.gnome.system.proxy.${type.name}",
              "port",
              "$port"
            ],
          );
        }
        if (isKDE) {
          final kwriteconfig = await _getKWriteConfigCmd();
          final protocol = type == ProxyTypes.socks ? 'socks' : 'http';
          cmdList.add(
            [
              kwriteconfig,
              "--file",
              "$configDir/kioslaverc",
              "--group",
              "Proxy Settings",
              "--key",
              "${type.name}Proxy",
              "$protocol://$url:$port"
            ],
          );
        }
      }
      if (isKDE) {
        cmdList.add([
          "dbus-send",
          "--type=method_call",
          "--dest=org.kde.KIO",
          "/KIO/kioslave",
          "org.kde.KIO.kioslave.reparseConfiguration"
        ]);
      }
      for (final cmd in cmdList) {
        await Process.run(cmd[0], cmd.sublist(1), runInShell: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  String _gnomeIgnoreHosts(List<String> bypassDomain) {
    final hosts = bypassDomain.map((host) {
      final prefix = RegExp(r'^(\d{1,3}(?:\.\d{1,3}){0,2})\.\*$')
          .firstMatch(host)
          ?.group(1);
      if (prefix != null) {
        final octets = prefix.split(".");
        final address = [...octets, ...List.filled(4 - octets.length, "0")];
        return "${address.join(".")}/${octets.length * 8}";
      }
      if (host.startsWith("[") && host.endsWith("]")) {
        return host.substring(1, host.length - 1);
      }
      return host;
    }).map(
        (host) => "'${host.replaceAll(r"\", r"\\").replaceAll("'", r"\'")}'");
    return "[${hosts.join(", ")}]";
  }

  Future<bool> _stopProxyWithLinux() async {
    try {
      final homeDir = Platform.environment['HOME']!;
      final configDir = join(homeDir, ".config/");
      final cmdList = List<List<String>>.empty(growable: true);
      final desktop = Platform.environment['XDG_CURRENT_DESKTOP'] ?? "";
      final isKDE = desktop.toUpperCase().contains("KDE");
      if (isKDE) {
        final kwriteconfig = await _getKWriteConfigCmd();
        cmdList.add(
          [
            kwriteconfig,
            "--file",
            "$configDir/kioslaverc",
            "--group",
            "Proxy Settings",
            "--key",
            "ProxyType",
            "0"
          ],
        );
        cmdList.add([
          "dbus-send",
          "--type=method_call",
          "--dest=org.kde.KIO",
          "/KIO/kioslave",
          "org.kde.KIO.kioslave.reparseConfiguration"
        ]);
      } else {
        cmdList.add(
          ["gsettings", "set", "org.gnome.system.proxy", "mode", "none"],
        );
      }
      for (final cmd in cmdList) {
        await Process.run(cmd[0], cmd.sublist(1), runInShell: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _startProxyWithMacos(int port, List<String> bypassDomain) async {
    try {
      final devices = await _getNetworkDeviceListWithMacos();
      for (final dev in devices) {
        await Future.wait([
          Process.run(
            "/usr/sbin/networksetup",
            ["-setwebproxystate", dev, "on"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setwebproxy", dev, url, "$port"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setsecurewebproxystate", dev, "on"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setsecurewebproxy", dev, url, "$port"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setsocksfirewallproxystate", dev, "on"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setsocksfirewallproxy", dev, url, "$port"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            [
              "-setproxybypassdomains",
              dev,
              ...bypassDomain.isEmpty ? ["Empty"] : bypassDomain,
            ],
          ),
        ]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _stopProxyWithMacos() async {
    try {
      final devices = await _getNetworkDeviceListWithMacos();
      for (final dev in devices) {
        await Future.wait([
          Process.run(
            "/usr/sbin/networksetup",
            ["-setautoproxystate", dev, "off"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setwebproxystate", dev, "off"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setsecurewebproxystate", dev, "off"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setsocksfirewallproxystate", dev, "off"],
          ),
          Process.run(
            "/usr/sbin/networksetup",
            ["-setproxybypassdomains", dev, "Empty"],
          ),
        ]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> _getNetworkDeviceListWithMacos() async {
    final res = await Process.run(
        "/usr/sbin/networksetup", ["-listallnetworkservices"]);
    final lines = res.stdout.toString().split("\n");
    lines.removeWhere((element) => element.contains("*"));
    return lines;
  }
}
