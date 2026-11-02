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

  static String m2(count) => "${count} failed";

  static String m3(message) => "Last generation failed: ${message}";

  static String m4(count) => "You can merge up to ${count} subscriptions";

  static String m5(count) => "${count} nodes";

  static String m6(proxies, duplicates, time) =>
      "${proxies} nodes · ${duplicates} duplicates removed · ${time}";

  static String m7(count) => "${count} profiles merged";

  static String m8(value) => "Avg ${value}";

  static String m9(count) => "${Intl.plural(count, one: 'day', other: 'days')}";

  static String m10(label) =>
      "This profile is part of \"${label}\". Deleting it removes it from the merged subscription.";

  static String m11(label) => "Delete selected ${label}?";

  static String m12(label) => "Delete current ${label}?";

  static String m13(reason) => "Fake-IP · ${reason}: will return the real IP";

  static String m14(reason, range) =>
      "Fake-IP · ${reason}: will return a virtual address from ${range}";

  static String m15(ips) => "Matched Hosts: will return ${ips}";

  static String m16(outbound) =>
      "Final outbound \"${outbound}\", the node resolves the domain";

  static String m17(outbound) =>
      "Final outbound \"${outbound}\", the node resolves the domain; Hosts not applied";

  static String m18(label) => "${label} cannot be empty";

  static String m19(label) => "${label} already exists";

  static String m20(count) =>
      "${Intl.plural(count, one: '${count} hit', other: '${count} hits')}";

  static String m21(count) =>
      "${Intl.plural(count, one: 'hour', other: 'hours')}";

  static String m22(count) => "${count} icons";

  static String m23(inbound, user) => "${inbound} (user ${user})";

  static String m24(score) =>
      "Scamalytics can see web traffic from this IP directly. The score of ${score} reflects the share of that traffic suspected to be fraudulent.";

  static String m25(score, isp) =>
      "Scamalytics can\'t see web traffic from this IP directly. The score of ${score} is estimated from the overall risk of IPs operated by ${isp}.";

  static String m26(port) => "Port ${port} is already in use. Try another port";

  static String m27(code) => "The server rejected the test (error ${code})";

  static String m28(lost, total) => "${lost}/${total} packets";

  static String m29(name) => "Scanned: ${name}";

  static String m30(value) => "${value} s";

  static String m31(port) => "Listening on port ${port}";

  static String m32(count) => "${count} streams";

  static String m33(count) => "${count}";

  static String m34(count) => "${count} bytes";

  static String m35(address) => "From ${address}";

  static String m36(count) =>
      "Showing the latest ${count}. Copy the result to see all";

  static String m37(min, avg, max, jitter) =>
      "Round trip: min ${min} / avg ${avg} / max ${max} / jitter ${jitter} ms";

  static String m38(target) => "Ping statistics for ${target}";

  static String m39(sent, received, lost, loss) =>
      "Sent ${sent}, received ${received}, lost ${lost} (${loss}% loss)";

  static String m40(level) =>
      "${level} mode is for network debugging; turn it off for daily use";

  static String m41(version) => "Built-in ${version}";

  static String m42(enabled, total) => "${enabled} of ${total} enabled";

  static String m43(version) => "Upstream ${version}";

  static String m44(done, total, unlocked) =>
      "${done}/${total} tested · ${unlocked} available";

  static String m45(size) => "Freed ${size}";

  static String m46(index) => "Merged subscription ${index}";

  static String m47(count) =>
      "${Intl.plural(count, one: 'minute', other: 'minutes')}";

  static String m48(count) =>
      "${Intl.plural(count, one: 'month', other: 'months')}";

  static String m49(count) => "${count} entries";

  static String m50(ip) => "via ${ip}";

  static String m51(count) => "${count} new logs";

  static String m52(prefix) => "Node prefix: ${prefix}";

  static String m53(label) => "No ${label}";

  static String m54(min, max) => "Enter a whole number from ${min} to ${max}";

  static String m55(label) => "${label} must be a number";

  static String m56(label) => "Only ${label}";

  static String m57(label) =>
      "${label} must be between 1024 and 49151, 0 to disable";

  static String m58(statusCode) =>
      "Failed to import profile. Please check your network status or try resetting the subscription link ( HTTP error code: ${statusCode} )";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} provider', other: '${count} providers')}";

  static String m60(count) => "Add ${count}";

  static String m61(count) => "Remove ${count}";

  static String m62(index, time) => "Resolved by rule #${index} · ${time} ms";

  static String m63(ips) => "Hosts hit: ${ips}";

  static String m64(total, index) => "${total} rules, matched #${index}";

  static String m65(total) => "${total} rules";

  static String m66(count) => "${count} rules";

  static String m67(count, group) =>
      "${count} rules, included in the ${group} group";

  static String m68(count) => "${count} items selected";

  static String m69(count) =>
      "Multi uses ${count} parallel connections to saturate bandwidth";

  static String m70(provider) =>
      "The outbound may be blocking ${provider} speed tests. Switch the test source or the outbound.";

  static String m71(protocol, fallback) =>
      "${protocol} unavailable, fell back to ${fallback}";

  static String m72(count) => "${count} connections";

  static String m73(provider) => "Switch to ${provider}";

  static String m74(label) => "${label} must be a URL";

  static String m75(count) =>
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
    "addBundleMember": MessageLookupByLibrary.simpleMessage("Add members"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
    "addRoute": MessageLookupByLibrary.simpleMessage("Manage routes"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add Rule"),
    "addRuleSet": MessageLookupByLibrary.simpleMessage("Add rule set"),
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
    "autoStickyHeader": MessageLookupByLibrary.simpleMessage("Pin Expanded"),
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
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist Mode"),
    "blockComment": MessageLookupByLibrary.simpleMessage("Comment"),
    "builtIn": MessageLookupByLibrary.simpleMessage("Built-in"),
    "builtInManagedMode": MessageLookupByLibrary.simpleMessage("Built-in mode"),
    "bundleAddUrl": MessageLookupByLibrary.simpleMessage("Subscription link"),
    "bundleAddUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Import as a new subscription and add it",
    ),
    "bundleCollapse": MessageLookupByLibrary.simpleMessage("Collapse members"),
    "bundleCollapseDesc": MessageLookupByLibrary.simpleMessage(
      "Show only the merged subscription in the list; tap the arrow on its card to expand",
    ),
    "bundleDedupTip": MessageLookupByLibrary.simpleMessage(
      "Identical nodes are kept once, earlier members first",
    ),
    "bundleExpand": MessageLookupByLibrary.simpleMessage("Expand"),
    "bundleFailures": m2,
    "bundleMemberFailed": m3,
    "bundleMemberLimit": m4,
    "bundleMembers": MessageLookupByLibrary.simpleMessage("Members"),
    "bundleMembersDesc": MessageLookupByLibrary.simpleMessage(
      "Tap to change the node prefix, drag to reorder",
    ),
    "bundleNoMembers": MessageLookupByLibrary.simpleMessage(
      "Add at least one member",
    ),
    "bundlePendingImport": MessageLookupByLibrary.simpleMessage(
      "Pending import",
    ),
    "bundleProxies": m5,
    "bundleReportDesc": m6,
    "bundleSummary": m7,
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
    "checkUrlTip": MessageLookupByLibrary.simpleMessage(
      "Please check that the URL is correct",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "circle": MessageLookupByLibrary.simpleMessage("Circle"),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
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
    "currentSelection": MessageLookupByLibrary.simpleMessage("Current"),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "Custom Title",
    ),
    "customRuleSetUrl": MessageLookupByLibrary.simpleMessage(
      "Custom rule set URL",
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
    "dashboardAverage": m8,
    "dashboardTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "days": m9,
    "defaultGateway": MessageLookupByLibrary.simpleMessage("Gateway"),
    "defaultSort": MessageLookupByLibrary.simpleMessage("Default Sort"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayAnimation": MessageLookupByLibrary.simpleMessage("Delay Animation"),
    "delayAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Customize animation during delay testing",
    ),
    "delaySort": MessageLookupByLibrary.simpleMessage("Sort by Delay"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMemberTip": m10,
    "deleteMultipTip": m11,
    "deleteTip": m12,
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
    "disableQuic": MessageLookupByLibrary.simpleMessage("Disable QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC to resolve specific network issues",
    ),
    "disableQuicManagedDesc": MessageLookupByLibrary.simpleMessage(
      "Disable QUIC has no effect with scripts enabled",
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
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "FakeIP and DNS cache cleared",
    ),
    "dnsHijack": MessageLookupByLibrary.simpleMessage("DNS Hijack"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Take over system DNS and route it to the core",
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
    "dnsQueryFakeIpOff": m13,
    "dnsQueryFakeIpOn": m14,
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
    "dnsQueryHostsHit": m15,
    "dnsQueryNoRecords": MessageLookupByLibrary.simpleMessage("No records"),
    "dnsQueryNormalMode": MessageLookupByLibrary.simpleMessage(
      "Normal: will return the real IP, rules match by IP",
    ),
    "dnsQueryRedirHost": MessageLookupByLibrary.simpleMessage(
      "Redir-Host: will return the real IP, domain restored on connect",
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
      "Final outbound DIRECT, resolved locally by the core and connected directly",
    ),
    "dnsQueryViaDirectHosts": MessageLookupByLibrary.simpleMessage(
      "Final outbound DIRECT, connects to the Hosts address",
    ),
    "dnsQueryViaProxy": m16,
    "dnsQueryViaProxyHosts": m17,
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
    "dynamicColor": MessageLookupByLibrary.simpleMessage("Dynamic color"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editRoute": MessageLookupByLibrary.simpleMessage("Edit route"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("Edit Forwarding"),
    "editUser": MessageLookupByLibrary.simpleMessage("Edit User"),
    "emptyTip": m18,
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
    "existsTip": m19,
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
    "fakeIpFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Specify FakeIP filter mode",
    ),
    "fast": MessageLookupByLibrary.simpleMessage("Fast"),
    "fcmAndroidTip": MessageLookupByLibrary.simpleMessage(
      " Due to system permission reasons, on Android you may need to disable \"Allow bypass VPN\" in network settings to get more accurate results",
    ),
    "fcmOptimization": MessageLookupByLibrary.simpleMessage("FCM Optimization"),
    "fcmOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Enhance FCM connection stability",
    ),
    "fcmTip": MessageLookupByLibrary.simpleMessage(
      "Firebase Cloud Messaging (FCM) is a cross-platform messaging solution. Its connection support depends on the device and network, so the results are for reference only.",
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
    "forceGCTitle": MessageLookupByLibrary.simpleMessage(
      "Force Garbage Collection",
    ),
    "formatError": MessageLookupByLibrary.simpleMessage(
      "Please check the format",
    ),
    "fourColumns": MessageLookupByLibrary.simpleMessage("4 Columns"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Fruit Salad"),
    "fullRestart": MessageLookupByLibrary.simpleMessage("Cold Restart"),
    "fullRestartDesc": MessageLookupByLibrary.simpleMessage(
      "Fully restarts the core for more thorough memory release",
    ),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "Modify global settings",
    ),
    "generate": MessageLookupByLibrary.simpleMessage("Generate"),
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
    "getOriginRules": MessageLookupByLibrary.simpleMessage("Original Rules"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download Now"),
    "groupOrderTip": MessageLookupByLibrary.simpleMessage(
      "Matched from top to bottom, drag to reorder",
    ),
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
    "heapObjects": MessageLookupByLibrary.simpleMessage("Heap Objects"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Hide Unavailable Proxies",
    ),
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
    "hitCount": m20,
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage(
      "Append hosts to current config",
    ),
    "hotReload": MessageLookupByLibrary.simpleMessage("Hot Reload"),
    "hotReloadDesc": MessageLookupByLibrary.simpleMessage(
      "Keeps the core running for faster profile switching",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey Conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Control app via keyboard",
    ),
    "hourGlass": MessageLookupByLibrary.simpleMessage("Hourglass"),
    "hours": m21,
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
    "iconCount": m22,
    "iconSets": MessageLookupByLibrary.simpleMessage("Icon Sets"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon Style"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFailed": MessageLookupByLibrary.simpleMessage("Import failed"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from File"),
    "importFromCode": MessageLookupByLibrary.simpleMessage("Import from Code"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "inUse": MessageLookupByLibrary.simpleMessage("Current"),
    "inbound": MessageLookupByLibrary.simpleMessage("Inbound"),
    "inboundWithUser": m23,
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never Expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Enter a valid hotkey",
    ),
    "installTime": MessageLookupByLibrary.simpleMessage("Install Time"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Smart Select"),
    "internalTraffic": MessageLookupByLibrary.simpleMessage("Internal traffic"),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetAndGateway": MessageLookupByLibrary.simpleMessage("LAN & Gateway"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Local IP"),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Not a valid icon set",
    ),
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
    "ipRiskAlert": MessageLookupByLibrary.simpleMessage("IP Risk Alert"),
    "ipRiskAmountHigh": MessageLookupByLibrary.simpleMessage("High"),
    "ipRiskAmountLow": MessageLookupByLibrary.simpleMessage("Low"),
    "ipRiskAmountMedium": MessageLookupByLibrary.simpleMessage("Medium"),
    "ipRiskAnonymousVpn": MessageLookupByLibrary.simpleMessage(
      "Anonymizing VPN",
    ),
    "ipRiskBlacklist": MessageLookupByLibrary.simpleMessage("Blacklist flags"),
    "ipRiskCheck": MessageLookupByLibrary.simpleMessage("Check IP purity"),
    "ipRiskCommercialServer": MessageLookupByLibrary.simpleMessage(
      "Commercial server",
    ),
    "ipRiskDatacenter": MessageLookupByLibrary.simpleMessage("Datacenter"),
    "ipRiskHigh": MessageLookupByLibrary.simpleMessage("High risk"),
    "ipRiskHint": MessageLookupByLibrary.simpleMessage("Enter an IP to check"),
    "ipRiskHomeBroadband": MessageLookupByLibrary.simpleMessage(
      "Premium Residential IP",
    ),
    "ipRiskHostingOrProxy": MessageLookupByLibrary.simpleMessage(
      "Hosting or proxy",
    ),
    "ipRiskHostname": MessageLookupByLibrary.simpleMessage("Hostname"),
    "ipRiskInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid public IP",
    ),
    "ipRiskLow": MessageLookupByLibrary.simpleMessage("Low risk"),
    "ipRiskMedium": MessageLookupByLibrary.simpleMessage("Medium risk"),
    "ipRiskNoteAmount": MessageLookupByLibrary.simpleMessage(
      "Observed traffic",
    ),
    "ipRiskNoteAmountIsp": MessageLookupByLibrary.simpleMessage(
      "Operator traffic",
    ),
    "ipRiskNoteConnection": MessageLookupByLibrary.simpleMessage("Connection"),
    "ipRiskNoteDirect": m24,
    "ipRiskNoteFootnote": MessageLookupByLibrary.simpleMessage(
      "This assessment covers web traffic only; other traffic may carry a different risk.",
    ),
    "ipRiskNoteGeneric": MessageLookupByLibrary.simpleMessage(
      "The fraud score (0–100) reflects the share of web traffic from this IP that Scamalytics suspects to be fraudulent.",
    ),
    "ipRiskNoteIndirect": m25,
    "ipRiskNoteOwner": MessageLookupByLibrary.simpleMessage("Owner"),
    "ipRiskNoteProxying": MessageLookupByLibrary.simpleMessage(
      "May be relaying traffic from elsewhere; the actual user could be anywhere",
    ),
    "ipRiskNoteShare": MessageLookupByLibrary.simpleMessage("Suspected fraud"),
    "ipRiskNoteTitle": MessageLookupByLibrary.simpleMessage(
      "About the fraud score",
    ),
    "ipRiskNoteWarningHigh": MessageLookupByLibrary.simpleMessage(
      "Web traffic from this IP is likely to come from fraudsters.",
    ),
    "ipRiskNoteWarningVeryHigh": MessageLookupByLibrary.simpleMessage(
      "Web traffic from this IP is very likely to come from fraudsters.",
    ),
    "ipRiskProxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "ipRiskPublicProxy": MessageLookupByLibrary.simpleMessage("Public proxy"),
    "ipRiskResidentialProxy": MessageLookupByLibrary.simpleMessage(
      "Residential proxy",
    ),
    "ipRiskScore": MessageLookupByLibrary.simpleMessage("Fraud score"),
    "ipRiskSearchRobot": MessageLookupByLibrary.simpleMessage(
      "Search engine robot",
    ),
    "ipRiskServer": MessageLookupByLibrary.simpleMessage("Server"),
    "ipRiskShareAlmostAll": MessageLookupByLibrary.simpleMessage("Almost all"),
    "ipRiskShareLittle": MessageLookupByLibrary.simpleMessage("Very little"),
    "ipRiskShareSome": MessageLookupByLibrary.simpleMessage("Some"),
    "ipRiskSource": MessageLookupByLibrary.simpleMessage("Source"),
    "ipRiskTorExit": MessageLookupByLibrary.simpleMessage("Tor exit node"),
    "ipRiskVeryHigh": MessageLookupByLibrary.simpleMessage("Very high risk"),
    "ipRiskWebProxy": MessageLookupByLibrary.simpleMessage("Web proxy"),
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
    "iperfErrorPortInUse": m26,
    "iperfErrorProtocol": MessageLookupByLibrary.simpleMessage(
      "Unexpected response. The other side may not be an iPerf3 server",
    ),
    "iperfErrorRefused": MessageLookupByLibrary.simpleMessage(
      "Connection refused. Make sure the iPerf3 server is running",
    ),
    "iperfErrorServer": m27,
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
    "iperfLostPackets": m28,
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
    "iperfScanned": m29,
    "iperfSeconds": m30,
    "iperfSend": MessageLookupByLibrary.simpleMessage("Send"),
    "iperfServer": MessageLookupByLibrary.simpleMessage("Server"),
    "iperfServerListening": m31,
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
    "iperfStreams": m32,
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
    "itemsCount": m33,
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
    "largeRuleSetTip": MessageLookupByLibrary.simpleMessage(
      "Large rule sets use more memory",
    ),
    "lastEdit": MessageLookupByLibrary.simpleMessage("Last edited"),
    "lastGenerated": MessageLookupByLibrary.simpleMessage("Last generated"),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "leftClickBehavior": MessageLookupByLibrary.simpleMessage("Left Click"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "limitedUnlock": MessageLookupByLibrary.simpleMessage("Originals Only"),
    "lineWrap": MessageLookupByLibrary.simpleMessage("Wrap Lines"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup data locally",
    ),
    "localFile": MessageLookupByLibrary.simpleMessage("Local File"),
    "localPing": MessageLookupByLibrary.simpleMessage("Local Ping"),
    "localPingAverage": MessageLookupByLibrary.simpleMessage("Average"),
    "localPingBytes": m34,
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
    "localPingFrom": m35,
    "localPingGateway": MessageLookupByLibrary.simpleMessage("Gateway"),
    "localPingListLimit": m36,
    "localPingMax": MessageLookupByLibrary.simpleMessage("Max"),
    "localPingMin": MessageLookupByLibrary.simpleMessage("Min"),
    "localPingReady": MessageLookupByLibrary.simpleMessage(
      "Choose a target to start",
    ),
    "localPingReceived": MessageLookupByLibrary.simpleMessage("Received"),
    "localPingResolving": MessageLookupByLibrary.simpleMessage("Resolving"),
    "localPingResult": MessageLookupByLibrary.simpleMessage("Ping result"),
    "localPingRttSummary": m37,
    "localPingRunning": MessageLookupByLibrary.simpleMessage("Pinging"),
    "localPingSent": MessageLookupByLibrary.simpleMessage("Sent"),
    "localPingSize": MessageLookupByLibrary.simpleMessage("Packet size"),
    "localPingStart": MessageLookupByLibrary.simpleMessage("Start ping"),
    "localPingStats": m38,
    "localPingSummary": m39,
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
    "logLevelDebugHint": m40,
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
    "managedBundled": m41,
    "managedMode": MessageLookupByLibrary.simpleMessage("Managed mode"),
    "managedModeDesc": MessageLookupByLibrary.simpleMessage(
      "Generate proxy groups and rules with the built-in script",
    ),
    "managedOptions": MessageLookupByLibrary.simpleMessage("Default options"),
    "managedOptionsDesc": m42,
    "managedRestoreTip": MessageLookupByLibrary.simpleMessage(
      "Restore the built-in script and regenerate all merged subscriptions?",
    ),
    "managedSyncTip": MessageLookupByLibrary.simpleMessage(
      "Download the latest script from upstream and regenerate all merged subscriptions?",
    ),
    "managedSynced": m43,
    "managedUpToDate": MessageLookupByLibrary.simpleMessage(
      "Already up to date",
    ),
    "managedVersion": MessageLookupByLibrary.simpleMessage("Version"),
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
    "mediaBatchSummary": m44,
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
    "memoryAlreadyOptimal": MessageLookupByLibrary.simpleMessage(
      "Memory already optimal",
    ),
    "memoryAndRuntime": MessageLookupByLibrary.simpleMessage(
      "Memory & Runtime",
    ),
    "memoryFreed": m45,
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "The current memory information value displayed is the dynamic stack memory usage of the core during runtime, not the complete APP memory statistics, for reference only.",
    ),
    "mergeProfile": MessageLookupByLibrary.simpleMessage("Subscription merge"),
    "mergeProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Merge multiple subscriptions and manage routing in one place",
    ),
    "mergeProfileUnavailable": MessageLookupByLibrary.simpleMessage(
      "At least two profiles are needed to merge",
    ),
    "merged": MessageLookupByLibrary.simpleMessage("Merged"),
    "mergedSubscriptionName": m46,
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
    "minutes": m47,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "months": m48,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage("More IP Information"),
    "mrsCopyUrl": MessageLookupByLibrary.simpleMessage("Copy URL"),
    "mrsLookup": MessageLookupByLibrary.simpleMessage("MRS Lookup"),
    "mrsLookupDesc": MessageLookupByLibrary.simpleMessage(
      "Find the GEO / RULE-SET rule sets for a domain or IP",
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
    "mrsRules": m49,
    "mrsTapAction": MessageLookupByLibrary.simpleMessage("Tap action"),
    "mrsVia": m50,
    "mrsViewRules": MessageLookupByLibrary.simpleMessage("View rules"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameSort": MessageLookupByLibrary.simpleMessage("Sort by Name"),
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
    "newLogsCount": m51,
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
    "noNodePrefix": MessageLookupByLibrary.simpleMessage("No prefix"),
    "noProxy": MessageLookupByLibrary.simpleMessage("No Proxy"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Please create or add a valid profile",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("No Resolve"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage("No Status"),
    "noUsageData": MessageLookupByLibrary.simpleMessage("No usage data"),
    "node": MessageLookupByLibrary.simpleMessage("Node"),
    "nodeExclusion": MessageLookupByLibrary.simpleMessage("Node Exclusion"),
    "nodeExclusionDesc": MessageLookupByLibrary.simpleMessage(
      "Exclude all matched nodes",
    ),
    "nodeExclusionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "HK|Hong Kong|🇭🇰",
    ),
    "nodePrefix": MessageLookupByLibrary.simpleMessage("Node prefix"),
    "nodePrefixValue": m52,
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
    "nullTip": m53,
    "numberRangeInvalid": m54,
    "numberTip": m55,
    "oneColumn": MessageLookupByLibrary.simpleMessage("1 Column"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("Online Panel"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon Only"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "Third-Party Apps Only",
    ),
    "onlyShow": m56,
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
    "portTip": m57,
    "pouringHourGlass": MessageLookupByLibrary.simpleMessage(
      "Pouring Hourglass",
    ),
    "pouringHourGlassRefined": MessageLookupByLibrary.simpleMessage(
      "Refined Hourglass",
    ),
    "powerSwitch": MessageLookupByLibrary.simpleMessage("Power"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Press a key"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "privateIp": MessageLookupByLibrary.simpleMessage(
      "Private / LAN IP Address",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "processPath": MessageLookupByLibrary.simpleMessage("Process Path"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAndRules": MessageLookupByLibrary.simpleMessage("Profile & Rules"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter update interval"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Profile modified. Disable auto-update?",
    ),
    "profileImportFailed": m58,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a profile name",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "Profile parse error",
    ),
    "profileSwitchMode": MessageLookupByLibrary.simpleMessage(
      "Profile Switching",
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
    "providersCount": m59,
    "provinceAndCity": MessageLookupByLibrary.simpleMessage("Province / City"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Proxy Settings"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy Chains"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy Group"),
    "proxyGroupsCount": MessageLookupByLibrary.simpleMessage("Proxy Groups"),
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
      "Close connections on network change or node switch",
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
    "regenerate": MessageLookupByLibrary.simpleMessage("Regenerate"),
    "reject": MessageLookupByLibrary.simpleMessage("Block"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("Remaining"),
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
    "restoreBundled": MessageLookupByLibrary.simpleMessage(
      "Restore built-in version",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "rightClickBehavior": MessageLookupByLibrary.simpleMessage("Right Click"),
    "ring": MessageLookupByLibrary.simpleMessage("Ring"),
    "ripple": MessageLookupByLibrary.simpleMessage("Ripple"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("Rotating Circle"),
    "rotatingPlain": MessageLookupByLibrary.simpleMessage("Rotating Plain"),
    "routeAddCount": m60,
    "routeCategoryAi": MessageLookupByLibrary.simpleMessage("AI"),
    "routeCategoryDeveloper": MessageLookupByLibrary.simpleMessage("Developer"),
    "routeCategoryFinance": MessageLookupByLibrary.simpleMessage("Finance"),
    "routeCategoryGaming": MessageLookupByLibrary.simpleMessage("Gaming"),
    "routeCategorySocial": MessageLookupByLibrary.simpleMessage("Social"),
    "routeCategoryStreaming": MessageLookupByLibrary.simpleMessage("Streaming"),
    "routeCategoryTech": MessageLookupByLibrary.simpleMessage("Tech"),
    "routeNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Name cannot contain commas or line breaks",
    ),
    "routeRemoveCount": m61,
    "routeTarget": MessageLookupByLibrary.simpleMessage("Default target"),
    "routeTrace": MessageLookupByLibrary.simpleMessage("Route Trace"),
    "routeTraceChain": MessageLookupByLibrary.simpleMessage("Proxy Chain"),
    "routeTraceCheckedRules": MessageLookupByLibrary.simpleMessage(
      "Checked Rules",
    ),
    "routeTraceDesc": MessageLookupByLibrary.simpleMessage(
      "See how the core resolves and matches a domain or IP",
    ),
    "routeTraceDns": MessageLookupByLibrary.simpleMessage("DNS Resolution"),
    "routeTraceDnsBy": m62,
    "routeTraceDnsIp": MessageLookupByLibrary.simpleMessage(
      "The target is an IP, no resolution needed",
    ),
    "routeTraceDnsSkipped": MessageLookupByLibrary.simpleMessage(
      "No IP resolution was needed while matching",
    ),
    "routeTraceFinal": MessageLookupByLibrary.simpleMessage("Final Outbound"),
    "routeTraceHint": MessageLookupByLibrary.simpleMessage("Domain, IP or URL"),
    "routeTraceHostsHit": m63,
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
    "routeTraceRulesSummary": m64,
    "routeTraceRulesTotal": m65,
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
    "ruleCount": m66,
    "ruleCountIncluded": m67,
    "ruleHits": MessageLookupByLibrary.simpleMessage("Rule hits"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule Name"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule Providers"),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage(
      "Rule Providers",
    ),
    "ruleSets": MessageLookupByLibrary.simpleMessage("Rule sets"),
    "ruleSort": MessageLookupByLibrary.simpleMessage("Rule Order"),
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
    "searchIcons": MessageLookupByLibrary.simpleMessage("Search icons"),
    "searchRuleSets": MessageLookupByLibrary.simpleMessage("Search rule sets"),
    "searchServices": MessageLookupByLibrary.simpleMessage("Search services"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "Secret copied to clipboard",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
    "selectBackupVersion": MessageLookupByLibrary.simpleMessage(
      "Select Backup Version",
    ),
    "selectIcon": MessageLookupByLibrary.simpleMessage("Select icon"),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m68,
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
      "Show Hidden Groups",
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
    "sniffHost": MessageLookupByLibrary.simpleMessage("Sniffed Host"),
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
    "speedTestConnectionsDesc": m69,
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
    "speedTestErrorBlockedDesc": m70,
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
    "speedTestProtocolFallback": m71,
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
    "speedTestStreams": m72,
    "speedTestSwitchProvider": m73,
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
    "subdomains": MessageLookupByLibrary.simpleMessage("Subdomains"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "switchLabel": MessageLookupByLibrary.simpleMessage("Switch"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "syncAll": MessageLookupByLibrary.simpleMessage("Sync All"),
    "syncDelayAnimation": MessageLookupByLibrary.simpleMessage(
      "Sync animation to other pages",
    ),
    "syncFailed": MessageLookupByLibrary.simpleMessage("Sync Failed"),
    "syncFromUpstream": MessageLookupByLibrary.simpleMessage(
      "Sync from upstream",
    ),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System App"),
    "systemDns": MessageLookupByLibrary.simpleMessage("DNS"),
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
      "Set theme color options",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("This Month"),
    "thisWeek": MessageLookupByLibrary.simpleMessage("This Week"),
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
    "today": MessageLookupByLibrary.simpleMessage("Today"),
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
    "trafficRanking": MessageLookupByLibrary.simpleMessage("Ranking"),
    "trafficStatsClearTip": MessageLookupByLibrary.simpleMessage(
      "Clear all traffic statistics?",
    ),
    "trafficStatsDesc": MessageLookupByLibrary.simpleMessage(
      "See exactly where your traffic goes by day, week and month",
    ),
    "trafficStatsDetail": MessageLookupByLibrary.simpleMessage(
      "Record details",
    ),
    "trafficStatsDetailDesc": MessageLookupByLibrary.simpleMessage(
      "Record domains, processes, nodes and rules. When off, only totals are kept",
    ),
    "trafficStatsDisabledTip": MessageLookupByLibrary.simpleMessage(
      "Off by default. Once on, traffic is recorded on this device only",
    ),
    "trafficStatsEnable": MessageLookupByLibrary.simpleMessage(
      "Traffic statistics",
    ),
    "trafficStatsRetention": MessageLookupByLibrary.simpleMessage(
      "Data retention",
    ),
    "trafficStatsSiteIcon": MessageLookupByLibrary.simpleMessage(
      "Show site icons",
    ),
    "trafficStatsSiteIconDesc": MessageLookupByLibrary.simpleMessage(
      "Fetch icons from the sites first, use Google\'s icon service when a site has no sharp icon, and cache them locally",
    ),
    "trafficTrend": MessageLookupByLibrary.simpleMessage("Trend"),
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
    "urlTip": m74,
    "usageStyle": MessageLookupByLibrary.simpleMessage("Usage Style"),
    "usageStyleBar": MessageLookupByLibrary.simpleMessage("Bars"),
    "usageStyleConcentric": MessageLookupByLibrary.simpleMessage(
      "Concentric Rings",
    ),
    "usageStyleRing": MessageLookupByLibrary.simpleMessage("Rings"),
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "Script per Profile",
    ),
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
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist Mode"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Write to System"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Requires administrator privileges",
    ),
    "xattrUnsupportedFallback": MessageLookupByLibrary.simpleMessage(
      "The filesystem does not support file capabilities, falling back to setuid",
    ),
    "years": m75,
  };
}
