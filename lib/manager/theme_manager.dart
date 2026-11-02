import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/theme.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/state.dart';

class ThemeManager extends ConsumerStatefulWidget {
  final Widget child;

  const ThemeManager({super.key, required this.child});

  @override
  ConsumerState<ThemeManager> createState() => _ThemeManagerState();
}

class _ThemeManagerState extends ConsumerState<ThemeManager> {
  ThemeData? _theme;
  double? _textScaleFactor;

  void _syncThemeMetrics(double textScaleFactor) {
    final theme = Theme.of(context);
    if (identical(theme, _theme) && textScaleFactor == _textScaleFactor) {
      return;
    }
    _theme = theme;
    _textScaleFactor = textScaleFactor;
    globalState.measure = Measure.of(context, textScaleFactor);
    globalState.theme = CommonTheme.of(context, textScaleFactor);
  }

  Widget _buildSystemUi(Widget child) {
    if (!system.isAndroid) {
      return child;
    }
    return Consumer(
      builder: (context, ref, _) {
        final brightness = ref.watch(currentBrightnessProvider);
        final iconBrightness = brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light;
        final style = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: iconBrightness,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarIconBrightness: iconBrightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        );
        if (globalState.appState.systemUiOverlayStyle != style) {
          globalState.appState = globalState.appState.copyWith(
            systemUiOverlayStyle: style,
          );
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: style,
          sized: false,
          child: child,
        );
      },
    );
  }

  // _buildScrollbar(Widget child) {
  //   return Consumer(
  //     builder: (_, ref, child) {
  //       final isMobileView = ref.read(isMobileViewProvider);
  //       if (isMobileView) {
  //         return ScrollConfiguration(
  //           behavior: HiddenBarScrollBehavior(),
  //           child: child!,
  //         );
  //       }
  //       return child!;
  //     },
  //     child: child,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final textScale = ref.read(
      themeSettingProvider.select((state) => state.textScale),
    );
    final double textScaleFactor = max(
      min(
        textScale.enable ? textScale.scale : defaultTextScaleFactor,
        maxTextScale,
      ),
      minTextScale,
    );

    _syncThemeMetrics(textScaleFactor);
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final height = mediaQuery.size.height;
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
        padding: padding.copyWith(
          top: padding.top > height * 0.3 ? 20.0 : padding.top,
        ),
      ),
      child: LayoutBuilder(
        builder: (_, container) {
          globalState.appController.updateViewSize(
            Size(container.maxWidth, container.maxHeight),
          );
          return _buildSystemUi(widget.child);
        },
      ),
    );
  }
}
