import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleBottomNavBar extends ConsumerWidget {
  final List<NavigationItem> navigationItems;
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const GoogleBottomNavBar({
    super.key,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onTabChange,
  });

  IconData _extractIconData(Widget iconWidget) {
    if (iconWidget is Icon) {
      return iconWidget.icon ?? Icons.home;
    }
    return Icons.home;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableHapticFeedback = ref.watch(
      appSettingProvider.select((state) => state.enableNavBarHapticFeedback),
    );
    final tabsList = navigationItems
        .map(
          (e) => GButton(
            icon: _extractIconData(e.icon),
            text: Intl.message(e.label.name),
          ),
        )
        .toList();

    void handleTabChange(int index) {
      // Trigger vibration only if haptic feedback enabled
      if (system.isAndroid && enableHapticFeedback) {
        HapticFeedback.selectionClick(); // Lighter haptic feedback
      }
      onTabChange(index);
    }

    return RepaintBoundary(
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: context.colorScheme.brightness == Brightness.light
                      ? 0.5
                      : 0.4,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  color: Colors.black.withValues(
                    alpha: context.colorScheme.brightness == Brightness.light
                        ? 0.08
                        : 0.18,
                  ),
                ),
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                  color: Colors.black.withValues(
                    alpha: context.colorScheme.brightness == Brightness.light
                        ? 0.04
                        : 0.1,
                  ),
                ),
              ],
            ),
            child: GNav(
              rippleColor: enableHapticFeedback
                  ? context.colorScheme.onSurface.withValues(alpha: 0.15)
                  : Colors
                        .transparent, // Disabling ripple may disable haptic feedback
              hoverColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
              haptic: enableHapticFeedback, // Control GNav haptic feedback
              gap: 8,
              activeColor: context.colorScheme.onSecondaryContainer,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              duration: const Duration(milliseconds: 250),
              tabBackgroundColor: context.colorScheme.secondaryContainer,
              color: context.colorScheme.onSurfaceVariant,
              tabs: tabsList,
              selectedIndex: selectedIndex,
              onTabChange: handleTabChange,
            ),
          ),
        ),
      ),
    );
  }
}
