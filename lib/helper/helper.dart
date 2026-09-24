import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:bett_box/common/helper_auth.dart';
import 'package:bett_box/common/identity.dart';
import 'package:bett_box/common/print.dart';
import 'package:bett_box/common/win32_kernel.dart';
import 'package:ffi/ffi.dart';

const helperProtocolVersion = 1;
const helperPipeName = WindowsHelperIdentity.pipeName;
const helperMaxFrameSize = 1024 * 1024;
const helperDefaultTimeout = Duration(seconds: 5);

abstract class HelperTransport {
  Future<String> send(
    String payload, {
    Duration timeout = helperDefaultTimeout,
  });
}

class HelperAuth {
  const HelperAuth({required this.timestamp, required this.signature});

  final int timestamp;
  final String signature;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'signature': signature,
  };
}

class HelperRequest {
  const HelperRequest({
    required this.id,
    required this.method,
    required this.body,
    required this.auth,
  });

  final String id;
  final String method;
  final String body;
  final HelperAuth auth;

  String encode() {
    return json.encode({
      'version': helperProtocolVersion,
      'id': id,
      'method': method,
      'body': body,
      'auth': auth.toJson(),
    });
  }
}

class HelperResponse {
  const HelperResponse({
    required this.id,
    required this.ok,
    this.data,
    this.error,
  });

  final String id;
  final bool ok;
  final Object? data;
  final HelperResponseError? error;

  factory HelperResponse.decode(String value) {
    final data = json.decode(value);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid helper response');
    }
    return HelperResponse(
      id: data['id'] as String? ?? '',
      ok: data['ok'] == true,
      data: data['data'],
      error: data['error'] is Map<String, dynamic>
          ? HelperResponseError.fromJson(data['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HelperResponseError {
  const HelperResponseError({required this.code, required this.message});

  final String code;
  final String message;

  factory HelperResponseError.fromJson(Map<String, dynamic> json) {
    return HelperResponseError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'Unknown helper error',
    );
  }
}

class HelperRpcException implements Exception {
  const HelperRpcException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

class HelperClient {
  HelperClient({required HelperTransport transport}) : _transport = transport;

  final HelperTransport _transport;
  final Random _random = Random.secure();

  Future<bool> ping(
    String expectedToken, {
    Duration timeout = const Duration(milliseconds: 500),
  }) async {
    try {
      final response = await _request('helper.ping', timeout: timeout);
      return response.data == expectedToken;
    } catch (e) {
      commonPrint.log('[HelperClient] ping failed: $e');
      return false;
    }
  }

  Future<bool> startCore({
    required String corePath,
    required String arg,
    required String homeDir,
  }) async {
    try {
      await _request(
        'core.start',
        body: {'path': corePath, 'arg': arg, 'home_dir': homeDir},
        timeout: const Duration(seconds: 5),
      );
      return true;
    } catch (e) {
      commonPrint.log('[HelperClient] startCore failed: $e');
      return false;
    }
  }

  Future<bool> stopCore() async {
    try {
      await _request('core.stop', timeout: const Duration(milliseconds: 2000));
      return true;
    } catch (e) {
      commonPrint.log('[HelperClient] stopCore failed: $e');
      return false;
    }
  }

  Future<bool> stopHelperService() async {
    try {
      await _request(
        'helper.stop_service',
        timeout: const Duration(milliseconds: 2000),
      );
      return true;
    } catch (e) {
      commonPrint.log('[HelperClient] stopHelperService failed: $e');
      return false;
    }
  }

  Future<bool> setProcessPriority(String processName, bool enable) async {
    try {
      await _request(
        'process.set_priority',
        body: {'process_name': processName, 'enable': enable},
        timeout: const Duration(milliseconds: 2000),
      );
      return true;
    } catch (e) {
      commonPrint.log('[HelperClient] setProcessPriority failed: $e');
      return false;
    }
  }

  Future<List<String>> getLogs() async {
    final response = await _request('helper.logs');
    final data = response.data;
    if (data is List) {
      return data.whereType<String>().toList();
    }
    return const [];
  }

  Future<HelperResponse> _request(
    String method, {
    Map<String, dynamic>? body,
    Duration timeout = helperDefaultTimeout,
  }) async {
    await HelperAuthManager.ensureAuthKey();

    final bodyPayload = body == null ? '' : json.encode(body);
    final authPayload = '$helperProtocolVersion:$method:$bodyPayload';
    final headers = HelperAuthManager.generateAuthHeaders(authPayload);
    final timestamp = int.tryParse(headers['X-Timestamp'] ?? '');
    final signature = headers['X-Signature'];
    if (timestamp == null || signature == null) {
      throw const HelperRpcException(
        'AUTH_NOT_READY',
        'Helper auth key is not ready',
      );
    }

    final request = HelperRequest(
      id: _nextId(),
      method: method,
      body: bodyPayload,
      auth: HelperAuth(timestamp: timestamp, signature: signature),
    );
    final responsePayload = await _transport.send(
      request.encode(),
      timeout: timeout,
    );
    final response = HelperResponse.decode(responsePayload);
    if (!response.ok) {
      final error = response.error;
      throw HelperRpcException(
        error?.code ?? 'HELPER_ERROR',
        error?.message ?? 'Unknown helper error',
      );
    }
    return response;
  }

  String _nextId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final suffix = _random.nextInt(0x7fffffff).toRadixString(16);
    return '$now-$suffix';
  }
}

HelperTransport _createHelperTransport() {
  if (Platform.isWindows) {
    return const NamedPipeHelperTransport();
  }
  return _UnsupportedHelperTransport();
}

class _UnsupportedHelperTransport implements HelperTransport {
  @override
  Future<String> send(
    String payload, {
    Duration timeout = helperDefaultTimeout,
  }) {
    throw UnsupportedError(
      'Helper IPC transport is not available on this platform',
    );
  }
}

final helperClient = HelperClient(transport: _createHelperTransport());

class NamedPipeHelperTransport implements HelperTransport {
  const NamedPipeHelperTransport({this.pipeName = helperPipeName});

  final String pipeName;

  @override
  Future<String> send(
    String payload, {
    Duration timeout = helperDefaultTimeout,
  }) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('Named Pipe helper transport is Windows-only');
    }
    return Isolate.run(
      () => _sendNamedPipeRequest(pipeName, payload, timeout.inMilliseconds),
    );
  }
}

String _sendNamedPipeRequest(String pipeName, String payload, int timeoutMs) {
  final client = _NamedPipeClient(pipeName: pipeName, timeoutMs: timeoutMs);
  return client.send(payload);
}

class _NamedPipeClient {
  _NamedPipeClient({required this.pipeName, required this.timeoutMs});

  final String pipeName;
  final int timeoutMs;

  String send(String payload) {
    final handle = _connect();
    try {
      final bytes = utf8.encode(payload);
      if (bytes.length > helperMaxFrameSize) {
        throw StateError('Helper request frame is too large');
      }
      final frame = Uint8List(4 + bytes.length);
      final frameView = ByteData.sublistView(frame);
      frameView.setUint32(0, bytes.length, Endian.little);
      frame.setRange(4, frame.length, bytes);
      _writeAll(handle, frame);

      final header = _readExactly(handle, 4);
      final length = ByteData.sublistView(header).getUint32(0, Endian.little);
      if (length > helperMaxFrameSize) {
        throw StateError('Helper response frame is too large');
      }
      final response = _readExactly(handle, length);
      return utf8.decode(response);
    } finally {
      Kernel32.instance.closeHandle(handle);
    }
  }

  int _connect() {
    final kernel32 = Kernel32.instance;
    final pipeNamePtr = pipeName.toNativeUtf16();
    final stopwatch = Stopwatch()..start();

    try {
      while (true) {
        final handle = kernel32.createFile(
          pipeNamePtr,
          genericRead | genericWrite,
          0,
          nullptr,
          openExisting,
          0,
          0,
        );
        if (handle != invalidHandleValue) {
          return handle;
        }

        final error = kernel32.getLastError();
        final remainingMs = timeoutMs - stopwatch.elapsedMilliseconds;
        if (remainingMs <= 0) {
          throw StateError('Helper pipe connection timed out: $error');
        }

        if (error == errorPipeBusy) {
          kernel32.waitNamedPipe(pipeNamePtr, remainingMs);
        } else if (error == errorFileNotFound) {
          sleep(const Duration(milliseconds: 50));
        } else {
          throw StateError('Helper pipe connection failed: $error');
        }
      }
    } finally {
      calloc.free(pipeNamePtr);
    }
  }

  void _writeAll(int handle, Uint8List data) {
    final kernel32 = Kernel32.instance;
    final buffer = calloc<Uint8>(data.length);
    final written = calloc<Uint32>();

    try {
      buffer.asTypedList(data.length).setAll(0, data);
      var offset = 0;
      while (offset < data.length) {
        written.value = 0;
        final result = kernel32.writeFile(
          handle,
          buffer + offset,
          data.length - offset,
          written,
          nullptr,
        );
        if (result == 0 || written.value == 0) {
          throw StateError(
            'Helper pipe write failed: ${kernel32.getLastError()}',
          );
        }
        offset += written.value;
      }
    } finally {
      calloc.free(written);
      calloc.free(buffer);
    }
  }

  Uint8List _readExactly(int handle, int length) {
    final kernel32 = Kernel32.instance;
    final buffer = calloc<Uint8>(length);
    final bytesRead = calloc<Uint32>();

    try {
      var offset = 0;
      while (offset < length) {
        bytesRead.value = 0;
        final result = kernel32.readFile(
          handle,
          buffer + offset,
          length - offset,
          bytesRead,
          nullptr,
        );
        if (result == 0 || bytesRead.value == 0) {
          throw StateError(
            'Helper pipe read failed: ${kernel32.getLastError()}',
          );
        }
        offset += bytesRead.value;
      }
      return Uint8List.fromList(buffer.asTypedList(length));
    } finally {
      calloc.free(bytesRead);
      calloc.free(buffer);
    }
  }
}
