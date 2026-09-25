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

  String get baseName =>
      fileName.replaceAll(RegExp(r'\.zip$', caseSensitive: false), '');

  String get backupFile => '$root/$fileName';

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
            commonPrint.log('Prune backup failed: $e');
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
        commonPrint.log('WebDAV mkdir warning (may already exist): $e');
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

  Future<List<int>> recovery([String? targetFileName]) async {
    return await _retryOperation(() async {
      final target = targetFileName ?? backupFile;
      final targetPath = target.startsWith('/') ? target : '$root/$target';
      commonPrint.log('WebDAV recovery: downloading from $targetPath');

      try {
        await client.mkdir(root);
      } catch (e) {
        commonPrint.log('WebDAV mkdir warning: $e');
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
