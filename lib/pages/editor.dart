import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart' hide Mode;
import 'package:bett_box/models/common.dart';
import 'package:bett_box/plugins/clipboard_ext.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart' show Mode;
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

typedef EditorWidgetBuilder = Widget Function();

const int _kLargeEditableLineThresholdMobile = 5800;
const int _kLargeEditableLineThresholdDesktop = 5800;
const Duration _kFindFocusDelay = Duration(milliseconds: 500);
const Duration _kMinBusyDuration = Duration(milliseconds: 600);

class EditorPage extends ConsumerStatefulWidget {
  final String title;
  final String content;
  final List<Language> languages;
  final bool supportRemoteDownload;
  final bool titleEditable;
  final bool readOnly;
  final bool delayedFocus;
  final bool simple;
  final Function(BuildContext context, String title, String content)? onSave;
  final Future<bool> Function(
    BuildContext context,
    String title,
    String content,
  )?
  onPop;
  final void Function(String url)? onUrlImport;

  const EditorPage({
    super.key,
    required this.title,
    required this.content,
    this.titleEditable = false,
    this.readOnly = false,
    this.delayedFocus = false,
    this.simple = false,
    this.onSave,
    this.onPop,
    this.onUrlImport,
    this.supportRemoteDownload = false,
    this.languages = const [Language.yaml],
  });

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  late CodeForgeController _controller;
  late _EditorFindController _findController;
  late UndoRedoController _undoController;
  late TextEditingController _titleController;
  final _focusNode = FocusNode();
  late final FocusNode _saveButtonFocusNode;
  VoidCallback? _removePasteHandler;
  bool _lineWrap = false;
  late final int _lineCount;
  bool _isLoading = true;
  bool _isBusy = false;

  bool get _disableSyntaxHighlight =>
      widget.simple || _lineCount > _largeEditableLineThreshold;

  bool get _isLineWrapDisabled => _lineCount > _largeEditableLineThreshold;

  int get _largeEditableLineThreshold => system.isDesktop
      ? _kLargeEditableLineThresholdDesktop
      : _kLargeEditableLineThresholdMobile;

  @override
  void initState() {
    super.initState();
    _saveButtonFocusNode = FocusNode();
    _lineCount = widget.content.split('\n').length;
    _lineWrap = !widget.readOnly && !_isLineWrapDisabled;
    _controller = CodeForgeController();
    _controller.useSpaceAsTab = true;
    _controller.tabSize = 2;
    _controller.text = widget.content;
    _findController = _EditorFindController(_controller);
    _undoController = UndoRedoController();
    _titleController = TextEditingController(text: widget.title);

    if (system.isWindows) {
      _removePasteHandler = clipboardExt.addHandler(_handleNativePaste);
    }

    final loadingStopwatch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final elapsed = loadingStopwatch.elapsedMilliseconds;
      final remaining = _kMinBusyDuration.inMilliseconds - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }
      if (mounted) setState(() => _isLoading = false);
      if (widget.delayedFocus) {
        Future.delayed(_kFindFocusDelay, () {
          if (mounted) _focusNode.requestFocus();
        });
      }
    });
  }

  /// Handles a native paste command (Windows clipboard history) while the
  /// editor holds focus. Returns false so other handlers can take over.
  Future<bool> _handleNativePaste() async {
    if (widget.readOnly || widget.simple) return false;
    if (!_focusNode.hasFocus) return false;
    await _controller.paste();
    return true;
  }

  @override
  void dispose() {
    _removePasteHandler?.call();
    _controller.text = '';
    _findController.dispose();
    _undoController.dispose();
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    _saveButtonFocusNode.dispose();
    super.dispose();
  }

  Widget _wrapTitleController(EditorWidgetBuilder builder) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _titleController,
        _CodeForgeControllerListenable(_controller),
      ]),
      builder: (_, _) => builder(),
    );
  }

  void _handleSearch() {
    _findController.isReplaceMode = false;
    _findController.isActive = true;
  }

  void _handleReplace() {
    _findController.isReplaceMode = true;
    _findController.isActive = true;
  }

  void _handleSave(BuildContext context) {
    if (widget.onSave == null) return;
    if (widget.readOnly || widget.simple) return;
    if (_isLoading) return;
    if (_controller.text == widget.content &&
        _titleController.text == widget.title) {
      return;
    }
    widget.onSave!(context, _titleController.text, _controller.text);
  }

  void _setBusy(bool value) {
    if (!mounted) return;
    setState(() => _isBusy = value);
  }

  Future<void> _withBusy(Future<void> Function() task) async {
    _setBusy(true);
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    final stopwatch = Stopwatch()..start();
    try {
      await task();
    } finally {
      final remaining =
          _kMinBusyDuration.inMilliseconds - stopwatch.elapsedMilliseconds;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }
      if (mounted) _setBusy(false);
    }
  }

  Future<void> _toggleLineWrap() async {
    await _withBusy(() async {
      setState(() => _lineWrap = !_lineWrap);
      await SchedulerBinding.instance.endOfFrame;
    });
  }

  Future<void> _handleImport() async {
    final option = await globalState.showCommonDialog<ImportOption>(
      child: _ImportOptionsDialog(),
    );
    if (option == null) {
      return;
    }
    if (option == ImportOption.file) {
      final file = await picker.pickerFile();
      if (file == null) {
        return;
      }
      final bytes = file.bytes;
      if (bytes == null) {
        return;
      }
      final res = utf8.decode(bytes);
      _controller.text = res;
      return;
    }
    final url = await globalState.showCommonDialog(
      child: InputDialog(
        title: appLocalizations.import,
        value: '',
        labelText: appLocalizations.url,
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
    if (url == null) {
      return;
    }
    final res = await request.getTextResponseForUrl(url);
    _controller.text = res.data;
    widget.onUrlImport?.call(url);
  }

  Mode? _languageMode() {
    if (_disableSyntaxHighlight) return null;
    final language = widget.languages.firstOrNull;
    switch (language) {
      case Language.yaml:
        return langYaml;
      case Language.javaScript:
        return langJavascript;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobileView = ref.watch(isMobileViewProvider);
    final brightness = Theme.of(context).brightness;
    final readOnly = widget.readOnly || widget.simple;
    final canReplace =
        !readOnly && !_disableSyntaxHighlight && _languageMode() != null;
    final menuItems = <PopupMenuItemData>[
      PopupMenuItemData(
        icon: Icons.search,
        label: appLocalizations.search,
        onPressed: _handleSearch,
      ),
      if (canReplace)
        PopupMenuItemData(
          icon: Icons.find_replace,
          label: appLocalizations.replace,
          onPressed: _handleReplace,
        ),
      PopupMenuItemData(
        icon: Icons.undo,
        label: appLocalizations.undo,
        onPressed: _undoController.canUndo
            ? () => _undoController.undo()
            : null,
      ),
      PopupMenuItemData(
        icon: Icons.redo,
        label: appLocalizations.redo,
        onPressed: _undoController.canRedo
            ? () => _undoController.redo()
            : null,
      ),
      PopupMenuItemData(
        icon: _lineWrap ? Icons.check : Icons.wrap_text,
        label: appLocalizations.lineWrap,
        onPressed: _isLineWrapDisabled ? null : _toggleLineWrap,
      ),
    ];

    return CommonPopScope(
      onPop: () async {
        if (globalState.isAndroidTV && _focusNode.hasFocus) {
          final hasChanges =
              _controller.text != widget.content ||
              _titleController.text != widget.title;
          final canSave =
              hasChanges &&
              widget.onSave != null &&
              !widget.simple &&
              !widget.readOnly;
          if (canSave) {
            _saveButtonFocusNode.requestFocus();
            return false;
          }
        }
        if (widget.onPop == null) {
          return true;
        }
        final res = await widget.onPop!(
          context,
          _titleController.text,
          _controller.text,
        );
        if (res && context.mounted) {
          return true;
        }
        return false;
      },
      child: CallbackShortcuts(
        bindings: readOnly
            ? const {}
            : {
                const SingleActivator(
                  LogicalKeyboardKey.keyS,
                  control: true,
                ): () =>
                    _handleSave(context),
                const SingleActivator(
                  LogicalKeyboardKey.keyS,
                  meta: true,
                ): () =>
                    _handleSave(context),
              },
        child: AbsorbPointer(
          absorbing: _isBusy || _isLoading,
          child: CommonScaffold(
            appBar: AppBar(
              title: TextField(
                enabled: widget.titleEditable && !readOnly,
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: appLocalizations.unnamed,
                ),
                style: context.textTheme.titleLarge,
                autofocus: false,
              ),
              actions: genActions([
                if (widget.onSave != null && !readOnly)
                  _wrapTitleController(
                    () => Focus(
                      focusNode: _saveButtonFocusNode,
                      child: IconButton(
                        onPressed:
                            !_isLoading &&
                                (_controller.text != widget.content ||
                                    _titleController.text != widget.title)
                            ? () => _handleSave(context)
                            : null,
                        tooltip: appLocalizations.save,
                        icon: const Icon(Icons.save_sharp),
                      ),
                    ),
                  ),
                if (widget.supportRemoteDownload && !readOnly)
                  IconButton(
                    onPressed: _isLoading ? null : _handleImport,
                    tooltip: appLocalizations.download,
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ListenableBuilder(
                  listenable: _undoController,
                  builder: (_, _) => CommonPopupBox(
                    targetBuilder: (open) {
                      return IconButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                open(offset: const Offset(-20, 20));
                              },
                        tooltip: appLocalizations.more,
                        icon: const Icon(Icons.more_vert),
                      );
                    },
                    popup: CommonPopupMenu(items: menuItems),
                  ),
                ),
              ]),
            ),
            body: Stack(
              children: [
                if (!_isLoading)
                  RepaintBoundary(
                    child: CodeForge(
                      controller: _controller,
                      focusNode: _focusNode,
                      findController: _findController,
                      undoController: _undoController,
                      readOnly: readOnly,
                      lineWrap: _lineWrap,
                      enableFolding: !widget.simple && !_disableSyntaxHighlight,
                      enableGuideLines:
                          !widget.simple && !_disableSyntaxHighlight,
                      enableGutter: true,
                      enableGutterDivider: false,
                      enableLocalSuggestions: true,
                      enableKeyboardSuggestions: true,
                      enableMagnifier: true,
                      language: _languageMode(),
                      languageId: switch (widget.languages.firstOrNull) {
                        Language.yaml => 'yaml',
                        Language.javaScript => 'javascript',
                        _ => null,
                      },
                      blockCommentLabel: appLocalizations.blockComment,
                      editorTheme: brightness == Brightness.dark
                          ? atomOneDarkTheme
                          : atomOneLightTheme,
                      textStyle: TextStyle(
                        fontFamily: FontFamily.jetBrainsMono.value,
                        fontSize: context.textTheme.bodyLarge?.fontSize?.ap,
                      ),
                      innerPadding: const EdgeInsets.only(right: 16),
                      finderBuilder: (context, controller) => FindPanel(
                        controller: controller,
                        readOnly: readOnly,
                        isMobileView: isMobileView,
                      ),
                      scrollbarDecoration: ScrollbarDecoration(
                        showLineNumberIndicator: false,
                        thumbVisibility: false,
                        thickness: 8,
                        thumbColor: context.colorScheme.onSurface.withAlpha(
                          100,
                        ),
                      ),
                    ),
                  ),
                if (_isBusy || _isLoading)
                  Positioned.fill(
                    child: Container(
                      color: context.colorScheme.surface.withAlpha(200),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorFindController extends FindController {
  _EditorFindController(super.codeController);

  final ValueNotifier<bool> isOpenNotifier = ValueNotifier<bool>(false);

  @override
  set isActive(bool value) {
    if (value == isActive) return;
    super.isActive = value;
    isOpenNotifier.value = value;
  }
}

class FindPanel extends StatelessWidget implements PreferredSizeWidget {
  final FindController controller;
  final bool readOnly;
  final bool isMobileView;

  const FindPanel({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.isMobileView,
  });

  @override
  Size get preferredSize {
    if (!controller.isActive) return Size.zero;
    final baseRows = isMobileView ? 2 : 1;
    final totalRows =
        baseRows + (!readOnly && controller.isReplaceMode ? 1 : 0);
    final calculatedHeight = totalRows * 36.0 + (totalRows - 1) * 6.0 + 26.0;
    return Size(double.infinity, calculatedHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isActive) {
      return const SizedBox(width: 0, height: 0);
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(120),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _buildFindInputView(context),
      ),
    );
  }

  Widget _buildFindInputView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showReplace = !readOnly && controller.isReplaceMode;
    final resultText = controller.matchCount == 0
        ? appLocalizations.none
        : controller.hasMoreMatches
        ? '${controller.currentMatchIndex + 1}/1000+'
        : '${controller.currentMatchIndex + 1}/${controller.matchCount}';

    final topBar = SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMobileView) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: _buildFindInput(context),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(80),
              ),
            ),
            child: Text(
              resultText,
              style: context.textTheme.labelMedium?.copyWith(
                color: controller.matchCount == 0
                    ? colorScheme.onSurfaceVariant.withAlpha(150)
                    : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 6,
              children: [
                _buildIconButton(
                  onPressed: controller.matchCount == 0
                      ? null
                      : controller.previous,
                  icon: Icons.keyboard_arrow_up,
                ),
                _buildIconButton(
                  onPressed: controller.matchCount == 0
                      ? null
                      : controller.next,
                  icon: Icons.keyboard_arrow_down,
                ),
                if (isMobileView && showReplace) ...[
                  _buildIconButton(
                    onPressed: controller.matchCount == 0
                        ? null
                        : controller.replace,
                    icon: Icons.find_replace,
                    tooltip: appLocalizations.replace,
                  ),
                  _buildIconButton(
                    onPressed: controller.matchCount == 0
                        ? null
                        : controller.replaceAll,
                    icon: Icons.published_with_changes,
                    tooltip: appLocalizations.replaceAll,
                  ),
                ],
                if (!readOnly)
                  _buildIconButton(
                    onPressed: () => controller.toggleReplaceMode(),
                    icon: controller.isReplaceMode
                        ? Icons.unfold_less
                        : Icons.unfold_more,
                    tooltip: appLocalizations.replace,
                  ),
                const SizedBox(width: 2),
                IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.isActive = false,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      colorScheme.errorContainer.withAlpha(160),
                    ),
                    foregroundColor: WidgetStatePropertyAll(
                      colorScheme.onErrorContainer,
                    ),
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(0)),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobileView) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar,
          const SizedBox(height: 6),
          _buildFindInput(context),
          if (showReplace) ...[
            const SizedBox(height: 6),
            _buildReplaceInput(context),
          ],
        ],
      );
    }

    if (showReplace) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar,
          const SizedBox(height: 6),
          _buildReplaceRow(context),
        ],
      );
    }

    return topBar;
  }

  Widget _buildReplaceRow(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: _buildReplaceInput(context),
          ),
          const SizedBox(width: 10),
          _buildIconButton(
            onPressed: controller.matchCount == 0 ? null : controller.replace,
            icon: Icons.find_replace,
            tooltip: appLocalizations.replace,
          ),
          _buildIconButton(
            onPressed: controller.matchCount == 0
                ? null
                : controller.replaceAll,
            icon: Icons.published_with_changes,
            tooltip: appLocalizations.replaceAll,
          ),
        ],
      ),
    );
  }

  Stack _buildFindInput(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildTextField(
          context: context,
          hintText: appLocalizations.search,
          prefixIcon: Icons.search,
          onSubmitted: () {
            if (controller.matchCount == 0) {
              return;
            }
            controller.next();
            controller.findInputFocusNode.requestFocus();
          },
          controller: controller.findInputController,
          focusNode: controller.findInputFocusNode,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 6,
          children: [
            _buildCheckText(
              context: context,
              text: 'Aa',
              isSelected: controller.caseSensitive,
              onPressed: controller.toggleCaseSensitive,
            ),
            _buildCheckText(
              context: context,
              text: '.*',
              isSelected: controller.isRegex,
              onPressed: controller.toggleRegex,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ],
    );
  }

  Widget _buildReplaceInput(BuildContext context) {
    return _buildTextField(
      context: context,
      hintText: appLocalizations.replace,
      prefixIcon: Icons.find_replace,
      onSubmitted: () {
        if (controller.matchCount == 0) return;
        controller.replace();
        controller.replaceInputFocusNode.requestFocus();
      },
      controller: controller.replaceInputController,
      focusNode: controller.replaceInputFocusNode,
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSubmitted,
    String? hintText,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      height: 36,
      child: TextField(
        maxLines: 1,
        focusNode: focusNode,
        style: context.textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: colorScheme.surface,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 16,
                  color: colorScheme.onSurfaceVariant.withAlpha(160),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 36,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withAlpha(100),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withAlpha(100),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          hintText: hintText,
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withAlpha(120),
          ),
        ),
        onSubmitted: (_) {
          onSubmitted();
        },
        controller: controller,
      ),
    );
  }

  Widget _buildCheckText({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 28,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withAlpha(120)
              : colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: Center(
          child: Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      tooltip: tooltip,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(6)),
        minimumSize: WidgetStatePropertyAll(Size(28, 28)),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _CodeForgeControllerListenable extends Listenable {
  _CodeForgeControllerListenable(this._controller);

  final CodeForgeController _controller;

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);
}


class _ImportOptionsDialog extends StatefulWidget {
  const _ImportOptionsDialog();

  @override
  State<_ImportOptionsDialog> createState() => _ImportOptionsDialogState();
}

class _ImportOptionsDialogState extends State<_ImportOptionsDialog> {
  void _handleOnTab(ImportOption value) {
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.import,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Wrap(
        children: [
          ListItem(
            onTap: () {
              _handleOnTab(ImportOption.url);
            },
            title: Text(appLocalizations.importUrl),
          ),
          ListItem(
            onTap: () {
              _handleOnTab(ImportOption.file);
            },
            title: Text(appLocalizations.importFile),
          ),
        ],
      ),
    );
  }
}
