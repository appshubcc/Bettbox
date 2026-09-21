import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:intl/intl.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/cupertino.dart';

class Request {
  late final Dio _dio;
  late final Dio _clashDio;
  String? userAgent;

  Request() {
    _dio = Dio(BaseOptions(headers: {'User-Agent': browserUa}));
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.autoUncompress = false;
        return client;
      },
    );
    _clashDio = Dio();
    _clashDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.autoUncompress = false;
        client.findProxy = (Uri uri) {
          client.userAgent = globalState.ua;
          return BettboxHttpOverrides.handleFindProxy(uri);
        };
        return client;
      },
    );
  }

  Uint8List _decompressIfNeeded(Uint8List bytes, Headers headers) {
    final encodings =
        headers['content-encoding']?.map((e) => e.toLowerCase()).toList() ?? [];
    final encodingStr = encodings.join(', ');
    var wantGzip = encodingStr.contains('gzip');
    var wantDeflate = encodingStr.contains('deflate');

    var current = bytes;
    for (var i = 0; i < 4; i++) {
      final isGzipMagic =
          current.length >= 2 && current[0] == 0x1f && current[1] == 0x8b;
      if (wantGzip || isGzipMagic) {
        if (!isGzipMagic) {
          break;
        }
        try {
          current = Uint8List.fromList(gzip.decode(current));
          wantGzip = false;
          continue;
        } catch (_) {
          break;
        }
      }
      if (wantDeflate) {
        try {
          current = Uint8List.fromList(zlib.decode(current));
          wantDeflate = false;
          continue;
        } catch (_) {
          try {
            current = Uint8List.fromList(
              ZLibDecoder(raw: true).convert(current),
            );
            wantDeflate = false;
            continue;
          } catch (_) {
            break;
          }
        }
      }
      break;
    }
    return current;
  }

  Uint8List _bytesFromResponse(Response response) {
    final data = response.data;
    if (data is Uint8List) return data;
    return Uint8List.fromList((data as List).cast<int>());
  }

  Future<Response> _getFileResponseForUrl(
    String url,
    ResponseType responseType,
  ) async {
    final uri = Uri.parse(url);
    final segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty && uri.host.isEmpty) {
      throw Exception('Empty file path in file url: $url');
    }

    final filePath = _buildFilePath(uri, segments);
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Local file not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    return _buildResponseFromBytes(
      url: url,
      bytes: bytes,
      responseType: responseType,
      fileName: segments.lastOrNull,
    );
  }

  String _buildFilePath(Uri uri, List<String> segments) {
    if (segments.isNotEmpty && segments.first.contains(':')) {
      return segments.join('/');
    }
    final host = uri.host;
    if (host.isNotEmpty && host.toLowerCase() != 'localhost') {
      if (host.length == 1 && RegExp(r'^[a-zA-Z]$').hasMatch(host)) {
        return '$host:/${segments.join('/')}';
      }
      return '//$host/${segments.join('/')}';
    }
    return '/${segments.join('/')}';
  }

  Response _buildResponseFromBytes({
    required String url,
    required Uint8List bytes,
    required ResponseType responseType,
    String? fileName,
  }) {
    final requestOptions = RequestOptions(path: url);
    final disposition = fileName == null
        ? null
        : 'attachment; filename*=UTF-8\'\'${Uri.encodeComponent(fileName)}';
    final headers = disposition == null
        ? null
        : Headers.fromMap({'content-disposition': [disposition]});
    if (responseType == ResponseType.plain) {
      return Response(
        requestOptions: requestOptions,
        data: utf8.decode(bytes, allowMalformed: true),
        statusCode: HttpStatus.ok,
        headers: headers,
      );
    }
    return Response(
      requestOptions: requestOptions,
      data: bytes,
      statusCode: HttpStatus.ok,
      headers: headers,
    );
  }

  Future<Response> _getResponseForUrl(
    String url,
    ResponseType responseType,
  ) async {
    if (url.isFileUrl) {
      return _getFileResponseForUrl(url, responseType);
    }

    String? userInfo;
    String requestUrl = url;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      final schemeEnd = url.indexOf('://') + 3;
      final slashIndex = url.indexOf('/', schemeEnd);
      final questionIndex = url.indexOf('?', schemeEnd);
      final hashIndex = url.indexOf('#', schemeEnd);
      var authorityEnd = url.length;
      if (slashIndex != -1) authorityEnd = slashIndex;
      if (questionIndex != -1 && questionIndex < authorityEnd) {
        authorityEnd = questionIndex;
      }
      if (hashIndex != -1 && hashIndex < authorityEnd) {
        authorityEnd = hashIndex;
      }
      final atIndex = url.lastIndexOf('@', authorityEnd - 1);
      if (atIndex >= schemeEnd) {
        userInfo = url.substring(schemeEnd, atIndex);
        requestUrl = url.substring(0, schemeEnd) + url.substring(atIndex + 1);
      }
    }

    final headers = <String, dynamic>{'Connection': 'close'};
    if (userInfo != null && userInfo.isNotEmpty) {
      final auth = base64Encode(utf8.encode(userInfo));
      headers['Authorization'] = 'Basic $auth';
    }

    final response = await _clashDio.get(
      requestUrl,
      options: Options(responseType: ResponseType.bytes, headers: headers),
    );

    final rawBytes = _bytesFromResponse(response);
    final decompressedBytes = _decompressIfNeeded(rawBytes, response.headers);

    if (responseType == ResponseType.plain) {
      final text = utf8.decode(decompressedBytes, allowMalformed: true);
      return Response(
        requestOptions: response.requestOptions,
        data: text,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
        headers: response.headers,
      );
    } else {
      return Response(
        requestOptions: response.requestOptions,
        data: decompressedBytes,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
        headers: response.headers,
      );
    }
  }

  Future<Response> getFileResponseForUrl(String url) async {
    return _getResponseForUrl(url, ResponseType.bytes);
  }

  Future<Response> getTextResponseForUrl(String url) async {
    return _getResponseForUrl(url, ResponseType.plain);
  }

  Future<MemoryImage?> getImage(String url) async {
    if (url.isEmpty) return null;
    final response = await _dio.get<Uint8List>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null) return null;
    final bytes = _decompressIfNeeded(data, response.headers);
    return MemoryImage(bytes);
  }

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final t = DateTime.now().millisecondsSinceEpoch;
      final response = await _dio.get(
        'https://github.com/$repository/releases/latest?t=$t',
        options: Options(
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 300 && status < 400,
        ),
      );
      final location = response.headers['location']?.firstOrNull;
      if (location != null && location.contains('/releases/tag/')) {
        final remoteVersion = location.split('/').last.trim();
        if (remoteVersion.isNotEmpty) {
          final version = globalState.packageInfo.version;
          final hasUpdate =
              utils.compareVersions(
                remoteVersion.replaceAll('v', ''),
                version,
              ) >
              0;
          if (!hasUpdate) return null;
          return {
            'tag_name': remoteVersion,
            'html_url': 'https://github.com/$repository/releases/latest',
            'body': 'New version available. Please visit GitHub to download.',
          };
        }
      }
    } catch (e) {
      commonPrint.log('Check update failed: ${e.formatErrorLog}');
    }
    return null;
  }

  List<String> _getPrimaryIpSources() {
    final locale = Intl.getCurrentLocale().toLowerCase();
    final isZh = locale.startsWith('zh');
    return [
      isZh ? 'http://ip-api.com/json/?lang=zh-CN' : 'http://ip-api.com/json',
      'https://get.geojs.io/v1/ip/geo.json',
    ];
  }

  final List<String> _domesticIpSources = ['https://myip.ipip.net/json'];

  final List<String> _cloudflareIpInfoSources = [
    'https://ip.sb/cdn-cgi/trace',
    'https://api.ip.sb/cdn-cgi/trace',
  ];

  final List<String> _cloudflareDomesticIpSources = [
    'https://www.qualcomm.cn/cdn-cgi/trace',
    'https://www.teamviewer.cn/cdn-cgi/trace',
  ];

  Future<Result<IpInfo?>> _checkIpFromSources(
    List<String> sources,
    CancelToken? cancelToken,
    Duration? timeout, {
    void Function(IpInfo info)? onUpdate,
  }) async {
    final effectiveTimeout = timeout ?? const Duration(seconds: 5);

    final dio = Dio(
      BaseOptions(
        receiveTimeout: effectiveTimeout,
        connectTimeout: effectiveTimeout,
        sendTimeout: effectiveTimeout,
      ),
    );
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.autoUncompress = false;
        client.connectionTimeout = effectiveTimeout;
        return client;
      },
    );

    final Completer<Result<IpInfo?>> firstCompleter = Completer();
    IpInfo? primaryInfo;
    IpInfo? fallbackInfo;
    int completedCount = 0;
    Timer? cleanupTimer;

    void cleanup() {
      cleanupTimer?.cancel();
      cleanupTimer = null;
      dio.close(force: true);
    }

    cleanupTimer = Timer(effectiveTimeout, cleanup);
    cancelToken?.whenCancel.then((_) => cleanup());

    void checkAllFinished() {
      completedCount++;
      if (completedCount == sources.length) {
        if (!firstCompleter.isCompleted) {
          final res = primaryInfo ?? fallbackInfo;
          if (res != null) onUpdate?.call(res);
          firstCompleter.complete(Result.success(res));
        }
        cleanup();
      }
    }

    for (int i = 0; i < sources.length; i++) {
      final url = sources[i];
      final isPrimary = i == 0;
      dio
          .get<Uint8List>(
            url,
            cancelToken: cancelToken,
            options: Options(responseType: ResponseType.bytes),
          )
          .then((res) {
            if (res.statusCode == HttpStatus.ok && res.data != null) {
              try {
                final text = utf8
                    .decode(
                      _decompressIfNeeded(_bytesFromResponse(res), res.headers),
                      allowMalformed: true,
                    )
                    .trim();
                IpInfo? ipInfo;
                if (text.startsWith('{')) {
                  final jsonMap = json.decode(text);
                  if (jsonMap is Map<String, dynamic>) {
                    if (url.contains('ip-api.com') &&
                        jsonMap['status'] != 'success') {
                      ipInfo = null;
                    } else {
                      ipInfo = IpInfo.fromJson(jsonMap);
                    }
                  }
                } else {
                  ipInfo = IpInfo.fromCloudflareTrace(text);
                }

                if (ipInfo != null) {
                  if (isPrimary) {
                    primaryInfo = ipInfo;
                    onUpdate?.call(ipInfo);
                    if (!firstCompleter.isCompleted) {
                      firstCompleter.complete(Result.success(ipInfo));
                    }
                  } else {
                    fallbackInfo = ipInfo;
                    if (sources.length == 1) {
                      onUpdate?.call(ipInfo);
                      if (!firstCompleter.isCompleted) {
                        firstCompleter.complete(Result.success(ipInfo));
                      }
                    }
                  }
                }
              } catch (_) {}
            }
            checkAllFinished();
          })
          .catchError((e) {
            if (e is DioException && e.type == DioExceptionType.cancel) {
              if (!firstCompleter.isCompleted) {
                firstCompleter.complete(Result.error('cancelled'));
              }
            }
            checkAllFinished();
          });
    }

    return await firstCompleter.future.timeout(
      effectiveTimeout,
      onTimeout: () {
        cleanup();
        cancelToken?.cancel('timeout');
        final res = primaryInfo ?? fallbackInfo;
        if (res != null) {
          return Result.success(res);
        }
        return Result.error('timeout');
      },
    );
  }

  Future<Result<IpInfo?>> checkIp({
    CancelToken? cancelToken,
    Duration? timeout,
    void Function(IpInfo info)? onUpdate,
  }) async {
    return _checkIpFromSources(
      _getPrimaryIpSources(),
      cancelToken,
      timeout,
      onUpdate: onUpdate,
    );
  }

  Future<Result<IpInfo?>> checkIpDomestic({
    CancelToken? cancelToken,
    Duration? timeout,
    void Function(IpInfo info)? onUpdate,
  }) async {
    return _checkIpFromSources(
      _domesticIpSources,
      cancelToken,
      timeout,
      onUpdate: onUpdate,
    );
  }

  Future<Result<IpInfo?>> checkIpCloudflare({
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    return _checkIpFromSources(_cloudflareIpInfoSources, cancelToken, timeout);
  }

  Future<Result<IpInfo?>> checkIpDomesticCloudflare({
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    return _checkIpFromSources(
      _cloudflareDomesticIpSources,
      cancelToken,
      timeout,
    );
  }

  static const _cacheDuration = Duration(days: 30);

  Future<File> _getIpCacheFile() async {
    final filePath = await appPath.ipCacheFilePath;
    final file = File(filePath);
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    return file;
  }

  Future<void> _writeIpCacheFile(File file, Map<String, dynamic> entries) async {
    try {
      final tempFile = File('${file.path}.${DateTime.now().microsecondsSinceEpoch}.tmp');
      await tempFile.parent.create(recursive: true);
      await tempFile.writeAsString(json.encode(entries), flush: true);
      try {
        await tempFile.rename(file.path);
      } catch (_) {
        if (await tempFile.exists()) {
          await tempFile.copy(file.path);
          await tempFile.delete();
        }
      }
    } catch (_) {}
  }

  Future<IpInfo?> _getValidCachedIp(String cacheKey) async {
    try {
      final file = await _getIpCacheFile();
      if (!await file.exists()) return null;

      final cacheStr = await file.readAsString();
      if (cacheStr.isEmpty) return null;

      final dynamic decoded = json.decode(cacheStr);
      if (decoded is! Map) return null;

      final rawMap = Map<String, dynamic>.from(decoded);
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAgeMs = _cacheDuration.inMilliseconds;

      bool hasExpired = false;
      final validEntries = <String, dynamic>{};
      IpInfo? matchedIpInfo;

      for (final entry in rawMap.entries) {
        final val = entry.value;
        if (val is Map) {
          final valMap = Map<String, dynamic>.from(val);
          final timestamp = valMap['timestamp'] as num?;
          if (timestamp != null && (now - timestamp) < maxAgeMs) {
            validEntries[entry.key] = valMap;
            if (entry.key == cacheKey && valMap['data'] is Map) {
              try {
                matchedIpInfo = IpInfo.fromJson(
                  Map<String, dynamic>.from(valMap['data'] as Map),
                );
              } catch (_) {}
            }
          } else {
            hasExpired = true;
          }
        }
      }

      if (hasExpired) {
        await _writeIpCacheFile(file, validEntries);
      }

      return matchedIpInfo;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCachedIp(String cacheKey, IpInfo ipInfo) async {
    try {
      final file = await _getIpCacheFile();
      Map<String, dynamic> rawMap = {};
      if (await file.exists()) {
        final cacheStr = await file.readAsString();
        if (cacheStr.isNotEmpty) {
          try {
            rawMap = Map<String, dynamic>.from(json.decode(cacheStr) as Map);
          } catch (_) {}
        }
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAgeMs = _cacheDuration.inMilliseconds;

      final validEntries = <String, dynamic>{};
      for (final entry in rawMap.entries) {
        final val = entry.value;
        if (val is Map) {
          final valMap = Map<String, dynamic>.from(val);
          final timestamp = valMap['timestamp'] as num?;
          if (timestamp != null && (now - timestamp) < maxAgeMs) {
            validEntries[entry.key] = valMap;
          }
        }
      }

      validEntries[cacheKey] = {'timestamp': now, 'data': ipInfo.toJson()};

      await _writeIpCacheFile(file, validEntries);
    } catch (_) {}
  }

  Future<Result<IpInfo?>> queryIpDetail(
    String ip, {
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final isZh = Intl.getCurrentLocale().toLowerCase().startsWith('zh');
    final cacheKey = '${ip}_${isZh ? 'zh' : 'en'}';

    final cached = await _getValidCachedIp(cacheKey);
    if (cached != null) {
      return Result.success(cached);
    }

    final effectiveTimeout = timeout ?? const Duration(seconds: 5);
    final url = isZh
        ? 'http://ip-api.com/json/$ip?lang=zh-CN'
        : 'http://ip-api.com/json/$ip';

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: effectiveTimeout,
          sendTimeout: effectiveTimeout,
        ),
      );

      if (res.statusCode == HttpStatus.ok && res.data != null) {
        final data = res.data!;
        final status = data['status']?.toString();
        if (status == 'fail') {
          final message = data['message']?.toString() ?? 'query failed';
          return Result.error(message);
        }
        final ipInfo = IpInfo.fromJson(data);
        await _saveCachedIp(cacheKey, ipInfo);
        return Result.success(ipInfo);
      }
      return Result.error('query failed');
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return Result.error('cancelled');
      }
      return Result.error(e.toString());
    }
  }
}

final request = Request();
