import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/dav_client.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports servers with multiple WWW-Authenticate headers', () async {
    final backupBytes = utf8.encode('backup-data');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var storedBytes = <int>[];

    final subscription = server.listen((request) async {
      final authorization = request.headers.value(
        HttpHeaders.authorizationHeader,
      );
      if (authorization == null) {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.headers.add(
          HttpHeaders.wwwAuthenticateHeader,
          'Digest realm="DUFS", nonce="test-nonce", qop="auth"',
          preserveHeaderCase: true,
        );
        request.response.headers.add(
          HttpHeaders.wwwAuthenticateHeader,
          'Basic realm="DUFS"',
          preserveHeaderCase: true,
        );
      } else if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.ok;
      } else if (request.method == 'MKCOL') {
        request.response.statusCode = HttpStatus.created;
      } else if (request.method == 'PUT') {
        storedBytes = await request.fold<List<int>>(
          <int>[],
          (bytes, chunk) => bytes..addAll(chunk),
        );
        request.response.statusCode = HttpStatus.created;
      } else if (request.method == 'GET') {
        request.response.statusCode = HttpStatus.ok;
        request.response.add(storedBytes);
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    });

    try {
      final client = DAVClient(
        DAV(
          uri: 'http://${server.address.host}:${server.port}',
          user: 'test',
          password: 'password',
        ),
      );

      expect(await client.pingCompleter.future, isTrue);
      expect(await client.backup(backupBytes), isTrue);
      expect(storedBytes, backupBytes);
      expect(await client.recovery(), backupBytes);
    } finally {
      await server.close(force: true);
      await subscription.cancel();
    }
  });
}
