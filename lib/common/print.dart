import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

class CommonPrint {
  static CommonPrint? _instance;
  static const _maxPending = 64;

  final List<Log> _pending = [];

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  void log(String? text, {String? module}) =>
      _dispatch(text, LogLevel.info, module);

  void debug(String? text, {String? module}) =>
      _dispatch(text, LogLevel.debug, module);

  void warn(String? text, {String? module}) =>
      _dispatch(text, LogLevel.warning, module);

  void error(String? text, {String? module}) =>
      _dispatch(text, LogLevel.error, module);

  void flush() {
    if (_pending.isEmpty) return;
    final logs = List.of(_pending);
    _pending.clear();
    logs.forEach(_emit);
  }

  void _dispatch(String? text, LogLevel level, String? module) {
    final log = Log.app('$text', level: level, module: module);
    debugPrint('[APP] ${log.raw}');
    if (!globalState.isInit) {
      if (globalState.isService) return;
      if (_pending.length >= _maxPending) _pending.removeAt(0);
      _pending.add(log);
      return;
    }
    _emit(log);
  }

  void _emit(Log log) {
    final config = globalState.config;
    if (!config.appSetting.openLogs) return;
    final level = config.patchClashConfig.logLevel;
    if (level == LogLevel.silent) return;
    if (log.logLevel == LogLevel.debug && level != LogLevel.debug) return;
    globalState.appController.addLog(log);
  }
}

final commonPrint = CommonPrint();
