import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'path.dart';
import 'print.dart';

class Preferences {
  static Preferences? _instance;
  Completer<SharedPreferences?> sharedPreferencesCompleter = Completer();

  Future<bool> get isInit async => await sharedPreferencesCompleter.future != null;

  Preferences._internal() {
    SharedPreferences.getInstance()
        .then((value) => sharedPreferencesCompleter.complete(value))
        .onError((_, _) => sharedPreferencesCompleter.complete(null));
  }

  factory Preferences() {
    _instance ??= Preferences._internal();
    return _instance!;
  }

  Future<ClashConfig?> getClashConfig() async {
    final preferences = await sharedPreferencesCompleter.future;
    final clashConfigString = preferences?.getString(clashConfigKey);
    if (clashConfigString == null) return null;
    try {
      final clashConfigMap = json.decode(clashConfigString);
      return ClashConfig.fromJson(clashConfigMap);
    } catch (e, stackTrace) {
      commonPrint.log('Failed to parse clash config from preferences: $e\n$stackTrace');
      return null;
    }
  }

  Future<Config?> getConfig() async {
    final preferences = await sharedPreferencesCompleter.future;

    Config? fileConfig;
    try {
      final configFilePath = await appPath.appConfigPath;
      final configFile = File(configFilePath);
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        if (content.isNotEmpty) {
          final configMap = json.decode(content);
          fileConfig = Config.compatibleFromJson(configMap);
        }
      }
    } catch (e, stackTrace) {
      commonPrint.log('Failed to parse config from file: $e\n$stackTrace');
    }

    Config? prefsConfig;
    try {
      final configString = preferences?.getString(configKey);
      if (configString != null && configString.isNotEmpty) {
        final configMap = json.decode(configString);
        prefsConfig = Config.compatibleFromJson(configMap);
      }
    } catch (e, stackTrace) {
      commonPrint.log('Failed to parse config from preferences: $e\n$stackTrace');
    }

    Config? selectedConfig;
    if (fileConfig != null && prefsConfig != null) {
      if (fileConfig.profiles.isEmpty && prefsConfig.profiles.isNotEmpty) {
        selectedConfig = prefsConfig;
        await saveConfig(prefsConfig);
      } else {
        selectedConfig = fileConfig;
      }
    } else {
      selectedConfig = fileConfig ?? prefsConfig;
      if (selectedConfig != null && fileConfig == null) {
        await saveConfig(selectedConfig);
      }
    }

    if (selectedConfig != null &&
        preferences?.getBool('autoLaunch') != selectedConfig.appSetting.autoLaunch) {
      await preferences?.setBool('autoLaunch', selectedConfig.appSetting.autoLaunch);
    }

    if (Platform.isMacOS &&
        selectedConfig != null &&
        preferences?.getBool('keepDockIcon') != selectedConfig.appSetting.keepDockIcon) {
      await preferences?.setBool('keepDockIcon', selectedConfig.appSetting.keepDockIcon);
    }

    return selectedConfig;
  }

  Future<bool> saveConfig(Config config) async {
    final preferences = await sharedPreferencesCompleter.future;
    await preferences?.setBool('autoLaunch', config.appSetting.autoLaunch);
    if (Platform.isMacOS) {
      await preferences?.setBool('keepDockIcon', config.appSetting.keepDockIcon);
    }

    final jsonStr = json.encode(config);

    try {
      await preferences?.setString(configKey, jsonStr);
    } catch (e) {
      commonPrint.log('Failed to mirror config to preferences: $e');
    }

    try {
      final configFilePath = await appPath.appConfigPath;
      final tempFile = File('$configFilePath.${DateTime.now().microsecondsSinceEpoch}.tmp');
      await tempFile.parent.create(recursive: true);
      await tempFile.writeAsString(jsonStr, flush: true);
      try {
        await tempFile.rename(configFilePath);
      } catch (_) {
        if (await tempFile.exists()) {
          await tempFile.copy(configFilePath);
          await tempFile.delete();
        }
      }
      return true;
    } catch (e, stackTrace) {
      commonPrint.log('Failed to save config to file: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> clearClashConfig() async {
    final preferences = await sharedPreferencesCompleter.future;
    preferences?.remove(clashConfigKey);
  }

  Future<void> clearPreferences() async {
    final sharedPreferencesIns = await sharedPreferencesCompleter.future;
    await sharedPreferencesIns?.clear();
    try {
      final file = File(await appPath.appConfigPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    try {
      final ipFile = File(await appPath.ipCacheFilePath);
      if (await ipFile.exists()) {
        await ipFile.delete();
      }
    } catch (_) {}
  }
}

final preferences = Preferences();
