import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _pngs = {
  'red':
      'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAEklEQVR4nGP4z8DwHx9mGBkKAMLXf4EvceABAAAAAElFTkSuQmCC',
  'blue':
      'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAEUlEQVR4nGNgYPj/Hz8eEQoAQ1d/gZtbdTsAAAAASUVORK5CYII=',
};

const _rgb = {'red': (255, 0, 0), 'blue': (0, 0, 255)};

void main() {
  late String tmp;
  late HttpServer server;
  var color = 'red';

  setUpAll(() async {
    HttpOverrides.global = null;
    tmp = Directory.systemTemp.createTempSync('target_icon').path;
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => tmp,
        );
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      final response = request.response;
      if (request.uri.path.startsWith('/png')) {
        response
          ..headers.contentType = ContentType('image', 'png')
          ..add(base64.decode(_pngs[color]!));
      } else {
        final fill = _rgb[color]!;
        response
          ..headers.contentType = ContentType('image', 'svg+xml')
          ..write(
            '<?xml version="1.0"?>\n'
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">'
            '<rect width="10" height="10" '
            'fill="rgb(${fill.$1},${fill.$2},${fill.$3})"/></svg>',
          );
      }
      response.close();
    });
  });

  tearDownAll(() => server.close(force: true));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<String?> centerColor(WidgetTester tester, GlobalKey key) async {
    return tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      final offset = ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
      final pixel = (
        data!.getUint8(offset),
        data.getUint8(offset + 1),
        data.getUint8(offset + 2),
      );
      image.dispose();
      if (pixel.$1 > 200 && pixel.$2 < 60 && pixel.$3 < 60) return 'red';
      if (pixel.$3 > 200 && pixel.$1 < 60 && pixel.$2 < 60) return 'blue';
      return '$pixel';
    });
  }

  for (final path in [
    '/a.svg',
    '/b.svg?v=2',
    '/icon',
    '/png/a.png',
    '/png/b.png?v=2',
    '/png/icon',
  ]) {
    testWidgets('$path renders and refreshes after reset', (tester) async {
      color = 'red';
      await tester.runAsync(CommonTargetIcon.clearCache);
      final key = GlobalKey();
      final url = 'http://127.0.0.1:${server.port}$path';
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: Colors.white,
                child: CommonTargetIcon(src: url, size: 40),
              ),
            ),
          ),
        ),
      );
      await settle(tester);
      expect(await centerColor(tester, key), 'red');
      color = 'blue';
      await tester.runAsync(CommonTargetIcon.clearCache);
      await settle(tester);
      expect(await centerColor(tester, key), 'blue');
    });
  }
}
