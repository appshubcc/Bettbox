import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:intl/intl.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

class _LimitedByteSink extends ByteConversionSinkBase {
  _LimitedByteSink(this.maxBytes);

  final int maxBytes;
  final BytesBuilder _builder = BytesBuilder(copy: false);

  Uint8List takeBytes() => _builder.takeBytes();

  @override
  void add(List<int> chunk) {
    if (_builder.length + chunk.length > maxBytes) {
      throw const FormatException('Decompressed data exceeds limit');
    }
    _builder.add(chunk);
  }

  @override
  void close() {}
}

class Request {
  static const _maxDecompressedBytes = 64 * 1024 * 1024;

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

  Uint8List _decodeWithLimit(
    Converter<List<int>, List<int>> decoder,
    Uint8List input,
  ) {
    final sink = _LimitedByteSink(_maxDecompressedBytes);
    final inputSink = decoder.startChunkedConversion(sink);
    inputSink.add(input);
    inputSink.close();
    return sink.takeBytes();
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
          current = _decodeWithLimit(gzip.decoder, current);
          wantGzip = false;
          continue;
        } catch (_) {
          break;
        }
      }
      if (wantDeflate) {
        try {
          current = _decodeWithLimit(zlib.decoder, current);
          wantDeflate = false;
          continue;
        } catch (_) {
          try {
            current = _decodeWithLimit(ZLibDecoder(raw: true), current);
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

  Future<({File file, String? fileName})> _localFileForUrl(String url) async {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty && uri.host.isEmpty) {
      throw Exception('Empty file path in file url: $url');
    }

    final filePath = _buildFilePath(uri, segments);
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Local file not found: $filePath');
    }
    return (file: file, fileName: segments.lastOrNull);
  }

  Headers? _fileHeaders(String? fileName) {
    if (fileName == null) return null;
    return Headers.fromMap({
      'content-disposition': [
        'attachment; filename*=UTF-8\'\'${Uri.encodeComponent(fileName)}',
      ],
    });
  }

  Future<Response> _getFileResponseForUrl(
    String url,
    ResponseType responseType,
  ) async {
    final local = await _localFileForUrl(url);
    final bytes = await local.file.readAsBytes();
    return _buildResponseFromBytes(
      url: url,
      bytes: bytes,
      responseType: responseType,
      fileName: local.fileName,
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
    final headers = _fileHeaders(fileName);
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

  (String, Map<String, dynamic>) _authorizedRequest(String url) {
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

    return (requestUrl, headers);
  }

  Future<T> _withPlainEncodingRetry<T>(
    Map<String, dynamic> headers,
    Future<T> Function(Map<String, dynamic> requestHeaders) send,
  ) async {
    try {
      return await send(headers);
    } on DioException catch (e) {
      final error = e.error;
      if (error is! HttpException ||
          !error.message.contains(HttpHeaders.contentEncodingHeader)) {
        rethrow;
      }
      return send({...headers, HttpHeaders.acceptEncodingHeader: 'identity'});
    }
  }

  Future<({String path, Headers? headers, bool remote})> fetchProfileSource(
    String url,
    String downloadPath,
  ) async {
    if (url.isFileUrl) {
      final local = await _localFileForUrl(url);
      await local.file.copy(downloadPath);
      return (
        path: downloadPath,
        headers: _fileHeaders(local.fileName),
        remote: false,
      );
    }
    final (requestUrl, headers) = _authorizedRequest(url);
    final response = await _withPlainEncodingRetry(
      headers,
      (requestHeaders) => _clashDio.download(
        requestUrl,
        downloadPath,
        options: Options(headers: requestHeaders),
      ),
    );
    return (path: downloadPath, headers: response.headers, remote: true);
  }

  Future<Response> _getResponseForUrl(
    String url,
    ResponseType responseType,
  ) async {
    if (url.isFileUrl) {
      return _getFileResponseForUrl(url, responseType);
    }

    final (requestUrl, headers) = _authorizedRequest(url);
    final response = await _withPlainEncodingRetry(
      headers,
      (requestHeaders) => _clashDio.get(
        requestUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: requestHeaders,
        ),
      ),
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

  Future<Uint8List?> getBytes(String url, {CancelToken? cancelToken}) async {
    final response = await _dio.get<Uint8List>(
      url,
      cancelToken: cancelToken,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null) return null;
    return _decompressIfNeeded(data, response.headers);
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
      commonPrint.warn('Check update failed: ${e.formatErrorLog}');
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

  final List<String> _domesticIpSources = [
    'https://myip.ipip.net/json',
    'https://uapis.cn/api/v1/network/myip',
  ];

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
    String? proxy,
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
        if (proxy != null) client.findProxy = (_) => proxy;
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
    String? proxy,
  }) async {
    return _checkIpFromSources(
      _getPrimaryIpSources(),
      cancelToken,
      timeout,
      onUpdate: onUpdate,
      proxy: proxy,
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

  Future<Map<String, dynamic>?> readIpCache(String cacheKey) async {
    try {
      final raw = await clashCore.storeGet(StoreSpace.ip, cacheKey);
      if (raw.isEmpty) return null;
      final decoded = json.decode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeIpCache(String cacheKey, Map<String, dynamic> data) async {
    try {
      await clashCore.storeSet(StoreSpace.ip, cacheKey, data);
    } catch (_) {}
  }

  String _ipDetailCacheKey(String ip) {
    final isZh = Intl.getCurrentLocale().toLowerCase().startsWith('zh');
    return '${ip}_${isZh ? 'zh' : 'en'}';
  }

  Future<IpInfo?> readIpDetailCache(String ip) async {
    try {
      final cached = await readIpCache(_ipDetailCacheKey(ip));
      return cached == null ? null : IpInfo.fromJson(cached);
    } catch (_) {
      return null;
    }
  }

  Future<Result<IpInfo?>> queryIpDetail(
    String ip, {
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    final isZh = Intl.getCurrentLocale().toLowerCase().startsWith('zh');
    final cacheKey = _ipDetailCacheKey(ip);

    final cached = await readIpDetailCache(ip);
    if (cached != null) return Result.success(cached);

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
          connectTimeout: effectiveTimeout,
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
        await writeIpCache(cacheKey, ipInfo.toJson());
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

  Future<IpRisk?> readIpRiskCache(String ip) async {
    try {
      final cached = await readIpCache('risk_$ip');
      return cached == null ? null : IpRisk.fromJson(cached).normalized;
    } catch (_) {
      return null;
    }
  }

  Future<Result<IpRisk?>> queryIpRisk(
    String ip, {
    bool force = false,
    CancelToken? cancelToken,
  }) async {
    final cacheKey = 'risk_$ip';
    if (!force) {
      final cached = await readIpRiskCache(ip);
      if (cached != null) return Result.success(cached);
    }
    const timeout = Duration(seconds: 10);
    try {
      final res = await _dio.get<List<int>>(
        'https://scamalytics.com/ip/${Uri.encodeComponent(ip)}',
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          connectTimeout: timeout,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      final data = res.data;
      if (res.statusCode != HttpStatus.ok || data == null) {
        return Result.error('query failed');
      }
      final risk = await Isolate.run(() => parseScamalyticsBytes(ip, data));
      if (risk == null) return Result.error('parse failed');
      await writeIpCache(cacheKey, risk.toJson());
      return Result.success(risk);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return Result.error('cancelled');
      }
      return Result.error(e.toString());
    }
  }
}

final request = Request();
