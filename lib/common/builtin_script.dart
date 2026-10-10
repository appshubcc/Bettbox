/// 内置脚本：MyClash 的 mihomo 配置覆写脚本。
///
/// 它是一份普通脚本，只是随 App 一起分发（见 [builtinScriptAssetPath]）：
/// - 首次安装（或脚本缺失）时用随包资源播种，之后只能从上游同步，**不开放编辑**
///   ——合并的产物结构依赖它的固定输出（自定义节点恒为空）；
/// - 固定出现在脚本菜单里，用户不能删除；
/// - 合并配置的生成期用它逐个覆写成员配置，所以：
///   * 当前配置是合并配置时，脚本菜单里它按「强制开启」展示且不允许切换
///     （只锁展示，不改用户选中的全局脚本）；
///   * 它的内容或自定义开关一改，已生成的合并配置就过期，需要重新合并。
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 内置脚本在脚本列表里的固定 id。
const builtinScriptId = 'builtin-mihomo-script';

/// 随包分发的脚本资源路径（只用于播种）。
const builtinScriptAssetPath = 'assets/scripts/mihomo_script.js';

/// 脚本的上游地址，播种时写进脚本条目的 url，菜单里的「同步」用它拉取最新版。
const builtinScriptSourceUrl =
    'https://raw.githubusercontent.com/AIsouler/MyClash/main/Script/mihomoScript.js';

/// 内置脚本的签名：脚本内容 + 自定义开关。
///
/// 合并配置生成时把它记进 `BundleConfig.scriptStamp`，之后脚本一改（同步 / 改自定义
/// 开关），签名就对不上，合并配置即视为过期需要重新生成。
///
/// 自定义开关按原样参与签名与求值：脚本自己能声明哪些开关（面板只列它声明的），
/// App 侧不再过滤任何开关，免得求值与签名用两份数据。
String builtinScriptStamp({
  required String content,
  Map<String, bool>? customOptions,
}) {
  final options = customOptions ?? const <String, bool>{};
  final keys = options.keys.toList()..sort();
  final buffer = StringBuffer(content)..write('\u0000');
  for (final key in keys) {
    buffer.write('$key=${options[key]}\u0001');
  }
  return md5.convert(utf8.encode(buffer.toString())).toString();
}
