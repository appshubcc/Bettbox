import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_highlight/re_highlight.dart';

import '../LSP/lsp.dart';

class SemanticWordSpan {
  final int startChar;
  final int endChar;
  final String word;
  final TextStyle style;

  SemanticWordSpan({
    required this.startChar,
    required this.endChar,
    required this.word,
    required this.style,
  });
}

class HighlightedLine {
  final String text;
  final TextSpan? span;
  final int version;

  HighlightedLine(this.text, this.span, this.version);
}

class _SpanData {
  final String text;
  final String? scope;
  final List<_SpanData> children;

  _SpanData(this.text, this.scope, [this.children = const []]);
}

class SyntaxHighlighter {
  final Mode language;
  final List<Mode> extraLanguages;
  final Map<String, TextStyle> editorTheme;
  final TextStyle? baseTextStyle;
  final String? languageId;
  final String Function(int)? getLineText;
  final Map<int, HighlightedLine> _grammarCache = {}, _mergedCache = {};
  final Map<int, List<SemanticWordSpan>> _lineSemanticSpans = {};
  final Map<String, TextSpan?> _lineSpanCache = {};
  late final String _langId;
  late final Highlight _highlight;
  late final Map<String, TextStyle> _resolvedTheme;
  late final List<Mode> _registeredExtraLanguages;
  late final Map<String, List<String>> _semanticMapping;
  static const int isolateThreshold = 500;
  static const int _cacheKeepMargin = 500;
  static const int _maxLineCacheEntries = 6000;
  static const int _maxSpanCacheEntries = 8000;
  static const int _blockCommentLookbackLimit = 200;
  int get documentVersion => _documentVersion;
  Future<void>? _preHighlightInFlight;
  int _preHighlightInFlightVersion = -1, _version = 0, _documentVersion = 0;
  bool _isEditing = false;

  SyntaxHighlighter({
    required this.language,
    required this.editorTheme,
    this.baseTextStyle,
    this.languageId,
    this.extraLanguages = const [],
    this.getLineText,
  }) {
    _langId = language.hashCode.toString();
    _resolvedTheme = _buildResolvedTheme(editorTheme);
    _highlight = Highlight();
    _highlight.registerLanguage(_langId, language);

    _registeredExtraLanguages = <Mode>[...extraLanguages];

    for (final lang in _registeredExtraLanguages) {
      _registerLanguageWithAliases(_highlight, lang);
    }

    _semanticMapping = getSemanticMapping(languageId ?? '');
  }

  void updateSemanticTokens(
    List<LspSemanticToken> tokens,
    String Function(int) getLineText,
    int lineCount,
  ) {
    final updatedLineSemanticSpans = <int, List<SemanticWordSpan>>{};
    final lineCache = <int, String>{};

    for (final token in tokens) {
      if (token.line < 0 || token.line >= lineCount) continue;
      final lineText = lineCache.putIfAbsent(
        token.line,
        () => getLineText(token.line),
      );
      final start = token.start.clamp(0, lineText.length);
      final end = (token.start + token.length).clamp(0, lineText.length);

      if (start < end) {
        final word = lineText.substring(start, end);
        final style = _resolveSemanticStyle(token.tokenTypeName);

        if (style != null && word.isNotEmpty) {
          final lineSpans = updatedLineSemanticSpans.putIfAbsent(
            token.line,
            () => [],
          );
          lineSpans.add(
            SemanticWordSpan(
              startChar: start,
              endChar: end,
              word: word,
              style: style,
            ),
          );
        }
      }
    }

    for (final spans in updatedLineSemanticSpans.values) {
      spans.sort((a, b) => a.startChar.compareTo(b.startChar));
    }

    for (final entry in updatedLineSemanticSpans.entries) {
      _lineSemanticSpans[entry.key] = entry.value;
    }

    _isEditing = false;
    _lineSpanCache.clear();
    _mergedCache.clear();
    _grammarCache.clear();
    _version++;
  }

  void applyDocumentEdit(
    int editLine,
    int editStart,
    int oldEnd,
    String insertedText,
    String deletedText,
  ) {
    _documentVersion++;
    final insertedLineBreaks = '\n'.allMatches(insertedText).length;
    final deletedLineBreaks = '\n'.allMatches(deletedText).length;
    final lineBreakDelta = insertedLineBreaks - deletedLineBreaks;
    final isPureInsertion = oldEnd == editStart;
    final isPureDeletion = insertedText.isEmpty && oldEnd > editStart;
    if (lineBreakDelta != 0 && (isPureInsertion || isPureDeletion)) {
      final shiftedSemanticSpans = <int, List<SemanticWordSpan>>{};
      for (final entry in _lineSemanticSpans.entries) {
        final lineIndex = entry.key;
        if (lineIndex > editLine) {
          shiftedSemanticSpans[lineIndex + lineBreakDelta] = entry.value;
        } else {
          shiftedSemanticSpans[lineIndex] = entry.value;
        }
      }

      _lineSemanticSpans
        ..clear()
        ..addAll(shiftedSemanticSpans);
      _grammarCache.removeWhere((line, _) => line >= editLine);
      _mergedCache.removeWhere((line, _) => line >= editLine);
      _isEditing = false;
    } else if (insertedText.isNotEmpty || deletedText.isNotEmpty) {
      final lineSemanticSpans = _lineSemanticSpans[editLine];
      if (lineSemanticSpans != null && lineSemanticSpans.isNotEmpty) {
        final updatedLineSemanticSpans = <SemanticWordSpan>[];
        final insertedLength = insertedText.length;
        final deletedLength = deletedText.length;
        final shiftDelta = insertedLength - deletedLength;
        final insertedEnd = editStart + insertedLength;

        for (final span in lineSemanticSpans) {
          if (span.endChar <= editStart) {
            updatedLineSemanticSpans.add(span);
            continue;
          }

          if (span.startChar >= oldEnd) {
            updatedLineSemanticSpans.add(
              SemanticWordSpan(
                startChar: span.startChar + shiftDelta,
                endChar: span.endChar + shiftDelta,
                word: span.word,
                style: span.style,
              ),
            );
            continue;
          }

          if (span.startChar < editStart) {
            final leftEnd = editStart.clamp(span.startChar, span.endChar);
            if (leftEnd > span.startChar) {
              updatedLineSemanticSpans.add(
                SemanticWordSpan(
                  startChar: span.startChar,
                  endChar: leftEnd,
                  word: span.word.substring(0, leftEnd - span.startChar),
                  style: span.style,
                ),
              );
            }
          }

          if (span.endChar > oldEnd) {
            final rightStart = insertedEnd;
            final rightEnd = span.endChar + shiftDelta;
            if (rightEnd > rightStart) {
              final rightWordStart =
                  (span.word.length - (span.endChar - oldEnd)).clamp(
                    0,
                    span.word.length,
                  );
              updatedLineSemanticSpans.add(
                SemanticWordSpan(
                  startChar: rightStart,
                  endChar: rightEnd,
                  word: span.word.substring(rightWordStart),
                  style: span.style,
                ),
              );
            }
          }
        }

        updatedLineSemanticSpans.sort(
          (a, b) => a.startChar == b.startChar
              ? a.endChar.compareTo(b.endChar)
              : a.startChar.compareTo(b.startChar),
        );
        _lineSemanticSpans[editLine] = updatedLineSemanticSpans;
      }

      _isEditing = false;
    } else {
      _isEditing = true;
    }

    _version++;
  }

  void invalidateAll() {
    _grammarCache.clear();
    _mergedCache.clear();
    _documentVersion++;
    _version++;
  }

  void invalidateLines(Set<int> lines) {
    for (final line in lines) {
      _grammarCache.remove(line);
      _mergedCache.remove(line);
    }
    _version++;
  }

  void invalidateRange(int startLine, int endLine) {
    for (int i = startLine; i <= endLine; i++) {
      _grammarCache.remove(i);
      _mergedCache.remove(i);
    }
    final keysToRemove = _grammarCache.keys.where((k) => k > endLine).toList();
    for (final key in keysToRemove) {
      _grammarCache.remove(key);
      _mergedCache.remove(key);
    }
    _version++;
  }

  TextSpan? getLineSpan(int lineIndex, String lineText) {
    final mergedCache = _mergedCache[lineIndex];
    if (mergedCache != null &&
        mergedCache.version == _version &&
        mergedCache.text == lineText) {
      return mergedCache.span;
    }

    if (_isInsideBlockComment(lineIndex)) {
      final commentStyle = _resolvedTheme['comment'] ?? baseTextStyle;
      final commentSpan = TextSpan(text: lineText, style: commentStyle);
      _mergedCache[lineIndex] = HighlightedLine(
        lineText,
        commentSpan,
        _version,
      );
      return commentSpan;
    }

    final grammarCache = _grammarCache[lineIndex];
    final cachedGrammarSpan =
        grammarCache != null &&
            grammarCache.version == _version &&
            grammarCache.text == lineText
        ? grammarCache.span
        : null;

    final semanticSpans = _lineSemanticSpans[lineIndex];
    if (_isEditing || semanticSpans == null || semanticSpans.isEmpty) {
      if (_lineSpanCache.containsKey(lineText)) {
        return _lineSpanCache[lineText];
      }
      if (cachedGrammarSpan != null) {
        _lineSpanCache[lineText] = cachedGrammarSpan;
        return cachedGrammarSpan;
      }
    }

    if (cachedGrammarSpan != null) {
      final mergedSpan = _mergeGrammarAndSemantic(
        lineText,
        cachedGrammarSpan,
        semanticSpans,
      );

      _lineSpanCache[lineText] = mergedSpan;
      _mergedCache[lineIndex] = HighlightedLine(lineText, mergedSpan, _version);
      return mergedSpan;
    }

    if (_lineSpanCache.containsKey(lineText) &&
        (semanticSpans == null || semanticSpans.isEmpty || _isEditing)) {
      return _lineSpanCache[lineText];
    }

    final grammarSpan = _highlightLine(lineText);

    if (_isEditing) {
      _lineSpanCache[lineText] = grammarSpan;
      return grammarSpan;
    }

    final mergedSpan = _mergeGrammarAndSemantic(
      lineText,
      grammarSpan,
      semanticSpans,
    );

    _lineSpanCache[lineText] = mergedSpan;
    _mergedCache[lineIndex] = HighlightedLine(lineText, mergedSpan, _version);

    return mergedSpan;
  }

  TextSpan? _mergeGrammarAndSemantic(
    String lineText,
    TextSpan? grammarSpan,
    List<SemanticWordSpan>? semanticSpans,
  ) {
    if (lineText.isEmpty) {
      return grammarSpan;
    }

    if (semanticSpans == null || semanticSpans.isEmpty) {
      return grammarSpan;
    }

    final grammarSegments = <({String text, TextStyle? style})>[];
    _flattenGrammarSpan(grammarSpan, grammarSegments, baseTextStyle);

    final children = <TextSpan>[];
    int currentPos = 0; // UTF‑16 index

    final utf16SemanticRanges = semanticSpans.map((span) {
      final start = _scalarToUtf16Index(
        lineText,
        span.startChar,
      ).clamp(0, lineText.length);
      final end = _scalarToUtf16Index(
        lineText,
        span.endChar,
      ).clamp(0, lineText.length);
      return (start: start, end: end, style: span.style);
    }).toList();

    for (final range in utf16SemanticRanges) {
      if (range.start > currentPos) {
        _addGrammarSegments(
          children,
          grammarSegments,
          currentPos,
          range.start,
          lineText,
        );
      }

      if (range.start < range.end) {
        final actualText = lineText.substring(range.start, range.end);
        final grammarStyle = _getStyleAtPosition(grammarSegments, range.start);
        final preserveGrammar =
            _isStringOrCommentStyle(grammarStyle) ||
            _hasMeaningfulGrammarStyle(grammarStyle);

        if (preserveGrammar) {
          children.add(TextSpan(text: actualText, style: grammarStyle));
        } else {
          children.add(TextSpan(text: actualText, style: range.style));
        }
      }

      currentPos = range.end;
    }

    if (currentPos < lineText.length) {
      _addGrammarSegments(
        children,
        grammarSegments,
        currentPos,
        lineText.length,
        lineText,
      );
    }

    if (children.isEmpty) {
      return grammarSpan;
    }

    if (children.length == 1) {
      return children.first;
    }

    return TextSpan(style: baseTextStyle, children: children);
  }

  int _scalarToUtf16Index(String text, int scalarOffset) {
    if (scalarOffset <= 0) return 0;
    int utf16 = 0;
    int scalar = 0;
    for (final rune in text.runes) {
      if (scalar >= scalarOffset) break;
      utf16 += rune > 0xFFFF ? 2 : 1;
      scalar++;
    }
    return utf16;
  }

  void _flattenGrammarSpan(
    TextSpan? span,
    List<({String text, TextStyle? style})> segments,
    TextStyle? parentStyle,
  ) {
    if (span == null) return;

    final effectiveStyle = span.style ?? parentStyle;

    if (span.text != null && span.text!.isNotEmpty) {
      segments.add((text: span.text!, style: effectiveStyle));
    }

    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan) {
          _flattenGrammarSpan(child, segments, effectiveStyle);
        }
      }
    }
  }

  void _addGrammarSegments(
    List<TextSpan> children,
    List<({String text, TextStyle? style})> grammarSegments,
    int startPos,
    int endPos,
    String lineText,
  ) {
    int segmentOffset = 0;
    int addedLength = 0;

    for (final segment in grammarSegments) {
      final segmentStart = segmentOffset;
      final segmentEnd = segmentOffset + segment.text.length;

      if (segmentEnd > startPos && segmentStart < endPos) {
        final overlapStart = segmentStart < startPos
            ? startPos - segmentStart
            : 0;
        final overlapEnd = segmentEnd > endPos
            ? segment.text.length - (segmentEnd - endPos)
            : segment.text.length;

        if (overlapEnd > overlapStart) {
          final text = segment.text.substring(overlapStart, overlapEnd);
          children.add(
            TextSpan(text: text, style: segment.style ?? baseTextStyle),
          );
          addedLength += text.length;
        }
      }

      segmentOffset = segmentEnd;

      if (segmentOffset >= endPos) break;
    }

    final expectedLength = endPos - startPos;
    if (addedLength < expectedLength) {
      final subStart = (startPos + addedLength).clamp(0, lineText.length);
      final subEnd = endPos.clamp(0, lineText.length);
      if (subEnd > subStart) {
        final remaining = lineText.substring(subStart, subEnd);
        if (remaining.isNotEmpty) {
          children.add(TextSpan(text: remaining, style: baseTextStyle));
        }
      }
    }
  }

  TextStyle? _getStyleAtPosition(
    List<({String text, TextStyle? style})> grammarSegments,
    int position,
  ) {
    int offset = 0;
    for (final segment in grammarSegments) {
      final segmentEnd = offset + segment.text.length;
      if (position >= offset && position < segmentEnd) {
        return segment.style;
      }
      offset = segmentEnd;
    }
    return baseTextStyle;
  }

  bool _isStringOrCommentStyle(TextStyle? style) {
    if (style == null) return false;

    final stringStyle = editorTheme['string'];
    final commentStyle = editorTheme['comment'];
    final numberStyle = editorTheme['number'];
    final regexpStyle = editorTheme['regexp'];
    final metaStringStyle = editorTheme['meta-string'];
    final styleColor = style.color;

    if (styleColor == null) return false;
    if (stringStyle?.color == styleColor) return true;
    if (commentStyle?.color == styleColor) return true;
    if (numberStyle?.color == styleColor) return true;
    if (regexpStyle?.color == styleColor) return true;
    if (metaStringStyle?.color == styleColor) return true;

    return false;
  }

  bool _hasMeaningfulGrammarStyle(TextStyle? style) {
    if (style == null) return false;

    final rootStyle = baseTextStyle ?? _resolvedTheme['root'];
    final rootColor = rootStyle?.color;

    if (style.color != null && rootColor != null && style.color != rootColor) {
      return true;
    }
    if (style.fontWeight != null && style.fontWeight != rootStyle?.fontWeight) {
      return true;
    }
    if (style.fontStyle != null && style.fontStyle != rootStyle?.fontStyle) {
      return true;
    }

    return false;
  }

  TextStyle? _resolveSemanticStyle(String? tokenTypeName) {
    if (tokenTypeName == null) return null;

    final hljsKeys = _semanticMapping[tokenTypeName];
    if (hljsKeys == null) return null;

    for (final key in hljsKeys) {
      final style = editorTheme[key];
      final styleFromResolved = _resolvedTheme[key];
      if (styleFromResolved != null) return styleFromResolved;
      if (style != null) return style;
    }

    return null;
  }

  bool _isInsideBlockComment(int lineIndex) {
    final getLineText = this.getLineText;
    if (getLineText == null) return false;

    final startLine = (lineIndex - _blockCommentLookbackLimit).clamp(
      0,
      lineIndex,
    );

    for (int i = lineIndex; i >= startLine; i--) {
      final text = getLineText(i);
      if (text.isEmpty) continue;

      int pos = 0;
      while (true) {
        final openIdx = text.indexOf('/*', pos);
        final closeIdx = text.indexOf('*/', pos);

        if (openIdx < 0 && closeIdx < 0) break;

        if (openIdx >= 0 && (closeIdx < 0 || openIdx < closeIdx)) {
          final afterOpen = text.indexOf('*/', openIdx + 2);
          if (afterOpen >= 0) {
            pos = afterOpen + 2;
            continue;
          }
          return i != lineIndex;
        }

        if (closeIdx >= 0 && (openIdx < 0 || closeIdx < openIdx)) {
          return i == lineIndex;
        }
      }
    }

    return false;
  }

  TextSpan? _highlightLine(String lineText) {
    if (lineText.isEmpty) return null;

    try {
      final result = _highlight.highlight(code: lineText, language: _langId);
      final renderer = TextSpanRenderer(baseTextStyle, _resolvedTheme);
      result.render(renderer);
      var span = renderer.span;
      if (_isTsxOrJsx && _looksLikeJsxTagLine(lineText)) {
        span = _applyJsxTagFallback(lineText, span);
      }
      span = _applyRegexFallback(lineText, span);
      return span;
    } catch (e) {
      return TextSpan(text: lineText, style: baseTextStyle);
    }
  }

  TextSpan? _applyRegexFallback(String lineText, TextSpan? span) {
    if (span == null || lineText.isEmpty) return span;

    final regexpStyle = _resolvedTheme['regexp'] ?? _resolvedTheme['string'];
    if (regexpStyle == null) return span;

    final regexLiteralPattern = RegExp(
      r'(^|[\s:=,({[\?])(\/(?![/*])(?:\\.|\[(?:\\.|[^\]\\])*\]|[^/\\[\n])+\/[a-z]*)',
    );

    final matches = regexLiteralPattern.allMatches(lineText).toList();
    if (matches.isEmpty) return span;

    final grammarSegments = <({String text, TextStyle? style})>[];
    _flattenGrammarSpan(span, grammarSegments, baseTextStyle);

    final ranges = <({int start, int end})>[];
    for (final match in matches) {
      final prefix = match.group(1) ?? '';
      final regexStr = match.group(2);
      if (regexStr == null || regexStr.isEmpty) continue;

      final start = match.start + prefix.length;
      final end = start + regexStr.length;

      final existingStyle = _getStyleAtPosition(grammarSegments, start);
      if (!_isStringOrCommentStyle(existingStyle)) {
        ranges.add((
          start: start.clamp(0, lineText.length),
          end: end.clamp(0, lineText.length),
        ));
      }
    }

    if (ranges.isEmpty) return span;

    final children = <TextSpan>[];
    int currentPos = 0;

    for (final range in ranges) {
      if (range.start > currentPos) {
        _addGrammarSegments(
          children,
          grammarSegments,
          currentPos,
          range.start,
          lineText,
        );
      }
      if (range.start < range.end) {
        final regexText = lineText.substring(range.start, range.end);
        children.add(TextSpan(text: regexText, style: regexpStyle));
        currentPos = range.end;
      }
    }

    if (currentPos < lineText.length) {
      _addGrammarSegments(
        children,
        grammarSegments,
        currentPos,
        lineText.length,
        lineText,
      );
    }

    return TextSpan(children: children, style: baseTextStyle);
  }

  bool get _isTsxOrJsx {
    final id = languageId?.toLowerCase().trim();
    return id == 'tsx' || id == 'jsx';
  }

  bool _looksLikeJsxTagLine(String line) {
    return RegExp(r'(^|[^A-Za-z0-9_])<\/?[A-Za-z]').hasMatch(line);
  }

  TextSpan? _applyJsxTagFallback(String lineText, TextSpan? span) {
    if (span == null || lineText.isEmpty) return span;

    final tagStyle =
        _resolvedTheme['tag'] ??
        _resolvedTheme['name'] ??
        _resolvedTheme['selector-tag'];
    if (tagStyle == null) return span;

    final grammarSegments = <({String text, TextStyle? style})>[];
    _flattenGrammarSpan(span, grammarSegments, baseTextStyle);

    final ranges = <({int start, int end})>[];
    final tagOpen = RegExp(
      r'(^|[^A-Za-z0-9_])<\/?\s*([A-Za-z][A-Za-z0-9:_-]*)',
    );

    for (final match in tagOpen.allMatches(lineText)) {
      final prefix = match.group(1) ?? '';
      final leadingStart = match.start + prefix.length;
      if (leadingStart < 0 || leadingStart >= lineText.length) continue;

      final nameGroup = match.group(2);
      if (nameGroup == null) continue;
      final nameStart = match.end - nameGroup.length;
      final nameEnd = match.end;

      ranges.add((
        start: leadingStart,
        end: (nameStart).clamp(leadingStart, lineText.length),
      ));
      ranges.add((start: nameStart, end: nameEnd));

      final closeIndex = lineText.indexOf('>', match.end);
      if (closeIndex != -1) {
        final beforeClose = closeIndex > 0 ? lineText[closeIndex - 1] : '';
        if (beforeClose == '/') {
          ranges.add((start: closeIndex - 1, end: closeIndex));
        }
        ranges.add((start: closeIndex, end: closeIndex + 1));
      }
    }

    if (ranges.isEmpty) return span;

    ranges.sort((a, b) => a.start.compareTo(b.start));

    final mergedRanges = <({int start, int end})>[];
    for (final range in ranges) {
      final start = range.start.clamp(0, lineText.length);
      final end = range.end.clamp(0, lineText.length);
      if (end <= start) continue;

      if (mergedRanges.isEmpty || start > mergedRanges.last.end) {
        mergedRanges.add((start: start, end: end));
      } else {
        final last = mergedRanges.removeLast();
        mergedRanges.add((
          start: last.start,
          end: end > last.end ? end : last.end,
        ));
      }
    }

    final children = <TextSpan>[];
    int current = 0;

    for (final range in mergedRanges) {
      if (range.start > current) {
        _addGrammarSegments(
          children,
          grammarSegments,
          current,
          range.start,
          lineText,
        );
      }

      final existing = _getStyleAtPosition(grammarSegments, range.start);
      final chosen = _hasMeaningfulGrammarStyle(existing) ? existing : tagStyle;
      final part = lineText.substring(range.start, range.end);
      if (part.isNotEmpty) {
        children.add(TextSpan(text: part, style: chosen));
      }
      current = range.end;
    }

    if (current < lineText.length) {
      _addGrammarSegments(
        children,
        grammarSegments,
        current,
        lineText.length,
        lineText,
      );
    }

    return TextSpan(style: baseTextStyle, children: children);
  }

  ui.Paragraph buildHighlightedParagraph(
    int lineIndex,
    String lineText,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
  }) {
    final span = getLineSpan(lineIndex, lineText);
    final builder = ui.ParagraphBuilder(paragraphStyle);

    if (span == null || lineText.isEmpty) {
      final style = _getUiTextStyle(null, fontSize, fontFamily);
      builder.pushStyle(style);
      builder.addText(lineText.isEmpty ? ' ' : lineText);
      final p = builder.build();
      p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
      return p;
    }

    _addTextSpanToBuilder(builder, span, fontSize, fontFamily);

    final p = builder.build();
    p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
    return p;
  }

  void _addTextSpanToBuilder(
    ui.ParagraphBuilder builder,
    TextSpan span,
    double fontSize,
    String? fontFamily,
  ) {
    final style = _textStyleToUiStyle(span.style, fontSize, fontFamily);
    builder.pushStyle(style);

    if (span.text != null) {
      builder.addText(span.text!);
    }

    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan) {
          _addTextSpanToBuilder(builder, child, fontSize, fontFamily);
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
    final baseStyle = style ?? baseTextStyle ?? editorTheme['root'];

    return ui.TextStyle(
      color: baseStyle?.color ?? editorTheme['root']?.color ?? Colors.black,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: baseStyle?.fontWeight,
      fontStyle: baseStyle?.fontStyle,
    );
  }

  ui.TextStyle _getUiTextStyle(
    String? className,
    double fontSize,
    String? fontFamily,
  ) {
    final themeStyle = className != null ? editorTheme[className] : null;
    final baseStyle = themeStyle ?? baseTextStyle ?? editorTheme['root'];

    return ui.TextStyle(
      color: baseStyle?.color ?? editorTheme['root']?.color ?? Colors.black,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: baseStyle?.fontWeight,
      fontStyle: baseStyle?.fontStyle,
    );
  }

  Future<void> preHighlightLines(
    int startLine,
    int endLine,
    String Function(int) getLineText,
  ) async {
    if (_preHighlightInFlight != null &&
        _preHighlightInFlightVersion == _version) {
      return _preHighlightInFlight;
    }

    final requestVersion = _version;
    _preHighlightInFlightVersion = requestVersion;
    final future = _preHighlightLinesInternal(
      startLine,
      endLine,
      getLineText,
      requestVersion,
    );
    _preHighlightInFlight = future;

    try {
      await future;
    } finally {
      if (identical(_preHighlightInFlight, future)) {
        _preHighlightInFlight = null;
        _preHighlightInFlightVersion = -1;
      }
    }
  }

  Future<void> _preHighlightLinesInternal(
    int startLine,
    int endLine,
    String Function(int) getLineText,
    int requestVersion,
  ) async {
    _pruneCachesForViewport(startLine, endLine);

    final linesToProcess = <int, String>{};

    for (int i = startLine; i <= endLine; i++) {
      final lineText = getLineText(i);
      final cached = _grammarCache[i];
      if (cached == null ||
          cached.text != lineText ||
          cached.version != _version) {
        linesToProcess[i] = lineText;
      }
    }

    if (linesToProcess.isEmpty) return;

    if (linesToProcess.length < 50) {
      if (requestVersion != _version) return;
      for (final entry in linesToProcess.entries) {
        if (requestVersion != _version) return;
        final span = _highlightLine(entry.value);
        _grammarCache[entry.key] = HighlightedLine(entry.value, span, _version);
      }
      return;
    }

    final results = await compute(
      _highlightLinesInBackground,
      _BackgroundHighlightData(
        langId: _langId,
        lines: linesToProcess,
        languageMode: language,
        extraLanguages: _registeredExtraLanguages,
        theme: _resolvedTheme,
        baseStyle: baseTextStyle,
      ),
    );

    if (requestVersion != _version) return;

    for (final entry in results.entries) {
      final spanData = entry.value;
      final textSpan = spanData != null ? _spanDataToTextSpan(spanData) : null;
      _grammarCache[entry.key] = HighlightedLine(
        linesToProcess[entry.key]!,
        textSpan,
        requestVersion,
      );
    }

    _pruneCachesForViewport(startLine, endLine);
  }

  void _pruneCachesForViewport(int startLine, int endLine) {
    final minKeep = (startLine - _cacheKeepMargin).clamp(0, 1 << 30);
    final maxKeep = endLine + _cacheKeepMargin;

    if (_grammarCache.length > _maxLineCacheEntries) {
      _grammarCache.removeWhere((line, _) => line < minKeep || line > maxKeep);
    }

    if (_mergedCache.length > _maxLineCacheEntries) {
      _mergedCache.removeWhere((line, _) => line < minKeep || line > maxKeep);
    }

    if (_lineSemanticSpans.length > _maxLineCacheEntries) {
      _lineSemanticSpans.removeWhere(
        (line, _) => line < minKeep || line > maxKeep,
      );
    }

    if (_lineSpanCache.length > _maxSpanCacheEntries) {
      _lineSpanCache.clear();
    }
  }

  TextSpan? _spanDataToTextSpan(_SpanData? data) {
    if (data == null) return null;

    final style = data.scope != null
        ? _resolvedTheme[data.scope]
        : baseTextStyle;

    if (data.children.isEmpty) {
      return TextSpan(text: data.text, style: style);
    }

    return TextSpan(
      text: data.text.isEmpty ? null : data.text,
      style: style,
      children: data.children.map((c) => _spanDataToTextSpan(c)!).toList(),
    );
  }

  Map<String, TextStyle> _buildResolvedTheme(Map<String, TextStyle> theme) {
    final resolved = Map<String, TextStyle>.from(theme);

    if (!resolved.containsKey('tag')) {
      final fallbackTagStyle = resolved['selector-tag'] ?? resolved['name'];
      if (fallbackTagStyle != null) {
        resolved['tag'] = fallbackTagStyle;
      }
    }

    return resolved;
  }

  void dispose() {
    _grammarCache.clear();
    _mergedCache.clear();
    _lineSemanticSpans.clear();
    _lineSpanCache.clear();
  }
}

class _BackgroundHighlightData {
  final String langId;
  final Map<int, String> lines;
  final Mode languageMode;
  final List<Mode> extraLanguages;
  final Map<String, TextStyle> theme;
  final TextStyle? baseStyle;

  _BackgroundHighlightData({
    required this.langId,
    required this.lines,
    required this.languageMode,
    required this.extraLanguages,
    required this.theme,
    this.baseStyle,
  });
}

Map<int, _SpanData?> _highlightLinesInBackground(
  _BackgroundHighlightData data,
) {
  final highlight = Highlight();
  highlight.registerLanguage(data.langId, data.languageMode);
  for (final lang in data.extraLanguages) {
    _registerLanguageWithAliases(highlight, lang);
  }

  final results = <int, _SpanData?>{};

  for (final entry in data.lines.entries) {
    final lineIndex = entry.key;
    final lineText = entry.value;

    if (lineText.isEmpty) {
      results[lineIndex] = null;
      continue;
    }

    try {
      final result = highlight.highlight(code: lineText, language: data.langId);
      final renderer = TextSpanRenderer(data.baseStyle, data.theme);
      result.render(renderer);
      final span = renderer.span;
      results[lineIndex] = span != null ? _textSpanToSpanData(span) : null;
    } catch (e) {
      results[lineIndex] = _SpanData(lineText, null);
    }
  }

  return results;
}

void _registerLanguageWithAliases(Highlight highlight, Mode language) {
  if (language.name == null) return;

  final normalizedName = language.name!.toLowerCase().trim();
  highlight.registerLanguage(normalizedName, language);

  for (final token in normalizedName.split(RegExp(r'[^a-z0-9_+#-]+'))) {
    if (token.isNotEmpty) {
      highlight.registerLanguage(token, language);
    }
  }

  for (final alias in language.aliases ?? const <String>[]) {
    final normalizedAlias = alias.toLowerCase();
    highlight.registerLanguage(normalizedAlias, language);
  }
}

_SpanData _textSpanToSpanData(TextSpan span) {
  final children = <_SpanData>[];

  if (span.children != null) {
    for (final child in span.children!) {
      if (child is TextSpan) {
        children.add(_textSpanToSpanData(child));
      }
    }
  }

  String? scope;

  return _SpanData(span.text ?? '', scope, children);
}
