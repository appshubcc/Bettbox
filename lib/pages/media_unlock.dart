import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class MediaUnlockPage extends ConsumerStatefulWidget {
  final SheetType type;

  const MediaUnlockPage({
    super.key,
    this.type = SheetType.page,
  });

  @override
  ConsumerState<MediaUnlockPage> createState() => _MediaUnlockPageState();
}

class _MediaUnlockPageState extends ConsumerState<MediaUnlockPage> {
  MediaCategory? _selectedCategory;

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
    return SizedBox(
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
            side: BorderSide.none,
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
    return 'assets/images/platforms/${platform.name}.svg';
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

    final isUnlocked = status == null ||
        status == MediaUnlockStatus.unlocked ||
        status == MediaUnlockStatus.limited ||
        status == MediaUnlockStatus.flagged;
    final isTestingOrUnknown =
        status == MediaUnlockStatus.unknown || status == MediaUnlockStatus.testing;

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
    final appSetting = ref.read(appSettingProvider);
    final currentPinned = List<MediaPlatform>.from(appSetting.pinnedMediaPlatforms);
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    final availableCategories = isChinese
        ? MediaCategory.values
        : MediaCategory.values.where((c) => c != MediaCategory.china).toList();

    globalState.showCommonDialog<void>(
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return CommonDialog(
            title: appLocalizations.mediaUnlockDisplaySettings,
            titleTrailing: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                size: 20.ap,
                color: context.colorScheme.onSurfaceVariant,
              ),
              tooltip: appLocalizations.mediaUnlockMiscSettings,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.all(2.ap),
              constraints: const BoxConstraints(),
              onPressed: _showMiscSettingsDialog,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(appLocalizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  ref.read(appSettingProvider.notifier).value = ref
                      .read(appSettingProvider)
                      .copyWith(pinnedMediaPlatforms: currentPinned);
                  globalState.appController.savePreferencesDebounce();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(appLocalizations.confirm),
              ),
            ],
            child: SizedBox(
              width: 320.ap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      appLocalizations.mediaUnlockPinnedSettingsDesc,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 400.ap),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final category in availableCategories) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 4,
                                ),
                                child: Text(
                                  _getCategoryLabel(category),
                                  style:
                                      context.textTheme.labelMedium?.copyWith(
                                    color: context.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              for (final platform in MediaPlatform.values
                                  .where((p) => p.category == category))
                                CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  secondary: Container(
                                    width: 32,
                                    height: 32,
                                    clipBehavior: Clip.antiAlias,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: context
                                          .colorScheme.surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: _buildPlatformIcon(
                                      platform,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    platform.defaultName,
                                    style: context.textTheme.bodyMedium,
                                  ),
                                  value: currentPinned.contains(platform),
                                  onChanged: (bool? checked) {
                                    if (checked == true) {
                                      if (currentPinned.length >= 4) {
                                        globalState.showNotifier(
                                          appLocalizations
                                              .mediaUnlockSelectLimit,
                                        );
                                        return;
                                      }
                                      setDialogState(() {
                                        currentPinned.add(platform);
                                      });
                                    } else {
                                      if (currentPinned.length <= 1) {
                                        return;
                                      }
                                      setDialogState(() {
                                        currentPinned.remove(platform);
                                      });
                                    }
                                  },
                                ),
                            ],
                          ],
                        ),
                      ),
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

  void _showMiscSettingsDialog() {
    globalState.showCommonDialog<void>(
      child: CommonDialog(
        title: appLocalizations.mediaUnlockMiscSettings,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: SizedBox(
          width: 320.ap,
          child: Consumer(
            builder: (context, ref, _) {
              final setting = ref.watch(appSettingProvider);
              void updateSetting(AppSettingProps Function(AppSettingProps) updater) {
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
                    title: Text(appLocalizations.mediaUnlockRefreshOnNodeChange),
                    delegate: SwitchDelegate(
                      value: setting.mediaUnlockRefreshOnNodeChange,
                      onChanged: (value) {
                        updateSetting(
                          (s) => s.copyWith(mediaUnlockRefreshOnNodeChange: value),
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
                          (s) => s.copyWith(mediaUnlockRefreshByCategory: value),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
            const Color(0xFF4CAF50),
          ),
          Container(
            height: 24,
            width: 1,
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          _buildSummaryItem(
            appLocalizations.notUnlocked,
            '$blocked',
            context.colorScheme.error,
          ),
          Container(
            height: 24,
            width: 1,
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          _buildSummaryItem(
            appLocalizations.other,
            '$other',
            Colors.orange,
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
    final isTesting =
        isItemTesting || result?.status == MediaUnlockStatus.testing;
    final status = result?.status ??
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
    final isBrandColor = status == MediaUnlockStatus.unknown ||
        status == MediaUnlockStatus.testing ||
        status == MediaUnlockStatus.unlocked ||
        status == MediaUnlockStatus.limited ||
        status == MediaUnlockStatus.flagged;
    final colo = result?.colo;
    final ip = result?.ip;
    final isWarp = result?.isWarp == true;
    final isChinaCategory = platform.category == MediaCategory.china;
    final showColo = !isChinaCategory &&
            (showExtraDetails || platform.pinColoBadge) &&
            colo != null &&
            colo.isNotEmpty
        ? colo
        : null;
    final showWarp = !isChinaCategory && showExtraDetails && isWarp;
    final showIp =
        showExtraDetails && ip != null && ip.isNotEmpty ? ip : null;

    return Container(
      key: ValueKey(platform),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
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
                  ? context.colorScheme.surfaceContainerHigh
                  : color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: _buildPlatformIcon(
              platform,
              status: status,
              size: 25,
            ),
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
                            color: context.colorScheme.surfaceContainerHighest,
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
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'WARP',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
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
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: SpinKitRing(
                      color: color,
                      lineWidth: 1.2,
                      size: 10,
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
              Icon(
                icon,
                size: 16,
                color: color,
              ),
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
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    final (showExtraDetails, refreshByCategory) = ref.watch(
      appSettingProvider.select(
        (state) => (
          state.mediaUnlockExtraDetails,
          state.mediaUnlockRefreshByCategory,
        ),
      ),
    );

    return ValueListenableBuilder<MediaUnlockState>(
      valueListenable: mediaUnlockState.state,
      builder: (context, state, _) {
        final unlockedList = <MediaPlatform>[];
        final blockedList = <MediaPlatform>[];
        final otherList = <MediaPlatform>[];

        final basePlatforms = isChinese
            ? MediaPlatform.values
            : MediaPlatform.values
                .where((p) => p.category != MediaCategory.china)
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
          } else if (status == MediaUnlockStatus.blocked) {
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
                        platforms:
                            refreshByCategory ? displayedPlatforms : null,
                      );
                    },
              tooltip: appLocalizations.retry,
              icon: isCategoryLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: SpinKitRing(
                        color: context.colorScheme.primary,
                        lineWidth: 1.5,
                        size: 16,
                      ),
                    )
                  : const Icon(Icons.sync),
            ),
          ],
          body: CustomScrollView(
            slivers: [
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
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}
