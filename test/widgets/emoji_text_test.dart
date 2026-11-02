import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/widgets/text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const style = TextStyle(fontSize: 13);

  test('按字素切分表情与普通文本，重复构建结果一致', () {
    final spans = EmojiText.buildSpans('🇺🇸 美国 01', style);
    expect(spans.map((span) => span.text), ['🇺🇸', ' 美国 01']);
    expect(spans.first.style?.fontFamily, FontFamily.twEmoji.value);
    expect(spans.last.style, style);
    expect(EmojiText.buildSpans('🇺🇸 美国 01', style), spans);
  });

  test('不含表情的文本保持单段原样式', () {
    expect(EmojiText.buildSpans('DIRECT', style), [
      const TextSpan(text: 'DIRECT', style: style),
    ]);
    expect(EmojiText.buildSpans('', style), isEmpty);
    expect(EmojiText.hasEmoji('DIRECT'), isFalse);
    expect(EmojiText.hasEmoji(''), isFalse);
    expect(EmojiText.hasEmoji('⚡️ 自动选择'), isTrue);
  });

  test('超出缓存容量后切分结果仍然正确', () {
    for (var i = 0; i < 1500; i++) {
      final text = 'node $i 🇸🇬';
      final spans = EmojiText.buildSpans(text, style);
      expect(spans.map((span) => span.text), ['node $i ', '🇸🇬']);
    }
  });
}
