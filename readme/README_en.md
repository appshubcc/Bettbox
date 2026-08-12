<h4 align="right">
  <a href="../README.md">简体中文</a> | <strong>English</strong> | <a href="README_ru.md">Русский</a> | <a href="README_fa.md">فارسی</a> | <a href="README_ja.md">日本語</a> | <a href="README_ko.md">한국어</a>
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
## 🚀 Core Features

* **Out-of-the-Box**: Robust permission handling and smooth TUN/VPN experience with optimized defaults for instant usability.
* **Meticulously Crafted**: Polished UI and interaction details. High FPS foreground animations, ultra-low mobile power consumption, and minimal desktop footprint.
* **Security First**: Core tracks the main Mihomo branch with rapid feature adoption, maintaining strict cross-platform permission checks.
* **Rock-Solid Fault Tolerance**: Edge-case optimizations for extreme multi-platform scenarios and dual config verification for enterprise-grade stability.
* **Performance Focused**: Native desktop ARM64 support, hardware tiering, and Flutter/native optimizations to maximize performance.
* **Enhanced Utilities**: Industry-first multi-platform seamless smart start/stop, Android sleep support, one-click QUIC toggle, and enhanced tray menu.
* **Visual Settings**: Rich visual configuration parameters with real-time application — no tedious manual config editing required.
* **Home Widgets**: Exquisite built-in widgets for real-time speed monitoring and system state tracking at a glance.
* **Personalized Customization**: Rich color themes, custom icons/titles, and 10 dynamic speedtest animations.
* **Custom Adaptation**: First-in-class JS script override UI adaptation with visual toggles.
* **Professional Code Editor**: Built-in refactored high-performance code-forge editor across platforms, matching IDE-level editing experience.
* **Device Compatibility**: Actively maintained Compatible builds for legacy OS versions and older hardware, extending device lifespans.
* **Zero Privacy Risk**: Fully open-source, ad-free, transparent CI/CD, and fully audited to ensure zero background telemetry.
* **Community Driven**: Community feedback is carefully evaluated, prioritizing high-quality issues to ensure your voice is heard.

---
</div>

###   🛩️ Recommended Services
### Premium Dedicated Line  〢  [BBXY](https://www.bbxy01.com/v2/register?code=c09R)

### Bettbox Exclusive Discount Code (32% OFF): bettbox68

**Review** : ❚ ❚  Established premium line operated overseas for years with excellent stability and reputation. Approx. ¥17/mo or ¥127/yr after discount. Ideal for users demanding high stability and low latency. Extra 5-10GB bonus bandwidth per daily check-in.

--------------------------------
### Low-Cost Direct  〢  [Liangxin Cloud](https://xn--9kqz23b19z.com/#/register?code=VTnrQYAj)  〢  [YiFen](https://xn--4gqx1hgtfdmt.com/#/register?code=AuCiXprV)  〢  [Peiqian](https://xn--mes358aby2apfg.com/register?code=z7TUZLmM&cover=sfw)

**Review** : ❚  AWS/Channel servers with lower direct-connection risks. 1000GB non-expiring packages offer great cost-performance. High volume at low prices, ideal for budget users or backup usage.

---
## 🛠️ Installation & Downloads

Please visit the **[[Releases]](https://github.com/appshubcc/Bettbox/releases)** page to download the latest installer for your platform.


* **Cross-Platform Desktop**: 
**Windows 8.1+:** (x64/arm64)
**Linux Kernel 5.4+:** (x64/arm64)
**macOS 10.15+:** (Intel/Apple Silicon)
* **Android 8.0+:** Android (ARMv8/ ARMv7/ x86_64/ Universal) 
* **Android TV:** Adapted, optional ARMv7 32-bit
* **HarmonyOS NEXT:** Supported via [[ZhuoYiTong]](https://harmonyos.cool/android-app)

**Other Installation Methods:**<br>
**ArchLinux:** <code>yay -S bettbox-bin or paru -S bettbox-bin</code> (Maintained by [lyj404](https://github.com/lyj404/bettbox-aur))<br>
**AMD64=v1:** <code>yay -S bettbox-compatible-bin or paru -S bettbox-compatible-bin</code> (Maintained by [VillagerTom](https://github.com/VillagerTom))

---
## ❓ Frequently Asked Questions

1.  **Installation, Startup & Security Issues**:
   - Android devices: **Ensure sufficient background permissions are granted and minimum requirements are met**: Android 8.0+
   - Legacy desktop devices: Check if your CPU architecture **requires downloading a specific CPU-level Compatible version**.
   - **Security: Bettbox is fully open-source and transparent with zero telemetry. Current builds have passed SignPath security audit.**

2.  **Desktop FAQs**:
   - Windows Admin Permissions: Handled automatically during installation — **no manual re-authorization required**.
   - Unable to enable TUN mode: macOS and Linux users **must enter the correct password to grant network permissions**.
   - Other errors: Provide debug logs and **ensure no conflicting proxy software or services are running**.
   - If issues persist, please submit a GitHub Issue.

3.  **macOS Installation Guide**:
   - Download the appropriate `.dmg` file for your architecture (Intel / Apple Silicon) and double-click to open.
   - Drag the Bettbox icon into the `Applications` folder.
   - **Bypassing macOS Gatekeeper on first launch** ([as Apple Developer Certificate is not currently purchased](https://support.apple.com/en-us/102445)):
     - **Recommended**: Open `Applications`, **right-click the Bettbox icon**, select **"Open"**, and click **"Open"** again in the confirmation prompt.
     - **Alternative**: If blocked, go to System Settings -> Privacy & Security, scroll to find Bettbox, and click **"Open Anyway"**.
   - Upon enabling TUN mode for the first time, enter your Mac system password when prompted.
   - **If prompted "App is damaged and can't be opened. You should move it to the Trash"**:
     - This is a false positive from macOS Gatekeeper for unsigned apps. Open Terminal and run:
       ```bash
       xattr -d com.apple.quarantine /Applications/Bettbox.app
       ```

4.  **Unable to Import Subscription Links**:
   - **Always try resetting the subscription link first** to ensure it is valid before importing.
   - If issues persist, please submit a GitHub Issue.

5.  **More FAQs coming soon...**

---

## 💻 Build & UI Customization

Building on Windows:

* Requires a Windows PC (OS ≥ Windows 10)
* Dependencies: Git, Visual Studio, Flutter 3.44.x, Golang, Inno Setup, Rust
```bash
* flutter pub get
* dart .\setup.dart windows --arch amd64 --out core (Build Core only)
* dart .\setup.dart windows --arch amd64 --out app --compatible (Optional Compatible build)
* Output binaries are located in the `dist/` directory
```

Custom Script UI Adaptation:

* Starting from v1.18.8, Bettbox supports external override scripts for UI adaptation. Taking AIsouler's **[Script/Config Repository](https://github.com/AIsouler/MyClash)** as an example, simply add the following declaration on the first line of your script to enable Bettbox built-in visual toggles:
* <code>const Compatible_With_Bettbox = { ruleOptionsEnable: true };</code>

---

### ☕ Sponsorship

**If you find this project helpful, consider supporting development via:**

* EVM Compatible:  <code>0xF8B1B39431013359D83F38a4e403087624618E67</code>
* Bitcoin: <code>bc1qu950cl6035qvllmzk6cfw3l30j2lg3cq9n6g6h</code>
---

## 🙏 Acknowledgments

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

Special thanks to all [Contributors](https://github.com/appshubcc/Bettbox/graphs/contributors) and referenced open-source projects:

[CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN)

---

## 📄 License

GPL-3.0 License
