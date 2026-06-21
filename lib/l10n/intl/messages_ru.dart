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

  static String m0(label) => "Удалить выбранные ${label}?";

  static String m1(label) => "Удалить текущий ${label}?";

  static String m2(label) => "Подробности ${label}";

  static String m3(label) => "${label} не может быть пустым";

  static String m4(label) => "${label} уже существует";

  static String m5(label) => "${label} отсутствует";

  static String m6(label) => "${label} должен быть числом";

  static String m7(label) =>
      "${label} должен быть от 1024 до 49151, 0 для отключения";

  static String m8(statusCode) =>
      "Не удалось импортировать профиль. Проверьте подключение к сети и попробуйте сбросить ссылку подписки (код ошибки HTTP: ${statusCode})";

  static String m9(count) => "Выбрано: ${count}";

  static String m10(label) => "${label} должен быть URL";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Только выбранные приложения используют VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка доступа приложений к прокси",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения исключены из VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "action_start": MessageLookupByLibrary.simpleMessage("Запуск/Остановка"),
    "action_tun": MessageLookupByLibrary.simpleMessage("Виртуальный адаптер"),
    "action_view": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addTunnel": MessageLookupByLibrary.simpleMessage(
      "Добавить перенаправление",
    ),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage(
      "Добавить к исходным",
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
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "Генерация ключа Age",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "Пара ключей X25519 создана, сохраните её в надёжном месте",
    ),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage(
      "Закрытый ключ Age",
    ),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, сначала введите корректный закрытый ключ Age",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage(
      "Открытый ключ Age",
    ),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите корректный приватный ключ Age (должен начинаться с AGE-SECRET-KEY-)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage(
      "Приватный ключ Age (необязательно)",
    ),
    "ago": MessageLookupByLibrary.simpleMessage(" назад"),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allApps": MessageLookupByLibrary.simpleMessage("Все приложения"),
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
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage("Настройки приложения"),
    "application": MessageLookupByLibrary.simpleMessage("Приложение"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки приложения",
    ),
    "authorized": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
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
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Автоматически настроить системный DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (минуты)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Создать копию"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файл",
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
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключить домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только при включённом системном прокси",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Обход частной сети",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически обходить IP-адреса частной сети",
    ),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Алгоритм кэша"),
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
    "checkError": MessageLookupByLibrary.simpleMessage("Ошибка проверки"),
    "checkOrAddProfile": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Установлена последняя версия",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Проверка..."),
    "circle": MessageLookupByLibrary.simpleMessage("Круг"),
    "clearCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Очистить кэш FakeIP и DNS?",
    ),
    "clearCacheTitle": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clipboard": MessageLookupByLibrary.simpleMessage("Буфер обмена"),
    "clipboardDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически получать ссылки из буфера обмена",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Экспорт в буфер"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Импорт из буфера"),
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
    "connection": MessageLookupByLibrary.simpleMessage("Активные соединения"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр текущих соединений",
    ),
    "connectionsSort": MessageLookupByLibrary.simpleMessage(
      "Сортировка соединений",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Подключение:"),
    "contactMe": MessageLookupByLibrary.simpleMessage("Связаться со мной"),
    "content": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Контентная тема"),
    "controlSecret": MessageLookupByLibrary.simpleMessage("Пароль управления"),
    "controlSecretDesc": MessageLookupByLibrary.simpleMessage(
      "Пароль для доступа к RESTful API",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreConnected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Информация о ядре"),
    "coreSuspended": MessageLookupByLibrary.simpleMessage("Приостановлено"),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "custom": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "Пользовательский заголовок",
    ),
    "customUrl": MessageLookupByLibrary.simpleMessage("Пользовательский URL"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Главная"),
    "days": MessageLookupByLibrary.simpleMessage("дней"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS по умолчанию",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения DNS-серверов",
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
    "deleteMultipTip": m0,
    "deleteTip": m1,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage(
      "Удалить перенаправление",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettbox основан на мощном и гибком прокси-ядре Mihomo (Clash.Meta) и стремится к созданию лучшего пользовательского опыта. Форк от FlClash: Улучшенный опыт, готов к работе «из коробки»",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Адрес назначения"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Геолокация назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "IP ASN назначения",
    ),
    "details": m2,
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
      "Включить преобразование IP4P в диалере",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Напрямую"),
    "directNameserver": MessageLookupByLibrary.simpleMessage("DNS для прямых"),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения прямых доменов",
    ),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "Прямой DNS следует правилам",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("Отключить QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить QUIC для решения сетевых проблем",
    ),
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
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "doubleBounce": MessageLookupByLibrary.simpleMessage("Двойной отскок"),
    "download": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "dozeSuspend": MessageLookupByLibrary.simpleMessage("Поддержка Doze"),
    "dozeSuspendDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация с режимом сна Android",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editTunnel": MessageLookupByLibrary.simpleMessage(
      "Изменить перенаправление",
    ),
    "emptyTip": m3,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enableCrashReport": MessageLookupByLibrary.simpleMessage("Анализ сбоев"),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "Отправка отчётов о сбоях при необходимости",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение",
    ),
    "endpointIndependentNat": MessageLookupByLibrary.simpleMessage(
      "Улучшенный NAT",
    ),
    "endpointIndependentNatDesc": MessageLookupByLibrary.simpleMessage(
      "Включить NAT независимый от конечной точки",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних"),
    "excludeChina": MessageLookupByLibrary.simpleMessage("Исключить Китай"),
    "excludeChinaDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить QUIC-трафик Китая вместо полной блокировки",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрыть приложение из недавних задач",
    ),
    "existsTip": m4,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "expand": MessageLookupByLibrary.simpleMessage("Максимальная"),
    "experimental": MessageLookupByLibrary.simpleMessage("Экспериментальное"),
    "experimentalDesc": MessageLookupByLibrary.simpleMessage(
      "Экспериментальные настройки, используйте с осторожностью",
    ),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
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
    "fadingFour": MessageLookupByLibrary.simpleMessage("Затухающие точки"),
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
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Обычно используются зарубежные DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage(
      "Фильтр резервного DNS",
    ),
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
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Поиск процесса"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Включить поиск процесса",
    ),
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
      "Изменить общие настройки",
    ),
    "generateFromPrivateKey": MessageLookupByLibrary.simpleMessage(
      "Создать из закрытого ключа Age",
    ),
    "generateSecret": MessageLookupByLibrary.simpleMessage("Сгенерировать"),
    "geoData": MessageLookupByLibrary.simpleMessage("Геоданные"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Экономия памяти GEO",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать загрузчик GEO с низким потреблением памяти",
    ),
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
      "Сохранить изменения кэша?",
    ),
    "healthCheckTimeout": MessageLookupByLibrary.simpleMessage(
      "Таймаут проверки",
    ),
    "healthCheckTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Таймаут проверки работоспособности узлов",
    ),
    "highPriority": MessageLookupByLibrary.simpleMessage("Высокий приоритет"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "Повысить приоритет основного и основного процессов",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage(
      "Высокая частота обновления",
    ),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "Включить поддержку максимальной частоты обновления устройства",
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
    "hours": MessageLookupByLibrary.simpleMessage("часов"),
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
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Умный выбор"),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Интервал"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Локальный IP"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage(
      "Неверный формат IP или CIDR",
    ),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage(
      "Режим отображения",
    ),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage("Скрыть IP"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("Включить поддержку IPv6"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящие IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "just": MessageLookupByLibrary.simpleMessage("только что"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал TCP keep-alive",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "layout": MessageLookupByLibrary.simpleMessage("Ширина"),
    "light": MessageLookupByLibrary.simpleMessage("Светлая"),
    "lightIcon": MessageLookupByLibrary.simpleMessage("Светлая иконка"),
    "lightIconDesc": MessageLookupByLibrary.simpleMessage(
      "Переключить на светлый стиль рабочего стола вручную",
    ),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Прослушивание"),
    "local": MessageLookupByLibrary.simpleMessage("Локальное хранилище"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование данных в файл",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление из файла",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Лог"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logcat": MessageLookupByLibrary.simpleMessage("Сбор логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("Показать раздел логов"),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Просмотр журналов"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест логов"),
    "loopback": MessageLookupByLibrary.simpleMessage("Разблокировка UWP"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Инструмент для разблокировки UWP loopback",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Максимальная"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("Обновить IP"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Расход памяти"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "Это тестовое сообщение.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Минимальная"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Изменить поведение при выходе",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("минут"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "months": MessageLookupByLibrary.simpleMessage("месяцев"),
    "more": MessageLookupByLibrary.simpleMessage("Подробности"),
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameSort": MessageLookupByLibrary.simpleMessage("По имени"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Основной DNS"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения доменов",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("Политика DNS"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Указать политику DNS для конкретных доменов",
    ),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "Тактильная отдача",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Вибрация при переключении нижней панели навигации",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("Настройки сети"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("Ваш IP адрес"),
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
      "Показывать текущую скорость в панели уведомлений",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральный"),
    "noAnimation": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Нет горячих клавиш"),
    "noIcon": MessageLookupByLibrary.simpleMessage("Без иконок"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Нет дополнительной информации",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложения без сети"),
    "noProxy": MessageLookupByLibrary.simpleMessage("Нет прокси"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Создайте или добавьте профиль",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("Не разрешать IP"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage(
      "Статус недоступен",
    ),
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
    "nullTip": m5,
    "numberTip": m6,
    "oneColumn": MessageLookupByLibrary.simpleMessage("1 колонка"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("Онлайн-панель"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только иконки"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage("Только сторонние"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Только прокси-трафик",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Считать только трафик через прокси",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("Открыть Zashboard"),
    "openSettings": MessageLookupByLibrary.simpleMessage("Открыть настройки"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники",
    ),
    "otherSettings": MessageLookupByLibrary.simpleMessage(
      "Расширенные инструменты",
    ),
    "otherSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка расширенных функций",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Режим работы"),
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
    "overrideInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Не действует в режиме скрипта",
    ),
    "overrideNtp": MessageLookupByLibrary.simpleMessage("Переопределить NTP"),
    "overrideNtpDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение настроек NTP в конфигурации",
    ),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage(
      "Переопределить исходные",
    ),
    "overrideSniffer": MessageLookupByLibrary.simpleMessage(
      "Переопределить Sniffer",
    ),
    "overrideSnifferDesc": MessageLookupByLibrary.simpleMessage(
      "Включить переопределение настроек Sniffer в конфигурации",
    ),
    "overrideTestUrl": MessageLookupByLibrary.simpleMessage(
      "Переопределить URL теста",
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
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Разбор чистых IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Разбирать соединения по чистому IP",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Привяжите WebDAV",
    ),
    "pleaseCloseSystemProxyFirst": MessageLookupByLibrary.simpleMessage(
      "Сначала отключите системный прокси",
    ),
    "pleaseCloseTunFirst": MessageLookupByLibrary.simpleMessage(
      "Сначала отключите виртуальный адаптер",
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
    "portTip": m7,
    "powerSwitch": MessageLookupByLibrary.simpleMessage("Переключатель"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Приоритет HTTP/3 для DoH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Нажмите клавиши"),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Введите корректный формат интервала",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите интервал автообновления"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Конфигурация изменена. Отключить автообновление?",
    ),
    "profileImportFailed": m8,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите имя профиля",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "Ошибка разбора профиля",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "progress": MessageLookupByLibrary.simpleMessage("Прогресс"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providers": MessageLookupByLibrary.simpleMessage("Провайдеры"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Настройки прокси"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("DNS для прокси"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения доменов прокси",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("Порт прокси"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Установить порт прослушивания Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "pulse": MessageLookupByLibrary.simpleMessage("Пульсация"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чистый чёрный"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканировать QR для получения профиля",
    ),
    "quicGoDisableEcn": MessageLookupByLibrary.simpleMessage(
      "Отключить ECN QUIC",
    ),
    "quicGoDisableEcnDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить Explicit Congestion Notification для QUIC",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage(
      "Отключить GSO QUIC",
    ),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "Отключить Generic Segmentation Offload для QUIC",
    ),
    "quicPortSniffer": MessageLookupByLibrary.simpleMessage(
      "QUIC порты сниффера",
    ),
    "quickResponse": MessageLookupByLibrary.simpleMessage("Быстрый отклик"),
    "quickResponseDesc": MessageLookupByLibrary.simpleMessage(
      "Активно отключать соединения при изменении сети",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радуга"),
    "realTimeSpeed": MessageLookupByLibrary.simpleMessage("Скорость"),
    "recovery": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Все данные"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage("Только профили"),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "Режим восстановления",
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
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр недавних запросов",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetTip": MessageLookupByLibrary.simpleMessage("Сбросить настройки?"),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Управление внешними ресурсами",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Следовать правилам"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-соединения следуют правилам",
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
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("Вращающийся круг"),
    "ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "rule": MessageLookupByLibrary.simpleMessage("Правила"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Имя правила"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Провайдеры правил"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Цель правила"),
    "runTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("Конфигурация"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "saveTip": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка глобального скрипта переопределения",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "Пароль скопирован в буфер обмена",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать все"),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "selectedCountTitle": m9,
    "serviceReady": MessageLookupByLibrary.simpleMessage("Служба готова"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage("Служба запущена"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "shrink": MessageLookupByLibrary.simpleMessage("Средняя"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Тихий запуск"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запуск в фоне без открытия окна",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Высота"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Пропустить домены"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Пропустить IP назначения",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Пропустить IP источника",
    ),
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
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
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
    "spinningLines": MessageLookupByLibrary.simpleMessage("Вращающиеся линии"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Средняя"),
    "start": MessageLookupByLibrary.simpleMessage("Запуск"),
    "startTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN"),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Использовать системный DNS при выключении",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Остановка"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN"),
    "storeFix": MessageLookupByLibrary.simpleMessage("Исправление магазина"),
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
    "syncFailed": MessageLookupByLibrary.simpleMessage("Ошибка синхронизации"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системные приложения"),
    "systemFont": MessageLookupByLibrary.simpleMessage("Системный шрифт"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Настроить системный прокси",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладки"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только в мобильном режиме",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP параллелизм"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить параллельные TCP-соединения",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL теста"),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка темы и иконок",
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
    "tooManyRules": MessageLookupByLibrary.simpleMessage("Максимум 2 правила"),
    "tools": MessageLookupByLibrary.simpleMessage("Настройки"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Общий трафик"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт Tproxy"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("Улучшение трея"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "Управление группами прокси в контекстном меню трея",
    ),
    "tryManualRefresh": MessageLookupByLibrary.simpleMessage(
      "Попробуйте обновить вручную",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("Виртуальный адаптер"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Перехват всего трафика устройства",
    ),
    "tunEnableRequireAdmin": MessageLookupByLibrary.simpleMessage(
      "Для включения виртуального адаптера требуются права администратора. Запустите программу от имени администратора.",
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
    "twoColumns": MessageLookupByLibrary.simpleMessage("2 колонки"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Невозможно обновить текущий профиль",
    ),
    "unauthorized": MessageLookupByLibrary.simpleMessage("Не разрешено"),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage(
      "Унифицированная задержка",
    ),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Убрать задержку рукопожатия и разбора",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без имени"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "upload": MessageLookupByLibrary.simpleMessage("Отправка"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("Получить профиль по URL"),
    "urlTip": m10,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "Глобальное переопределение",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системные hosts",
    ),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркий"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("Настройки VPN"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматическая маршрутизация всего трафика через VpnService",
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
    "wave": MessageLookupByLibrary.simpleMessage("Волна"),
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
    "years": MessageLookupByLibrary.simpleMessage("лет"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("Китайский (упрощённый)"),
    "zh_TC": MessageLookupByLibrary.simpleMessage("Китайский (традиционный)"),
  };
}
