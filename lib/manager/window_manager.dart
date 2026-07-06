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

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  ProviderSubscription? _autoLaunchSub;

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
  Future<void> onWindowMoved() async {
    super.onWindowMoved();
    final offset = await windowManager.getPosition();
    ref
        .read(windowSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(top: offset.dy, left: offset.dx),
        );
  }

  @override
  Future<void> onWindowResized() async {
    super.onWindowResized();
    final size = await windowManager.getSize();
    ref
        .read(windowSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(width: size.width, height: size.height),
        );
  }

  @override
  void onWindowMinimize() async {
    globalState.appController.savePreferencesDebounce();
    _renderToggleTimer?.cancel();
    await globalState.handleBackground();
    super.onWindowMinimize();
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

  @override
  Future<void> dispose() async {
    _autoLaunchSub?.close();
    windowManager.removeListener(this);
    windowExtManager.removeListener(this);
    _renderToggleTimer?.cancel();
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
        final version = ref.watch(versionProvider);
        if ((version <= 10 || !isMobileView) && system.isMacOS) {
          return child!;
        }
        return Stack(
          children: [
            Column(
              children: [
                SizedBox(height: kHeaderHeight),
                Expanded(flex: 1, child: child!),
              ],
            ),
            const WindowHeader(),
          ],
        );
      },
      child: child,
    );
  }
}

class WindowHeader extends StatefulWidget {
  const WindowHeader({super.key});

  @override
  State<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends State<WindowHeader> {
  final isMaximizedNotifier = ValueNotifier<bool>(false);
  final isPinNotifier = ValueNotifier<bool>(false);
  final isHoveringNotifier = ValueNotifier<bool>(false); // 新增：鼠标悬停状态

  @override
  void initState() {
    super.initState();
    _initNotifier();
  }

  Future<void> _initNotifier() async {
    isMaximizedNotifier.value = await windowManager.isMaximized();
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  @override
  void dispose() {
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
    isHoveringNotifier.dispose(); // 新增：释放资源
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
    await windowManager.setAlwaysOnTop(!isAlwaysOnTop);
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  Widget _buildActions() {
    final shouldUseHoverEffect = system.isWindows || system.isLinux;

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
          return Consumer(
            builder: (context, ref, child) {
              final alwaysShowTitleBar = ref.watch(
                vpnSettingProvider.select((state) => state.alwaysShowTitleBar),
              );
              final showButtons =
                  !shouldUseHoverEffect || alwaysShowTitleBar || isHovering;
              return Opacity(
                opacity: showButtons ? 1.0 : 0.0,
                child: IgnorePointer(ignoring: !showButtons, child: child),
              );
            },
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    _updatePin();
                  },
                  icon: ValueListenableBuilder(
                    valueListenable: isPinNotifier,
                    builder: (_, value, _) {
                      return value
                          ? const Icon(Icons.push_pin)
                          : const Icon(Icons.push_pin_outlined);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    windowManager.minimize();
                  },
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () async {
                    _updateMaximized();
                  },
                  icon: ValueListenableBuilder(
                    valueListenable: isMaximizedNotifier,
                    builder: (_, value, _) {
                      return value
                          ? const Icon(Icons.filter_none, size: 20)
                          : const Icon(Icons.crop_square);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    globalState.appController.unBackBlock();
                    isHoveringNotifier.value = true;
                    globalState.appController.handleBackOrExit();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            child: GestureDetector(
              onPanStart: (_) {
                windowManager.startDragging();
              },
              onDoubleTap: () {
                _updateMaximized();
              },
              child: Container(
                color: context.colorScheme.secondary.opacity15,
                alignment: Alignment.centerLeft,
                height: kHeaderHeight,
              ),
            ),
          ),
          if (system.isMacOS)
            const Text(appName)
          else ...[
            Positioned(right: 0, child: _buildActions()),
          ],
        ],
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
  const AppIcon({super.key});

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
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          cacheWidth: 64,
          cacheHeight: 64,
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
      child: SizedBox(width: 40, height: 40, child: icon),
    );
  }
}
