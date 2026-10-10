import 'package:bett_box/common/builtin_script.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 内置脚本的签名决定「脚本改了 → 合并配置过期」，这里把它的判定钉住。
///
/// 注意：这个文件里**只能有一个 testWidgets**，而且后续不要再用普通 `test` 做真实 IO
/// （读文件 / 起引擎）——`testWidgets` 装上 fake async 之后，真实异步再也回不来，用例会
/// 一路挂到 10 分钟超时。要读脚本内容就复用下面这次 `rootBundle` 的结果（读的时候必须
/// 走 `runAsync`，否则同样是挂住）。
void main() {
  testWidgets('随包脚本资源已注册且可加载', (tester) async {
    final content = await tester.runAsync(
      () => rootBundle.loadString(builtinScriptAssetPath),
    );
    expect(content, contains('Compatible_With_Bettbox'));
    expect(content, contains('function main(config)'));
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
}
