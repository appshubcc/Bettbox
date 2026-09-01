import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/external_control.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/manager/hotkey_manager.dart';
import 'package:bett_box/manager/manager.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';
import 'pages/pages.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application>
    with WidgetsBindingObserver {
  Timer? _autoUpdateGroupTaskTimer;
  Timer? _autoUpdateProfilesTaskTimer;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  ColorScheme _getAppColorScheme({
    required Brightness brightness,
    int? primaryColor,
  }) {
    return ref.read(genColorSchemeProvider(brightness));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    globalState.backgroundMode.addListener(_syncAutoUpdateTasks);
    _syncAutoUpdateTasks();
    globalState.appController = AppController(context, ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initApp());
    });
  }

  bool get _isForeground {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }

  Future<void> _initApp() async {
    final currentContext = globalState.navigatorKey.currentContext;
    if (currentContext != null && currentContext != context) {
      globalState.appController = AppController(currentContext, ref);
    }
    await globalState.appController.init();
    try {
      await ExternalControl.start();
    } catch (e) {
      commonPrint.log('ExternalControl start failed: $e');
    }
    globalState.appController.initLink();
    if (system.isAndroid) {
      app.initShortcuts();
    }
    Future.delayed(const Duration(seconds: 3), () {
      globalState.warmupCommonDialog();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncAutoUpdateTasks();
    if (state == AppLifecycleState.resumed) {
      if (system.isAndroid &&
          globalState.config.appSetting.enableHighRefreshRate) {
        _restoreHighRefreshRate();
      }
    }
  }

  void _syncAutoUpdateTasks() {
    final shouldRun = _isForeground && !globalState.backgroundMode.value;
    if (!shouldRun) {
      _autoUpdateGroupTaskTimer?.cancel();
      _autoUpdateGroupTaskTimer = null;
      if (!system.isDesktop) {
        _autoUpdateProfilesTaskTimer?.cancel();
        _autoUpdateProfilesTaskTimer = null;
      }
      return;
    }
    if (_autoUpdateGroupTaskTimer == null) {
      _autoUpdateGroupTask();
    }
    if (_autoUpdateProfilesTaskTimer == null) {
      _autoUpdateProfilesTask();
    }
  }

  Future<void> _restoreHighRefreshRate() async {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      commonPrint.log('Failed to restore high refresh rate: $e');
    }
  }

  void _autoUpdateGroupTask() {
    _autoUpdateGroupTaskTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => globalState.appController.updateGroupsDebounce(),
    );
  }

  void _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer.periodic(
      const Duration(hours: 24),
      (_) => unawaited(globalState.appController.autoUpdateProfiles()),
    );
  }

  Widget _buildPlatformState(Widget child) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(
            child: ProxyManager(child: SmartAutoStopManager(child: child)),
          ),
        ),
      );
    }
    return AndroidManager(
      child: TileManager(child: SmartAutoStopManager(child: child)),
    );
  }

  Widget _buildState(Widget child) {
    return AppStateManager(
      child: ClashManager(
        child: ConnectivityManager(
          onConnectivityChanged: (results) async {
            if (!results.contains(ConnectivityResult.vpn)) {
              clashCore.closeConnections();
            }
            if (system.isMacOS) {
              // Wait for DHCP and the default route to settle before moving the
              // managed DNS from the previous network to the new one.
              await Future.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              final dnsState = ref.read(autoSetSystemDnsStateProvider);
              await macOS?.updateDns(!(dnsState.a && dnsState.b));
            }
            globalState.appController.updateLocalIp();
            globalState.appController.addCheckIpNumDebounce();
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlatformApp(Widget child) {
    if (system.isDesktop) {
      return WindowHeaderContainer(child: child);
    }
    return VpnManager(child: child);
  }

  Widget _buildApp(Widget child) {
    return MessageManager(child: ThemeManager(child: child));
  }

  @override
  Widget build(context) {
    return _buildPlatformState(
      _buildState(
        Consumer(
          builder: (_, ref, child) {
            final locale = ref.watch(
              appSettingProvider.select((state) => state.locale),
            );
            final themeProps = ref.watch(themeSettingProvider);
            final fontFamily = themeProps.useHarmonyFont
                ? 'HarmonyOS_Sans'
                : null;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: globalState.navigatorKey,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              builder: (_, child) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: globalState.animationEnabled,
                    builder: (_, enabled, _) {
                      return TickerMode(
                        enabled: enabled,
                        child: AppEnvManager(
                          child: _buildApp(
                            AppSidebarContainer(
                              child: _buildPlatformApp(child!),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              scrollBehavior: BaseScrollBehavior(),
              title: appName,
              locale:
                  utils.getLocaleForString(locale) ?? utils.getSystemLocale(),
              supportedLocales: AppLocalizations.delegate.supportedLocales,
              themeMode: themeProps.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.light,
                  primaryColor: themeProps.primaryColor,
                ),
                fontFamily: fontFamily,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  elevation: 3,
                  hoverElevation: 5,
                ),
                dialogTheme: DialogThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                bottomSheetTheme: const BottomSheetThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
                popupMenuTheme: const PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                dividerTheme: DividerThemeData(
                  color: _getAppColorScheme(
                    brightness: Brightness.light,
                    primaryColor: themeProps.primaryColor,
                  ).outlineVariant.withValues(alpha: 0.6),
                  thickness: 1,
                  space: 1,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: _getAppColorScheme(
                        brightness: Brightness.light,
                        primaryColor: themeProps.primaryColor,
                      ).outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: _getAppColorScheme(
                        brightness: Brightness.light,
                        primaryColor: themeProps.primaryColor,
                      ).primary,
                      width: 2,
                    ),
                  ),
                ),
                chipTheme: ChipThemeData(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  side: BorderSide(
                    color: _getAppColorScheme(
                      brightness: Brightness.light,
                      primaryColor: themeProps.primaryColor,
                    ).outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                tooltipTheme: const TooltipThemeData(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.dark,
                  primaryColor: themeProps.primaryColor,
                ).toPureBlack(themeProps.pureBlack),
                fontFamily: fontFamily,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  elevation: 3,
                  hoverElevation: 5,
                ),
                dialogTheme: DialogThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                bottomSheetTheme: const BottomSheetThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
                popupMenuTheme: const PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                dividerTheme: DividerThemeData(
                  color:
                      _getAppColorScheme(
                            brightness: Brightness.dark,
                            primaryColor: themeProps.primaryColor,
                          )
                          .toPureBlack(themeProps.pureBlack)
                          .outlineVariant
                          .withValues(alpha: 0.45),
                  thickness: 1,
                  space: 1,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color:
                          _getAppColorScheme(
                                brightness: Brightness.dark,
                                primaryColor: themeProps.primaryColor,
                              )
                              .toPureBlack(themeProps.pureBlack)
                              .outlineVariant
                              .withValues(alpha: 0.45),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: _getAppColorScheme(
                        brightness: Brightness.dark,
                        primaryColor: themeProps.primaryColor,
                      ).toPureBlack(themeProps.pureBlack).primary,
                      width: 2,
                    ),
                  ),
                ),
                chipTheme: ChipThemeData(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  side: BorderSide(
                    color:
                        _getAppColorScheme(
                              brightness: Brightness.dark,
                              primaryColor: themeProps.primaryColor,
                            )
                            .toPureBlack(themeProps.pureBlack)
                            .outlineVariant
                            .withValues(alpha: 0.45),
                  ),
                ),
                tooltipTheme: const TooltipThemeData(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              home: child!,
            );
          },
          child: const HomePage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    globalState.backgroundMode.removeListener(_syncAutoUpdateTasks);
    WidgetsBinding.instance.removeObserver(this);
    linkManager.destroy();
    _autoUpdateGroupTaskTimer?.cancel();
    _autoUpdateProfilesTaskTimer?.cancel();
    ExternalControl.stop();
    if (!system.isAndroid && !globalState.isExiting) {
      unawaited(globalState.appController.handleExit());
    }
    super.dispose();
  }
}
