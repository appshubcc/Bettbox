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
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';
import 'pages/pages.dart';
import 'panel/panel_auth.dart';
import 'views/panel_login.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application>
    with WidgetsBindingObserver {
  Timer? _autoUpdateGroupTaskTimer;
  Timer? _autoUpdateProfilesTaskTimer;
  // [Gamebox] 面板会话心跳（对齐 iGame：约 60s 一次 GET /v1/me）。
  Timer? _panelHeartbeatTimer;
  Timer? _panelHeartbeatFirstTimer;

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
    if (system.isAndroid) {
      unawaited(SystemNavigator.setFrameworkHandlesBack(true));
    }
    globalState.backgroundMode.addListener(_syncAutoUpdateTasks);
    globalState.panelUnlocked.addListener(_syncAutoUpdateTasks);
    globalState.panelUnlocked.addListener(_syncPanelHeartbeat);
    _syncAutoUpdateTasks();
    globalState.appController = AppController(context, ref);
    globalState.clearPanelSubscriptions = clearPanelDataOnExit;
    globalState.openMainAfterLogin = _openMainAfterLogin;
    // [Gamebox] 原生窗口在引擎就绪时已经按登录尺寸显示。第一帧后再聚焦一次。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalState.panelUnlocked.value) return;
      unawaited(window?.show());
      // [Gamebox] 登录页期间预热内核连接，与后面 init 共用，缩短托盘退出冷启动等待。
      unawaited(
        globalState.appController.preheatCoreWhileLogin().catchError((
          Object e,
        ) {
          commonPrint.log('preheat core during login: $e');
        }),
      );
    });
  }

  bool _mainStarted = false;

  Future<void> _openMainAfterLogin() async {
    // [Gamebox] 登录窗期间托盘是关掉的。进主界面后再允许创建。
    tray.releaseForMain();
    final silent = globalState.config.appSetting.silentLaunch;
    final firstStart = !_mainStarted;

    if (firstStart) {
      // [Gamebox] 托盘退出 = 冷启动，必须先跑完与上游相同的 init（含自动连接），再亮主界面。
      // 以前先亮仪表盘再 init，TUN/内核阶段会在「网络检测/启动」上空转十几秒；
      // 退出账号再登录不重走 init，所以不卡。这里只调整时机，不改启动逻辑本身。
      try {
        await _initApp();
      } catch (e) {
        commonPrint.log('init after login: $e');
      }
    }

    if (system.isDesktop && window != null) {
      // [Gamebox] 先把窗口调成完全透明，再改尺寸、换主界面，避免登录页被拉大闪一下。
      await window!.setOpacity(0);
      await window!.showAsMainWindow();
    }
    globalState.panelUnlocked.value = true;
    if (system.isDesktop && window != null) {
      await WidgetsBinding.instance.endOfFrame;
      if (silent) {
        await window!.hide();
        await window!.setOpacity(1);
      } else {
        await window!.setOpacity(1);
        await window!.show();
      }
    }

    if (!firstStart) {
      // [Gamebox] 退出账号后再登录：内核已在，只补托盘和自动连接。
      unawaited(
        globalState.appController.updateTray(true, false, true).catchError((
          Object e,
        ) {
          commonPrint.log('tray after login: $e');
        }),
      );
      if (globalState.config.appSetting.autoRun && !globalState.isStart) {
        unawaited(
          globalState.appController.updateStatus(true).catchError((Object e) {
            commonPrint.log('auto connect after login: $e');
          }),
        );
      }
    }
  }

  bool get _isForeground {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }

  Future<void> _initApp() async {
    _mainStarted = true;
    globalState.mainStarted = true;
    final currentContext = globalState.navigatorKey.currentContext;
    if (currentContext != null && currentContext != context) {
      globalState.appController = AppController(currentContext, ref);
    }
    await globalState.appController.init();
    if (!appPath.isPortable) {
      try {
        await ExternalControl.start();
      } catch (e) {
        commonPrint.log('ExternalControl start failed: $e');
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncAutoUpdateTasks();
    if (state == AppLifecycleState.resumed) {
      if (system.isAndroid &&
          globalState.config.appSetting.enableHighRefreshRate) {
        _restoreHighRefreshRate();
      }
    }
  }

  void _syncPanelHeartbeat() {
    // [Gamebox] 已登录就心跳，最小化也继续，好收到面板踢出。
    _panelHeartbeatFirstTimer?.cancel();
    _panelHeartbeatFirstTimer = null;
    _panelHeartbeatTimer?.cancel();
    _panelHeartbeatTimer = null;
    if (!globalState.panelUnlocked.value) return;
    _panelHeartbeatFirstTimer = Timer(const Duration(milliseconds: 2500), () {
      unawaited(tickPanelSessionHeartbeat());
    });
    _panelHeartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      unawaited(tickPanelSessionHeartbeat());
    });
  }

  void _syncAutoUpdateTasks() {
    if (!globalState.panelUnlocked.value) {
      _autoUpdateGroupTaskTimer?.cancel();
      _autoUpdateGroupTaskTimer = null;
      _autoUpdateProfilesTaskTimer?.cancel();
      _autoUpdateProfilesTaskTimer = null;
      return;
    }
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
              unawaited(
                clashCore.closeConnections().then<void>(
                  (_) {},
                  onError: (Object e) =>
                      commonPrint.log('closeConnections ignored: $e'),
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
              builder: (themeContext, child) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: globalState.panelUnlocked,
                    builder: (_, unlocked, _) {
                      if (!unlocked) {
                        // [Gamebox] 必须用 MaterialApp builder 的 context 取主题。
                        // Application 的 context 在 MaterialApp 外面，只有默认浅色。
                        // 登录窗不再套标题栏占位，避免卡片外面多出一层底色。
                        return ColoredBox(
                          color: Theme.of(themeContext)
                              .colorScheme
                              .surfaceContainerHigh,
                          child: _buildApp(child!),
                        );
                      }
                      return ValueListenableBuilder<bool>(
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
                      );
                    },
                  ),
                );
              },
              scrollBehavior: BaseScrollBehavior(),
              title: appName,
              // [Gamebox] 界面固定简体中文。上游使用已保存语言，没有则跟随系统。
              locale: const Locale('zh', 'CN'),
              supportedLocales: const [Locale('zh', 'CN')],
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
                ),
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
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                ),
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
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              home: child!,
            );
          },
          child: const _AppHome(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    globalState.backgroundMode.removeListener(_syncAutoUpdateTasks);
    globalState.panelUnlocked.removeListener(_syncAutoUpdateTasks);
    globalState.panelUnlocked.removeListener(_syncPanelHeartbeat);
    WidgetsBinding.instance.removeObserver(this);
    linkManager.destroy();
    _panelHeartbeatFirstTimer?.cancel();
    _panelHeartbeatTimer?.cancel();
    _autoUpdateGroupTaskTimer?.cancel();
    _autoUpdateProfilesTaskTimer?.cancel();
    ExternalControl.stop();
    if (!system.isAndroid && !globalState.isExiting) {
      unawaited(globalState.appController.handleExit());
    }
    super.dispose();
  }
}

// [Gamebox] 冷启动的路由就是登录页。登录成功后同一条路由换成主页，不另开窗口。
class _AppHome extends StatelessWidget {
  const _AppHome();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalState.panelUnlocked,
      builder: (_, unlocked, _) {
        if (!unlocked) return const PanelLoginGate();
        return const HomePage();
      },
    );
  }
}
