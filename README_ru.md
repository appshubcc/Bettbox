<h4 align="right">
  <a href="README_zh.md">简体中文</a> | <a href="README.md">English</a> | <strong>Русский</strong> | <a href="README_fa.md">فارسی</a> | <a href="README_ja.md">日本語</a> | <a href="README_ko.md">한국어</a>
</h4>

<h1 align="center">⚡ Bettbox</h1>
<p align="center">
  <strong>Another Better Mihomo Client</strong>
</p>

**Bettbox — это мультиплатформенный клиент для отладки сети и маршрутизации трафика на базе правил, созданный на ядре Mihomo (Clash Meta) и переработанный из ранней версии FlClash.**

Следуя принципу «Better Experience» (Лучший опыт), Bettbox сохраняет отличный UI оригинала, глубоко оптимизируя детали интерфейса и логику функций. Цель: плавная работа в активном режиме и незаметное энергосбережение в фоновом — лёгкий и надёжный клиент Mihomo.

Название Bettbox означает: Better Experience, Out of the box (Превосходный опыт из коробки).

[![Latest Release](https://img.shields.io/github/v/release/appshubcc/Bettbox?style=for-the-badge&logo=github&color=238636&label=Release)](https://github.com/appshubcc/Bettbox/releases/latest) [![Core](https://img.shields.io/github/v/release/MetaCubeX/mihomo?style=for-the-badge&logo=go&logoColor=white&color=8A2BE2&label=Mihomo)](https://github.com/MetaCubeX/mihomo/releases/latest)
---
### ✈️ Сообщество в Telegram

</div>

<div align="left">

[![Telegram Group](https://img.shields.io/badge/Bettbox-Chat-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_chat) [![Telegram Channel](https://img.shields.io/badge/Bettbox-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_channel)

---

## 🛠️ Установка и загрузка

Перейдите на страницу **[[Releases]](https://github.com/appshubcc/Bettbox/releases)**, чтобы скачать актуальный установочный пакет для вашей платформы и системы.


* **Все ПК платформы**: **Windows** (x64/arm64), **macOS** (Intel/Apple Silicon), **Linux** (x64/arm64)
* **Устройства Android**: Android (ARMv8 / ARMv7 / x86_64 / Universal)
* **Android TV**: Поддерживается, опционально ARMv7 32-bit
* **HarmonyOS NEXT**: Совместимо при использовании с [[ZhuoYiTong]](https://harmonyos.cool/android-app)

**Другие способы установки:**<br>
**ArchLinux:** <code>yay -S bettbox-bin</code> или <code>paru -S bettbox-bin</code><br>
**AMD64=v1:** <code>yay -S bettbox-compatible-bin</code> или <code>paru -S bettbox-compatible-bin</code>

---
</div>

## 🚀 Основные особенности

* **Готово к работе**: Стабильное управление правами и удобный TUN/VPN. Предустановленные оптимизации для мгновенного старта.
* **Отточенный UI**: Тщательная проработка UI и взаимодействия. Плавные высококадровые анимации, экономия батареи на мобильных, минимум нагрузки на ПК.
* **Надёжная защита**: Ядро следует основной ветке Mihomo с оперативным внедрением функций и строгой проверкой прав на всех платформах.
* **Высокая отказоустойчивость**: Оптимизация крайних сценариев и двойная проверка конфигурации для надёжности корпоративного уровня.
* **Фокус на производительность**: Нативный ARM64 для ПК, профилирование оборудования и оптимизация Flutter для выжимания максимума из железа.
* **Умные утилиты**: Умный автозапуск/остановка, поддержка режима сна Android, отключение QUIC в один клик и расширенное меню в трее.
* **Наглядные настройки**: Удобная регулировка параметров через UI с мгновенным применением — без ручной правки файлов.
* **Виджеты на главном экране**: Стильные виджеты для удобного контроля скорости сети и состояния системы.
* **Кастомизация**: Разнообразные цветовые темы, пользовательские иконки/заголовки и 10 динамических анимаций спидтеста.
* **Гибкая адаптация**: Наглядное UI-разделение для всех JS-скриптов оверрайда с удобными переключателями.
* **Поддержка старых устройств**: Постоянный релиз сборок Compatible для старых ОС и железа, продлевающий срок службы устройств.
* **Конфиденциальность 100%**: Открытый код, без рекламы, прозрачный CI/CD и доступность для аудита. Нулевой сбор данных в фоне.
* **Внимание к сообществу**: Мы ценим обратную связь и оперативно реагируем на качественные Issue — ваш голос важен.

---

## ❓ FAQ (Часто задаваемые вопросы)

1. **Проблемы с установкой, запуском и безопасностью**:
   - Android устройства: **убедитесь в наличии фоновых разрешений и соответствии системным требованиям**: Android 8.0+
   - Старые ПК: проверьте архитектуру системы, **требуется ли сборка CPU класса Compatible**.
   - **Безопасность: Беттбокс прозрачен и открыт, код успешно прошёл аудит безопасности Signpath.**

2. **Частые проблемы на ПК**:
   - Права администратора Windows: Обрабатываются автоматически при установке — **ручная авторизация не требуется**.
   - Не удается включить виртуальный адаптер TUN: На macOS/Linux **убедитесь, что ввели правильный пароль для прав**.
   - Другие ошибки: Предоставьте Debug информацию и **убедитесь в отсутствии конфликтующих прокси-сервисов**.
   - Если проблема не решена, пожалуйста, создайте ISSUE для обратной связи.

3. **Инструкция по установке на macOS**:
   - Скачайте образ для вашей платформы (Intel / Apple Silicon) и откройте `Bettbox-macos-xx.dmg`.
   - Перетащите значок Bettbox в папку `Applications` (Программы).
   - **Обход блокировок Gatekeeper при первом запуске** ([так как мы пока не приобретали сертификат разработчика Apple](https://support.apple.com/en-us/102445)):
     - **Рекомендуемый**: откройте папку «Программы», **нажмите правой кнопкой мыши по значку Bettbox**, выберите **«Открыть»**, а затем снова **«Открыть»** в окне подтверждения.
     - **Альтернативный**: если запуск заблокирован, перейдите в «Системные настройки» -> «Конфиденциальность и безопасность», найдите Bettbox и нажмите **«Подтвердить вход»**.
   - При первом включении режима TUN введите пароль пользователя Mac для настройки сети.
   - **Если появляется сообщение «Приложение повреждено и его нельзя открыть. Вам следует переместить его в Корзину»**:
     - Это ложное срабатывание macOS Gatekeeper. Откройте Терминал и выполните:
       ```bash
       xattr -d com.apple.quarantine /Applications/Bettbox.app
       ```

4. **Не удается импортировать ссылку на подписку**:
   - **Обязательно сначала сбросьте ссылку**, чтобы убедиться в её работоспособности перед импортом.
   - Если проблема не решена, создайте ISSUE для обратной связи.

5. **Продолжение следует...**

---

## 💻 Разработка и сборка

Пример для Windows:

* Требования: ПК под управлением Windows (ОС ≥ Windows 10)
* Необходимое окружение: Git, Visual Studio, Flutter 3.44.x, Golang, Inno Setup, Rust
* `flutter pub get` (получить зависимости)
* `dart .\setup.dart windows --arch amd64 --out core` (сборка только Core ядра)
* `dart .\setup.dart windows --arch amd64 --out app --compatible` (опциональная совместимая версия)
* Готовые файлы будут находиться в папке `dist/`

Адаптация UI для пользовательских скриптов:

* На примере конфигурации **[MyClash от AIsouler](https://github.com/AIsouler/MyClash)**: достаточно добавить следующую строку первой строкой в скрипт, чтобы задействовать визуальные переключатели Bettbox:
* <code>const Compatible_With_Bettbox = { ruleOptionsEnable: true };</code>

---

### ☕ Спонсорская поддержка

**Если этот проект был вам полезен, вы можете поддержать разработку следующими способами:**

* TRON (TRC-20): <code>TCkTtZfF2WrciZLaJj3e1aqrh3zdTnCkDa</code>
* EVM Compatible: <code>0xF8B1B39431013359D83F38a4e403087624618E67</code>
* Solana: <code>C2YQPcKR2YmrPtBvkE13wckjgescUfMA5HzUioR4rQUd</code>
* Bitcoin: <code>bc1qu950cl6035qvllmzk6cfw3l30j2lg3cq9n6g6h</code>

---

## ❤️ Благодарности

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

**[FlClash GUI](https://github.com/chen08209/FlClash)** - **[Mihomo Core](https://github.com/MetaCubeX/mihomo)**

Благодарим всех участников [Contributors](https://github.com/appshubcc/Bettbox/graphs/contributors) и смежные проекты с открытым исходным кодом:

[CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN)

---

## 📄 Лицензия

Лицензия GPL-3.0
