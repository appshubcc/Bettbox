// Copyright (c) 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Inspired by:
// - github.com/chromium/chromium/src/base/file_version_info_win.cc
// - github.com/timsneath/win32/example/filever.dart

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class LANGANDCODEPAGE extends Struct {
  @WORD()
  external int wLanguage;

  @WORD()
  external int wCodePage;
}

class FileVersionInfoData {
  const FileVersionInfoData({required this.lpBlock, required this.lpLang});
  final Pointer<BYTE> lpBlock;
  final Pointer<LANGANDCODEPAGE> lpLang;
}

class FileVersionInfo {
  final String filePath;
  final FileVersionInfoData _data;

  FileVersionInfo(this.filePath) : _data = getData(filePath);

  void dispose() => free(_data.lpBlock);

  String get companyName => getValue('CompanyName');
  String get companyShortName => getValue('CompanyShortName');
  String get productName => getValue('ProductName');
  String get productShortName => getValue('ProductShortName');
  String get internalName => getValue('InternalName');
  String get productVersion => getValue('ProductVersion');
  String get specialBuild => getValue('SpecialBuild');
  String get originalFilename => getValue('OriginalFilename');
  String get fileDescription => getValue('FileDescription');
  String get fileVersion => getValue('FileVersion');

  String getValue(String name) {
    final langCodepages = [
      // try the language and codepage from the EXE
      [_data.lpLang.ref.wLanguage, _data.lpLang.ref.wCodePage],
      // try the default language and codepage from the EXE
      [GetUserDefaultLangID(), _data.lpLang.ref.wCodePage],
      // try the language from the EXE and Latin codepage (most common)
      [_data.lpLang.ref.wLanguage, 1252],
      // try the default language and Latin codepage (most common)
      [GetUserDefaultLangID(), 1252],
    ];

    final lplpBuffer = calloc<LPWSTR>();
    final puLen = calloc<UINT>();
    String toHex4(int val) => val.toRadixString(16).padLeft(4, '0');

    try {
      for (final langCodepage in langCodepages) {
        final lang = toHex4(langCodepage[0]);
        final codepage = toHex4(langCodepage[1]);
        final lpSubBlock = TEXT('\\StringFileInfo\\$lang$codepage\\$name');
        final res =
            VerQueryValue(_data.lpBlock, lpSubBlock, lplpBuffer.cast(), puLen);
        free(lpSubBlock);

        if (res != 0 && lplpBuffer.address != 0 && puLen.value > 0) {
          return lplpBuffer.value.toDartString();
        }
      }

      return '';
    } finally {
      free(lplpBuffer);
      free(puLen);
    }
  }

  static FileVersionInfoData getData(String filePath) {
    if (!File(filePath).existsSync()) {
      throw ArgumentError.value(filePath, 'filePath', 'File not present');
    }

    final lptstrFilename = TEXT(filePath);
    final dwLen = GetFileVersionInfoSize(lptstrFilename, nullptr);

    final lpData = calloc<BYTE>(dwLen); // freed by the dispose() method
    final lpSubBlock = TEXT(r'\VarFileInfo\Translation');
    final lpTranslate = calloc<Pointer<LANGANDCODEPAGE>>();
    final puLen = calloc<UINT>();
    try {
      if (GetFileVersionInfo(lptstrFilename, NULL, dwLen, lpData) == 0) {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }

      if (VerQueryValue(lpData, lpSubBlock, lpTranslate.cast(), puLen) == 0) {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }
      return FileVersionInfoData(lpBlock: lpData, lpLang: lpTranslate.value);
    } finally {
      free(lptstrFilename);
      free(lpTranslate);
      free(lpSubBlock);
      free(puLen);
    }
  }
}
