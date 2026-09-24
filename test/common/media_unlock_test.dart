import 'package:flutter_test/flutter_test.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaPlatform & Region Tests', () {
    test('MediaPlatform enum count and extensions', () {
      expect(MediaPlatform.values.length, 51);
      expect(MediaCategory.values.length, 7);

      for (final p in MediaPlatform.values) {
        expect(p.defaultName.isNotEmpty, true);
        expect(p.category, isNotNull);
      }

      for (final cat in MediaCategory.values) {
        final count = MediaPlatform.values
            .where((p) => p.category == cat)
            .length;
        expect(count > 0, true);
      }

      expect(MediaPlatform.openai.defaultName, 'OpenAI');
      expect(MediaPlatform.openai.category, MediaCategory.ai);
      expect(MediaPlatform.claude.defaultName, 'Claude');
      expect(MediaPlatform.claude.category, MediaCategory.ai);
      expect(MediaPlatform.grok.defaultName, 'Grok');
      expect(MediaPlatform.grok.category, MediaCategory.ai);
      expect(MediaPlatform.cloudflare.defaultName, 'Cloudflare');
      expect(MediaPlatform.cloudflare.category, MediaCategory.ai);
      expect(MediaPlatform.perplexity.defaultName, 'Perplexity');
      expect(MediaPlatform.perplexity.category, MediaCategory.ai);

      expect(MediaPlatform.tencent.defaultName, 'Tencent(CN)');
      expect(MediaPlatform.tencent.category, MediaCategory.china);
      expect(MediaPlatform.alibaba.defaultName, 'Alibaba(CN)');
      expect(MediaPlatform.alibaba.category, MediaCategory.china);
      expect(MediaPlatform.netease.defaultName, 'Netease(CN)');
      expect(MediaPlatform.netease.category, MediaCategory.china);
      expect(MediaPlatform.douyin.defaultName, 'Douyin(CN)');
      expect(MediaPlatform.douyin.category, MediaCategory.china);
      expect(MediaPlatform.bilibili.defaultName, 'Bilibili(CN)');
      expect(MediaPlatform.bilibili.category, MediaCategory.china);
      expect(MediaPlatform.cloudflarecn.defaultName, 'Cloudflare(CN)');
      expect(MediaPlatform.cloudflarecn.category, MediaCategory.china);

      expect(MediaPlatform.netflix.category, MediaCategory.streaming);
      expect(MediaPlatform.disney.category, MediaCategory.streaming);
      expect(MediaPlatform.youtube.category, MediaCategory.streaming);
      expect(MediaPlatform.youtubemusic.defaultName, 'YouTube Music');
      expect(MediaPlatform.youtubemusic.category, MediaCategory.streaming);
      expect(MediaPlatform.spotify.category, MediaCategory.streaming);
      expect(MediaPlatform.tiktok.category, MediaCategory.streaming);
      expect(MediaPlatform.iqiyi.category, MediaCategory.streaming);
      expect(MediaPlatform.crunchyroll.category, MediaCategory.streaming);
      expect(MediaPlatform.missav.category, MediaCategory.streaming);
      expect(MediaPlatform.ehentai.category, MediaCategory.streaming);

      expect(MediaPlatform.x.defaultName, 'Twitter');
      expect(MediaPlatform.x.category, MediaCategory.social);
      expect(MediaPlatform.reddit.category, MediaCategory.social);
      expect(MediaPlatform.discord.category, MediaCategory.social);
      expect(MediaPlatform.v2ex.category, MediaCategory.social);
      expect(MediaPlatform.medium.category, MediaCategory.social);
      expect(MediaPlatform.stackoverflow.category, MediaCategory.social);
      expect(MediaPlatform.quora.category, MediaCategory.social);
      expect(MediaPlatform.telegram.defaultName, 'Telegram');
      expect(MediaPlatform.telegram.category, MediaCategory.social);
      expect(MediaPlatform.telegram.pinColoBadge, true);

      expect(MediaPlatform.github.category, MediaCategory.developer);
      expect(MediaPlatform.wikipedia.category, MediaCategory.developer);
      expect(MediaPlatform.apple.category, MediaCategory.developer);
      expect(MediaPlatform.onetrust.category, MediaCategory.developer);
      expect(MediaPlatform.gitlab.category, MediaCategory.developer);
      expect(MediaPlatform.npm.category, MediaCategory.developer);
      expect(MediaPlatform.cdnjs.category, MediaCategory.developer);
      expect(MediaPlatform.unpkg.category, MediaCategory.developer);
      expect(MediaPlatform.nodejs.category, MediaCategory.developer);

      expect(MediaPlatform.steam.category, MediaCategory.gaming);
      expect(MediaPlatform.epic.category, MediaCategory.gaming);
      expect(MediaPlatform.ubisoft.category, MediaCategory.gaming);
      expect(MediaPlatform.humblebundle.category, MediaCategory.gaming);

      expect(MediaPlatform.coinbase.category, MediaCategory.crypto);
      expect(MediaPlatform.okx.category, MediaCategory.crypto);
      expect(MediaPlatform.kraken.category, MediaCategory.crypto);
      expect(MediaPlatform.cryptocom.category, MediaCategory.crypto);
      expect(MediaPlatform.phantom.category, MediaCategory.crypto);

      expect(MediaPlatform.x.isMonochrome, false);
      expect(MediaPlatform.github.isMonochrome, true);
      expect(MediaPlatform.apple.isMonochrome, true);
      expect(MediaPlatform.grok.isMonochrome, true);
      expect(MediaPlatform.epic.isMonochrome, true);
      expect(MediaPlatform.openai.isMonochrome, false);
      expect(MediaPlatform.netflix.isMonochrome, false);
      expect(MediaPlatform.tiktok.isMonochrome, false);
    });
    test(
      'defaultPinnedMediaPlatforms has 3 items: reddit, gemini, cloudflare',
      () {
        expect(defaultPinnedMediaPlatforms, [
          MediaPlatform.reddit,
          MediaPlatform.gemini,
          MediaPlatform.cloudflare,
        ]);
      },
    );

    test('pinnedMediaPlatformsSafeFromJson migration', () {
      final migrated = pinnedMediaPlatformsSafeFromJson([
        'chatgpt',
        'linuxdo',
        'youtube',
        'github',
        'qqnews',
        'alidnsprobe',
        'bytedance',
      ]);
      expect(migrated, [
        MediaPlatform.openai,
        MediaPlatform.youtube,
        MediaPlatform.github,
        MediaPlatform.tencent,
        MediaPlatform.alibaba,
        MediaPlatform.douyin,
      ]);
    });

    test('utils.normalizeRegion mappings', () {
      expect(utils.normalizeRegion('TWN'), 'TW');
      expect(utils.normalizeRegion('NTW'), 'TW');
      expect(utils.normalizeRegion('TWD'), 'TW');
      expect(utils.normalizeRegion('JPN'), 'JP');
      expect(utils.normalizeRegion('JPY'), 'JP');
      expect(utils.normalizeRegion('KOR'), 'KR');
      expect(utils.normalizeRegion('KRW'), 'KR');
      expect(utils.normalizeRegion('SGP'), 'SG');
      expect(utils.normalizeRegion('SGD'), 'SG');
      expect(utils.normalizeRegion('GBR'), 'GB');
      expect(utils.normalizeRegion('GBP'), 'GB');
      expect(utils.normalizeRegion('USD'), 'US');
      expect(utils.normalizeRegion('HKD'), 'HK');
    });
  });
}
