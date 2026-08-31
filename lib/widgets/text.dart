import 'package:emoji_regex/emoji_regex.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:flutter/material.dart';

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
          final size = globalState.measure.computeTextSize(textWidget);
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

  const EmojiText(
    this.text, {
    super.key,
    this.maxLines,
    this.overflow,
    this.style,
    this.textAlign,
  });

  List<TextSpan> _buildTextSpans(
    String text,
    TextStyle defaultStyle,
  ) {
    final List<TextSpan> spans = [];
    final matches = emojiRegex().allMatches(text);
    final effectiveStyle = defaultStyle.merge(style);

    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: effectiveStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: effectiveStyle.merge(
            TextStyle(
              fontFamily: FontFamily.twEmoji.value,
              fontFamilyFallback: [FontFamily.twEmoji.value],
            ),
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(text: text.substring(lastMatchEnd), style: effectiveStyle),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      textScaler: MediaQuery.of(context).textScaler,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        children: _buildTextSpans(text, defaultStyle),
      ),
    );
  }
}