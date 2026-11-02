import 'dart:math' as math;
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Color navBarBodyColor(ColorScheme colorScheme) {
  if (colorScheme.brightness == Brightness.light) {
    return Color.lerp(
      colorScheme.surface,
      colorScheme.surfaceContainerLowest,
      0.5,
    )!;
  }
  return colorScheme.surfaceContainerHigh;
}

double navBarSlotResistance(double slot, int count) {
  const maxOvershoot = 0.22;
  final maxIndex = math.max(0, count - 1).toDouble();
  if (slot < 0.0) {
    return -maxOvershoot * (1.0 - math.exp(slot / maxOvershoot));
  }
  if (slot > maxIndex) {
    return maxIndex +
        maxOvershoot * (1.0 - math.exp((maxIndex - slot) / maxOvershoot));
  }
  return slot;
}

class SelectionHaptic {
  int _lastTime = 0;

  void call(bool enable) {
    if (!system.isAndroid || !enable) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTime <= 35) return;
    _lastTime = now;
    HapticFeedback.selectionClick();
  }
}

class GoogleBottomNavBar extends ConsumerStatefulWidget {
  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const GoogleBottomNavBar({
    super.key,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  ConsumerState<GoogleBottomNavBar> createState() => _GoogleBottomNavBarState();
}

class _GoogleBottomNavBarState extends ConsumerState<GoogleBottomNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _posController = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  late final AnimationController _liftController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );

  int? _activePointerId;
  bool _isDragging = false;
  bool _dragCancel = false;
  Offset? _downPosition;
  VelocityTracker? _velocityTracker;
  double _anchorSlot = 0.0;
  double _barWidth = 0;
  int _lastSnappedIndex = 0;
  final _haptic = SelectionHaptic();
  late final ValueNotifier<int> _highlightedIndex = ValueNotifier(
    widget.selectedIndex,
  );
  late final ValueNotifier<int?> _pressedIndex = ValueNotifier(null);
  final ValueNotifier<double> _dragOffset = ValueNotifier(0.0);

  static const double _horizontalInset = 17.0;

  double? _posTarget;
  int? _jumpFromIndex;
  int? _jumpToIndex;

  void _glideTo(int index, int milliseconds) {
    _posTarget = index.toDouble();
    final fromIndex = _posController.value.round().clamp(
      0,
      widget.navigationItems.length - 1,
    );
    if ((fromIndex - index).abs() > 1 && !_isDragging) {
      _jumpFromIndex = fromIndex;
      _jumpToIndex = index;
    } else {
      _jumpFromIndex = null;
      _jumpToIndex = null;
    }
    if (milliseconds <= 0) {
      _posController.value = index.toDouble();
      _jumpFromIndex = null;
      _jumpToIndex = null;
      return;
    }
    _posController
        .animateTo(
          index.toDouble(),
          duration: Duration(milliseconds: milliseconds),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (mounted && _posTarget == index.toDouble()) {
            _jumpFromIndex = null;
            _jumpToIndex = null;
          }
        });
  }

  void _liftTo(double value, int milliseconds) {
    _liftController.animateTo(
      value,
      duration: Duration(milliseconds: milliseconds),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _lastSnappedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant GoogleBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        _activePointerId == null) {
      _highlightedIndex.value = widget.selectedIndex;
      _lastSnappedIndex = widget.selectedIndex;
      if (!_posController.isAnimating) {
        _posController.value = widget.selectedIndex.toDouble();
      }
    }
  }

  @override
  void dispose() {
    _highlightedIndex.dispose();
    _pressedIndex.dispose();
    _dragOffset.dispose();
    _posController.dispose();
    _liftController.dispose();
    super.dispose();
  }

  double get _slotWidth {
    final count = widget.navigationItems.length;
    if (count == 0) return 0.0;
    return math.max(0.0, _barWidth - 2.0) / count;
  }

  void _commitDragOffset() {
    if (_dragOffset.value == 0.0) return;
    _posController.value = navBarSlotResistance(
      _posController.value + _dragOffset.value,
      widget.navigationItems.length,
    );
    _dragOffset.value = 0.0;
  }

  int _indexFromLocalDx(double dx) {
    const borderWidth = 1.0;
    final innerWidth = math.max(0.0, _barWidth - (2 * borderWidth));
    final count = widget.navigationItems.length;
    if (innerWidth <= 0 || count == 0) return widget.selectedIndex;
    final slotWidth = innerWidth / count;
    final localDx = (dx - borderWidth).clamp(0.0, innerWidth - 0.001);
    return (localDx / slotWidth).floor().clamp(0, count - 1);
  }

  @override
  Widget build(BuildContext context) {
    final enableFeedback = ref.watch(
      appSettingProvider.select((state) => state.enableNavBarHapticFeedback),
    );
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final primaryColor = colorScheme.primary;
    final onSurfaceVariantColor = colorScheme.onSurfaceVariant;

    final navColor = navBarBodyColor(
      colorScheme,
    ).withValues(alpha: 0.98);
    final shadowStrength = isLight ? 1.0 : 3.0;

    const itemTextStyle = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w500,
    );

    final count = widget.navigationItems.length;
    final localizedLabels = [
      for (final item in widget.navigationItems) item.label.localizedName,
    ];

    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            if (_activePointerId != null) return;
            _activePointerId = event.pointer;
            _downPosition = event.localPosition;
            _velocityTracker = VelocityTracker.withKind(event.kind)
              ..addPosition(event.timeStamp, event.localPosition);
            _dragCancel = false;
            _isDragging = false;
            _dragOffset.value = 0.0;

            final touchedIndex = _indexFromLocalDx(
              event.localPosition.dx - _horizontalInset,
            );
            _anchorSlot = touchedIndex.toDouble();
            _lastSnappedIndex = touchedIndex;
            _highlightedIndex.value = touchedIndex;
            _pressedIndex.value = touchedIndex;
            if (touchedIndex != widget.selectedIndex) {
              _haptic(enableFeedback);
            }

            _posController.stop();
            _posController.value = touchedIndex.toDouble();
            _jumpFromIndex = null;
            _jumpToIndex = null;

            _liftTo(1.0, 140);
          },
          onPointerMove: (event) {
            if (_activePointerId != event.pointer || _dragCancel) return;
            final downPos = _downPosition;
            if (downPos == null) return;
            _velocityTracker?.addPosition(event.timeStamp, event.localPosition);
            final delta = event.localPosition - downPos;
            if (delta.dy < -50 || delta.dy > 80) {
              _dragCancel = true;
              _isDragging = false;
              _velocityTracker = null;
              _pressedIndex.value = null;
              _highlightedIndex.value = widget.selectedIndex;
              _commitDragOffset();
              _glideTo(widget.selectedIndex, 180);
              _liftTo(0.0, 180);
              return;
            }

            final slotWidth = _slotWidth;
            if (!_isDragging && delta.dx.abs() > 4) {
              _isDragging = true;
              _jumpFromIndex = null;
              _jumpToIndex = null;
            }
            if (!_isDragging || slotWidth <= 0) return;

            _dragOffset.value = delta.dx / slotWidth;
            final index = (_anchorSlot + _dragOffset.value).round().clamp(
              0,
              count - 1,
            );
            _highlightedIndex.value = index;
            _pressedIndex.value = index;
            if (index != _lastSnappedIndex) {
              _lastSnappedIndex = index;
              _haptic(enableFeedback);
            }
          },
          onPointerUp: (event) {
            if (_activePointerId != event.pointer) return;
            _activePointerId = null;
            _pressedIndex.value = null;
            _liftTo(0.0, 180);
            if (_dragCancel) {
              _dragCancel = false;
              _isDragging = false;
              _velocityTracker = null;
              return;
            }

            final slotWidth = _slotWidth;
            final int targetIndex;
            if (_isDragging && slotWidth > 0) {
              final velocityPx =
                  _velocityTracker?.getVelocity().pixelsPerSecond.dx ?? 0.0;
              final slotVelocity = velocityPx / slotWidth;
              final currentSlot = _anchorSlot + _dragOffset.value;
              final fling = (slotVelocity * 0.16).clamp(-1.2, 1.2);
              var projected = (currentSlot + fling).round();
              if (velocityPx.abs() > 240.0) {
                final baseIndex = currentSlot.round();
                if (projected == baseIndex) {
                  projected += velocityPx.sign.toInt();
                }
              }
              targetIndex = projected.clamp(0, count - 1);

              _commitDragOffset();
              _highlightedIndex.value = targetIndex;
              final distance = (_posController.value - targetIndex.toDouble())
                  .abs();
              final snapMs = (130 + (distance * 80) - (velocityPx.abs() * 0.03))
                  .clamp(120, 220)
                  .toInt();
              _glideTo(targetIndex, snapMs);
            } else {
              targetIndex = _indexFromLocalDx(
                event.localPosition.dx - _horizontalInset,
              );
              _highlightedIndex.value = targetIndex;
              _posController.stop();
              _posController.value = targetIndex.toDouble();
            }

            _velocityTracker = null;
            _isDragging = false;
            if (targetIndex != widget.selectedIndex) {
              widget.onTabChange(targetIndex);
            }
          },
          onPointerCancel: (event) {
            if (_activePointerId != event.pointer) return;
            _activePointerId = null;
            _isDragging = false;
            _dragCancel = false;
            _velocityTracker = null;
            _pressedIndex.value = null;
            _highlightedIndex.value = widget.selectedIndex;
            _commitDragOffset();
            _posController.stop();
            _posController.value = widget.selectedIndex.toDouble();
            _liftTo(0.0, 180);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
            child: LayoutBuilder(
              builder: (context, constraints) {
                _barWidth = constraints.maxWidth;
                const barHeight = 60.0;

                return RepaintBoundary(
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: navColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          color: colorScheme.shadow.withValues(
                            alpha: 0.08 * shadowStrength,
                          ),
                        ),
                        BoxShadow(
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                          color: colorScheme.shadow.withValues(
                            alpha: 0.04 * shadowStrength,
                          ),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        if (count > 0)
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: NavBarPillPainter(
                                  position: _posController,
                                  lift: _liftController,
                                  dragOffset: _dragOffset,
                                  count: count,
                                  slot: navBarSlotResistance,
                                  color: primaryColor,
                                  baseAlpha: isLight ? 0.12 : 0.20,
                                  activeAlpha: isLight ? 0.18 : 0.26,
                                ),
                              ),
                            ),
                          ),
                        RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _posController,
                              _dragOffset,
                              _pressedIndex,
                              _liftController,
                            ]),
                            builder: (context, _) {
                              final currentPos = navBarSlotResistance(
                                _posController.value + _dragOffset.value,
                                count,
                              );
                              final pressedIdx = _pressedIndex.value;
                              final liftValue = _liftController.value;

                              final jumpFrom = _jumpFromIndex;
                              final jumpTo = _jumpToIndex;
                              final isNonAdjacentJump =
                                  jumpFrom != null &&
                                  jumpTo != null &&
                                  (jumpFrom - jumpTo).abs() > 1;
                              final minJump = isNonAdjacentJump
                                  ? math.min(jumpFrom, jumpTo)
                                  : -1;
                              final maxJump = isNonAdjacentJump
                                  ? math.max(jumpFrom, jumpTo)
                                  : -1;

                              return Row(
                                children: List.generate(count, (index) {
                                  final item = widget.navigationItems[index];
                                  final isPressed = index == pressedIdx;
                                  final double itemScale;
                                  final Color itemColor;
                                  if (isNonAdjacentJump &&
                                      index > minJump &&
                                      index < maxJump) {
                                    itemScale = 1.0;
                                    itemColor = onSurfaceVariantColor;
                                  } else {
                                    final double selectFactor;
                                    if (isNonAdjacentJump) {
                                      if (index == jumpFrom) {
                                        final distFromOrigin =
                                            (currentPos - jumpFrom).abs().clamp(
                                              0.0,
                                              1.0,
                                            );
                                        selectFactor =
                                            1.0 -
                                            Curves.easeOut.transform(
                                              distFromOrigin,
                                            );
                                      } else if (index == jumpTo) {
                                        final distToTarget =
                                            (currentPos - jumpTo).abs().clamp(
                                              0.0,
                                              1.0,
                                            );
                                        selectFactor =
                                            1.0 -
                                            Curves.easeOut.transform(
                                              distToTarget,
                                            );
                                      } else {
                                        selectFactor = 0.0;
                                      }
                                    } else {
                                      final rawDist = (currentPos - index)
                                          .abs();
                                      if (rawDist >= 1.0) {
                                        selectFactor = 0.0;
                                      } else {
                                        final dist = rawDist.clamp(0.0, 1.0);
                                        selectFactor =
                                            1.0 -
                                            Curves.easeOut.transform(dist);
                                      }
                                    }

                                    if (selectFactor <= 0.0 && !isPressed) {
                                      itemScale = 1.0;
                                      itemColor = onSurfaceVariantColor;
                                    } else {
                                      itemScale = isPressed
                                          ? (1.0 - 0.05 * liftValue)
                                          : (1.0 + 0.04 * selectFactor);
                                      itemColor = Color.lerp(
                                        onSurfaceVariantColor,
                                        primaryColor,
                                        selectFactor,
                                      )!;
                                    }
                                  }

                                  return Expanded(
                                    child: Center(
                                      child: Transform.scale(
                                        scale: itemScale,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconTheme(
                                              data: IconThemeData(
                                                color: itemColor,
                                                size: 22,
                                              ),
                                              child: item.icon,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              localizedLabels[index],
                                              style: itemTextStyle.copyWith(
                                                color: itemColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NavBarPillPainter extends CustomPainter {
  final Animation<double> position;
  final Animation<double> lift;
  final ValueListenable<double> dragOffset;
  final int count;
  final double Function(double slot, int count) slot;
  final Color color;
  final double baseAlpha;
  final double activeAlpha;
  final Rect Function(Size size, double position)? track;

  NavBarPillPainter({
    required this.position,
    required this.lift,
    required this.dragOffset,
    required this.count,
    required this.slot,
    required this.color,
    required this.baseAlpha,
    required this.activeAlpha,
    this.track,
  }) : super(repaint: Listenable.merge([position, lift, dragOffset]));

  static const double _restingGap = 4.0;

  Rect pillRect(Size size) {
    final gap = _restingGap * (1 - lift.value);
    final pos = slot(position.value + dragOffset.value, count);
    final slotWidth = size.width / count;
    final base =
        track?.call(size, pos) ??
        Rect.fromLTWH(pos * slotWidth, 0, slotWidth, size.height);
    final width = math.max(0.0, base.width - 2 * gap);
    return Rect.fromLTWH(
      base.center.dx - width / 2,
      gap,
      width,
      size.height - 2 * gap,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = lift.value;
    final restingRadius = (size.height - 2 * _restingGap) / 2;
    final radius = restingRadius + (size.height / 2 - restingRadius) * t;
    final alpha = baseAlpha + (activeAlpha - baseAlpha) * t;
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.height / 2),
      ),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect(size), Radius.circular(radius)),
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(NavBarPillPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.lift != lift ||
        oldDelegate.dragOffset != dragOffset ||
        oldDelegate.count != count ||
        oldDelegate.track != track ||
        oldDelegate.color != color ||
        oldDelegate.baseAlpha != baseAlpha ||
        oldDelegate.activeAlpha != activeAlpha;
  }
}
