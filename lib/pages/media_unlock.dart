import 'dart:async';
import 'dart:convert';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

import 'speed_test.dart';
import 'toolbox/common.dart';

class MediaUnlockPage extends ConsumerStatefulWidget {
  final SheetType type;

  const MediaUnlockPage({super.key, this.type = SheetType.page});

  @override
  ConsumerState<MediaUnlockPage> createState() => _MediaUnlockPageState();
}

class _MediaUnlockPageState extends ConsumerState<MediaUnlockPage> {
  MediaCategory? _selectedCategory;
  bool _isStart = false;

  @override
  void dispose() {
    mediaUnlockState.cancelUnattended();
    super.dispose();
  }

  Future<void> _openBatch(MediaPlatform platform) async {
    final groups = ref.read(currentGroupsStateProvider).value;
    final target = await showBatchOutboundPicker(groups: groups);
    if (target == null || !mounted) return;
    final nodes = collectBatchNodes(groups, target);
    showSheet<void>(
      context: context,
      props: const SheetProps(maxWidth: 480),
      builder: (_, type) => _MediaBatchSheet(
        type: type,
        platform: platform,
        nodes: nodes,
        scope: switch (target.scope) {
          OutboundBatchScope.all => appLocalizations.mediaBatchAll,
          _ => target.name,
        },
        icon: _buildPlatformIcon(platform, size: 22),
        statusText: _getStatusText,
      ),
    );
  }

  String _getCategoryLabel(MediaCategory? category) {
    if (category == null) return appLocalizations.categoryAll;
    return switch (category) {
      MediaCategory.ai => appLocalizations.categoryAi,
      MediaCategory.streaming => appLocalizations.categoryStreaming,
      MediaCategory.china => appLocalizations.categoryChina,
      MediaCategory.social => appLocalizations.categorySocial,
      MediaCategory.developer => appLocalizations.categoryDeveloper,
      MediaCategory.gaming => appLocalizations.categoryGaming,
      MediaCategory.crypto => appLocalizations.categoryCrypto,
    };
  }

  Widget _buildCategoryTabs(bool isChinese) {
    final availableCategories = isChinese
        ? MediaCategory.values
        : MediaCategory.values.where((c) => c != MediaCategory.china).toList();
    final categories = [null, ...availableCategories];
    return RepaintBoundary(
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = _selectedCategory == cat;
            return FilterChip(
              key: ValueKey(cat),
              selected: isSelected,
              showCheckmark: false,
              label: Text(_getCategoryLabel(cat)),
              labelStyle: context.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: context.colorScheme.surfaceContainerHigh,
              selectedColor: context.colorScheme.primary,
              side: toolChipSide(
                context,
                selected: isSelected,
                idle: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            );
          },
        ),
      ),
    );
  }

  String _getStatusText(MediaUnlockStatus status, [MediaPlatform? platform]) {
    switch (status) {
      case MediaUnlockStatus.unlocked:
        if (platform?.category == MediaCategory.streaming) {
          return appLocalizations.mediaUnlocked;
        }
        return appLocalizations.unlocked;
      case MediaUnlockStatus.limited:
        if (platform?.category == MediaCategory.streaming) {
          return appLocalizations.limitedUnlock;
        }
        return appLocalizations.flagged;
      case MediaUnlockStatus.flagged:
        return appLocalizations.flagged;
      case MediaUnlockStatus.blocked:
        return appLocalizations.notUnlocked;
      case MediaUnlockStatus.failed:
        return appLocalizations.checkFailed;
      case MediaUnlockStatus.testing:
        return appLocalizations.testing;
      case MediaUnlockStatus.unknown:
        return '-';
    }
  }

  String _getPlatformSvgPath(MediaPlatform platform) {
    return 'assets/svg/${platform.icon}';
  }

  Widget _buildPlatformIcon(
    MediaPlatform platform, {
    MediaUnlockStatus? status,
    double size = 20,
  }) {
    final assetPath = _getPlatformSvgPath(platform);
    final scale = size / 20.0;
    final iconSize = platform.iconSize;
    final iconWidth = iconSize.width * scale;
    final iconHeight = iconSize.height * scale;

    final isUnlocked =
        status == null ||
        status == MediaUnlockStatus.unlocked ||
        status == MediaUnlockStatus.limited ||
        status == MediaUnlockStatus.flagged;
    final isTestingOrUnknown =
        status == MediaUnlockStatus.unknown ||
        status == MediaUnlockStatus.testing;

    final Widget icon;
    if (platform.isMonochrome) {
      icon = SvgPicture.asset(
        assetPath,
        width: iconWidth,
        height: iconHeight,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          isUnlocked
              ? context.colorScheme.onSurface
              : (isTestingOrUnknown
                    ? context.colorScheme.onSurfaceVariant
                    : status.statusColor(context.colorScheme)),
          BlendMode.srcIn,
        ),
      );
    } else if (isUnlocked) {
      icon = SvgPicture.asset(
        assetPath,
        width: iconWidth,
        height: iconHeight,
        fit: BoxFit.contain,
      );
    } else {
      icon = ColorFiltered(
        colorFilter: monochromeColorFilter,
        child: SvgPicture.asset(
          assetPath,
          width: iconWidth,
          height: iconHeight,
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: icon),
    );
  }

  void _showPinnedSettingsDialog() {
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    final categories = isChinese
        ? MediaCategory.values
        : MediaCategory.values.where((c) => c != MediaCategory.china).toList();
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          title: appLocalizations.mediaUnlockDisplaySettings,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: appLocalizations.mediaUnlockMiscSettings,
              onPressed: _showMiscSettingsDialog,
            ),
          ],
          body: _PinnedSettingsView(
            categories: categories,
            labelBuilder: _getCategoryLabel,
            iconBuilder: (platform) => _buildPlatformIcon(platform, size: 18),
          ),
        );
      },
    );
  }

  void _showMiscSettingsDialog() {
    globalState.showAdaptiveSheet<void>(
      child: CommonDialog(
        title: appLocalizations.mediaUnlockMiscSettings,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: 320.ap,
          child: Consumer(
            builder: (context, ref, _) {
              final setting = ref.watch(appSettingProvider);
              void updateSetting(
                AppSettingProps Function(AppSettingProps) updater,
              ) {
                final latest = ref.read(appSettingProvider);
                ref.read(appSettingProvider.notifier).value = updater(latest);
                globalState.appController.savePreferencesDebounce();
              }

              final divider = Divider(
                height: 1,
                thickness: 1,
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: context.colorScheme.brightness == Brightness.light
                      ? 0.6
                      : 0.45,
                ),
                indent: 16,
                endIndent: 16,
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListItem.switchItem(
                    title: Text(
                      appLocalizations.mediaUnlockMoreStreamingPlatforms,
                    ),
                    delegate: SwitchDelegate(
                      value: setting.mediaUnlockMoreStreamingPlatforms,
                      onChanged: (value) {
                        updateSetting(
                          (s) => s.copyWith(
                            mediaUnlockMoreStreamingPlatforms: value,
                          ),
                        );
                      },
                    ),
                  ),
                  divider,
                  ListItem.switchItem(
                    title: Text(appLocalizations.mediaUnlockExtraDetails),
                    delegate: SwitchDelegate(
                      value: setting.mediaUnlockExtraDetails,
                      onChanged: (value) {
                        updateSetting(
                          (s) => s.copyWith(mediaUnlockExtraDetails: value),
                        );
                      },
                    ),
                  ),
                  divider,
                  ListItem.switchItem(
                    title: Text(
                      appLocalizations.mediaUnlockRefreshOnNodeChange,
                    ),
                    delegate: SwitchDelegate(
                      value: setting.mediaUnlockRefreshOnNodeChange,
                      onChanged: (value) {
                        updateSetting(
                          (s) =>
                              s.copyWith(mediaUnlockRefreshOnNodeChange: value),
                        );
                      },
                    ),
                  ),
                  divider,
                  ListItem.switchItem(
                    title: Text(appLocalizations.mediaUnlockColorfulIcons),
                    delegate: SwitchDelegate(
                      value: setting.mediaUnlockColorfulIcons,
                      onChanged: (value) {
                        updateSetting(
                          (s) => s.copyWith(mediaUnlockColorfulIcons: value),
                        );
                      },
                    ),
                  ),
                  divider,
                  ListItem.switchItem(
                    title: Text(appLocalizations.mediaUnlockRefreshByCategory),
                    delegate: SwitchDelegate(
                      value: setting.mediaUnlockRefreshByCategory,
                      onChanged: (value) {
                        updateSetting(
                          (s) =>
                              s.copyWith(mediaUnlockRefreshByCategory: value),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    int unlocked,
    int blocked,
    int other, {
    bool isStreaming = false,
  }) {
    final isLight = context.colorScheme.brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLight
            ? context.colorScheme.surfaceContainerLowest
            : context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: isLight ? 0.45 : 0.25,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            isStreaming
                ? appLocalizations.mediaUnlocked
                : appLocalizations.unlocked,
            '$unlocked',
            mediaUnlockGreen,
          ),
          Container(
            height: 24,
            width: 1,
            color: context.colorScheme.outlineVariant.withValues(
              alpha: isLight ? 0.45 : 0.25,
            ),
          ),
          _buildSummaryItem(
            appLocalizations.notUnlocked,
            '$blocked',
            context.colorScheme.error,
          ),
          Container(
            height: 24,
            width: 1,
            color: context.colorScheme.outlineVariant.withValues(
              alpha: isLight ? 0.45 : 0.25,
            ),
          ),
          _buildSummaryItem(
            appLocalizations.other,
            '$other',
            mediaUnlockOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformRow(
    MediaPlatform platform,
    MediaUnlockResult? result, {
    bool isItemTesting = false,
    required bool showExtraDetails,
  }) {
    final isLight = context.colorScheme.brightness == Brightness.light;
    final isTesting =
        isItemTesting || result?.status == MediaUnlockStatus.testing;
    final status =
        result?.status ??
        (isTesting ? MediaUnlockStatus.testing : MediaUnlockStatus.unknown);
    final color = isTesting
        ? context.colorScheme.primary
        : status.statusColor(context.colorScheme);
    final statusText = isTesting
        ? appLocalizations.testing
        : _getStatusText(status, platform);
    final rawRegion = result?.region;
    final region = rawRegion != null && rawRegion.isNotEmpty
        ? utils.normalizeRegion(rawRegion)
        : null;
    final regionDisplay = region != null && region.isNotEmpty
        ? (region.length == 2
              ? '${utils.countryCodeToEmoji(region)} $region'
              : region)
        : null;
    final latencyText = result?.latency != null ? '${result!.latency}ms' : null;
    final isBrandColor =
        status == MediaUnlockStatus.unknown ||
        status == MediaUnlockStatus.testing ||
        status == MediaUnlockStatus.unlocked ||
        status == MediaUnlockStatus.limited ||
        status == MediaUnlockStatus.flagged;
    final colo = result?.colo;
    final ip = result?.ip;
    final isWarp = result?.isWarp == true;
    final isChinaCategory = platform.category == MediaCategory.china;
    final showColo =
        !isChinaCategory &&
            (showExtraDetails || platform.pinColoBadge) &&
            colo != null &&
            colo.isNotEmpty
        ? colo
        : null;
    final showWarp = !isChinaCategory && showExtraDetails && isWarp;
    final showIp = showExtraDetails && ip != null && ip.isNotEmpty ? ip : null;

    return RepaintBoundary(
      key: ValueKey(platform),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isLight
              ? context.colorScheme.surfaceContainerLowest
              : context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isBrandColor
                    ? (isLight
                          ? context.colorScheme.surfaceContainer
                          : context.colorScheme.surfaceContainerHighest)
                    : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: _buildPlatformIcon(platform, status: status, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    platform.defaultName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (regionDisplay != null ||
                      latencyText != null ||
                      showColo != null ||
                      showWarp ||
                      showIp != null) ...[
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (regionDisplay != null)
                          EmojiText(
                            regionDisplay,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        if (showColo != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  context.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              showColo,
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: context.colorScheme.primary,
                              ),
                            ),
                          ),
                        if (showWarp)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: mediaUnlockOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'WARP',
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: mediaUnlockOrange,
                              ),
                            ),
                          ),
                        if (showIp != null)
                          Text(
                            showIp,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        if (latencyText != null)
                          Text(
                            latencyText,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTesting) ...[
                    RepaintBoundary(
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: SpinKitRing(
                          color: color,
                          lineWidth: 1.2,
                          size: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    statusText,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_isStart && !isChinaCategory)
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: appLocalizations.mediaBatchTest,
                  onPressed: () => _openBatch(platform),
                  icon: Icon(
                    Icons.fact_check_outlined,
                    size: 17,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: isTesting
                    ? null
                    : () {
                        mediaUnlockState.checkSingle(platform);
                      },
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusSectionSlivers({
    required String title,
    required IconData icon,
    required Color color,
    required List<MediaPlatform> platforms,
    required MediaUnlockState state,
    required bool showExtraDetails,
  }) {
    if (platforms.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${platforms.length})',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList.builder(
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          return _buildPlatformRow(
            platform,
            state.results[platform],
            isItemTesting: state.testingPlatforms.contains(platform),
            showExtraDetails: showExtraDetails,
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _isStart = ref.watch(runTimeProvider.select((state) => state != null));
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    final (showExtraDetails, refreshByCategory, showMoreStreaming) = ref.watch(
      appSettingProvider.select(
        (state) => (
          state.mediaUnlockExtraDetails,
          state.mediaUnlockRefreshByCategory,
          state.mediaUnlockMoreStreamingPlatforms,
        ),
      ),
    );

    return ValueListenableBuilder<MediaUnlockState>(
      valueListenable: mediaUnlockState.state,
      builder: (context, state, _) {
        final unlockedList = <MediaPlatform>[];
        final blockedList = <MediaPlatform>[];
        final otherList = <MediaPlatform>[];

        final basePlatforms =
            (isChinese
                    ? MediaPlatform.values
                    : MediaPlatform.values.where(
                        (p) => p.category != MediaCategory.china,
                      ))
                .where(
                  (p) =>
                      showMoreStreaming || !moreStreamingPlatforms.contains(p),
                )
                .toList();

        final effectiveCategory =
            (!isChinese && _selectedCategory == MediaCategory.china)
            ? null
            : _selectedCategory;

        final displayedPlatforms = effectiveCategory == null
            ? basePlatforms
            : basePlatforms
                  .where((p) => p.category == effectiveCategory)
                  .toList();

        final isCategoryLoading = refreshByCategory
            ? mediaUnlockState.isBatchChecking(displayedPlatforms)
            : mediaUnlockState.isBatchChecking();

        for (final p in displayedPlatforms) {
          final status = state.results[p]?.status;
          if (status == MediaUnlockStatus.unlocked) {
            unlockedList.add(p);
          } else if (status == MediaUnlockStatus.blocked ||
              status == MediaUnlockStatus.failed) {
            blockedList.add(p);
          } else {
            otherList.add(p);
          }
        }

        return AdaptiveSheetScaffold(
          type: widget.type,
          title: appLocalizations.mediaUnlock,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: appLocalizations.mediaUnlockDisplaySettings,
              onPressed: _showPinnedSettingsDialog,
            ),
            IconButton(
              onPressed: isCategoryLoading
                  ? null
                  : () {
                      mediaUnlockState.checkAll(
                        force: true,
                        platforms: refreshByCategory
                            ? displayedPlatforms
                            : null,
                      );
                    },
              tooltip: appLocalizations.retry,
              icon: isCategoryLoading
                  ? RepaintBoundary(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: SyncedLoading(
                          size: 16,
                          child: SpinKitRing(
                            color: context.colorScheme.primary,
                            lineWidth: 1.5,
                            size: 16,
                          ),
                        ),
                      ),
                    )
                  : const Icon(Icons.sync),
            ),
          ],
          body: ScrollEdgeRise(
            builder: (_, rise) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: rise)),
                SliverToBoxAdapter(
                  child: _buildSummaryCard(
                    unlockedList.length,
                    blockedList.length,
                    otherList.length,
                    isStreaming: effectiveCategory == MediaCategory.streaming,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                SliverToBoxAdapter(child: _buildCategoryTabs(isChinese)),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                ..._buildStatusSectionSlivers(
                  title: _selectedCategory == MediaCategory.streaming
                      ? appLocalizations.mediaUnlocked
                      : appLocalizations.unlocked,
                  icon: Icons.check_circle_outline_rounded,
                  color: mediaUnlockGreen,
                  platforms: unlockedList,
                  state: state,
                  showExtraDetails: showExtraDetails,
                ),
                ..._buildStatusSectionSlivers(
                  title: appLocalizations.notUnlocked,
                  icon: Icons.cancel_outlined,
                  color: context.colorScheme.error,
                  platforms: blockedList,
                  state: state,
                  showExtraDetails: showExtraDetails,
                ),
                ..._buildStatusSectionSlivers(
                  title: appLocalizations.other,
                  icon: Icons.help_outline_rounded,
                  color: mediaUnlockOrange,
                  platforms: otherList,
                  state: state,
                  showExtraDetails: showExtraDetails,
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: globalState.isAndroidTV ? 48.0 : 24.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PinnedSettingsView extends ConsumerWidget {
  final List<MediaCategory> categories;
  final String Function(MediaCategory category) labelBuilder;
  final Widget Function(MediaPlatform platform) iconBuilder;

  const _PinnedSettingsView({
    required this.categories,
    required this.labelBuilder,
    required this.iconBuilder,
  });

  void _handleChanged(WidgetRef ref, MediaPlatform platform, bool checked) {
    final setting = ref.read(appSettingProvider);
    final pinned = List<MediaPlatform>.from(setting.pinnedMediaPlatforms);
    if (checked) {
      if (pinned.length >= 3) {
        globalState.showNotifier(appLocalizations.mediaUnlockSelectLimit);
        return;
      }
      pinned.add(platform);
    } else {
      if (pinned.length <= 1) return;
      pinned.remove(platform);
    }
    ref.read(appSettingProvider.notifier).value = setting.copyWith(
      pinnedMediaPlatforms: pinned,
    );
    globalState.appController.savePreferencesDebounce();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (pinned, showMore) = ref.watch(
      appSettingProvider.select(
        (state) => (
          state.pinnedMediaPlatforms,
          state.mediaUnlockMoreStreamingPlatforms,
        ),
      ),
    );
    final items = <Object>[
      for (final category in categories) ...[
        category,
        ...MediaPlatform.values.where(
          (p) =>
              p.category == category &&
              (showMore || !moreStreamingPlatforms.contains(p)),
        ),
      ],
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              appLocalizations.mediaUnlockPinnedSettingsDesc,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final item = items[index - 1];
        if (item is MediaCategory) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              labelBuilder(item),
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        final platform = item as MediaPlatform;
        return CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          secondary: Container(
            width: 32,
            height: 32,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: iconBuilder(platform),
          ),
          title: Text(
            platform.defaultName,
            style: context.textTheme.bodyMedium,
          ),
          value: pinned.contains(platform),
          onChanged: (checked) =>
              _handleChanged(ref, platform, checked == true),
        );
      },
    );
  }
}

const _batchConcurrency = 4;

class _MediaBatchItem {
  final String name;
  final MediaUnlockResult? result;
  final bool testing;

  const _MediaBatchItem({
    required this.name,
    this.result,
    this.testing = false,
  });
}

class _MediaBatchSheet extends ConsumerStatefulWidget {
  final SheetType type;
  final MediaPlatform platform;
  final List<String> nodes;
  final String scope;
  final Widget icon;
  final String Function(MediaUnlockStatus status, [MediaPlatform? platform])
  statusText;

  const _MediaBatchSheet({
    required this.type,
    required this.platform,
    required this.nodes,
    required this.scope,
    required this.icon,
    required this.statusText,
  });

  @override
  ConsumerState<_MediaBatchSheet> createState() => _MediaBatchSheetState();
}

class _MediaBatchSheetState extends ConsumerState<_MediaBatchSheet> {
  List<_MediaBatchItem> _items = [];
  final Set<MediaUnlockChecker> _checkers = {};
  bool _running = false;
  int _serial = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.nodes.map((name) => _MediaBatchItem(name: name)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _stop();
    clashCore.stopToolProxy();
    super.dispose();
  }

  void _stop() {
    _serial++;
    for (final checker in _checkers) {
      checker.cancel();
    }
    _checkers.clear();
    if (mounted && _running) {
      setState(() {
        _running = false;
        _items = [
          for (final item in _items)
            item.testing ? _MediaBatchItem(name: item.name) : item,
        ];
      });
    }
  }

  Future<void> _start() async {
    if (_running || _items.isEmpty) return;
    final serial = ++_serial;
    setState(() {
      _running = true;
      _items = [for (final item in _items) _MediaBatchItem(name: item.name)];
    });
    final port = await clashCore.startToolProxy();
    if (!mounted) {
      clashCore.stopToolProxy();
      return;
    }
    if (serial != _serial) return;
    if (port <= 0) {
      setState(() => _running = false);
      return;
    }
    final queue = List<int>.generate(_items.length, (index) => index);
    Future<void> worker() async {
      while (queue.isNotEmpty && serial == _serial && mounted) {
        final index = queue.removeAt(0);
        final name = _items[index].name;
        _update(serial, index, _MediaBatchItem(name: name, testing: true));
        final user = utf8
            .encode(name)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        final checker = MediaUnlockChecker(
          proxy: 'PROXY $user:x@127.0.0.1:$port',
        );
        _checkers.add(checker);
        MediaUnlockResult result;
        try {
          result = await checker.checkPlatform(widget.platform);
        } catch (_) {
          result = MediaUnlockResult(
            platform: widget.platform,
            status: MediaUnlockStatus.failed,
          );
        }
        _checkers.remove(checker);
        _update(serial, index, _MediaBatchItem(name: name, result: result));
      }
    }

    await Future.wait(List.generate(_batchConcurrency, (_) => worker()));
    if (!mounted || serial != _serial) return;
    setState(() => _running = false);
  }

  void _update(int serial, int index, _MediaBatchItem item) {
    if (!mounted || serial != _serial) return;
    setState(() => _items = [..._items]..[index] = item);
  }

  int _rank(_MediaBatchItem item) => switch (item.result?.status) {
    MediaUnlockStatus.unlocked => 0,
    MediaUnlockStatus.limited || MediaUnlockStatus.flagged => 1,
    null when item.testing => 2,
    null => 3,
    MediaUnlockStatus.blocked => 4,
    _ => 5,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final done = _items.where((item) => item.result != null).length;
    final unlocked = _items
        .where((item) => item.result?.status == MediaUnlockStatus.unlocked)
        .length;
    final sorted = [..._items]
      ..sort((a, b) {
        final rank = _rank(a).compareTo(_rank(b));
        if (rank != 0) return rank;
        return (a.result?.latency ?? 1 << 30).compareTo(
          b.result?.latency ?? 1 << 30,
        );
      });
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.mediaBatchTest,
      actions: [
        IconButton(
          tooltip: _running ? appLocalizations.stop : appLocalizations.retry,
          onPressed: _running ? _stop : _start,
          icon: Icon(_running ? Icons.stop_rounded : Icons.refresh_rounded),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(child: widget.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiText(
                        '${widget.platform.defaultName} · ${widget.scope}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        appLocalizations.mediaBatchSummary(
                          done,
                          _items.length,
                          unlocked,
                        ),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_running)
            LinearProgressIndicator(
              minHeight: 2,
              value: _items.isEmpty ? null : done / _items.length,
            )
          else
            const SizedBox(height: 2),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text(
                      appLocalizations.mediaBatchNoNodes,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final item = sorted[index];
                      final result = item.result;
                      final status = item.testing
                          ? MediaUnlockStatus.testing
                          : result?.status ?? MediaUnlockStatus.unknown;
                      final color = item.testing
                          ? colorScheme.primary
                          : status.statusColor(colorScheme);
                      final region = result?.region;
                      final normalized = region == null || region.isEmpty
                          ? ''
                          : utils.normalizeRegion(region);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: EmojiText(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyMedium,
                              ),
                            ),
                            if (normalized.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                normalized.length == 2
                                    ? '${utils.countryCodeToEmoji(normalized)} $normalized'
                                    : normalized,
                                style: context.textTheme.labelSmall,
                              ),
                            ],
                            if (result?.latency case final latency?) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${latency}ms',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(width: 10),
                            Text(
                              widget.statusText(status, widget.platform),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
