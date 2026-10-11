import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_packager/src/makers/exe/make_exe_config.dart';
import 'package:liquid_engine/liquid_engine.dart';
import 'package:path/path.dart' as path;

const String _template = """
[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
ArchitecturesAllowed={{ARCH}}
ArchitecturesInstallIn64BitMode={{ARCH}}

[Languages]
{% for locale in LOCALES %}
{% if locale.lang == 'en' %}Name: "english"; MessagesFile: "compiler:Default.isl"{% endif %}
{% if locale.lang == 'hy' %}Name: "armenian"; MessagesFile: "compiler:Languages\\Armenian.isl"{% endif %}
{% if locale.lang == 'bg' %}Name: "bulgarian"; MessagesFile: "compiler:Languages\\Bulgarian.isl"{% endif %}
{% if locale.lang == 'ca' %}Name: "catalan"; MessagesFile: "compiler:Languages\\Catalan.isl"{% endif %}
{% if locale.lang == 'zh' %}
Name: "chineseSimplified"; MessagesFile: {% if locale.file %}{{ locale.file }}{% else %}"compiler:Languages\\ChineseSimplified.isl"{% endif %}
{% endif %}
{% if locale.lang == 'co' %}Name: "corsican"; MessagesFile: "compiler:Languages\\Corsican.isl"{% endif %}
{% if locale.lang == 'cs' %}Name: "czech"; MessagesFile: "compiler:Languages\\Czech.isl"{% endif %}
{% if locale.lang == 'da' %}Name: "danish"; MessagesFile: "compiler:Languages\\Danish.isl"{% endif %}
{% if locale.lang == 'nl' %}Name: "dutch"; MessagesFile: "compiler:Languages\\Dutch.isl"{% endif %}
{% if locale.lang == 'fi' %}Name: "finnish"; MessagesFile: "compiler:Languages\\Finnish.isl"{% endif %}
{% if locale.lang == 'fr' %}Name: "french"; MessagesFile: "compiler:Languages\\French.isl"{% endif %}
{% if locale.lang == 'de' %}Name: "german"; MessagesFile: "compiler:Languages\\German.isl"{% endif %}
{% if locale.lang == 'he' %}Name: "hebrew"; MessagesFile: "compiler:Languages\\Hebrew.isl"{% endif %}
{% if locale.lang == 'is' %}Name: "icelandic"; MessagesFile: "compiler:Languages\\Icelandic.isl"{% endif %}
{% if locale.lang == 'it' %}Name: "italian"; MessagesFile: "compiler:Languages\\Italian.isl"{% endif %}
{% if locale.lang == 'ja' %}Name: "japanese"; MessagesFile: "compiler:Languages\\Japanese.isl"{% endif %}
{% if locale.lang == 'no' %}Name: "norwegian"; MessagesFile: "compiler:Languages\\Norwegian.isl"{% endif %}
{% if locale.lang == 'pl' %}Name: "polish"; MessagesFile: "compiler:Languages\\Polish.isl"{% endif %}
{% if locale.lang == 'pt' %}Name: "portuguese"; MessagesFile: "compiler:Languages\\Portuguese.isl"{% endif %}
{% if locale.lang == 'ru' %}Name: "russian"; MessagesFile: "compiler:Languages\\Russian.isl"{% endif %}
{% if locale.lang == 'sk' %}Name: "slovak"; MessagesFile: "compiler:Languages\\Slovak.isl"{% endif %}
{% if locale.lang == 'sl' %}Name: "slovenian"; MessagesFile: "compiler:Languages\\Slovenian.isl"{% endif %}
{% if locale.lang == 'es' %}Name: "spanish"; MessagesFile: "compiler:Languages\\Spanish.isl"{% endif %}
{% if locale.lang == 'tr' %}Name: "turkish"; MessagesFile: "compiler:Languages\\Turkish.isl"{% endif %}
{% if locale.lang == 'uk' %}Name: "ukrainian"; MessagesFile: "compiler:Languages\\Ukrainian.isl"{% endif %}
{% endfor %}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,{{DISPLAY_NAME}}}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if LAUNCH_AT_STARTUP != true %}unchecked{% else %}checkedonce{% endif %}
[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
Name: "{userstartup}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; WorkingDir: "{app}"; Tasks: launchAtStartup
[Run]
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: {% if PRIVILEGES_REQUIRED == 'admin' %}runascurrentuser{% endif %} nowait postinstall skipifsilent
""";

class InnoSetupScript {
  InnoSetupScript({
    required this.makeConfig,
  });

  factory InnoSetupScript.fromMakeConfig(MakeExeConfig makeConfig) {
    return InnoSetupScript(
      makeConfig: makeConfig,
    );
  }

  final MakeExeConfig makeConfig;

  Future<File> createFile() async {
    final isDev = makeConfig.flavor == 'dev' ||
        (makeConfig.displayName?.contains('Dev') ?? false);
    // [Gamebox] 安装进系统的文件名。上游是 Bettbox*。
    final coreExecutableName = isDev ? 'GameboxDevCore.exe' : 'GameboxCore.exe';
    final helperExecutableName = isDev
        ? 'GameboxDevHelperService.exe'
        : 'GameboxHelperService.exe';
    final helperServiceName = isDev
        ? 'GameboxDevHelperService'
        : 'GameboxHelperService';
    final helperPipeName = isDev
        ? r'\\.\pipe\GameboxDev.Helper'
        : r'\\.\pipe\Gamebox.Helper';
    final taskName = isDev ? 'Gamebox Dev' : 'Gamebox';
    Map<String, dynamic> variables = {
      'APP_ID': makeConfig.appId,
      'APP_NAME': makeConfig.appName,
      'APP_VERSION': makeConfig.appVersion.toString(),
      'EXECUTABLE_NAME':
          makeConfig.executableName ?? makeConfig.defaultExecutableName,
      'DISPLAY_NAME': makeConfig.displayName,
      'PUBLISHER_NAME': makeConfig.publisherName,
      'ARCH': makeConfig.arch ?? 'x64',
      'PUBLISHER_URL': makeConfig.publisherUrl,
      'CREATE_DESKTOP_ICON': makeConfig.createDesktopIcon,
      'LAUNCH_AT_STARTUP': makeConfig.launchAtStartup,
      'INSTALL_DIR_NAME':
          makeConfig.installDirName ?? makeConfig.defaultInstallDirName,
      'SOURCE_DIR': makeConfig.sourceDir,
      'OUTPUT_BASE_FILENAME': makeConfig.outputBaseFileName,
      'LOCALES': makeConfig.locales,
      'SETUP_ICON_FILE': makeConfig.setupIconFile ?? '',
      'PRIVILEGES_REQUIRED': makeConfig.privilegesRequired ?? 'none',
      'CORE_EXECUTABLE_NAME': coreExecutableName,
      'HELPER_EXECUTABLE_NAME': helperExecutableName,
      'HELPER_SERVICE_NAME': helperServiceName,
      'HELPER_PIPE_NAME': helperPipeName,
      'TASK_NAME': taskName,
    }..removeWhere((key, value) => value == null);

    Context context = Context.create();
    context.variables = variables;

    String scriptTemplate = _template;
    if (makeConfig.scriptTemplate != null) {
      File scriptTemplateFile = File(
        path.join(
          'windows/packaging/exe/',
          makeConfig.scriptTemplate!,
        ),
      );
      scriptTemplate = scriptTemplateFile.readAsStringSync();
    }

    Template template = Template.parse(
      context,
      Source.fromString(scriptTemplate),
    );

    String content = '\uFEFF${await template.render(context)}';
    File file = File('${makeConfig.packagingDirectory.path}.iss');

    file.writeAsBytesSync(utf8.encode(content));
    return file;
  }
}
