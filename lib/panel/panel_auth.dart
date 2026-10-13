import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/panel/panel_site.dart';
import 'package:bett_box/state.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

export 'package:bett_box/panel/panel_site.dart'
    show panelSiteBase, panelApiRelayBase, panelSubRelayBase;

// [Gamebox] 面板登录 / API / 订阅：先反代，超时或链路异常再回源站。
const _subscribePath = '/AAA8624DACB3448683390D4A72575AAA';
const _passportLogin = '/api/v1/passport/auth/login';
const _legacyLogin = '/v1/auth/login';
const _legacyMe = '/v1/me';
const _changePassword = '/api/v1/user/change-password';
const _logoutPaths = ['/api/v1/passport/auth/logout', '/v1/auth/logout'];
const _rememberKeyLabel = 'Gamebox.panel.remember.v1';
const _relayRequestTimeout = Duration(seconds: 12);
const _originRequestTimeout = Duration(seconds: 20);

class RememberedPanelLogin {
  const RememberedPanelLogin({
    required this.username,
    required this.password,
    required this.autoLogin,
  });

  final String username;
  final String password;
  final bool autoLogin;
}

class _PanelSession {
  const _PanelSession({
    required this.authData,
    required this.subscribeToken,
    required this.username,
  });

  final String authData;
  final String subscribeToken;
  final String username;
}

String _trimBase(String raw) {
  var u = raw.trim();
  if (u.isEmpty) return '';
  if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(u)) {
    u = 'https://$u';
  }
  return u.replaceAll(RegExp(r'/+$'), '');
}

Future<String> _homeFile(String name) async {
  return p.join(await appPath.homeDirPath, name);
}

Future<String> _deviceId() async {
  final file = File(await _homeFile('panel_device_id'));
  if (await file.exists()) {
    final id = (await file.readAsString()).trim();
    if (id.length >= 8) return id;
  }
  final id =
      'd_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  await file.writeAsString(id);
  return id;
}

List<int> _xor(List<int> data) {
  final key = sha256.convert(utf8.encode(_rememberKeyLabel)).bytes;
  return [for (var i = 0; i < data.length; i++) data[i] ^ key[i % key.length]];
}

String _hideSecret(String text) => base64Encode(_xor(utf8.encode(text)));

String _revealSecret(String encoded) =>
    utf8.decode(_xor(base64Decode(encoded)));

HttpClient _directClient({Duration? timeout}) {
  // [Gamebox] 面板请求不走系统/HTTP 代理。findProxy 固定 DIRECT。
  // TUN 下还靠 panelTunDirectRules 把域名打成 DIRECT，否则仍会进节点。
  final client = HttpClient();
  client.findProxy = (_) => 'DIRECT';
  client.connectionTimeout = timeout ?? const Duration(seconds: 10);
  client.badCertificateCallback = (_, _, _) => true;
  client.userAgent = AppIdentity.productName;
  return client;
}

/// 链路层失败才回源；业务 4xx（设备满/封禁等）不回源。
bool _isTransientFailure(Object error) {
  if (error is TimeoutException ||
      error is SocketException ||
      error is HandshakeException ||
      error is TlsException ||
      error is HttpException ||
      error is IOException) {
    return true;
  }
  final text = error.toString().toLowerCase();
  return text.contains('timeout') ||
      text.contains('timed out') ||
      text.contains('connection reset') ||
      text.contains('connection refused') ||
      text.contains('network is unreachable') ||
      text.contains('failed host lookup') ||
      text.contains('certificate');
}

bool _isBadGatewayStatus(int status) =>
    status == 502 || status == 503 || status == 504;

/// [relayBases] 先试，失败再 [originBase]。已拿到业务响应（含 4xx）则不再回源。
Future<T> _preferRelayThenOrigin<T>({
  required List<String> relayBases,
  required String originBase,
  required Future<T> Function(String base) run,
  bool Function(T value)? shouldRetry,
}) async {
  final seen = <String>{};
  final bases = <String>[
    for (final raw in [...relayBases, originBase])
      if (_trimBase(raw).isNotEmpty && seen.add(_trimBase(raw))) _trimBase(raw),
  ];
  Object? lastError;
  for (var i = 0; i < bases.length; i++) {
    final base = bases[i];
    final isLast = i == bases.length - 1;
    try {
      final value = await run(base);
      if (!isLast && shouldRetry != null && shouldRetry(value)) {
        lastError = Exception('relay_soft_fail');
        continue;
      }
      return value;
    } catch (e) {
      lastError = e;
      if (!isLast && _isTransientFailure(e)) {
        continue;
      }
      rethrow;
    }
  }
  // [Gamebox] 反代+源站都失败时给出可定位的中文，避免只抛 request_failed。
  final detail = lastError?.toString().replaceFirst('Exception: ', '') ?? '';
  throw Exception(
    detail.isEmpty
        ? '网络请求失败：反代与源站均不可用'
        : '网络请求失败：反代与源站均不可用（$detail）',
  );
}

Future<({int status, String text})> _postJsonApi(
  String path,
  Map<String, String> body, {
  Map<String, String>? headers,
}) {
  final origin = _trimBase(panelSiteBase);
  return _preferRelayThenOrigin(
    relayBases: const [panelApiRelayBase],
    originBase: panelSiteBase,
    shouldRetry: (res) => _isBadGatewayStatus(res.status),
    run: (base) => _postJson(
      '$base$path',
      body,
      headers: headers,
      timeout: base == origin ? _originRequestTimeout : _relayRequestTimeout,
    ),
  );
}

Future<({int status, String text})> _getTextApi(
  String path, {
  Map<String, String>? headers,
  Duration? relayTimeout,
  Duration? originTimeout,
}) {
  return _preferRelayThenOrigin(
    relayBases: const [panelApiRelayBase],
    originBase: panelSiteBase,
    shouldRetry: (res) => _isBadGatewayStatus(res.status),
    run: (base) {
      final isRelay = base != _trimBase(panelSiteBase);
      return _getText(
        '$base$path',
        headers: headers,
        timeout: isRelay
            ? (relayTimeout ?? _relayRequestTimeout)
            : (originTimeout ?? _originRequestTimeout),
      );
    },
  );
}

Future<Map<String, String>> _headers({String? bearer}) async {
  final headers = <String, String>{
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.userAgentHeader: AppIdentity.productName,
    'X-Device-Id': await _deviceId(),
    'X-Client-OS': 'windows',
  };
  if (bearer != null && bearer.isNotEmpty) {
    headers[HttpHeaders.authorizationHeader] = 'Bearer $bearer';
  }
  return headers;
}

String _httpFailure(int status, String text, String path) {
  final t = text.trim();
  if (t.startsWith('<') || t.contains('<!DOCTYPE') || t.contains('<html')) {
    return 'HTTP $status：返回了网页而非 JSON（$path）';
  }
  return t.length > 280 ? '${t.substring(0, 280)}…' : (t.isEmpty ? 'HTTP $status' : t);
}

String? _jsonMessage(Object? parsed) {
  if (parsed is! Map) return null;
  final message = parsed['message'];
  if (message is String && message.trim().isNotEmpty) return message;
  final error = parsed['error'];
  if (error is String && error.trim().isNotEmpty) return error;
  return null;
}

Future<({int status, String text})> _postJson(
  String url,
  Map<String, String> body, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final client = _directClient();
  try {
    final request = await client.postUrl(Uri.parse(url));
    (headers ?? await _headers()).forEach(request.headers.set);
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close().timeout(timeout);
    final text = await response.transform(utf8.decoder).join();
    return (status: response.statusCode, text: text);
  } finally {
    client.close(force: true);
  }
}

Future<({int status, String text})> _getText(
  String url, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final client = _directClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    (headers ?? await _headers()).forEach(request.headers.set);
    final response = await request.close().timeout(timeout);
    final text = await response.transform(utf8.decoder).join();
    return (status: response.statusCode, text: text);
  } finally {
    client.close(force: true);
  }
}

({String authData, String subscribeToken}) _parsePassport(Object? parsed) {
  if (parsed is! Map) {
    throw const FormatException('missing_auth_data');
  }
  final data = parsed['data'];
  var authData = '';
  var subscribeToken = '';
  if (data is Map) {
    final a = data['auth_data'];
    final t = data['token'];
    if (a is String) authData = a;
    if (t is String) subscribeToken = t;
  }
  if (authData.isEmpty) {
    final a = parsed['auth_data'];
    if (a is String) authData = a;
  }
  if (authData.isEmpty) {
    throw const FormatException('missing_auth_data');
  }
  if (subscribeToken.isEmpty) {
    throw const FormatException('missing_subscribe_token');
  }
  return (authData: authData, subscribeToken: subscribeToken);
}

Future<_PanelSession> _loginLegacy(String identifier, String password) async {
  final res = await _postJsonApi(_legacyLogin, {
    'username': identifier,
    'password': password,
  });
  Object? parsed;
  try {
    parsed = jsonDecode(res.text);
  } catch (_) {
    throw Exception(_httpFailure(res.status, res.text, _legacyLogin));
  }
  if (res.status < 200 || res.status >= 300) {
    throw Exception(
      _jsonMessage(parsed) ?? _httpFailure(res.status, res.text, _legacyLogin),
    );
  }
  final map = parsed is Map ? parsed : <String, dynamic>{};
  final accessToken = map['access_token'];
  if (accessToken is! String || accessToken.isEmpty) {
    throw Exception('旧版接口未返回 access_token');
  }
  final me = await _getTextApi(
    _legacyMe,
    headers: await _headers(bearer: accessToken),
  );
  Object? meParsed;
  try {
    meParsed = jsonDecode(me.text);
  } catch (_) {
    throw Exception('无法解析 /v1/me 响应');
  }
  if (me.status < 200 || me.status >= 300) {
    throw Exception(_httpFailure(me.status, me.text, _legacyMe));
  }
  String? subToken;
  if (meParsed is Map) {
    final user = meParsed['user'];
    if (user is Map) {
      final token = user['sub_token'];
      if (token is String) subToken = token;
    }
  }
  if (subToken == null || subToken.isEmpty) {
    throw Exception('无法从 /v1/me 获取 sub_token');
  }
  return _PanelSession(
    authData: accessToken,
    subscribeToken: subToken,
    username: identifier,
  );
}

Future<_PanelSession> _login(String identifier, String password) async {
  final id = identifier.trim();
  final attempts = <Map<String, String>>[
    id.contains('@')
        ? {'email': id, 'password': password}
        : {'username': id, 'password': password},
  ];
  if (!id.contains('@')) {
    attempts.add({'email': id, 'password': password});
  }
  var lastErr = 'login_failed';
  for (final body in attempts) {
    final res = await _postJsonApi(_passportLogin, body);
    if (res.status == 404) {
      return _loginLegacy(id, password);
    }
    Object? parsed;
    try {
      parsed = jsonDecode(res.text);
    } catch (_) {
      if (res.status < 200 || res.status >= 300) {
        lastErr = _httpFailure(res.status, res.text, _passportLogin);
        continue;
      }
      throw Exception(res.text.isEmpty ? 'HTTP ${res.status}' : res.text);
    }
    if (res.status < 200 || res.status >= 300) {
      lastErr =
          _jsonMessage(parsed) ??
          _httpFailure(res.status, res.text, _passportLogin);
      // [Gamebox] 设备满、封禁、过期都是 403。不要再试邮箱，否则会把这条错误盖掉。
      if (res.status == 403) {
        throw Exception(lastErr);
      }
      continue;
    }
    final tokens = _parsePassport(parsed);
    return _PanelSession(
      authData: tokens.authData,
      subscribeToken: tokens.subscribeToken,
      username: id,
    );
  }
  // [Gamebox] 与 iGame（invalid_credentials / login_failed）一致的可读中文。
  if (lastErr == 'login_failed' ||
      lastErr == 'invalid_credentials' ||
      lastErr.toLowerCase().contains('login_failed') ||
      lastErr.toLowerCase().contains('invalid_credentials')) {
    throw Exception('用户名或密码错误');
  }
  throw Exception(lastErr);
}

Future<void> _writeJson(String name, Map<String, Object?> data) async {
  final file = File(await _homeFile(name));
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}

Future<Map<String, Object?>?> _readJson(String name) async {
  final file = File(await _homeFile(name));
  if (!await file.exists()) return null;
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}
  return null;
}

Future<void> _saveSession(_PanelSession session) async {
  await _writeJson('panel_session.json', {
    'authData': session.authData,
    'subscribeToken': session.subscribeToken,
    'username': session.username,
  });
  globalState.panelAccountName.value = session.username;
}

Future<_PanelSession?> _loadSession() async {
  final data = await _readJson('panel_session.json');
  if (data == null) return null;
  final authData = data['authData'];
  final subscribeToken = data['subscribeToken'];
  final username = data['username'];
  if (authData is! String ||
      subscribeToken is! String ||
      username is! String ||
      authData.isEmpty ||
      subscribeToken.isEmpty) {
    return null;
  }
  return _PanelSession(
    authData: authData,
    subscribeToken: subscribeToken,
    username: username,
  );
}

Future<void> _clearSession() async {
  final file = File(await _homeFile('panel_session.json'));
  if (await file.exists()) {
    await file.delete();
  }
  globalState.panelAccountName.value = '';
}

Future<void> saveRememberedPanelLogin({
  required String username,
  required String password,
  required bool remember,
  required bool autoLogin,
}) async {
  final file = File(await _homeFile('panel_remember.json'));
  if (!remember) {
    if (await file.exists()) {
      await file.delete();
    }
    return;
  }
  await _writeJson('panel_remember.json', {
    'username': username.trim(),
    'password': _hideSecret(password),
    'remember': true,
    'autoLogin': autoLogin,
  });
}

Future<RememberedPanelLogin?> loadRememberedPanelLogin() async {
  final data = await _readJson('panel_remember.json');
  if (data == null) return null;
  if (data['remember'] != true) return null;
  final username = data['username'];
  final password = data['password'];
  if (username is! String || password is! String || username.isEmpty) {
    return null;
  }
  try {
    return RememberedPanelLogin(
      username: username,
      password: _revealSecret(password),
      autoLogin: data['autoLogin'] == true,
    );
  } catch (_) {
    return null;
  }
}

Future<void> _serverLogout(String authData) async {
  final headers = await _headers(bearer: authData);
  final origin = _trimBase(panelSiteBase);
  for (final path in _logoutPaths) {
    try {
      final res = await _preferRelayThenOrigin(
        relayBases: const [panelApiRelayBase],
        originBase: panelSiteBase,
        shouldRetry: (r) => _isBadGatewayStatus(r.status),
        run: (base) => _postJson(
          '$base$path',
          const {},
          headers: headers,
          timeout: base == origin
              ? const Duration(seconds: 6)
              : const Duration(seconds: 5),
        ),
      );
      // [Gamebox] 一条成功就停。托盘退出要等这个请求，避免两条都卡满超时。
      if (res.status >= 200 && res.status < 300) return;
    } catch (_) {}
  }
}

// [Gamebox] 订阅 403 的正文是 error 字段，不能只显示 HTTP 403。
String _subscribeFailure(int status, String text) {
  Object? parsed;
  try {
    parsed = jsonDecode(text);
  } catch (_) {}
  final error = parsed is Map ? '${parsed['error'] ?? ''}' : '';
  final message = parsed is Map ? '${parsed['message'] ?? ''}' : '';
  final blob = '$error $message $text';
  final lower = blob.toLowerCase();
  if (lower.contains('device_limit') ||
      blob.contains('已在别处登录') ||
      blob.contains('设备')) {
    return '在线设备已达上限';
  }
  if (lower.contains('account_banned') || blob.contains('封禁')) {
    return '账号已封禁';
  }
  if (lower.contains('account_expired') || blob.contains('过期')) {
    return '账号已过期';
  }
  if (lower.contains('account_unavailable') || blob.contains('不可用')) {
    return '账号当前不可用，无法拉取订阅。如有疑问请联系管理员。';
  }
  return 'HTTP $status';
}

Future<
  ({
    Uint8List bytes,
    String? disposition,
    String? userinfo,
  })
> _downloadSubscribeBytes(String url, {required Duration timeout}) async {
  final client = _directClient(
    timeout: timeout > const Duration(seconds: 10)
        ? const Duration(seconds: 10)
        : timeout,
  );
  try {
    final request = await client.getUrl(Uri.parse(url));
    (await _headers()).forEach(request.headers.set);
    final response = await request.close().timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final text = await response.transform(utf8.decoder).join();
      // 502/503/504 当作瞬时失败，触发回源；其它业务错误直接抛。
      if (_isBadGatewayStatus(response.statusCode)) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      throw Exception(_subscribeFailure(response.statusCode, text));
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return (
      bytes: Uint8List.fromList(builder.takeBytes()),
      disposition: response.headers.value('content-disposition'),
      userinfo: response.headers.value('subscription-userinfo'),
    );
  } finally {
    client.close(force: true);
  }
}

/// 是否面板订阅链（反代或源站）。更新时走反代优先，不走原版单 URL 拉取。
bool isPanelSubscribeUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return false;
  if (!uri.path.contains('AAA8624DACB3448683390D4A72575AAA')) return false;
  final host = uri.host.trim().toLowerCase();
  final originHost = panelSiteHost?.toLowerCase();
  final relayHost = Uri.tryParse(panelSubRelayBase)?.host.trim().toLowerCase();
  return host == originHost || host == relayHost;
}

String panelSubscribeRelayUrl(String token) {
  final t = Uri.encodeQueryComponent(token.trim());
  return '${_trimBase(panelSubRelayBase)}$_subscribePath?token=$t';
}

Future<
  ({
    Uint8List bytes,
    String? disposition,
    String? userinfo,
  })
> _fetchSubscribePreferRelay(String token) {
  final q = Uri.encodeQueryComponent(token.trim());
  return _preferRelayThenOrigin(
    relayBases: const [panelSubRelayBase],
    originBase: panelSiteBase,
    run: (base) {
      final url = '$base$_subscribePath?token=$q';
      final isOrigin = base == _trimBase(panelSiteBase);
      return _downloadSubscribeBytes(
        url,
        timeout: isOrigin ? _originRequestTimeout : _relayRequestTimeout,
      );
    },
  );
}

/// 手动/自动更新：反代优先，源站兜底；Profile.url 始终写成反代地址。
Future<Profile> updatePanelSubscribeProfile(
  Profile profile, {
  bool validate = true,
}) async {
  final token = Uri.tryParse(profile.url)?.queryParameters['token']?.trim() ?? '';
  if (token.isEmpty) {
    throw Exception('面板订阅缺少 token');
  }
  final fetched = await _fetchSubscribePreferRelay(token);
  final panelName = utils.getFileNameForDisposition(fetched.disposition);
  final label = (panelName == null || panelName.trim().isEmpty)
      ? profile.label
      : panelName.trim();
  return profile
      .copyWith(
        url: panelSubscribeRelayUrl(token),
        label: label,
        subscriptionInfo: SubscriptionInfo.formHString(fetched.userinfo),
      )
      .saveFile(fetched.bytes, validate: validate);
}

Future<void> _importSubscription(_PanelSession session) async {
  final token = session.subscribeToken.trim();
  // [Gamebox] 反代优先拉内容；写入的 Profile.url 也是反代（源站仅失败时才用）。
  final fetched = await _fetchSubscribePreferRelay(token);
  final panelName = utils.getFileNameForDisposition(fetched.disposition);
  final label = (panelName == null || panelName.trim().isEmpty)
      ? null
      : panelName.trim();
  var created = Profile.normal(
    url: panelSubscribeRelayUrl(token),
    label: label,
  ).copyWith(
    subscriptionInfo: SubscriptionInfo.formHString(fetched.userinfo),
  );
  // [Gamebox] 第一次登录时内核还没 init，跳过校验。载入仍走原版 applyProfile。
  created = await created.saveFile(fetched.bytes, validate: false);
  await globalState.appController.addProfile(created);
}

// 返回错误文案；成功返回 null。
// [Gamebox] 成功路径不再通过 onProgress 刷「正在导入」类提示（登录按钮已有动画）。
Future<String?> loginPanelAccount({
  required String username,
  required String password,
  required bool remember,
  required bool autoLogin,
  void Function(String message)? onProgress,
}) async {
  try {
    final session = await _login(username, password);
    await _saveSession(session);
    await saveRememberedPanelLogin(
      username: username,
      password: password,
      remember: remember,
      autoLogin: autoLogin,
    );
    await globalState.appController.deleteAllProfiles();
    try {
      await _importSubscription(session);
    } catch (e) {
      // [Gamebox] 封禁、过期、设备满时不要留下已登录会话。
      await _clearSession();
      final msg = e.toString().replaceFirst('Exception: ', '');
      return msg.startsWith('订阅') ? msg : '订阅拉取失败：$msg';
    }
    if (globalState.mainStarted) {
      try {
        await globalState.appController.applyProfile(silence: true);
      } catch (e) {
        return '已登录，订阅已保存，但载入配置失败：$e';
      }
    }
    return null;
  } catch (e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}

Future<String?> changePanelPassword({
  required String username,
  required String oldPassword,
  required String newPassword,
}) async {
  try {
    final res = await _postJsonApi(_changePassword, {
      'username': username.trim(),
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    Object? parsed;
    try {
      parsed = jsonDecode(res.text);
    } catch (_) {
      return _httpFailure(res.status, res.text, _changePassword);
    }
    if (res.status < 200 || res.status >= 300) {
      return _jsonMessage(parsed) ??
          _httpFailure(res.status, res.text, _changePassword);
    }
    if (parsed is! Map || parsed['status'] != 'success') {
      return _jsonMessage(parsed) ?? '修改密码失败';
    }
    final remembered = await loadRememberedPanelLogin();
    if (remembered != null && remembered.username == username.trim()) {
      await saveRememberedPanelLogin(
        username: username,
        password: newPassword,
        remember: true,
        autoLogin: remembered.autoLogin,
      );
    }
    return null;
  } catch (e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}

Future<void> logoutPanelAccount() async {
  globalState.skipPanelAutoLogin = true;
  // [Gamebox] 登录窗不显示托盘。先挡住，避免后面停代理时又把图标建回来。不必重启进程。
  await tray.hideUntilLogin();
  final session = await _loadSession();
  if (session != null) {
    unawaited(_serverLogout(session.authData));
  }
  try {
    if (globalState.isStart) {
      await globalState.appController.updateStatus(false);
    }
  } catch (_) {}
  await globalState.appController.deleteAllProfiles();
  await _clearSession();
  final nav = globalState.navigatorKey.currentState;
  nav?.popUntil((route) => route.isFirst);
  if (system.isDesktop && window != null) {
    // [Gamebox] 先透明再缩成登录窗，避免主界面被缩小时闪一下。
    await window!.setOpacity(0);
    await window!.showAsLoginWindow();
  }
  globalState.panelUnlocked.value = false;
  if (system.isDesktop && window != null) {
    await WidgetsBinding.instance.endOfFrame;
    await window!.setOpacity(1);
  }
}

Future<void> clearPanelDataOnExit() async {
  final session = await _loadSession();
  if (session != null) {
    // [Gamebox] 和退出账号走同一条登出。进程退出前要等它完成，面板设备数才会减。
    try {
      await _serverLogout(session.authData);
    } catch (_) {}
  }
  try {
    await globalState.appController.deleteAllProfiles(throughCore: false);
  } catch (_) {}
  await _clearSession();
}

// [Gamebox] 与 iGame 对齐：踢出/会话撤销类错误立刻回登录窗。
const _immediateReauthErrors = {
  'session_ended',
  'session_revoked',
  'session_revoked_login_elsewhere',
  'session_invalid',
  'invalid_token',
};

bool _isImmediateReauthError(String? error) {
  final e = error?.trim();
  if (e == null || e.isEmpty) return false;
  return _immediateReauthErrors.contains(e);
}

class _PanelMeProbe {
  const _PanelMeProbe({
    required this.ok,
    required this.unauthorized,
    this.unauthorizedError,
  });

  final bool ok;
  final bool unauthorized;
  final String? unauthorizedError;
}

DateTime? _lastForcedReloginAt;
bool _forcingRelogin = false;

Future<_PanelMeProbe> _probePanelMe(_PanelSession session) async {
  final res = await _getTextApi(
    _legacyMe,
    headers: await _headers(bearer: session.authData),
    relayTimeout: const Duration(seconds: 5),
    originTimeout: const Duration(seconds: 6),
  );
  if (res.status == 401) {
    String? err;
    try {
      final parsed = jsonDecode(res.text);
      if (parsed is Map && parsed['error'] is String) {
        err = (parsed['error'] as String).trim();
      }
    } catch (_) {}
    return _PanelMeProbe(
      ok: false,
      unauthorized: true,
      unauthorizedError: err,
    );
  }
  if (res.status < 200 || res.status >= 300) {
    return const _PanelMeProbe(ok: false, unauthorized: false);
  }
  return const _PanelMeProbe(ok: true, unauthorized: false);
}

// [Gamebox] 被踢/会话失效：回登录窗，不停代理、不删订阅（对齐 iGame 软重登）。
Future<void> forcePanelReloginFromServer() async {
  if (_forcingRelogin) return;
  final now = DateTime.now();
  if (_lastForcedReloginAt != null &&
      now.difference(_lastForcedReloginAt!) < const Duration(seconds: 4)) {
    return;
  }
  if (!globalState.panelUnlocked.value) return;
  final session = await _loadSession();
  if (session == null) return;
  _forcingRelogin = true;
  _lastForcedReloginAt = now;
  try {
    globalState.skipPanelAutoLogin = true;
    await tray.hideUntilLogin();
    try {
      await _serverLogout(session.authData);
    } catch (_) {}
    await _clearSession();
    final nav = globalState.navigatorKey.currentState;
    nav?.popUntil((route) => route.isFirst);
    if (system.isDesktop && window != null) {
      await window!.setOpacity(0);
      await window!.showAsLoginWindow();
    }
    globalState.panelUnlocked.value = false;
    if (system.isDesktop && window != null) {
      await WidgetsBinding.instance.endOfFrame;
      await window!.setOpacity(1);
    }
    globalState.showNotifier('登录已失效，请重新登录');
  } finally {
    _forcingRelogin = false;
  }
}

int _heartbeatUnauthorizedStreak = 0;

// [Gamebox] 会话心跳：GET /v1/me，仅走 _directClient。
Future<void> tickPanelSessionHeartbeat() async {
  if (!globalState.panelUnlocked.value) {
    _heartbeatUnauthorizedStreak = 0;
    return;
  }
  final session = await _loadSession();
  if (session == null) {
    _heartbeatUnauthorizedStreak = 0;
    return;
  }
  late final _PanelMeProbe probe;
  try {
    probe = await _probePanelMe(session);
  } catch (_) {
    // 离线/超时：不累计 401，也不清会话。
    return;
  }
  if (probe.unauthorized) {
    _heartbeatUnauthorizedStreak += 1;
    if (_isImmediateReauthError(probe.unauthorizedError) ||
        _heartbeatUnauthorizedStreak >= 2) {
      _heartbeatUnauthorizedStreak = 0;
      await forcePanelReloginFromServer();
    }
    return;
  }
  _heartbeatUnauthorizedStreak = 0;
}
