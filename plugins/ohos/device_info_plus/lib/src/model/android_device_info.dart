// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math show sqrt;
import 'package:device_info_plus_platform_interface/model/base_device_info.dart';

/// Information derived from `android.os.Build`.
///
/// See: https://developer.android.com/reference/android/os/Build.html
class AndroidDeviceInfo extends BaseDeviceInfo {
  AndroidDeviceInfo._({
    required Map<String, dynamic> data,
    required this.version,
    required this.board,
    required this.bootloader,
    required this.brand,
    required this.device,
    required this.display,
    required this.fingerprint,
    required this.hardware,
    required this.host,
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.product,
    required List<String> supported32BitAbis,
    required List<String> supported64BitAbis,
    required List<String> supportedAbis,
    required this.tags,
    required this.type,
    required this.isPhysicalDevice,
    required List<String> systemFeatures,
    required this.displayMetrics,
    required this.serialNumber,
  })  : supported32BitAbis = List<String>.unmodifiable(supported32BitAbis),
        supported64BitAbis = List<String>.unmodifiable(supported64BitAbis),
        supportedAbis = List<String>.unmodifiable(supportedAbis),
        systemFeatures = List<String>.unmodifiable(systemFeatures),
        super(data);

  /// Android operating system version values derived from `android.os.Build.VERSION`.
  final AndroidBuildVersion version;

  /// The name of the underlying board, like "goldfish".
  /// https://developer.android.com/reference/android/os/Build#BOARD
  final String board;

  /// The system bootloader version number.
  /// https://developer.android.com/reference/android/os/Build#BOOTLOADER
  final String bootloader;

  /// The consumer-visible brand with which the product/hardware will be associated, if any.
  /// https://developer.android.com/reference/android/os/Build#BRAND
  final String brand;

  /// The name of the industrial design.
  /// https://developer.android.com/reference/android/os/Build#DEVICE
  final String device;

  /// A build ID string meant for displaying to the user.
  /// https://developer.android.com/reference/android/os/Build#DISPLAY
  final String display;

  /// A string that uniquely identifies this build.
  /// https://developer.android.com/reference/android/os/Build#FINGERPRINT
  final String fingerprint;

  /// The name of the hardware (from the kernel command line or /proc).
  /// https://developer.android.com/reference/android/os/Build#HARDWARE
  final String hardware;

  /// Hostname.
  /// https://developer.android.com/reference/android/os/Build#HOST
  final String host;

  /// Either a changelist number, or a label like "M4-rc20".
  /// https://developer.android.com/reference/android/os/Build#ID
  final String id;

  /// The manufacturer of the product/hardware.
  /// https://developer.android.com/reference/android/os/Build#MANUFACTURER
  final String manufacturer;

  /// The end-user-visible name for the end product.
  /// https://developer.android.com/reference/android/os/Build#MODEL
  final String model;

  /// The name of the overall product.
  /// https://developer.android.com/reference/android/os/Build#PRODUCT
  final String product;

  /// An ordered list of 32 bit ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_32_BIT_ABIS
  final List<String> supported32BitAbis;

  /// An ordered list of 64 bit ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_64_BIT_ABIS
  final List<String> supported64BitAbis;

  /// An ordered list of ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_ABIS
  final List<String> supportedAbis;

  /// Comma-separated tags describing the build, like "unsigned,debug".
  /// https://developer.android.com/reference/android/os/Build#TAGS
  final String tags;

  /// The type of build, like "user" or "eng".
  /// https://developer.android.com/reference/android/os/Build#TIME
  final String type;

  /// `false` if the application is running in an emulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// Describes what features are available on the current device.
  ///
  /// This can be used to check if the device has, for example, a front-facing
  /// camera, or a touchscreen. However, in many cases this is not the best
  /// API to use. For example, if you are interested in bluetooth, this API
  /// can tell you if the device has a bluetooth radio, but it cannot tell you
  /// if bluetooth is currently enabled, or if you have been granted the
  /// necessary permissions to use it. Please *only* use this if there is no
  /// other way to determine if a feature is supported.
  ///
  /// This data comes from Android's PackageManager.getSystemAvailableFeatures,
  /// and many of the common feature strings to look for are available in
  /// PackageManager's public documentation:
  /// https://developer.android.com/reference/android/content/pm/PackageManager
  final List<String> systemFeatures;

  /// Information about the current android display.
  final AndroidDisplayMetrics displayMetrics;

  /// Hardware serial number of the device, if available
  ///
  /// There are special restrictions on this identifier, more info here:
  /// https://developer.android.com/reference/android/os/Build#getSerial()
  final String serialNumber;

  /// Deserializes from the message received from [_kChannel].
  static AndroidDeviceInfo fromMap(Map<String, dynamic> map) {
    return AndroidDeviceInfo._(
      data: map,
      version: AndroidBuildVersion._fromMap(
          map['version']?.cast<String, dynamic>() ?? {}),
      board: map['board'],
      bootloader: map['bootloader'],
      brand: map['brand'],
      device: map['device'],
      display: map['display'],
      fingerprint: map['fingerprint'],
      hardware: map['hardware'],
      host: map['host'],
      id: map['id'],
      manufacturer: map['manufacturer'],
      model: map['model'],
      product: map['product'],
      supported32BitAbis: _fromList(map['supported32BitAbis'] ?? <String>[]),
      supported64BitAbis: _fromList(map['supported64BitAbis'] ?? <String>[]),
      supportedAbis: _fromList(map['supportedAbis'] ?? []),
      tags: map['tags'],
      type: map['type'],
      isPhysicalDevice: map['isPhysicalDevice'],
      systemFeatures: _fromList(map['systemFeatures'] ?? []),
      displayMetrics: AndroidDisplayMetrics._fromMap(
          map['displayMetrics']?.cast<String, dynamic>() ?? {}),
      serialNumber: map['serialNumber'],
    );
  }

  /// Deserializes message as List<String>
  static List<String> _fromList(List<dynamic> message) {
    final list = message.takeWhile((item) => item != null).toList();
    return List<String>.from(list);
  }
}

/// Version values of the current Android operating system build derived from
/// `android.os.Build.VERSION`.
///
/// See: https://developer.android.com/reference/android/os/Build.VERSION.html
class AndroidBuildVersion {
  const AndroidBuildVersion._({
    this.baseOS,
    required this.codename,
    required this.incremental,
    required this.previewSdkInt,
    required this.release,
    required this.sdkInt,
    this.securityPatch,
  });

  /// The base OS build the product is based on.
  /// Available only on Android M (API 23) and newer
  final String? baseOS;

  /// The current development codename, or the string "REL" if this is a release build.
  final String codename;

  /// The internal value used by the underlying source control to represent this build.
  /// Available only on Android M (API 23) and newer
  final String incremental;

  /// The developer preview revision of a pre-release SDK.
  final int? previewSdkInt;

  /// The user-visible version string.
  final String release;

  /// The user-visible SDK version of the framework.
  ///
  /// Possible values are defined in: https://developer.android.com/reference/android/os/Build.VERSION_CODES.html
  final int sdkInt;

  /// The user-visible security patch level.
  /// Available only on Android M (API 23) and newer
  final String? securityPatch;

  /// Serializes [ AndroidBuildVersion ] to map.
  @Deprecated('[toMap] method will be discontinued')
  Map<String, dynamic> toMap() {
    return {
      'baseOS': baseOS,
      'sdkInt': sdkInt,
      'release': release,
      'codename': codename,
      'incremental': incremental,
      'previewSdkInt': previewSdkInt,
      'securityPatch': securityPatch,
    };
  }

  /// Deserializes from the map message received from [_kChannel].
  static AndroidBuildVersion _fromMap(Map<String, dynamic> map) {
    return AndroidBuildVersion._(
      baseOS: map['baseOS'],
      codename: map['codename'],
      incremental: map['incremental'],
      previewSdkInt: map['previewSdkInt'],
      release: map['release'],
      sdkInt: map['sdkInt'],
      securityPatch: map['securityPatch'],
    );
  }
}

/// Details for the current display
///
/// See: https://developer.android.com/reference/android/util/DisplayMetrics
class AndroidDisplayMetrics {
  const AndroidDisplayMetrics._({
    required this.widthPx,
    required this.heightPx,
    required this.xDpi,
    required this.yDpi,
  });

  /// Gets the absolute width in pixels of the largest region of the display accessible to an app
  /// in the current system state, without subtracting any window decor or applying scaling factors.
  final double widthPx;

  /// Gets the absolute height in pixels of the largest region of the display accessible to an app
  /// in the current system state, without subtracting any window decor or applying scaling factors.
  final double heightPx;

  /// The exact physical pixels per inch of the screen in the X dimension.
  final double xDpi;

  /// The exact physical pixels per inch of the screen in the Y dimension.
  final double yDpi;

  /// The exact physical display width in inches.
  double get widthInches => widthPx / xDpi;

  /// The exact physical display height in inches.
  double get heightInches => heightPx / yDpi;

  /// The exact physical size in inches measured diagonally across the display.
  double get sizeInches {
    final width = widthInches;
    final height = heightInches;
    return math.sqrt((width * width) + (height * height));
  }

  /// Serializes [AndroidDisplayMetrics] to map.
  Map<String, dynamic> toMap() {
    return {
      'widthPx': widthPx,
      'heightPx': heightPx,
      'xDpi': xDpi,
      'yDpi': yDpi,
    };
  }

  /// Deserializes from the map message received from the [MethodChannel].
  static AndroidDisplayMetrics _fromMap(Map<String, dynamic> map) {
    return AndroidDisplayMetrics._(
      widthPx: map['widthPx'],
      heightPx: map['heightPx'],
      xDpi: map['xDpi'],
      yDpi: map['yDpi'],
    );
  }
}
