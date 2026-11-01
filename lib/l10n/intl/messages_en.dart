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

  static String m0(log) => "Analyze Bettbox (Mihomo) log: ${log}";

  static String m1(error) => "Auto backup failed: ${error}";

  static String m2(value) => "Avg ${value}";

  static String m3(count) => "${Intl.plural(count, one: 'day', other: 'days')}";

  static String m4(label) => "Delete selected ${label}?";

  static String m5(label) => "Delete current ${label}?";

  static String m6(reason) => "Fake-IP · ${reason}: returns the real IP";

  static String m7(reason, range) =>
      "Fake-IP · ${reason}: returns a virtual address from ${range}";

  static String m8(ips) => "Matched Hosts: returns ${ips}";

  static String m9(outbound) =>
      "Via \"${outbound}\", the node resolves the domain";

  static String m10(outbound) =>
      "Via \"${outbound}\", the node resolves the domain; Hosts not applied";

  static String m11(label) => "${label} cannot be empty";

  static String m12(label) => "${label} already exists";

  static String m13(count) =>
      "${Intl.plural(count, one: 'hour', other: 'hours')}";

  static String m14(port) => "Port ${port} is already in use. Try another port";

  static String m15(code) => "The server rejected the test (error ${code})";

  static String m16(lost, total) => "${lost}/${total} packets";

  static String m17(name) => "Scanned: ${name}";

  static String m18(value) => "${value} s";

  static String m19(port) => "Listening on port ${port}";

  static String m20(count) => "${count} streams";

  static String m21(count) => "${count}";

  static String m22(count) => "${count} bytes";

  static String m23(address) => "From ${address}";

  static String m24(count) =>
      "Showing the latest ${count}. Copy the result to see all";

  static String m25(min, avg, max, jitter) =>
      "Round trip: min ${min} / avg ${avg} / max ${max} / jitter ${jitter} ms";

  static String m26(target) => "Ping statistics for ${target}";

  static String m27(sent, received, lost, loss) =>
      "Sent ${sent}, received ${received}, lost ${lost} (${loss}% loss)";

  static String m28(level) =>
      "${level} mode is for network debugging; turn it off for daily use";

  static String m29(done, total, unlocked) =>
      "${done}/${total} tested · ${unlocked} available";

  static String m30(count) =>
      "${Intl.plural(count, one: 'minute', other: 'minutes')}";

  static String m31(count) =>
      "${Intl.plural(count, one: 'month', other: 'months')}";

  static String m32(count) => "${count} entries";

  static String m33(ip) => "via ${ip}";

  static String m34(count) => "${count} new logs";

  static String m35(label) => "No ${label}";

  static String m36(min, max) => "Enter a whole number from ${min} to ${max}";

  static String m37(label) => "${label} must be a number";

  static String m38(label) => "Only ${label}";

  static String m39(label) =>
      "${label} must be between 1024 and 49151, 0 to disable";

  static String m40(statusCode) =>
      "Failed to import profile. Please check your network status or try resetting the subscription link ( HTTP error code: ${statusCode} )";

  static String m41(index, time) => "Resolved by rule #${index} · ${time} ms";

  static String m42(ips) => "Hosts hit: ${ips}";

  static String m43(total, index) => "${total} rules, matched #${index}";

  static String m44(total) => "${total} rules";

  static String m45(count) => "${count} items selected";

  static String m46(count) =>
      "Multi uses ${count} parallel connections to saturate bandwidth";

  static String m47(provider) =>
      "The outbound may be blocking ${provider} speed tests. Switch the test source or the outbound.";

  static String m48(protocol, fallback) =>
      "${protocol} unavailable, fell back to ${fallback}";

  static String m49(count) => "${count} connections";

  static String m50(provider) => "Switch to ${provider}";

  static String m51(online, total) => "${online} / ${total} online";

  static String m52(region) => "Relay ${region}";

  static String m53(label) => "${label} must be a URL";

  static String m54(count) =>
      "${Intl.plural(count, one: 'year', other: 'years')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access Control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only route selected apps through VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "App allowlist and blocklist",
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
    "addUser": MessageLookupByLibrary.simpleMessage("Add User"),
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
    "ageCipherText": MessageLookupByLibrary.simpleMessage(
      "Cipher Text (-----BEGIN AGE ENCRYPTED FILE-----)",
    ),
    "ageDecryptFailed": MessageLookupByLibrary.simpleMessage(
      "Decryption failed",
    ),
    "ageEncryptFailed": MessageLookupByLibrary.simpleMessage(
      "Encryption failed",
    ),
    "ageFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "File too large (8 MB max)",
    ),
    "ageGenerateKeyPair": MessageLookupByLibrary.simpleMessage("New Key Pair"),
    "ageInputRequired": MessageLookupByLibrary.simpleMessage(
      "Enter content or choose a file",
    ),
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "Age Key Generation",
    ),
    "ageKeyHybridTip": MessageLookupByLibrary.simpleMessage(
      "Post-quantum hybrid key. Stronger, but the public key is much longer and requires age v1.3 or later.",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "X25519 Key pair generated, please keep it safe",
    ),
    "ageKeyType": MessageLookupByLibrary.simpleMessage("Key type"),
    "ageNotEncrypted": MessageLookupByLibrary.simpleMessage(
      "Content is not Age encrypted",
    ),
    "ageOutput": MessageLookupByLibrary.simpleMessage("Result"),
    "agePlainText": MessageLookupByLibrary.simpleMessage("Plain Text"),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage(
      "Age Private Key",
    ),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a correct Age private key first",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage("Age Public Key"),
    "ageRecipientRequired": MessageLookupByLibrary.simpleMessage(
      "Add at least one recipient public key",
    ),
    "ageRecipients": MessageLookupByLibrary.simpleMessage(
      "Recipient Public Keys",
    ),
    "ageRecipientsHint": MessageLookupByLibrary.simpleMessage(
      "One age1… key per line, multiple allowed",
    ),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid Age secret key (must start with AGE-SECRET-KEY-)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage(
      "Age Secret Key (Optional)",
    ),
    "ageTabDecrypt": MessageLookupByLibrary.simpleMessage("Decrypt"),
    "ageTabEncrypt": MessageLookupByLibrary.simpleMessage("Encrypt"),
    "ageTabKeys": MessageLookupByLibrary.simpleMessage("Keys"),
    "ageTool": MessageLookupByLibrary.simpleMessage("Age Encrypt / Decrypt"),
    "ageToolDesc": MessageLookupByLibrary.simpleMessage(
      "Generate keys, encrypt or decrypt text and configs",
    ),
    "ageToolTip": MessageLookupByLibrary.simpleMessage(
      "Everything runs locally. Private keys are never stored or uploaded.",
    ),
    "ageUseForEncrypt": MessageLookupByLibrary.simpleMessage("Use to Encrypt"),
    "ageUseProfileKey": MessageLookupByLibrary.simpleMessage(
      "Use Current Profile Key",
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
      "Always show top-right title bar buttons",
    ),
    "analyzeLogPrompt": m0,
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
    "autoBackup": MessageLookupByLibrary.simpleMessage("Auto Backup"),
    "autoBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Auto back up on profile changes",
    ),
    "autoBackupFailed": m1,
    "autoBackupSuccess": MessageLookupByLibrary.simpleMessage(
      "Auto backed up to WebDAV",
    ),
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
    "autoStickyHeader": MessageLookupByLibrary.simpleMessage(
      "Auto Sticky Header",
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
    "backupEncryptedTip": MessageLookupByLibrary.simpleMessage(
      "Backup encrypted with AES-256",
    ),
    "backupPassword": MessageLookupByLibrary.simpleMessage("Backup Password"),
    "backupPasswordDesc": MessageLookupByLibrary.simpleMessage(
      "AES-256 encrypted, leave blank for none",
    ),
    "backupPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "This backup is encrypted, please enter the password",
    ),
    "backupPasswordTip": MessageLookupByLibrary.simpleMessage(
      "Only English letters, digits and symbols are supported",
    ),
    "backupPasswordWrong": MessageLookupByLibrary.simpleMessage(
      "Incorrect backup password",
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
    "clearFilter": MessageLookupByLibrary.simpleMessage("Clear filters"),
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
    "collapse": MessageLookupByLibrary.simpleMessage("Collapse"),
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
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "Congestion Controller",
    ),
    "connection": MessageLookupByLibrary.simpleMessage("Active"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsActive": MessageLookupByLibrary.simpleMessage("Active"),
    "connectionsClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View active and closed connections",
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
    "coreCapabilityNotEffective": MessageLookupByLibrary.simpleMessage(
      "Core authorization did not take effect: the running core lacks CAP_NET_ADMIN, TUN may fail",
    ),
    "coreConnected": MessageLookupByLibrary.simpleMessage("Connected"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Core Info"),
    "coreMountNosuid": MessageLookupByLibrary.simpleMessage(
      "The core is on a filesystem mounted with nosuid, so file capabilities and setuid cannot take effect",
    ),
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
      "Custom Title",
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
    "dashboardAverage": m2,
    "dashboardTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "days": m3,
    "defaultGateway": MessageLookupByLibrary.simpleMessage("Gateway"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default Nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Resolve DNS servers",
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
    "deleteMultipTip": m4,
    "deleteTip": m5,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage("Delete Forwarding"),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettbox is deeply crafted on the powerful and flexible Mihomo kernel, dedicated to a superior client experience. Our vision: Connecting Open Source and AI, Accelerating Innovation",
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
      "Enable dialer IP4P conversion",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "directNameserver": MessageLookupByLibrary.simpleMessage(
      "Direct Nameserver",
    ),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Resolve direct domains",
    ),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "Direct DNS Follows Policy",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("Disable QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC to resolve specific network issues",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
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
    "dnsQuery": MessageLookupByLibrary.simpleMessage("DNS Lookup"),
    "dnsQueryCompare": MessageLookupByLibrary.simpleMessage("Compare"),
    "dnsQueryCompareDesc": MessageLookupByLibrary.simpleMessage(
      "Resolve with rules, system DNS and the chosen server side by side to spot pollution or routing differences",
    ),
    "dnsQueryDesc": MessageLookupByLibrary.simpleMessage(
      "Resolve with rules, system or a chosen server",
    ),
    "dnsQueryFakeIpOff": m6,
    "dnsQueryFakeIpOn": m7,
    "dnsQueryFilterBlackHit": MessageLookupByLibrary.simpleMessage(
      "in blacklist",
    ),
    "dnsQueryFilterBlackMiss": MessageLookupByLibrary.simpleMessage(
      "not in blacklist",
    ),
    "dnsQueryFilterRuleFake": MessageLookupByLibrary.simpleMessage(
      "rule says fake-ip",
    ),
    "dnsQueryFilterRuleReal": MessageLookupByLibrary.simpleMessage(
      "rule says real-ip",
    ),
    "dnsQueryFilterWhiteHit": MessageLookupByLibrary.simpleMessage(
      "in whitelist",
    ),
    "dnsQueryFilterWhiteMiss": MessageLookupByLibrary.simpleMessage(
      "not in whitelist",
    ),
    "dnsQueryHint": MessageLookupByLibrary.simpleMessage("Domain"),
    "dnsQueryHostsHit": m8,
    "dnsQueryNoRecords": MessageLookupByLibrary.simpleMessage("No records"),
    "dnsQueryNormalMode": MessageLookupByLibrary.simpleMessage(
      "Normal: returns the real IP, rules match by IP",
    ),
    "dnsQueryRedirHost": MessageLookupByLibrary.simpleMessage(
      "Redir-Host: returns the real IP, domain restored on connect",
    ),
    "dnsQueryServer": MessageLookupByLibrary.simpleMessage("DNS Server"),
    "dnsQueryServerHint": MessageLookupByLibrary.simpleMessage(
      "e.g. 1.1.1.1, https://cloudflare-dns.com/dns-query",
    ),
    "dnsQueryServerInvalid": MessageLookupByLibrary.simpleMessage(
      "Invalid DNS server",
    ),
    "dnsQueryStopped": MessageLookupByLibrary.simpleMessage(
      "Proxy is not running, \"Follow Rules\" is unavailable",
    ),
    "dnsQuerySystem": MessageLookupByLibrary.simpleMessage("System DNS"),
    "dnsQueryViaDirect": MessageLookupByLibrary.simpleMessage(
      "Via DIRECT, resolved locally by the core",
    ),
    "dnsQueryViaDirectHosts": MessageLookupByLibrary.simpleMessage(
      "Via DIRECT, connects to the Hosts address",
    ),
    "dnsQueryViaProxy": m9,
    "dnsQueryViaProxyHosts": m10,
    "dnsQueryViaReject": MessageLookupByLibrary.simpleMessage(
      "Rejected by rules",
    ),
    "dnsResolution": MessageLookupByLibrary.simpleMessage("DNS Resolution"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Do you want to pass",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "doubleBounce": MessageLookupByLibrary.simpleMessage("Double Bounce"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "dozeSuspend": MessageLookupByLibrary.simpleMessage("Doze Support"),
    "dozeSuspendDesc": MessageLookupByLibrary.simpleMessage(
      "Sync with system Doze mode",
    ),
    "dualRing": MessageLookupByLibrary.simpleMessage("Dual Ring"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("Edit Forwarding"),
    "editUser": MessageLookupByLibrary.simpleMessage("Edit User"),
    "emptyTip": m11,
    "enableCrashReport": MessageLookupByLibrary.simpleMessage(
      "Crash Analytics",
    ),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "Upload crash logs when needed",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage("Enable Override"),
    "enableTraySpeed": MessageLookupByLibrary.simpleMessage("Tray Speed"),
    "enableTraySpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Show network speed in menu bar",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
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
      "Allow China QUIC instead of blocking all",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide app from recent tasks list",
    ),
    "existsTip": m12,
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
    "fast": MessageLookupByLibrary.simpleMessage("Fast"),
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
    "flushDnsOnNetworkChange": MessageLookupByLibrary.simpleMessage(
      "Clear DNS Cache",
    ),
    "flushDnsOnNetworkChangeDesc": MessageLookupByLibrary.simpleMessage(
      "Clear the DNS cache when the network changes",
    ),
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
    "geoBuiltInResources": MessageLookupByLibrary.simpleMessage(
      "GEO Built-in Resources",
    ),
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
      "Elevate app & core process priority",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage(
      "High Refresh Rate",
    ),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "Enable max refresh rate",
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
    "hours": m13,
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
    "iconConfigurationDesc": MessageLookupByLibrary.simpleMessage(
      "Customize proxy group ICON icons",
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
    "intranetAndGateway": MessageLookupByLibrary.simpleMessage("LAN & Gateway"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Local IP"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid IP or CIDR format",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP Address"),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage("Toggle Display"),
    "ipLookup": MessageLookupByLibrary.simpleMessage("IP Lookup"),
    "ipLookupDesc": MessageLookupByLibrary.simpleMessage(
      "Your exit IPs, or look up any IP or domain",
    ),
    "ipLookupDomesticExit": MessageLookupByLibrary.simpleMessage(
      "Domestic Local IP",
    ),
    "ipLookupHint": MessageLookupByLibrary.simpleMessage("IP or domain"),
    "ipLookupInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid IP or domain",
    ),
    "ipLookupLocal": MessageLookupByLibrary.simpleMessage("Local Network"),
    "ipLookupMine": MessageLookupByLibrary.simpleMessage("My IP"),
    "ipLookupProxyExit": MessageLookupByLibrary.simpleMessage(
      "Default Node IP",
    ),
    "ipLookupResolveFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to resolve this domain",
    ),
    "ipLookupResult": MessageLookupByLibrary.simpleMessage("Results"),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage(
      "Hide IP Display",
    ),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "iperfAddressHint": MessageLookupByLibrary.simpleMessage(
      "Server address, e.g. 192.168.1.5",
    ),
    "iperfAddressRequired": MessageLookupByLibrary.simpleMessage(
      "Enter a server address",
    ),
    "iperfAddresses": MessageLookupByLibrary.simpleMessage("This device"),
    "iperfBandwidth": MessageLookupByLibrary.simpleMessage("Send rate"),
    "iperfBidir": MessageLookupByLibrary.simpleMessage("Both"),
    "iperfClient": MessageLookupByLibrary.simpleMessage("Client"),
    "iperfCommands": MessageLookupByLibrary.simpleMessage("iperf3 commands"),
    "iperfConnecting": MessageLookupByLibrary.simpleMessage("Connecting…"),
    "iperfDirection": MessageLookupByLibrary.simpleMessage("Direction"),
    "iperfDone": MessageLookupByLibrary.simpleMessage("Test complete"),
    "iperfDuration": MessageLookupByLibrary.simpleMessage("Duration"),
    "iperfErrorBusy": MessageLookupByLibrary.simpleMessage(
      "The server is busy with another test. Try again later",
    ),
    "iperfErrorInterrupted": MessageLookupByLibrary.simpleMessage(
      "The test was interrupted",
    ),
    "iperfErrorListen": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t start the server",
    ),
    "iperfErrorPortInUse": m14,
    "iperfErrorProtocol": MessageLookupByLibrary.simpleMessage(
      "Unexpected response. The other side may not be an iPerf3 server",
    ),
    "iperfErrorRefused": MessageLookupByLibrary.simpleMessage(
      "Connection refused. Make sure the iPerf3 server is running",
    ),
    "iperfErrorServer": m15,
    "iperfErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "Connection timed out. Check the address and network",
    ),
    "iperfErrorUdp": MessageLookupByLibrary.simpleMessage(
      "UDP handshake failed. It may be blocked by a firewall",
    ),
    "iperfErrorUnreachable": MessageLookupByLibrary.simpleMessage(
      "Can\'t reach the server",
    ),
    "iperfFirewallTip": MessageLookupByLibrary.simpleMessage(
      "If other devices can\'t connect, allow incoming connections for the Bettbox core in your system firewall.",
    ),
    "iperfLostPackets": m16,
    "iperfNoAddress": MessageLookupByLibrary.simpleMessage(
      "No LAN address found. Make sure Wi-Fi or Ethernet is connected",
    ),
    "iperfParallel": MessageLookupByLibrary.simpleMessage("Streams"),
    "iperfPeer": MessageLookupByLibrary.simpleMessage("Peer"),
    "iperfPort": MessageLookupByLibrary.simpleMessage("Port"),
    "iperfPortInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a port between 1 and 65535",
    ),
    "iperfProtocol": MessageLookupByLibrary.simpleMessage("Protocol"),
    "iperfReady": MessageLookupByLibrary.simpleMessage(
      "Enter a server address or scan a QR code to start",
    ),
    "iperfReceive": MessageLookupByLibrary.simpleMessage("Receive"),
    "iperfResult": MessageLookupByLibrary.simpleMessage("Result"),
    "iperfRetest": MessageLookupByLibrary.simpleMessage("Test again"),
    "iperfRetransmits": MessageLookupByLibrary.simpleMessage("Retransmits"),
    "iperfRtt": MessageLookupByLibrary.simpleMessage("RTT"),
    "iperfRunning": MessageLookupByLibrary.simpleMessage("Testing"),
    "iperfScan": MessageLookupByLibrary.simpleMessage("Scan to connect"),
    "iperfScanHint": MessageLookupByLibrary.simpleMessage(
      "Scan with Bettbox on another device to connect in one tap",
    ),
    "iperfScanInvalid": MessageLookupByLibrary.simpleMessage(
      "This isn\'t an iPerf3 connection QR code",
    ),
    "iperfScanned": m17,
    "iperfSeconds": m18,
    "iperfSend": MessageLookupByLibrary.simpleMessage("Send"),
    "iperfServer": MessageLookupByLibrary.simpleMessage("Server"),
    "iperfServerListening": m19,
    "iperfServerOff": MessageLookupByLibrary.simpleMessage(
      "Server is not running",
    ),
    "iperfServerOffHint": MessageLookupByLibrary.simpleMessage(
      "Once started, other devices can scan the QR code or enter this device\'s address to connect",
    ),
    "iperfServerStart": MessageLookupByLibrary.simpleMessage("Start server"),
    "iperfServerStop": MessageLookupByLibrary.simpleMessage("Stop server"),
    "iperfServerTip": MessageLookupByLibrary.simpleMessage(
      "The server only runs while this page is open and stops when you leave. The screen stays on while it runs.",
    ),
    "iperfStart": MessageLookupByLibrary.simpleMessage("Start test"),
    "iperfStreams": m20,
    "iperfTest": MessageLookupByLibrary.simpleMessage("iPerf3 Tool"),
    "iperfTestDesc": MessageLookupByLibrary.simpleMessage(
      "Measure bandwidth between devices on your LAN, compatible with iperf3",
    ),
    "iperfThroughput": MessageLookupByLibrary.simpleMessage("Throughput"),
    "iperfTransferred": MessageLookupByLibrary.simpleMessage("Data"),
    "iperfUdpUnavailable": MessageLookupByLibrary.simpleMessage(
      "The UDP port is in use, so only TCP tests are available.",
    ),
    "iperfWaiting": MessageLookupByLibrary.simpleMessage(
      "Waiting for a client",
    ),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "Enable IPv6 traffic routing",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "isp": MessageLookupByLibrary.simpleMessage("ISP"),
    "itemsCount": m21,
    "just": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "keepDockIcon": MessageLookupByLibrary.simpleMessage("Keep in Dock"),
    "keepDockIconDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the app icon in the Dock",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "lanSharing": MessageLookupByLibrary.simpleMessage("LAN Sharing"),
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
    "localPing": MessageLookupByLibrary.simpleMessage("Local Ping"),
    "localPingAverage": MessageLookupByLibrary.simpleMessage("Average"),
    "localPingBytes": m22,
    "localPingClosed": MessageLookupByLibrary.simpleMessage("Port closed"),
    "localPingCount": MessageLookupByLibrary.simpleMessage("Count"),
    "localPingDesc": MessageLookupByLibrary.simpleMessage(
      "Direct ICMP, TCP and UDP latency and loss test",
    ),
    "localPingDone": MessageLookupByLibrary.simpleMessage("Ping finished"),
    "localPingErrorDenied": MessageLookupByLibrary.simpleMessage(
      "ICMP is not permitted on this system. Try TCP or UDP ping",
    ),
    "localPingErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Unable to send ping packets",
    ),
    "localPingErrorResolve": MessageLookupByLibrary.simpleMessage(
      "Could not resolve the domain",
    ),
    "localPingFailed": MessageLookupByLibrary.simpleMessage("Send failed"),
    "localPingFrom": m23,
    "localPingGateway": MessageLookupByLibrary.simpleMessage("Gateway"),
    "localPingListLimit": m24,
    "localPingMax": MessageLookupByLibrary.simpleMessage("Max"),
    "localPingMin": MessageLookupByLibrary.simpleMessage("Min"),
    "localPingReady": MessageLookupByLibrary.simpleMessage(
      "Choose a target to start",
    ),
    "localPingReceived": MessageLookupByLibrary.simpleMessage("Received"),
    "localPingResolving": MessageLookupByLibrary.simpleMessage("Resolving"),
    "localPingResult": MessageLookupByLibrary.simpleMessage("Ping result"),
    "localPingRttSummary": m25,
    "localPingRunning": MessageLookupByLibrary.simpleMessage("Pinging"),
    "localPingSent": MessageLookupByLibrary.simpleMessage("Sent"),
    "localPingSize": MessageLookupByLibrary.simpleMessage("Packet size"),
    "localPingStart": MessageLookupByLibrary.simpleMessage("Start ping"),
    "localPingStats": m26,
    "localPingSummary": m27,
    "localPingTargetHint": MessageLookupByLibrary.simpleMessage(
      "Domain or IP address",
    ),
    "localPingTcpTip": MessageLookupByLibrary.simpleMessage(
      "TCP ping measures connection setup time. A refused connection also means the host is reachable",
    ),
    "localPingTimeout": MessageLookupByLibrary.simpleMessage(
      "Request timed out",
    ),
    "localPingUdpTip": MessageLookupByLibrary.simpleMessage(
      "Port 53 sends a DNS query and waits for the answer. Most other ports never reply, so a timeout does not mean the host is down",
    ),
    "localPingUnreachable": MessageLookupByLibrary.simpleMessage(
      "Destination unreachable",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from file",
    ),
    "locate": MessageLookupByLibrary.simpleMessage("Locate"),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logAiSearch": MessageLookupByLibrary.simpleMessage("AI Search"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log Level"),
    "logLevelDebugHint": m28,
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
    "loopbackProtection": MessageLookupByLibrary.simpleMessage(
      "Loopback Protection",
    ),
    "loopbackProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "Block loopback traffic from errors",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("Refresh IP"),
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "mediaBatchAll": MessageLookupByLibrary.simpleMessage("All nodes"),
    "mediaBatchAllDesc": MessageLookupByLibrary.simpleMessage(
      "Every node, excluding DIRECT",
    ),
    "mediaBatchGroup": MessageLookupByLibrary.simpleMessage("Test"),
    "mediaBatchNoNodes": MessageLookupByLibrary.simpleMessage(
      "No nodes to test",
    ),
    "mediaBatchScope": MessageLookupByLibrary.simpleMessage(
      "Choose what to test",
    ),
    "mediaBatchSummary": m29,
    "mediaBatchTest": MessageLookupByLibrary.simpleMessage("Batch Node Test"),
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
    "mediaUnlockMoreStreamingPlatforms": MessageLookupByLibrary.simpleMessage(
      "More Streaming Unlock Items",
    ),
    "mediaUnlockPinnedSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Pin up to 3 items on widget",
    ),
    "mediaUnlockRefreshByCategory": MessageLookupByLibrary.simpleMessage(
      "Partially refresh based on current category",
    ),
    "mediaUnlockRefreshOnNodeChange": MessageLookupByLibrary.simpleMessage(
      "Auto refresh on node change",
    ),
    "mediaUnlockSelectLimit": MessageLookupByLibrary.simpleMessage(
      "You can select up to 3 items",
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
    "minutes": m30,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "months": m31,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage("More IP Information"),
    "mrsCopyRawLink": MessageLookupByLibrary.simpleMessage(
      "Copy as GitHub Raw link",
    ),
    "mrsLookup": MessageLookupByLibrary.simpleMessage("MRS Lookup"),
    "mrsLookupDesc": MessageLookupByLibrary.simpleMessage(
      "Find the GEODATA / RULE-SET rule sets for a domain or IP",
    ),
    "mrsLookupHint": MessageLookupByLibrary.simpleMessage("Domain or IP"),
    "mrsMissing": MessageLookupByLibrary.simpleMessage(
      "Bundled BundleMRS not found",
    ),
    "mrsNoMatch": MessageLookupByLibrary.simpleMessage("No rule set matched"),
    "mrsPrepareFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to load rule sets",
    ),
    "mrsReferenced": MessageLookupByLibrary.simpleMessage("In use"),
    "mrsResolveDns": MessageLookupByLibrary.simpleMessage(
      "Resolve domains with DNS rules",
    ),
    "mrsResolveDnsDesc": MessageLookupByLibrary.simpleMessage(
      "When on, domains are resolved to IPs with the current DNS config and the IPs are matched too",
    ),
    "mrsRules": m32,
    "mrsVia": m33,
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameSort": MessageLookupByLibrary.simpleMessage("Sort by Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Resolve domain names",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver Policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify domain-specific nameservers",
    ),
    "natCopyResult": MessageLookupByLibrary.simpleMessage("Copy Result"),
    "natDescBlocked": MessageLookupByLibrary.simpleMessage(
      "No STUN reply. UDP may be blocked by a firewall, your ISP or the outbound node.",
    ),
    "natDescCone": MessageLookupByLibrary.simpleMessage(
      "Most P2P and online games work fine. This server can\'t tell exactly which of NAT1–3 you have; try another server for a precise result.",
    ),
    "natDescFullCone": MessageLookupByLibrary.simpleMessage(
      "NAT1: any external host can reach you. Best for P2P, gaming and voice calls.",
    ),
    "natDescOpen": MessageLookupByLibrary.simpleMessage(
      "No NAT in between. Peers can reach you directly, which is ideal for P2P and gaming.",
    ),
    "natDescPortRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT3: only the exact address and port you contacted can reply. Some P2P or gaming may need a relay.",
    ),
    "natDescRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT2: only addresses you contacted can reply. Most P2P and games work well.",
    ),
    "natDescSymmetric": MessageLookupByLibrary.simpleMessage(
      "NAT4: every destination gets a different mapped port. P2P is hard and usually needs a relay.",
    ),
    "natDescUnknown": MessageLookupByLibrary.simpleMessage(
      "Unable to determine the NAT type.",
    ),
    "natErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Unable to reach the STUN server",
    ),
    "natErrorUnsupported": MessageLookupByLibrary.simpleMessage(
      "The selected outbound does not support UDP",
    ),
    "natExternalIp": MessageLookupByLibrary.simpleMessage("External IP"),
    "natExternalPort": MessageLookupByLibrary.simpleMessage("External Port"),
    "natFiltering": MessageLookupByLibrary.simpleMessage("Filtering"),
    "natLocalIp": MessageLookupByLibrary.simpleMessage("Local IP"),
    "natMapping": MessageLookupByLibrary.simpleMessage("Mapping"),
    "natMappingAddress": MessageLookupByLibrary.simpleMessage(
      "Address-dependent",
    ),
    "natMappingAddressPort": MessageLookupByLibrary.simpleMessage(
      "Address and port-dependent",
    ),
    "natMappingDependent": MessageLookupByLibrary.simpleMessage(
      "Destination-dependent",
    ),
    "natMappingIndependent": MessageLookupByLibrary.simpleMessage(
      "Endpoint-independent",
    ),
    "natPhaseBinding": MessageLookupByLibrary.simpleMessage("Binding"),
    "natPhaseFiltering": MessageLookupByLibrary.simpleMessage("Filtering"),
    "natPhaseMapping": MessageLookupByLibrary.simpleMessage("Mapping"),
    "natPortPreserve": MessageLookupByLibrary.simpleMessage(
      "Port Preservation",
    ),
    "natPreserved": MessageLookupByLibrary.simpleMessage("Preserved"),
    "natProxyTip": MessageLookupByLibrary.simpleMessage(
      "Through a proxy, the result reflects the outbound node side NAT, not your local network.",
    ),
    "natRandomized": MessageLookupByLibrary.simpleMessage("Randomized"),
    "natReady": MessageLookupByLibrary.simpleMessage(
      "Tap the button below to start",
    ),
    "natResult": MessageLookupByLibrary.simpleMessage("Result"),
    "natRetest": MessageLookupByLibrary.simpleMessage("Detect Again"),
    "natServer": MessageLookupByLibrary.simpleMessage("STUN Server"),
    "natServerCustom": MessageLookupByLibrary.simpleMessage("Custom Server"),
    "natServerHint": MessageLookupByLibrary.simpleMessage(
      "host:port, e.g. stun.example.com:3478",
    ),
    "natServerInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid host:port",
    ),
    "natStart": MessageLookupByLibrary.simpleMessage("Start Detection"),
    "natTest": MessageLookupByLibrary.simpleMessage("NAT Detection"),
    "natTestDesc": MessageLookupByLibrary.simpleMessage(
      "Check NAT type, external address and UDP connectivity",
    ),
    "natType": MessageLookupByLibrary.simpleMessage("NAT Type"),
    "natTypeBlocked": MessageLookupByLibrary.simpleMessage("UDP Blocked"),
    "natTypeCone": MessageLookupByLibrary.simpleMessage("Cone NAT"),
    "natTypeFullCone": MessageLookupByLibrary.simpleMessage("Full Cone NAT"),
    "natTypeOpen": MessageLookupByLibrary.simpleMessage("Open Internet"),
    "natTypePortRestricted": MessageLookupByLibrary.simpleMessage(
      "Port Restricted Cone NAT",
    ),
    "natTypeRestricted": MessageLookupByLibrary.simpleMessage(
      "Restricted Cone NAT",
    ),
    "natTypeSymmetric": MessageLookupByLibrary.simpleMessage("Symmetric NAT"),
    "natTypeUnknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "Motion Feedback",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Bottom navigation bar animation and haptic feedback",
    ),
    "navConnections": MessageLookupByLibrary.simpleMessage("Connections"),
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
    "newLogsCount": m34,
    "noAnimation": MessageLookupByLibrary.simpleMessage("Default"),
    "noBackupFileFound": MessageLookupByLibrary.simpleMessage(
      "No backup file found",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No Data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No Hotkeys"),
    "noIcon": MessageLookupByLibrary.simpleMessage("No Icon"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No Info"),
    "noMatchedLogs": MessageLookupByLibrary.simpleMessage("No matching logs"),
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
      "Foreground high-priority notification",
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
    "nullTip": m35,
    "numberRangeInvalid": m36,
    "numberTip": m37,
    "oneColumn": MessageLookupByLibrary.simpleMessage("1 Column"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("Online Panel"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon Only"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "Third-Party Apps Only",
    ),
    "onlyShow": m38,
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Proxy Traffic Only",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Only record proxy traffic",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("Open Zashboard"),
    "openRouterAdmin": MessageLookupByLibrary.simpleMessage("Open Gateway"),
    "openSettings": MessageLookupByLibrary.simpleMessage("Open Settings"),
    "operatorOrAsn": MessageLookupByLibrary.simpleMessage("Organization / ASN"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "organizationDomain": MessageLookupByLibrary.simpleMessage(
      "Organization / Domain",
    ),
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
    "portTip": m39,
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
    "profileImportFailed": m40,
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
      "Resolve proxy node domains",
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
      "Disable QUIC ECN",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC GSO",
    ),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC GSO",
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
    "recoveryDecryptedTip": MessageLookupByLibrary.simpleMessage(
      "Decrypted and restored with the current password",
    ),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Restore Profiles Only",
    ),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "Recovery Strategy",
    ),
    "recoveryStrategyDesc_compatible": MessageLookupByLibrary.simpleMessage(
      "Keep local items, merge backup by ID",
    ),
    "recoveryStrategyDesc_override": MessageLookupByLibrary.simpleMessage(
      "Clear local items and replace with backup",
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
    "relatedSettings": MessageLookupByLibrary.simpleMessage("Related Settings"),
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
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetIconCache": MessageLookupByLibrary.simpleMessage("Reset Icon Cache"),
    "resetIconCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Reset the local icon cache? This is safe, the app will fetch icons from their remote links again automatically.",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("External Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "View external resources and rule sets",
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
    "routeTrace": MessageLookupByLibrary.simpleMessage("Route Trace"),
    "routeTraceChain": MessageLookupByLibrary.simpleMessage("Proxy Chain"),
    "routeTraceCheckedRules": MessageLookupByLibrary.simpleMessage(
      "Checked Rules",
    ),
    "routeTraceDesc": MessageLookupByLibrary.simpleMessage(
      "See how the core resolves and matches a domain or IP",
    ),
    "routeTraceDns": MessageLookupByLibrary.simpleMessage("DNS Resolution"),
    "routeTraceDnsBy": m41,
    "routeTraceDnsIp": MessageLookupByLibrary.simpleMessage(
      "The target is an IP, no resolution needed",
    ),
    "routeTraceDnsSkipped": MessageLookupByLibrary.simpleMessage(
      "No IP resolution was needed while matching",
    ),
    "routeTraceFinal": MessageLookupByLibrary.simpleMessage("Final Outbound"),
    "routeTraceHint": MessageLookupByLibrary.simpleMessage("Domain, IP or URL"),
    "routeTraceHostsHit": m42,
    "routeTraceInput": MessageLookupByLibrary.simpleMessage("Target"),
    "routeTraceModeDirect": MessageLookupByLibrary.simpleMessage(
      "Direct mode: all traffic goes direct",
    ),
    "routeTraceModeGlobal": MessageLookupByLibrary.simpleMessage(
      "Global mode: all traffic uses GLOBAL",
    ),
    "routeTraceNoMatch": MessageLookupByLibrary.simpleMessage(
      "No rule matched, using DIRECT",
    ),
    "routeTraceRules": MessageLookupByLibrary.simpleMessage("Rule Matching"),
    "routeTraceRulesSummary": m43,
    "routeTraceRulesTotal": m44,
    "routeTraceSkipMissing": MessageLookupByLibrary.simpleMessage(
      "Skipped, target not found",
    ),
    "routeTraceSkipPass": MessageLookupByLibrary.simpleMessage(
      "Skipped by PASS",
    ),
    "routeTraceSkipUdp": MessageLookupByLibrary.simpleMessage(
      "Skipped, no UDP support",
    ),
    "routeTraceStopped": MessageLookupByLibrary.simpleMessage(
      "Proxy is not running, route trace is unavailable",
    ),
    "routeTraceTrigger": MessageLookupByLibrary.simpleMessage("Triggered DNS"),
    "routeTraceTruncated": MessageLookupByLibrary.simpleMessage(
      "Only the first 3000 rules are shown",
    ),
    "routeTraceUdpUnsupported": MessageLookupByLibrary.simpleMessage(
      "This outbound does not support UDP",
    ),
    "routeTraceViewRules": MessageLookupByLibrary.simpleMessage(
      "View checked rules",
    ),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule Name"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule Providers"),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage(
      "Rule Providers",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule Target"),
    "rulesCount": MessageLookupByLibrary.simpleMessage("Rules"),
    "runTime": MessageLookupByLibrary.simpleMessage("Uptime"),
    "runningMode": MessageLookupByLibrary.simpleMessage("Running Mode"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("Runtime Config"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save changes?"),
    "saveTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Override Script"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "Configure JavaScript override scripts",
    ),
    "scriptOtherOptions": MessageLookupByLibrary.simpleMessage(
      "Other Settings",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "Secret copied to clipboard",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
    "selectBackupVersion": MessageLookupByLibrary.simpleMessage(
      "Select Backup Version",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m45,
    "serviceReady": MessageLookupByLibrary.simpleMessage("Service Ready"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage("Service Running"),
    "setcapFailedFallback": MessageLookupByLibrary.simpleMessage(
      "Could not grant file capabilities, falling back to setuid",
    ),
    "setcapNotInstalledFallback": MessageLookupByLibrary.simpleMessage(
      "setcap is not installed, falling back to setuid",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "sharedAddress": MessageLookupByLibrary.simpleMessage("Shared Address"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showHiddenItems": MessageLookupByLibrary.simpleMessage(
      "Show Hidden Items",
    ),
    "showMenu": MessageLookupByLibrary.simpleMessage("Open Menu"),
    "showPanel": MessageLookupByLibrary.simpleMessage("Show Window"),
    "showStartSwitch": MessageLookupByLibrary.simpleMessage("Linkage Switch"),
    "showStartSwitchDesc": MessageLookupByLibrary.simpleMessage(
      "Show standalone switch on homepage",
    ),
    "shrink": MessageLookupByLibrary.simpleMessage("Compact"),
    "sidebarFlyout": MessageLookupByLibrary.simpleMessage("Hover Panel"),
    "sidebarFlyoutDelay": MessageLookupByLibrary.simpleMessage("Trigger Delay"),
    "sidebarFlyoutDesc": MessageLookupByLibrary.simpleMessage(
      "Show sidebar settings hover card",
    ),
    "sidebarFlyoutEntries": MessageLookupByLibrary.simpleMessage("Entries"),
    "sidebarFlyoutOutsideTools": MessageLookupByLibrary.simpleMessage(
      "Only show outside the “Tools” page",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent Launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Skip Domain"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Skip Destination IP",
    ),
    "skipLocalAuth": MessageLookupByLibrary.simpleMessage(
      "Skip Local Authentication",
    ),
    "skipLocalAuthDesc": MessageLookupByLibrary.simpleMessage(
      "Allow local access without credentials",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("Skip Source IP"),
    "slow": MessageLookupByLibrary.simpleMessage("Slow"),
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
    "speedTest": MessageLookupByLibrary.simpleMessage("Speed Test"),
    "speedTestAgain": MessageLookupByLibrary.simpleMessage("Test Again"),
    "speedTestChangeOutbound": MessageLookupByLibrary.simpleMessage(
      "Change Outbound",
    ),
    "speedTestClearHistoryTip": MessageLookupByLibrary.simpleMessage(
      "Clear all speed test history?",
    ),
    "speedTestConnecting": MessageLookupByLibrary.simpleMessage("Connecting"),
    "speedTestConnections": MessageLookupByLibrary.simpleMessage("Connections"),
    "speedTestConnectionsDesc": m46,
    "speedTestCoreStopped": MessageLookupByLibrary.simpleMessage(
      "Not started · Direct test",
    ),
    "speedTestCredit": MessageLookupByLibrary.simpleMessage(
      "Speed test servers are provided by public third parties. Special thanks to Apple, Cloudflare and Speedtest by Ookla.",
    ),
    "speedTestDataUsed": MessageLookupByLibrary.simpleMessage("Data Used"),
    "speedTestDuration": MessageLookupByLibrary.simpleMessage("Test Duration"),
    "speedTestErrorBlocked": MessageLookupByLibrary.simpleMessage(
      "Speed test unavailable",
    ),
    "speedTestErrorBlockedDesc": m47,
    "speedTestErrorNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Check whether the outbound is available, then retry.",
    ),
    "speedTestErrorRejected": MessageLookupByLibrary.simpleMessage(
      "Blocked by rules",
    ),
    "speedTestErrorRejectedDesc": MessageLookupByLibrary.simpleMessage(
      "The current rules route the test domain to REJECT. Choose another outbound and retry.",
    ),
    "speedTestErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "Speed test timed out",
    ),
    "speedTestErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Cannot reach the speed test service",
    ),
    "speedTestExitNode": MessageLookupByLibrary.simpleMessage("Exit Node"),
    "speedTestFollowRules": MessageLookupByLibrary.simpleMessage(
      "Follow Rules",
    ),
    "speedTestHistory": MessageLookupByLibrary.simpleMessage("Test History"),
    "speedTestHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "No test history yet",
    ),
    "speedTestHistoryRetention": MessageLookupByLibrary.simpleMessage(
      "Kept for 14 days",
    ),
    "speedTestJitter": MessageLookupByLibrary.simpleMessage("Jitter"),
    "speedTestLoadedLatency": MessageLookupByLibrary.simpleMessage(
      "Loaded Latency",
    ),
    "speedTestManual": MessageLookupByLibrary.simpleMessage("Manual"),
    "speedTestMobileDataTip": MessageLookupByLibrary.simpleMessage(
      "You are on mobile data. One test may use hundreds of MB. Continue?",
    ),
    "speedTestMultiThread": MessageLookupByLibrary.simpleMessage("Multi"),
    "speedTestOutbound": MessageLookupByLibrary.simpleMessage("Outbound"),
    "speedTestPacketLoss": MessageLookupByLibrary.simpleMessage("Packet Loss"),
    "speedTestProbing": MessageLookupByLibrary.simpleMessage(
      "Detecting outbound…",
    ),
    "speedTestProtocol": MessageLookupByLibrary.simpleMessage("Protocol"),
    "speedTestProtocolDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP/3 runs over QUIC (UDP); if unavailable it falls back to HTTP/2, and to HTTP/1.1 if HTTP/2 is unavailable too",
    ),
    "speedTestProtocolFallback": m48,
    "speedTestQuality": MessageLookupByLibrary.simpleMessage("Network Quality"),
    "speedTestReady": MessageLookupByLibrary.simpleMessage("Ready"),
    "speedTestRealtime": MessageLookupByLibrary.simpleMessage(
      "Realtime Throughput",
    ),
    "speedTestResponsiveness": MessageLookupByLibrary.simpleMessage(
      "Responsiveness",
    ),
    "speedTestRoute": MessageLookupByLibrary.simpleMessage("Route Rule"),
    "speedTestServer": MessageLookupByLibrary.simpleMessage("Test Server"),
    "speedTestServerAutoDesc": MessageLookupByLibrary.simpleMessage(
      "Automatically select Speedtest server",
    ),
    "speedTestSettings": MessageLookupByLibrary.simpleMessage(
      "Speed Test Settings",
    ),
    "speedTestSingleThread": MessageLookupByLibrary.simpleMessage("Single"),
    "speedTestStart": MessageLookupByLibrary.simpleMessage("Start Test"),
    "speedTestStreams": m49,
    "speedTestSwitchProvider": m50,
    "speedTestUseSystemDns": MessageLookupByLibrary.simpleMessage(
      "Resolve with System DNS",
    ),
    "speedTestUseSystemDnsDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, the selected speed test server is always resolved with system DNS, which can help in some cases",
    ),
    "spinningCircle": MessageLookupByLibrary.simpleMessage("Spinning Circle"),
    "spinningLines": MessageLookupByLibrary.simpleMessage("Spinning Lines"),
    "squareCircle": MessageLookupByLibrary.simpleMessage("Square Circle"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack Mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startSwitchOffLabel": MessageLookupByLibrary.simpleMessage(
      "Text when off",
    ),
    "startSwitchOnLabel": MessageLookupByLibrary.simpleMessage("Text when on"),
    "startSwitchOutlined": MessageLookupByLibrary.simpleMessage("Outlined"),
    "startSwitchPersonalized": MessageLookupByLibrary.simpleMessage(
      "Personalized Display",
    ),
    "startSwitchStyle": MessageLookupByLibrary.simpleMessage("Style"),
    "startSwitchTonal": MessageLookupByLibrary.simpleMessage("Tonal"),
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
    "syncDelayAnimation": MessageLookupByLibrary.simpleMessage(
      "Sync animation to other pages",
    ),
    "syncFailed": MessageLookupByLibrary.simpleMessage("Sync Failed"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System App"),
    "systemDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "systemFont": MessageLookupByLibrary.simpleMessage("System Font"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System Proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("Set system proxy"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tailscale": MessageLookupByLibrary.simpleMessage("Tailscale"),
    "tailscaleAcceptRoutes": MessageLookupByLibrary.simpleMessage(
      "Accept subnet routes",
    ),
    "tailscaleAcceptRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Use subnet routes advertised in the tailnet",
    ),
    "tailscaleAddNetwork": MessageLookupByLibrary.simpleMessage("Add network"),
    "tailscaleAuthKey": MessageLookupByLibrary.simpleMessage("Auth key"),
    "tailscaleAuthKeyDesc": MessageLookupByLibrary.simpleMessage(
      "Optional; without one, use Log in (SSO/OIDC)",
    ),
    "tailscaleConnected": MessageLookupByLibrary.simpleMessage("Connected"),
    "tailscaleControlUrl": MessageLookupByLibrary.simpleMessage(
      "Control server",
    ),
    "tailscaleControlUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Empty uses Tailscale. Set a URL for Headscale",
    ),
    "tailscaleDeleteNetwork": MessageLookupByLibrary.simpleMessage(
      "Delete network",
    ),
    "tailscaleDesc": MessageLookupByLibrary.simpleMessage(
      "Route chosen domains and IPs through your tailnet",
    ),
    "tailscaleDevices": MessageLookupByLibrary.simpleMessage("Devices"),
    "tailscaleDns": MessageLookupByLibrary.simpleMessage("Tailnet DNS"),
    "tailscaleDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Domains resolved by a DNS server inside the tailnet, as domain=server (e.g. corp.example.com=10.1.0.53). Add the subnets they resolve to under Routing list",
    ),
    "tailscaleEnable": MessageLookupByLibrary.simpleMessage("Enable Tailscale"),
    "tailscaleEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Join the tailnet with the built-in Tailscale node",
    ),
    "tailscaleExitNode": MessageLookupByLibrary.simpleMessage("Exit node"),
    "tailscaleExitNodeDesc": MessageLookupByLibrary.simpleMessage(
      "Tailnet device name or IP, or auto:any. Needed for public sites",
    ),
    "tailscaleExitNodeLan": MessageLookupByLibrary.simpleMessage(
      "Allow LAN access",
    ),
    "tailscaleExitNodeLanDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the local network reachable while using the exit node",
    ),
    "tailscaleHostname": MessageLookupByLibrary.simpleMessage("Device name"),
    "tailscaleInvalidDns": MessageLookupByLibrary.simpleMessage(
      "Use domain=server with an IP server or a tls:// / https:// URL, e.g. corp.example.com=10.1.0.53",
    ),
    "tailscaleInvalidEntry": MessageLookupByLibrary.simpleMessage(
      "Enter a domain, IP or CIDR",
    ),
    "tailscaleLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Tailscale logged in",
    ),
    "tailscaleLogin": MessageLookupByLibrary.simpleMessage("Log in"),
    "tailscaleLoginDesc": MessageLookupByLibrary.simpleMessage(
      "Sign in in the browser with your tailnet\'s SSO/OIDC; no auth key needed",
    ),
    "tailscaleLoginNeeded": MessageLookupByLibrary.simpleMessage(
      "Tailscale needs login",
    ),
    "tailscaleNeedsApproval": MessageLookupByLibrary.simpleMessage(
      "Waiting for an admin to approve this device",
    ),
    "tailscaleNetwork": MessageLookupByLibrary.simpleMessage("Network"),
    "tailscaleNetworks": MessageLookupByLibrary.simpleMessage("Networks"),
    "tailscaleNotStarted": MessageLookupByLibrary.simpleMessage("Not started"),
    "tailscaleNotStartedDesc": MessageLookupByLibrary.simpleMessage(
      "Starts on first use; tap to start now",
    ),
    "tailscaleNotes": MessageLookupByLibrary.simpleMessage(
      "• Built-in node: Bettbox joins your tailnet itself, no Tailscale app needed. Only the Routing list and Tailnet DNS go through it.\n• Rule mode only: Global and Direct modes skip these rules.\n• Use full names like host.tailnet.ts.net; short names like nas don\'t resolve.\n• Subnets: add them to the Routing list and turn on Accept subnet routes. On desktop without TUN, private subnets (10.x, 172.16–31.x, 192.168.x) bypass the system proxy.\n• Public sites through the tailnet need an exit node.\n• Tailnet IPv6 addresses need IPv6 turned on.\n• The node starts on first use. Its login link is only shown while Bettbox is open.\n• Android: Routing list changes apply after the VPN restarts.",
    ),
    "tailscaleNotesTitle": MessageLookupByLibrary.simpleMessage("Notes"),
    "tailscaleOnlineCount": m51,
    "tailscaleRelay": m52,
    "tailscaleReset": MessageLookupByLibrary.simpleMessage("Reset node"),
    "tailscaleResetDesc": MessageLookupByLibrary.simpleMessage(
      "Forget this device\'s tailnet identity and join as a new device; remove the old one in the admin console",
    ),
    "tailscaleRoutes": MessageLookupByLibrary.simpleMessage("Routing list"),
    "tailscaleRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Domains and IPs/CIDRs sent through Tailscale in Rule mode. Private subnets need TUN on desktop",
    ),
    "tailscaleStarting": MessageLookupByLibrary.simpleMessage(
      "Starting Tailscale…",
    ),
    "tailscaleSubnetRoutes": MessageLookupByLibrary.simpleMessage(
      "Subnet routes",
    ),
    "tailscaleThisDevice": MessageLookupByLibrary.simpleMessage("This device"),
    "tailscaleUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "tailscaleUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Send UDP traffic through Tailscale",
    ),
    "tailscaleWarnings": MessageLookupByLibrary.simpleMessage("Warnings"),
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
      "Set theme color options",
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
    "toolConnectivityDesc": MessageLookupByLibrary.simpleMessage(
      "Check common services, with per-node batch testing",
    ),
    "toolHistoryClear": MessageLookupByLibrary.simpleMessage("Clear history"),
    "toolSpeedTestDesc": MessageLookupByLibrary.simpleMessage(
      "Measure download, upload and latency",
    ),
    "toolbox": MessageLookupByLibrary.simpleMessage("Toolbox"),
    "toolboxDesc": MessageLookupByLibrary.simpleMessage(
      "Network diagnostics, debugging and utilities",
    ),
    "toolboxEditTip": MessageLookupByLibrary.simpleMessage(
      "Tap a card to change its size, long-press and drag to rearrange",
    ),
    "toolboxEditTipDesktop": MessageLookupByLibrary.simpleMessage(
      "Click a card to change its size, drag to rearrange",
    ),
    "toolboxEditTipTv": MessageLookupByLibrary.simpleMessage(
      "Select a card and press OK to change its size",
    ),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total Traffic"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy Port"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic Usage"),
    "trayClickBehavior": MessageLookupByLibrary.simpleMessage(
      "Tray Click Behavior",
    ),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("Tray Enhancement"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "Control proxy groups via tray menu",
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
    "urlTip": m53,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "Use Global Script Override",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Use Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use System Hosts"),
    "userAuth": MessageLookupByLibrary.simpleMessage("User Authentication"),
    "userAuthEmpty": MessageLookupByLibrary.simpleMessage(
      "No authentication configured, LAN connections do not require credentials",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameCannotContainColon": MessageLookupByLibrary.simpleMessage(
      "Username cannot contain colons",
    ),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "viewDetailedIpData": MessageLookupByLibrary.simpleMessage(
      "View Detailed IP Data",
    ),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("VPN-related settings"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Route traffic via VpnService",
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
    "xattrUnsupportedFallback": MessageLookupByLibrary.simpleMessage(
      "The filesystem does not support file capabilities, falling back to setuid",
    ),
    "years": m54,
  };
}
