import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bett_box/common/print.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// 纯 Dart 二维码解码（ZXing 的 Dart 移植）。
///
/// mobile_scanner 只实现了 Android / iOS / macOS / Web，Windows 与 Linux 上
/// `analyzeImage` 会抛 `MissingPluginException`，这些平台用本实现识别图片。
class QrReader {
  /// 解码前图片长边的上限，大图先等比缩小，避免几百 MB 的像素缓冲。
  static const int maxDecodeSide = 2000;

  const QrReader();

  String? decodeFile(String path) {
    try {
      return decodeBytes(File(path).readAsBytesSync());
    } catch (e) {
      commonPrint.log('Failed to read qr image file: $e');
      return null;
    }
  }

  String? decodeBytes(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final scaled = max(decoded.width, decoded.height) > maxDecodeSide
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? maxDecodeSide : null,
              height: decoded.height > decoded.width ? maxDecodeSide : null,
            )
          : decoded;

      final result = _decode(scaled);
      if (result != null || identical(scaled, decoded)) return result;
      // 缩放可能让小二维码丢掉细节，原图再试一次
      return _decode(decoded);
    } catch (e) {
      commonPrint.log('Failed to decode qr code: $e');
      return null;
    }
  }

  String? _decode(img.Image image) {
    final pixels = image
        .convert(numChannels: 4)
        .getBytes(order: img.ChannelOrder.abgr)
        .buffer
        .asInt32List();
    final bitmap = BinaryBitmap(
      HybridBinarizer(RGBLuminanceSource(image.width, image.height, pixels)),
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
