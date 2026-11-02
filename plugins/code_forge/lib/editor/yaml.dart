import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart' show HASH_COMMENT_MODE, Mode;

final Mode editorYamlMode = Mode(
  refs: {
    ...?langYaml.refs,
    '~contains~14': Mode(
      className: 'number',
      begin:
          r'(-?)(\b0[xX][a-fA-F0-9]+|(\b\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?)\b(?=[\s,\]}]|$)',
      relevance: 0,
    ),
  },
  name: langYaml.name,
  caseInsensitive: langYaml.caseInsensitive,
  contains: [
    for (final mode in langYaml.contains ?? const <Mode>[])
      if (mode.ref == '~contains~0')
        Mode(
          scope: 'attr',
          variants: [
            _blockKey(
              r'''[^\s\-?:,\[\]{}#&*!|>'"%@`][^#{}\[\]]*?:(?=[ \t]|$)''',
            ),
            _blockKey(r'"(?:[^"\\]|\\.)*":(?=[ \t]|$)'),
            _blockKey(r"'(?:[^']|'')*':(?=[ \t]|$)"),
          ],
        )
      else if (identical(mode, HASH_COMMENT_MODE))
        Mode(scope: 'comment', begin: r'(?<![^\s])#', end: r'$')
      else
        mode,
  ],
);

Mode _blockKey(String pattern) =>
    Mode(begin: '(?<=^[ \\t]*(?:-[ \\t]+)*)$pattern');
