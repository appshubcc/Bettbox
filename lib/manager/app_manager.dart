import 'dart:async';

import 'package:bett_box/clash/core.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  late final VoidCallback _dashboardTickListener;

  static const _missedUpdateCheckDelay = Duration(seconds: 5);
  static const _missedUpdateCheckThrottle = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    final isBackgroundState =
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        (state == AppLifecycleState.inactive && !system.isDesktop);

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
        commonPrint.log('foreground core refresh skipped: $e');
      }

      detectionState.checkOnForegroundResume();
      mediaUnlockState.checkOnForegroundResume();
    }
    if (state == AppLifecycleState.resumed && system.isAndroid) {
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

final sidebarCollapsedProvider =
    StateNotifierProvider<SidebarCollapsedNotifier, bool>((ref) {
      return SidebarCollapsedNotifier();
    });

class SidebarCollapsedNotifier extends StateNotifier<bool> {
  // [Gamebox] 左侧菜单默认折叠。上游默认展开。
  SidebarCollapsedNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    state = prefs?.getBool(sidebarCollapsedKey) ?? true;
  }

  Future<void> toggle() async {
    final next = !state;
    state = next;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setBool(sidebarCollapsedKey, next);
  }

  Future<void> setCollapsed(bool value) async {
    state = value;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setBool(sidebarCollapsedKey, value);
  }
}

const _sidebarAnimDuration = Duration(milliseconds: 200);
const _sidebarAnimCurve = Curves.easeOutCubic;

class _SidebarToggleButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isCollapsed;

  const _SidebarToggleButton({
    required this.onTap,
    this.isCollapsed = false,
  });

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
              tween: Tween<double>(
                end: widget.isCollapsed ? 1.0 : 0.0,
              ),
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
        painter: _SidebarIconPainter(
          color: color,
          progress: progress,
        ),
      ),
    );
  }
}

class _SidebarIconPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _SidebarIconPainter({
    required this.color,
    this.progress = 0.0,
  });

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

  double get _headerHeight => 46.0;

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

  Widget _buildBackground({
    required BuildContext context,
    required bool isCollapsed,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: _sidebarAnimDuration,
      curve: _sidebarAnimCurve,
      width: isCollapsed ? 56 : 152,
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
                top: 7,
                bottom: 11,
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
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppIdentity.productName,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
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
    final needSafeArea = !system.isDesktop;
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final onToggle = ref.read(sidebarCollapsedProvider.notifier).toggle;
    final isLight = context.colorScheme.brightness == Brightness.light;
    final pureBlack = ref.watch(
      themeSettingProvider.select((s) => s.pureBlack),
    );
    final bgGradient = LinearGradient(
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.4),
      colors: isLight
          ? [
              context.colorScheme.surfaceContainer,
              Color.lerp(
                context.colorScheme.surfaceContainer,
                context.colorScheme.surfaceContainerLowest,
                0.85,
              )!,
            ]
          : (!pureBlack
                ? [
                    context.colorScheme.surfaceContainer,
                    Color.lerp(
                      context.colorScheme.surfaceContainer,
                      context.colorScheme.surfaceContainerHigh,
                      0.35,
                    )!,
                  ]
                : [
                    context.colorScheme.surfaceContainer,
                    context.colorScheme.surfaceContainer,
                  ]),
    );
    return _SidebarOverlay(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: bgGradient),
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
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          itemCount: navigationItems.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 3),
                                          itemBuilder: (context, index) {
                                            final item = navigationItems[index];
                                            final isSelected =
                                              currentIndex == index;
                                            return _SidebarItem(
                                              icon: item.icon,
                                              label: item.label.localizedName,
                                              isSelected: isSelected,
                                              isCollapsed: isCollapsed,
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
                width: 152,
                height: _headerHeight +
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
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isCollapsed = false,
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
      data: IconThemeData(color: foregroundColor, size: 19),
      child: widget.icon,
    );

    final content = AnimatedContainer(
      duration: _sidebarAnimDuration,
      curve: _sidebarAnimCurve,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(width: 36, height: 36, child: Center(child: iconWidget)),
          Expanded(
            child: ClipRect(
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
                    overflow: TextOverflow.fade,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

    if (isCollapsed) {
      return Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 350),
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
