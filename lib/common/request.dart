import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
    _clashDio = Dio();
    _clashDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (Uri uri) {
          client.userAgent = globalState.ua;
          return BettboxHttpOverrides.handleFindProxy(uri);
        };
        return client;
      },
    );
  }

  Future<Response> _getResponseForUrl(
    String url,
    ResponseType responseType,
  ) async {
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

    final headers = <String, dynamic>{
      'Connection': 'close',
    };
    if (userInfo != null && userInfo.isNotEmpty) {
      final auth = base64Encode(utf8.encode(userInfo));
      headers['Authorization'] = 'Basic $auth';
    }

    final response = await _clashDio.get(
      requestUrl,
      options: Options(
        responseType: responseType,
        headers: headers,
      ),
    );
    return response;
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
    return MemoryImage(data);
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
      final location = response.headers.value('location');
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
      commonPrint.log('Check update failed: ${e.formatError}');
    }
    return null;
  }

  final List<String> _ipInfoSources = [
    'https://cp.cloudflare.com/cdn-cgi/trace',
    'https://api.cloudflare.com/cdn-cgi/trace',
  ];

  final List<String> _domesticIpSources = [
    'https://www.qualcomm.cn/cdn-cgi/trace',
    'https://www.cloudflare-cn.com/cdn-cgi/trace',
  ];

  Future<Result<IpInfo?>> _checkIpFromSources(
    List<String> sources,
    CancelToken? cancelToken,
    Duration? timeout,
  ) async {
    final effectiveTimeout = timeout ?? const Duration(seconds: 5);

    final dio = Dio(
      BaseOptions(
        receiveTimeout: effectiveTimeout,
        connectTimeout: effectiveTimeout,
      ),
    );

    final Completer<Result<IpInfo?>> resultCompleter = Completer();
    int failureCount = 0;

    void handleFailure() {
      if (resultCompleter.isCompleted) return;
      failureCount++;
      if (failureCount == sources.length) {
        resultCompleter.complete(Result.success(null));
      }
    }

    for (final url in sources) {
      dio
          .get<String>(
            url,
            cancelToken: cancelToken,
            options: Options(responseType: ResponseType.plain),
          )
          .then((res) {
            if (resultCompleter.isCompleted) return;
            if (res.statusCode == HttpStatus.ok && res.data != null) {
              try {
                resultCompleter.complete(
                  Result.success(IpInfo.fromCloudflareTrace(res.data!)),
                );
              } catch (_) {
                handleFailure();
              }
            } else {
              handleFailure();
            }
          })
          .catchError((e) {
            if (resultCompleter.isCompleted) return;
            if (e is DioException && e.type == DioExceptionType.cancel) {
              resultCompleter.complete(Result.error('cancelled'));
              return;
            }
            handleFailure();
          });
    }

    try {
      return await resultCompleter.future.timeout(
        effectiveTimeout,
        onTimeout: () => Result.success(null),
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<Result<IpInfo?>> checkIp({
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    return _checkIpFromSources(_ipInfoSources, cancelToken, timeout);
  }

  Future<Result<IpInfo?>> checkIpDomestic({
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    return _checkIpFromSources(_domesticIpSources, cancelToken, timeout);
  }
}

final request = Request();
