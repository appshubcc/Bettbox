/// The Windows implementation of `device_info_plus`.
library device_info_plus_windows;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'package:win32/win32.dart';
import 'package:win32_registry/win32_registry.dart';

import 'model/windows_device_info.dart';

/// The Windows implementation of [DeviceInfoPlatform].
class DeviceInfoPlusWindowsPlugin extends DeviceInfoPlatform {
  /// Register this dart class as the platform implementation for windows
  static void registerWith() {
    DeviceInfoPlatform.instance = DeviceInfoPlusWindowsPlugin();
  }

  WindowsDeviceInfo? _cache;

  // In a well-meaning but somewhat misguided attempt to reduce apps from using
  // version numbers for feature detection, most version number APIs don't give
  // expected results on Windows 8 and above. RtlGetVersion is reliable and
  // stable, but as a kernel API is documented in the Windows DDK (Driver
  // Development Kit), rather than the SDK. As such, it's not included in
  // package:win32, so we have to manually define it here.
  //
  // ignore: non_constant_identifier_names
  void Function(Pointer<OSVERSIONINFOEX>) RtlGetVersion =
      DynamicLibrary.open('ntdll.dll').lookupFunction<
          Void Function(Pointer<OSVERSIONINFOEX>),
          void Function(Pointer<OSVERSIONINFOEX>)>('RtlGetVersion');

  /// Returns a [WindowsDeviceInfo] with information about the device.
  @override
  Future<BaseDeviceInfo> deviceInfo() {
    return Future.value(_cache ??= getInfo());
  }

  @visibleForTesting
  WindowsDeviceInfo getInfo() {
    final systemInfo = calloc<SYSTEM_INFO>();
    final osVersionInfo = calloc<OSVERSIONINFOEX>()
      ..ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFOEX>();

    try {
      final currentVersionKey = Registry.openPath(RegistryHive.localMachine,
          path: r'SOFTWARE\Microsoft\Windows NT\CurrentVersion');
      final buildLab = currentVersionKey.getValueAsString('BuildLab') ?? '';
      final buildLabEx = currentVersionKey.getValueAsString('BuildLabEx') ?? '';
      final digitalProductIdValue =
          currentVersionKey.getValue('DigitalProductId');
      final digitalProductId = digitalProductIdValue is BinaryValue
          ? digitalProductIdValue.value
          : Uint8List(0);
      final displayVersion =
          currentVersionKey.getValueAsString('DisplayVersion') ?? '';
      final editionId = currentVersionKey.getValueAsString('EditionID') ?? '';
      final installDate = DateTime.fromMillisecondsSinceEpoch(
          1000 * (currentVersionKey.getValueAsInt('InstallDate') ?? 0));
      final productId = currentVersionKey.getValueAsString('ProductID') ?? '';
      var productName = currentVersionKey.getValueAsString('ProductName') ?? '';
      final registeredOwner =
          currentVersionKey.getValueAsString('RegisteredOwner') ?? '';
      final releaseId = currentVersionKey.getValueAsString('ReleaseId') ?? '';

      final sqmClientKey = Registry.openPath(RegistryHive.localMachine,
          path: r'SOFTWARE\Microsoft\SQMClient');
      final machineId = sqmClientKey.getValueAsString('MachineId') ?? '';

      GetSystemInfo(systemInfo);

      // Use `RtlGetVersion` from `ntdll.dll` to get the Windows version.
      RtlGetVersion(osVersionInfo);

      // Handle [productName] for Windows 11 separately (as per Raymond Chen's comment).
      // https://stackoverflow.com/questions/69460588/how-can-i-find-the-windows-product-name-in-windows-11
      if (osVersionInfo.ref.dwBuildNumber >= 22000) {
        productName = productName.replaceAll('10', '11');
      }
      final data = WindowsDeviceInfo(
        numberOfCores: systemInfo.ref.dwNumberOfProcessors,
        computerName: getComputerName(),
        systemMemoryInMegabytes: getSystemMemoryInMegabytes(),
        userName: getUserName(),
        majorVersion: osVersionInfo.ref.dwMajorVersion,
        minorVersion: osVersionInfo.ref.dwMinorVersion,
        buildNumber: osVersionInfo.ref.dwBuildNumber,
        platformId: osVersionInfo.ref.dwPlatformId,
        csdVersion: osVersionInfo.ref.szCSDVersion,
        servicePackMajor: osVersionInfo.ref.wServicePackMajor,
        servicePackMinor: osVersionInfo.ref.wServicePackMinor,
        suitMask: osVersionInfo.ref.wSuiteMask,
        productType: osVersionInfo.ref.wProductType,
        reserved: osVersionInfo.ref.wReserved,
        buildLab: buildLab,
        buildLabEx: buildLabEx,
        digitalProductId: digitalProductId,
        displayVersion: displayVersion,
        editionId: editionId,
        installDate: installDate,
        productId: productId,
        productName: productName,
        registeredOwner: registeredOwner,
        releaseId: releaseId,
        deviceId: machineId,
      );
      return data;
    } finally {
      free(systemInfo);
      free(osVersionInfo);
    }
  }

  @visibleForTesting
  int getSystemMemoryInMegabytes() {
    final memoryInKilobytes = calloc<ULONGLONG>();
    try {
      final result = GetPhysicallyInstalledSystemMemory(memoryInKilobytes);
      if (result != 0) {
        return memoryInKilobytes.value ~/ 1024;
      } else {
        final error = GetLastError();
        throw WindowsException(HRESULT_FROM_WIN32(error));
      }
    } finally {
      free(memoryInKilobytes);
    }
  }

  @visibleForTesting
  String getComputerName() {
    // We call this a first time to get the length of the string in characters,
    // so we can allocate sufficient memory.
    final nSize = calloc<DWORD>();
    GetComputerNameEx(
        COMPUTER_NAME_FORMAT.ComputerNameDnsFullyQualified, nullptr, nSize);

    // Now allocate memory for a native string and call this a second time.
    final lpBuffer = wsalloc(nSize.value);
    try {
      final result = GetComputerNameEx(
          COMPUTER_NAME_FORMAT.ComputerNameDnsFullyQualified, lpBuffer, nSize);

      if (result != 0) {
        return lpBuffer.toDartString();
      } else {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }
    } finally {
      free(lpBuffer);
      free(nSize);
    }
  }

  @visibleForTesting
  String getUserName() {
    const maxLength = 256; // defined as UNLEN in Lmcons.h
    final lpBuffer = wsalloc(maxLength + 1); // allow for terminating null
    final pcbBuffer = calloc<DWORD>()..value = maxLength + 1;
    try {
      final result = GetUserName(lpBuffer, pcbBuffer);
      if (result != 0) {
        return lpBuffer.toDartString();
      } else {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }
    } finally {
      free(pcbBuffer);
      free(lpBuffer);
    }
  }
}
