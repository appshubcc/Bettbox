import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/common/picker.dart';
import 'package:bett_box/common/qr_reader.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// 生成一张二维码图片，[scale] 为每个模块的像素边长，[margin] 为四周留白模块数。
Uint8List encodeQrImage(String content, {int scale = 6, int margin = 4}) {
  final matrix = Encoder.encode(content, ErrorCorrectionLevel.m).matrix!;
  final image = img.Image(
    width: (matrix.width + margin * 2) * scale,
    height: (matrix.height + margin * 2) * scale,
    numChannels: 4,
  );
  img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));
  for (var x = 0; x < matrix.width; x++) {
    for (var y = 0; y < matrix.height; y++) {
      if (matrix.get(x, y) == 1) {
        img.fillRect(
          image,
          x1: (x + margin) * scale,
          y1: (y + margin) * scale,
          x2: (x + margin + 1) * scale - 1,
          y2: (y + margin + 1) * scale - 1,
          color: img.ColorRgba8(0, 0, 0, 255),
        );
      }
    }
  }
  return img.encodePng(image);
}

/// 仿照用户实际提交的截图：页面底色 + 白色圆角卡片 + 卡片里的二维码。
Uint8List encodeQrScreenshot(String content, {int side = 525, int height = 624}) {
  final page = img.Image(width: side, height: height, numChannels: 4);
  img.fill(page, color: img.ColorRgba8(0xF2, 0xF2, 0xF2, 0xFF));
  final qrSide = (side * 0.78).round();
  img.compositeImage(
    page,
    img.decodeImage(encodeQrImage(content, scale: 8))!,
    dstX: (side - qrSide) ~/ 2,
    dstY: (height - qrSide) ~/ 2,
    dstW: qrSide,
    dstH: qrSide,
  );
  return img.encodePng(page);
}

String writeTempImage(Uint8List bytes, String name) {
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}$name',
  );
  file.writeAsBytesSync(bytes);
  return file.path;
}

void main() {
  group('二维码图片解码（纯 Dart 实现）', () {
    test('截图里的二维码（页面底色 + 卡片留白）可解码', () {
      final path = writeTempImage(
        encodeQrScreenshot('https://example.com/subscribe?token=abc123'),
        'bettbox_qr_screenshot.png',
      );
      expect(
        qrReader.decodeFile(path),
        'https://example.com/subscribe?token=abc123',
      );
    });

    test('生成的二维码图片可解码', () {
      final bytes = encodeQrImage('https://example.com/api/v1/subscribe');
      expect(
        qrReader.decodeBytes(bytes),
        'https://example.com/api/v1/subscribe',
      );
    });

    test('非 URL 内容原样返回（URL 校验由调用方负责）', () {
      final bytes = encodeQrImage('WIFI:S:MyWiFi;T:WPA;P:12345678;;');
      expect(qrReader.decodeBytes(bytes), 'WIFI:S:MyWiFi;T:WPA;P:12345678;;');
    });

    test('超过长边上限的大图会先缩放再解码', () {
      final matrix = Encoder.encode(
        'https://example.com/big',
        ErrorCorrectionLevel.m,
      ).matrix!;
      // 按模块边长放大到超过 QrReader.maxDecodeSide
      final scale = (QrReader.maxDecodeSide + 600) ~/ (matrix.width + 8);
      final bytes = encodeQrImage(
        'https://example.com/big',
        scale: scale,
        margin: 4,
      );
      expect(
        img.decodeImage(bytes)!.width,
        greaterThan(QrReader.maxDecodeSide),
      );
      expect(qrReader.decodeBytes(bytes), 'https://example.com/big');
    });

    test('大图里的小二维码也能解码', () {
      // 3000 宽的画布上放一个模块仅 2px 的小二维码：缩到 2000 会丢掉细节，
      // 需要回退到原图再解一次
      final qr = img.decodeImage(
        encodeQrImage('https://example.com/small', scale: 2),
      )!;
      final page = img.Image(width: 3000, height: 2400, numChannels: 4);
      img.fill(page, color: img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF));
      img.compositeImage(page, qr, dstX: 1400, dstY: 1100);
      final bytes = img.encodePng(page);
      expect(img.decodeImage(bytes)!.width, 3000);
      expect(qrReader.decodeBytes(bytes), 'https://example.com/small');
    });

    test('没有二维码的图片返回 null', () {
      final blank = img.Image(width: 300, height: 300, numChannels: 4);
      img.fill(blank, color: img.ColorRgba8(255, 255, 255, 255));
      expect(qrReader.decodeBytes(img.encodePng(blank)), isNull);
    });

    test('文件不存在或不是图片时返回 null', () {
      expect(qrReader.decodeFile('test/fixtures/not_exists.png'), isNull);
      expect(qrReader.decodeBytes(Uint8List.fromList(List.filled(16, 0))), isNull);
    });
  });

  group('导入二维码图片（picker 入口）', () {
    setUpAll(() async {
      await AppLocalizations.load(const Locale('zh', 'CN'));
    });

    test('扫码导入拿到的 URL 就是二维码内容', () async {
      final path = writeTempImage(
        encodeQrScreenshot('https://example.com/subscribe?token=abc123'),
        'bettbox_qr_import.png',
      );
      expect(
        await picker.decodeProfileUrlFromQrImage(path),
        'https://example.com/subscribe?token=abc123',
      );
    });

    test('非 URL 的二维码提示「请上传有效的二维码」', () async {
      final path = writeTempImage(
        encodeQrImage('hello world'),
        'bettbox_qr_not_url.png',
      );
      await expectLater(
        picker.decodeProfileUrlFromQrImage(path),
        throwsA(
          predicate<String>((e) => e.contains('二维码'), '二维码提示文案'),
        ),
      );
    });

    test('图片里没有二维码时提示「请上传有效的二维码」', () async {
      final blank = img.Image(width: 300, height: 300, numChannels: 4);
      img.fill(blank, color: img.ColorRgba8(255, 255, 255, 255));
      final path = writeTempImage(
        img.encodePng(blank),
        'bettbox_qr_blank.png',
      );
      await expectLater(
        picker.decodeProfileUrlFromQrImage(path),
        throwsA(
          predicate<String>((e) => e.contains('二维码'), '二维码提示文案'),
        ),
      );
    });
  });
}
