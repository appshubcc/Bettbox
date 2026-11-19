import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/common/dav_client.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'shared backup conditionally creates and updates the same file',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final saved = <String, List<int>>{};
      final revisions = <String, int>{};
      server.listen((request) async {
        final response = request.response;
        final path = request.uri.path;
        final etag = '"${revisions[path] ?? 0}"';
        switch (request.method) {
          case 'OPTIONS':
          case 'MKCOL':
            response.statusCode = HttpStatus.ok;
          case 'GET':
            if (saved[path] case final data?) {
              response.headers.set(HttpHeaders.etagHeader, etag);
              response.add(data);
            } else {
              response.statusCode = HttpStatus.notFound;
            }
          case 'PUT':
            final incoming = await request.fold(
              <int>[],
              (bytes, chunk) => bytes..addAll(chunk),
            );
            final ifNoneMatch = request.headers.value('if-none-match');
            final ifMatch = request.headers.value('if-match');
            final matches = saved[path] == null
                ? ifNoneMatch == '*'
                : ifMatch == etag;
            if (matches) {
              saved[path] = incoming;
              revisions[path] = (revisions[path] ?? 0) + 1;
              response.statusCode = HttpStatus.noContent;
            } else {
              response.statusCode = HttpStatus.preconditionFailed;
            }
          case 'DELETE':
          case 'UNLOCK':
            saved.remove(path);
            revisions.remove(path);
            response.statusCode = HttpStatus.noContent;
          default:
            response.statusCode = HttpStatus.methodNotAllowed;
        }
        await response.close();
      });

      final client = DAVClient(
        DAV(
          uri: 'http://${server.address.host}:${server.port}',
          user: '',
          password: '',
        ),
      );
      final first = Uint8List.fromList([1]);
      final second = Uint8List.fromList([2]);
      expect(await client.readSharedBackup(), isNull);
      expect(await client.writeSharedBackup(first, expectedEtag: null), isTrue);
      final initial = (await client.readSharedBackup())!;
      expect(initial.data, first);
      expect(
        await client.writeSharedBackup(second, expectedEtag: initial.etag),
        isTrue,
      );
      expect(
        await client.writeSharedBackup(first, expectedEtag: initial.etag),
        isFalse,
      );
      expect(await client.recovery(), second);
    },
  );

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
    final webDavServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
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
