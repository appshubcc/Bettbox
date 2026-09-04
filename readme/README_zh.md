<h4 align="right">
  <a href="../README.md">简体中文</a> | <a href="README_en.md">English</a> | <a href="README_ru.md">Русский</a> | <a href="README_fa.md">فارسی</a> | <a href="README_ja.md">日本語</a> | <a href="README_ko.md">한국어</a>
</h4>

<h1 align="center">⚡ Bettbox</h1>
<p align="center">
  <strong>Another Better Mihomo Client</strong>
</p>

**Bettbox 是一款使用Mihomo(Clash Meta)内核、基于FlClash早期版本进行重构的、多平台网络调试及规则分流客户端**

秉承“Better Experience更优体验”的原则，Bettbox在继承原版优秀界面的基础上，深度优化了诸多细节与实用功能/逻辑。核心特性及设计目标: 前台流畅丝滑、后台省电无感，致力于成为体验更好、以少量资源消耗即可长期稳定运行的 Mihomo 客户端

我们的愿景: Connecting AI, Accelerating Innovation - 连接AI，为创新加速

Bettbox意为: Better Experience, Out of the box - 更好的体验，亦开箱可用

[![Latest Release](https://img.shields.io/github/v/release/appshubcc/Bettbox?style=for-the-badge&logo=github&color=238636&label=Release)](https://github.com/appshubcc/Bettbox/releases/latest) [![Core](https://img.shields.io/github/v/release/MetaCubeX/mihomo?style=for-the-badge&logo=go&logoColor=white&color=8A2BE2&label=Mihomo)](https://github.com/MetaCubeX/mihomo/releases/latest)
---
### ✈️ Telegram 社区交流

</div>

<div align="left">

[![Telegram Group](https://img.shields.io/badge/Bettbox-Chat-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_chat) [![Telegram Channel](https://img.shields.io/badge/Bettbox-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_channel)

---
## 🚀 核心特性

* **开箱即用**：稳定的权限处理与舒适的 TUN/VPN 体验，大量预置优化细节，开箱即达可用状态。
* **精雕细琢**：打磨每处 UI 与功能交互细节，前台高帧率动画流畅，移动端低能耗，桌面端低占用。
* **安全守护**：内核紧跟 Mihomo 主线分支且积极适配最新特性，多平台保持严格的权限控制与校验。
* **稳定容错**：优化多平台极端场景下的边界问题并内置双重配置检测验证，媲美企业级的使用稳定性。
* **性能优先**：桌面端原生 ARM64 架构支持，提供硬件分级和 Flutter 以及原生优化，榨干硬件性能。
* **增强工具**：首个多平台无感智能启停、Android端休眠支持、一键禁用QUIC、托盘菜单增强等等。
* **可视化设置**：提供丰富参数的可视化调节界面，支持改动即时生效，无需繁琐修改配置。
* **首页小组件**：内置多款精致 Widget 小组件，在首页直观掌控实时网速与全局运行状态。
* **个性化定制**：支持丰富色彩主题、自定义图标/标题等，甚至还包含 10 种精美测速动画。
* **自定义适配**：提供首个JS覆写脚本可用的分流 UI 适配，以及自定义可用的可视化便捷开关。
* **专业编辑**：多平台内置高性能重构版code-forge编辑器，甚至可媲美专业级别的编辑器体验。
* **设备兼容**：持续维护面向旧版系统及老旧硬件的 Compatible 兼容版本，延长设备使用周期。
* **零隐私风险**：开源、无广告，全透明的 CI/CD 流程且接受全方位审计，杜绝后台隐私收集。
* **社区导向**：我们会认真评估社区反馈，优先对待高质量的 Issue，你的声音不会无故被淹没。

---
</div>

###   🛩️ 推荐服务
### 小众低调专线  〢  [百变小樱](https://www.bbxy01.com/v2/register?code=c09R)

### 专享68折优惠码：bettbox68

**简评** : ❚ ❚  老牌小众专线，海外团队运营多年，BGP入口+广港&沪日线路，折后约17元/月或127元/年，解锁流媒体与AI，口碑优秀，适合对稳定性和延迟要求较高的用户，小技巧：后台个人中心签到每日可再额外领取5-10GB流量

--------------------------------
### 低价直连  〢  [良心云](https://xn--9kqz23b19z.com/#/register?code=VTnrQYAj)  〢  [一分](https://xn--4gqx1hgtfdmt.com/#/register?code=AuCiXprV)

**简评** : ❚  大流量或资源机为主，跑路风险相对较低（也许？），1000G不限时套餐通常更有性价比，量大管饱，价格低廉，适合要求不高的用户或备用流量及大流量下载选择

---
## 🛠️ 安装与下载

请前往 **[[Releases]](https://github.com/appshubcc/Bettbox/releases)** 页面下载最新适合您平台和系统的安装包


* **全平台桌面端**: 
**Windows 8.1+:** (x64/arm64)
**Linux Kernel 5.4+:** (x64/arm64)
**macOS 10.15+:** (Intel/Apple Silicon)
* **Android 8.0+:** Android (ARMv8/ ARMv7/ x86_64/ Universal) 
* **Android TV:** 已完整适配，可选 ARMv7 32位
* **鸿蒙 NEXT:** 可配合 [[卓易通]](https://harmonyos.cool/android-app) 使用

**其他安装方式:**<br>
**ArchLinux:** <code>yay -S bettbox-bin 或 paru -S bettbox-bin</code> (由[lyj404](https://github.com/lyj404/bettbox-aur)维护)<br>
**AMD64=v1:** <code>yay -S bettbox-compatible-bin 或 paru -S bettbox-compatible-bin</code> (由[VillagerTom](https://github.com/VillagerTom)维护)

---
##  常见问题

1.  **安装启动及安全问题**：
   - 安卓端设备，请检查**是否授予了充足的后台权限，并满足最低系统要求**:Android 8.0+
   - 桌面端旧设备，请检查系统平台架构**是否需要下载特定CPU等级的Compatible版本**
   - **安全相关：Bettbox 项目开源透明零隐私上传，当前代码已通过 Signpath 安全审计**

2.  **桌面端常见问题**：
   - Windows管理员权限：Bettbox在安装时已提前处理，**无需手动再次授权**
   - 无法开启TUN虚拟网卡：macOS和Linux**请确保输入正确密码给与权限授权**
   - 其他报错：请提供Debug信息，并**确保没有冲突的代理软件或服务正在运行**
   - 其他问题如持续存在，请提交ISSUE反馈

3.  **macOS安装注意事项**：
   - 根据所属平台(Intel/Apple Silicon)下载完成后，双击打开 Bettbox-macos-xx.dmg 文件
   - 将 Bettbox 图标拖拽至 Applications（应用程序）文件夹中即可完成安装
   - **安装或更新时避开系统安全拦截**（[由于当前暂未购买 Apple 开发者证书](https://support.apple.com/en-us/102445)）：
     - **推荐**：进入“应用程序”文件夹，**右键 Bettbox 图标**，选择 **“打开”**，在确认弹窗中再次点击 **“打开”** 即可
     - **备选**：如果直接双击被阻止，请前往 Mac 系统“设置” -> “隐私与安全性”，找到 Bettbox 并点击 **“仍要打开”**
   - 首次开启 TUN 模式时，系统会弹出密码授权窗口，请输入当前登录用户的密码以允许 Bettbox 配置网络

4.  **无法导入订阅链接**：
   - **请务必先尝试重置链接**，确保链接正常后导入
   - 其他问题如持续存在，请先联系服务商解决，如为APP原因，则提交ISSUE反馈

---

##  开发构建及UI适配

以 Windows 平台构建为例：

* 你需要一台 Windows 设备（系统 ≥ Windows 10）
* 其他必要环境：Git，Visual Studio，Flutter 3.44.x，Golang，Inno Setup，Rust
```bash
* flutter pub get (获取相关依赖)
* dart .\setup.dart windows --arch amd64 --out core (仅构建Core核心)
* dart .\setup.dart windows --arch amd64 --out app --compatible (可选兼容版本)
* 构建完成后，最终产物位于 `dist/` 目录
```

自定义脚本 UI 适配：

* Bettbox自v1.18.8版本起支持外置覆写脚本适配UI，例如以AIsouler的**[脚本/配置分享](https://github.com/AIsouler/MyClash)**为例，仅需要在脚本首行添加以下声明，即可直接使用Bettbox内置的可视化开关。
* <code>const Compatible_With_Bettbox = { ruleOptionsEnable: true };</code>

---

### ☕ 赞助支持

**如果您觉得这个项目对您有所帮助，可通过以下方式赞助开发或使用推荐链接：**

* TRON (TRC-20)：   <code>TCkTtZfF2WrciZLaJj3e1aqrh3zdTnCkDa</code>
* Bitcoin： <code>bc1qu950cl6035qvllmzk6cfw3l30j2lg3cq9n6g6h</code>
---

##  致谢

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

**[FlClash GUI](https://github.com/chen08209/FlClash)** 〢 **[Mihomo Core](https://github.com/MetaCubeX/mihomo)**

其他为本项目添砖加瓦的 [Contributors](https://github.com/appshubcc/Bettbox/graphs/contributors) 以及相关开源项目使用或参考

[Zashboard](https://github.com/Zephyruso/zashboard), [CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN)

---

## 📄 开源协议

GPL-3.0 license 开源协议
