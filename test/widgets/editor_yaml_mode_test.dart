import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import '../plugins/code_forge/support.dart';

void main() {
  setUpAll(initEditorNative);

  final highlighter = SyntaxHighlighter(
    language: editorYamlMode,
    editorTheme: atomOneLightTheme,
  );
  final comment = atomOneLightTheme['comment']?.color;

  Map<String, Color?> colors(String line) {
    final result = <String, Color?>{};
    highlighter.lineSpan(line)?.visitChildren((span) {
      if (span is TextSpan && span.text != null) {
        result[span.text ?? ''] = span.style?.color;
      }
      return true;
    });
    return result;
  }

  test('a hash inside a value is not a comment', () {
    for (final line in [
      '    - 114.114.114.114#DIRECT',
      '    - tls://223.5.5.5#DIRECT',
      'port: 7890#x',
    ]) {
      expect(colors(line).values, isNot(contains(comment)), reason: line);
    }
    expect(colors('    - 114.114.114.114#DIRECT').keys, [
      '    ',
      '-',
      ' ',
      '114.114.114.114#DIRECT',
    ]);
  });

  test('a hash after whitespace or at the line start is a comment', () {
    expect(colors('port: 7890 # mixed')['# mixed'], comment);
    expect(colors('# whole line')['# whole line'], comment);
    expect(colors('  # indented')['# indented'], comment);
  });

  test('block keys may hold commas, symbols and non-ASCII text', () {
    final attr = atomOneLightTheme['attr']?.color;
    for (final (line, key) in [
      ('    rule-set:epicgames,cn:', 'rule-set:epicgames,cn:'),
      ('    "geosite:cn,private": [223.5.5.5]', '"geosite:cn,private":'),
      ("  '+.mcdn.bilivideo.com': ['0.0.0.0']", "'+.mcdn.bilivideo.com':"),
      ('  geolocation-!cn:', 'geolocation-!cn:'),
      ('    <<: *base', '<<:'),
      ('  - 节点: 值', '节点:'),
    ]) {
      expect(colors(line)[key], attr, reason: line);
    }
  });

  test('only the start of a line or a flow mapping holds a key', () {
    expect(
      colors('description: see a: b')['a:'],
      atomOneLightTheme['string']?.color,
    );
    expect(colors('- {name: a, b: c}')['b:'], atomOneLightTheme['attr']?.color);
  });

  test('numbers keep their color on their own', () {
    final number = atomOneLightTheme['number']?.color;
    expect(colors('port: 7890')['7890'], number);
    expect(colors('ports: [80, 443]')['80'], number);
  });
}
