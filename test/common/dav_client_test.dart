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

  test('removes WebDAV authorization after a cross-origin redirect', () async {
    final downloadedBytes = utf8.encode('backup-data');
    final storageServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final webDavServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    var storageReceivedAuthorization = false;

    final storageSubscription = storageServer.listen((request) async {
      storageReceivedAuthorization =
          request.headers.value(HttpHeaders.authorizationHeader) != null;
      if (storageReceivedAuthorization) {
        request.response.statusCode = HttpStatus.unauthorized;
      } else {
        request.response.statusCode = HttpStatus.ok;
        request.response.add(downloadedBytes);
      }
      await request.response.close();
    });

    final webDavSubscription = webDavServer.listen((request) async {
      final authorization = request.headers.value(
        HttpHeaders.authorizationHeader,
      );
      if (authorization == null) {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.headers.set(
          HttpHeaders.wwwAuthenticateHeader,
          'Basic realm="test"',
        );
      } else if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.ok;
      } else if (request.method == 'MKCOL') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
      } else if (request.method == 'GET') {
        request.response.statusCode = HttpStatus.found;
        request.response.headers.set(
          HttpHeaders.locationHeader,
          'http://${storageServer.address.host}:${storageServer.port}/backup.zip',
        );
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    });

    try {
      final client = DAVClient(
        DAV(
          uri: 'http://${webDavServer.address.host}:${webDavServer.port}',
          user: 'user',
          password: 'password',
        ),
      );

      expect(await client.pingCompleter.future, isTrue);
      expect(await client.recovery(), downloadedBytes);
      expect(storageReceivedAuthorization, isFalse);
    } finally {
      await webDavServer.close(force: true);
      await storageServer.close(force: true);
      await webDavSubscription.cancel();
      await storageSubscription.cancel();
    }
  });
}
