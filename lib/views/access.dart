import 'dart:async';
import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Force refresh icon flag
final forceRefreshIconProvider = StateProvider<bool>((ref) => false);

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView>
    with WidgetsBindingObserver {
  List<String> acceptList = [];
  List<String> rejectList = [];
  late ScrollController _controller;
  final Completer<void> _completer = Completer<void>();
  bool _requestedPackageListPermission = false;
  bool _notifiedPackageListPermissionDenied = false;
  bool _isCheckingPermissionOrLoading = false;
  bool _packageListPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _updateInitList();
    _controller = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndLoadPackages(interactive: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!mounted) return;
    if (ref.read(packagesProvider).isNotEmpty &&
        !_packageListPermissionDenied) {
      return;
    }
    _checkPermissionAndLoadPackages(interactive: false);
  }

  void _completeLoadingIfNeeded() {
    if (_completer.isCompleted) return;
    _completer.complete();
  }

  Widget _buildPackageListPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apps_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              appLocalizations.packageListPermissionDenied,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.packageListPermissionRequired,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    _requestedPackageListPermission = true;
                    await app.requestPackageListPermission();
                  },
                  icon: const Icon(Icons.settings),
                  label: Text(appLocalizations.openSettings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPermissionAndLoadPackages({
    required bool interactive,
    bool forceReload = false,
    bool openSettingsFallback = false,
  }) async {
    if (_isCheckingPermissionOrLoading) return;
    _isCheckingPermissionOrLoading = true;
    try {
      final hasPermission = await app.hasPackageListPermission();
      if (!mounted) return;

      if (!hasPermission) {
        if (!_packageListPermissionDenied) {
          setState(() {
            _packageListPermissionDenied = true;
          });
        }
        if (interactive) {
          if (openSettingsFallback) {
            _requestedPackageListPermission = true;
            await app.requestPackageListPermission();
          } else {
            final res = await globalState.showMessage(
              title: appLocalizations.tip,
              message: TextSpan(
                text: appLocalizations.packageListPermissionRequired,
              ),
              confirmText: appLocalizations.openSettings,
            );
            if (!mounted) return;
            if (res == true) {
              _requestedPackageListPermission = true;
              await app.requestPackageListPermission();
            } else if (!_notifiedPackageListPermissionDenied) {
              _notifiedPackageListPermissionDenied = true;
              globalState.showNotifier(
                appLocalizations.packageListPermissionDenied,
              );
            }
          }
        } else if (_requestedPackageListPermission &&
            !_notifiedPackageListPermissionDenied) {
          _notifiedPackageListPermissionDenied = true;
          globalState.showNotifier(
            appLocalizations.packageListPermissionDenied,
          );
        }
        _completeLoadingIfNeeded();
        return;
      }

      if (_packageListPermissionDenied) {
        setState(() {
          _packageListPermissionDenied = false;
        });
      }
      await globalState.appController.getPackages(forceRefresh: forceReload);
      if (!mounted) return;
      if (system.isAndroid && ref.read(packagesProvider).isEmpty) {
        if (!_packageListPermissionDenied) {
          setState(() {
            _packageListPermissionDenied = true;
          });
        }
        if (interactive) {
          final res = await globalState.showMessage(
            title: appLocalizations.tip,
            message: TextSpan(
              text: appLocalizations.packageListPermissionRequired,
            ),
            confirmText: appLocalizations.openSettings,
          );
          if (!mounted) return;
          if (res == true) {
            _requestedPackageListPermission = true;
            await app.requestPackageListPermission();
          }
        }
        _completeLoadingIfNeeded();
        return;
      }
      _completeLoadingIfNeeded();
    } catch (e) {
      _completeLoadingIfNeeded();
      if (e is PlatformException && e.code == 'PACKAGE_LIST_PERMISSION') {
        if (!mounted) return;
        if (!_packageListPermissionDenied) {
          setState(() {
            _packageListPermissionDenied = true;
          });
        }
        if (interactive) {
          if (openSettingsFallback) {
            _requestedPackageListPermission = true;
            await app.requestPackageListPermission();
            return;
          }
          final res = await globalState.showMessage(
            title: appLocalizations.tip,
            message: TextSpan(
              text: appLocalizations.packageListPermissionRequired,
            ),
            confirmText: appLocalizations.openSettings,
          );
          if (!mounted) return;
          if (res == true) {
            _requestedPackageListPermission = true;
            await app.requestPackageListPermission();
          } else if (!_notifiedPackageListPermissionDenied) {
            _notifiedPackageListPermissionDenied = true;
            globalState.showNotifier(
              appLocalizations.packageListPermissionDenied,
            );
          }
          return;
        }
        if (_requestedPackageListPermission &&
            !_notifiedPackageListPermissionDenied) {
          _notifiedPackageListPermissionDenied = true;
          globalState.showNotifier(
            appLocalizations.packageListPermissionDenied,
          );
          return;
        }
      }
      globalState.showNotifier(e.toString());
    } finally {
      _isCheckingPermissionOrLoading = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _updateInitList() {
    acceptList = globalState.config.vpnProps.accessControl.acceptList;
    rejectList = globalState.config.vpnProps.accessControl.rejectList;
  }

  Widget _buildSearchButton() {
    return IconButton(
      tooltip: appLocalizations.search,
      onPressed: () {
        showSearch(
          context: context,
          delegate: AccessControlSearchDelegate(
            acceptList: acceptList,
            rejectList: rejectList,
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              _updateInitList();
            });
          }
        });
      },
      icon: const Icon(Icons.search),
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      tooltip: appLocalizations.refreshAppList,
      onPressed: () async {
        final res = await globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: appLocalizations.refreshAppListConfirm),
        );
        if (res != true) return;

        // Reload app list (auto-checks and requests permissions)
        await globalState.appController.safeRun(() async {
          // Clear cache, force reload
          // Mark as force refresh mode
          ref.read(forceRefreshIconProvider.notifier).state = true;
          await _checkPermissionAndLoadPackages(
            interactive: true,
            forceReload: true,
          );
          // Reset force refresh flag
          if (mounted) {
            ref.read(forceRefreshIconProvider.notifier).state = false;
          }
        }, needLoading: true);

        if (mounted) {
          setState(() {
            _updateInitList();
          });
        }
      },
      icon: const Icon(Icons.sync),
    );
  }

  Widget _buildSelectedAllButton({
    required bool isSelectedAll,
    required List<String> allValueList,
  }) {
    final tooltip = isSelectedAll
        ? appLocalizations.cancelSelectAll
        : appLocalizations.selectAll;
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        ref.read(vpnSettingProvider.notifier).updateState((state) {
          final isAccept =
              state.accessControl.mode == AccessControlMode.acceptSelected;
          if (isSelectedAll) {
            return switch (isAccept) {
              true => state.copyWith.accessControl(acceptList: []),
              false => state.copyWith.accessControl(rejectList: []),
            };
          } else {
            return switch (isAccept) {
              true => state.copyWith.accessControl(acceptList: allValueList),
              false => state.copyWith.accessControl(rejectList: allValueList),
            };
          }
        });
      },
      icon: isSelectedAll
          ? const Icon(Icons.deselect)
          : const Icon(Icons.select_all),
    );
  }

  Future<void> _intelligentSelected() async {
    final packageNames = ref.read(
      packageListSelectorStateProvider.select(
        (state) => state.list.map((item) => item.packageName),
      ),
    );
    final commonScaffoldState = context.commonScaffoldState;
    if (commonScaffoldState?.mounted != true) return;
    final selectedPackageNames =
        (await globalState.appController.safeRun<List<String>>(
          needLoading: true,
          () async {
            return await app.getChinaPackageNames();
          },
        ))?.toSet() ??
        {};
    final acceptList = packageNames
        .where((item) => !selectedPackageNames.contains(item))
        .toList();
    final rejectList = packageNames
        .where((item) => selectedPackageNames.contains(item))
        .toList();
    ref
        .read(vpnSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith.accessControl(
            acceptList: acceptList,
            rejectList: rejectList,
          ),
        );
  }

  Widget _buildSettingButton() {
    return IconButton(
      onPressed: () async {
        final res = await showSheet<int>(
          context: context,
          props: SheetProps(isScrollControlled: true),
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              body: AccessControlPanel(),
              title: appLocalizations.proxiesSetting,
            );
          },
        );
        if (res == 1) {
          _intelligentSelected();
        }
      },
      icon: const Icon(Icons.tune),
    );
  }

  void _handleSelected(List<String> valueList, Package package, bool? value) {
    if (value == true) {
      valueList.add(package.packageName);
    } else {
      valueList.remove(package.packageName);
    }
    ref.read(vpnSettingProvider.notifier).updateState((state) {
      return switch (state.accessControl.mode ==
          AccessControlMode.acceptSelected) {
        true => state.copyWith.accessControl(acceptList: valueList),
        false => state.copyWith.accessControl(rejectList: valueList),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageListSelectorStateProvider);
    final accessControl = state.accessControl;
    final accessControlMode = accessControl.mode;
    final packages = state.getSortList(
      accessControlMode == AccessControlMode.acceptSelected
          ? acceptList
          : rejectList,
    );
    final currentList = accessControl.currentList;
    final packageNameList = packages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(packageNameList);
    final describe = accessControlMode == AccessControlMode.acceptSelected
        ? appLocalizations.accessControlAllowDesc
        : appLocalizations.accessControlNotAllowDesc;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 0,
          child: ListItem.switchItem(
            title: Text(appLocalizations.appAccessControl),
            trailing: accessControl.enable ? _buildRefreshButton() : null,
            delegate: SwitchDelegate(
              value: accessControl.enable,
              onChanged: (enable) {
                ref
                    .read(vpnSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith.accessControl(enable: enable),
                    );
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 12),
        ),
        Flexible(
          child: DisabledMask(
            status: !accessControl.enable,
            child: Column(
              children: [
                ActivateBox(
                  active: accessControl.enable,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: 16,
                      right: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          appLocalizations.selected,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      const Flexible(child: SizedBox(width: 8)),
                                      Flexible(
                                        child: Text(
                                          '${valueList.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(child: Text(describe)),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(child: _buildSearchButton()),
                            Flexible(
                              child: _buildSelectedAllButton(
                                isSelectedAll:
                                    valueList.length == packageNameList.length,
                                allValueList: packageNameList,
                              ),
                            ),
                            Flexible(child: _buildSettingButton()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FutureBuilder(
                    future: _completer.future,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (_packageListPermissionDenied) {
                        return _buildPackageListPermissionDeniedView();
                      }
                      return packages.isEmpty
                          ? NullStatus(label: appLocalizations.noData)
                          : CommonScrollBar(
                              controller: _controller,
                              child: ListView.builder(
                                controller: _controller,
                                itemCount: packages.length,
                                itemExtent: 72,
                                itemBuilder: (_, index) {
                                  final package = packages[index];
                                  return PackageListItem(
                                    key: Key(package.packageName),
                                    package: package,
                                    value: valueList.contains(
                                      package.packageName,
                                    ),
                                    isActive: accessControl.enable,
                                    onChanged: (value) {
                                      _handleSelected(
                                        valueList,
                                        package,
                                        value,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PackageListItem extends ConsumerWidget {
  final Package package;
  final bool value;
  final bool isActive;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceRefresh = ref.watch(forceRefreshIconProvider);

    return ActivateBox(
      active: isActive,
      child: ListItem.checkbox(
        leading: SizedBox(
          width: 48,
          height: 48,
          child: FutureBuilder<Uint8List?>(
            future: app.getPackageIcon(
              package.packageName,
              forceRefresh: forceRefresh,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final devicePixelRatio = MediaQuery.of(
                  context,
                ).devicePixelRatio;
                final cacheSize = (48 * devicePixelRatio).ceil();

                return Image.memory(
                  snapshot.data!,
                  gaplessPlayback: true,
                  width: 48,
                  height: 48,
                  cacheWidth: cacheSize,
                  cacheHeight: cacheSize,
                  errorBuilder: (_, _, _) => _buildDefaultIcon(context),
                );
              }
              return _buildDefaultIcon(context);
            },
          ),
        ),
        title: Text(
          package.label,
          style: const TextStyle(overflow: TextOverflow.ellipsis),
          maxLines: 1,
        ),
        subtitle: Text(
          package.packageName,
          style: const TextStyle(overflow: TextOverflow.ellipsis),
          maxLines: 1,
        ),
        delegate: CheckboxDelegate(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.apps,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class AccessControlSearchDelegate extends SearchDelegate {
  List<String> acceptList = [];
  List<String> rejectList = [];

  AccessControlSearchDelegate({
    required this.acceptList,
    required this.rejectList,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
            return;
          }
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  void _handleSelected(
    WidgetRef ref,
    List<String> valueList,
    Package package,
    bool? value,
  ) {
    if (value == true) {
      valueList.add(package.packageName);
    } else {
      valueList.remove(package.packageName);
    }
    ref.read(vpnSettingProvider.notifier).updateState((state) {
      return switch (state.accessControl.mode ==
          AccessControlMode.acceptSelected) {
        true => state.copyWith.accessControl(acceptList: valueList),
        false => state.copyWith.accessControl(rejectList: valueList),
      };
    });
  }

  Widget _packageList() {
    final lowQuery = query.toLowerCase();
    return Consumer(
      builder: (context, ref, _) {
        final vm3 = ref.watch(
          packageListSelectorStateProvider.select(
            (state) => VM3(
              a: state.getSortList(
                state.accessControl.mode == AccessControlMode.acceptSelected
                    ? acceptList
                    : rejectList,
              ),
              b: state.accessControl.enable,
              c: state.accessControl.currentList,
            ),
          ),
        );
        final packages = vm3.a;

        // Search filter (inside Consumer, auto-responds to query changes)
        final queryPackages = query.isEmpty
            ? packages
            : packages
                  .where(
                    (package) =>
                        package.label.toLowerCase().contains(lowQuery) ||
                        package.packageName.contains(lowQuery),
                  )
                  .toList();

        final isAccessControl = vm3.b;
        final currentList = vm3.c;
        final packageNameList = packages.map((e) => e.packageName).toList();
        final valueList = currentList.intersection(packageNameList);

        return DisabledMask(
          status: !isAccessControl,
          child: ListView.builder(
            itemCount: queryPackages.length,
            itemExtent: 72,
            itemBuilder: (_, index) {
              final package = queryPackages[index];
              return PackageListItem(
                key: Key(package.packageName),
                package: package,
                value: valueList.contains(package.packageName),
                isActive: isAccessControl,
                onChanged: (value) {
                  _handleSelected(ref, valueList, package, value);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _packageList();
  }
}

class AccessControlPanel extends ConsumerStatefulWidget {
  const AccessControlPanel({super.key});

  @override
  ConsumerState createState() => _AccessControlPanelState();
}

class _AccessControlPanelState extends ConsumerState<AccessControlPanel> {
  IconData _getIconWithAccessControlMode(AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => Icons.adjust_outlined,
      AccessControlMode.rejectSelected => Icons.block_outlined,
    };
  }

  String _getTextWithAccessControlMode(AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
  }

  String _getTextWithAccessSortType(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => appLocalizations.defaultText,
      AccessSortType.name => appLocalizations.name,
      AccessSortType.time => appLocalizations.time,
    };
  }

  IconData _getIconWithProxiesSortType(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => Icons.sort,
      AccessSortType.name => Icons.sort_by_alpha,
      AccessSortType.time => Icons.timeline,
    };
  }

  List<Widget> _buildModeSetting() {
    return generateSection(
      title: appLocalizations.mode,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessControlMode = ref.watch(
                vpnSettingProvider.select((state) => state.accessControl.mode),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in AccessControlMode.values)
                    SettingInfoCard(
                      Info(
                        label: _getTextWithAccessControlMode(item),
                        iconData: _getIconWithAccessControlMode(item),
                      ),
                      isSelected: accessControlMode == item,
                      onPressed: () {
                        ref
                            .read(vpnSettingProvider.notifier)
                            .updateState(
                              (state) =>
                                  state.copyWith.accessControl(mode: item),
                            );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSortSetting() {
    return generateSection(
      title: appLocalizations.sort,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessSortType = ref.watch(
                vpnSettingProvider.select((state) => state.accessControl.sort),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in AccessSortType.values)
                    SettingInfoCard(
                      Info(
                        label: _getTextWithAccessSortType(item),
                        iconData: _getIconWithProxiesSortType(item),
                      ),
                      isSelected: accessSortType == item,
                      onPressed: () {
                        ref
                            .read(vpnSettingProvider.notifier)
                            .updateState(
                              (state) =>
                                  state.copyWith.accessControl(sort: item),
                            );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSourceSetting() {
    return generateSection(
      title: appLocalizations.source,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final vm2 = ref.watch(
                vpnSettingProvider.select(
                  (state) => VM2(
                    a: state.accessControl.isFilterSystemApp,
                    b: state.accessControl.isFilterNonInternetApp,
                  ),
                ),
              );
              return Wrap(
                spacing: 16,
                children: [
                  SettingTextCard(
                    appLocalizations.systemApp,
                    isSelected: vm2.a == false,
                    onPressed: () {
                      ref
                          .read(vpnSettingProvider.notifier)
                          .updateState(
                            (state) => state.copyWith.accessControl(
                              isFilterSystemApp: !vm2.a,
                            ),
                          );
                    },
                  ),
                  SettingTextCard(
                    appLocalizations.noNetworkApp,
                    isSelected: vm2.b == false,
                    onPressed: () {
                      ref
                          .read(vpnSettingProvider.notifier)
                          .updateState(
                            (state) => state.copyWith.accessControl(
                              isFilterNonInternetApp: !vm2.b,
                            ),
                          );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard() async {
    await globalState.appController.safeRun(() {
      final data = globalState.config.vpnProps.accessControl.toJson();
      Clipboard.setData(ClipboardData(text: json.encode(data)));
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pasteToClipboard() async {
    await globalState.appController.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      
      AccessControl newAccessControl;
      try {
        newAccessControl = AccessControl.fromJson(json.decode(text));
      } catch (_) {
        final packages = text.split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
            
        final currentState = ref.read(vpnSettingProvider).accessControl;
        final isAccept = currentState.mode == AccessControlMode.acceptSelected;
        
        newAccessControl = currentState.copyWith(
          acceptList: isAccept ? packages : currentState.acceptList,
          rejectList: !isAccept ? packages : currentState.rejectList,
        );
      }

      ref
          .read(vpnSettingProvider.notifier)
          .updateState(
            (state) => state.copyWith(
              accessControl: newAccessControl,
            ),
          );
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  List<Widget> _buildActionSetting() {
    return generateSection(
      title: appLocalizations.action,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            runSpacing: 16,
            spacing: 16,
            children: [
              CommonChip(
                avatar: const Icon(Icons.auto_awesome),
                label: appLocalizations.intelligentSelected,
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
              CommonChip(
                avatar: const Icon(Icons.paste),
                label: appLocalizations.clipboardImport,
                onPressed: _pasteToClipboard,
              ),
              CommonChip(
                avatar: const Icon(Icons.content_copy),
                label: appLocalizations.clipboardExport,
                onPressed: _copyToClipboard,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildModeSetting(),
            ..._buildSortSetting(),
            ..._buildSourceSetting(),
            ..._buildActionSetting(),
          ],
        ),
      ),
    );
  }
}
