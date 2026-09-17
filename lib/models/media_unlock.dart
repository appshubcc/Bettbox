import 'package:flutter/material.dart';

const monochromeColorFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0,      0,      0,      1, 0,
]);

const mediaUnlockGreen = Color(0xFF10B981);
const mediaUnlockOrange = Color(0xFFF59E0B);

enum MediaCategory {
  ai,
  streaming,
  china,
  social,
  developer,
  gaming,
  crypto,
}

enum MediaPlatform {
  openai,
  claude,
  gemini,
  grok,
  openrouter,
  poe,
  suno,
  cloudflare,
  perplexity,
  netflix,
  disney,
  youtube,
  spotify,
  tiktok,
  iqiyi,
  crunchyroll,
  missav,
  ehentai,
  qqnews,
  alidnsprobe,
  netease,
  bytedance,
  bilibili,
  cloudflarecn,
  reddit,
  x,
  discord,
  v2ex,
  medium,
  stackoverflow,
  quora,
  telegram,
  github,
  wikipedia,
  apple,
  onetrust,
  gitlab,
  npm,
  cdnjs,
  unpkg,
  nodejs,
  steam,
  epic,
  ubisoft,
  humblebundle,
  coinbase,
  okx,
  kraken,
  cryptocom,
  phantom,
}

extension MediaPlatformExt on MediaPlatform {
  MediaCategory get category => switch (this) {
        MediaPlatform.openai ||
        MediaPlatform.claude ||
        MediaPlatform.gemini ||
        MediaPlatform.grok ||
        MediaPlatform.openrouter ||
        MediaPlatform.poe ||
        MediaPlatform.suno ||
        MediaPlatform.cloudflare ||
        MediaPlatform.perplexity =>
          MediaCategory.ai,
        MediaPlatform.netflix ||
        MediaPlatform.disney ||
        MediaPlatform.youtube ||
        MediaPlatform.spotify ||
        MediaPlatform.tiktok ||
        MediaPlatform.iqiyi ||
        MediaPlatform.crunchyroll ||
        MediaPlatform.missav ||
        MediaPlatform.ehentai =>
          MediaCategory.streaming,
        MediaPlatform.qqnews ||
        MediaPlatform.alidnsprobe ||
        MediaPlatform.netease ||
        MediaPlatform.bytedance ||
        MediaPlatform.bilibili ||
        MediaPlatform.cloudflarecn =>
          MediaCategory.china,
        MediaPlatform.reddit ||
        MediaPlatform.x ||
        MediaPlatform.discord ||
        MediaPlatform.v2ex ||
        MediaPlatform.medium ||
        MediaPlatform.stackoverflow ||
        MediaPlatform.quora ||
        MediaPlatform.telegram =>
          MediaCategory.social,
        MediaPlatform.github ||
        MediaPlatform.wikipedia ||
        MediaPlatform.apple ||
        MediaPlatform.onetrust ||
        MediaPlatform.gitlab ||
        MediaPlatform.npm ||
        MediaPlatform.cdnjs ||
        MediaPlatform.unpkg ||
        MediaPlatform.nodejs =>
          MediaCategory.developer,
        MediaPlatform.steam ||
        MediaPlatform.epic ||
        MediaPlatform.ubisoft ||
        MediaPlatform.humblebundle =>
          MediaCategory.gaming,
        MediaPlatform.coinbase ||
        MediaPlatform.okx ||
        MediaPlatform.kraken ||
        MediaPlatform.cryptocom ||
        MediaPlatform.phantom =>
          MediaCategory.crypto,
      };

  String get defaultName => switch (this) {
        MediaPlatform.openai => 'OpenAI',
        MediaPlatform.claude => 'Claude',
        MediaPlatform.gemini => 'Gemini',
        MediaPlatform.grok => 'Grok',
        MediaPlatform.openrouter => 'OpenRouter',
        MediaPlatform.poe => 'Poe',
        MediaPlatform.suno => 'Suno',
        MediaPlatform.cloudflare => 'Cloudflare',
        MediaPlatform.perplexity => 'Perplexity',
        MediaPlatform.netflix => 'Netflix',
        MediaPlatform.disney => 'Disney+',
        MediaPlatform.youtube => 'YouTube',
        MediaPlatform.spotify => 'Spotify',
        MediaPlatform.tiktok => 'TikTok',
        MediaPlatform.bilibili => 'Bilibili(CN)',
        MediaPlatform.iqiyi => 'iQIYI',
        MediaPlatform.crunchyroll => 'Crunchyroll',
        MediaPlatform.missav => 'MissAV',
        MediaPlatform.ehentai => 'E-Hentai',
        MediaPlatform.qqnews => 'Tencent(CN)',
        MediaPlatform.alidnsprobe => 'Alibaba(CN)',
        MediaPlatform.netease => 'Netease(CN)',
        MediaPlatform.bytedance => 'Douyin(CN)',
        MediaPlatform.cloudflarecn => 'Cloudflare(CN)',
        MediaPlatform.reddit => 'Reddit',
        MediaPlatform.x => 'Twitter',
        MediaPlatform.discord => 'Discord',
        MediaPlatform.v2ex => 'V2EX',
        MediaPlatform.medium => 'Medium',
        MediaPlatform.stackoverflow => 'Stack Overflow',
        MediaPlatform.quora => 'Quora',
        MediaPlatform.telegram => 'Telegram',
        MediaPlatform.github => 'GitHub',
        MediaPlatform.wikipedia => 'Wikipedia',
        MediaPlatform.apple => 'Apple',
        MediaPlatform.onetrust => 'OneTrust',
        MediaPlatform.gitlab => 'GitLab',
        MediaPlatform.npm => 'npm',
        MediaPlatform.cdnjs => 'cdnjs',
        MediaPlatform.unpkg => 'unpkg',
        MediaPlatform.nodejs => 'Node.js',
        MediaPlatform.steam => 'Steam',
        MediaPlatform.epic => 'Epic Games',
        MediaPlatform.ubisoft => 'Ubisoft',
        MediaPlatform.humblebundle => 'Humble Bundle',
        MediaPlatform.coinbase => 'Coinbase',
        MediaPlatform.okx => 'OKX',
        MediaPlatform.kraken => 'Kraken',
        MediaPlatform.cryptocom => 'Crypto.com',
        MediaPlatform.phantom => 'Phantom',
      };

  bool get isMonochrome => switch (this) {
        MediaPlatform.github ||
        MediaPlatform.wikipedia ||
        MediaPlatform.apple ||
        MediaPlatform.x ||
        MediaPlatform.medium ||
        MediaPlatform.grok ||
        MediaPlatform.epic =>
          true,
        _ => false,
      };

  bool get pinColoBadge => this == MediaPlatform.telegram;

  Size get iconSize => switch (this) {
        MediaPlatform.youtube => const Size(19, 13.5),
        MediaPlatform.disney ||
        MediaPlatform.onetrust =>
          const Size(19, 10.5),
        MediaPlatform.netflix => const Size(10, 18),
        MediaPlatform.reddit ||
        MediaPlatform.spotify ||
        MediaPlatform.telegram ||
        MediaPlatform.coinbase ||
        MediaPlatform.cryptocom ||
        MediaPlatform.steam =>
          const Size(15, 15),
        MediaPlatform.openai ||
        MediaPlatform.claude ||
        MediaPlatform.openrouter ||
        MediaPlatform.perplexity ||
        MediaPlatform.apple =>
          const Size(17, 17),
        _ => const Size(16, 16),
      };
}

enum MediaUnlockStatus {
  unlocked,
  limited,
  flagged,
  blocked,
  failed,
  testing,
  unknown,
}

extension MediaUnlockStatusExt on MediaUnlockStatus {
  Color statusColor(ColorScheme colorScheme) => switch (this) {
        MediaUnlockStatus.unlocked => mediaUnlockGreen,
        MediaUnlockStatus.limited || MediaUnlockStatus.flagged =>
          mediaUnlockOrange,
        MediaUnlockStatus.blocked || MediaUnlockStatus.failed =>
          colorScheme.error,
        MediaUnlockStatus.testing => colorScheme.primary,
        MediaUnlockStatus.unknown => colorScheme.outlineVariant,
      };
}

class MediaUnlockResult {
  final MediaPlatform platform;
  final MediaUnlockStatus status;
  final String? region;
  final int? latency;
  final String? colo;
  final String? ip;
  final bool isWarp;

  const MediaUnlockResult({
    required this.platform,
    required this.status,
    this.region,
    this.latency,
    this.colo,
    this.ip,
    this.isWarp = false,
  });

  MediaUnlockResult copyWith({
    MediaPlatform? platform,
    MediaUnlockStatus? status,
    String? region,
    int? latency,
    String? colo,
    String? ip,
    bool? isWarp,
  }) {
    return MediaUnlockResult(
      platform: platform ?? this.platform,
      status: status ?? this.status,
      region: region ?? this.region,
      latency: latency ?? this.latency,
      colo: colo ?? this.colo,
      ip: ip ?? this.ip,
      isWarp: isWarp ?? this.isWarp,
    );
  }
}

class MediaUnlockState {
  final bool isLoading;
  final Map<MediaPlatform, MediaUnlockResult> results;
  final Set<MediaPlatform> testingPlatforms;
  final DateTime? lastChecked;

  const MediaUnlockState({
    this.isLoading = false,
    this.results = const {},
    this.testingPlatforms = const {},
    this.lastChecked,
  });

  MediaUnlockState copyWith({
    bool? isLoading,
    Map<MediaPlatform, MediaUnlockResult>? results,
    Set<MediaPlatform>? testingPlatforms,
    DateTime? lastChecked,
  }) {
    return MediaUnlockState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      testingPlatforms: testingPlatforms ?? this.testingPlatforms,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}
