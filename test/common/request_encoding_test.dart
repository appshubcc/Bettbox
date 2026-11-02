import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _content = 'mixed-port: 7890\nmode: rule\n';

void main() {
  late ServerSocket server;
  late Directory home;
  late String url;
  final acceptEncodings = <String>[];
  var duplicateEncoding = true;

  void serve(Socket socket) {
    final buffer = BytesBuilder();
    var handled = false;
    socket.listen((chunk) async {
      if (handled) return;
      buffer.add(chunk);
      final head = latin1.decode(buffer.toBytes());
      if (!head.contains('\r\n\r\n')) return;
      handled = true;
      final acceptEncoding =
          RegExp(
            r'^accept-encoding:\s*([^\r\n]*)',
            caseSensitive: false,
            multiLine: true,
          ).firstMatch(head)?.group(1)?.trim() ??
          '';
      acceptEncodings.add(acceptEncoding);
      final gzipped = acceptEncoding.contains('gzip');
      final body = gzipped
          ? gzip.encode(utf8.encode(_content))
          : utf8.encode(_content);
      final encodings = [
        if (gzipped) 'gzip',
        if (!gzipped || duplicateEncoding) 'identity',
      ];
      socket
        ..add(
          latin1.encode(
            [
              'HTTP/1.1 200 OK',
              'Content-Type: text/plain',
              for (final encoding in encodings) 'Content-Encoding: $encoding',
              'Content-Length: ${body.length}',
              'Connection: close',
              '',
              '',
            ].join('\r\n'),
          ),
        )
        ..add(body);
      await socket.close();
    }, onError: (_) {});
  }

  setUpAll(() async {
    globalState.packageInfo = PackageInfo(
      appName: 'Bettbox',
      packageName: 'com.appshub.bettbox',
      version: '1.0.0',
      buildNumber: '1',
    );
    home = await Directory.systemTemp.createTemp('bettbox_request_');
    server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(serve);
    url = 'http://127.0.0.1:${server.port}/clash.yaml';
  });

  tearDownAll(() async {
    await server.close();
    await home.delete(recursive: true);
  });

  setUp(() {
    acceptEncodings.clear();
    duplicateEncoding = true;
  });

  test('content-encoding 多值时下载订阅改用 identity 重试', () async {
    final path = '${home.path}/profile.download';
    final source = await request.fetchProfileSource(url, path);

    expect(acceptEncodings, ['gzip', 'identity']);
    expect(source.headers?['content-encoding'], ['identity']);
    expect(await File(path).readAsString(), _content);
  });

  test('content-encoding 多值时文本请求改用 identity 重试', () async {
    final response = await request.getTextResponseForUrl(url);

    expect(acceptEncodings, ['gzip', 'identity']);
    expect(response.data, _content);
  });

  test('正常 gzip 响应不重试', () async {
    duplicateEncoding = false;
    final response = await request.getTextResponseForUrl(url);

    expect(acceptEncodings, ['gzip']);
    expect(response.data, _content);
  });
}
