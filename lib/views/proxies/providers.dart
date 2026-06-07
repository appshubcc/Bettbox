import 'dart:convert';
import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/models/core.dart';
import 'package:bett_box/models/profile.dart';
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
      globalState.appController.updateProviders();
    });
  }

  Future<void> _updateProviders() async {
    final providers = ref.read(providersProvider);
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);
    final proxyProviders = providers
        .where((item) => item.type == 'Proxy')
        .map((item) => ProviderItem(provider: item));
    final ruleProviders = providers
        .where((item) => item.type == 'Rule')
        .map((item) => ProviderItem(provider: item));
    final proxySection = generateSection(
      title: appLocalizations.proxyProviders,
      items: proxyProviders,
    );
    final ruleSection = generateSection(
      title: appLocalizations.ruleProviders,
      items: ruleProviders,
    );
    return AdaptiveSheetScaffold(
      actions: [
        IconButton(
          onPressed: () {
            _updateProviders();
          },
          icon: const Icon(Icons.sync),
        ),
      ],
      type: widget.type,
      body: generateListView([...proxySection, ...ruleSection]),
      title: appLocalizations.providers,
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

  String _buildProviderDesc() {
    final baseInfo = provider.updateAt.lastUpdateTimeDesc;
    final trafficInfo = _buildTrafficInfoText(provider.subscriptionInfo);
    final infoText = trafficInfo == null
        ? baseInfo
        : '$trafficInfo  ·  $baseInfo';
    final count = provider.count;
    return switch (count == 0) {
      true => infoText,
      false => '$infoText  ·  $count${appLocalizations.entries}',
    };
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