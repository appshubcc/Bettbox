import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PlatformDispatcher;

import 'package:bett_box/common/common.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
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
        PlatformDispatcher.instance.views.firstOrNull?.devicePixelRatio ?? 2;
    return (_listSize * ratio).ceil().clamp(_minSize, _maxSize);
  }

  bool contains(String domain) => _files.containsKey(domain);

  File? peek(String domain) {
    if (!_files.containsKey(domain)) return null;
    final file = _files.remove(domain);
    _files[domain] = file;
    return file;
  }

  ImageProvider imageOf(String domain, File file, int size) {
    (_decodedSizes[domain] ??= {}).add(size);
    return ResizeImage(FileImage(file), width: size, height: size);
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
      return await Isolate.run(() => normalizeSiteIcon(bytes, size));
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

  static img.Image? _decodeLargest(Uint8List bytes) {
    final decoder = img.findDecoderForData(bytes);
    if (decoder is img.IcoDecoder) return decoder.decodeImageLargest(bytes);
    return decoder?.decode(bytes, frame: 0);
  }

  static SiteIconImage? normalizeSiteIcon(Uint8List bytes, int size) {
    final image = _decodeLargest(bytes);
    if (image == null || image.width < 8 || image.height < 8) return null;
    final source = math.max(image.width, image.height);
    final side = math.min(source, size);
    final width = math.max((image.width * side / source).round(), 1);
    final height = math.max((image.height * side / source).round(), 1);
    final resized = width == image.width && height == image.height
        ? image
        : img.copyResize(
            image,
            width: width,
            height: height,
            interpolation: img.Interpolation.average,
          );
    final square = width == height
        ? resized
        : img.compositeImage(
            img.Image(width: side, height: side, numChannels: 4),
            resized,
            center: true,
          );
    return (bytes: img.encodePng(square, singleFrame: true), source: source);
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

class _SiteIconState extends State<SiteIcon> {
  File? _icon;

  bool get _isAddress => InternetAddress.tryParse(widget.domain) != null;

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
    final domain = widget.domain;
    _icon = siteIconCache.peek(domain);
    if (!widget.enabled || _isAddress || domain.isEmpty) return;
    if (siteIconCache.contains(domain)) return;
    siteIconCache.get(domain).then((icon) {
      if (!mounted || widget.domain != domain) return;
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
          ? Icon(Icons.public, size: size * 0.56, color: colorScheme.primary)
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
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
    return ClipRRect(
      borderRadius: radius,
      child: Image(
        image: siteIconCache.imageOf(widget.domain, icon, pixels),
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
