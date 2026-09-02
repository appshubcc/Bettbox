import 'dart:ui';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/profiles/edit_profile.dart';
import 'package:bett_box/views/profiles/override_profile.dart';
import 'package:bett_box/views/profiles/scripts.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'add_profile.dart';

class ProfilesView extends ConsumerStatefulWidget {
  const ProfilesView({super.key});

  @override
  ConsumerState<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends ConsumerState<ProfilesView> {
  Function? applyConfigDebounce;

  void _handleShowAddExtendPage() {
    showExtend(
      globalState.navigatorKey.currentState!.context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: AddProfileView(
            context: globalState.navigatorKey.currentState!.context,
          ),
          title: appLocalizations.add,
        );
      },
    );
  }

  Future<void> _updateProfiles() async {
    final profiles = globalState.config.profiles;
    final messages = <String>[];
    final updateProfiles = profiles.map<Future>((profile) async {
      if (profile.type == ProfileType.file) return;
      globalState.appController.setProfile(profile.copyWith(isUpdating: true));
      try {
        await globalState.appController.updateProfile(profile);
      } on Object catch (e) {
        messages.add('${profile.label ?? profile.id}: ${e.formatError}\n');
        globalState.appController.setProfile(
          profile.copyWith(isUpdating: false),
        );
      }
    });
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(
          children: [for (final message in messages) TextSpan(text: message)],
        ),
        cancelable: false,
      );
    }
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        onPressed: () {
          _updateProfiles();
        },
        icon: const Icon(Icons.sync),
        tooltip: appLocalizations.syncAll,
      ),
      IconButton(
        onPressed: () {
          showExtend(
            context,
            builder: (_, type) {
              return const ScriptsView();
            },
          );
        },
        tooltip: appLocalizations.script,
        icon: Consumer(
          builder: (_, ref, _) {
            final isScriptMode = ref.watch(
              scriptStateProvider.select((state) => state.realId != null),
            );
            return Icon(
              Icons.functions,
              color: isScriptMode ? context.colorScheme.primary : null,
            );
          },
        ),
      ),
      IconButton(
        onPressed: () {
          final profiles = globalState.config.profiles;
          showSheet(
            context: context,
            builder: (_, type) {
              return ReorderableProfilesSheet(type: type, profiles: profiles);
            },
          );
        },
        tooltip: appLocalizations.sort,
        icon: const Icon(Icons.sort),
        iconSize: 26,
      ),
    ];
  }

  Widget _buildFAB() {
    final isMobileView = ref.watch(isMobileViewProvider);
    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobileView
            ? getFloatingBottomBarFABReserveHeight(context)
            : 0,
      ),
      child: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _handleShowAddExtendPage,
        icon: const Icon(Icons.add),
        label: Text(appLocalizations.addProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appSettingProvider.select((state) => state.locale));
    return CommonScaffold(
      title: appLocalizations.profiles,
      floatingActionButton: _buildFAB(),
      actions: _buildActions(),
      body: Consumer(
        builder: (_, ref, _) {
          final profilesSelectorState = ref.watch(
            profilesSelectorStateProvider,
          );
          final isMobileView = ref.watch(isMobileViewProvider);
          if (profilesSelectorState.profiles.isEmpty) {
            return NullStatus(label: appLocalizations.nullProfileDesc);
          }
          final columns = system.isAndroid
              ? 1
              : profilesSelectorState.profiles.length <
                    profilesSelectorState.columns
              ? profilesSelectorState.profiles.length
              : profilesSelectorState.columns;
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              key: profilesStoreKey,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    (profilesSelectorState.profiles.isNotEmpty &&
                            profilesSelectorState.profiles.length % columns == 0
                        ? 88
                        : 16) +
                    (isMobileView
                        ? getFloatingBottomBarReserveHeight(context)
                        : 0),
              ),
              child: Grid(
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                crossAxisCount: columns,
                children: [
                  for (
                    int i = 0;
                    i < profilesSelectorState.profiles.length;
                    i++
                  )
                    GridItem(
                      child: ProfileItem(
                        key: Key(profilesSelectorState.profiles[i].id),
                        profile: profilesSelectorState.profiles[i],
                        groupValue: profilesSelectorState.currentProfileId,
                        onChanged: (profileId) {
                          ref.read(currentProfileIdProvider.notifier).value =
                              profileId;
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final Profile profile;
  final String? groupValue;
  final void Function(String? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  Future<void> _handleDeleteProfile(BuildContext context) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (res != true) {
      return;
    }
    await globalState.appController.deleteProfile(profile.id);
  }

  Future<void> _handlePreviewRuntimeConfig(BuildContext context) async {
    await globalState.appController.safeRun(
      () async {
        final patchConfig = globalState.config.patchClashConfig;
        final runtimeConfig = await globalState.patchRawConfig(
          patchConfig: patchConfig,
          profile: profile,
        );
        final content = await encodeYamlTask(runtimeConfig);
        if (!context.mounted) {
          return;
        }

        final previewPage = EditorPage(
          title:
              '${appLocalizations.runtimeConfig} - ${profile.label ?? profile.id}',
          content: content,
          readOnly: true,
        );
        BaseNavigator.push<String>(
          context,
          previewPage,
          maintainState: false,
        );
      },
      needLoading: true,
      title: appLocalizations.tip,
    );
  }

  Future updateProfile() async {
    final appController = globalState.appController;
    if (profile.type == ProfileType.file) return;
    try {
      appController.setProfile(profile.copyWith(isUpdating: true));
      await appController.updateProfile(profile);
    } on Object catch (e) {
      appController.setProfile(profile.copyWith(isUpdating: false));
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(
          text: '${profile.label ?? profile.id}: ${e.formatError}',
        ),
        cancelable: false,
      );
    }
  }

  void _handleShowEditExtendPage(BuildContext context) {
    final editKey = GlobalKey<EditProfileViewState>();
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          actions: [
            IconButton(
              icon: const Icon(Icons.security),
              tooltip: appLocalizations.ageKeyGenerateTitle,
              onPressed: () {
                editKey.currentState?.showAgeKeyGenerator();
              },
            ),
          ],
          body: EditProfileView(
            key: editKey,
            profile: profile,
            context: context,
          ),
          title: appLocalizations.edit,
        );
      },
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    String? subtitleText;
    if (profile.type == ProfileType.file) {
      subtitleText = appLocalizations.localFile;
    } else if (profile.type == ProfileType.url) {
      final info = profile.subscriptionInfo;
      if (info != null &&
          (info.total > 0 ||
              info.upload + info.download > 0 ||
              info.expire > 0)) {
        if (info.expire > 0 &&
            info.expire * 1000 < DateTime.now().millisecondsSinceEpoch) {
          subtitleText = appLocalizations.expired;
        } else if (info.expire == 0) {
          if (info.total > 0) {
            subtitleText = appLocalizations.infiniteTime;
          }
        } else {
          subtitleText =
              DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).show;
        }
      }
    }

    return Row(
      children: [
        Flexible(
          child: EmojiText(
            profile.label ?? profile.id,
            style: context.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (subtitleText != null && subtitleText.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            '·',
            style: context.textTheme.labelMedium?.toLight,
          ),
          const SizedBox(width: 6),
          Text(
            subtitleText,
            style: context.textTheme.labelMedium?.toLight,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildContentInfo(BuildContext context) {
    final subscriptionInfo = profile.subscriptionInfo;
    final updateTimeText = profile.lastUpdateDate?.lastUpdateTimeDesc ?? '';
    final hasUsageBar = subscriptionInfo != null &&
        ((subscriptionInfo.upload + subscriptionInfo.download > 0) ||
            subscriptionInfo.total > 0);

    String bottomText;
    if (hasUsageBar) {
      bottomText = '${_getTrafficText(subscriptionInfo!)} · $updateTimeText';
    } else if (profile.type == ProfileType.url) {
      final trafficText = subscriptionInfo != null
          ? _getTrafficText(subscriptionInfo)
          : 'Unlimited';
      bottomText = '$trafficText · $updateTimeText';
    } else {
      bottomText = '${appLocalizations.lastEdit} · $updateTimeText';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 6),
        SizedBox(
          height: 14,
          child: hasUsageBar
              ? Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.5),
                    child: Container(
                      height: 5,
                      alignment: Alignment.centerLeft,
                      color:
                          context.colorScheme.primary.withValues(alpha: 0.15),
                      child: FractionallySizedBox(
                        widthFactor: (subscriptionInfo!.total > 0
                                ? (subscriptionInfo.upload +
                                        subscriptionInfo.download) /
                                    subscriptionInfo.total
                                : 0.0)
                            .clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      appLocalizations.noUsageData,
                      style: context.textTheme.labelSmall?.toLight?.copyWith(
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          bottomText,
          style: context.textTheme.labelMedium?.toLight,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getTrafficText(SubscriptionInfo subscriptionInfo) {
    final use = subscriptionInfo.upload + subscriptionInfo.download;
    final total = subscriptionInfo.total;

    // Show Unlimited when no traffic info
    if (use == 0 && total == 0) {
      return 'Unlimited';
    }

    // Total is 0 but has usage
    if (total == 0) {
      final useShow = TrafficValue(value: use).show;
      return '$useShow / Unlimited';
    }

    final useShow = TrafficValue(value: use).show;
    final totalShow = TrafficValue(value: total).show;
    return '$useShow / $totalShow';
  }

  // _handleCopyLink(BuildContext context) async {
  //   await Clipboard.setData(
  //     ClipboardData(
  //       text: profile.url,
  //     ),
  //   );
  //   if (context.mounted) {
  //     context.showNotifier(appLocalizations.copySuccess);
  //   }
  // }

  Future<void> _handleExportFile(BuildContext context) async {
    final res = await globalState.appController.safeRun<bool>(
      () async {
        final file = await profile.getFile();
        final rawName = (profile.label ?? profile.id).trim();
        final fileName = (rawName.endsWith('.yaml') || rawName.endsWith('.yml'))
            ? rawName
            : '$rawName.yaml';
        final value = await picker.saveFile(
          fileName,
          await file.readAsBytes(),
          allowedExtensions: ['yaml', 'yml'],
        );
        if (value == null) return false;
        return true;
      },
      needLoading: true,
      title: appLocalizations.tip,
    );
    if (res == true && context.mounted) {
      context.showNotifier(appLocalizations.exportSuccess);
    }
  }

  void _handlePushGenProfilePage(BuildContext context, String id) {
    final overrideProfileView = OverrideProfileView(profileId: id);
    BaseNavigator.push(context, overrideProfileView);
  }

  List<PopupMenuItemData> _buildMenuItems(BuildContext context) {
    return [
      PopupMenuItemData(
        icon: Icons.edit_outlined,
        label: appLocalizations.edit,
        onPressed: () {
          _handleShowEditExtendPage(context);
        },
      ),
      if (profile.type == ProfileType.url) ...[
        PopupMenuItemData(
          icon: Icons.sync_alt_sharp,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile();
          },
        ),
      ],
      PopupMenuItemData(
        icon: Icons.extension_outlined,
        label: appLocalizations.override,
        onPressed: () {
          _handlePushGenProfilePage(context, profile.id);
        },
      ),
      PopupMenuItemData(
        icon: Icons.file_copy_outlined,
        label: appLocalizations.exportFile,
        onPressed: () {
          _handleExportFile(context);
        },
      ),
      PopupMenuItemData(
        icon: Icons.delete_outlined,
        label: appLocalizations.delete,
        onPressed: () {
          _handleDeleteProfile(context);
        },
      ),
    ];
  }

  void _showTVMenu(BuildContext context) {
    final items = _buildMenuItems(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              ListTile(
                leading: item.icon != null ? Icon(item.icon) : null,
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop();
                  item.onPressed!();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    final trailingWidget = SizedBox(
      height: 36,
      width: 36,
      child: FadeThroughBox(
        child: profile.isUpdating
            ? Padding(
                padding: const EdgeInsets.all(6),
                child: SpinKitFadingCircle(
                  color: context.colorScheme.primary,
                  size: 24,
                ),
              )
            : CommonPopupBox(
                popup: CommonPopupMenu(items: _buildMenuItems(context)),
                targetBuilder: (open) {
                  return IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      open();
                    },
                    tooltip: appLocalizations.more,
                    icon: const Icon(Icons.more_vert, size: 20),
                  );
                },
              ),
      ),
    );
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 36),
                child: _buildTitleRow(context),
              ),
              _buildContentInfo(context),
            ],
          ),
        ),
        Positioned(top: 6, right: 6, child: trailingWidget),
      ],
    );
  }

  Widget _buildTVLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onChanged(profile.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleRow(context),
                  _buildContentInfo(context),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showTVMenu(context),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTV = globalState.isAndroidTV;
    return CommonCard(
      isSelected: profile.id == groupValue,
      onPressed: isTV ? null : () => onChanged(profile.id),
      onLongPress: isTV ? null : () => _handlePreviewRuntimeConfig(context),
      child: isTV ? _buildTVLayout(context) : _buildNormalLayout(context),
    );
  }
}

class ReorderableProfilesSheet extends StatefulWidget {
  final List<Profile> profiles;
  final SheetType type;

  const ReorderableProfilesSheet({
    super.key,
    required this.profiles,
    required this.type,
  });

  @override
  State<ReorderableProfilesSheet> createState() =>
      _ReorderableProfilesSheetState();
}

class _ReorderableProfilesSheetState extends State<ReorderableProfilesSheet> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    final profile = profiles[index];
    return AnimatedBuilder(
      animation: animation,
      builder: (_, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        key: Key(profile.id),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: CommonCard(
          type: CommonCardType.filled,
          child: ListTile(
            contentPadding: const EdgeInsets.only(right: 44, left: 16),
            title: EmojiText(profile.label ?? profile.id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: widget.type,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            globalState.appController.setProfiles(profiles);
          },
          icon: Icon(Icons.save),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.only(bottom: 32, top: 16),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          proxyDecorator: proxyDecorator,
          // ignore: deprecated_member_use
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final profile = profiles.removeAt(oldIndex);
              profiles.insert(newIndex, profile);
            });
          },
          itemBuilder: (_, index) {
            final profile = profiles[index];
            return Container(
              key: Key(profile.id),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CommonCard(
                type: CommonCardType.filled,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(right: 16, left: 16),
                  title: EmojiText(profile.label ?? profile.id),
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
            );
          },
          itemCount: profiles.length,
        ),
      ),
      title: appLocalizations.profilesSort,
    );
  }
}
