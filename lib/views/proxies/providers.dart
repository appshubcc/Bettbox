import 'dart:convert';
import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/models/core.dart';
import 'package:bett_box/models/profile.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef UpdatingMap = Map<String, bool>;

class ProvidersView extends ConsumerStatefulWidget {
  final SheetType type;

  const ProvidersView({super.key, required this.type});

  @override
  ConsumerState<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends ConsumerState<ProvidersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(providersProvider).isEmpty) {
        globalState.appController.updateProviders();
      }
    });
  }

  Future<void> _updateProviders({String? type}) async {
    final allProviders = ref.read(providersProvider);
    final providers = type == null
        ? allProviders
        : allProviders.where((p) => p.type == type).toList();

    if (providers.isEmpty) return;

    final providersNotifier = ref.read(providersProvider.notifier);
    final messages = [];
    final updateProviders = providers.map<Future>((provider) async {
      providersNotifier.setProvider(provider.copyWith(isUpdating: true));
      final message = await clashCore.updateExternalProvider(
        providerName: provider.name,
      );
      if (message.isNotEmpty) {
        messages.add('${provider.name}: $message \n');
      }
      providersNotifier.setProvider(
        await clashCore.getExternalProvider(provider.name),
      );
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

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);
    final proxyProviders = providers
        .where((item) => item.type == 'Proxy')
        .toList();
    final ruleProviders = providers
        .where((item) => item.type == 'Rule')
        .toList();
    final sections = <({String title, List<ExternalProvider> providers, VoidCallback onSync})>[
      if (proxyProviders.isNotEmpty)
        (
          title: appLocalizations.proxyProviders,
          providers: proxyProviders,
          onSync: () => _updateProviders(type: 'Proxy'),
        ),
      if (ruleProviders.isNotEmpty)
        (
          title: appLocalizations.ruleProviders,
          providers: ruleProviders,
          onSync: () => _updateProviders(type: 'Rule'),
        ),
    ];

    return RepaintBoundary(
      child: AdaptiveSheetScaffold(
        actions: [
          IconButton(
            onPressed: _updateProviders,
            icon: const Icon(Icons.sync),
          ),
        ],
        type: widget.type,
        body: Builder(
          builder: (context) {
            final bottomPadding = MediaQuery.of(context).padding.bottom;
            final itemCount = sections.fold<int>(
              0,
              (sum, section) => sum + 1 + section.providers.length,
            );
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 24 + bottomPadding, top: 12),
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
            );
          },
        ),
        title: appLocalizations.providers,
      ),
    );
  }
}

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
      final bytes = platformFile?.bytes;
      if (bytes == null || provider.path == null) return;
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

  String _buildProviderDesc() {
    final updateTimeText = provider.updateAt.lastUpdateTimeDesc;
    final subInfo = provider.subscriptionInfo;
    String infoText;
    if (subInfo == null) {
      infoText = updateTimeText;
    } else {
      final trafficText = _buildTrafficInfoText(subInfo);
      final expireText = _getExpireText(subInfo);
      infoText = trafficText == null
          ? '$expireText - $updateTimeText'
          : '$trafficText · $expireText - $updateTimeText';
    }
    final count = provider.count;
    return count == 0
        ? infoText
        : '$infoText · $count${appLocalizations.entries}';
  }

  String _getExpireText(SubscriptionInfo subscriptionInfo) {
    if (subscriptionInfo.expire == 0) {
      return appLocalizations.infiniteTime;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      subscriptionInfo.expire * 1000,
    ).show;
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
      title: Text(provider.name),
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
                          child: CircularProgressIndicator(),
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
