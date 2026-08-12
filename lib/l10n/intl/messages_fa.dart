// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fa locale. All the
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
  String get localeName => 'fa';

  static String m0(count) => "${Intl.plural(count, other: '# روز')}";

  static String m1(label) => "آیا از حذف موارد انتخاب شده اطمینان دارید؟";

  static String m2(label) => "آیا از حذف ${label} اطمینان دارید؟";

  static String m3(label) => "${label} نمی‌تواند خالی باشد";

  static String m4(label) => "${label} از قبل وجود دارد";

  static String m5(count) => "${Intl.plural(count, other: '# ساعت')}";

  static String m6(count) => "${Intl.plural(count, other: '# دقیقه')}";

  static String m7(count) => "${Intl.plural(count, other: '# ماه')}";

  static String m8(label) => "هیچ مورد ${label} یافت نشد";

  static String m9(label) => "${label} باید عدد باشد";

  static String m10(label) =>
      "${label} باید بین ۱۰۲۴ تا ۴۹۱۵۱ باشد (۰ برای غیرفعال)";

  static String m11(statusCode) =>
      "خطا در دریافت پروفایل. لطفاً شبکه خود را بررسی کرده یا لینک را ریست کنید ( کد خطا: ${statusCode} )";

  static String m12(count) => "${count} مورد انتخاب شده";

  static String m13(label) => "${label} باید یک URL معتبر باشد";

  static String m14(count) => "${Intl.plural(count, other: '# سال')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("درباره"),
    "accessControl": MessageLookupByLibrary.simpleMessage("کنترل دسترسی"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "تنها برنامه‌های انتخاب شده از VPN عبور کنند",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم لیست سیاه/سفید دسترسی برنامه‌ها",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "برنامه‌های انتخاب شده از VPN استثنا شوند",
    ),
    "account": MessageLookupByLibrary.simpleMessage("حساب کاربری"),
    "action": MessageLookupByLibrary.simpleMessage("عملیات"),
    "action_mode": MessageLookupByLibrary.simpleMessage("تغییر حالت"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("پروکسی سیستم"),
    "action_start": MessageLookupByLibrary.simpleMessage("شروع / توقف"),
    "action_tun": MessageLookupByLibrary.simpleMessage("کارت شبکه مجازی (TUN)"),
    "action_view": MessageLookupByLibrary.simpleMessage("نمایش / پنهان"),
    "add": MessageLookupByLibrary.simpleMessage("افزودن"),
    "addProfile": MessageLookupByLibrary.simpleMessage("افزودن پروفایل"),
    "addRule": MessageLookupByLibrary.simpleMessage("افزودن قانون"),
    "addTunnel": MessageLookupByLibrary.simpleMessage("افزودن هدایت"),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage(
      "افزودن به قوانین اصلی",
    ),
    "address": MessageLookupByLibrary.simpleMessage("آدرس"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("آدرس سرور WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "لطفاً آدرس WebDAV معتبری وارد کنید",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "شروع خودکار با دسترسی Admin",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "اجرای خودکار با دسترسی Admin هنگام بووت",
    ),
    "advancedSettings": MessageLookupByLibrary.simpleMessage("تنظیمات پیشرفته"),
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "تولید کلید Age",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "جفت کلید X25519 با موفقیت ساخته شد. لطفاً آن را ذخیره کنید",
    ),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage(
      "کلید خصوصی Age",
    ),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "لطفا ابتدا کلید خصوصی Age صحیح را وارد کنید",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage("کلید عمومی Age"),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید خصوصی معتبری وارد کنید (باید با -AGE-SECRET-KEY شروع شود)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage(
      "کلید خصوصی Age (اختیاری)",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("قبل"),
    "agree": MessageLookupByLibrary.simpleMessage("موافقم"),
    "allApps": MessageLookupByLibrary.simpleMessage("همه برنامه‌ها"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("اجازه میانبر VPN"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه به برخی برنامه‌ها برای عبور مستقیم بدون VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("دسترسی شبکه محلی"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه دسترسی به پروکسی از شبکه محلی (LAN)",
    ),
    "alreadyInWhitelist": MessageLookupByLibrary.simpleMessage(
      "برنامه قبلاً در لیست سفید قرار دارد",
    ),
    "alwaysShowTitleBar": MessageLookupByLibrary.simpleMessage(
      "دکمه‌های عنوان",
    ),
    "alwaysShowTitleBarDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش همیشگی دکمه‌های نوار عنوان بالا سمت راست",
    ),
    "app": MessageLookupByLibrary.simpleMessage("برنامه"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "کنترل دسترسی برنامه‌ها",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage("تنظیمات مربوط به برنامه"),
    "application": MessageLookupByLibrary.simpleMessage("برنامه"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "مدیریت تنظیمات برنامه",
    ),
    "authorized": MessageLookupByLibrary.simpleMessage("احراز هویت شده"),
    "auto": MessageLookupByLibrary.simpleMessage("خودکار"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "بررسی خودکار بروزرسانی",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "بررسی خودکار بروزرسانی هنگام اجرای برنامه",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "بستن خودکار اتصالات",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "قطع خودکار اتصالات هنگام تغییر نود",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("شروع خودکار"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "اجرای خودکار هنگام روشن شدن سیستم",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("اتصال خودکار"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "اتصال خودکار پروکسی پس از باز شدن برنامه",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "تنظیم خودکار DNS سیستم",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("بروزرسانی خودکار"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "فاصله بروزرسانی خودکار (دقیقه)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری و بازیابی",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی داده‌ها از طریق WebDAV یا محلی",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری با موفقیت انجام شد",
    ),
    "basicConfig": MessageLookupByLibrary.simpleMessage("تنظیمات هسته"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر کلی تنظیمات هسته",
    ),
    "batteryOptimization": MessageLookupByLibrary.simpleMessage(
      "بهینه‌سازی باتری",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "درخواست استثنا از بهینه‌سازی باتری",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("اتصال"),
    "blacklist": MessageLookupByLibrary.simpleMessage("لیست سیاه"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سیاه"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("دامنه‌های استثنا"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "اعمال تنها در صورت فعال بودن پروکسی سیستم",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "استثنای شبکه خصوصی",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "استثنای خودکار آدرس‌های شبکه خصوصی (LAN)",
    ),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage(
      "الگوریتم حافظه پنهان",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "حافظه پنهان آسیب دیده است. آیا پاکسازی شود؟",
    ),
    "cameraPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "مجوز دوربین رد شد",
    ),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "برای اسکن کد QR دسترسی دوربین لازم است. لطفاً از تنظیمات مجوز دهید.",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("لغو"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "لغو فیلتر برنامه‌های سیستم",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("لغو انتخاب همه"),
    "checkError": MessageLookupByLibrary.simpleMessage("بررسی ناموفق بود"),
    "checkOrAddProfile": MessageLookupByLibrary.simpleMessage(
      "لطفاً ابتدا یک پروفایل اضافه کنید",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("بررسی بروزرسانی"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "شما از آخرین نسخه استفاده می‌کنید",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("در حال بررسی..."),
    "circle": MessageLookupByLibrary.simpleMessage("حلقه"),
    "clearCacheDesc": MessageLookupByLibrary.simpleMessage(
      "آیا حافظه پنهان FakeIP و DNS پاکسازی شود؟",
    ),
    "clearCacheTitle": MessageLookupByLibrary.simpleMessage(
      "پاکسازی حافظه پنهان",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("پاکسازی داده‌ها"),
    "clearDataTipDesc": MessageLookupByLibrary.simpleMessage(
      "این عملیات تمامی تنظیمات برنامه را بازنشانی می‌کند. آیا مطمئن هستید؟",
    ),
    "clearDataTipTitle": MessageLookupByLibrary.simpleMessage("عملیات حساس"),
    "clipboard": MessageLookupByLibrary.simpleMessage("حافظه موقت"),
    "clipboardDesc": MessageLookupByLibrary.simpleMessage(
      "دریافت خودکار لینک از حافظه موقت",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "خروجی به حافظه موقت",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "وارد کردن از حافظه موقت",
    ),
    "color": MessageLookupByLibrary.simpleMessage("رنگ"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("پالت‌های رنگی"),
    "columns": MessageLookupByLibrary.simpleMessage("تعداد ستون‌ها"),
    "compatible": MessageLookupByLibrary.simpleMessage("حالت سازگاری"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی برخی ویژگی‌ها جهت سازگاری کامل با Clash",
    ),
    "concurrencyLimit": MessageLookupByLibrary.simpleMessage("محدودیت همزمانی"),
    "concurrencyLimitDesc": MessageLookupByLibrary.simpleMessage(
      "حداکثر تعداد تست همزمان تاخیر",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("تایید"),
    "connection": MessageLookupByLibrary.simpleMessage("اتصال فعال"),
    "connections": MessageLookupByLibrary.simpleMessage("اتصالات"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده اتصالات فعال شبکه",
    ),
    "connectionsSort": MessageLookupByLibrary.simpleMessage(
      "مرتب‌سازی اتصال‌ها",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("وضعیت اتصال:"),
    "contactMe": MessageLookupByLibrary.simpleMessage("تماس با ما"),
    "content": MessageLookupByLibrary.simpleMessage("محتوا"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("پوسته محتوا"),
    "controlSecret": MessageLookupByLibrary.simpleMessage("رمز عبور کنترل"),
    "controlSecretDesc": MessageLookupByLibrary.simpleMessage(
      "رمز عبور دسترسی به RESTful API",
    ),
    "copiedPackageName": MessageLookupByLibrary.simpleMessage(
      "نام پکیج کپی شد",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("کپی"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("کپی متغیرهای محیطی"),
    "copyLink": MessageLookupByLibrary.simpleMessage("کپی لینک"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("با موفقیت کپی شد"),
    "core": MessageLookupByLibrary.simpleMessage("هسته"),
    "coreConnected": MessageLookupByLibrary.simpleMessage("متصل شد"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("اطلاعات هسته"),
    "coreSuspended": MessageLookupByLibrary.simpleMessage("معلق شد"),
    "country": MessageLookupByLibrary.simpleMessage("منطقه"),
    "crashTest": MessageLookupByLibrary.simpleMessage("تست خرابی"),
    "create": MessageLookupByLibrary.simpleMessage("ایجاد"),
    "creationTime": MessageLookupByLibrary.simpleMessage("زمان ایجاد"),
    "custom": MessageLookupByLibrary.simpleMessage("سفارشی"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "عنوان سفارشی",
    ),
    "customScriptOptions": MessageLookupByLibrary.simpleMessage(
      "قوانین سفارشی",
    ),
    "customUrl": MessageLookupByLibrary.simpleMessage("آدرس URL سفارشی"),
    "cut": MessageLookupByLibrary.simpleMessage("برش"),
    "dark": MessageLookupByLibrary.simpleMessage("تاریک"),
    "darkIcon": MessageLookupByLibrary.simpleMessage("آیکون تاریک"),
    "darkIconDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر آیکون برنامه به تم تاریک",
    ),
    "dashboard": MessageLookupByLibrary.simpleMessage("داشبورد"),
    "days": m0,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "سرور نام پیش‌فرض",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "برای تحلیل سرورهای DNS",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی پیش‌فرض"),
    "defaultText": MessageLookupByLibrary.simpleMessage("پیش‌فرض"),
    "delay": MessageLookupByLibrary.simpleMessage("تاخیر"),
    "delayAnimation": MessageLookupByLibrary.simpleMessage("انیمیشن تست"),
    "delayAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "سفارشی‌سازی انیمیشن حین تست تاخیر",
    ),
    "delaySort": MessageLookupByLibrary.simpleMessage(
      "مرتب‌سازی بر اساس تاخیر",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteMultipTip": m1,
    "deleteTip": m2,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage("حذف هدایت"),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettbox یک کلاینت پروکسی بر پایه هسته قدرتمند Mihomo (Clash.Meta) است. (برگرفته از FlClash)",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("آدرس مقصد"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "موقعیت جغرافیایی مقصد",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("شناسه ASN مقصد"),
    "details": MessageLookupByLibrary.simpleMessage("جزئیات"),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "استفاده از API جانبی (صرفاً جهت اطلاع)",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("حالت توسعه‌دهنده"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "حالت توسعه‌دهنده فعال شد.",
    ),
    "dialerIp4pConvert": MessageLookupByLibrary.simpleMessage(
      "فعالسازی تبدیل IP4P",
    ),
    "dialerIp4pConvertDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی تبدیل آدرس IP4P شماره‌گیر",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("مستقیم"),
    "directNameserver": MessageLookupByLibrary.simpleMessage("DNS مستقیم"),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "برای تحلیل دامنه‌های خروجی مستقیم",
    ),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "DNS مستقیم از سیاست پیروی کند",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("غیرفعال‌سازی QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC برای رفع مشکلات شبکه",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("سلب مسئولیت"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "این نرم‌افزار رایگان و متن‌باز است و صرفاً برای استفاده شخصی و آموزشی ارائه شده است.",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "نسخه جدیدی پیدا شد",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage("نسخه جدید یافت شد"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("تنظیمات مربوط به DNS"),
    "dnsHijack": MessageLookupByLibrary.simpleMessage("ربودن DNS"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "هدایت استعلام‌های DNS به ماژول داخلی",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("حالت DNS"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "آیا می‌خواهید مجوز دهید برای:",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("دامنه"),
    "doubleBounce": MessageLookupByLibrary.simpleMessage("جهش دوگانه"),
    "download": MessageLookupByLibrary.simpleMessage("دانلود"),
    "dozeSuspend": MessageLookupByLibrary.simpleMessage("پشتیبانی از Doze"),
    "dozeSuspendDesc": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی با حالت خواب سیستم (Doze)",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("ویرایش"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("ویرایش هدایت"),
    "emptyTip": m3,
    "enableCrashReport": MessageLookupByLibrary.simpleMessage("تحلیل خرابی‌ها"),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "ارسال گزارش خرابی در صورت لزوم",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage("فعالسازی اورراید"),
    "enableTraySpeed": MessageLookupByLibrary.simpleMessage("نمایش سرعت شبکه"),
    "enableTraySpeedDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش سرعت آپلود و دانلود در نوار منو",
    ),
    "endpointIndependentNat": MessageLookupByLibrary.simpleMessage(
      "ارتقای NAT",
    ),
    "endpointIndependentNatConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی Endpoint-Independent NAT ممکن است کارایی را اندکی کاهش دهد. تنها در صورت نیاز استفاده کنید",
    ),
    "endpointIndependentNatDesc": MessageLookupByLibrary.simpleMessage(
      "بهینه‌سازی تجربه برنامه‌های UDP و P2P",
    ),
    "entries": MessageLookupByLibrary.simpleMessage("مورد"),
    "exclude": MessageLookupByLibrary.simpleMessage("پنهان‌سازی از پس‌زمینه"),
    "excludeChina": MessageLookupByLibrary.simpleMessage("استثنای چین"),
    "excludeChinaDesc": MessageLookupByLibrary.simpleMessage(
      "مجاز ساختن ترافیک QUIC چین به جای مسدودی کامل",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "پنهان کردن برنامه از لیست برنامه‌های اخیر",
    ),
    "existsTip": m4,
    "exit": MessageLookupByLibrary.simpleMessage("خروج"),
    "expand": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "experimental": MessageLookupByLibrary.simpleMessage("ویژگی‌های آزمایشی"),
    "experimentalDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات آزمایشی با احتیاط استفاده شود",
    ),
    "expirationTime": MessageLookupByLibrary.simpleMessage("تاریخ انقضا"),
    "exportFile": MessageLookupByLibrary.simpleMessage("خروجی فایل"),
    "exportLogs": MessageLookupByLibrary.simpleMessage(
      "خروجی گرفتن از گزارش‌ها",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "خروجی با موفقیت گرفته شد",
    ),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("حس‌آمیز"),
    "externalController": MessageLookupByLibrary.simpleMessage("کنترل خارجی"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "کنترل هسته از طریق پورت آنلاین",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("لینک خارجی"),
    "externalResources": MessageLookupByLibrary.simpleMessage("منابع خارجی"),
    "fadingCircle": MessageLookupByLibrary.simpleMessage("حلقه محوشونده"),
    "fadingFour": MessageLookupByLibrary.simpleMessage("چهار دایره محوشونده"),
    "fakeIpFilterMode": MessageLookupByLibrary.simpleMessage(
      "حالت فیلتر FakeIP",
    ),
    "fakeIpFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "تعیین حالت فیلتر FakeIP",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("لیست فیلتر FakeIP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("محدوده FakeIP"),
    "fakeipRangeV6": MessageLookupByLibrary.simpleMessage("محدوده FakeIPv6"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("زمان اعتبار FakeIP"),
    "fallback": MessageLookupByLibrary.simpleMessage("فالبک DNS"),
    "fallbackConcurrent": MessageLookupByLibrary.simpleMessage(
      "استعلام همزمان فالبک",
    ),
    "fallbackConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "استعلام همزمان از DNS اصلی و فالبک",
    ),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده برای دامنه‌های خارجی",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("فیلتر فالبک"),
    "fcmOptimization": MessageLookupByLibrary.simpleMessage("بهینه‌سازی FCM"),
    "fcmOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "افزایش پایداری اتصال مستقیم FCM",
    ),
    "fcmTip": MessageLookupByLibrary.simpleMessage(
      "اتصال FCM به دستگاه شما بستگی دارد. برای نتایج دقیق‌تر، گزینه \'میانبر زدن VPN\' را غیرفعال کنید",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("فیدلیتی"),
    "file": MessageLookupByLibrary.simpleMessage("فایل"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "آپلود فایل پروفایل از حافظه",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "فایل تغییر یافته است. آیا ذخیره شود؟",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "فیلتر برنامه‌های سیستم",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("جستجوی پردازش"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "امکان جستجو و تطبیق پردازش‌ها",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("فونت"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("نگاشت اجباری DNS"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "نگاشت اجباری نتایج DNS به اتصالات",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("دامنه‌های اجباری"),
    "forceGCDesc": MessageLookupByLibrary.simpleMessage(
      "آیا آزادسازی اجباری حافظه هسته انجام شود؟ (ازمایشی)",
    ),
    "forceGCTitle": MessageLookupByLibrary.simpleMessage(
      "پاکسازی اجباری حافظه",
    ),
    "formatError": MessageLookupByLibrary.simpleMessage(
      "لطفاً صحت فرمت را بررسی کنید",
    ),
    "fourColumns": MessageLookupByLibrary.simpleMessage("۴ ستون"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("سالاد میوه"),
    "general": MessageLookupByLibrary.simpleMessage("عمومی"),
    "generalDesc": MessageLookupByLibrary.simpleMessage("تغییر تنظیمات عمومی"),
    "generateFromPrivateKey": MessageLookupByLibrary.simpleMessage(
      "تولید از کلید خصوصی",
    ),
    "generateSecret": MessageLookupByLibrary.simpleMessage("تولید"),
    "geoData": MessageLookupByLibrary.simpleMessage("داده‌های جغرافیایی"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "کاهش مصرف حافظه GEO",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از لودر کم‌مصرف داده‌های GEO",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("کد GeoIP"),
    "getOriginRules": MessageLookupByLibrary.simpleMessage(
      "دریافت قوانین اصلی",
    ),
    "global": MessageLookupByLibrary.simpleMessage("سراسر جهان"),
    "go": MessageLookupByLibrary.simpleMessage("رفتن"),
    "goDownload": MessageLookupByLibrary.simpleMessage("رفتن به دانلود"),
    "harmonyFont": MessageLookupByLibrary.simpleMessage("ترمیم فونت"),
    "harmonyFontDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از فونت داخلی برای رفع مشکلات نمایش",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "آیا تغییرات ذخیره شوند؟",
    ),
    "healthCheckTimeout": MessageLookupByLibrary.simpleMessage(
      "مهلت زمانی تست",
    ),
    "healthCheckTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "مهلت زمانی تست سلامت نودها",
    ),
    "highPriority": MessageLookupByLibrary.simpleMessage("اولویت بالا"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "افزایش اولویت پردازش برنامه و هسته",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage("نرخ نوسازی بالا"),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی حداکثر نرخ نوسازی صفحه نمایش",
    ),
    "host": MessageLookupByLibrary.simpleMessage("هاست"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage(
      "افزودن Hosts به پروفایل فعلی",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("تداخل کلید میانبر"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "مدیریت کلیدهای میانبر",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "کنترل برنامه با صفحه کلید",
    ),
    "hours": m5,
    "httpPortSniffer": MessageLookupByLibrary.simpleMessage("اسنیف پورت HTTP"),
    "icmpForwarding": MessageLookupByLibrary.simpleMessage("هدایت ICMP"),
    "icmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبانی از پینگ ICMP در صورت فعال بودن",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("تصویر"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage("تنظیمات تصویر"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("سبک آیکون"),
    "import": MessageLookupByLibrary.simpleMessage("وارد کردن"),
    "importFailed": MessageLookupByLibrary.simpleMessage(
      "وارد کردن ناموفق بود",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("وارد کردن از فایل"),
    "importFromCode": MessageLookupByLibrary.simpleMessage(
      "وارد کردن از طریق کد",
    ),
    "importFromURL": MessageLookupByLibrary.simpleMessage("وارد کردن از URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("وارد کردن از URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("نامحدود"),
    "init": MessageLookupByLibrary.simpleMessage("راه‌اندازی اولیه"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید میانبر معتبری وارد کنید",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "انتخاب هوشمند",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("اینترنت"),
    "interval": MessageLookupByLibrary.simpleMessage("فاصله زمانی"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP شبکه محلی"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage(
      "فرمت IP یا CIDR نامعتبر است",
    ),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage("تغییر نمایش"),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage(
      "پنهان‌سازی IP",
    ),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP / ماسک"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "دریافت ترافیک IPv6 فعال باشد",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "ورودی IPv6 مجاز باشد",
    ),
    "just": MessageLookupByLibrary.simpleMessage("همین الان"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "فاصله زمانی TCP Keep-Alive",
    ),
    "key": MessageLookupByLibrary.simpleMessage("کلید"),
    "language": MessageLookupByLibrary.simpleMessage("زبان"),
    "layout": MessageLookupByLibrary.simpleMessage("چیدمان"),
    "light": MessageLookupByLibrary.simpleMessage("روشن"),
    "lightIcon": MessageLookupByLibrary.simpleMessage("آیکون روشن"),
    "lightIconDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر آیکون برنامه به تم روشن",
    ),
    "lineWrap": MessageLookupByLibrary.simpleMessage("شکستن خطوط"),
    "list": MessageLookupByLibrary.simpleMessage("فهرست"),
    "listen": MessageLookupByLibrary.simpleMessage("شنود"),
    "local": MessageLookupByLibrary.simpleMessage("محلی"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری داده‌ها در فایل محلی",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از فایل محلی",
    ),
    "log": MessageLookupByLibrary.simpleMessage("گزارش"),
    "logLevel": MessageLookupByLibrary.simpleMessage("سطح گزارش"),
    "logcat": MessageLookupByLibrary.simpleMessage("ثبت گزارش‌ها"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش ورودی گزارش‌ها در صورت فعال بودن",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("گزارش‌ها"),
    "logsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده گزارش‌های ثبت شده",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("تست گزارش‌ها"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "ابزار رفع محدودیت Loopback",
    ),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "رفع محدودیت Loopback برای برنامه‌های UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("باز"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("دریافت مجدد IP"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("اطلاعات حافظه"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "مقادیر حافظه نشان داده شده صرفاً مربوط به حافظه دینامیک هسته بوده و تمام حافظه برنامه نیست (جهت اطلاع).",
    ),
    "messageTest": MessageLookupByLibrary.simpleMessage("تست پیام"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "این یک پیام تستی است.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("حداقل"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "مینیمایز هنگام خروج",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر رفتار پیش‌فرض بستن окно",
    ),
    "minutes": m6,
    "mixedPort": MessageLookupByLibrary.simpleMessage("پورت ترکیبی (Mixed)"),
    "mode": MessageLookupByLibrary.simpleMessage("حالت"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("تک‌رنگ"),
    "months": m7,
    "more": MessageLookupByLibrary.simpleMessage("بیشتر"),
    "name": MessageLookupByLibrary.simpleMessage("نام"),
    "nameSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس نام"),
    "nameserver": MessageLookupByLibrary.simpleMessage("سرور نام (Nameserver)"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "برای تحلیل دامنه‌ها",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("سیاست سرور نام"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "تعیین سیاست DNS برای دامنه‌ها",
    ),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "بازخورد لمسی",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "لرزش هنگام تغییر زبانه‌های نوار پایین",
    ),
    "navConnections": MessageLookupByLibrary.simpleMessage("اتصالات"),
    "navTools": MessageLookupByLibrary.simpleMessage("ابزارها"),
    "network": MessageLookupByLibrary.simpleMessage("شبکه"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("تغییر تنظیمات شبکه"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("تست شبکه"),
    "networkFix": MessageLookupByLibrary.simpleMessage("ترمیم شبکه"),
    "networkFixDesc": MessageLookupByLibrary.simpleMessage(
      "رفع مشکل آیکون کره زمین شبکه سیستم",
    ),
    "networkMatch": MessageLookupByLibrary.simpleMessage("تطبیق شبکه"),
    "networkMatchHint": MessageLookupByLibrary.simpleMessage(
      "IP یا CIDR (حداکثر ۲ مورد با ویرگول جدا شوند)",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("سرعت شبکه"),
    "networkSpeedNotification": MessageLookupByLibrary.simpleMessage(
      "اعلان سرعت",
    ),
    "networkSpeedNotificationDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش سرعت شبکه و اشتراک در نوار اعلان",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("نوع شبکه"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("خنثی"),
    "noAnimation": MessageLookupByLibrary.simpleMessage("پیش‌فرض"),
    "noData": MessageLookupByLibrary.simpleMessage("داده‌ای موجود نیست"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("بدون کلید میانبر"),
    "noIcon": MessageLookupByLibrary.simpleMessage("بدون آیکون"),
    "noInfo": MessageLookupByLibrary.simpleMessage("اطلاعاتی موجود نیست"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "اطلاعات بیشتری موجود نیست",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("بدون شبکه"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage(
      "برنامه‌های بدون شبکه",
    ),
    "noProxy": MessageLookupByLibrary.simpleMessage("بدون پروکسی"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک پروفایل معتبر ایجاد یا اضافه کنید",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("عدم تحلیل IP"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage(
      "وضعیتی یافت نشد",
    ),
    "nodeExclusion": MessageLookupByLibrary.simpleMessage("استثنای نودها"),
    "nodeExclusionDesc": MessageLookupByLibrary.simpleMessage(
      "حذف نودهای مطابقت یافته با عبارت",
    ),
    "nodeExclusionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "HK|ایران|🇮🇷",
    ),
    "none": MessageLookupByLibrary.simpleMessage("هیچکدام"),
    "notRecommended": MessageLookupByLibrary.simpleMessage("توصیه نمی‌شود"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "گروه پروکسی فعلی قابل انتخاب نیست",
    ),
    "ntp": MessageLookupByLibrary.simpleMessage("همگام‌سازی زمان NTP"),
    "ntpDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از سرویس زمان NTP",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("فاصله بروزرسانی"),
    "ntpPort": MessageLookupByLibrary.simpleMessage("پورت"),
    "ntpServer": MessageLookupByLibrary.simpleMessage("سرور"),
    "ntpStatus": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی سرویس زمان NTP",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "هیچ پروفایلی یافت نشد. لطفاً یکی اضافه کنید",
    ),
    "nullTip": m8,
    "numberTip": m9,
    "oneColumn": MessageLookupByLibrary.simpleMessage("۱ ستون"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("پنل آنلاین"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("فقط آیکون"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "فقط برنامه‌های جانبی",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "آمار ترافیک پروکسی",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "محاسبه ترافیک فقط برای پروکسی‌ها",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("باز کردن Zashboard"),
    "openSettings": MessageLookupByLibrary.simpleMessage("باز کردن تنظیمات"),
    "options": MessageLookupByLibrary.simpleMessage("گزینه‌ها"),
    "other": MessageLookupByLibrary.simpleMessage("سایر"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "مشارکت‌کنندگان دیگر (ترتیب تصادفی)",
    ),
    "otherSettings": MessageLookupByLibrary.simpleMessage("ابزارهای پیشرفته"),
    "otherSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر تنظیمات ابزارهای پیشرفته",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("حالت خروجی"),
    "override": MessageLookupByLibrary.simpleMessage("اورراید"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "اورراید تنظیمات پروکسی",
    ),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "جایگزینی آدرس مقصد",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از نتیجه اسنیفر برای آدرس مقصد",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("اورراید DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "جایگزینی تنظیمات DNS پروفایل",
    ),
    "overrideExperimental": MessageLookupByLibrary.simpleMessage(
      "اورراید تنظیمات آزمایشی",
    ),
    "overrideExperimentalDesc": MessageLookupByLibrary.simpleMessage(
      "جایگزینی تنظیمات آزمایشی پروفایل",
    ),
    "overrideInvalidTip": MessageLookupByLibrary.simpleMessage(
      "در حالت اسکریپت اعمال نمی‌شود",
    ),
    "overrideNtp": MessageLookupByLibrary.simpleMessage("اورراید NTP"),
    "overrideNtpDesc": MessageLookupByLibrary.simpleMessage(
      "جایگزینی تنظیمات NTP پروفایل",
    ),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage(
      "جایگزینی قوانین اصلی",
    ),
    "overrideSniffer": MessageLookupByLibrary.simpleMessage("اورراید Sniffer"),
    "overrideSnifferDesc": MessageLookupByLibrary.simpleMessage(
      "جایگزینی تنظیمات Sniffer پروفایل",
    ),
    "overrideTestUrl": MessageLookupByLibrary.simpleMessage(
      "جایگزینی آدرس تست",
    ),
    "overrideTunnel": MessageLookupByLibrary.simpleMessage("اورراید تونل"),
    "overrideTunnelDesc": MessageLookupByLibrary.simpleMessage(
      "جایگزینی تنظیمات تونل پروفایل",
    ),
    "packageListPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "مجوز رد شد. امکان دسترسی به لیست برنامه‌ها وجود ندارد.",
    ),
    "packageListPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "برای دسترسی به لیست برنامه‌ها مجوز لازم است. آیا موافقید؟",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("پالت"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage(
      "تحلیل اتصالات IP خالص",
    ),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "تحلیل اتصالات مستقیم IP",
    ),
    "password": MessageLookupByLibrary.simpleMessage("رمز عبور"),
    "paste": MessageLookupByLibrary.simpleMessage("جایگذاری"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "لطفاً به WebDAV متصل شوید",
    ),
    "pleaseCloseSystemProxyFirst": MessageLookupByLibrary.simpleMessage(
      "لطفاً ابتدا پروکسی سیستم را غیرفعال کنید",
    ),
    "pleaseCloseTunFirst": MessageLookupByLibrary.simpleMessage(
      "لطفاً ابتدا حالت TUN را غیرفعال کنید",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "لطفاً نام اسکریپت را وارد کنید",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "لطفاً رمز عبور Admin را وارد کنید",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "لطفاً فایل را آپلود کنید",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "لطفاً تصویر کد QR معتبری آپلود کنید",
    ),
    "port": MessageLookupByLibrary.simpleMessage("پورت"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "لطفاً پورت غیرتکراری وارد کنید",
    ),
    "portTip": m10,
    "powerSwitch": MessageLookupByLibrary.simpleMessage("کلید روشن/خاموش"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "اولویت استفاده از HTTP/3 در DoH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید را فشار دهید",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
    "profile": MessageLookupByLibrary.simpleMessage("پروفایل"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "لطفاً فرمت زمان معتبری وارد کنید",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("لطفاً فاصله زمانی را وارد کنید"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "پروفایل تغییر یافته است. آیا بروزرسانی خودکار غیرفعال شود؟",
    ),
    "profileImportFailed": m11,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً نام پروفایل را وارد کنید",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "خطا در پردازش فایل پروفایل",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک آدرس URL معتبر وارد کنید",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً آدرس URL را وارد کنید",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("پروفایل‌ها"),
    "profilesSort": MessageLookupByLibrary.simpleMessage(
      "مرتب‌سازی پروفایل‌ها",
    ),
    "progress": MessageLookupByLibrary.simpleMessage("پردازش"),
    "project": MessageLookupByLibrary.simpleMessage("پروژه"),
    "providers": MessageLookupByLibrary.simpleMessage("ارائه‌دهندگان"),
    "proxies": MessageLookupByLibrary.simpleMessage("پروکسی‌ها"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("تنظیمات پروکسی"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("زنجیره پروکسی"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("گروه پروکسی"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("DNS پروکسی"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "برای تحلیل دامنه‌های نودهای پروکسی",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("پورت پروکسی"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم پورت گوش به زنگ Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان پروکسی",
    ),
    "pulse": MessageLookupByLibrary.simpleMessage("پالس"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("حالت مشکی خالص"),
    "qrcode": MessageLookupByLibrary.simpleMessage("کد QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "اسکن کد QR برای دریافت پروفایل",
    ),
    "quicGoDisableEcn": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC ECN",
    ),
    "quicGoDisableEcnDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی ویژگی ECN در QUIC",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC GSO",
    ),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی ویژگی GSO در QUIC",
    ),
    "quicPortSniffer": MessageLookupByLibrary.simpleMessage("اسنیف پورت QUIC"),
    "quickResponse": MessageLookupByLibrary.simpleMessage("پاسخ سریع"),
    "quickResponseDesc": MessageLookupByLibrary.simpleMessage(
      "قطع فوری اتصال‌ها هنگام تغییر شبکه",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("رنگین‌کمان"),
    "realTimeSpeed": MessageLookupByLibrary.simpleMessage("سرعت لحظه‌ای"),
    "recovery": MessageLookupByLibrary.simpleMessage("بازیابی"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("بازیابی تمام داده‌ها"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "فقط بازیابی پروفایل‌ها",
    ),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "استراتژی بازیابی",
    ),
    "recoveryStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "سازگار",
    ),
    "recoveryStrategy_override": MessageLookupByLibrary.simpleMessage(
      "جایگزینی",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage(
      "بازیابی با موفقیت انجام شد",
    ),
    "redirPort": MessageLookupByLibrary.simpleMessage("پورت Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("انجام مجدد"),
    "refreshAppList": MessageLookupByLibrary.simpleMessage(
      "بروزرسانی لیست برنامه‌ها",
    ),
    "refreshAppListConfirm": MessageLookupByLibrary.simpleMessage(
      "آیا لیست برنامه‌ها بروزرسانی شود؟",
    ),
    "regExp": MessageLookupByLibrary.simpleMessage("عبارت باقاعده (RegEx)"),
    "remote": MessageLookupByLibrary.simpleMessage("از راه دور"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری داده‌ها روی WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "مقصد از راه دور",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("حذف"),
    "rename": MessageLookupByLibrary.simpleMessage("تغییر نام"),
    "replace": MessageLookupByLibrary.simpleMessage("جایگزینی"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("جایگزینی همه"),
    "request": MessageLookupByLibrary.simpleMessage("درخواست"),
    "requests": MessageLookupByLibrary.simpleMessage("درخواست‌ها"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده تاریخچه درخواست‌های اخیر",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("بازنشانی"),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "آیا از بازنشانی اطمینان دارید؟",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("منابع"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "اطلاعات منابع خارجی",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("پیروی از قوانین"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "اتصالات DNS از قوانین پیروی کنند",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("راه‌اندازی مجدد"),
    "restartApp": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی مجدد برنامه",
    ),
    "restartCoreDesc": MessageLookupByLibrary.simpleMessage(
      "آیا هسته به صورت دستی راه‌اندازی مجدد شود؟",
    ),
    "restartCoreTitle": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی مجدد هسته",
    ),
    "restartTip": MessageLookupByLibrary.simpleMessage(
      "تغییرات پس از راه‌اندازی مجدد TUN اعمال می‌شود",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("تلاش مجدد"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("چرخش تک‌دایره"),
    "rule": MessageLookupByLibrary.simpleMessage("قوانین"),
    "ruleName": MessageLookupByLibrary.simpleMessage("نام قانون"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان قوانین",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("مقصد قانون"),
    "runTime": MessageLookupByLibrary.simpleMessage("مدت زمان اجرا"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("پیکربندی زمان اجرا"),
    "save": MessageLookupByLibrary.simpleMessage("ذخیره"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "آیا تغییرات ذخیره شوند؟",
    ),
    "saveTip": MessageLookupByLibrary.simpleMessage(
      "آیا از ذخیره تغییرات اطمینان دارید؟",
    ),
    "script": MessageLookupByLibrary.simpleMessage("اسکریپت"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات اسکریپت اورراید سراسری",
    ),
    "search": MessageLookupByLibrary.simpleMessage("جستجو"),
    "seconds": MessageLookupByLibrary.simpleMessage("ثانیه"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "رمز عبور در حافظه موقت کپی شد",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("انتخاب همه"),
    "selected": MessageLookupByLibrary.simpleMessage("انتخاب شده"),
    "selectedCountTitle": m12,
    "serviceReady": MessageLookupByLibrary.simpleMessage("سرویس آماده است"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage(
      "سرویس در حال اجرا است",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
    "show": MessageLookupByLibrary.simpleMessage("نمایش"),
    "showHiddenItems": MessageLookupByLibrary.simpleMessage(
      "نمایش موارد پنهان",
    ),
    "showStartSwitch": MessageLookupByLibrary.simpleMessage("دکمه کلید سوئیچ"),
    "showStartSwitchDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش دکمه مستقل روشن/خاموش در صفحه اصلی",
    ),
    "shrink": MessageLookupByLibrary.simpleMessage("فشرده"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("اجرای بی‌صدا"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "اجرا در پس‌زمینه بدون باز کردن پنجره",
    ),
    "size": MessageLookupByLibrary.simpleMessage("اندازه"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("دامنه‌های مستثنی"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("IP مقصد مستثنی"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("IP مبدا مستثنی"),
    "smartAutoStop": MessageLookupByLibrary.simpleMessage("توقف هوشمند"),
    "smartAutoStopDesc": MessageLookupByLibrary.simpleMessage(
      "توقف سرویس پروکسی هنگام اتصال به شبکه مشخص",
    ),
    "smartAutoStopServiceRunning": MessageLookupByLibrary.simpleMessage(
      "سرویس توقف هوشمند در حال اجرا است",
    ),
    "smartDelayLaunch": MessageLookupByLibrary.simpleMessage("شروع با تاخیر"),
    "smartDelayLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "اجرا تنها پس از اتصال موفق شبکه",
    ),
    "sniffer": MessageLookupByLibrary.simpleMessage("اسنیفر (Sniffer)"),
    "snifferAddressHint": MessageLookupByLibrary.simpleMessage(
      "هر سطر یک آدرس",
    ),
    "snifferDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات ردیابی دامنه (Domain Sniffing)",
    ),
    "snifferDomainHint": MessageLookupByLibrary.simpleMessage(
      "هر سطر یک دامنه",
    ),
    "snifferPorts": MessageLookupByLibrary.simpleMessage("پورت‌ها"),
    "snifferPortsHint": MessageLookupByLibrary.simpleMessage(
      "مثال: 80, 8080-8880",
    ),
    "snifferStatus": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی سرویس ردیابی",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("پورت Socks"),
    "sort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی"),
    "source": MessageLookupByLibrary.simpleMessage("منبع"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP مبدا"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("پروکسی ویژه"),
    "specialRules": MessageLookupByLibrary.simpleMessage("قوانین ویژه"),
    "spinningLines": MessageLookupByLibrary.simpleMessage("خطوط چرخان"),
    "stackMode": MessageLookupByLibrary.simpleMessage("حالت پشته"),
    "standard": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "start": MessageLookupByLibrary.simpleMessage("شروع"),
    "startTest": MessageLookupByLibrary.simpleMessage("تست تاخیر"),
    "startVpn": MessageLookupByLibrary.simpleMessage("در حال شروع..."),
    "status": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت غیرفعال بودن از DNS سیستم استفاده می‌شود",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("توقف"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("در حال توقف..."),
    "storeFix": MessageLookupByLibrary.simpleMessage("ترمیم استور"),
    "storeFixDesc": MessageLookupByLibrary.simpleMessage(
      "رفع مشکلات دانلود Google Play Store",
    ),
    "strictRoute": MessageLookupByLibrary.simpleMessage("مسیریابی سخت‌گیرانه"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از حالت مسیریابی سخت‌گیرانه TUN",
    ),
    "style": MessageLookupByLibrary.simpleMessage("سبک"),
    "subRule": MessageLookupByLibrary.simpleMessage("زیرقانون"),
    "submit": MessageLookupByLibrary.simpleMessage("ارسال"),
    "success": MessageLookupByLibrary.simpleMessage("موفقیت‌آمیز"),
    "switchLabel": MessageLookupByLibrary.simpleMessage("کلید"),
    "switchToDomesticIp": MessageLookupByLibrary.simpleMessage(
      "دریافت IP داخلی",
    ),
    "sync": MessageLookupByLibrary.simpleMessage("همگام‌سازی"),
    "syncAll": MessageLookupByLibrary.simpleMessage("همگام‌سازی همه"),
    "syncFailed": MessageLookupByLibrary.simpleMessage("همگام‌سازی ناموفق بود"),
    "system": MessageLookupByLibrary.simpleMessage("سیستم"),
    "systemApp": MessageLookupByLibrary.simpleMessage("برنامه‌های سیستم"),
    "systemFont": MessageLookupByLibrary.simpleMessage("فونت سیستم"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("پروکسی سیستم"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات پروکسی سیستم",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("زبانه"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("اتصال همزمان TCP"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه به اتصال‌های همزمان TCP",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("آدرس تست"),
    "textScale": MessageLookupByLibrary.simpleMessage("مقیاس متن"),
    "theme": MessageLookupByLibrary.simpleMessage("پوسته"),
    "themeColor": MessageLookupByLibrary.simpleMessage("رنگ پوسته"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات رنگ و آیکون پوسته",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("حالت پوسته"),
    "threeBounce": MessageLookupByLibrary.simpleMessage("جهش سه گانه"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("۳ ستون"),
    "threeInOut": MessageLookupByLibrary.simpleMessage("سه دایره"),
    "tight": MessageLookupByLibrary.simpleMessage("فشرده"),
    "time": MessageLookupByLibrary.simpleMessage("زمان"),
    "tip": MessageLookupByLibrary.simpleMessage("راهنما"),
    "titleTooLong": MessageLookupByLibrary.simpleMessage(
      "عنوان بیش از حد طولانی است (حداکثر ۲۰ کاراکتر)",
    ),
    "tlsPortSniffer": MessageLookupByLibrary.simpleMessage("اسنیف پورت TLS"),
    "toggle": MessageLookupByLibrary.simpleMessage("تغییر"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("تونال اسپات"),
    "tooManyRules": MessageLookupByLibrary.simpleMessage(
      "حداکثر ۵ قانون مجاز است",
    ),
    "tools": MessageLookupByLibrary.simpleMessage("ابزارها"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("مجموع ترافیک"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("پورت Tproxy"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("مصرف ترافیک"),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("ارتقای منوی سینی"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "مدیریت گروه‌ها از منوی راست‌کلیک تسک‌بار",
    ),
    "trayIconInvert": MessageLookupByLibrary.simpleMessage(
      "معکوس‌سازی آیکون تسک‌بار",
    ),
    "trayIconInvertDesc": MessageLookupByLibrary.simpleMessage(
      "معکوس کردن رنگ آیکون تسک‌بار",
    ),
    "tryManualRefresh": MessageLookupByLibrary.simpleMessage(
      "لطفاً به صورت دستی بروزرسانی کنید",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("کارت شبکه مجازی (TUN)"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "مدیریت تمام ترافیک دستگاه با حالت TUN",
    ),
    "tunEnableRequireAdmin": MessageLookupByLibrary.simpleMessage(
      "استفاده از حالت TUN نیازمند دسترسی Admin یا ROOT است",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("تونل"),
    "tunnelAddress": MessageLookupByLibrary.simpleMessage("آدرس گوش به زنگ"),
    "tunnelAddressHint": MessageLookupByLibrary.simpleMessage(
      "مثال: 127.0.0.1:6553",
    ),
    "tunnelDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از تونل هدایت ترافیک",
    ),
    "tunnelList": MessageLookupByLibrary.simpleMessage("لیست هدایت‌ها"),
    "tunnelNetwork": MessageLookupByLibrary.simpleMessage("پروتکل شبکه"),
    "tunnelNetworkHint": MessageLookupByLibrary.simpleMessage("مثال: tcp, udp"),
    "tunnelProxy": MessageLookupByLibrary.simpleMessage("نام پروکسی"),
    "tunnelProxyHint": MessageLookupByLibrary.simpleMessage(
      "مثال: proxy (اختیاری)",
    ),
    "tunnelTarget": MessageLookupByLibrary.simpleMessage("آدرس مقصد"),
    "tunnelTargetHint": MessageLookupByLibrary.simpleMessage(
      "مثال: 114.114.114.114:53",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("۲ ستون"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "امکان بروزرسانی پروفایل فعلی وجود ندارد",
    ),
    "unauthorized": MessageLookupByLibrary.simpleMessage("احراز هویت نشده"),
    "undo": MessageLookupByLibrary.simpleMessage("واکشی"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("تاخیر یکپارچه"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "حذف تاخیرهای اضافی دست‌تکانی",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("نامشخص"),
    "unnamed": MessageLookupByLibrary.simpleMessage("بدون نام"),
    "update": MessageLookupByLibrary.simpleMessage("بروزرسانی"),
    "upload": MessageLookupByLibrary.simpleMessage("آپلود"),
    "url": MessageLookupByLibrary.simpleMessage("آدرس URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "دریافت پروفایل از طریق آدرس URL",
    ),
    "urlTip": m13,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "استفاده از اسکریپت اورراید سراسری",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("استفاده از Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "استفاده از Hosts سیستم",
    ),
    "value": MessageLookupByLibrary.simpleMessage("مقدار"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("پررنگ"),
    "view": MessageLookupByLibrary.simpleMessage("مشاهده"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("تنظیمات مربوط به VPN"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "هدایت ترافیک سیستم از طریق VpnService",
    ),
    "vpnSystemProxyConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از پروکسی HTTP در موبایل پیشنهاد نمی‌شود مگر در صورت نیاز",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "افزودن پروکسی HTTP به VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "تغییرات پس از راه‌اندازی مجدد VPN اعمال می‌شود",
    ),
    "wakelock": MessageLookupByLibrary.simpleMessage("قفل روشن ماندن صفحه"),
    "wakelockDescription": MessageLookupByLibrary.simpleMessage(
      "جلوگیری از خاموش شدن خودکار صفحه نمایش برای فعال ماندن برنامه‌ها در پس‌زمینه.",
    ),
    "wave": MessageLookupByLibrary.simpleMessage("موج"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "تنظیمات WebDAV",
    ),
    "whitelist": MessageLookupByLibrary.simpleMessage("لیست سفید"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سفید"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("اعمال به سیستم"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "نیازمند دسترسی مدیریت (Admin)",
    ),
    "years": m14,
  };
}
