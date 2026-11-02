import 'dart:typed_data';

import 'package:bett_box/common/archive.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/dav_client.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:bett_box/widgets/fade_box.dart';
import 'package:bett_box/widgets/input.dart';
import 'package:bett_box/widgets/list.dart';
import 'package:bett_box/widgets/text.dart';
import 'package:bett_box/widgets/delay_animation_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class BackupAndRecovery extends ConsumerStatefulWidget {
  const BackupAndRecovery({super.key});

  @override
  ConsumerState<BackupAndRecovery> createState() => _BackupAndRecoveryState();
}

class _BackupAndRecoveryState extends ConsumerState<BackupAndRecovery> {
  DAVClient? _client;
  DAV? _lastDav;

  DAVClient? _getClient(DAV? dav) {
    if (dav == null) {
      _client = null;
      _lastDav = null;
      return null;
    }
    if (_lastDav != dav || _client == null) {
      _lastDav = dav;
      _client = DAVClient(dav);
    }
    return _client;
  }

  Future<void> _showAddWebDAV(DAV? dav) async {
    await globalState.showCommonDialog<String>(
      child: WebDAVFormDialog(dav: dav?.copyWith()),
    );
  }

  void _showBackupSuccess(bool encrypted) {
    globalState.showMessage(
      title: appLocalizations.backup,
      message: TextSpan(
        text: [
          appLocalizations.backupSuccess,
          if (encrypted) appLocalizations.backupEncryptedTip,
        ].join('\n'),
      ),
      cancelable: false,
    );
  }

  void _showRecoverySuccess(bool decrypted) {
    globalState.showMessage(
      title: appLocalizations.recovery,
      message: TextSpan(
        text: [
          appLocalizations.recoverySuccess,
          if (decrypted) appLocalizations.recoveryDecryptedTip,
        ].join('\n'),
      ),
      cancelable: false,
    );
  }

  Future<void> _backupOnWebDAV(DAVClient client, DAV dav) async {
    final encrypted = ref
        .read(appSettingProvider.select((state) => state.backupPassword))
        .isNotEmpty;
    final res = await globalState.appController.safeRun<bool>(
      () => globalState.appController.backupToWebDAV(client, dav),
      needLoading: true,
      title: appLocalizations.backup,
    );
    if (res != true) return;
    _showBackupSuccess(encrypted);
  }

  Future<void> _recoveryOnWebDAV(
    BuildContext context,
    DAVClient client,
    String targetFileName,
    RecoveryOption recoveryOption,
  ) async {
    final res = await globalState.appController.safeRun(
      () async {
        final data = await client.recovery(targetFileName);
        return await globalState.appController.recoveryData(
          data,
          recoveryOption,
        );
      },
      needLoading: true,
      title: appLocalizations.recovery,
    );
    if (res == null) return;
    _showRecoverySuccess(res.decrypted);
  }

  Future<void> _handleRecoveryOnWebDAV(
    BuildContext context,
    DAVClient client,
  ) async {
    final files = await globalState.appController.safeRun<List<webdav.File>>(
      () => client.getBackupFiles(),
      needLoading: true,
      title: appLocalizations.recovery,
    );
    if (!context.mounted) return;
    if (files == null || files.isEmpty) {
      globalState.showNotifier(appLocalizations.noBackupFileFound);
      return;
    }

    final selectedFile = await globalState.showAdaptiveSheet<webdav.File>(
      child: BackupVersionsDialog(files: files),
    );
    if (selectedFile == null || !context.mounted) return;

    final recoveryOption = await globalState.showCommonDialog<RecoveryOption>(
      child: const RecoveryOptionsDialog(),
    );
    if (recoveryOption == null || !context.mounted) return;

    final fileName = selectedFile.name ?? client.fileName;
    _recoveryOnWebDAV(context, client, fileName, recoveryOption);
  }

  Future<void> _backupOnLocal(BuildContext context) async {
    final password = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.backupPassword,
        value: ref.read(
          appSettingProvider.select((state) => state.backupPassword),
        ),
        hintText: appLocalizations.backupPasswordTip,
        obscureText: true,
        validator: _validateBackupPassword,
      ),
    );
    if (password == null || !context.mounted) return;
    final res = await globalState.appController.safeRun<bool>(() async {
      final backupData = await globalState.appController.backupData(
        password: password,
      );
      final value = await picker.saveFile(
        utils.getBackupFileName(),
        Uint8List.fromList(backupData),
      );
      if (value == null) return false;
      return true;
    }, title: appLocalizations.backup);
    if (res != true) return;
    _showBackupSuccess(password.isNotEmpty);
  }

  Future<void> _recoveryOnLocal(RecoveryOption recoveryOption) async {
    final file = await picker.pickerFile();
    final path = file?.path;
    final res = await globalState.appController.safeRun(
      () async {
        if (path != null) {
          return await globalState.appController.recoveryDataFromFile(
            path,
            recoveryOption,
          );
        }
        if (file == null) return null;
        final bytes = await file.readAsBytes();
        return await globalState.appController.recoveryData(
          List<int>.from(bytes),
          recoveryOption,
        );
      },
      needLoading: true,
      title: appLocalizations.recovery,
    );
    if (res == null) return;
    _showRecoverySuccess(res.decrypted);
  }

  Future<void> _handleRecoveryOnLocal(BuildContext context) async {
    final recoveryOption = await globalState.showCommonDialog<RecoveryOption>(
      child: const RecoveryOptionsDialog(),
    );
    if (recoveryOption == null || !context.mounted) return;
    _recoveryOnLocal(recoveryOption);
  }

  String? _validateBackupPassword(String? value) {
    if (value == null || isValidBackupPassword(value)) return null;
    return appLocalizations.backupPasswordTip;
  }

  Future<void> _handleUpdateBackupPassword() async {
    final password = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.backupPassword,
        value: ref.read(
          appSettingProvider.select((state) => state.backupPassword),
        ),
        hintText: appLocalizations.backupPasswordTip,
        resetValue: '',
        obscureText: true,
        validator: _validateBackupPassword,
      ),
    );
    if (password == null) return;
    ref
        .read(appSettingProvider.notifier)
        .updateState((state) => state.copyWith(backupPassword: password));
  }

  void _handleAutoBackupChange(bool value) {
    ref
        .read(appDAVSettingProvider.notifier)
        .updateState((state) => state?.copyWith(autoBackup: value));
    if (value) {
      globalState.appController.autoBackupDebounce();
    }
  }

  void _handleChange(String? value, WidgetRef ref) {
    if (value == null) {
      return;
    }
    ref
        .read(appDAVSettingProvider.notifier)
        .updateState((state) => state?.copyWith(fileName: value));
  }

  Future<void> _handleUpdateRecoveryStrategy(WidgetRef ref) async {
    final recoveryStrategy = ref.read(
      appSettingProvider.select((state) => state.recoveryStrategy),
    );
    final res = await globalState.showAdaptiveSheet(
      child: OptionsDialog<RecoveryStrategy>(
        title: appLocalizations.recoveryStrategy,
        options: RecoveryStrategy.values,
        textBuilder: (mode) => Intl.message('recoveryStrategy_${mode.name}'),
        value: recoveryStrategy,
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .updateState((state) => state.copyWith(recoveryStrategy: res));
  }

  @override
  Widget build(BuildContext context) {
    final dav = ref.watch(appDAVSettingProvider);
    final client = _getClient(dav);
    return generateListView([
      ...generateSection(
        title: appLocalizations.remote,
        items: [
          if (dav == null)
            ListItem(
              leading: const Icon(Icons.account_box),
              title: Text(appLocalizations.noInfo),
              subtitle: Text(appLocalizations.pleaseBindWebDAV),
              trailing: FilledButton.tonal(
                onPressed: () {
                  _showAddWebDAV(dav);
                },
                child: Text(appLocalizations.bind),
              ),
            )
          else ...[
            ListItem(
              leading: const Icon(Icons.account_box),
              title: TooltipText(
                text: Text(
                  dav.user,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(appLocalizations.connectivity),
                    FutureBuilder<bool>(
                      future: client!.pingCompleter.future,
                      builder: (_, snapshot) {
                        return Center(
                          child: FadeThroughBox(
                            child:
                                snapshot.connectionState != ConnectionState.done
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: SyncedLoading(
                                      size: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: snapshot.data == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    width: 12,
                                    height: 12,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () {
                  _showAddWebDAV(dav);
                },
                child: Text(appLocalizations.edit),
              ),
            ),
            ListItem.input(
              title: Text(appLocalizations.file),
              subtitle: Text(dav.fileName),
              delegate: InputDelegate(
                title: appLocalizations.file,
                value: dav.fileName,
                resetValue: defaultDavFileName,
                onChanged: (value) {
                  _handleChange(value, ref);
                },
              ),
            ),
            ListItem.switchItem(
              title: Text(appLocalizations.autoBackup),
              subtitle: Text(appLocalizations.autoBackupDesc),
              delegate: SwitchDelegate(
                value: dav.autoBackup,
                onChanged: _handleAutoBackupChange,
              ),
            ),
            ListItem(
              onTap: () {
                _backupOnWebDAV(client, dav);
              },
              title: Text(appLocalizations.backup),
              subtitle: Text(appLocalizations.remoteBackupDesc),
            ),
            ListItem(
              onTap: () {
                _handleRecoveryOnWebDAV(context, client);
              },
              title: Text(appLocalizations.recovery),
              subtitle: Text(appLocalizations.remoteRecoveryDesc),
            ),
          ],
        ],
      ),
      ...generateSection(
        title: appLocalizations.local,
        items: [
          ListItem(
            onTap: () {
              _backupOnLocal(context);
            },
            title: Text(appLocalizations.backup),
            subtitle: Text(appLocalizations.localBackupDesc),
          ),
          ListItem(
            onTap: () {
              _handleRecoveryOnLocal(context);
            },
            title: Text(appLocalizations.recovery),
            subtitle: Text(appLocalizations.localRecoveryDesc),
          ),
        ],
      ),
      ...generateSection(
        title: appLocalizations.options,
        items: [
          Consumer(
            builder: (_, ref, _) {
              final hasPassword = ref.watch(
                appSettingProvider.select(
                  (state) => state.backupPassword.isNotEmpty,
                ),
              );
              return ListItem(
                onTap: _handleUpdateBackupPassword,
                title: Text(appLocalizations.backupPassword),
                subtitle: Text(appLocalizations.backupPasswordDesc),
                trailing: Icon(hasPassword ? Icons.lock : Icons.lock_open),
              );
            },
          ),
          Consumer(
            builder: (_, ref, _) {
              final recoveryStrategy = ref.watch(
                appSettingProvider.select((state) => state.recoveryStrategy),
              );
              return ListItem(
                onTap: () {
                  _handleUpdateRecoveryStrategy(ref);
                },
                title: Text(appLocalizations.recoveryStrategy),
                subtitle: Text(
                  Intl.message('recoveryStrategyDesc_${recoveryStrategy.name}'),
                ),
                trailing: FilledButton(
                  onPressed: () {
                    _handleUpdateRecoveryStrategy(ref);
                  },
                  child: Text(
                    Intl.message('recoveryStrategy_${recoveryStrategy.name}'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ]);
  }
}

class BackupVersionsDialog extends StatefulWidget {
  final List<webdav.File> files;

  const BackupVersionsDialog({super.key, required this.files});

  @override
  State<BackupVersionsDialog> createState() => _BackupVersionsDialogState();
}

class _BackupVersionsDialogState extends State<BackupVersionsDialog> {
  late webdav.File _selectedFile;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.files.first;
  }

  String? _subtitle(webdav.File file) {
    final sizeText = TrafficValue(value: file.size ?? 0).show;
    final timeText = file.mTime?.lastUpdateTimeDesc ?? '';
    final subtitle = [
      if (sizeText.isNotEmpty) sizeText,
      if (timeText.isNotEmpty) timeText,
    ].join('  ·  ');
    return subtitle.isEmpty ? null : subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final displayFiles = widget.files.take(10).toList();
    return CommonDialog(
      title: appLocalizations.selectBackupVersion,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selectedFile),
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final file in displayFiles)
                OptionItem(
                  text: file.name ?? '',
                  subtitle: _subtitle(file),
                  selected: file == _selectedFile,
                  onTap: () => setState(() => _selectedFile = file),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecoveryOptionsDialog extends StatefulWidget {
  const RecoveryOptionsDialog({super.key});

  @override
  State<RecoveryOptionsDialog> createState() => _RecoveryOptionsDialogState();
}

class _RecoveryOptionsDialogState extends State<RecoveryOptionsDialog> {
  void _handleOnTab(RecoveryOption? value) {
    if (value == null) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.recovery,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Wrap(
        children: [
          ListItem(
            onTap: () {
              _handleOnTab(RecoveryOption.onlyProfiles);
            },
            title: Text(appLocalizations.recoveryProfiles),
          ),
          ListItem(
            onTap: () {
              _handleOnTab(RecoveryOption.all);
            },
            title: Text(appLocalizations.recoveryAll),
          ),
        ],
      ),
    );
  }
}

class WebDAVFormDialog extends ConsumerStatefulWidget {
  final DAV? dav;

  const WebDAVFormDialog({super.key, this.dav});

  @override
  ConsumerState<WebDAVFormDialog> createState() => _WebDAVFormDialogState();
}

class _WebDAVFormDialogState extends ConsumerState<WebDAVFormDialog> {
  late TextEditingController uriController;
  late TextEditingController userController;
  late TextEditingController passwordController;
  final _obscureController = ValueNotifier<bool>(true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    uriController = TextEditingController(text: widget.dav?.uri);
    userController = TextEditingController(text: widget.dav?.user);
    passwordController = TextEditingController(text: widget.dav?.password);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final uri = uriController.text;
    final user = userController.text;
    final password = passwordController.text;
    ref.read(appDAVSettingProvider.notifier).value =
        widget.dav?.copyWith(uri: uri, user: user, password: password) ??
        DAV(uri: uri, user: user, password: password);
    Navigator.pop(context);
  }

  void _delete() {
    ref.read(appDAVSettingProvider.notifier).value = null;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    uriController.dispose();
    userController.dispose();
    passwordController.dispose();
    _obscureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.webDAVConfiguration,
      actions: [
        if (widget.dav != null)
          TextButton(onPressed: _delete, child: Text(appLocalizations.delete)),
        TextButton(onPressed: _submit, child: Text(appLocalizations.save)),
      ],
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              controller: uriController,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link),
                border: const OutlineInputBorder(),
                labelText: appLocalizations.address,
                helperText: appLocalizations.addressHelp,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty || !value.isHttpUrl) {
                  return appLocalizations.addressTip;
                }
                return null;
              },
            ),
            TextFormField(
              controller: userController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_circle),
                border: const OutlineInputBorder(),
                labelText: appLocalizations.account,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.account);
                }
                return null;
              },
            ),
            ValueListenableBuilder(
              valueListenable: _obscureController,
              builder: (_, obscure, _) {
                return TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        _obscureController.value = !obscure;
                      },
                    ),
                    labelText: appLocalizations.password,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.emptyTip(
                        appLocalizations.password,
                      );
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
