import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/media_unlock.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
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
            Text(enabled ? '$count' : appLocalizations.disabled),
            const AppIcon(Icons.chevron_right),
          ],
        ),
        onTap: () => showSheet<void>(
          context: context,
          builder: (_, type) => _ProxyUnlockTagsSettingsSheet(type: type),
        ),
      ),
    );
  }
}

class _ProxyUnlockTagsSettingsSheet extends ConsumerWidget {
  const _ProxyUnlockTagsSettingsSheet({required this.type});

  final SheetType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (enabled, platforms) = ref.watch(
      appSettingProvider.select(
        (settings) =>
            (settings.showProxyUnlockTags, settings.proxyUnlockPlatforms),
      ),
    );
    final setting = ref.read(appSettingProvider.notifier);
    return AdaptiveSheetScaffold(
      title: appLocalizations.proxyUnlockTags,
      type: type,
      body: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            SwitchListTile(
              title: Text(appLocalizations.proxyUnlockTags),
              value: enabled,
              onChanged: (enabled) => setting.updateState(
                (state) => state.copyWith(showProxyUnlockTags: enabled),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: MediaPlatform.values.length,
                itemBuilder: (context, index) {
                  final platform = MediaPlatform.values[index];
                  return SwitchListTile(
                    secondary: mediaPlatformIcon(context, platform, size: 22),
                    title: Text(platform.defaultName),
                    value: platforms.contains(platform),
                    onChanged: (selected) => setting.updateState((state) {
                      final next = state.proxyUnlockPlatforms.toSet();
                      selected ? next.add(platform) : next.remove(platform);
                      return state.copyWith(
                        proxyUnlockPlatforms: [
                          for (final item in MediaPlatform.values)
                            if (next.contains(item)) item,
                        ],
                      );
                    }),
                  );
                },
              ),
            ),
          ],
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
            children: [
              for (final platform in platforms)
                Tooltip(
                  message: platform.defaultName,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _showDetails(context, platform),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: mediaPlatformIcon(
                        context,
                        platform,
                        size: 15,
                        colorful:
                            nodeResults?[platform]?.status ==
                            MediaUnlockStatus.unlocked,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    MediaPlatform platform,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ValueListenableBuilder<MediaUnlockResults>(
        valueListenable: mediaUnlockStore.results,
        builder: (context, results, _) {
          final result = results[proxyName]?[platform];
          final status = result?.status ?? MediaUnlockStatus.unknown;
          final region = result?.region?.trim();
          final ip = result?.ip;
          final colo = result?.colo;
          final latency = result?.latency;
          return CommonDialog(
            title: platform.defaultName,
            titleTrailing: mediaPlatformIcon(
              context,
              platform,
              colorful: status == MediaUnlockStatus.unlocked,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(appLocalizations.confirm),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                _detailRow(appLocalizations.node, proxyName),
                Text(
                  status == MediaUnlockStatus.unknown
                      ? appLocalizations.proxyUnlockNotTested
                      : mediaStatusText(status, platform),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: status == MediaUnlockStatus.unknown
                        ? context.colorScheme.onSurfaceVariant
                        : status.statusColor(context.colorScheme),
                  ),
                ),
                if (region != null && region.isNotEmpty)
                  _detailRow(appLocalizations.regionName, region),
                if (latency != null)
                  _detailRow(appLocalizations.delay, '$latency ms'),
                if (ip != null && ip.isNotEmpty)
                  _detailRow(appLocalizations.ipAddress, ip),
                if (colo != null && colo.isNotEmpty) _detailRow('PoP', colo),
                if (result?.isWarp == true) const Text('WARP'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(title),
        Expanded(child: SelectableText(value, textAlign: TextAlign.end)),
      ],
    );
  }
}
