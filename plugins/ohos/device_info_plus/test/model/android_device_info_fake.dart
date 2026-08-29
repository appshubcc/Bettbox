part of '../model/android_device_info_test.dart';

const _fakeAndroidBuildVersion = <String, dynamic>{
  'sdkInt': 16,
  'baseOS': 'baseOS',
  'previewSdkInt': 30,
  'release': 'release',
  'codename': 'codename',
  'incremental': 'incremental',
  'securityPatch': 'securityPatch',
};

const _fakeDisplayMetrics = <String, dynamic>{
  'widthPx': 1080.0,
  'heightPx': 2220.0,
  'xDpi': 530.0859,
  'yDpi': 529.4639,
};

const _fakeSupportedAbis = <String>['arm64-v8a', 'x86', 'x86_64'];
const _fakeSupported32BitAbis = <String?>['x86 (IA-32)', 'MMX'];
const _fakeSupported64BitAbis = <String?>['x86-64', 'MMX', 'SSSE3'];
const _fakeSystemFeatures = ['FEATURE_AUDIO_PRO', 'FEATURE_AUDIO_OUTPUT'];

const _fakeAndroidDeviceInfo = <String, dynamic>{
  'id': 'id',
  'host': 'host',
  'tags': 'tags',
  'type': 'type',
  'model': 'model',
  'board': 'board',
  'brand': 'Google',
  'device': 'device',
  'product': 'product',
  'display': 'display',
  'hardware': 'hardware',
  'isPhysicalDevice': true,
  'bootloader': 'bootloader',
  'fingerprint': 'fingerprint',
  'manufacturer': 'manufacturer',
  'supportedAbis': _fakeSupportedAbis,
  'systemFeatures': _fakeSystemFeatures,
  'version': _fakeAndroidBuildVersion,
  'supported64BitAbis': _fakeSupported64BitAbis,
  'supported32BitAbis': _fakeSupported32BitAbis,
  'displayMetrics': _fakeDisplayMetrics,
  'serialNumber': 'SERIAL',
};
