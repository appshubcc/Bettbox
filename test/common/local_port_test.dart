import 'dart:io';

import 'package:bett_box/common/local_port.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'selects another local port when the preferred port is occupied',
    () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      try {
        final selected = await findAvailableLocalPort(server.port);
        expect(selected, isNot(server.port));
      } finally {
        await server.close();
      }
    },
  );

  test('keeps port zero disabled', () async {
    expect(await findAvailableLocalPort(0), 0);
  });
}
