import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:collection/collection.dart';
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
      commonPrint.warn('WebDAV ping failed: $e');
      return false;
    }
  }

  String get root => '/$appName';

  String get baseName =>
      fileName.replaceAll(RegExp(r'\.zip$', caseSensitive: false), '');

  String get backupFile => '$root/$fileName';

  bool _conditionalWritesVerified = false;

  Future<List<File>> getBackupFiles() async {
    try {
      await client.mkdir(root);
    } catch (_) {}
    final rawFiles = await client.readDir(root);
    final reg = RegExp(
      '^${RegExp.escape(baseName)}(?:_(\\d{8})_(\\d{2}))?\\.zip\$',
      caseSensitive: false,
    );
    final validFiles = rawFiles.where((f) {
      if (f.isDir == true) return false;
      final name = f.name;
      if (name == null || name.isEmpty) return false;
      return reg.hasMatch(name);
    }).toList();

    validFiles.sort((a, b) {
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      if (nameA == fileName && nameB != fileName) return -1;
      if (nameB == fileName && nameA != fileName) return 1;
      final matchA = reg.firstMatch(nameA);
      final matchB = reg.firstMatch(nameB);
      final dateA = matchA?.group(1);
      final seqA = matchA?.group(2);
      final dateB = matchB?.group(1);
      final seqB = matchB?.group(2);
      if (dateA != null && seqA != null && dateB != null && seqB != null) {
        final cmpDate = dateB.compareTo(dateA);
        if (cmpDate != 0) return cmpDate;
        return seqB.compareTo(seqA);
      }
      if (dateA != null && dateB == null) return -1;
      if (dateA == null && dateB != null) return 1;
      final timeA = a.mTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.mTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });

    return validFiles;
  }

  Future<String> getNextBackupFileName() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final reg = RegExp(
      '^${RegExp.escape(baseName)}_${dateStr}_(\\d{2})\\.zip\$',
      caseSensitive: false,
    );
    var maxSeq = 0;
    try {
      final files = await getBackupFiles();
      for (final f in files) {
        final match = reg.firstMatch(f.name ?? '');
        if (match != null) {
          final seq = int.tryParse(match.group(1) ?? '') ?? 0;
          if (seq > maxSeq) {
            maxSeq = seq;
          }
        }
      }
    } catch (_) {}
    final nextSeq = (maxSeq + 1).toString().padLeft(2, '0');
    return '${baseName}_${dateStr}_$nextSeq.zip';
  }

  Future<void> _pruneOldBackups() async {
    final files = await getBackupFiles();
    if (files.length > 10) {
      final toRemove = files.sublist(10);
      for (final f in toRemove) {
        final name = f.name;
        if (name != null && name.isNotEmpty) {
          try {
            await client.remove('$root/$name');
          } catch (e) {
            commonPrint.warn('Prune backup failed: $e');
          }
        }
      }
    }
  }

  Future<bool> backup(Uint8List data) async {
    return await _retryOperation(() async {
      try {
        await client.mkdir(root);
      } catch (e) {
        commonPrint.warn('WebDAV mkdir warning (may already exist): $e');
      }

      final targetName = await getNextBackupFileName();
      final targetPath = '$root/$targetName';
      commonPrint.log(
        'WebDAV backup: uploading ${data.length} bytes to $targetPath',
      );

      await client.write(targetPath, data);
      commonPrint.log('WebDAV backup successful');

      try {
        await _pruneOldBackups();
      } catch (_) {}

      return true;
    }, operationName: 'backup');
  }

  Future<List<int>?> readLatestVersion() async {
    final files = await getBackupFiles();
    final latest = files.firstWhereOrNull((file) => file.name != fileName);
    return latest == null ? null : recovery(latest.name);
  }

  Future<({List<int> data, String etag})?> readSharedBackup() async {
    final response = await client.c.req<List<int>>(
      client,
      'GET',
      backupFile,
      optionsHandler: (options) => options.responseType = ResponseType.bytes,
    );
    if (response.statusCode == 404) return null;
    _checkSharedBackupResponse(response);
    final etag = response.headers.value('etag')?.trim();
    if (etag == null || !etag.startsWith('"') || !etag.endsWith('"')) {
      throw StateError('The WebDAV server must provide a strong backup ETag.');
    }
    return (data: response.data!, etag: etag);
  }

  Future<bool> writeSharedBackup(
    Uint8List data, {
    required String? expectedEtag,
  }) async {
    try {
      await client.mkdir(root);
    } catch (_) {
      // The collection usually exists. Let the upload report any error.
    }
    await _verifyConditionalWrites();
    final response = await client.c.req<void>(
      client,
      'PUT',
      backupFile,
      data: data,
      optionsHandler: (options) {
        options.headers!['Content-Type'] = 'application/zip';
        if (expectedEtag == null) {
          options.headers!['If-None-Match'] = '*';
        } else {
          options.headers!['If-Match'] = expectedEtag;
        }
      },
    );
    if (response.statusCode == 412) return false;
    _checkSharedBackupResponse(response);
    return true;
  }

  Future<void> _verifyConditionalWrites() async {
    if (_conditionalWritesVerified) return;
    final probe =
        '$root/.bettbox-conditional-'
        '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
    final data = Uint8List.fromList([66, 66, 88]);
    var created = false;
    try {
      final first = await _conditionalWrite(probe, data, ifNoneMatch: '*');
      if (first.statusCode != 200 &&
          first.statusCode != 201 &&
          first.statusCode != 204) {
        throw StateError(
          'The WebDAV server rejected a conditional backup write.',
        );
      }
      created = true;
      final duplicate = await _conditionalWrite(probe, data, ifNoneMatch: '*');
      final stale = await _conditionalWrite(
        probe,
        data,
        ifMatch: '"bettbox-missing"',
      );
      if (duplicate.statusCode != 412 || stale.statusCode != 412) {
        throw StateError(
          'The WebDAV server does not safely enforce conditional writes.',
        );
      }
      _conditionalWritesVerified = true;
    } finally {
      if (created) {
        try {
          await client.remove(probe);
        } catch (_) {
          // A failed cleanup does not invalidate a verified write policy.
        }
      }
    }
  }

  Future<Response<dynamic>> _conditionalWrite(
    String path,
    Uint8List data, {
    String? ifMatch,
    String? ifNoneMatch,
  }) => client.c.req<dynamic>(
    client,
    'PUT',
    path,
    data: data,
    optionsHandler: (options) {
      options.headers!['Content-Type'] = 'application/octet-stream';
      if (ifMatch != null) options.headers!['If-Match'] = ifMatch;
      if (ifNoneMatch != null) options.headers!['If-None-Match'] = ifNoneMatch;
    },
  );

  void _checkSharedBackupResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException.badResponse(
        statusCode: statusCode,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  Future<List<int>> recovery([String? targetFileName]) async {
    return await _retryOperation(() async {
      final target = targetFileName ?? backupFile;
      final targetPath = target.startsWith('/') ? target : '$root/$target';
      commonPrint.log('WebDAV recovery: downloading from $targetPath');

      try {
        await client.mkdir(root);
      } catch (e) {
        commonPrint.warn('WebDAV mkdir warning: $e');
      }

      final data = await client.read(targetPath);
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
          commonPrint.error(
            'WebDAV $operationName failed after $maxAttempts attempts: $e',
          );
          throw 'WebDAV $operationName failed: ${_formatError(e)}';
        }

        commonPrint.warn(
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
