android_app_arm64:
	dart ./setup.dart android --arch arm64

android_app_all:
	dart ./setup.dart android

android_app_universal:
	dart ./setup.dart android --arch universal

android_core_arm64:
	dart ./setup.dart android --arch arm64 --out core
	
android_core_all:
	dart ./setup.dart android --out core

macos_app:
	dart ./setup.dart macos

macos_app_arm64:
	dart ./setup.dart macos --arch arm64
	
macos_app_amd64:
	dart ./setup.dart macos --arch amd64

macos_app_universal:
	dart ./setup.dart macos --arch universal

macos_core:
	dart ./setup.dart macos --out core

macos_core_arm64:
	dart ./setup.dart macos --arch arm64  --out core
	
macos_core_amd64:
	dart ./setup.dart macos --arch amd64 --out core

windows_app:
	dart ./setup.dart windows

windows_app_amd64_compatible:
	dart ./setup.dart windows --arch amd64 --compatible

linux:
	dart ./setup.dart linux --build-only

linux_amd64_compatible:
	dart ./setup.dart linux --arch amd64 --compatible --build-only

linux_core:
	dart ./setup.dart linux --out core
	
linux_core_amd64_compatible:
	dart ./setup.dart linux --out core --arch amd64 --compatible
