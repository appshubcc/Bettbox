import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/api/symbolic_icon.dart';

// format of make_config for deb
/*
# the name used to display in the OS. Specifically desktop
# entry name
display_name: Hola Amigos

# package name for debian/apt repository
# the name should be all lowercase with -+.
package_name: hola-amigos

maintainer:
  name: Gamer Boy 69
  email: rickastley@gmail.lol

co_authors:
  - name: Mir Jafar
    email: contributor@gmail.com

# enum options -> required, important, standard, optional, extra
# refer: https://www.debian.org/doc/debian-policy/ch-archive.html#s-priorities
priority: optional

# enum options: admin, cli-mono, comm, database, debug, devel, doc, editors, education, electronics, embedded, fonts, games, gnome, gnu-r, gnustep, graphics, hamradio, haskell, httpd, interpreters, introspection, java, javascript, kde, kernel, libdevel, libs, lisp, localization, mail, math, metapackages, misc, net, news, ocaml, oldlibs, otherosfs, perl, php, python, ruby, rust, science, shells, sound, tasks, tex, text, utils, vcs, video, web, x11, xfce, zope
# refer: https://www.debian.org/doc/debian-policy/ch-archive.html#s-subsections
section: x11

# the size of binary in kilobyte
installed_size: 24400

# direct dependencies required by the application
# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
dependencies:
  - libkeybinder-3.0-0 (>= 0.3.2)

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
build_dependencies_indep:
  - texinfo

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
build_dependencies:
  - kernel-headers-2.2.10 [!hurd-i386]
  - gnumach-dev [hurd-i386]
  - libluajit5.1-dev [i386 amd64 kfreebsd-i386 armel armhf powerpc mips]

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
recommended_dependencies:
  - neofetch

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
suggested_dependencies:
  - libkeybinder-3.0-0 (>= 0.3.2)

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
enhances:
  - spotube

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
pre_dependencies:
  - libc6

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#packages-which-break-other-packages-breaks
breaks:
  - libspotify (<< 3.0.0)

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#conflicting-binary-packages-conflicts
conflicts:
  - spotify

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#virtual-packages-provides
provides:
  - libx11

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#overwriting-files-and-replacing-packages-replaces
replaces:
  - spotify

essential: false

postinstall_scripts:
  - echo `Installed my awesome app`
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

class MakeDebConfig extends MakeLinuxPackageConfig {
  MakeDebConfig({
    required this.displayName,
    required this.packageName,
    required this.installedSize,
    required this.maintainer,
    this.startupNotify = true,
    this.essential = false,
    List<String>? postinstallScripts,
    List<String>? postuninstallScripts,
    this.priority = 'optional',
    this.section = 'x11',
    this.actions,
    this.breaks,
    this.buildDependencies,
    this.buildDependenciesIndep,
    this.suggestedDependencies,
    this.categories,
    this.coAuthors,
    this.dependencies,
    this.enhances,
    this.genericName,
    this.icon,
    this.keywords,
    this.preDependencies,
    this.provides,
    this.recommendedDependencies,
    this.replaces,
    this.conflicts,
    this.supportedMimeType,
    this.iconsSymbolic,
  })  : _postinstallScripts = postinstallScripts ?? [],
        _postuninstallScripts = postuninstallScripts ?? [];

  factory MakeDebConfig.fromJson(Map<String, dynamic> map) {
    return MakeDebConfig(
      displayName: map['display_name'],
      packageName: map['package_name'],
      maintainer:
          "${map['maintainer']['name']} <${map['maintainer']['email']}>",
      coAuthors: (map['co_authors'] as List?)
          ?.map((e) => "${e['name']} <${e['email']}>")
          .toList(),
      priority: map['priority'],
      section: map['section'],
      dependencies: map['dependencies'] != null
          ? List.castFrom<dynamic, String>(map['dependencies'])
          : null,
      buildDependenciesIndep: map['build_dependencies_indep'] != null
          ? List.castFrom<dynamic, String>(map['build_dependencies_indep'])
          : null,
      buildDependencies: map['build_dependencies'] != null
          ? List.castFrom<dynamic, String>(map['build_dependencies'])
          : null,
      recommendedDependencies: map['recommended_dependencies'] != null
          ? List.castFrom<dynamic, String>(map['recommended_dependencies'])
          : null,
      suggestedDependencies: map['suggested_dependencies'] != null
          ? List.castFrom<dynamic, String>(map['suggested_dependencies'])
          : null,
      enhances: map['enhances'] != null
          ? List.castFrom<dynamic, String>(map['enhances'])
          : null,
      preDependencies: map['pre_dependencies'] != null
          ? List.castFrom<dynamic, String>(map['pre_dependencies'])
          : null,
      breaks: map['breaks'] != null
          ? List.castFrom<dynamic, String>(map['breaks'])
          : null,
      conflicts: map['conflicts'] != null
          ? List.castFrom<dynamic, String>(map['conflicts'])
          : null,
      provides: map['provides'] != null
          ? List.castFrom<dynamic, String>(map['provides'])
          : null,
      replaces: map['replaces'] != null
          ? List.castFrom<dynamic, String>(map['replaces'])
          : null,
      postinstallScripts: map['postinstall_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postinstall_scripts'])
          : null,
      postuninstallScripts: map['postuninstall_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postuninstall_scripts'])
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
      essential: map['essential'],
      genericName: map['generic_name'],
      startupNotify: map['startup_notify'],
      installedSize: map['installed_size'],
      icon: map['icon'],
      iconsSymbolic: SymbolicIcon.fromJsonList(map['icons_symbolic']),
    );
  }

  String displayName;
  String packageName;
  String maintainer;
  String priority;
  String section;
  int installedSize;
  bool? essential;
  String? icon;
  String? genericName;
  bool? startupNotify;
  List<String>? coAuthors;
  List<String>? dependencies;
  List<String>? buildDependenciesIndep;
  List<String>? buildDependencies;
  List<String>? recommendedDependencies;
  List<String>? suggestedDependencies;
  List<String>? enhances;
  List<String>? preDependencies;
  List<String>? breaks;
  List<String>? conflicts;
  List<String>? provides;
  List<String>? replaces;
  List<String> _postinstallScripts;
  List<String> _postuninstallScripts;
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
        ..._postuninstallScripts,
      ];

  @override
  Map<String, dynamic> toJson() {
    return {
      'CONTROL': {
        'Maintainer': maintainer,
        'Package': packageName,
        'Version': appVersion.toString(),
        'Section': section,
        'Priority': priority,
        'Architecture': _getArchitecture(),
        'Essential':
            essential != null ? (essential == true ? 'yes' : 'no') : null,
        'Installed-Size': installedSize,
        'Description': pubspec.description,
        'Homepage': pubspec.homepage,
        'Depends': dependencies?.join(', '),
        'Build-Depends-Indep': buildDependenciesIndep?.join(', '),
        'Build-Depends': buildDependencies?.join(', '),
        'Pre-Depends': preDependencies?.join(', '),
        'Recommends': recommendedDependencies?.join(', '),
        'Suggests': suggestedDependencies?.join(', '),
        'Enhances': enhances?.join(', '),
        'Breaks': breaks?.join(', '),
        'Conflicts': conflicts?.join(', '),
        'Provides': provides?.join(', '),
        'Replaces': replaces?.join(', '),
        'Uploaders': coAuthors?.join(', '),
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
    final controlFile =
        '${(json['CONTROL'] as Map<String, dynamic>).entries.map(
              (e) => '${e.key}: ${e.value}',
            ).join('\n')}\n';

    final desktopFile = [
      '[Desktop Entry]',
      ...(json['DESKTOP'] as Map<String, dynamic>).entries.map(
            (e) => '${e.key}=${e.value}',
          ),
    ].join('\n');
    final map = {
      'CONTROL': controlFile,
      'DESKTOP': desktopFile,
      'postinst': postinstallScripts.isNotEmpty
          ? [
              '#!/usr/bin/env sh',
              ...postinstallScripts,
              'exit 0',
            ].join('\n')
          : null,
      'postrm': postuninstallScripts.isNotEmpty
          ? [
              '#!/usr/bin/env sh',
              ...postuninstallScripts,
              'exit 0',
            ].join('\n')
          : null,
    }..removeWhere((key, value) => value == null);
    return Map.castFrom<String, String?, String, String>(map);
  }
}

class MakeDebConfigLoader extends DefaultMakeConfigLoader {
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
    return MakeDebConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}

String _getArchitecture() {
  final result = Process.runSync('uname', ['-m']);
  if ('${result.stdout}'.trim() == 'aarch64') {
    return 'arm64';
  } else {
    return 'amd64';
  }
}
