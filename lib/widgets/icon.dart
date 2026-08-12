import 'dart:io';
import 'dart:ui' as ui;
import 'package:bett_box/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xml/xml.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

class CommonTargetIcon extends StatefulWidget {
  final String src;
  final double size;

  const CommonTargetIcon({super.key, required this.src, required this.size});

  @override
  State<CommonTargetIcon> createState() => _CommonTargetIconState();
}

class _CommonTargetIconState extends State<CommonTargetIcon> {
  File? _file;
  String? _cachedSrc; // Cached src
  int? _cachedSize; // Cached size
  bool _didSyncCheck = false; // Guard for didChangeDependencies

  static final Map<String, File?> _moduleFileCache = {};
  static final Map<String, bool> _moduleSvgValidCache = {};
  static final Map<String, DateTime> _moduleFailureCache = {};
  static const _maxCacheEntries = 80;
  static const _failureCooldownSeconds = 10;

  String _moduleCacheKey(int cacheSize) {
    if (widget.src.isSvg) return 'svg|${widget.src}';
    return 'bmp|${widget.src}|$cacheSize';
  }

  static void _ensureCacheLimit() {
    while (_moduleFileCache.length > _maxCacheEntries) {
      _moduleFileCache.remove(_moduleFileCache.keys.first);
    }
    while (_moduleSvgValidCache.length > _maxCacheEntries) {
      _moduleSvgValidCache.remove(_moduleSvgValidCache.keys.first);
    }
  }

  bool _shouldRetry(String mKey) {
    final failedAt = _moduleFailureCache[mKey];
    if (failedAt == null) return true;
    if (DateTime.now().difference(failedAt).inSeconds <
        _failureCooldownSeconds) {
      return false;
    }
    _moduleFailureCache.remove(mKey);
    return true;
  }

  void _syncCheckAndInit() {
    if (widget.src.isEmpty || widget.src.getBase64 != null) return;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (widget.size * devicePixelRatio).ceil();
    final key = _moduleCacheKey(cacheSize);

    final cachedFile = _moduleFileCache[key] ?? _findCachedFileForSrc(widget.src);
    final syncHit = cachedFile != null;

    if (syncHit) {
      _cachedSrc = widget.src;
      _cachedSize = cacheSize;
      _file = cachedFile;
    }
    _init(cacheSize);
  }

  @override
  void didUpdateWidget(covariant CommonTargetIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src || oldWidget.size != widget.size) {
      _file = null;
      _cachedSrc = null;
      _cachedSize = null;
      _didSyncCheck = true;
      _syncCheckAndInit();
    }
  }

  static File? _findCachedFileForSrc(String src) {
    if (src.isSvg) {
      return _moduleFileCache['svg|$src'];
    }
    for (final entry in _moduleFileCache.entries) {
      if (entry.key.startsWith('bmp|$src|') && entry.value != null) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSyncCheck) return;
    _didSyncCheck = true;
    _syncCheckAndInit();
  }

  /// Generate resized cache path
  Future<String> _getResizedCachePath(String originalPath, int size) async {
    final hash = md5.convert(utf8.encode('${originalPath}_$size')).toString();
    final tempDir = await appPath.tempPath;
    return path.join(tempDir, 'resized_icons', '$hash.png');
  }

  /// Decode, resize and cache image to disk
  Future<File?> _resizeAndCacheImage(File originalFile, int targetSize) async {
    try {
      final cachePath = await _getResizedCachePath(
        originalFile.path,
        targetSize,
      );
      final cacheFile = File(cachePath);

      // Return cached file if exists
      if (await cacheFile.exists()) {
        return cacheFile;
      }

      // Read original image
      final bytes = await originalFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetSize,
        targetHeight: targetSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Convert to PNG bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return null;
      }

      // Save to disk
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsBytes(byteData.buffer.asUint8List());

      return cacheFile;
    } catch (e) {
      // Resize failed, verify original file is decodable before falling back
      try {
        final bytes = await originalFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        await codec.getNextFrame();
        return originalFile;
      } catch (_) {
        return null;
      }
    }
  }

  /// Validate and sanitize SVG file
  Future<bool> _validateSvg(File file) async {
    try {
      final content = await file.readAsString();
      final trimmed = content.trim();

      // Check if content starts with valid SVG/XML tags
      if (!trimmed.startsWith('<svg') &&
          !trimmed.startsWith('<?xml') &&
          !trimmed.startsWith('<!DOCTYPE svg')) {
        commonPrint.log('Invalid SVG: not starting with svg tag');
        return false;
      }

      // Check for HTML error pages
      if (trimmed.contains('<!DOCTYPE html>') ||
          trimmed.contains('<html>') ||
          trimmed.contains('<head>') ||
          trimmed.contains('<body>')) {
        commonPrint.log('Invalid SVG: HTML content detected');
        return false;
      }

      // Validate XML structure
      try {
        XmlDocument.parse(content);
      } catch (e) {
        commonPrint.log('Invalid SVG: XML parse error - $e');
        return false;
      }

      // Fix invalid font-weight values
      if (content.contains('font-weight:none') ||
          content.contains('font-weight: none')) {
        final fixed = content
            .replaceAll('font-weight:none', 'font-weight:normal')
            .replaceAll('font-weight: none', 'font-weight: normal');
        await file.writeAsString(fixed);
      }
      return true;
    } catch (e) {
      commonPrint.log('SVG validation failed: $e');
      return false;
    }
  }

  Future<void> _init(int cacheSize) async {
    if (widget.src.isEmpty) {
      return;
    }
    if (widget.src.getBase64 != null) {
      return;
    }

    // If cached with same src and size, return directly
    if (_cachedSrc == widget.src && _cachedSize == cacheSize && _file != null) {
      return;
    }

    final mKey = _moduleCacheKey(cacheSize);

    // Check module-level cache: another instance (or a previous
    // expand/collapse) may have already loaded this URL at the same size.
    // The cached File is already display-ready — no async resize needed.
    if (_moduleFileCache.containsKey(mKey)) {
      final cachedFile = _moduleFileCache[mKey];
      if (cachedFile == null) return; // permanently invalid

      if (mounted) {
        setState(() {
          _file = cachedFile;
          _cachedSrc = widget.src;
          _cachedSize = cacheSize;
        });
      }
      return;
    }

    if (!_shouldRetry(mKey)) return;

    // Get from cache first, no network check
    final fileInfo = await DefaultCacheManager().getFileFromCache(widget.src);
    if (fileInfo != null && mounted && widget.src.isNotEmpty) {
      await _processFile(fileInfo.file, cacheSize, mKey);
      return;
    }

    // Download if cache not exists
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.src);
      if (mounted && widget.src.isNotEmpty) {
        await _processFile(file, cacheSize, mKey);
      }
    } catch (e) {
      // Transient network failure: record cooldown, do not mark permanent.
      _moduleFailureCache[mKey] = DateTime.now();
    }
  }

  Future<void> _processFile(File file, int cacheSize, String mKey) async {
    if (widget.src.isSvg) {
      final isValid = await _validateSvg(file);
      if (!isValid) {
        await DefaultCacheManager().removeFile(widget.src);
        _moduleFileCache[mKey] = null;
        _moduleFailureCache.remove(mKey);
        if (mounted) {
          setState(() {
            _file = null;
            _cachedSrc = null;
            _cachedSize = null;
          });
        }
        return;
      }
      _moduleFileCache[mKey] = file;
      _moduleSvgValidCache[widget.src] = true;
      _moduleFailureCache.remove(mKey);
      _ensureCacheLimit();
      if (mounted) {
        setState(() {
          _file = file;
          _cachedSrc = widget.src;
          _cachedSize = cacheSize;
        });
      }
      return;
    }

    final displayFile = (await _resizeAndCacheImage(file, cacheSize)) ?? file;
    _moduleFileCache[mKey] = displayFile;
    _moduleFailureCache.remove(mKey);
    _ensureCacheLimit();
    if (mounted) {
      setState(() {
        _file = displayFile;
        _cachedSrc = widget.src;
        _cachedSize = cacheSize;
      });
    }
  }

  Widget _defaultIcon() {
    return Icon(IconsExt.target, size: widget.size);
  }

  Widget _buildIcon() {
    if (widget.src.isEmpty) {
      return _defaultIcon();
    }
    final base64 = widget.src.getBase64;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (widget.size * devicePixelRatio).ceil();

    if (base64 != null) {
      return Image.memory(
        base64,
        gaplessPlayback: true,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        errorBuilder: (_, error, _) {
          return _defaultIcon();
        },
      );
    }
    if (_file != null) {
      if (widget.src.isSvg) {
        final mKey = _moduleCacheKey(cacheSize);
        if (_moduleSvgValidCache[widget.src] == true) {
          try {
            return SvgPicture.file(
              _file!,
              width: widget.size,
              height: widget.size,
              placeholderBuilder: (_) => _defaultIcon(),
            );
          } catch (e) {
            commonPrint.log('Failed to load SVG: $e');
            _moduleFileCache.remove(mKey);
            _moduleSvgValidCache.remove(widget.src);
            _moduleFailureCache.remove(mKey);
            return _defaultIcon();
          }
        }
        return FutureBuilder<bool>(
          future: _validateSvg(_file!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _defaultIcon();
            }
            if (snapshot.hasError || snapshot.data == false) {
              commonPrint.log(
                'SVG validation failed in build: ${snapshot.error}',
              );
              DefaultCacheManager().removeFile(widget.src);
              _moduleFileCache.remove(_moduleCacheKey(cacheSize));
              _moduleSvgValidCache.remove(widget.src);
              _file = null;
              _cachedSrc = null;
              _cachedSize = null;
              return _defaultIcon();
            }
            _moduleSvgValidCache[widget.src] = true;
            try {
              return SvgPicture.file(
                _file!,
                width: widget.size,
                height: widget.size,
                placeholderBuilder: (_) => _defaultIcon(),
              );
            } catch (e) {
              commonPrint.log('Failed to load SVG: $e');
              DefaultCacheManager().removeFile(widget.src);
              _moduleFileCache.remove(_moduleCacheKey(cacheSize));
              _moduleSvgValidCache.remove(widget.src);
              _file = null;
              _cachedSrc = null;
              _cachedSize = null;
              return _defaultIcon();
            }
          },
        );
      }
      final mKey = _moduleCacheKey(cacheSize);
      return Image.file(
        _file!,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) {
          _moduleFileCache.remove(mKey);
          _moduleFailureCache.remove(mKey);
          return _defaultIcon();
        },
      );
    }
    return _defaultIcon();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey<String>('${widget.src}_${_file?.path}'),
          child: _buildIcon(),
        ),
      ),
    );
  }
}
