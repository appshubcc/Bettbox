import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/re_highlight.dart';

import 'package:code_forge/src/rust/api/editor.dart';

import 'yaml.dart';

/// This class provides styling options for code selection in the code editor.
class CodeSelectionStyle {
  /// The color of the cursor line, defaults to the highlight theme text color.
  final Color? cursorColor;

  /// The color used to highlight selected text in the code editor.
  final Color selectionColor;

  /// The color of the cursor bubble that appears when selecting text.
  final Color cursorBubbleColor;

  CodeSelectionStyle({
    this.cursorColor,
    this.selectionColor = const Color(0x6E2195F3),
    this.cursorBubbleColor = Colors.blue,
  });
}

/// This class provides styling options for the Gutter.
class GutterStyle {
  /// The background color of the gutter bar.
  final Color? backgroundColor;

  /// The color of the fold indicator icons. Defaults to the line number color.
  final Color? foldIconColor;

  /// The text style of the line numbers. Defaults to the editor's text style;
  /// a missing color comes from the theme.
  final TextStyle? lineNumberStyle;

  final Color? dividerColor;

  const GutterStyle({
    this.backgroundColor,
    this.foldIconColor,
    this.lineNumberStyle,
    this.dividerColor,
  });
}

typedef _UiStyleKey = (ui.Color, ui.FontWeight?, ui.FontStyle?);

/// Highlights each line on its own, so a line's spans follow from its text
/// alone and are cached by it.
class SyntaxHighlighter {
  /// re_highlight slows with the square of line length; longer lines stay plain.
  static const maxHighlightedLineLength = 4096;

  static bool isPlain(String lineText) =>
      lineText.length > maxHighlightedLineLength;

  static const _maxCachedLines = 8000;
  static const _evictedLines = _maxCachedLines ~/ 4;
  static const _maxInlineBatchChars = 2000;

  final Mode language;
  final Map<String, TextStyle> editorTheme;
  final TextStyle? baseTextStyle;
  final Map<String, TextSpan?> _spans = {};
  late final _grammar = _Grammar(
    language,
    _resolveTheme(editorTheme),
    baseTextStyle,
  );
  final Map<_UiStyleKey, ui.TextStyle> _uiStyles = {};
  late final TextStyle? _baseStyle = baseTextStyle ?? editorTheme['root'];
  late final ui.Color _fallbackColor =
      editorTheme['root']?.color ?? Colors.black;
  double? _uiStyleSize;
  String? _uiStyleFamily;
  Future<void>? _pending;

  SyntaxHighlighter({
    required this.language,
    required this.editorTheme,
    this.baseTextStyle,
  });

  bool hasLineSpan(String lineText) =>
      isPlain(lineText) || _spans.containsKey(lineText);

  TextSpan? lineSpan(String lineText) {
    if (isPlain(lineText)) return null;
    final cached = _spans[lineText];
    if (cached != null || _spans.containsKey(lineText)) return cached;
    return _remember(lineText, _grammar.highlight(lineText));
  }

  TextSpan? _remember(String lineText, TextSpan? span) {
    if (_spans.length >= _maxCachedLines) {
      for (final key in _spans.keys.take(_evictedLines).toList()) {
        _spans.remove(key);
      }
    }
    return _spans[lineText] = span;
  }

  ui.Paragraph buildHighlightedParagraph(
    String lineText,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
    bool allowSynchronousHighlight = true,
  }) {
    final span = allowSynchronousHighlight
        ? lineSpan(lineText)
        : _spans[lineText];
    if (span == null || lineText.isEmpty) {
      return buildPlainParagraph(
        lineText,
        paragraphStyle,
        fontSize,
        fontFamily,
        width: width,
      );
    }

    final builder = ui.ParagraphBuilder(paragraphStyle);
    _addTextSpanToBuilder(builder, span, fontSize, fontFamily);

    final p = builder.build();
    p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
    return p;
  }

  TextSpan blockCommentSpan(String lineText) {
    final comment = _grammar.theme['comment'] ?? baseTextStyle;
    final close = lineText.indexOf('*/');
    if (close < 0 || close + 2 >= lineText.length) {
      return TextSpan(text: lineText, style: comment);
    }
    final rest = lineText.substring(close + 2);
    return TextSpan(
      children: [
        TextSpan(text: lineText.substring(0, close + 2), style: comment),
        lineSpan(rest) ?? TextSpan(text: rest),
      ],
    );
  }

  ui.Paragraph buildBlockCommentParagraph(
    String lineText,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
  }) {
    if (lineText.isEmpty || isPlain(lineText)) {
      return buildPlainParagraph(
        lineText,
        paragraphStyle,
        fontSize,
        fontFamily,
        width: width,
      );
    }
    final builder = ui.ParagraphBuilder(paragraphStyle);
    _addTextSpanToBuilder(
      builder,
      blockCommentSpan(lineText),
      fontSize,
      fontFamily,
    );
    return builder.build()
      ..layout(ui.ParagraphConstraints(width: width ?? double.infinity));
  }

  ui.Paragraph buildPlainParagraph(
    String text,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
  }) {
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(_getUiTextStyle(fontSize, fontFamily))
      ..addText(text.isEmpty ? ' ' : text);
    return builder.build()
      ..layout(ui.ParagraphConstraints(width: width ?? double.infinity));
  }

  void _addTextSpanToBuilder(
    ui.ParagraphBuilder builder,
    TextSpan span,
    double fontSize,
    String? fontFamily, {
    TextStyle? inheritedStyle,
  }) {
    final effectiveStyle = (inheritedStyle ?? _baseStyle ?? const TextStyle())
        .merge(span.style);
    final style = _textStyleToUiStyle(effectiveStyle, fontSize, fontFamily);
    builder.pushStyle(style);

    if (span.text != null) {
      builder.addText(span.text!);
    }

    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan) {
          _addTextSpanToBuilder(
            builder,
            child,
            fontSize,
            fontFamily,
            inheritedStyle: effectiveStyle,
          );
        }
      }
    }

    builder.pop();
  }

  ui.TextStyle _textStyleToUiStyle(
    TextStyle? style,
    double fontSize,
    String? fontFamily,
  ) {
    if (fontSize != _uiStyleSize || fontFamily != _uiStyleFamily) {
      _uiStyles.clear();
      _uiStyleSize = fontSize;
      _uiStyleFamily = fontFamily;
    }
    final color = style?.color ?? _fallbackColor;
    final fontWeight = style?.fontWeight;
    final fontStyle = style?.fontStyle;
    return _uiStyles[(color, fontWeight, fontStyle)] ??= ui.TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontFamilyFallback: baseTextStyle?.fontFamilyFallback,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  ui.TextStyle _getUiTextStyle(double fontSize, String? fontFamily) =>
      _textStyleToUiStyle(_baseStyle, fontSize, fontFamily);

  /// A call while one runs joins it, leaving its own lines to the next paint.
  Future<void> preHighlightLines(
    List<int> lines,
    String Function(int) getLineText,
  ) => _pending ??= _preHighlight(
    lines,
    getLineText,
  ).whenComplete(() => _pending = null);

  Future<void> _preHighlight(
    List<int> lines,
    String Function(int) getLineText,
  ) async {
    final pending = {
      for (final line in lines)
        if (getLineText(line) case final text when !hasLineSpan(text)) text,
    }.toList();
    if (pending.isEmpty) return;
    final chars = pending.fold(0, (sum, text) => sum + text.length);
    if (_grammar.isNative || chars < _maxInlineBatchChars) {
      for (final text in pending) {
        lineSpan(text);
      }
      return;
    }
    final spans = await compute(_grammar.highlightAll, pending);
    for (final (index, text) in pending.indexed) {
      _remember(text, spans[index]);
    }
  }

  void dispose() => _spans.clear();
}

Map<String, TextStyle> _resolveTheme(Map<String, TextStyle> theme) => {
  ...theme,
  if (!theme.containsKey('tag'))
    'tag': ?(theme['selector-tag'] ?? theme['name']),
};

class _Grammar {
  _Grammar(this.language, this.theme, this.base);

  final Mode language;
  final Map<String, TextStyle> theme;
  final TextStyle? base;
  late final String _id = language.hashCode.toString();
  late final Highlight _highlight = Highlight()
    ..registerLanguage(_id, language);

  /// YAML and JavaScript are scanned natively, which gives a line the scopes
  /// re_highlight gives it.
  late final bool _isYaml = identical(language, editorYamlMode);
  late final bool _isJavascript = identical(language, langJavascript);
  bool get isNative => _isYaml || _isJavascript;

  static final List<String> _javascriptScopes = highlightJavascriptScopes();

  static const _yamlScopes = [
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

  late final List<TextStyle?> _scopeStyles = [
    for (final scope in _isYaml ? _yamlScopes : _javascriptScopes)
      theme[scope] ?? base,
  ];

  /// Null for a line the native engine leaves to re_highlight.
  TextSpan? _nativeSpan(String lineText) {
    final tokens = _isYaml
        ? highlightYamlLine(text: lineText)
        : highlightJavascriptLine(text: lineText);
    if (tokens == null) return null;
    if (tokens.isEmpty) return TextSpan(text: lineText, style: base);
    final styles = _scopeStyles;
    final length = lineText.length;
    final spans = List<TextSpan>.filled(
      tokens.length ~/ 3 * 2 + 1,
      const TextSpan(),
      growable: true,
    );
    var count = 0;
    var index = 0;
    var from = 0;
    var to = 0;
    var current = base;
    while (to < length) {
      final TextStyle? style;
      final int end;
      if (index < tokens.length && tokens[index] <= to) {
        end = tokens[index + 1];
        style = styles[tokens[index + 2]];
        index += 3;
      } else {
        end = index < tokens.length ? tokens[index] : length;
        style = base;
      }
      if (!identical(style, current)) {
        if (to > from) {
          spans[count++] = TextSpan(
            text: lineText.substring(from, to),
            style: current,
          );
        }
        from = to;
        current = style;
      }
      to = end;
    }
    spans[count++] = TextSpan(
      text: lineText.substring(from, to),
      style: current,
    );
    if (count == 1) return spans.first;
    spans.length = count;
    return TextSpan(children: spans, style: base);
  }

  TextSpan? highlight(String lineText) {
    if (lineText.isEmpty) return null;
    try {
      if (isNative) {
        final span = _nativeSpan(lineText);
        if (span != null) return span;
      }
      final renderer = TextSpanRenderer(base, theme);
      _highlight.highlight(code: lineText, language: _id).render(renderer);
      return renderer.span;
    } catch (_) {
      return TextSpan(text: lineText, style: base);
    }
  }

  List<TextSpan?> highlightAll(List<String> lines) => [
    for (final line in lines) highlight(line),
  ];
}
