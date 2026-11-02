import 'dart:io';
import 'dart:math';

import 'package:code_forge/code_forge.dart' show editorYamlMode;
import 'package:code_forge/src/rust/api/editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/re_highlight.dart';

import 'support.dart';

const _scopes = [
  'attr',
  'meta',
  'string',
  'type',
  'bullet',
  'comment',
  'doctag',
  'literal',
  'number',
  'template-variable',
];

class _Scopes implements HighlightRenderer {
  final units = <String?>[];
  final _open = <String?>[];

  @override
  void addText(String text) {
    final scope = _open.lastWhere((scope) => scope != null, orElse: () => null);
    units.addAll(List.filled(text.length, _open.isEmpty ? null : scope));
  }

  @override
  void openNode(DataNode node) => _open.add(node.scope);

  @override
  void closeNode(DataNode node) => _open.removeLast();
}

final _reference = Highlight()
  ..registerLanguage('yaml', editorYamlMode)
  ..registerLanguage('javascript', langJavascript);

List<String?> _expected(String line, String language) {
  final renderer = _Scopes();
  _reference.highlight(code: line, language: language).render(renderer);
  return renderer.units;
}

final List<String> _javascriptScopes = highlightJavascriptScopes();
var _left = 0;

/// Null for a line the native engine leaves to re_highlight.
List<String?>? _actual(String line, String language) {
  final yaml = language == 'yaml';
  final tokens = yaml
      ? highlightYamlLine(text: line)
      : highlightJavascriptLine(text: line);
  if (tokens == null) {
    _left++;
    return null;
  }
  final scopes = yaml ? _scopes : _javascriptScopes;
  final units = List<String?>.filled(line.length, null);
  for (var i = 0; i < tokens.length; i += 3) {
    units.fillRange(tokens[i], tokens[i + 1], scopes[tokens[i + 2]]);
  }
  return units;
}

String _describe(String line, List<String?> units) {
  final buffer = StringBuffer();
  var start = 0;
  for (var i = 1; i <= units.length; i++) {
    if (i < units.length && units[i] == units[start]) continue;
    buffer.write('[${units[start] ?? '-'}:${line.substring(start, i)}]');
    start = i;
  }
  return buffer.toString();
}

void _expectSame(String line, [String language = 'yaml']) {
  final actual = _actual(line, language);
  if (actual == null) return;
  final expected = _expected(line, language);
  if (expected.length == actual.length &&
      Iterable.generate(
        expected.length,
      ).every((i) => expected[i] == actual[i])) {
    return;
  }
  fail(
    'line     ${line.runes.map((r) => r < 32 || r > 126 ? '\\u{${r.toRadixString(16)}}' : String.fromCharCode(r)).join()}\n'
    'expected ${_describe(line, expected)}\n'
    'actual   ${_describe(line, actual)}',
  );
}

const _alphabet = [
  'a',
  'b',
  'T',
  'Z',
  'e',
  'x',
  'n',
  'o',
  '0',
  '1',
  '2',
  '9',
  ' ',
  ' ',
  ' ',
  '\t',
  ':',
  ':',
  '-',
  '-',
  '.',
  ',',
  ',',
  '{',
  '}',
  '[',
  ']',
  "'",
  '"',
  '#',
  '!',
  '&',
  '*',
  '%',
  '<',
  '>',
  '\\',
  '/',
  '+',
  '=',
  '@',
  '_',
  '|',
  '?',
  '`',
  '节',
  '😀',
  ' ',
];

const _words = [
  'true',
  'false',
  'yes',
  'no',
  'null',
  'True',
  'NULL',
  'name: ',
  'port: 443',
  '- ',
  '---',
  '{{',
  '}}',
  '%{',
  '<%',
  '%>',
  '!!str',
  '!<a>',
  '!a!b',
  '&anchor',
  '*alias',
  '# ',
  'TODO:',
  'fixme:',
  ' is so it ',
  " it's a well-known thing. ",
  '2024-01-02',
  '2024-01-02T03:04:05Z',
  '12:30:00',
  '0x1F',
  '1.5e3',
  '.5',
  '-7',
  '127.0.0.1',
  "'a: b'",
  '"k":',
  "'k': ",
  'https://a.b/c',
  'rule-set:a,b: ',
  "'+.a.com': ",
  '"k\\"x": ',
  "'it''s': ",
  '<<: ',
  '- - ',
  '\r',
  ' ',
];

String _randomLine(Random random) {
  final buffer = StringBuffer();
  final parts = 1 + random.nextInt(14);
  for (var i = 0; i < parts; i++) {
    buffer.write(
      random.nextInt(3) == 0
          ? _words[random.nextInt(_words.length)]
          : _alphabet[random.nextInt(_alphabet.length)],
    );
  }
  return buffer.toString();
}

const _javascriptAlphabet = [
  'a',
  'b',
  'x',
  'A',
  'B',
  '_',
  r'$',
  '0',
  '1',
  '9',
  ' ',
  ' ',
  ' ',
  '\t',
  '(',
  ')',
  '(',
  ')',
  '{',
  '}',
  '[',
  ']',
  '<',
  '>',
  '=',
  '=',
  '+',
  '-',
  '*',
  '/',
  '/',
  '%',
  '!',
  '&',
  '|',
  '^',
  '~',
  '?',
  ':',
  ';',
  ',',
  '.',
  '.',
  '#',
  '@',
  "'",
  '"',
  '`',
  '\\',
  '节',
  '😀',
];

const _javascriptWords = [
  'function ',
  'function',
  'const ',
  'let ',
  'var ',
  'return ',
  'class ',
  ' extends ',
  'new ',
  'async ',
  'await ',
  'if (',
  'for (',
  'while (',
  'case ',
  'throw ',
  'typeof ',
  'import ',
  'export default ',
  ' from ',
  'true',
  'false',
  'null',
  'undefined',
  'this',
  'super',
  'constructor(',
  'get ',
  'set ',
  'static ',
  '=> ',
  '=>',
  '...',
  '?.',
  '??',
  '===',
  '!==',
  '&&',
  '||',
  '++',
  '// ',
  '/* ',
  '*/',
  '/** @param {string} name the name */',
  'TODO:',
  '@returns ',
  'console.log(',
  'Math.max(',
  'JSON.parse(',
  'Object.keys(',
  'Array',
  'Promise',
  'config.proxies',
  "'use strict'",
  '#!/usr/bin/env node',
  r'${',
  r'`a ${b} c`',
  '/ab+c/gi',
  '/[/]\\//',
  '0x1F',
  '1e3',
  '.5',
  '1_000',
  '0b101',
  '12n',
  '3.14',
  'MAX_VALUE',
  'Foo',
  'fooBar',
  'foo(',
  'foo (a, b) {',
  '(a, b) => ',
  'a => ',
  '<div>',
  '</div>',
  '<A />',
  '<T,',
  '<a b="c">',
  'prototype',
  r'$1',
  'html`',
  'css`',
  ' = ',
  ': ',
  '; ',
  ', ',
  'main(config)',
  '.map((x) => x.name)',
];

String _randomJavascriptLine(Random random) {
  final buffer = StringBuffer();
  final parts = 1 + random.nextInt(12);
  for (var i = 0; i < parts; i++) {
    buffer.write(
      random.nextInt(5) < 3
          ? _javascriptWords[random.nextInt(_javascriptWords.length)]
          : _javascriptAlphabet[random.nextInt(_javascriptAlphabet.length)],
    );
  }
  return buffer.toString();
}

void main() {
  setUpAll(initEditorNative);

  test('JavaScript lines get the scopes re_highlight gives them', () {
    const lines = [
      'function main(config) {',
      '  const proxies = config.proxies || [];',
      '  const name = `节点 \${index + 1} 😀`;',
      '  return proxies.filter((proxy) => !/过期|剩余/i.test(proxy.name));',
      "  if (typeof value === 'string' && value.length > 0x10) return null;",
      '  // TODO: tidy this up, as it is not the way to do it',
      '  /** @param {string} name the group name */',
      'class Group extends Base {',
      '  constructor(name, ...rest) { super(name); this.rest = rest; }',
      '  static get size() { return Object.keys(MAX_SIZE).length; }',
      'const build = async (name, options = {}) => ({ name, ...options });',
      "export default { 'mixed-port': 7890, dns: { enable: true } };",
      'const view = <Item key={id} />;',
    ];
    _left = 0;
    for (final line in lines) {
      _expectSame(line, 'javascript');
    }
    expect(_left, 0);
  });

  test('random JavaScript lines get the scopes re_highlight gives them', () {
    final random = Random(20261012);
    final count = int.parse(Platform.environment['HIGHLIGHT_FUZZ'] ?? '20000');
    _left = 0;
    for (var i = 0; i < count; i++) {
      _expectSame(_randomJavascriptLine(random), 'javascript');
    }
    printOnFailure('left to re_highlight: $_left of $count');
    expect(_left, lessThan(count ~/ 50));
  });

  test('the lines of given scripts get the scopes re_highlight gives them', () {
    final paths = Platform.environment['HIGHLIGHT_SCRIPTS'];
    if (paths == null) return;
    _left = 0;
    var total = 0;
    for (final path in paths.split(':')) {
      for (final line in File(path).readAsStringSync().split('\n').toSet()) {
        total++;
        _expectSame(line, 'javascript');
      }
    }
    expect(_left, lessThan(total ~/ 100 + 1));
  });

  test('YAML lines get the scopes re_highlight gives them', () {
    const lines = [
      '',
      'proxies:',
      '  - name: "节点 😀 01"',
      "  - {name: 'a', type: vmess, server: a.example.com, port: 443, tls: true}",
      '  - { name: a, alpn: [h2, http/1.1], ws-opts: { path: /x, headers: { Host: a.b } } }',
      'mixed-port: 7890 # TODO: change it, as it is not the one to use',
      'dns: {enable: true, nameserver: [1.1.1.1, tls://dns.google], x: null}',
      "  url: 'http://a/b?c={{d}}&e=%{f}' # note: x",
      '---',
      'key: !!str value',
      'base: &base',
      '  <<: *base',
      'time: 2024-01-02T03:04:05Z',
      'a: {b: {{c}}{{d}}\\e, f: [g}h], i]j}',
      "unterminated: 'abc {{ def",
      '节点: 值',
      '- DOMAIN-SUFFIX,example.com,DIRECT',
      '<%= ruby %> after',
    ];
    lines.forEach(_expectSame);
  });

  test('random lines get the scopes re_highlight gives them', () {
    final random = Random(20261012);
    final count = int.parse(Platform.environment['HIGHLIGHT_FUZZ'] ?? '20000');
    for (var i = 0; i < count; i++) {
      _expectSame(_randomLine(random));
    }
  });

  test('the lines of given files get the scopes re_highlight gives them', () {
    final paths = Platform.environment['HIGHLIGHT_FILES'];
    if (paths == null) return;
    for (final path in paths.split(':')) {
      File(path).readAsStringSync().split('\n').toSet().forEach(_expectSame);
    }
  });
}
