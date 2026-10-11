import 'package:package_info_plus/package_info_plus.dart';

extension PackageInfoExtension on PackageInfo {
  // [Gamebox] 内核配置 > 常规 > 默认 UA。globalUa 为空时走这里。
  // 上游是 FlClash/ClashMetaForAndroid/2.11.33.Bettbox。同步时保留这一行。
  String get ua => 'Gamebox';
}
