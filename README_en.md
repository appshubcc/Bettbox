<h4 align="right">
  <a href="README_zh.md">简体中文</a> | <strong>English</strong> | <a href="README_ru.md">Русский</a> | <a href="README_fa.md">فارسی</a> | <a href="README_ja.md">日本語</a> | <a href="README_ko.md">한국어</a>
</h4>

<h1 align="center">⚡ Bettbox</h1>
<p align="center">
  <strong>Another Better Mihomo Client</strong>
</p>

**Bettbox is a cross-platform network debugging and rule-based traffic splitting client powered by the Mihomo (Clash Meta) core and refactored from an early version of FlClash.**

Guided by the principle of "Better Experience", Bettbox inherits the original sleek UI while deeply refining key details and feature logic. Goal: silky-smooth animations in the foreground, zero-impact power saving in the background — a lightweight, rock-solid Mihomo client.

Bettbox stands for: Better Experience, Out of the box.

[![Latest Release](https://img.shields.io/github/v/release/appshubcc/Bettbox?style=for-the-badge&logo=github&color=238636&label=Release)](https://github.com/appshubcc/Bettbox/releases/latest) [![Core](https://img.shields.io/github/v/release/MetaCubeX/mihomo?style=for-the-badge&logo=go&logoColor=white&color=8A2BE2&label=Mihomo)](https://github.com/MetaCubeX/mihomo/releases/latest)
---
### ✈️ Telegram Community

</div>

<div align="left">

[![Telegram Group](https://img.shields.io/badge/Bettbox-Chat-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_chat) [![Telegram Channel](https://img.shields.io/badge/Bettbox-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_channel)

---
### 🛩️ Recommended Services
### Niche IEPL Dedicated Lines  丨  [BBXY (百变小樱)](https://www.bbxy01.com/v2/register?code=c09R)

### Low-cost Direct Connections  丨  [Liangxinyun (良心云)](https://xn--9kqz23b19z.com/#/register?code=VTnrQYAj)  丨  [Yifen (一分机场)](https://xn--4gqx1hgtfdmt.com/#/register?code=AuCiXprV)  丨  [Peiqian (赔钱机场)](https://xn--mes358aby2apfg.com/register?code=z7TUZLmM&cover=sfw)

**Notes**: ❚ ❚ Dedicated lines (with direct backup) offer higher stability, while direct connections supply huge bandwidth at low cost. Good community feedback. Note: These services are unaffiliated with Bettbox. Please assess performance on your own.

---

## 🛠️ Installation & Download

Please visit the **[[Releases]](https://github.com/appshubcc/Bettbox/releases)** page to download the latest package for your platform and system.


* **All Desktop Platforms**: **Windows** (x64/arm64), **macOS** (Intel/Apple Silicon), **Linux** (x64/arm64)
* **Android**: Android (ARMv8 / ARMv7 / x86_64 / Universal)
* **Android TV**: Supported, optional ARMv7 32-bit
* **HarmonyOS NEXT**: Compatible via [[ZhuoYiTong]](https://harmonyos.cool/android-app)

**Other Installation Methods:**<br>
**ArchLinux:** <code>yay -S bettbox-bin</code> or <code>paru -S bettbox-bin</code><br>
**AMD64=v1:** <code>yay -S bettbox-compatible-bin</code> or <code>paru -S bettbox-compatible-bin</code>

---
</div>

## 🚀 Core Features

* **Out of the Box**: Reliable permission management and smooth TUN/VPN experience. Pre-optimized for instant use.
* **Fine-Tuned UI**: Polished UI & interaction logic. High FPS animations, ultra-low mobile power draw, minimal desktop footprint.
* **Security First**: Tracks Mihomo mainline closely with quick feature adoption and strict multi-platform permission verification.
* **Rock-Solid Stability**: Edge-case handling for extreme scenarios with dual config checks for enterprise-grade reliability.
* **Performance Focus**: Native desktop ARM64 support, hardware tiering, and full Flutter optimization to squeeze hardware performance.
* **Smart Utilities**: First seamless multi-platform smart start/stop, Android sleep mode, one-click QUIC disable, rich tray menu.
* **Visual Controls**: Intuitive UI controls with real-time application — no manual config editing needed.
* **Home Widgets**: Elegant built-in widgets to track network speeds and running status at a glance.
* **Personalization**: Rich color themes, custom icons/titles, and 10 dynamic speed-test animations.
* **Open & Adaptable**: Traffic-splitting UI adaptation for all JS override scripts with visual toggle switches.
* **Legacy Support**: Maintained Compatible builds for older OS and hardware to extend device lifecycles.
* **Zero Privacy Risk**: Open-source, ad-free, transparent CI/CD, and fully auditable with zero background telemetry.
* **Community Driven**: Active evaluation of community feedback and priority for quality issues. Your voice is heard.

---

## ❓ FAQ

1. **Installation, Startup & Security**:
   - Android devices: **ensure sufficient background permissions are granted and system requirements are met**: Android 8.0+
   - Older desktop devices: check if your system architecture **requires downloading a specific CPU-grade Compatible version**.
   - **Security**: Bettbox is open-source and transparent with zero privacy uploads. Codebase has passed Signpath security audits.

2. **Desktop Common Issues**:
   - Windows Admin Privileges: Handled automatically during installation — **no manual authorization required**.
   - Unable to enable TUN adapter: On macOS/Linux, **ensure you enter the correct password for authorization**.
   - Other errors: Please provide Debug info and **ensure no conflicting proxy software or services are running**.
   - If issues persist, please submit an ISSUE for feedback.

3. **macOS Installation Guide**:
   - Download the build for your platform (Intel / Apple Silicon) and double-click `Bettbox-macos-xx.dmg`.
   - Drag the Bettbox icon into the `Applications` folder to complete installation.
   - **Bypass initial Gatekeeper blocks** ([as we currently do not purchase Apple Developer Certificates](https://support.apple.com/en-us/102445)):
     - **Recommended**: Open `Applications`, **right-click Bettbox icon**, select **"Open"**, and click **"Open"** again in the prompt.
     - **Alternative**: If double-click is blocked, go to Mac "System Settings" -> "Privacy & Security", find Bettbox and click **"Open Anyway"**.
   - When enabling TUN mode for the first time, enter your Mac system password to allow Bettbox to configure network settings.
   - **If prompted "is damaged and can't be opened. You should move it to the Trash"**:
     - This is a false positive from macOS Gatekeeper for unsigned software. Open Terminal and run:
       ```bash
       xattr -d com.apple.quarantine /Applications/Bettbox.app
       ```

4. **Unable to Import Subscriptions**:
   - **Please try resetting your link first** to ensure it is valid before importing.
   - If issues persist, please submit an ISSUE for feedback.

5. **To be continued...**

---

## 💻 Build & Development

Example for Windows:

* Requirements: Windows device (OS ≥ Windows 10)
* Prerequisites: Git, Visual Studio, Flutter 3.44.x, Golang, Inno Setup, Rust
* `flutter pub get` (fetch dependencies)
* `dart .\setup.dart windows --arch amd64 --out core` (build Core only)
* `dart .\setup.dart windows --arch amd64 --out app --compatible` (optional Compatible version)
* Built artifacts will be located in the `dist/` directory.

Custom Script UI Adaptation:

* Taking AIsouler's **[MyClash Configuration Share](https://github.com/AIsouler/MyClash)** as an example, add the following line at the very top of your script to enable Bettbox's visual toggles directly:
* <code>const Compatible_With_Bettbox = { ruleOptionsEnable: true };</code>

---

### ☕ Sponsorship

**If you find this project helpful, you can sponsor development through the following methods or by using the recommended links above:**

* TRON (TRC-20): <code>TCkTtZfF2WrciZLaJj3e1aqrh3zdTnCkDa</code>
* EVM Compatible: <code>0xF8B1B39431013359D83F38a4e403087624618E67</code>
* Solana: <code>C2YQPcKR2YmrPtBvkE13wckjgescUfMA5HzUioR4rQUd</code>
* Bitcoin: <code>bc1qu950cl6035qvllmzk6cfw3l30j2lg3cq9n6g6h</code>

---

## ❤️ Acknowledgements

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

Thanks to all [Contributors](https://github.com/appshubcc/Bettbox/graphs/contributors) and open-source project references:

[CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN)

---

## 📄 License

GPL-3.0 License
