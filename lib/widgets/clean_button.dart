import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

enum _CleanPhase { idle, running, done }

class CleanButton extends StatefulWidget {
  final String tooltip;
  final Future<String> Function()? onClean;

  const CleanButton({super.key, required this.tooltip, required this.onClean});

  @override
  State<CleanButton> createState() => _CleanButtonState();
}

class _CleanButtonState extends State<CleanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  _CleanPhase _phase = _CleanPhase.idle;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  Future<void> _handle() async {
    final onClean = widget.onClean;
    if (onClean == null || _phase != _CleanPhase.idle) return;
    if (system.isAndroid) HapticFeedback.lightImpact();
    setState(() => _phase = _CleanPhase.running);
    _spin.repeat();
    final minDuration = Future<void>.delayed(const Duration(milliseconds: 700));
    String message;
    try {
      message = await onClean();
      await minDuration;
    } catch (e) {
      globalState.showNotifier(e.toString());
      if (!mounted) return;
      _spin.stop();
      setState(() => _phase = _CleanPhase.idle);
      return;
    }
    globalState.showNotifier(message);
    if (!mounted) return;
    if (system.isAndroid) HapticFeedback.mediumImpact();
    _spin.stop();
    setState(() => _phase = _CleanPhase.done);
    _resetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _phase = _CleanPhase.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (_phase) {
      _CleanPhase.idle => const Icon(
        Icons.cleaning_services_outlined,
        key: ValueKey(_CleanPhase.idle),
      ),
      _CleanPhase.running => RotationTransition(
        key: const ValueKey(_CleanPhase.running),
        turns: _spin,
        child: Icon(Icons.sync_rounded, color: context.colorScheme.primary),
      ),
      _CleanPhase.done => Icon(
        Icons.check_rounded,
        key: const ValueKey(_CleanPhase.done),
        color: context.colorScheme.primary,
      ),
    };
    return IconButton(
      onPressed: widget.onClean == null ? null : _handle,
      tooltip: widget.tooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: icon,
      ),
    );
  }
}
