import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_ext/window_ext.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('window_ext');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setDockIconVisible forwards the visibility flag to window_ext', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    await windowExtManager.setDockIconVisible(false);
    await windowExtManager.setDockIconVisible(true);

    expect(
      calls.map((call) => call.method),
      ['setDockIconVisible', 'setDockIconVisible'],
    );
    expect(calls.map((call) => call.arguments), [false, true]);
  });

  test('setDockIconVisible completes when the platform returns null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);

    await expectLater(windowExtManager.setDockIconVisible(false), completes);
  });

  test('setDockIconVisible propagates platform errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'invalid_arguments');
    });

    await expectLater(
      windowExtManager.setDockIconVisible(false),
      throwsA(isA<PlatformException>()),
    );
  });
}
