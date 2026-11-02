import 'package:material_ui/material_ui.dart';

const monochromeColorFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

const mediaUnlockGreen = Color(0xFF10B981);
const mediaUnlockOrange = Color(0xFFF59E0B);

enum MediaCategory { ai, streaming, china, social, developer, gaming, crypto }

enum MediaPlatform {
  openai,
  claude,
  gemini,
  grok,
  openrouter,
  opencode,
  suno,
  cloudflare,
  perplexity,
  netflix,
  disney,
  youtube,
  youtubemusic,
  spotify,
  tiktok,
  iqiyi,
  crunchyroll,
  missav,
  ehentai,
  tencent,
  alibaba,
  netease,
  douyin,
  bilibili,
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
  paypal,
  mytvsuper,
  viutv,
  hoytv,
  rthk,
}

const moreStreamingPlatforms = {
  MediaPlatform.mytvsuper,
  MediaPlatform.viutv,
  MediaPlatform.hoytv,
  MediaPlatform.rthk,
};

extension MediaPlatformExt on MediaPlatform {
  MediaCategory get category => switch (this) {
    MediaPlatform.openai ||
    MediaPlatform.claude ||
    MediaPlatform.gemini ||
    MediaPlatform.grok ||
    MediaPlatform.openrouter ||
    MediaPlatform.opencode ||
    MediaPlatform.suno ||
    MediaPlatform.cloudflare ||
    MediaPlatform.perplexity => MediaCategory.ai,
    MediaPlatform.netflix ||
    MediaPlatform.disney ||
    MediaPlatform.youtube ||
    MediaPlatform.youtubemusic ||
    MediaPlatform.spotify ||
    MediaPlatform.tiktok ||
    MediaPlatform.iqiyi ||
    MediaPlatform.crunchyroll ||
    MediaPlatform.missav ||
    MediaPlatform.ehentai ||
    MediaPlatform.mytvsuper ||
    MediaPlatform.viutv ||
    MediaPlatform.hoytv ||
    MediaPlatform.rthk => MediaCategory.streaming,
    MediaPlatform.tencent ||
    MediaPlatform.alibaba ||
    MediaPlatform.netease ||
    MediaPlatform.douyin ||
    MediaPlatform.bilibili => MediaCategory.china,
    MediaPlatform.reddit ||
    MediaPlatform.x ||
    MediaPlatform.discord ||
    MediaPlatform.v2ex ||
    MediaPlatform.medium ||
    MediaPlatform.stackoverflow ||
    MediaPlatform.quora ||
    MediaPlatform.telegram => MediaCategory.social,
    MediaPlatform.github ||
    MediaPlatform.wikipedia ||
    MediaPlatform.apple ||
    MediaPlatform.onetrust ||
    MediaPlatform.gitlab ||
    MediaPlatform.npm ||
    MediaPlatform.cdnjs ||
    MediaPlatform.unpkg ||
    MediaPlatform.nodejs => MediaCategory.developer,
    MediaPlatform.steam ||
    MediaPlatform.epic ||
    MediaPlatform.ubisoft ||
    MediaPlatform.humblebundle => MediaCategory.gaming,
    MediaPlatform.coinbase ||
    MediaPlatform.okx ||
    MediaPlatform.kraken ||
    MediaPlatform.cryptocom ||
    MediaPlatform.phantom ||
    MediaPlatform.paypal => MediaCategory.crypto,
  };

  String get defaultName => switch (this) {
    MediaPlatform.openai => 'OpenAI',
    MediaPlatform.claude => 'Claude',
    MediaPlatform.gemini => 'Gemini',
    MediaPlatform.grok => 'Grok',
    MediaPlatform.openrouter => 'OpenRouter',
    MediaPlatform.opencode => 'OpenCode',
    MediaPlatform.suno => 'Suno',
    MediaPlatform.cloudflare => 'Cloudflare',
    MediaPlatform.perplexity => 'Perplexity',
    MediaPlatform.netflix => 'Netflix',
    MediaPlatform.disney => 'Disney+',
    MediaPlatform.youtube => 'YouTube',
    MediaPlatform.youtubemusic => 'YouTube Music',
    MediaPlatform.spotify => 'Spotify',
    MediaPlatform.tiktok => 'TikTok',
    MediaPlatform.bilibili => 'Bilibili(CN)',
    MediaPlatform.iqiyi => 'iQIYI',
    MediaPlatform.crunchyroll => 'Crunchyroll',
    MediaPlatform.missav => 'MissAV',
    MediaPlatform.ehentai => 'E-Hentai',
    MediaPlatform.tencent => 'Tencent(CN)',
    MediaPlatform.alibaba => 'Alibaba(CN)',
    MediaPlatform.netease => 'Netease(CN)',
    MediaPlatform.douyin => 'Douyin(CN)',
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
    MediaPlatform.cryptocom => 'Crypto',
    MediaPlatform.phantom => 'Phantom',
    MediaPlatform.paypal => 'PayPal',
    MediaPlatform.mytvsuper => 'myTV SUPER',
    MediaPlatform.viutv => 'ViuTV',
    MediaPlatform.hoytv => 'HOY TV',
    MediaPlatform.rthk => 'RTHK',
  };

  String get icon => switch (this) {
    MediaPlatform.openai => 'OpenAI.svg',
    MediaPlatform.claude => 'Claude.svg',
    MediaPlatform.gemini => 'Gemini.svg',
    MediaPlatform.grok => 'Grok.svg',
    MediaPlatform.openrouter => 'OpenRouter.svg',
    MediaPlatform.opencode => 'Opencode.svg',
    MediaPlatform.suno => 'Suno.svg',
    MediaPlatform.cloudflare => 'Cloudflare.svg',
    MediaPlatform.perplexity => 'Perplexity.svg',
    MediaPlatform.netflix => 'Netflix.svg',
    MediaPlatform.disney => 'Disney.svg',
    MediaPlatform.youtube => 'YouTube.svg',
    MediaPlatform.youtubemusic => 'YouTubeMusic.svg',
    MediaPlatform.spotify => 'Spotify.svg',
    MediaPlatform.tiktok => 'TikTok.svg',
    MediaPlatform.iqiyi => 'iQIYI.svg',
    MediaPlatform.crunchyroll => 'Crunchyroll.svg',
    MediaPlatform.missav => 'MissAV.svg',
    MediaPlatform.ehentai => 'EHentai.svg',
    MediaPlatform.tencent => 'QQ.svg',
    MediaPlatform.alibaba => 'Alibaba.svg',
    MediaPlatform.netease => 'NetEase.svg',
    MediaPlatform.douyin => 'Douyin.svg',
    MediaPlatform.bilibili => 'Bilibili.svg',
    MediaPlatform.reddit => 'Reddit.svg',
    MediaPlatform.x => 'Twitter.svg',
    MediaPlatform.discord => 'Discord.svg',
    MediaPlatform.v2ex => 'V2EX.svg',
    MediaPlatform.medium => 'Medium.svg',
    MediaPlatform.stackoverflow => 'StackOverflow.svg',
    MediaPlatform.quora => 'Quora.svg',
    MediaPlatform.telegram => 'Telegram.svg',
    MediaPlatform.github => 'GitHub.svg',
    MediaPlatform.wikipedia => 'Wikipedia.svg',
    MediaPlatform.apple => 'Apple.svg',
    MediaPlatform.onetrust => 'OneTrust.svg',
    MediaPlatform.gitlab => 'GitLab.svg',
    MediaPlatform.npm => 'Npm.svg',
    MediaPlatform.cdnjs => 'Cdnjs.svg',
    MediaPlatform.unpkg => 'Unpkg.svg',
    MediaPlatform.nodejs => 'NodeJs.svg',
    MediaPlatform.steam => 'Steam.svg',
    MediaPlatform.epic => 'EpicGames.svg',
    MediaPlatform.ubisoft => 'Ubisoft.svg',
    MediaPlatform.humblebundle => 'HumbleBundle.svg',
    MediaPlatform.coinbase => 'Coinbase.svg',
    MediaPlatform.okx => 'OKX.svg',
    MediaPlatform.kraken => 'Kraken.svg',
    MediaPlatform.cryptocom => 'CryptoCom.svg',
    MediaPlatform.phantom => 'Phantom.svg',
    MediaPlatform.paypal => 'PayPal.svg',
    MediaPlatform.mytvsuper => 'MyTVSuper.svg',
    MediaPlatform.viutv => 'ViuTV.svg',
    MediaPlatform.hoytv => 'HOYTV.svg',
    MediaPlatform.rthk => 'RTHK.svg',
  };

  bool get isMonochrome => switch (this) {
    MediaPlatform.opencode ||
    MediaPlatform.github ||
    MediaPlatform.wikipedia ||
    MediaPlatform.apple ||
    MediaPlatform.medium ||
    MediaPlatform.grok ||
    MediaPlatform.epic ||
    MediaPlatform.onetrust ||
    MediaPlatform.openrouter ||
    MediaPlatform.suno ||
    MediaPlatform.v2ex ||
    MediaPlatform.unpkg ||
    MediaPlatform.ubisoft ||
    MediaPlatform.okx => true,
    _ => false,
  };

  bool get pinColoBadge => this == MediaPlatform.telegram;

  Size get iconSize => switch (this) {
    MediaPlatform.youtube ||
    MediaPlatform.youtubemusic ||
    MediaPlatform.disney ||
    MediaPlatform.onetrust ||
    MediaPlatform.iqiyi ||
    MediaPlatform.alibaba ||
    MediaPlatform.okx => const Size(19, 19),
    MediaPlatform.netflix ||
    MediaPlatform.gemini ||
    MediaPlatform.cloudflare ||
    MediaPlatform.mytvsuper ||
    MediaPlatform.viutv ||
    MediaPlatform.hoytv ||
    MediaPlatform.rthk => const Size(18, 18),
    MediaPlatform.ehentai ||
    MediaPlatform.npm ||
    MediaPlatform.unpkg ||
    MediaPlatform.v2ex => const Size(16, 16),
    _ => const Size(17, 17),
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
    MediaUnlockStatus.limited || MediaUnlockStatus.flagged => mediaUnlockOrange,
    MediaUnlockStatus.blocked || MediaUnlockStatus.failed => colorScheme.error,
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
