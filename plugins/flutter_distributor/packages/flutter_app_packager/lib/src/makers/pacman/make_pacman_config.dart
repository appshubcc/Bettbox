import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/api/symbolic_icon.dart';

// Ported from https://gist.github.com/Earnestly/bebad057f40a662b5cc3
// format of make_config for pacman
/*
# the name used to display in the OS. Specifically desktop
# entry name
display_name: Hola Amigos

# package name for arch repository
# the name should be all lowercase with -+.
package_name: hola-amigos

licenses:
  - MIT

maintainer:
  name: Gamer Boy 69
  email: rickastley@gmail.lol

# the size of binary in kilobyte
installed_size: 24400

# direct dependencies required by the application
# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
dependencies:
  - mysupercooldep

# optional dependencies not so much required by the application
# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
optional_dependencies:
  - iamalwaysoptional

# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
provides:
  - whatsup

# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
options:
  - zipman

# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
conflicts:
  - libwhatsup

# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
replaces:
  - yourdep

# refer: https://man.archlinux.org/man/PKGBUILD.5#OPTIONS_AND_DIRECTIVES
provides:
  - libx11

postinstall_scripts:
  - echo `Installed my awesome app`
postupgrade_scripts:
  - echo `Supercharger my awesome app`
postuninstall_scripts:
  - echo `Surprised Pickachu face`


# application icon path relative to project url
icon: assets/logo.png

keywords:
  - Hello
  - World
  - Test
  - Application

# a name to categorize the app into a section of application
generic_name: Hobby Application

# supported mime types that can be opened using this application
supported_mime_type:
  - audio/mpeg

# shown when right clicked the desktop entry icons
actions:
  - Gallery
  - Create

# the categories the application belong to
# refer: https://specifications.freedesktop.org/menu-spec/latest/
categories:
  - Music
  - Media

# let OS know if the application can be run on start_up. If it's false 
# the application will deny to the OS if it was added as a start_up 
# application
startup_notify: true  
*/

class MakePacmanConfig extends MakeLinuxPackageConfig {
  MakePacmanConfig({
    required this.displayName,
    required this.packageName,
    this.installedSize,
    required this.maintainer,
    this.packageRelease = 1,
    List<String>? postinstallScripts,
    List<String>? postupgradeScripts,
    List<String>? postuninstallScripts,
    this.actions,
    this.categories,
    this.dependencies,
    this.genericName,
    this.optDependencies,
    this.options,
    this.startupNotify = false,
    this.groups = const ['default'],
    this.licenses = const ['unknown'],
    this.icon,
    this.metainfo,
    this.keywords,
    this.provides,
    this.conflicts,
    this.replaces,
    this.supportedMimeType,
    this.iconsSymbolic,
  })  : _postinstallScripts = postinstallScripts ?? [],
        _postupgradeScripts = postupgradeScripts ?? [],
        _postremoveScripts = postuninstallScripts ?? [];

  factory MakePacmanConfig.fromJson(Map<String, dynamic> map) {
    return MakePacmanConfig(
      displayName: map['display_name'],
      packageName: map['package_name'], //
      packageRelease: int.tryParse(map['package_release'] ?? '1') ?? 1,
      maintainer:
          "${map['maintainer']['name']} <${map['maintainer']['email']}>",
      dependencies: map['dependencies'] != null
          ? List.castFrom<dynamic, String>(map['dependencies'])
          : null,
      conflicts: map['conflicts'] != null
          ? List.castFrom<dynamic, String>(map['conflicts'])
          : null,
      replaces: map['replaces'] != null
          ? List.castFrom<dynamic, String>(map['replaces'])
          : null,
      options: map['options'] != null
          ? List.castFrom<dynamic, String>(map['options'])
          : null,
      optDependencies: map['optional_dependencies'] != null
          ? List.castFrom<dynamic, String>(map['optional_dependencies'])
          : null,
      licenses: map['licenses'] != null
          ? List.castFrom<dynamic, String>(map['licenses'])
          : ['unknown'],
      groups: map['groups'] != null
          ? List.castFrom<dynamic, String>(map['groups'])
          : ['default'],
      provides: map['provides'] != null
          ? List.castFrom<dynamic, String>(map['provides'])
          : null,
      postinstallScripts: map['postinstall_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postinstall_scripts'])
          : null,
      postuninstallScripts: map['postuninstall_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postuninstall_scripts'])
          : null,
      postupgradeScripts: map['postupgrade_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postupgrade_scripts'])
          : null,
      keywords: map['keywords'] != null
          ? List.castFrom<dynamic, String>(map['keywords'])
          : null,
      supportedMimeType: map['supported_mime_type'] != null
          ? List.castFrom<dynamic, String>(map['supported_mime_type'])
          : null,
      actions: map['actions'] != null
          ? List.castFrom<dynamic, String>(map['actions'])
          : null,
      categories: map['categories'] != null
          ? List.castFrom<dynamic, String>(map['categories'])
          : null,
      startupNotify: map['startup_notify'],
      genericName: map['generic_name'],
      installedSize: map['installed_size'],
      icon: map['icon'],
      metainfo: map['metainfo'],
      iconsSymbolic: SymbolicIcon.fromJsonList(map['icons_symbolic']),
    );
  }

  String displayName;
  String packageName;
  String maintainer;
  int packageRelease;
  int? installedSize;
  List<String> licenses;
  List<String> groups;
  String? icon;
  String? metainfo;
  String? genericName;
  bool startupNotify;
  List<String>? options;
  List<String>? dependencies;
  List<String>? optDependencies;
  List<String>? conflicts;
  List<String>? replaces;
  List<String>? provides;
  List<String> _postinstallScripts;
  List<String> _postupgradeScripts;
  List<String> _postremoveScripts;
  List<String>? keywords;
  List<String>? supportedMimeType;
  List<String>? actions;
  List<String>? categories;
  List<SymbolicIcon>? iconsSymbolic;

  List<String> get postinstallScripts => [
        'ln -s /usr/share/$appBinaryName/$appBinaryName /usr/bin/$appBinaryName',
        'chmod +x /usr/bin/$appBinaryName',
        ..._postinstallScripts,
      ];

  List<String> get postuninstallScripts => [
        'rm /usr/bin/$appBinaryName',
        ..._postremoveScripts,
      ];

  List<String> get postupgradeScripts => _postupgradeScripts;

  @override
  Map<String, dynamic> toJson() {
    return {
      'PKGINFO': {
        'pkgname': packageName,
        'pkgver': appVersion.toString(),
        'pkgdesc': pubspec.description,
        'packager': maintainer,
        'size': installedSize,
        'license': '(${licenses.join(', ')})',
        'groups': '(${groups.join(', ')})',
        'arch': '(${_getArchitecture()})',
        'url': pubspec.homepage,
        'options': options != null ? "(${options!.join(', ')})" : null,
        'depends':
            dependencies != null ? "(${dependencies!.join(', ')})" : null,
        'optdepends':
            optDependencies != null ? "(${optDependencies!.join(', ')})" : null,
        'conflicts': conflicts != null ? "(${conflicts!.join(', ')})" : null,
        'replaces': replaces != null ? "(${replaces!.join(', ')})" : null,
        'provides': provides != null ? "(${provides!.join(', ')})" : null,
      }..removeWhere((key, value) => value == null),
      'DESKTOP': {
        'Type': 'Application',
        'Version': appVersion.toString(),
        'Name': displayName,
        'GenericName': genericName,
        'Icon': appBinaryName,
        'Exec': '$appBinaryName %U',
        'Actions': actions != null && actions!.isNotEmpty
            ? '${actions!.join(';')};'
            : null,
        'MimeType': supportedMimeType != null && supportedMimeType!.isNotEmpty
            ? '${supportedMimeType!.join(';')};'
            : null,
        'Categories': categories != null && categories!.isNotEmpty
            ? '${categories!.join(';')};'
            : null,
        'Keywords': keywords != null && keywords!.isNotEmpty
            ? '${keywords!.join(';')};'
            : null,
        'StartupNotify': startupNotify,
      }..removeWhere((key, value) => value == null),
    };
  }

  Map<String, String> toFilesString() {
    final json = toJson();
    final pkginfoFile =
        '${(json['PKGINFO'] as Map<String, dynamic>).entries.map(
              (e) => '${e.key}=${e.value}',
            ).join('\n')}\n';
    final installFileMap = {
      'post_install': postinstallScripts.join('\n\t'),
      'post_upgrade':
          postupgradeScripts.isNotEmpty ? postupgradeScripts.join('\n') : null,
      'post_remove': postuninstallScripts.join('\n'),
    }..removeWhere((key, value) => value == null);

    final installFile = installFileMap.entries
        .map(
          (e) => '${e.key}() {\n\t${e.value}\n}',
        )
        .join('\n');

    final desktopFile = [
      '[Desktop Entry]',
      ...(json['DESKTOP'] as Map<String, dynamic>).entries.map(
            (e) => '${e.key}=${e.value}',
          ),
    ].join('\n');
    final map = {
      'PKGINFO': pkginfoFile,
      'DESKTOP': desktopFile,
      'INSTALL': installFile,
    };
    return map;
  }
}

class MakePacmanConfigLoader extends DefaultMakeConfigLoader {
  @override
  MakeConfig load(
    Map<String, dynamic>? arguments,
    Directory outputDirectory, {
    required Directory buildOutputDirectory,
    required List<File> buildOutputFiles,
  }) {
    final baseMakeConfig = super.load(
      arguments,
      outputDirectory,
      buildOutputDirectory: buildOutputDirectory,
      buildOutputFiles: buildOutputFiles,
    );
    final map = loadMakeConfigYaml(
      '$platform/packaging/$packageFormat/make_config.yaml',
    );
    return MakePacmanConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}

String _getArchitecture() {
  final result = Process.runSync('uname', ['-m']);
  if ('${result.stdout}'.trim() == 'aarch64') {
    return 'aarch64';
  } else {
    return 'x86_64';
  }
}
