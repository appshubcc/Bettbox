/// 内置脚本：MyClash 的 mihomo 配置覆写脚本。
///
/// 它是一份普通脚本，只是随 App 一起分发（见 [builtinScriptAssetPath]）：
/// - 首次安装（或脚本缺失）时用随包资源播种，之后只能从上游同步，**不开放编辑**
///   ——合并的产物结构依赖它的固定输出（自定义节点恒为空、链式代理默认关闭）；
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

/// 内置脚本用不到的自定义开关。
///
/// 内置脚本不开放编辑，脚本里写死的自定义节点（`customizeProxies`）恒为空，而
/// 「链式代理」在没有自定义节点时会直接抛错、整份配置都生成不出来。所以这一项在
/// 自定义面板里隐藏，也不会传给脚本（历史数据里万一开着，也按关闭处理）。
const builtinScriptHiddenOptions = {'链式代理'};

/// 真正交给内置脚本的自定义开关：滤掉 [builtinScriptHiddenOptions]。
///
/// 生成合并配置时，求值与 [builtinScriptStamp] 都必须用这份过滤后的开关，
/// 否则同一版脚本会算出两个签名、合并配置会被反复重生。
Map<String, bool> builtinScriptCustomOptions(Map<String, bool>? options) {
  if (options == null || options.isEmpty) return const {};
  return {
    for (final entry in options.entries)
      if (!builtinScriptHiddenOptions.contains(entry.key))
        entry.key: entry.value,
  };
}

/// 内置脚本的签名：脚本内容 + 自定义开关。
///
/// 合并配置生成时把它记进 `BundleConfig.scriptStamp`，之后脚本一改（同步 / 改自定义
/// 开关），签名就对不上，合并配置即视为过期需要重新生成。
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
