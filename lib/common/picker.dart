import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:bett_box/common/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Picker {
  Future<List<PlatformFile>?> pickerFiles({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    final useCustom =
        !system.isAndroid &&
        allowedExtensions != null &&
        allowedExtensions.isNotEmpty;
    if (system.isMacOS) {
      await FilePicker.skipEntitlementsChecks();
    }
    if (allowMultiple) {
      final files = await FilePicker.pickFiles(
        allowedExtensions: useCustom ? allowedExtensions : null,
        type: useCustom ? FileType.custom : FileType.any,
        initialDirectory: await appPath.downloadDirPath,
      );
      return files.isEmpty ? null : files;
    } else {
      final file = await FilePicker.pickFile(
        allowedExtensions: useCustom ? allowedExtensions : null,
        type: useCustom ? FileType.custom : FileType.any,
        initialDirectory: await appPath.downloadDirPath,
      );
      return file != null ? [file] : null;
    }
  }

  Future<PlatformFile?> pickerFile({List<String>? allowedExtensions}) async {
    final files = await pickerFiles(
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
    );
    return files != null && files.isNotEmpty ? files.first : null;
  }

  Future<String?> saveFile(
    String fileName,
    Uint8List bytes, {
    List<String>? allowedExtensions,
  }) async {
    var name = fileName;
    if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
      final hasExt = allowedExtensions.any((ext) => name.endsWith('.$ext'));
      if (!hasExt) {
        name = '$name.${allowedExtensions.first}';
      }
    }
    if (system.isMacOS) {
      await FilePicker.skipEntitlementsChecks();
    }
    final uri = await FilePicker.saveFile(
      fileName: name,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    if (uri == null) return null;
    if (uri.scheme != 'file') return uri.path;

    final path = uri.toFilePath();
    if (allowedExtensions == null || allowedExtensions.isEmpty) return path;
    if (allowedExtensions.any((ext) => path.endsWith('.$ext'))) return path;
    final savePath = '$path.${allowedExtensions.first}';
    await File(path).rename(savePath);
    return savePath;
  }

  Future<String?> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      return null;
    }
    return decodeProfileUrlFromQrImage(xFile.path);
  }

  Future<String?> decodeProfileUrlFromQrImage(String path) async {
    final result = await _decodeQrCodeImage(path);
    if (result == null || !result.isUrl) {
      throw appLocalizations.pleaseUploadValidQrcode;
    }
    return result;
  }

  Future<String?> _decodeQrCodeImage(String path) async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      try {
        final capture = await MobileScannerController().analyzeImage(
          path,
          formats: const [BarcodeFormat.qrCode],
        );
        final barcodes = capture?.barcodes;
        final result = barcodes == null || barcodes.isEmpty
            ? null
            : barcodes.first.rawValue;
        if (result != null && result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        commonPrint.warn('Native qr decode failed: $e');
      }
    }
    return Isolate.run(() => qrReader.decodeFile(path));
  }
}

final picker = Picker();
