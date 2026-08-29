// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:device_info_plus_platform_interface/model/base_device_info.dart';

/// Device information for a Linux system.
///
/// See:
/// - https://www.freedesktop.org/software/systemd/man/os-release.html
/// - https://www.freedesktop.org/software/systemd/man/machine-id.html
class LinuxDeviceInfo implements BaseDeviceInfo {
  /// Constructs a LinuxDeviceInfo.
  LinuxDeviceInfo({
    required this.name,
    this.version,
    required this.id,
    this.idLike,
    this.versionCodename,
    this.versionId,
    required this.prettyName,
    this.buildId,
    this.variant,
    this.variantId,
    required this.machineId,
  });

  /// A string identifying the operating system, without a version component,
  /// and suitable for presentation to the user.
  ///
  /// Examples: 'Fedora', 'Debian GNU/Linux'.
  ///
  /// If not set, defaults to 'Linux'.
  final String name;

  /// A string identifying the operating system version, excluding any OS name
  /// information, possibly including a release code name, and suitable for
  /// presentation to the user.
  ///
  /// Examples: '17', '17 (Beefy Miracle)'.
  ///
  /// This field is optional and may be null on some systems.
  final String? version;

  /// A lower-case string identifying the operating system, excluding any
  /// version information and suitable for processing by scripts or usage in
  /// generated filenames.
  ///
  /// The ID contains no spaces or other characters outside of 0–9, a–z, '.',
  /// '_' and '-'.
  ///
  /// Examples: 'fedora', 'debian'.
  ///
  /// If not set, defaults to 'linux'.
  final String id;

  /// A space-separated list of operating system identifiers in the same syntax
  /// as the [id] value. It lists identifiers of operating systems that are
  /// closely related to the local operating system in regards to packaging
  /// and programming interfaces, for example listing one or more OS identifiers
  /// the local OS is a derivative from.
  ///
  /// Examples: an operating system with [id] 'centos', would list 'rhel' and
  /// 'fedora', and an operating system with [id] 'ubuntu' would list 'debian'.
  ///
  /// This field is optional and may be null on some systems.
  final List<String>? idLike;

  /// A lower-case string identifying the operating system release code name,
  /// excluding any OS name information or release version, and suitable for
  /// processing by scripts or usage in generated filenames.
  ///
  /// The codename contains no spaces or other characters outside of 0–9, a–z,
  /// '.', '_' and '-'.
  ///
  /// Examples: 'buster', 'xenial'.
  ///
  /// This field is optional and may be null on some systems.
  final String? versionCodename;

  /// A lower-case string identifying the operating system version, excluding
  /// any OS name information or release code name, and suitable for processing
  /// by scripts or usage in generated filenames.
  ///
  /// The version is mostly numeric, and contains no spaces or other characters
  /// outside of 0–9, a–z, '.', '_' and '-'.
  ///
  /// Examples: '17', '11.04'.
  ///
  /// This field is optional and may be null on some systems.
  final String? versionId;

  /// A pretty operating system name in a format suitable for presentation to
  /// the user. May or may not contain a release code name or OS version of some
  /// kind, as suitable.
  ///
  /// Examples: 'Fedora 17 (Beefy Miracle)'.
  ///
  /// If not set, defaults to 'Linux'.
  final String prettyName;

  /// A string uniquely identifying the system image used as the origin for a
  /// distribution (it is not updated with system updates). The field can be
  /// identical between different [versionId]s as `buildId` is an only a unique
  /// identifier to a specific version.
  ///
  /// Examples: '2013-03-20.3', '201303203'.
  ///
  /// This field is optional and may be null on some systems.
  final String? buildId;

  /// A string identifying a specific variant or edition of the operating system
  /// suitable for presentation to the user. This field may be used to inform
  /// the user that the configuration of this system is subject to a specific
  /// divergent set of rules or default configuration settings.
  ///
  /// Examples: 'Server Edition', 'Smart Refrigerator Edition'.
  ///
  /// Note: this field is for display purposes only. The [variantId] field
  /// should be used for making programmatic decisions.
  ///
  /// This field is optional and may be null on some systems.
  final String? variant;

  /// A lower-case string identifying a specific variant or edition of the
  /// operating system. This may be interpreted in order to determine a
  /// divergent default configuration.
  ///
  /// The variant ID contains no spaces or other characters outside of 0–9, a–z,
  /// '.', '_' and '-'.
  ///
  /// Examples: 'server', 'embedded'.
  ///
  /// This field is optional and may be null on some systems.
  final String? variantId;

  /// A unique machine ID of the local system that is set during installation or
  /// boot. The machine ID is hexadecimal, 32-character, lowercase ID. When
  /// decoded from hexadecimal, this corresponds to a 16-byte/128-bit value.
  final String? machineId;

  @override
  // ignore: deprecated_member_use_from_same_package
  Map<String, dynamic> get data => toMap();

  @Deprecated('Use [data] getter instead')
  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'version': version,
      'id': id,
      'idLike': idLike,
      'versionCodename': versionCodename,
      'versionId': versionId,
      'prettyName': prettyName,
      'buildId': buildId,
      'variant': variant,
      'variantId': variantId,
      'machineId': machineId,
    };
  }
}
