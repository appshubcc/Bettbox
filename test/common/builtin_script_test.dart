import 'package:bett_box/common/builtin_script.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 内置脚本的签名决定「脚本改了 → 合并配置过期」，这里把它的判定钉住。
///
/// 注意：这个文件里**只能有一个 testWidgets**，而且后续不要再用普通 `test` 做真实 IO
/// （读文件 / 起引擎）——`testWidgets` 装上 fake async 之后，后面的真实异步再也回不来，
/// 用例会一路挂到 10 分钟超时。要读脚本内容就复用下面这次 `rootBundle` 的结果。
void main() {
  testWidgets('随包脚本资源已注册且可加载，隐藏开关名单有效', (tester) async {
    final content = await rootBundle.loadString(builtinScriptAssetPath);
    expect(content, contains('Compatible_With_Bettbox'));
    expect(content, contains('function main(config)'));

    // 隐藏名单不能失效：脚本里得真有这些开关，否则隐藏逻辑就是死的
    for (final key in builtinScriptHiddenOptions) {
      expect(content, contains(key));
    }

    // 历史数据里开着的隐藏开关不该影响签名，否则合并配置会被反复判成过期
    final base = builtinScriptStamp(
      content: content,
      customOptions: builtinScriptCustomOptions(const {'Google': true}),
    );
    final withStaleChain = builtinScriptStamp(
      content: content,
      customOptions: builtinScriptCustomOptions(
        const {'Google': true, '链式代理': true},
      ),
    );
    expect(withStaleChain, base);
  });

  test('内容或自定义开关变化都会改变签名', () {
    final base = builtinScriptStamp(content: 'main(){}');

    expect(builtinScriptStamp(content: 'main(){}'), base);
    expect(builtinScriptStamp(content: 'main(){/*2*/}'), isNot(base));
    expect(
      builtinScriptStamp(content: 'main(){}', customOptions: const {'A': true}),
      isNot(base),
    );
    expect(
      builtinScriptStamp(content: 'main(){}', customOptions: const {'A': false}),
      isNot(
        builtinScriptStamp(content: 'main(){}', customOptions: const {'A': true}),
      ),
    );
  });

  test('自定义开关的书写顺序不影响签名', () {
    expect(
      builtinScriptStamp(
        content: 'main(){}',
        customOptions: const {'A': true, 'B': false},
      ),
      builtinScriptStamp(
        content: 'main(){}',
        customOptions: const {'B': false, 'A': true},
      ),
    );
  });

  test('空自定义开关与 null 等价', () {
    expect(
      builtinScriptStamp(content: 'x', customOptions: const {}),
      builtinScriptStamp(content: 'x'),
    );
  });

  test('内置脚本会滤掉隐藏开关（链式代理），其余开关原样保留', () {
    expect(
      builtinScriptCustomOptions({
        '链式代理': true,
        'Google': false,
        '极简模式': true,
      }),
      {'Google': false, '极简模式': true},
    );
    expect(builtinScriptCustomOptions(null), isEmpty);
    expect(builtinScriptCustomOptions(const {}), isEmpty);
  });
}
