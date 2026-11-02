final _routeIconKeyPattern = RegExp(r'[^a-z0-9]');
final _routeTokenPattern = RegExp(r'[-_.]+');
final _routeTrailingDigits = RegExp(r'\d+$');
final routeWordPattern = RegExp(
  r'[a-z0-9]+|[\p{Script=Han}]+',
  unicode: true,
);
final routeHanPattern = RegExp(r'[\p{Script=Han}]', unicode: true);

const defaultRouteAliases = <String, String>{
  '香港': 'flag/Hong_Kong.svg',
  'hk': 'flag/Hong_Kong.svg',
  'hkg': 'flag/Hong_Kong.svg',
  'hongkong': 'flag/Hong_Kong.svg',
  '日本': 'flag/Japan.svg',
  'jp': 'flag/Japan.svg',
  'jpn': 'flag/Japan.svg',
  'japan': 'flag/Japan.svg',
  '美国': 'flag/United_States.svg',
  'us': 'flag/United_States.svg',
  'usa': 'flag/United_States.svg',
  'unitedstates': 'flag/United_States.svg',
  '新加坡': 'flag/Singapore.svg',
  'sg': 'flag/Singapore.svg',
  'sgp': 'flag/Singapore.svg',
  'singapore': 'flag/Singapore.svg',
  '台湾': 'flag/China_Taiwan.svg',
  'tw': 'flag/China_Taiwan.svg',
  'twn': 'flag/China_Taiwan.svg',
  'taiwan': 'flag/China_Taiwan.svg',
  '韩国': 'flag/South_Korea.svg',
  'kr': 'flag/South_Korea.svg',
  'kor': 'flag/South_Korea.svg',
  'korea': 'flag/South_Korea.svg',
  '英国': 'flag/United_Kingdom.svg',
  'uk': 'flag/United_Kingdom.svg',
  'gb': 'flag/United_Kingdom.svg',
  'gbr': 'flag/United_Kingdom.svg',
  'unitedkingdom': 'flag/United_Kingdom.svg',
  '德国': 'flag/Germany.svg',
  'de': 'flag/Germany.svg',
  'deu': 'flag/Germany.svg',
  'germany': 'flag/Germany.svg',
  '法国': 'flag/France.svg',
  'fr': 'flag/France.svg',
  'fra': 'flag/France.svg',
  'france': 'flag/France.svg',
  '加拿大': 'flag/Canada.svg',
  'ca': 'flag/Canada.svg',
  'can': 'flag/Canada.svg',
  'canada': 'flag/Canada.svg',
  '澳大利亚': 'flag/Australia.svg',
  '澳洲': 'flag/Australia.svg',
  'au': 'flag/Australia.svg',
  'aus': 'flag/Australia.svg',
  'australia': 'flag/Australia.svg',
  '俄罗斯': 'flag/Russia.svg',
  'ru': 'flag/Russia.svg',
  'rus': 'flag/Russia.svg',
  'russia': 'flag/Russia.svg',
  '印度': 'flag/India.svg',
  'in': 'flag/India.svg',
  'ind': 'flag/India.svg',
  'india': 'flag/India.svg',
  '荷兰': 'flag/Netherlands.svg',
  'nl': 'flag/Netherlands.svg',
  'nld': 'flag/Netherlands.svg',
  'netherlands': 'flag/Netherlands.svg',
  '土耳其': 'flag/Turkey.svg',
  'tr': 'flag/Turkey.svg',
  'tur': 'flag/Turkey.svg',
  'turkey': 'flag/Turkey.svg',
  '马来西亚': 'flag/Malaysia.svg',
  'my': 'flag/Malaysia.svg',
  'mys': 'flag/Malaysia.svg',
  'malaysia': 'flag/Malaysia.svg',
  '泰国': 'flag/Thailand.svg',
  'th': 'flag/Thailand.svg',
  'tha': 'flag/Thailand.svg',
  'thailand': 'flag/Thailand.svg',
  '菲律宾': 'flag/Philippines.svg',
  'ph': 'flag/Philippines.svg',
  'phl': 'flag/Philippines.svg',
  'philippines': 'flag/Philippines.svg',
  '越南': 'flag/Vietnam.svg',
  'vn': 'flag/Vietnam.svg',
  'vnm': 'flag/Vietnam.svg',
  'vietnam': 'flag/Vietnam.svg',
  '阿根廷': 'flag/Argentina.svg',
  'ar': 'flag/Argentina.svg',
  'arg': 'flag/Argentina.svg',
  'argentina': 'flag/Argentina.svg',
  '巴西': 'flag/Brazil.svg',
  'br': 'flag/Brazil.svg',
  'bra': 'flag/Brazil.svg',
  'brazil': 'flag/Brazil.svg',
  '中国': 'flag/China.svg',
  '国内': 'flag/China.svg',
  'cn': 'flag/China.svg',
  'chn': 'flag/China.svg',
  'china': 'flag/China.svg',
  '油管': 'YouTube.svg',
  '电报': 'Telegram.svg',
  'tg': 'Telegram.svg',
  '推特': 'Twitter.svg',
  '奈飞': 'Netflix.svg',
  '网飞': 'Netflix.svg',
  '脸书': 'Facebook.svg',
  '谷歌': 'Google.svg',
  '必应': 'Bing.svg',
  '双子座': 'Gemini.svg',
  '暴雪': 'BattleNet.svg',
  '战网': 'BattleNet.svg',
  '哔哩哔哩': 'Bilibili.svg',
  'b站': 'Bilibili.svg',
  '苹果': 'Apple.svg',
  '微软': 'Microsoft.svg',
  '网易云': 'NeteaseMusic.svg',
  '网易云音乐': 'NeteaseMusic.svg',
  '微信': 'WeChat.svg',
  'qq': 'QQ.svg',
  '腾讯': 'Tencent.svg',
  '阿里': 'Alibaba.svg',
  '阿里巴巴': 'Alibaba.svg',
  '阿里云': 'Aliyun.svg',
  '百度': 'Baidu.svg',
  '知乎': 'Zhihu.svg',
  '淘宝': 'Taobao.svg',
  '京东': 'JD.svg',
  '小红书': 'Xiaohongshu.svg',
  '爱奇艺': 'iQIYI.svg',
  '即梦': 'Jimeng.svg',
  '智谱': 'Zhipu.svg',
  '清言': 'Qingyan.svg',
  '智谱清言': 'Zhipu.svg',
  '元宝': 'Yuanbao.svg',
  '腾讯元宝': 'Yuanbao.svg',
  '混元': 'Hunyuan.svg',
  '腾讯混元': 'Hunyuan.svg',
  '天工': 'Tiangong.svg',
  '剪映': 'CapCut.svg',
  '搬瓦工': 'BandwagonHost.svg',
  '咸鱼云': 'SaltyFish.svg',
  '火狐': 'Firefox(1).svg',
  '微博': 'Weibo.svg',
  '飞书': 'Feishu.svg',
  '钉钉': 'DingTalk.svg',
  '115': 'Netdisk115.svg',
  '迅雷': 'Xunlei.svg',
  '虎牙': 'Huya.svg',
  '斗鱼': 'Douyu.svg',
  '喜马拉雅': 'Ximalaya.svg',
  '酷狗': 'Kugou.svg',
  '拼多多': 'Pinduoduo.svg',
  '美团': 'Meituan.svg',
  '饿了么': 'Eleme.svg',
  '直连': 'flag/China.svg',
  '自建': 'Server.svg',
  '自建节点': 'Server.svg',
  '自动': 'Auto.svg',
  '自动选择': 'Auto.svg',
  '兜底': 'Global.svg',
  '漏网之鱼': 'Global.svg',
  '其他': 'Global.svg',
  '其它': 'Global.svg',
};

const _routeIconSuffixes = [
  '-!cn',
  '-cn',
  '-ads-all',
  '-ads',
  '-all',
  '-global',
  '-intl',
  '-international',
  '-dev',
  '-app',
  '-apps',
  '-cdn',
  '-games',
  '-game',
  '-tv',
  '-music',
  '-video',
  '-cloud',
  '-api',
  '-shop',
  '-store',
];

String routeIconKey(String value) =>
    value.toLowerCase().replaceAll(_routeIconKeyPattern, '');

Map<String, String> routeIconIndex(Iterable<String> files) {
  final index = <String, String>{};
  for (final file in files) {
    final base = file.substring(file.lastIndexOf('/') + 1);
    final name = base.endsWith('.svg')
        ? base.substring(0, base.length - 4)
        : base;
    final key = routeIconKey(name);
    if (key.isNotEmpty) index.putIfAbsent(key, () => file);
  }
  return index;
}

String? matchRouteIcon(String name, Map<String, String> index) {
  String? find(String value) {
    final key = routeIconKey(value);
    return key.isEmpty ? null : index[key];
  }

  final exact = find(name);
  if (exact != null) return exact;
  var base = name.split('@').first;
  final byBase = find(base);
  if (byBase != null) return byBase;
  var changed = true;
  while (changed) {
    changed = false;
    if (base.startsWith('category-')) {
      base = base.substring(9);
      changed = true;
    }
    for (final suffix in _routeIconSuffixes) {
      if (base.length > suffix.length + 1 && base.endsWith(suffix)) {
        base = base.substring(0, base.length - suffix.length);
        changed = true;
      }
    }
  }
  final byAffix = find(base);
  if (byAffix != null) return byAffix;
  final tokens = base
      .split(_routeTokenPattern)
      .where((token) => token.isNotEmpty)
      .toList();
  for (var count = tokens.length - 1; count > 0; count--) {
    final key = routeIconKey(tokens.take(count).join());
    if (key.length < 3) continue;
    final icon = index[key];
    if (icon != null) return icon;
  }
  final key = routeIconKey(base);
  final digits = _routeTrailingDigits.firstMatch(key);
  if (digits == null || digits.start < 3) return null;
  return index[key.substring(0, digits.start)];
}
