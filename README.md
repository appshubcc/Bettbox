<h1 align="center">⚡ Bettbox</h1>
<p align="center">
  <strong>Another Better Mihomo Client</strong>
</p>

Bettbox 是一款使用Mihomo(Clash Meta)内核、基于FlClash早期版本进行重构的多平台代理客户端

秉承“Better Experience更优体验”的原则，Bettbox在继承原版优秀界面的基础上，深度优化了诸多细节与实用功能/逻辑。前台流畅丝滑、后台省电无感，致力于成为体验更好、可长期稳定运行的 Mihomo 客户端

Bettbox意为: Better Experience, Out of the box，卓越体验，亦开箱即用

[![Latest Release](https://img.shields.io/github/v/release/appshubcc/Bettbox?style=for-the-badge&logo=github&color=238636&label=Release)](https://github.com/appshubcc/Bettbox/releases/latest) [![Core](https://img.shields.io/github/v/release/MetaCubeX/mihomo?style=for-the-badge&logo=go&logoColor=white&color=8A2BE2&label=Mihomo)](https://github.com/MetaCubeX/mihomo/releases/latest) [![Downloads](https://img.shields.io/github/downloads/appshubcc/Bettbox/total?style=for-the-badge&logo=github&color=007ec6)](https://github.com/appshubcc/Bettbox/releases) 

---

##  推荐服务链接

### 高性价比机场： [一分机场](https://xn--4gqx1hgtfdmt.com/#/register?code=AuCiXprV)   -   [良心云官网](https://xn--9kqz23b19z.com/#/register?code=VTnrQYAj) 
简评: 2元/100G/月起售，大流量套餐：6元/1000GB流量性价比较高，流媒体与AI服务解锁尚可，相对跑路风险较低

**注意** : 以上机场&服务与Bettbox项目并无直接关联，经群友反馈口碑相对尚可，仅日常推荐且后期可能会有变化

---


## 🛠️ 安装与下载

请前往 [Releases](https://github.com/appshubcc/Bettbox/releases) 页面下载最新适合您平台和系统的安装包

* **桌面端多平台**: Windows (x64/arm64), macOS (Intel/Apple Silicon), Linux (x64/arm64)
* **Windows7**: 请配合 [[VxKex]](https://github.com/i486/VxKex/releases) 使用
* **Android平台**: Android (ARMv8/ ARMv7/ x86_64/ Universal) 
* **Android TV**: 已适配,可选ARMv7 32位
* **鸿蒙NEXT**: 请配合 [[卓易通]](https://harmonyos.cool/android-app) 使用

---
### ✈️ Telegram 社区交流

</div>

<div align="left">

[![Telegram Group](https://img.shields.io/badge/Appshub-Chat-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_chat) [![Telegram Channel](https://img.shields.io/badge/Appshub-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_channel)

---
</div>

## 🚀 核心特性

### 深度体验优化
* **开箱即用**：稳定权限处理与舒适 TUN/VPN 体验，预置大陆环境优化参数，开箱即达最佳状态。
* **精雕细琢**：打磨每一处 UI 与交互细节，后台稳定轻量化运行，移动端低能耗，桌面端低占用。

### 安全与稳定性
* **安全守护**：内核紧跟 Mihomo 主线且积极适配新特性，多平台保持严格的权限控制与校验。
* **韧性容错**：优化极端场景下的稳定性，内置配置错误优雅回退机制，确保服务连续可靠性。

### 自由可定制化
* **可视化配置**：提供丰富参数的可视化调节界面，所有改动即时生效，无需繁琐修改配置。
* **首页小组件**：内置多款精致 Widget 小组件，在首页直观掌控实时网速与全局运行状态。
* **个性化定制**：支持丰富色彩主题、自定义图标/标题等，甚至包含了 10 种精美测速动画。

### 多平台与性能优化
* **极致性能**：原生多平台支持桌面端 ARM64 架构，提供硬件性能分级及 Flutter整体性能优化。
* **设备兼容**：持续维护面向旧版系统及老旧硬件的 Compatible 兼容版本，延长设备使用周期。
* **社区导向**：我们会认真评估社区反馈，优先对待高质量的 Issue，你的声音不会无故被淹没。

### 开源纯净透明
* **自动化构建**：基于 GitHub Actions 的全透明 CI/CD 流程，代码即产物，所见即所得。
* **零隐私风险**：完全免费、无广告，代码开源且接受全方位审计，杜绝任何后台隐私收集。

---

##  常见问题

1. 安装后无法启动？
   - **常用设备平台，android-arm64-v8a, windows-amd64, macos-arm64**
   - 安卓端旧设备，请检查是否满足Bettbox的最低系统要求:Android 8.0+
   - 桌面端旧设备，请检查是否需要下载特定CPU等级的Compatible兼容版本
   - 其他问题如持续存在，请提交ISSUE反馈

2. 桌面端常见问题
   - Windows管理员权限：Bettbox在安装时已提前处理，无需手动再次授权
   - 无法开启TUN虚拟网卡：macOS和Linux请确保输入正确密码给与权限授权
   - 其他报错：请提供日志信息，并确保没有冲突的代理软件或服务正在运行
   - 其他问题如持续存在，请提交ISSUE反馈

3. 无法导入订阅链接
   - 请务必先尝试重置链接，确保链接正常后再导入
   - 确保导入的是Clash（Mihomo）格式的订阅链接
   - 其他问题如持续存在，请提交ISSUE反馈

4. 待持续完善补充..

---

##  开发构建

以Windows为例：

* 你需要一台Windows设备（≥Windows 10）
* 必要的软件依赖：Visual Studio，Flutter SDK≥3.44，Golang，Inno Setup，Rust
* dart .\setup.dart windows --arch amd64 --compatible(可选兼容版本)

---

##  致谢

Bettbox 的诞生依赖以下根基项目：

* [FlClash](https://github.com/chen08209/FlClash) - 来自陈师傅的优秀开源项目
* [Mihomo](https://github.com/MetaCubeX/mihomo) - 强大灵活稳定的代理内核

开发构建过程中还额外从以下开源项目获取过灵感(以参考顺序排名)：

[CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN)

---

## 📄 开源协议

延续原项目 GPL-3.0 license 开源协议
