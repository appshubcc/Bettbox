import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bett_box/common/print.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// 二维码解码。
///
/// mobile_scanner 只实现了 Android / iOS / macOS / Web，Windows 与 Linux 上
/// `analyzeImage` 会抛 `MissingPluginException`，这两个平台用本实现识别图片。
///
/// 首选 Flutter 引擎自带的图片解码器（`dart:ui`）：它按目标尺寸采样解码、在引擎的
/// 工作线程上跑，比纯 Dart 快好几倍（实测 12MP 照片 97ms 对 636ms），也不占 isolate。
/// 引擎解不了的格式（TIFF 等）或引擎报错时，退回纯 Dart 解码（`image` + `zxing2`）。
class QrReader {
  /// 解码前图片长边的上限：大图按这个尺寸解码，避免几百 MB 的像素缓冲。
  static const int maxDecodeSide = 2000;

  /// 是否优先用引擎解码。关掉后只走纯 Dart，测试用来比对两条路的识别结果。
  final bool useEngineCodec;

  const QrReader({this.useEngineCodec = true});

  /// 解码文件里的二维码，失败返回 null。
  Future<String?> decodeFile(String path) async {
    final Uint8List bytes;
    try {
      // 异步读盘走 dart:io 的线程池，不占 isolate
      bytes = await File(path).readAsBytes();
    } catch (e) {
      commonPrint.log('Failed to read qr image file: $e');
      return null;
    }
    return decodeBytes(bytes);
  }

  /// 解码字节里的二维码，失败返回 null。
  Future<String?> decodeBytes(Uint8List bytes) async {
    if (useEngineCodec) {
      try {
        return await _decodeWithEngine(bytes);
      } catch (e) {
        // 引擎认不出这个文件（格式不支持 / 文件损坏），换纯 Dart 再试
        commonPrint.log('Engine qr decode failed: $e');
      }
    }
    return _decodeWithDart(bytes);
  }

  /// 引擎解码：先把长边缩到 [maxDecodeSide]，缩完没解出再拿原图试一次。
  static Future<String?> _decodeWithEngine(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      final downscaled =
          max(descriptor.width, descriptor.height) > maxDecodeSide;
      final result = await _decodeFrame(
        descriptor,
        width: downscaled && descriptor.width >= descriptor.height
            ? maxDecodeSide
            : null,
        height: downscaled && descriptor.height > descriptor.width
            ? maxDecodeSide
            : null,
      );
      if (result != null || !downscaled) return result;
      // 缩放可能让小二维码丢掉细节，原图再试一次（引擎全尺寸解码仍比纯 Dart 快 3~4 倍）
      return await _decodeFrame(descriptor);
    } finally {
      descriptor.dispose();
      buffer.dispose();
    }
  }

  /// 按给定目标尺寸解一帧，回读成 RGBA 后交给后台 isolate 识别。
  static Future<String?> _decodeFrame(
    ui.ImageDescriptor descriptor, {
    int? width,
    int? height,
  }) async {
    final codec = await descriptor.instantiateCodec(
      targetWidth: width,
      targetHeight: height,
    );
    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (data == null) return null;
        return await _zxingInIsolate(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          image.width,
          image.height,
        );
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  /// `image` 解码 + `zxing2` 识别，整个在后台 isolate 里跑（12MP 照片 0.6~0.8s）。
  ///
  /// 失败原因带回主 isolate 再写日志：后台 isolate 里 `commonPrint` 依赖的
  /// `globalState` 是另一份未初始化的单例，直接在那里写日志会丢掉这条记录。
  static Future<String?> _decodeWithDart(Uint8List bytes) async {
    final (text, error) = await Isolate.run(() => _decodeBytes(bytes));
    if (error != null) {
      commonPrint.log(error);
    }
    return text;
  }

  static (String?, String?) _decodeBytes(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return (null, null);
      if (max(decoded.width, decoded.height) <= maxDecodeSide) {
        return (_decodeImage(decoded), null);
      }
      final scaled = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maxDecodeSide : null,
        height: decoded.height > decoded.width ? maxDecodeSide : null,
      );
      final result = _decodeImage(scaled);
      if (result != null) return (result, null);
      // 缩放可能让小二维码丢掉细节，原图再试一次
      return (_decodeImage(decoded), null);
    } catch (e) {
      return (null, 'Failed to decode qr code: $e');
    }
  }

  static String? _decodeImage(img.Image image) {
    // getBytes(order: rgba) 会顺带把灰度 / 调色板 / 3 通道的图补成 4 通道
    return _zxing(
      image.getBytes(order: img.ChannelOrder.rgba),
      image.width,
      image.height,
    );
  }

  /// 亮度 + 二值化 + 识别都是纯 CPU 活，放后台 isolate（普通拷贝 ~3ms/12MB 就够快）。
  static Future<String?> _zxingInIsolate(
    Uint8List rgba,
    int width,
    int height,
  ) {
    return Isolate.run(() => _zxing(rgba, width, height));
  }

  /// 把 RGBA 像素交给 zxing2 识别。
  ///
  /// `RGBLuminanceSource` 要的是 0x00RRGGBB 的 int 数组（红在 bit16-23、绿在 bit8-15、
  /// 蓝在 bit0-7），亮度由它自己按 `(r + 2g + b) / 4` 算出来。
  static String? _zxing(Uint8List rgba, int width, int height) {
    final pixels = Int32List(width * height);
    for (var i = 0, p = 0; p < pixels.length; i += 4, p++) {
      pixels[p] = (rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2];
    }
    final bitmap = BinaryBitmap(
      HybridBinarizer(RGBLuminanceSource(width, height, pixels)),
    );
    try {
      final text = QRCodeReader().decode(bitmap).text.trim();
      return text.isEmpty ? null : text;
    } on ReaderException {
      // 图片里没有可识别的二维码
      return null;
    }
  }
}

final qrReader = QrReader();
