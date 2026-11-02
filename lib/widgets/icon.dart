import 'dart:io';
import 'package:bett_box/common/common.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

class _IconFileManager {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.bytes,
    ),
  );

  static final Map<String, Future<File?>> _inFlightDownloads = {};

  static Future<File> getCacheFile(String url) async {
    final hash = md5.convert(utf8.encode(url)).toString();
    final tempDir = await appPath.tempPath;
    final ext = url.isSvg ? '.svg' : '.img';
    final dir = Directory(path.join(tempDir, 'icon_raw_cache'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return File(path.join(dir.path, '$hash$ext'));
  }

  static Future<File?> getFileFromCache(String url) async {
    try {
      final file = await getCacheFile(url);
      if (await file.exists() && (await file.length()) > 0) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  static Future<File?> downloadFile(String url) async {
    final existing = await getFileFromCache(url);
    if (existing != null) {
      return existing;
    }

    if (_inFlightDownloads.containsKey(url)) {
      return await _inFlightDownloads[url];
    }

    final future = _downloadInternal(url);
    _inFlightDownloads[url] = future;
    try {
      return await future;
    } finally {
      _inFlightDownloads.remove(url);
    }
  }

  static Future<File?> _downloadInternal(String url) async {
    try {
      final targetFile = await getCacheFile(url);
      final tempFile = File('${targetFile.path}.tmp');

      final response = await _dio.get<List<int>>(url);
      final data = response.data;
      if (data == null || data.isEmpty) {
        return null;
      }

      await tempFile.writeAsBytes(data, flush: true);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      return targetFile;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeFile(String url) async {
    try {
      final file = await getCacheFile(url);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

class CommonTargetIcon extends StatefulWidget {
  final String src;
  final double size;

  const CommonTargetIcon({super.key, required this.src, required this.size});

  static final ValueNotifier<int> _cacheVersion = ValueNotifier(0);

  static Future<void> clearCache() async {
    final tempDir = await appPath.tempPath;
    for (final name in ['icon_raw_cache', 'resized_icons']) {
      final dir = Directory(path.join(tempDir, name));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
    _CommonTargetIconState._moduleFileCache.clear();
    _CommonTargetIconState._moduleSvgCache.clear();
    _CommonTargetIconState._moduleFailureCache.clear();
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
    svg.cache.clear();
    _cacheVersion.value++;
  }

  @override
  State<CommonTargetIcon> createState() => _CommonTargetIconState();
}

class _CommonTargetIconState extends State<CommonTargetIcon> {
  File? _file;
  String? _cachedSrc; // Cached src
  int? _cachedSize; // Cached size
  bool _didSyncCheck = false; // Guard for didChangeDependencies

  static final Map<String, File?> _moduleFileCache = {};
  static final Map<String, bool> _moduleSvgCache = {};
  static final Map<String, DateTime> _moduleFailureCache = {};
  static const _maxCacheEntries = 1024;
  static const _failureCooldownSeconds = 10;

  static void _ensureCacheLimit() {
    while (_moduleFileCache.length > _maxCacheEntries) {
      _moduleFileCache.remove(_moduleFileCache.keys.first);
    }
    while (_moduleSvgCache.length > _maxCacheEntries) {
      _moduleSvgCache.remove(_moduleSvgCache.keys.first);
    }
  }

  bool _shouldRetry(String key) {
    final failedAt = _moduleFailureCache[key];
    if (failedAt == null) return true;
    if (DateTime.now().difference(failedAt).inSeconds <
        _failureCooldownSeconds) {
      return false;
    }
    _moduleFailureCache.remove(key);
    return true;
  }

  @override
  void initState() {
    super.initState();
    CommonTargetIcon._cacheVersion.addListener(_handleCacheReset);
  }

  @override
  void dispose() {
    CommonTargetIcon._cacheVersion.removeListener(_handleCacheReset);
    super.dispose();
  }

  void _handleCacheReset() {
    if (!mounted) return;
    setState(() {
      _file = null;
      _cachedSrc = null;
      _cachedSize = null;
    });
    _syncCheckAndInit();
  }

  void _syncCheckAndInit() {
    if (widget.src.isEmpty || widget.src.getBase64 != null) return;
    if (routeIconAsset(widget.src) != null) return;

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (widget.size * devicePixelRatio).ceil();

    final exactFile = _moduleFileCache[widget.src];
    if (exactFile != null) {
      _cachedSrc = widget.src;
      _cachedSize = cacheSize;
      _file = exactFile;
      return;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSyncCheck) return;
    _didSyncCheck = true;
    _syncCheckAndInit();
  }

  Future<bool> _validateSvg(File file) async {
    try {
      final content = await file.readAsString();
      final trimmed = content.trim();

      if (!trimmed.startsWith('<svg') &&
          !trimmed.startsWith('<?xml') &&
          !trimmed.startsWith('<!DOCTYPE svg')) {
        commonPrint.warn('Invalid SVG: not starting with svg tag');
        return false;
      }

      if (trimmed.contains('<!DOCTYPE html>') ||
          trimmed.contains('<html>') ||
          trimmed.contains('<head>') ||
          trimmed.contains('<body>')) {
        commonPrint.warn('Invalid SVG: HTML content detected');
        return false;
      }

      if (!trimmed.contains('<svg') &&
          !trimmed.contains('<svg ') &&
          !trimmed.contains('<svg\n')) {
        commonPrint.warn('Invalid SVG: svg tag missing');
        return false;
      }

      if (!trimmed.endsWith('</svg>') &&
          !trimmed.endsWith('/>') &&
          !trimmed.contains('</svg>')) {
        commonPrint.warn('Invalid SVG: closing tag missing');
        return false;
      }

      if (content.contains('font-weight:none') ||
          content.contains('font-weight: none')) {
        final fixed = content
            .replaceAll('font-weight:none', 'font-weight:normal')
            .replaceAll('font-weight: none', 'font-weight: normal');
        await file.writeAsString(fixed);
      }
      return true;
    } catch (e) {
      commonPrint.warn('SVG validation failed: $e');
      return false;
    }
  }

  Future<void> _init(int cacheSize) async {
    if (widget.src.isEmpty || widget.src.getBase64 != null) {
      return;
    }

    if (_cachedSrc == widget.src && _cachedSize == cacheSize && _file != null) {
      return;
    }

    final key = widget.src;

    if (_moduleFileCache.containsKey(key)) {
      final cachedFile = _moduleFileCache[key];
      if (cachedFile == null) return;

      if (mounted) {
        setState(() {
          _file = cachedFile;
          _cachedSrc = widget.src;
          _cachedSize = cacheSize;
        });
      }
      return;
    }

    if (!_shouldRetry(key)) return;

    final cachedFile = await _IconFileManager.getFileFromCache(widget.src);
    if (cachedFile != null && mounted && widget.src.isNotEmpty) {
      await _processFile(cachedFile, cacheSize, key);
      return;
    }

    try {
      final file = await _IconFileManager.downloadFile(widget.src);
      if (file != null && mounted && widget.src.isNotEmpty) {
        await _processFile(file, cacheSize, key);
      } else {
        _moduleFailureCache[key] = DateTime.now();
      }
    } catch (_) {
      _moduleFailureCache[key] = DateTime.now();
    }
  }

  Future<bool> _sniffSvg(File file) async {
    try {
      final raf = await file.open();
      try {
        final text = utf8
            .decode(await raf.read(1024), allowMalformed: true)
            .trimLeft()
            .toLowerCase();
        return text.startsWith('<svg') ||
            (text.startsWith('<?xml') || text.startsWith('<!doctype svg')) &&
                text.contains('<svg');
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> _processFile(File file, int cacheSize, String key) async {
    if (widget.src.isSvg || await _sniffSvg(file)) {
      final isValid = await _validateSvg(file);
      if (!isValid) {
        await _IconFileManager.removeFile(widget.src);
        _moduleFileCache[key] = null;
        _moduleFailureCache.remove(key);
        if (mounted) {
          setState(() {
            _file = null;
            _cachedSrc = null;
            _cachedSize = null;
          });
        }
        return;
      }
      _moduleFileCache[key] = file;
      _moduleSvgCache[key] = true;
      _moduleFailureCache.remove(key);
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

    _moduleFileCache[key] = file;
    _moduleSvgCache[key] = false;
    _moduleFailureCache.remove(key);
    _ensureCacheLimit();
    if (mounted) {
      setState(() {
        _file = file;
        _cachedSrc = widget.src;
        _cachedSize = cacheSize;
      });
    }
  }

  Widget _defaultIcon() {
    return Icon(IconsExt.target, size: widget.size);
  }

  SvgTheme _svgTheme() => SvgTheme(
    currentColor: IconTheme.of(context).color ?? context.colorScheme.onSurface,
  );

  Widget _buildIcon() {
    if (widget.src.isEmpty) {
      return _defaultIcon();
    }
    if (routeIconAsset(widget.src) case final asset?) {
      return SvgPicture.asset(
        asset,
        width: widget.size,
        height: widget.size,
        theme: _svgTheme(),
      );
    }
    final base64 = widget.src.getBase64;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (widget.size * devicePixelRatio).ceil();

    if (base64 != null) {
      return Image(
        image: ResizeImage(
          MemoryImage(base64),
          width: cacheSize,
          height: cacheSize,
          policy: ResizeImagePolicy.fit,
        ),
        gaplessPlayback: true,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return _defaultIcon();
        },
      );
    }
    if (_file != null) {
      final key = widget.src;
      if (_moduleSvgCache[key] ?? widget.src.isSvg) {
        return SvgPicture.file(
          _file!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          theme: _svgTheme(),
          placeholderBuilder: (_) => _defaultIcon(),
          errorBuilder: (_, error, _) {
            commonPrint.warn('Failed to load SVG: $error');
            _IconFileManager.removeFile(widget.src);
            _moduleFileCache.remove(key);
            _moduleSvgCache.remove(widget.src);
            _moduleFailureCache[key] = DateTime.now();
            return _defaultIcon();
          },
        );
      }
      return Image.file(
        _file!,
        gaplessPlayback: true,
        fit: BoxFit.contain,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        errorBuilder: (_, _, _) {
          _moduleFileCache.remove(key);
          _moduleFailureCache[key] = DateTime.now();
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
          key: ValueKey<(String, String?, int)>((
            widget.src,
            _file?.path,
            CommonTargetIcon._cacheVersion.value,
          )),
          child: _buildIcon(),
        ),
      ),
    );
  }
}

class MenuDotsIcon extends StatelessWidget {
  final bool isOpen;
  final Color? accent;

  const MenuDotsIcon({super.key, this.isOpen = false, this.accent});

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? context.colorScheme.onSurfaceVariant;
    return RepaintBoundary(
      child: AnimatedRotation(
        turns: isOpen ? 0.125 : 0,
        duration: midDuration,
        curve: Curves.easeOutBack,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: accent ?? color),
          duration: midDuration,
          builder: (_, accent, _) => SizedBox.square(
            dimension: 24,
            child: CustomPaint(
              painter: _MenuDotsPainter(color: color, accent: accent ?? color),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuDotsPainter extends CustomPainter {
  static final Paint _paint = Paint();

  final Color color;
  final Color accent;

  const _MenuDotsPainter({required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 2.6;
    const distance = 5.2;
    final center = size.center(Offset.zero);
    _paint.color = color;
    canvas.drawCircle(
      center + const Offset(-distance, -distance),
      radius,
      _paint,
    );
    canvas.drawCircle(
      center + const Offset(-distance, distance),
      radius,
      _paint,
    );
    canvas.drawCircle(
      center + const Offset(distance, distance),
      radius,
      _paint,
    );
    _paint.color = accent;
    canvas.drawCircle(
      center + const Offset(distance, -distance),
      radius,
      _paint,
    );
  }

  @override
  bool shouldRepaint(_MenuDotsPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accent != accent;
  }
}
