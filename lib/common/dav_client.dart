import 'dart:async';
import 'dart:typed_data';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:dio/dio.dart';
import 'package:webdav_client/webdav_client.dart';

class DAVClient {
  late Client client;
  Completer<bool> pingCompleter = Completer();
  late String fileName;
  late final Uri _serverUri;

  DAVClient(DAV dav) {
    client = newClient(dav.uri, user: dav.user, password: dav.password);
    fileName = dav.fileName;
    _serverUri = Uri.parse(dav.uri);
    client.c.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!_hasSameOrigin(options.uri, _serverUri)) {
            options.headers.remove('authorization');
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          final challenges = response.headers['www-authenticate'];
          if (response.statusCode == 401 &&
              challenges != null &&
              challenges.length > 1) {
            response.headers.set('www-authenticate', challenges.join(', '));
          }
          handler.next(response);
        },
      ),
    );
    client.setHeaders({'accept-charset': 'utf-8', 'Content-Type': 'text/xml'});
    client.setConnectTimeout(15000);
    client.setSendTimeout(120000);
    client.setReceiveTimeout(120000);
    pingCompleter.complete(_ping());
  }

  Future<bool> _ping() async {
    try {
      await client.ping();
      commonPrint.log('WebDAV ping successful');
      return true;
    } catch (e) {
      commonPrint.log('WebDAV ping failed: $e');
      return false;
    }
  }

  String get root => '/$appName';

  String get backupFile => '$root/$fileName';

  Future<bool> backup(Uint8List data) async {
    return await _retryOperation(() async {
      commonPrint.log(
        'WebDAV backup: uploading ${data.length} bytes to $backupFile',
      );

      try {
        await client.mkdir(root);
      } catch (e) {
        commonPrint.log('WebDAV mkdir warning (may already exist): $e');
      }

      await client.write(backupFile, data);
      commonPrint.log('WebDAV backup successful');
      return true;
    }, operationName: 'backup');
  }

  Future<List<int>> recovery() async {
    return await _retryOperation(() async {
      commonPrint.log('WebDAV recovery: downloading from $backupFile');

      try {
        await client.mkdir(root);
      } catch (e) {
        commonPrint.log('WebDAV mkdir warning: $e');
      }

      final data = await client.read(backupFile);
      commonPrint.log('WebDAV recovery successful: ${data.length} bytes');
      return data;
    }, operationName: 'recovery');
  }

  bool _hasSameOrigin(Uri left, Uri right) {
    return left.scheme.toLowerCase() == right.scheme.toLowerCase() &&
        left.host.toLowerCase() == right.host.toLowerCase() &&
        left.port == right.port;
  }

  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    required String operationName,
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 2);

    while (attempt < maxAttempts) {
      attempt++;

      try {
        return await operation();
      } catch (e) {
        final isLastAttempt = attempt >= maxAttempts;

        if (isLastAttempt) {
          commonPrint.log(
            'WebDAV $operationName failed after $maxAttempts attempts: $e',
          );
          throw 'WebDAV $operationName failed: ${_formatError(e)}';
        }

        commonPrint.log(
          'WebDAV $operationName attempt $attempt failed: $e, retrying in ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);

        delay *= 2;
      }
    }

    throw 'WebDAV $operationName failed: unexpected error';
  }

  String _formatError(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection')) {
      return 'Network connection failed. Please check your internet connection and WebDAV server address.';
    }

    if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return 'Authentication failed. Please check your username and password.';
    }

    if (errorStr.contains('403') || errorStr.contains('Forbidden')) {
      return 'Access denied. Please check your account permissions.';
    }

    if (errorStr.contains('404') || errorStr.contains('Not Found')) {
      return 'Backup file not found on server.';
    }

    if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
      return 'Operation timed out. Please check your network connection or try again later.';
    }

    if (errorStr.contains('507') || errorStr.contains('Insufficient Storage')) {
      return 'Server storage is full. Please free up space on your WebDAV server.';
    }

    return errorStr;
  }
}
