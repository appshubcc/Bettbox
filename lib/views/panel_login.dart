import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/panel/panel_auth.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// [Gamebox] 登录界面按 iGame 的面板登录页排。
// 冷启动窗口本身就是这张卡片，不再套一层底色。最小化、关闭一直显示，不显示最大化。

void showPanelChangePassword({String username = ''}) {
  globalState.showCommonDialog<void>(
    child: _PanelChangePasswordDialog(username: username),
  );
}

class PanelLoginGate extends StatefulWidget {
  const PanelLoginGate({super.key});

  @override
  State<PanelLoginGate> createState() => _PanelLoginGateState();
}

class _PanelLoginGateState extends State<PanelLoginGate> {
  bool _changePassword = false;
  String _username = '';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => windowManager.startDragging(),
            child: Padding(
              // [Gamebox] 窗口加高后内容偏上，整体下移一点。
              padding: const EdgeInsets.only(top: 28),
              child: _changePassword
                ? _PanelChangePasswordDialog(
                    username: _username,
                    embedded: true,
                    onClose: () => setState(() => _changePassword = false),
                  )
                : _PanelLoginForm(
                    onChangePassword: (name) {
                      setState(() {
                        _username = name;
                        _changePassword = true;
                      });
                    },
                  ),
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: _LoginWindowButtons(),
          ),
        ],
      ),
    );
  }
}

class _LoginWindowButtons extends StatefulWidget {
  const _LoginWindowButtons();

  @override
  State<_LoginWindowButtons> createState() => _LoginWindowButtonsState();
}

class _LoginWindowButtonsState extends State<_LoginWindowButtons> {
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    unawaited(_readPin());
  }

  Future<void> _readPin() async {
    final pinned = await windowManager.isAlwaysOnTop();
    if (!mounted) return;
    setState(() => _pinned = pinned);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _icon(
          tooltip: '置顶',
          color: color,
          icon: _pinned ? Icons.push_pin : Icons.push_pin_outlined,
          onPressed: () async {
            final next = !_pinned;
            await windowManager.setAlwaysOnTop(next);
            if (!mounted) return;
            setState(() => _pinned = next);
          },
        ),
        _icon(
          tooltip: '最小化',
          color: color,
          icon: Icons.remove,
          onPressed: () => windowManager.minimize(),
        ),
        _icon(
          tooltip: '关闭',
          color: color,
          icon: Icons.close,
          onPressed: () {
            globalState.appController.unBackBlock();
            globalState.appController.handleBackOrExit();
          },
        ),
      ],
    );
  }
}

Widget _icon({
  required String tooltip,
  required Color color,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    onPressed: onPressed,
    icon: Icon(icon, size: 18, color: color),
  );
}

class _PanelLoginForm extends StatefulWidget {
  const _PanelLoginForm({required this.onChangePassword});

  final ValueChanged<String> onChangePassword;

  @override
  State<_PanelLoginForm> createState() => _PanelLoginFormState();
}

class _PanelLoginFormState extends State<_PanelLoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _rememberPassword = false;
  bool _autoLogin = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRemembered());
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _notify(String text) {
    final shown = context.showNotifier(text);
    if (shown == null) {
      globalState.showNotifier(text);
    }
  }

  Future<void> _loadRemembered() async {
    final saved = await loadRememberedPanelLogin();
    if (!mounted || saved == null) return;
    setState(() {
      _username.value = TextEditingValue(
        text: saved.username,
        selection: TextSelection.collapsed(offset: saved.username.length),
      );
      _password.value = TextEditingValue(
        text: saved.password,
        selection: TextSelection.collapsed(offset: saved.password.length),
      );
      _rememberPassword = true;
      _autoLogin = saved.autoLogin;
    });
    // [Gamebox] 填入记住的账号后不要保持全选。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _username.selection = TextSelection.collapsed(offset: _username.text.length);
      _password.selection = TextSelection.collapsed(offset: _password.text.length);
    });
    // [Gamebox] 只在冷启动自动登录。退出账号后的这一次跳过，避免马上又登回去。
    if (!saved.autoLogin) return;
    if (globalState.skipPanelAutoLogin) {
      globalState.skipPanelAutoLogin = false;
      return;
    }
    // [Gamebox] 先画完填好的登录页，再自动登录，保证按钮转圈能看见。
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _submit();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      _notify('请输入用户名和密码');
      return;
    }
    setState(() => _submitting = true);
    // [Gamebox] 先让转圈画出来再请求；自动登录时否则容易看不到动画。
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    // [Gamebox] 登录中只靠按钮转圈反馈；「正在导入/已导入」通知冗余，仅失败时弹错误。
    final message = await loginPanelAccount(
      username: _username.text,
      password: _password.text,
      remember: _rememberPassword,
      autoLogin: _autoLogin,
    );
    if (!mounted) return;
    if (message != null) {
      setState(() => _submitting = false);
      _notify(_loginNotice(message));
      return;
    }
    // [Gamebox] 成功后保持转圈直到进主界面（含冷启动 init），避免像登录中断。
    await globalState.openMainAfterLogin?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final bothEmpty =
        _username.text.trim().isEmpty && _password.text.isEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gamebox',
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '搬砖不抖，稳如老狗',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          _field(
            controller: _username,
            hint: '用户名或邮箱',
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          _field(
            controller: _password,
            hint: '密码',
            obscure: true,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _check(
                label: '记住密码',
                value: _rememberPassword,
                onChanged: (value) {
                  setState(() {
                    _rememberPassword = value;
                    if (!value) _autoLogin = false;
                  });
                },
              ),
              const SizedBox(width: 24),
              _check(
                label: '自动登录',
                value: _autoLogin,
                onChanged: (value) {
                  setState(() {
                    _autoLogin = value;
                    if (value) _rememberPassword = true;
                  });
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  widget.onChangePassword(_username.text.trim());
                },
                child: const Text('修改密码'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            // [Gamebox] 登录中保持按钮颜色，只把图标换成转圈，和 iGame 一样。
            onPressed: bothEmpty || _submitting ? null : _submit,
            icon: _submitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.login_rounded, size: 18),
            label: const Text('登录'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(45),
              disabledBackgroundColor: _submitting
                  ? scheme.primary
                  : null,
              disabledForegroundColor: _submitting
                  ? scheme.onPrimary
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelChangePasswordDialog extends StatefulWidget {
  const _PanelChangePasswordDialog({
    required this.username,
    this.embedded = false,
    this.onClose,
  });

  final String username;
  final bool embedded;
  final VoidCallback? onClose;

  @override
  State<_PanelChangePasswordDialog> createState() =>
      _PanelChangePasswordDialogState();
}

class _PanelChangePasswordDialogState
    extends State<_PanelChangePasswordDialog> {
  late final TextEditingController _username;
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _username.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.of(context).pop();
  }

  void _notify(String text) {
    final shown = context.showNotifier(text);
    if (shown == null) {
      globalState.showNotifier(text);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_username.text.trim().isEmpty) {
      _notify('请先填写用户名');
      return;
    }
    if (_oldPassword.text.isEmpty || _newPassword.text.isEmpty) {
      _notify('请填写完整');
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _notify('两次输入的新密码不一致');
      return;
    }
    setState(() => _submitting = true);
    final message = await changePanelPassword(
      username: _username.text,
      oldPassword: _oldPassword.text,
      newPassword: _newPassword.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (message != null) {
      _notify(_loginNotice(message));
      return;
    }
    _notify('密码已更新，请使用新密码登录');
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final form = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '修改密码',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _field(controller: _username, hint: '用户名或邮箱'),
        const SizedBox(height: 12),
        _field(controller: _oldPassword, hint: '当前密码', obscure: true),
        const SizedBox(height: 12),
        _field(controller: _newPassword, hint: '新密码', obscure: true),
        const SizedBox(height: 12),
        _field(
          controller: _confirmPassword,
          hint: '确认新密码',
          obscure: true,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _submitting ? null : _close,
              child: Text(appLocalizations.cancel),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const SizedBox.shrink(),
              label: const Text('确认修改'),
              style: FilledButton.styleFrom(
                disabledBackgroundColor: _submitting ? scheme.primary : null,
                disabledForegroundColor: _submitting ? scheme.onPrimary : null,
              ),
            ),
          ],
        ),
      ],
    );
    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(40, 48, 40, 40),
        child: form,
      );
    }
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 390,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: form,
        ),
      ),
    );
  }
}

// [Gamebox] 把面板/网络原始错误收成可读中文，便于对照排查（已是完整中文则原样显示）。
String _loginNotice(String raw) {
  final text = raw
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '')
      .trim();
  final lower = text.toLowerCase();

  // —— 账号/业务 ——
  // [Gamebox] 账号类文案与 iGame Windows zh/panel.json（密码错误对齐 Android invalid_credentials）一致。
  if (lower.contains('device') ||
      text.contains('设备') ||
      text.contains('已在别处登录')) {
    return '在线设备已达上限';
  }
  if (lower.contains('account_banned') || text.contains('封禁')) {
    return '该账号已被封禁';
  }
  if (lower.contains('account_expired') || text.contains('过期')) {
    return '账号已过期，无法拉取订阅。请续费后重试。';
  }
  if (lower.contains('account_unavailable') || text.contains('不可用')) {
    return '账号当前不可用，无法拉取订阅。如有疑问请联系管理员。';
  }
  if (lower.contains('login_failed') ||
      lower.contains('invalid_credentials') ||
      (lower.contains('invalid') && lower.contains('password')) ||
      text.contains('密码错误') ||
      text.contains('用户名或密码')) {
    return '用户名或密码错误';
  }
  if (lower.contains('missing_auth_data')) {
    return '登录失败：服务器未返回登录凭证 auth_data';
  }
  if (lower.contains('missing_subscribe_token')) {
    return '登录失败：服务器未返回订阅 token';
  }

  // —— 网络/隧道（反代优先、源站兜底之后仍失败）——
  if (lower.contains('timeout') || lower.contains('timed out')) {
    return '连接超时：反代与源站均未响应（查 DNS/隧道/安全组 1699·1688）';
  }
  if (lower.contains('handshake') || lower.contains('certificate')) {
    return 'TLS 握手失败：查证书与端口（API:1699 / 订阅:1688）';
  }
  if (lower.contains('connection refused') ||
      lower.contains('connection reset')) {
    return '连接被拒绝或重置：查反代机 Xray 与面板 Nginx 是否在听';
  }
  if (lower.contains('failed host lookup') ||
      lower.contains('name or service not known') ||
      lower.contains('nodename nor servname')) {
    return '域名解析失败：查 wegame.com.api / wegame.com.sub / mini 的 DNS';
  }
  if (lower.contains('request_failed') || lower.contains('relay_soft_fail')) {
    return '网络请求失败：反代与源站均不可用';
  }

  if (text.isEmpty) return '登录失败，请稍后重试';
  return text;
}

Widget _check({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return InkWell(
    onTap: () => onChanged(!value),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: OverflowBox(
            maxWidth: 40,
            maxHeight: 40,
            child: Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                onChanged: (next) => onChanged(next ?? false),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    ),
  );
}

Widget _field({
  required TextEditingController controller,
  required String hint,
  bool obscure = false,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
