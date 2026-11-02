import 'dart:async';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bett_box/views/profiles/add_profile.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:intl/intl.dart';

import 'tile.dart';
import 'quick_options.dart';

class StartButton extends ConsumerStatefulWidget {
  final DashboardTileSize? size;

  const StartButton({super.key, this.size});

  @override
  ConsumerState<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<StartButton> {
  bool _isDisabled = false;
  bool? _optimisticStart;

  void _handleStart() async {
    if (_isDisabled) return;
    final newState =
        ref.read(isSmartStoppedProvider) || ref.read(runTimeProvider) == null;
    setState(() {
      _isDisabled = true;
      _optimisticStart = newState;
    });

    try {
      await globalState.appController.updateStatus(newState);
    } catch (e) {
      commonPrint.error('updateStatus failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDisabled = false;
          _optimisticStart = null;
        });
      }
    }
  }

  Future<void> _handleLongPress() async {
    final isStart = ref.read(runTimeProvider) != null;
    if (!isStart) return;

    final result = await globalState.showMessage(
      title: appLocalizations.restartCoreTitle,
      message: TextSpan(text: appLocalizations.restartCoreDesc),
    );

    if (result == true) {
      await globalState.appController.restartCore();
      globalState.showNotifier(appLocalizations.success);
    }
  }

  void _handleShowAddProfile() {
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: AddProfileView(context: context),
          title: appLocalizations.add,
        );
      },
    );
  }

  List<Widget> _buildChips() {
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));
    final tun = ref.watch(patchClashConfigProvider.select((s) => s.tun.enable));
    final systemProxy = ref.watch(
      networkSettingProvider.select((s) => s.systemProxy),
    );
    return [
      DashboardChip(
        icon: switch (mode) {
          Mode.rule => Icons.alt_route_rounded,
          Mode.global => Icons.language_rounded,
          Mode.direct => Icons.east_rounded,
        },
        label: Intl.message(mode.name),
        onTap: () => showOutboundModeSheet(context),
      ),
      if (system.isDesktop && tun)
        DashboardChip(
          icon: Icons.vpn_lock_rounded,
          label: appLocalizations.tun,
          onTap: () => showTunSheet(context),
        )
      else if (system.isDesktop && systemProxy)
        DashboardChip(
          icon: Icons.settings_ethernet_rounded,
          label: appLocalizations.systemProxy,
          onTap: () => showSystemProxySheet(context),
        ),
    ];
  }

  Widget _buildStatus(
    BuildContext context,
    StartButtonSelectorState state,
    bool isStart,
    bool isRestarting,
    bool isSmartStopped,
  ) {
    final colorScheme = context.colorScheme;
    final textStyle = context.textTheme.bodyMedium?.toLight.adjustSize(1);
    if (isSmartStopped) {
      return Text(
        appLocalizations.coreSuspended,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle?.copyWith(color: colorScheme.outline),
      );
    }
    if (!state.isInit || _isDisabled || isRestarting) {
      return SpinKitThreeBounce(color: colorScheme.primary, size: 16);
    }
    if (!state.hasProfile) {
      return Text(
        appLocalizations.checkOrAddProfile,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }
    if (!isStart) {
      return Text(
        appLocalizations.serviceReady,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }
    return ValueListenableBuilder<int>(
      valueListenable: dashboardRefreshManager.tick1s,
      builder: (_, _, _) => Text(
        _formatRunTime(ref.read(runTimeProvider)),
        maxLines: 1,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, DashboardTileSize size) {
    final state = ref.watch(startButtonSelectorStateProvider);
    final isSmartStopped = ref.watch(isSmartStoppedProvider);
    final isRestarting = ref.watch(isRestartingCoreProvider);
    final isStart = ref.watch(runTimeProvider.select((time) => time != null));
    final displayStart = isSmartStopped ? false : (_optimisticStart ?? isStart);
    final canPress = state.isInit && state.hasProfile && !_isDisabled;
    final hasNoProfile =
        state.isInit && !state.hasProfile && !_isDisabled && !isSmartStopped;
    final colorScheme = context.colorScheme;
    final isTall = size == DashboardTileSize.tall;
    final chips = isStart && !isSmartStopped ? _buildChips() : const <Widget>[];
    final status = _buildStatus(
      context,
      state,
      isStart,
      isRestarting,
      isSmartStopped,
    );
    final icon = displayStart ? Icons.pause_rounded : Icons.play_arrow_rounded;
    final onPressed = canPress
        ? _handleStart
        : hasNoProfile
        ? _handleShowAddProfile
        : null;
    final onLongPress = canPress && !isSmartStopped ? _handleLongPress : null;
    return DashboardTileCard(
      size: size,
      info: Info(
        label: isSmartStopped
            ? appLocalizations.coreSuspended
            : isRestarting
            ? appLocalizations.restartCoreTitle
            : displayStart
            ? appLocalizations.runTime
            : appLocalizations.powerSwitch,
        iconData: Icons.power_settings_new,
      ),
      mark: DashboardDecor.icon(context, Icons.power_settings_new, 80),
      markBottom: !isTall,
      markAngle: isTall ? -0.08 : 0.1,
      onPressed: null,
      onLongPress: null,
      child: isTall
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedContainer(
                        duration: midDuration,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(
                            alpha: displayStart ? 0.14 : 0.08,
                          ),
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onPressed,
                            onLongPress: onLongPress,
                            child: SizedBox.square(
                              dimension: 56,
                              child: Icon(
                                icon,
                                size: 30,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FittedBox(fit: BoxFit.scaleDown, child: status),
                    ),
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final (index, chip) in chips.indexed) ...[
                          if (index > 0) const SizedBox(width: 6),
                          Flexible(child: chip),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(11, 0, 72, 14),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onPressed,
                        onLongPress: onLongPress,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            icon,
                            size: 22,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: FittedBox(fit: BoxFit.scaleDown, child: status),
                    ),
                    for (final chip in chips) ...[
                      const SizedBox(width: 8),
                      Flexible(child: chip),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size case final size?) return _buildTile(context, size);
    final state = ref.watch(startButtonSelectorStateProvider);
    final isSmartStopped = ref.watch(isSmartStoppedProvider);
    final canPress = state.isInit && state.hasProfile && !_isDisabled;
    final hasNoProfile =
        state.isInit && !state.hasProfile && !_isDisabled && !isSmartStopped;
    final isRestarting = ref.watch(isRestartingCoreProvider);
    final isStart = ref.watch(runTimeProvider.select((time) => time != null));
    final displayStart = isSmartStopped ? false : (_optimisticStart ?? isStart);

    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(
          label: isSmartStopped
              ? appLocalizations.coreSuspended
              : isRestarting
              ? appLocalizations.restartCoreTitle
              : displayStart
              ? appLocalizations.runTime
              : appLocalizations.powerSwitch,
          iconData: Icons.power_settings_new,
        ),
        onPressed: canPress
            ? _handleStart
            : hasNoProfile
            ? _handleShowAddProfile
            : null,
        onLongPress: canPress && !isSmartStopped ? _handleLongPress : null,
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: globalState.measure.bodyMediumHeight + 2,
                child: FadeThroughBox(
                  child: _buildContent(
                    context,
                    ref,
                    state,
                    isStart,
                    isRestarting,
                    _isDisabled,
                    isSmartStopped,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    StartButtonSelectorState state,
    bool isStart,
    bool isRestarting,
    bool isDisabled,
    bool isSmartStopped,
  ) {
    if (isSmartStopped) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 20,
            color: context.colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Suspended',
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colorScheme.outline)
                  .adjustSize(1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (!state.isInit || isDisabled || isRestarting) {
      return Container(
        padding: const EdgeInsets.all(2),
        child: Center(
          child: OverflowBox(
            maxWidth: 30,
            maxHeight: 16,
            child: SpinKitThreeBounce(
              color: context.colorScheme.primary,
              size: 16,
            ),
          ),
        ),
      );
    }

    if (!state.hasProfile) {
      return Text(
        appLocalizations.checkOrAddProfile,
        style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (!isStart) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.play_arrow, size: 16, color: context.colorScheme.primary),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              appLocalizations.serviceReady,
              style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.pause, size: 16, color: context.colorScheme.primary),
        const SizedBox(width: 4),
        Text('  ', style: context.textTheme.bodyMedium?.toLight.adjustSize(1)),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: dashboardRefreshManager.tick1s,
            builder: (_, _, _) {
              final runTime = ref.read(runTimeProvider);
              final timeText = _formatRunTime(runTime);
              return Text(
                timeText,
                style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatRunTime(int? timeStamp) {
    if (timeStamp == null) return '00:00:00';

    final diff = timeStamp / 1000;
    int inHours = (diff / 3600).floor();
    int inMinutes = (diff / 60 % 60).floor();
    int inSeconds = (diff % 60).floor();

    // Limit maximum display to 999:59:59
    if (inHours > 999) {
      inHours = 999;
      inMinutes = 59;
      inSeconds = 59;
    }

    // If less than 100 hours, show 2 digits; otherwise 3
    final hourStr = inHours < 100
        ? inHours.toString().padLeft(2, '0')
        : inHours.toString().padLeft(3, '0');

    return '$hourStr:${inMinutes.toString().padLeft(2, '0')}:${inSeconds.toString().padLeft(2, '0')}';
  }
}
