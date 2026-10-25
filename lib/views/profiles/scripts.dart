import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/card.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:bett_box/widgets/fade_box.dart';
import 'package:bett_box/widgets/icon.dart';
import 'package:bett_box/widgets/input.dart';
import 'package:bett_box/widgets/list.dart';
import 'package:bett_box/widgets/null_status.dart';
import 'package:bett_box/widgets/pop_scope.dart';
import 'package:bett_box/widgets/popup.dart';
import 'package:bett_box/widgets/scaffold.dart';
import 'package:bett_box/widgets/scroll.dart';
import 'package:bett_box/widgets/sheet.dart';
import 'package:bett_box/widgets/text.dart';
import 'package:bett_box/widgets/delay_animation_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

const Duration _kMinLoadingDuration = Duration(seconds: 1);

bool _isValidIconUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final lower = url.toLowerCase();
  return lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('data:image/');
}

({
  Map<String, bool> options,
  Map<String, String> icons,
  Set<String> policyGroupOptions,
})
_processScriptData(Map<String, dynamic> data, Script script) {
  final rawOptions = data['options'];
  final rawIcons = data['icons'];

  final options = <String, bool>{};
  if (rawOptions is Map) {
    rawOptions.forEach((k, v) {
      options[k.toString()] = v is bool ? v : true;
    });
  }
  if (script.customOptions != null) {
    script.customOptions!.forEach((k, v) {
      if (options.containsKey(k)) {
        options[k] = v;
      }
    });
  }

  final icons = <String, String>{};
  if (rawIcons is Map) {
    rawIcons.forEach((k, v) {
      if (v != null) {
        icons[k.toString()] = v.toString();
      }
    });
  }

  final rawPolicyGroupOptions = data['policyGroupOptions'];
  final policyGroupOptions = <String>{};
  if (rawPolicyGroupOptions is List) {
    for (final item in rawPolicyGroupOptions) {
      if (item != null) {
        policyGroupOptions.add(item.toString());
      }
    }
  }
  return (
    options: options,
    icons: icons,
    policyGroupOptions: policyGroupOptions,
  );
}

Future<void> showScriptCustomOptions(
  BuildContext context, {
  required Script script,
}) async {
  await showExtend(
    context,
    builder: (_, type) {
      return _ScriptCustomOptionsSheet(type: type, script: script);
    },
  );
}

class ScriptsView extends ConsumerStatefulWidget {
  const ScriptsView({super.key});

  @override
  ConsumerState<ScriptsView> createState() => _ScriptsViewState();
}

class _ScriptsViewState extends ConsumerState<ScriptsView> {
  Future<void> _handleDelScript(String label) async {
    final res = await globalState.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.script),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(scriptStateProvider.notifier).del(label);
  }

  Future<void> _handleSyncScript(String id) async {
    await globalState.appController.safeRun(silence: false, () async {
      await ref.read(scriptStateProvider.notifier).syncScript(id);
      globalState.showNotifier(appLocalizations.success);
    });
  }

  Future<void> _handleCustomOptions(Script script) async {
    await showScriptCustomOptions(context, script: script);
  }

  Future<void> _handleExportFile(Script script) async {
    final res = await globalState.appController.safeRun<bool>(
      () async {
        final rawName = script.label.trim();
        final fileName = rawName.endsWith('.js') ? rawName : '$rawName.js';
        final value = await picker.saveFile(
          fileName,
          utf8.encode(await script.readContent()),
          allowedExtensions: ['js'],
        );
        if (value == null) return false;
        return true;
      },
      needLoading: true,
      title: appLocalizations.tip,
    );
    if (res == true && mounted) {
      context.showNotifier(appLocalizations.exportSuccess);
    }
  }

  void _handleShowScriptSettings() {
    showSheet(
      context: context,
      builder: (_, type) {
        return _ScriptSettingsSheet(type: type);
      },
    );
  }

  Widget _buildScriptTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.opacity12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.colorScheme.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.primary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer(
      builder: (_, ref, _) {
        final vm2 = ref.watch(
          scriptStateProvider.select(
            (state) => VM2(a: state.currentId, b: state.scripts),
          ),
        );
        final currentId = vm2.a;
        final scripts = vm2.b;
        if (scripts.isEmpty) {
          return NullStatus(
            label: appLocalizations.nullTip(appLocalizations.script),
          );
        }
        return ScrollEdgeRise(
          builder: (_, rise) => CommonScrollBar(
            controller: null,
            child: ListView.separated(
              padding: const EdgeInsets.all(
                16,
              ).copyWith(top: 16 + rise, bottom: 16 + 64),
              itemCount: scripts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final script = scripts[index];
                final isSelected = script.id == currentId;
                final hasRemote = script.url?.isNotEmpty ?? false;
                final hasCustom = script.compatible;
                final hasTags = hasRemote || hasCustom;
                return CommonCard(
                  key: ValueKey(script.id),
                  elevated: false,
                  isSelected: isSelected,
                  radius: 16,
                  type: CommonCardType.filled,
                  child: Container(
                    constraints: BoxConstraints(minHeight: hasTags ? 68 : 60),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Switch(
                          value: isSelected,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) {
                            ref
                                .read(scriptStateProvider.notifier)
                                .setId(script.id);
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EmojiText(
                                script.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              if (hasTags)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (hasRemote)
                                        _buildScriptTag(
                                          icon: Icons.sync,
                                          label: appLocalizations.remote,
                                        ),
                                      if (hasCustom)
                                        _buildScriptTag(
                                          icon: Icons.tune,
                                          label: appLocalizations.custom,
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        CommonPopupBox(
                          targetBuilder: (open) {
                            return IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: () {
                                open();
                              },
                              tooltip: appLocalizations.more,
                              icon: const Icon(Icons.more_vert, size: 20),
                            );
                          },
                          popup: CommonPopupMenu(
                            items: [
                              PopupMenuItemData(
                                icon: Icons.edit,
                                label: appLocalizations.edit,
                                onPressed: () {
                                  _handleToEditor(script: script);
                                },
                              ),
                              if (script.compatible)
                                PopupMenuItemData(
                                  icon: Icons.tune,
                                  label: appLocalizations.custom,
                                  onPressed: () {
                                    _handleCustomOptions(script);
                                  },
                                ),
                              if (script.url?.isNotEmpty ?? false)
                                PopupMenuItemData(
                                  icon: Icons.sync,
                                  label: appLocalizations.sync,
                                  onPressed: () {
                                    _handleSyncScript(script.id);
                                  },
                                ),
                              PopupMenuItemData(
                                icon: Icons.file_copy_outlined,
                                label: appLocalizations.exportFile,
                                onPressed: () {
                                  _handleExportFile(script);
                                },
                              ),
                              PopupMenuItemData(
                                icon: Icons.delete,
                                label: appLocalizations.delete,
                                onPressed: () {
                                  _handleDelScript(script.label);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEditorSave(
    BuildContext _,
    String title,
    String content, {
    Script? script,
    String? url,
  }) async {
    var finalLabel = title.trim();
    if (finalLabel.isEmpty) {
      finalLabel = ref
          .read(scriptStateProvider.notifier)
          .getAvailableLabel(appLocalizations.unnamed);
    }
    final draft =
        script?.copyWith(label: finalLabel, url: url) ??
        Script.create(label: finalLabel, url: url);
    if (draft.label != script?.label) {
      final isExits = ref
          .read(scriptStateProvider.notifier)
          .isExits(draft.label);
      if (isExits) {
        globalState.showMessage(
          message: TextSpan(
            text: appLocalizations.existsTip(appLocalizations.name),
          ),
          cancelable: false,
        );
        return;
      }
    }
    final newScript = await globalState.appController.safeRun(
      silence: false,
      () => draft.writeContent(content),
    );
    if (newScript == null || !mounted) return;
    ref.read(scriptStateProvider.notifier).setScript(newScript);
    Navigator.of(context).pop();
  }

  Future<bool> _handleEditorPop(
    BuildContext _,
    String title,
    String content,
    String raw, {
    Script? script,
  }) async {
    if (content == raw) {
      return true;
    }
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == true && mounted) {
      _handleEditorSave(
        context,
        title,
        content,
        script: script,
        url: script?.url,
      );
    } else {
      return true;
    }
    return false;
  }

  Future<void> _handleToEditor({
    Script? script,
    String? initialContent,
    String? url,
    bool delayedFocus = false,
  }) async {
    final title = script?.label ?? '';
    final raw = initialContent ?? await script?.readContent() ?? scriptTemplate;
    if (!mounted) return;
    String? importedUrl = url ?? script?.url;
    BaseNavigator.push(
      context,
      EditorPage(
        titleEditable: true,
        title: title,
        supportRemoteDownload: true,
        delayedFocus: delayedFocus,
        onUrlImport: (downloadedUrl) {
          importedUrl = downloadedUrl;
        },
        onSave: (context, title, content) {
          final scriptToSave = script != null
              ? script.copyWith(url: importedUrl)
              : null;
          _handleEditorSave(
            context,
            title,
            content,
            script: scriptToSave,
            url: importedUrl,
          );
        },
        onPop: (context, title, content) {
          return _handleEditorPop(context, title, content, raw, script: script);
        },
        languages: const [Language.javaScript],
        content: raw,
      ),
    );
  }

  Future<void> _handleImport() async {
    final option = await globalState.showCommonDialog<ImportOption>(
      child: const _ScriptImportOptionsDialog(),
    );
    if (option == null) {
      return;
    }

    switch (option) {
      case ImportOption.code:
        _handleToEditor(delayedFocus: true);
      case ImportOption.url:
        await _handleUrlImport();
      case ImportOption.file:
        await _handleFileImport();
    }
  }

  Future<void> _handleUrlImport() async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.importUrl,
        value: '',
        labelText: appLocalizations.url,
        delayedFocus: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.value);
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip(appLocalizations.value);
          }
          return null;
        },
      ),
    );
    if (url == null || url.isEmpty) {
      return;
    }

    try {
      final res = await request.getTextResponseForUrl(url);
      if (mounted) {
        _handleToEditor(initialContent: res.data, url: url);
      }
    } catch (e) {
      globalState.showMessage(
        message: TextSpan(text: '${appLocalizations.importFailed}: $e'),
        cancelable: false,
      );
    }
  }

  Future<void> _handleFileImport() async {
    final file = await picker.pickerFile();
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return;
    }
    final content = utf8.decode(bytes);
    if (mounted) {
      _handleToEditor(initialContent: content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleImport();
        },
        child: Icon(Icons.add),
      ),
      actions: [
        IconButton(
          onPressed: _handleShowScriptSettings,
          tooltip: appLocalizations.settings,
          icon: Icon(Icons.settings),
        ),
      ],
      body: _buildContent(),
      title: appLocalizations.script,
    );
  }
}

class _ScriptSettingsSheet extends ConsumerWidget {
  final SheetType type;

  const _ScriptSettingsSheet({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final currentProfileId = ref.watch(currentProfileIdProvider);
    return AdaptiveSheetScaffold(
      type: type,
      body: profiles.isEmpty
          ? NullStatus(label: appLocalizations.nullProfileDesc)
          : ScrollEdgeRise(
              builder: (_, rise) => ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  12,
                  16 + rise,
                  12,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: profiles.length,
                itemBuilder: (_, index) {
                  final profile = profiles[index];
                  final isCurrentProfile = profile.id == currentProfileId;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CommonCard(
                      elevated: false,
                      type: CommonCardType.filled,
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        title: EmojiText(profile.label ?? profile.id),
                        trailing: Switch(
                          value: profile.useScriptOverride,
                          onChanged: (value) async {
                            ref
                                .read(profilesProvider.notifier)
                                .updateProfile(
                                  profile.id,
                                  (p) => p.copyWith(useScriptOverride: value),
                                );
                            if (isCurrentProfile) {
                              await globalState.appController.applyProfile(
                                silence: true,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      title: appLocalizations.useGlobalScriptOverride,
    );
  }
}

class _ScriptImportOptionsDialog extends StatelessWidget {
  const _ScriptImportOptionsDialog();

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.import,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Wrap(
        children: [
          ListItem(
            onTap: () {
              Navigator.of(context).pop(ImportOption.code);
            },
            leading: const Icon(Icons.code),
            title: Text(appLocalizations.importFromCode),
          ),
          ListItem(
            onTap: () {
              Navigator.of(context).pop(ImportOption.url);
            },
            leading: const Icon(Icons.link),
            title: Text(appLocalizations.importUrl),
          ),
          ListItem(
            onTap: () {
              Navigator.of(context).pop(ImportOption.file);
            },
            leading: const Icon(Icons.file_open),
            title: Text(appLocalizations.importFile),
          ),
        ],
      ),
    );
  }
}

class _ScriptCustomOptionsSheet extends ConsumerStatefulWidget {
  final SheetType type;
  final Script script;

  const _ScriptCustomOptionsSheet({required this.type, required this.script});

  @override
  ConsumerState<_ScriptCustomOptionsSheet> createState() =>
      __ScriptCustomOptionsSheetState();
}

class __ScriptCustomOptionsSheetState
    extends ConsumerState<_ScriptCustomOptionsSheet> {
  Map<String, bool> _options = {};
  Map<String, String> _icons = {};
  Set<String> _policyGroupOptions = {};
  bool _isLoading = true;
  bool _dirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final cached = JavaScriptRuntimeManager.getCachedOptions(widget.script);
    if (cached != null) {
      _applyData(cached);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_load);
    });
  }

  void _applyData(Map<String, dynamic> data) {
    final (:options, :icons, :policyGroupOptions) = _processScriptData(
      data,
      widget.script,
    );
    _options = options;
    _icons = icons;
    _policyGroupOptions = policyGroupOptions;
    _isLoading = false;
  }

  Future<void> _load() async {
    if (!mounted) return;
    final data = await globalState.appController.safeRun(
      silence: false,
      () => JavaScriptRuntimeManager.extractScriptOptions(widget.script),
    );
    if (!mounted) return;
    if (data == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _applyData(data));
  }

  bool get _hasUnsavedChanges => _dirty;

  Future<void> _handleSave({bool popSheet = true}) async {
    if (_isSaving) return;
    final scripts = ref.read(scriptStateProvider).scripts;
    final index = scripts.indexWhere((item) => item.id == widget.script.id);
    if (index == -1) {
      _dirty = false;
      if (mounted) setState(() {});
      return;
    }
    final currentScript = scripts[index];
    final updatedScript = currentScript.copyWith(
      customOptions: Map<String, bool>.from(_options),
    );
    ref.read(scriptStateProvider.notifier).setScript(updatedScript);
    _dirty = false;
    if (mounted) setState(() => _isSaving = true);
    try {
      final applyFuture =
          ref.read(scriptStateProvider).currentId == widget.script.id
          ? globalState.appController.applyProfile(silence: true)
          : Future.value();
      await Future.wait([applyFuture, Future.delayed(_kMinLoadingDuration)]);
    } finally {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) {
        setState(() => _isSaving = false);
        if (popSheet) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _handleSaveOtherOptions(Map<String, bool> values) async {
    setState(() {
      _options.addAll(values);
      _dirty = true;
    });
    await _handleSave(popSheet: false);
  }

  Future<void> _handleOpenOtherOptions(List<String> keys) async {
    await showExtend(
      context,
      builder: (_, type) {
        return _ScriptOtherOptionsSheet(
          type: type,
          values: {for (final key in keys) key: _options[key] ?? true},
          icons: _icons,
          onSave: _handleSaveOtherOptions,
        );
      },
    );
  }

  void _onOptionChanged(String key, bool value) {
    setState(() {
      _options[key] = value;
      _dirty = true;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (_isSaving) return false;
    if (!_hasUnsavedChanges) return true;
    return _showSaveChangesDialog(onSave: _handleSave);
  }

  ({List<String> groups, List<String> others, bool split}) _splitOptions() {
    final groups = <String>[];
    final others = <String>[];
    for (final key in _options.keys) {
      if (_policyGroupOptions.contains(key)) {
        groups.add(key);
      } else {
        others.add(key);
      }
    }
    return (
      groups: groups,
      others: others,
      split: groups.isNotEmpty && others.isNotEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = _options.keys.toList();
    final (:groups, :others, :split) = _splitOptions();
    final displayKeys = split ? groups : keys;
    return CommonPopScope(
      onPop: _confirmDiscard,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: AdaptiveSheetScaffold(
          type: widget.type,
          title: appLocalizations.customScriptOptions,
          actions: [
            IconButton(
              onPressed: (_dirty && !_isSaving) ? _handleSave : null,
              icon: const Icon(Icons.save),
              tooltip: appLocalizations.save,
            ),
          ],
          body: Column(
            children: [
              if (_isSaving)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: context.colorScheme.primary,
                ),
              Expanded(
                child: FadeBox(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const Center(
                          child: SyncedLoading(
                            size: 40,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : keys.isEmpty
                      ? NullStatus(label: appLocalizations.noStatusAvailable)
                      : RepaintBoundary(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            itemCount: displayKeys.length + (split ? 1 : 0),
                            itemBuilder: (_, index) {
                              if (split && index == displayKeys.length) {
                                return RepaintBoundary(
                                  child: _ScriptNavTile(
                                    label: appLocalizations.scriptOtherOptions,
                                    assetIcon: 'assets/images/settings.svg',
                                    onTap: () {
                                      _handleOpenOtherOptions(others);
                                    },
                                  ),
                                );
                              }
                              final key = displayKeys[index];
                              return RepaintBoundary(
                                child: _ScriptOptionTile(
                                  label: key,
                                  value: _options[key] ?? true,
                                  iconUrl: _icons[key],
                                  onChanged: (v) {
                                    _onOptionChanged(key, v);
                                  },
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
      ),
    );
  }
}

class _ScriptOtherOptionsSheet extends StatefulWidget {
  final SheetType type;
  final Map<String, bool> values;
  final Map<String, String> icons;
  final Future<void> Function(Map<String, bool> values) onSave;

  const _ScriptOtherOptionsSheet({
    required this.type,
    required this.values,
    required this.icons,
    required this.onSave,
  });

  @override
  State<_ScriptOtherOptionsSheet> createState() =>
      _ScriptOtherOptionsSheetState();
}

class _ScriptOtherOptionsSheetState extends State<_ScriptOtherOptionsSheet> {
  late Map<String, bool> _options;
  bool _dirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _options = Map<String, bool>.from(widget.values);
  }

  Future<void> _handleSave() async {
    if (_isSaving || !_dirty) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(Map<String, bool>.from(_options));
      _dirty = false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _confirmDiscard() async {
    if (_isSaving) return false;
    if (!_dirty) return true;
    return _showSaveChangesDialog(onSave: _handleSave);
  }

  @override
  Widget build(BuildContext context) {
    final keys = _options.keys.toList();
    return CommonPopScope(
      onPop: _confirmDiscard,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: AdaptiveSheetScaffold(
          type: widget.type,
          title: appLocalizations.scriptOtherOptions,
          actions: [
            IconButton(
              onPressed: (_dirty && !_isSaving) ? _handleSave : null,
              icon: const Icon(Icons.save),
              tooltip: appLocalizations.save,
            ),
          ],
          body: Column(
            children: [
              if (_isSaving)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: context.colorScheme.primary,
                ),
              Expanded(
                child: keys.isEmpty
                    ? NullStatus(label: appLocalizations.noStatusAvailable)
                    : RepaintBoundary(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          itemCount: keys.length,
                          itemBuilder: (_, index) {
                            final key = keys[index];
                            return RepaintBoundary(
                              child: _ScriptOptionTile(
                                label: key,
                                value: _options[key] ?? true,
                                iconUrl: widget.icons[key],
                                onChanged: (v) {
                                  setState(() {
                                    _options[key] = v;
                                    _dirty = true;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScriptOptionTile extends StatelessWidget {
  final String label;
  final bool value;
  final String? iconUrl;
  final ValueChanged<bool> onChanged;

  const _ScriptOptionTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CommonCard(
        type: CommonCardType.filled,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 16, right: 16),
          leading: _isValidIconUrl(iconUrl)
              ? CommonTargetIcon(src: iconUrl!, size: 24)
              : const Icon(Icons.alt_route),
          title: Text(label),
          trailing: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}

class _ScriptNavTile extends StatelessWidget {
  final String label;
  final String assetIcon;
  final VoidCallback onTap;

  const _ScriptNavTile({
    required this.label,
    required this.assetIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CommonCard(
        type: CommonCardType.filled,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 16, right: 16),
          leading: SvgPicture.asset(
            assetIcon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          title: Text(label),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

Future<bool> _showSaveChangesDialog({
  required Future<void> Function() onSave,
}) async {
  final res = await globalState.showCommonDialog<bool>(
    child: CommonDialog(
      title: appLocalizations.saveChanges,
      actions: [
        TextButton(
          onPressed: () => globalState.navigatorKey.currentState?.pop(false),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: () => globalState.navigatorKey.currentState?.pop(true),
          child: Text(appLocalizations.save),
        ),
      ],
    ),
  );
  if (res == true) {
    await onSave();
    return false;
  }
  return res == false;
}

Future<void> showGroupSwitchOptions(
  BuildContext context, {
  required String profileId,
}) async {
  await showExtend(
    context,
    builder: (_, type) {
      return _GroupSwitchOptionsSheet(type: type, profileId: profileId);
    },
  );
}

class _GroupSwitchOptionsSheet extends ConsumerStatefulWidget {
  final SheetType type;
  final String profileId;

  const _GroupSwitchOptionsSheet({required this.type, required this.profileId});

  @override
  ConsumerState<_GroupSwitchOptionsSheet> createState() =>
      _GroupSwitchOptionsSheetState();
}

class _GroupSwitchOptionsSheetState
    extends ConsumerState<_GroupSwitchOptionsSheet> {
  late final Mode _mode;
  List<String> _groupNames = [];
  String? _matchTarget;
  Map<String, bool> _options = {};
  Map<String, bool> _originalOptions = {};
  Set<String> _lockedGroups = {};
  bool _isLoading = true;
  bool _dirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mode = ref.read(patchClashConfigProvider).mode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_load);
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    final rawConfig = await globalState.appController.safeRun(
      silence: false,
      () => globalState.getProfileSnippet(widget.profileId),
    );
    if (!mounted) return;
    if (rawConfig == null) {
      Navigator.of(context).pop();
      return;
    }
    final rules = rawConfig['rules'] as List? ?? [];
    final proxyGroups = rawConfig['proxy-groups'] as List? ?? [];
    String? matchTarget;
    for (final rule in rules) {
      if (rule is! String) continue;
      final parsed = ParsedRule.parseString(rule);
      final target = parsed.ruleTarget;
      if (parsed.ruleAction == RuleAction.MATCH &&
          target != null &&
          target.isNotEmpty) {
        matchTarget = target;
        break;
      }
    }
    final groupSwitches = ref.read(currentProfileProvider)?.groupSwitches ?? {};
    final isGlobalMode = _mode == Mode.global;
    setState(() {
      _groupNames = [
        for (final g in proxyGroups)
          if (g is Map && g['name'] is String) g['name'] as String,
      ];
      _matchTarget = matchTarget;
      _options = {
        for (final name in _groupNames)
          if (isGlobalMode || name != 'GLOBAL')
            name: groupSwitches[name] ?? true,
      };
      _originalOptions = Map<String, bool>.from(_options);
      _lockedGroups = _computeLockedGroups();
      _isLoading = false;
    });
  }

  Set<String> _computeLockedGroups() {
    final locked = <String>{};
    final firstNonGlobal = _options.keys.firstWhere(
      (k) => k != 'GLOBAL',
      orElse: () => '',
    );
    if (firstNonGlobal.isNotEmpty) {
      locked.add(firstNonGlobal);
    }
    if (_mode == Mode.global && _options.containsKey('GLOBAL')) {
      locked.add('GLOBAL');
    }
    final matchTarget = _matchTarget;
    if (matchTarget != null && matchTarget.isNotEmpty) {
      locked.add(matchTarget);
    }
    return locked;
  }

  bool get _hasUnsavedChanges => _dirty;

  void _onOptionChanged(String key, bool value) {
    setState(() {
      _options[key] = value;
      _dirty = true;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (_isSaving) return false;
    if (!_hasUnsavedChanges) return true;
    final res = await globalState.showCommonDialog<bool>(
      child: CommonDialog(
        title: appLocalizations.saveChanges,
        actions: [
          TextButton(
            onPressed: () => globalState.navigatorKey.currentState?.pop(false),
            child: Text(appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => globalState.navigatorKey.currentState?.pop(true),
            child: Text(appLocalizations.save),
          ),
        ],
      ),
    );
    if (res == true) {
      await _handleSave();
      return false;
    }
    return res == false;
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    if (widget.profileId != ref.read(currentProfileIdProvider)) {
      _dirty = false;
      if (mounted) setState(() {});
      return;
    }

    if (mounted) setState(() => _isSaving = true);

    try {
      final validOptions = {
        for (final name in _groupNames) name: _options[name] ?? true,
      };

      ref
          .read(profilesProvider.notifier)
          .updateProfile(
            widget.profileId,
            (state) => state.copyWith(groupSwitches: validOptions),
          );

      final patchConfig = ref.read(patchClashConfigProvider);
      final message = await globalState.validatePatchedConfig(
        patchConfig: patchConfig,
      );

      if (message.isNotEmpty) {
        ref
            .read(profilesProvider.notifier)
            .updateProfile(
              widget.profileId,
              (state) => state.copyWith(groupSwitches: _originalOptions),
            );
        if (mounted) {
          await globalState.showMessage(
            message: TextSpan(
              text: '${appLocalizations.profileParseErrorDesc}: $message',
            ),
            cancelable: false,
          );
        }
        return;
      }

      final applyFuture = globalState.appController.applyProfile(silence: true);
      await Future.wait([applyFuture, Future.delayed(_kMinLoadingDuration)]);

      _dirty = false;
      _originalOptions = Map<String, bool>.from(validOptions);
    } finally {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = _options.keys.toList();
    return CommonPopScope(
      onPop: _confirmDiscard,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: AdaptiveSheetScaffold(
          type: widget.type,
          title: appLocalizations.customScriptOptions,
          actions: [
            IconButton(
              onPressed: (_dirty && !_isSaving) ? _handleSave : null,
              icon: const Icon(Icons.save),
              tooltip: appLocalizations.save,
            ),
          ],
          body: Column(
            children: [
              if (_isSaving)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: context.colorScheme.primary,
                ),
              Expanded(
                child: FadeBox(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const Center(
                          child: SyncedLoading(
                            size: 40,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : keys.isEmpty
                      ? NullStatus(label: appLocalizations.noStatusAvailable)
                      : RepaintBoundary(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            itemCount: keys.length,
                            itemBuilder: (_, index) {
                              final key = keys[index];
                              final val = _options[key] ?? true;
                              final locked = _lockedGroups.contains(key);
                              return RepaintBoundary(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: CommonCard(
                                    type: CommonCardType.filled,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                      ),
                                      leading: const Icon(Icons.alt_route),
                                      title: Text(key),
                                      trailing: Switch(
                                        value: val,
                                        onChanged: locked
                                            ? null
                                            : (v) {
                                                _onOptionChanged(key, v);
                                              },
                                      ),
                                    ),
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
      ),
    );
  }
}
