import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:bett_box/common/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Picker {
  Future<List<PlatformFile>?> pickerFiles({
    bool withData = true,
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    final useCustom = !system.isAndroid &&
        allowedExtensions != null &&
        allowedExtensions.isNotEmpty;
    final filePickerResult = await FilePicker.platform.pickFiles(
      withData: withData,
      allowMultiple: allowMultiple,
      allowedExtensions: useCustom ? allowedExtensions : null,
      type: useCustom ? FileType.custom : FileType.any,
      initialDirectory: await appPath.downloadDirPath,
    );
    return filePickerResult?.files;
  }

  Future<PlatformFile?> pickerFile({
    bool withData = true,
    List<String>? allowedExtensions,
  }) async {
    final files = await pickerFiles(
      withData: withData,
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
    final useCustom = !system.isAndroid &&
        allowedExtensions != null &&
        allowedExtensions.isNotEmpty;
    final path = await FilePicker.platform.saveFile(
      fileName: name,
      initialDirectory: await appPath.downloadDirPath,
      bytes: system.isAndroid ? bytes : null,
      allowedExtensions: useCustom ? allowedExtensions : null,
      type: useCustom ? FileType.custom : FileType.any,
    );
    if (path == null) return null;

    var savePath = path;
    if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
      final hasExt = allowedExtensions.any((ext) => savePath.endsWith('.$ext'));
      if (!hasExt) {
        savePath = '$savePath.${allowedExtensions.first}';
      }
    }

    if (!system.isAndroid) {
      final file = await File(savePath).create(recursive: true);
      await file.writeAsBytes(bytes);
    }
    return savePath;
  }

  Future<String?> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      return null;
    }
    return decodeProfileUrlFromQrImage(xFile.path);
  }

  /// 解码二维码图片，并校验它是可用作订阅的 URL。
  Future<String?> decodeProfileUrlFromQrImage(String path) async {
    final result = await _decodeQrCodeImage(path);
    if (result == null || !result.isUrl) {
      throw appLocalizations.pleaseUploadValidQrcode;
    }
    return result;
  }

  /// mobile_scanner 只实现了 Android / iOS / macOS / Web，Windows 与 Linux 上
  /// 调用原生识别会抛 `MissingPluginException`；原生识别失败或没找到二维码时，
  /// 再退回纯 Dart 解码。
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
        commonPrint.log('Native qr decode failed: $e');
      }
    }
    return qrReader.decodeFile(path);
  }
}

final picker = Picker();
