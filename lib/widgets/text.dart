import 'package:emoji_regex/emoji_regex.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

import '../state.dart';

class TooltipText extends StatelessWidget {
  final Widget text;

  const TooltipText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, container) {
        final maxWidth = container.maxWidth;
        Text? textWidget;
        String? message;
        if (text is Text) {
          textWidget = text as Text;
          message = textWidget.data;
        } else if (text is EmojiText) {
          final emojiText = text as EmojiText;
          textWidget = Text(
            emojiText.text,
            style: emojiText.style,
            maxLines: emojiText.maxLines,
            overflow: emojiText.overflow,
          );
          message = emojiText.text;
        }
        if (textWidget != null) {
          final size = globalState.measure.cachedTextSize(textWidget);
          if (maxWidth < size.width) {
            return Tooltip(
              triggerMode: TooltipTriggerMode.longPress,
              preferBelow: false,
              message: message,
              child: text,
            );
          }
        }
        return text;
      },
    );
  }
}

class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  static final _emojiRegex = emojiRegex();
  static final _emojiFontStyle = TextStyle(
    fontFamily: FontFamily.twEmoji.value,
    fontFamilyFallback: [FontFamily.twEmoji.value],
  );
  static const _maxCachedSegments = 1024;
  static final _segmentCache = <String, List<({int end, bool emoji})>>{};

  const EmojiText(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.style,
    this.textAlign,
  });

  static List<({int end, bool emoji})> _segmentsOf(String text) {
    final cached = _segmentCache.remove(text);
    if (cached != null) {
      _segmentCache[text] = cached;
      return cached;
    }
    final segments = _emojiRegex.hasMatch(text)
        ? _splitSegments(text)
        : const <({int end, bool emoji})>[];
    if (_segmentCache.length >= _maxCachedSegments) {
      _segmentCache.remove(_segmentCache.keys.first);
    }
    _segmentCache[text] = segments;
    return segments;
  }

  static List<({int end, bool emoji})> _splitSegments(String text) {
    final segments = <({int end, bool emoji})>[];
    var index = 0;
    bool? current;
    for (final char in text.characters) {
      final isEmoji = _emojiRegex.hasMatch(char);
      if (current != null && current != isEmoji) {
        segments.add((end: index, emoji: current));
      }
      current = isEmoji;
      index += char.length;
    }
    if (current != null) {
      segments.add((end: text.length, emoji: current));
    }
    return segments;
  }

  static bool hasEmoji(String text) {
    if (text.isEmpty) return false;
    return _segmentsOf(text).isNotEmpty;
  }

  static List<TextSpan> buildSpans(String text, TextStyle style) {
    if (text.isEmpty) {
      return const [];
    }

    final segments = _segmentsOf(text);
    if (segments.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final emojiStyle = style.merge(_emojiFontStyle);
    final spans = <TextSpan>[];
    var start = 0;
    for (final (:end, :emoji) in segments) {
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: emoji ? emojiStyle : style,
        ),
      );
      start = end;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;

    return Text.rich(
      TextSpan(children: buildSpans(text, defaultStyle.merge(style))),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
