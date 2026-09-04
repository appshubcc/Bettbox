import 'package:bett_box/common/stoverride.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Surge stoverride mitm hosts and rewrite', () {
    const source = '''
name: biliad
http:
  mitm:
    - app.bilibili.com
    - "*.biliapi.net"
    - -broadcast.chat.bilibili.com
  rewrite:
    - ^https://app.bilibili.com/x/v2/splash/show - reject-dict
  script:
    - match: https://example.com
      name: x
script-providers:
  x:
    url: https://example.com/x.js
''';
    final parsed = parseStOverride(source);
    expect(parsed.name, 'biliad');
    expect(parsed.hosts, contains('app.bilibili.com'));
    expect(parsed.hosts, contains('*.biliapi.net'));
    expect(parsed.rewrite.single, contains('reject-dict'));
    expect(parsed.ignoredScripts, isTrue);
  });

  test('mergeUnique keeps order and drops duplicates', () {
    expect(
      mergeUnique(['a', 'b'], ['b', 'c']),
      ['a', 'b', 'c'],
    );
  });
}
