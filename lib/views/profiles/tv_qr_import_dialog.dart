import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';

class TvQrImportDialog extends StatefulWidget {
  const TvQrImportDialog({super.key});

  @override
  State<TvQrImportDialog> createState() => _TvQrImportDialogState();
}

class _TvQrImportDialogState extends State<TvQrImportDialog> {
  HttpServer? _server;
  String? _ip;
  int? _port;
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _successName;

  String get _lanUrl {
    if (_ip == null || _ip!.isEmpty || _port == null) return '';
    return 'http://$_ip:$_port';
  }

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  Future<void> _startServer() async {
    try {
      final ip = await utils.getLocalIpAddress();
      if (!mounted) return;

      HttpServer? server;
      try {
        server = await HttpServer.bind(InternetAddress.anyIPv4, 9870);
      } catch (_) {
        server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      }

      if (!mounted) {
        server.close(force: true);
        return;
      }

      _server = server;
      _ip = ip;
      _port = server.port;
      _isLoading = false;
      setState(() {});

      server.listen(_handleHttpRequest);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleHttpRequest(HttpRequest request) async {
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, OPTIONS',
    );
    request.response.headers.add(
      'Access-Control-Allow-Headers',
      'Content-Type',
    );

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    if (request.method == 'GET' && (path == '/' || path.isEmpty)) {
      request.response.headers.contentType = ContentType(
        'text',
        'html',
        charset: 'utf-8',
      );
      request.response.headers.add(
        'Cache-Control',
        'no-cache, no-store, must-revalidate',
      );
      request.response.headers.add('Pragma', 'no-cache');
      request.response.headers.add('Expires', '0');
      final acceptLang =
          request.headers
              .value(HttpHeaders.acceptLanguageHeader)
              ?.toLowerCase() ??
          '';
      final isZh = acceptLang.contains('zh');
      request.response.write(_getHtml(isZh: isZh));
      await request.response.close();
      return;
    }

    if (request.method == 'POST' && path == '/api/upload') {
      try {
        final body = await utf8.decodeStream(request);
        final data = jsonDecode(body) as Map<String, dynamic>;
        final type = data['type'] as String?;

        if (type == 'file' || data.containsKey('content')) {
          final content = data['content'] as String? ?? '';
          final rawName = data['name'] as String? ?? 'config.yaml';
          final name = rawName.isEmpty ? 'config.yaml' : rawName;

          if (content.trim().isEmpty) {
            _respondJson(
              request,
              statusCode: 400,
              success: false,
              message: 'Content is empty',
            );
            return;
          }

          _respondJson(request, statusCode: 200, success: true, message: 'ok');
          _onReceivedProfileFile(name, content);
          return;
        }

        final url = (data['url'] as String? ?? '').trim();
        if (url.isEmpty || !url.isUrl) {
          _respondJson(
            request,
            statusCode: 400,
            success: false,
            message: 'Invalid URL',
          );
          return;
        }

        _respondJson(request, statusCode: 200, success: true, message: 'ok');
        _onReceivedProfileUrl(url);
      } catch (e) {
        _respondJson(
          request,
          statusCode: 500,
          success: false,
          message: e.toString(),
        );
      }
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  void _respondJson(
    HttpRequest request, {
    required int statusCode,
    required bool success,
    required String message,
  }) async {
    request.response.statusCode = statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({'success': success, 'message': message}),
    );
    await request.response.close();
  }

  void _onReceivedProfileUrl(String url) {
    if (!mounted) return;
    setState(() {
      _isSuccess = true;
      _successName = url;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop();
        globalState.appController.addProfileFormURL(url);
      }
    });
  }

  void _onReceivedProfileFile(String name, String content) async {
    if (!mounted) return;
    setState(() {
      _isSuccess = true;
      _successName = name;
    });

    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      Navigator.of(context).pop();
      try {
        final profile = await Profile.normal(
          label: name,
        ).saveFileWithString(content);
        await globalState.appController.addProfile(profile);
        globalState.appController.toProfiles();
      } catch (e) {
        globalState.showMessage(
          title: appLocalizations.file,
          message: TextSpan(text: e.toString()),
          cancelable: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasNetwork = _ip != null && _ip!.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, minHeight: 340),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _isLoading
              ? const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                )
              : !hasNetwork
              ? _buildNoNetworkView()
              : _buildMainView(),
        ),
      ),
    );
  }

  Widget _buildNoNetworkView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: 64,
          color: context.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          appLocalizations.tvScanNoNetwork,
          style: context.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              autofocus: true,
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _startServer();
              },
              icon: const Icon(Icons.refresh),
              label: Text(appLocalizations.retry),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.cancel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainView() {
    if (_isSuccess) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                appLocalizations.tvScanSuccess,
                style: context.textTheme.headlineSmall?.toBold,
              ),
              if (_successName != null) ...[
                const SizedBox(height: 8),
                Text(
                  _successName!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrCodeWidget(data: _lanUrl, size: 210),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.tvScanWaiting,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocalizations.qrcode,
                style: context.textTheme.titleLarge?.toBold,
              ),
              const SizedBox(height: 4),
              Text(
                appLocalizations.qrcodeDesc,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildStepRow(
                icon: Icons.wifi,
                text: appLocalizations.tvScanStep1,
              ),
              const SizedBox(height: 10),
              _buildStepRow(
                icon: Icons.qr_code_scanner,
                text: appLocalizations.tvScanStep2,
              ),
              const SizedBox(height: 10),
              _buildStepRow(
                icon: Icons.send_to_mobile,
                text: appLocalizations.tvScanStep3,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appLocalizations.tvScanManualUrl,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lanUrl,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: Text(appLocalizations.close),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  static String _getHtml({required bool isZh}) =>
      '''<!DOCTYPE html>
<html lang="${isZh ? 'zh-CN' : 'en'}">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Bettbox</title>
<style>
:root {
  --bg-gradient: radial-gradient(at 0% 0%, rgba(59, 130, 246, 0.08) 0px, transparent 50%),
                 radial-gradient(at 100% 100%, rgba(99, 102, 241, 0.08) 0px, transparent 50%),
                 #f8fafc;
  --card-bg: rgba(255, 255, 255, 0.85);
  --card-border: rgba(255, 255, 255, 0.6);
  --card-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.05), 0 0 1px 1px rgba(0, 0, 0, 0.04);
  --text: #0f172a;
  --text-sub: #64748b;
  --primary: #2563eb;
  --primary-gradient: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  --primary-glow: 0 8px 20px -4px rgba(37, 99, 235, 0.35);
  --border: #e2e8f0;
  --input-bg: rgba(248, 250, 252, 0.8);
  --tab-bg: #f1f5f9;
  --tab-active: #ffffff;
  --tab-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  --upload-bg: rgba(248, 250, 252, 0.5);
  --upload-hover: rgba(239, 246, 255, 0.6);
  --success: #059669;
  --success-bg: rgba(16, 185, 129, 0.08);
  --success-border: rgba(16, 185, 129, 0.2);
  --error: #dc2626;
  --error-bg: rgba(239, 68, 68, 0.08);
  --error-border: rgba(239, 68, 68, 0.2);
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg-gradient: radial-gradient(at 0% 0%, rgba(59, 130, 246, 0.15) 0px, transparent 50%),
                   radial-gradient(at 100% 100%, rgba(147, 51, 234, 0.12) 0px, transparent 50%),
                   #090d16;
    --card-bg: rgba(17, 24, 39, 0.75);
    --card-border: rgba(255, 255, 255, 0.08);
    --card-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5), 0 0 1px 1px rgba(255, 255, 255, 0.05);
    --text: #f8fafc;
    --text-sub: #94a3b8;
    --primary: #3b82f6;
    --primary-gradient: linear-gradient(135deg, #60a5fa 0%, #2563eb 100%);
    --primary-glow: 0 8px 24px -4px rgba(59, 130, 246, 0.4);
    --border: #1e293b;
    --input-bg: rgba(15, 23, 42, 0.6);
    --tab-bg: #111827;
    --tab-active: #1e293b;
    --tab-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    --upload-bg: rgba(15, 23, 42, 0.4);
    --upload-hover: rgba(30, 41, 59, 0.6);
    --success: #34d399;
    --success-bg: rgba(16, 185, 129, 0.12);
    --success-border: rgba(16, 185, 129, 0.3);
    --error: #f87171;
    --error-bg: rgba(239, 68, 68, 0.12);
    --error-border: rgba(239, 68, 68, 0.3);
  }
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", Roboto, sans-serif;
  -webkit-font-smoothing: antialiased;
}

body {
  background: var(--bg-gradient);
  background-attachment: fixed;
  color: var(--text);
  padding: 32px 16px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.container {
  width: 100%;
  max-width: 440px;
  background: var(--card-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--card-border);
  border-radius: 28px;
  box-shadow: var(--card-shadow);
  padding: 24px 28px 32px;
  transition: transform 0.2s ease;
}

.header-bar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 8px;
}

.lang-btn {
  background: var(--tab-bg);
  border: 1px solid var(--border);
  color: var(--text);
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
  touch-action: manipulation;
  -webkit-tap-highlight-color: transparent;
  user-select: none;
  -webkit-user-select: none;
  line-height: 1.2;
}

.lang-btn:hover {
  border-color: var(--primary);
  color: var(--primary);
}

.lang-btn:active {
  transform: scale(0.95);
  background: var(--tab-active);
}

.header {
  text-align: center;
  margin-bottom: 24px;
}

.header h1 {
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.02em;
  color: var(--text);
  margin-bottom: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.header p {
  font-size: 13.5px;
  color: var(--text-sub);
  letter-spacing: -0.01em;
}

.tabs {
  display: flex;
  background: var(--tab-bg);
  border-radius: 14px;
  padding: 4px;
  margin-bottom: 22px;
  border: 1px solid var(--border);
}

.tab-btn {
  flex: 1;
  border: none;
  background: transparent;
  color: var(--text-sub);
  padding: 9px 0;
  border-radius: 10px;
  font-size: 13.5px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}

.tab-btn.active {
  background: var(--tab-active);
  color: var(--text);
  box-shadow: var(--tab-shadow);
}

.tab-content {
  display: none;
  animation: fadeIn 0.25s ease-out;
}

.tab-content.active {
  display: block;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(4px); }
  to { opacity: 1; transform: translateY(0); }
}

.form-group {
  margin-bottom: 18px;
}

label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 8px;
  color: var(--text);
  letter-spacing: -0.01em;
}

input[type="text"], textarea {
  width: 100%;
  padding: 13px 15px;
  border: 1px solid var(--border);
  border-radius: 14px;
  font-size: 14px;
  background: var(--input-bg);
  color: var(--text);
  outline: none;
  transition: all 0.2s ease;
  line-height: 1.5;
}

input[type="text"]:focus, textarea:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3.5px rgba(59, 130, 246, 0.15);
  background: var(--card-bg);
}

textarea {
  resize: vertical;
  min-height: 96px;
}

.file-upload {
  border: 1.5px dashed var(--border);
  background: var(--upload-bg);
  border-radius: 18px;
  padding: 32px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.25s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.file-upload:hover {
  border-color: var(--primary);
  background: var(--upload-hover);
  transform: translateY(-1px);
}

.file-upload input {
  display: none;
}

.file-upload-icon-wrapper {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: rgba(59, 130, 246, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
}

.file-upload svg {
  width: 26px;
  height: 26px;
  fill: var(--primary);
}

.file-upload-text {
  font-size: 13.5px;
  font-weight: 600;
  color: var(--text);
}

.file-name {
  font-size: 12px;
  color: var(--primary);
  font-weight: 600;
  margin-top: 10px;
  word-break: break-all;
  padding: 4px 10px;
  background: rgba(59, 130, 246, 0.08);
  border-radius: 8px;
  display: inline-block;
}

.file-name:empty {
  display: none;
}

.btn {
  width: 100%;
  padding: 13.5px;
  border: none;
  border-radius: 14px;
  background: var(--primary-gradient);
  color: #ffffff;
  font-size: 14.5px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 22px;
  box-shadow: var(--primary-glow);
}

.btn:hover:not(:disabled) {
  opacity: 0.95;
  transform: translateY(-1px);
}

.btn:active:not(:disabled) {
  transform: translateY(1px);
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
  filter: grayscale(20%);
}

.alert {
  margin-top: 16px;
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 13px;
  font-weight: 500;
  display: none;
  line-height: 1.4;
  animation: fadeIn 0.2s ease-out;
}

.alert.success {
  background: var(--success-bg);
  border: 1px solid var(--success-border);
  color: var(--success);
}

.alert.error {
  background: var(--error-bg);
  border: 1px solid var(--error-border);
  color: var(--error);
}
</style>
</head>
<body>
<div class="container">
  <div class="header-bar">
    <button type="button" class="lang-btn" id="lang-btn" onclick="toggleLang()">English</button>
  </div>
  <div class="header">
    <h1>📺 Bettbox</h1>
    <p id="t-subtitle">推送配置至 Android TV 电视端</p>
  </div>
  <div class="tabs">
    <button class="tab-btn active" id="t-tab-url" onclick="switchTab('url')">订阅链接</button>
    <button class="tab-btn" id="t-tab-file" onclick="switchTab('file')">本地配置文件</button>
  </div>
  <div id="tab-url" class="tab-content active">
    <div class="form-group">
      <label id="t-label-url">订阅链接 (URL)</label>
      <textarea id="url-input" placeholder="在此粘贴 Clash Meta 订阅链接 (https://...)"></textarea>
    </div>
    <div class="form-group">
      <label id="t-label-name">配置名称（可选）</label>
      <input type="text" id="name-input" placeholder="未填写则自动识别">
    </div>
    <button class="btn" id="btn-submit-url" onclick="submitUrl()">🚀 推送至电视</button>
  </div>
  <div id="tab-file" class="tab-content">
    <div class="file-upload" onclick="document.getElementById('file-input').click()">
      <div class="file-upload-icon-wrapper">
        <svg viewBox="0 0 24 24"><path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM14 13v4h-4v-4H7l5-5 5 5h-3z"/></svg>
      </div>
      <div class="file-upload-text" id="t-upload-text">点击选择 .yaml / .yml 配置文件</div>
      <div class="file-name" id="selected-file-name"></div>
      <input type="file" id="file-input" accept=".yaml,.yml,.txt" onchange="onFileSelected(this)">
    </div>
    <button class="btn" id="btn-submit-file" onclick="submitFile()" disabled>🚀 推送配置文件</button>
  </div>
  <div class="alert" id="status-alert"></div>
</div>
<script>
const I18N = {
  zh: {
    title: 'Bettbox 配置推送',
    subtitle: '推送配置至 Android TV 电视端',
    tabUrl: '订阅链接',
    tabFile: '本地配置文件',
    labelUrl: '订阅链接 (URL)',
    placeholderUrl: '在此粘贴 Clash Meta 订阅链接 (https://...)',
    labelName: '配置名称（可选）',
    placeholderName: '未填写则自动识别',
    btnPushUrl: '🚀 推送至电视',
    uploadText: '点击选择 .yaml / .yml 配置文件',
    btnPushFile: '🚀 推送配置文件',
    pushing: '正在推送...',
    readingAndPushing: '正在读取与推送...',
    errEmptyUrl: '请先输入订阅链接',
    successUrl: '✅ 已成功推送至电视！电视端正在自动导入配置...',
    successFile: '✅ 配置文件已成功推送至电视！',
    errReadFile: '❌ 读取文件失败',
    errPushFailed: '❌ 推送失败：',
    errCannotConnect: '❌ 推送失败，无法连接到电视：',
    langToggle: 'English'
  },
  en: {
    title: 'Bettbox Profile Push',
    subtitle: 'Push profile to Android TV',
    tabUrl: 'Subscription URL',
    tabFile: 'Local File',
    labelUrl: 'Subscription URL',
    placeholderUrl: 'Paste Clash Meta subscription URL here (https://...)',
    labelName: 'Profile Name (Optional)',
    placeholderName: 'Auto-detected if left empty',
    btnPushUrl: '🚀 Push to TV',
    uploadText: 'Tap to select .yaml / .yml profile',
    btnPushFile: '🚀 Push Profile',
    pushing: 'Pushing...',
    readingAndPushing: 'Reading & pushing...',
    errEmptyUrl: 'Please enter subscription URL first',
    successUrl: '✅ Pushed to TV successfully! Importing profile...',
    successFile: '✅ Profile pushed to TV successfully!',
    errReadFile: '❌ Failed to read file',
    errPushFailed: '❌ Push failed: ',
    errCannotConnect: '❌ Push failed, unable to connect to TV: ',
    langToggle: '中文'
  }
};

let currentLang = ${isZh ? "'zh'" : "'en'"};

function toggleLang() {
  const next = currentLang === 'zh' ? 'en' : 'zh';
  try { localStorage.setItem('bettbox_tv_lang', next); } catch (_) {}
  applyLang(next);
}

function applyLang(lang) {
  currentLang = lang;
  document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';
  const t = I18N[lang];
  if (!t) return;
  document.title = t.title;

  const setTxt = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.textContent = val;
  };
  const setHolder = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.placeholder = val;
  };

  setTxt('t-subtitle', t.subtitle);
  setTxt('t-tab-url', t.tabUrl);
  setTxt('t-tab-file', t.tabFile);
  setTxt('t-label-url', t.labelUrl);
  setHolder('url-input', t.placeholderUrl);
  setTxt('t-label-name', t.labelName);
  setHolder('name-input', t.placeholderName);
  setTxt('btn-submit-url', t.btnPushUrl);
  setTxt('t-upload-text', t.uploadText);
  setTxt('btn-submit-file', t.btnPushFile);
  setTxt('lang-btn', t.langToggle);
}



let selectedFile = null;
function switchTab(tab) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
  hideAlert();
  if (tab === 'url') {
    document.querySelectorAll('.tab-btn')[0].classList.add('active');
    document.getElementById('tab-url').classList.add('active');
  } else {
    document.querySelectorAll('.tab-btn')[1].classList.add('active');
    document.getElementById('tab-file').classList.add('active');
  }
}
function showAlert(msg, isSuccess) {
  const el = document.getElementById('status-alert');
  el.textContent = msg;
  el.className = 'alert ' + (isSuccess ? 'success' : 'error');
  el.style.display = 'block';
}
function hideAlert() {
  const el = document.getElementById('status-alert');
  el.style.display = 'none';
  el.className = 'alert';
}
function onFileSelected(input) {
  if (input.files && input.files[0]) {
    selectedFile = input.files[0];
    document.getElementById('selected-file-name').textContent = selectedFile.name + ' (' + (selectedFile.size / 1024).toFixed(1) + ' KB)';
    document.getElementById('btn-submit-file').disabled = false;
  }
}
async function submitUrl() {
  const t = I18N[currentLang];
  const url = document.getElementById('url-input').value.trim();
  const name = document.getElementById('name-input').value.trim();
  if (!url) {
    showAlert(t.errEmptyUrl, false);
    return;
  }
  const btn = document.getElementById('btn-submit-url');
  btn.disabled = true;
  btn.textContent = t.pushing;
  hideAlert();
  try {
    const res = await fetch('/api/upload', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type: 'url', url: url, name: name })
    });
    const data = await res.json();
    if (res.ok && data.success) {
      showAlert(t.successUrl, true);
      document.getElementById('url-input').value = '';
    } else {
      showAlert(t.errPushFailed + (data.message || 'Error'), false);
    }
  } catch (e) {
    showAlert(t.errCannotConnect + e, false);
  } finally {
    btn.disabled = false;
    btn.textContent = t.btnPushUrl;
  }
}
async function submitFile() {
  if (!selectedFile) return;
  const t = I18N[currentLang];
  const btn = document.getElementById('btn-submit-file');
  btn.disabled = true;
  btn.textContent = t.readingAndPushing;
  hideAlert();
  const reader = new FileReader();
  reader.onload = async function(e) {
    try {
      const content = e.target.result;
      const res = await fetch('/api/upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: 'file', name: selectedFile.name, content: content })
      });
      const data = await res.json();
      if (res.ok && data.success) {
        showAlert(t.successFile, true);
        selectedFile = null;
        document.getElementById('selected-file-name').textContent = '';
        document.getElementById('file-input').value = '';
      } else {
        showAlert(t.errPushFailed + (data.message || 'Error'), false);
      }
    } catch (err) {
      showAlert(t.errCannotConnect + err, false);
    } finally {
      btn.disabled = selectedFile === null;
      btn.textContent = t.btnPushFile;
    }
  };
  reader.onerror = function() {
    showAlert(t.errReadFile, false);
    btn.disabled = false;
    btn.textContent = t.btnPushFile;
  };
  reader.readAsText(selectedFile);
}

try {
  const saved = localStorage.getItem('bettbox_tv_lang');
  if (saved === 'zh' || saved === 'en') {
    currentLang = saved;
  }
} catch (_) {}
applyLang(currentLang);
</script>
</body>
</html>''';
}
