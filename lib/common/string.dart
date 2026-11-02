import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'app_localizations.dart';
import 'print.dart';

extension StringExtension on String {
  bool get isHttpUrl {
    return RegExp(r'^(http|https)://', caseSensitive: false).hasMatch(this);
  }

  bool get isFileUrl {
    return RegExp(r'^file://', caseSensitive: false).hasMatch(this);
  }

  bool get isRemoteUrl {
    return isHttpUrl;
  }

  bool get isLocalUrl {
    return isFileUrl;
  }

  bool get isUrl {
    return isRemoteUrl || isLocalUrl;
  }

  dynamic get splitByMultipleSeparators {
    final parts = split(
      RegExp(r'[, ;]+'),
    ).where((part) => part.isNotEmpty).toList();

    return parts.length > 1 ? parts : this;
  }

  int compareToLower(String other) {
    return toLowerCase().compareTo(other.toLowerCase());
  }

  List<int> get encodeUtf16LeWithBom {
    final byteData = ByteData(length * 2);
    final bom = [0xFF, 0xFE];
    for (int i = 0; i < length; i++) {
      int charCode = codeUnitAt(i);
      byteData.setUint16(i * 2, charCode, Endian.little);
    }
    return bom + byteData.buffer.asUint8List();
  }

  static final _base64Pattern = RegExp(r'base64,(.*)');
  static const _maxCachedBase64 = 64;
  static final _base64Cache = <String, Uint8List>{};

  Uint8List? get getBase64 {
    if (!contains('base64,')) {
      return null;
    }
    final cached = _base64Cache.remove(this);
    if (cached != null) {
      _base64Cache[this] = cached;
      return cached;
    }
    final match = _base64Pattern.firstMatch(this);
    final realValue = match?.group(1) ?? '';
    if (realValue.isEmpty) {
      return null;
    }
    try {
      final bytes = base64.decode(realValue);
      if (_base64Cache.length >= _maxCachedBase64) {
        _base64Cache.remove(_base64Cache.keys.first);
      }
      return _base64Cache[this] = bytes;
    } catch (e) {
      return null;
    }
  }

  bool get isSvg {
    return endsWith('.svg');
  }

  bool get isRegex {
    try {
      RegExp(this);
      return true;
    } catch (e) {
      commonPrint.debug(e.toString());
      return false;
    }
  }

  String toMd5() {
    final bytes = utf8.encode(this);
    return md5.convert(bytes).toString();
  }
}

extension StringExtensionSafe on String? {
  String getSafeValue(String defaultValue) {
    return this?.isEmpty != false ? defaultValue : this!;
  }
}

extension ObjectExtension on Object {
  String get formatError => _format(isLog: false);

  String get formatErrorLog => _format(isLog: true);

  String _format({required bool isLog}) {
    final errorStr = toString();
    if (errorStr.contains('DioException [bad response]') ||
        errorStr.contains('status code of')) {
      final match = RegExp(r'status code of (\d+)').firstMatch(errorStr);
      final statusCode = match?.group(1);
      if (statusCode != null) {
        return isLog
            ? 'Failed to import profile. Please check your network status or try resetting the subscription link ( HTTP error code: $statusCode )'
            : appLocalizations.profileImportFailed(statusCode);
      }
    }
    return errorStr;
  }
}
