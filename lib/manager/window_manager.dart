import 'dart:async';
import 'dart:ui' show ClipOp;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
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
    final revision = ++_windowGeometryRevision;
    _windowGeometryTimer?.cancel();
    _windowGeometryTimer = Timer(const Duration(milliseconds: 125), () async {
      if (!mounted || revision != _windowGeometryRevision) return;
      final isAbnormal =
          (await windowManager.isMaximized()) ||
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

      ref
          .read(windowSettingProvider.notifier)
          .updateState(
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

  ProviderSubscription<bool>? _autoLaunchSub;
  ProviderSubscription<bool>? _dockVisibleSub;

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
          if (prev == next || !next) return;
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
      commonPrint.warn('Update dock icon failed: $e', module: 'System');
    }
  }

  @override
  void dispose() {
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
        return Material(
          color: isMobileView
              ? context.colorScheme.pageColor
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
    ref
        .read(windowSettingProvider.notifier)
        .updateState((state) => state.copyWith(isPinned: newIsPinned));
  }

  Widget _buildPinButton(bool isPinned) {
    final size = system.isWindows ? kHeaderHeight : 28.0;
    final button = IconButton(
      onPressed: _updatePin,
      style: IconButton.styleFrom(
        fixedSize: Size.square(size),
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        iconSize: 16,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: AppIcon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
    );
    if (system.isWindows) return button;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: button,
    );
  }

  Widget _buildCaptionButton({
    required _CaptionGlyph glyph,
    required VoidCallback onPressed,
  }) {
    if (!system.isWindows) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(28),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            iconSize: 16,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: AppIcon(switch (glyph) {
            _CaptionGlyph.minimize => Icons.remove,
            _CaptionGlyph.maximize => Icons.crop_square,
            _CaptionGlyph.restore => Icons.filter_none,
            _CaptionGlyph.close => Icons.close,
          }, size: glyph == _CaptionGlyph.restore ? 14 : null),
        ),
      );
    }
    final colorScheme = context.colorScheme;
    final isClose = glyph == _CaptionGlyph.close;
    bool isActive(Set<WidgetState> states) =>
        isClose &&
        (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed));
    return IconButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size(46, kHeaderHeight)),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => isActive(states) ? colorScheme.error : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              isActive(states) ? colorScheme.onError : colorScheme.onSurface,
        ),
        overlayColor: isClose
            ? const WidgetStatePropertyAll(Colors.transparent)
            : null,
      ),
      icon: _CaptionIcon(glyph),
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
                      return _buildPinButton(value);
                    },
                  ),
                  _buildCaptionButton(
                    glyph: _CaptionGlyph.minimize,
                    onPressed: () {
                      windowManager.minimize();
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: isMaximizedNotifier,
                    builder: (_, value, _) {
                      return _buildCaptionButton(
                        glyph: value
                            ? _CaptionGlyph.restore
                            : _CaptionGlyph.maximize,
                        onPressed: () async {
                          unawaited(_updateMaximized());
                        },
                      );
                    },
                  ),
                  _buildCaptionButton(
                    glyph: _CaptionGlyph.close,
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      globalState.appController.unBackBlock();
                      globalState.appController.handleBackOrExit();
                    },
                  ),
                  if (!system.isWindows) const SizedBox(width: 6),
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

enum _CaptionGlyph { minimize, maximize, restore, close }

class _CaptionIcon extends StatelessWidget {
  final _CaptionGlyph glyph;

  const _CaptionIcon(this.glyph);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(10),
      painter: _CaptionGlyphPainter(
        glyph: glyph,
        color: IconTheme.of(context).color ?? context.colorScheme.onSurface,
      ),
    );
  }
}

class _CaptionGlyphPainter extends CustomPainter {
  final _CaptionGlyph glyph;
  final Color color;

  const _CaptionGlyphPainter({required this.glyph, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round;
    const corner = Radius.circular(1);
    final box = (Offset.zero & size).deflate(0.5);
    switch (glyph) {
      case _CaptionGlyph.minimize:
        final y = (size.height / 2).floorToDouble() + 0.5;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      case _CaptionGlyph.maximize:
        canvas.drawRRect(RRect.fromRectAndRadius(box, corner), paint);
      case _CaptionGlyph.restore:
        const offset = 2.0;
        final front = Rect.fromLTRB(
          box.left,
          box.top + offset,
          box.right - offset,
          box.bottom,
        );
        final back = front.shift(const Offset(offset, -offset));
        canvas.drawRRect(RRect.fromRectAndRadius(front, corner), paint);
        canvas.save();
        canvas.clipRect(front.inflate(0.5), clipOp: ClipOp.difference);
        canvas.drawRRect(RRect.fromRectAndRadius(back, corner), paint);
        canvas.restore();
      case _CaptionGlyph.close:
        paint.strokeCap = StrokeCap.round;
        canvas.drawLine(box.topLeft, box.bottomRight, paint);
        canvas.drawLine(box.topRight, box.bottomLeft, paint);
    }
  }

  @override
  bool shouldRepaint(_CaptionGlyphPainter oldDelegate) =>
      glyph != oldDelegate.glyph || color != oldDelegate.color;
}
