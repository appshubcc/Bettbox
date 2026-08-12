// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:liquid_engine/liquid_engine.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('arch', allowed: ['amd64', 'arm64'], mandatory: true)
    ..addFlag('compatible', defaultsTo: false)
    ..addOption('env', defaultsTo: 'pre')
    ..addFlag('dev', defaultsTo: false);

  final args = parser.parse(arguments);
  final arch = args['arch'] as String;
  final compatible = args['compatible'] as bool;
  final isDev = args['dev'] as bool;

  final desc = compatible ? '$arch-compatible' : arch;

  // 1. Get version from pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found.');
    exit(1);
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final versionMatch = RegExp(r'^version:\s*([^\s+]+)', multiLine: true).firstMatch(pubspecContent);
  if (versionMatch == null) {
    print('Error: Could not find version in pubspec.yaml.');
    exit(1);
  }
  final appVersion = versionMatch.group(1)!;
  print('App Version: $appVersion');

  final outputBaseName = 'Bettbox-$appVersion-windows-$desc-setup';

  // 2. Parse make_config.yaml
  final configFile = File('windows/packaging/exe/make_config.yaml');
  if (!configFile.existsSync()) {
    print('Error: make_config.yaml not found.');
    exit(1);
  }
  final configContent = configFile.readAsStringSync();
  final makeConfig = loadYaml(configContent) as YamlMap;

  // 3. Define directories
  final buildDirName = arch == 'arm64' ? 'arm64' : 'x64';
  final sourceDir = path.absolute('build/windows/$buildDirName/runner/Release');
  print('Source Directory: $sourceDir');
  if (!Directory(sourceDir).existsSync()) {
    print('Error: Source directory $sourceDir does not exist. Run flutter build first.');
    exit(1);
  }

  // 4. Map variables for Inno Setup template
  final coreExecutableName = isDev ? 'BettboxDevCore.exe' : 'BettboxCore.exe';
  final helperExecutableName = isDev ? 'BettboxDevHelperService.exe' : 'BettboxHelperService.exe';
  final helperServiceName = isDev ? 'BettboxDevHelperService' : 'BettboxHelperService';
  final taskName = isDev ? 'Bettbox Dev' : 'Bettbox';
  
  // Format locales - resolve file paths to absolute to avoid Inno Setup relative path issues
  final packagingDir = path.absolute('windows/packaging/exe');
  final locales = [];
  if (makeConfig['locales'] != null) {
    for (var locale in makeConfig['locales']) {
      final fileVal = locale['file'] as String?;
      locales.add({
        'lang': locale['lang'],
        // Extract just the filename and resolve against the packaging directory
        'file': fileVal != null ? path.join(packagingDir, path.basename(fileVal)) : null,
      });
    }
  }

  final variables = {
    'APP_ID': makeConfig['app_id'],
    'APP_NAME': makeConfig['app_name'],
    'APP_VERSION': appVersion,
    'EXECUTABLE_NAME': makeConfig['executable_name'] ?? 'Bettbox.exe',
    'DISPLAY_NAME': makeConfig['display_name'] ?? 'Bettbox',
    'PUBLISHER_NAME': makeConfig['publisher'] ?? 'appshub.cc',
    'ARCH': arch == 'arm64' ? 'arm64' : 'x64',
    'PUBLISHER_URL': makeConfig['publisher_url'] ?? 'https://github.com/appshubcc/Bettbox',
    'CREATE_DESKTOP_ICON': true,
    'LAUNCH_AT_STARTUP': true,
    'INSTALL_DIR_NAME': '{autopf64}\\${makeConfig['display_name'] ?? 'Bettbox'}',
    'SOURCE_DIR': sourceDir,
    'OUTPUT_BASE_FILENAME': outputBaseName,
    'LOCALES': locales,
    'SETUP_ICON_FILE': path.absolute('windows/runner/resources/app_icon.ico'),
    'PRIVILEGES_REQUIRED': makeConfig['privileges_required'] ?? 'admin',
    'CORE_EXECUTABLE_NAME': coreExecutableName,
    'HELPER_EXECUTABLE_NAME': helperExecutableName,
    'HELPER_SERVICE_NAME': helperServiceName,
    'TASK_NAME': taskName,
  };

  // 5. Render Liquid template
  final templateFile = File('windows/packaging/exe/inno_setup.iss');
  if (!templateFile.existsSync()) {
    print('Error: inno_setup.iss template not found.');
    exit(1);
  }
  final templateContent = templateFile.readAsStringSync();

  final context = Context.create();
  context.variables = variables;

  final template = Template.parse(
    context,
    Source.fromString(templateContent),
  );

  final renderedContent = '\uFEFF${await template.render(context)}';
  final tempIssFile = File('windows/packaging/exe/temp_setup.iss');
  tempIssFile.writeAsBytesSync(utf8.encode(renderedContent));
  print('Generated temp_setup.iss');

  // 6. Run ISCC.exe
  final isccPath = 'C:\\Program Files (x86)\\Inno Setup 6\\ISCC.exe';
  if (!File(isccPath).existsSync()) {
    print('Error: Inno Setup 6 is not installed at $isccPath');
    tempIssFile.deleteSync();
    exit(1);
  }

  print('Running ISCC.exe...');
  final processResult = await Process.run(isccPath, [tempIssFile.path]);
  print(processResult.stdout);
  print(processResult.stderr);

  // Clean up temp ISS file
  if (tempIssFile.existsSync()) {
    tempIssFile.deleteSync();
  }

  if (processResult.exitCode != 0) {
    print('Error: ISCC.exe compilation failed.');
    exit(processResult.exitCode);
  }

  // 7. Move generated installer to dist/
  final generatedInstallerPath = path.join('windows/packaging/exe', '$outputBaseName.exe');
  final generatedInstallerFile = File(generatedInstallerPath);
  if (!generatedInstallerFile.existsSync()) {
    print('Error: Generated installer not found at $generatedInstallerPath');
    exit(1);
  }

  final distDir = Directory('dist');
  if (!distDir.existsSync()) {
    distDir.createSync(recursive: true);
  }

  final targetInstallerPath = path.join('dist', '$outputBaseName.exe');
  generatedInstallerFile.renameSync(targetInstallerPath);
  print('Successfully generated and moved installer to: $targetInstallerPath');
}
