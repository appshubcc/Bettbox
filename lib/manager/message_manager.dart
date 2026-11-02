import 'dart:async';
import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/widgets/fade_box.dart';
import 'package:bett_box/widgets/text.dart';
import 'package:material_ui/material_ui.dart';

const _lightShadows = [
  BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
  BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 20),
  BoxShadow(
    color: Color(0x24000000),
    offset: Offset(0, 24),
    blurRadius: 48,
    spreadRadius: -12,
  ),
];

const _darkShadows = [
  BoxShadow(color: Color(0x80000000), offset: Offset(0, 2), blurRadius: 5),
  BoxShadow(
    color: Color(0x99000000),
    offset: Offset(0, 24),
    blurRadius: 48,
    spreadRadius: -12,
  ),
];

class MessageManager extends StatefulWidget {
  final Widget child;

  const MessageManager({super.key, required this.child});

  @override
  State<MessageManager> createState() => MessageManagerState();
}

class MessageManagerState extends State<MessageManager> {
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  final List<CommonMessage> _bufferMessages = [];
  bool _pushing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    super.dispose();
  }

  Future<void> message(
    String text, {
    VoidCallback? onAction,
    String? actionLabel,
    bool showCountdown = false,
  }) async {
    if (_messagesNotifier.value.any((m) => m.text == text) ||
        _bufferMessages.any((m) => m.text == text)) {
      return;
    }

    final commonMessage = CommonMessage(
      id: utils.uuidV4,
      text: text,
      onAction: onAction,
      actionLabel: actionLabel,
      showCountdown: showCountdown,
    );
    _bufferMessages.add(commonMessage);
    await _showMessage();
  }

  Future<void> _showMessage() async {
    if (_pushing) return;
    _pushing = true;
    while (_bufferMessages.isNotEmpty) {
      final commonMessage = _bufferMessages.removeAt(0);
      _messagesNotifier.value = List.from(_messagesNotifier.value)
        ..add(commonMessage);
      await Future.delayed(const Duration(seconds: 1));
      Future.delayed(
        commonMessage.duration,
        () => _handleRemove(commonMessage),
      );
      if (_bufferMessages.isEmpty) _pushing = false;
    }
  }

  void _handleRemove(CommonMessage commonMessage) {
    _messagesNotifier.value = List<CommonMessage>.from(_messagesNotifier.value)
      ..remove(commonMessage);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        utils.getViewMode(MediaQuery.sizeOf(context).width) == ViewMode.mobile;
    final top = isMobile
        ? MediaQuery.paddingOf(context).top + 8
        : kToolbarHeight + 8;
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final shape = RoundedSuperellipseBorder(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(
          alpha: isLight ? 0.5 : 0.35,
        ),
      ),
    );
    final pageColor = colorScheme.pageColor;
    return Stack(
      children: [
        widget.child,
        if (isMobile)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 72,
            child: IgnorePointer(
              child: ValueListenableBuilder(
                valueListenable: _messagesNotifier,
                builder: (_, messages, child) => AnimatedOpacity(
                  opacity: messages.isEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: child,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [pageColor, pageColor, pageColor.withAlpha(0)],
                      stops: const [0, 0.7, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ValueListenableBuilder(
          valueListenable: _messagesNotifier,
          builder: (_, messages, _) {
            return FadeThroughBox(
              margin: EdgeInsets.only(top: top, left: 16, right: 16),
              alignment: Alignment.topCenter,
              child: messages.isEmpty
                  ? SizedBox()
                  : LayoutBuilder(
                      key: Key(messages.last.id),
                      builder: (_, constraints) {
                        final message = messages.last;
                        return DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: shape,
                            shadows: isLight ? _lightShadows : _darkShadows,
                          ),
                          child: Material(
                            shape: shape,
                            clipBehavior: Clip.antiAlias,
                            color: isLight
                                ? colorScheme.surfaceBright
                                : colorScheme.surfaceContainerHighest,
                            child: Container(
                              width: isMobile
                                  ? constraints.maxWidth
                                  : min(constraints.maxWidth, 500),
                              constraints: const BoxConstraints(minHeight: 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (message.showCountdown)
                                    _CountdownWidget(
                                      duration: message.duration,
                                    ),
                                  Expanded(
                                    child: EmojiText(
                                      message.text,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  if (message.actionLabel != null &&
                                      message.onAction != null) ...[
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        _handleRemove(message);
                                        message.onAction?.call();
                                      },
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(0, 32),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.standard,
                                        padding: const EdgeInsets.only(
                                          left: 22,
                                          right: 20,
                                        ),
                                        foregroundColor: colorScheme.primary,
                                        backgroundColor: colorScheme.primary
                                            .withValues(alpha: 0.12),
                                        textStyle: context.textTheme.labelLarge
                                            ?.copyWith(letterSpacing: 2),
                                        shape: const StadiumBorder(),
                                      ),
                                      child: Text(message.actionLabel!),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ],
    );
  }
}

class _CountdownWidget extends StatefulWidget {
  final Duration duration;

  const _CountdownWidget({required this.duration});

  @override
  State<_CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<_CountdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.duration.inSeconds;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 24,
        height: 24,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final remaining = (_totalSeconds * (1 - _controller.value)).ceil();
            final currentSecond = remaining > 0 ? remaining : 1;

            return Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1 - _controller.value,
                  strokeWidth: 2,
                  backgroundColor: primaryColor.withAlpha(56),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                Text(
                  '$currentSecond',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
