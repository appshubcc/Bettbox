<h4 align="right">
  <a href="../README.md">简体中文</a> | <a href="README_en.md">English</a> | <strong>Русский</strong> | <a href="README_fa.md">فارسی</a> | <a href="README_ja.md">日本語</a> | <a href="README_ko.md">한국어</a>
</h4>

<h1 align="center">⚡ Bettbox</h1>
<p align="center">
  <strong>Another Better Mihomo Client</strong>
</p>

**Bettbox — это мультиплатформенный клиент для отладки сети и маршрутизации трафика на базе правил, созданный на ядре Mihomo (Clash Meta) и переработанный из ранней версии FlClash.**

Следуя принципу «Better Experience» (Лучший опыт), Bettbox сохраняет отличный UI оригинала, глубоко оптимизируя детали интерфейса и логику функций. Ключевые особенности и цели: плавная работа в активном режиме и незаметное энергосбережение в фоновом — надёжный клиент Mihomo для долгосрочной стабильной работы с минимальным потреблением ресурсов.

Наше видение: Connecting AI, Accelerating Innovation — Соединяя ИИ, ускоряем инновации

Название Bettbox означает: Better Experience, Out of the box — Превосходный опыт из коробки.

[![Latest Release](https://img.shields.io/github/v/release/appshubcc/Bettbox?style=for-the-badge&logo=github&color=238636&label=Release)](https://github.com/appshubcc/Bettbox/releases/latest) [![Core](https://img.shields.io/github/v/release/MetaCubeX/mihomo?style=for-the-badge&logo=go&logoColor=white&color=8A2BE2&label=Mihomo)](https://github.com/MetaCubeX/mihomo/releases/latest)
---
### ✈️ Сообщество в Telegram

</div>

<div align="left">

[![Telegram Group](https://img.shields.io/badge/Bettbox-Chat-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_chat) [![Telegram Channel](https://img.shields.io/badge/Bettbox-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/appshub_channel)

---
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
* **Профессиональный редактор**: Встроенный высокопроизводительный редактор code-forge на всех платформах, не уступающий профессиональным IDE.
* **Поддержка старых устройств**: Постоянный релиз сборок Compatible для старых ОС и железа, продлевающий срок службы устройств.
* **Конфиденциальность 100%**: Открытый код, без рекламы, прозрачный CI/CD и доступность для аудита. Нулевой сбор данных в фоне.
* **Внимание к сообществу**: Мы ценим обратную связь и оперативно реагируем на качественные Issue — ваш голос важен.

---
</div>

## 🛠️ Установка и загрузка

Перейдите на страницу **[[Releases]](https://github.com/appshubcc/Bettbox/releases)**, чтобы скачать актуальный установочный пакет для вашей платформы и системы.


* **Все ПК платформы**: 
**Windows 8.1+:** (x64/arm64)
**Linux Kernel 5.4+:** (x64/arm64)
**macOS 10.15+:** (Intel/Apple Silicon)
* **Устройства Android 8.0+:** Android (ARMv8 / ARMv7 / x86_64 / Universal)
* **Android TV:** Полностью адаптирован, опционально ARMv7 32-bit
* **HarmonyOS NEXT:** Совместимо при использовании с [[ZhuoYiTong]](https://harmonyos.cool/android-app)

**Другие способы установки:**<br>
**ArchLinux:** <code>yay -S bettbox-bin или paru -S bettbox-bin</code> (поддерживается [lyj404](https://github.com/lyj404/bettbox-aur))<br>
**AMD64=v1:** <code>yay -S bettbox-compatible-bin или paru -S bettbox-compatible-bin</code> (поддерживается [VillagerTom](https://github.com/VillagerTom))

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

3. **Важные примечания по установке на macOS**:
   - Скачайте образ для вашей платформы (Intel / Apple Silicon) и откройте `Bettbox-macos-xx.dmg`.
   - Перетащите значок Bettbox в папку `Applications` (Программы).
   - **Обход блокировок Gatekeeper при установке или обновлении** ([так как мы пока не приобретали сертификат разработчика Apple](https://support.apple.com/en-us/102445)):
     - **Рекомендуемый**: откройте папку «Программы», **нажмите правой кнопкой мыши по значку Bettbox**, выберите **«Открыть»**, а затем снова **«Открыть»** в окне подтверждения.
     - **Альтернативный**: если запуск заблокирован, перейдите в «Системные настройки» -> «Конфиденциальность и безопасность», найдите Bettbox и нажмите **«Подтвердить вход»**.
   - При первом включении режима TUN введите пароль текущего вошедшего пользователя Mac для настройки сети.

4. **Не удается импортировать ссылку на подписку**:
   - **Обязательно сначала сбросьте ссылку**, чтобы убедиться в её работоспособности перед импортом.
   - Если проблема не устранена, сначала обратитесь к поставщику услуг. Если проблема на стороне приложения, создайте ISSUE для обратной связи.

---

## 💻 Разработка и сборка

Пример для Windows:

* Требуется ПК с Windows (ОС ≥ Windows 10)
* Окружение: Git, Visual Studio, Flutter 3.44.x, Golang, Inno Setup, Rust
```bash
* flutter pub get
* dart .\setup.dart windows --arch amd64 --out core (Только ядро)
* dart .\setup.dart windows --arch amd64 --out app --compatible (Опциональная сборка Compatible)
* Готовые файлы располагаются в директории `dist/`
```

Адаптация пользовательских скриптов UI:

* Начиная с v1.18.8, Bettbox поддерживает внешние скрипты оверрайда для UI. Например, для конфигураций AIsouler **[Репозиторий скриптов](https://github.com/AIsouler/MyClash)** достаточно добавить строку в начало скрипта:
* <code>const Compatible_With_Bettbox = { ruleOptionsEnable: true };</code>

---

### ☕ Поддержка проекта

**Если вам нравится проект, вы можете поддержать разработку:**

* TRON (TRC-20):   <code>TCkTtZfF2WrciZLaJj3e1aqrh3zdTnCkDa</code>
* Bitcoin: <code>bc1qu950cl6035qvllmzk6cfw3l30j2lg3cq9n6g6h</code>
---

## 🙏 Благодарности

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

Отдельное спасибо всем [Участникам](https://github.com/appshubcc/Bettbox/graphs/contributors), а также используемым и связанным открытым проектам:

[Zashboard](https://github.com/Zephyruso/zashboard), [CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid), [Sparkle](https://github.com/xishang0128/sparkle), [SFA](https://github.com/SagerNet/sing-box-for-android), [HUSI](https://github.com/xchacha20-poly1305/husi), [V2rayN](https://github.com/2dust/v2rayN)

---

## 📄 Лицензия

Лицензия GPL-3.0
