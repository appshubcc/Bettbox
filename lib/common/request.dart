import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/helper_auth.dart';
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

  Future<Response> _getResponseForUrl(String url, ResponseType responseType) async {
    final uri = Uri.parse(url);
    final userInfo = uri.userInfo;

    Options? options;
    if (userInfo.isNotEmpty) {
      final auth = base64Encode(utf8.encode(userInfo));
      options = Options(
        responseType: responseType,
        headers: {'Authorization': 'Basic $auth'},
      );
      url = uri.replace(userInfo: '').toString();
    }

    final response = await _clashDio.get(
      url,
      options: options ?? Options(responseType: responseType),
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
      final response = await _dio.get(
        'https://github.com/$repository/releases/latest',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status >= 300 && status < 400,
        ),
      );
      final location = response.headers.value('location');
      if (location != null && location.contains('/releases/tag/')) {
        final remoteVersion = location.split('/').last.trim();
        if (remoteVersion.isNotEmpty) {
          final version = globalState.packageInfo.version;
          final hasUpdate =
              utils.compareVersions(remoteVersion.replaceAll('v', ''), version) > 0;
          if (!hasUpdate) return null;
          return {
            'tag_name': remoteVersion,
            'html_url': 'https://github.com/$repository/releases/latest',
            'body': 'New version available. Please visit GitHub to download.',
          };
        }
      }
    } catch (e) {
      commonPrint.log('Check update failed: $e');
    }
    return null;
  }

  final List<String> _ipInfoSources = [
    'https://1.1.1.1/cdn-cgi/trace',
    'https://cp.cloudflare.com/cdn-cgi/trace',
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
      dio.get<String>(
        url,
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.plain),
      ).then((res) {
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
      }).catchError((e) {
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

  Future<bool> quickPingHelper() async {
    try {
      final response = await _dio
          .get(
            'http://$localhost:$helperPort/ping',
            options: Options(responseType: ResponseType.plain),
          )
          .timeout(const Duration(milliseconds: 500));
      if (response.statusCode != HttpStatus.ok) {
        return false;
      }
      return (response.data as String) == globalState.coreSHA256;
    } catch (_) {
      return false;
    }
  }

  Future<bool> startCoreByHelper(String arg) async {
    final helperAlive = await quickPingHelper();
    if (!helperAlive) {
      commonPrint.log('Helper service is not reachable, skipping startCoreByHelper');
      return false;
    }

    final homeDirPath = await appPath.homeDirPath;
    final body = json.encode({
      'path': appPath.corePath,
      'arg': arg,
      'home_dir': homeDirPath,
    });
    final authHeaders = HelperAuthManager.generateAuthHeaders(body);

    const maxAttempts = 4;
    const interval = Duration(milliseconds: 500);
    const requestTimeout = Duration(seconds: 5);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _dio
            .post(
              'http://$localhost:$helperPort/start',
              data: body,
              options: Options(
                responseType: ResponseType.plain,
                headers: authHeaders,
              ),
            )
            .timeout(requestTimeout);
        if (response.statusCode == HttpStatus.ok) {
          final data = response.data as String;
          if (data.isEmpty) return true;
        }
      } catch (e) {
        if (attempt == maxAttempts) {
          commonPrint.log('Failed to start core by helper after $maxAttempts attempts: $e');
          return false;
        }
      }
      await Future.delayed(interval);
    }
    return false;
  }

  Future<bool> stopCoreByHelper() async {
    try {
      final authHeaders = HelperAuthManager.generateAuthHeaders('');

      final response = await _dio
          .post(
            'http://$localhost:$helperPort/stop',
            options: Options(
              responseType: ResponseType.plain,
              headers: authHeaders,
            ),
          )
          .timeout(const Duration(milliseconds: 2000));
      if (response.statusCode != HttpStatus.ok) {
        return false;
      }
      return true;
    } catch (e) {
      commonPrint.log('Failed to stop core by helper: $e');
      return false;
    }
  }

  Future<bool> setProcessPriorityByHelper(String processName, bool enable) async {
    try {
      final helperAlive = await quickPingHelper();
      if (!helperAlive) {
        commonPrint.log('Helper service is not reachable, skipping setProcessPriorityByHelper');
        return false;
      }

      final body = json.encode({
        'process_name': processName,
        'enable': enable,
      });
      final authHeaders = HelperAuthManager.generateAuthHeaders(body);

      final response = await _dio
          .post(
            'http://$localhost:$helperPort/set_priority',
            data: body,
            options: Options(
              responseType: ResponseType.plain,
              headers: authHeaders,
            ),
          )
          .timeout(const Duration(milliseconds: 2000));
      
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      commonPrint.log('Failed to set process priority by helper: $e');
      return false;
    }
  }
}

final request = Request();
