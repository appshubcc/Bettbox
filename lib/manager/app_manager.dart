import 'dart:async';
import 'dart:math' as math;

import 'package:bett_box/clash/core.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/tools.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  bool _isRefreshActive = false;
  Timer? _dashboardRefreshDebounceTimer;
  Timer? _missedUpdateCheckTimer;
  DateTime? _lastMissedUpdateCheck;
  AppLifecycleState? _lifecycleState;
  late final VoidCallback _dashboardTickListener;

  static const _missedUpdateCheckDelay = Duration(seconds: 5);
  static const _missedUpdateCheckThrottle = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleState = WidgetsBinding.instance.lifecycleState;
    _dashboardTickListener = () {
      if (!globalState.isStart) {
        return;
      }
      unawaited(globalState.appController.updateRunTime());
    };
    dashboardRefreshManager.tick1s.addListener(_dashboardTickListener);
    ref.listenManual(layoutChangeProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (prev != next) {
          globalState.computeHeightMapCache = {};
        }
      });
    });
    ref.listenManual(checkIpProvider, (prev, next) {
      if (next.b && (prev?.a != next.a)) {
        detectionState.startCheck();
      }
    });
    ref.listenManual(initProvider, (prev, next) {
      if (next) {
        detectionState.flushPendingCheck();
      }
    });
    ref.listenManual(checkMediaUnlockProvider, (prev, next) {
      if (next.b && (prev?.a != next.a)) {
        mediaUnlockState.startCheckOnNodeChange();
      }
    });
    ref.listenManual(configStateProvider, (prev, next) {
      if (prev != next) {
        globalState.appController.savePreferencesDebounce();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDashboardRefreshState();
      detectionState.tryStartCheck();
      mediaUnlockState.tryStartCheck();
      globalState.appController.updateGroupsDebounce();
    });
    if (window == null) {
      return;
    }
    ref.listenManual(autoSetSystemDnsStateProvider, (prev, next) async {
      if (prev == next) {
        return;
      }
      final shouldSet = next.a == true && next.b == true;
      await macOS?.updateDns(!shouldSet);
    });
    ref.listenManual(currentBrightnessProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      window?.updateMacOSBrightness(next);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _dashboardRefreshDebounceTimer?.cancel();
    _missedUpdateCheckTimer?.cancel();
    dashboardRefreshManager.tick1s.removeListener(_dashboardTickListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _updateDashboardRefreshState() async {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    final isForeground =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    var isVisible = true;
    var isMinimized = false;
    if (system.isDesktop) {
      final visible = await window?.isVisible;
      if (visible == false) {
        isVisible = false;
      }
      isMinimized = await window?.isMinimized ?? false;
    }
    final isPinned =
        system.isDesktop &&
        ref.read(windowSettingProvider.select((s) => s.isPinned));
    final shouldRun = system.isDesktop
        ? (isPinned || (isVisible && !isMinimized))
        : isForeground;

    if (!shouldRun) {
      _dashboardRefreshDebounceTimer?.cancel();
      _dashboardRefreshDebounceTimer = null;
      if (_isRefreshActive) {
        dashboardRefreshManager.stop();
        _isRefreshActive = false;
      }
      return;
    }

    if (_isRefreshActive) {
      return;
    }

    _dashboardRefreshDebounceTimer?.cancel();
    _dashboardRefreshDebounceTimer = Timer(
      const Duration(milliseconds: 1000),
      () {
        if (!mounted) return;
        if (_isRefreshActive) return;
        dashboardRefreshManager.start();
        _isRefreshActive = true;
      },
    );
  }

  bool get _shouldCheckMissedUpdates {
    if (_lastMissedUpdateCheck == null) return true;
    return DateTime.now().difference(_lastMissedUpdateCheck!) >
        _missedUpdateCheckThrottle;
  }

  void _scheduleMissedUpdateCheck() {
    if (!_shouldCheckMissedUpdates) return;
    _missedUpdateCheckTimer?.cancel();
    _missedUpdateCheckTimer = Timer(_missedUpdateCheckDelay, () {
      _lastMissedUpdateCheck = DateTime.now();
      globalState.appController.checkAndUpdateMissedProfiles();
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final previousState = _lifecycleState;
    _lifecycleState = state;
    final isLeaving =
        previousState == null || state.index > previousState.index;
    final isBackgroundState =
        isLeaving &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            (state == AppLifecycleState.inactive && !system.isDesktop));

    if (isBackgroundState) {
      _missedUpdateCheckTimer?.cancel();
      globalState.appController.savePreferences();
      await globalState.handleBackground();
    } else if (state == AppLifecycleState.resumed) {
      globalState.handleForeground();
      render?.resume();
      await globalState.resumeForegroundUpdates();
      await globalState.appController.syncWakelockIfNeeded();
      _scheduleMissedUpdateCheck();
      try {
        final isInit = await clashCore.isInit;
        if (isInit) {
          await globalState.appController.updateGroups();
        }
      } catch (e) {
        commonPrint.debug('foreground core refresh skipped: $e');
      }

      detectionState.checkOnForegroundResume();
      mediaUnlockState.checkOnForegroundResume();
    }
    if (state == AppLifecycleState.resumed && system.isAndroid) {
      unawaited(
        globalState.refreshPrivateDnsMode().catchError((Object e) {
          commonPrint.warn('Private DNS mode refresh failed: $e');
        }),
      );
      final hidden = ref.read(appSettingProvider.select((s) => s.hidden));
      app.updateExcludeFromRecents(hidden);
      SystemChrome.setSystemUIOverlayStyle(
        globalState.appState.systemUiOverlayStyle,
      );
    }
    _updateDashboardRefreshState();
  }

  @override
  void didChangePlatformBrightness() {
    globalState.appController.updateBrightness();
    globalState.appController.updateTray();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppEnvManager extends StatelessWidget {
  final Widget child;

  const AppEnvManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      if (globalState.isPre) {
        return Banner(
          message: 'DEBUG',
          location: BannerLocation.topEnd,
          child: child,
        );
      }
    }
    if (globalState.isPre) {
      return Banner(
        message: 'PRE',
        location: BannerLocation.topEnd,
        child: child,
      );
    }
    return child;
  }
}

const _sidebarAnimDuration = Duration(milliseconds: 200);
const _sidebarAnimCurve = Curves.easeOutCubic;
const double _sidebarExpandedWidth = 132.0;
const double _sidebarCollapsedWidth = 56.0;
const double _sidebarHeaderHeight = 46.0;
const double _sidebarItemHeight = 38.0;
const double _sidebarIconSize = 21.0;
const double _sidebarItemRadius = 10.0;
const double _sidebarToggleTouchSlack = 12.0;

class _SidebarToggleButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isCollapsed;

  const _SidebarToggleButton({required this.onTap, this.isCollapsed = false});

  @override
  State<_SidebarToggleButton> createState() => _SidebarToggleButtonState();
}

class _SidebarToggleButtonState extends State<_SidebarToggleButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final iconColor = (_isHovering || _isPressed)
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final bgColor = _isPressed
        ? colorScheme.onSurface.withValues(alpha: isLight ? 0.16 : 0.22)
        : (_isHovering
              ? colorScheme.onSurface.withValues(alpha: isLight ? 0.08 : 0.12)
              : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() {
        _isHovering = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Padding(
          padding: system.isDesktop
              ? EdgeInsets.zero
              : const EdgeInsets.fromLTRB(0, 6, _sidebarToggleTouchSlack, 6),
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: widget.isCollapsed ? 1.0 : 0.0),
                duration: _sidebarAnimDuration,
                curve: _sidebarAnimCurve,
                builder: (context, progress, _) {
                  return _SidebarIcon(
                    color: iconColor,
                    width: 15,
                    height: 13,
                    progress: progress,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double progress;

  const _SidebarIcon({
    required this.color,
    this.width = 15,
    this.height = 13,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SidebarIconPainter(color: color, progress: progress),
      ),
    );
  }
}

class _SidebarIconPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _SidebarIconPainter({required this.color, this.progress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * (1.35 / 16.5);
    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final radius = Radius.circular(size.width * (2.8 / 16.5));
    final rrect = RRect.fromRectAndRadius(rect, radius);

    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(rrect, outerPaint);

    final topInset = rect.height * 0.23 * progress;
    final bottomInset = rect.height * 0.23 * progress;
    final lineTop = rect.top + topInset;
    final lineBottom = rect.bottom - bottomInset;
    final dividerX = rect.left + rect.width * (0.30 - 0.05 * progress);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = progress > 0.04 ? StrokeCap.round : StrokeCap.butt;

    canvas.drawLine(
      Offset(dividerX, lineTop),
      Offset(dividerX, lineBottom),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SidebarIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}

class _SidebarOverlay extends StatefulWidget {
  final Widget child;

  const _SidebarOverlay({required this.child});

  @override
  State<_SidebarOverlay> createState() => _SidebarOverlayState();
}

class _SidebarOverlayState extends State<_SidebarOverlay> {
  late final OverlayEntry _entry = OverlayEntry(
    builder: (context) => widget.child,
  );

  @override
  void didUpdateWidget(_SidebarOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [_entry]);
  }
}

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  double get _headerHeight => _sidebarHeaderHeight;

  Widget _buildLoading({
    required bool isCollapsed,
    required bool needSafeArea,
  }) {
    return Consumer(
      builder: (_, ref, _) {
        final loading = ref.watch(loadingProvider);
        final isMobileView = ref.watch(isMobileViewProvider);
        if (!loading || isMobileView) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          left: false,
          top: needSafeArea,
          right: false,
          bottom: needSafeArea,
          child: Column(
            children: [
              AnimatedContainer(
                duration: _sidebarAnimDuration,
                curve: _sidebarAnimCurve,
                height: isCollapsed ? _headerHeight : 0,
              ),
              const Expanded(
                child: RepaintBoundary(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: LinearProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static (String, TextScaler, String?, double)? _expandedWidthCache;

  double _calculateExpandedWidth(
    BuildContext context,
    List<NavigationItem> items,
  ) {
    if (items.isEmpty) return _sidebarExpandedWidth;
    final labels = items.map((item) => item.label.localizedName).join('\n');
    final scaler =
        MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
    final fontFamily = context.textTheme.labelLarge?.fontFamily;
    final cache = _expandedWidthCache;
    if (cache != null &&
        cache.$1 == labels &&
        cache.$2 == scaler &&
        cache.$3 == fontFamily) {
      return cache.$4;
    }
    final width = _measureExpandedWidth(context, items, scaler);
    _expandedWidthCache = (labels, scaler, fontFamily, width);
    return width;
  }

  double _measureExpandedWidth(
    BuildContext context,
    List<NavigationItem> items,
    TextScaler textScaler,
  ) {
    final textStyle = (context.textTheme.labelLarge ?? const TextStyle())
        .copyWith(
          fontSize: 13.5,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w600,
        );
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;

    double maxTextWidth = 0.0;
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(text: item.label.localizedName, style: textStyle),
        textDirection: direction,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      if (painter.width > maxTextWidth) {
        maxTextWidth = painter.width;
      }
      painter.dispose();
    }

    final requiredWidth = 18.0 + _sidebarItemHeight + maxTextWidth + 10.0;
    final itemsWidth = requiredWidth <= 110.0
        ? 118.0
        : requiredWidth <= 120.0
        ? 132.0
        : requiredWidth <= 136.0
        ? 148.0
        : 156.0;
    if (system.isMacOS) return itemsWidth;
    final brandPainter = TextPainter(
      text: TextSpan(
        text: AppIdentity.productName,
        style: _brandTextStyle(context),
      ),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final headerWidth =
        14.0 +
        brandPainter.width +
        8.0 +
        28.0 +
        (system.isDesktop ? 10.0 : _sidebarToggleTouchSlack);
    brandPainter.dispose();
    return math.max(itemsWidth, headerWidth.ceilToDouble());
  }

  TextStyle? _brandTextStyle(BuildContext context) {
    return context.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 14.5,
      letterSpacing: 0.3,
    );
  }

  Widget _buildBackground({
    required BuildContext context,
    required bool isCollapsed,
    required double expandedWidth,
    required double leftInset,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: _sidebarAnimDuration,
      curve: _sidebarAnimCurve,
      width: (isCollapsed ? _sidebarCollapsedWidth : expandedWidth) + leftInset,
      child: ClipRect(
        child: Material(color: Colors.transparent, child: child),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required VoidCallback onToggle,
    required bool isCollapsed,
  }) {
    final dragArea = Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) {
          windowManager.startDragging();
        },
        onDoubleTap: () async {
          final isMax = await windowManager.isMaximized();
          if (isMax) {
            await windowManager.unmaximize();
          } else {
            await windowManager.maximize();
          }
        },
      ),
    );

    if (system.isMacOS) {
      return SizedBox(
        height: _headerHeight,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            dragArea,
            Padding(
              padding: const EdgeInsets.only(
                left: 80,
                right: 10,
                top: 6,
                bottom: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SidebarToggleButton(
                    onTap: onToggle,
                    isCollapsed: isCollapsed,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: _headerHeight,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (system.isDesktop) dragArea,
          Padding(
            padding: EdgeInsets.only(
              left: 14,
              right: system.isDesktop ? 10 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: _sidebarAnimDuration,
                  curve: _sidebarAnimCurve,
                  alignment: Alignment.centerLeft,
                  child: isCollapsed && !system.isDesktop
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            AppIdentity.productName,
                            maxLines: 1,
                            softWrap: false,
                            style: _brandTextStyle(context),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: _SidebarToggleButton(
                    onTap: onToggle,
                    isCollapsed: isCollapsed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appSettingProvider.select((s) => s.locale));
    final (navigationItems, isMobileView, currentIndex) = ref.watch(
      navigationStateProvider.select(
        (state) => (
          state.navigationItems,
          state.viewMode == ViewMode.mobile,
          state.currentIndex,
        ),
      ),
    );
    if (isMobileView) {
      return child;
    }
    final expandedWidth = _calculateExpandedWidth(context, navigationItems);
    final needSafeArea = !system.isDesktop;
    final leftInset = needSafeArea ? MediaQuery.paddingOf(context).left : 0.0;
    final isCollapsed = ref.watch(
      appSettingProvider.select((s) => s.sidebarCollapsed),
    );
    final (sidebarFlyout, sidebarFlyoutOutsideTools) = ref.watch(
      appSettingProvider.select(
        (s) => (s.sidebarFlyout, s.sidebarFlyoutOutsideTools),
      ),
    );
    void onToggle() => ref
        .read(appSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(sidebarCollapsed: !state.sidebarCollapsed),
        );
    final isLight = context.colorScheme.brightness == Brightness.light;
    final pureBlack = ref.watch(
      themeSettingProvider.select((s) => s.pureBlack),
    );
    final washColor = context.colorScheme.surfaceContainer;
    final baseColor = isLight
        ? Color.lerp(
            washColor,
            context.colorScheme.surfaceContainerLowest,
            0.85,
          )!
        : (pureBlack
              ? washColor
              : Color.lerp(
                  washColor,
                  context.colorScheme.surfaceContainerHigh,
                  0.35,
                )!);
    return _SidebarOverlay(
      child: _WashBackground(
        baseColor: baseColor,
        washColor: washColor,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Row(
                children: [
                  RepaintBoundary(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        _buildBackground(
                          context: context,
                          isCollapsed: isCollapsed,
                          expandedWidth: expandedWidth,
                          leftInset: leftInset,
                          child: SafeArea(
                            left: true,
                            top: needSafeArea,
                            right: false,
                            bottom: needSafeArea,
                            child: Column(
                              children: [
                                SizedBox(height: _headerHeight),
                                Expanded(
                                  child: ScrollConfiguration(
                                    behavior: HiddenBarScrollBehavior(),
                                    child: CallbackShortcuts(
                                      bindings: <ShortcutActivator, VoidCallback>{
                                        const SingleActivator(
                                          LogicalKeyboardKey.arrowUp,
                                        ): () {
                                          if (currentIndex > 0) {
                                            globalState.appController.toPage(
                                              navigationItems[currentIndex - 1]
                                                  .label,
                                            );
                                          }
                                        },
                                        const SingleActivator(
                                          LogicalKeyboardKey.arrowDown,
                                        ): () {
                                          if (currentIndex <
                                              navigationItems.length - 1) {
                                            globalState.appController.toPage(
                                              navigationItems[currentIndex + 1]
                                                  .label,
                                            );
                                          }
                                        },
                                        const SingleActivator(
                                          LogicalKeyboardKey.select,
                                        ): () {},
                                        const SingleActivator(
                                          LogicalKeyboardKey.enter,
                                        ): () {},
                                      },
                                      child: Focus(
                                        autofocus: true,
                                        child: ListView.separated(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 4,
                                          ),
                                          itemCount: navigationItems.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 3.5),
                                          itemBuilder: (context, index) {
                                            final item = navigationItems[index];
                                            final isSelected =
                                                currentIndex == index;
                                            final hasFlyout =
                                                sidebarFlyout &&
                                                item.label == PageLabel.tools &&
                                                !(sidebarFlyoutOutsideTools &&
                                                    isSelected);
                                            final sidebarItem = _SidebarItem(
                                              icon: item.icon,
                                              label: item.label.localizedName,
                                              isSelected: isSelected,
                                              isCollapsed: isCollapsed,
                                              hasTooltip:
                                                  !hasFlyout && !isSelected,
                                              expandedWidth: expandedWidth,
                                              onTap: () {
                                                if (currentIndex == index) {
                                                  final pageContext =
                                                      GlobalObjectKey(
                                                        item.label,
                                                      ).currentContext;
                                                  if (pageContext != null) {
                                                    Navigator.of(
                                                      pageContext,
                                                    ).popUntil(
                                                      (route) => route.isFirst,
                                                    );
                                                  }
                                                }
                                                globalState.appController
                                                    .toPage(item.label);
                                              },
                                            );
                                            if (!hasFlyout) {
                                              return sidebarItem;
                                            }
                                            return _SidebarFlyout(
                                              title: item.label.localizedName,
                                              child: sidebarItem,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        _buildLoading(
                          isCollapsed: isCollapsed,
                          needSafeArea: needSafeArea,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: RepaintBoundary(
                      child: ClipRect(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeLeft: true,
                          removeTop: system.isMacOS,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                width: expandedWidth + leftInset,
                height:
                    _headerHeight +
                    (needSafeArea ? MediaQuery.paddingOf(context).top : 0),
                child: RepaintBoundary(
                  child: SafeArea(
                    left: true,
                    top: needSafeArea,
                    right: false,
                    bottom: false,
                    child: _buildHeader(
                      context,
                      onToggle: onToggle,
                      isCollapsed: isCollapsed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final bool hasTooltip;
  final double expandedWidth;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isCollapsed = false,
    this.hasTooltip = true,
    required this.expandedWidth,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final isSelected = widget.isSelected;
    final isCollapsed = widget.isCollapsed;

    final backgroundColor = isSelected
        ? (isLight
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.primary.withValues(alpha: 0.20))
        : (_isHovering
              ? colorScheme.onSurface.withValues(alpha: isLight ? 0.05 : 0.08)
              : Colors.transparent);

    final foregroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final iconWidget = IconTheme(
      data: IconThemeData(color: foregroundColor, size: _sidebarIconSize),
      child: widget.icon,
    );

    final expandedItemWidth = widget.expandedWidth - 18.0;

    final content = AnimatedContainer(
      duration: _sidebarAnimDuration,
      curve: _sidebarAnimCurve,
      height: _sidebarItemHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_sidebarItemRadius),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.centerStart,
          minWidth: expandedItemWidth,
          maxWidth: expandedItemWidth,
          child: Row(
            children: [
              SizedBox(
                width: _sidebarItemHeight,
                height: _sidebarItemHeight,
                child: Center(child: iconWidget),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    curve: _sidebarAnimCurve,
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final itemWidget = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );

    if (isCollapsed && widget.hasTooltip) {
      return Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 150),
        positionDelegate: (context) {
          final x = context.target.dx + context.targetSize.width / 2 + 12;
          final y = (context.target.dy - context.tooltipSize.height / 2).clamp(
            8.0,
            context.overlaySize.height - context.tooltipSize.height - 8.0,
          );
          return Offset(x, y);
        },
        child: itemWidget,
      );
    }

    return itemWidget;
  }
}

class _SidebarFlyout extends ConsumerStatefulWidget {
  final String title;
  final Widget child;

  const _SidebarFlyout({required this.title, required this.child});

  @override
  ConsumerState<_SidebarFlyout> createState() => _SidebarFlyoutState();
}

class _SidebarFlyoutState extends ConsumerState<_SidebarFlyout>
    with SingleTickerProviderStateMixin {
  final _portalController = OverlayPortalController();
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 100),
  );
  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleEnter() {
    _timer?.cancel();
    if (_portalController.isShowing) {
      _animationController.forward();
      return;
    }
    final delay = ref.read(appSettingProvider).sidebarFlyoutDelay.duration;
    _timer = Timer(delay, () {
      _portalController.show();
      _animationController.forward();
    });
  }

  void _handleExit() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), _hide);
  }

  void _hide() {
    _timer?.cancel();
    _animationController.reverse().whenCompleteOrCancel(() {
      if (mounted && _animationController.isDismissed) {
        _portalController.hide();
      }
    });
  }

  void _handleOpen(ToolsShortcut shortcut) {
    _timer?.cancel();
    _animationController.value = 0;
    _portalController.hide();
    if (shortcut.builder != null) {
      globalState.appController.toPage(PageLabel.tools);
    }
    final navigatorContext = globalState.navigatorKey.currentContext;
    if (navigatorContext == null) {
      return;
    }
    shortcut.open(navigatorContext);
  }

  Widget _buildItem(BuildContext context, ToolsShortcut shortcut) {
    final colorScheme = context.colorScheme;
    final subtitle = shortcut.subtitle;
    return InkWell(
      borderRadius: BorderRadius.circular(_sidebarItemRadius),
      onTap: () => _handleOpen(shortcut),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                color: colorScheme.onSurfaceVariant,
                size: _sidebarIconSize,
              ),
              child: shortcut.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortcut.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    List<ToolsShortcut> shortcuts,
    bool pureBlack,
  ) {
    final itemBox = this.context.findRenderObject();
    final overlayBox = Overlay.of(this.context).context.findRenderObject();
    if (itemBox is! RenderBox || overlayBox is! RenderBox) {
      return const SizedBox.shrink();
    }
    final left = itemBox
        .localToGlobal(Offset(itemBox.size.width, 0), ancestor: overlayBox)
        .dx;
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final viewPadding = system.isDesktop
        ? EdgeInsets.zero
        : MediaQuery.paddingOf(context);
    return Positioned(
      left: left,
      top: viewPadding.top + _sidebarHeaderHeight,
      bottom: 0,
      child: MouseRegion(
        onEnter: (_) => _handleEnter(),
        onExit: (_) => _handleExit(),
        child: Padding(
          padding: EdgeInsets.only(left: 13, bottom: viewPadding.bottom + 8),
          child: FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.04, 0),
                end: Offset.zero,
              ).animate(_animation),
              child: Material(
                color: isLight || pureBlack
                    ? colorScheme.surfaceContainerLow
                    : colorScheme.surfaceContainerHighest,
                elevation: 6,
                shadowColor: Colors.black.withValues(
                  alpha: isLight ? 0.35 : 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(
                      alpha: isLight ? 0.6 : 0.5,
                    ),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 168,
                    maxWidth: 280,
                  ),
                  child: IntrinsicWidth(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                            child: Text(
                              widget.title,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          for (final shortcut in shortcuts)
                            _buildItem(context, shortcut),
                        ],
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

  @override
  Widget build(BuildContext context) {
    final moreItems = ref.watch(
      moreToolsSelectorStateProvider.select((state) => state.navigationItems),
    );
    final entries = ref.watch(
      appSettingProvider.select((state) => state.sidebarFlyoutEntries),
    );
    final shortcuts = getToolsShortcuts(moreItems, entries);
    final pureBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) =>
          _buildPanel(context, shortcuts, pureBlack),
      child: MouseRegion(
        onEnter: (_) => _handleEnter(),
        onExit: (_) => _handleExit(),
        child: Listener(onPointerDown: (_) => _hide(), child: widget.child),
      ),
    );
  }
}

class _WashBackground extends StatelessWidget {
  final Color baseColor;
  final Color washColor;
  final Widget child;

  const _WashBackground({
    required this.baseColor,
    required this.washColor,
    required this.child,
  });

  Decoration _wash(Alignment center, double radius) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: center,
        radius: radius,
        stops: const [0, 0.25, 0.5, 0.75, 1],
        colors: [
          for (final alpha in const [1.0, 0.8, 0.45, 0.14, 0.0])
            washColor.withValues(alpha: alpha),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (baseColor == washColor) {
      return ColoredBox(color: baseColor, child: child);
    }
    return ColoredBox(
      color: baseColor,
      child: DecoratedBox(
        decoration: _wash(const Alignment(-1, -1), 1.2),
        child: DecoratedBox(
          decoration: _wash(const Alignment(-1, 1.1), 1),
          child: child,
        ),
      ),
    );
  }
}
