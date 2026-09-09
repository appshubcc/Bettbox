import 'package:flutter/foundation.dart';

const _spaces = [
  '',
  ' ',
  '  ',
  '   ',
  '    ',
  '     ',
  '      ',
  '       ',
  '        ',
  '         ',
  '          ',
  '           ',
  '            ',
];

const _yamlKeywords = {
  'true',
  'false',
  'yes',
  'no',
  'y',
  'n',
  'on',
  'off',
  'null',
  'nil',
  '~',
  'nan',
  'inf',
  '+inf',
  '-inf',
  'infinity',
  '+infinity',
  '-infinity',
};

const _unsafeLeadingChars = '-?:,[]{}#&*!|>\'"%@`~0123456789+./';

Future<String> encodeYamlTask<T>(T data) async {
  return await compute<T, String>(_encodeYaml, data);
}

Future<String> encodeCompactYamlTask<T>(T data) async {
  return await compute<T, String>(_encodeYaml, data);
}

String _encodeYaml<T>(T content) {
  if (content is Map) {
    if (content.isEmpty) return '{}\n';
    final sb = StringBuffer();
    _writeMap(sb, content, 0);
    return sb.toString();
  }
  if (content is List) {
    if (content.isEmpty) return '[]\n';
    final sb = StringBuffer();
    _writeList(sb, content, 0);
    return sb.toString();
  }
  return '${_formatScalar(content)}\n';
}

bool _needsQuotesForKey(String key) {
  if (key.isEmpty) return true;
  for (int i = 0; i < key.length; i++) {
    final code = key.codeUnitAt(i);
    final isAlphaNumeric = (code >= 97 && code <= 122) ||
        (code >= 65 && code <= 90) ||
        (code >= 48 && code <= 57) ||
        code == 95 ||
        code == 45;
    if (!isAlphaNumeric) return true;
  }
  final first = key.codeUnitAt(0);
  if ((first >= 48 && first <= 57) || first == 45) return true;
  if (_yamlKeywords.contains(key.toLowerCase())) return true;
  return false;
}

bool _needsQuotes(String s) {
  if (s.isEmpty) return true;
  if (s.startsWith(' ') ||
      s.startsWith('\t') ||
      s.endsWith(' ') ||
      s.endsWith('\t')) {
    return true;
  }
  if (_unsafeLeadingChars.contains(s[0])) return true;
  if (_yamlKeywords.contains(s.toLowerCase())) return true;
  if (s.contains(': ') || s.contains(':\t') || s.endsWith(':')) return true;
  if (s.contains(' #') || s.contains('\t#') || s.contains('#')) return true;
  if (s.contains('"') || s.contains("'") || s.contains('\\')) return true;
  if (s.contains('[') ||
      s.contains(']') ||
      s.contains('{') ||
      s.contains('}')) {
    return true;
  }
  if (s.contains('\n') || s.contains('\r') || s.contains('\t')) return true;
  return false;
}

String _escapeString(String s) {
  final sb = StringBuffer('"');
  for (int i = 0; i < s.length; i++) {
    final char = s[i];
    switch (char) {
      case '\\':
        sb.write(r'\\');
        break;
      case '"':
        sb.write(r'\"');
        break;
      case '\n':
        sb.write(r'\n');
        break;
      case '\r':
        sb.write(r'\r');
        break;
      case '\t':
        sb.write(r'\t');
        break;
      default:
        sb.write(char);
    }
  }
  sb.write('"');
  return sb.toString();
}

String _formatKey(dynamic key) {
  final str = key.toString();
  if (_needsQuotesForKey(str)) {
    return _escapeString(str);
  }
  return str;
}

String _formatScalar(dynamic value) {
  if (value == null) return 'null';
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return value.toString();
  final str = value.toString();
  if (_needsQuotes(str)) {
    return _escapeString(str);
  }
  return str;
}

void _writeIndent(StringBuffer sb, int indent) {
  if (indent < _spaces.length) {
    sb.write(_spaces[indent]);
  } else {
    sb.write(' ' * indent);
  }
}

void _writeMap(StringBuffer sb, Map map, int indent) {
  for (final entry in map.entries) {
    final key = _formatKey(entry.key);
    final val = entry.value;
    _writeIndent(sb, indent);
    sb.write(key);
    if (val is Map) {
      if (val.isEmpty) {
        sb.write(': {}\n');
      } else {
        sb.write(':\n');
        _writeMap(sb, val, indent + 2);
      }
    } else if (val is List) {
      if (val.isEmpty) {
        sb.write(': []\n');
      } else {
        sb.write(':\n');
        _writeList(sb, val, indent + 2);
      }
    } else {
      sb.write(': ');
      sb.write(_formatScalar(val));
      sb.write('\n');
    }
  }
}

void _writeList(StringBuffer sb, List list, int indent) {
  for (final item in list) {
    if (item is Map) {
      if (item.isEmpty) {
        _writeIndent(sb, indent);
        sb.write('- {}\n');
      } else {
        var isFirst = true;
        for (final entry in item.entries) {
          final key = _formatKey(entry.key);
          final val = entry.value;
          _writeIndent(sb, isFirst ? indent : indent + 2);
          if (isFirst) {
            sb.write('- ');
            isFirst = false;
          }
          sb.write(key);
          if (val is Map) {
            if (val.isEmpty) {
              sb.write(': {}\n');
            } else {
              sb.write(':\n');
              _writeMap(sb, val, indent + 4);
            }
          } else if (val is List) {
            if (val.isEmpty) {
              sb.write(': []\n');
            } else {
              sb.write(':\n');
              _writeList(sb, val, indent + 4);
            }
          } else {
            sb.write(': ');
            sb.write(_formatScalar(val));
            sb.write('\n');
          }
        }
      }
    } else if (item is List) {
      if (item.isEmpty) {
        _writeIndent(sb, indent);
        sb.write('- []\n');
      } else {
        _writeIndent(sb, indent);
        sb.write('-\n');
        _writeList(sb, item, indent + 2);
      }
    } else {
      _writeIndent(sb, indent);
      sb.write('- ');
      sb.write(_formatScalar(item));
      sb.write('\n');
    }
  }
}
