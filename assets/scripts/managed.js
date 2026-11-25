/**
 * 覆写脚本源作者及仓库：@AIsouler https://github.com/AIsouler/MyClash 
 * 分流管理自定义图标集：@aaANDkk https://github.com/aaANDkk/Qure_Style_SVG
 * 自定义分流远程规则集：@appshubcc https://github.com/appshubcc/bett-rules 
 */

// @version 2026112502
const Compatible_With_Bettbox = { ruleOptionsEnable: true };

const ruleOptionsEnable = {
  '手动选择': true,
  '自动选择': false,

  'AI': true,
  'FCM': true,
  'YouTube': true,
  'Google': true,
  'GitHub': true,
  'Microsoft': true,
  'Apple': true,
  'Telegram': true,
  'Steam': true,
  'TikTok': true,
  'Twitter': true,
  'Meta': true,
  'Netflix': true,
  'PikPak': false,
  'Spotify': false,
  'Crypto': true,
  'AdBlock': true,

  '极简国内外分流模式': false,
  '生成地区自动选择组': false,
  '隐藏地区手动选择组': false,
  '分流组添加所有节点': false,
  '生成高低倍率组': false,
  '过滤低倍率节点': false,
  '过滤高倍率节点': false,
  '过滤非地区节点': true,
  '禁用内核QUIC流量': true,
  '优先国内DNS加速': true,
  '优先连接IPv6节点': false,
};

const prefixRules = [
  'RULE-SET,private,DIRECT',
];

const directRules = [
  'RULE-SET,geolocation-cn,直连',
  'RULE-SET,category-ai-cn,直连',
  'RULE-SET,microsoft_cn,直连',
  'RULE-SET,games_cn,直连',
  'RULE-SET,games_download_cn,直连',
  'RULE-SET,apple_cn,直连',
  // 'RULE-SET,google_cn,直连',
];

const excludeFilter =
  /群|返利|循环|官网|客服|网站|网址|获取|订阅|流量|到期|机场|下次|版本|官址|备用|过期|已用|联系|邮箱|工单|贩卖|通知|倒卖|防止|国内|地址|频道|电报|无法|说明|提示|访问|支持|教程|关注|更新|作者|加入|超时|收藏|优惠|福利|邀请|好友|失联|选择|剩余|公益|发布|DIZTNA|通路|登录|禁止|定时|渠道|牢记|永久|余额|阁下|本站|刷新|导航|建议|重置|以下|过滤|⚠️|@|t\.me\/\+|\bexpire\b|\bhttps?:\/\/|\.com|\btraffic\b/iu;

const blockQuicRules = ['AND,((NETWORK,UDP),(DST-PORT,443)),REJECT'];

const udpOptionalProxyTypes = new Set([
  'ss',
  'ssr',
  'socks5',
  'vmess',
  'vless',
  'trojan',
  'wireguard',
  'gost-relay',
  'mieru',
  'anytls',
  'masque',
  'trusttunnel',
  'tailscale',
  'zerotier',
  'easytier',
]);

const directProxies = [
  {
    name: '🇨🇳 直连 | IPv4优先',
    type: 'direct',
    'ip-version': 'ipv4-prefer',
  },
  {
    name: '🇨🇳 直连 | IPv6优先',
    type: 'direct',
    'ip-version': 'ipv6-prefer',
  },
];


const iconBaseUrl = 'https://cdn.jsdelivr.net/gh/appshubcc/Qure_Style_SVG@main/icon/svg/';
const ruleSetBaseUrl = 'https://cdn.jsdelivr.net/gh/appshubcc/bett-rules@meta/geo/';
const directTestUrl = 'http://dns.alidns.com';

const regionDefinitions = [
  {
    name: '香港',
    flag: '🇭🇰',
    regex: /🇭🇰|香港|(?<![A-Za-z])HKG?(?![A-Za-z])|hong\s*kong/i,
    icon: `${iconBaseUrl}flag/Hong_Kong.svg`,
    default: true,
  },
  {
    name: '日本',
    flag: '🇯🇵',
    regex: /🇯🇵|日本|东京|大阪|京都|(?<![A-Za-z])JPN?(?![A-Za-z])|japan/i,
    icon: `${iconBaseUrl}flag/Japan.svg`,
    default: true,
  },
  {
    name: '美国',
    flag: '🇺🇸',
    regex: /🇺🇸|美国|纽约|洛杉矶|旧金山|芝加哥|休斯顿|迈阿密|西雅图|波士顿|华盛顿|拉斯维加斯|圣何塞|(?<![A-Za-z])USA?(?![A-Za-z])|america|united\s*states/i,
    icon: `${iconBaseUrl}flag/United_States.svg`,
    default: true,
  },
  {
    name: '新加坡',
    flag: '🇸🇬',
    regex: /🇸🇬|新加坡|狮城|(?<![A-Za-z])SGP?(?![A-Za-z])|singapore/i,
    icon: `${iconBaseUrl}flag/Singapore.svg`,
    default: true,
  },
  {
    name: '台湾',
    flag: '🇹🇼',
    regex: /🇹🇼|台湾|台北|高雄|(?<![A-Za-z])TWN?(?![A-Za-z])|taiwan/i,
    icon: `${iconBaseUrl}flag/China_Taiwan.svg`,
    default: true,
  },
  {
    name: '韩国',
    flag: '🇰🇷',
    regex: /🇰🇷|(?<!北)(?:韩国|南韩)|首尔|汉城|仁川|春川|釜山|大邱|大田|光州|济州|(?<![A-Za-z])(?:KR|KOR|ICN|(?i:(?<!north\s*)korean?|seoul|incheon|chuncheon|busan|pusan|jeju))(?![A-Za-z])/,
    icon: `${iconBaseUrl}flag/South_Korea.svg`,
    default: false,
  },
];

const customRegionDefinitions =
  typeof bettboxCustomRegions !== 'undefined' && Array.isArray(bettboxCustomRegions)
    ? bettboxCustomRegions
      .filter((r) => r && typeof r.name === 'string' && typeof r.regex === 'string')
      .map((r) => {
        let reg;
        try {
          const match = r.regex.match(/^\/(.+)\/([a-z]*)$/i);
          const source = match ? match[1] : r.regex.trim();
          if (!source) throw new SyntaxError('empty pattern');
          reg = new RegExp(source, `${match ? match[2].replace(/[gyi]/gi, '') : ''}i`);
        } catch {
          reg = new RegExp(RegExp.escape(r.name), 'i');
        }
        return {
          name: r.name,
          regex: reg,
          icon: typeof r.icon === 'string' && r.icon ? r.icon : `${iconBaseUrl}common/Airport.svg`,
        };
      })
    : [];

const allAvailableRegions = [...regionDefinitions, ...customRegionDefinitions];

const enabledRegionNames =
  typeof bettboxRegions !== 'undefined' && Array.isArray(bettboxRegions) ? new Set(bettboxRegions) : null;
const activeRegionDefinitions = allAvailableRegions.filter((region) =>
  enabledRegionNames ? enabledRegionNames.has(region.name) : region.default,
);

const lowRateRegionName = '低倍率节点';
const highRateRegionName = '高倍率节点';

const rateRegionDefinitions = [
  {
    name: lowRateRegionName,
    regex: /^(?!.*(?:剩|期)).*(?:(?<![\d.])0(?:\.[0-5]|[*×✕✖⨯⨉倍]|x(?![A-Za-z])))|(?:(?:[*×✕✖⨯⨉]|(?<![A-Za-z])x)0(?:\.[0-5]\d*)?(?![\d.]))|^(?!.*(?:客户端|软件)).*下载|低倍|免费|(?<![A-Za-z])free(?![A-Za-z])/i,
    icon: `${iconBaseUrl}common/Available.svg`,
  },
  {
    name: highRateRegionName,
    regex: /(?:(?:[*×✕✖⨯⨉]|(?<![A-Za-z])x)(?:[2-9]\d*|[1-9]\d+)(?:\.\d+)?)|(?:(?<![\d.])(?:[2-9]\d*|[1-9]\d+)(?:\.\d+)?(?:倍|[*×✕✖⨯⨉]|x(?![A-Za-z])))/i,
    icon: `${iconBaseUrl}common/Airport.svg`,
  },
];

const allRegionDefinitions = [...activeRegionDefinitions, ...rateRegionDefinitions];

const ruleProviderCommonDomain = {
  type: 'http',
  format: 'mrs',
  interval: 86400,
  behavior: 'domain',
};
const ruleProviderCommonIpcidr = {
  type: 'http',
  format: 'mrs',
  interval: 86400,
  behavior: 'ipcidr',
};

const baseRuleProviders = {
  private: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/private.mrs`,
    path: './ruleset/private.mrs',
    'path-in-bundle': 'geo/geosite/private.mrs',
  },
  private_ip: {
    ...ruleProviderCommonIpcidr,
    url: `${ruleSetBaseUrl}geoip/private.mrs`,
    path: './ruleset/private_ip.mrs',
    'path-in-bundle': 'geo/geoip/private.mrs',
  },
  games_cn: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/category-games@cn.mrs`,
    path: './ruleset/category-games@cn.mrs',
    'path-in-bundle': 'geo/geosite/category-games@cn.mrs',
  },
  games_download_cn: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/category-game-platforms-download@cn.mrs`,
    path: './ruleset/category-game-platforms-download@cn.mrs',
    'path-in-bundle': 'geo/geosite/category-game-platforms-download@cn.mrs',
  },
  apple_cn: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/apple@cn.mrs`,
    path: './ruleset/apple@cn.mrs',
    'path-in-bundle': 'geo/geosite/apple@cn.mrs',
  },
  ...(directRules.some((r) => r.includes(',google_cn,')) && {
    google_cn: {
      ...ruleProviderCommonDomain,
      url: `${ruleSetBaseUrl}geosite/google@cn.mrs`,
      path: './ruleset/google@cn.mrs',
      'path-in-bundle': 'geo/geosite/google@cn.mrs',
    },
  }),
  microsoft_cn: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/microsoft@cn.mrs`,
    path: './ruleset/microsoft@cn.mrs',
    'path-in-bundle': 'geo/geosite/microsoft@cn.mrs',
  },
  'geolocation-cn': {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/geolocation-cn.mrs`,
    path: './ruleset/geolocation-cn.mrs',
    'path-in-bundle': 'geo/geosite/geolocation-cn.mrs',
  },
  'category-ai-cn': {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/category-ai-cn.mrs`,
    path: './ruleset/category-ai-cn.mrs',
    'path-in-bundle': 'geo/geosite/category-ai-cn.mrs',
  },
  cn_ip: {
    ...ruleProviderCommonIpcidr,
    url: `${ruleSetBaseUrl}geoip/cn.mrs`,
    path: './ruleset/cn_ip.mrs',
    'path-in-bundle': 'geo/geoip/cn.mrs',
  },
  'geolocation-!cn': {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/geolocation-!cn.mrs`,
    path: './ruleset/geolocation-!cn.mrs',
    'path-in-bundle': 'geo/geosite/geolocation-!cn.mrs',
  },
  fakeip_filter: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/fakeip-filter.mrs`,
    path: './ruleset/fakeip-filter.mrs',
    'path-in-bundle': 'geo/geosite/fakeip-filter.mrs',
  },
  connectcheck: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/connectivity-check.mrs`,
    path: './ruleset/connectivity-check.mrs',
    'path-in-bundle': 'geo/geosite/connectivity-check.mrs',
  },
  cn: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/cn.mrs`,
    path: './ruleset/cn.mrs',
    'path-in-bundle': 'geo/geosite/cn.mrs',
  },
  douyin: {
    ...ruleProviderCommonDomain,
    url: `${ruleSetBaseUrl}geosite/douyin.mrs`,
    path: './ruleset/douyin.mrs',
    'path-in-bundle': 'geo/geosite/douyin.mrs',
  },
};

const groupBaseOption = {
  url: 'http://www.msftncsi.com/ncsi.txt',
  'max-failed-times': 3,
  'empty-fallback': 'REJECT',
};

const selectBaseOption = {
  ...groupBaseOption,
  type: 'select',
};

const urlTestBaseOption = {
  ...groupBaseOption,
  type: 'url-test',
  interval: 600,
  lazy: true,
  tolerance: 50,
  'exclude-type': 'DIRECT',
  icon: `${iconBaseUrl}common/Auto.svg`,
  hidden: true,
};

const baseGroups = [
  {
    name: '手动选择',
    baseOption: selectBaseOption,
    includeAll: true,
    icon: `${iconBaseUrl}common/Static.svg`,
  },
  {
    name: '自动选择',
    baseOption: urlTestBaseOption,
    includeAll: true,
    icon: `${iconBaseUrl}common/Auto.svg`,
  },
];

const rejectGroupProxies = ['REJECT', 'PASS', '直连', '默认代理'];
const nonHkRegionPriority = ['台湾', '新加坡', '日本', '美国'];

const serviceConfigs = [
  ...baseGroups,
  {
    name: 'AI',
    baseOption: selectBaseOption,
    defaultSelected: nonHkRegionPriority,
    providers: {
      ai: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/category-ai-!cn.mrs`,
        path: './ruleset/ai.mrs',
        'path-in-bundle': 'geo/geosite/category-ai-!cn.mrs',
      },
      openai_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/openai.mrs`,
        path: './ruleset/openai_ip.mrs',
        'path-in-bundle': 'geo/geoip/openai.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Anthropic.svg`,
    rules: ['RULE-SET,ai,AI'],
    ipRules: ['RULE-SET,openai_ip,AI'],
  },
  {
    name: 'YouTube',
    baseOption: selectBaseOption,
    providers: {
      youtube: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/youtube.mrs`,
        path: './ruleset/youtube.mrs',
        'path-in-bundle': 'geo/geosite/youtube.mrs',
      },
    },
    icon: `${iconBaseUrl}common/YouTube.svg`,
    rules: ['RULE-SET,youtube,YouTube'],
  },
  {
    name: 'FCM',
    baseOption: selectBaseOption,
    direct: true,
    defaultSelected: '直连',
    providers: {
      googlefcm: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/googlefcm.mrs`,
        path: './ruleset/googlefcm.mrs',
        'path-in-bundle': 'geo/geosite/googlefcm.mrs',
      },
    },
    icon: `${iconBaseUrl}common/FCM.svg`,
    rules: ['RULE-SET,googlefcm,FCM'],
  },
  {
    name: 'Google',
    baseOption: selectBaseOption,
    defaultSelected: nonHkRegionPriority,
    providers: {
      google: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/google.mrs`,
        path: './ruleset/google.mrs',
        'path-in-bundle': 'geo/geosite/google.mrs',
      },
      google_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/google.mrs`,
        path: './ruleset/google_ip.mrs',
        'path-in-bundle': 'geo/geoip/google.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Google.svg`,
    rules: ['RULE-SET,google,Google'],
    ipRules: ['RULE-SET,google_ip,Google'],
  },
  {
    name: 'Telegram',
    baseOption: selectBaseOption,
    providers: {
      telegram: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/telegram.mrs`,
        path: './ruleset/telegram.mrs',
        'path-in-bundle': 'geo/geosite/telegram.mrs',
      },
      telegram_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/telegram.mrs`,
        path: './ruleset/telegram_ip.mrs',
        'path-in-bundle': 'geo/geoip/telegram.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Telegram.svg`,
    rules: ['RULE-SET,telegram,Telegram'],
    ipRules: ['RULE-SET,telegram_ip,Telegram'],
  },
  {
    name: 'GitHub',
    baseOption: selectBaseOption,
    providers: {
      github: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/github.mrs`,
        path: './ruleset/github.mrs',
        'path-in-bundle': 'geo/geosite/github.mrs',
      },
    },
    icon: `${iconBaseUrl}common/GitHub.svg`,
    rules: ['RULE-SET,github,GitHub'],
  },
  {
    name: 'Microsoft',
    baseOption: selectBaseOption,
    direct: true,
    providers: {
      microsoft: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/microsoft.mrs`,
        path: './ruleset/microsoft.mrs',
        'path-in-bundle': 'geo/geosite/microsoft.mrs',
      },
      microsoft_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/microsoft.mrs`,
        path: './ruleset/microsoft_ip.mrs',
        'path-in-bundle': 'geo/geoip/microsoft.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Microsoft.svg`,
    rules: ['RULE-SET,microsoft,Microsoft'],
    ipRules: ['RULE-SET,microsoft_ip,Microsoft'],
  },
  {
    name: 'Apple',
    baseOption: selectBaseOption,
    direct: true,
    providers: {
      apple: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/apple.mrs`,
        path: './ruleset/apple.mrs',
        'path-in-bundle': 'geo/geosite/apple.mrs',
      },
      apple_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/apple.mrs`,
        path: './ruleset/apple_ip.mrs',
        'path-in-bundle': 'geo/geoip/apple.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Apple.svg`,
    rules: ['RULE-SET,apple,Apple'],
    ipRules: ['RULE-SET,apple_ip,Apple'],
  },
  {
    name: 'Steam',
    baseOption: selectBaseOption,
    direct: true,
    providers: {
      steam: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/steam.mrs`,
        path: './ruleset/steam.mrs',
        'path-in-bundle': 'geo/geosite/steam.mrs',
      },
      steam_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/steam.mrs`,
        path: './ruleset/steam_ip.mrs',
        'path-in-bundle': 'geo/geoip/steam.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Steam.svg`,
    rules: ['RULE-SET,steam,Steam'],
    ipRules: ['RULE-SET,steam_ip,Steam'],
  },
  {
    name: 'TikTok',
    baseOption: selectBaseOption,
    defaultSelected: '日本',
    providers: {
      tiktok: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/tiktok.mrs`,
        path: './ruleset/tiktok.mrs',
        'path-in-bundle': 'geo/geosite/tiktok.mrs',
      },
      tiktok_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/tiktok.mrs`,
        path: './ruleset/tiktok_ip.mrs',
        'path-in-bundle': 'geo/geoip/tiktok.mrs',
      },
    },
    icon: `${iconBaseUrl}common/TikTok.svg`,
    rules: ['RULE-SET,tiktok,TikTok'],
    ipRules: ['RULE-SET,tiktok_ip,TikTok'],
  },
  {
    name: 'Twitter',
    baseOption: selectBaseOption,
    providers: {
      twitter: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/twitter.mrs`,
        path: './ruleset/twitter.mrs',
        'path-in-bundle': 'geo/geosite/twitter.mrs',
      },
      twitter_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/twitter.mrs`,
        path: './ruleset/twitter_ip.mrs',
        'path-in-bundle': 'geo/geoip/twitter.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Twitter.svg`,
    rules: ['RULE-SET,twitter,Twitter'],
    ipRules: ['RULE-SET,twitter_ip,Twitter'],
  },
  {
    name: 'Meta',
    baseOption: selectBaseOption,
    providers: {
      meta: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/meta.mrs`,
        path: './ruleset/meta.mrs',
        'path-in-bundle': 'geo/geosite/meta.mrs',
      },
      facebook_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/facebook.mrs`,
        path: './ruleset/facebook_ip.mrs',
        'path-in-bundle': 'geo/geoip/facebook.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Meta.svg`,
    rules: ['RULE-SET,meta,Meta'],
    ipRules: ['RULE-SET,facebook_ip,Meta'],
  },
  {
    name: 'Netflix',
    baseOption: selectBaseOption,
    providers: {
      netflix: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/netflix.mrs`,
        path: './ruleset/netflix.mrs',
        'path-in-bundle': 'geo/geosite/netflix.mrs',
      },
      netflix_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/netflix.mrs`,
        path: './ruleset/netflix_ip.mrs',
        'path-in-bundle': 'geo/geoip/netflix.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Netflix.svg`,
    rules: ['RULE-SET,netflix,Netflix'],
    ipRules: ['RULE-SET,netflix_ip,Netflix'],
  },
  {
    name: 'PikPak',
    baseOption: selectBaseOption,
    direct: true,
    providers: {
      pikpak: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/pikpak.mrs`,
        path: './ruleset/pikpak.mrs',
        'path-in-bundle': 'geo/geosite/pikpak.mrs',
      },
    },
    icon: `${iconBaseUrl}common/PikPak.svg`,
    rules: ['RULE-SET,pikpak,PikPak'],
  },
  {
    name: 'Spotify',
    baseOption: selectBaseOption,
    direct: true,
    providers: {
      spotify: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/spotify.mrs`,
        path: './ruleset/spotify.mrs',
        'path-in-bundle': 'geo/geosite/spotify.mrs',
      },
      spotify_ip: {
        ...ruleProviderCommonIpcidr,
        url: `${ruleSetBaseUrl}geoip/spotify.mrs`,
        path: './ruleset/spotify_ip.mrs',
        'path-in-bundle': 'geo/geoip/spotify.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Spotify.svg`,
    rules: ['RULE-SET,spotify,Spotify'],
    ipRules: ['RULE-SET,spotify_ip,Spotify'],
  },
  {
    name: 'Crypto',
    baseOption: selectBaseOption,
    defaultSelected: '日本',
    providers: {
      cryptocurrency: {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/category-cryptocurrency.mrs`,
        path: './ruleset/cryptocurrency.mrs',
        'path-in-bundle': 'geo/geosite/category-cryptocurrency.mrs',
      },
    },
    icon: `${iconBaseUrl}common/Bitcoin.svg`,
    rules: ['RULE-SET,cryptocurrency,Crypto'],
  },
  {
    name: 'AdBlock',
    baseOption: selectBaseOption,
    reject: true,
    priority: true,
    providers: {
      'category-ads': {
        ...ruleProviderCommonDomain,
        url: `${ruleSetBaseUrl}geosite/category-ads.mrs`,
        path: './ruleset/category-ads.mrs',
        'path-in-bundle': 'geo/geosite/category-ads.mrs',
      },
    },
    icon: `${iconBaseUrl}common/AdBlock.svg`,
    rules: ['RULE-SET,category-ads,AdBlock'],
  },
];

/**
 * 适配 Bettbox 策略组开关
 * 声明哪些开关属于策略组：基础策略组 + 全部分流策略组。
 */
Compatible_With_Bettbox.policyGroupOptions = serviceConfigs.map((svc) => svc.name);

const customRoutes = typeof bettboxRoutes !== 'undefined' && Array.isArray(bettboxRoutes) ? bettboxRoutes : [];
const groupOrder = typeof bettboxOrder !== 'undefined' && Array.isArray(bettboxOrder) ? bettboxOrder : [];
const builtinRuleDeps = [
  ['AI', 'Google'],
  ['AI', 'Microsoft'],
  ['YouTube', 'Google'],
  ['FCM', 'Google'],
  ['GitHub', 'Microsoft'],
];
const customRuleDeps =
  typeof bettboxRuleDeps !== 'undefined' && Array.isArray(bettboxRuleDeps) ? bettboxRuleDeps : [];
const allRuleDeps = [...builtinRuleDeps, ...customRuleDeps];
const builtInReservedNames = [
  'GLOBAL',
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'PASS',
  'PASS-RULE',
  'COMPATIBLE',
  '默认代理',
  '直连',
  '其他节点',
  '其他节点-自动选择',
  ...serviceConfigs.map((svc) => svc.name),
  ...allRegionDefinitions.flatMap((region) => [region.name, `${region.name}-自动选择`]),
  ...directProxies.map((p) => p.name),
];

/**
 * 零宽/不可见字符：部分机场会在节点名中逐字符插入这类字符（如 H\u200BK），会打断地区、倍率等正则匹配。
 *
 * 刻意排除三类「有语义」的字符，避免误伤：
 * - U+200C / U+200D（ZWNJ / ZWJ）：参与连字与 emoji 组合，删掉会改变字形；
 * - U+FE00–U+FE0F 及 U+E0100–U+E01EF（变体选择符）：控制 emoji 呈现方式；
 * - U+E0020–U+E007F（标签字符）：组成英格兰、苏格兰等地区旗帜。
 * 其余零宽/不可见字符不含任何语义，只用于干扰匹配，可安全忽略。
 */
const invisibleCharsRegex =
  /[\p{Default_Ignorable_Code_Point}--[\u200C\u200D\uFE00-\uFE0F\u{E0020}-\u{E007F}\u{E0100}-\u{E01EF}]]/gv;

/**
 * 取节点名「可用于匹配」的形式：剥离零宽/不可见字符
 */
function toMatchableName(name) {
  return typeof name === 'string' ? name.replace(invisibleCharsRegex, '') : name;
}

/**
 * 节点匹配缓存，避免重复执行正则
 */
const regionMatchCache = new Map();
function getMatchedRegions(proxyName) {
  if (regionMatchCache.has(proxyName)) {
    return regionMatchCache.get(proxyName);
  }

  const matchableName = toMatchableName(proxyName);
  const regions = allRegionDefinitions.filter((region) => region.regex.test(matchableName));
  regionMatchCache.set(proxyName, regions);

  return regions;
}

const userNodeNames =
  typeof bettboxNodeNames !== 'undefined' && Array.isArray(bettboxNodeNames)
    ? bettboxNodeNames.filter((name) => typeof name === 'string' && name)
    : [];

Compatible_With_Bettbox.nodeRegions = Object.fromEntries(
  userNodeNames.map((name) => [
    name,
    getMatchedRegions(name)
      .filter((region) => activeRegionDefinitions.includes(region))
      .map((region) => region.name),
  ]),
);

/**
 * 标准化节点名称：补全地区国旗、折叠多余空格，并预缓存匹配结果
 */
const flagRegex = /\p{RGI_Emoji_Flag_Sequence}/v;
function normalizeProxyName(proxy) {
  const originalName = proxy.name;

  const flag = originalName.match(flagRegex)?.[0];

  const nameWithoutFlag = (flag ? originalName.replace(flag, '') : originalName).replace(/\s+/g, ' ').trim();

  const matchedRegions = getMatchedRegions(originalName);

  const regionFlag = flag || matchedRegions.find((region) => region.flag)?.flag;

  const normalizedName = regionFlag
    ? (nameWithoutFlag ? `${regionFlag} ${nameWithoutFlag}` : regionFlag)
    : nameWithoutFlag;

  if (normalizedName !== originalName) {
    regionMatchCache.set(normalizedName, matchedRegions);
  }

  return normalizedName === originalName ? proxy : { ...proxy, name: normalizedName };
}

/**
 * 解析 dialer-proxy 目标：节点按重命名更新，只含单个成员的原策略组展开为该成员，无法确定唯一节点时返回 null
 */
function resolveDialerTarget(target, renameMap, proxyNames, groupMembers) {
  const seen = new Set();
  let current = target;
  while (!seen.has(current)) {
    seen.add(current);
    if (renameMap.has(current)) return renameMap.get(current);
    if (proxyNames.has(current)) return current;
    const members = groupMembers.get(current);
    if (members?.length !== 1) return null;
    current = members[0];
  }
  return null;
}

/**
 * 修复 dialer-proxy 引用：目标无法解析为保留下来的节点时返回 null，由调用方剔除该节点，避免中转失效后直连落地
 */
function fixDialerProxy(proxy, renameMap, proxyNames, groupMembers) {
  if (proxy['dialer-proxy'] == null || proxy['dialer-proxy'] === '') return proxy;
  const target = resolveDialerTarget(String(proxy['dialer-proxy']), renameMap, proxyNames, groupMembers);
  if (target === null) return null;
  return target === proxy['dialer-proxy'] ? proxy : { ...proxy, 'dialer-proxy': target };
}

/**
 * 过滤并标准化节点：剔除内置/信息节点、按配置过滤、去重、修复 dialer-proxy 引用，空列表时抛错
 */
function filterAndNormalizeProxies(config) {
  regionMatchCache.clear();

  const filterLowRateProxiesEnabled = ruleOptionsEnable.过滤低倍率节点;
  const filterHighRateProxiesEnabled = ruleOptionsEnable.过滤高倍率节点;
  const filterNonRegionProxiesEnabled = ruleOptionsEnable.过滤非地区节点;

  const lowRateRegex = filterLowRateProxiesEnabled
    ? rateRegionDefinitions.find((r) => r.name === lowRateRegionName)?.regex
    : null;
  const highRateRegex = filterHighRateProxiesEnabled
    ? rateRegionDefinitions.find((r) => r.name === highRateRegionName)?.regex
    : null;

  const originalProxies = (Array.isArray(config.proxies) ? config.proxies : [])
    .filter((proxy) => proxy && typeof proxy === 'object' && proxy.name != null)
    .map((proxy) => (typeof proxy.name === 'string' ? proxy : { ...proxy, name: String(proxy.name) }));

  const filteredRawProxies = originalProxies.filter((proxy) => {
    const type = String(proxy.type ?? '').toLowerCase();
    if (type === 'direct' || type === 'reject' || type === 'rematch') return false;

    const matchableName = toMatchableName(proxy.name);

    if (lowRateRegex?.test(matchableName) || highRateRegex?.test(matchableName)) return false;

    if (!filterNonRegionProxiesEnabled) return true;

    const isRegionProxy = getMatchedRegions(proxy.name).some((region) => activeRegionDefinitions.includes(region));

    return isRegionProxy || !excludeFilter.test(matchableName);
  });

  const reservedProxyNames = new Set([
    ...builtInReservedNames,
    ...customRoutes
      .filter((route) => route && typeof route.name === 'string' && Array.isArray(route.sets) && route.sets.length > 0)
      .map((route) => route.name),
  ]);
  const renameMap = new Map();
  const normalizedProxies = [];
  const rawNames = new Set();
  const proxyNames = new Set();

  for (const rawProxy of filteredRawProxies) {
    if (rawNames.has(rawProxy.name)) continue;
    rawNames.add(rawProxy.name);

    let normalized = normalizeProxyName(rawProxy);
    const baseName = normalized.name || '节点';
    let candidate = baseName;
    if (proxyNames.has(candidate) || reservedProxyNames.has(candidate)) {
      let index = 2;
      while (proxyNames.has(`${baseName} ${index}`) || reservedProxyNames.has(`${baseName} ${index}`)) index++;
      candidate = `${baseName} ${index}`;
    }
    if (candidate !== normalized.name) {
      regionMatchCache.set(candidate, getMatchedRegions(rawProxy.name));
      normalized = { ...normalized, name: candidate };
    }
    if (normalized.name !== rawProxy.name) {
      renameMap.set(rawProxy.name, normalized.name);
    }
    proxyNames.add(normalized.name);
    normalizedProxies.push(normalized);
  }

  const groupMembers = new Map(
    (Array.isArray(config['proxy-groups']) ? config['proxy-groups'] : [])
      .filter((group) => group && group.name != null && Array.isArray(group.proxies))
      .map((group) => [String(group.name), group.proxies.map(String)]),
  );
  let filteredProxies = normalizedProxies
    .map((proxy) => fixDialerProxy(proxy, renameMap, proxyNames, groupMembers))
    .filter(Boolean);
  for (; ;) {
    const names = new Set(filteredProxies.map((proxy) => proxy.name));
    const next = filteredProxies.filter((proxy) => !proxy['dialer-proxy'] || names.has(proxy['dialer-proxy']));
    if (next.length === filteredProxies.length) break;
    filteredProxies = next;
  }

  if (!filteredProxies.length) {
    throw new Error('配置文件中未找到任何代理节点');
  }

  const preferIpv6 = ruleOptionsEnable.优先连接IPv6节点;
  return filteredProxies.map((proxy) => {
    const type = String(proxy.type ?? '').toLowerCase();
    const needsUdp =
      proxy.udp == null &&
      (udpOptionalProxyTypes.has(type) || (type === 'snell' && Number(proxy.version) >= 3));
    const needsIpv6 = preferIpv6 && proxy['ip-version'] !== 'ipv6-prefer';
    if (!needsUdp && !needsIpv6) return proxy;
    return {
      ...proxy,
      ...(needsUdp && { udp: true }),
      ...(needsIpv6 && { 'ip-version': 'ipv6-prefer' }),
    };
  });
}

/**
 * 构建地区策略组，可附带自动选择组
 */
function createRegionGroup(name, icon, proxies, userNodes) {
  const generateRegionAutoSelectEnabled = ruleOptionsEnable.生成地区自动选择组 || ruleOptionsEnable.隐藏地区手动选择组;
  const hideManualSelectGroupEnabled = ruleOptionsEnable.隐藏地区手动选择组;
  const region = userNodes ? { 'x-region': name } : {};
  const regionNodes = userNodes?.length ? { 'x-region-nodes': userNodes } : {};

  if (generateRegionAutoSelectEnabled) {
    const urlTestName = `${name}-自动选择`;
    return [
      {
        ...urlTestBaseOption,
        name: urlTestName,
        ...region,
        proxies,
      },
      {
        ...selectBaseOption,
        name,
        icon,
        ...region,
        ...regionNodes,
        proxies: [urlTestName, ...proxies],
        hidden: hideManualSelectGroupEnabled,
      },
    ];
  }
  return [
    {
      ...selectBaseOption,
      name,
      icon,
      ...region,
      ...regionNodes,
      proxies,
      hidden: hideManualSelectGroupEnabled,
    },
  ];
}

/**
 * 将节点按地区/倍率归类，构建地区策略组、倍率策略组与「其他节点」组
 */
function buildRegionGroups(filteredProxies) {
  const generateRateGroupEnabled = ruleOptionsEnable.生成高低倍率组;

  const regionGroups = Object.fromEntries(allRegionDefinitions.map(({ name }) => [name, []]));
  const otherProxies = [];

  for (const proxy of filteredProxies) {
    const matchedRegions = getMatchedRegions(proxy.name);
    const isRegionProxy = matchedRegions.some((region) => activeRegionDefinitions.includes(region));

    for (const region of matchedRegions) {
      regionGroups[region.name].push(proxy.name);
    }

    if (!isRegionProxy) {
      otherProxies.push(proxy.name);
    }
  }

  const regionDefs = [
    ...allRegionDefinitions.filter(
      (r) => regionGroups[r.name].length > 0 && (generateRateGroupEnabled || !rateRegionDefinitions.includes(r)),
    ),
    ...(otherProxies.length > 0
      ? [{ name: '其他节点', icon: `${iconBaseUrl}common/WorldMap.svg`, other: true }]
      : []),
  ];

  return sortByGroupOrder(regionDefs).flatMap((r) =>
    r.other
      ? createRegionGroup(r.name, r.icon, otherProxies)
      : createRegionGroup(
          r.name,
          r.icon,
          regionGroups[r.name],
          activeRegionDefinitions.includes(r)
            ? userNodeNames.filter((name) => Compatible_With_Bettbox.nodeRegions[name].includes(r.name))
            : undefined,
        ),
  );
}

/**
 * 构建用户自定义分流策略组与规则集
 */
function buildCustomServices(reservedNames) {
  const knownProviders = { ...baseRuleProviders };
  for (const svc of serviceConfigs) Object.assign(knownProviders, svc.providers || {});
  const providerByUrl = new Map(Object.entries(knownProviders).map(([name, provider]) => [provider.url, name]));
  const services = [];

  for (const route of customRoutes) {
    if (!route || typeof route.name !== 'string' || reservedNames.has(route.name) || !Array.isArray(route.sets)) continue;

    const providers = {};
    const rules = [];
    const ipRules = [];
    for (const set of route.sets) {
      if (!set || typeof set.tag !== 'string') continue;

      const ipcidr = set.type === 'geoip';
      const kind = ipcidr ? 'geoip' : 'geosite';
      const bundled = typeof set.url !== 'string';
      const url = bundled ? `${ruleSetBaseUrl}${kind}/${set.tag}.mrs` : set.url;
      const format = !bundled && ['yaml', 'text'].includes(set.format) ? set.format : 'mrs';
      const ext = format === 'text' ? 'list' : format;
      let providerName = providerByUrl.get(url);
      if (!providerName) {
        providerName = ipcidr ? `${set.tag}_ip` : set.tag;
        while (knownProviders[providerName]) providerName = `${providerName}_`;
        knownProviders[providerName] = {
          ...(ipcidr ? ruleProviderCommonIpcidr : ruleProviderCommonDomain),
          url,
          format,
          path: `./ruleset/${kind}/${set.tag}.${ext}`,
          ...(bundled && { 'path-in-bundle': `geo/${kind}/${set.tag}.mrs` }),
        };
        providerByUrl.set(url, providerName);
      }
      providers[providerName] = knownProviders[providerName];
      (ipcidr ? ipRules : rules).push(`RULE-SET,${providerName},${route.name}`);
    }
    if (!rules.length && !ipRules.length) continue;

    reservedNames.add(route.name);
    const reject = route.target === 'REJECT';
    services.push({
      name: route.name,
      baseOption: selectBaseOption,
      custom: true,
      direct: true,
      reject,
      ...(!reject && typeof route.target === 'string' && { defaultSelected: route.target }),
      ...(typeof route.icon === 'string' && route.icon && { icon: route.icon }),
      providers,
      rules,
      ipRules,
    });
  }

  return services;
}

/**
 * 按用户保存的策略组顺序排序，未在顺序中的策略组紧随前一项之后
 */
const groupOrderKeys = (() => {
  if (!groupOrder.length) return null;

  const serviceNames = serviceConfigs.map((svc) => svc.name);
  const anchorIndex = serviceNames.indexOf('AdBlock');
  serviceNames.splice(
    anchorIndex < 0 ? serviceNames.length : anchorIndex,
    0,
    ...customRoutes.map((route) => route?.name).filter((name) => typeof name === 'string'),
  );
  const names = [...serviceNames, ...allRegionDefinitions.map((region) => region.name)];

  const rank = new Map(groupOrder.map((name, index) => [name, index]));
  const keys = new Map();
  let last = -1;
  names.forEach((name, index) => {
    const order = rank.get(name);
    if (order !== undefined) last = order;
    if (typeof name === 'string' && !keys.has(name)) keys.set(name, [order ?? last + 0.5, index]);
  });

  const serviceRanks = serviceNames
    .map((name) => rank.get(name))
    .filter((order) => order !== undefined);
  const directOrder = rank.get('直连');
  const directFallback = serviceRanks.length ? Math.max(...serviceRanks) + 0.75 : -0.25;
  keys.set('直连', [directOrder ?? directFallback, names.length]);

  const otherOrder = rank.get('其他节点');
  keys.set('其他节点', [otherOrder ?? groupOrder.length, names.length + 1]);
  return keys;
})();

function sortByGroupOrder(services) {
  if (!groupOrderKeys) return services;

  const keyOf = (name) =>
    groupOrderKeys.get(name) ?? groupOrderKeys.get(name.replace(/-自动选择$/, '')) ?? [Infinity, Infinity];
  return services
    .map((svc, index) => ({ svc, index, key: keyOf(svc.name) }))
    .sort((a, b) => a.key[0] - b.key[0] || a.key[1] - b.key[1] || a.index - b.index)
    .map((entry) => entry.svc);
}

function sortRuleServices(services) {
  if (services.length <= 1) return services;

  const indexByName = new Map(services.map((svc, index) => [svc.name, index]));
  const adj = Array.from({ length: services.length }, () => new Set());
  const indegree = new Array(services.length).fill(0);

  for (const dep of allRuleDeps) {
    if (!Array.isArray(dep) || dep.length < 2) continue;
    const from = indexByName.get(dep[0]);
    const to = indexByName.get(dep[1]);
    if (from === undefined || to === undefined || from === to || adj[from].has(to)) continue;
    adj[from].add(to);
    indegree[to]++;
  }

  const priority = Array.from({ length: services.length }, (_, index) => index);
  for (let pass = 0; pass < services.length; pass++) {
    let changed = false;
    for (let u = 0; u < services.length; u++) {
      for (const v of adj[u]) {
        if (priority[v] < priority[u]) {
          priority[u] = priority[v];
          changed = true;
        }
      }
    }
    if (!changed) break;
  }

  const placed = new Array(services.length).fill(false);
  const result = [];
  for (let count = 0; count < services.length; count++) {
    let next = -1;
    for (let i = 0; i < services.length; i++) {
      if (!placed[i] && indegree[i] === 0) {
        if (next === -1 || priority[i] < priority[next]) next = i;
      }
    }
    if (next === -1) {
      for (let i = 0; i < services.length; i++) {
        if (!placed[i] && (next === -1 || priority[i] < priority[next])) next = i;
      }
    }
    placed[next] = true;
    result.push(services[next]);
    for (const target of adj[next]) {
      indegree[target]--;
    }
  }
  return result;
}

/**
 * 构建基础/分流策略组/部分节点组与规则集，并汇总分流规则
 */
function buildFunctionalGroups(filteredProxies, generatedRegionGroups) {
  const minimalModeEnabled = ruleOptionsEnable.极简国内外分流模式;
  const addAllNodesToServiceGroupsEnabled = ruleOptionsEnable.分流组添加所有节点;
  const hideManualSelectGroupEnabled = ruleOptionsEnable.隐藏地区手动选择组;

  const functionalGroups = [];
  const functionalRules = [];
  const functionalIpRules = [];
  const priorityRules = [];
  const dnsPolicyGroups = [];
  const finalRuleProviders = { ...baseRuleProviders };

  const allProxiesNames = filteredProxies.map((p) => p.name);
  const groupNamesOfSelect = generatedRegionGroups.filter((g) => g.type === 'select').map((g) => g.name);
  const baseGroupNames = baseGroups.filter((g) => ruleOptionsEnable[g.name]).map((g) => g.name);

  if (minimalModeEnabled) {
    const autoSelectGroupEnabled = ruleOptionsEnable.自动选择;

    const adBlockService = ruleOptionsEnable.AdBlock ? serviceConfigs.find((svc) => svc.priority) : null;
    const adBlockGroup = adBlockService && {
      ...adBlockService.baseOption,
      name: adBlockService.name,
      icon: adBlockService.icon,
      proxies: [...rejectGroupProxies],
    };
    if (adBlockService) {
      priorityRules.push(...adBlockService.rules);
      Object.assign(finalRuleProviders, adBlockService.providers);
    }

    const defaultGroup = {
      ...selectBaseOption,
      name: '默认代理',
      proxies: [...allProxiesNames, ...(autoSelectGroupEnabled ? ['自动选择'] : [])],
      icon: `${iconBaseUrl}common/Proxy.svg`,
    };

    const autoSelectGroup = {
      ...urlTestBaseOption,
      name: '自动选择',
      proxies: allProxiesNames,
      hidden: true,
    };

    const directGroup = {
      ...selectBaseOption,
      name: '直连',
      url: directTestUrl,
      'default-selected': '🇨🇳 直连 | IPv4优先',
      proxies: directProxies.map((p) => p.name),
      icon: `${iconBaseUrl}flag/China.svg`,
      hidden: true,
    };

    return {
      orderedGroups: [
        defaultGroup,
        ...(autoSelectGroupEnabled ? [autoSelectGroup] : []),
        ...(adBlockGroup ? [adBlockGroup] : []),
        directGroup,
      ],
      functionalRules: [],
      functionalIpRules: [],
      priorityRules,
      dnsPolicyGroups: [],
      finalRuleProviders,
    };
  }

  functionalGroups.push({
    ...selectBaseOption,
    name: '默认代理',
    proxies: [...groupNamesOfSelect, ...baseGroupNames],
    icon: `${iconBaseUrl}common/Proxy.svg`,
  });

  const reservedNames = new Set([
    ...builtInReservedNames,
    ...allProxiesNames,
  ]);
  const builtinServices = serviceConfigs.filter((svc) => ruleOptionsEnable[svc.name]);
  const allServices = [...builtinServices];
  const anchorIndex = allServices.findIndex((svc) => svc.name === 'AdBlock');
  allServices.splice(anchorIndex < 0 ? allServices.length : anchorIndex, 0, ...buildCustomServices(reservedNames));
  const orderedServices = sortByGroupOrder(allServices);

  const ruleServices = [
    ...sortRuleServices(orderedServices.filter((svc) => svc.priority || svc.reject)),
    ...sortRuleServices(orderedServices.filter((svc) => !svc.priority && !svc.reject)),
  ];

  for (const svc of ruleServices) {
    (svc.priority || svc.reject ? priorityRules : functionalRules).push(...(svc.rules || []));
    functionalIpRules.push(...(svc.ipRules || []));
    Object.assign(finalRuleProviders, svc.providers || {});
    if (!svc.reject && !svc.direct) {
      for (const rule of svc.rules || []) dnsPolicyGroups.push([rule.split(',')[1], svc.name]);
    }
  }

  for (const svc of orderedServices) {
    let groupProxies = [];
    if (svc.includeAll) {
      groupProxies = [...allProxiesNames];
    } else if (svc.reject) {
      groupProxies = [...rejectGroupProxies];
    } else {
      groupProxies = !addAllNodesToServiceGroupsEnabled
        ? ['默认代理', ...baseGroupNames, ...groupNamesOfSelect, ...(svc.direct ? ['直连'] : [])]
        : [
          '默认代理',
          ...baseGroupNames,
          ...groupNamesOfSelect,
          ...allProxiesNames,
          ...(svc.direct ? ['直连'] : []),
        ];
    }

    const defaultCandidates = Array.isArray(svc.defaultSelected)
      ? svc.defaultSelected
      : svc.defaultSelected !== undefined
        ? [svc.defaultSelected]
        : [];
    const selected = defaultCandidates.find((name) => groupProxies.includes(name));
    functionalGroups.push({
      ...svc.baseOption,
      name: svc.name,
      ...(svc.icon && { icon: svc.icon }),
      proxies: groupProxies,
      ...(selected !== undefined && { 'default-selected': selected }),
    });
  }

  const directGroup = {
    ...selectBaseOption,
    name: '直连',
    url: directTestUrl,
    'default-selected': '🇨🇳 直连 | IPv4优先',
    proxies: directProxies.map((p) => p.name),
    icon: `${iconBaseUrl}flag/China.svg`,
    hidden: hideManualSelectGroupEnabled,
  };

  const [defaultGroup, ...serviceGroups] = functionalGroups;
  const orderedGroups = [
    defaultGroup,
    ...sortByGroupOrder([
      ...serviceGroups,
      directGroup,
      ...generatedRegionGroups,
    ]),
  ];

  return {
    orderedGroups,
    functionalRules,
    functionalIpRules,
    priorityRules,
    dnsPolicyGroups,
    finalRuleProviders,
  };
}

const commonDnsList = [
  '223.5.5.5',
  '223.6.6.6',
  '2400:3200::1',
  '2400:3200:baba::1',
  'alidns',

  '119.29.29.29',
  '119.28.28.28',
  '182.254.116.116',
  '182.254.118.118',
  '1.12.12.12',
  '120.53.53.53',
  '2402:4e00::',
  'doh.pub',
  'dot.pub',
  'dns.pub',
  'dnspod',

  '114.114.114.114',
  '114.114.115.115',
  '114.114.114.119',
  '114.114.115.119',
  '114.114.114.110',
  '114.114.115.110',

  '180.76.76.76',
  '2400:da00::6666',
  'dns.baidu',

  '1.2.4.8',
  '210.2.4.8',
  '2001:dc7:1000::1',
  'cnnic',

  '101.226.4.6',
  '218.30.118.6',
  '123.125.81.6',
  '140.207.198.6',
  '2400:8800:1::6',
  '2400:8800:2::6',
  'doh.360',
  'dot.360',
  'dns.360',

  '180.184.1.1',
  '180.184.2.2',

  '117.50.11.11',
  '117.50.22.22',
  '52.80.66.66',
  '117.50.10.10',
  '52.80.52.52',
  '117.50.60.30',
  '52.80.60.30',
  'onedns.net',

  '101.6.6.6',
  '2001:da8::666',

  '240c::6666',
  '240c::6644',

  '202.141.162.123',
  '202.141.178.13',

  '1.1.1.1',
  '1.0.0.1',
  '1.1.1.2',
  '1.0.0.2',
  '1.1.1.3',
  '1.0.0.3',
  '2606:4700:4700::1111',
  '2606:4700:4700::1001',
  '2606:4700:4700::1112',
  '2606:4700:4700::1002',
  '2606:4700:4700::1113',
  '2606:4700:4700::1003',
  'dns.cloudflare',
  'cloudflare-dns',
  'one.one.one.one',

  '8.8.8.8',
  '8.8.4.4',
  '2001:4860:4860::8888',
  '2001:4860:4860::8844',
  'dns.google',

  '9.9.9.9',
  '9.9.9.10',
  '9.9.9.11',
  '149.112.112.112',
  '149.112.112.10',
  '149.112.112.11',
  '2620:fe::fe',
  '2620:fe::9',
  'quad9',

  '208.67.222.222',
  '208.67.220.220',
  '208.67.222.123',
  '208.67.220.123',
  '2620:119:35::35',
  '2620:119:53::53',
  '2620:119:35::123',
  '2620:119:53::123',
  'opendns',

  '94.140.14.14',
  '94.140.15.15',
  '94.140.14.15',
  '94.140.15.16',
  '2a10:50c0::ad1:ff',
  '2a10:50c0::ad2:ff',
  '2a10:50c0::bad1:ff',
  '2a10:50c0::bad2:ff',
  'adguard',

  '76.76.2.0',
  '76.76.10.0',
  '76.76.19.19',
  '76.223.122.150',

  '185.228.168.9',
  '185.228.169.9',
  '185.228.168.10',
  '185.228.169.11',
  '185.228.168.168',
  '185.228.169.168',
  '2a0d:2a00:1::2',
  '2a0d:2a00:2::2',

  '77.88.8.8',
  '77.88.8.1',
  '2a02:6b8::feed:0ff',
  '2a02:6b8:0:1::feed:0ff',

  '156.154.70.1',
  '156.154.71.1',
  '156.154.70.2',
  '156.154.71.2',
  '2610:a1:1018::1',
  '2610:a1:1019::1',

  '194.242.2.2',
  '2a07:e340::2',

  '74.82.42.42',
  '2001:470:20::2',

  'nextdns',

  'dns.apple',
];

const commonDnsIps = new Set(commonDnsList.filter(isIpAddress));
const commonDnsKeywords = commonDnsList.filter((dns) => !isIpAddress(dns));

function dnsHost(dns) {
  let host = dns.replace(/^[a-z][a-z0-9+.-]*:\/\//, '').split(/[/?#]/, 1)[0];
  host = host.slice(host.lastIndexOf('@') + 1);
  const bracketed = host.match(/^\[([^\]]*)\]/);
  if (bracketed) return bracketed[1];
  return host.indexOf(':') === host.lastIndexOf(':') ? host.split(':')[0] : host;
}

const chinaDNS = ['223.6.6.6#DIRECT', '119.29.29.29#DIRECT'];
const douyinDNS = ['180.184.1.1#DIRECT', '180.184.2.2#DIRECT'];
const policyDNS = (group) => [`1.1.1.1#${group}`, `8.8.8.8#${group}`];
const foreignDNS = policyDNS('默认代理');
const defaultDNS = ['114.114.114.114#DIRECT', '119.29.29.29#DIRECT'];
const proxyServerDNS = [
  'https://223.5.5.5/dns-query#DIRECT',
  'https://doh.pub/dns-query#DIRECT',
];

/**
 * hosts 匹配优先级：精确 > +. > . > *（同级按出现顺序）
 */
function hostSpecificity(pattern) {
  if (pattern.startsWith('+.')) return 2;
  if (pattern.startsWith('.')) return 1;
  if (pattern.includes('*')) return 0;
  return 3;
}

/**
 * 判断域名规则（精确/通配）是否匹配节点域名集合，忽略大小写
 */
function matchDomainPattern(pattern, domains) {
  pattern = pattern.toLowerCase();

  // 精确匹配
  if (!pattern.includes('*') && !pattern.startsWith('+.') && !pattern.startsWith('.')) {
    return typeof domains === 'string'
      ? domains.toLowerCase() === pattern
      : [...domains].some((d) => d.toLowerCase() === pattern);
  }

  const domainList = typeof domains === 'string' ? [domains.toLowerCase()] : [...domains].map((d) => d.toLowerCase());

  // +.example.com
  if (pattern.startsWith('+.')) {
    const suffix = pattern.slice(2);
    return domainList.some((domain) => domain === suffix || domain.endsWith(`.${suffix}`));
  }

  // .example.com
  if (pattern.startsWith('.')) {
    const suffix = pattern.slice(1);
    return domainList.some((domain) => domain !== suffix && domain.endsWith(`.${suffix}`));
  }

  // *.example.com、example.*.com 等
  const patternParts = pattern.split('.');
  return domainList.some((domain) => {
    const domainParts = domain.split('.');
    return (
      patternParts.length === domainParts.length &&
      patternParts.every((part, index) => part === '*' || part === domainParts[index])
    );
  });
}

/**
 * 为节点域名集合构建高频匹配器（支持精确、+.、. 与 * 通配）
 */
function createDomainMatcher(domains) {
  const exact = new Set();
  const suffixes = new Set();
  const properSuffixes = new Set();
  const splitDomains = [];

  for (const raw of domains) {
    const domain = raw.toLowerCase();
    if (exact.has(domain)) continue;
    exact.add(domain);
    const parts = domain.split('.');
    splitDomains.push(parts);
    suffixes.add(domain);
    for (let i = 1; i < parts.length; i++) {
      const suffix = parts.slice(i).join('.');
      suffixes.add(suffix);
      properSuffixes.add(suffix);
    }
  }

  let wildcardIndex = null;
  const candidatesOf = (key) => {
    if (!wildcardIndex) {
      wildcardIndex = new Map();
      for (const parts of splitDomains) {
        for (let i = 0; i <= parts.length; i++) {
          const indexKey = `${parts.length}:${parts.slice(i).join('.')}`;
          const list = wildcardIndex.get(indexKey);
          if (list) list.push(parts);
          else wildcardIndex.set(indexKey, [parts]);
        }
      }
    }
    return wildcardIndex.get(key) || [];
  };

  return (rawPattern) => {
    const pattern = String(rawPattern).toLowerCase();
    if (pattern.startsWith('+.')) return suffixes.has(pattern.slice(2));
    if (pattern.startsWith('.')) return properSuffixes.has(pattern.slice(1));
    if (!pattern.includes('*')) return exact.has(pattern);

    const patternParts = pattern.split('.');
    const key = `${patternParts.length}:${patternParts.slice(patternParts.lastIndexOf('*') + 1).join('.')}`;
    return candidatesOf(key).some((parts) =>
      patternParts.every((part, index) => part === '*' || part === parts[index]),
    );
  };
}

/**
 * 为 hosts 条目构建按优先级查找器（精确 > +. > . > *）
 */
function createHostFinder(hostEntries) {
  const exact = new Map();
  const plus = new Map();
  const dot = new Map();
  const wildcards = [];

  hostEntries.forEach((entry, index) => {
    const pattern = entry[0].toLowerCase();
    const level = hostSpecificity(pattern);
    if (level === 0) {
      wildcards.push(entry);
      return;
    }
    const [map, key] = level === 3 ? [exact, pattern] : level === 2 ? [plus, pattern.slice(2)] : [dot, pattern.slice(1)];
    if (!map.has(key)) map.set(key, { entry, index });
  });

  const firstOf = (map, keys) => {
    let found = null;
    for (const key of keys) {
      const item = map.get(key);
      if (item && (!found || item.index < found.index)) found = item;
    }
    return found?.entry;
  };

  return (domain) => {
    const exactEntry = exact.get(domain)?.entry;
    if (exactEntry) return exactEntry;

    const parts = domain.split('.');
    const suffixes = parts.map((_, i) => parts.slice(i).join('.'));
    return (
      firstOf(plus, suffixes) ??
      firstOf(dot, suffixes.slice(1)) ??
      wildcards.find(([pattern]) => matchDomainPattern(pattern, domain))
    );
  };
}

/**
 * 根据订阅 hosts 映射改写节点 server，改写后无需再复制 hosts 进新配置。
 * 支持链式映射（如 a: b、b: c 时节点 a 改写为 c）；
 */
function applyHostsToProxies(proxies, hosts) {
  if (!hosts || typeof hosts !== 'object') return proxies;

  const hostEntries = Object.entries(hosts)
    .filter(
      ([, value]) => (typeof value === 'string' && value.length > 0) || (Array.isArray(value) && value.length > 0),
    )
    .sort((a, b) => hostSpecificity(b[0]) - hostSpecificity(a[0]));

  if (hostEntries.length === 0) return proxies;

  const targetOf = (value) => {
    if (Array.isArray(value)) value = value.find((v) => typeof v === 'string' && v.length > 0);
    return typeof value === 'string' && value.length > 0 ? value : null;
  };

  const findHost = createHostFinder(hostEntries);
  const resolveCache = new Map();
  const resolve = (server) => {
    const cached = resolveCache.get(server);
    if (cached !== undefined) return cached;

    const seen = new Set();
    let current = server.toLowerCase();
    let result = server;
    while (!seen.has(current)) {
      seen.add(current);
      const entry = findHost(current);
      const target = entry && targetOf(entry[1]);
      if (!target) break;
      result = target;
      current = target.toLowerCase();
    }
    resolveCache.set(server, result);
    return result;
  };

  return proxies.map((proxy) => {
    if (typeof proxy.server !== 'string') return proxy;
    const server = resolve(proxy.server);
    return server === proxy.server ? proxy : { ...proxy, server };
  });
}

/**
 * 剥离 DNS 地址的 # 策略组后缀；
 * 参数包含 direct 或 直连 时，强制改为 #DIRECT
 */
function stripDnsSuffix(dns) {
  const str = String(dns);
  const hashIndex = str.indexOf('#');
  if (hashIndex === -1) return str;

  const prefix = str.slice(0, hashIndex).trim();

  const suffix = str
    .slice(hashIndex + 1)
    .toLowerCase()
    .trim();

  if (suffix.includes('direct') || suffix.includes('直连')) return `${prefix}#DIRECT`;

  return prefix;
}

/**
 * 判断节点 server 是否为 IP 地址（IPv4 / IPv6），用于从节点域名集合中排除 IP 类型的 server
 */
function isIpAddress(server) {
  return /^\d{1,3}(\.\d{1,3}){3}$/.test(server) || server.includes(':');
}

/**
 * 简化节点域名策略：将相同 DNS 的节点域名按后缀归类，至少三段的域名可合并为 +. 后缀形式
 */
function simplifyDomainPolicy(policy) {
  const groups = Map.groupBy(
    Object.entries(policy).map(([domain, dns]) => ({
      domain,
      dns,
      dnsKey: JSON.stringify(Array.isArray(dns) ? dns.toSorted() : dns),
    })),
    ({ domain }) => {
      const parts = domain.split('.');
      return domain.startsWith('+.') || domain.startsWith('.') || domain.includes('*') || parts.length < 3
        ? `keep:${domain}`
        : parts.slice(-2).join('.');
    },
  );

  const result = {};

  for (const [suffix, domains] of groups) {
    const firstDnsKey = domains[0].dnsKey;
    const sameDns = domains.every(({ dnsKey }) => dnsKey === firstDnsKey);

    if (domains.length >= 2 && sameDns) {
      result[`+.${suffix}`] = domains[0].dns;
    } else {
      for (const { domain, dns } of domains) {
        result[domain] = dns;
      }
    }
  }

  return result;
}

/**
 * 构建 DNS 与 hosts：保留私有 DNS、节点域名 policy/fake-ip-filter 与命中节点域名的订阅 hosts，并按 hosts 改写节点 server。
 */
function buildDnsAndHostsConfig(config, filteredProxies, dnsPolicyGroups) {
  const minimalModeEnabled = ruleOptionsEnable.极简国内外分流模式;

  const originalDnsConfig = config.dns || {};

  const proxyServerNameservers = originalDnsConfig['proxy-server-nameserver'] || [];
  const listenValue = originalDnsConfig.listen;

  const shouldRewriteByHosts =
    proxyServerNameservers.length === 1 &&
    typeof listenValue === 'string' &&
    listenValue.length > 0 &&
    (proxyServerNameservers.some((dns) => String(dns).toLowerCase().includes(listenValue.toLowerCase())) ||
      (listenValue.includes('0.0.0.0') &&
        proxyServerNameservers.some((dns) => String(dns).toLowerCase().includes('127.0.0.1'))));

  const mappedProxies = shouldRewriteByHosts ? applyHostsToProxies(filteredProxies, config.hosts) : filteredProxies;

  const proxyDomains = new Set(
    mappedProxies
      .filter((proxy) => typeof proxy.server === 'string')
      .map((proxy) => proxy.server.toLowerCase())
      .filter((server) => !isIpAddress(server)),
  );

  const matchProxyDomain = createDomainMatcher(proxyDomains);

  const privateProxyServerNameservers = shouldRewriteByHosts ? [] : proxyServerNameservers;

  const isCommonDns = (dns) => {
    const value = String(dns).trim().toLowerCase();
    if (value === 'system' || value === 'system://') return true;

    const host = dnsHost(value);
    return commonDnsIps.has(host) || commonDnsKeywords.some((keyword) => host.includes(keyword));
  };

  const privateDNS = [
    ...new Set(
      [...(originalDnsConfig.nameserver || []), ...privateProxyServerNameservers]
        .map(stripDnsSuffix)
        .filter((dns) => dns.length > 0 && !isCommonDns(dns)),
    ),
  ];

  const matchedProxyPolicy = {};
  for (const [domain, dns] of Object.entries({
    ...originalDnsConfig['nameserver-policy'],
    ...originalDnsConfig['proxy-server-nameserver-policy'],
  })) {
    if (!matchProxyDomain(domain)) continue;

    const stripedDns = Array.isArray(dns) ? dns.map(stripDnsSuffix).filter((d) => d.length > 0) : stripDnsSuffix(dns);
    if (Array.isArray(stripedDns) && stripedDns.length === 0) continue;

    matchedProxyPolicy[domain] = stripedDns;
  }

  if (privateDNS.length > 0 && Object.keys(matchedProxyPolicy).length === 0) {
    for (const domain of proxyDomains) {
      matchedProxyPolicy[domain] = privateDNS;
    }
  }

  const matchedPolicyDomains = Object.keys(matchedProxyPolicy);
  const proxyServerPolicy =
    proxyDomains.size === matchedPolicyDomains.length &&
      matchedPolicyDomains.every((domain) => proxyDomains.has(domain.toLowerCase()))
      ? simplifyDomainPolicy(matchedProxyPolicy)
      : matchedProxyPolicy;

  const originalFakeIpFilter = originalDnsConfig['fake-ip-filter'] || [];
  const proxyFakeIpFilter = originalFakeIpFilter.filter(matchProxyDomain);

  const nameserverPolicy = {
    'rule-set:private': 'system',
    'rule-set:douyin': douyinDNS,
  };
  for (const [provider, group] of dnsPolicyGroups) {
    nameserverPolicy[`rule-set:${provider}`] ??= policyDNS(group);
  }
  delete nameserverPolicy['rule-set:cn'];
  delete nameserverPolicy['rule-set:geolocation-!cn'];
  if (ruleOptionsEnable.优先国内DNS加速) {
    nameserverPolicy['rule-set:geolocation-!cn'] = foreignDNS;
  } else {
    nameserverPolicy['rule-set:cn'] = chinaDNS;
  }

  const dns = {
    enable: true,
    ipv6: true,
    'default-nameserver': defaultDNS,
    'enhanced-mode': 'fake-ip',
    'fake-ip-filter': [
      '*',
      'rule-set:cn',
      'rule-set:private',
      'rule-set:fakeip_filter',
      'rule-set:connectcheck',
      ...(minimalModeEnabled ? [] : ruleOptionsEnable.FCM ? ['rule-set:googlefcm'] : []),
      ...proxyFakeIpFilter,
    ],
    'fake-ip-range': '198.18.0.1/15',
    'fake-ip-range6': '2001:2::1/48',
    nameserver: ruleOptionsEnable.优先国内DNS加速 ? chinaDNS : foreignDNS,
    'nameserver-policy': nameserverPolicy,
    'proxy-server-nameserver': proxyServerDNS,
    'direct-nameserver': chinaDNS,
    ...(Object.keys(proxyServerPolicy).length > 0 && {
      'proxy-server-nameserver-policy': proxyServerPolicy,
    }),
  };

  const proxyHosts = Object.fromEntries(
    Object.entries(config.hosts && typeof config.hosts === 'object' ? config.hosts : {}).filter(
      ([pattern, value]) =>
        ((typeof value === 'string' && value.length > 0) || (Array.isArray(value) && value.length > 0)) &&
        matchProxyDomain(pattern),
    ),
  );

  const hosts = {
    ...proxyHosts,

    // 解决谷歌商店无法下载的问题
    'services.googleapis.cn': 'services.googleapis.com',

    'dns.alidns.com': ['223.5.5.5', '223.6.6.6', '2400:3200::1', '2400:3200:baba::1'],
    'doh.pub': ['120.53.53.53', '1.12.12.12', '2402:4e00:1::', '2402:4e00::'],
  };

  return { dns, hosts, proxies: mappedProxies };
}

/**
 * 主入口：覆写机场订阅配置，生成完整 Mihomo 配置
 */
function main(config) {
  const newConfig = {};

  const filteredProxies = filterAndNormalizeProxies(config);

  const generatedRegionGroups = ruleOptionsEnable.极简国内外分流模式
    ? []
    : buildRegionGroups(filteredProxies);

  const {
    orderedGroups,
    functionalRules,
    functionalIpRules,
    priorityRules,
    dnsPolicyGroups,
    finalRuleProviders,
  } = buildFunctionalGroups(filteredProxies, generatedRegionGroups);

  const { dns, hosts, proxies: mappedProxies } = buildDnsAndHostsConfig(config, filteredProxies, dnsPolicyGroups);

  newConfig.dns = dns;
  newConfig.hosts = hosts;

  newConfig.profile = {
    'store-selected': true,
    'store-fake-ip': true,
  };

  newConfig.ntp = {
    enable: true,
    'write-to-system': false,
    server: 'ntp.aliyun.com',
    port: 123,
    interval: 360,
  };

  newConfig.proxies = [...mappedProxies, ...directProxies];
  newConfig['proxy-groups'] = orderedGroups;
  newConfig['rule-providers'] = finalRuleProviders;

  newConfig.rules = [
    ...prefixRules,
    ...(ruleOptionsEnable.禁用内核QUIC流量 ? blockQuicRules : []),
    ...priorityRules,
    ...directRules,
    ...functionalRules,
    'RULE-SET,geolocation-!cn,默认代理',
    'RULE-SET,cn_ip,直连',
    'RULE-SET,private_ip,DIRECT',
    ...functionalIpRules,
    'MATCH,默认代理',
    'NETWORK,UDP,REJECT',
  ];

  return newConfig;
}
