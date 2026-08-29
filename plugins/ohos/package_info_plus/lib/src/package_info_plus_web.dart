import 'dart:convert';
import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

/// The web implementation of [PackageInfoPlatform].
///
/// This class implements the `package:package_info_plus` functionality for the web.
class PackageInfoPlusWebPlugin extends PackageInfoPlatform {
  final Client? _client;

  /// Create plugin with http client.
  PackageInfoPlusWebPlugin([this._client]);

  /// Registers this class as the default instance of [PackageInfoPlatform].
  static void registerWith(Registrar registrar) {
    PackageInfoPlatform.instance = PackageInfoPlusWebPlugin();
  }

  /// Get version.json full url.
  Uri versionJsonUrl(String baseUrl, int cacheBuster) {
    final baseUri = Uri.parse(baseUrl);
    final regExp = RegExp(r'[^/]+\.html.*');
    final originPath =
        '${baseUri._origin}${baseUri.path.replaceAll(regExp, '')}';
    final versionJson = 'version.json?cachebuster=$cacheBuster';
    return Uri.parse(originPath.endsWith('/')
        ? '$originPath$versionJson'
        : '$originPath/$versionJson');
  }

  @override
  Future<PackageInfoData> getAll() async {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final url = versionJsonUrl(window.document.baseUri!, cacheBuster);
    final response = _client == null ? await get(url) : await _client!.get(url);
    final versionMap = _getVersionMap(response);

    return PackageInfoData(
      appName: versionMap['app_name'] ?? '',
      version: versionMap['version'] ?? '',
      buildNumber: versionMap['build_number'] ?? '',
      packageName: versionMap['package_name'] ?? '',
      // will remain empty on web
      buildSignature: '',
    );
  }

  Map<String, dynamic> _getVersionMap(Response response) {
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return <String, dynamic>{};
      }
    } else {
      return <String, dynamic>{};
    }
  }
}

extension _UriOrigin on Uri {
  /// Get origin.
  ///
  /// This is different from [Uri.origin] because that has checks to prevent
  /// non-http/https use-cases.
  String get _origin {
    if (isScheme('chrome-extension')) {
      return '$scheme://$host';
    }
    return origin;
  }
}
