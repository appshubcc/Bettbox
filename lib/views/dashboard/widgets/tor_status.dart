import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/plugins/tor.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TorStatus extends StatefulWidget {
  const TorStatus({super.key});

  @override
  State<TorStatus> createState() => _TorStatusState();
}

class _TorStatusState extends State<TorStatus> {
  static const _tor = TorControl();

  Timer? _timer;
  String _status = 'disabled';
  String? _message;
  int _progress = 0;
  String? _ip;
  String? _countryCode;
  String? _errorMessage;
  int? _latencyMs;
  bool _checkingExit = false;
  DateTime? _lastExitCheck;

  @override
  void initState() {
    super.initState();
    _refresh(immediateExitCheck: true);
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool immediateExitCheck = false}) async {
    final status = await _tor.status();
    if (!mounted) return;

    final progress = (status['bootstrapPercent'] as num?)?.toInt() ?? 0;
    final torStatus = status['status']?.toString() ?? 'disabled';
    final message = status['message']?.toString();

    setState(() {
      _status = torStatus;
      _message = message;
      _progress = progress.clamp(0, 100);
      if (torStatus == 'disabled') {
        _ip = null;
        _countryCode = null;
        _errorMessage = null;
        _latencyMs = null;
      }
    });

    if (_shouldCheckExit(immediateExitCheck)) {
      await _checkExit();
    }
  }

  bool _shouldCheckExit(bool immediate) {
    if (_checkingExit || _progress < 100) {
      return false;
    }
    if (immediate || _ip == null) return true;
    final last = _lastExitCheck;
    return last == null || DateTime.now().difference(last).inSeconds >= 30;
  }

  Future<void> _checkExit() async {
    setState(() {
      _checkingExit = true;
      _errorMessage = null;
    });

    final stopwatch = Stopwatch()..start();
    final result = await _tor.checkExit().timeout(
      const Duration(seconds: 20),
      onTimeout: () => const {'ok': false, 'error': 'Tor check timeout'},
    );
    stopwatch.stop();
    if (!mounted) return;

    setState(() {
      _checkingExit = false;
      _lastExitCheck = DateTime.now();
      _latencyMs = stopwatch.elapsedMilliseconds;
      if (result['ok'] == true) {
        _ip = result['ip']?.toString();
        _countryCode = result['countryCode']?.toString();
        _errorMessage = _ip == null ? 'Tor check failed' : null;
      } else {
        _errorMessage = result['error']?.toString() ?? 'Tor check failed';
      }
    });
  }

  String? _countryCodeToEmoji(String? countryCode) {
    final code = countryCode?.toUpperCase();
    if (code == null || code.length != 2) return null;
    final firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  String get _statusText {
    if (_progress >= 100) return 'Tor 已连接';
    return switch (_status) {
      'running' => 'Tor 已连接',
      'starting' => 'Tor 启动中',
      'failed' => 'Tor 启动失败',
      _ => 'Tor 未启动',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isWorking = _status == 'starting' || _checkingExit;
    final progress = _progress / 100;
    final countryEmoji = _countryCodeToEmoji(_countryCode);

    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        onPressed: () => _refresh(immediateExitCheck: true),
        child: Padding(
          padding: baseInfoEdgeInsets,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  countryEmoji != null
                      ? Text(
                          countryEmoji,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.toLight
                              .copyWith(fontFamily: FontFamily.twEmoji.value),
                        )
                      : Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TooltipText(
                      text: Text(
                        'Tor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (isWorking)
                    SizedBox(
                      width: 28,
                      height: 16,
                      child: SpinKitThreeBounce(
                        color: context.colorScheme.primary,
                        size: 14,
                      ),
                    )
                  else
                    Icon(
                      _status == 'running'
                          ? Icons.verified_user_outlined
                          : Icons.shield_outlined,
                      size: 16,
                      color: _status == 'running'
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _status == 'disabled' ? 0 : progress,
                  minHeight: 3,
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                ),
              ),
              TooltipText(
                text: Text(
                  _ip != null
                      ? '${_countryCode ?? '--'}  $_ip${_latencyMs == null ? '' : '  ${_latencyMs}ms'}'
                      : _errorMessage ?? '$_statusText $_progress%',
                  style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
