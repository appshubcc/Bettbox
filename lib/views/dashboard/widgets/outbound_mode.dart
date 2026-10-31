import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';

import 'quick_options.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OutboundMode extends StatelessWidget {
  const OutboundMode({super.key});

  @override
  Widget build(BuildContext context) {
    final height = getWidgetHeight(context, 2);
    return SizedBox(
      height: height,
      child: Consumer(
        builder: (_, ref, _) {
          final mode = ref.watch(
            patchClashConfigProvider.select((state) => state.mode),
          );
          return CommonCard(
            info: Info(
              label: appLocalizations.outboundMode,
              iconData: ReIcons.routing2,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in Mode.values)
                    Flexible(
                      fit: FlexFit.tight,
                      child: Material(
                        color: Colors.transparent,
                        child: Focus(
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;
                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  globalState.appController.changeMode(item);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isFocused && globalState.isAndroidTV
                                        ? context.colorScheme.primary
                                              .withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    border: isFocused && globalState.isAndroidTV
                                        ? Border.all(
                                            color: context.colorScheme.primary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.ap,
                                    vertical: 8.ap,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item == mode
                                            ? ReIcons.tickCircleFilled
                                            : ReIcons.record4,
                                        size: 21,
                                        color: item == mode
                                            ? context.colorScheme.primary
                                            : context
                                                  .colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                      ),
                                      SizedBox(width: 12.ap),
                                      Expanded(
                                        child: Text(
                                          Intl.message(item.name),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.toSoftBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
}

class OutboundModeV2 extends StatelessWidget {
  const OutboundModeV2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InfoHeader(
              padding: EdgeInsets.fromLTRB(16.ap, 11.ap, 12.ap, 0),
              info: Info(
                label: appLocalizations.runningMode,
                iconData: ReIcons.routing2,
              ),
              actions: const [_OutboundStatusChips()],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.ap, 8.ap, 10.ap, 10.ap),
                child: Consumer(
                  builder: (_, ref, _) {
                    final mode = ref.watch(
                      patchClashConfigProvider.select((state) => state.mode),
                    );
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final item in Mode.values) ...[
                          if (item != Mode.values.first)
                            const SizedBox(width: 2),
                          Expanded(
                            child: _OutboundModeButton(
                              mode: item,
                              selected: item == mode,
                              first: item == Mode.values.first,
                              last: item == Mode.values.last,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutboundModeButton extends StatelessWidget {
  final Mode mode;
  final bool selected;
  final bool first;
  final bool last;

  const _OutboundModeButton({
    required this.mode,
    required this.selected,
    required this.first,
    required this.last,
  });

  IconData get _icon => switch (mode) {
    Mode.rule => ReIcons.listSquare,
    Mode.global => ReIcons.global,
    Mode.direct => ReIcons.arrowRight,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final foreground = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.82);
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = Radius.circular(constraints.maxHeight / 2);
        const inner = Radius.circular(8);
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: selected || first ? full : inner,
            right: selected || last ? full : inner,
          ),
        );
        return Focus(
          child: Builder(
            builder: (context) {
              final isFocused =
                  globalState.isAndroidTV && Focus.of(context).hasFocus;
              return AnimatedContainer(
                duration: midDuration,
                curve: Curves.easeOutCubic,
                decoration: ShapeDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(
                          alpha: isLight ? 0.12 : 0.20,
                        )
                      : colorScheme.onSurface.withValues(
                          alpha: isLight ? 0.04 : 0.06,
                        ),
                  shape: shape.copyWith(
                    side: isFocused
                        ? BorderSide(color: colorScheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: shape,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => globalState.appController.changeMode(mode),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_icon, size: 17, color: foreground),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            Intl.message(mode.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: foreground,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
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
      },
    );
  }
}

class _OutboundStatusChips extends ConsumerWidget {
  const _OutboundStatusChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStart = ref.watch(runTimeProvider.select((value) => value != null));
    final realTunEnable = ref.watch(realTunEnableProvider);
    final (tunEnable, systemProxyEnable) = system.isAndroid
        ? ref.watch(
            vpnSettingProvider.select(
              (state) => (state.enable, state.systemProxy),
            ),
          )
        : (
            ref.watch(
              patchClashConfigProvider.select((state) => state.tun.enable),
            ),
            ref.watch(
              networkSettingProvider.select((state) => state.systemProxy),
            ),
          );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusChip(
          label: system.isAndroid ? 'VPN' : 'TUN',
          active: isStart && tunEnable && (system.isAndroid || realTunEnable),
          onTap: () =>
              system.isAndroid ? showVpnSheet(context) : showTunSheet(context),
        ),
        const SizedBox(width: 6),
        _StatusChip(
          label: appLocalizations.systemProxy,
          active: isStart && systemProxyEnable,
          onTap: () => showSystemProxySheet(context),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final color = active
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: midDuration,
          padding: const EdgeInsets.fromLTRB(7, 3, 8, 3),
          decoration: BoxDecoration(
            color: active
                ? colorScheme.primary.withValues(alpha: isLight ? 0.12 : 0.20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
                  ? colorScheme.primary.withValues(alpha: isLight ? 0.28 : 0.36)
                  : colorScheme.outlineVariant.withValues(
                      alpha: isLight ? 0.9 : 0.6,
                    ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: midDuration,
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: active
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
