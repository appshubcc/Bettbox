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

  DAVClient(DAV dav) {
    client = newClient(dav.uri, user: dav.user, password: dav.password);
    fileName = dav.fileName;
    client.c.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final challenges = response.headers['www-authenticate'];
          if (response.statusCode == 401 &&
              challenges != null &&
              challenges.length > 1) {
            // webdav_client reads this header through Headers.value(), which
            // throws when servers such as DUFS advertise Digest and Basic.
            response.headers.set('www-authenticate', challenges.join(', '));
          }
          handler.next(response);
        },
      ),
    );
    client.setHeaders({'accept-charset': 'utf-8', 'Content-Type': 'text/xml'});
    // 增加超时时间以适应慢速网络
    client.setConnectTimeout(15000); // 15秒连接超时
    client.setSendTimeout(120000); // 2分钟发送超时（大文件）
    client.setReceiveTimeout(120000); // 2分钟接收超时（大文件）
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

  /// 备份数据到 WebDAV（带重试机制）
  Future<bool> backup(Uint8List data) async {
    return await _retryOperation(() async {
      commonPrint.log(
        'WebDAV backup: uploading ${data.length} bytes to $backupFile',
      );

      // 确保目录存在
      try {
        await client.mkdir(root);
      } catch (e) {
        // 目录可能已存在，忽略错误
        commonPrint.log('WebDAV mkdir warning (may already exist): $e');
      }

      // 上传文件
      await client.write(backupFile, data);
      commonPrint.log('WebDAV backup successful');
      return true;
    }, operationName: 'backup');
  }

  /// 从 WebDAV 恢复数据（带重试机制）
  Future<List<int>> recovery() async {
    return await _retryOperation(() async {
      commonPrint.log('WebDAV recovery: downloading from $backupFile');

      // 确保目录存在
      try {
        await client.mkdir(root);
      } catch (e) {
        commonPrint.log('WebDAV mkdir warning: $e');
      }

      // 下载文件
      final data = await client.read(backupFile);
      commonPrint.log('WebDAV recovery successful: ${data.length} bytes');
      return data;
    }, operationName: 'recovery');
  }

  /// 重试机制：最多重试3次，指数退避
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
          // 最后一次尝试失败，抛出详细错误
          commonPrint.log(
            'WebDAV $operationName failed after $maxAttempts attempts: $e',
          );
          throw 'WebDAV $operationName failed: ${_formatError(e)}';
        }

        // 非最后一次尝试，等待后重试
        commonPrint.log(
          'WebDAV $operationName attempt $attempt failed: $e, retrying in ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);

        // 指数退避：2s -> 4s -> 8s
        delay *= 2;
      }
    }

    throw 'WebDAV $operationName failed: unexpected error';
  }

  /// 格式化错误信息，提供更友好的提示
  String _formatError(dynamic error) {
    final errorStr = error.toString();

    // 常见错误的友好提示
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

    // 返回原始错误（如果无法识别）
    return errorStr;
  }
}
