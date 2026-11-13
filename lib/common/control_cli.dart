import 'dart:math' as math;

/// ExternalControl 控制通道的语法层。
///
/// 语法：`[<scope>] <option> [<value>...] [--json]`
///
/// - `<scope>` 是名词作用域：`profiles` / `mode` / `tun` / `core` / `settings`；
///   省略作用域时选项作用于 APP 本身（`--status`、`--refresh-dns`）。
/// - 每个作用域都接受 `--json`（单行 JSON）与 `-h/--help`；
///   裸 `<scope>` 等价于 `<scope> --status`。
/// - 旧的扁平命令（`status`、`profile xxx`、`set k v`、`apply`、`dns`……）
///   保留为别名，第三方 socket 客户端不需要跟着改。
class ControlCliError implements Exception {
  const ControlCliError(this.message);

  final String message;

  @override
  String toString() => message;
}

class ControlCommand {
  const ControlCommand({
    required this.scope,
    required this.option,
    required this.args,
    required this.json,
    required this.help,
  });

  /// 作用域，空串表示作用于 APP 本身。
  final String scope;

  /// 归一化的选项名，例如 `--status`、`--select`。
  final String option;

  final List<String> args;
  final bool json;
  final bool help;

  /// 归一化后的命令标识：`profiles --select`、`--status`。
  String get key => scope.isEmpty ? option : '$scope $option';

  /// 位置参数合成的一个值（`settings --set secret a b` 里的 `a b`）。
  String get value => args.join(' ');
}

class _OptionSpec {
  const _OptionSpec(
    this.usage,
    this.summary, {
    this.minArgs = 0,
    this.maxArgs = 0,
    this.hidden = false,
  });

  final String usage;
  final String summary;

  /// 允许的位置参数个数，`-1` 表示不限。
  final int minArgs;
  final int maxArgs;

  /// 不出现在帮助里（内部/兼容用）。
  final bool hidden;
}

class _ScopeSpec {
  const _ScopeSpec(this.title, this.options);

  final String title;
  final Map<String, _OptionSpec> options;
}

const Map<String, _ScopeSpec> _scopes = {
  '': _ScopeSpec('顶层选项（作用于 APP 本身）', {
    '--status': _OptionSpec('--status', '内核 / 模式 / TUN / 端口 / 当前订阅快照'),
    '--refresh-dns': _OptionSpec('--refresh-dns', '刷新 DNS 缓存'),
    '--show': _OptionSpec('--show', '显示主窗口'),
    '--restart': _OptionSpec('--restart', '重启应用'),
    '--exit': _OptionSpec('--exit', '退出应用'),
    '--ping': _OptionSpec('--ping', '健康检查，回 pong', hidden: true),
  }),
  'profiles': _ScopeSpec('订阅管理', {
    '--list': _OptionSpec('--list', '列出全部订阅（current / loaded 标记）'),
    '--status': _OptionSpec('--status', '当前订阅与加载状态'),
    '--select': _OptionSpec(
      '--select <id|label>',
      '切换订阅',
      minArgs: 1,
      maxArgs: 1,
    ),
    '--update': _OptionSpec(
      '--update [id|label|all]',
      '更新订阅；省略或 all 表示全部',
      maxArgs: 1,
    ),
    '--reapply': _OptionSpec('--reapply', '重新下发当前配置'),
  }),
  'mode': _ScopeSpec('出站模式', {
    '--status': _OptionSpec('--status', '当前模式'),
    '--switch': _OptionSpec(
      '--switch rule|global|direct',
      '切换模式',
      minArgs: 1,
      maxArgs: 1,
    ),
  }),
  'tun': _ScopeSpec('TUN', {
    '--status': _OptionSpec('--status', 'TUN 开关与内核实际状态'),
    '--enable': _OptionSpec('--enable', '开启 TUN（Linux 走 polkit 提权）'),
    '--disable': _OptionSpec('--disable', '关闭 TUN'),
  }),
  'core': _ScopeSpec('内核', {
    '--status': _OptionSpec('--status', '内核运行状态'),
    '--start': _OptionSpec('--start', '启动内核'),
    '--stop': _OptionSpec('--stop', '停止内核'),
    '--restart': _OptionSpec('--restart', '重启内核'),
  }),
  'settings': _ScopeSpec('配置项（GUI 专有字段）', {
    '--list': _OptionSpec('--list', '列出可写字段与当前值'),
    '--status': _OptionSpec('--status', '同 --list'),
    '--get': _OptionSpec('--get [field]', '读取单个字段', maxArgs: 1),
    '--set': _OptionSpec(
      '--set <field> [value]',
      '写入字段（secret 不带值 = 清除）',
      minArgs: 1,
      maxArgs: -1,
    ),
  }),
};

/// 旧扁平命令 → 新语法的别名表。
const Map<String, List<String>> _legacyAliases = {
  'exit': ['--exit'],
  'restart': ['--restart'],
  'show': ['--show'],
  'status': ['--status'],
  'apply': ['profiles', '--reapply'],
  'dns': ['--refresh-dns'],
  'help': ['--help'],
  'ping': ['--ping'],
};

class ControlCli {
  const ControlCli._();

  static const String globalHelp = '''
usage: Bettbox [<scope>] <option> [<value>] [--json]

顶层选项（作用于 APP 本身）:
  --status            内核 / 模式 / TUN / 端口 / 当前订阅
  --refresh-dns       刷新 DNS 缓存
  --show              显示主窗口
  --restart           重启应用
  --exit              退出应用
  --help, -h          本帮助

作用域（名词）:
  profiles            订阅：--list --status --select --update --reapply
  mode                出站模式：--status --switch
  tun                 TUN：--status --enable --disable
  core                内核：--status --start --stop --restart
  settings            配置项：--list --get --set

  Bettbox <scope> --help    查看该作用域的全部选项与说明

说明:
  命令都发给正在运行的实例，返回值 0 成功 / 1 失败；
  实例没在跑时直接报错，不会拉起界面。
  --json 输出单行 JSON；失败时为 {"ok":false,"error":"..."}。''';

  /// 实例没在跑时原生层用的极简提示，避免为了 --help 也依赖实例。
  static const String offlineUsage =
      'usage: Bettbox [--status|--show|--restart|--exit|--refresh-dns] '
      '[<scope> <option> ...] [--json]\n'
      'scopes: profiles mode tun core settings\n'
      "run 'Bettbox <scope> --help' for details (需要实例在运行)";

  static List<String> scopeNames() =>
      _scopes.keys.where((e) => e.isNotEmpty).toList();

  /// 把一行命令（或原始参数列表）解析成 [ControlCommand]。
  static ControlCommand parse(String line) {
    final tokens = line
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      throw const ControlCliError('empty command (try: Bettbox --help)');
    }

    var expanded = _expandLegacy(tokens);
    var scope = '';
    if (_scopes.containsKey(expanded.first)) {
      scope = expanded.removeAt(0);
      if (expanded.isNotEmpty && !expanded.first.startsWith('-')) {
        expanded = _expandShorthand(scope, expanded);
      }
    } else if (!expanded.first.startsWith('-')) {
      throw ControlCliError(
        'unknown scope: ${expanded.first} '
        '(scopes: ${scopeNames().join('|')})',
      );
    }

    final options = _scopes[scope]!.options;
    var json = false;
    var help = false;
    String? option;
    final args = <String>[];

    var i = 0;
    while (i < expanded.length) {
      final token = expanded[i];
      if (token == '-h' || token == '--help') {
        help = true;
        i++;
        continue;
      }
      if (token == '--json') {
        json = true;
        i++;
        continue;
      }
      if (!token.startsWith('-')) {
        throw ControlCliError('unexpected argument: $token');
      }
      if (option != null) {
        throw ControlCliError(
          'one option per command (got $option and $token)',
        );
      }
      final spec = options[token];
      if (spec == null) {
        throw ControlCliError(
          'unknown option: $token${scope.isEmpty ? '' : ' (scope $scope)'} '
          "(try: Bettbox ${scope.isEmpty ? '' : '$scope '}--help)",
        );
      }
      option = token;
      i++;
      var taken = 0;
      while (i < expanded.length) {
        final value = expanded[i];
        if (value.startsWith('-')) break;
        if (spec.maxArgs >= 0 && taken >= spec.maxArgs) {
          throw ControlCliError(
            'too many arguments for $token (${spec.usage})',
          );
        }
        args.add(value);
        taken++;
        i++;
      }
      if (taken < spec.minArgs) {
        throw ControlCliError('missing argument: ${spec.usage}');
      }
    }

    return ControlCommand(
      scope: scope,
      // 裸 scope（`Bettbox profiles`）默认看状态。
      option: option ?? '--status',
      args: args,
      json: json,
      help: help,
    );
  }

  static List<String> _expandLegacy(List<String> tokens) {
    final head = tokens.first.toLowerCase();
    final rest = tokens.sublist(1);
    // 已经是新语法的作用域名，别再当旧命令翻译（否则 `profiles --list`
    // 会被展开成 `profiles --list --list`）。
    if (_scopes.containsKey(head)) return tokens;
    final alias = _legacyAliases[head];
    if (alias != null) return [...alias, ...rest];
    switch (head) {
      case 'profile':
        return ['profiles', '--select', ...rest];
      case 'profile-update':
        return ['profiles', '--update', ...rest];
      case 'set':
        return ['settings', '--set', ...rest];
      default:
        return tokens;
    }
  }

  /// 作用域后面直接跟值的位置写法（`Bettbox mode global`、`Bettbox tun on`、
  /// `Bettbox core restart`），等价于该作用域对应的动作选项。
  static List<String> _expandShorthand(String scope, List<String> rest) {
    switch (scope) {
      case 'mode':
        return ['--switch', ...rest];
      case 'tun':
        return [
          rest.first == 'off' ? '--disable' : '--enable',
          ...rest.skip(1),
        ];
      case 'core':
        return ['--${rest.first}', ...rest.skip(1)];
      case 'profiles':
        return ['--select', ...rest];
      case 'settings':
        return rest.length > 1
            ? ['--set', ...rest]
            : ['--get', ...rest];
      default:
        throw ControlCliError('unexpected argument: ${rest.first}');
    }
  }

  /// `scope` 为空串时给全局帮助。
  static String help(String scope) {
    if (scope.isEmpty) return globalHelp;
    final spec = _scopes[scope]!;
    final rows = spec.options.entries.where((e) => !e.value.hidden).toList();
    final width = rows.fold<int>(
      0,
      (max, e) => math.max(max, e.value.usage.length),
    );
    final buffer = StringBuffer()
      ..writeln('Bettbox $scope — ${spec.title}')
      ..writeln();
    for (final entry in rows) {
      buffer.writeln(
        '  ${entry.value.usage.padRight(width)}  ${entry.value.summary}',
      );
    }
    buffer
      ..writeln()
      ..writeln('公共选项: --json 输出单行 JSON')
      ..writeln('裸 `Bettbox $scope` 等价于 `Bettbox $scope --status`。');
    return buffer.toString().trimRight();
  }

  /// 把若干 `label → value` 行对齐输出。
  static String kv(List<(String, String)> rows) {
    final width = rows.fold<int>(0, (max, r) => math.max(max, r.$1.length));
    return rows.map((r) => '${r.$1.padRight(width)}  ${r.$2}').join('\n');
  }

  static String formatAppStatus(Map<String, dynamic> data) {
    final loaded =
        data['loadedProfileId'] != null &&
        data['loadedProfileId'] == data['profileId'];
    final profile = data['profileLabel'] ?? data['profileId'] ?? '(none)';
    return kv([
      ('version', '${data['version']}'),
      ('core', '${data['core']}'),
      ('mode', '${data['mode']}'),
      ('tun', '${_onOff(data['tun'])} (real-tun ${_onOff(data['realTun'])})'),
      (
        'ports',
        'mixed ${data['mixedPort']} / http ${data['port']} / '
            'socks ${data['socksPort']}',
      ),
      ('lan', _onOff(data['allowLan'])),
      (
        'external',
        '${data['externalController']} '
            '(${data['hasSecret'] == true ? 'secret set' : 'no secret'})',
      ),
      ('log-level', '${data['logLevel']}'),
      ('profile', loaded ? '$profile (loaded)' : '$profile (not loaded)'),
    ]);
  }

  static String formatProfiles(List<dynamic> list) {
    if (list.isEmpty) return '(no profiles)';
    final buffer = StringBuffer();
    for (final item in list.cast<Map<String, dynamic>>()) {
      final flags = <String>[
        if (item['current'] == true) 'current',
        if (item['loaded'] == true) 'loaded',
      ];
      final id = '${item['id']}';
      final label = item['label'] ?? id;
      buffer.writeln(
        '${item['current'] == true ? '*' : '-'} $label ($id)'
        '${flags.isEmpty ? '' : ' [${flags.join(', ')}]'}',
      );
    }
    return buffer.toString().trimRight();
  }

  static String formatProfilesStatus(Map<String, dynamic> data) {
    final current = data['currentLabel'] ?? data['currentId'] ?? '(none)';
    final String loaded;
    if (data['loadedId'] == null) {
      loaded = '(not loaded)';
    } else if (data['loadedId'] == data['currentId']) {
      loaded = '$current (loaded)';
    } else {
      loaded = '${data['loadedId']} (stale)';
    }
    return kv([('current', '$current'), ('loaded', loaded)]);
  }

  static String formatModeStatus(Map<String, dynamic> data) =>
      kv([('mode', '${data['mode']}')]);

  static String formatTunStatus(Map<String, dynamic> data) => kv([
    ('tun', _onOff(data['tun'])),
    ('real-tun', _onOff(data['realTun'])),
  ]);

  static String formatCoreStatus(Map<String, dynamic> data) =>
      kv([('core', '${data['core']}'), ('version', '${data['version']}')]);

  static String formatSettings(Map<String, dynamic> data) => kv(
    data.entries.map((e) => (e.key, e.value == null ? '-' : '${e.value}')).toList(),
  );

  static String _onOff(Object? value) => value == true ? 'on' : 'off';
}
