import 'dart:convert';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:bett_box/common/archive.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter/foundation.dart';

typedef DashboardLayout = ({
  List<DashboardWidget> widgets,
  Map<String, String> sizes,
  DateTime? updatedAt,
});

Future<AppSettingProps?> readBackupDashboardSettingsInBackground(
  List<int> data, {
  required String password,
}) => Isolate.run(() => readBackupDashboardSettings(data, password: password));

AppSettingProps? readBackupDashboardSettings(
  List<int> data, {
  required String password,
}) {
  final input = InputMemoryStream(data);
  try {
    final (archive: archive, encrypted: _) = decodeBackupArchive(
      input,
      password.isEmpty ? null : password,
    );
    final config = archive.findFile('config.json');
    if (config == null) {
      throw const FormatException('WebDAV backup is missing config.json');
    }
    final decoded = jsonDecode(utf8.decode(config.content));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid WebDAV backup configuration');
    }
    final settings = decoded['appSetting'];
    if (settings == null) return null;
    if (settings is! Map<String, dynamic>) {
      throw const FormatException('Invalid WebDAV backup app settings');
    }
    final layoutSettings = {
      for (final key in [
        'dashboardWidgets',
        'mobileDashboardWidgets',
        'mobileDashboardSizes',
        'mobileDashboardUpdatedAt',
        'desktopDashboardWidgets',
        'desktopDashboardSizes',
        'desktopDashboardUpdatedAt',
      ])
        if (settings.containsKey(key)) key: settings[key],
    };
    if (layoutSettings.isEmpty) return null;
    return AppSettingProps.safeFromJson(layoutSettings);
  } on BackupPasswordException {
    throw const FormatException('Cannot decrypt the existing WebDAV backup');
  } finally {
    input.close();
  }
}

extension DashboardBackup on AppSettingProps {
  DashboardLayout dashboardLayout({required bool mobile}) => mobile
      ? (
          widgets: mobileDashboardWidgets,
          sizes: mobileDashboardSizes,
          updatedAt: mobileDashboardUpdatedAt,
        )
      : (
          widgets: desktopDashboardWidgets,
          sizes: desktopDashboardSizes,
          updatedAt: desktopDashboardUpdatedAt,
        );

  AppSettingProps updateDashboardLayout({
    required bool mobile,
    required List<DashboardWidget> widgets,
    Map<String, String>? sizes,
  }) {
    final current = dashboardLayout(mobile: mobile);
    final nextSizes = sizes ?? current.sizes;
    if (listEquals(current.widgets, widgets) &&
        mapEquals(current.sizes, nextSizes)) {
      return this;
    }
    final updatedAt = DateTime.now().toUtc();
    return mobile
        ? copyWith(
            dashboardWidgets: widgets,
            mobileDashboardWidgets: widgets,
            mobileDashboardSizes: nextSizes,
            mobileDashboardUpdatedAt: updatedAt,
          )
        : copyWith(
            dashboardWidgets: widgets,
            desktopDashboardWidgets: widgets,
            desktopDashboardSizes: nextSizes,
            desktopDashboardUpdatedAt: updatedAt,
          );
  }

  /// Takes each layout as a unit, including its tile order and sizes.
  AppSettingProps mergeDashboardLayouts(
    AppSettingProps other, {
    required bool mobile,
    bool restoring = false,
  }) {
    DashboardLayout choose({required bool forMobile}) {
      final local = dashboardLayout(mobile: forMobile);
      final incoming = other.dashboardLayout(mobile: forMobile);
      final localTime = local.updatedAt;
      final incomingTime = incoming.updatedAt;
      if (incomingTime != null && localTime == null) return incoming;
      if (incomingTime == null && localTime != null) return local;
      if (incomingTime != null && localTime != null) {
        if (incomingTime.isAfter(localTime)) return incoming;
        if (localTime.isAfter(incomingTime)) return local;
      }
      // During an explicit restore, use the selected backup for legacy/tied
      // layouts. During upload, prefer the device responsible for each layout.
      if (localTime == null && incomingTime == null) {
        final differs = !listEquals(local.widgets, incoming.widgets) ||
            !mapEquals(local.sizes, incoming.sizes);
        if (differs && (restoring || forMobile != mobile)) return incoming;
      }
      return local;
    }

    final mobileLayout = choose(forMobile: true);
    final desktopLayout = choose(forMobile: false);
    return (restoring ? other : this).copyWith(
      dashboardWidgets: mobile ? mobileLayout.widgets : desktopLayout.widgets,
      mobileDashboardWidgets: mobileLayout.widgets,
      mobileDashboardSizes: mobileLayout.sizes,
      mobileDashboardUpdatedAt: mobileLayout.updatedAt,
      desktopDashboardWidgets: desktopLayout.widgets,
      desktopDashboardSizes: desktopLayout.sizes,
      desktopDashboardUpdatedAt: desktopLayout.updatedAt,
    );
  }
}
