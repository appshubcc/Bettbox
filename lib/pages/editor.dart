import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart' hide Mode;
import 'package:bett_box/models/common.dart';
import 'package:bett_box/plugins/clipboard_ext.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/re_highlight.dart' show Mode;
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

typedef EditorWidgetBuilder = Widget Function();

const double _kMinEditorZoom = 0.7;
const double _kMaxEditorZoom = 1.5;
const double _kMaxLineNumberZoom = 1;
const double _kToolbarGapAbove = 32;
const double _kToolbarGapBelow = 16;
const double _kToolbarClearance = 72;

final List<String> _emojiFontFallback = [FontFamily.twEmoji.value];

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
  late final FocusNode _titleFocusNode;
  late final FocusNode _saveButtonFocusNode;
  VoidCallback? _removePasteHandler;
  VoidCallback? _hideSelectionToolbar;
  bool _lineWrap = false;
  bool _isLoading = true;
  Brightness? _brightness;
  Map<String, TextStyle> _editorTheme = const {};
  SyntaxHighlighter? _magnifierHighlighter;
  final _magnifierComments = BlockCommentStates();
  int _magnifierCommentsVersion = -1;
  static double _zoom = 1;
  double _baseFontSize = 14;
  CodeSelectionStyle? _selectionStyle;
  TextStyle? _textStyle;
  TextStyle? _lineNumberStyle;

  bool get _disableSyntaxHighlight => widget.simple;

  bool get _editorHasFocus => _controller.focusNode?.hasFocus ?? false;

  late final String _original = CodeForgeController.normalizeLineBreaks(
    widget.content,
  );
  int _loadedLength = 0;
  int _checkedVersion = -1;
  bool _modified = false;

  bool get _isModified {
    if (_isLoading) return false;
    final version = _controller.contentVersion;
    if (version != _checkedVersion) {
      _checkedVersion = version;
      _modified =
          _controller.isComposingActive ||
          _controller.length != _loadedLength ||
          _controller.text != _original;
    }
    return _modified;
  }

  @override
  void initState() {
    super.initState();
    _saveButtonFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (!globalState.isAndroidTV || event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (widget.titleEditable && !widget.readOnly && !widget.simple) {
            _titleFocusNode.requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
    _titleFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (!globalState.isAndroidTV || event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (_titleController.selection.baseOffset >=
                  _titleController.text.length ||
              _titleController.text.isEmpty) {
            _saveButtonFocusNode.requestFocus();
            return KeyEventResult.handled;
          }
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _saveButtonFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
    _lineWrap = !widget.readOnly;
    _controller = CodeForgeController();
    _controller.useSpaceAsTab = true;
    _controller.tabSize = 2;
    _controller.enableLocalSuggestions = !widget.readOnly && !widget.simple;
    if (!widget.simple) {
      final language = widget.languages.firstOrNull;
      _controller
        ..lineCommentPrefix = switch (language) {
          Language.yaml => '# ',
          Language.javaScript => '// ',
          _ => null,
        }
        ..blockComments = language == Language.javaScript;
    }
    _findController = _EditorFindController(_controller);
    _undoController = UndoRedoController();
    _titleController = TextEditingController(text: widget.title);

    if (system.isWindows) {
      _removePasteHandler = clipboardExt.addHandler(_handleNativePaste);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _routeSettled();
      if (!mounted) return;
      _controller
        ..text = widget.content
        ..selection = const TextSelection.collapsed(offset: 0);
      _loadedLength = _controller.length;
      _checkedVersion = _controller.contentVersion;
      setState(() => _isLoading = false);
      if (widget.delayedFocus) {
        unawaited(_controller.focusNode?.requestFocusWhenIdle());
      }
    });
  }

  /// Handles a native paste command (Windows clipboard history) while the
  /// editor holds focus. Returns false so other handlers can take over.
  Future<bool> _handleNativePaste() async {
    if (widget.readOnly || widget.simple) return false;
    if (!_editorHasFocus) return false;
    await _controller.paste();
    return true;
  }

  @override
  void dispose() {
    _hideSelectionToolbar?.call();
    _removePasteHandler?.call();
    _controller.text = '';
    _findController.dispose();
    _undoController.dispose();
    _controller.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
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
    _findController.show();
  }

  void _handleReplace() {
    _findController.show(replace: true);
  }

  void _handleSave(BuildContext context) {
    if (widget.onSave == null) return;
    if (widget.readOnly || widget.simple) return;
    if (_isLoading) return;
    final isNewScript = widget.title.isEmpty;
    if (!isNewScript && !_isModified && _titleController.text == widget.title) {
      return;
    }
    widget.onSave!(context, _titleController.text, _controller.text);
  }

  Future<void> _routeSettled() async {
    final route = ModalRoute.of(context);
    while (route != null && route.offstage && route.isActive) {
      await SchedulerBinding.instance.endOfFrame;
    }
    final animation = route?.animation;
    if (animation == null || !animation.isAnimating) return;
    final completer = Completer<void>();
    void listener(AnimationStatus status) {
      if (status.isAnimating) return;
      animation.removeStatusListener(listener);
      completer.complete();
    }

    animation.addStatusListener(listener);
    return completer.future;
  }

  void _toggleLineWrap() {
    setState(() => _lineWrap = !_lineWrap);
  }

  void _updateStyles(BuildContext context) {
    _baseFontSize = context.textTheme.bodyMedium?.fontSize?.ap ?? 14;
    final colorScheme = context.colorScheme;
    if (colorScheme.brightness != _brightness) {
      _brightness = colorScheme.brightness;
      _editorTheme = colorScheme.brightness == Brightness.dark
          ? atomOneDarkTheme
          : atomOneLightTheme;
      _magnifierHighlighter = null;
    }
    final selectionStyle = CodeSelectionStyle(
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withAlpha(77),
      cursorBubbleColor: colorScheme.primary,
    );
    if (_selectionStyle?.cursorColor != selectionStyle.cursorColor) {
      _selectionStyle = selectionStyle;
    }
    final textStyle = TextStyle(
      fontFamily: FontFamily.jetBrainsMono.value,
      fontFamilyFallback: _emojiFontFallback,
      fontSize: _baseFontSize * _zoom,
    );
    if (textStyle != _textStyle) {
      _textStyle = textStyle;
      _magnifierHighlighter = null;
    }
    _lineNumberStyle = TextStyle(
      fontFamily: FontFamily.jetBrainsMono.value,
      fontSize: _baseFontSize * math.min(_zoom, _kMaxLineNumberZoom),
    );
  }

  TextSpan? _magnifierLineSpan(int line, String text) {
    final highlighter = _highlighterForMagnifier;
    if (_controller.blockComments) {
      final version = _controller.contentVersion;
      if (version != _magnifierCommentsVersion) {
        _magnifierCommentsVersion = version;
        _magnifierComments.reset();
      }
      if (_magnifierComments.startsInside(_controller, line)) {
        return highlighter.blockCommentSpan(text);
      }
    }
    return highlighter.lineSpan(text);
  }

  SyntaxHighlighter get _highlighterForMagnifier =>
      _magnifierHighlighter ??= SyntaxHighlighter(
        language: _languageMode(),
        editorTheme: _editorTheme,
        baseTextStyle: _textStyle,
      );

  void _commitZoom(double zoom) {
    final previous = _zoom;
    final fontSize = (_baseFontSize * zoom * 2).round() / 2;
    final next = (fontSize / _baseFontSize).clamp(
      _kMinEditorZoom,
      _kMaxEditorZoom,
    );
    if (next == previous) return;
    setState(() => _zoom = next);
  }

  void _setZoom(double zoom) {
    if (zoom == _zoom) return;
    setState(() => _zoom = zoom);
  }

  void _showContextMenu(
    BuildContext context,
    CodeForgeContextMenuRequest request,
  ) {
    final items = [
      if (request.hasSelection && !request.readOnly)
        PopupMenuItemData(
          icon: Icons.content_cut,
          label: appLocalizations.cut,
          onPressed: request.cut,
        ),
      if (request.hasSelection)
        PopupMenuItemData(
          icon: Icons.content_copy,
          label: appLocalizations.copy,
          onPressed: request.copy,
        ),
      if (!request.readOnly)
        PopupMenuItemData(
          icon: Icons.content_paste,
          label: appLocalizations.paste,
          onPressed: request.paste,
        ),
      PopupMenuItemData(
        icon: Icons.search,
        label: appLocalizations.search,
        onPressed: _handleSearch,
      ),
      if (!request.readOnly && _controller.lineCommentPrefix != null)
        PopupMenuItemData(
          icon: Icons.code,
          label: appLocalizations.blockComment,
          onPressed: _controller.toggleLineComment,
        ),
      if (!request.isAllSelected)
        PopupMenuItemData(
          icon: Icons.select_all,
          label: appLocalizations.selectAll,
          onPressed: request.selectAll,
        ),
    ];
    if (items.isEmpty) return;
    if (!system.isDesktop) {
      _showSelectionToolbar(context, request, items);
      return;
    }
    final navigator = Navigator.of(context);
    final navigatorBox = navigator.context.findRenderObject();
    if (navigatorBox is! RenderBox) return;
    final route = EditorMenuRoute(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      anchor: navigatorBox.globalToLocal(request.globalPosition),
      builder: (_) => CommonPopupMenu(items: items),
    );
    final stopWatching = _closeOnceOutdated(() {
      if (route.isCurrent) navigator.pop();
    });
    navigator.push(route).whenComplete(stopWatching);
  }

  void _showSelectionToolbar(
    BuildContext context,
    CodeForgeContextMenuRequest request,
    List<PopupMenuItemData> items,
  ) {
    _hideSelectionToolbar?.call();
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject();
    if (overlayBox is! RenderBox) return;
    final position = overlayBox.globalToLocal(request.globalPosition);
    final selectionRect = request.selectionRect;
    var anchorAbove = position.translate(0, -_kToolbarGapAbove);
    var anchorBelow = position.translate(0, _kToolbarGapBelow);
    if (selectionRect != null) {
      final paddingTop = MediaQuery.paddingOf(overlay.context).top;
      final insetBottom = MediaQuery.viewInsetsOf(overlay.context).bottom;
      final above = overlayBox.globalToLocal(selectionRect.topCenter);
      final below = overlayBox.globalToLocal(selectionRect.bottomCenter);
      final fitsAbove = above.dy - paddingTop >= _kToolbarClearance;
      final fitsBelow =
          below.dy + _kToolbarClearance <= overlayBox.size.height - insetBottom;
      if (fitsAbove || fitsBelow) {
        anchorAbove = above;
        anchorBelow = below;
      }
    }
    final root = _editorTheme['root'];
    final background = HSLColor.fromColor(
      root?.backgroundColor ?? context.colorScheme.surface,
    );
    final entry = OverlayEntry(
      builder: (_) => EditorSelectionToolbar(
        anchorAbove: anchorAbove,
        anchorBelow: anchorBelow,
        items: items,
        backgroundColor: background
            .withLightness((background.lightness + 0.03).clamp(0.0, 1.0))
            .toColor(),
        foregroundColor: root?.color,
        onDismiss: () => _hideSelectionToolbar?.call(),
      ),
    );
    late final VoidCallback stopWatching;
    _hideSelectionToolbar = () {
      _hideSelectionToolbar = null;
      stopWatching();
      entry.remove();
    };
    stopWatching = _closeOnceOutdated(() => _hideSelectionToolbar?.call());
    overlay.insert(entry);
  }

  VoidCallback _closeOnceOutdated(VoidCallback close) {
    final controller = _controller;
    final selection = controller.selection;
    final version = controller.contentVersion;
    final composition = controller.imeComposition;
    final focusNode = controller.focusNode;
    final hadFocus = focusNode?.hasFocus ?? false;
    void closeOnceOutdated() {
      final outdated =
          controller.selection != selection ||
          controller.contentVersion != version ||
          controller.imeComposition != composition ||
          hadFocus && !(focusNode?.hasFocus ?? false);
      if (outdated) close();
    }

    controller.addListener(closeOnceOutdated);
    focusNode?.addListener(closeOnceOutdated);
    return () {
      controller.removeListener(closeOnceOutdated);
      focusNode?.removeListener(closeOnceOutdated);
    };
  }

  Future<void> _handleImport() async {
    final option = await globalState.showAdaptiveSheet<ImportOption>(
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
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return;
      }
      final res = utf8.decode(bytes);
      _controller.replaceText(res);
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
    _controller.replaceText(res.data);
    widget.onUrlImport?.call(url);
  }

  Mode _languageMode() {
    if (_disableSyntaxHighlight) return langPlaintext;
    return switch (widget.languages.firstOrNull) {
      Language.yaml => editorYamlMode,
      Language.javaScript => langJavascript,
      _ => langPlaintext,
    };
  }

  List<PopupMenuItemData> _menuItems(bool canReplace) {
    return [
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
        onPressed: _toggleLineWrap,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobileView = ref.watch(isMobileViewProvider);
    _updateStyles(context);
    final readOnly = widget.readOnly || widget.simple;
    final canReplace =
        !readOnly &&
        !_disableSyntaxHighlight &&
        _languageMode() != langPlaintext;
    return CommonPopScope(
      onPop: () async {
        if (globalState.isAndroidTV &&
            (_editorHasFocus || _titleFocusNode.hasFocus)) {
          final isNewScript = widget.title.isEmpty;
          final hasChanges =
              isNewScript ||
              _isModified ||
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
          _isLoading ? widget.content : _controller.text,
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
          absorbing: _isLoading,
          child: CommonScaffold(
            scrollEdgeFade: false,
            appBar: AppBar(
              title: TextField(
                focusNode: _titleFocusNode,
                enabled: widget.titleEditable && !readOnly,
                controller: _titleController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _saveButtonFocusNode.requestFocus();
                },
                decoration: InputDecoration(
                  filled: false,
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
                  _wrapTitleController(() {
                    final isNewScript = widget.title.isEmpty;
                    final canSave =
                        !_isLoading &&
                        (isNewScript ||
                            _isModified ||
                            _titleController.text != widget.title);
                    return IconButton(
                      focusNode: _saveButtonFocusNode,
                      style: globalState.isAndroidTV
                          ? ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.focused)) {
                                  return context.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  );
                                }
                                return null;
                              }),
                              side: WidgetStateBorderSide.resolveWith((states) {
                                if (states.contains(WidgetState.focused)) {
                                  return BorderSide(
                                    color: context.colorScheme.primary,
                                    width: 2,
                                  );
                                }
                                return null;
                              }),
                            )
                          : null,
                      onPressed: canSave ? () => _handleSave(context) : null,
                      tooltip: appLocalizations.save,
                      icon: const Icon(Icons.save_sharp),
                    );
                  }),
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
                    popup: CommonPopupMenu(
                      items: _menuItems(canReplace),
                      footer: EditorZoomMenuItem(
                        zoom: _zoom,
                        minZoom: _kMinEditorZoom,
                        maxZoom: _kMaxEditorZoom,
                        onChanged: _setZoom,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            body: Stack(
              children: [
                if (!_isLoading)
                  CodeForge(
                    controller: _controller,
                    findController: _findController,
                    undoController: _undoController,
                    readOnly: readOnly,
                    lineWrap: _lineWrap,
                    tabSize: 2,
                    useSpaceAsTab: true,
                    language: _languageMode(),
                    editorTheme: _editorTheme,
                    selectionStyle: _selectionStyle,
                    textStyle: _textStyle,
                    lineNumberStyle: _lineNumberStyle,
                    innerPadding: const EdgeInsets.only(right: 16),
                    zoom: _zoom,
                    minZoom: _kMinEditorZoom,
                    maxZoom: _kMaxEditorZoom,
                    lineNumberMaxZoom: _kMaxLineNumberZoom,
                    onZoomEnd: _commitZoom,
                    onContextMenu: _showContextMenu,
                    suggestionPopupBuilder: (_, details) =>
                        CustomSingleChildLayout(
                          delegate: CaretPopupLayout(
                            caretRect: details.caretRect,
                          ),
                          child: EditorCompletionPopup(
                            details: details,
                            textStyle: _textStyle ?? const TextStyle(),
                          ),
                        ),
                    gutterDividerColor:
                        (_editorTheme['root']?.color ?? Colors.grey).withAlpha(
                          50,
                        ),
                    magnifierBuilder: (context, _, magnifierInfo) =>
                        EditorMagnifier(
                          controller: _controller,
                          magnifierInfo: magnifierInfo,
                          lineSpan: _magnifierLineSpan,
                          textStyle: _textStyle ?? const TextStyle(),
                          backgroundColor:
                              _editorTheme['root']?.backgroundColor ??
                              context.colorScheme.surface,
                          borderColor:
                              _editorTheme['root']?.color ?? Colors.grey,
                          caretColor: context.colorScheme.primary,
                          selectionColor:
                              _selectionStyle?.selectionColor ??
                              context.colorScheme.primary.withAlpha(77),
                        ),
                    scrollbarBuilder: (context, details, child) => RawScrollbar(
                      controller: details.controller,
                      thickness: 8,
                      minThumbLength: 48,
                      radius: const Radius.circular(4),
                      interactive: true,
                      thumbColor: context.colorScheme.onSurface.withAlpha(100),
                      child: _NoMouseDragScroll(child: child),
                    ),
                    finderBuilder: (context, controller) => FindPanel(
                      controller: controller,
                      readOnly: readOnly,
                      isMobileView: isMobileView,
                    ),
                  ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: context.colorScheme.surface.withAlpha(200),
                      child: Center(
                        child: SyncedLoading(
                          size: 40,
                          child: CircularProgressIndicator(
                            color: context.colorScheme.primary,
                          ),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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

class _NoMouseDragScroll extends StatelessWidget {
  const _NoMouseDragScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: {...behavior.dragDevices}..remove(PointerDeviceKind.mouse),
      ),
      child: child,
    );
  }
}
