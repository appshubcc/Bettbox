import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/silky_scroll.dart';

void main() {
  group('SilkyScrollController', () {
    late ScrollController clientController;
    late SilkyScrollController silkyController;

    setUp(() {
      clientController = ScrollController();
      silkyController = SilkyScrollController(
        clientController: clientController,
      );
    });

    tearDown(() {
      silkyController.dispose();
      clientController.dispose();
    });

    test('stores clientController reference', () {
      expect(silkyController.clientController, same(clientController));
    });

    test('setPointerDeviceKind is no-op when no position exists', () {
      // Should not throw when currentSilkyScrollPosition is null
      silkyController.setPointerDeviceKind(PointerDeviceKind.mouse);
      expect(silkyController.currentSilkyScrollPosition, isNull);
    });

    testWidgets('creates SilkyScrollPosition inside scrollable', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: silkyController,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      expect(silkyController.currentSilkyScrollPosition, isNotNull);
      expect(
        silkyController.currentSilkyScrollPosition,
        isA<SilkyScrollPosition>(),
      );
    });

    testWidgets('setPointerDeviceKind updates position kind', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: silkyController,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      silkyController.setPointerDeviceKind(PointerDeviceKind.mouse);
      expect(
        silkyController.currentSilkyScrollPosition!.kind,
        PointerDeviceKind.mouse,
      );

      silkyController.setPointerDeviceKind(PointerDeviceKind.trackpad);
      expect(
        silkyController.currentSilkyScrollPosition!.kind,
        PointerDeviceKind.trackpad,
      );
    });

    testWidgets('attach/detach syncs with clientController', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: silkyController,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      // Both controllers should have clients
      expect(silkyController.hasClients, isTrue);
      expect(clientController.hasClients, isTrue);
    });
  });

  group('SilkyScrollPosition', () {
    testWidgets('defaults to trackpad kind', (tester) async {
      final client = ScrollController();
      final controller = SilkyScrollController(clientController: client);

      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      expect(
        controller.currentSilkyScrollPosition!.kind,
        PointerDeviceKind.trackpad,
      );

      controller.dispose();
      client.dispose();
    });
  });
}
