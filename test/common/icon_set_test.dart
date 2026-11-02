import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icon sets read the Quantumult X and Loon gallery format', () {
    final parsed = parseIconSet(
      jsonEncode({
        'name': 'Qure-Style-SVG',
        'icons': [
          {'name': 'Hong_Kong.svg', 'url': 'https://a.com/flag/Hong_Kong.svg'},
          {'url': 'https://a.com/common/Available%281%29.svg'},
          {'name': 'Dup', 'url': 'https://a.com/flag/Hong_Kong.svg'},
          {'name': 'Bad', 'url': 'file:///x.svg'},
          'skip',
        ],
      }),
    );
    expect(parsed.name, 'Qure-Style-SVG');
    expect(parsed.icons.map((icon) => icon.name), [
      'Hong_Kong.svg',
      'Available(1).svg',
    ]);
    expect(parsed.icons.first.label, 'Hong Kong');
    expect(
      const IconSetIcon(name: 'Apple_Fitness%2B.svg', url: '').label,
      'Apple Fitness+',
    );
  });

  test('documents without icons are rejected', () {
    expect(() => parseIconSet('[]'), throwsFormatException);
    expect(() => parseIconSet('{"icons": []}'), throwsFormatException);
    expect(
      () => parseIconSet('{"icons": [{"url": "ftp://a/b.svg"}]}'),
      throwsFormatException,
    );
  });
}
