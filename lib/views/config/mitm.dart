import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MitmEnableItem extends ConsumerWidget {
  const MitmEnableItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(mitmSettingProvider.select((state) => state.enable));
    return ListItem.switchItem(
      title: Text(appLocalizations.mitmEnable),
      subtitle: Text(appLocalizations.mitmEnableDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (bool value) async {
          if (value) {
            final ok = await globalState.showMessage(
              title: appLocalizations.mitmWarningTitle,
              message: TextSpan(text: appLocalizations.mitmWarningDesc),
            );
            if (ok != true) return;
          }
          ref.read(mitmSettingProvider.notifier).updateState(
            (state) => state.copyWith(enable: value),
          );
          globalState.appController.applyProfileDebounce(silence: true);
        },
      ),
    );
  }
}

class MitmQuicBlockItem extends ConsumerWidget {
  const MitmQuicBlockItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final value = ref.watch(
      mitmSettingProvider.select((state) => state.quicBlock),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.mitmQuicBlock),
      subtitle: Text(appLocalizations.mitmQuicBlockDesc),
      delegate: SwitchDelegate(
        value: value,
        onChanged: (bool next) {
          ref.read(mitmSettingProvider.notifier).updateState(
            (state) => state.copyWith(quicBlock: next),
          );
          globalState.appController.applyProfileDebounce(silence: true);
        },
      ),
    );
  }
}

class MitmSkipCertVerifyItem extends ConsumerWidget {
  const MitmSkipCertVerifyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final value = ref.watch(
      mitmSettingProvider.select((state) => state.skipCertVerify),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.mitmSkipCertVerify),
      delegate: SwitchDelegate(
        value: value,
        onChanged: (bool next) {
          ref.read(mitmSettingProvider.notifier).updateState(
            (state) => state.copyWith(skipCertVerify: next),
          );
          globalState.appController.applyProfileDebounce(silence: true);
        },
      ),
    );
  }
}

class MitmHostsItem extends ConsumerWidget {
  const MitmHostsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem.next(
      title: Text(appLocalizations.mitmHosts),
      subtitle: Text(appLocalizations.mitmPinningHint),
      delegate: NextDelegate(
        blur: false,
        title: appLocalizations.mitmHosts,
        widget: Consumer(
          builder: (_, ref, _) {
            final hosts = ref.watch(
              mitmSettingProvider.select((state) => state.hosts),
            );
            return ListInputPage(
              title: appLocalizations.mitmHosts,
              items: hosts,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref.read(mitmSettingProvider.notifier).updateState(
                  (state) => state.copyWith(hosts: List.from(items)),
                );
                globalState.appController.applyProfileDebounce(silence: true);
              },
            );
          },
        ),
      ),
    );
  }
}

class MitmRewriteItem extends ConsumerWidget {
  const MitmRewriteItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem.next(
      title: Text(appLocalizations.mitmRewrite),
      delegate: NextDelegate(
        blur: false,
        title: appLocalizations.mitmRewrite,
        widget: Consumer(
          builder: (_, ref, _) {
            final rewrite = ref.watch(
              mitmSettingProvider.select((state) => state.rewrite),
            );
            return ListInputPage(
              title: appLocalizations.mitmRewrite,
              items: rewrite,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref.read(mitmSettingProvider.notifier).updateState(
                  (state) => state.copyWith(rewrite: List.from(items)),
                );
                globalState.appController.applyProfileDebounce(silence: true);
              },
            );
          },
        ),
      ),
    );
  }
}

class MitmCertificateItem extends ConsumerStatefulWidget {
  const MitmCertificateItem({super.key});

  @override
  ConsumerState<MitmCertificateItem> createState() =>
      _MitmCertificateItemState();
}

class _MitmCertificateItemState extends ConsumerState<MitmCertificateItem> {
  Map<String, String>? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final info = await clashCore.getMitmCA();
      if (!mounted) return;
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _info = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fingerprint = _info?['fingerprint'] ?? '';
    final hash = _info?['subject-hash'] ?? '';
    final subtitle = _loading
        ? '...'
        : fingerprint.isEmpty
        ? appLocalizations.mitmNotGenerated
        : '${appLocalizations.mitmFingerprint}: ${fingerprint.length > 16 ? fingerprint.substring(0, 16) : fingerprint}  ($hash)';
    return ListItem(
      title: Text(appLocalizations.mitmCertificate),
      subtitle: Text(subtitle),
    );
  }
}

class MitmExportPemItem extends StatelessWidget {
  const MitmExportPemItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(appLocalizations.mitmExportPem),
      onTap: () async {
        try {
          final info = await clashCore.getMitmCA();
          final pem = info['cert-pem'] ?? '';
          if (pem.isEmpty) {
            globalState.showNotifier(appLocalizations.mitmCaNotReady);
            return;
          }
          await picker.saveFile(
            'bettbox-mitm-ca.pem',
            Uint8List.fromList(pem.codeUnits),
            allowedExtensions: const ['pem', 'crt'],
          );
        } catch (e) {
          globalState.showNotifier(e.toString());
        }
      },
    );
  }
}

class MitmExportModuleItem extends StatelessWidget {
  const MitmExportModuleItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(appLocalizations.mitmExportModule),
      subtitle: Text(appLocalizations.mitmModuleHint),
      onTap: () async {
        try {
          final info = await clashCore.exportMitmModule();
          final path = info['path'] ?? '';
          final filename = info['filename'] ?? 'bettbox-ca.zip';
          if (path.isEmpty) {
            globalState.showNotifier(appLocalizations.mitmCaNotReady);
            return;
          }
          final bytes = await File(path).readAsBytes();
          final saved = await picker.saveFile(
            filename,
            bytes,
            allowedExtensions: const ['zip'],
          );
          if (system.isAndroid) {
            await app.shareFile(saved ?? path, 'application/zip');
          }
        } catch (e) {
          globalState.showNotifier(e.toString());
        }
      },
    );
  }
}

class MitmRegenerateItem extends StatelessWidget {
  const MitmRegenerateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(appLocalizations.mitmRegenerateCA),
      onTap: () async {
        final ok = await globalState.showMessage(
          title: appLocalizations.mitmRegenerateCA,
          message: TextSpan(text: appLocalizations.mitmRegenerateCATip),
        );
        if (ok != true) return;
        try {
          await clashCore.regenerateMitmCA();
          globalState.appController.applyProfileDebounce(silence: true);
        } catch (e) {
          globalState.showNotifier(e.toString());
        }
      },
    );
  }
}

class MitmImportItem extends ConsumerWidget {
  const MitmImportItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem(
      title: Text(appLocalizations.mitmImport),
      onTap: () async {
        final file = await picker.pickerFile(
          allowedExtensions: const ['stoverride', 'sgmodule', 'yaml', 'yml', 'conf'],
        );
        if (file == null) return;
        final content = file.bytes != null
            ? String.fromCharCodes(file.bytes!)
            : (file.path != null ? await File(file.path!).readAsString() : '');
        if (content.isEmpty) return;
        final parsed = parseStOverride(content);
        if (parsed.isEmpty) {
          globalState.showNotifier(appLocalizations.mitmImportEmpty);
          return;
        }
        ref.read(mitmSettingProvider.notifier).updateState((state) {
          return state.copyWith(
            hosts: mergeUnique(state.hosts, parsed.hosts),
            rewrite: mergeUnique(state.rewrite, parsed.rewrite),
          );
        });
        globalState.appController.applyProfileDebounce(silence: true);
        if (parsed.ignoredScripts) {
          globalState.showNotifier(appLocalizations.mitmImportScriptIgnored);
        }
      },
    );
  }
}

final mitmItems = <Widget>[
  ...generateSection(items: const [MitmEnableItem()]),
  ...generateSection(
    title: appLocalizations.options,
    items: const [
      MitmQuicBlockItem(),
      MitmSkipCertVerifyItem(),
      MitmHostsItem(),
      MitmRewriteItem(),
      MitmImportItem(),
    ],
  ),
  ...generateSection(
    title: appLocalizations.mitmCertificate,
    items: const [
      MitmCertificateItem(),
      MitmExportPemItem(),
      MitmExportModuleItem(),
      MitmRegenerateItem(),
    ],
  ),
];

class MitmListView extends ConsumerWidget {
  const MitmListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return generateListView(mitmItems);
  }
}
