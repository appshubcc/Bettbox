// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(log) => "Проанализируй лог Bettbox (Mihomo): ${log}";

  static String m1(error) => "Ошибка автоматического резервирования: ${error}";

  static String m2(value) => "Сред. ${value}";

  static String m3(count) =>
      "${Intl.plural(count, one: 'день', few: 'дня', many: 'дней', other: 'дней')}";

  static String m4(label) => "Удалить выбранные ${label}?";

  static String m5(label) => "Удалить текущий ${label}?";

  static String m6(reason) => "Fake-IP · ${reason}: реальный IP";

  static String m7(reason, range) =>
      "Fake-IP · ${reason}: виртуальный адрес из ${range}";

  static String m8(ips) => "Совпадение в Hosts: ${ips}";

  static String m9(outbound) => "Через «${outbound}», домен разрешает узел";

  static String m10(outbound) =>
      "Через «${outbound}», домен разрешает узел; Hosts не действует";

  static String m11(label) => "${label} не может быть пустым";

  static String m12(label) => "${label} уже существует";

  static String m13(count) =>
      "${Intl.plural(count, one: 'час', few: 'часа', many: 'часов', other: 'часов')}";

  static String m14(port) => "Порт ${port} уже занят. Выберите другой";

  static String m15(code) => "Сервер отклонил тест (ошибка ${code})";

  static String m16(lost, total) => "${lost}/${total} пакетов";

  static String m17(name) => "Отсканировано: ${name}";

  static String m18(value) => "${value} с";

  static String m19(port) => "Ожидание на порту ${port}";

  static String m20(count) => "Потоков: ${count}";

  static String m21(count) => "${count}";

  static String m22(count) => "${count} байт";

  static String m23(address) => "От ${address}";

  static String m24(count) =>
      "Показаны последние ${count}. Скопируйте результат, чтобы увидеть все";

  static String m25(min, avg, max, jitter) =>
      "Время отклика: мин. ${min} / сред. ${avg} / макс. ${max} / джиттер ${jitter} мс";

  static String m26(target) => "Статистика Ping для ${target}";

  static String m27(sent, received, lost, loss) =>
      "Отправлено ${sent}, получено ${received}, потеряно ${lost} (${loss}% потерь)";

  static String m28(level) =>
      "Режим ${level} подходит для отладки сети; в обычной работе его лучше отключить";

  static String m29(done, total, unlocked) =>
      "Проверено ${done}/${total} · доступно ${unlocked}";

  static String m30(count) =>
      "${Intl.plural(count, one: 'минуту', few: 'минуты', many: 'минут', other: 'минут')}";

  static String m31(count) =>
      "${Intl.plural(count, one: 'месяц', few: 'месяца', many: 'месяцев', other: 'месяцев')}";

  static String m32(count) => "${count} записей";

  static String m33(ip) => "через ${ip}";

  static String m34(count) => "Новых логов: ${count}";

  static String m35(label) => "${label} отсутствует";

  static String m36(min, max) => "Введите целое число от ${min} до ${max}";

  static String m37(label) => "${label} должен быть числом";

  static String m38(label) => "Только ${label}";

  static String m39(label) =>
      "${label} должен быть от 1024 до 49151, 0 для отключения";

  static String m40(statusCode) =>
      "Не удалось импортировать профиль. Проверьте состояние сети или попробуйте сбросить ссылку подписки ( код ошибки HTTP: ${statusCode} )";

  static String m41(index, time) => "Разрешено правилом #${index} · ${time} мс";

  static String m42(ips) => "Совпадение в hosts: ${ips}";

  static String m43(total, index) => "Правил: ${total}, совпало #${index}";

  static String m44(total) => "Правил: ${total}";

  static String m45(count) => "Выбрано: ${count}";

  static String m46(count) =>
      "Несколько — ${count} параллельных соединений для полной загрузки канала";

  static String m47(provider) =>
      "Выход может блокировать тесты ${provider}. Смените источник теста или выход.";

  static String m48(protocol, fallback) =>
      "${protocol} недоступен, используется ${fallback}";

  static String m49(count) => "Соединений: ${count}";

  static String m50(provider) => "Переключить на ${provider}";

  static String m51(online, total) => "${online} / ${total} в сети";

  static String m52(region) => "Ретранслятор ${region}";

  static String m53(label) => "${label} должен быть URL";

  static String m54(count) =>
      "${Intl.plural(count, one: 'год', few: 'года', many: 'лет', other: 'лет')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage(
      "Маршрутизация приложений",
    ),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Только выбранные приложения используют VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Белый и чёрный списки приложений",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения исключены из VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "action_start": MessageLookupByLibrary.simpleMessage("Запуск/Остановка"),
    "action_tun": MessageLookupByLibrary.simpleMessage("Режим TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "activeGoroutines": MessageLookupByLibrary.simpleMessage("Goroutines"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addTunnel": MessageLookupByLibrary.simpleMessage(
      "Добавить перенаправление",
    ),
    "addUser": MessageLookupByLibrary.simpleMessage("Добавить пользователя"),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage(
      "Добавить к исходным правилам",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("Адрес сервера WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес WebDAV",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Автозапуск от администратора",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Автозапуск с правами администратора",
    ),
    "advancedSettings": MessageLookupByLibrary.simpleMessage(
      "Расширенные настройки",
    ),
    "ageCipherText": MessageLookupByLibrary.simpleMessage(
      "Шифртекст (-----BEGIN AGE ENCRYPTED FILE-----)",
    ),
    "ageDecryptFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка расшифровки",
    ),
    "ageEncryptFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка шифрования",
    ),
    "ageFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "Файл слишком большой (макс. 8 МБ)",
    ),
    "ageGenerateKeyPair": MessageLookupByLibrary.simpleMessage(
      "Новая пара ключей",
    ),
    "ageInputRequired": MessageLookupByLibrary.simpleMessage(
      "Введите текст или выберите файл",
    ),
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "Генерация ключа Age",
    ),
    "ageKeyHybridTip": MessageLookupByLibrary.simpleMessage(
      "Постквантовый гибридный ключ. Надёжнее, но открытый ключ намного длиннее и требует age v1.3 или новее.",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "Пара ключей X25519 создана, сохраните её в надёжном месте",
    ),
    "ageKeyType": MessageLookupByLibrary.simpleMessage("Тип ключа"),
    "ageNotEncrypted": MessageLookupByLibrary.simpleMessage(
      "Содержимое не зашифровано Age",
    ),
    "ageOutput": MessageLookupByLibrary.simpleMessage("Результат"),
    "agePlainText": MessageLookupByLibrary.simpleMessage("Открытый текст"),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage(
      "Приватный ключ",
    ),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, сначала введите корректный приватный ключ Age",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage("Публичный ключ"),
    "ageRecipientRequired": MessageLookupByLibrary.simpleMessage(
      "Укажите хотя бы один открытый ключ",
    ),
    "ageRecipients": MessageLookupByLibrary.simpleMessage(
      "Открытые ключи получателей",
    ),
    "ageRecipientsHint": MessageLookupByLibrary.simpleMessage(
      "Можно несколько, по одному ключу age1… на строку",
    ),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите корректный приватный ключ Age (должен начинаться с AGE-SECRET-KEY-)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage(
      "Приватный ключ Age (необязательно)",
    ),
    "ageTabDecrypt": MessageLookupByLibrary.simpleMessage("Расшифровать"),
    "ageTabEncrypt": MessageLookupByLibrary.simpleMessage("Зашифровать"),
    "ageTabKeys": MessageLookupByLibrary.simpleMessage("Ключи"),
    "ageTool": MessageLookupByLibrary.simpleMessage(
      "Шифрование и расшифровка Age",
    ),
    "ageToolDesc": MessageLookupByLibrary.simpleMessage(
      "Ключи, шифрование и расшифровка текста и конфигов",
    ),
    "ageToolTip": MessageLookupByLibrary.simpleMessage(
      "Всё выполняется локально, закрытые ключи не сохраняются и не передаются.",
    ),
    "ageUseForEncrypt": MessageLookupByLibrary.simpleMessage(
      "Использовать для шифрования",
    ),
    "ageUseProfileKey": MessageLookupByLibrary.simpleMessage(
      "Ключ текущего профиля",
    ),
    "ago": MessageLookupByLibrary.simpleMessage(" назад"),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allApps": MessageLookupByLibrary.simpleMessage("Все приложения"),
    "allocatedMemory": MessageLookupByLibrary.simpleMessage("Выделено"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("Разрешить обход VPN"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Некоторые приложения смогут обходить VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN доступ"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить доступ из локальной сети",
    ),
    "alreadyInWhitelist": MessageLookupByLibrary.simpleMessage(
      "Уже в белом списке",
    ),
    "alwaysShowTitleBar": MessageLookupByLibrary.simpleMessage(
      "Кнопки заголовка",
    ),
    "alwaysShowTitleBarDesc": MessageLookupByLibrary.simpleMessage(
      "Всегда показывать кнопки в правом верхнем углу",
    ),
    "analyzeLogPrompt": m0,
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Маршрутизация приложений",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage("Настройки приложения"),
    "application": MessageLookupByLibrary.simpleMessage("Приложение"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки приложения",
    ),
    "authorized": MessageLookupByLibrary.simpleMessage("Авторизован"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoBackup": MessageLookupByLibrary.simpleMessage(
      "Автоматическое резервирование",
    ),
    "autoBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Автобэкап при изменении профилей",
    ),
    "autoBackupFailed": m1,
    "autoBackupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервная копия автоматически сохранена в WebDAV",
    ),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка обновлений при запуске",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Автозакрытие соединений",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Закрывать соединения при смене узла",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автозапуск"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запуск при старте системы",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автоподключение"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Подключаться при запуске приложения",
    ),
    "autoScroll": MessageLookupByLibrary.simpleMessage("Автопрокрутка"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Автоматически настроить системный DNS",
    ),
    "autoStickyHeader": MessageLookupByLibrary.simpleMessage(
      "Автозакрепление заголовка",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (минуты)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "backup": MessageLookupByLibrary.simpleMessage("Создать копию"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или локально",
    ),
    "backupEncryptedTip": MessageLookupByLibrary.simpleMessage(
      "Резервная копия зашифрована AES-256",
    ),
    "backupPassword": MessageLookupByLibrary.simpleMessage(
      "Пароль резервной копии",
    ),
    "backupPasswordDesc": MessageLookupByLibrary.simpleMessage(
      "Шифрование AES-256 (пусто — без пароля)",
    ),
    "backupPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Эта резервная копия зашифрована, введите пароль",
    ),
    "backupPasswordTip": MessageLookupByLibrary.simpleMessage(
      "Поддерживаются только латинские буквы, цифры и символы",
    ),
    "backupPasswordWrong": MessageLookupByLibrary.simpleMessage(
      "Неверный пароль резервной копии",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование успешно",
    ),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Конфигурация ядра"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Глобальное изменение конфигурации ядра",
    ),
    "batteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Оптимизация батареи",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Запросить добавление в белый список энергосбережения",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "blacklist": MessageLookupByLibrary.simpleMessage("Чёрный список"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Режим чёрного списка",
    ),
    "blockComment": MessageLookupByLibrary.simpleMessage("Комментарий"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключить домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только при включённом системном прокси",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Исключить локальные сети (LAN)",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Направлять локальные IP-адреса в обход прокси",
    ),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage(
      "Алгоритм кэширования",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить?",
    ),
    "cameraPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Доступ к камере запрещён",
    ),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Для сканирования QR-кода требуется доступ к камере. Пожалуйста, предоставьте разрешение в настройках.",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Показать системные приложения",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Отменить выбор"),
    "categoryAi": MessageLookupByLibrary.simpleMessage("AI"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("Все"),
    "categoryChina": MessageLookupByLibrary.simpleMessage("Китай (прямой)"),
    "categoryCrypto": MessageLookupByLibrary.simpleMessage("Криптовалюта"),
    "categoryDeveloper": MessageLookupByLibrary.simpleMessage(
      "Для разработчиков",
    ),
    "categoryGaming": MessageLookupByLibrary.simpleMessage("Игровой центр"),
    "categorySocial": MessageLookupByLibrary.simpleMessage("Сообщество"),
    "categoryStreaming": MessageLookupByLibrary.simpleMessage("Стриминг"),
    "chasingDots": MessageLookupByLibrary.simpleMessage("Догоняющие точки"),
    "checkError": MessageLookupByLibrary.simpleMessage("Ошибка проверки"),
    "checkFailed": MessageLookupByLibrary.simpleMessage("Timeout"),
    "checkOrAddProfile": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Установлена последняя версия",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Проверка..."),
    "circle": MessageLookupByLibrary.simpleMessage("Круг"),
    "clear": MessageLookupByLibrary.simpleMessage("Очистить"),
    "clearCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Очистить кэш FakeIP и DNS?",
    ),
    "clearCacheTitle": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clearDataTipDesc": MessageLookupByLibrary.simpleMessage(
      "Это действие сбросит настройки приложения. Пожалуйста, сделайте резервную копию. Вы уверены, что хотите продолжить?",
    ),
    "clearDataTipTitle": MessageLookupByLibrary.simpleMessage(
      "Опасная операция",
    ),
    "clearFilter": MessageLookupByLibrary.simpleMessage("Сбросить фильтры"),
    "clipboard": MessageLookupByLibrary.simpleMessage("Буфер обмена"),
    "clipboardDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически получать ссылки из буфера обмена",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Экспорт в буфер"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Импорт из буфера"),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "closeAll": MessageLookupByLibrary.simpleMessage("Закрыть все"),
    "collapse": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Цветовые схемы"),
    "columns": MessageLookupByLibrary.simpleMessage("Колонки"),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "Включает полную поддержку Clash с потерей некоторых функций",
    ),
    "concurrencyLimit": MessageLookupByLibrary.simpleMessage(
      "Лимит параллелизма",
    ),
    "concurrencyLimitDesc": MessageLookupByLibrary.simpleMessage(
      "Максимальное количество параллельных тестов задержки",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "Управление перегрузкой",
    ),
    "connection": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectionsActive": MessageLookupByLibrary.simpleMessage("Активные"),
    "connectionsClosed": MessageLookupByLibrary.simpleMessage("Закрытые"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр активных и закрытых соединений",
    ),
    "connectionsSort": MessageLookupByLibrary.simpleMessage(
      "Сортировка соединений",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Подключение: "),
    "contactMe": MessageLookupByLibrary.simpleMessage("Связаться со мной"),
    "content": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Контентная тема"),
    "continent": MessageLookupByLibrary.simpleMessage("Континент"),
    "controlSecret": MessageLookupByLibrary.simpleMessage("Пароль управления"),
    "controlSecretDesc": MessageLookupByLibrary.simpleMessage(
      "Пароль для доступа к RESTful API",
    ),
    "copiedPackageName": MessageLookupByLibrary.simpleMessage(
      "Скопировано имя пакета",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Скопировано в буфер обмена",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreCapabilityNotEffective": MessageLookupByLibrary.simpleMessage(
      "Авторизация ядра не применилась: у запущенного ядра нет CAP_NET_ADMIN, TUN может не работать",
    ),
    "coreConnected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Информация о ядре"),
    "coreMountNosuid": MessageLookupByLibrary.simpleMessage(
      "Ядро находится на файловой системе, смонтированной с nosuid, поэтому file capabilities и setuid не действуют",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Статус ядра"),
    "coreSuspended": MessageLookupByLibrary.simpleMessage("Приостановлено"),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "countryOrRegion": MessageLookupByLibrary.simpleMessage("Страна / Регион"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "cubeGrid": MessageLookupByLibrary.simpleMessage("Сетка кубов"),
    "custom": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "Пользовательский заголовок",
    ),
    "customScriptOptions": MessageLookupByLibrary.simpleMessage("Свои правила"),
    "customUrl": MessageLookupByLibrary.simpleMessage("Пользовательский URL"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dancingSquare": MessageLookupByLibrary.simpleMessage("Танцующий квадрат"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "darkIcon": MessageLookupByLibrary.simpleMessage("Тёмная иконка"),
    "darkIconDesc": MessageLookupByLibrary.simpleMessage(
      "Вручную переключить на тёмную иконку приложения",
    ),
    "dashboard": MessageLookupByLibrary.simpleMessage("Главная"),
    "dashboardAverage": m2,
    "dashboardTotal": MessageLookupByLibrary.simpleMessage("Всего"),
    "days": m3,
    "defaultGateway": MessageLookupByLibrary.simpleMessage("Шлюз"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS по умолчанию",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешение DNS-серверов",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delayAnimation": MessageLookupByLibrary.simpleMessage("Анимация задержки"),
    "delayAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка анимации при тестировании",
    ),
    "delaySort": MessageLookupByLibrary.simpleMessage("По задержке"),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteMultipTip": m4,
    "deleteTip": m5,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage(
      "Удалить перенаправление",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettbox глубоко проработан на базе мощного и гибкого ядра Mihomo и ориентирован на лучший клиентский опыт. Наше видение: Connecting Open Source and AI, Accelerating Innovation",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Адрес назначения"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Геолокация назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "IP ASN назначения",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Подробности"),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Зависит от сторонних API, только для справки",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика включён.",
    ),
    "dialerIp4pConvert": MessageLookupByLibrary.simpleMessage(
      "Включить преобразование IP4P",
    ),
    "dialerIp4pConvertDesc": MessageLookupByLibrary.simpleMessage(
      "Преобразование IP4P в диалере",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Напрямую"),
    "directNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS для прямого подключения",
    ),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешение прямых доменов",
    ),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "Прямой DNS учитывает политики DNS",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("Отключить QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить QUIC для решения сетевых проблем",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Отключено"),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Отказ от ответственности",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Это бесплатное ПО с открытым исходным кодом, предназначенное только для обучения и личного тестирования. Действия прокси-провайдеров не связаны с этим ПО. Соглашаясь, вы подтверждаете, что полностью осведомлены об этом. Если не согласны, пожалуйста, выйдите!",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage("Доступно обновление"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("Настройки DNS"),
    "dnsHijack": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Перенаправить разбор в модуль DNS",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "dnsQuery": MessageLookupByLibrary.simpleMessage("DNS-запрос"),
    "dnsQueryCompare": MessageLookupByLibrary.simpleMessage("Сравнение"),
    "dnsQueryCompareDesc": MessageLookupByLibrary.simpleMessage(
      "Параллельно через правила, системный DNS и сервер — для выявления подмены и различий маршрутизации",
    ),
    "dnsQueryDesc": MessageLookupByLibrary.simpleMessage(
      "Через правила, систему или выбранный сервер",
    ),
    "dnsQueryFakeIpOff": m6,
    "dnsQueryFakeIpOn": m7,
    "dnsQueryFilterBlackHit": MessageLookupByLibrary.simpleMessage(
      "в чёрном списке",
    ),
    "dnsQueryFilterBlackMiss": MessageLookupByLibrary.simpleMessage(
      "нет в чёрном списке",
    ),
    "dnsQueryFilterRuleFake": MessageLookupByLibrary.simpleMessage(
      "правило: fake-ip",
    ),
    "dnsQueryFilterRuleReal": MessageLookupByLibrary.simpleMessage(
      "правило: real-ip",
    ),
    "dnsQueryFilterWhiteHit": MessageLookupByLibrary.simpleMessage(
      "в белом списке",
    ),
    "dnsQueryFilterWhiteMiss": MessageLookupByLibrary.simpleMessage(
      "нет в белом списке",
    ),
    "dnsQueryHint": MessageLookupByLibrary.simpleMessage("Домен"),
    "dnsQueryHostsHit": m8,
    "dnsQueryNoRecords": MessageLookupByLibrary.simpleMessage("Записей нет"),
    "dnsQueryNormalMode": MessageLookupByLibrary.simpleMessage(
      "Normal: реальный IP, правила по IP",
    ),
    "dnsQueryRedirHost": MessageLookupByLibrary.simpleMessage(
      "Redir-Host: реальный IP, домен восстанавливается при подключении",
    ),
    "dnsQueryServer": MessageLookupByLibrary.simpleMessage("DNS-сервер"),
    "dnsQueryServerHint": MessageLookupByLibrary.simpleMessage(
      "например 1.1.1.1, https://cloudflare-dns.com/dns-query",
    ),
    "dnsQueryServerInvalid": MessageLookupByLibrary.simpleMessage(
      "Неверный DNS-сервер",
    ),
    "dnsQueryStopped": MessageLookupByLibrary.simpleMessage(
      "Прокси не запущен, «По правилам» недоступно",
    ),
    "dnsQuerySystem": MessageLookupByLibrary.simpleMessage("Системный DNS"),
    "dnsQueryViaDirect": MessageLookupByLibrary.simpleMessage(
      "DIRECT, ядро разрешает локально и подключается напрямую",
    ),
    "dnsQueryViaDirectHosts": MessageLookupByLibrary.simpleMessage(
      "DIRECT, прямое подключение к адресу из Hosts",
    ),
    "dnsQueryViaProxy": m9,
    "dnsQueryViaProxyHosts": m10,
    "dnsQueryViaReject": MessageLookupByLibrary.simpleMessage(
      "Отклонено правилами",
    ),
    "dnsResolution": MessageLookupByLibrary.simpleMessage("Разрешение DNS"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "doubleBounce": MessageLookupByLibrary.simpleMessage("Двойной отскок"),
    "download": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "dozeSuspend": MessageLookupByLibrary.simpleMessage("Поддержка Doze"),
    "dozeSuspendDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация с режимом сна Android",
    ),
    "dualRing": MessageLookupByLibrary.simpleMessage("Двойное кольцо"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editTunnel": MessageLookupByLibrary.simpleMessage(
      "Изменить перенаправление",
    ),
    "editUser": MessageLookupByLibrary.simpleMessage(
      "Редактировать пользователя",
    ),
    "emptyTip": m11,
    "enableCrashReport": MessageLookupByLibrary.simpleMessage("Анализ сбоев"),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "Отправка отчётов о сбоях при необходимости",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение",
    ),
    "enableTraySpeed": MessageLookupByLibrary.simpleMessage("Скорость в трее"),
    "enableTraySpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать скорость в строке меню",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Включено"),
    "endpointIndependentNat": MessageLookupByLibrary.simpleMessage(
      "Улучшенный NAT",
    ),
    "endpointIndependentNatConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "Включение функции Endpoint-Independent NAT может незначительно снизить производительность. Рекомендуется включать её только в случае необходимости и если вы с ней знакомы.",
    ),
    "endpointIndependentNatDesc": MessageLookupByLibrary.simpleMessage(
      "Оптимизация работы UDP/P2P приложений",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних"),
    "excludeChina": MessageLookupByLibrary.simpleMessage("Исключить Китай"),
    "excludeChinaDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить QUIC для Китая",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрыть приложение из недавних задач",
    ),
    "existsTip": m12,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "expand": MessageLookupByLibrary.simpleMessage("Максимальная"),
    "experimental": MessageLookupByLibrary.simpleMessage("Экспериментальное"),
    "experimentalDesc": MessageLookupByLibrary.simpleMessage(
      "Экспериментальные настройки, используйте с осторожностью",
    ),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "expired": MessageLookupByLibrary.simpleMessage("Истекший"),
    "export": MessageLookupByLibrary.simpleMessage("Экспорт"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспорт успешен"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивный"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Внешнее управление",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Управление ядром через REST API",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "Внешние ресурсы",
    ),
    "fadingCircle": MessageLookupByLibrary.simpleMessage("Затухающий круг"),
    "fadingCube": MessageLookupByLibrary.simpleMessage("Затухающий куб"),
    "fadingFour": MessageLookupByLibrary.simpleMessage("Затухающие точки"),
    "fadingGrid": MessageLookupByLibrary.simpleMessage("Затухающая сетка"),
    "fakeIpFilterMode": MessageLookupByLibrary.simpleMessage(
      "Режим фильтрации FakeIP",
    ),
    "fakeIpFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Указать режим фильтрации FakeIP",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Фильтр FakeIP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Диапазон FakeIP"),
    "fakeipRangeV6": MessageLookupByLibrary.simpleMessage("Диапазон FakeIPv6"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Время жизни FakeIP"),
    "fallback": MessageLookupByLibrary.simpleMessage("Резервный DNS"),
    "fallbackConcurrent": MessageLookupByLibrary.simpleMessage(
      "Параллельный опрос резервного DNS",
    ),
    "fallbackConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Одновременный опрос основного и резервного DNS",
    ),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Обычно используются зарубежные DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage(
      "Фильтр резервного DNS",
    ),
    "fast": MessageLookupByLibrary.simpleMessage("Быстро"),
    "fcmOptimization": MessageLookupByLibrary.simpleMessage("Оптимизация FCM"),
    "fcmOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Повышает стабильность FCM при прямом подключении",
    ),
    "fcmTip": MessageLookupByLibrary.simpleMessage(
      "FCM зависит от устройства. Для точных результатов отключите \'Разрешить обход VPN\'",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Высокая точность"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Загрузить файл конфигурации",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл изменён. Сохранить изменения?",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Скрыть системные приложения",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage(
      "Определение процессов",
    ),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Включить определение процессов",
    ),
    "flagged": MessageLookupByLibrary.simpleMessage("Помечен"),
    "flushDnsOnNetworkChange": MessageLookupByLibrary.simpleMessage(
      "Очистка кэша DNS",
    ),
    "flushDnsOnNetworkChangeDesc": MessageLookupByLibrary.simpleMessage(
      "Очищать кэш DNS при смене сети",
    ),
    "foldingCube": MessageLookupByLibrary.simpleMessage("Складывающийся куб"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Принудительное DNS-отображение",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Принудительно отображать результаты DNS на соединение",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage(
      "Принудительный сниффинг доменов",
    ),
    "forceGCDesc": MessageLookupByLibrary.simpleMessage(
      "Выполнить сброс мусора ядра? Экспериментально, используйте с осторожностью",
    ),
    "forceGCTitle": MessageLookupByLibrary.simpleMessage("Очистка кеша ядра"),
    "formatError": MessageLookupByLibrary.simpleMessage("Проверьте формат"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("4 колонки"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Фруктовый микс"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "Изменить глобальные настройки",
    ),
    "generateFromPrivateKey": MessageLookupByLibrary.simpleMessage(
      "Создать из приватного ключа",
    ),
    "generateSecret": MessageLookupByLibrary.simpleMessage("Сгенерировать"),
    "geoBuiltInResources": MessageLookupByLibrary.simpleMessage(
      "Встроенные ресурсы GEO",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("Геоданные"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Экономия памяти GEO",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать загрузчик GEO с низким потреблением памяти",
    ),
    "geodataUse": MessageLookupByLibrary.simpleMessage("Загрузка GEO"),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Код GeoIP"),
    "getOriginRules": MessageLookupByLibrary.simpleMessage(
      "Получить исходные правила",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Глобально"),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Перейти к загрузке"),
    "harmonyFont": MessageLookupByLibrary.simpleMessage("Исправление шрифта"),
    "harmonyFontDesc": MessageLookupByLibrary.simpleMessage(
      "Встроенный шрифт для исправления отображения",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Кэшировать изменения?",
    ),
    "healthCheckTimeout": MessageLookupByLibrary.simpleMessage(
      "Таймаут проверки",
    ),
    "healthCheckTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Таймаут проверки работоспособности узлов",
    ),
    "heapObjects": MessageLookupByLibrary.simpleMessage("Objects"),
    "highPriority": MessageLookupByLibrary.simpleMessage("Высокий приоритет"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "Повысить приоритет приложения и ядра",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage(
      "Высокая частота обновления",
    ),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "Максимальная частота обновления экрана",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage(
      "Добавить hosts к текущей конфигурации",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage(
      "Конфликт горячих клавиш",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Управление горячими клавишами",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Управление приложением с клавиатуры",
    ),
    "hourGlass": MessageLookupByLibrary.simpleMessage("Песочные часы"),
    "hours": m13,
    "httpPortSniffer": MessageLookupByLibrary.simpleMessage(
      "HTTP порты сниффера",
    ),
    "icmpForwarding": MessageLookupByLibrary.simpleMessage("Пересылка ICMP"),
    "icmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "Включить поддержку ICMP Ping",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("Иконка"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройка иконки",
    ),
    "iconConfigurationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка значков ICON групп прокси",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль иконок"),
    "import": MessageLookupByLibrary.simpleMessage("Импорт"),
    "importFailed": MessageLookupByLibrary.simpleMessage("Ошибка импорта"),
    "importFile": MessageLookupByLibrary.simpleMessage("Импорт из файла"),
    "importFromCode": MessageLookupByLibrary.simpleMessage("Импорт из кода"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Импорт из URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Импорт по URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Бессрочно"),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Введите корректное сочетание клавиш",
    ),
    "installTime": MessageLookupByLibrary.simpleMessage("Время установки"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Умный выбор"),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Интервал"),
    "intranetAndGateway": MessageLookupByLibrary.simpleMessage("LAN и шлюз"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Локальный IP"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage(
      "Неверный формат IP или CIDR",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP-адрес"),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage(
      "Режим отображения",
    ),
    "ipLookup": MessageLookupByLibrary.simpleMessage("Поиск IP"),
    "ipLookupDesc": MessageLookupByLibrary.simpleMessage(
      "Ваши внешние IP и поиск любого IP или домена",
    ),
    "ipLookupDomesticExit": MessageLookupByLibrary.simpleMessage(
      "Внутренний локальный IP",
    ),
    "ipLookupHint": MessageLookupByLibrary.simpleMessage("IP или домен"),
    "ipLookupInvalid": MessageLookupByLibrary.simpleMessage(
      "Введите корректный IP или домен",
    ),
    "ipLookupLocal": MessageLookupByLibrary.simpleMessage("Локальная сеть"),
    "ipLookupMine": MessageLookupByLibrary.simpleMessage("Мой IP"),
    "ipLookupProxyExit": MessageLookupByLibrary.simpleMessage(
      "IP узла по умолчанию",
    ),
    "ipLookupResolveFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось разрешить домен",
    ),
    "ipLookupResult": MessageLookupByLibrary.simpleMessage("Результаты"),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage("Скрыть IP"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "iperfAddressHint": MessageLookupByLibrary.simpleMessage(
      "Адрес сервера, например 192.168.1.5",
    ),
    "iperfAddressRequired": MessageLookupByLibrary.simpleMessage(
      "Введите адрес сервера",
    ),
    "iperfAddresses": MessageLookupByLibrary.simpleMessage("Адреса устройства"),
    "iperfBandwidth": MessageLookupByLibrary.simpleMessage("Битрейт"),
    "iperfBidir": MessageLookupByLibrary.simpleMessage("Оба"),
    "iperfClient": MessageLookupByLibrary.simpleMessage("Клиент"),
    "iperfCommands": MessageLookupByLibrary.simpleMessage("Команды iperf3"),
    "iperfConnecting": MessageLookupByLibrary.simpleMessage("Подключение…"),
    "iperfDirection": MessageLookupByLibrary.simpleMessage("Направление"),
    "iperfDone": MessageLookupByLibrary.simpleMessage("Тест завершён"),
    "iperfDuration": MessageLookupByLibrary.simpleMessage("Длительность"),
    "iperfErrorBusy": MessageLookupByLibrary.simpleMessage(
      "Сервер занят другим тестом. Повторите позже",
    ),
    "iperfErrorInterrupted": MessageLookupByLibrary.simpleMessage(
      "Тест прерван",
    ),
    "iperfErrorListen": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить сервер",
    ),
    "iperfErrorPortInUse": m14,
    "iperfErrorProtocol": MessageLookupByLibrary.simpleMessage(
      "Неожиданный ответ. Возможно, это не сервер iPerf3",
    ),
    "iperfErrorRefused": MessageLookupByLibrary.simpleMessage(
      "Подключение отклонено. Убедитесь, что сервер iPerf3 запущен",
    ),
    "iperfErrorServer": m15,
    "iperfErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "Время подключения истекло. Проверьте адрес и сеть",
    ),
    "iperfErrorUdp": MessageLookupByLibrary.simpleMessage(
      "Ошибка UDP-рукопожатия. Возможно, его блокирует брандмауэр",
    ),
    "iperfErrorUnreachable": MessageLookupByLibrary.simpleMessage(
      "Не удаётся связаться с сервером",
    ),
    "iperfFirewallTip": MessageLookupByLibrary.simpleMessage(
      "Если другие устройства не могут подключиться, разрешите входящие подключения для ядра Bettbox в брандмауэре.",
    ),
    "iperfLostPackets": m16,
    "iperfNoAddress": MessageLookupByLibrary.simpleMessage(
      "Адрес в локальной сети не найден. Проверьте подключение к Wi-Fi или Ethernet",
    ),
    "iperfParallel": MessageLookupByLibrary.simpleMessage("Потоки"),
    "iperfPeer": MessageLookupByLibrary.simpleMessage("Узел"),
    "iperfPort": MessageLookupByLibrary.simpleMessage("Порт"),
    "iperfPortInvalid": MessageLookupByLibrary.simpleMessage(
      "Введите порт от 1 до 65535",
    ),
    "iperfProtocol": MessageLookupByLibrary.simpleMessage("Протокол"),
    "iperfReady": MessageLookupByLibrary.simpleMessage(
      "Введите адрес сервера или отсканируйте QR-код",
    ),
    "iperfReceive": MessageLookupByLibrary.simpleMessage("Приём"),
    "iperfResult": MessageLookupByLibrary.simpleMessage("Результат"),
    "iperfRetest": MessageLookupByLibrary.simpleMessage("Повторить"),
    "iperfRetransmits": MessageLookupByLibrary.simpleMessage("Повторы"),
    "iperfRtt": MessageLookupByLibrary.simpleMessage("Задержка RTT"),
    "iperfRunning": MessageLookupByLibrary.simpleMessage("Идёт тест"),
    "iperfScan": MessageLookupByLibrary.simpleMessage(
      "Сканировать для подключения",
    ),
    "iperfScanHint": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте в Bettbox на другом устройстве, чтобы подключиться одним касанием",
    ),
    "iperfScanInvalid": MessageLookupByLibrary.simpleMessage(
      "Это не QR-код подключения iPerf3",
    ),
    "iperfScanned": m17,
    "iperfSeconds": m18,
    "iperfSend": MessageLookupByLibrary.simpleMessage("Передача"),
    "iperfServer": MessageLookupByLibrary.simpleMessage("Сервер"),
    "iperfServerListening": m19,
    "iperfServerOff": MessageLookupByLibrary.simpleMessage("Сервер не запущен"),
    "iperfServerOffHint": MessageLookupByLibrary.simpleMessage(
      "После запуска другие устройства смогут подключиться по QR-коду или по адресу этого устройства",
    ),
    "iperfServerStart": MessageLookupByLibrary.simpleMessage(
      "Запустить сервер",
    ),
    "iperfServerStop": MessageLookupByLibrary.simpleMessage(
      "Остановить сервер",
    ),
    "iperfServerTip": MessageLookupByLibrary.simpleMessage(
      "Сервер работает, только пока открыта эта страница, и останавливается при выходе. Пока он работает, экран не гаснет.",
    ),
    "iperfStart": MessageLookupByLibrary.simpleMessage("Начать тест"),
    "iperfStreams": m20,
    "iperfTest": MessageLookupByLibrary.simpleMessage("Инструмент iPerf3"),
    "iperfTestDesc": MessageLookupByLibrary.simpleMessage(
      "Пропускная способность между устройствами в локальной сети, совместимо с iperf3",
    ),
    "iperfThroughput": MessageLookupByLibrary.simpleMessage("Скорость"),
    "iperfTransferred": MessageLookupByLibrary.simpleMessage("Объём"),
    "iperfUdpUnavailable": MessageLookupByLibrary.simpleMessage(
      "UDP-порт занят, доступны только тесты TCP.",
    ),
    "iperfWaiting": MessageLookupByLibrary.simpleMessage("Ожидание клиента"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("Включить поддержку IPv6"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящие IPv6",
    ),
    "isp": MessageLookupByLibrary.simpleMessage("Провайдер"),
    "itemsCount": m21,
    "just": MessageLookupByLibrary.simpleMessage("Только что"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал TCP keep-alive",
    ),
    "keepDockIcon": MessageLookupByLibrary.simpleMessage("Закрепить в Dock"),
    "keepDockIconDesc": MessageLookupByLibrary.simpleMessage(
      "Сохранять иконку приложения в Dock",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "lanSharing": MessageLookupByLibrary.simpleMessage("Общий доступ в LAN"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "lastEdit": MessageLookupByLibrary.simpleMessage(
      "Последнее редактирование",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Ширина"),
    "leftClickBehavior": MessageLookupByLibrary.simpleMessage("Действие ЛКМ"),
    "light": MessageLookupByLibrary.simpleMessage("Светлая"),
    "limitedUnlock": MessageLookupByLibrary.simpleMessage("Только оригиналы"),
    "lineWrap": MessageLookupByLibrary.simpleMessage("Перенос строк"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Прослушивание"),
    "local": MessageLookupByLibrary.simpleMessage("Локальное хранилище"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование данных в файл",
    ),
    "localFile": MessageLookupByLibrary.simpleMessage("Локальный файл"),
    "localPing": MessageLookupByLibrary.simpleMessage("Локальный Ping"),
    "localPingAverage": MessageLookupByLibrary.simpleMessage("Средняя"),
    "localPingBytes": m22,
    "localPingClosed": MessageLookupByLibrary.simpleMessage("Порт закрыт"),
    "localPingCount": MessageLookupByLibrary.simpleMessage("Количество"),
    "localPingDesc": MessageLookupByLibrary.simpleMessage(
      "Прямая проверка задержки и потерь ICMP, TCP и UDP",
    ),
    "localPingDone": MessageLookupByLibrary.simpleMessage("Ping завершён"),
    "localPingErrorDenied": MessageLookupByLibrary.simpleMessage(
      "Система запрещает ICMP. Используйте TCP или UDP Ping",
    ),
    "localPingErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Не удалось отправить пакеты Ping",
    ),
    "localPingErrorResolve": MessageLookupByLibrary.simpleMessage(
      "Не удалось разрешить домен",
    ),
    "localPingFailed": MessageLookupByLibrary.simpleMessage("Ошибка отправки"),
    "localPingFrom": m23,
    "localPingGateway": MessageLookupByLibrary.simpleMessage("Шлюз"),
    "localPingListLimit": m24,
    "localPingMax": MessageLookupByLibrary.simpleMessage("Макс."),
    "localPingMin": MessageLookupByLibrary.simpleMessage("Мин."),
    "localPingReady": MessageLookupByLibrary.simpleMessage(
      "Выберите цель для запуска",
    ),
    "localPingReceived": MessageLookupByLibrary.simpleMessage("Получено"),
    "localPingResolving": MessageLookupByLibrary.simpleMessage(
      "Разрешение имени",
    ),
    "localPingResult": MessageLookupByLibrary.simpleMessage("Результат Ping"),
    "localPingRttSummary": m25,
    "localPingRunning": MessageLookupByLibrary.simpleMessage("Пингование"),
    "localPingSent": MessageLookupByLibrary.simpleMessage("Отправлено"),
    "localPingSize": MessageLookupByLibrary.simpleMessage("Размер пакета"),
    "localPingStart": MessageLookupByLibrary.simpleMessage("Начать Ping"),
    "localPingStats": m26,
    "localPingSummary": m27,
    "localPingTargetHint": MessageLookupByLibrary.simpleMessage(
      "Домен или IP-адрес",
    ),
    "localPingTcpTip": MessageLookupByLibrary.simpleMessage(
      "TCP Ping измеряет время установки соединения. Отказ в соединении тоже означает, что узел доступен",
    ),
    "localPingTimeout": MessageLookupByLibrary.simpleMessage(
      "Превышено время ожидания",
    ),
    "localPingUdpTip": MessageLookupByLibrary.simpleMessage(
      "На порт 53 отправляется DNS-запрос с ожиданием ответа. Большинство других портов не отвечают, поэтому тайм-аут не означает недоступность",
    ),
    "localPingUnreachable": MessageLookupByLibrary.simpleMessage(
      "Узел недоступен",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление из файла",
    ),
    "locate": MessageLookupByLibrary.simpleMessage("Найти"),
    "log": MessageLookupByLibrary.simpleMessage("Лог"),
    "logAiSearch": MessageLookupByLibrary.simpleMessage("Поиск с ИИ"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logLevelDebugHint": m28,
    "logcat": MessageLookupByLibrary.simpleMessage("Сбор логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("Показать раздел логов"),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Просмотр логов"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест логов"),
    "loopback": MessageLookupByLibrary.simpleMessage("Разблокировка UWP"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Инструмент для разблокировки UWP loopback",
    ),
    "loopbackProtection": MessageLookupByLibrary.simpleMessage(
      "Защита от закольцовки",
    ),
    "loopbackProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "Блокировать петли трафика из-за ошибок",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Максимальная"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("Обновить IP"),
    "maximize": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "mediaBatchAll": MessageLookupByLibrary.simpleMessage("Все узлы"),
    "mediaBatchAllDesc": MessageLookupByLibrary.simpleMessage(
      "Все узлы, кроме DIRECT",
    ),
    "mediaBatchGroup": MessageLookupByLibrary.simpleMessage("Тест"),
    "mediaBatchNoNodes": MessageLookupByLibrary.simpleMessage(
      "Нет узлов для проверки",
    ),
    "mediaBatchScope": MessageLookupByLibrary.simpleMessage(
      "Выберите, что проверить",
    ),
    "mediaBatchSummary": m29,
    "mediaBatchTest": MessageLookupByLibrary.simpleMessage(
      "Пакетная проверка узлов",
    ),
    "mediaUnlock": MessageLookupByLibrary.simpleMessage("Проверка доступности"),
    "mediaUnlockColorfulIcons": MessageLookupByLibrary.simpleMessage(
      "Показывать цветные значки по умолчанию",
    ),
    "mediaUnlockDetails": MessageLookupByLibrary.simpleMessage(
      "Детали проверки доступности",
    ),
    "mediaUnlockDisplaySettings": MessageLookupByLibrary.simpleMessage(
      "Настройки отображения",
    ),
    "mediaUnlockExtraDetails": MessageLookupByLibrary.simpleMessage(
      "Показывать больше сведений об IP",
    ),
    "mediaUnlockMiscSettings": MessageLookupByLibrary.simpleMessage(
      "Прочие настройки",
    ),
    "mediaUnlockMoreStreamingPlatforms": MessageLookupByLibrary.simpleMessage(
      "Больше платформ стриминга",
    ),
    "mediaUnlockPinnedSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Закрепить до 3 элементов в виджете",
    ),
    "mediaUnlockRefreshByCategory": MessageLookupByLibrary.simpleMessage(
      "Частичное обновление по текущей категории",
    ),
    "mediaUnlockRefreshOnNodeChange": MessageLookupByLibrary.simpleMessage(
      "Автообновление при смене узла",
    ),
    "mediaUnlockSelectLimit": MessageLookupByLibrary.simpleMessage(
      "Можно выбрать максимум 3 элемента",
    ),
    "mediaUnlocked": MessageLookupByLibrary.simpleMessage("Разблокировано"),
    "memoryAndRuntime": MessageLookupByLibrary.simpleMessage(
      "Память и среда выполнения",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Память"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Текущее значение памяти — это динамическое потребление стека ядра во время выполнения, а не полная статистика памяти приложения, только для справки.",
    ),
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "Это тестовое сообщение.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Минимальная"),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Изменить поведение при выходе",
    ),
    "minutes": m30,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "months": m31,
    "more": MessageLookupByLibrary.simpleMessage("Подробности"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage(
      "Подробная информация об IP",
    ),
    "mrsCopyRawLink": MessageLookupByLibrary.simpleMessage(
      "Копировать как ссылку GitHub Raw",
    ),
    "mrsLookup": MessageLookupByLibrary.simpleMessage("Поиск MRS"),
    "mrsLookupDesc": MessageLookupByLibrary.simpleMessage(
      "Наборы GEODATA / RULE-SET для домена или IP",
    ),
    "mrsLookupHint": MessageLookupByLibrary.simpleMessage("Домен или IP"),
    "mrsMissing": MessageLookupByLibrary.simpleMessage(
      "Встроенный BundleMRS не найден",
    ),
    "mrsNoMatch": MessageLookupByLibrary.simpleMessage("Совпадений нет"),
    "mrsPrepareFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить наборы правил",
    ),
    "mrsReferenced": MessageLookupByLibrary.simpleMessage("Используется"),
    "mrsResolveDns": MessageLookupByLibrary.simpleMessage(
      "Разрешать домен по правилам DNS",
    ),
    "mrsResolveDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Если включено, домены разрешаются в IP по текущей настройке DNS, и эти IP тоже проверяются",
    ),
    "mrsRules": m32,
    "mrsVia": m33,
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameSort": MessageLookupByLibrary.simpleMessage("По имени"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Основной DNS"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешение доменов",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("Политика DNS"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Указать политику DNS для конкретных доменов",
    ),
    "natCopyResult": MessageLookupByLibrary.simpleMessage(
      "Копировать результат",
    ),
    "natDescBlocked": MessageLookupByLibrary.simpleMessage(
      "Ответ STUN не получен: UDP может блокироваться файрволом, провайдером или узлом.",
    ),
    "natDescCone": MessageLookupByLibrary.simpleMessage(
      "Большинство P2P-приложений и онлайн-игр будут работать нормально. Этот сервер не может точно определить тип среди NAT1–3 — для точного результата попробуйте другой сервер.",
    ),
    "natDescFullCone": MessageLookupByLibrary.simpleMessage(
      "NAT1: любой внешний узел может подключиться. Лучший вариант для P2P, игр и звонков.",
    ),
    "natDescOpen": MessageLookupByLibrary.simpleMessage(
      "NAT отсутствует, внешние узлы могут подключаться напрямую — идеально для P2P и игр.",
    ),
    "natDescPortRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT3: отвечать может только тот адрес и порт, к которому вы обращались. Для части P2P и игр нужен релей.",
    ),
    "natDescRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT2: отвечать могут только адреса, к которым вы обращались. Большинство P2P и игр работают.",
    ),
    "natDescSymmetric": MessageLookupByLibrary.simpleMessage(
      "NAT4: для каждого адреса выделяется свой порт. Прямой P2P почти невозможен, нужен релей.",
    ),
    "natDescUnknown": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить тип NAT.",
    ),
    "natErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться к STUN-серверу",
    ),
    "natErrorUnsupported": MessageLookupByLibrary.simpleMessage(
      "Выбранный выход не поддерживает UDP",
    ),
    "natExternalIp": MessageLookupByLibrary.simpleMessage("Внешний IP"),
    "natExternalPort": MessageLookupByLibrary.simpleMessage("Внешний порт"),
    "natFiltering": MessageLookupByLibrary.simpleMessage("Фильтрация"),
    "natLocalIp": MessageLookupByLibrary.simpleMessage("Локальный IP"),
    "natMapping": MessageLookupByLibrary.simpleMessage("Отображение"),
    "natMappingAddress": MessageLookupByLibrary.simpleMessage(
      "Зависит от адреса",
    ),
    "natMappingAddressPort": MessageLookupByLibrary.simpleMessage(
      "Зависит от адреса и порта",
    ),
    "natMappingDependent": MessageLookupByLibrary.simpleMessage(
      "Зависит от назначения",
    ),
    "natMappingIndependent": MessageLookupByLibrary.simpleMessage(
      "Не зависит от адреса",
    ),
    "natPhaseBinding": MessageLookupByLibrary.simpleMessage("Привязка"),
    "natPhaseFiltering": MessageLookupByLibrary.simpleMessage("Фильтрация"),
    "natPhaseMapping": MessageLookupByLibrary.simpleMessage("Отображение"),
    "natPortPreserve": MessageLookupByLibrary.simpleMessage("Сохранение порта"),
    "natPreserved": MessageLookupByLibrary.simpleMessage("Сохраняется"),
    "natProxyTip": MessageLookupByLibrary.simpleMessage(
      "Через прокси результат относится к NAT на стороне узла, а не вашей локальной сети.",
    ),
    "natRandomized": MessageLookupByLibrary.simpleMessage("Случайный"),
    "natReady": MessageLookupByLibrary.simpleMessage(
      "Нажмите кнопку ниже, чтобы начать",
    ),
    "natResult": MessageLookupByLibrary.simpleMessage("Результат"),
    "natRetest": MessageLookupByLibrary.simpleMessage("Проверить снова"),
    "natServer": MessageLookupByLibrary.simpleMessage("STUN-сервер"),
    "natServerCustom": MessageLookupByLibrary.simpleMessage("Свой сервер"),
    "natServerHint": MessageLookupByLibrary.simpleMessage(
      "хост:порт, например stun.example.com:3478",
    ),
    "natServerInvalid": MessageLookupByLibrary.simpleMessage(
      "Введите корректный хост:порт",
    ),
    "natStart": MessageLookupByLibrary.simpleMessage("Начать проверку"),
    "natTest": MessageLookupByLibrary.simpleMessage("Проверка NAT"),
    "natTestDesc": MessageLookupByLibrary.simpleMessage(
      "Тип NAT, внешний адрес и доступность UDP",
    ),
    "natType": MessageLookupByLibrary.simpleMessage("Тип NAT"),
    "natTypeBlocked": MessageLookupByLibrary.simpleMessage("UDP заблокирован"),
    "natTypeCone": MessageLookupByLibrary.simpleMessage("Cone NAT"),
    "natTypeFullCone": MessageLookupByLibrary.simpleMessage("Full Cone NAT"),
    "natTypeOpen": MessageLookupByLibrary.simpleMessage("Прямое подключение"),
    "natTypePortRestricted": MessageLookupByLibrary.simpleMessage(
      "Port Restricted Cone NAT",
    ),
    "natTypeRestricted": MessageLookupByLibrary.simpleMessage(
      "Restricted Cone NAT",
    ),
    "natTypeSymmetric": MessageLookupByLibrary.simpleMessage(
      "Симметричный NAT",
    ),
    "natTypeUnknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "Анимация и отклик",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Анимация и тактильная отдача нижней панели навигации",
    ),
    "navConnections": MessageLookupByLibrary.simpleMessage("Сессии"),
    "navTools": MessageLookupByLibrary.simpleMessage("Еще"),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("Настройки сети"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("IP сети"),
    "networkErrorRetryLater": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети, попробуйте позже",
    ),
    "networkFix": MessageLookupByLibrary.simpleMessage("Исправление сети"),
    "networkFixDesc": MessageLookupByLibrary.simpleMessage(
      "Исправляет значок сети в системе",
    ),
    "networkMatch": MessageLookupByLibrary.simpleMessage("Сопоставление сети"),
    "networkMatchHint": MessageLookupByLibrary.simpleMessage(
      "Введите IP или CIDR, максимум 2, через запятую",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkSpeedNotification": MessageLookupByLibrary.simpleMessage(
      "Скорость в уведомлениях",
    ),
    "networkSpeedNotificationDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать скорость и подписку в панели уведомлений",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральный"),
    "newLogsCount": m34,
    "noAnimation": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "noBackupFileFound": MessageLookupByLibrary.simpleMessage(
      "Файл резервной копии не найден",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Нет горячих клавиш"),
    "noIcon": MessageLookupByLibrary.simpleMessage("Без иконок"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noMatchedLogs": MessageLookupByLibrary.simpleMessage(
      "Нет подходящих логов",
    ),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Нет дополнительной информации",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложения без сети"),
    "noProxy": MessageLookupByLibrary.simpleMessage("Нет прокси"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Создайте или добавьте профиль",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("Без разрешения IP"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage(
      "Статус недоступен",
    ),
    "noUsageData": MessageLookupByLibrary.simpleMessage("Нет статистики"),
    "nodeExclusion": MessageLookupByLibrary.simpleMessage("Исключение узлов"),
    "nodeExclusionDesc": MessageLookupByLibrary.simpleMessage(
      "Исключить все узлы, соответствующие шаблону",
    ),
    "nodeExclusionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "HK|Гонконг|🇭🇰",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notRecommended": MessageLookupByLibrary.simpleMessage("Не рекомендуется"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Невозможно выбрать эту группу прокси",
    ),
    "notUnlocked": MessageLookupByLibrary.simpleMessage("Заблокировано"),
    "notificationHighPriority": MessageLookupByLibrary.simpleMessage(
      "Высокий приоритет",
    ),
    "notificationHighPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "Высокий приоритет уведомлений",
    ),
    "notificationHighPriorityTip": MessageLookupByLibrary.simpleMessage(
      "Уведомления с высоким приоритетом могут решить проблемы работы в фоне на некоторых кастомных прошивках. Если ваш VPN работает нормально, рекомендуется оставить выключенным. Включить?",
    ),
    "ntp": MessageLookupByLibrary.simpleMessage("NTP"),
    "ntpDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать службу времени NTP",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("Интервал обновления"),
    "ntpPort": MessageLookupByLibrary.simpleMessage("Порт NTP"),
    "ntpServer": MessageLookupByLibrary.simpleMessage("Сервер NTP"),
    "ntpStatus": MessageLookupByLibrary.simpleMessage("Статус NTP"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Включить службу времени NTP",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Нет профиля, добавьте его",
    ),
    "nullTip": m35,
    "numberRangeInvalid": m36,
    "numberTip": m37,
    "oneColumn": MessageLookupByLibrary.simpleMessage("1 колонка"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("Онлайн-панель"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только иконки"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage("Только сторонние"),
    "onlyShow": m38,
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Только прокси-трафик",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Считать только трафик через прокси",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("Открыть Zashboard"),
    "openRouterAdmin": MessageLookupByLibrary.simpleMessage("Открыть шлюз"),
    "openSettings": MessageLookupByLibrary.simpleMessage("Открыть настройки"),
    "operatorOrAsn": MessageLookupByLibrary.simpleMessage("Организация / ASN"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "organizationDomain": MessageLookupByLibrary.simpleMessage(
      "Организация / Домен",
    ),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники (в случайном порядке)",
    ),
    "otherSettings": MessageLookupByLibrary.simpleMessage(
      "Расширенные инструменты",
    ),
    "otherSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка расширенных функций",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Маршрутизация"),
    "override": MessageLookupByLibrary.simpleMessage("Переопределение"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "Переопределение конфигурации прокси",
    ),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Переопределить назначение",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать результаты сниффинга для переопределения целевого адреса",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Переопределить DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение настроек DNS в конфигурации",
    ),
    "overrideExperimental": MessageLookupByLibrary.simpleMessage(
      "Переопределить экспериментальное",
    ),
    "overrideExperimentalDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение экспериментальных настроек в конфигурации",
    ),
    "overrideNtp": MessageLookupByLibrary.simpleMessage("Переопределить NTP"),
    "overrideNtpDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение настроек NTP в конфигурации",
    ),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage(
      "Переопределить исходные правила",
    ),
    "overrideSniffer": MessageLookupByLibrary.simpleMessage(
      "Переопределить сниффер",
    ),
    "overrideSnifferDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение настроек сниффера в конфигурации",
    ),
    "overrideTestUrl": MessageLookupByLibrary.simpleMessage(
      "Переопределить конфигурацию",
    ),
    "overrideTunnel": MessageLookupByLibrary.simpleMessage(
      "Переопределить туннель",
    ),
    "overrideTunnelDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение настроек туннеля в конфигурации",
    ),
    "packageListPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Разрешение отклонено. Без доступа невозможно получить список приложений.",
    ),
    "packageListPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Эта функция требует доступа к списку установленных приложений. Предоставить разрешение?",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Палитра"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Сниффинг прямых IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Разбирать соединения по чистому IP",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "pianoWave": MessageLookupByLibrary.simpleMessage("Фортепианная волна"),
    "pin": MessageLookupByLibrary.simpleMessage("Закрепить"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Привяжите WebDAV",
    ),
    "pleaseCloseSystemProxyFirst": MessageLookupByLibrary.simpleMessage(
      "Сначала отключите системный прокси",
    ),
    "pleaseCloseTunFirst": MessageLookupByLibrary.simpleMessage(
      "Сначала отключите режим TUN",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Введите название скрипта",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Введите пароль администратора",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage("Загрузите файл"),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Загрузите корректный QR-код",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите разные порты",
    ),
    "portTip": m39,
    "pouringHourGlass": MessageLookupByLibrary.simpleMessage("Сыплющиеся часы"),
    "pouringHourGlassRefined": MessageLookupByLibrary.simpleMessage(
      "Точные песочные часы",
    ),
    "powerSwitch": MessageLookupByLibrary.simpleMessage("Запуск"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Приоритет HTTP/3 для DoH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Нажмите клавиши"),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "privateIp": MessageLookupByLibrary.simpleMessage(
      "Частный / локальный IP-адрес",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAndRules": MessageLookupByLibrary.simpleMessage(
      "Профиль и правила",
    ),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Введите корректный формат интервала",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите интервал автообновления"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Конфигурация изменена. Отключить автообновление?",
    ),
    "profileImportFailed": m40,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите имя профиля",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "Ошибка чтения профиля",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "progress": MessageLookupByLibrary.simpleMessage("Процесс"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providers": MessageLookupByLibrary.simpleMessage("Провайдеры"),
    "provinceAndCity": MessageLookupByLibrary.simpleMessage(
      "Провинция / Город",
    ),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Настройки прокси"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyGroupsCount": MessageLookupByLibrary.simpleMessage("Группы"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("DNS для прокси"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешение доменов прокси",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("Порт прокси"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Установить порт прослушивания Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "proxyProvidersCount": MessageLookupByLibrary.simpleMessage(
      "Наборы прокси",
    ),
    "pulse": MessageLookupByLibrary.simpleMessage("Пульсация"),
    "pulsingGrid": MessageLookupByLibrary.simpleMessage("Пульсирующая сетка"),
    "pumpingHeart": MessageLookupByLibrary.simpleMessage("Бьющееся сердце"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чистый чёрный"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканировать QR для импорта профиля",
    ),
    "quicGoDisableEcn": MessageLookupByLibrary.simpleMessage(
      "Отключить ECN QUIC",
    ),
    "quicGoDisableEcnDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить ECN для QUIC",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage(
      "Отключить GSO QUIC",
    ),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить GSO для QUIC",
    ),
    "quicPortSniffer": MessageLookupByLibrary.simpleMessage(
      "QUIC порты сниффера",
    ),
    "quickResponse": MessageLookupByLibrary.simpleMessage("Быстрый отклик"),
    "quickResponseDesc": MessageLookupByLibrary.simpleMessage(
      "Активно отключать соединения при изменении сети",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радуга"),
    "realTimeSpeed": MessageLookupByLibrary.simpleMessage("Текущая скорость"),
    "reclaimableMemory": MessageLookupByLibrary.simpleMessage("К возврату"),
    "recovery": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Все данные"),
    "recoveryDecryptedTip": MessageLookupByLibrary.simpleMessage(
      "Расшифровано и восстановлено с текущим паролем",
    ),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage("Только профили"),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "Режим восстановления",
    ),
    "recoveryStrategyDesc_compatible": MessageLookupByLibrary.simpleMessage(
      "Сохранить локальные и объединить по ID",
    ),
    "recoveryStrategyDesc_override": MessageLookupByLibrary.simpleMessage(
      "Удалить локальные и заменить копией",
    ),
    "recoveryStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Совместимость",
    ),
    "recoveryStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Перезаписать",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage(
      "Восстановление успешно",
    ),
    "redirPort": MessageLookupByLibrary.simpleMessage("Порт перенаправления"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "refreshAppList": MessageLookupByLibrary.simpleMessage(
      "Обновить список приложений",
    ),
    "refreshAppListConfirm": MessageLookupByLibrary.simpleMessage(
      "Обновить список приложений?",
    ),
    "regExp": MessageLookupByLibrary.simpleMessage("Регулярное выражение"),
    "relatedSettings": MessageLookupByLibrary.simpleMessage(
      "Связанные настройки",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Удалённый сервер"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование на WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Удалённое назначение",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление с WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "rename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "replace": MessageLookupByLibrary.simpleMessage("Заменить"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Заменить все"),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetIconCache": MessageLookupByLibrary.simpleMessage(
      "Сбросить кэш значков",
    ),
    "resetIconCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Сбросить локальный кэш значков? Это безопасно: приложение автоматически загрузит их заново по удалённым ссылкам.",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Сбросить настройки?"),
    "resources": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр внешних ресурсов и наборов правил",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Следовать правилам"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-запросы следуют правилам маршрутизации",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Перезапуск"),
    "restartApp": MessageLookupByLibrary.simpleMessage("Перезапустить"),
    "restartCoreDesc": MessageLookupByLibrary.simpleMessage(
      "Перезапустить ядро вручную?",
    ),
    "restartCoreTitle": MessageLookupByLibrary.simpleMessage("Перезапуск ядра"),
    "restartTip": MessageLookupByLibrary.simpleMessage(
      "Изменения вступят в силу после перезапуска TUN",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "rightClickBehavior": MessageLookupByLibrary.simpleMessage("Действие ПКМ"),
    "ring": MessageLookupByLibrary.simpleMessage("Кольцо"),
    "ripple": MessageLookupByLibrary.simpleMessage("Рябь"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("Вращающийся круг"),
    "rotatingPlain": MessageLookupByLibrary.simpleMessage(
      "Вращающаяся плоскость",
    ),
    "routeTrace": MessageLookupByLibrary.simpleMessage("Трассировка маршрута"),
    "routeTraceChain": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "routeTraceCheckedRules": MessageLookupByLibrary.simpleMessage(
      "Проверенные правила",
    ),
    "routeTraceDesc": MessageLookupByLibrary.simpleMessage(
      "DNS и сопоставление правил в ядре для домена или IP",
    ),
    "routeTraceDns": MessageLookupByLibrary.simpleMessage("Разрешение DNS"),
    "routeTraceDnsBy": m41,
    "routeTraceDnsIp": MessageLookupByLibrary.simpleMessage(
      "Цель — IP, разрешение не требуется",
    ),
    "routeTraceDnsSkipped": MessageLookupByLibrary.simpleMessage(
      "При сопоставлении разрешение IP не понадобилось",
    ),
    "routeTraceFinal": MessageLookupByLibrary.simpleMessage("Итоговый выход"),
    "routeTraceHint": MessageLookupByLibrary.simpleMessage("Домен, IP или URL"),
    "routeTraceHostsHit": m42,
    "routeTraceInput": MessageLookupByLibrary.simpleMessage("Цель"),
    "routeTraceModeDirect": MessageLookupByLibrary.simpleMessage(
      "Прямой режим: весь трафик напрямую",
    ),
    "routeTraceModeGlobal": MessageLookupByLibrary.simpleMessage(
      "Глобальный режим: весь трафик через GLOBAL",
    ),
    "routeTraceNoMatch": MessageLookupByLibrary.simpleMessage(
      "Нет совпадений, используется DIRECT",
    ),
    "routeTraceRules": MessageLookupByLibrary.simpleMessage(
      "Сопоставление правил",
    ),
    "routeTraceRulesSummary": m43,
    "routeTraceRulesTotal": m44,
    "routeTraceSkipMissing": MessageLookupByLibrary.simpleMessage(
      "Пропущено: цель не найдена",
    ),
    "routeTraceSkipPass": MessageLookupByLibrary.simpleMessage(
      "Пропущено (PASS)",
    ),
    "routeTraceSkipUdp": MessageLookupByLibrary.simpleMessage(
      "Пропущено: нет UDP",
    ),
    "routeTraceStopped": MessageLookupByLibrary.simpleMessage(
      "Прокси не запущен, трассировка недоступна",
    ),
    "routeTraceTrigger": MessageLookupByLibrary.simpleMessage(
      "Запущено разрешение",
    ),
    "routeTraceTruncated": MessageLookupByLibrary.simpleMessage(
      "Показаны только первые 3000",
    ),
    "routeTraceUdpUnsupported": MessageLookupByLibrary.simpleMessage(
      "Этот выход не поддерживает UDP",
    ),
    "routeTraceViewRules": MessageLookupByLibrary.simpleMessage(
      "Показать проверенные правила",
    ),
    "rule": MessageLookupByLibrary.simpleMessage("По правилам"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Имя правила"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Провайдеры правил"),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage("Наборы правил"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Цель правила"),
    "rulesCount": MessageLookupByLibrary.simpleMessage("Правила"),
    "runTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "runningMode": MessageLookupByLibrary.simpleMessage("Режим работы"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage(
      "Рантайм-конфигурация",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "saveTip": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт переопределения"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка скриптов переопределения на JavaScript",
    ),
    "scriptOtherOptions": MessageLookupByLibrary.simpleMessage(
      "Другие настройки",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "Пароль скопирован в буфер обмена",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать все"),
    "selectBackupVersion": MessageLookupByLibrary.simpleMessage(
      "Выберите версию резервной копии",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "selectedCountTitle": m45,
    "serviceReady": MessageLookupByLibrary.simpleMessage("Служба готова"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage("Служба запущена"),
    "setcapFailedFallback": MessageLookupByLibrary.simpleMessage(
      "Не удалось выдать file capabilities, выполнен откат на setuid",
    ),
    "setcapNotInstalledFallback": MessageLookupByLibrary.simpleMessage(
      "setcap не установлен, выполнен откат на setuid",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "sharedAddress": MessageLookupByLibrary.simpleMessage("Общий адрес"),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showHiddenItems": MessageLookupByLibrary.simpleMessage("Показать скрытые"),
    "showMenu": MessageLookupByLibrary.simpleMessage("Открыть меню"),
    "showPanel": MessageLookupByLibrary.simpleMessage("Показать окно"),
    "showStartSwitch": MessageLookupByLibrary.simpleMessage(
      "Тумблер запуска на главной",
    ),
    "showStartSwitchDesc": MessageLookupByLibrary.simpleMessage(
      "Отдельная кнопка на главной",
    ),
    "shrink": MessageLookupByLibrary.simpleMessage("Стандарт"),
    "sidebarFlyout": MessageLookupByLibrary.simpleMessage("Всплывающая панель"),
    "sidebarFlyoutDelay": MessageLookupByLibrary.simpleMessage(
      "Задержка появления",
    ),
    "sidebarFlyoutDesc": MessageLookupByLibrary.simpleMessage(
      "Карточка настроек при наведении на панель",
    ),
    "sidebarFlyoutEntries": MessageLookupByLibrary.simpleMessage(
      "Пункты панели",
    ),
    "sidebarFlyoutOutsideTools": MessageLookupByLibrary.simpleMessage(
      "Показывать только вне страницы «Инструменты»",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Тихий запуск"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запуск в фоне без открытия окна",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Высота"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Пропустить домены"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Пропустить IP назначения",
    ),
    "skipLocalAuth": MessageLookupByLibrary.simpleMessage(
      "Пропустить локальную аутентификацию",
    ),
    "skipLocalAuthDesc": MessageLookupByLibrary.simpleMessage(
      "Доступ без пароля для локального устройства",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Пропустить IP источника",
    ),
    "slow": MessageLookupByLibrary.simpleMessage("Медленно"),
    "smartAutoStop": MessageLookupByLibrary.simpleMessage("Умная остановка"),
    "smartAutoStopDesc": MessageLookupByLibrary.simpleMessage(
      "Останавливать прокси при подключении к заданной сети",
    ),
    "smartAutoStopServiceRunning": MessageLookupByLibrary.simpleMessage(
      "Служба умной остановки работает",
    ),
    "smartDelayLaunch": MessageLookupByLibrary.simpleMessage("Умная задержка"),
    "smartDelayLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запуск после успешного подключения к сети",
    ),
    "sniffer": MessageLookupByLibrary.simpleMessage("Сниффер"),
    "snifferAddressHint": MessageLookupByLibrary.simpleMessage(
      "Один адрес на строку",
    ),
    "snifferDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка сниффинга доменов",
    ),
    "snifferDomainHint": MessageLookupByLibrary.simpleMessage(
      "Один домен на строку",
    ),
    "snifferPorts": MessageLookupByLibrary.simpleMessage("Порты"),
    "snifferPortsHint": MessageLookupByLibrary.simpleMessage(
      "Например: 80, 8080-8880",
    ),
    "snifferStatus": MessageLookupByLibrary.simpleMessage("Статус сниффера"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "Включить службу сниффинга",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Порт Socks"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP источника"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Специальный прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Специальные правила"),
    "speedTest": MessageLookupByLibrary.simpleMessage("Тест скорости"),
    "speedTestAgain": MessageLookupByLibrary.simpleMessage("Повторить"),
    "speedTestChangeOutbound": MessageLookupByLibrary.simpleMessage(
      "Сменить выход",
    ),
    "speedTestClearHistoryTip": MessageLookupByLibrary.simpleMessage(
      "Очистить всю историю тестов?",
    ),
    "speedTestConnecting": MessageLookupByLibrary.simpleMessage("Подключение"),
    "speedTestConnections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "speedTestConnectionsDesc": m46,
    "speedTestCoreStopped": MessageLookupByLibrary.simpleMessage(
      "Не запущен · Прямой тест",
    ),
    "speedTestCredit": MessageLookupByLibrary.simpleMessage(
      "Серверы для теста скорости предоставлены публичными сторонними сервисами. Особая благодарность Apple, Cloudflare и Speedtest by Ookla.",
    ),
    "speedTestDataUsed": MessageLookupByLibrary.simpleMessage("Трафик"),
    "speedTestDuration": MessageLookupByLibrary.simpleMessage("Длительность"),
    "speedTestErrorBlocked": MessageLookupByLibrary.simpleMessage(
      "Тест скорости недоступен",
    ),
    "speedTestErrorBlockedDesc": m47,
    "speedTestErrorNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Проверьте доступность выхода и повторите.",
    ),
    "speedTestErrorRejected": MessageLookupByLibrary.simpleMessage(
      "Заблокировано правилами",
    ),
    "speedTestErrorRejectedDesc": MessageLookupByLibrary.simpleMessage(
      "Текущие правила направляют домен теста в REJECT. Выберите другой выход и повторите.",
    ),
    "speedTestErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "Время ожидания истекло",
    ),
    "speedTestErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удаётся подключиться к сервису",
    ),
    "speedTestExitNode": MessageLookupByLibrary.simpleMessage("Выходной узел"),
    "speedTestFollowRules": MessageLookupByLibrary.simpleMessage("По правилам"),
    "speedTestHistory": MessageLookupByLibrary.simpleMessage("История тестов"),
    "speedTestHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "История пуста",
    ),
    "speedTestHistoryRetention": MessageLookupByLibrary.simpleMessage(
      "Хранится 14 дней",
    ),
    "speedTestJitter": MessageLookupByLibrary.simpleMessage("Джиттер"),
    "speedTestLoadedLatency": MessageLookupByLibrary.simpleMessage(
      "Задержка под нагрузкой",
    ),
    "speedTestManual": MessageLookupByLibrary.simpleMessage("Вручную"),
    "speedTestMobileDataTip": MessageLookupByLibrary.simpleMessage(
      "Используются мобильные данные. Один тест может потратить сотни МБ. Продолжить?",
    ),
    "speedTestMultiThread": MessageLookupByLibrary.simpleMessage("Несколько"),
    "speedTestOutbound": MessageLookupByLibrary.simpleMessage("Выход"),
    "speedTestPacketLoss": MessageLookupByLibrary.simpleMessage("Потери"),
    "speedTestProbing": MessageLookupByLibrary.simpleMessage(
      "Определение выхода…",
    ),
    "speedTestProtocol": MessageLookupByLibrary.simpleMessage("Протокол"),
    "speedTestProtocolDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP/3 работает поверх QUIC (UDP); если он недоступен — откат на HTTP/2, а если недоступен и HTTP/2 — на HTTP/1.1",
    ),
    "speedTestProtocolFallback": m48,
    "speedTestQuality": MessageLookupByLibrary.simpleMessage("Качество сети"),
    "speedTestReady": MessageLookupByLibrary.simpleMessage("Готово"),
    "speedTestRealtime": MessageLookupByLibrary.simpleMessage(
      "Скорость в реальном времени",
    ),
    "speedTestResponsiveness": MessageLookupByLibrary.simpleMessage(
      "Отзывчивость",
    ),
    "speedTestRoute": MessageLookupByLibrary.simpleMessage("Правило"),
    "speedTestServer": MessageLookupByLibrary.simpleMessage("Сервер теста"),
    "speedTestServerAutoDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически выбирать сервер Speedtest",
    ),
    "speedTestSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки теста",
    ),
    "speedTestSingleThread": MessageLookupByLibrary.simpleMessage("Одно"),
    "speedTestStart": MessageLookupByLibrary.simpleMessage("Начать тест"),
    "speedTestStreams": m49,
    "speedTestSwitchProvider": m50,
    "speedTestUseSystemDns": MessageLookupByLibrary.simpleMessage(
      "Разрешать через системный DNS",
    ),
    "speedTestUseSystemDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Если включено, выбранный сервер теста всегда разрешается через системный DNS — иногда это помогает",
    ),
    "spinningCircle": MessageLookupByLibrary.simpleMessage("Вращающийся диск"),
    "spinningLines": MessageLookupByLibrary.simpleMessage("Вращающиеся линии"),
    "squareCircle": MessageLookupByLibrary.simpleMessage("Квадратный круг"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандарт"),
    "start": MessageLookupByLibrary.simpleMessage("Запуск"),
    "startSwitchOffLabel": MessageLookupByLibrary.simpleMessage(
      "Текст при выключении",
    ),
    "startSwitchOnLabel": MessageLookupByLibrary.simpleMessage(
      "Текст при включении",
    ),
    "startSwitchOutlined": MessageLookupByLibrary.simpleMessage("С контуром"),
    "startSwitchPersonalized": MessageLookupByLibrary.simpleMessage(
      "Персонализация",
    ),
    "startSwitchStyle": MessageLookupByLibrary.simpleMessage("Стиль"),
    "startSwitchTonal": MessageLookupByLibrary.simpleMessage("Тональный"),
    "startTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN"),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать системный DNS при выключении",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Остановка"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN"),
    "storeFix": MessageLookupByLibrary.simpleMessage("Исправление Google Play"),
    "storeFixDesc": MessageLookupByLibrary.simpleMessage(
      "Исправляет проблемы загрузки Google Play",
    ),
    "strictRoute": MessageLookupByLibrary.simpleMessage(
      "Строгая маршрутизация",
    ),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать строгий режим маршрутизации TUN",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subRule": MessageLookupByLibrary.simpleMessage("Подправило"),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "success": MessageLookupByLibrary.simpleMessage("Успех"),
    "switchLabel": MessageLookupByLibrary.simpleMessage("Переключатель"),
    "switchToDomesticIp": MessageLookupByLibrary.simpleMessage(
      "Получить локальный IP",
    ),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизировать"),
    "syncAll": MessageLookupByLibrary.simpleMessage("Синхронизировать всё"),
    "syncDelayAnimation": MessageLookupByLibrary.simpleMessage(
      "Синхронизировать анимацию с другими страницами",
    ),
    "syncFailed": MessageLookupByLibrary.simpleMessage("Ошибка синхронизации"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системные приложения"),
    "systemDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "systemFont": MessageLookupByLibrary.simpleMessage("Системный шрифт"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Настроить системный прокси",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладки"),
    "tailscale": MessageLookupByLibrary.simpleMessage("Tailscale"),
    "tailscaleAcceptRoutes": MessageLookupByLibrary.simpleMessage(
      "Принимать маршруты подсетей",
    ),
    "tailscaleAcceptRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать маршруты подсетей, объявленные в tailnet",
    ),
    "tailscaleAddNetwork": MessageLookupByLibrary.simpleMessage(
      "Добавить сеть",
    ),
    "tailscaleAuthKey": MessageLookupByLibrary.simpleMessage(
      "Ключ авторизации",
    ),
    "tailscaleAuthKeyDesc": MessageLookupByLibrary.simpleMessage(
      "Необязательно; без ключа используйте «Войти» (SSO/OIDC)",
    ),
    "tailscaleConnected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "tailscaleControlUrl": MessageLookupByLibrary.simpleMessage(
      "Сервер управления",
    ),
    "tailscaleControlUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Пусто — Tailscale. Для Headscale укажите URL",
    ),
    "tailscaleDeleteNetwork": MessageLookupByLibrary.simpleMessage(
      "Удалить сеть",
    ),
    "tailscaleDesc": MessageLookupByLibrary.simpleMessage(
      "Направлять выбранные домены и IP через tailnet",
    ),
    "tailscaleDevices": MessageLookupByLibrary.simpleMessage("Устройства"),
    "tailscaleDns": MessageLookupByLibrary.simpleMessage("DNS tailnet"),
    "tailscaleDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Домены, которые разрешает DNS-сервер внутри tailnet: домен=сервер (например, corp.example.com=10.1.0.53). Добавьте их подсети в список маршрутизации",
    ),
    "tailscaleEnable": MessageLookupByLibrary.simpleMessage(
      "Включить Tailscale",
    ),
    "tailscaleEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Подключаться к tailnet через встроенный узел Tailscale",
    ),
    "tailscaleExitNode": MessageLookupByLibrary.simpleMessage("Выходной узел"),
    "tailscaleExitNodeDesc": MessageLookupByLibrary.simpleMessage(
      "Имя или IP устройства в tailnet либо auto:any. Нужен для публичных сайтов",
    ),
    "tailscaleExitNodeLan": MessageLookupByLibrary.simpleMessage(
      "Доступ к локальной сети",
    ),
    "tailscaleExitNodeLanDesc": MessageLookupByLibrary.simpleMessage(
      "Оставлять локальную сеть доступной при выходном узле",
    ),
    "tailscaleHostname": MessageLookupByLibrary.simpleMessage("Имя устройства"),
    "tailscaleInvalidDns": MessageLookupByLibrary.simpleMessage(
      "Формат домен=сервер, где сервер — IP или URL tls:// / https://, например corp.example.com=10.1.0.53",
    ),
    "tailscaleInvalidEntry": MessageLookupByLibrary.simpleMessage(
      "Введите домен, IP или CIDR",
    ),
    "tailscaleLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Вход в Tailscale выполнен",
    ),
    "tailscaleLogin": MessageLookupByLibrary.simpleMessage("Войти"),
    "tailscaleLoginDesc": MessageLookupByLibrary.simpleMessage(
      "Вход в браузере через SSO/OIDC вашей tailnet, без ключа авторизации",
    ),
    "tailscaleLoginNeeded": MessageLookupByLibrary.simpleMessage(
      "Требуется вход в Tailscale",
    ),
    "tailscaleNeedsApproval": MessageLookupByLibrary.simpleMessage(
      "Ожидание одобрения устройства администратором",
    ),
    "tailscaleNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
    "tailscaleNetworks": MessageLookupByLibrary.simpleMessage("Сети"),
    "tailscaleNotStarted": MessageLookupByLibrary.simpleMessage("Не запущено"),
    "tailscaleNotStartedDesc": MessageLookupByLibrary.simpleMessage(
      "Запускается при первом использовании; нажмите, чтобы запустить",
    ),
    "tailscaleNotes": MessageLookupByLibrary.simpleMessage(
      "• Встроенный узел: Bettbox сам подключается к tailnet, приложение Tailscale не нужно. Через него идёт только трафик из списка маршрутизации и Tailnet DNS.\n• Только в режиме правил: глобальный и прямой режимы пропускают эти правила.\n• Используйте полные имена вроде host.tailnet.ts.net; короткие имена вроде nas не разрешаются.\n• Подсети: добавьте их в список маршрутизации и включите приём маршрутов подсетей. На ПК без TUN частные подсети (10.x, 172.16–31.x, 192.168.x) обходят системный прокси.\n• Для публичных сайтов через tailnet нужен выходной узел.\n• Для IPv6-адресов tailnet нужно включить IPv6.\n• Узел запускается при первом использовании. Ссылка для входа показывается, только пока Bettbox открыт.\n• Android: изменения списка маршрутизации применяются после перезапуска VPN.",
    ),
    "tailscaleNotesTitle": MessageLookupByLibrary.simpleMessage("Пояснения"),
    "tailscaleOnlineCount": m51,
    "tailscaleRelay": m52,
    "tailscaleReset": MessageLookupByLibrary.simpleMessage("Сбросить узел"),
    "tailscaleResetDesc": MessageLookupByLibrary.simpleMessage(
      "Удалить данные tailnet этого устройства и подключиться как новое; старое удалите в консоли администратора",
    ),
    "tailscaleRoutes": MessageLookupByLibrary.simpleMessage(
      "Список маршрутизации",
    ),
    "tailscaleRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Домены и IP/CIDR, идущие через Tailscale в режиме правил. Частным подсетям на ПК нужен TUN",
    ),
    "tailscaleStarting": MessageLookupByLibrary.simpleMessage(
      "Запуск Tailscale…",
    ),
    "tailscaleSubnetRoutes": MessageLookupByLibrary.simpleMessage(
      "Маршруты подсетей",
    ),
    "tailscaleThisDevice": MessageLookupByLibrary.simpleMessage(
      "Это устройство",
    ),
    "tailscaleUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "tailscaleUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Передавать UDP-трафик через Tailscale",
    ),
    "tailscaleWarnings": MessageLookupByLibrary.simpleMessage("Предупреждения"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage(
      "Параллельные TCP-соединения",
    ),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить параллельные TCP-соединения",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL теста"),
    "testing": MessageLookupByLibrary.simpleMessage("Проверка"),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка темы и цветов",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "threeBounce": MessageLookupByLibrary.simpleMessage("Прыгающие точки"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("3 колонки"),
    "threeInOut": MessageLookupByLibrary.simpleMessage("Три точки"),
    "tight": MessageLookupByLibrary.simpleMessage("Минимальная"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "titleTooLong": MessageLookupByLibrary.simpleMessage(
      "Слишком длинный, максимум 20 символов",
    ),
    "tlsPortSniffer": MessageLookupByLibrary.simpleMessage(
      "TLS порты сниффера",
    ),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тональный акцент"),
    "tooManyRules": MessageLookupByLibrary.simpleMessage("Максимум 5 правил"),
    "toolConnectivityDesc": MessageLookupByLibrary.simpleMessage(
      "Доступность сервисов и пакетная проверка узлов",
    ),
    "toolHistoryClear": MessageLookupByLibrary.simpleMessage(
      "Очистить историю",
    ),
    "toolSpeedTestDesc": MessageLookupByLibrary.simpleMessage(
      "Скорость загрузки, отдачи и задержка",
    ),
    "toolbox": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "toolboxDesc": MessageLookupByLibrary.simpleMessage(
      "Диагностика и отладка сети, утилиты",
    ),
    "toolboxEditTip": MessageLookupByLibrary.simpleMessage(
      "Нажмите на карточку, чтобы изменить размер; удерживайте и перетащите, чтобы переместить",
    ),
    "toolboxEditTipDesktop": MessageLookupByLibrary.simpleMessage(
      "Нажмите на карточку, чтобы изменить размер; перетащите, чтобы переместить",
    ),
    "toolboxEditTipTv": MessageLookupByLibrary.simpleMessage(
      "Выберите карточку и нажмите OK, чтобы изменить размер",
    ),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Общий трафик"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт Tproxy"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trayClickBehavior": MessageLookupByLibrary.simpleMessage(
      "Действие при нажатии на значок",
    ),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("Улучшение трея"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "Управление группами прокси в трее",
    ),
    "trayIconInvert": MessageLookupByLibrary.simpleMessage(
      "Инвертировать значок трея",
    ),
    "trayIconInvertDesc": MessageLookupByLibrary.simpleMessage(
      "Инвертировать цвет текущего значка в трее",
    ),
    "tryManualRefresh": MessageLookupByLibrary.simpleMessage(
      "Обновите вручную",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("Режим TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать TUN для перехвата трафика устройства",
    ),
    "tunEnableRequireAdmin": MessageLookupByLibrary.simpleMessage(
      "Для включения режима TUN требуются права администратора или ROOT.",
    ),
    "tunVirtualAddress": MessageLookupByLibrary.simpleMessage(
      "Адрес виртуального сетевого адаптера TUN",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("Туннель"),
    "tunnelAddress": MessageLookupByLibrary.simpleMessage(
      "Адрес прослушивания",
    ),
    "tunnelAddressHint": MessageLookupByLibrary.simpleMessage(
      "Например: 127.0.0.1:6553",
    ),
    "tunnelDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать туннель перенаправления трафика",
    ),
    "tunnelList": MessageLookupByLibrary.simpleMessage(
      "Список перенаправлений",
    ),
    "tunnelNetwork": MessageLookupByLibrary.simpleMessage("Сетевой протокол"),
    "tunnelNetworkHint": MessageLookupByLibrary.simpleMessage(
      "Например: tcp, udp",
    ),
    "tunnelProxy": MessageLookupByLibrary.simpleMessage("Имя прокси"),
    "tunnelProxyHint": MessageLookupByLibrary.simpleMessage(
      "Например: proxy (опционально)",
    ),
    "tunnelTarget": MessageLookupByLibrary.simpleMessage("Целевой адрес"),
    "tunnelTargetHint": MessageLookupByLibrary.simpleMessage(
      "Например: 114.114.114.114:53",
    ),
    "tvScanImport": MessageLookupByLibrary.simpleMessage(
      "Сканирование / Импорт по LAN",
    ),
    "tvScanImportDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR или отправьте профиль на ТВ через LAN",
    ),
    "tvScanManualUrl": MessageLookupByLibrary.simpleMessage(
      "Или введите адрес в браузере телефона:",
    ),
    "tvScanNoNetwork": MessageLookupByLibrary.simpleMessage(
      "Доступная локальная сеть не найдена, проверьте Wi-Fi",
    ),
    "tvScanStep1": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что телефон и TV подключены к одной сети Wi-Fi",
    ),
    "tvScanStep2": MessageLookupByLibrary.simpleMessage(
      "Отсканируйте QR-код поддерживаемой камерой или браузером",
    ),
    "tvScanStep3": MessageLookupByLibrary.simpleMessage(
      "Вставьте URL подписки или загрузите конфигурацию на веб-странице и отправьте",
    ),
    "tvScanSuccess": MessageLookupByLibrary.simpleMessage(
      "Профиль получен, выполняется импорт...",
    ),
    "tvScanWaiting": MessageLookupByLibrary.simpleMessage(
      "Ожидание отправки профиля с телефона...",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("2 колонки"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Невозможно обновить текущий профиль",
    ),
    "unauthorized": MessageLookupByLibrary.simpleMessage("Не авторизован"),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage(
      "Унифицированная задержка",
    ),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Убрать задержку рукопожатия и разбора",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unlocked": MessageLookupByLibrary.simpleMessage("Завершено"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без имени"),
    "unpin": MessageLookupByLibrary.simpleMessage("Открепить"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "updateTime": MessageLookupByLibrary.simpleMessage("Время обновления"),
    "upload": MessageLookupByLibrary.simpleMessage("Отправка"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("Получить профиль по URL"),
    "urlTip": m53,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "Глобальное переопределение",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системные hosts",
    ),
    "userAuth": MessageLookupByLibrary.simpleMessage(
      "Аутентификация пользователей",
    ),
    "userAuthEmpty": MessageLookupByLibrary.simpleMessage(
      "Пользователи аутентификации не настроены, подключение по LAN не требует учетных данных",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Имя пользователя"),
    "usernameCannotContainColon": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя не может содержать двоеточие",
    ),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркий"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "viewDetailedIpData": MessageLookupByLibrary.simpleMessage(
      "Посмотреть подробные данные IP",
    ),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("Настройки VPN"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Маршрутизация через VpnService",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Добавить HTTP-прокси к VPN",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Перезапустите VPN для применения изменений",
    ),
    "wakelock": MessageLookupByLibrary.simpleMessage("Блокировка сна"),
    "wakelockDescription": MessageLookupByLibrary.simpleMessage(
      "Эта функция не требует специальных разрешений, так как использует только блокировку пробуждения экрана, а не CPU. Приложение остаётся активным в фоне, экран не гаснет автоматически, что полезно в некоторых сценариях.",
    ),
    "wanderingCubes": MessageLookupByLibrary.simpleMessage("Блуждающие кубы"),
    "wave": MessageLookupByLibrary.simpleMessage("Волна"),
    "waveSpinner": MessageLookupByLibrary.simpleMessage("Волновой спиннер"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройки WebDAV",
    ),
    "whitelist": MessageLookupByLibrary.simpleMessage("Белый список"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Записать в систему"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Требуются права администратора",
    ),
    "xattrUnsupportedFallback": MessageLookupByLibrary.simpleMessage(
      "Файловая система не поддерживает file capabilities (xattr), выполнен откат на setuid",
    ),
    "years": m54,
  };
}
