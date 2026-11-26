import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:bett_box/utils/platform_font.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('bettbox_font_test');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  File touch(String relative) {
    final file = File(p.join(root.path, relative));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('');
    return file;
  }

  test('目录里没有字体时返回 null', () {
    Directory(p.join(root.path, 'empty')).createSync();
    expect(PlatformFontFallback.findSystemCjkFont(searchRoots: [root.path]), 
        isNull);
  });

  test('优先级最高的是 Droid Sans Fallback 单字面', () {
    touch('opentype/noto/NotoSansCJK-Regular.ttc');
    final droid = touch('truetype/droid/DroidSansFallbackFull.ttf');
    final picked = PlatformFontFallback.findSystemCjkFont(
      searchRoots: [root.path, '/nonexistent-font-dir'],
    );
    expect(picked?.path, droid.path);
  });

  test('没有首选名时按 CJK 线索挑单字面，集合字体排在后面', () {
    touch('truetype/other/SomeLatin.ttf');
    final cjkTtc = touch('opentype/noto/NotoSansCJK-Regular.ttc');
    final picked = PlatformFontFallback.findSystemCjkFont(
      searchRoots: [root.path],
    );
    expect(picked?.path, cjkTtc.path); // 只有集合字体命中线索时才用它

    // 一旦出现单字面 CJK 字体，集合字体让位
    final cjkTtf = touch('truetype/wqy/my-cjk-font.ttf');
    final pickedTtf = PlatformFontFallback.findSystemCjkFont(
      searchRoots: [root.path],
    );
    expect(pickedTtf?.path, cjkTtf.path);
  });

  test('非字体文件被忽略', () {
    touch('truetype/dejavu/fonts.conf');
    touch('truetype/dejavu/README');
    expect(
      PlatformFontFallback.findSystemCjkFont(searchRoots: [root.path]),
      isNull,
    );
  });

  test('默认字体家族只在 arm64 Linux 上生效', () {
    final needsFallback = Platform.isLinux && Abi.current() == Abi.linuxArm64;
    expect(PlatformFontFallback.isNeeded, needsFallback);
    if (needsFallback) return; // arm64 真机车道另测
    // x64 Linux / 其他平台：保持系统字体（null），行为不变
    expect(PlatformFontFallback.defaultFontFamily, isNull);
  });
}
