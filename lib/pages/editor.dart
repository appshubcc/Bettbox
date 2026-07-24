import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart' hide Mode;
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart' show Mode;
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

typedef EditorWidgetBuilder = Widget Function();

const int _kLargeEditableLineThresholdMobile = 1000;
const int _kLargeEditableLineThresholdDesktop = 2000;
const Duration _kFindFocusDelay = Duration(milliseconds: 500);
const Duration _kMinBusyDuration = Duration(milliseconds: 600);
const double _kDefaultFindPanelHeight = 52;

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
    _lineCount = widget.content.split('\n').length;
    _lineWrap = !widget.readOnly && !_isLineWrapDisabled;
    _controller = CodeForgeController();
    _controller.text = widget.content;
    _findController = _EditorFindController(_controller);
    _undoController = UndoRedoController();
    _titleController = TextEditingController(text: widget.title);

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

  @override
  void dispose() {
    _controller.text = '';
    _findController.dispose();
    _undoController.dispose();
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
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
    _findController.isActive = true;
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
    final menuItems = <PopupMenuItemData>[
      PopupMenuItemData(
        icon: Icons.search,
        label: appLocalizations.search,
        onPressed: _handleSearch,
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
      child: AbsorbPointer(
        absorbing: _isBusy || _isLoading,
        child: CommonScaffold(
          appBar: AppBar(
            title: TextField(
              enabled: widget.titleEditable && !readOnly,
              controller: _titleController,
              decoration: InputDecoration(
                border: _NoInputBorder(),
                hintText: appLocalizations.unnamed,
              ),
              style: context.textTheme.titleLarge,
              autofocus: false,
            ),
            actions: genActions([
              if (widget.onSave != null && !readOnly)
                _wrapTitleController(
                  () => IconButton(
                    onPressed:
                        !_isLoading &&
                                (_controller.text != widget.content ||
                                    _titleController.text != widget.title)
                            ? () {
                                widget.onSave!(
                                  context,
                                  _titleController.text,
                                  _controller.text,
                                );
                              }
                            : null,
                    icon: const Icon(Icons.save_sharp),
                  ),
                ),
              if (widget.supportRemoteDownload && !readOnly)
                IconButton(
                  onPressed: _isLoading ? null : _handleImport,
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
                    enableGuideLines: !widget.simple && !_disableSyntaxHighlight,
                    enableGutter: true,
                    enableGutterDivider: false,
                    enableLocalSuggestions: false,
                    enableKeyboardSuggestions: false,
                    enableMagnifier: false,
                    language: _languageMode(),
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
                      thumbColor: context.colorScheme.onSurface.withAlpha(100),
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
  final double height;

  const FindPanel({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.isMobileView,
  }) : height =
           (isMobileView
               ? _kDefaultFindPanelHeight * 2
               : _kDefaultFindPanelHeight) +
           8;

  @override
  Size get preferredSize =>
      Size(double.infinity, controller.isActive ? height : 0);

  @override
  Widget build(BuildContext context) {
    if (!controller.isActive) {
      return const SizedBox(width: 0, height: 0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      color: context.colorScheme.surface,
      alignment: Alignment.centerLeft,
      height: height,
      child: _buildFindInputView(context),
    );
  }

  Widget _buildFindInputView(BuildContext context) {
    final result = controller.matchCount == 0
        ? appLocalizations.none
        : controller.hasMoreMatches
            ? '${controller.currentMatchIndex + 1}/1000+'
            : '${controller.currentMatchIndex + 1}/${controller.matchCount}';
    final bar = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isMobileView) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _buildFindInput(context),
          ),
          const SizedBox(width: 12),
        ],
        Text(result, style: context.textTheme.bodyMedium),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              _buildIconButton(
                onPressed: controller.matchCount == 0
                    ? null
                    : controller.previous,
                icon: Icons.arrow_upward,
              ),
              _buildIconButton(
                onPressed: controller.matchCount == 0
                    ? null
                    : controller.next,
                icon: Icons.arrow_downward,
              ),
              const SizedBox(width: 2),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.isActive = false,
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                ),
                icon: const Icon(Icons.close, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
    if (isMobileView) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [bar, const SizedBox(height: 4), _buildFindInput(context)],
      );
    }
    return bar;
  }

  Stack _buildFindInput(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildTextField(
          context: context,
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
          spacing: 8,
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSubmitted,
  }) {
    return TextField(
      maxLines: 1,
      focusNode: focusNode,
      style: context.textTheme.bodyMedium,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      onSubmitted: (_) {
        onSubmitted();
      },
      controller: controller,
    );
  }

  Widget _buildCheckText({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: isSelected
            ? IconButton.filledTonal(
                onPressed: onPressed,
                padding: const EdgeInsets.all(2),
                icon: Text(text, style: context.textTheme.bodySmall),
              )
            : IconButton(
                onPressed: onPressed,
                padding: const EdgeInsets.all(2),
                icon: Text(text, style: context.textTheme.bodySmall),
              ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
      ),
      icon: Icon(icon, size: 16),
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

class _NoInputBorder extends InputBorder {
  const _NoInputBorder() : super(borderSide: BorderSide.none);

  @override
  _NoInputBorder copyWith({BorderSide? borderSide}) => const _NoInputBorder();

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  _NoInputBorder scale(double t) => const _NoInputBorder();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    canvas.drawRect(rect, paint);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {}
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
