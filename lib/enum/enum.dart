// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:bett_box/common/system.dart';
import 'package:bett_box/common/app_localizations.dart';
import 'package:bett_box/views/dashboard/widgets/widgets.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

enum SupportPlatform {
  Windows,
  MacOS,
  Linux,
  Android;

  static SupportPlatform get currentPlatform {
    if (system.isWindows) {
      return SupportPlatform.Windows;
    } else if (system.isMacOS) {
      return SupportPlatform.MacOS;
    } else if (Platform.isLinux) {
      return SupportPlatform.Linux;
    } else if (system.isAndroid) {
      return SupportPlatform.Android;
    }
    throw 'invalid platform';
  }
}

const desktopPlatforms = [
  SupportPlatform.Linux,
  SupportPlatform.MacOS,
  SupportPlatform.Windows,
];

enum GroupType {
  Selector,
  URLTest,
  Fallback,
  LoadBalance;

  static GroupType parseProfileType(String type) {
    return switch (type) {
      'url-test' => URLTest,
      'select' => Selector,
      'fallback' => Fallback,
      'load-balance' => LoadBalance,
      String() => throw UnimplementedError(),
    };
  }
}

enum GroupName { GLOBAL, Proxy, Auto, Fallback }

extension GroupTypeExtension on GroupType {
  static List<String> get valueList =>
      GroupType.values.map((e) => e.toString().split('.').last).toList();

  bool get isComputedSelected {
    return [GroupType.URLTest, GroupType.Fallback].contains(this);
  }

  static GroupType? getGroupType(String value) {
    final index = GroupTypeExtension.valueList.indexOf(value);
    if (index == -1) return null;
    return GroupType.values[index];
  }

  String get value => GroupTypeExtension.valueList[index];
}

enum UsedProxy { GLOBAL, DIRECT, REJECT }

extension UsedProxyExtension on UsedProxy {
  static List<String> get valueList =>
      UsedProxy.values.map((e) => e.toString().split('.').last).toList();

  String get value => UsedProxyExtension.valueList[index];
}

enum Mode { rule, global, direct }

enum IpClickBehavior { privacyProtection, manualRefresh, switchDomestic }

enum TrayClickBehavior { showPanel, showMenu }

enum ViewMode { mobile, laptop, desktop }

enum LogLevel { debug, info, warning, error, silent }

extension LogLevelExt on LogLevel {
  String get label => '${name[0].toUpperCase()}${name.substring(1)}';
}

enum LogSource { core, app }

enum TransportProtocol { udp, tcp }

enum TrafficUnit { B, KB, MB, GB, TB }

enum NavigationItemMode { mobile, desktop, more }

enum Network { tcp, udp }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed, mips }

enum TunDnsMode { disabled, native, hijack }

enum CongestionController { cubic, reno, bbr, bbr3 }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, installTime, updateTime }

enum ProfileType { file, url }

enum ConnectionsSortType {
  defaultSort,
  realTimeSpeed,
  totalTraffic,
  creationTime,
}

enum ResultType {
  @JsonValue(0)
  success,
  @JsonValue(-1)
  error,
}

enum AppMessageType {
  log,
  delay,
  request,
  loaded,
  speedTest,
  stunTest,
  iperf,
  localPing,
  tailscaleAuth,
}

enum InvokeMessageType { protect, process }

enum FindProcessMode { always, off }

enum RecoveryOption { all, onlyProfiles }

enum ChipType { action, delete }

enum CommonCardType { plain, filled }
//
// extension CommonCardTypeExt on CommonCardType {
//   CommonCardType get variant => CommonCardType.plain;
// }

enum ProxiesType { tab, list }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { expand, shrink, min }

enum DnsMode {
  normal,
  @JsonValue('fake-ip')
  fakeIp,
  @JsonValue('redir-host')
  redirHost,
  hosts,
}

enum CacheAlgorithm { arc, lru }

enum FilterMode { blacklist, whitelist, rule }

enum ExternalControllerStatus {
  @JsonValue('')
  close(''),
  @JsonValue('127.0.0.1:9090')
  open('127.0.0.1:9090');

  final String value;

  const ExternalControllerStatus(this.value);
}

enum KeyboardModifier {
  alt([PhysicalKeyboardKey.altLeft, PhysicalKeyboardKey.altRight]),
  capsLock([PhysicalKeyboardKey.capsLock]),
  control([PhysicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlRight]),
  fn([PhysicalKeyboardKey.fn]),
  meta([PhysicalKeyboardKey.metaLeft, PhysicalKeyboardKey.metaRight]),
  shift([PhysicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftRight]);

  final List<PhysicalKeyboardKey> physicalKeys;

  const KeyboardModifier(this.physicalKeys);
}

extension KeyboardModifierExt on KeyboardModifier {
  HotKeyModifier toHotKeyModifier() {
    return switch (this) {
      KeyboardModifier.alt => HotKeyModifier.alt,
      KeyboardModifier.capsLock => HotKeyModifier.capsLock,
      KeyboardModifier.control => HotKeyModifier.control,
      KeyboardModifier.fn => HotKeyModifier.fn,
      KeyboardModifier.meta => HotKeyModifier.meta,
      KeyboardModifier.shift => HotKeyModifier.shift,
    };
  }
}

enum HotAction { start, view, mode, proxy, tun }

enum ProxiesIconStyle { standard, none, icon }

enum FontFamily {
  twEmoji('Twemoji'),
  jetBrainsMono('JetBrainsMono'),
  icon('Icons');

  final String value;

  const FontFamily(this.value);
}

enum RouteMode { bypassPrivate, config }

enum ActionMethod {
  message,
  initClash,
  getIsInit,
  forceGc,
  shutdown,
  validateConfig,
  updateConfig,
  getConfig,
  getRuntimeConfig,
  exportConfig,
  getProxies,
  changeProxy,
  getTraffic,
  getTotalTraffic,
  resetTraffic,
  asyncTestDelay,
  getConnections,
  closeConnections,
  resetConnections,
  closeConnection,
  getExternalProviders,
  getExternalProvider,
  updateGeoData,
  updateExternalProvider,
  sideLoadExternalProvider,
  startLog,
  stopLog,
  getLogs,
  clearLogs,
  startTrackRequests,
  stopTrackRequests,
  getRequests,
  clearRequests,
  startListener,
  stopListener,
  getCountryCode,
  getMemory,
  crash,
  setupConfig,
  flushFakeIP,
  flushDnsCache,
  generateAgeKeyPair,
  convertAgeSecretKeyToPublicKey,
  decryptAgeConfig,
  getMode,
  parseExternalProviderContent,
  getCoreStatus,
  getTailscaleStatus,
  startTailscale,
  startSpeedTest,
  cancelSpeedTest,
  probeSpeedTest,
  getSpeedTestServers,
  startStunTest,
  cancelStunTest,
  routeTrace,
  dnsQuery,
  mrsPrepare,
  mrsLookup,
  cancelMrsLookup,
  startToolProxy,
  stopToolProxy,
  ageCrypt,
  startIperfServer,
  stopIperfServer,
  startIperfClient,
  cancelIperfClient,
  startLocalPing,
  cancelLocalPing,

  ///Android,
  setState,
  startTun,
  stopTun,
  getRunTime,
  updateDns,
  getAndroidVpnOptions,
  getCurrentProfileName,
}

enum StunTestPhase { connecting, binding, filtering, mapping, done }

enum IperfRole { client, server }

enum IperfPhase { connecting, running, done }

enum IperfProtocol { tcp, udp }

enum IperfDirection { upload, download, bidir }

enum LocalPingProtocol { icmp, tcp, udp }

enum LocalPingPhase { resolving, running, done }

enum LocalPingStatus { ok, closed, timeout, unreachable, error }

@JsonEnum(fieldRename: FieldRename.kebab)
enum NatType {
  open,
  fullCone,
  restricted,
  portRestricted,
  symmetric,
  cone,
  blocked,
  unknown,
}

enum SpeedTestProvider { apple, speedtest, cloudflare }

enum SpeedTestPhase { connecting, latency, download, upload, done }

enum SpeedTestProtocol {
  http1('h1', 'HTTP/1.1'),
  http2('h2', 'HTTP/2'),
  http3('h3', 'HTTP/3');

  final String value;
  final String label;

  const SpeedTestProtocol(this.value, this.label);

  static SpeedTestProtocol fromValue(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => http1);
}

enum AuthorizeCode { none, success, error }

enum WindowsHelperServiceStatus { none, presence, running }

enum FunctionTag {
  updateClashConfig,
  setupClashConfig,
  updateStatus,
  updateGroups,
  addCheckIpNum,
  applyProfile,
  savePreferences,
  changeProxy,
  checkIp,
  updateDelay,
  vpnTip,
  autoLaunch,
  renderPause,
  updatePageIndex,
  pageChange,
  proxiesTabChange,
  logs,
  requests,
  autoScrollToEnd,
  autoBackup,
}

enum DashboardWidget {
  networkSpeed(GridItem(crossAxisCellCount: 8, child: NetworkSpeed())),
  networkSpeedSmall(
    GridItem(crossAxisCellCount: 4, child: NetworkSpeedSmall()),
  ),
  outboundModeV2(GridItem(crossAxisCellCount: 8, child: OutboundModeV2())),
  outboundMode(GridItem(crossAxisCellCount: 4, child: OutboundMode())),
  trafficUsage(GridItem(crossAxisCellCount: 4, child: TrafficUsage())),
  networkDetection(GridItem(crossAxisCellCount: 4, child: NetworkDetection())),
  tunButton(
    GridItem(crossAxisCellCount: 4, child: TUNButton()),
    platforms: desktopPlatforms,
  ),
  vpnButton(
    GridItem(crossAxisCellCount: 4, child: VpnButton()),
    platforms: [SupportPlatform.Android],
  ),
  systemProxyButton(
    GridItem(crossAxisCellCount: 4, child: SystemProxyButton()),
    platforms: desktopPlatforms,
  ),
  intranetIp(GridItem(crossAxisCellCount: 4, child: IntranetIP())),
  memoryInfo(GridItem(crossAxisCellCount: 4, child: MemoryInfo())),
  connectionsCount(GridItem(crossAxisCellCount: 4, child: ConnectionsCount())),
  ipv6Switch(GridItem(crossAxisCellCount: 4, child: Ipv6Switch())),
  wakelockSwitch(
    GridItem(crossAxisCellCount: 4, child: WakelockSwitch()),
    platforms: desktopPlatforms,
  ),
  dnsOverride(GridItem(crossAxisCellCount: 4, child: DnsOverride())),
  snifferOverride(GridItem(crossAxisCellCount: 4, child: SnifferOverride())),
  ntpOverride(GridItem(crossAxisCellCount: 4, child: NtpOverride())),
  providersInfo(GridItem(crossAxisCellCount: 4, child: ProvidersInfo())),
  fcmStatus(GridItem(crossAxisCellCount: 4, child: FcmStatus())),
  onlinePanel(GridItem(crossAxisCellCount: 4, child: OnlinePanel())),
  mediaUnlock(GridItem(crossAxisCellCount: 8, child: MediaUnlock())),
  mediaUnlockSmall(GridItem(crossAxisCellCount: 4, child: MediaUnlockSmall())),
  startButton(
    GridItem(crossAxisCellCount: 4, isDeletable: false, child: StartButton()),
  );

  final GridItem widget;
  final List<SupportPlatform> platforms;

  const DashboardWidget(this.widget, {this.platforms = SupportPlatform.values});

  static const _variantGroups = [
    [networkSpeedSmall, networkSpeed],
    [outboundModeV2, outboundMode],
    [mediaUnlockSmall, mediaUnlock],
  ];

  List<DashboardWidget> get variants => _variantGroups.firstWhere(
    (group) => group.contains(this),
    orElse: () => [this],
  );

  DashboardWidget get family =>
      variants.reduce((a, b) => a.index <= b.index ? a : b);

  DashboardTileSize get nativeSize => switch (this) {
    networkSpeed || mediaUnlock => DashboardTileSize.large,
    outboundModeV2 => DashboardTileSize.wide,
    outboundMode || mediaUnlockSmall || trafficUsage => DashboardTileSize.tall,
    _ => DashboardTileSize.small,
  };

  List<DashboardTileSize> get sizes => switch (family) {
    networkSpeed => const [
      DashboardTileSize.small,
      DashboardTileSize.wide,
      DashboardTileSize.tall,
      DashboardTileSize.large,
    ],
    trafficUsage => const [DashboardTileSize.tall, DashboardTileSize.wide],
    networkDetection ||
    intranetIp ||
    memoryInfo ||
    connectionsCount ||
    startButton => const [
      DashboardTileSize.small,
      DashboardTileSize.wide,
      DashboardTileSize.tall,
    ],
    _ => [for (final item in variants) item.nativeSize],
  };

  bool get resizable => sizes.length > 1;

  DashboardWidget variantFor(DashboardTileSize size) => variants.firstWhere(
    (item) => item.nativeSize == size,
    orElse: () => family,
  );
}

enum DashboardTileSize {
  small(1, 1),
  wide(2, 1),
  tall(1, 2),
  large(2, 2);

  final int cross;
  final int rows;

  const DashboardTileSize(this.cross, this.rows);
}

enum GeodataLoader { standard, memconservative }

enum PageLabel {
  dashboard,
  proxies,
  profiles,
  tools,
  logs,
  resources,
  script,
  toolbox,
  connections,
}

extension PageLabelExtension on PageLabel {
  String get localizedName {
    switch (this) {
      case PageLabel.dashboard:
        return appLocalizations.dashboard;
      case PageLabel.proxies:
        return appLocalizations.proxies;
      case PageLabel.profiles:
        return appLocalizations.profiles;
      case PageLabel.tools:
        return appLocalizations.navTools;
      case PageLabel.logs:
        return appLocalizations.logs;
      case PageLabel.resources:
        return appLocalizations.resources;
      case PageLabel.script:
        return appLocalizations.script;
      case PageLabel.toolbox:
        return appLocalizations.toolbox;
      case PageLabel.connections:
        return appLocalizations.navConnections;
    }
  }
}

enum RuleAction {
  DOMAIN('DOMAIN'),
  DOMAIN_SUFFIX('DOMAIN-SUFFIX'),
  DOMAIN_KEYWORD('DOMAIN-KEYWORD'),
  DOMAIN_REGEX('DOMAIN-REGEX'),
  GEOSITE('GEOSITE'),
  IP_CIDR('IP-CIDR'),
  IP_CIDR6('IP-CIDR6'),
  IP_SUFFIX('IP-SUFFIX'),
  IP_ASN('IP-ASN'),
  GEOIP('GEOIP'),
  SRC_GEOIP('SRC-GEOIP'),
  SRC_IP_ASN('SRC-IP-ASN'),
  SRC_IP_CIDR('SRC-IP-CIDR'),
  SRC_IP_SUFFIX('SRC-IP-SUFFIX'),
  DST_PORT('DST-PORT'),
  SRC_PORT('SRC-PORT'),
  IN_PORT('IN-PORT'),
  IN_TYPE('IN-TYPE'),
  IN_USER('IN-USER'),
  IN_NAME('IN-NAME'),
  PROCESS_PATH('PROCESS-PATH'),
  PROCESS_PATH_REGEX('PROCESS-PATH-REGEX'),
  PROCESS_NAME('PROCESS-NAME'),
  PROCESS_NAME_REGEX('PROCESS-NAME-REGEX'),
  UID('UID'),
  NETWORK('NETWORK'),
  DSCP('DSCP'),
  RULE_SET('RULE-SET'),
  AND('AND'),
  OR('OR'),
  NOT('NOT'),
  SUB_RULE('SUB-RULE'),
  MATCH('MATCH');

  final String value;

  const RuleAction(this.value);
}

extension RuleActionExt on RuleAction {
  bool get hasParams => [
    RuleAction.GEOIP,
    RuleAction.IP_ASN,
    RuleAction.SRC_IP_ASN,
    RuleAction.IP_CIDR,
    RuleAction.IP_CIDR6,
    RuleAction.IP_SUFFIX,
    RuleAction.RULE_SET,
  ].contains(this);
}

enum OverrideRuleType { override, added }

enum RuleTarget { DIRECT, REJECT }

enum RecoveryStrategy { compatible, override }

enum StartSwitchStyle { tonal, outlined }

enum SidebarFlyoutEntry {
  resources,
  script,
  toolbox,
  theme,
  backupAndRecovery,
  hotkeyManagement,
  loopback,
  basicConfig,
  otherSettings,
  application,
  about;

  static List<SidebarFlyoutEntry> get supportedValues =>
      values.where((entry) => entry != loopback || system.isWindows).toList();

  String get localizedName => switch (this) {
    SidebarFlyoutEntry.resources => appLocalizations.resources,
    SidebarFlyoutEntry.script => appLocalizations.script,
    SidebarFlyoutEntry.toolbox => appLocalizations.toolbox,
    SidebarFlyoutEntry.theme => appLocalizations.theme,
    SidebarFlyoutEntry.backupAndRecovery => appLocalizations.backupAndRecovery,
    SidebarFlyoutEntry.hotkeyManagement => appLocalizations.hotkeyManagement,
    SidebarFlyoutEntry.loopback => appLocalizations.loopback,
    SidebarFlyoutEntry.basicConfig => appLocalizations.basicConfig,
    SidebarFlyoutEntry.otherSettings => appLocalizations.otherSettings,
    SidebarFlyoutEntry.application => appLocalizations.application,
    SidebarFlyoutEntry.about => appLocalizations.about,
  };
}

enum SidebarFlyoutDelay {
  fast(Duration(milliseconds: 50)),
  standard(Duration(milliseconds: 150)),
  slow(Duration(milliseconds: 400));

  final Duration duration;

  const SidebarFlyoutDelay(this.duration);
}

enum CacheTag { logs, rules, requests, proxiesList }

enum Language { yaml, javaScript }

enum ImportOption { code, url, file }

enum ScrollPositionCacheKeys { tools, profiles, proxiesList, proxiesTabList }

enum DelayAnimationType {
  none,
  rotatingCircle,
  pulse,
  spinningLines,
  threeInOut,
  threeBounce,
  circle,
  fadingCircle,
  fadingFour,
  wave,
  doubleBounce,
  chasingDots,
  cubeGrid,
  dancingSquare,
  dualRing,
  fadingCube,
  fadingGrid,
  foldingCube,
  hourGlass,
  pianoWave,
  pouringHourGlass,
  pouringHourGlassRefined,
  pulsingGrid,
  pumpingHeart,
  ring,
  ripple,
  rotatingPlain,
  spinningCircle,
  squareCircle,
  wanderingCubes,
  waveSpinner,
}

enum MrsRawSource {
  bettRules(
    'bett-rules',
    'https://raw.githubusercontent.com/appshubcc/bett-rules/meta/',
  ),
  metaRulesDat(
    'meta-rules-dat',
    'https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/',
  );

  final String label;
  final String baseUrl;

  const MrsRawSource(this.label, this.baseUrl);
}
