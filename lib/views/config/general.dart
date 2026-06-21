import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final logLevel = ref.watch(
      patchClashConfigProvider.select((state) => state.logLevel),
    );
    return ListItem<LogLevel>.options(
      leading: const Icon(Icons.info_outline),
      title: Text(appLocalizations.logLevel),
      subtitle: Text(logLevel.name),
      delegate: OptionsDelegate<LogLevel>(
        title: appLocalizations.logLevel,
        options: LogLevel.values,
        onChanged: (LogLevel? value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(logLevel: value));
        },
        textBuilder: (logLevel) => logLevel.name,
        value: logLevel,
      ),
    );
  }
}

class UaItem extends ConsumerStatefulWidget {
  const UaItem({super.key});

  @override
  ConsumerState<UaItem> createState() => _UaItemState();
}

class _UaItemState extends ConsumerState<UaItem> {
  String _lastCustomUa = '';

  @override
  Widget build(BuildContext context) {
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    final isCustom = globalUa != null;

    if (isCustom) {
      _lastCustomUa = globalUa;
    }

    return ListItem(
      leading: const Icon(Icons.computer_outlined),
      title: const Text('UA'),
      subtitle: Text(isCustom ? appLocalizations.custom : appLocalizations.defaultText),
      onTap: () async {
        final notifier = ref.read(patchClashConfigProvider.notifier);
        final result = await globalState.showCommonDialog<_UaOption>(
          child: _UaDialog(isCustom: isCustom),
        );

        if (result == null) return;

        switch (result.type) {
          case _UaOptionType.default_:
            notifier.updateState((state) => state.copyWith(globalUa: null));
          case _UaOptionType.custom:
            final customUa = await globalState.showCommonDialog<String>(
              child: InputDialog(
                title: appLocalizations.custom,
                value: _lastCustomUa,
                hintText: 'Clash.Meta',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return appLocalizations.emptyTip('UA');
                  }
                  return null;
                },
              ),
            );
            if (customUa != null && customUa.trim().isNotEmpty) {
              notifier.updateState((state) => state.copyWith(globalUa: customUa.trim()));
            }
        }
      },
    );
  }
}

enum _UaOptionType { default_, custom }

class _UaOption {
  final _UaOptionType type;

  const _UaOption(this.type);
}

class _UaDialog extends StatelessWidget {
  final bool isCustom;

  const _UaDialog({required this.isCustom});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: 'UA',
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Default option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop(const _UaOption(_UaOptionType.default_));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      !isCustom ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 21,
                      color: !isCustom
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      appLocalizations.defaultText,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Custom option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop(const _UaOption(_UaOptionType.custom));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isCustom ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 21,
                      color: isCustom
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      appLocalizations.custom,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeepAliveIntervalItem extends ConsumerWidget {
  const KeepAliveIntervalItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final keepAliveInterval = ref.watch(
      patchClashConfigProvider.select((state) => state.keepAliveInterval),
    );
    return ListItem.input(
      leading: const Icon(Icons.timer_outlined),
      title: Text(appLocalizations.keepAliveIntervalDesc),
      subtitle: Text('$keepAliveInterval ${appLocalizations.seconds}'),
      delegate: InputDelegate(
        title: appLocalizations.keepAliveIntervalDesc,
        suffixText: appLocalizations.seconds,
        resetValue: '$defaultKeepAliveInterval',
        value: '$keepAliveInterval',
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.interval);
          }
          final intValue = int.tryParse(value);
          if (intValue == null) {
            return appLocalizations.numberTip(appLocalizations.interval);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          final intValue = int.parse(value);
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith(keepAliveInterval: intValue),
              );
        },
      ),
    );
  }
}

class TestUrlItem extends ConsumerWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final testUrl = ref.watch(
      appSettingProvider.select((state) => state.testUrl),
    );

    return ListItem(
      leading: const Icon(Icons.timeline),
      title: Text(appLocalizations.testUrl),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(testUrl),
      ),
      onTap: () async {
        await globalState.showCommonDialog(
          child: _TestUrlDialog(currentUrl: testUrl),
        );
      },
    );
  }
}

class _TestUrlDialog extends ConsumerWidget {
  final String currentUrl;

  const _TestUrlDialog({required this.currentUrl});

  @override
  Widget build(BuildContext context, ref) {
    final overrideTestUrl = ref.watch(overrideTestUrlProvider);
    final isPresetUrl = presetTestUrls.contains(currentUrl);

    return CommonDialog(
      title: appLocalizations.testUrl,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Override switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appLocalizations.overrideTestUrl,
                  style: context.textTheme.bodyMedium,
                ),
                Switch(
                  value: overrideTestUrl,
                  onChanged: (bool value) async {
                    ref.read(overrideTestUrlProvider.notifier).value = value;
                    globalState.appController.applyProfileDebounce(silence: true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // URL list
          ...presetTestUrls.map((url) {
            final isSelected = currentUrl == url;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  ref
                      .read(appSettingProvider.notifier)
                      .updateState((state) => state.copyWith(testUrl: url));
                  if (ref.read(overrideTestUrlProvider)) {
                    globalState.appController.applyProfileDebounce(silence: true);
                  }
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 21,
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isSelected
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  url,
                                  style: context.textTheme.bodyMedium,
                                ),
                              )
                            : Text(
                                url,
                                style: context.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Custom URL option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final notifier = ref.read(appSettingProvider.notifier);
                final overrideTestUrl = ref.read(overrideTestUrlProvider);
                Navigator.of(context, rootNavigator: true).pop();
                final customUrl = await globalState.showCommonDialog<String>(
                  child: InputDialog(
                    title: appLocalizations.customUrl,
                    value: isPresetUrl ? '' : currentUrl,
                    resetValue: defaultTestUrl,
                    validator: (String? inputValue) {
                      if (inputValue == null || inputValue.isEmpty) {
                        return appLocalizations.emptyTip(appLocalizations.testUrl);
                      }
                      if (!inputValue.isUrl) {
                        return appLocalizations.urlTip(appLocalizations.testUrl);
                      }
                      return null;
                    },
                  ),
                );

                if (customUrl != null) {
                  notifier.updateState((state) => state.copyWith(testUrl: customUrl));
                  if (overrideTestUrl) {
                    globalState.appController.applyProfileDebounce(silence: true);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      !isPresetUrl
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 21,
                      color: !isPresetUrl
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appLocalizations.customUrl,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PortItem extends ConsumerWidget {
  const PortItem({super.key});

  Future<void> handleShowPortDialog() async {
    await globalState.showCommonDialog(child: _PortDialog());
    // inputDelegate.onChanged(value);
  }

  @override
  Widget build(BuildContext context, ref) {
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return ListItem(
      leading: const Icon(Icons.adjust_outlined),
      title: Text(appLocalizations.port),
      subtitle: Text('$mixedPort'),
      onTap: () {
        handleShowPortDialog();
      },
    );
  }
}

class Ipv6Item extends ConsumerWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final ipv6 = ref.watch(
      patchClashConfigProvider.select((state) => state.ipv6),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.filter_6_rounded),
      title: const Text('IPv6'),
      subtitle: Text(appLocalizations.ipv6Desc),
      delegate: SwitchDelegate(
        value: ipv6,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(ipv6: value));
        },
      ),
    );
  }
}

class AllowLanItem extends ConsumerWidget {
  const AllowLanItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allowLan = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.device_hub),
      title: Text(appLocalizations.allowLan),
      subtitle: Text(appLocalizations.allowLanDesc),
      delegate: SwitchDelegate(
        value: allowLan,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(allowLan: value));
        },
      ),
    );
  }
}

class UnifiedDelayItem extends ConsumerWidget {
  const UnifiedDelayItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final unifiedDelay = ref.watch(
      patchClashConfigProvider.select((state) => state.unifiedDelay),
    );

    return ListItem.switchItem(
      leading: const Icon(Icons.compress_outlined),
      title: Text(appLocalizations.unifiedDelay),
      subtitle: Text(appLocalizations.unifiedDelayDesc),
      delegate: SwitchDelegate(
        value: unifiedDelay,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(unifiedDelay: value));
        },
      ),
    );
  }
}

class FindProcessItem extends ConsumerWidget {
  const FindProcessItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final findProcess = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.findProcessMode == FindProcessMode.always,
      ),
    );

    return ListItem.switchItem(
      leading: const Icon(Icons.polymer_outlined),
      title: Text(appLocalizations.findProcessMode),
      subtitle: Text(appLocalizations.findProcessModeDesc),
      delegate: SwitchDelegate(
        value: findProcess,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith(
                  findProcessMode: value
                      ? FindProcessMode.always
                      : FindProcessMode.off,
                ),
              );
        },
      ),
    );
  }
}

class TcpConcurrentItem extends ConsumerWidget {
  const TcpConcurrentItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final tcpConcurrent = ref.watch(
      patchClashConfigProvider.select((state) => state.tcpConcurrent),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.double_arrow_outlined),
      title: Text(appLocalizations.tcpConcurrent),
      subtitle: Text(appLocalizations.tcpConcurrentDesc),
      delegate: SwitchDelegate(
        value: tcpConcurrent,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(tcpConcurrent: value));
        },
      ),
    );
  }
}

class GeodataLoaderItem extends ConsumerWidget {
  const GeodataLoaderItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isMemconservative = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.geodataLoader == GeodataLoader.memconservative,
      ),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.memory),
      title: Text(appLocalizations.geodataLoader),
      subtitle: Text(appLocalizations.geodataLoaderDesc),
      delegate: SwitchDelegate(
        value: isMemconservative,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith(
                  geodataLoader: value
                      ? GeodataLoader.memconservative
                      : GeodataLoader.standard,
                ),
              );
        },
      ),
    );
  }
}

class ExternalControllerItem extends ConsumerWidget {
  const ExternalControllerItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasExternalController = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.externalController == ExternalControllerStatus.open,
      ),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.api_outlined),
      title: Text(appLocalizations.externalController),
      subtitle: Text(appLocalizations.externalControllerDesc),
      delegate: SwitchDelegate(
        value: hasExternalController,
        onChanged: (bool value) async {
          if (value) {
            // Auto-generate 8-digit password when enabling external controller
            final newSecret = utils.generateSecret();
            ref
                .read(patchClashConfigProvider.notifier)
                .updateState(
                  (state) => state.copyWith(
                    externalController: ExternalControllerStatus.open,
                    secret: newSecret,
                  ),
                );
            // Apply config
            await globalState.appController.applyProfile();
          } else {
            // Disable external controller
            ref
                .read(patchClashConfigProvider.notifier)
                .updateState(
                  (state) => state.copyWith(
                    externalController: ExternalControllerStatus.close,
                  ),
                );
            // Apply config
            await globalState.appController.applyProfile();
          }
        },
      ),
    );
  }
}

class ControlSecretItem extends ConsumerWidget {
  const ControlSecretItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hasExternalController = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.externalController == ExternalControllerStatus.open,
      ),
    );

    // Only show when external controller is enabled
    if (!hasExternalController) {
      return const SizedBox.shrink();
    }

    final secret =
        ref.watch(patchClashConfigProvider.select((state) => state.secret)) ??
        '';

    return ListItem(
      leading: const Icon(Icons.password_outlined),
      title: Text(appLocalizations.controlSecret),
      subtitle: Text(
        secret.isEmpty ? appLocalizations.controlSecretDesc : secret,
      ),
      trailing: secret.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: appLocalizations.onlinePanel,
                  onPressed: () async {
                    final uri = Uri.parse(
                      'http://127.0.0.1:9090/ui/#/setup?hostname=127.0.0.1&port=9090&secret=$secret',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: appLocalizations.copy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: secret));
                    if (context.mounted) {
                      context.showSnackBar(appLocalizations.secretCopied);
                    }
                  },
                ),
              ],
            )
          : null,
      onTap: () async {
        await globalState.showCommonDialog(
          child: _SecretDialog(currentSecret: secret),
        );
      },
    );
  }
}

class _SecretDialog extends ConsumerStatefulWidget {
  final String currentSecret;

  const _SecretDialog({required this.currentSecret});

  @override
  ConsumerState<_SecretDialog> createState() => _SecretDialogState();
}

class _SecretDialogState extends ConsumerState<_SecretDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentSecret);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() == false) return;
    ref
        .read(patchClashConfigProvider.notifier)
        .updateState((state) => state.copyWith(secret: _controller.text));
    Navigator.of(context).pop();
    // Apply config after manual password change
    await globalState.appController.applyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.controlSecret,
      actions: [
        TextButton(onPressed: _handleSave, child: Text(appLocalizations.save)),
      ],
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.controlSecret,
              hintText: appLocalizations.controlSecretDesc,
            ),
          ),
        ),
      ),
    );
  }
}

final generalItems = <Widget>[
  LogLevelItem(),
  UaItem(),
  if (system.isDesktop) KeepAliveIntervalItem(),
  TestUrlItem(),
  PortItem(),
  Ipv6Item(),
  AllowLanItem(),
  UnifiedDelayItem(),
  FindProcessItem(),
  TcpConcurrentItem(),
  GeodataLoaderItem(),
  ExternalControllerItem(),
  ControlSecretItem(),
].separated(const Divider(height: 0)).toList();

class _PortDialog extends ConsumerStatefulWidget {
  const _PortDialog();

  @override
  ConsumerState<_PortDialog> createState() => _PortDialogState();
}

class _PortDialogState extends ConsumerState<_PortDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isMore = false;

  late TextEditingController _mixedPortController;
  late TextEditingController _portController;
  late TextEditingController _socksPortController;
  late TextEditingController _redirPortController;
  late TextEditingController _tProxyPortController;

  @override
  void initState() {
    super.initState();
    final vm5 = ref.read(
      patchClashConfigProvider.select((state) {
        return VM5(
          a: state.mixedPort,
          b: state.port,
          c: state.socksPort,
          d: state.redirPort,
          e: state.tproxyPort,
        );
      }),
    );
    _mixedPortController = TextEditingController(text: vm5.a.toString());
    _portController = TextEditingController(text: vm5.b.toString());
    _socksPortController = TextEditingController(text: vm5.c.toString());
    _redirPortController = TextEditingController(text: vm5.d.toString());
    _tProxyPortController = TextEditingController(text: vm5.e.toString());
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .updateState(
          (state) => state.copyWith(
            mixedPort: 7890,
            port: 0,
            socksPort: 0,
            redirPort: 0,
            tproxyPort: 0,
          ),
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState?.validate() == false) return;
    ref
        .read(patchClashConfigProvider.notifier)
        .updateState(
          (state) => state.copyWith(
            mixedPort: int.parse(_mixedPortController.text),
            port: int.parse(_portController.text),
            socksPort: int.parse(_socksPortController.text),
            redirPort: int.parse(_redirPortController.text),
            tproxyPort: int.parse(_tProxyPortController.text),
          ),
        );
    Navigator.of(context).pop();
  }

  void _handleMore() {
    setState(() {
      _isMore = !_isMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.port,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: _handleMore,
              icon: CommonExpandIcon(expand: _isMore),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _handleReset,
                  child: Text(appLocalizations.reset),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _handleUpdate,
                  child: Text(appLocalizations.submit),
                ),
              ],
            ),
          ],
        ),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 8),
          child: AnimatedSize(
            duration: midDuration,
            curve: Curves.easeOutQuad,
            alignment: Alignment.topCenter,
            child: Column(
              spacing: 24,
              children: [
                TextFormField(
                  keyboardType: TextInputType.url,
                  maxLines: 1,
                  minLines: 1,
                  controller: _mixedPortController,
                  onFieldSubmitted: (_) {
                    _handleUpdate();
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: appLocalizations.mixedPort,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.emptyTip(
                        appLocalizations.mixedPort,
                      );
                    }
                    final port = int.tryParse(value);
                    if (port == null) {
                      return appLocalizations.numberTip(
                        appLocalizations.mixedPort,
                      );
                    }
                    if (port == 0) {
                      return null;
                    }
                    if (port < 1024 || port > 49151) {
                      return appLocalizations.portTip(
                        appLocalizations.mixedPort,
                      );
                    }
                    final ports = [
                      _portController.text,
                      _socksPortController.text,
                      _tProxyPortController.text,
                      _redirPortController.text,
                    ].map((item) => item.trim());
                    if (ports.contains(value.trim())) {
                      return appLocalizations.portConflictTip;
                    }
                    return null;
                  },
                ),
                if (_isMore) ...[
                  TextFormField(
                    keyboardType: TextInputType.url,
                    maxLines: 1,
                    minLines: 1,
                    controller: _portController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.port,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(appLocalizations.port);
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.port,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(appLocalizations.port);
                      }
                      final ports = [
                        _mixedPortController.text,
                        _socksPortController.text,
                        _tProxyPortController.text,
                        _redirPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.url,
                    maxLines: 1,
                    minLines: 1,
                    controller: _socksPortController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.socksPort,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                          appLocalizations.socksPort,
                        );
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.socksPort,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(
                          appLocalizations.socksPort,
                        );
                      }
                      final ports = [
                        _portController.text,
                        _mixedPortController.text,
                        _tProxyPortController.text,
                        _redirPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.url,
                    maxLines: 1,
                    minLines: 1,
                    controller: _redirPortController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.redirPort,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                          appLocalizations.redirPort,
                        );
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.redirPort,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(
                          appLocalizations.redirPort,
                        );
                      }
                      final ports = [
                        _portController.text,
                        _socksPortController.text,
                        _tProxyPortController.text,
                        _mixedPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.url,
                    maxLines: 1,
                    minLines: 1,
                    controller: _tProxyPortController,
                    onFieldSubmitted: (_) {
                      _handleUpdate();
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.tproxyPort,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                          appLocalizations.tproxyPort,
                        );
                      }
                      final port = int.tryParse(value);
                      if (port == null) {
                        return appLocalizations.numberTip(
                          appLocalizations.tproxyPort,
                        );
                      }
                      if (port == 0) {
                        return null;
                      }
                      if (port < 1024 || port > 49151) {
                        return appLocalizations.portTip(
                          appLocalizations.tproxyPort,
                        );
                      }
                      final ports = [
                        _portController.text,
                        _socksPortController.text,
                        _mixedPortController.text,
                        _redirPortController.text,
                      ].map((item) => item.trim());
                      if (ports.contains(value.trim())) {
                        return appLocalizations.portConflictTip;
                      }

                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
