import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bett_box/common/print.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

class QrReader {
  static const int maxDecodeSide = 2000;

  const QrReader();

  String? decodeFile(String path) {
    try {
      return decodeBytes(File(path).readAsBytesSync());
    } catch (e) {
      commonPrint.warn('Read QR image failed: $e');
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
      return _decode(decoded);
    } catch (e) {
      commonPrint.warn('Decode QR failed: $e');
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
      return null;
    }
  }
}

final qrReader = QrReader();
