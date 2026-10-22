import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bett_box/common/system.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';
import 'package:window_ext/window_ext.dart';

class ProcessIconData {
  final Uint8List? bytes;
  final String? path;

  const ProcessIconData.bytes(this.bytes) : path = null;

  const ProcessIconData.path(this.path) : bytes = null;

  bool get isSvg => path?.toLowerCase().endsWith('.svg') ?? false;
}

class ProcessIcon {
  static const _size = 96;
  static const _windowsSource = 128;

  Future<Map<String, String>>? _linuxIndex;
  Future<void> _tail = Future.value();

  static const _safariApps = [
    '/Applications/Safari.app',
    '/System/Cryptexes/App/System/Applications/Safari.app',
    '/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app',
  ];

  String keyOf(String path) {
    if (path.isEmpty) return path;
    if (system.isMacOS) {
      final bundle = _macBundle(path);
      return bundle.endsWith('.app') ? bundle : '';
    }
    if (system.isLinux) return p.basename(path).toLowerCase();
    return path;
  }

  Future<ProcessIconData?> get(String path) async {
    if (path.isEmpty) return null;
    final task = _tail.then((_) => _load(path));
    _tail = task.then((_) {}, onError: (_) {});
    return task;
  }

  Future<ProcessIconData?> _load(String path) async {
    try {
      if (system.isMacOS) return await _getMacOS(path);
      if (system.isWindows) return await _getWindows(path);
      if (system.isLinux) return await _getLinux(path);
    } catch (_) {}
    return null;
  }

  Future<ProcessIconData?> _getMacOS(String path) async {
    final bundle = _macBundle(path);
    if (!bundle.endsWith('.app')) return null;
    final bytes = await windowExtManager.getFileIcon(bundle, _size);
    return bytes == null ? null : ProcessIconData.bytes(bytes);
  }

  static String _macBundle(String path) {
    final index = path.indexOf('.app/');
    if (index != -1) return path.substring(0, index + 4);
    if (p.basename(path).startsWith('com.apple.WebKit.')) {
      for (final app in _safariApps) {
        if (Directory(app).existsSync()) return app;
      }
    }
    return path;
  }

  Future<ProcessIconData?> _getWindows(String path) async {
    final bitmap = _readWindowsIcon(path);
    if (bitmap == null) return null;
    final (pixels, width, height) = bitmap;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.bgra8888,
      completer.complete,
      targetWidth: _size,
      targetHeight: _size,
      allowUpscaling: false,
    );
    final image = await completer.future;
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final bytes = data?.buffer.asUint8List();
    return bytes == null ? null : ProcessIconData.bytes(bytes);
  }

  (Uint8List, int, int)? _readWindowsIcon(String path) {
    return using((arena) {
      final pathPtr = path.toNativeUtf16(allocator: arena);
      final iconPtr = arena<Pointer>();
      final count = PrivateExtractIcons(
        PCWSTR(pathPtr),
        0,
        _windowsSource,
        _windowsSource,
        iconPtr,
        nullptr,
        1,
        0,
      );
      var hIcon = count > 0 && count != 0xFFFFFFFF
          ? HICON(iconPtr.value)
          : HICON(nullptr);
      if (!hIcon.isValid) {
        final info = arena<SHFILEINFO>();
        final res = SHGetFileInfo(
          PCWSTR(pathPtr),
          const FILE_FLAGS_AND_ATTRIBUTES(0),
          info,
          sizeOf<SHFILEINFO>(),
          SHGFI_FLAGS(SHGFI_ICON | SHGFI_LARGEICON),
        );
        if (res != 0) {
          hIcon = info.ref.hIcon;
        }
      }
      if (!hIcon.isValid) return null;
      final iconInfo = arena<ICONINFO>();
      if (!GetIconInfo(hIcon, iconInfo).value) {
        hIcon.close();
        return null;
      }
      final hbmColor = iconInfo.ref.hbmColor;
      final hbmMask = iconInfo.ref.hbmMask;
      final hdc = GetDC(null);
      try {
        if (!hbmColor.isValid) return null;
        final bitmap = arena<BITMAP>();
        if (GetObject(HGDIOBJ(hbmColor), sizeOf<BITMAP>(), bitmap) == 0) {
          return null;
        }
        final width = bitmap.ref.bmWidth;
        final height = bitmap.ref.bmHeight;
        if (width <= 0 || height <= 0) return null;
        final bmi = arena<BITMAPINFO>();
        bmi.ref.bmiHeader
          ..biSize = sizeOf<BITMAPINFOHEADER>()
          ..biWidth = width
          ..biHeight = -height
          ..biPlanes = 1
          ..biBitCount = 32
          ..biCompression = BI_RGB;
        final length = width * height * 4;
        final bits = arena<Uint8>(length);
        final lines = GetDIBits(
          hdc,
          hbmColor,
          0,
          height,
          bits,
          bmi,
          const DIB_USAGE(DIB_RGB_COLORS),
        );
        if (lines == 0) return null;
        final pixels = Uint8List.fromList(bits.asTypedList(length));
        var hasAlpha = false;
        for (var i = 3; i < length; i += 4) {
          if (pixels[i] != 0) {
            hasAlpha = true;
            break;
          }
        }
        for (var i = 0; i < length; i += 4) {
          if (!hasAlpha) {
            pixels[i + 3] = 255;
            continue;
          }
          final alpha = pixels[i + 3];
          if (alpha == 255) continue;
          pixels[i] = pixels[i] * alpha ~/ 255;
          pixels[i + 1] = pixels[i + 1] * alpha ~/ 255;
          pixels[i + 2] = pixels[i + 2] * alpha ~/ 255;
        }
        return (pixels, width, height);
      } finally {
        ReleaseDC(null, hdc);
        if (hbmColor.isValid) hbmColor.close();
        if (hbmMask.isValid) hbmMask.close();
        hIcon.close();
      }
    });
  }

  Future<ProcessIconData?> _getLinux(String path) async {
    final index = await (_linuxIndex ??= Isolate.run(_buildLinuxIndex));
    final name = p.basename(path).toLowerCase();
    final icon = index[name];
    if (icon == null) return null;
    if (p.isAbsolute(icon)) {
      return File(icon).existsSync() ? ProcessIconData.path(icon) : null;
    }
    // Let GTK resolve the name against the active icon theme. It returns the
    // real file path, which may be an SVG; rendering is the caller's job.
    final resolved = await windowExtManager.getIconPath(
      _stripIconExtension(icon),
      size: _size,
    );
    return resolved == null ? null : ProcessIconData.path(resolved);
  }

  static List<String> get _linuxDataDirs {
    final home = Platform.environment['HOME'] ?? '';
    return [
      if (home.isNotEmpty) p.join(home, '.local/share'),
      if (home.isNotEmpty) p.join(home, '.local/share/flatpak/exports/share'),
      '/usr/local/share',
      '/usr/share',
      '/var/lib/flatpak/exports/share',
      '/var/lib/snapd/desktop',
    ];
  }

  static Map<String, String> _buildLinuxIndex() {
    final index = <String, String>{};
    for (final dataDir in _linuxDataDirs) {
      final dir = Directory(p.join(dataDir, 'applications'));
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true, followLinks: true)) {
        if (entity is! File || !entity.path.endsWith('.desktop')) continue;
        String? exec;
        String? icon;
        try {
          for (final line in entity.readAsLinesSync()) {
            if (exec == null && line.startsWith('Exec=')) {
              exec = _parseLinuxExec(line.substring(5));
            } else if (icon == null && line.startsWith('Icon=')) {
              icon = line.substring(5).trim();
            }
            if (exec != null && icon != null) break;
          }
        } catch (_) {
          continue;
        }
        if (icon == null || icon.isEmpty) continue;
        if (exec != null && exec.isNotEmpty) {
          index.putIfAbsent(exec, () => icon!);
        }
        index.putIfAbsent(
          p.basenameWithoutExtension(entity.path).toLowerCase(),
          () => icon!,
        );
      }
    }
    return index;
  }

  static String? _parseLinuxExec(String value) {
    final tokens = value.trim().split(RegExp(r'\s+'));
    for (final token in tokens) {
      final text = token.replaceAll('"', '').replaceAll("'", '');
      if (text.isEmpty || text == 'env' || text.contains('=')) continue;
      return p.basename(text).toLowerCase();
    }
    return null;
  }

  static String _stripIconExtension(String name) {
    final lower = name.toLowerCase();
    for (final ext in const ['.png', '.svg', '.xpm', '.ico']) {
      if (lower.endsWith(ext)) {
        return name.substring(0, name.length - ext.length);
      }
    }
    return name;
  }
}

final processIcon = ProcessIcon();
