// ignore_for_file: invalid_annotation_target

import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/common.freezed.dart';
part 'generated/common.g.dart';

@freezed
abstract class NavigationItem with _$NavigationItem {
  const factory NavigationItem({
    required Icon icon,
    required PageLabel label,
    final String? description,
    required WidgetBuilder builder,
    @Default(true) bool keep,
    String? path,
    @Default([NavigationItemMode.mobile, NavigationItemMode.desktop])
    List<NavigationItemMode> modes,
  }) = _NavigationItem;
}

@freezed
abstract class Package with _$Package {
  const factory Package({
    required String packageName,
    required String label,
    required bool system,
    required bool internet,
    @Default(0) int firstInstallTime,
    @Default(0) int lastUpdateTime,
  }) = _Package;

  factory Package.fromJson(Map<String, Object?> json) =>
      _$PackageFromJson(json);
}

@freezed
abstract class Metadata with _$Metadata {
  const factory Metadata({
    @Default(0) int uid,
    @Default('') String network,
    @Default('') String sourceIP,
    @Default('') String sourcePort,
    @Default('') String destinationIP,
    @Default('') String destinationPort,
    @Default('') String host,
    DnsMode? dnsMode,
    @Default('') String process,
    @Default('') String processPath,
    @Default('') String remoteDestination,
    @Default([]) List<String> sourceGeoIP,
    @Default([]) List<String> destinationGeoIP,
    @Default('') String destinationIPASN,
    @Default('') String sourceIPASN,
    @Default('') String specialRules,
    @Default('') String specialProxy,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, Object?> json) =>
      _$MetadataFromJson(json);
}

@freezed
abstract class TrackerInfo with _$TrackerInfo {
  const factory TrackerInfo({
    required String id,
    @Default(0) int upload,
    @Default(0) int download,
    required DateTime start,
    required Metadata metadata,
    required List<String> chains,
    required String rule,
    required String rulePayload,
    int? downloadSpeed,
    int? uploadSpeed,
  }) = _TrackerInfo;

  factory TrackerInfo.fromJson(Map<String, Object?> json) =>
      _$TrackerInfoFromJson(json);
}

extension TrackerInfoExt on TrackerInfo {
  String get desc {
    var text = '${metadata.network}://';
    final ips = [
      metadata.host,
      metadata.destinationIP,
    ].where((ip) => ip.isNotEmpty);
    text += ips.join('/');
    text += ':${metadata.destinationPort}';
    return text;
  }

  String get progressText {
    final process = metadata.process;
    final uid = metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
  }
}

String _logDateTime(dynamic _) {
  return DateTime.now().showFull;
}

// String _logId(_) {
//   return utils.id;
// }

@freezed
abstract class Log with _$Log {
  const factory Log({
    // @JsonKey(fromJson: _logId) required String id,
    @JsonKey(name: 'LogLevel') @Default(LogLevel.error) LogLevel logLevel,
    @JsonKey(name: 'Payload') @Default('') String payload,
    @JsonKey(fromJson: _logDateTime) required String dateTime,
  }) = _Log;

  factory Log.app(String payload) {
    return Log(
      logLevel: LogLevel.info,
      payload: payload,
      dateTime: _logDateTime(null),
      // id: _logId(null),
    );
  }

  factory Log.fromJson(Map<String, Object?> json) => _$LogFromJson(json);
}

@freezed
abstract class LogsState with _$LogsState {
  const factory LogsState({
    @Default([]) List<Log> logs,
    @Default([]) List<String> keywords,
    @Default('') String query,
    @Default(false) bool autoScrollToEnd,
  }) = _LogsState;
}

extension LogsStateExt on LogsState {
  List<Log> get list {
    final lowQuery = query.toLowerCase();
    return logs.where((log) {
      final logLevelName = log.logLevel.name;
      return {logLevelName}.containsAll(keywords) &&
          ((log.payload.toLowerCase().contains(lowQuery)) ||
              logLevelName.contains(lowQuery));
    }).toList();
  }
}

@freezed
abstract class TrackerInfosState with _$TrackerInfosState {
  const factory TrackerInfosState({
    @Default([]) List<TrackerInfo> trackerInfos,
    @Default([]) List<String> keywords,
    @Default('') String query,
    @Default(false) bool autoScrollToEnd,
  }) = _TrackerInfosState;
}

extension TrackerInfosStateExt on TrackerInfosState {
  List<TrackerInfo> get list {
    final lowerQuery = query.toLowerCase().trim();
    final lowQuery = query.toLowerCase();
    return trackerInfos.where((trackerInfo) {
      final chains = trackerInfo.chains;
      final process = trackerInfo.metadata.process;
      final networkText = trackerInfo.metadata.network.toLowerCase();
      final hostText = trackerInfo.metadata.host.toLowerCase();
      final destinationIPText = trackerInfo.metadata.destinationIP
          .toLowerCase();
      final processText = trackerInfo.metadata.process.toLowerCase();
      final chainsText = chains.join('').toLowerCase();
      return {...chains, process}.containsAll(keywords) &&
          (networkText.contains(lowerQuery) ||
              hostText.contains(lowerQuery) ||
              destinationIPText.contains(lowQuery) ||
              processText.contains(lowerQuery) ||
              chainsText.contains(lowerQuery));
    }).toList();
  }
}

const defaultDavFileName = 'backup.zip';

@freezed
abstract class DAV with _$DAV {
  const factory DAV({
    required String uri,
    required String user,
    required String password,
    @Default(defaultDavFileName) String fileName,
  }) = _DAV;

  factory DAV.fromJson(Map<String, Object?> json) => _$DAVFromJson(json);
}

@freezed
abstract class FileInfo with _$FileInfo {
  const factory FileInfo({required int size, required DateTime lastModified}) =
      _FileInfo;
}

extension FileInfoExt on FileInfo {
  String get desc =>
      '${TrafficValue(value: size).show}  ·  ${lastModified.lastUpdateTimeDesc}';
}

@freezed
abstract class VersionInfo with _$VersionInfo {
  const factory VersionInfo({
    @Default('') String clashName,
    @Default('') String version,
  }) = _VersionInfo;

  factory VersionInfo.fromJson(Map<String, Object?> json) =>
      _$VersionInfoFromJson(json);
}

class Traffic {
  int id;
  TrafficValue up;
  TrafficValue down;

  Traffic({int? up, int? down})
    : id = DateTime.now().millisecondsSinceEpoch,
      up = TrafficValue(value: up),
      down = TrafficValue(value: down);

  num get speed => up.value + down.value;

  factory Traffic.fromMap(Map<String, dynamic> map) {
    return Traffic(up: map['up'], down: map['down']);
  }

  String toSpeedText() {
    return '↑ $up/s   ↓ $down/s';
  }

  @override
  String toString() {
    return '$up↑ $down↓';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Traffic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          up == other.up &&
          down == other.down;

  @override
  int get hashCode => id.hashCode ^ up.hashCode ^ down.hashCode;
}

@immutable
class TrafficValueShow {
  final double value;
  final TrafficUnit unit;

  const TrafficValueShow({required this.value, required this.unit});
}

@freezed
abstract class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

@freezed
abstract class Group with _$Group {
  const factory Group({
    required GroupType type,
    @Default([]) List<Proxy> all,
    String? now,
    bool? hidden,
    String? testUrl,
    @Default('') String icon,
    required String name,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}

extension GroupsExt on List<Group> {
  Group? getGroup(String groupName) {
    final index = indexWhere((element) => element.name == groupName);
    return index != -1 ? this[index] : null;
  }
}

extension GroupExt on Group {
  String get realNow => now ?? '';

  String getCurrentSelectedName(String proxyName) {
    if (type.isComputedSelected) {
      return realNow.isNotEmpty ? realNow : proxyName;
    }
    return proxyName.isNotEmpty ? proxyName : realNow;
  }
}

@immutable
class TrafficValue {
  final int _value;

  const TrafficValue({int? value}) : _value = value ?? 0;

  int get value => _value;

  String get show => '$showValue $showUnit';

  String get shortShow =>
      '${trafficValueShow.value.fixed(decimals: 1)} $showUnit';

  String get showValue => trafficValueShow.value.fixed();

  String get showUnit => trafficValueShow.unit.name;

  TrafficValueShow get trafficValueShow {
    if (_value > pow(1024, 4)) {
      return TrafficValueShow(
        value: _value / pow(1024, 4),
        unit: TrafficUnit.TB,
      );
    }
    if (_value > pow(1024, 3)) {
      return TrafficValueShow(
        value: _value / pow(1024, 3),
        unit: TrafficUnit.GB,
      );
    }
    if (_value > pow(1024, 2)) {
      return TrafficValueShow(
        value: _value / pow(1024, 2),
        unit: TrafficUnit.MB,
      );
    }
    if (_value > pow(1024, 1)) {
      return TrafficValueShow(
        value: _value / pow(1024, 1),
        unit: TrafficUnit.KB,
      );
    }
    return TrafficValueShow(value: _value.toDouble(), unit: TrafficUnit.B);
  }

  @override
  String toString() {
    return '$showValue$showUnit';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrafficValue &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

@freezed
abstract class ColorSchemes with _$ColorSchemes {
  const factory ColorSchemes({
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) = _ColorSchemes;
}

extension ColorSchemesExt on ColorSchemes {
  ColorScheme getColorSchemeForBrightness(
    Brightness brightness,
    DynamicSchemeVariant schemeVariant,
  ) {
    if (brightness == Brightness.dark) {
      return darkColorScheme != null
          ? ColorScheme.fromSeed(
              seedColor: darkColorScheme!.primary,
              brightness: Brightness.dark,
              dynamicSchemeVariant: schemeVariant,
            )
          : ColorScheme.fromSeed(
              seedColor: Color(defaultPrimaryColor),
              brightness: Brightness.dark,
              dynamicSchemeVariant: schemeVariant,
            );
    }
    return lightColorScheme != null
        ? ColorScheme.fromSeed(
            seedColor: lightColorScheme!.primary,
            dynamicSchemeVariant: schemeVariant,
          )
        : ColorScheme.fromSeed(
            seedColor: Color(defaultPrimaryColor),
            dynamicSchemeVariant: schemeVariant,
          );
  }
}

class IpInfo {
  final String ip;
  final String countryCode;
  final String? country;
  final String? province;
  final String? city;
  final String? isp;
  final String? asn;
  final String? asName;
  final String? asDomain;
  final String? continent;
  final String? continentCode;

  const IpInfo({
    required this.ip,
    required this.countryCode,
    this.country,
    this.province,
    this.city,
    this.isp,
    this.asn,
    this.asName,
    this.asDomain,
    this.continent,
    this.continentCode,
  });

  static IpInfo fromJson(Map<String, dynamic> json) {
    // myip.ipip.net 格式: {"ret":"ok", "data":{"ip":"...", "location":["中国", "浙江", "绍兴", "", "电信"]}}
    if (json['ret'] == 'ok' && json['data'] is Map) {
      final data = json['data'] as Map;
      final ip = data['ip']?.toString() ?? '';
      final loc = data['location'];
      if (loc is List && ip.isNotEmpty) {
        final locList = loc.map((e) => e?.toString() ?? '').toList();
        final country = locList.isNotEmpty && locList[0].isNotEmpty ? locList[0] : null;
        final countryCode = country == '中国' ? 'CN' : '';
        final province = locList.length > 1 && locList[1].isNotEmpty ? locList[1] : null;
        final city = locList.length > 2 && locList[2].isNotEmpty ? locList[2] : null;
        final last = locList.length > 4 && locList[4].isNotEmpty
            ? locList[4]
            : (locList.length > 3 && locList[3].isNotEmpty ? locList[3] : null);

        String? isp;
        String? asName;
        String? asDomain;
        if (last != null && last.isNotEmpty) {
          if (last.contains('.')) {
            asDomain = last;
            asName = last;
          } else {
            isp = last;
            asName = last;
          }
        }

        return IpInfo(
          ip: ip,
          countryCode: countryCode,
          country: country,
          province: province,
          city: city,
          isp: isp,
          asName: asName,
          asDomain: asDomain,
        );
      }
    }

    final ip = json['ip']?.toString() ?? '';
    // myip.la 格式: {"ip":"...", "location":{"country_code":"...", "country_name":"...", "province":"...", "city":"..."}}
    if (json['location'] is Map) {
      final loc = json['location'] as Map;
      final countryCode = loc['country_code']?.toString() ?? '';
      final country = loc['country_name']?.toString();
      final province = loc['province']?.toString();
      final city = loc['city']?.toString();
      if (ip.isNotEmpty) {
        return IpInfo(
          ip: ip,
          countryCode: countryCode,
          country: country,
          province: province,
          city: city,
        );
      }
    }
    // ip-api.com 格式: {"status":"success", "country":"...", "countryCode":"...", "regionName":"...", "city":"...", "isp":"...", "org":"...", "as":"...", "query":"..."}
    if (json['query'] != null || json['countryCode'] != null) {
      final ip = (json['query'] ?? json['ip'])?.toString() ?? '';
      final countryCode =
          (json['countryCode'] ?? json['country_code'])?.toString() ?? '';
      final country = json['country']?.toString();
      final province =
          (json['regionName'] ?? json['region'] ?? json['province'])?.toString();
      final city = json['city']?.toString();
      final isp = json['isp']?.toString();
      final org = json['org']?.toString();
      final asName = org?.isNotEmpty == true
          ? org
          : (json['as_name']?.toString());

      // 仅取最前面的 AS 号 (例如: "AS37963 Hangzhou Alibaba..." -> "AS37963")
      final rawAs = (json['as'] ?? json['asn'])?.toString() ?? '';
      final asnMatch =
          RegExp(r'^(AS\d+)', caseSensitive: false).firstMatch(rawAs.trim());
      final asn = asnMatch != null
          ? asnMatch.group(1)!.toUpperCase()
          : (rawAs.isNotEmpty ? rawAs.trim().split(' ').first : null);

      if (ip.isNotEmpty) {
        return IpInfo(
          ip: ip,
          countryCode: countryCode,
          country: country,
          province: province,
          city: city,
          isp: isp,
          asName: asName,
          asn: asn,
        );
      }
    }
    // ipinfo.io 格式: {"ip":"...", "country_code":"...", "country":"...", "asn":"...", "as_name":"...", "as_domain":"...", "continent":"...", "continent_code":"..."}
    final countryCode =
        (json['country_code'] ?? json['country'])?.toString() ?? '';
    final country = json['country']?.toString();
    final asn = json['asn']?.toString();
    final asName = json['as_name']?.toString();
    final asDomain = json['as_domain']?.toString();
    final continent = json['continent']?.toString();
    final continentCode = json['continent_code']?.toString();
    if (ip.isNotEmpty) {
      return IpInfo(
        ip: ip,
        countryCode: countryCode,
        country: country,
        asn: asn,
        asName: asName,
        asDomain: asDomain,
        continent: continent,
        continentCode: continentCode,
      );
    }
    throw const FormatException('invalid ip json format');
  }

  static IpInfo fromCloudflareTrace(String traceText) {
    // Cloudflare trace格式示例:
    // fl=...
    // h=...
    // ip=1.2.3.4
    // ts=...
    // visit_scheme=https
    // uag=...
    // colo=...
    // sliver=none
    // http=http/2
    // loc=US
    // tls=TLSv1.3
    // sni=plaintext
    // warp=off
    // gateway=off
    // rbi=off
    // kex=X25519

    final lines = traceText.split('\n');
    String? ip;
    String? countryCode;

    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();

        if (key == 'ip') {
          ip = value;
        } else if (key == 'loc') {
          countryCode = value;
        }
      }
    }

    if (ip != null && countryCode != null) {
      return IpInfo(ip: ip, countryCode: countryCode);
    }

    throw const FormatException('invalid cloudflare trace format');
  }

  static bool _hasNonAscii(String? str) {
    if (str == null || str.isEmpty) return false;
    return str.codeUnits.any((c) => c > 127);
  }

  IpInfo merge(IpInfo other, {bool otherIsAuthoritative = false}) {
    final isOtherPrimary = otherIsAuthoritative ||
        ((asn == null || asn!.isEmpty) &&
            (other.asn != null && other.asn!.isNotEmpty));

    final primary = isOtherPrimary ? other : this;
    final secondary = isOtherPrimary ? this : other;

    final mergedIp = primary.ip.isNotEmpty ? primary.ip : secondary.ip;
    final bool isSameIp = primary.ip.isEmpty ||
        secondary.ip.isEmpty ||
        primary.ip == secondary.ip;

    final primaryCc = primary.countryCode.trim().toUpperCase();
    final secondaryCc = secondary.countryCode.trim().toUpperCase();

    final bool isSameCountry = isSameIp &&
        (primaryCc.isEmpty ||
            secondaryCc.isEmpty ||
            primaryCc == secondaryCc);

    final mergedCountryCode = primaryCc.isNotEmpty ? primaryCc : secondaryCc;

    final mergedCountry = () {
      if (isSameCountry) {
        if (_hasNonAscii(primary.country)) return primary.country;
        if (_hasNonAscii(secondary.country)) return secondary.country;
        return (primary.country?.isNotEmpty == true)
            ? primary.country
            : secondary.country;
      }
      return (primary.country?.isNotEmpty == true)
          ? primary.country
          : secondary.country;
    }();

    final mergedProvince = primary.province?.isNotEmpty == true
        ? primary.province
        : (isSameCountry ? secondary.province : null);

    final mergedCity = primary.city?.isNotEmpty == true
        ? primary.city
        : (isSameCountry ? secondary.city : null);

    final mergedAsn =
        primary.asn?.isNotEmpty == true ? primary.asn : secondary.asn;
    final mergedAsName =
        primary.asName?.isNotEmpty == true ? primary.asName : secondary.asName;
    final mergedAsDomain = primary.asDomain?.isNotEmpty == true
        ? primary.asDomain
        : secondary.asDomain;
    final mergedIsp =
        primary.isp?.isNotEmpty == true ? primary.isp : secondary.isp;
    final mergedContinent = primary.continent?.isNotEmpty == true
        ? primary.continent
        : secondary.continent;
    final mergedContinentCode = primary.continentCode?.isNotEmpty == true
        ? primary.continentCode
        : secondary.continentCode;

    return IpInfo(
      ip: mergedIp,
      countryCode: mergedCountryCode,
      country: mergedCountry,
      province: mergedProvince,
      city: mergedCity,
      isp: mergedIsp,
      asn: mergedAsn,
      asName: mergedAsName,
      asDomain: mergedAsDomain,
      continent: mergedContinent,
      continentCode: mergedContinentCode,
    );
  }

  IpInfo copyWith({
    String? ip,
    String? countryCode,
    String? country,
    String? province,
    String? city,
    String? isp,
    String? asn,
    String? asName,
    String? asDomain,
    String? continent,
    String? continentCode,
  }) {
    return IpInfo(
      ip: ip ?? this.ip,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      isp: isp ?? this.isp,
      asn: asn ?? this.asn,
      asName: asName ?? this.asName,
      asDomain: asDomain ?? this.asDomain,
      continent: continent ?? this.continent,
      continentCode: continentCode ?? this.continentCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'countryCode': countryCode,
      if (country != null) 'country': country,
      if (province != null) 'regionName': province,
      if (city != null) 'city': city,
      if (isp != null) 'isp': isp,
      if (asName != null) 'org': asName,
      if (asn != null) 'as': asn,
      if (asDomain != null) 'as_domain': asDomain,
      if (continent != null) 'continent': continent,
      if (continentCode != null) 'continent_code': continentCode,
    };
  }

  @override
  String toString() {
    return 'IpInfo{ip: $ip, countryCode: $countryCode, country: $country, province: $province, city: $city, isp: $isp, asn: $asn, asName: $asName}';
  }
}

@freezed
abstract class HotKeyAction with _$HotKeyAction {
  const factory HotKeyAction({
    required HotAction action,
    int? key,
    @Default({}) Set<KeyboardModifier> modifiers,
  }) = _HotKeyAction;

  factory HotKeyAction.fromJson(Map<String, Object?> json) =>
      _$HotKeyActionFromJson(json);
}

typedef Validator = String? Function(String? value);

@freezed
abstract class Field with _$Field {
  const factory Field({
    required String label,
    required String value,
    Validator? validator,
  }) = _Field;
}

enum PopupMenuItemType { primary, danger }

class PopupMenuItemData {
  const PopupMenuItemData({
    this.icon,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
}

@freezed
abstract class TextPainterParams with _$TextPainterParams {
  const factory TextPainterParams({
    required String? text,
    required double? fontSize,
    required double textScaleFactor,
    @Default(double.infinity) double maxWidth,
    int? maxLines,
  }) = _TextPainterParams;

  factory TextPainterParams.fromJson(Map<String, Object?> json) =>
      _$TextPainterParamsFromJson(json);
}

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result({
    required T? data,
    required ResultType type,
    required String message,
    @Default(false) bool needRestart,
  }) = _Result;

  factory Result.success(T data, {bool needRestart = false}) =>
      Result(data: data, type: ResultType.success, message: '', needRestart: needRestart);

  factory Result.error(String message) =>
      Result(data: null, type: ResultType.error, message: message);
}

extension ResultExt on Result {
  bool get isError => type == ResultType.error;

  bool get isSuccess => type == ResultType.success;
}

@freezed
abstract class Script with _$Script {
  const factory Script({
    required String id,
    required String label,
    required String content,
    String? url,
    @JsonKey(name: 'custom-options') Map<String, bool>? customOptions,
  }) = _Script;

  factory Script.create({required String label, required String content, String? url}) {
    return Script(id: utils.uuidV4, label: label, content: content, url: url);
  }

  factory Script.fromJson(Map<String, Object?> json) => _$ScriptFromJson(json);
}

extension ScriptExt on Script {
  bool get isCompatibleWithBettbox {
    final head = content.length > 2000 ? content.substring(0, 2000) : content;
    return head.contains('Compatible_With_Bettbox');
  }
}
