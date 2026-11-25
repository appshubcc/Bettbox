import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bett_box/common/common.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as path;

typedef SiteIconImage = ({Uint8List bytes, int source});

class SiteIconCache {
  static const _version = '2';
  static const _missTtl = Duration(days: 7);
  static const _unusedTtl = Duration(days: 60);
  static const _touchAge = Duration(days: 7);
  static const _timeout = Duration(seconds: 10);
  static const _listSize = 32;
  static const _minSize = 32;
  static const _maxSize = 96;
  static const _maxConcurrent = 4;
  static const _maxEntries = 64;

  final Map<String, File?> _files = {};
  final Map<String, Set<int>> _decodedSizes = {};
  final Map<String, Future<File?>> _pending = {};
  final List<Completer<void>> _waiting = [];
  Future<Directory>? _directory;
  int _running = 0;
  int _generation = 0;

  static int get targetSize {
    final ratio =
        ui.PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ?? 2;
    return (_listSize * ratio).ceil().clamp(_minSize, _maxSize);
  }

  bool contains(String domain) => _files.containsKey(domain);

  File? peek(String domain) {
    if (!_files.containsKey(domain)) return null;
    final file = _files.remove(domain);
    _files[domain] = file;
    return file;
  }

  ImageProvider imageOf(
    String domain,
    File file,
    int size, {
    double? devicePixelRatio,
  }) {
    final ratio =
        devicePixelRatio ??
        ui.PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ??
        1.0;
    final decodeSize = (size * ratio).ceil().clamp(1, 512);
    (_decodedSizes[domain] ??= {}).add(decodeSize);
    return ResizeImage(
      FileImage(file),
      width: decodeSize,
      height: decodeSize,
    );
  }

  Future<File?> get(String domain) {
    if (_files.containsKey(domain)) return Future.value(peek(domain));
    final pending = _pending[domain];
    if (pending != null) return pending;
    final generation = _generation;
    late final Future<File?> future;
    future = _load(domain)
        .then((file) {
          if (generation == _generation) _remember(domain, file);
          return file;
        })
        .whenComplete(() {
          if (identical(_pending[domain], future)) _pending.remove(domain);
        });
    _pending[domain] = future;
    return future;
  }

  void _remember(String domain, File? file) {
    _forget(domain);
    while (_files.length >= _maxEntries) {
      _forget(_files.keys.first);
    }
    _files[domain] = file;
  }

  void _forget(String domain) {
    final file = _files.remove(domain);
    final sizes = _decodedSizes.remove(domain);
    if (file == null || sizes == null) return;
    for (final size in sizes) {
      ResizeImage(FileImage(file), width: size, height: size)
          .obtainKey(ImageConfiguration.empty)
          .then((key) => imageCache.evict(key, includeLive: false));
    }
  }

  Future<String> get _directoryPath async =>
      path.join(await appPath.homeDirPath, 'site_icons');

  Future<Directory> _openDirectory() {
    return _directory ??= _prepareDirectory().catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _directory = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  Future<Directory> _prepareDirectory() async {
    final directory = Directory(await _directoryPath);
    final versionFile = File(path.join(directory.path, '.version'));
    if (await versionFile.exists() &&
        await versionFile.readAsString() == _version) {
      await _prune(directory);
      return directory;
    }
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);
    await versionFile.writeAsString(_version, flush: true);
    return directory;
  }

  Future<void> _prune(Directory directory) async {
    final now = DateTime.now();
    try {
      await for (final entity in directory.list()) {
        if (entity is! File || path.basename(entity.path) == '.version') {
          continue;
        }
        final ttl = entity.path.endsWith('.png') ? _unusedTtl : _missTtl;
        try {
          if (now.difference(await entity.lastModified()) >= ttl) {
            await entity.delete();
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> clear() async {
    _generation++;
    for (final domain in _files.keys.toList()) {
      _forget(domain);
    }
    _decodedSizes.clear();
    _directory = null;
    try {
      final directory = Directory(await _directoryPath);
      if (await directory.exists()) await directory.delete(recursive: true);
    } catch (_) {}
  }

  Future<File?> _load(String domain) async {
    try {
      return await _loadFile(domain);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _loadFile(String domain) async {
    final directory = await _openDirectory();
    final iconFile = File(path.join(directory.path, '$domain.png'));
    if (await iconFile.exists()) {
      await _touch(iconFile);
      return iconFile;
    }
    final missFile = File(path.join(directory.path, '$domain.miss'));
    if (await missFile.exists()) {
      final modified = await missFile.lastModified();
      if (DateTime.now().difference(modified) < _missTtl) return null;
    }
    final icon = await _fetch(domain, targetSize);
    if (icon == null) {
      await missFile.writeAsString('');
      return null;
    }
    final tempFile = File('${iconFile.path}.tmp');
    await tempFile.writeAsBytes(icon, flush: true);
    await tempFile.rename(iconFile.path);
    if (await missFile.exists()) await missFile.delete();
    return iconFile;
  }

  Future<void> _touch(File file) async {
    try {
      final now = DateTime.now();
      if (now.difference(await file.lastModified()) >= _touchAge) {
        await file.setLastModified(now);
      }
    } catch (_) {}
  }

  @visibleForTesting
  static List<String> candidates(String domain, int size) => [
    'https://$domain/apple-touch-icon.png',
    'https://$domain/favicon.ico',
    'https://www.google.com/s2/favicons?domain=${Uri.encodeComponent(domain)}&sz=$size',
  ];

  Future<Uint8List?> _fetch(String domain, int size) async {
    await _acquire();
    try {
      SiteIconImage? best;
      for (final url in candidates(domain, size)) {
        final icon = await _download(url, size);
        if (icon == null) continue;
        if (icon.source >= size) return icon.bytes;
        if (best == null || icon.source > best.source) best = icon;
      }
      return best?.bytes;
    } finally {
      _release();
    }
  }

  Future<SiteIconImage?> _download(String url, int size) async {
    final cancelToken = CancelToken();
    final timer = Timer(_timeout, cancelToken.cancel);
    try {
      final bytes = await request.getBytes(url, cancelToken: cancelToken);
      if (bytes == null || bytes.isEmpty) return null;
      return await normalizeSiteIcon(bytes, size);
    } catch (_) {
      return null;
    } finally {
      timer.cancel();
    }
  }

  Future<void> _acquire() async {
    if (_running < _maxConcurrent) {
      _running++;
      return;
    }
    final completer = Completer<void>();
    _waiting.add(completer);
    await completer.future;
  }

  void _release() {
    if (_waiting.isEmpty) {
      _running--;
      return;
    }
    _waiting.removeAt(0).complete();
  }

  static bool _hasPngSignature(Uint8List bytes, int offset) {
    return offset + 8 <= bytes.length &&
        bytes[offset] == 0x89 &&
        bytes[offset + 1] == 0x50 &&
        bytes[offset + 2] == 0x4E &&
        bytes[offset + 3] == 0x47 &&
        bytes[offset + 4] == 0x0D &&
        bytes[offset + 5] == 0x0A &&
        bytes[offset + 6] == 0x1A &&
        bytes[offset + 7] == 0x0A;
  }

  static Uint8List? _extractIcoPayload(Uint8List bytes) {
    if (bytes.length < 6) return null;
    final data = ByteData.sublistView(bytes);
    final reserved = data.getUint16(0, Endian.little);
    final type = data.getUint16(2, Endian.little);
    if (reserved != 0 || type != 1) return bytes;
    final count = data.getUint16(4, Endian.little);
    final headerEnd = 6 + count * 16;
    if (count == 0 || headerEnd > bytes.length) return null;

    var bestIndex = -1;
    var bestOffset = 0;
    var bestLength = 0;
    var bestArea = -1;
    var bestBits = -1;
    var bestIsPng = false;

    for (var i = 0; i < count; i++) {
      final entry = 6 + i * 16;
      final length = data.getUint32(entry + 8, Endian.little);
      final offset = data.getUint32(entry + 12, Endian.little);
      if (length == 0 || offset < headerEnd || offset + length > bytes.length) {
        continue;
      }
      final isPng = length >= 24 && _hasPngSignature(bytes, offset);
      final int width;
      final int height;
      if (isPng) {
        width = data.getUint32(offset + 16, Endian.big);
        height = data.getUint32(offset + 20, Endian.big);
      } else {
        final rawW = bytes[entry];
        final rawH = bytes[entry + 1];
        width = rawW == 0 ? 256 : rawW;
        height = rawH == 0 ? 256 : rawH;
      }
      if (width <= 0 || height <= 0) continue;
      final bits = isPng
          ? math.max(data.getUint16(entry + 6, Endian.little), 32)
          : data.getUint16(entry + 6, Endian.little);
      final area = width * height;
      if (area > bestArea ||
          (area == bestArea &&
              (bits > bestBits || (bits == bestBits && length > bestLength)))) {
        bestIndex = i;
        bestOffset = offset;
        bestLength = length;
        bestArea = area;
        bestBits = bits;
        bestIsPng = isPng;
      }
    }

    if (bestIndex < 0) return null;
    if (bestIsPng) {
      return Uint8List.sublistView(bytes, bestOffset, bestOffset + bestLength);
    }
    if (count == 1 && bestOffset == 22 && bestLength == bytes.length - 22) {
      return bytes;
    }
    final single = Uint8List(22 + bestLength);
    single[2] = 1;
    single[4] = 1;
    final bestEntry = 6 + bestIndex * 16;
    single.setRange(6, 18, bytes, bestEntry);
    single[18] = 22;
    single.setRange(22, 22 + bestLength, bytes, bestOffset);
    return single;
  }

  static Future<SiteIconImage?> normalizeSiteIcon(
    Uint8List bytes,
    int size,
  ) async {
    if (bytes.length < 8 || size <= 0) return null;
    final payload = _extractIcoPayload(bytes);
    if (payload == null) return null;
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? frameImage;
    ui.Picture? picture;
    ui.Image? squareImage;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(payload);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final srcW = descriptor.width;
      final srcH = descriptor.height;
      if (srcW < 8 || srcH < 8) return null;
      final source = math.max(srcW, srcH);
      final side = math.min(source, size);
      final width = math.max((srcW * side / source).round(), 1);
      final height = math.max((srcH * side / source).round(), 1);
      codec = await descriptor.instantiateCodec(
        targetWidth: width,
        targetHeight: height,
      );
      final frame = await codec.getNextFrame();
      frameImage = frame.image;
      final ui.Image output;
      if (frameImage.width == side &&
          frameImage.height == side &&
          width == side &&
          height == side) {
        output = frameImage;
      } else {
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        final dx = ((side - width) ~/ 2).toDouble();
        final dy = ((side - height) ~/ 2).toDouble();
        canvas.drawImageRect(
          frameImage,
          ui.Rect.fromLTWH(
            0,
            0,
            frameImage.width.toDouble(),
            frameImage.height.toDouble(),
          ),
          ui.Rect.fromLTWH(dx, dy, width.toDouble(), height.toDouble()),
          ui.Paint()
            ..isAntiAlias = true
            ..filterQuality = ui.FilterQuality.medium,
        );
        picture = recorder.endRecording();
        squareImage = await picture.toImage(side, side);
        output = squareImage;
      }
      final encoded = await output.toByteData(format: ui.ImageByteFormat.png);
      if (encoded == null) return null;
      return (bytes: Uint8List.sublistView(encoded), source: source);
    } catch (_) {
      return null;
    } finally {
      squareImage?.dispose();
      picture?.dispose();
      frameImage?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}

final siteIconCache = SiteIconCache();

class SiteIcon extends StatefulWidget {
  final String domain;
  final double size;
  final bool enabled;

  const SiteIcon({
    super.key,
    required this.domain,
    this.size = 32,
    this.enabled = true,
  });

  @override
  State<SiteIcon> createState() => _SiteIconState();
}

final _telegramNetworks = [
  for (final cidr in telegramCidrs) ?_parseNetwork(cidr),
];

(Uint8List, int)? _parseNetwork(String cidr) {
  final parts = cidr.split('/');
  final address = InternetAddress.tryParse(parts.first);
  final prefix = parts.length == 2 ? int.tryParse(parts.last) : null;
  if (address == null || prefix == null) return null;
  return (address.rawAddress, prefix);
}

bool _inNetwork(Uint8List address, (Uint8List, int) network) {
  final (base, prefix) = network;
  if (address.length != base.length || prefix > base.length * 8) return false;
  final bytes = prefix ~/ 8;
  for (var i = 0; i < bytes; i++) {
    if (address[i] != base[i]) return false;
  }
  final bits = prefix % 8;
  if (bits == 0) return true;
  final mask = (0xFF << (8 - bits)) & 0xFF;
  return address[bytes] & mask == base[bytes] & mask;
}

String siteIconDomainOf(String host) {
  final address = InternetAddress.tryParse(host);
  if (address == null) return host;
  final raw = address.rawAddress;
  return _telegramNetworks.any((network) => _inNetwork(raw, network))
      ? 'telegram.org'
      : host;
}

class _SiteIconState extends State<SiteIcon> {
  File? _icon;

  String _domain = '';
  bool _isAddress = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(SiteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.domain != widget.domain ||
        oldWidget.enabled != widget.enabled) {
      _resolve();
    }
  }

  void _resolve() {
    final host = widget.domain;
    final domain = _domain = siteIconDomainOf(host);
    _isAddress = InternetAddress.tryParse(domain) != null;
    _icon = siteIconCache.peek(domain);
    if (!widget.enabled || _isAddress || domain.isEmpty) return;
    if (siteIconCache.contains(domain)) return;
    siteIconCache.get(domain).then((icon) {
      if (!mounted || widget.domain != host) return;
      setState(() => _icon = icon);
    });
  }

  Widget _buildPlaceholder(BuildContext context, BorderRadius radius) {
    final colorScheme = context.colorScheme;
    final size = widget.size;
    final letter = widget.domain.isEmpty
        ? '?'
        : widget.domain.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: radius,
      ),
      child: _isAddress
          ? AppIcon(Icons.public, size: size * 0.56, color: colorScheme.primary)
          : Text(
              letter,
              style: TextStyle(
                fontSize: size * 0.44,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                height: 1,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final radius = BorderRadius.circular(size * 0.28);
    final placeholder = _buildPlaceholder(context, radius);
    final icon = widget.enabled ? _icon : null;
    if (icon == null) return placeholder;
    return ClipRRect(
      borderRadius: radius,
      child: Image(
        image: siteIconCache.imageOf(
          _domain,
          icon,
          size.toInt(),
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
            wasSynchronouslyLoaded || frame != null ? child : placeholder,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
