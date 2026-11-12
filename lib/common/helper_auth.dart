import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'package:win32_registry/win32_registry.dart';

import 'common.dart';

const _cryptProtectUiForbidden = 0x1;

class HelperAuthManager {
  static String? _authKey;
  static Future<bool>? _ensuringAuthKey;

  static String? getAuthKey() => _authKey;

  static Future<bool> ensureAuthKey() async {
    if (_authKey != null) {
      return false;
    }
    return _ensuringAuthKey ??= _loadAuthKey().whenComplete(
      () => _ensuringAuthKey = null,
    );
  }

  static Future<bool> _loadAuthKey() async {
    if (Platform.isWindows) {
      commonPrint.log(
        '[HelperAuth] Trying to sync auth key from registry for service: $appHelperService',
      );
      RegistryKey? key;
      try {
        final keyPath =
            'SYSTEM\\CurrentControlSet\\Services\\$appHelperService';
        key = LOCAL_MACHINE.open(
          keyPath,
          config: const RegistryOpenConfig(access: RegistryAccess.read),
        );
        final list = key.getValue('Environment');
        if (list case MultiStringValue(:final value)) {
          for (final item in value) {
            if (item.startsWith('HELPER_AUTH_KEY=')) {
              final val = item.substring('HELPER_AUTH_KEY='.length);
              if (_isValidHexKey(val)) {
                _authKey = val;
                final file = File(await appPath.helperAuthKeyPath);
                await _persistAuthKey(file, _authKey!);
                commonPrint.log(
                  '[HelperAuth] Successfully synced auth key from registry.',
                );
                return false;
              }
            }
          }
        }
      } catch (e) {
        commonPrint.warn('[HelperAuth] Failed to read registry: $e');
      } finally {
        key?.close();
      }
    }

    final file = File(await appPath.helperAuthKeyPath);
    final existingKey = await _readPersistedAuthKey(file);
    if (existingKey != null) {
      _authKey = existingKey;
      commonPrint.log('[HelperAuth] Loaded auth key from file.');
      return false;
    }

    _authKey = _generateRandomKey();
    await _persistAuthKey(file, _authKey!);
    commonPrint.log('[HelperAuth] Generated new random auth key.');
    return true;
  }

  static Map<String, String> generateAuthHeaders(String body) {
    final authKey = _authKey;
    if (authKey == null) {
      return {};
    }
    return generateAuthHeadersWithKey(body, authKey);
  }

  static Map<String, String> generateAuthHeadersWithKey(
    String body,
    String authKey,
  ) {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final message = '$timestamp:$body';

    final keyBytes = _hexToBytes(authKey);
    final messageBytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(messageBytes);
    final signature = digest.toString();

    return {'X-Timestamp': timestamp.toString(), 'X-Signature': signature};
  }

  static Future<void> clearAuthKey() async {
    _authKey = null;
    final file = File(await appPath.helperAuthKeyPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Future<String?> _readPersistedAuthKey(File file) async {
    if (!await file.exists()) {
      return null;
    }

    try {
      final encoded = await file.readAsString();
      if (encoded.isEmpty) {
        return null;
      }
      final encrypted = base64Decode(encoded);
      final decrypted = Platform.isWindows
          ? _unprotectForCurrentUser(Uint8List.fromList(encrypted))
          : Uint8List.fromList(encrypted);
      final key = utf8.decode(decrypted);
      if (!_isValidHexKey(key)) {
        return null;
      }
      return key;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _persistAuthKey(File file, String key) async {
    final raw = Uint8List.fromList(utf8.encode(key));
    final encrypted = Platform.isWindows ? _protectForCurrentUser(raw) : raw;
    await file.parent.create(recursive: true);
    await file.writeAsString(base64Encode(encrypted), flush: true);
  }

  static bool _isValidHexKey(String value) {
    return RegExp(r'^[0-9a-f]{64}$').hasMatch(value);
  }

  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  static Uint8List _protectForCurrentUser(Uint8List input) {
    final dataIn = calloc<CRYPT_INTEGER_BLOB>();
    final dataOut = calloc<CRYPT_INTEGER_BLOB>();
    final inputBuffer = calloc<Uint8>(input.length);

    try {
      inputBuffer.asTypedList(input.length).setAll(0, input);
      dataIn.ref.cbData = input.length;
      dataIn.ref.pbData = inputBuffer;

      final result = CryptProtectData(
        dataIn,
        null,
        null,
        null,
        _cryptProtectUiForbidden,
        dataOut,
      );
      if (!result.value) {
        throw WindowsException(result.error.toHRESULT());
      }

      return Uint8List.fromList(
        dataOut.ref.pbData.asTypedList(dataOut.ref.cbData),
      );
    } finally {
      if (dataOut.ref.pbData != nullptr) {
        LocalFree(HLOCAL(dataOut.ref.pbData));
      }
      calloc.free(inputBuffer);
      calloc.free(dataIn);
      calloc.free(dataOut);
    }
  }

  static Uint8List _unprotectForCurrentUser(Uint8List input) {
    final dataIn = calloc<CRYPT_INTEGER_BLOB>();
    final dataOut = calloc<CRYPT_INTEGER_BLOB>();
    final inputBuffer = calloc<Uint8>(input.length);

    try {
      inputBuffer.asTypedList(input.length).setAll(0, input);
      dataIn.ref.cbData = input.length;
      dataIn.ref.pbData = inputBuffer;

      final result = CryptUnprotectData(
        dataIn,
        null,
        null,
        null,
        _cryptProtectUiForbidden,
        dataOut,
      );
      if (!result.value) {
        throw WindowsException(result.error.toHRESULT());
      }

      return Uint8List.fromList(
        dataOut.ref.pbData.asTypedList(dataOut.ref.cbData),
      );
    } finally {
      if (dataOut.ref.pbData != nullptr) {
        LocalFree(HLOCAL(dataOut.ref.pbData));
      }
      calloc.free(inputBuffer);
      calloc.free(dataIn);
      calloc.free(dataOut);
    }
  }
}
