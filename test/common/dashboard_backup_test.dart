import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:bett_box/common/dashboard_backup.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void expectLayout(DashboardLayout actual, DashboardLayout expected) {
  expect(actual.widgets, expected.widgets);
  expect(actual.sizes, expected.sizes);
  expect(actual.updatedAt, expected.updatedAt);
}

void main() {
  final older = DateTime.utc(2026, 1, 1);
  final newer = DateTime.utc(2026, 1, 2);
  final phone = AppSettingProps(
    mobileDashboardWidgets: const [DashboardWidget.memoryInfo],
    mobileDashboardSizes: const {'memoryInfo': 'tall'},
    mobileDashboardUpdatedAt: newer,
    desktopDashboardUpdatedAt: older,
    dashboardTitle: 'Phone',
  );
  final desktop = AppSettingProps(
    desktopDashboardWidgets: const [DashboardWidget.networkSpeed],
    desktopDashboardSizes: const {'networkSpeed': 'wide'},
    mobileDashboardUpdatedAt: older,
    desktopDashboardUpdatedAt: newer,
    dashboardTitle: 'Desktop',
  );

  test('alternating uploads keep the newest order and sizes per platform', () {
    final desktopUpload = desktop.mergeDashboardLayouts(phone, mobile: false);
    final phoneUpload = phone.mergeDashboardLayouts(
      desktopUpload,
      mobile: true,
    );
    for (final upload in [desktopUpload, phoneUpload]) {
      expectLayout(
        upload.dashboardLayout(mobile: true),
        phone.dashboardLayout(mobile: true),
      );
      expectLayout(
        upload.dashboardLayout(mobile: false),
        desktop.dashboardLayout(mobile: false),
      );
    }
    expect(desktopUpload.dashboardTitle, 'Desktop');
    expect(phoneUpload.dashboardTitle, 'Phone');
  });

  test('restore keeps a newer local layout and uses backup app settings', () {
    final restored = phone.mergeDashboardLayouts(
      desktop,
      mobile: true,
      restoring: true,
    );
    expectLayout(
      restored.dashboardLayout(mobile: true),
      phone.dashboardLayout(mobile: true),
    );
    expectLayout(
      restored.dashboardLayout(mobile: false),
      desktop.dashboardLayout(mobile: false),
    );
    expect(restored.dashboardWidgets, phone.mobileDashboardWidgets);
    expect(restored.dashboardTitle, 'Desktop');
  });

  test(
    'a size edit stamps only the edited platform and no-op preserves time',
    () {
      final edited = phone.updateDashboardLayout(
        mobile: true,
        widgets: phone.mobileDashboardWidgets,
        sizes: const {'memoryInfo': 'small'},
      );
      expect(edited.mobileDashboardUpdatedAt!.isAfter(newer), isTrue);
      expect(edited.desktopDashboardUpdatedAt, older);
      expect(
        edited.updateDashboardLayout(
          mobile: true,
          widgets: edited.mobileDashboardWidgets,
        ),
        same(edited),
      );
    },
  );

  test(
    'reads both layouts and their timestamps from one encrypted ZIP',
    () async {
      final merged = desktop.mergeDashboardLayouts(phone, mobile: false);
      final config = jsonEncode({'appSetting': merged.toJson()});
      final archive = Archive()
        ..addFile(ArchiveFile.string('config.json', config));
      final bytes = ZipEncoder(password: 'test').encodeBytes(archive);
      final settings = (await readBackupDashboardSettingsInBackground(
        bytes,
        password: 'test',
      ))!;
      expectLayout(
        settings.dashboardLayout(mobile: true),
        merged.dashboardLayout(mobile: true),
      );
      expectLayout(
        settings.dashboardLayout(mobile: false),
        merged.dashboardLayout(mobile: false),
      );
      expect(
        () => readBackupDashboardSettings(bytes, password: ''),
        throwsFormatException,
      );
    },
  );

  test(
    'legacy backup uses the shared widget list without inventing timestamps',
    () {
      final archive = Archive()
        ..addFile(
          ArchiveFile.string(
            'config.json',
            '{"appSetting":{"dashboardWidgets":["memoryInfo"]}}',
          ),
        );
      final settings = readBackupDashboardSettings(
        ZipEncoder().encodeBytes(archive),
        password: '',
      )!;
      expect(settings.mobileDashboardWidgets, [DashboardWidget.memoryInfo]);
      expect(settings.desktopDashboardWidgets, [DashboardWidget.memoryInfo]);
      expect(settings.mobileDashboardUpdatedAt, isNull);
      expect(settings.desktopDashboardUpdatedAt, isNull);
    },
  );
}
