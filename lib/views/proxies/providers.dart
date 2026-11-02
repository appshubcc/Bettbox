import 'dart:convert';
import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/models/core.dart';
import 'package:bett_box/models/profile.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef UpdatingMap = Map<String, bool>;

Future<void> updateExternalProviders(
  WidgetRef ref,
  BuildContext context, {
  String? type,
}) async {
  final allProviders = ref.read(providersProvider);
  final providers = type == null
      ? allProviders
      : allProviders.where((p) => p.type == type).toList();

  if (providers.isEmpty) return;

  final appController = globalState.appController;
  final messages = [];
  final updateProviders = providers.map<Future>((provider) async {
    appController.setProvider(provider.copyWith(isUpdating: true));
    final message = await clashCore.updateExternalProvider(
      providerName: provider.name,
    );
    if (message.isNotEmpty) {
      messages.add('${provider.name}: $message \n');
    }
    final updated = await clashCore.getExternalProvider(provider.name);
    appController.setProvider(updated);
  });
  final titleMedium = context.textTheme.titleMedium;
  await Future.wait(updateProviders);
  globalState.appController.updateGroupsDebounce();
  final hasRuleProvider = providers.any((p) => p.type == 'Rule');
  if (hasRuleProvider) {
    globalState.appController.applyProfileDebounce(silence: true);
  }
  if (messages.isNotEmpty) {
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        children: [
          for (final message in messages)
            TextSpan(text: message, style: titleMedium),
        ],
      ),
      cancelable: false,
    );
  }
}

class ProvidersView extends ConsumerWidget {
  final SheetType type;

  const ProvidersView({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: AdaptiveSheetScaffold(
        actions: [
          IconButton(
            onPressed: () => updateExternalProviders(ref, context),
            tooltip: appLocalizations.update,
            icon: const Icon(Icons.sync),
          ),
        ],
        type: type,
        body: const ProvidersBody(),
        title: appLocalizations.providers,
      ),
    );
  }
}

class ProvidersBody extends ConsumerStatefulWidget {
  const ProvidersBody({super.key});

  @override
  ConsumerState<ProvidersBody> createState() => _ProvidersBodyState();
}

class _ProvidersBodyState extends ConsumerState<ProvidersBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(globalState.appController.updateProviders);
    });
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);
    final proxyProviders = providers
        .where((item) => item.type == 'Proxy')
        .toList();
    final ruleProviders = providers
        .where((item) => item.type == 'Rule')
        .toList();
    final sections =
        <
          ({
            String title,
            List<ExternalProvider> providers,
            VoidCallback onSync,
          })
        >[
          if (proxyProviders.isNotEmpty)
            (
              title: appLocalizations.proxyProviders,
              providers: proxyProviders,
              onSync: () =>
                  updateExternalProviders(ref, context, type: 'Proxy'),
            ),
          if (ruleProviders.isNotEmpty)
            (
              title: appLocalizations.ruleProviders,
              providers: ruleProviders,
              onSync: () => updateExternalProviders(ref, context, type: 'Rule'),
            ),
        ];

    return Builder(
      builder: (context) {
        final bottomPadding = MediaQuery.paddingOf(context).bottom;
        final itemCount = sections.fold<int>(
          0,
          (sum, section) => sum + 1 + section.providers.length,
        );
        return ScrollEdgeRise(
          builder: (_, rise) {
            final slivers = [
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: 24 + bottomPadding,
                  top: 8 + rise,
                ),
                sliver: SliverList.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    var current = 0;
                    for (final section in sections) {
                      if (index == current) {
                        return ListHeader(
                          title: section.title,
                          padding: current == 0
                              ? const EdgeInsets.only(
                                  left: 16,
                                  right: 8,
                                  top: 4,
                                  bottom: 8,
                                )
                              : null,
                          actions: [
                            IconButton(
                              onPressed: section.onSync,
                              tooltip: appLocalizations.update,
                              icon: const Icon(Icons.sync),
                              iconSize: 20,
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        );
                      }
                      current++;
                      if (index < current + section.providers.length) {
                        final providerIndex = index - current;
                        final provider = section.providers[providerIndex];
                        return ContinuousListItem(
                          index: providerIndex,
                          count: section.providers.length,
                          child: ProviderItem(
                            key: ValueKey(provider.name),
                            provider: provider,
                          ),
                        );
                      }
                      current += section.providers.length;
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ];
            return RouteScrollCacheBuilder(
              builder: (_, cacheExtent) => CustomScrollView(
                scrollCacheExtent: cacheExtent,
                slivers: slivers,
              ),
            );
          },
        );
      },
    );
  }
}

const _ageArmorHeader = '-----BEGIN AGE ENCRYPTED FILE-----';

class ProviderItem extends StatelessWidget {
  final ExternalProvider provider;

  const ProviderItem({super.key, required this.provider});

  Future<void> _handleUpdateProvider() async {
    final appController = globalState.appController;
    if (provider.vehicleType != 'HTTP') return;
    await globalState.appController.safeRun(() async {
      appController.setProvider(provider.copyWith(isUpdating: true));
      final message = await clashCore.updateExternalProvider(
        providerName: provider.name,
      );
      if (message.isNotEmpty) throw message;
    }, silence: false);
    appController.setProvider(
      await clashCore.getExternalProvider(provider.name),
    );
    globalState.appController.updateGroupsDebounce();
    if (provider.type == 'Rule') {
      globalState.appController.applyProfileDebounce(silence: true);
    }
  }

  Future<void> _handleSideLoadProvider() async {
    await globalState.appController.safeRun<void>(() async {
      final platformFile = await picker.pickerFile();
      if (platformFile == null || provider.path == null) return;
      final bytes = await platformFile.readAsBytes();
      if (bytes.isEmpty) return;
      final file = await File(provider.path!).create(recursive: true);
      await file.writeAsBytes(bytes);
      final providerName = provider.name;
      var message = await clashCore.sideLoadExternalProvider(
        providerName: providerName,
        data: utf8.decode(bytes),
      );
      if (message.isNotEmpty) throw message;
      globalState.appController.setProvider(
        await clashCore.getExternalProvider(provider.name),
      );
      if (message.isNotEmpty) throw message;
    });
    globalState.appController.updateGroupsDebounce();
    if (provider.type == 'Rule') {
      globalState.appController.applyProfileDebounce(silence: true);
    }
  }

  Future<void> _handleViewProviderContent(BuildContext context) async {
    await globalState.appController.safeRun(
      () async {
        final path = provider.path;
        String content = '';
        if (path != null && path.isNotEmpty && !path.endsWith('.mrs')) {
          final file = File(path);
          if (await file.exists()) {
            try {
              content = await file.readAsString();
            } catch (_) {}
          }
        }
        if (content.isEmpty) {
          content = await clashCore.parseExternalProviderContent(provider.name);
        }
        final ageSecretKey = globalState.config.currentProfile?.ageSecretKey;
        if (ageSecretKey != null &&
            ageSecretKey.isNotEmpty &&
            content.trimLeft().startsWith(_ageArmorHeader)) {
          final decrypted = await clashCore.decryptAgeConfig(
            content.trim(),
            ageSecretKey,
          );
          if (decrypted.isNotEmpty) content = decrypted;
        }
        if (!context.mounted) return;
        BaseNavigator.push(
          context,
          EditorPage(
            title: '${appLocalizations.view} - ${provider.name}',
            content: content,
            readOnly: true,
            simple: provider.type == 'Rule',
          ),
          maintainState: false,
        );
      },
      needLoading: true,
      title: appLocalizations.tip,
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final subtitleText = provider.subscriptionInfo?.expireDesc;

    return Row(
      children: [
        Flexible(
          child: EmojiText(
            provider.name,
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

  String _buildProviderDesc() {
    final updateTimeText = provider.updateAt.lastUpdateTimeDesc;
    final subInfo = provider.subscriptionInfo;
    final trafficText = _buildTrafficInfoText(subInfo);
    final count = provider.count;
    final countText = count == 0 ? null : '$count${appLocalizations.entries}';

    final parts = [
      if (trafficText != null && trafficText.isNotEmpty) trafficText,
      updateTimeText,
      ?countText,
    ];

    return parts.join(' · ');
  }

  String? _buildTrafficInfoText(SubscriptionInfo? subscriptionInfo) {
    if (subscriptionInfo == null) {
      return null;
    }
    final use = subscriptionInfo.upload + subscriptionInfo.download;
    final total = subscriptionInfo.total;
    if (use == 0 && total == 0) {
      return null;
    }
    if (total == 0) {
      final useShow = TrafficValue(value: use).show;
      return '$useShow / Unlimited';
    }
    final useShow = TrafficValue(value: use).show;
    final totalShow = TrafficValue(value: total).show;
    return '$useShow / $totalShow';
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: _buildTitleRow(context),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(_buildProviderDesc()),
          const SizedBox(height: 4),
          if (provider.subscriptionInfo != null)
            SubscriptionInfoView(subscriptionInfo: provider.subscriptionInfo),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 6,
            spacing: 12,
            runAlignment: WrapAlignment.center,
            children: [
              CommonChip(
                avatar: const Icon(Icons.upload),
                label: appLocalizations.upload,
                onPressed: _handleSideLoadProvider,
              ),
              CommonChip(
                avatar: const Icon(Icons.visibility),
                label: appLocalizations.view,
                onPressed: () => _handleViewProviderContent(context),
              ),
              if (provider.vehicleType == 'HTTP')
                provider.isUpdating
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: SyncedLoading(
                            size: 26,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : CommonChip(
                        avatar: const Icon(Icons.sync),
                        label: appLocalizations.sync,
                        onPressed: _handleUpdateProvider,
                      ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
