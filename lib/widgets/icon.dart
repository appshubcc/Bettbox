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

  // Module-level cache, keyed by url_size so the cached value is the final
  // display-ready File (already resized for non-SVG).  Survives widget disposal
  // so collapsing/expanding a group does not re-trigger async loading.
  static final Map<String, File?> _moduleFileCache = {};
  static final Map<String, bool> _moduleSvgValidCache = {};

  String _moduleCacheKey(int cacheSize) => '${widget.src}_$cacheSize';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant CommonTargetIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (widget.size * devicePixelRatio).ceil();

    // Reinit when src or size changes
    if (oldWidget.src != widget.src || _cachedSize != cacheSize) {
      _file = null;
      _cachedSrc = null;
      _cachedSize = null;
      _didSyncCheck = false;
      _init();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSyncCheck) return;
    _didSyncCheck = true;

    // Bail out early — no-op for empty / base64 sources
    if (widget.src.isEmpty || widget.src.getBase64 != null) return;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (widget.size * devicePixelRatio).ceil();
    final key = _moduleCacheKey(cacheSize);

    final cachedFile = _moduleFileCache[key];
    if (cachedFile == null) return; // not cached — let _init() handle it
    if (widget.src.isSvg && _moduleSvgValidCache[widget.src] != true) return;

    // Sync cache hit: set _file before first build so no default-icon flash
    _cachedSrc = widget.src;
    _cachedSize = cacheSize;
    _file = cachedFile;
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
      // Resize failed, return original
      return originalFile;
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

  Future<void> _init() async {
    if (widget.src.isEmpty) {
      return;
    }
    if (widget.src.getBase64 != null) {
      return;
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (widget.size * devicePixelRatio).ceil();

    // If cached with same src and size, return directly
    if (_cachedSrc == widget.src && _cachedSize == cacheSize && _file != null) {
      return;
    }

    // Check module-level cache: another instance (or a previous
    // expand/collapse) may have already loaded this URL at the same size.
    // The cached File is already display-ready — no async resize needed.
    final mKey = _moduleCacheKey(cacheSize);
    if (_moduleFileCache.containsKey(mKey)) {
      final cachedFile = _moduleFileCache[mKey];
      if (cachedFile == null) return; // previously confirmed invalid
      if (widget.src.isSvg && _moduleSvgValidCache[widget.src] != true) return;

      if (mounted) {
        setState(() {
          _file = cachedFile;
          _cachedSrc = widget.src;
          _cachedSize = cacheSize;
        });
      }
      return;
    }

    // Get from cache first, no network check
    final fileInfo = await DefaultCacheManager().getFileFromCache(widget.src);
    if (fileInfo != null && mounted && widget.src.isNotEmpty) {
      // Validate SVG files
      if (widget.src.isSvg) {
        final isValid = await _validateSvg(fileInfo.file);
        if (!isValid) {
          // Remove invalid cached file
          await DefaultCacheManager().removeFile(widget.src);
          _moduleFileCache[mKey] = null;
          if (mounted) {
            setState(() {
              _file = null;
              _cachedSrc = null;
              _cachedSize = null;
            });
          }
          return;
        }
        _moduleFileCache[mKey] = fileInfo.file;
        _moduleSvgValidCache[widget.src] = true;
        if (mounted) {
          setState(() {
            _file = fileInfo.file;
            _cachedSrc = widget.src;
            _cachedSize = cacheSize;
          });
        }
        return;
      }

      // Resize non-SVG images
      final displayFile = await _resizeAndCacheImage(fileInfo.file, cacheSize);
      _moduleFileCache[mKey] = displayFile; // store display-ready File
      if (mounted) {
        setState(() {
          _file = displayFile;
          _cachedSrc = widget.src; // Mark cached
          _cachedSize = cacheSize; // Mark cached size
        });
      }
      return;
    }

    // Download if cache not exists
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.src);
      if (mounted && widget.src.isNotEmpty) {
        // Validate SVG files
        if (widget.src.isSvg) {
          final isValid = await _validateSvg(file);
          if (!isValid) {
            // Remove invalid downloaded file
            await DefaultCacheManager().removeFile(widget.src);
            _moduleFileCache[mKey] = null;
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
          if (mounted) {
            setState(() {
              _file = file;
              _cachedSrc = widget.src;
              _cachedSize = cacheSize;
            });
          }
          return;
        }

        // Resize non-SVG images
        final displayFile = await _resizeAndCacheImage(file, cacheSize);
        _moduleFileCache[mKey] = displayFile; // store display-ready File
        if (mounted) {
          setState(() {
            _file = displayFile;
            _cachedSrc = widget.src; // Mark cached
            _cachedSize = cacheSize; // Mark cached size
          });
        }
      }
    } catch (e) {
      // Handle download error
      _moduleFileCache[mKey] = null;
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
        return FutureBuilder<bool>(
          future: _validateSvg(_file!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _defaultIcon();
            }
            if (snapshot.hasError || snapshot.data == false) {
              commonPrint.log('SVG validation failed in build: ${snapshot.error}');
              // Remove invalid file and clear state
              DefaultCacheManager().removeFile(widget.src);
              _moduleFileCache.remove(_moduleCacheKey(cacheSize));
              _moduleSvgValidCache.remove(widget.src);
              _file = null;
              _cachedSrc = null;
              _cachedSize = null;
              return _defaultIcon();
            }
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
      return Image.file(
        _file!,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _defaultIcon(),
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
