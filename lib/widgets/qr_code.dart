import 'package:flutter/material.dart';
import 'package:zxing2/qrcode.dart';

class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(width: size, height: size);
    }

    QRCode? qrCode;
    try {
      qrCode = Encoder.encode(data, ErrorCorrectionLevel.m);
    } catch (_) {
      qrCode = null;
    }

    final matrix = qrCode?.matrix;
    if (matrix == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Icon(Icons.error_outline)),
      );
    }

    final qrColor = color ?? Colors.black;
    final qrBgColor = backgroundColor ?? Colors.white;
    final width = matrix.width;
    final height = matrix.height;
    final modules = List.generate(
      height,
      (y) => List.generate(width, (x) => matrix.get(x, y) == 1),
    );

    return Container(
      width: size,
      height: size,
      color: qrBgColor,
      child: CustomPaint(
        size: Size(size, size),
        painter: _QrCodePainter(
          modules: modules,
          color: qrColor,
          backgroundColor: qrBgColor,
        ),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final List<List<bool>> modules;
  final Color color;
  final Color backgroundColor;

  const _QrCodePainter({
    required this.modules,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final paint = Paint()..color = color;
    const quietZone = 2;
    final height = modules.length;
    final width = modules.isEmpty ? 0 : modules[0].length;
    final totalCols = width + quietZone * 2;
    final totalRows = height + quietZone * 2;
    final cellWidth = size.width / totalCols;
    final cellHeight = size.height / totalRows;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (modules[y][x]) {
          final rect = Rect.fromLTWH(
            (x + quietZone) * cellWidth,
            (y + quietZone) * cellHeight,
            cellWidth + 0.5,
            cellHeight + 0.5,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) =>
      oldDelegate.modules != modules ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor;
}

