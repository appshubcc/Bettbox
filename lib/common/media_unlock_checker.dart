import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';

class _BatchTokenInterceptor extends Interceptor {
  _BatchTokenInterceptor(this.token);
  final CancelToken token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token.isCancelled) {
      handler.reject(
        DioException(requestOptions: options, type: DioExceptionType.cancel),
        true,
      );
      return;
    }
    options.cancelToken ??= token;
    handler.next(options);
  }
}

class MediaUnlockChecker {
  static const _timeout = Duration(seconds: 5);

  bool get _useUnifiedDelay => globalState.config.patchClashConfig.unifiedDelay;

  Map<String, dynamic>? _parseJson(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  Future<int> _measureLatency(Dio dio, String url, int initialLatency) async {
    if (!_useUnifiedDelay) return initialLatency;
    final sw = Stopwatch()..start();
    try {
      await dio
          .head<void>(
            url,
            options: Options(
              sendTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 2),
            ),
          )
          .timeout(const Duration(seconds: 3));
      final delay = sw.elapsedMilliseconds;
      return delay > 0 ? delay : initialLatency;
    } catch (_) {
      return initialLatency;
    }
  }

  CancelToken _batchToken = CancelToken();

  CancelToken beginBatch() {
    _batchToken.cancel();
    return _batchToken = CancelToken();
  }

  void cancel() {
    final current = _batchToken;
    _batchToken = CancelToken();
    current.cancel();
  }

  Dio _createDio({bool followRedirects = false}) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: {
          'User-Agent': browserUa,
          'Accept-Language': 'en-US,en;q=0.9',
        },
        followRedirects: followRedirects,
        validateStatus: (status) => true,
      ),
    );
    dio.interceptors.add(_BatchTokenInterceptor(_batchToken));
    return dio;
  }

  static const _openaiUnsupportedRegions = {
    'CN', 'HK', 'MO', 'RU', 'IR', 'KP', 'SY', 'CU', 'VE', 'BY',
    'AF', 'SS', 'YE', 'ZW', 'MM', 'SD', 'SO', 'CF',
  };

  static const _claudeUnsupportedRegions = {
    'CN', 'HK', 'MO', 'RU', 'IR', 'KP', 'SY', 'CU', 'BY', 'VN',
    'TR', 'AF', 'SS', 'YE', 'ZW', 'MM', 'SD', 'SO', 'CF', 'VE',
  };

  static const _geminiUnsupportedRegions = {
    'CN', 'MO', 'RU', 'BY', 'IR', 'KP', 'SY', 'CU', 'VE', 'MM',
    'SD', 'AF', 'SS', 'YE', 'ZW',
  };

  String? _extractColoFromRay(String? ray) {
    if (ray == null) return null;
    final idx = ray.lastIndexOf('-');
    if (idx >= 0 && idx < ray.length - 1) {
      final code = ray.substring(idx + 1).trim().toUpperCase();
      if (code.length >= 3 && code.length <= 4) {
        return code;
      }
    }
    return null;
  }

  bool _isCloudflareChallenge(Response<dynamic> res) {
    final cfMitigated = res.headers.value('cf-mitigated')?.toLowerCase();
    if (cfMitigated == 'challenge') return true;

    final server = res.headers.value('server')?.toLowerCase() ?? '';
    final cfRay = res.headers.value('cf-ray');
    final isCf = server.contains('cloudflare') || cfRay != null;
    if (!isCf) return false;

    final statusCode = res.statusCode ?? 0;
    if (statusCode == 403 || statusCode == 503) return true;

    final data = res.data?.toString() ?? '';
    return data.contains('challenges.cloudflare.com') ||
        data.contains('cf-chl-') ||
        data.contains('/cdn-cgi/challenge-platform/') ||
        data.contains('cf-turnstile') ||
        data.contains(r'__CF$cv$params');
  }

  Future<MediaUnlockResult> _checkCloudflareTrace(
    MediaPlatform platform,
    String domain, {
    List<String>? fallbackDomains,
    Set<String>? unsupportedRegions,
    String? fallbackUrl,
  }) async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final domains = [domain, ...?fallbackDomains];
      MediaUnlockStatus? detectedStatus;
      String? detectedRegion;
      String? detectedColo;
      String? detectedIp;
      bool detectedWarp = false;
      String activeDomain = domain;
      bool hasAnyResponse = false;

      for (final candidate in domains) {
        try {
          final url = 'https://$candidate/cdn-cgi/trace';
          final res = await dio.get<String>(url);
          hasAnyResponse = true;
          final statusCode = res.statusCode ?? 0;
          String? ip;
          String? loc;
          String? colo;
          bool isWarp = false;

          if (statusCode >= 200 &&
              statusCode < 400 &&
              res.data != null &&
              !res.data!.contains('<!DOCTYPE')) {
            final lines = res.data!.split('\n');
            for (final line in lines) {
              final idx = line.indexOf('=');
              if (idx > 0) {
                final k = line.substring(0, idx).trim();
                final v = line.substring(idx + 1).trim();
                if (k == 'ip') ip = v;
                if (k == 'loc') loc = v;
                if (k == 'colo') colo = v;
                if (k == 'warp') isWarp = v != 'off';
              }
            }
          }

          colo ??= _extractColoFromRay(res.headers.value('cf-ray'));
          final region = loc?.toUpperCase();

          if (ip != null && ip.isNotEmpty) {
            final isBlocked = unsupportedRegions != null &&
                region != null &&
                unsupportedRegions.contains(region);
            detectedStatus = isBlocked
                ? MediaUnlockStatus.blocked
                : MediaUnlockStatus.unlocked;
            detectedRegion = region;
            detectedColo = colo?.toUpperCase();
            detectedIp = ip;
            detectedWarp = isWarp;
            activeDomain = candidate;
            break;
          } else if (_isCloudflareChallenge(res)) {
            detectedStatus = MediaUnlockStatus.flagged;
            detectedColo ??= colo?.toUpperCase();
            activeDomain = candidate;
          }
        } catch (_) {}
      }

      final MediaUnlockStatus status;
      if (detectedStatus != null) {
        status = detectedStatus;
      } else if (fallbackUrl != null) {
        final probe = await dio.get<String>(fallbackUrl);
        hasAnyResponse = true;
        final probeCode = probe.statusCode ?? 0;
        final probeColo = _extractColoFromRay(probe.headers.value('cf-ray'));
        if (_isCloudflareChallenge(probe)) {
          status = MediaUnlockStatus.flagged;
          detectedColo ??= probeColo?.toUpperCase();
        } else if (probeCode >= 200 && probeCode < 400) {
          status = MediaUnlockStatus.unlocked;
          detectedColo ??= probeColo?.toUpperCase();
        } else {
          status = MediaUnlockStatus.blocked;
        }
      } else if (!hasAnyResponse) {
        return MediaUnlockResult(
          platform: platform,
          status: MediaUnlockStatus.failed,
          latency: sw.elapsedMilliseconds,
        );
      } else {
        status = MediaUnlockStatus.blocked;
      }

      final latency = await _measureLatency(
        dio,
        'https://$activeDomain/',
        sw.elapsedMilliseconds,
      );

      return MediaUnlockResult(
        platform: platform,
        status: status,
        region: detectedRegion,
        colo: detectedColo,
        ip: detectedIp,
        isWarp: detectedWarp,
        latency: latency,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: platform,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkTencent() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<String>(
        'https://r.inews.qq.com/api/ip2city?otype=jsonp',
      );
      final raw = res.data ?? '';
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      String? ip;
      String? desc;
      String? region;
      if (start >= 0 && end > start) {
        final jsonStr = raw.substring(start, end + 1);
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          ip = json['ip']?.toString();
          final country = json['country']?.toString() ?? '';
          final province = json['province']?.toString() ?? '';
          final city = json['city']?.toString() ?? '';
          final isp = json['isp']?.toString() ?? '';
          if (country == '中国' || country == 'CN') {
            region = 'CN';
          }
          final parts =
              [province, city, isp].where((s) => s.isNotEmpty).toList();
          desc = parts.isNotEmpty ? parts.join(' ') : country;
        }
      }
      return MediaUnlockResult(
        platform: MediaPlatform.tencent,
        status: (ip != null && ip.isNotEmpty)
            ? MediaUnlockStatus.unlocked
            : MediaUnlockStatus.failed,
        region: region ?? 'CN',
        colo: desc,
        ip: ip,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.tencent,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkAlibaba() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final rand =
          List.generate(16, (_) => (ts % 16).toRadixString(16)).join();
      final res = await dio.get<String>(
        'https://$ts-$rand.dns-detect.alicdn.com/api/detect/DescribeDNSLookup?cb=cb',
      );
      final raw = res.data ?? '';
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      String? ip;
      String? ldns;
      if (start >= 0 && end > start) {
        final jsonStr = raw.substring(start, end + 1);
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          final content = json['content'];
          if (content is Map<String, dynamic>) {
            ip = content['localIp']?.toString();
            ldns = content['ldns']?.toString();
          }
        }
      }
      final latency = sw.elapsedMilliseconds;
      return MediaUnlockResult(
        platform: MediaPlatform.alibaba,
        status: (ip != null && ip.isNotEmpty)
            ? MediaUnlockStatus.unlocked
            : MediaUnlockStatus.failed,
        region: 'CN',
        colo: ldns != null ? 'DNS: $ldns' : null,
        ip: ip,
        latency: latency,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.alibaba,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkNetease() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.head<void>(
        'https://necaptcha.nosdn.127.net/ab7f4275c1744aa28e0a8f3a1c58c532.png',
      );
      final ip = res.headers.value('cdn-user-ip');
      final latency = sw.elapsedMilliseconds;
      return MediaUnlockResult(
        platform: MediaPlatform.netease,
        status: (ip != null && ip.isNotEmpty)
            ? MediaUnlockStatus.unlocked
            : (res.statusCode == 200
                  ? MediaUnlockStatus.unlocked
                  : MediaUnlockStatus.failed),
        region: 'CN',
        ip: ip,
        latency: latency,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.netease,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkDouyin() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.head<void>(
        'https://perfops.byte-test.com/500b-bench.jpg',
      );
      final ip = res.headers.value('x-request-ip') ??
          res.headers.value('x-response-cinfo');
      final latency = sw.elapsedMilliseconds;
      return MediaUnlockResult(
        platform: MediaPlatform.douyin,
        status: (ip != null && ip.isNotEmpty)
            ? MediaUnlockStatus.unlocked
            : (res.statusCode == 200
                  ? MediaUnlockStatus.unlocked
                  : MediaUnlockStatus.failed),
        region: 'CN',
        ip: ip,
        latency: latency,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.douyin,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  static const _telegramDcHost = '91.108.56.100';
  static const _telegramDcPort = 80;

  MediaUnlockResult _telegramResult(int latency) {
    return MediaUnlockResult(
      platform: MediaPlatform.telegram,
      status: MediaUnlockStatus.unlocked,
      region: 'SG',
      colo: 'DC5',
      latency: latency,
    );
  }

  bool _isCleartextBlocked(Object error) {
    final raw = error is DioException ? (error.error ?? error) : error;
    return raw.toString().toLowerCase().contains('insecure http');
  }

  Future<int?> _tcpConnectRtt(String host, int port) async {
    final sw = Stopwatch()..start();
    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: _timeout);
      final rtt = sw.elapsedMilliseconds;
      return rtt > 0 ? rtt : 1;
    } catch (_) {
      return null;
    } finally {
      socket?.destroy();
    }
  }

  Future<MediaUnlockResult> checkTelegram() async {
    final sw = Stopwatch()..start();
    final dio = _createDio();
    try {
      final res = await dio.get<void>('http://$_telegramDcHost/');
      if ((res.statusCode ?? 0) > 0) {
        return _telegramResult(sw.elapsedMilliseconds);
      }
    } catch (e) {
      if (_isCleartextBlocked(e)) {
        final rtt = await _tcpConnectRtt(_telegramDcHost, _telegramDcPort);
        if (rtt != null) return _telegramResult(rtt);
      }
    } finally {
      dio.close(force: true);
    }
    return MediaUnlockResult(
      platform: MediaPlatform.telegram,
      status: MediaUnlockStatus.failed,
      latency: sw.elapsedMilliseconds,
    );
  }

  Future<MediaUnlockResult> checkNetflix() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: false);
    try {
      final res1 = await dio.get<ResponseBody>(
        'https://www.netflix.com/title/70143836',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final loc1 = res1.headers.value('location') ?? '';
      final regionMatch = RegExp(r'netflix\.com/([a-z]{2})(?:-[a-z]{2})?/title/').firstMatch(loc1);
      final MediaUnlockStatus status;
      String? region = regionMatch?.group(1)?.toUpperCase();

      if ((res1.statusCode == 301 || res1.statusCode == 302) && loc1.contains('/title/70143836')) {
        status = MediaUnlockStatus.unlocked;
      } else if (res1.statusCode == 200) {
        status = MediaUnlockStatus.unlocked;
      } else {
        final res2 = await dio.get<ResponseBody>(
          'https://www.netflix.com/title/81280792',
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(seconds: 4),
            sendTimeout: const Duration(seconds: 4),
          ),
        );
        final loc2 = res2.headers.value('location') ?? '';
        final regionMatch2 = RegExp(r'netflix\.com/([a-z]{2})(?:-[a-z]{2})?/title/').firstMatch(loc2);
        region = regionMatch2?.group(1)?.toUpperCase() ?? region;
        if ((res2.statusCode == 301 || res2.statusCode == 302) && loc2.contains('/title/81280792')) {
          status = MediaUnlockStatus.limited;
        } else {
          status = MediaUnlockStatus.blocked;
        }
      }
      return MediaUnlockResult(
        platform: MediaPlatform.netflix,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.netflix,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkDisney() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.head<void>(
        'https://www.disneyplus.com/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final loc = res.headers.value('physical-location') ?? res.headers.value('region');
      final region = (loc != null && loc.isNotEmpty) ? loc.toUpperCase() : null;
      final MediaUnlockStatus status;

      if (res.statusCode == 200) {
        final uriStr = res.realUri.toString();
        status = uriStr.contains('unavailable')
            ? MediaUnlockStatus.blocked
            : MediaUnlockStatus.unlocked;
      } else {
        status = MediaUnlockStatus.blocked;
      }
      return MediaUnlockResult(
        platform: MediaPlatform.disney,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.disney,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkYouTube() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<ResponseBody>(
        'https://www.youtube.com/premium',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final realUrl = res.realUri.toString();
      if (realUrl.contains('sorry.google.com')) {
        return MediaUnlockResult(
          platform: MediaPlatform.youtube,
          status: MediaUnlockStatus.blocked,
          latency: sw.elapsedMilliseconds,
        );
      }

      final responseBody = res.data;
      final chunks = <int>[];
      if (responseBody != null) {
        try {
          await for (final chunk in responseBody.stream) {
            chunks.addAll(chunk);
            if (chunks.length >= 150 * 1024) break;
            final currentStr = utf8.decode(chunks, allowMalformed: true);
            if (currentStr.contains('"INNERTUBE_CONTEXT_GL"') ||
                currentStr.contains('Premium is not available') ||
                currentStr.contains('unavailable in your country')) {
              break;
            }
          }
        } catch (_) {}
      }

      final MediaUnlockStatus status;
      String? region;
      if (res.statusCode == 200) {
        final body = utf8.decode(chunks, allowMalformed: true);
        final glMatch = RegExp(r'"INNERTUBE_CONTEXT_GL"\s*:\s*"([A-Z]{2})"').firstMatch(body);
        final ccMatch = RegExp(r'"countryCode"\s*:\s*"([A-Z]{2})"').firstMatch(body);
        final reqDomainMatch = RegExp(r'"REQUEST_DOMAIN"\s*:\s*"([a-zA-Z]{2})"').firstMatch(body);
        region = glMatch?.group(1) ?? ccMatch?.group(1) ?? reqDomainMatch?.group(1)?.toUpperCase();

        if (body.contains('Premium is not available in your country') ||
            body.contains('unavailable in your country')) {
          status = MediaUnlockStatus.flagged;
        } else {
          status = MediaUnlockStatus.unlocked;
        }
      } else {
        status = MediaUnlockStatus.blocked;
      }
      return MediaUnlockResult(
        platform: MediaPlatform.youtube,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.youtube,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkYouTubeMusic() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<ResponseBody>(
        'https://music.youtube.com/',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
            'Accept-Language': 'en-US,en;q=0.9',
          },
        ),
      );
      final realUrl = res.realUri.toString();
      if (realUrl.contains('sorry.google.com') ||
          realUrl.contains('unavailable')) {
        return MediaUnlockResult(
          platform: MediaPlatform.youtubemusic,
          status: MediaUnlockStatus.blocked,
          latency: sw.elapsedMilliseconds,
        );
      }

      final responseBody = res.data;
      final chunks = <int>[];
      if (responseBody != null) {
        try {
          await for (final chunk in responseBody.stream) {
            chunks.addAll(chunk);
            if (chunks.length >= 150 * 1024) break;
            final currentStr = utf8.decode(chunks, allowMalformed: true);
            if (currentStr.contains('"INNERTUBE_CONTEXT_GL"') ||
                currentStr.contains('"countryCode"') ||
                currentStr.contains('not available in your') ||
                currentStr.contains('unavailable in your country')) {
              break;
            }
          }
        } catch (_) {}
      }

      final MediaUnlockStatus status;
      String? region;
      if (res.statusCode == 200) {
        final body = utf8.decode(chunks, allowMalformed: true);
        final glMatch = RegExp(
          r'"(?:INNERTUBE_CONTEXT_GL|countryCode|GL)"\s*:\s*"([A-Z]{2})"',
        ).firstMatch(body);
        region = glMatch?.group(1);

        if (body.contains('not available in your area') ||
            body.contains('not available in your country') ||
            body.contains('unavailable in your country') ||
            region == 'CN' ||
            region == 'RU') {
          status = MediaUnlockStatus.blocked;
        } else {
          status = MediaUnlockStatus.unlocked;
        }
      } else {
        status = MediaUnlockStatus.blocked;
      }
      return MediaUnlockResult(
        platform: MediaPlatform.youtubemusic,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.youtubemusic,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkReddit() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.head<void>(
        'https://www.reddit.com/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final timing = res.headers.value('server-timing') ?? '';
      final popMatch = RegExp(r'p=([A-Z]{3})').firstMatch(timing);
      final rawRegion = popMatch?.group(1);
      final region = rawRegion != null ? utils.normalizeRegion(rawRegion) : null;
      final MediaUnlockStatus status;

      if (res.statusCode == 200) {
        status = MediaUnlockStatus.unlocked;
      } else if (res.statusCode == 403) {
        status = MediaUnlockStatus.blocked;
      } else {
        final statusCode = res.statusCode ?? 0;
        status = statusCode >= 200 && statusCode < 400
            ? MediaUnlockStatus.unlocked
            : MediaUnlockStatus.blocked;
      }
      return MediaUnlockResult(
        platform: MediaPlatform.reddit,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.reddit,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkSpotify() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<ResponseBody>(
        'https://www.spotify.com/signup',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final finalUrl = res.realUri.toString();
      final pathMatch = RegExp(r'spotify\.com/([a-z]{2})(?:-[a-z]{2})?/').firstMatch(finalUrl);
      String? rawRegion = pathMatch?.group(1)?.toUpperCase();

      if (rawRegion == null) {
        final responseBody = res.data;
        final chunks = <int>[];
        if (responseBody != null) {
          try {
            await for (final chunk in responseBody.stream) {
              chunks.addAll(chunk);
              if (chunks.length >= 48 * 1024) break;
              final currentStr = utf8.decode(chunks, allowMalformed: true);
              if (currentStr.contains('geoCountry')) break;
            }
          } catch (_) {}
        }
        final body = utf8.decode(chunks, allowMalformed: true);
        final geoMatch = RegExp(r'geoCountry"?\s*:\s*"([A-Z]{2})"').firstMatch(body);
        rawRegion = geoMatch?.group(1);
      }

      final region = rawRegion != null ? utils.normalizeRegion(rawRegion) : null;
      final MediaUnlockStatus status;
      if (finalUrl.contains('why-not-available')) {
        status = MediaUnlockStatus.blocked;
      } else if (finalUrl.contains('signup') && (res.statusCode == 200 || (res.statusCode ?? 0) < 400)) {
        status = MediaUnlockStatus.unlocked;
      } else if (res.statusCode == 403 || res.statusCode == 429) {
        status = MediaUnlockStatus.blocked;
      } else {
        status = (res.statusCode ?? 0) < 400
            ? MediaUnlockStatus.unlocked
            : MediaUnlockStatus.blocked;
      }

      return MediaUnlockResult(
        platform: MediaPlatform.spotify,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.spotify,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkTikTok() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      Response<dynamic>? res;
      try {
        final r1 = await dio.head<dynamic>(
          'https://perfops1.byteperf.com/500b-bench.jpg',
        );
        if (r1.statusCode == 200) {
          res = r1;
        } else {
          res = await dio.head<dynamic>(
            'https://perfops2.byteperf.com/500b-bench.jpg',
          );
        }
      } catch (_) {
        res = await dio.head<dynamic>(
          'https://perfops2.byteperf.com/500b-bench.jpg',
        );
      }

      final statusCode = res.statusCode ?? 0;
      final via = res.headers.value('via') ?? '';
      final cinfo = res.headers.value('x-response-cinfo') ??
          res.headers.value('x-request-ip') ??
          '';
      final viaMatch = RegExp(
        r'oversea-([A-Z]{2})-',
        caseSensitive: false,
      ).firstMatch(via);
      final cinfoMatch = RegExp(
        r'\b([A-Z]{2})\b',
      ).firstMatch(cinfo.replaceAll(RegExp(r'\d+\.\d+\.\d+\.\d+'), ''));
      final rawRegion = viaMatch?.group(1) ?? cinfoMatch?.group(1);
      final region = rawRegion != null ? utils.normalizeRegion(rawRegion) : null;
      final isSuccess = statusCode >= 200 && statusCode < 400;
      return MediaUnlockResult(
        platform: MediaPlatform.tiktok,
        status:
            isSuccess ? MediaUnlockStatus.unlocked : MediaUnlockStatus.blocked,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.tiktok,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkGitHub() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.head<void>(
        'https://github.com/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final edge = res.headers.value('x-github-edge-region') ?? '';
      final rawEdge = edge.isNotEmpty ? edge.toUpperCase() : null;
      final region = rawEdge != null ? utils.normalizeRegion(rawEdge) : null;
      final MediaUnlockStatus status;
      if (res.statusCode == 200) {
        status = MediaUnlockStatus.unlocked;
      } else if (res.statusCode == 403) {
        status = MediaUnlockStatus.blocked;
      } else {
        status = MediaUnlockStatus.failed;
      }
      return MediaUnlockResult(
        platform: MediaPlatform.github,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.github,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkWikipedia() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<ResponseBody>(
        'https://www.wikipedia.org/',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final cookies = res.headers['set-cookie']?.join('; ') ?? '';
      final geoMatch = RegExp(r'GeoIP=([A-Z]{2}):').firstMatch(cookies);
      final region = geoMatch?.group(1);
      final status = res.statusCode == 200
          ? MediaUnlockStatus.unlocked
          : MediaUnlockStatus.blocked;
      return MediaUnlockResult(
        platform: MediaPlatform.wikipedia,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.wikipedia,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkSteam() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<ResponseBody>(
        'https://store.steampowered.com/',
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final responseBody = res.data;
      final chunks = <int>[];
      if (responseBody != null) {
        try {
          await for (final chunk in responseBody.stream) {
            chunks.addAll(chunk);
            if (chunks.length >= 64 * 1024) break;
            final currentStr = utf8.decode(chunks, allowMalformed: true);
            if (currentStr.contains('country_code') ||
                currentStr.contains('countrycode') ||
                currentStr.contains('COUNTRY')) {
              break;
            }
          }
        } catch (_) {}
      }

      final body = utf8.decode(chunks, allowMalformed: true);
      final countryMatch = RegExp(
        r'(?:COUNTRY|country_code|countrycode)(?:&quot;|"):\s*(?:&quot;|")([A-Z]{2})',
      ).firstMatch(body);
      String? region = countryMatch?.group(1);
      final status = res.statusCode == 200
          ? MediaUnlockStatus.unlocked
          : MediaUnlockStatus.blocked;
      return MediaUnlockResult(
        platform: MediaPlatform.steam,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.steam,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkGemini() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<String>(
        'https://gemini.google.com/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final realUrl = res.realUri.toString();
      if (realUrl.contains('sorry.google.com')) {
        return MediaUnlockResult(
          platform: MediaPlatform.gemini,
          status: MediaUnlockStatus.blocked,
          latency: sw.elapsedMilliseconds,
        );
      }

      final body = res.data ?? '';
      final regMatch = RegExp(r',2,1,200,"([A-Z]{3})"').firstMatch(body);
      final altMatch = RegExp(r'\[1,null,null,\d+,\d+,"([A-Z]{3})"').firstMatch(body);
      final rawRegion = regMatch?.group(1) ?? altMatch?.group(1);
      final region = rawRegion != null ? utils.normalizeRegion(rawRegion) : null;

      final isUnavailable = realUrl.contains('unavailable') ||
          body.contains('is not supported in your country') ||
          body.contains("isn't supported in your country") ||
          body.contains('not available in your country') ||
          body.contains('unavailable in your country') ||
          body.contains('is not currently supported') ||
          body.contains("isn't currently supported");

      final MediaUnlockStatus status;
      if (res.statusCode != 200 || isUnavailable) {
        status = MediaUnlockStatus.blocked;
      } else if (region != null && _geminiUnsupportedRegions.contains(region)) {
        status = MediaUnlockStatus.blocked;
      } else {
        status = MediaUnlockStatus.unlocked;
      }

      return MediaUnlockResult(
        platform: MediaPlatform.gemini,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.gemini,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkApple() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<String>('https://gspe1-ssl.ls.apple.com/pep/gcc');
      final text = (res.data ?? '').trim().toUpperCase();
      final region = text.length == 2 ? text : null;
      final status = (res.statusCode == 200 && region != null)
          ? MediaUnlockStatus.unlocked
          : MediaUnlockStatus.blocked;
      return MediaUnlockResult(
        platform: MediaPlatform.apple,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.apple,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkOneTrust() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.get<String>(
        'https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location',
      );
      final body = res.data ?? '';
      final countryMatch =
          RegExp(r'"country":\s*"([A-Z]{2})"').firstMatch(body);
      final region = countryMatch?.group(1);
      final status = (res.statusCode == 200 && region != null)
          ? MediaUnlockStatus.unlocked
          : MediaUnlockStatus.blocked;
      return MediaUnlockResult(
        platform: MediaPlatform.onetrust,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.onetrust,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkIqiyi() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      final res = await dio.head<void>(
        'https://www.iq.com/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final cookies = res.headers['set-cookie']?.join('; ') ?? '';
      final customIp = res.headers.value('x-custom-client-ip') ?? '';
      final modMatch =
          RegExp(r'mod=([a-zA-Z]+)').firstMatch('$cookies $customIp');
      final rawMod = modMatch?.group(1)?.toUpperCase();
      final region = rawMod != null ? utils.normalizeRegion(rawMod) : null;
      final status = res.statusCode == 200
          ? MediaUnlockStatus.unlocked
          : MediaUnlockStatus.blocked;
      return MediaUnlockResult(
        platform: MediaPlatform.iqiyi,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.iqiyi,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkBilibili() async {
    final sw = Stopwatch()..start();
    final dio = _createDio(followRedirects: true);
    try {
      String? region;
      MediaUnlockStatus status = MediaUnlockStatus.blocked;

      final resZone = await dio.get<dynamic>(
        'https://api.bilibili.com/x/web-interface/zone',
      );
      final zoneJson = _parseJson(resZone.data);
      if (zoneJson != null && zoneJson['code'] == 0) {
        final data = zoneJson['data'];
        if (data is Map<String, dynamic>) {
          final code = data['country_code']?.toString();
          final country = data['country']?.toString() ?? '';
          if (code == '86' || country.contains('中国')) {
            region = 'CN';
          } else if (code == '886' || country.contains('台湾')) {
            region = 'TW';
          } else if (code == '852' || country.contains('香港')) {
            region = 'HK';
          } else if (code == '853' || country.contains('澳门')) {
            region = 'MO';
          }
        }
      }

      final resPlay = await dio.get<dynamic>(
        'https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&module=bangumi',
      );
      final playJson = _parseJson(resPlay.data);
      final playCode = playJson?['code'];

      if (playCode == 0) {
        status = MediaUnlockStatus.unlocked;
        region ??= 'CN';
      } else {
        final resTw = await dio.get<dynamic>(
          'https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&module=bangumi',
        );
        final twJson = _parseJson(resTw.data);
        if (twJson?['code'] == 0) {
          status = MediaUnlockStatus.unlocked;
          region ??= 'TW';
        } else if (resZone.statusCode == 200) {
          status = MediaUnlockStatus.limited;
        }
      }

      return MediaUnlockResult(
        platform: MediaPlatform.bilibili,
        status: status,
        region: region,
        latency: sw.elapsedMilliseconds,
      );
    } catch (_) {
      return MediaUnlockResult(
        platform: MediaPlatform.bilibili,
        status: MediaUnlockStatus.failed,
        latency: sw.elapsedMilliseconds,
      );
    } finally {
      dio.close(force: true);
    }
  }

  Future<MediaUnlockResult> checkPlatform(MediaPlatform platform) {
    final checkFuture = switch (platform) {
      MediaPlatform.openai => _checkCloudflareTrace(
        MediaPlatform.openai,
        'chatgpt.com',
        unsupportedRegions: _openaiUnsupportedRegions,
      ),
      MediaPlatform.claude => _checkCloudflareTrace(
        MediaPlatform.claude,
        'api.anthropic.com',
        unsupportedRegions: _claudeUnsupportedRegions,
      ),
      MediaPlatform.gemini => checkGemini(),
      MediaPlatform.grok =>
        _checkCloudflareTrace(MediaPlatform.grok, 'api.x.ai'),
      MediaPlatform.openrouter =>
        _checkCloudflareTrace(MediaPlatform.openrouter, 'openrouter.ai'),
      MediaPlatform.poe =>
        _checkCloudflareTrace(MediaPlatform.poe, 'poe.com'),
      MediaPlatform.suno =>
        _checkCloudflareTrace(MediaPlatform.suno, 'suno.com'),
      MediaPlatform.cloudflare =>
        _checkCloudflareTrace(MediaPlatform.cloudflare, 'api.cloudflare.com'),
      MediaPlatform.perplexity =>
        _checkCloudflareTrace(MediaPlatform.perplexity, 'www.perplexity.ai'),
      MediaPlatform.netflix => checkNetflix(),
      MediaPlatform.disney => checkDisney(),
      MediaPlatform.youtube => checkYouTube(),
      MediaPlatform.youtubemusic => checkYouTubeMusic(),
      MediaPlatform.spotify => checkSpotify(),
      MediaPlatform.tiktok => checkTikTok(),
      MediaPlatform.bilibili => checkBilibili(),
      MediaPlatform.iqiyi => checkIqiyi(),
      MediaPlatform.crunchyroll =>
_checkCloudflareTrace(MediaPlatform.crunchyroll, 'crunchyroll.com'),
      MediaPlatform.missav => _checkCloudflareTrace(
        MediaPlatform.missav,
        'missav.ws',
        fallbackDomains: const ['missav.ai'],
      ),
      MediaPlatform.ehentai =>
_checkCloudflareTrace(MediaPlatform.ehentai, 'e-hentai.org'),
      MediaPlatform.tencent => checkTencent(),
      MediaPlatform.alibaba => checkAlibaba(),
      MediaPlatform.netease => checkNetease(),
      MediaPlatform.douyin => checkDouyin(),
      MediaPlatform.cloudflarecn => _checkCloudflareTrace(
        MediaPlatform.cloudflarecn,
        'www.cloudflare-cn.com',
      ),
      MediaPlatform.reddit => checkReddit(),
      MediaPlatform.x => _checkCloudflareTrace(
        MediaPlatform.x,
        'x.com',
        fallbackUrl: 'https://x.com/',
      ),
      MediaPlatform.discord =>
        _checkCloudflareTrace(MediaPlatform.discord, 'gateway.discord.gg'),
      MediaPlatform.v2ex =>
        _checkCloudflareTrace(MediaPlatform.v2ex, 'v2ex.com'),
      MediaPlatform.medium =>
        _checkCloudflareTrace(MediaPlatform.medium, 'medium.com'),
      MediaPlatform.stackoverflow => _checkCloudflareTrace(
        MediaPlatform.stackoverflow,
        'stackoverflow.com',
      ),
      MediaPlatform.quora =>
        _checkCloudflareTrace(MediaPlatform.quora, 'www.quora.com'),
      MediaPlatform.telegram => checkTelegram(),
      MediaPlatform.github => checkGitHub(),
      MediaPlatform.wikipedia => checkWikipedia(),
      MediaPlatform.apple => checkApple(),
      MediaPlatform.onetrust => checkOneTrust(),
      MediaPlatform.gitlab =>
        _checkCloudflareTrace(MediaPlatform.gitlab, 'gitlab.com'),
      MediaPlatform.npm =>
        _checkCloudflareTrace(MediaPlatform.npm, 'registry.npmjs.org'),
      MediaPlatform.cdnjs => _checkCloudflareTrace(
        MediaPlatform.cdnjs,
        'cdnjs.cloudflare.com',
      ),
      MediaPlatform.unpkg =>
        _checkCloudflareTrace(MediaPlatform.unpkg, 'unpkg.com'),
      MediaPlatform.nodejs =>
        _checkCloudflareTrace(MediaPlatform.nodejs, 'nodejs.org'),
      MediaPlatform.steam => checkSteam(),
      MediaPlatform.epic =>
        _checkCloudflareTrace(MediaPlatform.epic, 'store.epicgames.com'),
      MediaPlatform.ubisoft =>
        _checkCloudflareTrace(MediaPlatform.ubisoft, 'store.ubisoft.com'),
      MediaPlatform.humblebundle =>
        _checkCloudflareTrace(MediaPlatform.humblebundle, 'humblebundle.com'),
      MediaPlatform.coinbase =>
        _checkCloudflareTrace(MediaPlatform.coinbase, 'www.coinbase.com'),
      MediaPlatform.okx =>
        _checkCloudflareTrace(MediaPlatform.okx, 'www.okx.com'),
      MediaPlatform.kraken =>
        _checkCloudflareTrace(MediaPlatform.kraken, 'www.kraken.com'),
      MediaPlatform.cryptocom =>
        _checkCloudflareTrace(MediaPlatform.cryptocom, 'crypto.com'),
      MediaPlatform.phantom =>
        _checkCloudflareTrace(MediaPlatform.phantom, 'phantom.com'),
    };
    return checkFuture.timeout(
      const Duration(seconds: 8),
      onTimeout: () => MediaUnlockResult(
        platform: platform,
        status: MediaUnlockStatus.failed,
      ),
    );
  }

  Future<Map<MediaPlatform, MediaUnlockResult>> checkAll({
    List<MediaPlatform>? platforms,
    void Function(MediaUnlockResult result)? onProgress,
  }) async {
    final token = beginBatch();
    final targetPlatforms = platforms ?? MediaPlatform.values;
    final results = <MediaPlatform, MediaUnlockResult>{};
    final queue = List<MediaPlatform>.from(targetPlatforms);
    const concurrency = 8;
    final workers = List.generate(concurrency, (_) async {
      while (true) {
        if (token.isCancelled || queue.isEmpty) break;
        final p = queue.removeAt(0);
        try {
          final r = await checkPlatform(p);
          if (token.isCancelled) break;
          results[p] = r;
          onProgress?.call(r);
        } catch (_) {
          if (token.isCancelled) break;
          final fail = MediaUnlockResult(
            platform: p,
            status: MediaUnlockStatus.failed,
          );
          results[p] = fail;
          onProgress?.call(fail);
        }
      }
    });
    await Future.wait(workers);
    return results;
  }
}
