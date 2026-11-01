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

  static String m0(log) => "تحلیل گزارش Bettbox (Mihomo): ${log}";

  static String m1(error) => "پشتیبان‌گیری خودکار ناموفق بود: ${error}";

  static String m2(value) => "میانگین ${value}";

  static String m3(count) => "${Intl.plural(count, other: '# روز')}";

  static String m4(label) => "آیا از حذف موارد انتخاب شده اطمینان دارید؟";

  static String m5(label) => "آیا از حذف ${label} اطمینان دارید؟";

  static String m6(reason) => "Fake-IP · ${reason}: IP واقعی";

  static String m7(reason, range) =>
      "Fake-IP · ${reason}: آدرس مجازی از ${range}";

  static String m8(ips) => "تطبیق با Hosts: ${ips}";

  static String m9(outbound) =>
      "از طریق «${outbound}»، گره دامنه را تفکیک می‌کند";

  static String m10(outbound) =>
      "از طریق «${outbound}»، گره دامنه را تفکیک می‌کند؛ Hosts اعمال نمی‌شود";

  static String m11(label) => "${label} نمی‌تواند خالی باشد";

  static String m12(label) => "${label} از قبل وجود دارد";

  static String m13(count) => "${Intl.plural(count, other: '# ساعت')}";

  static String m14(port) =>
      "پورت ${port} در حال استفاده است؛ پورت دیگری انتخاب کنید";

  static String m15(code) => "سرور آزمون را رد کرد (خطای ${code})";

  static String m16(lost, total) => "${lost}/${total} بسته";

  static String m17(name) => "اسکن شد: ${name}";

  static String m18(value) => "${value} ثانیه";

  static String m19(port) => "در حال گوش دادن روی پورت ${port}";

  static String m20(count) => "${count} جریان";

  static String m21(count) => "${count}";

  static String m22(count) => "${count} بایت";

  static String m23(address) => "از ${address}";

  static String m24(count) =>
      "فقط ${count} مورد آخر نمایش داده می‌شود. برای دیدن همه، نتیجه را کپی کنید";

  static String m25(min, avg, max, jitter) =>
      "زمان رفت‌وبرگشت: کمینه ${min} / میانگین ${avg} / بیشینه ${max} / لرزش ${jitter} ms";

  static String m26(target) => "آمار Ping برای ${target}";

  static String m27(sent, received, lost, loss) =>
      "ارسال ${sent}، دریافت ${received}، از دست رفته ${lost} (${loss}٪ افت)";

  static String m28(level) =>
      "حالت ${level} برای اشکال‌زدایی شبکه مناسب است؛ در استفاده روزمره آن را خاموش کنید";

  static String m29(done, total, unlocked) =>
      "${done}/${total} بررسی شد · ${unlocked} در دسترس";

  static String m30(count) => "${Intl.plural(count, other: '# دقیقه')}";

  static String m31(count) => "${Intl.plural(count, other: '# ماه')}";

  static String m32(count) => "${count} مورد";

  static String m33(ip) => "از طریق ${ip}";

  static String m34(count) => "${count} گزارش جدید";

  static String m35(label) => "هیچ مورد ${label} یافت نشد";

  static String m36(min, max) => "یک عدد صحیح بین ${min} تا ${max} وارد کنید";

  static String m37(label) => "${label} باید عدد باشد";

  static String m38(label) => "فقط ${label}";

  static String m39(label) =>
      "${label} باید بین ۱۰۲۴ تا ۴۹۱۵۱ باشد (۰ برای غیرفعال)";

  static String m40(statusCode) =>
      "خطا در دریافت پروفایل. لطفاً شبکه خود را بررسی کرده یا لینک را ریست کنید ( کد خطا: ${statusCode} )";

  static String m41(index, time) => "تفکیک با قانون #${index} · ${time} ms";

  static String m42(ips) => "تطبیق Hosts: ${ips}";

  static String m43(total, index) => "${total} قانون، تطبیق با #${index}";

  static String m44(total) => "${total} قانون";

  static String m45(count) => "${count} مورد انتخاب شده";

  static String m46(count) =>
      "حالت چندرشته از ${count} اتصال موازی برای اشباع پهنای باند استفاده می‌کند";

  static String m47(provider) =>
      "ممکن است خروجی تست سرعت ${provider} را مسدود کند. منبع تست یا خروجی را تغییر دهید.";

  static String m48(protocol, fallback) =>
      "${protocol} در دسترس نیست، به ${fallback} بازگشت";

  static String m49(count) => "${count} اتصال";

  static String m50(provider) => "تغییر به ${provider}";

  static String m51(online, total) => "${online} / ${total} آنلاین";

  static String m52(region) => "رله ${region}";

  static String m53(label) => "${label} باید یک URL معتبر باشد";

  static String m54(count) => "${Intl.plural(count, other: '# سال')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("درباره"),
    "accessControl": MessageLookupByLibrary.simpleMessage("کنترل دسترسی"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "تنها برنامه‌های انتخاب شده از VPN عبور کنند",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "لیست سفید و سیاه دسترسی برنامه‌ها",
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
    "activeGoroutines": MessageLookupByLibrary.simpleMessage("Goroutines"),
    "add": MessageLookupByLibrary.simpleMessage("افزودن"),
    "addProfile": MessageLookupByLibrary.simpleMessage("افزودن پروفایل"),
    "addRule": MessageLookupByLibrary.simpleMessage("افزودن قانون"),
    "addTunnel": MessageLookupByLibrary.simpleMessage("افزودن هدایت"),
    "addUser": MessageLookupByLibrary.simpleMessage("افزودن کاربر"),
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
    "ageCipherText": MessageLookupByLibrary.simpleMessage(
      "متن رمز (-----BEGIN AGE ENCRYPTED FILE-----)",
    ),
    "ageDecryptFailed": MessageLookupByLibrary.simpleMessage(
      "رمزگشایی ناموفق بود",
    ),
    "ageEncryptFailed": MessageLookupByLibrary.simpleMessage(
      "رمزنگاری ناموفق بود",
    ),
    "ageFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "فایل بیش از حد بزرگ است (حداکثر ۸ مگابایت)",
    ),
    "ageGenerateKeyPair": MessageLookupByLibrary.simpleMessage("جفت‌کلید جدید"),
    "ageInputRequired": MessageLookupByLibrary.simpleMessage(
      "محتوا وارد کنید یا فایلی انتخاب کنید",
    ),
    "ageKeyGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "تولید کلید Age",
    ),
    "ageKeyHybridTip": MessageLookupByLibrary.simpleMessage(
      "کلید ترکیبی پساکوانتومی؛ امن‌تر است، اما کلید عمومی بسیار طولانی‌تر است و به age نسخهٔ ۱٫۳ یا بالاتر نیاز دارد.",
    ),
    "ageKeyPairGeneratedSuccess": MessageLookupByLibrary.simpleMessage(
      "جفت کلید X25519 با موفقیت ساخته شد. لطفاً آن را ذخیره کنید",
    ),
    "ageKeyType": MessageLookupByLibrary.simpleMessage("نوع کلید"),
    "ageNotEncrypted": MessageLookupByLibrary.simpleMessage(
      "محتوا با Age رمزنگاری نشده است",
    ),
    "ageOutput": MessageLookupByLibrary.simpleMessage("نتیجه"),
    "agePlainText": MessageLookupByLibrary.simpleMessage("متن ساده"),
    "agePrivateKeyLabel": MessageLookupByLibrary.simpleMessage(
      "کلید خصوصی Age",
    ),
    "agePrivateKeyRequired": MessageLookupByLibrary.simpleMessage(
      "لطفا ابتدا کلید خصوصی Age صحیح را وارد کنید",
    ),
    "agePublicKeyLabel": MessageLookupByLibrary.simpleMessage("کلید عمومی Age"),
    "ageRecipientRequired": MessageLookupByLibrary.simpleMessage(
      "دست‌کم یک کلید عمومی وارد کنید",
    ),
    "ageRecipients": MessageLookupByLibrary.simpleMessage(
      "کلیدهای عمومی گیرندگان",
    ),
    "ageRecipientsHint": MessageLookupByLibrary.simpleMessage(
      "چند کلید age1… مجاز است، هر خط یکی",
    ),
    "ageSecretKeyInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید خصوصی معتبری وارد کنید (باید با -AGE-SECRET-KEY شروع شود)",
    ),
    "ageSecretKeyOptional": MessageLookupByLibrary.simpleMessage(
      "کلید خصوصی Age (اختیاری)",
    ),
    "ageTabDecrypt": MessageLookupByLibrary.simpleMessage("رمزگشایی"),
    "ageTabEncrypt": MessageLookupByLibrary.simpleMessage("رمزنگاری"),
    "ageTabKeys": MessageLookupByLibrary.simpleMessage("کلیدها"),
    "ageTool": MessageLookupByLibrary.simpleMessage("رمزنگاری و رمزگشایی Age"),
    "ageToolDesc": MessageLookupByLibrary.simpleMessage(
      "ساخت کلید، رمزنگاری و رمزگشایی متن و پیکربندی",
    ),
    "ageToolTip": MessageLookupByLibrary.simpleMessage(
      "همه‌چیز به‌صورت محلی انجام می‌شود و کلید خصوصی ذخیره یا ارسال نمی‌شود.",
    ),
    "ageUseForEncrypt": MessageLookupByLibrary.simpleMessage(
      "استفاده برای رمزنگاری",
    ),
    "ageUseProfileKey": MessageLookupByLibrary.simpleMessage(
      "استفاده از کلید پیکربندی فعلی",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("قبل"),
    "agree": MessageLookupByLibrary.simpleMessage("موافقم"),
    "allApps": MessageLookupByLibrary.simpleMessage("همه برنامه‌ها"),
    "allocatedMemory": MessageLookupByLibrary.simpleMessage("تخصیص‌یافته"),
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
      "نمایش همیشگی دکمه‌های نوار عنوان",
    ),
    "analyzeLogPrompt": m0,
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
    "autoBackup": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری خودکار"),
    "autoBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری خودکار هنگام تغییر پروفایل‌ها",
    ),
    "autoBackupFailed": m1,
    "autoBackupSuccess": MessageLookupByLibrary.simpleMessage(
      "پشتیبان خودکار در WebDAV ذخیره شد",
    ),
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
    "autoScroll": MessageLookupByLibrary.simpleMessage("پیمایش خودکار"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "تنظیم خودکار DNS سیستم",
    ),
    "autoStickyHeader": MessageLookupByLibrary.simpleMessage(
      "چسبندگی خودکار سربرگ",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("بروزرسانی خودکار"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "فاصله بروزرسانی خودکار (دقیقه)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("بازگشت"),
    "backup": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری و بازیابی",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی داده‌ها از طریق WebDAV یا محلی",
    ),
    "backupEncryptedTip": MessageLookupByLibrary.simpleMessage(
      "پشتیبان با AES-256 رمزگذاری شد",
    ),
    "backupPassword": MessageLookupByLibrary.simpleMessage("رمز عبور پشتیبان"),
    "backupPasswordDesc": MessageLookupByLibrary.simpleMessage(
      "رمزنگاری AES-256 (خالی برای بدون رمز)",
    ),
    "backupPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "این پشتیبان رمزگذاری شده است، لطفاً رمز عبور را وارد کنید",
    ),
    "backupPasswordTip": MessageLookupByLibrary.simpleMessage(
      "فقط حروف انگلیسی، اعداد و نمادها پشتیبانی می‌شوند",
    ),
    "backupPasswordWrong": MessageLookupByLibrary.simpleMessage(
      "رمز عبور پشتیبان نادرست است",
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
    "blockComment": MessageLookupByLibrary.simpleMessage("کامنت"),
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
    "categoryAi": MessageLookupByLibrary.simpleMessage("AI"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("همه"),
    "categoryChina": MessageLookupByLibrary.simpleMessage("مستقیم چین"),
    "categoryCrypto": MessageLookupByLibrary.simpleMessage("ارز دیجیتال"),
    "categoryDeveloper": MessageLookupByLibrary.simpleMessage("توسعه‌دهندگان"),
    "categoryGaming": MessageLookupByLibrary.simpleMessage("مرکز بازی"),
    "categorySocial": MessageLookupByLibrary.simpleMessage(
      "پلتفرم‌های اجتماعی",
    ),
    "categoryStreaming": MessageLookupByLibrary.simpleMessage("رسانه‌های جاری"),
    "chasingDots": MessageLookupByLibrary.simpleMessage("نقاط تعقیب‌کننده"),
    "checkError": MessageLookupByLibrary.simpleMessage("بررسی ناموفق بود"),
    "checkFailed": MessageLookupByLibrary.simpleMessage("Timeout"),
    "checkOrAddProfile": MessageLookupByLibrary.simpleMessage(
      "لطفاً ابتدا یک پروفایل اضافه کنید",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("بررسی بروزرسانی"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "شما از آخرین نسخه استفاده می‌کنید",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("در حال بررسی..."),
    "circle": MessageLookupByLibrary.simpleMessage("حلقه"),
    "clear": MessageLookupByLibrary.simpleMessage("پاک کردن"),
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
    "clearFilter": MessageLookupByLibrary.simpleMessage("پاک کردن فیلترها"),
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
    "close": MessageLookupByLibrary.simpleMessage("بستن"),
    "closeAll": MessageLookupByLibrary.simpleMessage("بستن همه"),
    "collapse": MessageLookupByLibrary.simpleMessage("جمع کردن"),
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
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "کنترل ازدحام",
    ),
    "connection": MessageLookupByLibrary.simpleMessage("اتصال فعال"),
    "connections": MessageLookupByLibrary.simpleMessage("اتصالات"),
    "connectionsActive": MessageLookupByLibrary.simpleMessage("فعال"),
    "connectionsClosed": MessageLookupByLibrary.simpleMessage("بسته‌شده"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده اتصالات فعال و بسته‌شده",
    ),
    "connectionsSort": MessageLookupByLibrary.simpleMessage(
      "مرتب‌سازی اتصال‌ها",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("وضعیت اتصال:"),
    "contactMe": MessageLookupByLibrary.simpleMessage("تماس با ما"),
    "content": MessageLookupByLibrary.simpleMessage("محتوا"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("پوسته محتوا"),
    "continent": MessageLookupByLibrary.simpleMessage("قاره"),
    "controlSecret": MessageLookupByLibrary.simpleMessage("رمز عبور کنترل"),
    "controlSecretDesc": MessageLookupByLibrary.simpleMessage(
      "رمز عبور دسترسی به RESTful API",
    ),
    "copiedPackageName": MessageLookupByLibrary.simpleMessage(
      "نام پکیج کپی شد",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "در کلیپ‌بورد کپی شد",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("کپی"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("کپی متغیرهای محیطی"),
    "copyLink": MessageLookupByLibrary.simpleMessage("کپی لینک"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("با موفقیت کپی شد"),
    "core": MessageLookupByLibrary.simpleMessage("هسته"),
    "coreCapabilityNotEffective": MessageLookupByLibrary.simpleMessage(
      "مجوز هسته اعمال نشد: هسته در حال اجرا CAP_NET_ADMIN ندارد و TUN ممکن است کار نکند",
    ),
    "coreConnected": MessageLookupByLibrary.simpleMessage("متصل شد"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("اطلاعات هسته"),
    "coreMountNosuid": MessageLookupByLibrary.simpleMessage(
      "هسته روی سیستم فایلی با گزینه nosuid قرار دارد، بنابراین قابلیت‌های فایل و setuid اعمال نمی‌شوند",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("وضعیت هسته"),
    "coreSuspended": MessageLookupByLibrary.simpleMessage("معلق شد"),
    "country": MessageLookupByLibrary.simpleMessage("منطقه"),
    "countryOrRegion": MessageLookupByLibrary.simpleMessage("کشور / منطقه"),
    "crashTest": MessageLookupByLibrary.simpleMessage("تست خرابی"),
    "create": MessageLookupByLibrary.simpleMessage("ایجاد"),
    "creationTime": MessageLookupByLibrary.simpleMessage("زمان ایجاد"),
    "cubeGrid": MessageLookupByLibrary.simpleMessage("شبکه مکعب‌ها"),
    "custom": MessageLookupByLibrary.simpleMessage("سفارشی"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "عنوان سفارشی",
    ),
    "customScriptOptions": MessageLookupByLibrary.simpleMessage(
      "قوانین سفارشی",
    ),
    "customUrl": MessageLookupByLibrary.simpleMessage("آدرس URL سفارشی"),
    "cut": MessageLookupByLibrary.simpleMessage("برش"),
    "dancingSquare": MessageLookupByLibrary.simpleMessage("مربع رقصان"),
    "dark": MessageLookupByLibrary.simpleMessage("تاریک"),
    "darkIcon": MessageLookupByLibrary.simpleMessage("آیکون تاریک"),
    "darkIconDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر آیکون برنامه به تم تاریک",
    ),
    "dashboard": MessageLookupByLibrary.simpleMessage("داشبورد"),
    "dashboardAverage": m2,
    "dashboardTotal": MessageLookupByLibrary.simpleMessage("مجموع"),
    "days": m3,
    "defaultGateway": MessageLookupByLibrary.simpleMessage("گیت‌وی"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "سرور نام پیش‌فرض",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "تحلیل سرورهای DNS",
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
    "deleteMultipTip": m4,
    "deleteTip": m5,
    "deleteTunnel": MessageLookupByLibrary.simpleMessage("حذف هدایت"),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Bettbox به‌صورت عمیق بر پایه هسته قدرتمند و انعطاف‌پذیر Mihomo ساخته شده و بر ارائه تجربه کلاینت بهتر متمرکز است. چشم‌انداز ما: Connecting Open Source and AI, Accelerating Innovation",
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
      "فعالسازی تبدیل IP4P شماره‌گیر",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("مستقیم"),
    "directNameserver": MessageLookupByLibrary.simpleMessage("DNS مستقیم"),
    "directNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "تحلیل دامنه‌های اتصال مستقیم",
    ),
    "directNameserverFollowPolicy": MessageLookupByLibrary.simpleMessage(
      "DNS مستقیم از سیاست پیروی کند",
    ),
    "disableQuic": MessageLookupByLibrary.simpleMessage("غیرفعال‌سازی QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC برای رفع مشکلات شبکه",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("غیرفعال"),
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
    "dnsQuery": MessageLookupByLibrary.simpleMessage("جستجوی DNS"),
    "dnsQueryCompare": MessageLookupByLibrary.simpleMessage("مقایسه"),
    "dnsQueryCompareDesc": MessageLookupByLibrary.simpleMessage(
      "تفکیک هم‌زمان با قوانین، DNS سیستم و سرور منتخب برای یافتن آلودگی یا تفاوت مسیریابی",
    ),
    "dnsQueryDesc": MessageLookupByLibrary.simpleMessage(
      "تفکیک با قوانین، سیستم یا سرور دلخواه",
    ),
    "dnsQueryFakeIpOff": m6,
    "dnsQueryFakeIpOn": m7,
    "dnsQueryFilterBlackHit": MessageLookupByLibrary.simpleMessage(
      "در لیست سیاه",
    ),
    "dnsQueryFilterBlackMiss": MessageLookupByLibrary.simpleMessage(
      "خارج از لیست سیاه",
    ),
    "dnsQueryFilterRuleFake": MessageLookupByLibrary.simpleMessage(
      "قانون: fake-ip",
    ),
    "dnsQueryFilterRuleReal": MessageLookupByLibrary.simpleMessage(
      "قانون: real-ip",
    ),
    "dnsQueryFilterWhiteHit": MessageLookupByLibrary.simpleMessage(
      "در لیست سفید",
    ),
    "dnsQueryFilterWhiteMiss": MessageLookupByLibrary.simpleMessage(
      "خارج از لیست سفید",
    ),
    "dnsQueryHint": MessageLookupByLibrary.simpleMessage("دامنه"),
    "dnsQueryHostsHit": m8,
    "dnsQueryNoRecords": MessageLookupByLibrary.simpleMessage(
      "رکوردی وجود ندارد",
    ),
    "dnsQueryNormalMode": MessageLookupByLibrary.simpleMessage(
      "Normal: IP واقعی، تطبیق قوانین با IP",
    ),
    "dnsQueryRedirHost": MessageLookupByLibrary.simpleMessage(
      "Redir-Host: IP واقعی، دامنه هنگام اتصال بازیابی می‌شود",
    ),
    "dnsQueryServer": MessageLookupByLibrary.simpleMessage("سرور DNS"),
    "dnsQueryServerHint": MessageLookupByLibrary.simpleMessage(
      "مثلاً 1.1.1.1، https://cloudflare-dns.com/dns-query",
    ),
    "dnsQueryServerInvalid": MessageLookupByLibrary.simpleMessage(
      "قالب سرور DNS نامعتبر است",
    ),
    "dnsQueryStopped": MessageLookupByLibrary.simpleMessage(
      "پروکسی اجرا نیست؛ «پیروی از قوانین» در دسترس نیست",
    ),
    "dnsQuerySystem": MessageLookupByLibrary.simpleMessage("DNS سیستم"),
    "dnsQueryViaDirect": MessageLookupByLibrary.simpleMessage(
      "DIRECT، هسته به‌صورت محلی تفکیک و مستقیم وصل می‌شود",
    ),
    "dnsQueryViaDirectHosts": MessageLookupByLibrary.simpleMessage(
      "DIRECT، اتصال مستقیم به آدرس Hosts",
    ),
    "dnsQueryViaProxy": m9,
    "dnsQueryViaProxyHosts": m10,
    "dnsQueryViaReject": MessageLookupByLibrary.simpleMessage(
      "رد شده توسط قوانین",
    ),
    "dnsResolution": MessageLookupByLibrary.simpleMessage("تفکیک DNS"),
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
    "dualRing": MessageLookupByLibrary.simpleMessage("حلقه دوتایی"),
    "edit": MessageLookupByLibrary.simpleMessage("ویرایش"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("ویرایش هدایت"),
    "editUser": MessageLookupByLibrary.simpleMessage("ویرایش کاربر"),
    "emptyTip": m11,
    "enableCrashReport": MessageLookupByLibrary.simpleMessage("تحلیل خرابی‌ها"),
    "enableCrashReportDesc": MessageLookupByLibrary.simpleMessage(
      "ارسال گزارش خرابی در صورت لزوم",
    ),
    "enableOverride": MessageLookupByLibrary.simpleMessage("فعالسازی اورراید"),
    "enableTraySpeed": MessageLookupByLibrary.simpleMessage("نمایش سرعت شبکه"),
    "enableTraySpeedDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش سرعت در نوار منو",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("فعال"),
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
      "مجاز ساختن QUIC چین به جای مسدودی کامل",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "پنهان کردن برنامه از لیست برنامه‌های اخیر",
    ),
    "existsTip": m12,
    "exit": MessageLookupByLibrary.simpleMessage("خروج"),
    "expand": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "experimental": MessageLookupByLibrary.simpleMessage("ویژگی‌های آزمایشی"),
    "experimentalDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات آزمایشی با احتیاط استفاده شود",
    ),
    "expirationTime": MessageLookupByLibrary.simpleMessage("تاریخ انقضا"),
    "expired": MessageLookupByLibrary.simpleMessage("منقضی شده"),
    "export": MessageLookupByLibrary.simpleMessage("خروجی"),
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
    "fadingCube": MessageLookupByLibrary.simpleMessage("مکعب محوشونده"),
    "fadingFour": MessageLookupByLibrary.simpleMessage("چهار دایره محوشونده"),
    "fadingGrid": MessageLookupByLibrary.simpleMessage("شبکه محوشونده"),
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
    "fast": MessageLookupByLibrary.simpleMessage("سریع"),
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
    "flagged": MessageLookupByLibrary.simpleMessage("نشانه‌گذاری‌شده"),
    "flushDnsOnNetworkChange": MessageLookupByLibrary.simpleMessage(
      "پاک‌سازی کش DNS",
    ),
    "flushDnsOnNetworkChangeDesc": MessageLookupByLibrary.simpleMessage(
      "پاک‌سازی کش DNS هنگام تغییر شبکه",
    ),
    "foldingCube": MessageLookupByLibrary.simpleMessage("مکعب تاشو"),
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
    "geoBuiltInResources": MessageLookupByLibrary.simpleMessage(
      "منابع داخلی GEO",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("داده‌های جغرافیایی"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "کاهش مصرف حافظه GEO",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از لودر کم‌مصرف داده‌های GEO",
    ),
    "geodataUse": MessageLookupByLibrary.simpleMessage("بارگذاری GEO"),
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
    "heapObjects": MessageLookupByLibrary.simpleMessage("Objects"),
    "highPriority": MessageLookupByLibrary.simpleMessage("اولویت بالا"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "افزایش اولویت پردازش برنامه و هسته",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage("نرخ نوسازی بالا"),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی حداکثر نرخ نوسازی",
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
    "hourGlass": MessageLookupByLibrary.simpleMessage("ساعت شنی"),
    "hours": m13,
    "httpPortSniffer": MessageLookupByLibrary.simpleMessage("اسنیف پورت HTTP"),
    "icmpForwarding": MessageLookupByLibrary.simpleMessage("هدایت ICMP"),
    "icmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبانی از پینگ ICMP در صورت فعال بودن",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("تصویر"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage("تنظیمات تصویر"),
    "iconConfigurationDesc": MessageLookupByLibrary.simpleMessage(
      "سفارشی‌سازی آیکون‌های ICON گروه پروکسی",
    ),
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
    "installTime": MessageLookupByLibrary.simpleMessage("زمان نصب"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "انتخاب هوشمند",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("اینترنت"),
    "interval": MessageLookupByLibrary.simpleMessage("فاصله زمانی"),
    "intranetAndGateway": MessageLookupByLibrary.simpleMessage(
      "شبکه محلی و گیت‌وی",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP شبکه محلی"),
    "invalidIpFormat": MessageLookupByLibrary.simpleMessage(
      "فرمت IP یا CIDR نامعتبر است",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("آدرس IP"),
    "ipClickBehavior": MessageLookupByLibrary.simpleMessage("تغییر نمایش"),
    "ipLookup": MessageLookupByLibrary.simpleMessage("جستجوی IP"),
    "ipLookupDesc": MessageLookupByLibrary.simpleMessage(
      "IP خروجی شما یا جستجوی هر IP یا دامنه",
    ),
    "ipLookupDomesticExit": MessageLookupByLibrary.simpleMessage(
      "IP محلی داخلی",
    ),
    "ipLookupHint": MessageLookupByLibrary.simpleMessage("IP یا دامنه"),
    "ipLookupInvalid": MessageLookupByLibrary.simpleMessage(
      "IP یا دامنه معتبر وارد کنید",
    ),
    "ipLookupLocal": MessageLookupByLibrary.simpleMessage("شبکه محلی"),
    "ipLookupMine": MessageLookupByLibrary.simpleMessage("IP من"),
    "ipLookupProxyExit": MessageLookupByLibrary.simpleMessage("IP گره پیش‌فرض"),
    "ipLookupResolveFailed": MessageLookupByLibrary.simpleMessage(
      "تفکیک این دامنه ممکن نشد",
    ),
    "ipLookupResult": MessageLookupByLibrary.simpleMessage("نتایج"),
    "ipPrivacyProtection": MessageLookupByLibrary.simpleMessage(
      "پنهان‌سازی IP",
    ),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP / ماسک"),
    "iperfAddressHint": MessageLookupByLibrary.simpleMessage(
      "نشانی سرور، مثلاً 192.168.1.5",
    ),
    "iperfAddressRequired": MessageLookupByLibrary.simpleMessage(
      "نشانی سرور را وارد کنید",
    ),
    "iperfAddresses": MessageLookupByLibrary.simpleMessage(
      "نشانی‌های این دستگاه",
    ),
    "iperfBandwidth": MessageLookupByLibrary.simpleMessage("نرخ ارسال"),
    "iperfBidir": MessageLookupByLibrary.simpleMessage("دوطرفه"),
    "iperfClient": MessageLookupByLibrary.simpleMessage("کلاینت"),
    "iperfCommands": MessageLookupByLibrary.simpleMessage("دستورهای iperf3"),
    "iperfConnecting": MessageLookupByLibrary.simpleMessage("در حال اتصال…"),
    "iperfDirection": MessageLookupByLibrary.simpleMessage("جهت"),
    "iperfDone": MessageLookupByLibrary.simpleMessage("آزمون تمام شد"),
    "iperfDuration": MessageLookupByLibrary.simpleMessage("مدت"),
    "iperfErrorBusy": MessageLookupByLibrary.simpleMessage(
      "سرور مشغول آزمون دیگری است. بعداً دوباره تلاش کنید",
    ),
    "iperfErrorInterrupted": MessageLookupByLibrary.simpleMessage(
      "آزمون قطع شد",
    ),
    "iperfErrorListen": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی سرور ممکن نشد",
    ),
    "iperfErrorPortInUse": m14,
    "iperfErrorProtocol": MessageLookupByLibrary.simpleMessage(
      "پاسخ نامعتبر است؛ ممکن است طرف مقابل سرور iPerf3 نباشد",
    ),
    "iperfErrorRefused": MessageLookupByLibrary.simpleMessage(
      "اتصال رد شد. مطمئن شوید سرور iPerf3 در حال اجراست",
    ),
    "iperfErrorServer": m15,
    "iperfErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "زمان اتصال تمام شد. نشانی و شبکه را بررسی کنید",
    ),
    "iperfErrorUdp": MessageLookupByLibrary.simpleMessage(
      "دست‌دهی UDP ناموفق بود؛ شاید دیوارهٔ آتش آن را مسدود کرده باشد",
    ),
    "iperfErrorUnreachable": MessageLookupByLibrary.simpleMessage(
      "دسترسی به سرور ممکن نیست",
    ),
    "iperfFirewallTip": MessageLookupByLibrary.simpleMessage(
      "اگر دستگاه‌های دیگر نمی‌توانند وصل شوند، اتصال‌های ورودی هستهٔ Bettbox را در دیوارهٔ آتش سیستم مجاز کنید.",
    ),
    "iperfLostPackets": m16,
    "iperfNoAddress": MessageLookupByLibrary.simpleMessage(
      "نشانی شبکهٔ محلی یافت نشد. از اتصال Wi-Fi یا شبکهٔ سیمی مطمئن شوید",
    ),
    "iperfParallel": MessageLookupByLibrary.simpleMessage("جریان‌ها"),
    "iperfPeer": MessageLookupByLibrary.simpleMessage("طرف مقابل"),
    "iperfPort": MessageLookupByLibrary.simpleMessage("پورت"),
    "iperfPortInvalid": MessageLookupByLibrary.simpleMessage(
      "پورتی بین ۱ تا ۶۵۵۳۵ وارد کنید",
    ),
    "iperfProtocol": MessageLookupByLibrary.simpleMessage("پروتکل"),
    "iperfReady": MessageLookupByLibrary.simpleMessage(
      "نشانی سرور را وارد کنید یا کد QR را اسکن کنید",
    ),
    "iperfReceive": MessageLookupByLibrary.simpleMessage("دریافت"),
    "iperfResult": MessageLookupByLibrary.simpleMessage("نتیجه"),
    "iperfRetest": MessageLookupByLibrary.simpleMessage("آزمون دوباره"),
    "iperfRetransmits": MessageLookupByLibrary.simpleMessage("ارسال مجدد"),
    "iperfRtt": MessageLookupByLibrary.simpleMessage("تأخیر رفت‌وبرگشت"),
    "iperfRunning": MessageLookupByLibrary.simpleMessage("در حال آزمون"),
    "iperfScan": MessageLookupByLibrary.simpleMessage("اسکن برای اتصال"),
    "iperfScanHint": MessageLookupByLibrary.simpleMessage(
      "با Bettbox در دستگاه دیگر اسکن کنید تا با یک لمس وصل شوید",
    ),
    "iperfScanInvalid": MessageLookupByLibrary.simpleMessage(
      "این کد QR اتصال iPerf3 نیست",
    ),
    "iperfScanned": m17,
    "iperfSeconds": m18,
    "iperfSend": MessageLookupByLibrary.simpleMessage("ارسال"),
    "iperfServer": MessageLookupByLibrary.simpleMessage("سرور"),
    "iperfServerListening": m19,
    "iperfServerOff": MessageLookupByLibrary.simpleMessage("سرور اجرا نمی‌شود"),
    "iperfServerOffHint": MessageLookupByLibrary.simpleMessage(
      "پس از راه‌اندازی، دستگاه‌های دیگر با اسکن کد QR یا وارد کردن نشانی این دستگاه وصل می‌شوند",
    ),
    "iperfServerStart": MessageLookupByLibrary.simpleMessage("راه‌اندازی سرور"),
    "iperfServerStop": MessageLookupByLibrary.simpleMessage("توقف سرور"),
    "iperfServerTip": MessageLookupByLibrary.simpleMessage(
      "سرور فقط وقتی این صفحه باز است اجرا می‌شود و با خروج متوقف می‌شود. در این مدت صفحه روشن می‌ماند.",
    ),
    "iperfStart": MessageLookupByLibrary.simpleMessage("شروع آزمون"),
    "iperfStreams": m20,
    "iperfTest": MessageLookupByLibrary.simpleMessage("ابزار iPerf3"),
    "iperfTestDesc": MessageLookupByLibrary.simpleMessage(
      "اندازه‌گیری پهنای باند بین دستگاه‌های شبکهٔ محلی، سازگار با iperf3",
    ),
    "iperfThroughput": MessageLookupByLibrary.simpleMessage("سرعت"),
    "iperfTransferred": MessageLookupByLibrary.simpleMessage("حجم"),
    "iperfUdpUnavailable": MessageLookupByLibrary.simpleMessage(
      "پورت UDP در حال استفاده است؛ فقط آزمون TCP ممکن است.",
    ),
    "iperfWaiting": MessageLookupByLibrary.simpleMessage(
      "در انتظار اتصال کلاینت",
    ),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "دریافت ترافیک IPv6 فعال باشد",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "ورودی IPv6 مجاز باشد",
    ),
    "isp": MessageLookupByLibrary.simpleMessage("ارائه‌دهنده اینترنت"),
    "itemsCount": m21,
    "just": MessageLookupByLibrary.simpleMessage("همین الان"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "فاصله زمانی TCP Keep-Alive",
    ),
    "keepDockIcon": MessageLookupByLibrary.simpleMessage("نمایش دائمی در Dock"),
    "keepDockIconDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش آیکون برنامه در Dock",
    ),
    "key": MessageLookupByLibrary.simpleMessage("کلید"),
    "lanSharing": MessageLookupByLibrary.simpleMessage(
      "اشتراک‌گذاری در شبکه محلی",
    ),
    "language": MessageLookupByLibrary.simpleMessage("زبان"),
    "lastEdit": MessageLookupByLibrary.simpleMessage("آخرین ویرایش"),
    "layout": MessageLookupByLibrary.simpleMessage("چیدمان"),
    "leftClickBehavior": MessageLookupByLibrary.simpleMessage("کلیک چپ"),
    "light": MessageLookupByLibrary.simpleMessage("روشن"),
    "limitedUnlock": MessageLookupByLibrary.simpleMessage("فقط اختصاصی"),
    "lineWrap": MessageLookupByLibrary.simpleMessage("شکستن خطوط"),
    "list": MessageLookupByLibrary.simpleMessage("فهرست"),
    "listen": MessageLookupByLibrary.simpleMessage("شنود"),
    "local": MessageLookupByLibrary.simpleMessage("محلی"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری داده‌ها در فایل محلی",
    ),
    "localFile": MessageLookupByLibrary.simpleMessage("فایل محلی"),
    "localPing": MessageLookupByLibrary.simpleMessage("Ping محلی"),
    "localPingAverage": MessageLookupByLibrary.simpleMessage("میانگین"),
    "localPingBytes": m22,
    "localPingClosed": MessageLookupByLibrary.simpleMessage("درگاه بسته است"),
    "localPingCount": MessageLookupByLibrary.simpleMessage("تعداد"),
    "localPingDesc": MessageLookupByLibrary.simpleMessage(
      "آزمون مستقیم تأخیر و افت بسته با ICMP، TCP و UDP",
    ),
    "localPingDone": MessageLookupByLibrary.simpleMessage("Ping تمام شد"),
    "localPingErrorDenied": MessageLookupByLibrary.simpleMessage(
      "این سیستم اجازه ارسال ICMP نمی‌دهد. از Ping با TCP یا UDP استفاده کنید",
    ),
    "localPingErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "ارسال بسته‌های Ping ممکن نیست",
    ),
    "localPingErrorResolve": MessageLookupByLibrary.simpleMessage(
      "دامنه پیدا نشد",
    ),
    "localPingFailed": MessageLookupByLibrary.simpleMessage("ارسال ناموفق"),
    "localPingFrom": m23,
    "localPingGateway": MessageLookupByLibrary.simpleMessage("دروازه"),
    "localPingListLimit": m24,
    "localPingMax": MessageLookupByLibrary.simpleMessage("بیشینه"),
    "localPingMin": MessageLookupByLibrary.simpleMessage("کمینه"),
    "localPingReady": MessageLookupByLibrary.simpleMessage(
      "یک مقصد انتخاب کنید و شروع کنید",
    ),
    "localPingReceived": MessageLookupByLibrary.simpleMessage("دریافت‌شده"),
    "localPingResolving": MessageLookupByLibrary.simpleMessage(
      "در حال یافتن نشانی",
    ),
    "localPingResult": MessageLookupByLibrary.simpleMessage("نتیجه Ping"),
    "localPingRttSummary": m25,
    "localPingRunning": MessageLookupByLibrary.simpleMessage("در حال Ping"),
    "localPingSent": MessageLookupByLibrary.simpleMessage("ارسال‌شده"),
    "localPingSize": MessageLookupByLibrary.simpleMessage("اندازه بسته"),
    "localPingStart": MessageLookupByLibrary.simpleMessage("شروع Ping"),
    "localPingStats": m26,
    "localPingSummary": m27,
    "localPingTargetHint": MessageLookupByLibrary.simpleMessage(
      "دامنه یا نشانی IP",
    ),
    "localPingTcpTip": MessageLookupByLibrary.simpleMessage(
      "Ping با TCP زمان برقراری اتصال را می‌سنجد. رد شدن اتصال هم یعنی میزبان در دسترس است",
    ),
    "localPingTimeout": MessageLookupByLibrary.simpleMessage(
      "پایان مهلت درخواست",
    ),
    "localPingUdpTip": MessageLookupByLibrary.simpleMessage(
      "درگاه ۵۳ یک پرس‌وجوی DNS می‌فرستد و منتظر پاسخ می‌ماند. بیشتر درگاه‌های دیگر پاسخ نمی‌دهند، پس پایان مهلت به معنای قطع بودن نیست",
    ),
    "localPingUnreachable": MessageLookupByLibrary.simpleMessage(
      "مقصد در دسترس نیست",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از فایل محلی",
    ),
    "locate": MessageLookupByLibrary.simpleMessage("موقعیت"),
    "log": MessageLookupByLibrary.simpleMessage("گزارش"),
    "logAiSearch": MessageLookupByLibrary.simpleMessage("جستجوی هوش مصنوعی"),
    "logLevel": MessageLookupByLibrary.simpleMessage("سطح گزارش"),
    "logLevelDebugHint": m28,
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
    "loopbackProtection": MessageLookupByLibrary.simpleMessage(
      "محافظت در برابر لوپ‌بک",
    ),
    "loopbackProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "مسدودسازی لوپ‌بک ناشی از خطای شبکه",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("باز"),
    "manualRefreshIp": MessageLookupByLibrary.simpleMessage("دریافت مجدد IP"),
    "maximize": MessageLookupByLibrary.simpleMessage("بزرگ کردن"),
    "mediaBatchAll": MessageLookupByLibrary.simpleMessage("همهٔ نودها"),
    "mediaBatchAllDesc": MessageLookupByLibrary.simpleMessage(
      "همهٔ نودها به‌جز DIRECT",
    ),
    "mediaBatchGroup": MessageLookupByLibrary.simpleMessage("تست"),
    "mediaBatchNoNodes": MessageLookupByLibrary.simpleMessage(
      "نودی برای آزمون وجود ندارد",
    ),
    "mediaBatchScope": MessageLookupByLibrary.simpleMessage(
      "انتخاب محدودهٔ آزمون",
    ),
    "mediaBatchSummary": m29,
    "mediaBatchTest": MessageLookupByLibrary.simpleMessage("آزمون گروهی نودها"),
    "mediaUnlock": MessageLookupByLibrary.simpleMessage("تست اتصال"),
    "mediaUnlockColorfulIcons": MessageLookupByLibrary.simpleMessage(
      "نمایش آیکون‌های رنگی به‌صورت پیش‌فرض",
    ),
    "mediaUnlockDetails": MessageLookupByLibrary.simpleMessage(
      "جزئیات تست اتصال",
    ),
    "mediaUnlockDisplaySettings": MessageLookupByLibrary.simpleMessage(
      "تنظیمات نمایش",
    ),
    "mediaUnlockExtraDetails": MessageLookupByLibrary.simpleMessage(
      "نمایش جزئیات بیشتر IP",
    ),
    "mediaUnlockMiscSettings": MessageLookupByLibrary.simpleMessage(
      "تنظیمات متفرقه",
    ),
    "mediaUnlockMoreStreamingPlatforms": MessageLookupByLibrary.simpleMessage(
      "موارد بیشتر آنلاک استریم",
    ),
    "mediaUnlockPinnedSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "پین کردن حداکثر ۳ مورد در ویجت",
    ),
    "mediaUnlockRefreshByCategory": MessageLookupByLibrary.simpleMessage(
      "تازه‌سازی جزئی بر اساس دسته‌بندی فعلی",
    ),
    "mediaUnlockRefreshOnNodeChange": MessageLookupByLibrary.simpleMessage(
      "به‌روزرسانی خودکار هنگام تغییر گره",
    ),
    "mediaUnlockSelectLimit": MessageLookupByLibrary.simpleMessage(
      "حداکثر می‌توانید ۳ مورد را انتخاب کنید",
    ),
    "mediaUnlocked": MessageLookupByLibrary.simpleMessage("قفل‌گشایی شده"),
    "memoryAndRuntime": MessageLookupByLibrary.simpleMessage(
      "حافظه و زمان اجرا",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("اطلاعات حافظه"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "مقادیر حافظه نشان داده شده صرفاً مربوط به حافظه دینامیک هسته بوده و تمام حافظه برنامه نیست (جهت اطلاع).",
    ),
    "messageTest": MessageLookupByLibrary.simpleMessage("تست پیام"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "این یک پیام تستی است.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("حداقل"),
    "minimize": MessageLookupByLibrary.simpleMessage("کوچک کردن"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "مینیمایز هنگام خروج",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر رفتار پیش‌فرض بستن پنجره",
    ),
    "minutes": m30,
    "mixedPort": MessageLookupByLibrary.simpleMessage("پورت ترکیبی (Mixed)"),
    "mode": MessageLookupByLibrary.simpleMessage("حالت"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("تک‌رنگ"),
    "months": m31,
    "more": MessageLookupByLibrary.simpleMessage("بیشتر"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage("اطلاعات بیشتر IP"),
    "mrsCopyRawLink": MessageLookupByLibrary.simpleMessage(
      "کپی به‌صورت لینک GitHub Raw",
    ),
    "mrsLookup": MessageLookupByLibrary.simpleMessage("جستجوی MRS"),
    "mrsLookupDesc": MessageLookupByLibrary.simpleMessage(
      "یافتن مجموعه‌های GEODATA / RULE-SET برای دامنه یا IP",
    ),
    "mrsLookupHint": MessageLookupByLibrary.simpleMessage("دامنه یا IP"),
    "mrsMissing": MessageLookupByLibrary.simpleMessage(
      "BundleMRS داخلی پیدا نشد",
    ),
    "mrsNoMatch": MessageLookupByLibrary.simpleMessage(
      "هیچ مجموعه‌ای تطبیق نیافت",
    ),
    "mrsPrepareFailed": MessageLookupByLibrary.simpleMessage(
      "بارگذاری مجموعه قوانین ناموفق بود",
    ),
    "mrsReferenced": MessageLookupByLibrary.simpleMessage(
      "در پیکربندی استفاده شده",
    ),
    "mrsResolveDns": MessageLookupByLibrary.simpleMessage(
      "تفکیک دامنه با قوانین DNS",
    ),
    "mrsResolveDnsDesc": MessageLookupByLibrary.simpleMessage(
      "در حالت روشن، دامنه با تنظیمات فعلی DNS به IP تفکیک می‌شود و آن IP هم تطبیق داده می‌شود",
    ),
    "mrsRules": m32,
    "mrsVia": m33,
    "name": MessageLookupByLibrary.simpleMessage("نام"),
    "nameSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس نام"),
    "nameserver": MessageLookupByLibrary.simpleMessage("سرور نام (Nameserver)"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("تحلیل دامنه‌ها"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("سیاست سرور نام"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "تعیین سیاست DNS برای دامنه‌ها",
    ),
    "natCopyResult": MessageLookupByLibrary.simpleMessage("کپی نتیجه"),
    "natDescBlocked": MessageLookupByLibrary.simpleMessage(
      "پاسخ STUN دریافت نشد؛ ممکن است UDP توسط فایروال، ISP یا نود خروجی مسدود شده باشد.",
    ),
    "natDescCone": MessageLookupByLibrary.simpleMessage(
      "بیشتر برنامه‌های P2P و بازی‌های آنلاین به‌درستی کار می‌کنند. این سرور نمی‌تواند دقیقاً مشخص کند کدام یک از NAT1 تا 3 است؛ برای نتیجهٔ دقیق‌تر سرور دیگری را امتحان کنید.",
    ),
    "natDescFullCone": MessageLookupByLibrary.simpleMessage(
      "NAT1: هر میزبان خارجی می‌تواند متصل شود؛ بهترین حالت برای P2P، بازی و تماس صوتی.",
    ),
    "natDescOpen": MessageLookupByLibrary.simpleMessage(
      "NAT وجود ندارد و دیگران مستقیم به شما دسترسی دارند؛ ایده‌آل برای P2P و بازی.",
    ),
    "natDescPortRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT3: فقط همان آدرس و پورتی که با آن ارتباط گرفته‌اید پاسخ می‌دهد؛ برخی P2P و بازی‌ها به رله نیاز دارند.",
    ),
    "natDescRestricted": MessageLookupByLibrary.simpleMessage(
      "NAT2: فقط آدرس‌هایی که با آن‌ها ارتباط گرفته‌اید می‌توانند پاسخ دهند؛ بیشتر P2P و بازی‌ها کار می‌کنند.",
    ),
    "natDescSymmetric": MessageLookupByLibrary.simpleMessage(
      "NAT4: برای هر مقصد پورت متفاوتی نگاشت می‌شود؛ اتصال مستقیم P2P دشوار است و معمولاً رله لازم است.",
    ),
    "natDescUnknown": MessageLookupByLibrary.simpleMessage(
      "تعیین نوع NAT ممکن نشد.",
    ),
    "natErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "اتصال به سرور STUN ممکن نشد",
    ),
    "natErrorUnsupported": MessageLookupByLibrary.simpleMessage(
      "خروجی انتخاب‌شده از UDP پشتیبانی نمی‌کند",
    ),
    "natExternalIp": MessageLookupByLibrary.simpleMessage("IP خارجی"),
    "natExternalPort": MessageLookupByLibrary.simpleMessage("پورت خارجی"),
    "natFiltering": MessageLookupByLibrary.simpleMessage("رفتار فیلتر"),
    "natLocalIp": MessageLookupByLibrary.simpleMessage("IP محلی"),
    "natMapping": MessageLookupByLibrary.simpleMessage("رفتار نگاشت"),
    "natMappingAddress": MessageLookupByLibrary.simpleMessage("وابسته به آدرس"),
    "natMappingAddressPort": MessageLookupByLibrary.simpleMessage(
      "وابسته به آدرس و پورت",
    ),
    "natMappingDependent": MessageLookupByLibrary.simpleMessage(
      "وابسته به مقصد",
    ),
    "natMappingIndependent": MessageLookupByLibrary.simpleMessage(
      "مستقل از مقصد",
    ),
    "natPhaseBinding": MessageLookupByLibrary.simpleMessage("اتصال"),
    "natPhaseFiltering": MessageLookupByLibrary.simpleMessage("فیلتر"),
    "natPhaseMapping": MessageLookupByLibrary.simpleMessage("نگاشت"),
    "natPortPreserve": MessageLookupByLibrary.simpleMessage("حفظ پورت"),
    "natPreserved": MessageLookupByLibrary.simpleMessage("حفظ می‌شود"),
    "natProxyTip": MessageLookupByLibrary.simpleMessage(
      "هنگام استفاده از پروکسی، نتیجه مربوط به NAT سمت نود خروجی است، نه شبکه محلی شما.",
    ),
    "natRandomized": MessageLookupByLibrary.simpleMessage("تصادفی"),
    "natReady": MessageLookupByLibrary.simpleMessage(
      "برای شروع دکمه زیر را بزنید",
    ),
    "natResult": MessageLookupByLibrary.simpleMessage("نتیجه تشخیص"),
    "natRetest": MessageLookupByLibrary.simpleMessage("تشخیص مجدد"),
    "natServer": MessageLookupByLibrary.simpleMessage("سرور STUN"),
    "natServerCustom": MessageLookupByLibrary.simpleMessage("سرور سفارشی"),
    "natServerHint": MessageLookupByLibrary.simpleMessage(
      "میزبان:پورت، مثلاً stun.example.com:3478",
    ),
    "natServerInvalid": MessageLookupByLibrary.simpleMessage(
      "میزبان:پورت معتبر وارد کنید",
    ),
    "natStart": MessageLookupByLibrary.simpleMessage("شروع تشخیص"),
    "natTest": MessageLookupByLibrary.simpleMessage("تشخیص NAT"),
    "natTestDesc": MessageLookupByLibrary.simpleMessage(
      "بررسی نوع NAT، آدرس خارجی و اتصال UDP",
    ),
    "natType": MessageLookupByLibrary.simpleMessage("نوع NAT"),
    "natTypeBlocked": MessageLookupByLibrary.simpleMessage("UDP مسدود است"),
    "natTypeCone": MessageLookupByLibrary.simpleMessage("Cone NAT"),
    "natTypeFullCone": MessageLookupByLibrary.simpleMessage("Full Cone NAT"),
    "natTypeOpen": MessageLookupByLibrary.simpleMessage("اتصال مستقیم عمومی"),
    "natTypePortRestricted": MessageLookupByLibrary.simpleMessage(
      "Port Restricted Cone NAT",
    ),
    "natTypeRestricted": MessageLookupByLibrary.simpleMessage(
      "Restricted Cone NAT",
    ),
    "natTypeSymmetric": MessageLookupByLibrary.simpleMessage("Symmetric NAT"),
    "natTypeUnknown": MessageLookupByLibrary.simpleMessage("نامشخص"),
    "navBarHapticFeedback": MessageLookupByLibrary.simpleMessage(
      "بازخورد حرکتی",
    ),
    "navBarHapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "انیمیشن و بازخورد لمسی نوار ناوبری پایین",
    ),
    "navConnections": MessageLookupByLibrary.simpleMessage("اتصالات"),
    "navTools": MessageLookupByLibrary.simpleMessage("ابزارها"),
    "network": MessageLookupByLibrary.simpleMessage("شبکه"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("تغییر تنظیمات شبکه"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("تست شبکه"),
    "networkErrorRetryLater": MessageLookupByLibrary.simpleMessage(
      "خطای شبکه، لطفاً بعداً دوباره امتحان کنید",
    ),
    "networkFix": MessageLookupByLibrary.simpleMessage("ترمیم شبکه"),
    "networkFixDesc": MessageLookupByLibrary.simpleMessage(
      "رفع مشکل آیکون کره زمین شبکه سیستم",
    ),
    "networkMatch": MessageLookupByLibrary.simpleMessage("تطبیق شبکه"),
    "networkMatchHint": MessageLookupByLibrary.simpleMessage(
      "IP یا CIDR یا Gateway:IP/CIDR",
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
    "newLogsCount": m34,
    "noAnimation": MessageLookupByLibrary.simpleMessage("پیش‌فرض"),
    "noBackupFileFound": MessageLookupByLibrary.simpleMessage(
      "فایل پشتیبان پیدا نشد",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("داده‌ای موجود نیست"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("بدون کلید میانبر"),
    "noIcon": MessageLookupByLibrary.simpleMessage("بدون آیکون"),
    "noInfo": MessageLookupByLibrary.simpleMessage("اطلاعاتی موجود نیست"),
    "noMatchedLogs": MessageLookupByLibrary.simpleMessage(
      "گزارشی مطابق فیلتر یافت نشد",
    ),
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
    "noUsageData": MessageLookupByLibrary.simpleMessage("بدون آمار مصرف"),
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
    "notUnlocked": MessageLookupByLibrary.simpleMessage("مسدود"),
    "notificationHighPriority": MessageLookupByLibrary.simpleMessage(
      "اولویت بالا",
    ),
    "notificationHighPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "اعلان با اولویت بالا در پیش‌زمینه",
    ),
    "notificationHighPriorityTip": MessageLookupByLibrary.simpleMessage(
      "اعلان‌های با اولویت بالا می‌توانند مشکلات زنده نگه داشتن پس‌زمینه را در برخی سیستم‌ها کاهش دهند. اگر سرویس شما به درستی کار می‌کند، پیشنهاد می‌شود خاموش بماند. آیا فعال شود؟",
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
    "nullTip": m35,
    "numberRangeInvalid": m36,
    "numberTip": m37,
    "oneColumn": MessageLookupByLibrary.simpleMessage("۱ ستون"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("پنل آنلاین"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("فقط آیکون"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "فقط برنامه‌های جانبی",
    ),
    "onlyShow": m38,
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "آمار ترافیک پروکسی",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "محاسبه ترافیک فقط برای پروکسی‌ها",
    ),
    "openDashboard": MessageLookupByLibrary.simpleMessage("باز کردن Zashboard"),
    "openRouterAdmin": MessageLookupByLibrary.simpleMessage("باز کردن گیت‌وی"),
    "openSettings": MessageLookupByLibrary.simpleMessage("باز کردن تنظیمات"),
    "operatorOrAsn": MessageLookupByLibrary.simpleMessage("سازمان / ASN"),
    "options": MessageLookupByLibrary.simpleMessage("گزینه‌ها"),
    "organizationDomain": MessageLookupByLibrary.simpleMessage(
      "سازمان / دامنه",
    ),
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
    "pianoWave": MessageLookupByLibrary.simpleMessage("موج پیانو"),
    "pin": MessageLookupByLibrary.simpleMessage("پین"),
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
    "portTip": m39,
    "pouringHourGlass": MessageLookupByLibrary.simpleMessage("ساعت شنی روان"),
    "pouringHourGlassRefined": MessageLookupByLibrary.simpleMessage(
      "ساعت شنی ظریف",
    ),
    "powerSwitch": MessageLookupByLibrary.simpleMessage("کلید روشن/خاموش"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "اولویت استفاده از HTTP/3 در DoH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید را فشار دهید",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
    "privateIp": MessageLookupByLibrary.simpleMessage(
      "آدرس IP خصوصی / شبکه محلی",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("پروفایل"),
    "profileAndRules": MessageLookupByLibrary.simpleMessage("پروفایل و قوانین"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "لطفاً فرمت زمان معتبری وارد کنید",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("لطفاً فاصله زمانی را وارد کنید"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "پروفایل تغییر یافته است. آیا بروزرسانی خودکار غیرفعال شود؟",
    ),
    "profileImportFailed": m40,
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
    "provinceAndCity": MessageLookupByLibrary.simpleMessage("استان / شهر"),
    "proxies": MessageLookupByLibrary.simpleMessage("پروکسی‌ها"),
    "proxiesCount": MessageLookupByLibrary.simpleMessage("گره‌های پروکسی"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("تنظیمات پروکسی"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("زنجیره پروکسی"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("گروه پروکسی"),
    "proxyGroupsCount": MessageLookupByLibrary.simpleMessage("گروه‌های پروکسی"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("DNS پروکسی"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "تحلیل دامنه‌های پروکسی",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("پورت پروکسی"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم پورت گوش به زنگ Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان پروکسی",
    ),
    "proxyProvidersCount": MessageLookupByLibrary.simpleMessage(
      "مجموعه پروکسی",
    ),
    "pulse": MessageLookupByLibrary.simpleMessage("پالس"),
    "pulsingGrid": MessageLookupByLibrary.simpleMessage("شبکه تپنده"),
    "pumpingHeart": MessageLookupByLibrary.simpleMessage("قلب تپنده"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("حالت مشکی خالص"),
    "qrcode": MessageLookupByLibrary.simpleMessage("کد QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "اسکن کد QR برای وارد کردن پروفایل",
    ),
    "quicGoDisableEcn": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC ECN",
    ),
    "quicGoDisableEcnDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی ECN در QUIC",
    ),
    "quicGoDisableGso": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC GSO",
    ),
    "quicGoDisableGsoDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی GSO در QUIC",
    ),
    "quicPortSniffer": MessageLookupByLibrary.simpleMessage("اسنیف پورت QUIC"),
    "quickResponse": MessageLookupByLibrary.simpleMessage("پاسخ سریع"),
    "quickResponseDesc": MessageLookupByLibrary.simpleMessage(
      "قطع فوری اتصال‌ها هنگام تغییر شبکه",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("رنگین‌کمان"),
    "realTimeSpeed": MessageLookupByLibrary.simpleMessage("سرعت لحظه‌ای"),
    "reclaimableMemory": MessageLookupByLibrary.simpleMessage("قابل بازیافت"),
    "recovery": MessageLookupByLibrary.simpleMessage("بازیابی"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("بازیابی تمام داده‌ها"),
    "recoveryDecryptedTip": MessageLookupByLibrary.simpleMessage(
      "با رمز عبور فعلی رمزگشایی و بازیابی شد",
    ),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "فقط بازیابی پروفایل‌ها",
    ),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "استراتژی بازیابی",
    ),
    "recoveryStrategyDesc_compatible": MessageLookupByLibrary.simpleMessage(
      "حفظ موارد موجود و ادغام بر اساس شناسه",
    ),
    "recoveryStrategyDesc_override": MessageLookupByLibrary.simpleMessage(
      "پاکسازی موارد فعلی و جایگزینی با پشتیبان",
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
    "relatedSettings": MessageLookupByLibrary.simpleMessage("تنظیمات مرتبط"),
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
    "reset": MessageLookupByLibrary.simpleMessage("بازنشانی"),
    "resetIconCache": MessageLookupByLibrary.simpleMessage(
      "بازنشانی حافظه پنهان آیکون‌ها",
    ),
    "resetIconCacheDesc": MessageLookupByLibrary.simpleMessage(
      "حافظه پنهان محلی آیکون‌ها بازنشانی شود؟ این کار ایمن است، زیرا برنامه دوباره آن‌ها را به‌طور خودکار از پیوندهای راه دور دریافت می‌کند.",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "آیا از بازنشانی اطمینان دارید؟",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("منابع خارجی"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده منابع خارجی یا مجموعه قوانین",
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
    "restore": MessageLookupByLibrary.simpleMessage("بازیابی"),
    "retry": MessageLookupByLibrary.simpleMessage("تلاش مجدد"),
    "rightClickBehavior": MessageLookupByLibrary.simpleMessage("کلیک راست"),
    "ring": MessageLookupByLibrary.simpleMessage("حلقه"),
    "ripple": MessageLookupByLibrary.simpleMessage("موج آب"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("چرخش تک‌دایره"),
    "rotatingPlain": MessageLookupByLibrary.simpleMessage("صفحه چرخان"),
    "routeTrace": MessageLookupByLibrary.simpleMessage("ردیابی مسیر"),
    "routeTraceChain": MessageLookupByLibrary.simpleMessage("زنجیره پروکسی"),
    "routeTraceCheckedRules": MessageLookupByLibrary.simpleMessage(
      "قوانین بررسی‌شده",
    ),
    "routeTraceDesc": MessageLookupByLibrary.simpleMessage(
      "روند DNS و تطبیق قوانین دامنه یا IP در هسته",
    ),
    "routeTraceDns": MessageLookupByLibrary.simpleMessage("تفکیک DNS"),
    "routeTraceDnsBy": m41,
    "routeTraceDnsIp": MessageLookupByLibrary.simpleMessage(
      "هدف IP است و نیازی به تفکیک نیست",
    ),
    "routeTraceDnsSkipped": MessageLookupByLibrary.simpleMessage(
      "در حین تطبیق نیازی به تفکیک IP نبود",
    ),
    "routeTraceFinal": MessageLookupByLibrary.simpleMessage("خروجی نهایی"),
    "routeTraceHint": MessageLookupByLibrary.simpleMessage("دامنه، IP یا آدرس"),
    "routeTraceHostsHit": m42,
    "routeTraceInput": MessageLookupByLibrary.simpleMessage("هدف"),
    "routeTraceModeDirect": MessageLookupByLibrary.simpleMessage(
      "حالت مستقیم: همه ترافیک مستقیم",
    ),
    "routeTraceModeGlobal": MessageLookupByLibrary.simpleMessage(
      "حالت سراسری: همه ترافیک از GLOBAL",
    ),
    "routeTraceNoMatch": MessageLookupByLibrary.simpleMessage(
      "هیچ قانونی تطبیق نیافت؛ DIRECT استفاده می‌شود",
    ),
    "routeTraceRules": MessageLookupByLibrary.simpleMessage("تطبیق قوانین"),
    "routeTraceRulesSummary": m43,
    "routeTraceRulesTotal": m44,
    "routeTraceSkipMissing": MessageLookupByLibrary.simpleMessage(
      "رد شد؛ مقصد پیدا نشد",
    ),
    "routeTraceSkipPass": MessageLookupByLibrary.simpleMessage(
      "رد شده با PASS",
    ),
    "routeTraceSkipUdp": MessageLookupByLibrary.simpleMessage(
      "رد شد؛ UDP پشتیبانی نمی‌شود",
    ),
    "routeTraceStopped": MessageLookupByLibrary.simpleMessage(
      "پروکسی اجرا نیست؛ ردیابی مسیر ممکن نیست",
    ),
    "routeTraceTrigger": MessageLookupByLibrary.simpleMessage("آغاز تفکیک DNS"),
    "routeTraceTruncated": MessageLookupByLibrary.simpleMessage(
      "فقط ۳۰۰۰ مورد نخست نمایش داده می‌شود",
    ),
    "routeTraceUdpUnsupported": MessageLookupByLibrary.simpleMessage(
      "این خروجی از UDP پشتیبانی نمی‌کند",
    ),
    "routeTraceViewRules": MessageLookupByLibrary.simpleMessage(
      "نمایش قوانین بررسی‌شده",
    ),
    "rule": MessageLookupByLibrary.simpleMessage("قوانین"),
    "ruleName": MessageLookupByLibrary.simpleMessage("نام قانون"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان قوانین",
    ),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage("مجموعه قوانین"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("مقصد قانون"),
    "rulesCount": MessageLookupByLibrary.simpleMessage("قوانین مسیریابی"),
    "runTime": MessageLookupByLibrary.simpleMessage("مدت زمان اجرا"),
    "runningMode": MessageLookupByLibrary.simpleMessage("حالت اجرا"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("پیکربندی زمان اجرا"),
    "save": MessageLookupByLibrary.simpleMessage("ذخیره"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "آیا تغییرات ذخیره شوند؟",
    ),
    "saveTip": MessageLookupByLibrary.simpleMessage(
      "آیا از ذخیره تغییرات اطمینان دارید؟",
    ),
    "script": MessageLookupByLibrary.simpleMessage("اسکریپت اورراید"),
    "scriptDesc": MessageLookupByLibrary.simpleMessage(
      "پیکربندی اسکریپت‌های اورراید JavaScript",
    ),
    "scriptOtherOptions": MessageLookupByLibrary.simpleMessage("تنظیمات دیگر"),
    "search": MessageLookupByLibrary.simpleMessage("جستجو"),
    "seconds": MessageLookupByLibrary.simpleMessage("ثانیه"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "رمز عبور در حافظه موقت کپی شد",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("انتخاب همه"),
    "selectBackupVersion": MessageLookupByLibrary.simpleMessage(
      "انتخاب نسخه پشتیبان",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("انتخاب شده"),
    "selectedCountTitle": m45,
    "serviceReady": MessageLookupByLibrary.simpleMessage("سرویس آماده است"),
    "serviceRunning": MessageLookupByLibrary.simpleMessage(
      "سرویس در حال اجرا است",
    ),
    "setcapFailedFallback": MessageLookupByLibrary.simpleMessage(
      "اعطای قابلیت‌های فایل ممکن نشد؛ به setuid بازگشت داده شد",
    ),
    "setcapNotInstalledFallback": MessageLookupByLibrary.simpleMessage(
      "setcap نصب نیست؛ به setuid بازگشت داده شد",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
    "sharedAddress": MessageLookupByLibrary.simpleMessage("آدرس اشتراکی"),
    "show": MessageLookupByLibrary.simpleMessage("نمایش"),
    "showHiddenItems": MessageLookupByLibrary.simpleMessage(
      "نمایش موارد پنهان",
    ),
    "showMenu": MessageLookupByLibrary.simpleMessage("باز کردن منو"),
    "showPanel": MessageLookupByLibrary.simpleMessage("نمایش پنجره"),
    "showStartSwitch": MessageLookupByLibrary.simpleMessage("دکمه کلید سوئیچ"),
    "showStartSwitchDesc": MessageLookupByLibrary.simpleMessage(
      "دکمه مستقل در صفحه اصلی",
    ),
    "shrink": MessageLookupByLibrary.simpleMessage("فشرده"),
    "sidebarFlyout": MessageLookupByLibrary.simpleMessage("پنل شناور"),
    "sidebarFlyoutDelay": MessageLookupByLibrary.simpleMessage("تأخیر نمایش"),
    "sidebarFlyoutDesc": MessageLookupByLibrary.simpleMessage(
      "نمایش کارت تنظیمات هنگام هاور نوار کناری",
    ),
    "sidebarFlyoutEntries": MessageLookupByLibrary.simpleMessage("موارد نمایش"),
    "sidebarFlyoutOutsideTools": MessageLookupByLibrary.simpleMessage(
      "نمایش فقط خارج از صفحه «ابزارها»",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("اجرای بی‌صدا"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "اجرا در پس‌زمینه بدون باز کردن پنجره",
    ),
    "size": MessageLookupByLibrary.simpleMessage("اندازه"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("دامنه‌های مستثنی"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("IP مقصد مستثنی"),
    "skipLocalAuth": MessageLookupByLibrary.simpleMessage(
      "رد شدن از احراز هویت محلی",
    ),
    "skipLocalAuthDesc": MessageLookupByLibrary.simpleMessage(
      "دسترسی بدون احراز هویت برای سیستم محلی",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("IP مبدا مستثنی"),
    "slow": MessageLookupByLibrary.simpleMessage("کند"),
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
    "speedTest": MessageLookupByLibrary.simpleMessage("تست سرعت"),
    "speedTestAgain": MessageLookupByLibrary.simpleMessage("تست مجدد"),
    "speedTestChangeOutbound": MessageLookupByLibrary.simpleMessage(
      "تغییر خروجی",
    ),
    "speedTestClearHistoryTip": MessageLookupByLibrary.simpleMessage(
      "همه تاریخچه تست پاک شود؟",
    ),
    "speedTestConnecting": MessageLookupByLibrary.simpleMessage("در حال اتصال"),
    "speedTestConnections": MessageLookupByLibrary.simpleMessage("اتصالات"),
    "speedTestConnectionsDesc": m46,
    "speedTestCoreStopped": MessageLookupByLibrary.simpleMessage(
      "فعال نیست · تست مستقیم",
    ),
    "speedTestCredit": MessageLookupByLibrary.simpleMessage(
      "سرورهای تست سرعت توسط اشخاص ثالث عمومی ارائه می‌شوند. سپاس ویژه از Apple، Cloudflare و Speedtest by Ookla.",
    ),
    "speedTestDataUsed": MessageLookupByLibrary.simpleMessage("داده مصرفی"),
    "speedTestDuration": MessageLookupByLibrary.simpleMessage("مدت تست"),
    "speedTestErrorBlocked": MessageLookupByLibrary.simpleMessage(
      "تست سرعت در دسترس نیست",
    ),
    "speedTestErrorBlockedDesc": m47,
    "speedTestErrorNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "در دسترس بودن خروجی را بررسی و دوباره تلاش کنید.",
    ),
    "speedTestErrorRejected": MessageLookupByLibrary.simpleMessage(
      "توسط قوانین مسدود شد",
    ),
    "speedTestErrorRejectedDesc": MessageLookupByLibrary.simpleMessage(
      "قوانین فعلی دامنه تست را به REJECT می‌فرستند. خروجی دیگری انتخاب کرده و دوباره تلاش کنید.",
    ),
    "speedTestErrorTimeout": MessageLookupByLibrary.simpleMessage(
      "زمان تست سرعت به پایان رسید",
    ),
    "speedTestErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "اتصال به سرویس تست ممکن نیست",
    ),
    "speedTestExitNode": MessageLookupByLibrary.simpleMessage("گره خروجی"),
    "speedTestFollowRules": MessageLookupByLibrary.simpleMessage("طبق قوانین"),
    "speedTestHistory": MessageLookupByLibrary.simpleMessage("تاریخچه تست"),
    "speedTestHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "هنوز تاریخچه‌ای وجود ندارد",
    ),
    "speedTestHistoryRetention": MessageLookupByLibrary.simpleMessage(
      "۱۴ روز نگهداری می‌شود",
    ),
    "speedTestJitter": MessageLookupByLibrary.simpleMessage("جیتر"),
    "speedTestLoadedLatency": MessageLookupByLibrary.simpleMessage(
      "تأخیر تحت بار",
    ),
    "speedTestManual": MessageLookupByLibrary.simpleMessage("دستی"),
    "speedTestMobileDataTip": MessageLookupByLibrary.simpleMessage(
      "در حال استفاده از داده همراه هستید. هر تست ممکن است صدها مگابایت مصرف کند. ادامه می‌دهید؟",
    ),
    "speedTestMultiThread": MessageLookupByLibrary.simpleMessage("چندرشته"),
    "speedTestOutbound": MessageLookupByLibrary.simpleMessage("خروجی"),
    "speedTestPacketLoss": MessageLookupByLibrary.simpleMessage("افت بسته"),
    "speedTestProbing": MessageLookupByLibrary.simpleMessage(
      "در حال شناسایی خروجی…",
    ),
    "speedTestProtocol": MessageLookupByLibrary.simpleMessage("پروتکل"),
    "speedTestProtocolDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP/3 روی QUIC (UDP) اجرا می‌شود؛ اگر در دسترس نباشد به HTTP/2 و اگر HTTP/2 هم نباشد به HTTP/1.1 بازمی‌گردد",
    ),
    "speedTestProtocolFallback": m48,
    "speedTestQuality": MessageLookupByLibrary.simpleMessage("کیفیت شبکه"),
    "speedTestReady": MessageLookupByLibrary.simpleMessage("آماده"),
    "speedTestRealtime": MessageLookupByLibrary.simpleMessage("سرعت لحظه‌ای"),
    "speedTestResponsiveness": MessageLookupByLibrary.simpleMessage("پاسخگویی"),
    "speedTestRoute": MessageLookupByLibrary.simpleMessage("قانون مسیریابی"),
    "speedTestServer": MessageLookupByLibrary.simpleMessage("سرور تست"),
    "speedTestServerAutoDesc": MessageLookupByLibrary.simpleMessage(
      "انتخاب خودکار سرور Speedtest",
    ),
    "speedTestSettings": MessageLookupByLibrary.simpleMessage("تنظیمات تست"),
    "speedTestSingleThread": MessageLookupByLibrary.simpleMessage("تک‌رشته"),
    "speedTestStart": MessageLookupByLibrary.simpleMessage("شروع تست"),
    "speedTestStreams": m49,
    "speedTestSwitchProvider": m50,
    "speedTestUseSystemDns": MessageLookupByLibrary.simpleMessage(
      "تفکیک با DNS سیستم",
    ),
    "speedTestUseSystemDnsDesc": MessageLookupByLibrary.simpleMessage(
      "با فعال‌سازی، سرور تست سرعت انتخاب‌شده همیشه با DNS سیستم تفکیک می‌شود که در برخی موارد مفید است",
    ),
    "spinningCircle": MessageLookupByLibrary.simpleMessage("دایره چرخان"),
    "spinningLines": MessageLookupByLibrary.simpleMessage("خطوط چرخان"),
    "squareCircle": MessageLookupByLibrary.simpleMessage("مربع و دایره"),
    "stackMode": MessageLookupByLibrary.simpleMessage("حالت پشته"),
    "standard": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "start": MessageLookupByLibrary.simpleMessage("شروع"),
    "startSwitchOffLabel": MessageLookupByLibrary.simpleMessage(
      "متن حالت خاموش",
    ),
    "startSwitchOnLabel": MessageLookupByLibrary.simpleMessage("متن حالت روشن"),
    "startSwitchOutlined": MessageLookupByLibrary.simpleMessage("حاشیه‌دار"),
    "startSwitchPersonalized": MessageLookupByLibrary.simpleMessage(
      "نمایش شخصی‌سازی‌شده",
    ),
    "startSwitchStyle": MessageLookupByLibrary.simpleMessage("سبک"),
    "startSwitchTonal": MessageLookupByLibrary.simpleMessage("رنگی ملایم"),
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
    "syncDelayAnimation": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی انیمیشن با صفحات دیگر",
    ),
    "syncFailed": MessageLookupByLibrary.simpleMessage("همگام‌سازی ناموفق بود"),
    "system": MessageLookupByLibrary.simpleMessage("سیستم"),
    "systemApp": MessageLookupByLibrary.simpleMessage("برنامه‌های سیستم"),
    "systemDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "systemFont": MessageLookupByLibrary.simpleMessage("فونت سیستم"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("پروکسی سیستم"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات پروکسی سیستم",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("زبانه"),
    "tailscale": MessageLookupByLibrary.simpleMessage("Tailscale"),
    "tailscaleAcceptRoutes": MessageLookupByLibrary.simpleMessage(
      "پذیرش مسیرهای زیرشبکه",
    ),
    "tailscaleAcceptRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از مسیرهای زیرشبکه اعلام‌شده در tailnet",
    ),
    "tailscaleAddNetwork": MessageLookupByLibrary.simpleMessage("افزودن شبکه"),
    "tailscaleAuthKey": MessageLookupByLibrary.simpleMessage("کلید احراز هویت"),
    "tailscaleAuthKeyDesc": MessageLookupByLibrary.simpleMessage(
      "اختیاری؛ بدون آن از «ورود» (SSO/OIDC) استفاده کنید",
    ),
    "tailscaleConnected": MessageLookupByLibrary.simpleMessage("متصل"),
    "tailscaleControlUrl": MessageLookupByLibrary.simpleMessage("سرور کنترل"),
    "tailscaleControlUrlDesc": MessageLookupByLibrary.simpleMessage(
      "خالی یعنی Tailscale. برای Headscale نشانی URL را وارد کنید",
    ),
    "tailscaleDeleteNetwork": MessageLookupByLibrary.simpleMessage("حذف شبکه"),
    "tailscaleDesc": MessageLookupByLibrary.simpleMessage(
      "ارسال دامنه‌ها و IPهای انتخابی از طریق tailnet",
    ),
    "tailscaleDevices": MessageLookupByLibrary.simpleMessage("دستگاه‌ها"),
    "tailscaleDns": MessageLookupByLibrary.simpleMessage("DNS شبکه tailnet"),
    "tailscaleDnsDesc": MessageLookupByLibrary.simpleMessage(
      "دامنه‌هایی که سرور DNS داخل tailnet آن‌ها را resolve می‌کند: دامنه=سرور (مثلاً corp.example.com=10.1.0.53). زیرشبکه‌های مقصد را به فهرست مسیریابی اضافه کنید",
    ),
    "tailscaleEnable": MessageLookupByLibrary.simpleMessage(
      "فعال‌سازی Tailscale",
    ),
    "tailscaleEnableDesc": MessageLookupByLibrary.simpleMessage(
      "پیوستن به tailnet با گره داخلی Tailscale",
    ),
    "tailscaleExitNode": MessageLookupByLibrary.simpleMessage("گره خروجی"),
    "tailscaleExitNodeDesc": MessageLookupByLibrary.simpleMessage(
      "نام یا IP دستگاه در tailnet، یا auto:any. برای سایت‌های عمومی لازم است",
    ),
    "tailscaleExitNodeLan": MessageLookupByLibrary.simpleMessage(
      "اجازه دسترسی به LAN",
    ),
    "tailscaleExitNodeLanDesc": MessageLookupByLibrary.simpleMessage(
      "دسترسی به شبکه محلی هنگام استفاده از گره خروجی",
    ),
    "tailscaleHostname": MessageLookupByLibrary.simpleMessage("نام دستگاه"),
    "tailscaleInvalidDns": MessageLookupByLibrary.simpleMessage(
      "از قالب دامنه=سرور استفاده کنید؛ سرور یک IP یا نشانی tls:// / https:// باشد، مثلاً corp.example.com=10.1.0.53",
    ),
    "tailscaleInvalidEntry": MessageLookupByLibrary.simpleMessage(
      "یک دامنه، IP یا CIDR وارد کنید",
    ),
    "tailscaleLoggedIn": MessageLookupByLibrary.simpleMessage(
      "ورود به Tailscale انجام شد",
    ),
    "tailscaleLogin": MessageLookupByLibrary.simpleMessage("ورود"),
    "tailscaleLoginDesc": MessageLookupByLibrary.simpleMessage(
      "ورود در مرورگر با SSO/OIDC شبکه tailnet، بدون نیاز به کلید احراز هویت",
    ),
    "tailscaleLoginNeeded": MessageLookupByLibrary.simpleMessage(
      "Tailscale نیاز به ورود دارد",
    ),
    "tailscaleNeedsApproval": MessageLookupByLibrary.simpleMessage(
      "در انتظار تأیید این دستگاه توسط مدیر",
    ),
    "tailscaleNetwork": MessageLookupByLibrary.simpleMessage("شبکه"),
    "tailscaleNetworks": MessageLookupByLibrary.simpleMessage("شبکه‌ها"),
    "tailscaleNotStarted": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی نشده",
    ),
    "tailscaleNotStartedDesc": MessageLookupByLibrary.simpleMessage(
      "در اولین استفاده راه‌اندازی می‌شود؛ برای راه‌اندازی ضربه بزنید",
    ),
    "tailscaleNotes": MessageLookupByLibrary.simpleMessage(
      "• گره داخلی: Bettbox خودش به tailnet می‌پیوندد و به برنامه Tailscale نیازی نیست. فقط ترافیک فهرست مسیریابی و Tailnet DNS از آن عبور می‌کند.\n• فقط در حالت قانون: حالت‌های سراسری و مستقیم این قوانین را نادیده می‌گیرند.\n• از نام کامل مانند host.tailnet.ts.net استفاده کنید؛ نام‌های کوتاه مانند nas resolve نمی‌شوند.\n• زیرشبکه‌ها: آن‌ها را به فهرست مسیریابی اضافه کنید و «پذیرش مسیرهای زیرشبکه» را روشن کنید. در دسکتاپ بدون TUN، زیرشبکه‌های خصوصی (10.x، 172.16–31.x، 192.168.x) از پروکسی سیستم عبور نمی‌کنند.\n• برای دسترسی به سایت‌های عمومی از طریق tailnet به گره خروجی نیاز است.\n• آدرس‌های IPv6 شبکه tailnet به روشن بودن IPv6 نیاز دارند.\n• گره در اولین استفاده راه‌اندازی می‌شود. پیوند ورود فقط وقتی Bettbox باز است نمایش داده می‌شود.\n• Android: تغییرات فهرست مسیریابی پس از راه‌اندازی دوباره VPN اعمال می‌شوند.",
    ),
    "tailscaleNotesTitle": MessageLookupByLibrary.simpleMessage("توضیحات"),
    "tailscaleOnlineCount": m51,
    "tailscaleRelay": m52,
    "tailscaleReset": MessageLookupByLibrary.simpleMessage("بازنشانی گره"),
    "tailscaleResetDesc": MessageLookupByLibrary.simpleMessage(
      "حذف هویت tailnet این دستگاه و پیوستن به‌عنوان دستگاه جدید؛ دستگاه قبلی را در کنسول مدیریت حذف کنید",
    ),
    "tailscaleRoutes": MessageLookupByLibrary.simpleMessage("فهرست مسیریابی"),
    "tailscaleRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "دامنه‌ها و IP/CIDRهایی که در حالت قانون از Tailscale عبور می‌کنند. زیرشبکه‌های خصوصی در دسکتاپ به TUN نیاز دارند",
    ),
    "tailscaleStarting": MessageLookupByLibrary.simpleMessage(
      "در حال راه‌اندازی Tailscale…",
    ),
    "tailscaleSubnetRoutes": MessageLookupByLibrary.simpleMessage(
      "مسیرهای زیرشبکه",
    ),
    "tailscaleThisDevice": MessageLookupByLibrary.simpleMessage("این دستگاه"),
    "tailscaleUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "tailscaleUdpDesc": MessageLookupByLibrary.simpleMessage(
      "ارسال ترافیک UDP از طریق Tailscale",
    ),
    "tailscaleWarnings": MessageLookupByLibrary.simpleMessage("هشدارها"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("اتصال همزمان TCP"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه به اتصال‌های همزمان TCP",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("آدرس تست"),
    "testing": MessageLookupByLibrary.simpleMessage("در حال بررسی"),
    "textScale": MessageLookupByLibrary.simpleMessage("مقیاس متن"),
    "theme": MessageLookupByLibrary.simpleMessage("پوسته"),
    "themeColor": MessageLookupByLibrary.simpleMessage("رنگ پوسته"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات مربوط به رنگ و پوسته",
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
    "toolConnectivityDesc": MessageLookupByLibrary.simpleMessage(
      "بررسی دسترسی سرویس‌ها با آزمون گروهی نودها",
    ),
    "toolHistoryClear": MessageLookupByLibrary.simpleMessage(
      "پاک کردن تاریخچه",
    ),
    "toolSpeedTestDesc": MessageLookupByLibrary.simpleMessage(
      "سنجش سرعت دانلود، آپلود و تأخیر",
    ),
    "toolbox": MessageLookupByLibrary.simpleMessage("جعبه ابزار"),
    "toolboxDesc": MessageLookupByLibrary.simpleMessage(
      "عیب‌یابی و اشکال‌زدایی شبکه و ابزارهای کاربردی",
    ),
    "toolboxEditTip": MessageLookupByLibrary.simpleMessage(
      "برای تغییر اندازه روی کارت بزنید؛ برای جابه‌جایی نگه دارید و بکشید",
    ),
    "toolboxEditTipDesktop": MessageLookupByLibrary.simpleMessage(
      "برای تغییر اندازه روی کارت کلیک کنید؛ برای جابه‌جایی بکشید",
    ),
    "toolboxEditTipTv": MessageLookupByLibrary.simpleMessage(
      "یک کارت را انتخاب کنید و برای تغییر اندازه، دکمه تأیید را بزنید",
    ),
    "tools": MessageLookupByLibrary.simpleMessage("ابزارها"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("مجموع ترافیک"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("پورت Tproxy"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("مصرف ترافیک"),
    "trayClickBehavior": MessageLookupByLibrary.simpleMessage(
      "رفتار کلیک روی سینی",
    ),
    "trayEnhancement": MessageLookupByLibrary.simpleMessage("ارتقای منوی سینی"),
    "trayEnhancementDesc": MessageLookupByLibrary.simpleMessage(
      "کنترل گروه‌های پروکسی در منوی تسک‌بار",
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
    "tunVirtualAddress": MessageLookupByLibrary.simpleMessage(
      "آدرس کارت شبکه مجازی TUN",
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
    "tvScanImport": MessageLookupByLibrary.simpleMessage(
      "اسکن / وارد کردن از شبکه محلی",
    ),
    "tvScanImportDesc": MessageLookupByLibrary.simpleMessage(
      "اسکن کد یا ارسال پروفایل به تلویزیون از شبکه محلی",
    ),
    "tvScanManualUrl": MessageLookupByLibrary.simpleMessage(
      "یا آدرس را مستقیماً در مرورگر گوشی وارد کنید:",
    ),
    "tvScanNoNetwork": MessageLookupByLibrary.simpleMessage(
      "شبکه محلی در دسترس یافت نشد، لطفاً Wi-Fi را بررسی کنید",
    ),
    "tvScanStep1": MessageLookupByLibrary.simpleMessage(
      "مطمئن شوید گوشی و TV به یک شبکه Wi-Fi متصل هستند",
    ),
    "tvScanStep2": MessageLookupByLibrary.simpleMessage(
      "کد QR را با یک دوربین یا مرورگر پشتیبانی‌شده اسکن کنید",
    ),
    "tvScanStep3": MessageLookupByLibrary.simpleMessage(
      "لینک اشتراک را در صفحه وب جای‌گذاری کرده یا فایل پیکربندی را آپلود و ارسال کنید",
    ),
    "tvScanSuccess": MessageLookupByLibrary.simpleMessage(
      "پروفایل دریافت شد، در حال وارد کردن...",
    ),
    "tvScanWaiting": MessageLookupByLibrary.simpleMessage(
      "در انتظار ارسال پروفایل از گوشی...",
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
    "unlocked": MessageLookupByLibrary.simpleMessage("تکمیل شد"),
    "unnamed": MessageLookupByLibrary.simpleMessage("بدون نام"),
    "unpin": MessageLookupByLibrary.simpleMessage("برداشتن پین"),
    "update": MessageLookupByLibrary.simpleMessage("بروزرسانی"),
    "updateTime": MessageLookupByLibrary.simpleMessage("زمان به‌روزرسانی"),
    "upload": MessageLookupByLibrary.simpleMessage("آپلود"),
    "url": MessageLookupByLibrary.simpleMessage("آدرس URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "دریافت پروفایل از طریق آدرس URL",
    ),
    "urlTip": m53,
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "استفاده از اسکریپت اورراید سراسری",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("استفاده از Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "استفاده از Hosts سیستم",
    ),
    "userAuth": MessageLookupByLibrary.simpleMessage("احراز هویت کاربر"),
    "userAuthEmpty": MessageLookupByLibrary.simpleMessage(
      "کاربری برای احراز هویت تنظیم نشده، اتصال شبکه محلی نیازی به مشخصات ندارد",
    ),
    "username": MessageLookupByLibrary.simpleMessage("نام کاربری"),
    "usernameCannotContainColon": MessageLookupByLibrary.simpleMessage(
      "نام کاربری نباید شامل دونقطه (:) باشد",
    ),
    "value": MessageLookupByLibrary.simpleMessage("مقدار"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("پررنگ"),
    "view": MessageLookupByLibrary.simpleMessage("مشاهده"),
    "viewDetailedIpData": MessageLookupByLibrary.simpleMessage(
      "مشاهده داده‌های دقیق IP",
    ),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("تنظیمات مربوط به VPN"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "مسیریابی ترافیک با VpnService",
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
    "wanderingCubes": MessageLookupByLibrary.simpleMessage("مکعب‌های سرگردان"),
    "wave": MessageLookupByLibrary.simpleMessage("موج"),
    "waveSpinner": MessageLookupByLibrary.simpleMessage("چرخنده موجی"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "تنظیمات WebDAV",
    ),
    "whitelist": MessageLookupByLibrary.simpleMessage("لیست سفید"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سفید"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("اعمال به سیستم"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "نیازمند دسترسی مدیریت (Admin)",
    ),
    "xattrUnsupportedFallback": MessageLookupByLibrary.simpleMessage(
      "سیستم فایل از قابلیت‌های فایل (xattr) پشتیبانی نمی‌کند؛ به setuid بازگشت داده شد",
    ),
    "years": m54,
  };
}
