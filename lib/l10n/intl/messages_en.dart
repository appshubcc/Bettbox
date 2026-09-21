// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "${Intl.plural(count, one: 'day', other: 'days')}";

  static String m1(label) => "Delete selected ${label}?";

  static String m2(label) => "Delete current ${label}?";

  static String m3(label) => "${label} cannot be empty";

  static String m4(label) => "${label} already exists";

  static String m5(count) =>
      "${Intl.plural(count, one: 'hour', other: 'hours')}";

  static String m6(count) => "${count}";

  static String m7(count) =>
      "${Intl.plural(count, one: 'minute', other: 'minutes')}";

  static String m8(count) =>
      "${Intl.plural(count, one: 'month', other: 'months')}";

  static String m9(label) => "No ${label}";

  static String m10(label) => "${label} must be a number";

  static String m11(label) =>
      "${label} must be between 1024 and 49151, 0 to disable";

  static String m12(statusCode) =>
      "Failed to import profile. Please check your network status or try resetting the subscription link ( HTTP error code: ${statusCode} )";

  static String m13(count) => "${count} items selected";

  static String m14(label) => "${label} must be a URL";

  static String m15(count) =>
      "${Intl.plural(count, one: 'year', other: 'years')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access Control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only route selected apps through VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Configure per-app access allowlist/blocklist",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Exclude selected apps from VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Switch Mode"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("System Proxy"),
    "action_start": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "activeGoroutines": MessageLookupByLibrary.simpleMessage("Goroutines"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add Rule"),
    "addTunnel": MessageLookupByLibrary.simpleMessage("Add Forwarding"),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage(
      "Append to Original Rules",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Admin Auto-Launch",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Auto-start with admin privileges",
    ),
    "advancedSettings": MessageLookupByLibrary.simpleMessage(
      "Advanced Settings",
    ),
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "Age Key Generation",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "X25519 Key pair generated, please keep it safe",
    ),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage(
      "Age Private Key",
    ),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a correct Age private key first",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage("Age Public Key"),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid Age secret key (must start with AGE-SECRET-KEY-)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage(
      "Age Secret Key (Optional)",
    ),
    "ago": MessageLookupByLibrary.simpleMessage(" ago"),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allApps": MessageLookupByLibrary.simpleMessage("All Apps"),
    "allocatedMemory": MessageLookupByLibrary.simpleMessage("Allocated"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("Allow Bypassing VPN"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Allow specific apps to bypass VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow LAN access to proxy",
    ),
    "alreadyInWhitelist": MessageLookupByLibrary.simpleMessage(
      "Already in whitelist",
    ),
    "alwaysShowTitleBar": MessageLookupByLibrary.simpleMessage("Title Buttons"),
    "alwaysShowTitleBarDesc": MessageLookupByLibrary.simpleMessage(
      "Always show the title bar buttons in the top-right corner",
    ),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App Access Control",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage("App-related settings"),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Modify application settings",
    ),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto Check Updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Check updates on app launch",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto-Close Connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Close connections when switching nodes",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto Launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Launch on system startup",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto Run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Connect on app launch",
    ),
    "autoScroll": MessageLookupByLibrary.simpleMessage("Auto Scroll"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto Set System DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto Update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto update interval (min)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Backup & Restore",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or locally",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup Successful"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Core Configuration"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Global core settings",
    ),
    "batteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Battery Optimization",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Request battery optimization whitelist",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklist": MessageLookupByLibrary.simpleMessage("Blacklist"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist Mode"),
    "blockComment": MessageLookupByLibrary.simpleMessage("Comment"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass Domain"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Active only when System Proxy is on",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Bypass Private Network",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Automatically bypass private network IP addresses",
    ),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Cache Algorithm"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Cache corrupted. Clear it?",
    ),
    "cameraPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Camera Permission Denied",
    ),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Camera permission is required to scan QR codes. Please grant it in settings.",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Show System Apps",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Deselect All"),
    "categoryAi": MessageLookupByLibrary.simpleMessage("AI"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("All"),
    "categoryChina": MessageLookupByLibrary.simpleMessage("China Direct"),
    "categoryCrypto": MessageLookupByLibrary.simpleMessage("Crypto"),
    "categoryDeveloper": MessageLookupByLibrary.simpleMessage("Developer"),
    "categoryGaming": MessageLookupByLibrary.simpleMessage("Gaming Center"),
    "categorySocial": MessageLookupByLibrary.simpleMessage("Social Platforms"),
    "categoryStreaming": MessageLookupByLibrary.simpleMessage("Streaming"),
    "chasingDots": MessageLookupByLibrary.simpleMessage("Chasing Dots"),
    "checkError": MessageLookupByLibrary.simpleMessage("Check Failed"),
    "checkFailed": MessageLookupByLibrary.simpleMessage("Timeout"),
    "checkOrAddProfile": MessageLookupByLibrary.simpleMessage(
      "Please add a profile first",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for Updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Already on the latest version",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "circle": MessageLookupByLibrary.simpleMessage("Circle"),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Clear FakeIP and DNS cache?",
    ),
    "clearCacheTitle": MessageLookupByLibrary.simpleMessage("Clear Cache"),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear Data"),
    "clearDataTipDesc": MessageLookupByLibrary.simpleMessage(
      "This operation will reset the application. Please make backups. Are you sure you want to continue?",
    ),
    "clearDataTipTitle": MessageLookupByLibrary.simpleMessage(
      "Dangerous Operation",
    ),
    "clipboard": MessageLookupByLibrary.simpleMessage("Clipboard"),
    "clipboardDesc": MessageLookupByLibrary.simpleMessage(
      "Get profile link from clipboard",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Export to Clipboard",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Import from Clipboard",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeAll": MessageLookupByLibrary.simpleMessage("Close All"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color Schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatible Mode"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling this mode may limit some features, but provides full Clash support",
    ),
    "concurrencyLimit": MessageLookupByLibrary.simpleMessage(
      "Concurrency Limit",
    ),
    "concurrencyLimitDesc": MessageLookupByLibrary.simpleMessage(
      "Maximum concurrent delay tests",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "connection": MessageLookupByLibrary.simpleMessage("Active"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View active connections",
    ),
    "connectionsSort": MessageLookupByLibrary.simpleMessage("Connections Sort"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity:"),
    "contactMe": MessageLookupByLibrary.simpleMessage("Contact Me"),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "continent": MessageLookupByLibrary.simpleMessage("Continent"),
    "controlSecret": MessageLookupByLibrary.simpleMessage("Control Secret"),
    "controlSecretDesc": MessageLookupByLibrary.simpleMessage(
      "RESTful API access password",
    ),
    "copiedPackageName": MessageLookupByLibrary.simpleMessage(
      "Copied package name",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy Environment Variable",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copy Successful"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreConnected": MessageLookupByLibrary.simpleMessage("Connected"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Core Info"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core Status"),
    "coreSuspended": MessageLookupByLibrary.simpleMessage("Suspended"),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "countryOrRegion": MessageLookupByLibrary.simpleMessage("Country / Region"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash Test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation Time"),
    "cubeGrid": MessageLookupByLibrary.simpleMessage("Cube Grid"),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "Custom Dashboard Title",
    ),
    "customScriptOptions": MessageLookupByLibrary.simpleMessage(
      "Custom Rule Switch",
    ),
    "customUrl": MessageLookupByLibrary.simpleMessage("Custom URL"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dancingSquare": MessageLookupByLibrary.simpleMessage("Dancing Square"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "darkIcon": MessageLookupByLibrary.simpleMessage("Dark Icon"),
    "darkIconDesc": MessageLookupByLibrary.simpleMessage(
      "Manually switch dark app icon",
    ),
    "dashboard": MessageLookupByLibrary.simpleMessage("Home"),
    "days": m0,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default Nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve DNS servers",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("Default Sort"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayAnimation": MessageLookupByLibrary.simpleMessage("Delay Animation"),
    "delayAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Customize animation during delay testing",
    ),
    "delaySort": MessageLookupByLibrary.simpleMessage("Sort by Delay"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m1,
    "deleteTip": m2,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage("Delete Forwarding"),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettbox is based on the powerful and flexible Mihomo (Clash.Meta) proxy kernel, dedicated to a superior user experience. Our vision: Connecting Open Source and AI, Accelerating Innovation",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IP ASN",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Third-party API result (for reference only)",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer Mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "dialerIp4pConvert": MessageLookupByLibrary.simpleMessage(
      "Enable Dialer IP4P Conversion",
    ),
    "dialerIp4pConvertDesc": MessageLookupByLibrary.simpleMessage(
      "Enable dialer IP4P address conversion feature",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "directNameserver": MessageLookupByLibrary.simpleMessage(
      "Direct Nameserver",
    ),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve direct domains",
    ),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "Direct DNS Follows Policy",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("Disable QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC to resolve specific network issues",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This free open-source software is for non-commercial learning and personal use only. Proxy services are independent of this software. By agreeing, you acknowledge this; otherwise, please exit.",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New Version Available",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage("New Version Found"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("DNS-related settings"),
    "dnsHijack": MessageLookupByLibrary.simpleMessage("DNS Hijack"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Redirect DNS queries to internal DNS module",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS Mode"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Do you want to pass",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Organization / Domain"),
    "doubleBounce": MessageLookupByLibrary.simpleMessage("Double Bounce"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "dozeSuspend": MessageLookupByLibrary.simpleMessage("Doze Support"),
    "dozeSuspendDesc": MessageLookupByLibrary.simpleMessage(
      "Sync with system Doze mode",
    ),
    "dualRing": MessageLookupByLibrary.simpleMessage("Dual Ring"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("Edit Forwarding"),
    "emptyTip": m3,
    "enableCrashReport": MessageLookupByLibrary.simpleMessage(
      "Crash Analytics",
    ),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "Upload crash logs when needed",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage("Enable Override"),
    "enableTraySpeed": MessageLookupByLibrary.simpleMessage("Tray Speed"),
    "enableTraySpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Display upload and download rates in the menu bar",
    ),
    "endpointIndependentNat": MessageLookupByLibrary.simpleMessage(
      "NAT Enhancement",
    ),
    "endpointIndependentNatConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling Endpoint-Independent NAT feature may slightly degrade performance. It is recommended to enable it only if necessary and you are familiar with it.",
    ),
    "endpointIndependentNatDesc": MessageLookupByLibrary.simpleMessage(
      "Optimize UDP/P2P application experience",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from Recents"),
    "excludeChina": MessageLookupByLibrary.simpleMessage("Exclude China"),
    "excludeChinaDesc": MessageLookupByLibrary.simpleMessage(
      "Allow China QUIC traffic instead of blocking all",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide app from recent tasks list",
    ),
    "existsTip": m4,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "experimental": MessageLookupByLibrary.simpleMessage("Experimental"),
    "experimentalDesc": MessageLookupByLibrary.simpleMessage(
      "Use with caution",
    ),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Expiration Time"),
    "expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "export": MessageLookupByLibrary.simpleMessage("Export"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export File"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export Logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export Successful"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "External Controller",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Control core via online port",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("External Link"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "External Resources",
    ),
    "fadingCircle": MessageLookupByLibrary.simpleMessage("Fading Circle"),
    "fadingCube": MessageLookupByLibrary.simpleMessage("Fading Cube"),
    "fadingFour": MessageLookupByLibrary.simpleMessage("Fading Four"),
    "fadingGrid": MessageLookupByLibrary.simpleMessage("Fading Grid"),
    "fakeIpFilterMode": MessageLookupByLibrary.simpleMessage(
      "FakeIP Filter Mode",
    ),
    "fakeIpFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Specify FakeIP filter mode",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("FakeIP Filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("FakeIP Range"),
    "fakeipRangeV6": MessageLookupByLibrary.simpleMessage("FakeIPv6 Range"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("FakeIP TTL"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackConcurrent": MessageLookupByLibrary.simpleMessage(
      "Fallback Concurrent",
    ),
    "fallbackConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Query default DNS and Fallback synchronously",
    ),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Usually offshore DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback Filter"),
    "fcmOptimization": MessageLookupByLibrary.simpleMessage("FCM Optimization"),
    "fcmOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Enhance FCM connection stability",
    ),
    "fcmTip": MessageLookupByLibrary.simpleMessage(
      "FCM connection and support depend on the device itself, the results are for reference only. Due to system permission reasons, you need to disable \"Allow bypass VPN\" in settings to get accurate results",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Upload profile file"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "File modified. Save changes?",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Filter System Apps",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find Process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Enable process matching",
    ),
    "flagged": MessageLookupByLibrary.simpleMessage("Flagged"),
    "foldingCube": MessageLookupByLibrary.simpleMessage("Folding Cube"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Force DNS Mapping",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Force mapping DNS results to connections",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Force Sniff Domain"),
    "forceGCDesc": MessageLookupByLibrary.simpleMessage(
      "Force kernel garbage collection? Experimental, use with caution.",
    ),
    "forceGCTitle": MessageLookupByLibrary.simpleMessage(
      "Force Garbage Collection",
    ),
    "formatError": MessageLookupByLibrary.simpleMessage(
      "Please check the format",
    ),
    "fourColumns": MessageLookupByLibrary.simpleMessage("4 Columns"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Fruit Salad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "Modify global settings",
    ),
    "generateFromPrivateKey": MessageLookupByLibrary.simpleMessage(
      "Generate from private key",
    ),
    "generateSecret": MessageLookupByLibrary.simpleMessage("Generate"),
    "geoData": MessageLookupByLibrary.simpleMessage("GeoData"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage("GEO Low Memory"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Use GEO low memory loader",
    ),
    "geodataUse": MessageLookupByLibrary.simpleMessage("GEO Load"),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIP Code"),
    "getOriginRules": MessageLookupByLibrary.simpleMessage("Original Rules"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download Now"),
    "harmonyFont": MessageLookupByLibrary.simpleMessage("Font Fix"),
    "harmonyFontDesc": MessageLookupByLibrary.simpleMessage(
      "Use built-in font to fix display issues",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Cache modifications?",
    ),
    "healthCheckTimeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "healthCheckTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Node health check timeout",
    ),
    "heapObjects": MessageLookupByLibrary.simpleMessage("Objects"),
    "highPriority": MessageLookupByLibrary.simpleMessage("High Priority"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "Increase priority of main process and core process",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage(
      "High Refresh Rate",
    ),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "Enable highest refresh rate support",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage(
      "Append hosts to current config",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey Conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Control app via keyboard",
    ),
    "hourGlass": MessageLookupByLibrary.simpleMessage("Hourglass"),
    "hours": m5,
    "httpPortSniffer": MessageLookupByLibrary.simpleMessage(
      "HTTP Port Sniffing",
    ),
    "icmpForwarding": MessageLookupByLibrary.simpleMessage("ICMP Forwarding"),
    "icmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "Enable ICMP Ping",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "Icon Configuration",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon Style"),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFailed": MessageLookupByLibrary.simpleMessage("Import failed"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from File"),
    "importFromCode": MessageLookupByLibrary.simpleMessage("Import from Code"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never Expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Enter a valid hotkey",
    ),
    "installTime": MessageLookupByLibrary.simpleMessage("Install Time"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Smart Select"),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Local IP"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid IP or CIDR format",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP Address"),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage("Toggle Display"),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage(
      "Hide IP Display",
    ),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Enable IPv6 traffic routing",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "isp": MessageLookupByLibrary.simpleMessage("ISP"),
    "itemsCount": m6,
    "just": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lastEdit": MessageLookupByLibrary.simpleMessage("Last edited"),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "leftClickBehavior": MessageLookupByLibrary.simpleMessage("Left Click"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "limitedUnlock": MessageLookupByLibrary.simpleMessage("Originals Only"),
    "lineWrap": MessageLookupByLibrary.simpleMessage("Wrap Lines"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup data locally",
    ),
    "localFile": MessageLookupByLibrary.simpleMessage("Local File"),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from file",
    ),
    "locate": MessageLookupByLibrary.simpleMessage("Locate"),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log Level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Log Capture"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Show log capture entry",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("View captured logs"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs Test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback Unlock"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "UWP loopback unlocking tool",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("Refresh IP"),
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "mediaUnlock": MessageLookupByLibrary.simpleMessage("Connectivity Test"),
    "mediaUnlockColorfulIcons": MessageLookupByLibrary.simpleMessage(
      "Show colored icons by default",
    ),
    "mediaUnlockDetails": MessageLookupByLibrary.simpleMessage(
      "Connectivity Test Details",
    ),
    "mediaUnlockDisplaySettings": MessageLookupByLibrary.simpleMessage(
      "Display Settings",
    ),
    "mediaUnlockExtraDetails": MessageLookupByLibrary.simpleMessage(
      "Show more IP details",
    ),
    "mediaUnlockMiscSettings": MessageLookupByLibrary.simpleMessage(
      "Misc Settings",
    ),
    "mediaUnlockPinnedSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Select up to 4 items to pin on the widget",
    ),
    "mediaUnlockRefreshByCategory": MessageLookupByLibrary.simpleMessage(
      "Partially refresh based on current category",
    ),
    "mediaUnlockRefreshOnNodeChange": MessageLookupByLibrary.simpleMessage(
      "Auto refresh on node change",
    ),
    "mediaUnlockSelectLimit": MessageLookupByLibrary.simpleMessage(
      "You can select up to 4 items",
    ),
    "mediaUnlocked": MessageLookupByLibrary.simpleMessage("Unlocked"),
    "memoryAndRuntime": MessageLookupByLibrary.simpleMessage(
      "Memory & Runtime",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "The current memory information value displayed is the dynamic stack memory usage of the core during runtime, not the complete APP memory statistics, for reference only.",
    ),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message Test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on Exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Override default exit behavior",
    ),
    "minutes": m7,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "months": m8,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage("More IP Information"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameSort": MessageLookupByLibrary.simpleMessage("Sort by Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve domains",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver Policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify domain-specific nameservers",
    ),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "Haptic Feedback",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Vibrate on navigation tab switch",
    ),
    "navConnections": MessageLookupByLibrary.simpleMessage("Active"),
    "navTools": MessageLookupByLibrary.simpleMessage("More"),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Modify network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage("Network"),
    "networkErrorRetryLater": MessageLookupByLibrary.simpleMessage(
      "Network error, please try again later",
    ),
    "networkFix": MessageLookupByLibrary.simpleMessage("Network Fix"),
    "networkFixDesc": MessageLookupByLibrary.simpleMessage(
      "Fix system network globe icon issue",
    ),
    "networkMatch": MessageLookupByLibrary.simpleMessage("Network Match"),
    "networkMatchHint": MessageLookupByLibrary.simpleMessage(
      "Enter IP, CIDR or Gateway:IP/CIDR",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network Speed"),
    "networkSpeedNotification": MessageLookupByLibrary.simpleMessage(
      "Speed in Notification",
    ),
    "networkSpeedNotificationDesc": MessageLookupByLibrary.simpleMessage(
      "Show speed and subscription info in notification bar",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Network Type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "noAnimation": MessageLookupByLibrary.simpleMessage("Default"),
    "noData": MessageLookupByLibrary.simpleMessage("No Data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No Hotkeys"),
    "noIcon": MessageLookupByLibrary.simpleMessage("No Icon"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No Info"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("No more info"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No Network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No Network App"),
    "noProxy": MessageLookupByLibrary.simpleMessage("No Proxy"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Please create or add a valid profile",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("No Resolve"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage("No Status"),
    "noUsageData": MessageLookupByLibrary.simpleMessage("No usage data"),
    "nodeExclusion": MessageLookupByLibrary.simpleMessage("Node Exclusion"),
    "nodeExclusionDesc": MessageLookupByLibrary.simpleMessage(
      "Exclude all matched nodes",
    ),
    "nodeExclusionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "HK|Hong Kong|🇭🇰",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notRecommended": MessageLookupByLibrary.simpleMessage("Not Recommended"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Current proxy group cannot be selected.",
    ),
    "notUnlocked": MessageLookupByLibrary.simpleMessage("Not Unlocked"),
    "notificationHighPriority": MessageLookupByLibrary.simpleMessage(
      "High Priority",
    ),
    "notificationHighPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust current notification bar to foreground high priority",
    ),
    "notificationHighPriorityTip": MessageLookupByLibrary.simpleMessage(
      "High-priority notifications can alleviate background core keep-alive issues on some customized systems. If your VPN service is currently running normally, it is recommended to keep this option disabled. Are you sure you want to enable it?",
    ),
    "ntp": MessageLookupByLibrary.simpleMessage("NTP"),
    "ntpDesc": MessageLookupByLibrary.simpleMessage("Use NTP time service"),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("Update Interval"),
    "ntpPort": MessageLookupByLibrary.simpleMessage("Port"),
    "ntpServer": MessageLookupByLibrary.simpleMessage("Server"),
    "ntpStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Enable NTP time service",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profile. Please add one.",
    ),
    "nullTip": m9,
    "numberTip": m10,
    "oneColumn": MessageLookupByLibrary.simpleMessage("1 Column"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("Online Panel"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon Only"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "Third-Party Apps Only",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Proxy Traffic Only",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Only record proxy traffic",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("Open Zashboard"),
    "openSettings": MessageLookupByLibrary.simpleMessage("Open Settings"),
    "operatorOrAsn": MessageLookupByLibrary.simpleMessage("Organization / ASN"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other Contributors (Random Order)",
    ),
    "otherSettings": MessageLookupByLibrary.simpleMessage("Enhanced Tools"),
    "otherSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Modify enhanced tool settings",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound Mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "Override proxy configurations",
    ),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Override Destination",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Override destination with sniffed result",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Override profile\'s DNS settings",
    ),
    "overrideExperimental": MessageLookupByLibrary.simpleMessage(
      "Override Experimental",
    ),
    "overrideExperimentalDesc": MessageLookupByLibrary.simpleMessage(
      "Override profile\'s Experimental settings",
    ),
    "overrideInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Inactive in script mode",
    ),
    "overrideNtp": MessageLookupByLibrary.simpleMessage("Override NTP"),
    "overrideNtpDesc": MessageLookupByLibrary.simpleMessage(
      "Override profile\'s NTP settings",
    ),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage(
      "Override Original Rules",
    ),
    "overrideSniffer": MessageLookupByLibrary.simpleMessage("Override Sniffer"),
    "overrideSnifferDesc": MessageLookupByLibrary.simpleMessage(
      "Override profile\'s Sniffer settings",
    ),
    "overrideTestUrl": MessageLookupByLibrary.simpleMessage("Override Config"),
    "overrideTunnel": MessageLookupByLibrary.simpleMessage("Override Tunnel"),
    "overrideTunnelDesc": MessageLookupByLibrary.simpleMessage(
      "Override profile\'s Tunnel settings",
    ),
    "packageListPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permission denied. Cannot access app list.",
    ),
    "packageListPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Permission to access installed apps is required. Grant now?",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Parse Pure IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Parse pure IP connections",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pianoWave": MessageLookupByLibrary.simpleMessage("Piano Wave"),
    "pin": MessageLookupByLibrary.simpleMessage("Pin"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseCloseSystemProxyFirst": MessageLookupByLibrary.simpleMessage(
      "Please close System Proxy first",
    ),
    "pleaseCloseTunFirst": MessageLookupByLibrary.simpleMessage(
      "Please close TUN first",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter the admin password",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "Please upload a file",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m11,
    "pouringHourGlass": MessageLookupByLibrary.simpleMessage(
      "Pouring Hourglass",
    ),
    "pouringHourGlassRefined": MessageLookupByLibrary.simpleMessage(
      "Refined Hourglass",
    ),
    "powerSwitch": MessageLookupByLibrary.simpleMessage("Power"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prioritize DoH HTTP/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Press a key"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "privateIp": MessageLookupByLibrary.simpleMessage(
      "Private / LAN IP Address",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAndRules": MessageLookupByLibrary.simpleMessage("Profile & Rules"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter update interval"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Profile modified. Disable auto-update?",
    ),
    "profileImportFailed": m12,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a profile name",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "Profile parse error",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Profile Sorting"),
    "progress": MessageLookupByLibrary.simpleMessage("Progress"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("Providers"),
    "provinceAndCity": MessageLookupByLibrary.simpleMessage("Province / City"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Proxy Settings"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy Chains"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy Group"),
    "proxyGroupsCount": MessageLookupByLibrary.simpleMessage("Proxy Groups"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy Nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve proxy nodes",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("Proxy Port"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Set the Clash listening port",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy Providers"),
    "proxyProvidersCount": MessageLookupByLibrary.simpleMessage(
      "Proxy Providers",
    ),
    "pulse": MessageLookupByLibrary.simpleMessage("Pulse"),
    "pulsingGrid": MessageLookupByLibrary.simpleMessage("Pulsing Grid"),
    "pumpingHeart": MessageLookupByLibrary.simpleMessage("Pumping Heart"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure Black Mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR Code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan QR code to import profile",
    ),
    "quicGoDisableEcn": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC ECN",
    ),
    "quicGoDisableEcnDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC Explicit Congestion Notification",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC GSO",
    ),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC Generic Segmentation Offload",
    ),
    "quicPortSniffer": MessageLookupByLibrary.simpleMessage(
      "QUIC Port Sniffing",
    ),
    "quickResponse": MessageLookupByLibrary.simpleMessage("Quick Response"),
    "quickResponseDesc": MessageLookupByLibrary.simpleMessage(
      "Disconnect on network change (WiFi/Mobile)",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "realTimeSpeed": MessageLookupByLibrary.simpleMessage("Real-time Speed"),
    "reclaimableMemory": MessageLookupByLibrary.simpleMessage("Reclaimable"),
    "recovery": MessageLookupByLibrary.simpleMessage("Restore"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Restore All Data"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Restore Profiles Only",
    ),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "Recovery Strategy",
    ),
    "recoveryStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "recoveryStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Override",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage(
      "Restore Successful",
    ),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir Port"),
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "refreshAppList": MessageLookupByLibrary.simpleMessage("Refresh App List"),
    "refreshAppListConfirm": MessageLookupByLibrary.simpleMessage(
      "Refresh the app list?",
    ),
    "regExp": MessageLookupByLibrary.simpleMessage("RegExp"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote Destination",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "replace": MessageLookupByLibrary.simpleMessage("Replace"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Replace All"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recent request logs",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "External resource info",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect Rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connections follow Rules",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartApp": MessageLookupByLibrary.simpleMessage("Restart App"),
    "restartCoreDesc": MessageLookupByLibrary.simpleMessage(
      "Manually restart the core?",
    ),
    "restartCoreTitle": MessageLookupByLibrary.simpleMessage("Restart Core"),
    "restartTip": MessageLookupByLibrary.simpleMessage(
      "Restart TUN for changes to take effect",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "rightClickBehavior": MessageLookupByLibrary.simpleMessage("Right Click"),
    "ring": MessageLookupByLibrary.simpleMessage("Ring"),
    "ripple": MessageLookupByLibrary.simpleMessage("Ripple"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("Rotating Circle"),
    "rotatingPlain": MessageLookupByLibrary.simpleMessage("Rotating Plain"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule Name"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule Providers"),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage(
      "Rule Providers",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule Target"),
    "rulesCount": MessageLookupByLibrary.simpleMessage("Rules"),
    "runTime": MessageLookupByLibrary.simpleMessage("Uptime"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("Runtime Config"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save changes?"),
    "saveTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "Global override script config",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "Secret copied to clipboard",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m13,
    "serviceReady": MessageLookupByLibrary.simpleMessage("Service Ready"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage("Service Running"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showHiddenItems": MessageLookupByLibrary.simpleMessage(
      "Show Hidden Items",
    ),
    "showMenu": MessageLookupByLibrary.simpleMessage("Open Menu"),
    "showPanel": MessageLookupByLibrary.simpleMessage("Show Window"),
    "showStartSwitch": MessageLookupByLibrary.simpleMessage("Linkage Switch"),
    "showStartSwitchDesc": MessageLookupByLibrary.simpleMessage(
      "Display independent switch button on the homepage",
    ),
    "shrink": MessageLookupByLibrary.simpleMessage("Compact"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent Launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Skip Domain"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Skip Destination IP",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("Skip Source IP"),
    "smartAutoStop": MessageLookupByLibrary.simpleMessage("Smart Auto-Stop"),
    "smartAutoStopDesc": MessageLookupByLibrary.simpleMessage(
      "Stop VPN on specific networks",
    ),
    "smartAutoStopServiceRunning": MessageLookupByLibrary.simpleMessage(
      "Smart Auto-Stop running",
    ),
    "smartDelayLaunch": MessageLookupByLibrary.simpleMessage("Smart Delay"),
    "smartDelayLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Launch after network connected",
    ),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferAddressHint": MessageLookupByLibrary.simpleMessage(
      "One address per line",
    ),
    "snifferDesc": MessageLookupByLibrary.simpleMessage(
      "Modify domain sniffer config",
    ),
    "snifferDomainHint": MessageLookupByLibrary.simpleMessage(
      "One domain per line",
    ),
    "snifferPorts": MessageLookupByLibrary.simpleMessage("Ports"),
    "snifferPortsHint": MessageLookupByLibrary.simpleMessage(
      "e.g.: 80, 8080-8880",
    ),
    "snifferStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Enable Sniffer service",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks Port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special Proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Special Rules"),
    "spinningCircle": MessageLookupByLibrary.simpleMessage("Spinning Circle"),
    "spinningLines": MessageLookupByLibrary.simpleMessage("Spinning Lines"),
    "squareCircle": MessageLookupByLibrary.simpleMessage("Square Circle"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack Mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startTest": MessageLookupByLibrary.simpleMessage("Delay Test"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting..."),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Uses system DNS when disabled",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping..."),
    "storeFix": MessageLookupByLibrary.simpleMessage("Store Fix"),
    "storeFixDesc": MessageLookupByLibrary.simpleMessage(
      "Fix Play Store download issues",
    ),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Strict Route"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Use TUN strict routing mode",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub Rule"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "switchLabel": MessageLookupByLibrary.simpleMessage("Switch"),
    "switchToDomesticIp": MessageLookupByLibrary.simpleMessage(
      "Get Domestic IP",
    ),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "syncAll": MessageLookupByLibrary.simpleMessage("Sync All"),
    "syncFailed": MessageLookupByLibrary.simpleMessage("Sync Failed"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System App"),
    "systemFont": MessageLookupByLibrary.simpleMessage("System Font"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System Proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("Set system proxy"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP Concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Allow concurrent TCP connections",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "testing": MessageLookupByLibrary.simpleMessage("Testing"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text Scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme Color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set theme color and icon",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "threeBounce": MessageLookupByLibrary.simpleMessage("Three Bounce"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("3 Columns"),
    "threeInOut": MessageLookupByLibrary.simpleMessage("Three In Out"),
    "tight": MessageLookupByLibrary.simpleMessage("Compact"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "titleTooLong": MessageLookupByLibrary.simpleMessage(
      "Title is too long, maximum 20 characters supported",
    ),
    "tlsPortSniffer": MessageLookupByLibrary.simpleMessage("TLS Port Sniffing"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Tonal Spot"),
    "tooManyRules": MessageLookupByLibrary.simpleMessage("Max 5 rules allowed"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total Traffic"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy Port"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic Usage"),
    "trayClickBehavior": MessageLookupByLibrary.simpleMessage(
      "Tray Click Behavior",
    ),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("Tray Enhancement"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "Control proxy groups in system tray menu",
    ),
    "trayIconInvert": MessageLookupByLibrary.simpleMessage("Invert Tray Icon"),
    "trayIconInvertDesc": MessageLookupByLibrary.simpleMessage(
      "Invert the current tray icon color",
    ),
    "tryManualRefresh": MessageLookupByLibrary.simpleMessage(
      "Please try manual refresh",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Use TUN to take over device traffic",
    ),
    "tunEnableRequireAdmin": MessageLookupByLibrary.simpleMessage(
      "Enabling the TUN virtual network adapter requires Administrator or ROOT privileges.",
    ),
    "tunVirtualAddress": MessageLookupByLibrary.simpleMessage(
      "TUN Virtual Network Adapter",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("Tunnel"),
    "tunnelAddress": MessageLookupByLibrary.simpleMessage("Listen Address"),
    "tunnelAddressHint": MessageLookupByLibrary.simpleMessage(
      "e.g.: 127.0.0.1:6553",
    ),
    "tunnelDesc": MessageLookupByLibrary.simpleMessage(
      "Use traffic forwarding tunnel",
    ),
    "tunnelList": MessageLookupByLibrary.simpleMessage("Forwarding List"),
    "tunnelNetwork": MessageLookupByLibrary.simpleMessage("Network Protocol"),
    "tunnelNetworkHint": MessageLookupByLibrary.simpleMessage("e.g.: tcp, udp"),
    "tunnelProxy": MessageLookupByLibrary.simpleMessage("Proxy Name"),
    "tunnelProxyHint": MessageLookupByLibrary.simpleMessage(
      "e.g.: proxy (optional)",
    ),
    "tunnelTarget": MessageLookupByLibrary.simpleMessage("Target Address"),
    "tunnelTargetHint": MessageLookupByLibrary.simpleMessage(
      "e.g.: 114.114.114.114:53",
    ),
    "tvScanImport": MessageLookupByLibrary.simpleMessage("Scan / LAN Import"),
    "tvScanImportDesc": MessageLookupByLibrary.simpleMessage(
      "Scan QR or push profile to TV via LAN",
    ),
    "tvScanManualUrl": MessageLookupByLibrary.simpleMessage(
      "Or enter directly in phone browser:",
    ),
    "tvScanNoNetwork": MessageLookupByLibrary.simpleMessage(
      "No available LAN detected, please check Wi-Fi",
    ),
    "tvScanStep1": MessageLookupByLibrary.simpleMessage(
      "Ensure phone and TV are on the same Wi-Fi network",
    ),
    "tvScanStep2": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code with a supported camera or browser",
    ),
    "tvScanStep3": MessageLookupByLibrary.simpleMessage(
      "Paste subscription URL or upload profile on the webpage and push",
    ),
    "tvScanSuccess": MessageLookupByLibrary.simpleMessage(
      "Profile received, importing...",
    ),
    "tvScanWaiting": MessageLookupByLibrary.simpleMessage(
      "Waiting for profile from phone...",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("2 Columns"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Unable to update current profile",
    ),
    "unauthorized": MessageLookupByLibrary.simpleMessage("Unauthorized"),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified Delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Exclude handshake delays from testing",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unlocked": MessageLookupByLibrary.simpleMessage("Completed"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unpin": MessageLookupByLibrary.simpleMessage("Unpin"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateTime": MessageLookupByLibrary.simpleMessage("Update Time"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("Get profile via URL"),
    "urlTip": m14,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "Use Global Script Override",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Use Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use System Hosts"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "viewDetailedIpData": MessageLookupByLibrary.simpleMessage(
      "View Detailed IP Data",
    ),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("VPN-related settings"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Route system traffic via VpnService",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Attach HTTP proxy to VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Restart VPN to apply changes",
    ),
    "wakelock": MessageLookupByLibrary.simpleMessage("Wakelock"),
    "wakelockDescription": MessageLookupByLibrary.simpleMessage(
      "Keeps the screen on and app active in the background without requiring special CPU wakelock permissions.",
    ),
    "wanderingCubes": MessageLookupByLibrary.simpleMessage("Wandering Cubes"),
    "wave": MessageLookupByLibrary.simpleMessage("Wave"),
    "waveSpinner": MessageLookupByLibrary.simpleMessage("Wave Spinner"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV Configuration",
    ),
    "whitelist": MessageLookupByLibrary.simpleMessage("Whitelist"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist Mode"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Write to System"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Requires administrator privileges",
    ),
    "years": m15,
  };
}
