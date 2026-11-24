import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/media_unlock.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/profiles/scripts.dart'
    show showSaveChangesDialog;
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProxyUnlockTagsSetting extends ConsumerWidget {
  const ProxyUnlockTagsSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (enabled, count) = ref.watch(
      appSettingProvider.select(
        (settings) => (
          settings.showProxyUnlockTags,
          settings.proxyUnlockPlatforms.length,
        ),
      ),
    );
    return CommonCard(
      type: CommonCardType.filled,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const AppIcon(Icons.travel_explore_rounded),
        title: Text(appLocalizations.proxyUnlockTags),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              enabled ? '$count' : appLocalizations.disabled,
              style: context.textTheme.labelLarge?.toLight,
            ),
            const AppIcon(Icons.chevron_right),
          ],
        ),
        onTap: () => showExtend<void>(
          context,
          builder: (_, type) => _ProxyUnlockTagsSettingsSheet(type: type),
        ),
      ),
    );
  }
}

class _ProxyUnlockTagsSettingsSheet extends ConsumerStatefulWidget {
  const _ProxyUnlockTagsSettingsSheet({required this.type});

  final SheetType type;

  @override
  ConsumerState<_ProxyUnlockTagsSettingsSheet> createState() =>
      _ProxyUnlockTagsSettingsSheetState();
}

class _ProxyUnlockTagsSettingsSheetState
    extends ConsumerState<_ProxyUnlockTagsSettingsSheet> {
  late final bool _initialEnabled;
  late final Set<MediaPlatform> _initialPlatforms;
  late bool _enabled;
  late Set<MediaPlatform> _platforms;

  bool get _dirty =>
      _enabled != _initialEnabled || !setEquals(_platforms, _initialPlatforms);

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingProvider);
    _initialEnabled = _enabled = settings.showProxyUnlockTags;
    _initialPlatforms = settings.proxyUnlockPlatforms.toSet();
    _platforms = {..._initialPlatforms};
  }

  Future<void> _save() async {
    if (!_dirty) return;
    ref
        .read(appSettingProvider.notifier)
        .updateState(
          (settings) => settings.copyWith(
            showProxyUnlockTags: _enabled,
            proxyUnlockPlatforms: [
              for (final platform in MediaPlatform.values)
                if (_platforms.contains(platform)) platform,
            ],
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: () async => !_dirty || await showSaveChangesDialog(onSave: _save),
      child: AdaptiveSheetScaffold(
        title: appLocalizations.proxyUnlockTags,
        type: widget.type,
        actions: [
          IconButton(
            onPressed: _dirty ? _save : null,
            icon: const AppIcon(Icons.save),
            tooltip: appLocalizations.save,
          ),
        ],
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: MediaPlatform.values.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _option(
                title: appLocalizations.proxyUnlockTags,
                icon: const AppIcon(Icons.travel_explore_rounded),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              );
            }
            final platform = MediaPlatform.values[index - 1];
            return _option(
              title: platform.defaultName,
              icon: mediaPlatformIcon(context, platform, size: 24),
              value: _platforms.contains(platform),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _platforms.add(platform);
                  } else {
                    _platforms.remove(platform);
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _option({
    required String title,
    required Widget icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CommonCard(
        type: CommonCardType.filled,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: SizedBox.square(dimension: 24, child: Center(child: icon)),
          title: EmojiText(title),
          trailing: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}

class ProxyUnlockTags extends ConsumerWidget {
  const ProxyUnlockTags({super.key, required this.proxyName});

  final String proxyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platforms = ref.watch(
      appSettingProvider.select(
        (settings) => settings.showProxyUnlockTags
            ? settings.proxyUnlockPlatforms
            : const <MediaPlatform>[],
      ),
    );
    if (platforms.isEmpty ||
        ref.watch(
          groupsProvider.select((groups) => groups.getGroup(proxyName) != null),
        )) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<MediaUnlockResults>(
      valueListenable: mediaUnlockStore.results,
      builder: (context, results, _) {
        final nodeResults = results[proxyName];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: [
              for (final platform in platforms)
                Tooltip(
                  message: platform.defaultName,
                  preferBelow: false,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => globalState.showAdaptiveSheet<void>(
                      child: _UnlockDetails(
                        proxyName: proxyName,
                        platform: platform,
                      ),
                    ),
                    child: mediaPlatformIcon(
                      context,
                      platform,
                      size: 13,
                      alignment: AlignmentDirectional.centerStart,
                      colorful:
                          nodeResults?[platform]?.status ==
                          MediaUnlockStatus.unlocked,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UnlockDetails extends StatelessWidget {
  const _UnlockDetails({required this.proxyName, required this.platform});

  final String proxyName;
  final MediaPlatform platform;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MediaUnlockResults>(
      valueListenable: mediaUnlockStore.results,
      builder: (context, results, _) {
        final result = results[proxyName]?[platform];
        final status = result?.status ?? MediaUnlockStatus.unknown;
        final region = result?.region?.trim();
        final ip = result?.ip;
        final colo = result?.colo;
        final latency = result?.latency;
        final colorScheme = context.colorScheme;
        final statusColor = status == MediaUnlockStatus.unknown
            ? colorScheme.onSurfaceVariant
            : status.statusColor(colorScheme);
        final statusLabel = status == MediaUnlockStatus.unknown
            ? appLocalizations.proxyUnlockNotTested
            : mediaStatusText(status, platform);

        return CommonDialog(
          title: appLocalizations.mediaUnlockDetails,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.confirm),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              _panel(
                context,
                Row(
                  spacing: 10,
                  children: [
                    mediaPlatformIcon(
                      context,
                      platform,
                      size: 24,
                      colorful: status == MediaUnlockStatus.unlocked,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            platform.defaultName,
                            style: context.textTheme.labelMedium,
                          ),
                          EmojiText(
                            proxyName,
                            style: context.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _panel(
                context,
                Column(
                  spacing: 8,
                  children: [
                    _detailRow(
                      context,
                      appLocalizations.mediaUnlock,
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          child: Text(
                            statusLabel,
                            textAlign: TextAlign.end,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (region != null && region.isNotEmpty)
                      _textDetail(
                        context,
                        appLocalizations.countryOrRegion,
                        region,
                      ),
                    if (latency != null)
                      _textDetail(
                        context,
                        appLocalizations.delay,
                        '$latency ms',
                      ),
                    if (ip != null && ip.isNotEmpty)
                      _textDetail(context, appLocalizations.ipAddress, ip),
                    if (colo != null && colo.isNotEmpty)
                      _textDetail(context, 'PoP', colo),
                    if (result?.isWarp == true)
                      _textDetail(context, 'WARP', appLocalizations.enabled),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _panel(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: panelTileDecoration(context),
      child: child,
    );
  }

  Widget _textDetail(BuildContext context, String title, String value) {
    return _detailRow(
      context,
      title,
      SelectableText(
        value,
        textAlign: TextAlign.end,
        style: context.textTheme.bodyMedium,
      ),
    );
  }

  Widget _detailRow(BuildContext context, String title, Widget value) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Align(alignment: AlignmentDirectional.centerEnd, child: value),
        ),
      ],
    );
  }
}
