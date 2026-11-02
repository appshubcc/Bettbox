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

  static String m2(count) => "${count} ناموفق";

  static String m3(message) => "آخرین ساخت ناموفق بود: ${message}";

  static String m4(count) => "حداکثر ${count} اشتراک را می‌توانید ادغام کنید";

  static String m5(count) => "${count} گره";

  static String m6(proxies, duplicates, time) =>
      "${proxies} گره · ${duplicates} مورد تکراری حذف شد · ${time}";

  static String m7(count) => "${count} پروفایل ادغام شد";

  static String m8(value) => "میانگین ${value}";

  static String m9(count) => "${Intl.plural(count, other: '# روز')}";

  static String m10(label) =>
      "این پروفایل بخشی از «${label}» است. با حذف آن، از اشتراک ادغام‌شده خارج می‌شود.";

  static String m11(label) => "آیا از حذف موارد انتخاب شده اطمینان دارید؟";

  static String m12(label) => "آیا از حذف ${label} اطمینان دارید؟";

  static String m13(reason) => "Fake-IP · ${reason}: IP واقعی برگردانده می‌شود";

  static String m14(reason, range) =>
      "Fake-IP · ${reason}: آدرس مجازی از ${range} برگردانده می‌شود";

  static String m15(ips) => "تطبیق با Hosts: ${ips} برگردانده می‌شود";

  static String m16(outbound) =>
      "خروجی نهایی «${outbound}»، گره دامنه را تفکیک می‌کند";

  static String m17(outbound) =>
      "خروجی نهایی «${outbound}»، گره دامنه را تفکیک می‌کند؛ Hosts اعمال نمی‌شود";

  static String m18(label) => "${label} نمی‌تواند خالی باشد";

  static String m19(label) => "${label} از قبل وجود دارد";

  static String m20(count) => "${Intl.plural(count, other: '${count} بار')}";

  static String m21(count) => "${Intl.plural(count, other: '# ساعت')}";

  static String m22(count) => "${count} آیکون";

  static String m23(inbound, user) => "${inbound} (کاربر ${user})";

  static String m24(score) =>
      "Scamalytics ترافیک وب این IP را مستقیماً مشاهده می‌کند. امتیاز ${score} نشان‌دهنده سهم ترافیک مشکوک به تقلب از آن است.";

  static String m25(score, isp) =>
      "Scamalytics ترافیک وب این IP را مستقیماً نمی‌بیند. امتیاز ${score} بر اساس ریسک کلی IPهای ${isp} تخمین زده شده است.";

  static String m26(port) =>
      "پورت ${port} در حال استفاده است؛ پورت دیگری انتخاب کنید";

  static String m27(code) => "سرور آزمون را رد کرد (خطای ${code})";

  static String m28(lost, total) => "${lost}/${total} بسته";

  static String m29(name) => "اسکن شد: ${name}";

  static String m30(value) => "${value} ثانیه";

  static String m31(port) => "در حال گوش دادن روی پورت ${port}";

  static String m32(count) => "${count} جریان";

  static String m33(count) => "${count}";

  static String m34(count) => "${count} بایت";

  static String m35(address) => "از ${address}";

  static String m36(count) =>
      "فقط ${count} مورد آخر نمایش داده می‌شود. برای دیدن همه، نتیجه را کپی کنید";

  static String m37(min, avg, max, jitter) =>
      "زمان رفت‌وبرگشت: کمینه ${min} / میانگین ${avg} / بیشینه ${max} / لرزش ${jitter} ms";

  static String m38(target) => "آمار Ping برای ${target}";

  static String m39(sent, received, lost, loss) =>
      "ارسال ${sent}، دریافت ${received}، از دست رفته ${lost} (${loss}٪ افت)";

  static String m40(level) =>
      "حالت ${level} برای اشکال‌زدایی شبکه مناسب است؛ در استفاده روزمره آن را خاموش کنید";

  static String m41(version) => "داخلی ${version}";

  static String m42(enabled, total) => "${enabled} از ${total} فعال";

  static String m43(version) => "بالادستی ${version}";

  static String m44(done, total, unlocked) =>
      "${done}/${total} بررسی شد · ${unlocked} در دسترس";

  static String m45(size) => "${size} آزاد شد";

  static String m46(index) => "اشتراک ادغام‌شده ${index}";

  static String m47(count) => "${Intl.plural(count, other: '# دقیقه')}";

  static String m48(count) => "${Intl.plural(count, other: '# ماه')}";

  static String m49(count) => "${count} مورد";

  static String m50(ip) => "از طریق ${ip}";

  static String m51(count) => "${count} گزارش جدید";

  static String m52(prefix) => "پیشوند گره: ${prefix}";

  static String m53(label) => "هیچ مورد ${label} یافت نشد";

  static String m54(min, max) => "یک عدد صحیح بین ${min} تا ${max} وارد کنید";

  static String m55(label) => "${label} باید عدد باشد";

  static String m56(label) => "فقط ${label}";

  static String m57(label) =>
      "${label} باید بین ۱۰۲۴ تا ۴۹۱۵۱ باشد (۰ برای غیرفعال)";

  static String m58(statusCode) =>
      "خطا در دریافت پروفایل. لطفاً شبکه خود را بررسی کرده یا لینک را ریست کنید ( کد خطا: ${statusCode} )";

  static String m59(count) => "${count} ارائه‌دهنده";

  static String m60(count) => "افزودن ${count}";

  static String m61(count) => "حذف ${count}";

  static String m62(index, time) => "تفکیک با قانون #${index} · ${time} ms";

  static String m63(ips) => "تطبیق Hosts: ${ips}";

  static String m64(total, index) => "${total} قانون، تطبیق با #${index}";

  static String m65(total) => "${total} قانون";

  static String m66(count) => "${count} قانون";

  static String m67(count, group) =>
      "${count} قانون، در گروه ${group} گنجانده شده";

  static String m68(count) => "${count} مورد انتخاب شده";

  static String m69(count) =>
      "حالت چندرشته از ${count} اتصال موازی برای اشباع پهنای باند استفاده می‌کند";

  static String m70(provider) =>
      "ممکن است خروجی تست سرعت ${provider} را مسدود کند. منبع تست یا خروجی را تغییر دهید.";

  static String m71(protocol, fallback) =>
      "${protocol} در دسترس نیست، به ${fallback} بازگشت";

  static String m72(count) => "${count} اتصال";

  static String m73(provider) => "تغییر به ${provider}";

  static String m74(label) => "${label} باید یک URL معتبر باشد";

  static String m75(count) => "${Intl.plural(count, other: '# سال')}";

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
    "activeGoroutines": MessageLookupByLibrary.simpleMessage("گوروتین‌ها"),
    "add": MessageLookupByLibrary.simpleMessage("افزودن"),
    "addBundleMember": MessageLookupByLibrary.simpleMessage("افزودن اعضا"),
    "addProfile": MessageLookupByLibrary.simpleMessage("افزودن پروفایل"),
    "addRegion": MessageLookupByLibrary.simpleMessage("افزودن منطقه"),
    "addRoute": MessageLookupByLibrary.simpleMessage("مدیریت مسیرها"),
    "addRule": MessageLookupByLibrary.simpleMessage("افزودن قانون"),
    "addRuleSet": MessageLookupByLibrary.simpleMessage("افزودن مجموعه قوانین"),
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
    "autoStickyHeader": MessageLookupByLibrary.simpleMessage("سنجاق بازشده"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("بروزرسانی خودکار"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "فاصله بروزرسانی خودکار (دقیقه)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("بازگشت"),
    "backgroundWatermark": MessageLookupByLibrary.simpleMessage(
      "نشان پس‌زمینه",
    ),
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
    "blacklistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سیاه"),
    "blockComment": MessageLookupByLibrary.simpleMessage("کامنت"),
    "builtIn": MessageLookupByLibrary.simpleMessage("داخلی"),
    "builtInManagedMode": MessageLookupByLibrary.simpleMessage("حالت داخلی"),
    "bundleAddUrl": MessageLookupByLibrary.simpleMessage("پیوند اشتراک"),
    "bundleAddUrlDesc": MessageLookupByLibrary.simpleMessage(
      "به‌عنوان اشتراک جدید وارد و اضافه شود",
    ),
    "bundleCollapse": MessageLookupByLibrary.simpleMessage("جمع کردن اعضا"),
    "bundleCollapseDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال بودن، فقط اطلاعات اشتراک ادغام‌شده در فهرست نمایش داده می‌شود؛ برای باز یا بسته کردن، گوشه پایین سمت راست کارت را لمس کنید",
    ),
    "bundleDedupTip": MessageLookupByLibrary.simpleMessage(
      "گره‌های یکسان فقط یک بار نگه داشته می‌شوند و اعضای اول اولویت دارند",
    ),
    "bundleExpand": MessageLookupByLibrary.simpleMessage("باز کردن"),
    "bundleFailures": m2,
    "bundleMemberFailed": m3,
    "bundleMemberLimit": m4,
    "bundleMembers": MessageLookupByLibrary.simpleMessage("اعضا"),
    "bundleMembersDesc": MessageLookupByLibrary.simpleMessage(
      "برای تغییر پیشوند گره‌ها ضربه بزنید، برای مرتب‌سازی بکشید",
    ),
    "bundleNoMembers": MessageLookupByLibrary.simpleMessage(
      "حداقل یک عضو اضافه کنید",
    ),
    "bundlePendingImport": MessageLookupByLibrary.simpleMessage(
      "در انتظار وارد کردن",
    ),
    "bundleProxies": m5,
    "bundleReportDesc": m6,
    "bundleSummary": m7,
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
    "checkUrlTip": MessageLookupByLibrary.simpleMessage(
      "لطفاً درستی نشانی URL را بررسی کنید",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("در حال بررسی..."),
    "circle": MessageLookupByLibrary.simpleMessage("حلقه"),
    "clear": MessageLookupByLibrary.simpleMessage("پاک کردن"),
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
    "currentSelection": MessageLookupByLibrary.simpleMessage("انتخاب فعلی"),
    "custom": MessageLookupByLibrary.simpleMessage("سفارشی"),
    "customDashboardTitle": MessageLookupByLibrary.simpleMessage(
      "عنوان سفارشی",
    ),
    "customRuleSetUrl": MessageLookupByLibrary.simpleMessage(
      "نشانی مجموعه قوانین سفارشی",
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
    "dashboardAverage": m8,
    "dashboardTotal": MessageLookupByLibrary.simpleMessage("مجموع"),
    "days": m9,
    "defaultGateway": MessageLookupByLibrary.simpleMessage("گیت‌وی"),
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
    "deleteMemberTip": m10,
    "deleteMultipTip": m11,
    "deleteTip": m12,
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
    "disableQuic": MessageLookupByLibrary.simpleMessage("غیرفعال‌سازی QUIC"),
    "disableQuicDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال‌سازی QUIC برای کاهش مشکلات شبکه",
    ),
    "disableQuicManagedDesc": MessageLookupByLibrary.simpleMessage(
      "با فعال بودن اسکریپت، غیرفعال‌سازی QUIC اعمال نمی‌شود",
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
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "کش FakeIP و DNS پاک شد",
    ),
    "dnsHijack": MessageLookupByLibrary.simpleMessage("ربودن DNS"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "در دست گرفتن DNS سیستم و ارسال آن به هسته",
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
    "dnsQueryFakeIpOff": m13,
    "dnsQueryFakeIpOn": m14,
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
    "dnsQueryHostsHit": m15,
    "dnsQueryNoRecords": MessageLookupByLibrary.simpleMessage(
      "رکوردی وجود ندارد",
    ),
    "dnsQueryNormalMode": MessageLookupByLibrary.simpleMessage(
      "Normal: IP واقعی برگردانده می‌شود، تطبیق قوانین با IP",
    ),
    "dnsQueryRedirHost": MessageLookupByLibrary.simpleMessage(
      "Redir-Host: IP واقعی برگردانده می‌شود، دامنه هنگام اتصال بازیابی می‌شود",
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
      "خروجی نهایی DIRECT، هسته به‌صورت محلی تفکیک و مستقیم وصل می‌شود",
    ),
    "dnsQueryViaDirectHosts": MessageLookupByLibrary.simpleMessage(
      "خروجی نهایی DIRECT، اتصال مستقیم به آدرس Hosts",
    ),
    "dnsQueryViaProxy": m16,
    "dnsQueryViaProxyHosts": m17,
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
    "dynamicColor": MessageLookupByLibrary.simpleMessage("رنگ پویا"),
    "edit": MessageLookupByLibrary.simpleMessage("ویرایش"),
    "editRoute": MessageLookupByLibrary.simpleMessage("ویرایش مسیر"),
    "editTunnel": MessageLookupByLibrary.simpleMessage("ویرایش هدایت"),
    "editUser": MessageLookupByLibrary.simpleMessage("ویرایش کاربر"),
    "emptyTip": m18,
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
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "پنهان کردن برنامه از لیست برنامه‌های اخیر",
    ),
    "existsTip": m19,
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
    "fakeIpFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "تعیین حالت فیلتر FakeIP",
    ),
    "fast": MessageLookupByLibrary.simpleMessage("سریع"),
    "fcmAndroidTip": MessageLookupByLibrary.simpleMessage(
      " به دلیل محدودیت‌های مجوز سیستم، در Android ممکن است برای نتایج دقیق‌تر لازم باشد گزینه \'میانبر زدن VPN\' را در تنظیمات شبکه غیرفعال کنید",
    ),
    "fcmOptimization": MessageLookupByLibrary.simpleMessage("بهینه‌سازی FCM"),
    "fcmOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "افزایش پایداری اتصال مستقیم FCM",
    ),
    "fcmTip": MessageLookupByLibrary.simpleMessage(
      "Firebase Cloud Messaging (FCM) یک راهکار پیام‌رسانی چندسکویی است و پشتیبانی از اتصال آن به دستگاه و شبکه بستگی دارد؛ نتایج نمایش‌داده‌شده صرفاً جنبه مرجع دارند.",
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
    "foldingCube": MessageLookupByLibrary.simpleMessage("مکعب تاشو"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("فونت"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("نگاشت اجباری DNS"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "نگاشت اجباری نتایج DNS به اتصالات",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("دامنه‌های اجباری"),
    "forceGCTitle": MessageLookupByLibrary.simpleMessage(
      "پاکسازی اجباری حافظه",
    ),
    "formatError": MessageLookupByLibrary.simpleMessage(
      "لطفاً صحت فرمت را بررسی کنید",
    ),
    "fourColumns": MessageLookupByLibrary.simpleMessage("۴ ستون"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("سالاد میوه"),
    "fullRestart": MessageLookupByLibrary.simpleMessage("راه‌اندازی مجدد سرد"),
    "fullRestartDesc": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی مجدد کامل هسته و آزادسازی کامل‌تر حافظه",
    ),
    "general": MessageLookupByLibrary.simpleMessage("عمومی"),
    "generalDesc": MessageLookupByLibrary.simpleMessage("تغییر تنظیمات عمومی"),
    "generate": MessageLookupByLibrary.simpleMessage("ساخت"),
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
    "global": MessageLookupByLibrary.simpleMessage("سراسر جهان"),
    "go": MessageLookupByLibrary.simpleMessage("رفتن"),
    "goDownload": MessageLookupByLibrary.simpleMessage("رفتن به دانلود"),
    "groupOrderTip": MessageLookupByLibrary.simpleMessage(
      "از بالا به پایین بررسی می‌شود، برای تغییر ترتیب بکشید",
    ),
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
    "heapObjects": MessageLookupByLibrary.simpleMessage("اشیای هیپ"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "پنهان کردن گره‌های نامعتبر",
    ),
    "highPriority": MessageLookupByLibrary.simpleMessage("اولویت بالا"),
    "highPriorityDesc": MessageLookupByLibrary.simpleMessage(
      "افزایش اولویت پردازش برنامه و هسته",
    ),
    "highRefreshRate": MessageLookupByLibrary.simpleMessage("نرخ نوسازی بالا"),
    "highRefreshRateDesc": MessageLookupByLibrary.simpleMessage(
      "فعالسازی حداکثر نرخ نوسازی",
    ),
    "hitCount": m20,
    "host": MessageLookupByLibrary.simpleMessage("هاست"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage(
      "افزودن Hosts به پروفایل فعلی",
    ),
    "hotReload": MessageLookupByLibrary.simpleMessage("بارگذاری مجدد سریع"),
    "hotReloadDesc": MessageLookupByLibrary.simpleMessage(
      "هسته در حال اجرا می‌ماند و تغییر اشتراک سریع‌تر است",
    ),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("تداخل کلید میانبر"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "مدیریت کلیدهای میانبر",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "کنترل برنامه با صفحه کلید",
    ),
    "hourGlass": MessageLookupByLibrary.simpleMessage("ساعت شنی"),
    "hours": m21,
    "httpPortSniffer": MessageLookupByLibrary.simpleMessage("اسنیف پورت HTTP"),
    "icmpForwarding": MessageLookupByLibrary.simpleMessage("هدایت ICMP"),
    "icmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبانی از پینگ ICMP در صورت فعال بودن",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("آیکون"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage("تنظیمات آیکون"),
    "iconConfigurationDesc": MessageLookupByLibrary.simpleMessage(
      "سفارشی‌سازی آیکون‌های ICON گروه پروکسی",
    ),
    "iconCount": m22,
    "iconSets": MessageLookupByLibrary.simpleMessage("مجموعه‌های آیکون"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("سبک آیکون"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("نشانی نماد"),
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
    "inUse": MessageLookupByLibrary.simpleMessage("در حال استفاده"),
    "inbound": MessageLookupByLibrary.simpleMessage("ورودی"),
    "inboundWithUser": m23,
    "infiniteTime": MessageLookupByLibrary.simpleMessage("نامحدود"),
    "init": MessageLookupByLibrary.simpleMessage("راه‌اندازی اولیه"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید میانبر معتبری وارد کنید",
    ),
    "installTime": MessageLookupByLibrary.simpleMessage("زمان نصب"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "انتخاب هوشمند",
    ),
    "internalTraffic": MessageLookupByLibrary.simpleMessage("ترافیک داخلی"),
    "internet": MessageLookupByLibrary.simpleMessage("اینترنت"),
    "interval": MessageLookupByLibrary.simpleMessage("فاصله زمانی"),
    "intranetAndGateway": MessageLookupByLibrary.simpleMessage(
      "شبکه محلی و گیت‌وی",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP شبکه محلی"),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "مجموعه آیکون معتبر نیست",
    ),
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
    "ipRiskAlert": MessageLookupByLibrary.simpleMessage("هشدار ریسک IP"),
    "ipRiskAmountHigh": MessageLookupByLibrary.simpleMessage("زیاد"),
    "ipRiskAmountLow": MessageLookupByLibrary.simpleMessage("کم"),
    "ipRiskAmountMedium": MessageLookupByLibrary.simpleMessage("متوسط"),
    "ipRiskAnonymousVpn": MessageLookupByLibrary.simpleMessage("VPN ناشناس"),
    "ipRiskBlacklist": MessageLookupByLibrary.simpleMessage(
      "نشانه‌های لیست سیاه",
    ),
    "ipRiskCheck": MessageLookupByLibrary.simpleMessage("بررسی پاکی IP"),
    "ipRiskCommercialServer": MessageLookupByLibrary.simpleMessage(
      "سرور تجاری",
    ),
    "ipRiskDatacenter": MessageLookupByLibrary.simpleMessage("دیتاسنتر"),
    "ipRiskHigh": MessageLookupByLibrary.simpleMessage("ریسک بالا"),
    "ipRiskHint": MessageLookupByLibrary.simpleMessage(
      "IP مورد نظر را وارد کنید",
    ),
    "ipRiskHomeBroadband": MessageLookupByLibrary.simpleMessage(
      "IP مسکونی ممتاز",
    ),
    "ipRiskHostingOrProxy": MessageLookupByLibrary.simpleMessage(
      "میزبانی یا پروکسی",
    ),
    "ipRiskHostname": MessageLookupByLibrary.simpleMessage("نام میزبان"),
    "ipRiskInvalid": MessageLookupByLibrary.simpleMessage(
      "یک IP عمومی معتبر وارد کنید",
    ),
    "ipRiskLow": MessageLookupByLibrary.simpleMessage("ریسک پایین"),
    "ipRiskMedium": MessageLookupByLibrary.simpleMessage("ریسک متوسط"),
    "ipRiskNoteAmount": MessageLookupByLibrary.simpleMessage(
      "ترافیک مشاهده‌شده",
    ),
    "ipRiskNoteAmountIsp": MessageLookupByLibrary.simpleMessage(
      "ترافیک اپراتور",
    ),
    "ipRiskNoteConnection": MessageLookupByLibrary.simpleMessage("نوع اتصال"),
    "ipRiskNoteDirect": m24,
    "ipRiskNoteFootnote": MessageLookupByLibrary.simpleMessage(
      "این ارزیابی فقط ترافیک وب را در بر می‌گیرد؛ ریسک سایر ترافیک‌ها ممکن است متفاوت باشد.",
    ),
    "ipRiskNoteGeneric": MessageLookupByLibrary.simpleMessage(
      "امتیاز تقلب (0 تا 100) سهمی از ترافیک وب این IP را نشان می‌دهد که Scamalytics به تقلب مشکوک است.",
    ),
    "ipRiskNoteIndirect": m25,
    "ipRiskNoteOwner": MessageLookupByLibrary.simpleMessage("مالک"),
    "ipRiskNoteProxying": MessageLookupByLibrary.simpleMessage(
      "ممکن است ترافیک مناطق دیگر را پروکسی کند؛ کاربر واقعی می‌تواند هر جایی باشد",
    ),
    "ipRiskNoteShare": MessageLookupByLibrary.simpleMessage("مشکوک به تقلب"),
    "ipRiskNoteTitle": MessageLookupByLibrary.simpleMessage(
      "درباره امتیاز تقلب",
    ),
    "ipRiskNoteWarningHigh": MessageLookupByLibrary.simpleMessage(
      "ترافیک وب این IP به احتمال زیاد مربوط به کلاهبرداران است.",
    ),
    "ipRiskNoteWarningVeryHigh": MessageLookupByLibrary.simpleMessage(
      "ترافیک وب این IP به احتمال بسیار زیاد مربوط به کلاهبرداران است.",
    ),
    "ipRiskProxyType": MessageLookupByLibrary.simpleMessage("نوع پروکسی"),
    "ipRiskPublicProxy": MessageLookupByLibrary.simpleMessage("پروکسی عمومی"),
    "ipRiskResidentialProxy": MessageLookupByLibrary.simpleMessage(
      "پروکسی خانگی",
    ),
    "ipRiskScore": MessageLookupByLibrary.simpleMessage("امتیاز تقلب"),
    "ipRiskSearchRobot": MessageLookupByLibrary.simpleMessage(
      "ربات موتور جستجو",
    ),
    "ipRiskServer": MessageLookupByLibrary.simpleMessage("سرور"),
    "ipRiskShareAlmostAll": MessageLookupByLibrary.simpleMessage("تقریباً همه"),
    "ipRiskShareLittle": MessageLookupByLibrary.simpleMessage("بسیار کم"),
    "ipRiskShareSome": MessageLookupByLibrary.simpleMessage("بخشی"),
    "ipRiskSource": MessageLookupByLibrary.simpleMessage("منبع"),
    "ipRiskTorExit": MessageLookupByLibrary.simpleMessage("گره خروجی Tor"),
    "ipRiskVeryHigh": MessageLookupByLibrary.simpleMessage("ریسک بسیار بالا"),
    "ipRiskWebProxy": MessageLookupByLibrary.simpleMessage("پروکسی وب"),
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
    "iperfErrorPortInUse": m26,
    "iperfErrorProtocol": MessageLookupByLibrary.simpleMessage(
      "پاسخ نامعتبر است؛ ممکن است طرف مقابل سرور iPerf3 نباشد",
    ),
    "iperfErrorRefused": MessageLookupByLibrary.simpleMessage(
      "اتصال رد شد. مطمئن شوید سرور iPerf3 در حال اجراست",
    ),
    "iperfErrorServer": m27,
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
    "iperfLostPackets": m28,
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
    "iperfScanned": m29,
    "iperfSeconds": m30,
    "iperfSend": MessageLookupByLibrary.simpleMessage("ارسال"),
    "iperfServer": MessageLookupByLibrary.simpleMessage("سرور"),
    "iperfServerListening": m31,
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
    "iperfStreams": m32,
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
    "itemsCount": m33,
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
    "largeRuleSetTip": MessageLookupByLibrary.simpleMessage(
      "مجموعه‌های قوانین بزرگ حافظه بیشتری مصرف می‌کنند",
    ),
    "lastEdit": MessageLookupByLibrary.simpleMessage("آخرین ویرایش"),
    "lastGenerated": MessageLookupByLibrary.simpleMessage("آخرین ساخت"),
    "layout": MessageLookupByLibrary.simpleMessage("چیدمان"),
    "leftClickBehavior": MessageLookupByLibrary.simpleMessage("کلیک چپ"),
    "light": MessageLookupByLibrary.simpleMessage("روشن"),
    "limitedUnlock": MessageLookupByLibrary.simpleMessage("فقط اختصاصی"),
    "lineWrap": MessageLookupByLibrary.simpleMessage("شکستن خطوط"),
    "list": MessageLookupByLibrary.simpleMessage("فهرست"),
    "local": MessageLookupByLibrary.simpleMessage("محلی"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری داده‌ها در فایل محلی",
    ),
    "localFile": MessageLookupByLibrary.simpleMessage("فایل محلی"),
    "localPing": MessageLookupByLibrary.simpleMessage("Ping محلی"),
    "localPingAverage": MessageLookupByLibrary.simpleMessage("میانگین"),
    "localPingBytes": m34,
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
    "localPingFrom": m35,
    "localPingGateway": MessageLookupByLibrary.simpleMessage("دروازه"),
    "localPingListLimit": m36,
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
    "localPingRttSummary": m37,
    "localPingRunning": MessageLookupByLibrary.simpleMessage("در حال Ping"),
    "localPingSent": MessageLookupByLibrary.simpleMessage("ارسال‌شده"),
    "localPingSize": MessageLookupByLibrary.simpleMessage("اندازه بسته"),
    "localPingStart": MessageLookupByLibrary.simpleMessage("شروع Ping"),
    "localPingStats": m38,
    "localPingSummary": m39,
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
    "lockProxy": MessageLookupByLibrary.simpleMessage("قفل کردن گره"),
    "log": MessageLookupByLibrary.simpleMessage("گزارش"),
    "logAiSearch": MessageLookupByLibrary.simpleMessage("جستجوی هوش مصنوعی"),
    "logLevel": MessageLookupByLibrary.simpleMessage("سطح گزارش"),
    "logLevelDebugHint": m40,
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
    "managedBundled": m41,
    "managedMode": MessageLookupByLibrary.simpleMessage("حالت مدیریت‌شده"),
    "managedModeDesc": MessageLookupByLibrary.simpleMessage(
      "ساخت گروه‌های پروکسی و قوانین با اسکریپت داخلی",
    ),
    "managedOptions": MessageLookupByLibrary.simpleMessage("گزینه‌های پیش‌فرض"),
    "managedOptionsDesc": m42,
    "managedRestoreTip": MessageLookupByLibrary.simpleMessage(
      "اسکریپت داخلی بازگردانی و همه اشتراک‌های ادغام‌شده دوباره ساخته شوند؟",
    ),
    "managedSyncTip": MessageLookupByLibrary.simpleMessage(
      "آخرین اسکریپت از بالادست دانلود و همه اشتراک‌های ادغام‌شده دوباره ساخته شوند؟",
    ),
    "managedSynced": m43,
    "managedUpToDate": MessageLookupByLibrary.simpleMessage(
      "در حال حاضر به‌روز است",
    ),
    "managedVersion": MessageLookupByLibrary.simpleMessage("اطلاعات نسخه"),
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
    "mediaBatchSummary": m44,
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
    "memoryAlreadyOptimal": MessageLookupByLibrary.simpleMessage(
      "حافظه از قبل بهینه است",
    ),
    "memoryAndRuntime": MessageLookupByLibrary.simpleMessage(
      "حافظه و زمان اجرا",
    ),
    "memoryFreed": m45,
    "memoryInfo": MessageLookupByLibrary.simpleMessage("اطلاعات حافظه"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "مقادیر حافظه نشان داده شده صرفاً مربوط به حافظه دینامیک هسته بوده و تمام حافظه برنامه نیست (جهت اطلاع).",
    ),
    "mergeProfile": MessageLookupByLibrary.simpleMessage("ادغام اشتراک‌ها"),
    "mergeProfileDesc": MessageLookupByLibrary.simpleMessage(
      "چند اشتراک را ادغام کنید و پیکربندی مسیریابی را یکجا مدیریت کنید",
    ),
    "mergeProfileUnavailable": MessageLookupByLibrary.simpleMessage(
      "برای ادغام حداقل دو پروفایل لازم است",
    ),
    "merged": MessageLookupByLibrary.simpleMessage("ادغام‌شده"),
    "mergedSubscriptionName": m46,
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
    "minutes": m47,
    "mixedPort": MessageLookupByLibrary.simpleMessage("پورت ترکیبی (Mixed)"),
    "mode": MessageLookupByLibrary.simpleMessage("حالت"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("تک‌رنگ"),
    "months": m48,
    "more": MessageLookupByLibrary.simpleMessage("بیشتر"),
    "moreIpInfo": MessageLookupByLibrary.simpleMessage("اطلاعات بیشتر IP"),
    "mrsCopyUrl": MessageLookupByLibrary.simpleMessage("کپی URL"),
    "mrsLookup": MessageLookupByLibrary.simpleMessage("جستجوی MRS"),
    "mrsLookupDesc": MessageLookupByLibrary.simpleMessage(
      "یافتن مجموعه‌های GEO / RULE-SET برای دامنه یا IP",
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
    "mrsReferenced": MessageLookupByLibrary.simpleMessage("در حال استفاده"),
    "mrsResolveDns": MessageLookupByLibrary.simpleMessage(
      "تفکیک دامنه با قوانین DNS",
    ),
    "mrsResolveDnsDesc": MessageLookupByLibrary.simpleMessage(
      "در حالت روشن، دامنه با تنظیمات فعلی DNS به IP تفکیک می‌شود و آن IP هم تطبیق داده می‌شود",
    ),
    "mrsRules": m49,
    "mrsTapAction": MessageLookupByLibrary.simpleMessage("عملکرد ضربه"),
    "mrsVia": m50,
    "mrsViewRules": MessageLookupByLibrary.simpleMessage("مشاهده فهرست قوانین"),
    "name": MessageLookupByLibrary.simpleMessage("نام"),
    "nameSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس نام"),
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
    "networkInterface": MessageLookupByLibrary.simpleMessage("رابط شبکه"),
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
    "newLogsCount": m51,
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
    "noNodePrefix": MessageLookupByLibrary.simpleMessage("بدون پیشوند"),
    "noProxy": MessageLookupByLibrary.simpleMessage("بدون پروکسی"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک پروفایل معتبر ایجاد یا اضافه کنید",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("عدم تحلیل IP"),
    "noStatusAvailable": MessageLookupByLibrary.simpleMessage(
      "وضعیتی یافت نشد",
    ),
    "noUsageData": MessageLookupByLibrary.simpleMessage("بدون آمار مصرف"),
    "node": MessageLookupByLibrary.simpleMessage("گره"),
    "nodeExclusion": MessageLookupByLibrary.simpleMessage("استثنای نودها"),
    "nodeExclusionDesc": MessageLookupByLibrary.simpleMessage(
      "حذف نودهای مطابقت یافته با عبارت",
    ),
    "nodeExclusionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "HK|ایران|🇮🇷",
    ),
    "nodePrefix": MessageLookupByLibrary.simpleMessage("پیشوند گره"),
    "nodePrefixValue": m52,
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
    "nullTip": m53,
    "nullUdpConnections": MessageLookupByLibrary.simpleMessage(
      "هیچ اتصال UDP وجود ندارد",
    ),
    "numberRangeInvalid": m54,
    "numberTip": m55,
    "oneColumn": MessageLookupByLibrary.simpleMessage("۱ ستون"),
    "onlinePanel": MessageLookupByLibrary.simpleMessage("پنل آنلاین"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("فقط آیکون"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "فقط برنامه‌های جانبی",
    ),
    "onlyShow": m56,
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
    "overrideSniffer": MessageLookupByLibrary.simpleMessage("اورراید Sniffer"),
    "overrideSnifferDesc": MessageLookupByLibrary.simpleMessage(
      "جایگزینی تنظیمات Sniffer پروفایل",
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
    "portTip": m57,
    "pouringHourGlass": MessageLookupByLibrary.simpleMessage("ساعت شنی روان"),
    "pouringHourGlassRefined": MessageLookupByLibrary.simpleMessage(
      "ساعت شنی ظریف",
    ),
    "powerSwitch": MessageLookupByLibrary.simpleMessage("کلید روشن/خاموش"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید را فشار دهید",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
    "privateIp": MessageLookupByLibrary.simpleMessage(
      "آدرس IP خصوصی / شبکه محلی",
    ),
    "process": MessageLookupByLibrary.simpleMessage("فرایند"),
    "processPath": MessageLookupByLibrary.simpleMessage("مسیر فرآیند"),
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
    "profileImportFailed": m58,
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً نام پروفایل را وارد کنید",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "خطا در پردازش فایل پروفایل",
    ),
    "profileSwitchMode": MessageLookupByLibrary.simpleMessage(
      "تغییر پیکربندی شبکه",
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
    "providersCount": m59,
    "provinceAndCity": MessageLookupByLibrary.simpleMessage("استان / شهر"),
    "proxies": MessageLookupByLibrary.simpleMessage("پروکسی‌ها"),
    "proxiesCount": MessageLookupByLibrary.simpleMessage("گره‌های پروکسی"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("تنظیمات پروکسی"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("زنجیره پروکسی"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("گروه پروکسی"),
    "proxyGroupsCount": MessageLookupByLibrary.simpleMessage("گروه‌های پروکسی"),
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
      "قطع فوری اتصال‌ها هنگام تغییر شبکه یا نود",
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
    "regenerate": MessageLookupByLibrary.simpleMessage("ساخت دوباره"),
    "regexInvalid": MessageLookupByLibrary.simpleMessage(
      "قالب عبارت باقاعده نامعتبر است",
    ),
    "regionGroups": MessageLookupByLibrary.simpleMessage("گروه‌های منطقه‌ای"),
    "regionGroupsTip": MessageLookupByLibrary.simpleMessage(
      "منطقه‌هایی که گره منطبق ندارند ساخته نمی‌شوند؛ گره‌هایی که با هیچ منطقه‌ای منطبق نیستند به 其他节点 (سایر گره‌ها) می‌روند",
    ),
    "regionName": MessageLookupByLibrary.simpleMessage("نام منطقه"),
    "regionRegex": MessageLookupByLibrary.simpleMessage("عبارت باقاعده منطبق"),
    "reject": MessageLookupByLibrary.simpleMessage("مسدود کردن"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("باقی‌مانده"),
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
    "restoreBundled": MessageLookupByLibrary.simpleMessage(
      "بازگردانی نسخه داخلی",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("تلاش مجدد"),
    "rightClickBehavior": MessageLookupByLibrary.simpleMessage("کلیک راست"),
    "ring": MessageLookupByLibrary.simpleMessage("حلقه"),
    "ripple": MessageLookupByLibrary.simpleMessage("موج آب"),
    "rotatingCircle": MessageLookupByLibrary.simpleMessage("چرخش تک‌دایره"),
    "rotatingPlain": MessageLookupByLibrary.simpleMessage("صفحه چرخان"),
    "routeAddCount": m60,
    "routeCategoryAi": MessageLookupByLibrary.simpleMessage("هوش مصنوعی"),
    "routeCategoryDeveloper": MessageLookupByLibrary.simpleMessage(
      "ابزار توسعه",
    ),
    "routeCategoryFinance": MessageLookupByLibrary.simpleMessage(
      "مالی و پرداخت",
    ),
    "routeCategoryGaming": MessageLookupByLibrary.simpleMessage("بازی"),
    "routeCategorySocial": MessageLookupByLibrary.simpleMessage(
      "شبکه‌های اجتماعی",
    ),
    "routeCategoryStreaming": MessageLookupByLibrary.simpleMessage("استریم"),
    "routeCategoryTech": MessageLookupByLibrary.simpleMessage("فناوری"),
    "routeNameInvalid": MessageLookupByLibrary.simpleMessage(
      "نام نمی‌تواند شامل ویرگول یا شکست خط باشد",
    ),
    "routeRemoveCount": m61,
    "routeTarget": MessageLookupByLibrary.simpleMessage("خروجی پیش‌فرض"),
    "routeTrace": MessageLookupByLibrary.simpleMessage("ردیابی مسیر"),
    "routeTraceChain": MessageLookupByLibrary.simpleMessage("زنجیره پروکسی"),
    "routeTraceCheckedRules": MessageLookupByLibrary.simpleMessage(
      "قوانین بررسی‌شده",
    ),
    "routeTraceDesc": MessageLookupByLibrary.simpleMessage(
      "روند DNS و تطبیق قوانین دامنه یا IP در هسته",
    ),
    "routeTraceDns": MessageLookupByLibrary.simpleMessage("تفکیک DNS"),
    "routeTraceDnsBy": m62,
    "routeTraceDnsIp": MessageLookupByLibrary.simpleMessage(
      "هدف IP است و نیازی به تفکیک نیست",
    ),
    "routeTraceDnsSkipped": MessageLookupByLibrary.simpleMessage(
      "در حین تطبیق نیازی به تفکیک IP نبود",
    ),
    "routeTraceFinal": MessageLookupByLibrary.simpleMessage("خروجی نهایی"),
    "routeTraceHint": MessageLookupByLibrary.simpleMessage("دامنه، IP یا آدرس"),
    "routeTraceHostsHit": m63,
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
    "routeTraceRulesSummary": m64,
    "routeTraceRulesTotal": m65,
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
    "ruleCount": m66,
    "ruleCountIncluded": m67,
    "ruleHits": MessageLookupByLibrary.simpleMessage("تطابق قوانین"),
    "ruleName": MessageLookupByLibrary.simpleMessage("نام قانون"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان قوانین",
    ),
    "ruleProvidersCount": MessageLookupByLibrary.simpleMessage("مجموعه قوانین"),
    "ruleSets": MessageLookupByLibrary.simpleMessage("مجموعه‌های قوانین"),
    "ruleSort": MessageLookupByLibrary.simpleMessage("ترتیب قوانین"),
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
    "searchIcons": MessageLookupByLibrary.simpleMessage("جستجوی نمادها"),
    "searchRuleSets": MessageLookupByLibrary.simpleMessage(
      "جستجوی مجموعه قوانین",
    ),
    "searchServices": MessageLookupByLibrary.simpleMessage("جستجوی سرویس‌ها"),
    "seconds": MessageLookupByLibrary.simpleMessage("ثانیه"),
    "secretCopied": MessageLookupByLibrary.simpleMessage(
      "رمز عبور در حافظه موقت کپی شد",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("انتخاب همه"),
    "selectBackupVersion": MessageLookupByLibrary.simpleMessage(
      "انتخاب نسخه پشتیبان",
    ),
    "selectIcon": MessageLookupByLibrary.simpleMessage("انتخاب نماد"),
    "selected": MessageLookupByLibrary.simpleMessage("انتخاب شده"),
    "selectedCountTitle": m68,
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
      "نمایش گروه‌های پنهان",
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
    "sniffHost": MessageLookupByLibrary.simpleMessage("هاست شنودشده"),
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
    "speedTestConnectionsDesc": m69,
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
    "speedTestErrorBlockedDesc": m70,
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
    "speedTestProtocolFallback": m71,
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
    "speedTestStreams": m72,
    "speedTestSwitchProvider": m73,
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
    "subdomains": MessageLookupByLibrary.simpleMessage("زیردامنه‌ها"),
    "submit": MessageLookupByLibrary.simpleMessage("ارسال"),
    "success": MessageLookupByLibrary.simpleMessage("موفقیت‌آمیز"),
    "switchLabel": MessageLookupByLibrary.simpleMessage("کلید"),
    "sync": MessageLookupByLibrary.simpleMessage("همگام‌سازی"),
    "syncAll": MessageLookupByLibrary.simpleMessage("همگام‌سازی همه"),
    "syncDelayAnimation": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی انیمیشن با صفحات دیگر",
    ),
    "syncFailed": MessageLookupByLibrary.simpleMessage("همگام‌سازی ناموفق بود"),
    "syncFromUpstream": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی از بالادست",
    ),
    "system": MessageLookupByLibrary.simpleMessage("سیستم"),
    "systemApp": MessageLookupByLibrary.simpleMessage("برنامه‌های سیستم"),
    "systemDns": MessageLookupByLibrary.simpleMessage("DNS"),
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
    "testing": MessageLookupByLibrary.simpleMessage("در حال بررسی"),
    "textScale": MessageLookupByLibrary.simpleMessage("مقیاس متن"),
    "theme": MessageLookupByLibrary.simpleMessage("پوسته"),
    "themeColor": MessageLookupByLibrary.simpleMessage("رنگ پوسته"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیمات مربوط به رنگ و پوسته",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("حالت پوسته"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("این ماه"),
    "thisWeek": MessageLookupByLibrary.simpleMessage("این هفته"),
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
    "today": MessageLookupByLibrary.simpleMessage("امروز"),
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
    "trafficRanking": MessageLookupByLibrary.simpleMessage("رتبه‌بندی"),
    "trafficStatsClearTip": MessageLookupByLibrary.simpleMessage(
      "همهٔ آمار ترافیک پاک شود؟",
    ),
    "trafficStatsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهدهٔ جزئیات مقصد ترافیک به تفکیک روز، هفته و ماه",
    ),
    "trafficStatsDetail": MessageLookupByLibrary.simpleMessage("ثبت جزئیات"),
    "trafficStatsDetailDesc": MessageLookupByLibrary.simpleMessage(
      "ثبت دامنه‌ها، فرایندها، گره‌ها و قوانین. در حالت خاموش فقط مجموع ذخیره می‌شود",
    ),
    "trafficStatsDisabledTip": MessageLookupByLibrary.simpleMessage(
      "به‌طور پیش‌فرض خاموش است. پس از روشن کردن، ثبت آغاز می‌شود و داده‌ها فقط روی همین دستگاه ذخیره می‌شوند",
    ),
    "trafficStatsEnable": MessageLookupByLibrary.simpleMessage(
      "فعال‌سازی آمار ترافیک",
    ),
    "trafficStatsRetention": MessageLookupByLibrary.simpleMessage(
      "مدت نگهداری داده",
    ),
    "trafficStatsSiteIcon": MessageLookupByLibrary.simpleMessage(
      "نمایش آیکون سایت‌ها",
    ),
    "trafficStatsSiteIconDesc": MessageLookupByLibrary.simpleMessage(
      "ابتدا آیکون از خود سایت‌ها دریافت می‌شود و اگر آیکون واضحی نباشد از سرویس آیکون Google استفاده و به‌صورت محلی ذخیره می‌شود",
    ),
    "trafficTrend": MessageLookupByLibrary.simpleMessage("روند"),
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
    "unlockProxy": MessageLookupByLibrary.simpleMessage("باز کردن قفل"),
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
    "urlTip": m74,
    "usageStyle": MessageLookupByLibrary.simpleMessage("سبک نمایش مصرف"),
    "usageStyleBar": MessageLookupByLibrary.simpleMessage("نواری"),
    "usageStyleConcentric": MessageLookupByLibrary.simpleMessage(
      "حلقه‌های هم‌مرکز",
    ),
    "usageStyleRing": MessageLookupByLibrary.simpleMessage("حلقه‌ای"),
    "useGlobalScriptOverride": MessageLookupByLibrary.simpleMessage(
      "اسکریپت هر پروفایل",
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
    "whitelistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سفید"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("اعمال به سیستم"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "نیازمند دسترسی مدیریت (Admin)",
    ),
    "xattrUnsupportedFallback": MessageLookupByLibrary.simpleMessage(
      "سیستم فایل از قابلیت‌های فایل (xattr) پشتیبانی نمی‌کند؛ به setuid بازگشت داده شد",
    ),
    "years": m75,
  };
}
