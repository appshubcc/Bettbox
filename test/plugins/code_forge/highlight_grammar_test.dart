import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/lib/common.dart' as common;
import 'package:re_highlight/languages/lib/javascript.dart' as javascript;
import 'package:re_highlight/re_highlight.dart';

const _grammarPath =
    'plugins/code_forge/rust/src/editor/highlight/javascript.json';

/// The JavaScript grammar as re_highlight compiles it, for the native engine
/// to run: each mode with its rules in the order the matcher tries them.
Map<String, Object?> _export(Mode language) {
  final ids = <Mode, int>{};
  final modes = <Map<String, Object?>>[];

  Map<String, Object?>? scopeOf(dynamic scope) {
    if (scope == null) return null;
    return {
      'wrap': scope.wrap,
      'multi': scope.multi == true,
      'emit': {
        for (final MapEntry<int, bool> entry in (scope.emit ?? {}).entries)
          '${entry.key}': entry.value,
      },
      'positions': {
        for (final MapEntry<int, String?> entry
            in (scope.positions ?? {}).entries)
          '${entry.key}': entry.value,
      },
    };
  }

  String? callbackOf(ModeCallback? callback) {
    if (callback == null) return null;
    if (identical(callback, javascript.callbackOnBegin)) return 'jsx';
    if (identical(callback, common.callbackOnBegin2)) return 'shebang';
    throw StateError('unknown callback');
  }

  int visit(Mode mode) {
    final known = ids[mode];
    if (known != null) return known;
    final id = ids[mode] = modes.length;
    final out = <String, Object?>{};
    modes.add(out);
    if (mode.onEnd != null) throw StateError('onEnd is not supported');
    final dynamic matcher = mode.matcher;
    final keywords = mode.keywords as Map?;
    out.addAll({
      'scope': mode.scope is String && (mode.scope as String).isNotEmpty
          ? mode.scope
          : null,
      'hasScope': mode.scope != null,
      'beginScope': scopeOf(mode.beginScope),
      'endScope': scopeOf(mode.endScope),
      'keywords': keywords == null
          ? null
          : {
              for (final entry in keywords.entries)
                entry.key as String: (entry.value as dynamic).scopeName,
            },
      'keywordPattern': mode.keywordPatternRe?.pattern,
      'end': mode.endRe?.pattern,
      'skip': mode.skip,
      'excludeBegin': mode.excludeBegin == true,
      'excludeEnd': mode.excludeEnd == true,
      'returnBegin': mode.returnBegin == true,
      'returnEnd': mode.returnEnd == true,
      'endsWithParent': mode.endsWithParent == true,
      'endsParent': mode.endsParent == true,
      'subLanguage': mode.subLanguage != null,
      'beforeBegin': mode.beforeBegin != null,
      'onBegin': callbackOf(mode.onBegin),
      'starts': mode.starts == null ? null : visit(mode.starts!),
      'count': matcher.count,
      'rules': [
        for (final List<dynamic> rule in matcher.rules)
          [
            rule.first as String,
            rule.last.type as String,
            rule.last.rule == null ? null : visit(rule.last.rule as Mode),
          ],
      ],
    });
    return id;
  }

  visit(language);
  return {
    'caseInsensitive': language.caseInsensitive == true,
    'unicodeRegex': language.unicodeRegex == true,
    'aliases': language.classNameAliases ?? {},
    'modes': modes,
  };
}

void main() {
  test('the exported JavaScript grammar is the one re_highlight compiles', () {
    final highlight = Highlight()
      ..registerLanguage('javascript', langJavascript);
    highlight.highlight(code: 'x', language: 'javascript');
    final grammar = '${json.encode(_export(langJavascript))}\n';
    final file = File(_grammarPath);
    if (Platform.environment['UPDATE_GRAMMAR'] != null) {
      file.writeAsStringSync(grammar);
    }
    expect(
      file.readAsStringSync(),
      grammar,
      reason: 'run this test with UPDATE_GRAMMAR=1 and rebuild the library',
    );
  });
}
