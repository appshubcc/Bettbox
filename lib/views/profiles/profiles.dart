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
import 'package:material_ui/material_ui.dart';
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
              Icons.terminal_outlined,
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
      body: ActiveConsumer(
        builder: (_, ref) {
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
          return ScrollEdgeRise(
            builder: (context, rise) => Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                key: profilesStoreKey,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16 + rise,
                  bottom:
                      (profilesSelectorState.profiles.isNotEmpty &&
                              profilesSelectorState.profiles.length % columns ==
                                  0
                          ? 88
                          : 16) +
                      (isMobileView
                          ? getFloatingBottomBarReserveHeight(context)
                          : 0),
                ),
                child: Grid(
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
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
        final content = await globalState.getRuntimeConfigContent(
          patchConfig: patchConfig,
          profile: profile,
        );
        if (!context.mounted) {
          return;
        }

        final previewPage = EditorPage(
          title:
              '${appLocalizations.runtimeConfig} - ${profile.label ?? profile.id}',
          content: content,
          readOnly: true,
        );
        BaseNavigator.push<String>(context, previewPage, maintainState: false);
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
    final usages = profile.subscriptionUsages;
    final subtitleText = usages.length > 1
        ? profile.usageExpireText(ProfileUsage.of(profile))
        : profile.type == ProfileType.file
        ? appLocalizations.localFile
        : (usages.firstOrNull?.value ?? profile.subscriptionInfo)?.expireDesc;

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
          Text('·', style: context.textTheme.labelMedium?.toLight),
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

  double? _usageRatio(SubscriptionInfo info) => info.total > 0
      ? ((info.upload + info.download) / info.total).clamp(0.0, 1.0)
      : null;

  String _usagePercent(SubscriptionInfo info) => switch (_usageRatio(info)) {
    final ratio? => '${(ratio * 100).round()}%',
    null => '∞',
  };

  String _compactTrafficText(SubscriptionInfo info) {
    final used = TrafficValue(value: info.upload + info.download);
    if (info.total <= 0) return '${used.shortShow} / ∞';
    final total = TrafficValue(value: info.total);
    if (used.showUnit != total.showUnit) {
      return '${used.shortShow} / ${total.shortShow}';
    }
    return '${used.trafficValueShow.value.fixed(decimals: 1)} / ${total.shortShow}';
  }

  TextStyle? _providerTrafficStyle(
    BuildContext context,
    SubscriptionInfo info,
  ) {
    final expired =
        info.expire > 0 &&
        info.expire * 1000 < DateTime.now().millisecondsSinceEpoch;
    return expired
        ? context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.error,
          )
        : context.textTheme.labelSmall?.toLight;
  }

  Widget _buildProviderName(BuildContext context, String name) {
    return EmojiText(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildUsageBar(BuildContext context, double value) {
    final primary = context.colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 4,
        alignment: Alignment.centerLeft,
        color: primary.withValues(alpha: 0.15),
        child: FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildBarRow(
    BuildContext context,
    MapEntry<String, SubscriptionInfo> usage,
    double top,
  ) {
    final info = usage.value;
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.only(top: top, right: 10),
          child: _buildProviderName(context, usage.key),
        ),
        Padding(
          padding: EdgeInsets.only(top: top),
          child: _buildUsageBar(context, _usageRatio(info) ?? 0),
        ),
        Padding(
          padding: EdgeInsets.only(top: top, left: 10),
          child: Text(
            _compactTrafficText(info),
            maxLines: 1,
            textAlign: TextAlign.right,
            style: _providerTrafficStyle(context, info),
          ),
        ),
      ],
    );
  }

  Widget _buildBarUsages(
    BuildContext context,
    List<MapEntry<String, SubscriptionInfo>> usages,
  ) {
    return Table(
      columnWidths: const {
        0: MinColumnWidth(IntrinsicColumnWidth(), FractionColumnWidth(0.3)),
        1: FlexColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final (index, usage) in usages.indexed)
          _buildBarRow(context, usage, index > 0 ? 7 : 0),
      ],
    );
  }

  Widget _buildRingUsage(
    BuildContext context,
    MapEntry<String, SubscriptionInfo> usage,
    bool compact,
  ) {
    final info = usage.value;
    final primary = context.colorScheme.primary;
    return Row(
      children: [
        RingChart(
          size: 36,
          strokeWidth: 4,
          total: 1,
          trackColor: primary.withValues(alpha: 0.15),
          segments: [
            RingSegment(value: _usageRatio(info) ?? 0, color: primary),
          ],
          centerChild: Text(
            _usagePercent(info),
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProviderName(context, usage.key),
              Text(
                compact
                    ? TrafficValue(value: info.upload + info.download).shortShow
                    : _compactTrafficText(info),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _providerTrafficStyle(context, info),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRingUsages(
    BuildContext context,
    List<MapEntry<String, SubscriptionInfo>> usages,
  ) {
    return Row(
      children: [
        for (final (index, usage) in usages.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(child: _buildRingUsage(context, usage, usages.length > 2)),
        ],
      ],
    );
  }

  Widget _buildConcentricUsages(
    BuildContext context,
    List<MapEntry<String, SubscriptionInfo>> usages,
  ) {
    final primary = context.colorScheme.primary;
    final colors = [
      for (final alpha in const [1.0, 0.7, 0.45])
        primary.withValues(alpha: alpha),
    ];
    return Row(
      children: [
        SizedBox.square(
          dimension: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final (index, usage) in usages.indexed)
                RingChart(
                  size: 52 - index * 14,
                  strokeWidth: 5,
                  total: 1,
                  trackColor: primary.withValues(alpha: 0.12),
                  segments: [
                    RingSegment(
                      value: _usageRatio(usage.value) ?? 0,
                      color: colors[index],
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              for (final (index, usage) in usages.indexed) ...[
                if (index > 0) const SizedBox(height: 2),
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: _buildProviderName(context, usage.key)),
                    const SizedBox(width: 8),
                    Text(
                      [
                        if (_usageRatio(usage.value) != null)
                          _usagePercent(usage.value),
                        _compactTrafficText(usage.value),
                      ].join(' · '),
                      maxLines: 1,
                      style: _providerTrafficStyle(context, usage.value),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderUsages(
    BuildContext context,
    List<MapEntry<String, SubscriptionInfo>> usages,
  ) {
    final shown = usages.topByUsage(3);
    final more = usages.length - shown.length;
    final bottomText = [
      ?ProfileUsage.of(profile)?.usageText,
      profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
      if (more > 0) '+$more',
    ].join(' · ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        switch (profile.usageStyle) {
          ProfileUsageStyle.bar => _buildBarUsages(context, shown),
          ProfileUsageStyle.ring => _buildRingUsages(context, shown),
          ProfileUsageStyle.concentric => _buildConcentricUsages(
            context,
            shown,
          ),
        },
        const SizedBox(height: 8),
        Text(
          bottomText,
          style: context.textTheme.labelMedium?.toLight,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildContentInfo(BuildContext context) {
    final usages = profile.subscriptionUsages;
    if (usages.length > 1) return _buildProviderUsages(context, usages);
    final subscriptionInfo =
        usages.firstOrNull?.value ?? profile.subscriptionInfo;
    final updateTimeText = profile.lastUpdateDate?.lastUpdateTimeDesc ?? '';
    final hasUsageBar =
        subscriptionInfo != null &&
        ((subscriptionInfo.upload + subscriptionInfo.download > 0) ||
            subscriptionInfo.total > 0);

    String bottomText;
    if (hasUsageBar) {
      bottomText = '${_getTrafficText(subscriptionInfo)} · $updateTimeText';
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
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: FractionallySizedBox(
                        widthFactor:
                            (subscriptionInfo.total > 0
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
                      style: context.textTheme.labelSmall?.toLight.copyWith(
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

  Future<void> _handleChangeUsageStyle() async {
    final value = await globalState.showCommonDialog<ProfileUsageStyle>(
      child: OptionsDialog<ProfileUsageStyle>(
        title: appLocalizations.usageStyle,
        options: ProfileUsageStyle.values,
        textBuilder: (style) => switch (style) {
          ProfileUsageStyle.bar => appLocalizations.usageStyleBar,
          ProfileUsageStyle.ring => appLocalizations.usageStyleRing,
          ProfileUsageStyle.concentric => appLocalizations.usageStyleConcentric,
        },
        value: profile.usageStyle,
      ),
    );
    if (value == null) return;
    final appController = globalState.appController;
    final latest = appController.ref
        .read(profilesProvider)
        .getProfile(profile.id);
    if (latest == null || latest.usageStyle == value) return;
    appController.setProfile(latest.copyWith(usageStyle: value));
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
      if (profile.subscriptionUsages.length > 1)
        PopupMenuItemData(
          icon: Icons.donut_large_outlined,
          label: appLocalizations.usageStyle,
          onPressed: _handleChangeUsageStyle,
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
                child: SyncedLoading(
                  size: 24,
                  child: SpinKitFadingCircle(
                    color: context.colorScheme.primary,
                    size: 24,
                  ),
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
                children: [_buildTitleRow(context), _buildContentInfo(context)],
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
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: EdgeInsets.fromLTRB(
          12,
          16,
          12,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
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
      title: appLocalizations.profilesSort,
    );
  }
}
