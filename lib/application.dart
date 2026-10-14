import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/external_control.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/manager/hotkey_manager.dart';
import 'package:bett_box/manager/manager.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
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

  SwitchThemeData _switchTheme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    return SwitchThemeData(
      thumbIcon: const WidgetStatePropertyAll(Icon(null)),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;
        if (states.contains(WidgetState.selected)) return colorScheme.onPrimary;
        return isLight ? Colors.white : colorScheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return isLight
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHighest.lighten(6);
      }),
    );
  }

  InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    const border = UnderlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none,
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.brightness == Brightness.light
          ? Color.lerp(
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
              0.5,
            )
          : colorScheme.surfaceContainerHighest,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      disabledBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
      contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (system.isAndroid) {
      unawaited(SystemNavigator.setFrameworkHandlesBack(true));
    }
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
    if (!appPath.isPortable) {
      try {
        await ExternalControl.start();
      } catch (e) {
        commonPrint.warn('ExternalControl start failed: $e');
      }
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
  Future<bool> didPopRoute() async {
    if (!system.isAndroid) return false;
    final navigator = globalState.navigatorKey.currentState;
    if (navigator == null) return false;
    try {
      if (!await navigator.maybePop()) {
        await globalState.appController.handleBackOrExit();
      }
    } catch (e) {
      commonPrint.warn('Back dispatch failed: $e');
    }
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncAutoUpdateTasks();
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
              unawaited(
                clashCore.closeConnections().then<void>(
                  (_) {},
                  onError: (Object e) =>
                      commonPrint.debug('closeConnections ignored: $e'),
                ),
              );
            }
            if (system.isMacOS) {
              // Wait for DHCP and the default route to settle before moving the
              // managed DNS from the previous network to the new one.
              await Future.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              final dnsState = ref.read(autoSetSystemDnsStateProvider);
              await macOS?.updateDns(!(dnsState.a && dnsState.b));
              unawaited(globalState.appController.refreshTunRoutes());
            }
            globalState.appController.updateLocalNetwork();
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
              navigatorObservers: [routeIdleObserver],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
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
                scaffoldBackgroundColor: _getAppColorScheme(
                  brightness: Brightness.light,
                  primaryColor: themeProps.primaryColor,
                ).surfaceContainer,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                    systemStatusBarContrastEnforced: false,
                  ),
                ),
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.light,
                  primaryColor: themeProps.primaryColor,
                ),
                fontFamily: fontFamily,
                fontFamilyFallback: [FontFamily.twEmoji.value],
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  elevation: 3,
                  hoverElevation: 5,
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: _getAppColorScheme(
                    brightness: Brightness.light,
                    primaryColor: themeProps.primaryColor,
                  ).surfaceContainerLowest,
                  surfaceTintColor: Colors.transparent,
                  elevation: 10,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _getAppColorScheme(
                        brightness: Brightness.light,
                        primaryColor: themeProps.primaryColor,
                      ).outlineVariant.withValues(alpha: 0.6),
                    ),
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
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                dividerTheme: DividerThemeData(
                  color: _getAppColorScheme(
                    brightness: Brightness.light,
                    primaryColor: themeProps.primaryColor,
                  ).outlineVariant.withValues(alpha: 0.45),
                  thickness: 1,
                  space: 1,
                ),
                inputDecorationTheme: _inputDecorationTheme(
                  _getAppColorScheme(
                    brightness: Brightness.light,
                    primaryColor: themeProps.primaryColor,
                  ),
                ),
                switchTheme: _switchTheme(
                  _getAppColorScheme(
                    brightness: Brightness.light,
                    primaryColor: themeProps.primaryColor,
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
                tooltipTheme: TooltipThemeData(
                  decoration: BoxDecoration(
                    color: _getAppColorScheme(
                      brightness: Brightness.light,
                      primaryColor: themeProps.primaryColor,
                    ).inverseSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  textStyle: TextStyle(
                    color: _getAppColorScheme(
                      brightness: Brightness.light,
                      primaryColor: themeProps.primaryColor,
                    ).onInverseSurface,
                    fontSize: 13,
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                scaffoldBackgroundColor: _getAppColorScheme(
                  brightness: Brightness.dark,
                  primaryColor: themeProps.primaryColor,
                ).toPureBlack(themeProps.pureBlack).surfaceContainer,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                    systemStatusBarContrastEnforced: false,
                  ),
                ),
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.dark,
                  primaryColor: themeProps.primaryColor,
                ).toPureBlack(themeProps.pureBlack),
                fontFamily: fontFamily,
                fontFamilyFallback: [FontFamily.twEmoji.value],
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  elevation: 3,
                  hoverElevation: 5,
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: _getAppColorScheme(
                    brightness: Brightness.dark,
                    primaryColor: themeProps.primaryColor,
                  ).toPureBlack(themeProps.pureBlack).surfaceContainerHigh,
                  surfaceTintColor: Colors.transparent,
                  elevation: 10,
                  shadowColor: Colors.black.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          _getAppColorScheme(
                                brightness: Brightness.dark,
                                primaryColor: themeProps.primaryColor,
                              )
                              .toPureBlack(themeProps.pureBlack)
                              .outlineVariant
                              .withValues(alpha: 0.5),
                    ),
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
                    borderRadius: BorderRadius.all(Radius.circular(16)),
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
                          .withValues(alpha: 0.25),
                  thickness: 1,
                  space: 1,
                ),
                inputDecorationTheme: _inputDecorationTheme(
                  _getAppColorScheme(
                    brightness: Brightness.dark,
                    primaryColor: themeProps.primaryColor,
                  ).toPureBlack(themeProps.pureBlack),
                ),
                switchTheme: _switchTheme(
                  _getAppColorScheme(
                    brightness: Brightness.dark,
                    primaryColor: themeProps.primaryColor,
                  ).toPureBlack(themeProps.pureBlack),
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
                            .withValues(alpha: 0.5),
                  ),
                ),
                tooltipTheme: TooltipThemeData(
                  decoration: BoxDecoration(
                    color: _getAppColorScheme(
                      brightness: Brightness.dark,
                      primaryColor: themeProps.primaryColor,
                    ).toPureBlack(themeProps.pureBlack).inverseSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  textStyle: TextStyle(
                    color: _getAppColorScheme(
                      brightness: Brightness.dark,
                      primaryColor: themeProps.primaryColor,
                    ).toPureBlack(themeProps.pureBlack).onInverseSurface,
                    fontSize: 13,
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
