import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';

class MakeRPMConfig extends MakeConfig {
  MakeRPMConfig({
    // Desktop file
    required this.displayName,
    this.startupNotify = true,
    this.actions,
    this.categories,
    this.genericName,
    this.icon,
    this.keywords,
    this.supportedMimeType,

    // Spec file
    this.summary,
    this.group,
    this.vendor,
    this.packager,
    this.packagerEmail,
    this.license,
    this.url,
    this.buildArch,
    this.requires,
    this.buildRequires,
    this.description,
    this.prep,
    this.build,
    this.install,
    this.postun,
    this.files,
    this.defattr,
    this.attr,
    this.changelog,
  });

  factory MakeRPMConfig.fromJson(Map<String, dynamic> json) {
    return MakeRPMConfig(
      displayName: json['display_name'] as String,
      icon: json['icon'] as String?,
      genericName: json['generic_name'] as String?,
      startupNotify: json['startup_notify'] as bool?,
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>(),
      supportedMimeType: (json['supported_mime_type'] as List<dynamic>?)
          ?.cast<String>(),
      actions: (json['actions'] as List<dynamic>?)?.cast<String>(),
      categories: (json['categories'] as List<dynamic>?)?.cast<String>(),
      summary: json['summary'] as String?,
      group: json['group'] as String?,
      vendor: json['vendor'] as String?,
      packager: json['packager'] as String?,
      packagerEmail: json['packagerEmail'] as String?,
      license: json['license'] as String?,
      url: json['url'] as String?,
      buildArch: json['build_arch'] as String?,
      requires: (json['requires'] as List<dynamic>?)?.cast<String>(),
      buildRequires: (json['build_requires'] as List<dynamic>?)?.cast<String>(),
      description: json['description'] as String?,
      prep: json['prep'] as String?,
      build: json['build'] as String?,
      install: json['install'] as String?,
      postun: json['postun'] as String?,
      files: json['files'] as String?,
      defattr: json['defattr'] as String?,
      attr: json['attr'] as String?,
      changelog: json['changelog'] as String?,
    );
  }

  String displayName;
  String? icon;
  String? genericName;
  bool? startupNotify;
  List<String>? keywords;
  List<String>? supportedMimeType;
  List<String>? actions;
  List<String>? categories;

  //RPM preamble Spec file fields
  String? summary;
  String? group;
  String? vendor;
  String? packager;
  String? packagerEmail;
  String? license;
  String? url;
  String? buildArch;
  List<String>? requires;
  List<String>? buildRequires;
  //RPM postamble Spec file fields
  String? description;
  String? prep;
  String? build;
  String? install;
  String? postun;
  String? files;
  String? defattr;
  String? attr;
  String? changelog;

  @override
  Map<String, dynamic> toJson() {
    return {
      'SPEC': {
        'preamble': {
          'Name': appName,
          'Version': appVersion.toString(),
          'Release':
              "${appVersion.build.isNotEmpty ? appVersion.build.first : "1"}%{?dist}",
          'Summary': summary ?? pubspec.description,
          'Group': group,
          'Vendor': vendor,
          'Packager': packagerEmail != null
              ? '$packager <$packagerEmail>'
              : packager,
          'License': license,
          'URL': url,
          'Requires': requires?.join(', '),
          'BuildRequires': buildRequires?.join(', '),
          'BuildArch': buildArch ?? 'x86_64',
        }..removeWhere((key, value) => value == null),
        'body': {
          '%description': description ?? pubspec.description,
          '%install':
              install ??
              [
                'mkdir -p %{buildroot}%{_bindir}',
                'mkdir -p %{buildroot}%{_datadir}/%{name}',
                'mkdir -p %{buildroot}%{_datadir}/applications',
                'mkdir -p %{buildroot}%{_datadir}/pixmaps',
                'cp -r %{name}/* %{buildroot}%{_datadir}/%{name}',
                'ln -s %{_datadir}/%{name}/%{name} %{buildroot}%{_bindir}/%{name}',
                'cp -r %{name}.desktop %{buildroot}%{_datadir}/applications',
                'cp -r %{name}.png %{buildroot}%{_datadir}/pixmaps',
                'update-mime-database %{_datadir}/mime &> /dev/null || :',
              ].join('\n'),
          '%postun':
              postun ??
              [
                'update-mime-database %{_datadir}/mime &> /dev/null || :',
              ].join('\n'),
          '%files':
              files ??
              [
                if (defattr != null) '%defattr $defattr',
                if (attr != null) attr,
                '%{_bindir}/%{name}',
                '%{_datadir}/%{name}',
                '%{_datadir}/applications/%{name}.desktop',
                if (icon != null) '%{_datadir}/pixmaps/%{name}.png',
              ].join('\n'),
        }..removeWhere((key, value) => value == null),
      },
      'DESKTOP': {
        'Type': 'Application',
        'Version': appVersion.toString(),
        'Name': displayName,
        'GenericName': genericName,
        'Icon': appName,
        'Exec': '$appName %U',
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

    final preamble = [
      '%define _build_id_links none',
      ...(json['SPEC']['preamble'] as Map).entries.map(
        (e) => '${e.key}: ${e.value}',
      ),
    ].join('\n');
    final body = (json['SPEC']['body'] as Map).entries
        .map((e) {
          return '${e.key}\n${e.value}\n';
        })
        .join('\n');
    final inlineBody =
        (json['SPEC']['inline-body'] as Map?)?.entries
            .map((e) {
              return '${e.key}${e.value}\n';
            })
            .join('\n') ??
        '';

    final desktopFile = [
      '[Desktop Entry]',
      ...(json['DESKTOP'] as Map<String, dynamic>).entries.map(
        (e) => '${e.key}=${e.value}',
      ),
    ].join('\n');
    final map = {
      'DESKTOP': desktopFile,
      'SPEC': '$preamble\n\n$body\n\n$inlineBody',
    };
    return Map.castFrom<String, String?, String, String>(map);
  }
}

class MakeRpmConfigLoader extends DefaultMakeConfigLoader {
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
    return MakeRPMConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}
