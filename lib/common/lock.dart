import 'dart:io';

import 'package:bett_box/common/common.dart';

class SingleInstanceLock {
  static SingleInstanceLock? _instance;
  RandomAccessFile? _accessFile;

  SingleInstanceLock._internal();

  factory SingleInstanceLock() {
    _instance ??= SingleInstanceLock._internal();
    return _instance!;
  }

  Future<bool> acquire() async {
    for (int i = 0; i < 3; i++) {
      try {
        final lockFilePath = await appPath.lockFilePath;
        final lockFile = File(lockFilePath);
        await lockFile.create(recursive: true);
        _accessFile = await lockFile.open(mode: FileMode.write);
        await _accessFile?.lock();
        return true;
      } catch (e) {
        commonPrint.log('SingleInstanceLock acquire attempt ${i + 1} failed: $e');
        if (i < 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    return false;
  }
}

final singleInstanceLock = SingleInstanceLock();
