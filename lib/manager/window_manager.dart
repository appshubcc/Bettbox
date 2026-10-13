import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_ext/window_ext.dart';
import 'package:window_manager/window_manager.dart';

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({super.key, required this.child});

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener, WindowExtListener {
  Timer? _renderToggleTimer;
  bool? _pendingRenderResume;
  Timer? _windowGeometryTimer;
  int _windowGeometryRevision = 0;

  void _scheduleRenderToggle(bool resume) {
    _pendingRenderResume = resume;
    _renderToggleTimer?.cancel();
    _renderToggleTimer = Timer(const Duration(milliseconds: 500), () {
      if (_pendingRenderResume == true) {
        render?.resume();
      } else {
        render?.pause();
      }
    });
  }

  void _scheduleWindowGeometryCapture() {
    // [Gamebox] 登录小窗的尺寸不要写进主窗口配置。
    if (!globalState.panelUnlocked.value) return;
    final revision = ++_windowGeometryRevision;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = Timer(const Duration(milliseconds: 125), () async {
      if (!mounted || revision != _windowGeometryRevision) return;
      if (!globalState.panelUnlocked.value) return;
      final isAbnormal = (await windowManager.isMaximized()) ||
          (await windowManager.isFullScreen()) ||
          (await windowManager.isMinimized());
      if (isAbnormal) return;

      final bounds = await windowManager.getBounds();
      if (!bounds.width.isFinite ||
          !bounds.height.isFinite ||
          bounds.width <= 0 ||
          bounds.height <= 0) {
        return;
      }
      if (!bounds.left.isFinite || !bounds.top.isFinite) return;

      ref.read(windowSettingProvider.notifier).updateState(
            (state) => state.copyWith(
              width: bounds.width,
              height: bounds.height,
              left: bounds.left,
              top: bounds.top,
              scaleFactor: windowManager.getDevicePixelRatio(),
            ),
          );
    });
  }

  void _invalidateWindowGeometryCapture() {
    _windowGeometryRevision++;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  ProviderSubscription? _autoLaunchSub;
  ProviderSubscription? _dockVisibleSub;

  @override
  void initState() {
    super.initState();
    _autoLaunchSub = ref.listenManual(
      appSettingProvider.select((state) => state.autoLaunch),
      (prev, next) {
        if (prev != next) {
          debouncer.call(FunctionTag.autoLaunch, () {
            autoLaunch?.updateStatus(next);
          });
        }
      },
    );
    windowExtManager.addListener(this);
    windowManager.addListener(this);
    if (system.isMacOS) {
      _dockVisibleSub = ref.listenManual(
        appSettingProvider.select((state) => state.keepDockIcon),
        (prev, next) {
          if (prev == next) return;
          unawaited(_updateDockIcon(next));
        },
      );
    }
  }

  @override
  void onWindowClose() async {
    globalState.appController.unBackBlock();
    await globalState.appController.handleBackOrExit();
  }

  @override
  Future<void> onShouldTerminate() async {
    await globalState.appController.handleExit();
    super.onShouldTerminate();
  }

  @override
  void onWindowMove() {
    super.onWindowMove();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMoved() {
    super.onWindowMoved();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowResize() {
    super.onWindowResize();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMaximize() {
    _invalidateWindowGeometryCapture();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowEnterFullScreen() {
    _invalidateWindowGeometryCapture();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _scheduleWindowGeometryCapture();
  }

  @override
  void onWindowMinimize() async {
    globalState.appController.savePreferencesDebounce();
    _renderToggleTimer?.cancel();
    await globalState.handleBackground();
    super.onWindowMinimize();
  }

  @override
  void onWindowFocus() {
    if (globalState.backgroundMode.value) {
      globalState.handleForeground();
      _scheduleRenderToggle(true);
      unawaited(globalState.resumeForegroundUpdates());
      unawaited(globalState.appController.syncWakelockIfNeeded());
    }
    super.onWindowFocus();
  }

  @override
  void onWindowRestore() {
    globalState.handleForeground();
    _scheduleRenderToggle(true);
    unawaited(globalState.resumeForegroundUpdates());
    unawaited(globalState.appController.syncWakelockIfNeeded());
    super.onWindowRestore();
  }

  @override
  void onTaskbarCreated() {
    globalState.appController.updateTray(true);
    super.onTaskbarCreated();
  }

  Future<void> _updateDockIcon(bool visible) async {
    try {
      await windowExtManager.setDockIconVisible(visible);
    } catch (e) {
      commonPrint.log('Update dock icon visibility failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _autoLaunchSub?.close();
    _dockVisibleSub?.close();
    windowManager.removeListener(this);
    windowExtManager.removeListener(this);
    _renderToggleTimer?.cancel();
    _windowGeometryTimer?.cancel();
    super.dispose();
  }
}

class WindowHeaderContainer extends StatelessWidget {
  final Widget child;

  const WindowHeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final isMobileView = ref.watch(isMobileViewProvider);
        if (isMobileView) {
          return child!;
        }
        return Material(
          color: isMobileView
              ? context.colorScheme.surfaceContainer
              : Colors.transparent,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: kHeaderHeight),
                  Expanded(flex: 1, child: child!),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: kHeaderHeight,
                child: const WindowHeader(),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}

class WindowHeader extends ConsumerStatefulWidget {
  const WindowHeader({super.key});

  @override
  ConsumerState<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends ConsumerState<WindowHeader> {
  final isMaximizedNotifier = ValueNotifier<bool>(false);
  final isPinNotifier = ValueNotifier<bool>(false);
  final isHoveringNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initNotifier();
  }

  Future<void> _initNotifier() async {
    final isMaximized = await windowManager.isMaximized();
    if (!mounted) return;
    isMaximizedNotifier.value = isMaximized;
    
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    if (!mounted) return;
    isPinNotifier.value = isAlwaysOnTop;
  }

  @override
  void dispose() {
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
    isHoveringNotifier.dispose();
    super.dispose();
  }

  Future<void> _updateMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    switch (isMaximized) {
      case true:
        await windowManager.unmaximize();
        break;
      case false:
        await windowManager.maximize();
        break;
    }
    isMaximizedNotifier.value = await windowManager.isMaximized();
  }

  Future<void> _updatePin() async {
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    final newIsPinned = !isAlwaysOnTop;
    await windowManager.setAlwaysOnTop(newIsPinned);
    isPinNotifier.value = newIsPinned;
    ref.read(windowSettingProvider.notifier).updateState(
          (state) => state.copyWith(isPinned: newIsPinned),
        );
  }

  Widget _buildActions() {
    if (system.isMacOS) {
      return const SizedBox.shrink();
    }
    final shouldUseHoverEffect = system.isWindows || system.isLinux;
    final alwaysShowTitleBar = ref.watch(
      vpnSettingProvider.select((state) => state.alwaysShowTitleBar),
    );

    return MouseRegion(
      onEnter: shouldUseHoverEffect
          ? (_) => isHoveringNotifier.value = true
          : null,
      onExit: shouldUseHoverEffect
          ? (_) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  isHoveringNotifier.value = false;
                }
              });
            }
          : null,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHoveringNotifier,
        builder: (_, isHovering, _) {
          final showButtons =
              !shouldUseHoverEffect || alwaysShowTitleBar || isHovering;
          return Opacity(
            opacity: showButtons ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !showButtons,
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: isPinNotifier,
                    builder: (_, value, _) {
                      return IconButton(
                        onPressed: _updatePin,
                        icon: value
                            ? const Icon(Icons.push_pin)
                            : const Icon(Icons.push_pin_outlined),
                      );
                    },
                  ),
                  if (!system.isMacOS) ...[
                    IconButton(
                      onPressed: () {
                        windowManager.minimize();
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    // [Gamebox] 登录小窗不需要最大化，按钮先藏起来。
                    ValueListenableBuilder<bool>(
                      valueListenable: globalState.panelUnlocked,
                      builder: (_, unlocked, _) {
                        if (!unlocked) return const SizedBox.shrink();
                        return ValueListenableBuilder(
                          valueListenable: isMaximizedNotifier,
                          builder: (_, value, _) {
                            return IconButton(
                              onPressed: () async {
                                _updateMaximized();
                              },
                              icon: value
                                  ? const Icon(Icons.filter_none, size: 20)
                                  : const Icon(Icons.crop_square),
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        globalState.appController.unBackBlock();
                        globalState.appController.handleBackOrExit();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kHeaderHeight,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) {
                  windowManager.startDragging();
                },
                onDoubleTap: () {
                  if (!globalState.panelUnlocked.value) return;
                  _updateMaximized();
                },
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: RepaintBoundary(child: _buildActions()),
            ),
          ],
        ),
      ),
    );
  }
}

final sidebarIconPathProvider =
    StateNotifierProvider<SidebarIconPathNotifier, String?>((ref) {
      return SidebarIconPathNotifier();
    });

class SidebarIconPathNotifier extends StateNotifier<String?> {
  SidebarIconPathNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    state = prefs?.getString(customSidebarIconKey);
  }

  Future<void> updatePath(String? path) async {
    state = path;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    if (path == null) {
      prefs?.remove(customSidebarIconKey);
    } else {
      prefs?.setString(customSidebarIconKey, path);
    }
  }
}

class AppIcon extends ConsumerWidget {
  final double size;

  const AppIcon({super.key, this.size = 26});

  Future<void> _handlePickImage(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);
      final size = await file.length();
      if (size > 1024 * 1024) {
        if (context.mounted) {
          globalState.showNotifier('Image size exceeds 1MB');
        }
        return;
      }
      ref.read(sidebarIconPathProvider.notifier).updatePath(path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customIconPath = ref.watch(sidebarIconPathProvider);

    Widget icon;
    if (customIconPath != null && customIconPath.isNotEmpty) {
      icon = ClipOval(
        child: Image.file(
          File(customIconPath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: (size * 2).toInt(),
          cacheHeight: (size * 2).toInt(),
          errorBuilder: (_, _, _) {
            // Fallback if file load fails
            return Image.asset(
              isDark
                  ? 'assets/images/icon.png'
                  : 'assets/images/icon_light.png',
              fit: BoxFit.contain,
            );
          },
        ),
      );
    } else {
      icon = Image.asset(
        isDark ? 'assets/images/icon.png' : 'assets/images/icon_light.png',
        fit: BoxFit.contain,
      );
    }

    return GestureDetector(
      onLongPress: () => _handlePickImage(context, ref),
      child: SizedBox(width: size, height: size, child: icon),
    );
  }
}
