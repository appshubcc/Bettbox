import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/common/picker.dart';
import 'package:bett_box/common/qr_reader.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

const sampleUrl = 'https://example.com/subscribe?token=abc123';

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
Uint8List encodeQrScreenshot(
  String content, {
  int side = 525,
  int height = 624,
}) {
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

/// 长边超过 [QrReader.maxDecodeSide] 的二维码图（会走"先缩放"那条路）。
Uint8List encodeBigQrImage(String content) {
  final matrix = Encoder.encode(content, ErrorCorrectionLevel.m).matrix!;
  final scale = (QrReader.maxDecodeSide + 600) ~/ (matrix.width + 8);
  return encodeQrImage(content, scale: scale);
}

/// 大画布上放一个小二维码：缩到 [QrReader.maxDecodeSide] 会丢掉细节，
/// 需要回退到原图再解一次。
Uint8List encodeSmallQrOnCanvas(String content) {
  final page = img.Image(width: 3000, height: 2400, numChannels: 4);
  img.fill(page, color: img.ColorRgba8(255, 255, 255, 255));
  img.compositeImage(
    page,
    img.decodeImage(encodeQrImage(content, scale: 2))!,
    dstX: 1400,
    dstY: 1100,
  );
  return img.encodePng(page);
}

Uint8List encodeBlankImage() {
  final blank = img.Image(width: 300, height: 300, numChannels: 4);
  img.fill(blank, color: img.ColorRgba8(255, 255, 255, 255));
  return img.encodePng(blank);
}

String writeTempImage(Uint8List bytes, String name) {
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}$name',
  );
  file.writeAsBytesSync(bytes);
  return file.path;
}

/// 全部夹具：正常图 / 截图 / 超大图 / 大图里的小码 / 无码 / 坏文件
Map<String, Uint8List> fixtures() => {
  '生成图': encodeQrImage(sampleUrl),
  '截图': encodeQrScreenshot(sampleUrl),
  '超过长边上限的大图': encodeBigQrImage('https://example.com/big'),
  '大图里的小二维码': encodeSmallQrOnCanvas('https://example.com/small'),
  '没有二维码的图片': encodeBlankImage(),
  '坏文件': Uint8List.fromList(List.filled(16, 0)),
};

void main() {
  group('二维码图片解码（引擎解码器）', () {
    test('截图里的二维码（页面底色 + 卡片留白）可解码', () async {
      final path = writeTempImage(
        encodeQrScreenshot(sampleUrl),
        'bettbox_qr_screenshot.png',
      );
      expect(await qrReader.decodeFile(path), sampleUrl);
    });

    test('生成的二维码图片可解码', () async {
      expect(
        await qrReader.decodeBytes(
          encodeQrImage('https://example.com/api/v1/subscribe'),
        ),
        'https://example.com/api/v1/subscribe',
      );
    });

    test('非 URL 内容原样返回（URL 校验由调用方负责）', () async {
      final bytes = encodeQrImage('WIFI:S:MyWiFi;T:WPA;P:12345678;;');
      expect(
        await qrReader.decodeBytes(bytes),
        'WIFI:S:MyWiFi;T:WPA;P:12345678;;',
      );
    });

    test('超过长边上限的大图可解码', () async {
      final bytes = encodeBigQrImage('https://example.com/big');
      expect(
        img.decodeImage(bytes)!.width,
        greaterThan(QrReader.maxDecodeSide),
      );
      expect(await qrReader.decodeBytes(bytes), 'https://example.com/big');
    });

    test('大图里的小二维码也能解码（缩完没解出会退回原图）', () async {
      final bytes = encodeSmallQrOnCanvas('https://example.com/small');
      expect(img.decodeImage(bytes)!.width, 3000);
      expect(await qrReader.decodeBytes(bytes), 'https://example.com/small');
    });

    test('没有二维码的图片返回 null', () async {
      expect(await qrReader.decodeBytes(encodeBlankImage()), isNull);
    });

    test('文件不存在或不是图片时返回 null', () async {
      expect(await qrReader.decodeFile('test/fixtures/not_exists.png'), isNull);
      expect(
        await qrReader.decodeBytes(Uint8List.fromList(List.filled(16, 0))),
        isNull,
      );
    });
  });

  group('纯 Dart 兜底（引擎解不了的格式走这条）', () {
    const dartOnly = QrReader(useEngineCodec: false);

    test('引擎与纯 Dart 两条路的识别结果一致', () async {
      for (final entry in fixtures().entries) {
        expect(
          await qrReader.decodeBytes(entry.value),
          await dartOnly.decodeBytes(entry.value),
          reason: entry.key,
        );
      }
    });

    test('灰度与调色板图也能解码', () async {
      final decoded = img.decodeImage(encodeQrImage(sampleUrl))!;
      final cases = {
        '灰度': img.encodePng(decoded.convert(numChannels: 1)),
        '调色板': img.encodePng(img.quantize(decoded)),
      };
      for (final entry in cases.entries) {
        expect(
          await qrReader.decodeBytes(entry.value),
          sampleUrl,
          reason: entry.key,
        );
        expect(
          await dartOnly.decodeBytes(entry.value),
          sampleUrl,
          reason: entry.key,
        );
      }
    });

    test('引擎解不了的文件会退回纯 Dart，而不是直接失败', () async {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
      };
      try {
        final bytes = Uint8List.fromList(List.filled(16, 0));
        // 引擎对这个文件抛错 → 兜底接手 → 纯 Dart 也解不出 → null
        expect(await qrReader.decodeBytes(bytes), isNull);
        expect(
          logs.any((log) => log.contains('Engine qr decode failed')),
          isTrue,
          reason: '引擎报错后应落到兜底路径',
        );
      } finally {
        debugPrint = original;
      }
    });
  });

  group('导入二维码图片（picker 入口）', () {
    setUpAll(() async {
      await AppLocalizations.load(const Locale('zh', 'CN'));
    });

    test('扫码导入拿到的 URL 就是二维码内容', () async {
      final path = writeTempImage(
        encodeQrScreenshot(sampleUrl),
        'bettbox_qr_import.png',
      );
      expect(await picker.decodeProfileUrlFromQrImage(path), sampleUrl);
    });

    test('非 URL 的二维码提示「请上传有效的二维码」', () async {
      final path = writeTempImage(
        encodeQrImage('hello world'),
        'bettbox_qr_not_url.png',
      );
      await expectLater(
        picker.decodeProfileUrlFromQrImage(path),
        throwsA(predicate<String>((e) => e.contains('二维码'), '二维码提示文案')),
      );
    });

    test('图片里没有二维码时提示「请上传有效的二维码」', () async {
      final path = writeTempImage(encodeBlankImage(), 'bettbox_qr_blank.png');
      await expectLater(
        picker.decodeProfileUrlFromQrImage(path),
        throwsA(predicate<String>((e) => e.contains('二维码'), '二维码提示文案')),
      );
    });
  });
}
