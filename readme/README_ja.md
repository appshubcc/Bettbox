<h4 align="right">
  <a href="../README.md">简体中文</a> | <a href="README_en.md">English</a> | <a href="README_ru.md">Русский</a> | <a href="README_fa.md">فارسی</a> | <strong>日本語</strong> | <a href="README_ko.md">한국어</a>
</h4>

<h1 align="center">⚡ Bettbox</h1>
<p align="center">
  <strong>Another Better Network Toolbox</strong>
</p>

**Bettbox は、Mihomo コアをベースにしたマルチプラットフォーム対応のトラフィック分流・DNS デバッグツールです。究極のユーザー体験を追求し、長期安定稼働のために設計され、軽量で省リソース、データ収集は一切行いません。**

Bettbox は「Better Network Toolbox」を意味します。本プロジェクトは SignPath 財団による人的セキュリティ審査に合格しており、Windows 版には OV コード署名証明書を使用しています。

[![Latest Release](https://img.shields.io/github/v/release/appshubcc/Bettbox?style=for-the-badge&logo=github&color=238636&label=Release)](https://github.com/appshubcc/Bettbox/releases/latest) [![Core](https://img.shields.io/github/v/release/MetaCubeX/mihomo?style=for-the-badge&logo=go&logoColor=white&color=8A2BE2&label=Mihomo)](https://github.com/MetaCubeX/mihomo/releases/latest)

<p align="center">
  <img src="../snapshots/home.jpg" alt="Bettbox" />
</p>

---
### ✈️ Telegram コミュニティ

[![Telegram Group](https://img.shields.io/badge/Bettbox-Chat-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/bettbox_chat) [![Telegram Channel](https://img.shields.io/badge/Bettbox-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_channel)

---
## 🚀 主な特徴

* **すぐに使える**：権限ガイド、TUN、マネージド分流モードをあらかじめ搭載。インストール後すぐに使えます。
* **軽量・軽快**：モバイルは低消費電力、デスクトップはバックグラウンド使用量が少なく、UI アニメーションも滑らかです。
* **高セキュリティ**：コアは Mihomo メインラインに追従し、各プラットフォームで必要最小限の権限のみを要求します。
* **堅牢な耐障害性**：マルチプラットフォームの極端なネットワーク環境における境界問題を最適化し、設定の二重検証により長期運用に適しています。
* **アーキテクチャ最適化**：デスクトップ版は ARM64 をネイティブサポートし、旧型デバイス向けの Compatible 版も継続してメンテナンスしています。
* **スマートデーモン**：マルチプラットフォームでのスマートな自動起動/停止、モバイルの Doze スリープへの対応、デスクトップ各プラットフォームでのトレイからのクイック操作に対応。
* **ビジュアル設定**：パラメータをビジュアルに調整でき、変更は即時反映。初心者でも設定ファイルを手動で書き換える必要はありません。
* **ホームウィジェット**：洗練された複数の内蔵ウィジェットで、ホームから全体の稼働状況を把握できます。
* **万能ツールボックス**：プロ仕様のネットワーク・DNS 分流デバッグツールを内蔵し、ネットワークの状態が一目で分かります。
* **自由なカスタマイズ**：Material Design 風の多彩なカラーテーマ、アイコンやタイトルのカスタマイズ、さらに 30 種類のスピードテストアニメーション。
* **エコシステムと拡張**：外部 JS オーバーライドスクリプトを GUI に対応させ、高性能な Code-forge エディタを搭載。
* **プライバシーリスクゼロ**：コードはオープンソースで広告なし。CI/CD は完全自動で公開監査が可能、バックグラウンドでのデータ収集はありません。
* **コミュニティ主導**：コミュニティのフィードバックを真摯に受け止め、活発なユーザーコミュニティとともに進化し、質の高い Issue に迅速に対応します。

---
## 🛠️ インストールとダウンロード

**[[Releases]](https://github.com/appshubcc/Bettbox/releases)** ページから、お使いのプラットフォームやシステムに適した最新のインストールパッケージをダウンロードしてください：

* **デスクトップ対応**: 
  * **Windows 8.1+:** (x64 / arm64)
  * **Linux Kernel 5.4+:** (x64 / arm64)
  * **macOS 12.0+:** (Intel / Apple Silicon)
* **モバイルおよびその他**: 
  * **Android 8.0+:** (ARMv8 / ARMv7 / x86_64 / Universal) 
  * **Android TV:** 大画面に完全対応、ARMv7 32ビット版も選択可能
  * **HarmonyOS NEXT:** [[卓易通]](https://harmonyos.cool/android-app) と組み合わせて安定して利用可能

**Linux コミュニティパッケージ:**<br>
* **ArchLinux:** <code>yay -S bettbox-bin</code> または <code>paru -S bettbox-bin</code> ([lyj404](https://github.com/lyj404/bettbox-aur) により維持)<br>
* **AMD64=v1 (互換版):** <code>yay -S bettbox-compatible-bin</code> または <code>paru -S bettbox-compatible-bin</code> ([VillagerTom](https://github.com/VillagerTom) により維持)

---
## 💡 よくある質問

1. **動作環境と互換バージョン**：
   - Android 端末をご利用の場合、バックグラウンド実行権限が十分に付与されているかご確認ください。システム要件は Android 8.0 以上です。
   - デスクトップの旧型ハードウェアでは、CPU 命令セットアーキテクチャに応じて対応する Compatible 互換バージョンを選択してください。
   - セキュリティ：Bettbox は全工程がオープンソースかつ透明であり、コードは権威ある SignPath セキュリティ監査に合格しています。プライバシー情報の収集は一切ありません。

2. **デスクトップの権限と TUN**：
   - Windows 版の管理者権限はインストーラー側で事前処理されているため、日常的な使用で手動の再認証は不要です。
   - macOS / Linux で TUN 仮想 NIC を有効にする際は、システムプロンプトに従って正しいシステムパスワードを入力し、認証を完了してください。
   - その他のエラーが発生した場合は、バックグラウンドで他のプロキシツールがポートを占有していないか確認し、Debug ログを添付してフィードバックを送信してください。

3. **macOS 初回インストールガイド**：
   - お使いの環境 (Intel / Apple Silicon) に応じた `.dmg` インストーラーをダウンロードして開き、Bettbox アイコンを Applications フォルダにドラッグしてください。
   - **システムセキュリティブロックの回避**（[現在 Apple 商業開発者証明書は未購入です](https://support.apple.com/en-us/102445)）：
     - **推奨**：「Finder - アプリケーション」で、**Bettbox アイコンを右クリックして「開く」を選択**し、確認ダイアログで「開く」をクリックしてください。
     - **代替案**：ブロックされた場合、システムの「設定 -> プライバシーとセキュリティ」から Bettbox を探し、「このまま開く」をクリックしてください。
   - 初めて TUN モードを有効にする際、システムパスワードの認証が求められます。パスワードを入力して仮想ネットワークインターフェースの作成を許可してください。

4. **サブスクリプションのインポートとトラブルシューティング**：
   - インポートに失敗した場合は、プロバイダーの管理パネルでサブスクリプションリンクをリセットしてから再度お試しください。
   - 異常が続く場合は、プロバイダーとノード形式を確認してください。クライアント側の不具合と確認された場合は、お気軽に Issue を提出してください。

---
## 💻 開発・ビルドと UI 適応

Windows プラットフォームでのビルド例：

* システム要件：Windows 10 以上
* 必要環境：Git, Visual Studio, Flutter 3.47.x, Golang, Inno Setup, Rust
```bash
* flutter pub get (依存関係の取得)
* dart .\setup.dart windows --arch amd64 --out core (Core コアのみビルド)
* dart .\setup.dart windows --arch amd64 --out app --compatible (任意の互換バージョン)
* ビルド完了後、生成物は `dist/` ディレクトリに出力されます
```

カスタムスクリプトの UI 適応：

* Bettbox は、外部オーバーライドスクリプトのグラフィカル UI 適応に対応しています。AIsouler 氏の **[スクリプト/設定共有](https://github.com/AIsouler/MyClash)** を例にすると、スクリプトの先頭行に以下の宣言を追加するだけで、内蔵のビジュアルスイッチと直接連動させることができます：
* <code>const Compatible_With_Bettbox = { ruleOptionsEnable: true };</code>
* スクリプト内のスイッチにポリシーグループなどが含まれる場合、`policyGroupOptions` でポリシーグループのスイッチ名を宣言できます。宣言されていないスイッチは「⚙️ その他の設定」サブメニューに自動分類されます：

```js
const Compatible_With_Bettbox = {
  ruleOptionsEnable: true,
  // ポリシーグループに属するスイッチ名を宣言（ruleOptionsEnable のキーと完全一致させる必要があります）
  policyGroupOptions: ['🚀 节点选择', '🛑 广告拦截'],
};
```
* `policyGroupOptions` が宣言されていない、または名称が一致しない場合、すべてのスイッチはフラットに表示されます。

---
### 🛩️ おすすめサービス
#### IEPL 専用線  〢  [百変小桜 (BBXY)](https://www.bbxy01.com/v2/register?code=c09R)  〢  [白月光 (BaiYueGuang)](https://www.sibker.com/register?invite_code=YZq6L5zd)  〢  [Ytoo](https://y-too.net/aff.php?aff=10354)
--------------------------------
#### 低価格 直通  〢  [良心雲 (Liangxin Cloud)](https://xn--9kqz23b19z.com/#/register?code=VTnrQYAj)  〢  [吹雪雲 (Chuixue Cloud)](https://xn--9kqs1lo79d.com/#/register?code=skKMTab7)  〢  [一分 (YiFen)](https://xn--4gqx1hgtfdmt.com/#/register?code=AuCiXprV) 
--------------------------------
#### 百変小桜専用 32%OFF クーポンコード：bettbox68 、参照：[関連説明](https://t.me/appshub_channel/381)
--------------------------------

**簡単なレビュー** : ❚ ❚ 上記のリンクは主に個人利用、または TG グループ内で議論・推奨されたものです。ここでは AFF リンクとしてのみ掲載しています（注：リンク経由での購入により、開発者に少額の手数料が還元され開発の支援となります）。これは各サービスに対する保証や約束を意味するものではありません。各自でご判断の上、適切にご選択ください。

---
### ☕ スポンサーと支援

**本プロジェクトがお役に立ちましたら、以下の方法または [おすすめリンク](../README.md#%EF%B8%8F-%E6%8E%A8%E8%8D%90%E6%9C%8D%E5%8A%A1) を通じて開発をご支援いただけます：**

* TRON (TRC-20)： <code>TCkTtZfF2WrciZLaJj3e1aqrh3zdTnCkDa</code>
* Bitcoin： <code>bc1qu950cl6035qvllmzk6cfw3l30j2lg3cq9n6g6h</code>

---
## ❤️ 謝辞

<table>
  <tr>
    <td>
      <img alt="SignPath" src="https://signpath.org/assets/favicon-50x50.png" />
    </td>
    <td>
    Free code signing on Windows provided by <a href="https://signpath.io">SignPath.io</a>, certificate by <a href="https://signpath.org/">SignPath Foundation</a>
    </td>
  </tr>
</table>

* **[FlClash GUI](https://github.com/chen08209/FlClash)**（本プロジェクトは優れたオープンソースプロジェクト FlClash を起源としています。原作者の先駆的な探求と貢献に心から敬意を表します）
* **[Mihomo Core](https://github.com/MetaCubeX/mihomo)**（強力で柔軟なコアエンジン）

本プロジェクトの発展に貢献してくださったすべての [コントリビューター](https://github.com/appshubcc/Bettbox/graphs/contributors)、そしてインスピレーションと参考元となった以下のオープンソースプロジェクトに感謝いたします：

[Zashboard](https://github.com/Zephyruso/zashboard), [CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN), [Bett-rules](https://github.com/appshubcc/bett-rules)

---
## 📄 オープンソースライセンス

本プロジェクトは [GPL-3.0 License](../LICENSE) のもとで公開されています。
