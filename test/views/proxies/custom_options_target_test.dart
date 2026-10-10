import 'package:bett_box/views/proxies/proxies.dart';
import 'package:flutter_test/flutter_test.dart';

/// 代理页右上角「自定义」到底打开哪个面板：合并配置必须和脚本菜单里的入口一致，
/// 都指向内置脚本的自定义开关，而不是配置文件自己的策略组开关。
void main() {
  CustomOptionsTarget resolve({
    bool isBundle = false,
    bool builtinCompatible = false,
    bool scriptOn = false,
    bool scriptCompatible = false,
    bool useScriptOverride = false,
  }) {
    return resolveCustomOptionsTarget(
      isBundle: isBundle,
      builtinScriptCompatible: builtinCompatible,
      scriptOn: scriptOn,
      scriptCompatible: scriptCompatible,
      useScriptOverride: useScriptOverride,
    );
  }

  test('合并配置 → 内置脚本的自定义开关（与脚本菜单一致）', () {
    expect(
      resolve(isBundle: true, builtinCompatible: true),
      CustomOptionsTarget.builtinScript,
    );
    // 当前脚本是谁、成员自己的脚本开关是什么，都不影响合并配置走内置脚本
    expect(
      resolve(
        isBundle: true,
        builtinCompatible: true,
        scriptOn: true,
        scriptCompatible: true,
        useScriptOverride: false,
      ),
      CustomOptionsTarget.builtinScript,
    );
  });

  test('合并配置但内置脚本已被改得不兼容 → 退回策略组开关', () {
    expect(
      resolve(isBundle: true, builtinCompatible: false),
      CustomOptionsTarget.groupSwitches,
    );
  });

  test('普通配置 + 全局脚本覆写开启 → 当前脚本的自定义开关', () {
    expect(
      resolve(scriptOn: true, scriptCompatible: true, useScriptOverride: true),
      CustomOptionsTarget.script,
    );
  });

  test('普通配置没有脚本覆写 → 策略组开关', () {
    expect(resolve(), CustomOptionsTarget.groupSwitches);
    expect(
      resolve(scriptOn: true, scriptCompatible: true, useScriptOverride: false),
      CustomOptionsTarget.groupSwitches,
    );
  });
}
