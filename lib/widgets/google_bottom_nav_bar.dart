import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kFloatingNavBarBottomMargin = 16.0;
const kFloatingNavBarHorizontalMargin = 20.0;
const kFloatingNavBarBorderRadius = 32.0;
const kFloatingNavBarBlurSigma = 10.0;
const kFloatingNavBarScrollPadding = 72.0;
const kFloatingNavBarScrollInset =
    kFloatingNavBarScrollPadding + kFloatingNavBarBottomMargin;

class FloatingNavBarScope extends InheritedWidget {
  final double scrollBottomPadding;

  const FloatingNavBarScope({
    super.key,
    this.scrollBottomPadding = kFloatingNavBarScrollInset,
    required super.child,
  });

  static FloatingNavBarScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FloatingNavBarScope>();
  }

  @override
  bool updateShouldNotify(FloatingNavBarScope oldWidget) {
    return scrollBottomPadding != oldWidget.scrollBottomPadding;
  }
}

extension FloatingNavContext on BuildContext {
  double get floatingNavScrollPadding =>
      FloatingNavBarScope.maybeOf(this)?.scrollBottomPadding ?? 0;

  EdgeInsets withFloatingNavPadding(EdgeInsets padding) {
    final extra = floatingNavScrollPadding;
    if (extra == 0) return padding;
    return padding.copyWith(bottom: padding.bottom + extra);
  }
}

class FloatingNavFabLocation extends FloatingActionButtonLocation {
  final double bottomInset;

  const FloatingNavFabLocation(this.bottomInset);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final base =
        FloatingActionButtonLocation.endFloat.getOffset(scaffoldGeometry);
    return Offset(base.dx, base.dy - bottomInset);
  }
}

class GoogleBottomNavBar extends ConsumerWidget {
  static final ImageFilter _floatingBlurFilter = ImageFilter.blur(
    sigmaX: kFloatingNavBarBlurSigma,
    sigmaY: kFloatingNavBarBlurSigma,
  );

  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final bool floating;

  const GoogleBottomNavBar({
    super.key,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onTabChange,
    this.floating = false,
  });

  IconData _extractIconData(Widget iconWidget) {
    if (iconWidget is Icon) {
      return iconWidget.icon ?? Icons.home;
    }
    return Icons.home;
  }

  List<GButton> _buildTabs() {
    return navigationItems
        .map(
          (e) => GButton(
            key: ValueKey(e.label),
            icon: _extractIconData(e.icon),
            text: Intl.message(e.label.name),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableHapticFeedback = ref.watch(
      appSettingProvider.select((state) => state.enableNavBarHapticFeedback),
    );

    if (floating) {
      return _buildFloatingNav(context, enableHapticFeedback);
    }
    return _buildClassicNav(context, enableHapticFeedback);
  }

  Widget _buildClassicNav(BuildContext context, bool enableHapticFeedback) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            rippleColor: enableHapticFeedback
                ? context.colorScheme.onSurface.withValues(alpha: 0.15)
                : Colors.transparent,
            hoverColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
            haptic: enableHapticFeedback,
            gap: 8,
            activeColor: context.colorScheme.onSecondaryContainer,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 250),
            tabBackgroundColor: context.colorScheme.secondaryContainer,
            color: context.colorScheme.onSurfaceVariant,
            curve: Curves.easeInOut,
            tabs: _buildTabs(),
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              if (system.isAndroid && enableHapticFeedback) {
                HapticFeedback.selectionClick();
              }
              onTabChange(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNav(BuildContext context, bool enableHapticFeedback) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final glassColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.72)
        : colorScheme.surface.withValues(alpha: 0.82);

    final nav = GNav(
      key: ValueKey(
        navigationItems.map((e) => e.label).join(),
      ),
      backgroundColor: Colors.transparent,
      rippleColor: enableHapticFeedback
          ? colorScheme.onSurface.withValues(alpha: 0.12)
          : Colors.transparent,
      hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
      haptic: enableHapticFeedback,
      gap: 8,
      activeColor: colorScheme.onSecondaryContainer,
      iconSize: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      duration: const Duration(milliseconds: 250),
      tabBackgroundColor: colorScheme.secondaryContainer,
      tabBorderRadius: 24,
      color: colorScheme.onSurfaceVariant,
      curve: Curves.easeInOut,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      tabs: _buildTabs(),
      selectedIndex: selectedIndex,
      onTabChange: (index) {
        if (system.isAndroid && enableHapticFeedback) {
          HapticFeedback.selectionClick();
        }
        onTabChange(index);
      },
    );

    return RepaintBoundary(
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: kFloatingNavBarBottomMargin),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kFloatingNavBarHorizontalMargin,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(kFloatingNavBarBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(kFloatingNavBarBorderRadius),
                child: BackdropFilter(
                  filter: _floatingBlurFilter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: glassColor,
                      borderRadius:
                          BorderRadius.circular(kFloatingNavBarBorderRadius),
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: nav,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
