import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:path/path.dart';

class UiManager {
  static UiManager? _instance;
  Future<void>? _initFuture;

  UiManager._internal();

  factory UiManager() {
    _instance ??= UiManager._internal();
    return _instance!;
  }

  Future<void> initializeUI() {
    return _initFuture ??= _initializeUI().catchError((Object e) {
      _initFuture = null;
      commonPrint.error('Failed to initialize UI: $e');
    });
  }

  Future<void> _initializeUI() async {
    try {
      final uiPath = await appPath.uiPath;
      final uiDir = Directory(uiPath);
      final versionFile = File(join(uiPath, '.ui_version'));
      final appVersionFile = File(
        join(File(uiPath).parent.path, '.ui_app_version'),
      );
      final currentVersion = globalState.packageInfo.version;

      if (await uiDir.exists() && (await uiDir.list().toList()).isNotEmpty) {
        final deployedVersion = await appVersionFile.exists()
            ? (await appVersionFile.readAsString()).trim()
            : null;
        if (deployedVersion == currentVersion) {
          commonPrint.log('UI already up to date (v$currentVersion)');
          return;
        }
        if (!await versionFile.exists()) {
          commonPrint.log('UI managed by user, skip restore');
          await appVersionFile.writeAsString(currentVersion);
          return;
        }
        commonPrint.log(
          'UI version mismatch: $deployedVersion -> $currentVersion',
        );
        await clearUI();
      }

      commonPrint.log('Extracting UI from assets...');

      await uiDir.create(recursive: true);

      final zipData = await rootBundle.load('assets/data/zash.zip');

      final bytes = Uint8List.fromList(zipData.buffer.asUint8List());

      final tempPath = await appPath.tempPath;
      final tempExtractPath = join(
        tempPath,
        'ui_extract_${DateTime.now().millisecondsSinceEpoch}',
      );

      await Isolate.run(() async {
        final tempExtractDir = Directory(tempExtractPath);
        await tempExtractDir.create(recursive: true);

        try {
          final archive = ZipDecoder().decodeBytes(bytes);

          for (final file in archive) {
            final filename = file.name;
            final filePath = join(tempExtractPath, filename);

            if (file.isFile) {
              final outFile = File(filePath);
              await outFile.create(recursive: true);
              await outFile.writeAsBytes(file.content as List<int>);
            } else {
              await Directory(filePath).create(recursive: true);
            }
          }

          final extractedFiles = await tempExtractDir.list().toList();
          String sourceDir = tempExtractPath;

          if (extractedFiles.length == 1 && extractedFiles.first is Directory) {
            sourceDir = extractedFiles.first.path;
          }

          await _copyDirectory(Directory(sourceDir), Directory(uiPath));

          final vFile = File(join(uiPath, '.ui_version'));
          await vFile.writeAsString(currentVersion);
        } finally {
          if (await tempExtractDir.exists()) {
            await tempExtractDir.delete(recursive: true);
          }
        }
      });

      await appVersionFile.writeAsString(currentVersion);

      commonPrint.log(
        'UI extracted successfully to: $uiPath (v$currentVersion)',
      );
    } catch (e) {
      commonPrint.error('Error extracting UI: $e');
      rethrow;
    }
  }

  static Future<void> _copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(
          join(destination.path, basename(entity.path)),
        );
        await newDirectory.create(recursive: true);
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        final newFile = File(join(destination.path, basename(entity.path)));
        await entity.copy(newFile.path);
      }
    }
  }

  Future<void> clearUI() async {
    try {
      final uiPath = await appPath.uiPath;
      final uiDir = Directory(uiPath);

      if (await uiDir.exists()) {
        await uiDir.delete(recursive: true);
        commonPrint.log('UI cleared successfully');
      }
    } catch (e) {
      commonPrint.warn('Error clearing UI: $e');
    }
  }
}

final uiManager = UiManager();
