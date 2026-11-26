import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// Linux arm64 桌面版的字体缺口兜底（flutter#90951 / 修复 PR flutter#180235）。
///
/// 官方发布的 Flutter **linux-arm64** 桌面引擎没有链接 `libfontconfig`
/// （`readelf -d libflutter_linux_gtk.so | grep fontconfig`：x64 有
/// `libfontconfig.so.1`，arm64 没有），引擎自己扫 `/usr/share/fonts` 后拿不到
/// 可用的 CJK 字形回退，于是**界面里的中文整段空白**（拉丁数字正常），
/// 与机器上装了多少中文字体无关 —— Y700 平板（Debian trixie / arm64）实测如此。
///
/// 绕法：启动时把系统里的一份 CJK 字体读成字节，用 [FontLoader] 注册成字体家族
/// （走 asset 字体通道，不经过 fontconfig），再把它设为主字体。
/// 只在 arm64 Linux 生效；引擎上游修好后删掉本文件与 `main.dart` 里的调用即可。
class PlatformFontFallback {
  PlatformFontFallback._();

  /// 注册到引擎里的字体家族名，同时也用作 `ThemeData.fontFamily`。
  static const String family = 'PlatformSystemCjk';

  /// 找不到系统 CJK 字体时退回的随包字体（`pubspec.yaml` 的 `HarmonyOS_Sans`，
  /// 是只覆盖 UI 常用字的子集，够把界面救回来）。
  static const String bundledFamily = 'HarmonyOS_Sans';

  static const List<String> _searchRoots = [
    '/usr/share/fonts',
    '/usr/local/share/fonts',
  ];

  /// 优先单字面 `.ttf`/`.otf`（`.ttc` 集合字体的加载在 skia 上不稳，放到末尾）。
  static const List<String> _preferredSingleFace = [
    'DroidSansFallbackFull.ttf',
    'DroidSansFallback.ttf',
    'NotoSansSC-Regular.otf',
    'NotoSansCJKsc-Regular.otf',
    'SourceHanSansSC-Regular.otf',
    'wqy-zenhei.ttf',
    'WenQuanYiMicroHei.ttf',
  ];

  /// 单字面都没有时的集合字体候选。
  static const List<String> _preferredCollections = [
    'wqy-microhei.ttc',
    'wqy-zenhei.ttc',
    'NotoSansCJK-Regular.ttc',
    'NotoSansCJKsc-Regular.ttc',
  ];

  static final RegExp _cjkNameHint = RegExp(
    r'(cjk|wenquanyi|wqy|droidsansfallback|sourcehan|noto\s?serif\s?sc|noto\s?sans\s?sc|simsun|msyh)',
    caseSensitive: false,
  );

  static bool _loaded = false;

  /// 当前平台是否缺字体回退（只有 arm64 Linux 的官方引擎缺）。
  static bool get isNeeded => Platform.isLinux && Abi.current() == Abi.linuxArm64;

  /// 实际该用的默认字体家族：不需要兜底时返回 null（沿用系统字体）。
  ///
  /// arm64 Linux 上优先用已注册的系统 CJK 字体，加载失败则退回随包 HarmonyOS 子集。
  static String? get defaultFontFamily {
    if (!isNeeded) return null;
    return _loaded ? family : bundledFamily;
  }

  static bool get loaded => _loaded;

  /// 读取并注册系统 CJK 字体；任何失败都静默降级（不阻塞启动）。
  static Future<void> ensureLoaded({List<String>? searchRoots}) async {
    if (_loaded || !isNeeded) return;
    final file = findSystemCjkFont(searchRoots: searchRoots ?? _searchRoots);
    if (file == null) {
      debugPrint('[font] no system CJK font found, fallback to $bundledFamily');
      return;
    }
    try {
      final bytes = await file.readAsBytes();
      final loader = FontLoader(family)
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load();
      _loaded = true;
      debugPrint('[font] registered ${file.path} as $family');
    } catch (e) {
      debugPrint('[font] load ${file.path} failed: $e');
    }
  }

  /// 在字体目录里挑一份 CJK 字体（纯函数，便于单测）。
  static File? findSystemCjkFont({
    List<String> searchRoots = _searchRoots,
  }) {
    final byBaseName = <String, File>{};
    for (final root in searchRoots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;
      List<FileSystemEntity> entries;
      try {
        entries = dir.listSync(recursive: true, followLinks: false);
      } catch (_) {
        continue;
      }
      for (final entry in entries) {
        if (entry is! File) continue;
        final name = p.basename(entry.path).toLowerCase();
        if (!_isFontFile(name)) continue;
        byBaseName.putIfAbsent(name, () => entry);
      }
    }
    if (byBaseName.isEmpty) return null;

    for (final name in _preferredSingleFace) {
      final hit = byBaseName[name.toLowerCase()];
      if (hit != null) return hit;
    }
    // 其次按文件名里的 CJK 线索挑单字面。
    for (final entry in byBaseName.entries) {
      if (entry.key.endsWith('.ttc')) continue;
      if (_cjkNameHint.hasMatch(entry.key)) return entry.value;
    }
    // 最后才用集合字体（先首选名，再线索命中）。
    for (final name in _preferredCollections) {
      final hit = byBaseName[name.toLowerCase()];
      if (hit != null) return hit;
    }
    for (final entry in byBaseName.entries) {
      if (!entry.key.endsWith('.ttc')) continue;
      if (_cjkNameHint.hasMatch(entry.key)) return entry.value;
    }
    return null;
  }

  static bool _isFontFile(String lowerName) =>
      lowerName.endsWith('.ttf') ||
      lowerName.endsWith('.otf') ||
      lowerName.endsWith('.ttc');
}
