import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/pages.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class MediaUnlockSmall extends ConsumerStatefulWidget {
  const MediaUnlockSmall({super.key});

  @override
  ConsumerState<MediaUnlockSmall> createState() => _MediaUnlockSmallState();
}

class _MediaUnlockSmallState extends ConsumerState<MediaUnlockSmall> {
  MediaUnlockState? _lastState;
  List<MediaPlatform>? _lastDisplayedPlatforms;
  bool? _lastColorfulIcons;
  ThemeData? _lastTheme;
  Widget? _cachedCard;

  bool _shouldRebuildCard({
    required MediaUnlockState newState,
    required List<MediaPlatform> displayedPlatforms,
    required bool colorfulIcons,
  }) {
    if (_lastState == null ||
        _cachedCard == null ||
        _lastDisplayedPlatforms == null ||
        _lastColorfulIcons == null) {
      return true;
    }
    if (!listEquals(_lastDisplayedPlatforms, displayedPlatforms)) {
      return true;
    }
    if (_lastColorfulIcons != colorfulIcons) {
      return true;
    }
    if (_lastState!.isLoading != newState.isLoading) {
      return true;
    }
    for (final p in displayedPlatforms) {
      if (_lastState!.testingPlatforms.contains(p) !=
          newState.testingPlatforms.contains(p)) {
        return true;
      }
      if (_lastState!.results[p] != newState.results[p]) {
        return true;
      }
    }
    return false;
  }

  Widget _buildPlatformRow(
    MediaPlatform platform,
    MediaUnlockResult? result,
    bool isLoading,
    BuildContext context, {
    bool isItemTesting = false,
    required bool colorfulIcons,
  }) {
    final isTesting =
        isItemTesting ||
        (isLoading &&
            (result == null || result.status == MediaUnlockStatus.testing));
    final status = isTesting
        ? MediaUnlockStatus.testing
        : (result?.status ??
              (isLoading
                  ? MediaUnlockStatus.testing
                  : MediaUnlockStatus.unknown));
    final color = status.statusColor(context.colorScheme);
    final isError =
        status == MediaUnlockStatus.blocked ||
        status == MediaUnlockStatus.failed;
    final latency = result?.latency;
    final String statusDisplay;
    if (status == MediaUnlockStatus.unknown) {
      statusDisplay = '-';
    } else if (isError) {
      statusDisplay = appLocalizations.checkFailed;
    } else if (latency != null) {
      statusDisplay = '${latency}ms';
    } else {
      statusDisplay = '-';
    }

    final iconSize = platform.iconSize;
    final Widget icon;
    if (platform.isMonochrome) {
      icon = SvgPicture.asset(
        'assets/svg/${platform.icon}',
        width: iconSize.width.ap,
        height: iconSize.height.ap,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      );
    } else if (colorfulIcons) {
      icon = SvgPicture.asset(
        'assets/svg/${platform.icon}',
        width: iconSize.width.ap,
        height: iconSize.height.ap,
        fit: BoxFit.contain,
      );
    } else {
      icon = ColorFiltered(
        colorFilter: monochromeColorFilter,
        child: SvgPicture.asset(
          'assets/svg/${platform.icon}',
          width: iconSize.width.ap,
          height: iconSize.height.ap,
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      key: ValueKey(platform),
      height: 24.ap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.ap,
            height: 20.ap,
            child: Center(child: icon),
          ),
          SizedBox(width: 8.ap),
          Expanded(
            child: Text(
              platform.defaultName,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.ap,
                color: context.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.ap),
          if (status == MediaUnlockStatus.testing)
            RepaintBoundary(
              child: SizedBox(
                width: 12.ap,
                height: 12.ap,
                child: SyncedLoading(
                  size: 12.ap,
                  child: SpinKitRing(
                    color: context.colorScheme.primary,
                    lineWidth: 1.5,
                    size: 12.ap,
                  ),
                ),
              ),
            )
          else
            Text(
              statusDisplay,
              textAlign: TextAlign.right,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 10.5.ap,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: color,
              ),
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinned = ref.watch(
      appSettingProvider.select((state) => state.pinnedMediaPlatforms),
    );
    final colorfulIcons = ref.watch(
      appSettingProvider.select((state) => state.mediaUnlockColorfulIcons),
    );
    final displayedPlatforms =
        (pinned.isNotEmpty ? pinned : defaultPinnedMediaPlatforms)
            .take(3)
            .toList();

    return SizedBox(
      height: getWidgetHeight(context, 2),
      child: ValueListenableBuilder<MediaUnlockState>(
        valueListenable: mediaUnlockState.state,
        builder: (context, state, _) {
          final theme = Theme.of(context);
          final shouldRebuild =
              !identical(_lastTheme, theme) ||
              _shouldRebuildCard(
                newState: state,
                displayedPlatforms: displayedPlatforms,
                colorfulIcons: colorfulIcons,
              );
          if (!shouldRebuild) {
            return _cachedCard!;
          }
          _lastTheme = theme;
          _lastState = state;
          _lastDisplayedPlatforms = displayedPlatforms;
          _lastColorfulIcons = colorfulIcons;

          final isWidgetLoading = displayedPlatforms.any(
            state.testingPlatforms.contains,
          );
          final card = CommonCard(
            onPressed: () {
              showExtend(
                context,
                builder: (_, type) => MediaUnlockPage(type: type),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.ap, 10.ap, 8.ap, 6.ap),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 18.ap,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appLocalizations.mediaUnlock,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 24.ap,
                        height: 24.ap,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: isWidgetLoading
                              ? null
                              : () => mediaUnlockState.checkPlatforms(
                                  displayedPlatforms,
                                  force: true,
                                ),
                          icon: isWidgetLoading
                              ? RepaintBoundary(
                                  child: SizedBox(
                                    width: 13.ap,
                                    height: 13.ap,
                                    child: SpinKitRing(
                                      color: context.colorScheme.primary,
                                      lineWidth: 1.5,
                                      size: 13.ap,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.sync,
                                  size: 16.ap,
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.ap),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.ap, 6.ap, 16.ap, 8.ap),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final p in displayedPlatforms)
                          _buildPlatformRow(
                            p,
                            state.results[p],
                            state.isLoading,
                            context,
                            isItemTesting: state.testingPlatforms.contains(p),
                            colorfulIcons: colorfulIcons,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          _cachedCard = card;
          return card;
        },
      ),
    );
  }
}
