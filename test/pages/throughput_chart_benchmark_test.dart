import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

double computePeakOld(
  List<(double, double)> download,
  List<(double, double)> upload,
) {
  return [
    ...download.map((item) => item.$2),
    ...upload.map((item) => item.$2),
  ].fold<double>(0, max);
}

double computePeakNew(
  List<(double, double)> download,
  List<(double, double)> upload,
) {
  var peak = 0.0;
  for (var i = 0; i < download.length; i++) {
    final v = download[i].$2;
    if (v > peak) peak = v;
  }
  for (var i = 0; i < upload.length; i++) {
    final v = upload[i].$2;
    if (v > peak) peak = v;
  }
  return peak;
}

bool seriesChangedOld(List<(double, double)> a, List<(double, double)> b) {
  return a != b;
}

bool seriesChangedNew(List<(double, double)> a, List<(double, double)> b) {
  if (identical(a, b)) return false;
  final len = a.length;
  if (len != b.length) return true;
  if (len == 0) return false;
  return a.last != b.last || a.first != b.first || a[len >> 1] != b[len >> 1];
}

void main() {
  test('Peak compute accuracy and speed benchmark', () {
    final download = List.generate(
      500,
      (i) => (i / 500.0, sin(i * 0.1).abs() * 100e6),
    );
    final upload = List.generate(
      500,
      (i) => (i / 500.0, cos(i * 0.1).abs() * 80e6),
    );

    final peakOld = computePeakOld(download, upload);
    final peakNew = computePeakNew(download, upload);
    expect(peakNew, closeTo(peakOld, 1e-4));

    final swOld = Stopwatch()..start();
    for (var i = 0; i < 5000; i++) {
      computePeakOld(download, upload);
    }
    swOld.stop();

    final swNew = Stopwatch()..start();
    for (var i = 0; i < 5000; i++) {
      computePeakNew(download, upload);
    }
    swNew.stop();

    expect(swNew.elapsedMicroseconds, lessThan(swOld.elapsedMicroseconds));
  });

  test('Series dirty check accuracy', () {
    final listA = List.generate(100, (i) => (i / 100.0, i * 1.0));
    final listB = [...listA];
    final listC = [...listA, (1.01, 101.0)];

    expect(seriesChangedOld(listA, listB), isTrue);
    expect(seriesChangedNew(listA, listB), isFalse);
    expect(seriesChangedNew(listA, listC), isTrue);
  });
}
