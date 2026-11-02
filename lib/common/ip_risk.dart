import 'dart:convert';
import 'dart:io';

import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';

final _commentReg = RegExp(r'<!--[\s\S]*?-->');
final _scoreReg = RegExp(r'Fraud Score:\s*(\d+)');
final _jsonScoreReg = RegExp(r'"score"\s*:\s*"(\d+)"');
final _jsonRiskReg = RegExp(r'"risk"\s*:\s*"([^"]+)"');
final _panelRiskReg = RegExp(r'class="panel_title[^"]*"[^>]*>([^<]+)<');
final _rowReg = RegExp(
  r'<th\s+class="title[^"]*"[^>]*>([\s\S]*?)</th>|<th>([\s\S]*?)</th>\s*<td[^>]*>([\s\S]*?)</td>',
);
final _tagReg = RegExp(r'<[^>]+>');
final _noteTagReg = RegExp(r'<(?!/?b>)[^>]+>');
final _panelReg = RegExp(r'<div class="panel_body">([\s\S]*?)</div>');
final _indirectReg = RegExp(
  r'no visibility into the web traffic directly from[\s\S]*?overall risk from <b>([^<]+)</b>',
);
final _amountReg = RegExp(r'see (\w+) levels of');
final _shareReg = RegExp(r'network, ([a-z ]+?) of which');
final _operatorReg = RegExp(
  r'operated by <b>([^<]+)</b> whose (?:<b>)?web traffic(?:</b>)? we (?:also )?consider to present a potentially <b>([^<]+)</b>',
);
final _ownerReg = RegExp(
  r'owned by <b>([^<]+)</b> whose web traffic we (?:also )?consider to present a potentially <b>([^<]+)</b>',
);
final _deviceReg = RegExp(
  r'is operating an? ([A-Za-z ]+?), which could be proxying',
);
final _warningReg = RegExp(r'there is potentially an? ([a-z ]+?) risk that');
final _spaceReg = RegExp(r'\s+');

const _entities = {
  '&amp;': '&',
  '&nbsp;': ' ',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&rsquo;': '’',
};

String _unescape(String text) {
  var result = text;
  for (final MapEntry(:key, :value) in _entities.entries) {
    result = result.replaceAll(key, value);
  }
  return result;
}

String _text(String html) =>
    _unescape(html.replaceAll(_tagReg, ' ')).replaceAll(_spaceReg, ' ').trim();

IpRiskLevel? _levelWord(String? word) => switch (word?.trim().toLowerCase()) {
  'low' => IpRiskLevel.low,
  'medium' => IpRiskLevel.medium,
  'high' => IpRiskLevel.high,
  'very high' => IpRiskLevel.veryHigh,
  _ => null,
};

IpRiskNote? _note(String body) {
  final panel = _panelReg.firstMatch(body)?.group(1);
  if (panel == null) return null;
  final text = _unescape(
    panel.replaceAll(_noteTagReg, ' '),
  ).replaceAll(_spaceReg, ' ');
  final indirect = _indirectReg.firstMatch(text);
  final operator = _operatorReg.firstMatch(text);
  final owner = _ownerReg.firstMatch(text);
  final device = _deviceReg.firstMatch(text)?.group(1)?.toLowerCase();
  return IpRiskNote(
    direct: text.contains('where we have visibility, we apply')
        ? true
        : indirect != null
        ? false
        : null,
    isp: indirect?.group(1)?.trim() ?? '',
    amount: switch (_amountReg.firstMatch(text)?.group(1)) {
      'low' => IpRiskAmount.low,
      'medium' => IpRiskAmount.medium,
      'high' => IpRiskAmount.high,
      _ => null,
    },
    share: switch (_shareReg.firstMatch(text)?.group(1)) {
      'little' => IpRiskShare.little,
      'some' => IpRiskShare.some,
      'almost all' => IpRiskShare.almostAll,
      _ => null,
    },
    operatorName: operator?.group(1)?.trim() ?? '',
    operatorLevel: _levelWord(operator?.group(2)),
    ownerName: owner?.group(1)?.trim() ?? '',
    ownerLevel: _levelWord(owner?.group(2)),
    connection: text.contains('it is a commercial server')
        ? IpRiskConnection.server
        : switch (device) {
            'anonymising vpn' || 'anonymizing vpn' => IpRiskConnection.vpn,
            'public proxy' => IpRiskConnection.publicProxy,
            'tor exit node' => IpRiskConnection.tor,
            'web proxy' => IpRiskConnection.webProxy,
            _ => null,
          },
    warning: _levelWord(_warningReg.firstMatch(text)?.group(1)),
  );
}

IpRiskLevel _level(String text, int score) {
  final value = text.toLowerCase();
  if (value.contains('very high')) return IpRiskLevel.veryHigh;
  if (value.contains('high')) return IpRiskLevel.high;
  if (value.contains('medium')) return IpRiskLevel.medium;
  if (value.contains('low')) return IpRiskLevel.low;
  return switch (score) {
    >= 90 => IpRiskLevel.veryHigh,
    >= 60 => IpRiskLevel.high,
    >= 30 => IpRiskLevel.medium,
    _ => IpRiskLevel.low,
  };
}

IpRisk? parseScamalyticsBytes(String ip, List<int> data) {
  final bytes = data.length > 2 && data[0] == 0x1f && data[1] == 0x8b
      ? gzip.decode(data)
      : data;
  return parseScamalytics(ip, utf8.decode(bytes, allowMalformed: true));
}

IpRisk? parseScamalytics(String ip, String html) {
  final body = html.replaceAll(_commentReg, '');
  final score = int.tryParse(
    _scoreReg.firstMatch(body)?.group(1) ??
        _jsonScoreReg.firstMatch(body)?.group(1) ??
        '',
  );
  if (score == null) return null;
  final riskText =
      _jsonRiskReg.firstMatch(body)?.group(1) ??
      _panelRiskReg.firstMatch(body)?.group(1) ??
      '';
  final info = <String, String>{};
  final checks = <IpRiskCheck>[];
  var section = '';
  for (final match in _rowReg.allMatches(body)) {
    final title = match.group(1);
    if (title != null) {
      section = _text(title).toLowerCase();
      continue;
    }
    final name = _text(match.group(2) ?? '');
    final value = _text(match.group(3) ?? '');
    if (name.isEmpty || value.isEmpty) continue;
    final group = switch (section) {
      'datacenter' => IpRiskGroup.datacenter,
      'external blacklists' => IpRiskGroup.blacklist,
      'proxies' => IpRiskGroup.proxy,
      'residential proxy' when name == 'Residential Proxy' =>
        IpRiskGroup.datacenter,
      _ => null,
    };
    if (group == null) {
      if (value.toLowerCase() != 'n/a') info.putIfAbsent(name, () => value);
      continue;
    }
    checks.add(
      IpRiskCheck(
        group: group,
        name: name,
        hit: switch (value.toLowerCase()) {
          'yes' => true,
          'no' => false,
          _ => null,
        },
      ),
    );
  }
  final isServer = checks.any(
    (check) =>
        check.group == IpRiskGroup.proxy &&
        check.name == 'Server' &&
        check.hit == true,
  );
  final asn = info['ASN'] ?? '';
  final region = info['State / Province'] ?? '';
  final countryCode = IpInfo.normalizeCountryCode(
    info['Country Code'] ?? '',
    info['Country Name'],
    region,
  );
  final country =
      IpInfo.normalizeCountry(info['Country Name'], countryCode, region) ?? '';
  return IpRisk(
    ip: ip,
    score: score.clamp(0, 100),
    level: _level(riskText, score),
    hostname: info['Hostname'] ?? '',
    asn: asn.isEmpty || asn.startsWith('AS') ? asn : 'AS$asn',
    isp: info['ISP Name'] ?? '',
    organization: info['Organization Name'] ?? '',
    country: country,
    countryCode: countryCode,
    region: region,
    city: info['City'] ?? '',
    checks: [
      for (final check in checks)
        isServer && check.name == 'Datacenter' && check.hit == null
            ? check.copyWith(hit: true)
            : check,
    ],
    note: _note(body),
  );
}
