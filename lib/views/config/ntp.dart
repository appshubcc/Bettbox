import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverrideNtpItem extends ConsumerWidget {
  const OverrideNtpItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final override = ref.watch(overrideNtpProvider);
    return ListItem.switchItem(
      title: Text(appLocalizations.overrideNtp),
      subtitle: Text(appLocalizations.overrideNtpDesc),
      delegate: SwitchDelegate(
        value: override,
        onChanged: (bool value) async {
          ref.read(overrideNtpProvider.notifier).value = value;
        },
      ),
    );
  }
}

class NtpStatusItem extends ConsumerWidget {
  const NtpStatusItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      patchClashConfigProvider.select((state) => state.ntp.enable),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.ntpStatus),
      subtitle: Text(appLocalizations.ntpStatusDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.ntp(enable: value));
        },
      ),
    );
  }
}

class WriteToSystemItem extends ConsumerWidget {
  const WriteToSystemItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // Hide on Android due to lack of root permissions
    if (system.isAndroid) {
      return const SizedBox.shrink();
    }

    final writeToSystem = ref.watch(
      patchClashConfigProvider.select((state) => state.ntp.writeToSystem),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.writeToSystem),
      subtitle: Text(appLocalizations.writeToSystemDesc),
      delegate: SwitchDelegate(
        value: writeToSystem,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.ntp(writeToSystem: value));
        },
      ),
    );
  }
}

class NtpServerItem extends ConsumerWidget {
  const NtpServerItem({super.key});

  // Custom URL marker
  static const String _customUrlMarker = '__CUSTOM_NTP_SERVER__';

  // Pre-computed options list to avoid recreating on every build
  static final List<String> _options = [...presetNtpServers, _customUrlMarker];

  @override
  Widget build(BuildContext context, ref) {
    final server = ref.watch(
      patchClashConfigProvider.select((state) => state.ntp.server),
    );

    // Check if current server is in preset list
    final isPresetServer = presetNtpServers.contains(server);

    return ListItem<String>.options(
      title: Text(appLocalizations.ntpServer),
      subtitle: Text(server),
      delegate: OptionsDelegate<String>(
        title: appLocalizations.ntpServer,
        options: _options,
        value: isPresetServer ? server : _customUrlMarker,
        onChanged: (String? value) async {
          if (value == null) return;

          if (value == _customUrlMarker) {
            // Show custom server input dialog
            final customServer = await globalState.showCommonDialog<String>(
              child: InputDialog(
                title: appLocalizations.customUrl,
                value: isPresetServer ? '' : server,
                resetValue: defaultNtpServer,
                validator: (String? inputValue) {
                  if (inputValue == null || inputValue.isEmpty) {
                    return appLocalizations.emptyTip(
                      appLocalizations.ntpServer,
                    );
                  }
                  return null;
                },
              ),
            );

            if (customServer != null) {
              ref
                  .read(patchClashConfigProvider.notifier)
                  .updateState(
                    (state) => state.copyWith.ntp(server: customServer),
                  );
            }
          } else {
            // Use preset server
            ref
                .read(patchClashConfigProvider.notifier)
                .updateState((state) => state.copyWith.ntp(server: value));
          }
        },
        textBuilder: (server) {
          if (server == _customUrlMarker) {
            return appLocalizations.customUrl;
          }
          return server;
        },
      ),
    );
  }
}

class NtpPortItem extends ConsumerWidget {
  const NtpPortItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final port = ref.watch(
      patchClashConfigProvider.select((state) => state.ntp.port),
    );
    return ListItem.input(
      title: Text(appLocalizations.ntpPort),
      subtitle: Text(port.toString()),
      delegate: InputDelegate(
        title: appLocalizations.ntpPort,
        value: port.toString(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.ntpPort);
          }
          final intValue = int.tryParse(value);
          if (intValue == null) {
            return appLocalizations.numberTip(appLocalizations.ntpPort);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          final intValue = int.tryParse(value);
          if (intValue == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.ntp(port: intValue));
        },
      ),
    );
  }
}

class NtpIntervalItem extends ConsumerWidget {
  const NtpIntervalItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final interval = ref.watch(
      patchClashConfigProvider.select((state) => state.ntp.interval),
    );
    return ListItem.input(
      title: Text(appLocalizations.ntpInterval),
      subtitle: Text(interval.toString()),
      delegate: InputDelegate(
        title: appLocalizations.ntpInterval,
        value: interval.toString(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.ntpInterval);
          }
          final intValue = int.tryParse(value);
          if (intValue == null) {
            return appLocalizations.numberTip(appLocalizations.ntpInterval);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          final intValue = int.tryParse(value);
          if (intValue == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.ntp(interval: intValue));
        },
      ),
    );
  }
}

final ntpItems = <Widget>[
  const OverrideNtpItem(),
  ...generateSection(
    title: appLocalizations.options,
    items: const [
      NtpStatusItem(),
      WriteToSystemItem(),
      NtpServerItem(),
      NtpPortItem(),
      NtpIntervalItem(),
    ],
  ),
];

class NtpListView extends ConsumerWidget {
  const NtpListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return generateListView(ntpItems);
  }
}
