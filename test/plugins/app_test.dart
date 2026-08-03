import 'package:bett_box/plugins/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    app.onSystemWake = null;
  });

  test('forwards the native macOS wake event', () async {
    var wakeCount = 0;
    app.onSystemWake = () async {
      wakeCount++;
    };

    await app.handleMethodCall(const MethodCall('systemDidWake'));

    expect(wakeCount, 1);
  });
}
