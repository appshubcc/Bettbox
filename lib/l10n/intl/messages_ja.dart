// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(log) => "Bettbox(Mihomo)のログを分析:${log}";

  static String m1(error) => "自動バックアップに失敗しました：${error}";

  static String m2(value) => "平均 ${value}";

  static String m3(count) => "${Intl.plural(count, other: '日')}";

  static String m4(label) => "選択した ${label} を削除しますか？";

  static String m5(label) => "選択した ${label} を削除しますか？";

  static String m6(reason) => "Fake-IP · ${reason}：実 IP を返す";

  static String m7(reason, range) => "Fake-IP · ${reason}：${range} の仮想アドレスを返す";

  static String m8(ips) => "Hosts に一致：${ips} を返す";

  static String m9(outbound) => "「${outbound}」経由、ノードがドメインを解決";

  static String m10(outbound) => "「${outbound}」経由、ノードがドメインを解決（Hosts は無効）";

  static String m11(label) => "${label} は必須項目です";

  static String m12(label) => "${label} はすでに存在します";

  static String m13(count) => "${Intl.plural(count, other: '時間')}";

  static String m14(port) => "ポート ${port} は使用中です。別のポートを指定してください";

  static String m15(code) => "サーバーがテストを拒否しました（エラー ${code}）";

  static String m16(lost, total) => "${lost}/${total} パケット";

  static String m17(name) => "スキャン済み：${name}";

  static String m18(value) => "${value} 秒";

  static String m19(port) => "ポート ${port} で待機中";

  static String m20(count) => "${count} ストリーム";

  static String m21(count) => "${count}";

  static String m22(count) => "${count} バイト";

  static String m23(address) => "${address} から";

  static String m24(count) => "最新 ${count} 件のみ表示。結果をコピーすると全件を確認できます";

  static String m25(min, avg, max, jitter) =>
      "往復時間：最短 ${min} / 平均 ${avg} / 最長 ${max} / ジッター ${jitter} ms";

  static String m26(target) => "${target} の Ping 統計";

  static String m27(sent, received, lost, loss) =>
      "送信 ${sent}、受信 ${received}、損失 ${lost}（${loss}% 損失）";

  static String m28(level) => "${level}モードはネットワークのデバッグ向けです。普段はオフにすることをおすすめします";

  static String m29(done, total, unlocked) =>
      "${done}/${total} 検査済み · 利用可 ${unlocked}";

  static String m30(count) => "${Intl.plural(count, other: '分')}";

  static String m31(count) => "${Intl.plural(count, other: 'ヶ月')}";

  static String m32(count) => "${count} 件";

  static String m33(ip) => "${ip} で一致";

  static String m34(count) => "新しいログ ${count} 件";

  static String m35(label) => "${label} はありません";

  static String m36(min, max) => "${min}～${max} の整数を入力してください";

  static String m37(label) => "${label} は数値である必要があります";

  static String m38(label) => "${label} のみ表示";

  static String m39(label) => "${label} は1024〜49151の範囲で指定してください（0で無効）";

  static String m40(statusCode) =>
      "プロファイルのインポートに失敗しました。通信状態を確認するかURLをリセットしてください ( HTTPエラーコード: ${statusCode} )";

  static String m41(index, time) => "ルール #${index} で解決 · ${time} ms";

  static String m42(ips) => "Hosts に一致: ${ips}";

  static String m43(total, index) => "全 ${total} 件中 #${index} に一致";

  static String m44(total) => "全 ${total} 件のルール";

  static String m45(count) => "${count} 件選択中";

  static String m46(count) => "マルチは ${count} 本の並列接続で帯域を使い切ります";

  static String m47(provider) =>
      "アウトバウンドが ${provider} の速度テストをブロックしている可能性があります。測定元またはアウトバウンドを変更してください。";

  static String m48(protocol, fallback) =>
      "${protocol} が利用できないため ${fallback} に切り替えました";

  static String m49(count) => "${count} 接続";

  static String m50(provider) => "${provider} に切り替え";

  static String m51(online, total) => "${online} / ${total} オンライン";

  static String m52(region) => "リレー ${region}";

  static String m53(label) => "${label} は有効なURLである必要があります";

  static String m54(count) => "${Intl.plural(count, other: '年')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "accessControl": MessageLookupByLibrary.simpleMessage("アクセス制御"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリのみVPN経由で通信",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage("アプリのアクセスリスト設定"),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリをVPN対象外に設定",
    ),
    "account": MessageLookupByLibrary.simpleMessage("アカウント"),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "action_mode": MessageLookupByLibrary.simpleMessage("モード切替"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "action_start": MessageLookupByLibrary.simpleMessage("開始 / 停止"),
    "action_tun": MessageLookupByLibrary.simpleMessage("仮想NIC (TUN)"),
    "action_view": MessageLookupByLibrary.simpleMessage("表示 / 非表示"),
    "activeGoroutines": MessageLookupByLibrary.simpleMessage("Goroutines"),
    "add": MessageLookupByLibrary.simpleMessage("追加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("プロファイル追加"),
    "addRule": MessageLookupByLibrary.simpleMessage("ルール追加"),
    "addTunnel": MessageLookupByLibrary.simpleMessage("転送追加"),
    "addUser": MessageLookupByLibrary.simpleMessage("ユーザーを追加"),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage("元のルールに追加"),
    "address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAVサーバーアドレス"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "有効なWebDAVアドレスを入力してください",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage("管理者権限で自動起動"),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "管理者モードでOS起動時に自動開始",
    ),
    "advancedSettings": MessageLookupByLibrary.simpleMessage("高度な設定"),
    "ageCipherText": MessageLookupByLibrary.simpleMessage(
      "暗号文（-----BEGIN AGE ENCRYPTED FILE-----）",
    ),
    "ageDecryptFailed": MessageLookupByLibrary.simpleMessage("復号に失敗しました"),
    "ageEncryptFailed": MessageLookupByLibrary.simpleMessage("暗号化に失敗しました"),
    "ageFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "ファイルが大きすぎます（最大 8 MB）",
    ),
    "ageGenerateKeyPair": MessageLookupByLibrary.simpleMessage("新しい鍵ペア"),
    "ageInputRequired": MessageLookupByLibrary.simpleMessage(
      "内容を入力するかファイルを選択してください",
    ),
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage("Age Key 生成"),
    "ageKeyHybridTip": MessageLookupByLibrary.simpleMessage(
      "耐量子ハイブリッド鍵です。より安全ですが、公開鍵が長く、age v1.3 以降が必要です。",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "X25519鍵ペアを生成しました。大切に保管してください",
    ),
    "ageKeyType": MessageLookupByLibrary.simpleMessage("鍵の種類"),
    "ageNotEncrypted": MessageLookupByLibrary.simpleMessage("Age 暗号化形式ではありません"),
    "ageOutput": MessageLookupByLibrary.simpleMessage("結果"),
    "agePlainText": MessageLookupByLibrary.simpleMessage("平文"),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage("Age 秘密鍵"),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "正しいAge秘密鍵を先に入力してください",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage("Age 公開鍵"),
    "ageRecipientRequired": MessageLookupByLibrary.simpleMessage(
      "受信者の公開鍵を 1 つ以上入力してください",
    ),
    "ageRecipients": MessageLookupByLibrary.simpleMessage("受信者の公開鍵"),
    "ageRecipientsHint": MessageLookupByLibrary.simpleMessage(
      "複数可、1 行に 1 つの age1… 鍵",
    ),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効な Age 秘密鍵を入力してください (AGE-SECRET-KEY- で始まる必要があります)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage("Age 秘密鍵（任意）"),
    "ageTabDecrypt": MessageLookupByLibrary.simpleMessage("復号"),
    "ageTabEncrypt": MessageLookupByLibrary.simpleMessage("暗号化"),
    "ageTabKeys": MessageLookupByLibrary.simpleMessage("鍵"),
    "ageTool": MessageLookupByLibrary.simpleMessage("Age 暗号化・復号"),
    "ageToolDesc": MessageLookupByLibrary.simpleMessage("鍵の生成、テキストや設定の暗号化・復号"),
    "ageToolTip": MessageLookupByLibrary.simpleMessage(
      "すべて端末内で処理され、秘密鍵は保存・送信されません。",
    ),
    "ageUseForEncrypt": MessageLookupByLibrary.simpleMessage("暗号化に使用"),
    "ageUseProfileKey": MessageLookupByLibrary.simpleMessage("現在の設定の秘密鍵を使用"),
    "ago": MessageLookupByLibrary.simpleMessage("前"),
    "agree": MessageLookupByLibrary.simpleMessage("同意する"),
    "allApps": MessageLookupByLibrary.simpleMessage("すべてのアプリ"),
    "allocatedMemory": MessageLookupByLibrary.simpleMessage("割当済"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("VPN迂回を許可"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage("特定アプリのVPN迂回接続を許可"),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN共有"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("LAN経由でのプロキシ接続を許可"),
    "alreadyInWhitelist": MessageLookupByLibrary.simpleMessage(
      "すでに最適化除外リストに登録されています",
    ),
    "alwaysShowTitleBar": MessageLookupByLibrary.simpleMessage("タイトルボタン"),
    "alwaysShowTitleBarDesc": MessageLookupByLibrary.simpleMessage(
      "右上タイトルバーのボタンを常に表示",
    ),
    "analyzeLogPrompt": m0,
    "app": MessageLookupByLibrary.simpleMessage("アプリ"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("アプリのアクセス制御"),
    "appDesc": MessageLookupByLibrary.simpleMessage("アプリ設定を管理"),
    "application": MessageLookupByLibrary.simpleMessage("アプリケーション"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage("アプリ設定の変更"),
    "authorized": MessageLookupByLibrary.simpleMessage("認証済み"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoBackup": MessageLookupByLibrary.simpleMessage("自動バックアップ"),
    "autoBackupDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル変更時に自動バックアップ",
    ),
    "autoBackupFailed": m1,
    "autoBackupSuccess": MessageLookupByLibrary.simpleMessage(
      "WebDAV に自動バックアップしました",
    ),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("自動更新確認"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "起動時にアップデートを自動確認",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("接続の自動切断"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "ノード切り替え時に既存接続を自動切断",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自動起動"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage("OS起動時にアプリを自動開始"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自動接続"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("アプリ起動時に自動でプロキシに接続"),
    "autoScroll": MessageLookupByLibrary.simpleMessage("自動スクロール"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを自動設定"),
    "autoStickyHeader": MessageLookupByLibrary.simpleMessage("自動固定ヘッダー"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔（分）"),
    "back": MessageLookupByLibrary.simpleMessage("戻る"),
    "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVまたはローカルでデータを同期",
    ),
    "backupEncryptedTip": MessageLookupByLibrary.simpleMessage(
      "AES-256 でバックアップを暗号化しました",
    ),
    "backupPassword": MessageLookupByLibrary.simpleMessage("バックアップパスワード"),
    "backupPasswordDesc": MessageLookupByLibrary.simpleMessage(
      "AES-256で暗号化（空欄で暗号化なし）",
    ),
    "backupPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "このバックアップは暗号化されています。パスワードを入力してください",
    ),
    "backupPasswordTip": MessageLookupByLibrary.simpleMessage(
      "英字、数字、記号のみ使用できます",
    ),
    "backupPasswordWrong": MessageLookupByLibrary.simpleMessage(
      "バックアップパスワードが正しくありません",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("バックアップ成功"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("カーネル設定"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage("カーネル設定をグローバル変更"),
    "batteryOptimization": MessageLookupByLibrary.simpleMessage("バッテリー最適化"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "バッテリー最適化の除外権限をリクエスト",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("連携"),
    "blacklist": MessageLookupByLibrary.simpleMessage("ブラックリスト"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("ブラックリストモード"),
    "blockComment": MessageLookupByLibrary.simpleMessage("コメント"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("バイパスドメイン"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage("システムプロキシ有効時のみ適用"),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "プライベートネットワークをバイパス",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルIP（プライベートIP）を自動バイパス",
    ),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("キャッシュアルゴリズム"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "キャッシュが破損しています。クリアしますか？",
    ),
    "cameraPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "カメラ権限が拒否されました",
    ),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QRスキャンにはカメラ権限が必要です。設定から許可してください。",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "システムアプリ除外を解除",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("全選択解除"),
    "categoryAi": MessageLookupByLibrary.simpleMessage("AI"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("すべて"),
    "categoryChina": MessageLookupByLibrary.simpleMessage("中国直通"),
    "categoryCrypto": MessageLookupByLibrary.simpleMessage("暗号資産"),
    "categoryDeveloper": MessageLookupByLibrary.simpleMessage("開発者"),
    "categoryGaming": MessageLookupByLibrary.simpleMessage("ゲームセンター"),
    "categorySocial": MessageLookupByLibrary.simpleMessage("コミュニティ"),
    "categoryStreaming": MessageLookupByLibrary.simpleMessage("動画配信"),
    "chasingDots": MessageLookupByLibrary.simpleMessage("チェイシングドット"),
    "checkError": MessageLookupByLibrary.simpleMessage("確認失敗"),
    "checkFailed": MessageLookupByLibrary.simpleMessage("Timeout"),
    "checkOrAddProfile": MessageLookupByLibrary.simpleMessage(
      "最初にプロファイルを追加してください",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("更新の確認"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("最新バージョンを使用中です"),
    "checking": MessageLookupByLibrary.simpleMessage("確認中..."),
    "circle": MessageLookupByLibrary.simpleMessage("サークル"),
    "clear": MessageLookupByLibrary.simpleMessage("消去"),
    "clearCacheDesc": MessageLookupByLibrary.simpleMessage(
      "FakeIPとDNSキャッシュをクリアしますか？",
    ),
    "clearCacheTitle": MessageLookupByLibrary.simpleMessage("キャッシュ削除"),
    "clearData": MessageLookupByLibrary.simpleMessage("データ消去"),
    "clearDataTipDesc": MessageLookupByLibrary.simpleMessage(
      "アプリのすべての設定がリセットされます。バックアップを確認してください。続行しますか？",
    ),
    "clearDataTipTitle": MessageLookupByLibrary.simpleMessage("危険な操作"),
    "clearFilter": MessageLookupByLibrary.simpleMessage("フィルターをクリア"),
    "clipboard": MessageLookupByLibrary.simpleMessage("クリップボード"),
    "clipboardDesc": MessageLookupByLibrary.simpleMessage("クリップボードからURLを自動取得"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("クリップボードへ書き出し"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("クリップボードから取り込み"),
    "close": MessageLookupByLibrary.simpleMessage("閉じる"),
    "closeAll": MessageLookupByLibrary.simpleMessage("すべて閉じる"),
    "collapse": MessageLookupByLibrary.simpleMessage("折りたたむ"),
    "color": MessageLookupByLibrary.simpleMessage("カラー"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("カラーパレット"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "compatible": MessageLookupByLibrary.simpleMessage("互換モード"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "一部の独自機能を無効化しClash完全互換で動作",
    ),
    "concurrencyLimit": MessageLookupByLibrary.simpleMessage("並行テスト制限"),
    "concurrencyLimitDesc": MessageLookupByLibrary.simpleMessage(
      "レイテンシテストの最大並行数",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("確定"),
    "congestionController": MessageLookupByLibrary.simpleMessage("輻輳制御"),
    "connection": MessageLookupByLibrary.simpleMessage("アクティブ接続"),
    "connections": MessageLookupByLibrary.simpleMessage("接続"),
    "connectionsActive": MessageLookupByLibrary.simpleMessage("アクティブ"),
    "connectionsClosed": MessageLookupByLibrary.simpleMessage("終了済み"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "アクティブおよび終了済みの接続を表示",
    ),
    "connectionsSort": MessageLookupByLibrary.simpleMessage("接続並び替え"),
    "connectivity": MessageLookupByLibrary.simpleMessage("接続性："),
    "contactMe": MessageLookupByLibrary.simpleMessage("お問い合わせ"),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("コンテンツテーマ"),
    "continent": MessageLookupByLibrary.simpleMessage("大陸"),
    "controlSecret": MessageLookupByLibrary.simpleMessage("制御パスワード"),
    "controlSecretDesc": MessageLookupByLibrary.simpleMessage(
      "RESTful APIアクセスパスワード",
    ),
    "copiedPackageName": MessageLookupByLibrary.simpleMessage("パッケージ名をコピーしました"),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "クリップボードにコピーしました",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("コピー"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("環境変数をコピー"),
    "copyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("コピー成功"),
    "core": MessageLookupByLibrary.simpleMessage("カーネル"),
    "coreCapabilityNotEffective": MessageLookupByLibrary.simpleMessage(
      "コアの権限付与が有効になっていません：実行中のコアに CAP_NET_ADMIN がなく、TUN が動作しない可能性があります",
    ),
    "coreConnected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("カーネル情報"),
    "coreMountNosuid": MessageLookupByLibrary.simpleMessage(
      "コアが nosuid でマウントされたファイルシステム上にあるため、ファイルケーパビリティと setuid は有効になりません",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("コア負荷詳細"),
    "coreSuspended": MessageLookupByLibrary.simpleMessage("一時停止中"),
    "country": MessageLookupByLibrary.simpleMessage("地域"),
    "countryOrRegion": MessageLookupByLibrary.simpleMessage("国 / 地域"),
    "crashTest": MessageLookupByLibrary.simpleMessage("クラッシュテスト"),
    "create": MessageLookupByLibrary.simpleMessage("作成"),
    "creationTime": MessageLookupByLibrary.simpleMessage("作成日時"),
    "cubeGrid": MessageLookupByLibrary.simpleMessage("キューブグリッド"),
    "custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage("カスタムタイトル"),
    "customScriptOptions": MessageLookupByLibrary.simpleMessage("カスタムルール"),
    "customUrl": MessageLookupByLibrary.simpleMessage("カスタムURL"),
    "cut": MessageLookupByLibrary.simpleMessage("切り取り"),
    "dancingSquare": MessageLookupByLibrary.simpleMessage("ダンシングスクエア"),
    "dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "darkIcon": MessageLookupByLibrary.simpleMessage("ダークアイコン"),
    "darkIconDesc": MessageLookupByLibrary.simpleMessage("アプリアイコンをダーク系に切り替え"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ホーム"),
    "dashboardAverage": m2,
    "dashboardTotal": MessageLookupByLibrary.simpleMessage("合計"),
    "days": m3,
    "defaultGateway": MessageLookupByLibrary.simpleMessage("ゲートウェイ"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("デフォルトDNSサーバー"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage("DNSサーバーの解決"),
    "defaultSort": MessageLookupByLibrary.simpleMessage("デフォルト順"),
    "defaultText": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "delay": MessageLookupByLibrary.simpleMessage("レイテンシ"),
    "delayAnimation": MessageLookupByLibrary.simpleMessage("テストアニメーション"),
    "delayAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "テスト中の表示アニメーションを変更",
    ),
    "delaySort": MessageLookupByLibrary.simpleMessage("レイテンシ順"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteMultipTip": m4,
    "deleteTip": m5,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage("転送削除"),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettboxは強力で柔軟なMihomoカーネルをベースに深く作り込まれ、より優れたクライアント体験を追求しています。私たちのビジョン：Connecting Open Source and AI, Accelerating Innovation",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("宛先アドレス"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("宛先GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("宛先IP ASN"),
    "details": MessageLookupByLibrary.simpleMessage("詳細"),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "サードパーティAPIを使用しているため、参考値です",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("開発者モード"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "開発者モードが有効になりました。",
    ),
    "dialerIp4pConvert": MessageLookupByLibrary.simpleMessage("IP4P変換有効化"),
    "dialerIp4pConvertDesc": MessageLookupByLibrary.simpleMessage(
      "ダイヤラーのIP4P変換を有効化",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("ダイレクト"),
    "directNameserver": MessageLookupByLibrary.simpleMessage("直連用DNS"),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage("直連ドメインの解決"),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "直連DNSもポリシーに従う",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("QUIC無効化"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "特定の通信問題を解決するためQUICを無効化",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("無効"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責事項"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本アプリはオープンソースの無料ソフトウェアであり、個人的な学習・研究目的でのみ提供されています。プロキシ事業者の行為は本アプリと一切関係ありません。",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンが見つかりました",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage("新バージョン検出"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("DNS関連の設定を更新"),
    "dnsHijack": MessageLookupByLibrary.simpleMessage("DNSハイジャック"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "DNSクエリを内部DNSモジュールに引き込み",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNSモード"),
    "dnsQuery": MessageLookupByLibrary.simpleMessage("DNS 検索"),
    "dnsQueryCompare": MessageLookupByLibrary.simpleMessage("比較"),
    "dnsQueryCompareDesc": MessageLookupByLibrary.simpleMessage(
      "ルール・システム DNS・指定サーバーで同時に解決し、汚染や分流の差を確認",
    ),
    "dnsQueryDesc": MessageLookupByLibrary.simpleMessage("ルール・システム・指定サーバーで解決"),
    "dnsQueryFakeIpOff": m6,
    "dnsQueryFakeIpOn": m7,
    "dnsQueryFilterBlackHit": MessageLookupByLibrary.simpleMessage("ブラックリスト該当"),
    "dnsQueryFilterBlackMiss": MessageLookupByLibrary.simpleMessage(
      "ブラックリスト対象外",
    ),
    "dnsQueryFilterRuleFake": MessageLookupByLibrary.simpleMessage(
      "ルール判定 fake-ip",
    ),
    "dnsQueryFilterRuleReal": MessageLookupByLibrary.simpleMessage(
      "ルール判定 real-ip",
    ),
    "dnsQueryFilterWhiteHit": MessageLookupByLibrary.simpleMessage("ホワイトリスト該当"),
    "dnsQueryFilterWhiteMiss": MessageLookupByLibrary.simpleMessage(
      "ホワイトリスト対象外",
    ),
    "dnsQueryHint": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "dnsQueryHostsHit": m8,
    "dnsQueryNoRecords": MessageLookupByLibrary.simpleMessage("レコードなし"),
    "dnsQueryNormalMode": MessageLookupByLibrary.simpleMessage(
      "Normal：実 IP を返し、ルールは IP で照合",
    ),
    "dnsQueryRedirHost": MessageLookupByLibrary.simpleMessage(
      "Redir-Host：実 IP を返し、接続時にドメインへ復元",
    ),
    "dnsQueryServer": MessageLookupByLibrary.simpleMessage("DNS サーバー"),
    "dnsQueryServerHint": MessageLookupByLibrary.simpleMessage(
      "例: 1.1.1.1、https://cloudflare-dns.com/dns-query",
    ),
    "dnsQueryServerInvalid": MessageLookupByLibrary.simpleMessage(
      "DNS サーバーの形式が無効です",
    ),
    "dnsQueryStopped": MessageLookupByLibrary.simpleMessage(
      "プロキシ停止中のため「ルールに従う」は使用できません",
    ),
    "dnsQuerySystem": MessageLookupByLibrary.simpleMessage("システム DNS"),
    "dnsQueryViaDirect": MessageLookupByLibrary.simpleMessage(
      "DIRECT、コアがローカルで解決して直接接続",
    ),
    "dnsQueryViaDirectHosts": MessageLookupByLibrary.simpleMessage(
      "DIRECT、Hosts のアドレスへ直接接続",
    ),
    "dnsQueryViaProxy": m9,
    "dnsQueryViaProxyHosts": m10,
    "dnsQueryViaReject": MessageLookupByLibrary.simpleMessage("ルールで拒否"),
    "dnsResolution": MessageLookupByLibrary.simpleMessage("DNS解決"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage("許可しますか："),
    "domain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "doubleBounce": MessageLookupByLibrary.simpleMessage("ダブルバウンス"),
    "download": MessageLookupByLibrary.simpleMessage("受信"),
    "dozeSuspend": MessageLookupByLibrary.simpleMessage("スリープ連携"),
    "dozeSuspendDesc": MessageLookupByLibrary.simpleMessage(
      "OSのDozeスリープモードに同期",
    ),
    "dualRing": MessageLookupByLibrary.simpleMessage("デュアルリング"),
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("転送編集"),
    "editUser": MessageLookupByLibrary.simpleMessage("ユーザーを編集"),
    "emptyTip": m11,
    "enableCrashReport": MessageLookupByLibrary.simpleMessage("クラッシュ分析"),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "必要に応じてクラッシュログを送信",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage("オーバーライド有効化"),
    "enableTraySpeed": MessageLookupByLibrary.simpleMessage("速度表示"),
    "enableTraySpeedDesc": MessageLookupByLibrary.simpleMessage(
      "メニューバーに通信速度を表示",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("有効"),
    "endpointIndependentNat": MessageLookupByLibrary.simpleMessage("NAT強化"),
    "endpointIndependentNatConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "Endpoint-Independent NATを有効にするとパフォーマンスがわずかに低下する場合があります。必要な場合のみ設定してください",
    ),
    "endpointIndependentNatDesc": MessageLookupByLibrary.simpleMessage(
      "UDP / P2Pアプリの通信体験を最適化",
    ),
    "entries": MessageLookupByLibrary.simpleMessage("件"),
    "exclude": MessageLookupByLibrary.simpleMessage("タスク一覧で非表示"),
    "excludeChina": MessageLookupByLibrary.simpleMessage("中国通信を除外"),
    "excludeChinaDesc": MessageLookupByLibrary.simpleMessage(
      "中国のQUIC通信を許可（他は遮断）",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage("最近のタスク履歴からアプリを隠す"),
    "existsTip": m12,
    "exit": MessageLookupByLibrary.simpleMessage("終了"),
    "expand": MessageLookupByLibrary.simpleMessage("標準"),
    "experimental": MessageLookupByLibrary.simpleMessage("実験的機能"),
    "experimentalDesc": MessageLookupByLibrary.simpleMessage(
      "実験的設定（注意してご使用ください）",
    ),
    "expirationTime": MessageLookupByLibrary.simpleMessage("有効期限"),
    "expired": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "export": MessageLookupByLibrary.simpleMessage("エクスポート"),
    "exportFile": MessageLookupByLibrary.simpleMessage("ファイルをエクスポート"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("ログをエクスポート"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("エクスポート成功"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("エクスプレッシブ"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部制御"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "オンラインポート経由でカーネルを制御",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部リンク"),
    "externalResources": MessageLookupByLibrary.simpleMessage("外部リソース"),
    "fadingCircle": MessageLookupByLibrary.simpleMessage("フェードサークル"),
    "fadingCube": MessageLookupByLibrary.simpleMessage("フェードキューブ"),
    "fadingFour": MessageLookupByLibrary.simpleMessage("フェードフォースクエア"),
    "fadingGrid": MessageLookupByLibrary.simpleMessage("フェードグリッド"),
    "fakeIpFilterMode": MessageLookupByLibrary.simpleMessage("FakeIPフィルターモード"),
    "fakeIpFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "FakeIPフィルターの動作モードを指定",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("FakeIPフィルターリスト"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("FakeIP範囲"),
    "fakeipRangeV6": MessageLookupByLibrary.simpleMessage("FakeIPv6範囲"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("FakeIP TTL"),
    "fallback": MessageLookupByLibrary.simpleMessage("フォールバックDNS"),
    "fallbackConcurrent": MessageLookupByLibrary.simpleMessage("フォールバック並行検索"),
    "fallbackConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "デフォルトDNSとフォールバックDNSを同時に照会",
    ),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("主に海外ドメインの解決に使用"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("フォールバックフィルター"),
    "fast": MessageLookupByLibrary.simpleMessage("速い"),
    "fcmOptimization": MessageLookupByLibrary.simpleMessage("FCM最適化"),
    "fcmOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "FCM直連時の通信安定性を向上",
    ),
    "fcmTip": MessageLookupByLibrary.simpleMessage(
      "FCMの接続は端末環境に依存します。表示結果は参考値です。より正確なテストのため「VPNの迂回を許可」をオフにしてください",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("フィデリティ"),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("ローカル設定ファイルをアップロード"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "ファイルが変更されました。保存しますか？",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage("システムアプリを除外"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("プロセス検索"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名をマッチングして検索",
    ),
    "flagged": MessageLookupByLibrary.simpleMessage("フラグ付き"),
    "flushDnsOnNetworkChange": MessageLookupByLibrary.simpleMessage(
      "DNS キャッシュをクリア",
    ),
    "flushDnsOnNetworkChangeDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワーク変更時に DNS キャッシュをクリア",
    ),
    "foldingCube": MessageLookupByLibrary.simpleMessage("フォールディングキューブ"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("フォント"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("強制DNSマッピング"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "DNSクエリ結果を接続に強制マッピング",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("対象ドメイン"),
    "forceGCDesc": MessageLookupByLibrary.simpleMessage(
      "カーネルのメモリGCを強制実行しますか？（実験的機能）",
    ),
    "forceGCTitle": MessageLookupByLibrary.simpleMessage("強制ガベージコレクション"),
    "formatError": MessageLookupByLibrary.simpleMessage("フォーマットが正しいか確認してください"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("4列"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("フルーツサラダ"),
    "general": MessageLookupByLibrary.simpleMessage("一般"),
    "generalDesc": MessageLookupByLibrary.simpleMessage("全般設定を変更"),
    "generateFromPrivateKey": MessageLookupByLibrary.simpleMessage("秘密鍵から生成"),
    "generateSecret": MessageLookupByLibrary.simpleMessage("生成"),
    "geoBuiltInResources": MessageLookupByLibrary.simpleMessage("GEO 組み込みリソース"),
    "geoData": MessageLookupByLibrary.simpleMessage("Geoデータ"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage("GEO省メモリ"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "メモリ消費を抑えたGEOローダーを使用",
    ),
    "geodataUse": MessageLookupByLibrary.simpleMessage("GEO読込"),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIPコード"),
    "getOriginRules": MessageLookupByLibrary.simpleMessage("元のルールを取得"),
    "global": MessageLookupByLibrary.simpleMessage("グローバル"),
    "go": MessageLookupByLibrary.simpleMessage("移動"),
    "goDownload": MessageLookupByLibrary.simpleMessage("ダウンロードへ"),
    "harmonyFont": MessageLookupByLibrary.simpleMessage("フォント修復"),
    "harmonyFontDesc": MessageLookupByLibrary.simpleMessage(
      "表示異常を改善するため内蔵フォントを使用",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("変更をキャッシュしますか？"),
    "healthCheckTimeout": MessageLookupByLibrary.simpleMessage("タイムアウト時間"),
    "healthCheckTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "ヘルスチェックのタイムアウト時間",
    ),
    "heapObjects": MessageLookupByLibrary.simpleMessage("Objects"),
    "highPriority": MessageLookupByLibrary.simpleMessage("高優先度"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "アプリとコアのプロセス優先度を向上",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage("高リフレッシュレート"),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "最高リフレッシュレートを有効化",
    ),
    "host": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("プロファイルのHostsを追記"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("ショートカットキーの競合"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("ショートカットキー管理"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "キーボードでアプリを操作",
    ),
    "hourGlass": MessageLookupByLibrary.simpleMessage("アワーグラス"),
    "hours": m13,
    "httpPortSniffer": MessageLookupByLibrary.simpleMessage("HTTPポート解析"),
    "icmpForwarding": MessageLookupByLibrary.simpleMessage("ICMP転送"),
    "icmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "有効化するとICMP Pingをサポート",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("画像"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage("画像設定"),
    "iconConfigurationDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシグループのICONアイコンをカスタマイズ",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("アイコンスタイル"),
    "import": MessageLookupByLibrary.simpleMessage("インポート"),
    "importFailed": MessageLookupByLibrary.simpleMessage("インポート失敗"),
    "importFile": MessageLookupByLibrary.simpleMessage("ファイルからインポート"),
    "importFromCode": MessageLookupByLibrary.simpleMessage("コードからインポート"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("無期限"),
    "init": MessageLookupByLibrary.simpleMessage("初期化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "正しいショートカットキーを入力してください",
    ),
    "installTime": MessageLookupByLibrary.simpleMessage("インストール日時"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("スマート選択"),
    "internet": MessageLookupByLibrary.simpleMessage("インターネット"),
    "interval": MessageLookupByLibrary.simpleMessage("間隔"),
    "intranetAndGateway": MessageLookupByLibrary.simpleMessage("LANとゲートウェイ"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("ローカル IP"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage("無効なIPまたはCIDR形式"),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP アドレス"),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage("表示切替"),
    "ipLookup": MessageLookupByLibrary.simpleMessage("IP 検索"),
    "ipLookupDesc": MessageLookupByLibrary.simpleMessage(
      "自分の出口 IP、任意の IP・ドメインを検索",
    ),
    "ipLookupDomesticExit": MessageLookupByLibrary.simpleMessage("国内ローカル IP"),
    "ipLookupHint": MessageLookupByLibrary.simpleMessage("IP またはドメイン"),
    "ipLookupInvalid": MessageLookupByLibrary.simpleMessage(
      "有効な IP またはドメインを入力してください",
    ),
    "ipLookupLocal": MessageLookupByLibrary.simpleMessage("ローカルネットワーク"),
    "ipLookupMine": MessageLookupByLibrary.simpleMessage("自分の IP"),
    "ipLookupProxyExit": MessageLookupByLibrary.simpleMessage("デフォルトノード IP"),
    "ipLookupResolveFailed": MessageLookupByLibrary.simpleMessage(
      "このドメインを解決できません",
    ),
    "ipLookupResult": MessageLookupByLibrary.simpleMessage("検索結果"),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage("IP表示を隠す"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP / サブネットマスク"),
    "iperfAddressHint": MessageLookupByLibrary.simpleMessage(
      "サーバーアドレス（例：192.168.1.5）",
    ),
    "iperfAddressRequired": MessageLookupByLibrary.simpleMessage(
      "サーバーアドレスを入力してください",
    ),
    "iperfAddresses": MessageLookupByLibrary.simpleMessage("このデバイスのアドレス"),
    "iperfBandwidth": MessageLookupByLibrary.simpleMessage("送信レート"),
    "iperfBidir": MessageLookupByLibrary.simpleMessage("双方向"),
    "iperfClient": MessageLookupByLibrary.simpleMessage("クライアント"),
    "iperfCommands": MessageLookupByLibrary.simpleMessage("iperf3 コマンド"),
    "iperfConnecting": MessageLookupByLibrary.simpleMessage("接続中…"),
    "iperfDirection": MessageLookupByLibrary.simpleMessage("方向"),
    "iperfDone": MessageLookupByLibrary.simpleMessage("テスト完了"),
    "iperfDuration": MessageLookupByLibrary.simpleMessage("時間"),
    "iperfErrorBusy": MessageLookupByLibrary.simpleMessage(
      "サーバーは別のテストを実行中です。しばらくしてから再試行してください",
    ),
    "iperfErrorInterrupted": MessageLookupByLibrary.simpleMessage(
      "テストが中断されました",
    ),
    "iperfErrorListen": MessageLookupByLibrary.simpleMessage("サーバーを起動できません"),
    "iperfErrorPortInUse": m14,
    "iperfErrorProtocol": MessageLookupByLibrary.simpleMessage(
      "応答が不正です。相手が iPerf3 サーバーではない可能性があります",
    ),
    "iperfErrorRefused": MessageLookupByLibrary.simpleMessage(
      "接続が拒否されました。相手側で iPerf3 サーバーが起動しているか確認してください",
    ),
    "iperfErrorServer": m15,
    "iperfErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "接続がタイムアウトしました。アドレスとネットワークを確認してください",
    ),
    "iperfErrorUdp": MessageLookupByLibrary.simpleMessage(
      "UDP ハンドシェイクに失敗しました。ファイアウォールでブロックされている可能性があります",
    ),
    "iperfErrorUnreachable": MessageLookupByLibrary.simpleMessage(
      "サーバーに接続できません",
    ),
    "iperfFirewallTip": MessageLookupByLibrary.simpleMessage(
      "他のデバイスから接続できない場合は、システムのファイアウォールで Bettbox コアの受信接続を許可してください。",
    ),
    "iperfLostPackets": m16,
    "iperfNoAddress": MessageLookupByLibrary.simpleMessage(
      "LAN アドレスが見つかりません。Wi-Fi または有線に接続しているか確認してください",
    ),
    "iperfParallel": MessageLookupByLibrary.simpleMessage("並列"),
    "iperfPeer": MessageLookupByLibrary.simpleMessage("相手"),
    "iperfPort": MessageLookupByLibrary.simpleMessage("ポート"),
    "iperfPortInvalid": MessageLookupByLibrary.simpleMessage(
      "1〜65535 のポートを入力してください",
    ),
    "iperfProtocol": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "iperfReady": MessageLookupByLibrary.simpleMessage(
      "サーバーアドレスを入力するか QR コードをスキャンして開始",
    ),
    "iperfReceive": MessageLookupByLibrary.simpleMessage("受信"),
    "iperfResult": MessageLookupByLibrary.simpleMessage("テスト結果"),
    "iperfRetest": MessageLookupByLibrary.simpleMessage("再テスト"),
    "iperfRetransmits": MessageLookupByLibrary.simpleMessage("再送"),
    "iperfRtt": MessageLookupByLibrary.simpleMessage("往復遅延"),
    "iperfRunning": MessageLookupByLibrary.simpleMessage("テスト中"),
    "iperfScan": MessageLookupByLibrary.simpleMessage("スキャンして接続"),
    "iperfScanHint": MessageLookupByLibrary.simpleMessage(
      "別のデバイスの Bettbox でスキャンするとワンタップで接続できます",
    ),
    "iperfScanInvalid": MessageLookupByLibrary.simpleMessage(
      "iPerf3 の接続用 QR コードではありません",
    ),
    "iperfScanned": m17,
    "iperfSeconds": m18,
    "iperfSend": MessageLookupByLibrary.simpleMessage("送信"),
    "iperfServer": MessageLookupByLibrary.simpleMessage("サーバー"),
    "iperfServerListening": m19,
    "iperfServerOff": MessageLookupByLibrary.simpleMessage("サーバーは停止中"),
    "iperfServerOffHint": MessageLookupByLibrary.simpleMessage(
      "起動後、他のデバイスから QR コードを読み取るかアドレスを入力して接続できます",
    ),
    "iperfServerStart": MessageLookupByLibrary.simpleMessage("サーバーを起動"),
    "iperfServerStop": MessageLookupByLibrary.simpleMessage("サーバーを停止"),
    "iperfServerTip": MessageLookupByLibrary.simpleMessage(
      "サーバーはこのページを開いている間だけ動作し、離れると自動で停止します。動作中は画面が消えません。",
    ),
    "iperfStart": MessageLookupByLibrary.simpleMessage("テスト開始"),
    "iperfStreams": m20,
    "iperfTest": MessageLookupByLibrary.simpleMessage("iPerf3 ツール"),
    "iperfTestDesc": MessageLookupByLibrary.simpleMessage(
      "LAN 内のデバイス間の帯域幅を測定（公式 iperf3 互換）",
    ),
    "iperfThroughput": MessageLookupByLibrary.simpleMessage("スループット"),
    "iperfTransferred": MessageLookupByLibrary.simpleMessage("転送量"),
    "iperfUdpUnavailable": MessageLookupByLibrary.simpleMessage(
      "UDP ポートが使用中のため、TCP テストのみ利用できます。",
    ),
    "iperfWaiting": MessageLookupByLibrary.simpleMessage("クライアントの接続を待機中"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("IPv6トラフィックの受信を有効化"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("IPv6インバウンド通信を許可"),
    "isp": MessageLookupByLibrary.simpleMessage("プロバイダ"),
    "itemsCount": m21,
    "just": MessageLookupByLibrary.simpleMessage("たった今"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP Keep-Alive間隔",
    ),
    "keepDockIcon": MessageLookupByLibrary.simpleMessage("Dockに常駐"),
    "keepDockIconDesc": MessageLookupByLibrary.simpleMessage(
      "Dock にアプリアイコンを表示",
    ),
    "key": MessageLookupByLibrary.simpleMessage("キー"),
    "lanSharing": MessageLookupByLibrary.simpleMessage("LAN共有"),
    "language": MessageLookupByLibrary.simpleMessage("言語"),
    "lastEdit": MessageLookupByLibrary.simpleMessage("前回の編集"),
    "layout": MessageLookupByLibrary.simpleMessage("レイアウト"),
    "leftClickBehavior": MessageLookupByLibrary.simpleMessage("左クリック"),
    "light": MessageLookupByLibrary.simpleMessage("ライト"),
    "limitedUnlock": MessageLookupByLibrary.simpleMessage("自作のみ"),
    "lineWrap": MessageLookupByLibrary.simpleMessage("折り返し"),
    "list": MessageLookupByLibrary.simpleMessage("リスト"),
    "listen": MessageLookupByLibrary.simpleMessage("リスニング"),
    "local": MessageLookupByLibrary.simpleMessage("ローカル"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage("ローカルにデータをバックアップ"),
    "localFile": MessageLookupByLibrary.simpleMessage("ローカルファイル"),
    "localPing": MessageLookupByLibrary.simpleMessage("ローカル Ping"),
    "localPingAverage": MessageLookupByLibrary.simpleMessage("平均遅延"),
    "localPingBytes": m22,
    "localPingClosed": MessageLookupByLibrary.simpleMessage("ポート閉鎖"),
    "localPingCount": MessageLookupByLibrary.simpleMessage("回数"),
    "localPingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP・TCP・UDP の遅延とパケットロスを直接測定",
    ),
    "localPingDone": MessageLookupByLibrary.simpleMessage("Ping 完了"),
    "localPingErrorDenied": MessageLookupByLibrary.simpleMessage(
      "このシステムでは ICMP を送信できません。TCP または UDP Ping を使用してください",
    ),
    "localPingErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Ping パケットを送信できません",
    ),
    "localPingErrorResolve": MessageLookupByLibrary.simpleMessage(
      "ドメインを解決できません",
    ),
    "localPingFailed": MessageLookupByLibrary.simpleMessage("送信失敗"),
    "localPingFrom": m23,
    "localPingGateway": MessageLookupByLibrary.simpleMessage("ゲートウェイ"),
    "localPingListLimit": m24,
    "localPingMax": MessageLookupByLibrary.simpleMessage("最長"),
    "localPingMin": MessageLookupByLibrary.simpleMessage("最短"),
    "localPingReady": MessageLookupByLibrary.simpleMessage("対象を選んで開始"),
    "localPingReceived": MessageLookupByLibrary.simpleMessage("受信"),
    "localPingResolving": MessageLookupByLibrary.simpleMessage("名前解決中"),
    "localPingResult": MessageLookupByLibrary.simpleMessage("Ping 結果"),
    "localPingRttSummary": m25,
    "localPingRunning": MessageLookupByLibrary.simpleMessage("Ping 実行中"),
    "localPingSent": MessageLookupByLibrary.simpleMessage("送信"),
    "localPingSize": MessageLookupByLibrary.simpleMessage("パケットサイズ"),
    "localPingStart": MessageLookupByLibrary.simpleMessage("Ping を開始"),
    "localPingStats": m26,
    "localPingSummary": m27,
    "localPingTargetHint": MessageLookupByLibrary.simpleMessage(
      "ドメインまたは IP アドレス",
    ),
    "localPingTcpTip": MessageLookupByLibrary.simpleMessage(
      "TCP Ping は接続確立までの時間を測ります。接続が拒否された場合もホストには到達しています",
    ),
    "localPingTimeout": MessageLookupByLibrary.simpleMessage("タイムアウト"),
    "localPingUdpTip": MessageLookupByLibrary.simpleMessage(
      "ポート 53 では DNS クエリを送信して応答を待ちます。他のポートは多くが応答しないため、タイムアウトでも不通とは限りません",
    ),
    "localPingUnreachable": MessageLookupByLibrary.simpleMessage("宛先に到達できません"),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage("ファイルからデータを復元"),
    "locate": MessageLookupByLibrary.simpleMessage("位置"),
    "log": MessageLookupByLibrary.simpleMessage("ログ"),
    "logAiSearch": MessageLookupByLibrary.simpleMessage("AI 検索"),
    "logLevel": MessageLookupByLibrary.simpleMessage("ログレベル"),
    "logLevelDebugHint": m28,
    "logcat": MessageLookupByLibrary.simpleMessage("ログキャプチャ"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("有効にするとログエントリを表示"),
    "logs": MessageLookupByLibrary.simpleMessage("ログ"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("キャプチャログの確認"),
    "logsTest": MessageLookupByLibrary.simpleMessage("ログテスト"),
    "loopback": MessageLookupByLibrary.simpleMessage("ループバック解除ツール"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("UWPアプリのループバック制限を解除"),
    "loopbackProtection": MessageLookupByLibrary.simpleMessage("ループバック保護"),
    "loopbackProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "エラーによるループバックを遮断",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("ルーズ"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("IPを再取得"),
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "mediaBatchAll": MessageLookupByLibrary.simpleMessage("すべてのノード"),
    "mediaBatchAllDesc": MessageLookupByLibrary.simpleMessage(
      "DIRECT を除くすべてのノード",
    ),
    "mediaBatchGroup": MessageLookupByLibrary.simpleMessage("テスト"),
    "mediaBatchNoNodes": MessageLookupByLibrary.simpleMessage("検査できるノードがありません"),
    "mediaBatchScope": MessageLookupByLibrary.simpleMessage("検査範囲を選択"),
    "mediaBatchSummary": m29,
    "mediaBatchTest": MessageLookupByLibrary.simpleMessage("ノード一括検査"),
    "mediaUnlock": MessageLookupByLibrary.simpleMessage("接続性テスト"),
    "mediaUnlockColorfulIcons": MessageLookupByLibrary.simpleMessage(
      "既定でカラーアイコンを表示",
    ),
    "mediaUnlockDetails": MessageLookupByLibrary.simpleMessage("接続性テスト詳細"),
    "mediaUnlockDisplaySettings": MessageLookupByLibrary.simpleMessage("表示設定"),
    "mediaUnlockExtraDetails": MessageLookupByLibrary.simpleMessage(
      "IP の詳細情報を表示",
    ),
    "mediaUnlockMiscSettings": MessageLookupByLibrary.simpleMessage("その他の設定"),
    "mediaUnlockMoreStreamingPlatforms": MessageLookupByLibrary.simpleMessage(
      "その他のストリーミング解除項目",
    ),
    "mediaUnlockPinnedSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "ウィジェットに最大3項目を固定",
    ),
    "mediaUnlockRefreshByCategory": MessageLookupByLibrary.simpleMessage(
      "現在のカテゴリに基づいて部分更新",
    ),
    "mediaUnlockRefreshOnNodeChange": MessageLookupByLibrary.simpleMessage(
      "ノード変更時に自動更新",
    ),
    "mediaUnlockSelectLimit": MessageLookupByLibrary.simpleMessage(
      "最大3項目まで選択できます",
    ),
    "mediaUnlocked": MessageLookupByLibrary.simpleMessage("ロック解除済み"),
    "memoryAndRuntime": MessageLookupByLibrary.simpleMessage("メモリとランタイム"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("メモリ情報"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "表示されているメモリ値はカーネル動的ヒープの占有量であり、アプリ全体のメモリ統計ではありません（参考値）。",
    ),
    "messageTest": MessageLookupByLibrary.simpleMessage("メッセージテスト"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("テストメッセージです。"),
    "min": MessageLookupByLibrary.simpleMessage("最小"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("終了時に最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "デフォルトのウィンドウ閉じる動作を変更",
    ),
    "minutes": m30,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合ポート (Mixed)"),
    "mode": MessageLookupByLibrary.simpleMessage("モード"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("モノクローム"),
    "months": m31,
    "more": MessageLookupByLibrary.simpleMessage("詳細"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage("詳細 IP 情報"),
    "mrsCopyRawLink": MessageLookupByLibrary.simpleMessage(
      "GitHub Raw リンクとしてコピー",
    ),
    "mrsLookup": MessageLookupByLibrary.simpleMessage("MRS 検索"),
    "mrsLookupDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインや IP が属する GEODATA / RULE-SET を検索",
    ),
    "mrsLookupHint": MessageLookupByLibrary.simpleMessage("ドメインまたは IP"),
    "mrsMissing": MessageLookupByLibrary.simpleMessage("内蔵 BundleMRS が見つかりません"),
    "mrsNoMatch": MessageLookupByLibrary.simpleMessage("一致するルールセットはありません"),
    "mrsPrepareFailed": MessageLookupByLibrary.simpleMessage(
      "ルールセットの読み込みに失敗しました",
    ),
    "mrsReferenced": MessageLookupByLibrary.simpleMessage("設定で使用中"),
    "mrsResolveDns": MessageLookupByLibrary.simpleMessage("DNS ルールでドメインを解決"),
    "mrsResolveDnsDesc": MessageLookupByLibrary.simpleMessage(
      "オンにすると、ドメインを現在の DNS 設定で IP に解決し、その IP も照合します",
    ),
    "mrsRules": m32,
    "mrsVia": m33,
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameSort": MessageLookupByLibrary.simpleMessage("名前順"),
    "nameserver": MessageLookupByLibrary.simpleMessage("ネームサーバー"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("ドメイン名の解決"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("ネームサーバーポリシー"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "特定ドメイン用のDNSポリシーを指定",
    ),
    "natCopyResult": MessageLookupByLibrary.simpleMessage("結果をコピー"),
    "natDescBlocked": MessageLookupByLibrary.simpleMessage(
      "STUN 応答がありません。ファイアウォール、ISP、またはアウトバウンドが UDP をブロックしている可能性があります。",
    ),
    "natDescCone": MessageLookupByLibrary.simpleMessage(
      "ほとんどの P2P やオンライン対戦は問題なく使えます。このサーバーでは NAT1〜3 のどれかまでは判別できないため、別のサーバーで再測定すると正確になります。",
    ),
    "natDescFullCone": MessageLookupByLibrary.simpleMessage(
      "NAT1: 任意の外部ホストから到達可能。P2P・ゲーム・音声通話に最適です。",
    ),
    "natDescOpen": MessageLookupByLibrary.simpleMessage(
      "NAT がなく外部から直接到達できます。P2P やゲームに最適です。",
    ),
    "natDescPortRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT3: 通信済みのアドレスとポートのみ応答可能。一部の P2P やゲームはリレーが必要な場合があります。",
    ),
    "natDescRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT2: 通信したことのあるアドレスのみ応答可能。多くの P2P やゲームが利用できます。",
    ),
    "natDescSymmetric": MessageLookupByLibrary.simpleMessage(
      "NAT4: 宛先ごとに異なるポートが割り当てられます。P2P 直接接続は難しく、通常リレーが必要です。",
    ),
    "natDescUnknown": MessageLookupByLibrary.simpleMessage(
      "NAT タイプを判定できませんでした。",
    ),
    "natErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "STUN サーバーに接続できません",
    ),
    "natErrorUnsupported": MessageLookupByLibrary.simpleMessage(
      "選択中のアウトバウンドは UDP に対応していません",
    ),
    "natExternalIp": MessageLookupByLibrary.simpleMessage("外部 IP"),
    "natExternalPort": MessageLookupByLibrary.simpleMessage("外部ポート"),
    "natFiltering": MessageLookupByLibrary.simpleMessage("フィルタ動作"),
    "natLocalIp": MessageLookupByLibrary.simpleMessage("ローカル IP"),
    "natMapping": MessageLookupByLibrary.simpleMessage("マッピング動作"),
    "natMappingAddress": MessageLookupByLibrary.simpleMessage("アドレス依存"),
    "natMappingAddressPort": MessageLookupByLibrary.simpleMessage("アドレスとポート依存"),
    "natMappingDependent": MessageLookupByLibrary.simpleMessage("宛先依存"),
    "natMappingIndependent": MessageLookupByLibrary.simpleMessage("エンドポイント非依存"),
    "natPhaseBinding": MessageLookupByLibrary.simpleMessage("バインド"),
    "natPhaseFiltering": MessageLookupByLibrary.simpleMessage("フィルタ"),
    "natPhaseMapping": MessageLookupByLibrary.simpleMessage("マッピング"),
    "natPortPreserve": MessageLookupByLibrary.simpleMessage("ポート保持"),
    "natPreserved": MessageLookupByLibrary.simpleMessage("保持"),
    "natProxyTip": MessageLookupByLibrary.simpleMessage(
      "プロキシ経由の場合、結果はローカルネットワークではなくアウトバウンド側の NAT を表します。",
    ),
    "natRandomized": MessageLookupByLibrary.simpleMessage("ランダム"),
    "natReady": MessageLookupByLibrary.simpleMessage("下のボタンで検出を開始"),
    "natResult": MessageLookupByLibrary.simpleMessage("検出結果"),
    "natRetest": MessageLookupByLibrary.simpleMessage("再検出"),
    "natServer": MessageLookupByLibrary.simpleMessage("STUN サーバー"),
    "natServerCustom": MessageLookupByLibrary.simpleMessage("カスタムサーバー"),
    "natServerHint": MessageLookupByLibrary.simpleMessage(
      "ホスト:ポート (例: stun.example.com:3478)",
    ),
    "natServerInvalid": MessageLookupByLibrary.simpleMessage(
      "有効なホスト:ポートを入力してください",
    ),
    "natStart": MessageLookupByLibrary.simpleMessage("検出を開始"),
    "natTest": MessageLookupByLibrary.simpleMessage("NAT 検出"),
    "natTestDesc": MessageLookupByLibrary.simpleMessage(
      "NAT タイプ、外部アドレス、UDP 接続性を検査",
    ),
    "natType": MessageLookupByLibrary.simpleMessage("NAT タイプ"),
    "natTypeBlocked": MessageLookupByLibrary.simpleMessage("UDP ブロック"),
    "natTypeCone": MessageLookupByLibrary.simpleMessage("コーン NAT"),
    "natTypeFullCone": MessageLookupByLibrary.simpleMessage("フルコーン NAT"),
    "natTypeOpen": MessageLookupByLibrary.simpleMessage("パブリック (NAT なし)"),
    "natTypePortRestricted": MessageLookupByLibrary.simpleMessage(
      "ポート制限コーン NAT",
    ),
    "natTypeRestricted": MessageLookupByLibrary.simpleMessage("制限コーン NAT"),
    "natTypeSymmetric": MessageLookupByLibrary.simpleMessage("シンメトリック NAT"),
    "natTypeUnknown": MessageLookupByLibrary.simpleMessage("不明"),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "モーションフィードバック",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "ボトムナビゲーションのアニメーションと触覚フィードバック",
    ),
    "navConnections": MessageLookupByLibrary.simpleMessage("セッション"),
    "navTools": MessageLookupByLibrary.simpleMessage("ツール"),
    "network": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("ネットワーク関連設定を変更"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("ネットワーク検出"),
    "networkErrorRetryLater": MessageLookupByLibrary.simpleMessage(
      "ネットワークエラーが発生しました。後でもう一度お試しください",
    ),
    "networkFix": MessageLookupByLibrary.simpleMessage("ネットワーク修復"),
    "networkFixDesc": MessageLookupByLibrary.simpleMessage(
      "システムネットワーク検出アイコンの問題を修復",
    ),
    "networkMatch": MessageLookupByLibrary.simpleMessage("ネットワークマッチ"),
    "networkMatchHint": MessageLookupByLibrary.simpleMessage(
      "IP、CIDR または Gateway:IP/CIDR",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("通信速度"),
    "networkSpeedNotification": MessageLookupByLibrary.simpleMessage("速度通知"),
    "networkSpeedNotificationDesc": MessageLookupByLibrary.simpleMessage(
      "通知バーに通信速度とサブスク情報を表示",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("ネットワークの種類"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("ニュートラル"),
    "newLogsCount": m34,
    "noAnimation": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "noBackupFileFound": MessageLookupByLibrary.simpleMessage(
      "バックアップファイルが見つかりません",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("データがありません"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("ショートカットキーなし"),
    "noIcon": MessageLookupByLibrary.simpleMessage("アイコンなし"),
    "noInfo": MessageLookupByLibrary.simpleMessage("情報なし"),
    "noMatchedLogs": MessageLookupByLibrary.simpleMessage("条件に一致するログはありません"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("これ以上の情報はありません"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("ネットワークなし"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("非通信アプリ"),
    "noProxy": MessageLookupByLibrary.simpleMessage("プロキシなし"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage("プロファイルを作成または追加してください"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP解決なし"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage(
      "ステータスを取得できませんでした",
    ),
    "noUsageData": MessageLookupByLibrary.simpleMessage("使用量統計なし"),
    "nodeExclusion": MessageLookupByLibrary.simpleMessage("ノード除外"),
    "nodeExclusionDesc": MessageLookupByLibrary.simpleMessage(
      "指定キーワードに一致するノードを除外",
    ),
    "nodeExclusionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "HK|香港|🇭🇰",
    ),
    "none": MessageLookupByLibrary.simpleMessage("なし"),
    "notRecommended": MessageLookupByLibrary.simpleMessage("非推奨"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage("選択できないプロキシグループです"),
    "notUnlocked": MessageLookupByLibrary.simpleMessage("未解除"),
    "notificationHighPriority": MessageLookupByLibrary.simpleMessage("高優先度"),
    "notificationHighPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "通知を高優先度（フォアグラウンド）に設定",
    ),
    "notificationHighPriorityTip": MessageLookupByLibrary.simpleMessage(
      "高優先度の通知は、一部のカスタムOSでバックグラウンド維持の問題を緩和できます。現在VPNが正常に動作している場合は無効のままにすることをお勧めします。有効にしますか？",
    ),
    "ntp": MessageLookupByLibrary.simpleMessage("NTP時刻同期"),
    "ntpDesc": MessageLookupByLibrary.simpleMessage("NTP時刻同期サービスを使用"),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("更新間隔"),
    "ntpPort": MessageLookupByLibrary.simpleMessage("ポート"),
    "ntpServer": MessageLookupByLibrary.simpleMessage("サーバー"),
    "ntpStatus": MessageLookupByLibrary.simpleMessage("ステータス"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage("NTP時刻同期サービスを有効化"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルがありません。追加してください",
    ),
    "nullTip": m35,
    "numberRangeInvalid": m36,
    "numberTip": m37,
    "oneColumn": MessageLookupByLibrary.simpleMessage("1列"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("オンラインパネル"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("アイコンのみ"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage("サードパーティアプリのみ"),
    "onlyShow": m38,
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("プロキシ通信のみ統計"),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシ経由の通信量のみカウント",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("Zashboardを開く"),
    "openRouterAdmin": MessageLookupByLibrary.simpleMessage("ゲートウェイを開く"),
    "openSettings": MessageLookupByLibrary.simpleMessage("設定を開く"),
    "operatorOrAsn": MessageLookupByLibrary.simpleMessage("組織 / ASN"),
    "options": MessageLookupByLibrary.simpleMessage("オプション"),
    "organizationDomain": MessageLookupByLibrary.simpleMessage("組織 / ドメイン"),
    "other": MessageLookupByLibrary.simpleMessage("その他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("その他の貢献者（ランダム順）"),
    "otherSettings": MessageLookupByLibrary.simpleMessage("拡張ツール"),
    "otherSettingsDesc": MessageLookupByLibrary.simpleMessage("拡張ツールの設定を変更"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("アウトバウンドモード"),
    "override": MessageLookupByLibrary.simpleMessage("オーバーライド"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage("プロキシ関連設定のオーバーライド"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("宛先アドレス上書き"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "スニッフィング結果で宛先アドレスを置換",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNSオーバーライド"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル内のDNS設定を上書き",
    ),
    "overrideExperimental": MessageLookupByLibrary.simpleMessage(
      "実験的機能オーバーライド",
    ),
    "overrideExperimentalDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル内の実験的設定を上書き",
    ),
    "overrideNtp": MessageLookupByLibrary.simpleMessage("NTPオーバーライド"),
    "overrideNtpDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル内のNTP設定を上書き",
    ),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage("元のルールを上書き"),
    "overrideSniffer": MessageLookupByLibrary.simpleMessage("スニッファーオーバーライド"),
    "overrideSnifferDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル内のスニッファー設定を上書き",
    ),
    "overrideTestUrl": MessageLookupByLibrary.simpleMessage("テストURL上書き"),
    "overrideTunnel": MessageLookupByLibrary.simpleMessage("トンネルオーバーライド"),
    "overrideTunnelDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル内のトンネル設定を上書き",
    ),
    "packageListPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "権限が拒否されました。アプリ一覧を取得できません。",
    ),
    "packageListPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "インストール済みアプリ一覧を取得する権限が必要です。許可しますか？",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("パレット"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("IP直接接続の解析"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage("IP直接接続を解析"),
    "password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "paste": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "pianoWave": MessageLookupByLibrary.simpleMessage("ピアノウェーブ"),
    "pin": MessageLookupByLibrary.simpleMessage("固定"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAVを連携してください"),
    "pleaseCloseSystemProxyFirst": MessageLookupByLibrary.simpleMessage(
      "最初にシステムプロキシをオフにしてください",
    ),
    "pleaseCloseTunFirst": MessageLookupByLibrary.simpleMessage(
      "最初にTUNモードをオフにしてください",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "スクリプト名を入力してください",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "管理者パスワードを入力してください",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "ファイルをアップロードしてください",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "有効なQRコード画像をアップロードしてください",
    ),
    "port": MessageLookupByLibrary.simpleMessage("ポート"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "重複しないポート番号を入力してください",
    ),
    "portTip": m39,
    "pouringHourGlass": MessageLookupByLibrary.simpleMessage("ポーリングアワーグラス"),
    "pouringHourGlassRefined": MessageLookupByLibrary.simpleMessage(
      "リファインドグラス",
    ),
    "powerSwitch": MessageLookupByLibrary.simpleMessage("電源スイッチ"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("DoHでHTTP/3を優先使用"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("キーを入力してください"),
    "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "privateIp": MessageLookupByLibrary.simpleMessage("プライベート / LAN IP アドレス"),
    "profile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profileAndRules": MessageLookupByLibrary.simpleMessage("プロファイルとルール"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("有効な時間を指定してください"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("更新間隔を入力してください"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "プロファイルが変更されました。自動更新をオフにしますか？",
    ),
    "profileImportFailed": m40,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "設定名を入力してください",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルの解析エラー",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効なURLを入力してください",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "設定URLを入力してください",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("サブスク"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("プロファイル並び替え"),
    "progress": MessageLookupByLibrary.simpleMessage("プロセス"),
    "project": MessageLookupByLibrary.simpleMessage("プロジェクト"),
    "providers": MessageLookupByLibrary.simpleMessage("プロバイダー"),
    "provinceAndCity": MessageLookupByLibrary.simpleMessage("都道府県 / 都市"),
    "proxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "proxiesCount": MessageLookupByLibrary.simpleMessage("プロキシノード"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("プロキシ設定"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyGroupsCount": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("プロキシ用DNS"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage("ノードのドメイン解決"),
    "proxyPort": MessageLookupByLibrary.simpleMessage("プロキシポート"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage("Clashのリスニングポート設定"),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダー"),
    "proxyProvidersCount": MessageLookupByLibrary.simpleMessage("プロキシセット"),
    "pulse": MessageLookupByLibrary.simpleMessage("パルス"),
    "pulsingGrid": MessageLookupByLibrary.simpleMessage("パルスグリッド"),
    "pumpingHeart": MessageLookupByLibrary.simpleMessage("ハートビート"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("ピュアブラックモード"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QRコード"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("QRコードをスキャンして設定をインポート"),
    "quicGoDisableEcn": MessageLookupByLibrary.simpleMessage("QUIC ECN無効化"),
    "quicGoDisableEcnDesc": MessageLookupByLibrary.simpleMessage(
      "QUICのECNを無効化",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage("QUIC GSO無効化"),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "QUICのGSOを無効化",
    ),
    "quicPortSniffer": MessageLookupByLibrary.simpleMessage("QUICポート解析"),
    "quickResponse": MessageLookupByLibrary.simpleMessage("高速レスポンス"),
    "quickResponseDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワーク変更時に接続を自動切断",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("レインボー"),
    "realTimeSpeed": MessageLookupByLibrary.simpleMessage("リアルタイム速度"),
    "reclaimableMemory": MessageLookupByLibrary.simpleMessage("回収可能"),
    "recovery": MessageLookupByLibrary.simpleMessage("復元"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("すべてのデータを復元"),
    "recoveryDecryptedTip": MessageLookupByLibrary.simpleMessage(
      "現在のパスワードで復号して復元しました",
    ),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage("プロファイルのみ復元"),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage("復元戦略"),
    "recoveryStrategyDesc_compatible": MessageLookupByLibrary.simpleMessage(
      "既存を保持し、IDでバックアップを統合",
    ),
    "recoveryStrategyDesc_override": MessageLookupByLibrary.simpleMessage(
      "既存を消去し、バックアップで完全置換",
    ),
    "recoveryStrategy_compatible": MessageLookupByLibrary.simpleMessage("互換"),
    "recoveryStrategy_override": MessageLookupByLibrary.simpleMessage("上書き"),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("復元成功"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redirポート"),
    "redo": MessageLookupByLibrary.simpleMessage("やり直し"),
    "refreshAppList": MessageLookupByLibrary.simpleMessage("アプリ一覧を更新"),
    "refreshAppListConfirm": MessageLookupByLibrary.simpleMessage(
      "アプリ一覧を更新しますか？",
    ),
    "regExp": MessageLookupByLibrary.simpleMessage("正規表現"),
    "relatedSettings": MessageLookupByLibrary.simpleMessage("関連設定"),
    "remote": MessageLookupByLibrary.simpleMessage("リモート"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVへデータをバックアップ",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("リモート宛先"),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVからデータを復元",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("削除"),
    "rename": MessageLookupByLibrary.simpleMessage("名前変更"),
    "replace": MessageLookupByLibrary.simpleMessage("置換"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("すべて置換"),
    "request": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetIconCache": MessageLookupByLibrary.simpleMessage("アイコンキャッシュをリセット"),
    "resetIconCacheDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルのアイコンキャッシュをリセットしますか？アプリがリモートリンクから自動的に再取得するため、この操作は安全です。",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("本当にリセットしますか？"),
    "resources": MessageLookupByLibrary.simpleMessage("外部リソース"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部リソースやルールセットを表示"),
    "respectRules": MessageLookupByLibrary.simpleMessage("ルールに従う"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS接続でRules設定を適用",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("再起動"),
    "restartApp": MessageLookupByLibrary.simpleMessage("アプリ再起動"),
    "restartCoreDesc": MessageLookupByLibrary.simpleMessage("カーネルを手動で再起動しますか？"),
    "restartCoreTitle": MessageLookupByLibrary.simpleMessage("カーネル再起動"),
    "restartTip": MessageLookupByLibrary.simpleMessage("TUNの再起動後に有効化されます"),
    "restore": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "rightClickBehavior": MessageLookupByLibrary.simpleMessage("右クリック"),
    "ring": MessageLookupByLibrary.simpleMessage("リング"),
    "ripple": MessageLookupByLibrary.simpleMessage("リップル"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("ローテーション"),
    "rotatingPlain": MessageLookupByLibrary.simpleMessage("プレーンローテーション"),
    "routeTrace": MessageLookupByLibrary.simpleMessage("ルートトレース"),
    "routeTraceChain": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "routeTraceCheckedRules": MessageLookupByLibrary.simpleMessage("確認したルール"),
    "routeTraceDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインや IP のコア内 DNS・ルール照合を確認",
    ),
    "routeTraceDns": MessageLookupByLibrary.simpleMessage("DNS 解決"),
    "routeTraceDnsBy": m41,
    "routeTraceDnsIp": MessageLookupByLibrary.simpleMessage(
      "ターゲットは IP のため解決不要",
    ),
    "routeTraceDnsSkipped": MessageLookupByLibrary.simpleMessage(
      "照合中に IP 解決は不要でした",
    ),
    "routeTraceFinal": MessageLookupByLibrary.simpleMessage("最終アウトバウンド"),
    "routeTraceHint": MessageLookupByLibrary.simpleMessage("ドメイン、IP または URL"),
    "routeTraceHostsHit": m42,
    "routeTraceInput": MessageLookupByLibrary.simpleMessage("ターゲット"),
    "routeTraceModeDirect": MessageLookupByLibrary.simpleMessage(
      "ダイレクトモード: すべて直接接続",
    ),
    "routeTraceModeGlobal": MessageLookupByLibrary.simpleMessage(
      "グローバルモード: すべて GLOBAL を使用",
    ),
    "routeTraceNoMatch": MessageLookupByLibrary.simpleMessage(
      "一致するルールがなく DIRECT を使用",
    ),
    "routeTraceRules": MessageLookupByLibrary.simpleMessage("ルール照合"),
    "routeTraceRulesSummary": m43,
    "routeTraceRulesTotal": m44,
    "routeTraceSkipMissing": MessageLookupByLibrary.simpleMessage(
      "ターゲットがないためスキップ",
    ),
    "routeTraceSkipPass": MessageLookupByLibrary.simpleMessage("PASS でスキップ"),
    "routeTraceSkipUdp": MessageLookupByLibrary.simpleMessage("UDP 非対応のためスキップ"),
    "routeTraceStopped": MessageLookupByLibrary.simpleMessage(
      "プロキシが停止中のためルートを再現できません",
    ),
    "routeTraceTrigger": MessageLookupByLibrary.simpleMessage("DNS 解決を実行"),
    "routeTraceTruncated": MessageLookupByLibrary.simpleMessage(
      "最初の 3000 件のみ表示",
    ),
    "routeTraceUdpUnsupported": MessageLookupByLibrary.simpleMessage(
      "このアウトバウンドは UDP 非対応",
    ),
    "routeTraceViewRules": MessageLookupByLibrary.simpleMessage("確認したルールを表示"),
    "rule": MessageLookupByLibrary.simpleMessage("ルール"),
    "ruleName": MessageLookupByLibrary.simpleMessage("ルール名"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("ルールプロバイダー"),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage("ルールセット"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("ルールターゲット"),
    "rulesCount": MessageLookupByLibrary.simpleMessage("ルーティング規則"),
    "runTime": MessageLookupByLibrary.simpleMessage("稼働時間"),
    "runningMode": MessageLookupByLibrary.simpleMessage("実行モード"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("ランタイム設定"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存しますか？"),
    "saveTip": MessageLookupByLibrary.simpleMessage("保存してもよろしいですか？"),
    "script": MessageLookupByLibrary.simpleMessage("オーバーライドスクリプト"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "JavaScript オーバーライドスクリプトを設定",
    ),
    "scriptOtherOptions": MessageLookupByLibrary.simpleMessage("その他の設定"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "パスワードをクリップボードにコピーしました",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("すべて選択"),
    "selectBackupVersion": MessageLookupByLibrary.simpleMessage(
      "バックアップバージョンの選択",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("選択済み"),
    "selectedCountTitle": m45,
    "serviceReady": MessageLookupByLibrary.simpleMessage("サービス準備完了"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage("サービス稼働中"),
    "setcapFailedFallback": MessageLookupByLibrary.simpleMessage(
      "ファイルケーパビリティを付与できなかったため、setuid にフォールバックしました",
    ),
    "setcapNotInstalledFallback": MessageLookupByLibrary.simpleMessage(
      "setcap がインストールされていないため、setuid にフォールバックしました",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "sharedAddress": MessageLookupByLibrary.simpleMessage("共有アドレス"),
    "show": MessageLookupByLibrary.simpleMessage("表示"),
    "showHiddenItems": MessageLookupByLibrary.simpleMessage("非表示項目を表示"),
    "showMenu": MessageLookupByLibrary.simpleMessage("メニューを開く"),
    "showPanel": MessageLookupByLibrary.simpleMessage("ウィンドウを表示"),
    "showStartSwitch": MessageLookupByLibrary.simpleMessage("単独スイッチ表示"),
    "showStartSwitchDesc": MessageLookupByLibrary.simpleMessage(
      "ホーム画面に独立スイッチを表示",
    ),
    "shrink": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "sidebarFlyout": MessageLookupByLibrary.simpleMessage("ホバーパネル"),
    "sidebarFlyoutDelay": MessageLookupByLibrary.simpleMessage("表示までの遅延"),
    "sidebarFlyoutDesc": MessageLookupByLibrary.simpleMessage(
      "サイドバーのホバーカードを表示",
    ),
    "sidebarFlyoutEntries": MessageLookupByLibrary.simpleMessage("表示項目"),
    "sidebarFlyoutOutsideTools": MessageLookupByLibrary.simpleMessage(
      "「ツール」ページ以外でのみ表示",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("サイレント起動"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "画面を表示せずバックグラウンドで起動",
    ),
    "size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("除外ドメイン"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("除外宛先IP"),
    "skipLocalAuth": MessageLookupByLibrary.simpleMessage("ローカル認証をスキップ"),
    "skipLocalAuthDesc": MessageLookupByLibrary.simpleMessage("ローカル端末の認証をスキップ"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("除外送信元IP"),
    "slow": MessageLookupByLibrary.simpleMessage("遅い"),
    "smartAutoStop": MessageLookupByLibrary.simpleMessage("スマート自動停止"),
    "smartAutoStopDesc": MessageLookupByLibrary.simpleMessage(
      "指定ネットワーク接続時にプロキシを停止",
    ),
    "smartAutoStopServiceRunning": MessageLookupByLibrary.simpleMessage(
      "スマート自動停止サービス稼働中",
    ),
    "smartDelayLaunch": MessageLookupByLibrary.simpleMessage("遅延起動"),
    "smartDelayLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワーク接続完了後に起動",
    ),
    "sniffer": MessageLookupByLibrary.simpleMessage("スニッファー"),
    "snifferAddressHint": MessageLookupByLibrary.simpleMessage("1行に1アドレス"),
    "snifferDesc": MessageLookupByLibrary.simpleMessage("ドメインスニッフィングの設定変更"),
    "snifferDomainHint": MessageLookupByLibrary.simpleMessage("1行に1ドメイン"),
    "snifferPorts": MessageLookupByLibrary.simpleMessage("ポート"),
    "snifferPortsHint": MessageLookupByLibrary.simpleMessage(
      "例: 80, 8080-8880",
    ),
    "snifferStatus": MessageLookupByLibrary.simpleMessage("ステータス"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "スニッフィングサービスを有効化",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socksポート"),
    "sort": MessageLookupByLibrary.simpleMessage("並び替え"),
    "source": MessageLookupByLibrary.simpleMessage("送信元"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("送信元IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊プロキシ"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊ルール"),
    "speedTest": MessageLookupByLibrary.simpleMessage("速度テスト"),
    "speedTestAgain": MessageLookupByLibrary.simpleMessage("再測定"),
    "speedTestChangeOutbound": MessageLookupByLibrary.simpleMessage(
      "アウトバウンドを変更",
    ),
    "speedTestClearHistoryTip": MessageLookupByLibrary.simpleMessage(
      "すべての測定履歴を削除しますか？",
    ),
    "speedTestConnecting": MessageLookupByLibrary.simpleMessage("接続中"),
    "speedTestConnections": MessageLookupByLibrary.simpleMessage("接続方式"),
    "speedTestConnectionsDesc": m46,
    "speedTestCoreStopped": MessageLookupByLibrary.simpleMessage("未起動・直接接続で測定"),
    "speedTestCredit": MessageLookupByLibrary.simpleMessage(
      "速度テストサーバーは公開されている第三者によって提供されています。Apple、Cloudflare、Speedtest by Ookla に感謝します。",
    ),
    "speedTestDataUsed": MessageLookupByLibrary.simpleMessage("使用データ量"),
    "speedTestDuration": MessageLookupByLibrary.simpleMessage("測定時間"),
    "speedTestErrorBlocked": MessageLookupByLibrary.simpleMessage(
      "速度テストを利用できません",
    ),
    "speedTestErrorBlockedDesc": m47,
    "speedTestErrorNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "アウトバウンドが利用可能か確認してから再試行してください。",
    ),
    "speedTestErrorRejected": MessageLookupByLibrary.simpleMessage(
      "ルールによりブロックされました",
    ),
    "speedTestErrorRejectedDesc": MessageLookupByLibrary.simpleMessage(
      "現在のルールでは測定ドメインが REJECT に割り当てられています。別のアウトバウンドを選んで再試行してください。",
    ),
    "speedTestErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "速度テストがタイムアウトしました",
    ),
    "speedTestErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "速度テストサービスに接続できません",
    ),
    "speedTestExitNode": MessageLookupByLibrary.simpleMessage("出口ノード"),
    "speedTestFollowRules": MessageLookupByLibrary.simpleMessage("ルールに従う"),
    "speedTestHistory": MessageLookupByLibrary.simpleMessage("測定履歴"),
    "speedTestHistoryEmpty": MessageLookupByLibrary.simpleMessage("測定履歴はありません"),
    "speedTestHistoryRetention": MessageLookupByLibrary.simpleMessage(
      "14 日間保存",
    ),
    "speedTestJitter": MessageLookupByLibrary.simpleMessage("ジッター"),
    "speedTestLoadedLatency": MessageLookupByLibrary.simpleMessage("負荷時遅延"),
    "speedTestManual": MessageLookupByLibrary.simpleMessage("手動指定"),
    "speedTestMobileDataTip": MessageLookupByLibrary.simpleMessage(
      "モバイルデータ通信中です。1 回の測定で数百 MB を消費する場合があります。続行しますか？",
    ),
    "speedTestMultiThread": MessageLookupByLibrary.simpleMessage("マルチ"),
    "speedTestOutbound": MessageLookupByLibrary.simpleMessage("アウトバウンド"),
    "speedTestPacketLoss": MessageLookupByLibrary.simpleMessage("パケットロス"),
    "speedTestProbing": MessageLookupByLibrary.simpleMessage("アウトバウンドを検出中…"),
    "speedTestProtocol": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "speedTestProtocolDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP/3 は QUIC (UDP) を使用し、使えない場合は HTTP/2 に、HTTP/2 も使えない場合は HTTP/1.1 に切り替えます",
    ),
    "speedTestProtocolFallback": m48,
    "speedTestQuality": MessageLookupByLibrary.simpleMessage("ネットワーク品質"),
    "speedTestReady": MessageLookupByLibrary.simpleMessage("準備完了"),
    "speedTestRealtime": MessageLookupByLibrary.simpleMessage("リアルタイム速度"),
    "speedTestResponsiveness": MessageLookupByLibrary.simpleMessage("応答性"),
    "speedTestRoute": MessageLookupByLibrary.simpleMessage("ルーティング"),
    "speedTestServer": MessageLookupByLibrary.simpleMessage("測定サーバー"),
    "speedTestServerAutoDesc": MessageLookupByLibrary.simpleMessage(
      "Speedtest サーバーを自動選択",
    ),
    "speedTestSettings": MessageLookupByLibrary.simpleMessage("測定設定"),
    "speedTestSingleThread": MessageLookupByLibrary.simpleMessage("シングル"),
    "speedTestStart": MessageLookupByLibrary.simpleMessage("測定開始"),
    "speedTestStreams": m49,
    "speedTestSwitchProvider": m50,
    "speedTestUseSystemDns": MessageLookupByLibrary.simpleMessage(
      "システム DNS で解決",
    ),
    "speedTestUseSystemDnsDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、選択した速度テストサーバーを常にシステム DNS で解決します。状況によって役立ちます",
    ),
    "spinningCircle": MessageLookupByLibrary.simpleMessage("スピンサークル"),
    "spinningLines": MessageLookupByLibrary.simpleMessage("スピンライン"),
    "squareCircle": MessageLookupByLibrary.simpleMessage("スクエアサークル"),
    "stackMode": MessageLookupByLibrary.simpleMessage("スタックモード"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "start": MessageLookupByLibrary.simpleMessage("開始"),
    "startSwitchOffLabel": MessageLookupByLibrary.simpleMessage("オフ時のテキスト"),
    "startSwitchOnLabel": MessageLookupByLibrary.simpleMessage("オン時のテキスト"),
    "startSwitchOutlined": MessageLookupByLibrary.simpleMessage("アウトライン"),
    "startSwitchPersonalized": MessageLookupByLibrary.simpleMessage(
      "表示のカスタマイズ",
    ),
    "startSwitchStyle": MessageLookupByLibrary.simpleMessage("スタイル"),
    "startSwitchTonal": MessageLookupByLibrary.simpleMessage("淡色"),
    "startTest": MessageLookupByLibrary.simpleMessage("レイテンシテスト"),
    "startVpn": MessageLookupByLibrary.simpleMessage("起動中..."),
    "status": MessageLookupByLibrary.simpleMessage("ステータス"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("オフにするとシステムDNSを使用します"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("停止中..."),
    "storeFix": MessageLookupByLibrary.simpleMessage("ストア修復"),
    "storeFixDesc": MessageLookupByLibrary.simpleMessage(
      "Google Playストアのダウンロード問題を修復",
    ),
    "strictRoute": MessageLookupByLibrary.simpleMessage("厳格ルーティング"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "TUNの厳格ルーティングモードを使用",
    ),
    "style": MessageLookupByLibrary.simpleMessage("スタイル"),
    "subRule": MessageLookupByLibrary.simpleMessage("サブルーール"),
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "success": MessageLookupByLibrary.simpleMessage("成功"),
    "switchLabel": MessageLookupByLibrary.simpleMessage("スイッチ"),
    "switchToDomesticIp": MessageLookupByLibrary.simpleMessage("国内IPを取得"),
    "sync": MessageLookupByLibrary.simpleMessage("同期"),
    "syncAll": MessageLookupByLibrary.simpleMessage("すべて同期"),
    "syncDelayAnimation": MessageLookupByLibrary.simpleMessage(
      "アニメーションを他のページに同期",
    ),
    "syncFailed": MessageLookupByLibrary.simpleMessage("同期失敗"),
    "system": MessageLookupByLibrary.simpleMessage("システム"),
    "systemApp": MessageLookupByLibrary.simpleMessage("システムアプリ"),
    "systemDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "systemFont": MessageLookupByLibrary.simpleMessage("システムフォント"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("システムプロキシの設定"),
    "tab": MessageLookupByLibrary.simpleMessage("タブ"),
    "tailscale": MessageLookupByLibrary.simpleMessage("Tailscale"),
    "tailscaleAcceptRoutes": MessageLookupByLibrary.simpleMessage(
      "サブネットルートを受け入れる",
    ),
    "tailscaleAcceptRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "tailnet で広告されたサブネットルートを使用",
    ),
    "tailscaleAddNetwork": MessageLookupByLibrary.simpleMessage("ネットワークを追加"),
    "tailscaleAuthKey": MessageLookupByLibrary.simpleMessage("認証キー"),
    "tailscaleAuthKeyDesc": MessageLookupByLibrary.simpleMessage(
      "任意。未入力の場合は「ログイン」（SSO/OIDC）を使用",
    ),
    "tailscaleConnected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "tailscaleControlUrl": MessageLookupByLibrary.simpleMessage("コントロールサーバー"),
    "tailscaleControlUrlDesc": MessageLookupByLibrary.simpleMessage(
      "空欄で Tailscale を使用。Headscale の場合は URL を入力",
    ),
    "tailscaleDeleteNetwork": MessageLookupByLibrary.simpleMessage("ネットワークを削除"),
    "tailscaleDesc": MessageLookupByLibrary.simpleMessage(
      "指定したドメインと IP を tailnet 経由で接続",
    ),
    "tailscaleDevices": MessageLookupByLibrary.simpleMessage("デバイス"),
    "tailscaleDns": MessageLookupByLibrary.simpleMessage("Tailnet DNS"),
    "tailscaleDnsDesc": MessageLookupByLibrary.simpleMessage(
      "tailnet 内の DNS サーバーで解決するドメイン（ドメイン=サーバー、例: corp.example.com=10.1.0.53）。解決先のサブネットはルーティングリストに追加してください",
    ),
    "tailscaleEnable": MessageLookupByLibrary.simpleMessage("Tailscale を有効化"),
    "tailscaleEnableDesc": MessageLookupByLibrary.simpleMessage(
      "内蔵の Tailscale ノードで tailnet に参加",
    ),
    "tailscaleExitNode": MessageLookupByLibrary.simpleMessage("出口ノード"),
    "tailscaleExitNodeDesc": MessageLookupByLibrary.simpleMessage(
      "tailnet 内のデバイス名か IP、または auto:any。公開サイトへの接続に必要",
    ),
    "tailscaleExitNodeLan": MessageLookupByLibrary.simpleMessage(
      "LAN へのアクセスを許可",
    ),
    "tailscaleExitNodeLanDesc": MessageLookupByLibrary.simpleMessage(
      "出口ノード使用中もローカルネットワークに接続可能",
    ),
    "tailscaleHostname": MessageLookupByLibrary.simpleMessage("デバイス名"),
    "tailscaleInvalidDns": MessageLookupByLibrary.simpleMessage(
      "ドメイン=サーバー の形式で、サーバーは IP または tls:// / https:// URL（例: corp.example.com=10.1.0.53）",
    ),
    "tailscaleInvalidEntry": MessageLookupByLibrary.simpleMessage(
      "ドメイン、IP または CIDR を入力してください",
    ),
    "tailscaleLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Tailscale にログインしました",
    ),
    "tailscaleLogin": MessageLookupByLibrary.simpleMessage("ログイン"),
    "tailscaleLoginDesc": MessageLookupByLibrary.simpleMessage(
      "ブラウザで tailnet の SSO/OIDC によりログイン（認証キー不要）",
    ),
    "tailscaleLoginNeeded": MessageLookupByLibrary.simpleMessage(
      "Tailscale のログインが必要です",
    ),
    "tailscaleNeedsApproval": MessageLookupByLibrary.simpleMessage(
      "管理者によるこのデバイスの承認を待っています",
    ),
    "tailscaleNetwork": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "tailscaleNetworks": MessageLookupByLibrary.simpleMessage("ネットワーク一覧"),
    "tailscaleNotStarted": MessageLookupByLibrary.simpleMessage("未起動"),
    "tailscaleNotStartedDesc": MessageLookupByLibrary.simpleMessage(
      "初回使用時に起動します。タップで今すぐ起動",
    ),
    "tailscaleNotes": MessageLookupByLibrary.simpleMessage(
      "• 内蔵ノード：Bettbox 自身が tailnet に参加するため、Tailscale アプリは不要です。ルーティングリストと Tailnet DNS の通信だけが経由します。\n• ルールモードのみ：グローバル／ダイレクトモードではこれらのルールは使われません。\n• host.tailnet.ts.net のような完全な名前を使ってください。nas のような短い名前は解決されません。\n• サブネット：ルーティングリストに追加し、「サブネットルートを受け入れる」をオンにしてください。デスクトップで TUN を使わない場合、プライベートサブネット（10.x、172.16–31.x、192.168.x）はシステムプロキシを経由しません。\n• tailnet 経由で公開サイトにアクセスするには出口ノードが必要です。\n• tailnet の IPv6 アドレスには IPv6 の有効化が必要です。\n• ノードは初回使用時に起動します。ログインリンクは Bettbox が開いている間だけ表示されます。\n• Android：ルーティングリストの変更は VPN の再起動後に反映されます。",
    ),
    "tailscaleNotesTitle": MessageLookupByLibrary.simpleMessage("説明"),
    "tailscaleOnlineCount": m51,
    "tailscaleRelay": m52,
    "tailscaleReset": MessageLookupByLibrary.simpleMessage("ノードをリセット"),
    "tailscaleResetDesc": MessageLookupByLibrary.simpleMessage(
      "このデバイスの tailnet ID を削除して新しいデバイスとして参加します。古いデバイスは管理コンソールで削除してください",
    ),
    "tailscaleRoutes": MessageLookupByLibrary.simpleMessage("ルーティングリスト"),
    "tailscaleRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "ルールモードで Tailscale を経由するドメインと IP/CIDR。デスクトップのプライベートサブネットには TUN が必要",
    ),
    "tailscaleStarting": MessageLookupByLibrary.simpleMessage(
      "Tailscale を起動中…",
    ),
    "tailscaleSubnetRoutes": MessageLookupByLibrary.simpleMessage("サブネットルート"),
    "tailscaleThisDevice": MessageLookupByLibrary.simpleMessage("このデバイス"),
    "tailscaleUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "tailscaleUdpDesc": MessageLookupByLibrary.simpleMessage(
      "UDP 通信を Tailscale 経由で送信",
    ),
    "tailscaleWarnings": MessageLookupByLibrary.simpleMessage("警告"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP並列接続"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage("TCPの同時並列接続を許可"),
    "testUrl": MessageLookupByLibrary.simpleMessage("テストURL"),
    "testing": MessageLookupByLibrary.simpleMessage("検出中"),
    "textScale": MessageLookupByLibrary.simpleMessage("テキスト倍率"),
    "theme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "themeColor": MessageLookupByLibrary.simpleMessage("テーマカラー"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("テーマカラー関連の設定"),
    "themeMode": MessageLookupByLibrary.simpleMessage("テーマモード"),
    "threeBounce": MessageLookupByLibrary.simpleMessage("トリプルバウンス"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("3列"),
    "threeInOut": MessageLookupByLibrary.simpleMessage("トリプルインアウト"),
    "tight": MessageLookupByLibrary.simpleMessage("タイト"),
    "time": MessageLookupByLibrary.simpleMessage("時間"),
    "tip": MessageLookupByLibrary.simpleMessage("ヒント"),
    "titleTooLong": MessageLookupByLibrary.simpleMessage("長すぎます（最大20文字）"),
    "tlsPortSniffer": MessageLookupByLibrary.simpleMessage("TLSポート解析"),
    "toggle": MessageLookupByLibrary.simpleMessage("切替"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("トーナルスポット"),
    "tooManyRules": MessageLookupByLibrary.simpleMessage("ルールは最大5つまでです"),
    "toolConnectivityDesc": MessageLookupByLibrary.simpleMessage(
      "主要サービスの利用可否を検査、ノード一括検査に対応",
    ),
    "toolHistoryClear": MessageLookupByLibrary.simpleMessage("履歴を消去"),
    "toolSpeedTestDesc": MessageLookupByLibrary.simpleMessage(
      "ダウンロード・アップロード速度と遅延を測定",
    ),
    "toolbox": MessageLookupByLibrary.simpleMessage("ツールボックス"),
    "toolboxDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワーク診断・デバッグとユーティリティ",
    ),
    "toolboxEditTip": MessageLookupByLibrary.simpleMessage(
      "カードをタップしてサイズを変更、長押しでドラッグして並べ替え",
    ),
    "toolboxEditTipDesktop": MessageLookupByLibrary.simpleMessage(
      "カードをクリックしてサイズを変更、ドラッグで並べ替え",
    ),
    "toolboxEditTipTv": MessageLookupByLibrary.simpleMessage(
      "カードを選んで決定キーを押すとサイズを切り替えます",
    ),
    "tools": MessageLookupByLibrary.simpleMessage("ツール"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("総通信量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxyポート"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("通信量統計"),
    "trayClickBehavior": MessageLookupByLibrary.simpleMessage("トレイクリック動作"),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("トレイ拡張"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "システムトレイメニューでプロキシグループを操作",
    ),
    "trayIconInvert": MessageLookupByLibrary.simpleMessage("トレイアイコン反転"),
    "trayIconInvertDesc": MessageLookupByLibrary.simpleMessage(
      "現在のトレイアイコンの色を反転設定",
    ),
    "tryManualRefresh": MessageLookupByLibrary.simpleMessage(
      "手動で再読み込みをお試しください",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("仮想NIC (TUN)"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("TUNモードでデバイスの全通信を管理"),
    "tunEnableRequireAdmin": MessageLookupByLibrary.simpleMessage(
      "TUN仮想NIC機能の有効化には管理者（ROOT）権限が必要です",
    ),
    "tunVirtualAddress": MessageLookupByLibrary.simpleMessage(
      "TUN 仮想ネットワークアダプター",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("トンネル"),
    "tunnelAddress": MessageLookupByLibrary.simpleMessage("バインドアドレス"),
    "tunnelAddressHint": MessageLookupByLibrary.simpleMessage(
      "例: 127.0.0.1:6553",
    ),
    "tunnelDesc": MessageLookupByLibrary.simpleMessage("ポートフォワーディングを使用"),
    "tunnelList": MessageLookupByLibrary.simpleMessage("転送リスト"),
    "tunnelNetwork": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "tunnelNetworkHint": MessageLookupByLibrary.simpleMessage("例: tcp, udp"),
    "tunnelProxy": MessageLookupByLibrary.simpleMessage("プロキシ名"),
    "tunnelProxyHint": MessageLookupByLibrary.simpleMessage("例: proxy（任意）"),
    "tunnelTarget": MessageLookupByLibrary.simpleMessage("転送先アドレス"),
    "tunnelTargetHint": MessageLookupByLibrary.simpleMessage(
      "例: 114.114.114.114:53",
    ),
    "tvScanImport": MessageLookupByLibrary.simpleMessage("スキャン / LANインポート"),
    "tvScanImportDesc": MessageLookupByLibrary.simpleMessage(
      "スマホでスキャンまたはLAN経由でTVに設定をプッシュ",
    ),
    "tvScanManualUrl": MessageLookupByLibrary.simpleMessage(
      "スマホのブラウザに直接入力も可能：",
    ),
    "tvScanNoNetwork": MessageLookupByLibrary.simpleMessage(
      "利用可能なLANが見つかりません。Wi-Fiを確認してください",
    ),
    "tvScanStep1": MessageLookupByLibrary.simpleMessage(
      "スマホとTVが同じWi-Fiネットワークにあることを確認",
    ),
    "tvScanStep2": MessageLookupByLibrary.simpleMessage(
      "対応するカメラまたはブラウザでQRコードをスキャン",
    ),
    "tvScanStep3": MessageLookupByLibrary.simpleMessage(
      "Webページで購読URLを貼り付けまたは設定をアップロードしてプッシュ",
    ),
    "tvScanSuccess": MessageLookupByLibrary.simpleMessage(
      "設定がプッシュされました。インポート中...",
    ),
    "tvScanWaiting": MessageLookupByLibrary.simpleMessage("スマホからのプッシュを待機中..."),
    "twoColumns": MessageLookupByLibrary.simpleMessage("2列"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "現在のプロファイルを更新できません",
    ),
    "unauthorized": MessageLookupByLibrary.simpleMessage("未認証"),
    "undo": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("レイテンシの統一"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "ハンドシェイク等の追加レイテンシを除外",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("不明"),
    "unlocked": MessageLookupByLibrary.simpleMessage("完了"),
    "unnamed": MessageLookupByLibrary.simpleMessage("無題"),
    "unpin": MessageLookupByLibrary.simpleMessage("固定解除"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "updateTime": MessageLookupByLibrary.simpleMessage("更新日時"),
    "upload": MessageLookupByLibrary.simpleMessage("送信"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URLから設定を取得"),
    "urlTip": m53,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "グローバルスクリプトオーバーライドを使用",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Hostsを使用"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("システムHostsを使用"),
    "userAuth": MessageLookupByLibrary.simpleMessage("ユーザー認証"),
    "userAuthEmpty": MessageLookupByLibrary.simpleMessage(
      "認証ユーザーが設定されていません。LAN接続には資格情報が不要です",
    ),
    "username": MessageLookupByLibrary.simpleMessage("ユーザー名"),
    "usernameCannotContainColon": MessageLookupByLibrary.simpleMessage(
      "ユーザー名にコロン（:）を含めることはできません",
    ),
    "value": MessageLookupByLibrary.simpleMessage("値"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("バイブラント"),
    "view": MessageLookupByLibrary.simpleMessage("表示"),
    "viewDetailedIpData": MessageLookupByLibrary.simpleMessage("詳細なIPデータを見る"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("VPN関連の設定を変更"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VpnServiceで通信をルーティング",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "VpnServiceにHTTPプロキシを添付",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage("VPN再起動後に有効化されます"),
    "wakelock": MessageLookupByLibrary.simpleMessage("画面常時点灯"),
    "wakelockDescription": MessageLookupByLibrary.simpleMessage(
      "画面の自動消灯を防ぐ画面ウェイクロックを有効にします（CPUウェイクは使用しません）。バックグラウンド処理を維持したい場合に便利です。",
    ),
    "wanderingCubes": MessageLookupByLibrary.simpleMessage("ワンダリングキューブ"),
    "wave": MessageLookupByLibrary.simpleMessage("ウェーブ"),
    "waveSpinner": MessageLookupByLibrary.simpleMessage("ウェーブスピナー"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV設定"),
    "whitelist": MessageLookupByLibrary.simpleMessage("ホワイトリスト"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("ホワイトリストモード"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("システムへ適用"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage("管理者権限が必要です"),
    "xattrUnsupportedFallback": MessageLookupByLibrary.simpleMessage(
      "ファイルシステムがファイルケーパビリティ（xattr）に対応していないため、setuid にフォールバックしました",
    ),
    "years": m54,
  };
}
