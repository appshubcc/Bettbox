import 'dart:ui';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

String getDelayAnimationLabel(DelayAnimationType type) {
  return switch (type) {
    DelayAnimationType.none => appLocalizations.noAnimation,
    DelayAnimationType.rotatingCircle => appLocalizations.rotatingCircle,
    DelayAnimationType.pulse => appLocalizations.pulse,
    DelayAnimationType.spinningLines => appLocalizations.spinningLines,
    DelayAnimationType.threeInOut => appLocalizations.threeInOut,
    DelayAnimationType.threeBounce => appLocalizations.threeBounce,
    DelayAnimationType.circle => appLocalizations.circle,
    DelayAnimationType.fadingCircle => appLocalizations.fadingCircle,
    DelayAnimationType.fadingFour => appLocalizations.fadingFour,
    DelayAnimationType.wave => appLocalizations.wave,
    DelayAnimationType.doubleBounce => appLocalizations.doubleBounce,
    DelayAnimationType.chasingDots => appLocalizations.chasingDots,
    DelayAnimationType.cubeGrid => appLocalizations.cubeGrid,
    DelayAnimationType.dancingSquare => appLocalizations.dancingSquare,
    DelayAnimationType.dualRing => appLocalizations.dualRing,
    DelayAnimationType.fadingCube => appLocalizations.fadingCube,
    DelayAnimationType.fadingGrid => appLocalizations.fadingGrid,
    DelayAnimationType.foldingCube => appLocalizations.foldingCube,
    DelayAnimationType.hourGlass => appLocalizations.hourGlass,
    DelayAnimationType.pianoWave => appLocalizations.pianoWave,
    DelayAnimationType.pouringHourGlass => appLocalizations.pouringHourGlass,
    DelayAnimationType.pouringHourGlassRefined =>
      appLocalizations.pouringHourGlassRefined,
    DelayAnimationType.pulsingGrid => appLocalizations.pulsingGrid,
    DelayAnimationType.pumpingHeart => appLocalizations.pumpingHeart,
    DelayAnimationType.ring => appLocalizations.ring,
    DelayAnimationType.ripple => appLocalizations.ripple,
    DelayAnimationType.rotatingPlain => appLocalizations.rotatingPlain,
    DelayAnimationType.spinningCircle => appLocalizations.spinningCircle,
    DelayAnimationType.squareCircle => appLocalizations.squareCircle,
    DelayAnimationType.wanderingCubes => appLocalizations.wanderingCubes,
    DelayAnimationType.waveSpinner => appLocalizations.waveSpinner,
  };
}

class DelayAnimation extends StatelessWidget {
  final DelayAnimationType type;
  final double size;
  final Color color;

  const DelayAnimation({
    super.key,
    required this.type,
    this.size = 24.0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      DelayAnimationType.none => SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
      DelayAnimationType.rotatingCircle => SpinKitRotatingCircle(
          color: color,
          size: size,
        ),
      DelayAnimationType.pulse => SpinKitPulse(
          color: color,
          size: size,
        ),
      DelayAnimationType.spinningLines => SpinKitSpinningLines(
          color: color,
          size: size,
        ),
      DelayAnimationType.threeInOut => SpinKitThreeInOut(
          color: color,
          size: size,
        ),
      DelayAnimationType.threeBounce => SpinKitThreeBounce(
          color: color,
          size: size,
        ),
      DelayAnimationType.circle => SpinKitCircle(
          color: color,
          size: size,
        ),
      DelayAnimationType.fadingCircle => SpinKitFadingCircle(
          color: color,
          size: size,
        ),
      DelayAnimationType.fadingFour => SpinKitFadingFour(
          color: color,
          size: size,
        ),
      DelayAnimationType.wave => SpinKitWave(
          color: color,
          size: size,
        ),
      DelayAnimationType.doubleBounce => SpinKitDoubleBounce(
          color: color,
          size: size,
        ),
      DelayAnimationType.chasingDots => SpinKitChasingDots(
          color: color,
          size: size,
        ),
      DelayAnimationType.cubeGrid => SpinKitCubeGrid(
          color: color,
          size: size,
        ),
      DelayAnimationType.dancingSquare => SpinKitDancingSquare(
          color: color,
          size: size,
        ),
      DelayAnimationType.dualRing => SpinKitDualRing(
          color: color,
          size: size,
          lineWidth: size > 30 ? 4.0 : 2.0,
        ),
      DelayAnimationType.fadingCube => SpinKitFadingCube(
          color: color,
          size: size,
        ),
      DelayAnimationType.fadingGrid => SpinKitFadingGrid(
          color: color,
          size: size,
        ),
      DelayAnimationType.foldingCube => SpinKitFoldingCube(
          color: color,
          size: size,
        ),
      DelayAnimationType.hourGlass => SpinKitHourGlass(
          color: color,
          size: size,
        ),
      DelayAnimationType.pianoWave => SpinKitPianoWave(
          color: color,
          size: size,
        ),
      DelayAnimationType.pouringHourGlass => SpinKitPouringHourGlass(
          color: color,
          size: size,
        ),
      DelayAnimationType.pouringHourGlassRefined =>
        SpinKitPouringHourGlassRefined(
          color: color,
          size: size,
        ),
      DelayAnimationType.pulsingGrid => SpinKitPulsingGrid(
          color: color,
          size: size,
        ),
      DelayAnimationType.pumpingHeart => SpinKitPumpingHeart(
          color: color,
          size: size,
        ),
      DelayAnimationType.ring => SpinKitRing(
          color: color,
          size: size,
          lineWidth: size > 30 ? 4.0 : 2.0,
        ),
      DelayAnimationType.ripple => SpinKitRipple(
          color: color,
          size: size,
          borderWidth: size > 30 ? 4.0 : 2.0,
        ),
      DelayAnimationType.rotatingPlain => SpinKitRotatingPlain(
          color: color,
          size: size,
        ),
      DelayAnimationType.spinningCircle => SpinKitSpinningCircle(
          color: color,
          size: size,
        ),
      DelayAnimationType.squareCircle => SpinKitSquareCircle(
          color: color,
          size: size,
        ),
      DelayAnimationType.wanderingCubes => SpinKitWanderingCubes(
          color: color,
          size: size,
        ),
      DelayAnimationType.waveSpinner => SpinKitWaveSpinner(
          color: color,
          size: size,
          waveColor: color.withValues(alpha: 0.5),
        ),
    };
  }
}

class DelayAnimationPickerDialog extends StatefulWidget {
  final String title;
  final DelayAnimationType initialValue;

  const DelayAnimationPickerDialog({
    super.key,
    required this.title,
    required this.initialValue,
  });

  @override
  State<DelayAnimationPickerDialog> createState() =>
      _DelayAnimationPickerDialogState();
}

class _DelayAnimationPickerDialogState
    extends State<DelayAnimationPickerDialog> {
  late DelayAnimationType _currentValue = widget.initialValue;
  late final FixedExtentScrollController _scrollController;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    final initialIndex =
        DelayAnimationType.values.indexOf(widget.initialValue);
    _targetIndex = initialIndex >= 0 ? initialIndex : 0;
    _scrollController = FixedExtentScrollController(
      initialItem: _targetIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handlePointerScroll(PointerScrollEvent event) {
    if (event.scrollDelta.dy == 0) return;
    final direction = event.scrollDelta.dy > 0 ? 1 : -1;
    final current = _scrollController.hasClients
        ? _scrollController.selectedItem
        : _targetIndex;
    final nextIndex = (current + direction).clamp(
      0,
      DelayAnimationType.values.length - 1,
    );
    if (nextIndex != _targetIndex || current != nextIndex) {
      _targetIndex = nextIndex;
      _scrollController.animateToItem(
        _targetIndex,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      overrideScroll: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_currentValue),
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    context.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 38,
                  child: Center(
                    child: DelayAnimation(
                      type: _currentValue,
                      size: 32,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  getDelayAnimationLabel(_currentValue),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                      },
                    ),
                    child: CupertinoPicker(
                      scrollController: _scrollController,
                      itemExtent: 40.0,
                      magnification: 1.15,
                      useMagnifier: true,
                      squeeze: 1.15,
                      diameterRatio: 1.25,
                      selectionOverlay: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: context.colorScheme.primary
                                  .withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          _currentValue = DelayAnimationType.values[index];
                          _targetIndex = index;
                        });
                      },
                      children: DelayAnimationType.values.map((type) {
                        final isSelected = type == _currentValue;
                        return Center(
                          child: Text(
                            getDelayAnimationLabel(type),
                            style: TextStyle(
                              fontSize: isSelected ? 16 : 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        GestureBinding.instance.pointerSignalResolver.register(
                          pointerSignal,
                          (event) {
                            if (event is PointerScrollEvent) {
                              _handlePointerScroll(event);
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
