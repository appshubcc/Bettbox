import 'package:bett_box/common/string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('同一 base64 图标重复解码返回同一字节实例', () {
    const src = 'data:image/png;base64,iVBORw0KGgo=';
    final bytes = src.getBase64;
    expect(bytes, [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    expect(identical(src.getBase64, bytes), isTrue);
  });

  test('非 base64 或内容无效时返回空', () {
    expect('https://example.com/icon.png'.getBase64, isNull);
    expect('data:image/png;base64,'.getBase64, isNull);
    expect('data:image/png;base64,@@@'.getBase64, isNull);
  });
}
