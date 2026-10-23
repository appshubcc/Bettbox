import 'dart:async';
import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/activate_box.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  final bool Function(String value)? accept;

  const ScanPage({super.key, this.accept});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
    autoStart: false, // Disable autoStart to manually control initialization
  );

  StreamSubscription<Object?>? _subscription;
  bool _handled = false;
  bool _permissionDenied = false;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(() {
        if (!mounted) return;
        _ensureCameraStarted();
      });
    });
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_handled || barcodeCapture.barcodes.isEmpty) return;
    final rawValue = barcodeCapture.barcodes.first.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;
    _handled = true;
    final accepted =
        widget.accept?.call(rawValue) ?? rawValue.toLowerCase().isUrl;
    if (!accepted) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop<String>(context, rawValue);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription ??= controller.barcodes.listen(_handleBarcode);
        // Recheck permission when returning from settings
        _ensureCameraStarted();
        return;
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        if (controller.value.isRunning) {
          unawaited(controller.stop());
        }
        return;
    }
  }

  /// 启动相机；未授权时由 mobile_scanner 的 `start()` 发起系统授权申请。
  ///
  /// Android 的 `checkSelfPermission` 只能区分「已授权 / 未授权」：未授权既可能是
  /// 尚未申请，也可能是用户拒绝过。若据此提前判定为「权限被拒绝」，系统授权框就
  /// 永远不会弹出（「每次使用时询问」下必现），因此是否被拒只以 `start()` 的结果
  /// 为准。
  Future<void> _ensureCameraStarted() async {
    if (_starting) return; // 授权框的弹出与收起会触发 lifecycle 重入

    _starting = true;
    try {
      if (_permissionDenied && !await app.hasCameraPermission()) {
        // 处于拒绝视图：用户可能刚在系统设置里打开权限，没打开就保持现状，
        // 不再重复弹框。
        return;
      }
      if (!controller.value.isRunning) {
        await controller.start();
      }
      if (!mounted) return;
      final denied =
          controller.value.error?.errorCode ==
          MobileScannerErrorCode.permissionDenied;
      if (denied != _permissionDenied) {
        setState(() {
          _permissionDenied = denied;
        });
      }
    } catch (e) {
      // Handle start error silently
      commonPrint.log('Camera start error: $e');
    } finally {
      _starting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double sideLength = min(400, MediaQuery.of(context).size.width * 0.67);
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: sideLength,
      height: sideLength,
    );
    return Scaffold(
      body: Stack(
        children: [
          // scanner 始终挂载：系统授权申请由它的 start() 发起，权限被拒时由下面的
          // 拒绝视图盖住。
          Center(
            child: MobileScanner(
              controller: controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error) {
                if (error.errorCode ==
                    MobileScannerErrorCode.permissionDenied) {
                  // _ensureCameraStarted 在途时不打断它：它会在 start() 返回后统一
                  // 结算权限状态（否则刚起的相机会被这里停掉）。
                  if (!_starting && !_permissionDenied && mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _permissionDenied = true;
                      });
                    });
                    unawaited(controller.stop());
                  }
                  return _buildPermissionDeniedView(context);
                }
                return _buildErrorView(context, error);
              },
            ),
          ),
          if (_permissionDenied) _buildPermissionDeniedView(context),
          if (!_permissionDenied)
            CustomPaint(painter: ScannerOverlay(scanWindow: scanWindow)),
          AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              style: const ButtonStyle(
                iconSize: WidgetStatePropertyAll(32),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
            actions: [
              if (!_permissionDenied)
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: controller,
                  builder: (context, state, _) {
                    var icon = const Icon(Icons.flash_off);
                    var backgroundColor = Colors.black12;
                    switch (state.torchState) {
                      case TorchState.off:
                        icon = const Icon(Icons.flash_off);
                        backgroundColor = Colors.black12;
                      case TorchState.on:
                        icon = const Icon(Icons.flash_on);
                        backgroundColor = Colors.orange;
                      case TorchState.unavailable:
                        icon = const Icon(Icons.flash_off);
                        backgroundColor = Colors.transparent;
                      case TorchState.auto:
                        icon = const Icon(Icons.flash_auto);
                        backgroundColor = Colors.orange;
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ActivateBox(
                        active: state.torchState != TorchState.unavailable,
                        child: IconButton(
                          color: Colors.white,
                          icon: icon,
                          style: ButtonStyle(
                            foregroundColor: const WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              backgroundColor,
                            ),
                          ),
                          onPressed: () => controller.toggleTorch(),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          if (!_permissionDenied)
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              alignment: Alignment.bottomCenter,
              child: IconButton(
                color: Colors.white,
                style: const ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  backgroundColor: WidgetStatePropertyAll(Colors.grey),
                ),
                padding: const EdgeInsets.all(16),
                iconSize: 32.0,
                onPressed: globalState.appController.addProfileFormQrCode,
                icon: const Icon(Icons.photo_camera_back),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建权限被拒绝的视图
  Widget _buildPermissionDeniedView(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 24),
              Text(
                appLocalizations.cameraPermissionDenied,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                appLocalizations.cameraPermissionDesc,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, MobileScannerException error) {
    String errorMessage = 'Camera init failed';
    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Camera uninitialized';
        break;
      case MobileScannerErrorCode.genericError:
        errorMessage = 'Camera error';
        break;
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scan not supported';
        break;
      default:
        errorMessage = error.errorDetails?.message ?? 'Unknown error';
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(controller.dispose());
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({required this.scanWindow, this.borderRadius = 12.0});

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.opacity50
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
