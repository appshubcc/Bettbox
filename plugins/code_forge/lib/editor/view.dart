import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:code_forge/src/rust/api/editor.dart';

import '../code_forge.dart';
import 'text.dart';

part 'render.dart';
part 'paint.dart';

const int kExactWrappedHeightThreshold = 512;
const int kWrappedHeightSampleSize = 64;
const int kExactWrappedTailLines = 256;
const double kWheelZoomStep = 1.1;
const double kPanZoomPinchSlop = 0.05;

/// FlClash's code editor, with syntax highlighting, code folding, a line
/// number gutter, auto-indentation, bracket pairing, undo/redo, word
/// completion and search.
class CodeForge extends StatefulWidget {
  /// The controller for managing the editor's text content and selection.
  final CodeForgeController controller;

  /// The finder controller for managing search functionality.
  ///
  /// If not provided, an internal finder controller will be created.
  final FindController? findController;

  /// The controller for managing undo/redo operations.
  final UndoRedoController? undoController;

  /// The syntax highlighting theme as a map of token types to [TextStyle].
  final Map<String, TextStyle> editorTheme;

  /// The programming language mode for syntax highlighting.
  ///
  /// Determines which language syntax rules to apply.
  final Mode language;

  /// The base text style for the editor content.
  ///
  /// Defines the font family, size, and other text properties.
  final TextStyle? textStyle;

  /// Padding inside the editor content area.
  final EdgeInsets? innerPadding;

  /// Styling options for text selection and cursor.
  final CodeSelectionStyle? selectionStyle;

  /// Whether the editor is in read-only mode.
  ///
  /// When true, the user cannot modify the text content.
  final bool readOnly;

  /// Whether to wrap long lines.
  ///
  /// When true, lines wrap at the editor boundary. When false,
  /// horizontal scrolling is enabled.
  final bool lineWrap;

  /// The text style of the line numbers. Defaults to [textStyle]; a missing
  /// color comes from [editorTheme].
  final TextStyle? lineNumberStyle;

  final Color? gutterDividerColor;

  /// Custom tabSize for the editor.
  /// Defaults to 1 if using `\t`,
  /// or 2 if using space, by setting the [useSpaceAsTab] to `true`
  final int? tabSize;

  /// Use space instead of the `\t` character for tab key press.
  final bool useSpaceAsTab;

  /// Builder for a custom Finder widget.
  ///
  /// This builder is called to create the finder/search widget. It provides
  /// the [FindController] which can be used to control search functionality.
  /// The returned widget should implement [PreferredSizeWidget].
  final PreferredSizeWidget Function(
    BuildContext context,
    FindController findController,
  )?
  finderBuilder;

  final void Function(BuildContext context, CodeForgeContextMenuRequest request)
  onContextMenu;

  final Widget Function(
    BuildContext context,
    CodeForgeScrollbarDetails details,
    Widget child,
  )
  scrollbarBuilder;

  /// The popup is laid over the whole editor and positions itself against
  /// [CodeForgeSuggestionDetails.caretRect]; it is not built while the caret
  /// is scrolled out of view. The editor keeps the arrow keys, Enter, Tab and
  /// Escape.
  final Widget Function(
    BuildContext context,
    CodeForgeSuggestionDetails details,
  )
  suggestionPopupBuilder;

  /// Builds the loupe shown while a touch drags the caret, a selection handle
  /// or a selection. The editor shows it in the root overlay, feeds it the
  /// caret's [MagnifierInfo] in global coordinates and hides it through the
  /// controller when the drag ends. No loupe is shown when null.
  final MagnifierBuilder? magnifierBuilder;

  final double zoom;
  final double minZoom;
  final double maxZoom;
  final double lineNumberMaxZoom;
  final bool enablePinchZoom;
  final ValueChanged<double>? onZoomEnd;

  final int _tabSize;

  /// Creates a [CodeForge] code editor widget.
  const CodeForge({
    super.key,
    required this.controller,
    required this.editorTheme,
    required this.language,
    required this.onContextMenu,
    required this.scrollbarBuilder,
    required this.suggestionPopupBuilder,
    this.undoController,
    this.findController,
    this.textStyle,
    this.innerPadding,
    this.readOnly = false,
    this.lineWrap = false,
    this.lineNumberStyle,
    this.gutterDividerColor,
    this.tabSize,
    this.useSpaceAsTab = false,
    this.selectionStyle,
    this.finderBuilder,
    this.magnifierBuilder,
    this.zoom = 1.0,
    this.minZoom = 0.7,
    this.maxZoom = 1.5,
    this.lineNumberMaxZoom = double.infinity,
    this.enablePinchZoom = true,
    this.onZoomEnd,
  }) : _tabSize = tabSize ?? (useSpaceAsTab ? 2 : 1);

  @override
  State<CodeForge> createState() => _CodeForgeState();
}

class _CodeField extends LeafRenderObjectWidget {
  final CodeForgeController controller;
  final Map<String, TextStyle> editorTheme;
  final Mode language;
  final EdgeInsets? innerPadding;
  final ScrollController vscrollController, hscrollController;
  final FocusNode focusNode;
  final bool readOnly, isMobile, lineWrap;
  final AnimationController caretBlinkController;
  final AnimationController lineHighlightController;
  final TextStyle? textStyle;
  final GutterStyle gutterStyle;
  final CodeSelectionStyle selectionStyle;
  final ValueNotifier<bool> selectionActiveNotifier;
  final ValueNotifier<Rect?> caretRectNotifier;
  final ValueChanged<Offset> onContextMenuRequest;
  final ValueChanged<PointerSignalEvent> onPointerSignal;
  final ValueNotifier<MagnifierInfo?> magnifierNotifier;

  const _CodeField({
    super.key,
    required this.controller,
    required this.editorTheme,
    required this.language,
    required this.vscrollController,
    required this.hscrollController,
    required this.focusNode,
    required this.readOnly,
    required this.caretBlinkController,
    required this.lineHighlightController,
    required this.gutterStyle,
    required this.selectionStyle,
    required this.isMobile,
    required this.selectionActiveNotifier,
    required this.onContextMenuRequest,
    required this.onPointerSignal,
    required this.caretRectNotifier,
    required this.magnifierNotifier,
    required this.lineWrap,
    this.textStyle,
    this.innerPadding,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CodeFieldRenderer(
      controller: controller,
      editorTheme: editorTheme,
      language: language,
      innerPadding: innerPadding,
      vscrollController: vscrollController,
      hscrollController: hscrollController,
      focusNode: focusNode,
      readOnly: readOnly,
      caretBlinkController: caretBlinkController,
      lineHighlightController: lineHighlightController,
      textStyle: textStyle,
      gutterStyle: gutterStyle,
      selectionStyle: selectionStyle,
      isMobile: isMobile,
      selectionActiveNotifier: selectionActiveNotifier,
      onContextMenuRequest: onContextMenuRequest,
      onPointerSignal: onPointerSignal,
      lineWrap: lineWrap,
      caretRectNotifier: caretRectNotifier,
      magnifierNotifier: magnifierNotifier,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _CodeFieldRenderer renderObject,
  ) {
    renderObject
      ..editorTheme = editorTheme
      ..language = language
      ..textStyle = textStyle
      ..innerPadding = innerPadding
      ..readOnly = readOnly
      ..lineWrap = lineWrap
      ..gutterStyle = gutterStyle
      ..selectionStyle = selectionStyle;
  }
}

class CodeForgeContextMenuRequest {
  final Offset globalPosition;
  final bool hasSelection;

  /// The on-screen rows of the selection, in global coordinates; null when
  /// the selection is collapsed or scrolled out of view.
  final Rect? selectionRect;

  final bool isAllSelected;
  final bool readOnly;

  final VoidCallback copy;
  final VoidCallback cut;
  final VoidCallback paste;

  /// On mobile, also asks for the menu again, now for the whole document, the
  /// way the platform toolbars stay up after select all.
  final VoidCallback selectAll;

  const CodeForgeContextMenuRequest({
    required this.globalPosition,
    required this.hasSelection,
    this.selectionRect,
    required this.isAllSelected,
    required this.readOnly,
    required this.copy,
    required this.cut,
    required this.paste,
    required this.selectAll,
  });
}

class CodeForgeScrollbarDetails {
  final ScrollController controller;

  /// 1-based.
  final ValueListenable<int> firstVisibleLine;

  const CodeForgeScrollbarDetails({
    required this.controller,
    required this.firstVisibleLine,
  });
}

class CodeForgeSuggestionDetails {
  final List<CodeForgeSuggestion> suggestions;

  /// The entry Enter or Tab accepts, or null when none is highlighted.
  final int? selectedIndex;

  final ValueChanged<int> onAccept;
  final Rect caretRect;

  const CodeForgeSuggestionDetails({
    required this.suggestions,
    required this.selectedIndex,
    required this.onAccept,
    required this.caretRect,
  });
}

class _CodeForgeState extends State<CodeForge>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements CodeForgeView {
  late final ScrollController _hscrollController, _vscrollController;
  late CodeForgeController _controller;
  TwoDimensionalChildBuilderDelegate? _viewportDelegate;
  late final FocusNode _focusNode;
  late final AnimationController _caretBlinkController;
  late final AnimationController _lineHighlightController;
  late CodeSelectionStyle _selectionStyle;
  late GutterStyle _gutterStyle;
  late final ValueNotifier<bool> _selectionActiveNotifier;
  late UndoRedoController _undoRedoController;
  late FindController _findController;
  late bool _ownsUndoController, _ownsFindController;
  late final VoidCallback _controllerListener;
  late final VoidCallback _scrollbarLineNumberListener;
  final ValueNotifier<Rect?> _caretRectNotifier = ValueNotifier(null);
  final ValueNotifier<int> _scrollbarLineNumberIndicator = ValueNotifier(1);
  final ValueNotifier<MagnifierInfo?> _magnifierNotifier = ValueNotifier(null);
  final ValueNotifier<MagnifierInfo> _magnifierInfo = ValueNotifier(
    MagnifierInfo.empty,
  );
  final MagnifierController _magnifierController = MagnifierController();
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final Map<int, Offset> _touches = {};
  final ValueNotifier<Matrix4> _pinchTransform = ValueNotifier(
    Matrix4.identity(),
  );
  final ValueNotifier<bool> _isPinchingNotifier = ValueNotifier(false);
  int? _pinchPointer1;
  int? _pinchPointer2;
  int? _panZoomPointer;
  Offset _panZoomFocal = Offset.zero;
  Offset? _pinchFocalPoint;
  double? _startPinchDistance;
  double _pinchScale = 1.0;
  double _pinchDy = 0.0;
  double _pinchShiftX = 0.0;
  GlobalKey _codeFieldKey = GlobalKey();
  final GlobalKey _editorStackKey = GlobalKey();
  TextInputConnection? _connection;
  bool _isHovering = false;
  double _lastBottomViewInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();
    _hscrollController = ScrollController();
    _vscrollController = ScrollController();
    _selectionActiveNotifier = ValueNotifier(false);
    _magnifierNotifier.addListener(_syncMagnifier);
    _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();

    _gutterStyle = _gutterStyleFor(widget.editorTheme);

    _caretBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _lineHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _focusNode
      ..addListener(_handleFocusChange)
      ..addListener(_resetCursorBlink);

    _controllerListener = () {
      _resetCursorBlink();
      _updateScrollbarLineNumberIndicator();
    };

    _attachController();

    _scrollbarLineNumberListener = _updateScrollbarLineNumberIndicator;
    _vscrollController.addListener(_scrollbarLineNumberListener);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateScrollbarLineNumberIndicator(),
    );
  }

  _CodeFieldRenderer? get _renderer {
    final renderObject = _codeFieldKey.currentContext?.findRenderObject();
    return renderObject is _CodeFieldRenderer ? renderObject : null;
  }

  @override
  FocusNode get focusNode => _focusNode;

  @override
  void resetInput() => _resetImeConnection();

  @override
  Offset? caretOffset() => _renderer?.getCaretOffset();

  @override
  int? textOffsetAt(Offset position) =>
      _renderer?._getTextOffsetFromPosition(position);

  @override
  void toggleFold(int line) => _renderer?._toggleFoldAtLine(line);

  @override
  void scrollToLine(int line) => _renderer?._scrollToLine(line);

  GutterStyle _gutterStyleFor(Map<String, TextStyle> theme) {
    final themeColor = theme['root']?.color;
    return GutterStyle(
      foldIconColor: themeColor,
      backgroundColor: theme['root']?.backgroundColor,
      lineNumberStyle: widget.lineNumberStyle,
      dividerColor: widget.gutterDividerColor,
    );
  }

  @override
  void didUpdateWidget(covariant CodeForge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.editorTheme, oldWidget.editorTheme) ||
        widget.lineNumberStyle != oldWidget.lineNumberStyle ||
        widget.gutterDividerColor != oldWidget.gutterDividerColor) {
      _gutterStyle = _gutterStyleFor(widget.editorTheme);
    }
    if (widget.selectionStyle != oldWidget.selectionStyle) {
      _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();
    }

    if (!identical(widget.controller, oldWidget.controller)) {
      _detachController();
      _attachController();
      _codeFieldKey = GlobalKey();
      _openImeConnection();
    } else {
      if (!identical(widget.findController, oldWidget.findController)) {
        _detachFindController();
        _attachFindController();
      }
      if (!identical(widget.undoController, oldWidget.undoController)) {
        _detachUndoController();
        _attachUndoController();
      }
    }

    _controller
      ..useSpaceAsTab = widget.useSpaceAsTab
      ..tabSize = widget._tabSize;
    if (widget.readOnly != oldWidget.readOnly) {
      _controller.readOnly = widget.readOnly;
      _resetCursorBlink();
      if (widget.readOnly) {
        _closeImeConnection();
      } else {
        _openImeConnection();
      }
    }
    if (oldWidget.enablePinchZoom && !widget.enablePinchZoom) {
      _resetPinch();
    }
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final bottomInset = View.of(context).viewInsets.bottom;
    final insetGrew = bottomInset > _lastBottomViewInset;
    _lastBottomViewInset = bottomInset;
    if (!insetGrew || !_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderer = _renderer;
      if (renderer != null && renderer.attached) renderer._ensureCaretVisible();
    });
  }

  void _syncMagnifier() {
    final builder = widget.magnifierBuilder;
    final info = _magnifierNotifier.value;
    if (builder == null) return;
    if (info == null) {
      if (_magnifierController.shown) _magnifierController.hide();
      return;
    }
    _magnifierInfo.value = info;
    if (_magnifierController.overlayEntry != null) return;
    _magnifierController.show(
      context: context,
      builder: (context) =>
          builder(context, _magnifierController, _magnifierInfo) ??
          const SizedBox.shrink(),
    );
  }

  TwoDimensionalChildBuilderDelegate _replaceViewportDelegate(
    TwoDimensionalChildBuilderDelegate delegate,
  ) {
    final previous = _viewportDelegate;
    _viewportDelegate = delegate;
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
    return delegate;
  }

  @override
  void dispose() {
    _viewportDelegate?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _vscrollController.removeListener(_scrollbarLineNumberListener);
    _detachController();
    _caretBlinkController.dispose();
    _lineHighlightController.dispose();
    _selectionActiveNotifier.dispose();
    _caretRectNotifier.dispose();
    _magnifierNotifier.dispose();
    _magnifierController.hide();
    _magnifierInfo.dispose();
    _scrollbarLineNumberIndicator.dispose();
    _focusNode.dispose();
    _hscrollController.dispose();
    _vscrollController.dispose();
    _pinchTransform.dispose();
    _isPinchingNotifier.dispose();
    super.dispose();
  }

  void _resetPinch() {
    _touches.clear();
    _pinchPointer1 = null;
    _pinchPointer2 = null;
    _panZoomPointer = null;
    _pinchFocalPoint = null;
    _startPinchDistance = null;
    _pinchScale = 1.0;
    _pinchDy = 0.0;
    _pinchShiftX = 0.0;
    _pinchTransform.value = Matrix4.identity();
    _isPinchingNotifier.value = false;
  }

  void _finishPinch() {
    if (_startPinchDistance == null) return;
    final endScale = _pinchScale;
    final focal = _pinchFocalPoint;
    final dy = _pinchDy;
    final shiftX = _pinchShiftX;
    _startPinchDistance = null;
    _pinchPointer1 = null;
    _pinchPointer2 = null;
    _pinchFocalPoint = null;
    _pinchScale = 1.0;
    _pinchDy = 0.0;
    _pinchShiftX = 0.0;
    _pinchTransform.value = Matrix4.identity();
    _zoomAround(focal, endScale, dy, shiftX);
  }

  void _zoomAround(Offset? focal, double scale, double dy, double shiftX) {
    final renderer = _renderer;
    if (renderer != null && focal != null) {
      renderer._zoomFocus = (y: focal.dy, dy: dy, scale: scale, shiftX: shiftX);
      WidgetsBinding.instance
        ..addPostFrameCallback((_) => renderer._zoomFocus = null)
        ..ensureVisualUpdate();
    }
    widget.onZoomEnd?.call(widget.zoom * scale);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (_isMobile || !widget.enablePinchZoom || widget.onZoomEnd == null) {
      return;
    }
    if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) return;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      if (event is PointerScrollEvent) _zoomByWheel(event);
    });
  }

  void _zoomByWheel(PointerScrollEvent event) {
    event.respond(allowPlatformDefault: false);
    final renderer = _renderer;
    final stack = _editorStackKey.currentContext?.findRenderObject();
    if (renderer == null || stack is! RenderBox || !stack.attached) return;
    final baseZoom = max(0.001, widget.zoom);
    final step = event.scrollDelta.dy < 0 ? kWheelZoomStep : 1 / kWheelZoomStep;
    final targetZoom = (baseZoom * step).clamp(widget.minZoom, widget.maxZoom);
    if (targetZoom == baseZoom) return;
    final scale = targetZoom / baseZoom;
    final focal = stack.globalToLocal(event.position);
    final limit = widget.lineNumberMaxZoom;
    final preview = renderer._pinchPreview(
      focal,
      scale,
      min(targetZoom, limit) / min(baseZoom, limit),
    );
    _zoomAround(focal, scale, preview.dy, preview.shiftX);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enablePinchZoom || event.kind != PointerDeviceKind.touch) {
      return;
    }
    _touches[event.pointer] = event.localPosition;
    if (_pinchPointer1 == null && _touches.length >= 2) {
      final keys = _touches.keys.toList();
      _pinchPointer1 = keys[0];
      _pinchPointer2 = keys[1];
      final p1 = _touches[_pinchPointer1!]!;
      final p2 = _touches[_pinchPointer2!]!;
      _beginPinch((p1 + p2) / 2, max(1.0, (p1 - p2).distance));
    }
  }

  void _beginPinch(Offset focal, double start) {
    _startPinchDistance = start;
    _pinchFocalPoint = focal;
    _pinchScale = 1.0;
    _pinchDy = 0.0;
    _pinchShiftX = 0.0;
    _isPinchingNotifier.value = true;
    _controller.suggestionsNotifier.value = null;
    _magnifierNotifier.value = null;
    _renderer?._endGesture();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_touches.containsKey(event.pointer)) return;
    _touches[event.pointer] = event.localPosition;
    final p1 = _pinchPointer1;
    final p2 = _pinchPointer2;
    if (_startPinchDistance == null || p1 == null || p2 == null) return;
    if (event.pointer != p1 && event.pointer != p2) return;
    final pos1 = _touches[p1];
    final pos2 = _touches[p2];
    if (pos1 == null || pos2 == null) return;
    _updatePinch((pos1 - pos2).distance);
  }

  void _updatePinch(double distance) {
    final start = _startPinchDistance;
    if (start == null) return;
    final baseZoom = max(0.001, widget.zoom);
    final targetZoom = (baseZoom * distance / start).clamp(
      widget.minZoom,
      widget.maxZoom,
    );
    _pinchScale = targetZoom / baseZoom;
    final renderer = _renderer;
    final focal = _pinchFocalPoint;
    if (renderer == null || focal == null) return;
    final limit = widget.lineNumberMaxZoom;
    final preview = renderer._pinchPreview(
      focal,
      _pinchScale,
      min(targetZoom, limit) / min(baseZoom, limit),
    );
    _pinchDy = preview.dy;
    _pinchShiftX = preview.shiftX;
    _pinchTransform.value = Matrix4.translationValues(preview.dx, preview.dy, 0)
      ..scaleByDouble(_pinchScale, _pinchScale, 1, 1);
  }

  void _handlePanZoomStart(PointerPanZoomStartEvent event) {
    if (!widget.enablePinchZoom || _startPinchDistance != null) return;
    _panZoomPointer = event.pointer;
    _panZoomFocal = event.localPosition;
  }

  void _handlePanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (event.pointer != _panZoomPointer || _pinchPointer1 != null) return;
    if (_startPinchDistance == null) {
      if ((event.scale - 1).abs() < kPanZoomPinchSlop) return;
      _beginPinch(_panZoomFocal, event.scale);
    }
    _updatePinch(event.scale);
  }

  void _handlePanZoomEnd(PointerPanZoomEndEvent event) {
    if (event.pointer != _panZoomPointer) return;
    _panZoomPointer = null;
    if (_pinchPointer1 != null || _startPinchDistance == null) return;
    _finishPinch();
    _isPinchingNotifier.value = false;
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_touches.remove(event.pointer) == null) return;
    if (event.pointer == _pinchPointer1 || event.pointer == _pinchPointer2) {
      _finishPinch();
    }
    if (_touches.isEmpty && _isPinchingNotifier.value) {
      _isPinchingNotifier.value = false;
    }
  }

  void _attachController() {
    _controller = widget.controller
      ..attachView(this)
      ..readOnly = widget.readOnly
      ..tabSize = widget._tabSize
      ..useSpaceAsTab = widget.useSpaceAsTab
      ..addListener(_controllerListener);
    _attachFindController();
    _attachUndoController();
  }

  void _attachFindController() {
    _ownsFindController = widget.findController == null;
    _findController = widget.findController ?? FindController(_controller);
  }

  void _attachUndoController() {
    _ownsUndoController = widget.undoController == null;
    _undoRedoController = widget.undoController ?? UndoRedoController();
    _controller.setUndoController(_undoRedoController);
  }

  // A re-keyed editor mounts its replacement on the same controller before
  // this state is disposed, so only hooks still pointing here are cleared.
  void _detachController() {
    _controller.removeListener(_controllerListener);
    _closeImeConnection();
    _detachUndoController();
    _detachFindController();
    _controller.detachView(this);
  }

  void _detachFindController() {
    if (_ownsFindController) _findController.dispose();
  }

  bool get _isControllerView => identical(_controller.focusNode, _focusNode);

  void _detachUndoController() {
    if (_isControllerView &&
        _controller.undoController == _undoRedoController) {
      _controller.setUndoController(null);
    }
    if (_ownsUndoController) _undoRedoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.finderBuilder != null)
          ListenableBuilder(
            listenable: _findController,
            builder: (context, _) {
              if (!_findController.isActive) {
                return const SizedBox.shrink();
              }
              return widget.finderBuilder!(context, _findController);
            },
          ),
        Expanded(
          child: Stack(
            key: _editorStackKey,
            children: [
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerEnd,
                onPointerCancel: _handlePointerEnd,
                onPointerPanZoomStart: _handlePanZoomStart,
                onPointerPanZoomUpdate: _handlePanZoomUpdate,
                onPointerPanZoomEnd: _handlePanZoomEnd,
                child: _buildVerticalScrollbar(
                  context,
                  RawScrollbar(
                    thumbVisibility: _isHovering,
                    controller: _hscrollController,
                    child: GestureDetector(
                      onTap: () {
                        if (_isMobile) return;
                        _focusNode.requestFocus();
                      },
                      child: MouseRegion(
                        onEnter: (event) {
                          if (mounted) {
                            setState(() => _isHovering = true);
                          }
                        },
                        onExit: (event) {
                          if (mounted) {
                            setState(() => _isHovering = false);
                          }
                        },
                        child: ValueListenableBuilder(
                          valueListenable: _selectionActiveNotifier,
                          builder: (context, selVal, _) {
                            return ValueListenableBuilder(
                              valueListenable: _isPinchingNotifier,
                              builder: (context, isPinching, _) {
                                final isScrollLocked = selVal || isPinching;
                                return ValueListenableBuilder<Matrix4>(
                                  valueListenable: _pinchTransform,
                                  builder: (context, matrix, child) {
                                    return ClipRect(
                                      child: ColoredBox(
                                        color:
                                            widget
                                                .editorTheme['root']
                                                ?.backgroundColor ??
                                            Colors.white,
                                        child: Transform(
                                          transform: matrix,
                                          alignment: Alignment.topLeft,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: RepaintBoundary(
                                    child: TwoDimensionalScrollable(
                                      horizontalDetails:
                                          ScrollableDetails.horizontal(
                                            controller: _hscrollController,
                                            physics: isScrollLocked
                                                ? const NeverScrollableScrollPhysics()
                                                : const ClampingScrollPhysics(),
                                          ),
                                      verticalDetails: ScrollableDetails.vertical(
                                        controller: _vscrollController,
                                        physics: isScrollLocked
                                            ? const NeverScrollableScrollPhysics()
                                            : const ClampingScrollPhysics(),
                                      ),
                                      viewportBuilder: (_, voffset, hoffset) =>
                                          CustomViewport(
                                            verticalOffset: voffset,
                                            verticalAxisDirection:
                                                AxisDirection.down,
                                            horizontalOffset: hoffset,
                                            horizontalAxisDirection:
                                                AxisDirection.right,
                                            mainAxis: Axis.vertical,
                                            lineWrap: widget.lineWrap,
                                            delegate: _replaceViewportDelegate(
                                              TwoDimensionalChildBuilderDelegate(
                                                maxXIndex: 0,
                                                maxYIndex: 0,
                                                builder: (_, vic) {
                                                  return Focus(
                                                    focusNode: _focusNode,
                                                    onKeyEvent: _handleKeyEvent,
                                                    child: _CodeField(
                                                      key: _codeFieldKey,
                                                      controller: _controller,
                                                      editorTheme:
                                                          widget.editorTheme,
                                                      language: widget.language,
                                                      innerPadding:
                                                          widget.innerPadding,
                                                      vscrollController:
                                                          _vscrollController,
                                                      hscrollController:
                                                          _hscrollController,
                                                      focusNode: _focusNode,
                                                      readOnly: _readOnly,
                                                      caretBlinkController:
                                                          _caretBlinkController,
                                                      lineHighlightController:
                                                          _lineHighlightController,
                                                      textStyle:
                                                          widget.textStyle,
                                                      gutterStyle: _gutterStyle,
                                                      selectionStyle:
                                                          _selectionStyle,
                                                      isMobile: _isMobile,
                                                      selectionActiveNotifier:
                                                          _selectionActiveNotifier,
                                                      onContextMenuRequest:
                                                          _handleContextMenuRequest,
                                                      onPointerSignal:
                                                          _handlePointerSignal,
                                                      lineWrap: widget.lineWrap,
                                                      caretRectNotifier:
                                                          _caretRectNotifier,
                                                      magnifierNotifier:
                                                          _magnifierNotifier,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: _caretRectNotifier,
                  builder: (context, caretRect, child) {
                    if (caretRect == null) return const SizedBox.shrink();
                    return ValueListenableBuilder(
                      valueListenable: _controller.suggestionsNotifier,
                      builder: (_, sugg, child) {
                        if (sugg == null || sugg.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ValueListenableBuilder(
                          valueListenable:
                              _controller.selectedSuggestionNotifier,
                          builder: (context, selected, child) =>
                              _buildSuggestionPopup(
                                context,
                                sugg,
                                selected,
                                caretRect,
                              ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension _EditorStateKeyboard on _CodeForgeState {
  bool get _readOnly => widget.readOnly;

  // A word still composing is shown over the document, not held in it, and
  // the state sent once focus returns would leave the platform without it.
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _openImeConnection();
      return;
    }
    _controller.suggestionsNotifier.value = null;
    if (!_controller.isComposingActive) return;
    _controller.commitComposition();
    if (_connection?.attached ?? false) {
      _connection!.setEditingState(_controller.currentTextEditingValue);
    }
  }

  void _openImeConnection() {
    if (!_focusNode.hasFocus || _readOnly) return;
    if (!(_connection?.attached ?? false)) _attachImeConnection();
    if (!_isMobile) _connection!.show();
    _connection!.setEditingState(_controller.currentTextEditingValue);
  }

  // Closing the connection from this side leaves the platform nothing to end
  // a composition with, so it is committed here.
  void _closeImeConnection() {
    final connection = _connection;
    if (connection == null) return;
    _connection = null;
    connection.close();
    if (_controller.connection == connection) {
      _controller
        ..connection = null
        ..commitCompositionOnClose(later: true);
    }
  }

  void _attachImeConnection() {
    _controller.connection = _connection = TextInput.attach(
      _controller,
      TextInputConfiguration(
        readOnly: widget.readOnly,
        enableDeltaModel: true,
        inputType: TextInputType.multiline,
        inputAction: TextInputAction.newline,
        autocorrect: false,
        viewId: View.of(context).viewId,
      ),
    );
  }

  void _resetImeConnection() {
    if (_readOnly || !_focusNode.hasFocus) return;
    _closeImeConnection();
    _attachImeConnection();
    _connection!
      ..show()
      ..setEditingState(_controller.currentTextEditingValue);
  }

  void _resetCursorBlink() {
    if (!mounted) return;
    _caretBlinkController.stop();
    if (!_focusNode.hasFocus || _readOnly) {
      _caretBlinkController.value = 0.0;
      return;
    }
    _caretBlinkController
      ..value = 1.0
      ..repeat(reverse: true);
  }

  List<({ShortcutActivator? keys, bool edits, VoidCallback run})>
  _shortcutActions() {
    final shortcuts = CodeForgeKeyboardShortcuts.forPlatform(
      defaultTargetPlatform,
    );
    final controller = _controller;
    final undo = _undoRedoController;
    return [
      (keys: shortcuts.duplicate, edits: true, run: controller.duplicateLine),
      (
        keys: shortcuts.toggleComment,
        edits: true,
        run: controller.toggleLineComment,
      ),
      (
        keys: shortcuts.toggleBlockComment,
        edits: true,
        run: controller.toggleBlockComment,
      ),
      (
        keys: shortcuts.deleteWordBackward,
        edits: true,
        run: controller.deleteWordBackward,
      ),
      (
        keys: shortcuts.deleteWordForward,
        edits: true,
        run: controller.deleteWordForward,
      ),
      (
        keys: shortcuts.moveCursorToPreviousWord,
        edits: false,
        run: controller.moveWordLeft,
      ),
      (
        keys: shortcuts.moveCursorToNextWord,
        edits: false,
        run: controller.moveWordRight,
      ),
      (
        keys: shortcuts.jumpToDocumentStart,
        edits: false,
        run: controller.pressDocumentHomeKey,
      ),
      (
        keys: shortcuts.jumpToDocumentStartAndSelectText,
        edits: false,
        run: () => controller.pressDocumentHomeKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.jumpToDocumentEnd,
        edits: false,
        run: controller.pressDocumentEndKey,
      ),
      (
        keys: shortcuts.jumpToDocumentEndAndSelectText,
        edits: false,
        run: () => controller.pressDocumentEndKey(isShiftPressed: true),
      ),
      (keys: shortcuts.showFindBar, edits: false, run: _findController.show),
      (
        keys: shortcuts.showFindAndReplaceBar,
        edits: false,
        run: () => _findController.show(replace: !_readOnly),
      ),
      (keys: shortcuts.shiftLineUp, edits: true, run: controller.moveLineUp),
      (
        keys: shortcuts.shiftLineDown,
        edits: true,
        run: controller.moveLineDown,
      ),
      (
        keys: shortcuts.moveSelectionToPreviousWord,
        edits: false,
        run: () => controller.moveWordLeft(extend: true),
      ),
      (
        keys: shortcuts.moveSelectionToNextWord,
        edits: false,
        run: () => controller.moveWordRight(extend: true),
      ),
      (
        keys: shortcuts.moveSelectionForward,
        edits: false,
        run: () => controller.pressRightArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.moveSelectionBackward,
        edits: false,
        run: () => controller.pressLeftArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.moveSelectionUpward,
        edits: false,
        run: () => controller.pressUpArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.moveSelectionDownward,
        edits: false,
        run: () => controller.pressDownArrowKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.selectToLineStart,
        edits: false,
        run: () => controller.pressHomeKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.selectToLineEnd,
        edits: false,
        run: () => controller.pressEndKey(isShiftPressed: true),
      ),
      (
        keys: shortcuts.jumpToLineStart,
        edits: false,
        run: controller.pressHomeKey,
      ),
      (
        keys: shortcuts.jumpToLineEnd,
        edits: false,
        run: controller.pressEndKey,
      ),
      (
        keys: shortcuts.deleteToLineStart,
        edits: true,
        run: controller.deleteToLineStart,
      ),
      (keys: shortcuts.copy, edits: false, run: controller.copy),
      (keys: shortcuts.cut, edits: true, run: controller.cut),
      (keys: shortcuts.paste, edits: true, run: controller.paste),
      (keys: shortcuts.selectAll, edits: false, run: controller.selectAll),
      (
        keys: shortcuts.undo,
        edits: true,
        run: () {
          if (undo.canUndo) undo.undo();
        },
      ),
      (
        keys: shortcuts.redo,
        edits: true,
        run: () {
          if (undo.canRedo) undo.redo();
        },
      ),
    ];
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_controller.isComposingActive ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    for (final shortcut in _shortcutActions()) {
      if (!(shortcut.keys?.accepts(event, keyboard) ?? false)) continue;
      if (!shortcut.edits || !_readOnly) {
        shortcut.run();
        _resetCursorBlink();
      }
      return KeyEventResult.handled;
    }
    final key = event.logicalKey;
    if (_handleSuggestionKey(key)) return KeyEventResult.handled;
    final handled = _handleEditingKey(
      key,
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
      control: keyboard.isControlPressed || keyboard.isMetaPressed,
    );
    if (handled) _resetCursorBlink();
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  bool _handleSuggestionKey(LogicalKeyboardKey key) {
    if (!(_controller.suggestions?.isNotEmpty ?? false)) return false;
    switch (key) {
      case LogicalKeyboardKey.arrowDown:
        _controller.moveSuggestionSelection(1);
      case LogicalKeyboardKey.arrowUp:
        _controller.moveSuggestionSelection(-1);
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.tab:
        _controller.acceptSuggestion();
      case LogicalKeyboardKey.escape:
        _controller.suggestionsNotifier.value = null;
      default:
        return false;
    }
    return true;
  }

  bool _handleEditingKey(
    LogicalKeyboardKey key, {
    required bool shift,
    required bool alt,
    required bool control,
  }) {
    final controller = _controller;
    switch (key) {
      case LogicalKeyboardKey.tab when shift && !control:
        if (!_readOnly && !controller.previousSnippetStop()) {
          controller.unindent();
        }
      case LogicalKeyboardKey.backspace:
        if (_readOnly) return true;
        controller.backspace();
        _controller.suggestionsNotifier.value = null;
      case LogicalKeyboardKey.delete:
        if (_readOnly) return true;
        controller.delete();
        _controller.suggestionsNotifier.value = null;
      case LogicalKeyboardKey.arrowDown when !alt:
        controller.pressDownArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.arrowUp when !alt:
        controller.pressUpArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.arrowRight:
        controller.pressRightArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.arrowLeft:
        controller.pressLeftArrowKey(isShiftPressed: shift);
      case LogicalKeyboardKey.home:
        controller.pressHomeKey(isShiftPressed: shift);
      case LogicalKeyboardKey.end:
        controller.pressEndKey(isShiftPressed: shift);
      case LogicalKeyboardKey.escape:
        if (!_findController.isActive &&
            _controller.suggestions == null &&
            !controller.isSnippetActive) {
          return false;
        }
        controller.endSnippet();
        _findController.hide();
        _controller.suggestionsNotifier.value = null;
      case LogicalKeyboardKey.tab:
        if (!_readOnly &&
            _controller.suggestions == null &&
            !controller.nextSnippetStop()) {
          controller.indent();
        }
      case LogicalKeyboardKey.pageUp:
        _scrollPage(-1);
      case LogicalKeyboardKey.pageDown:
        _scrollPage(1);
      default:
        return false;
    }
    return true;
  }

  void _scrollPage(int direction) {
    _vscrollController.animateTo(
      _vscrollController.offset + direction * 650,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}

extension _EditorStateOverlays on _CodeForgeState {
  void _updateScrollbarLineNumberIndicator() {
    final renderer = _renderer;
    if (renderer == null) return;

    final lineNumber = renderer.getScrollbarLineNumberAtScrollOffset(
      _vscrollController.hasClients ? _vscrollController.offset : 0.0,
    );
    if (_scrollbarLineNumberIndicator.value != lineNumber) {
      _scrollbarLineNumberIndicator.value = lineNumber;
    }
  }

  void _handleContextMenuRequest(Offset offset) {
    final stack = _editorStackKey.currentContext?.findRenderObject();
    if (stack is! RenderBox || !stack.attached) return;
    final selection = _controller.selection;
    final selectionRect = _renderer?.getVisibleSelectionRect();
    widget.onContextMenu(
      context,
      CodeForgeContextMenuRequest(
        globalPosition: stack.localToGlobal(offset),
        hasSelection: !selection.isCollapsed,
        selectionRect: selectionRect,
        isAllSelected:
            selection.start == 0 && selection.end == _controller.length,
        readOnly: _readOnly,
        copy: _controller.copy,
        cut: _controller.cut,
        paste: () => _controller.paste(),
        selectAll: () {
          _controller.selectAll();
          if (_isMobile) _handleContextMenuRequest(offset);
        },
      ),
    );
  }

  Widget _buildVerticalScrollbar(BuildContext context, Widget child) {
    return widget.scrollbarBuilder(
      context,
      CodeForgeScrollbarDetails(
        controller: _vscrollController,
        firstVisibleLine: _scrollbarLineNumberIndicator,
      ),
      child,
    );
  }

  Widget _buildSuggestionPopup(
    BuildContext context,
    List<CodeForgeSuggestion> sugg,
    int? selectedIndex,
    Rect caretRect,
  ) {
    return widget.suggestionPopupBuilder(
      context,
      CodeForgeSuggestionDetails(
        suggestions: sugg,
        selectedIndex: selectedIndex,
        onAccept: _controller.acceptSuggestion,
        caretRect: caretRect,
      ),
    );
  }
}

/// A custom two-dimensional viewport for the code editor.
///
/// This viewport is used internally by [CodeForge] to enable both vertical
/// and horizontal scrolling within the editor. It delegates to a
/// [Render2DCodeField] for layout.
class CustomViewport extends TwoDimensionalViewport {
  final bool lineWrap;

  /// Creates a [CustomViewport] with the required scroll offsets and axes.
  const CustomViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    required this.lineWrap,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return Render2DCodeField(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      delegate: delegate,
      mainAxis: mainAxis,
      childManager: context as TwoDimensionalChildManager,
      lineWrap: lineWrap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTwoDimensionalViewport renderObject,
  ) {
    (renderObject as Render2DCodeField).lineWrap = lineWrap;
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..delegate = delegate
      ..mainAxis = mainAxis;
  }
}

/// The render object for the code editor's two-dimensional viewport.
///
/// This class handles the layout of the code editor content and manages
/// the content dimensions for both vertical and horizontal scrolling.
class Render2DCodeField extends RenderTwoDimensionalViewport {
  bool lineWrap;

  /// Creates a [Render2DCodeField] with the required scroll configuration.
  Render2DCodeField({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
    required this.lineWrap,
  });

  @override
  void layoutChildSequence() {
    final child = buildOrObtainChildFor(
      const ChildVicinity(xIndex: 0, yIndex: 0),
    );

    if (child != null) {
      child.layout(
        BoxConstraints(
          minHeight: viewportDimension.height,
          minWidth: viewportDimension.width,
          maxWidth: lineWrap ? viewportDimension.width : double.infinity,
          maxHeight: double.infinity,
        ),
        parentUsesSize: true,
      );
      parentDataOf(child).layoutOffset = Offset.zero;

      verticalOffset.applyContentDimensions(
        0.0,
        math.max(0.0, child.size.height - viewportDimension.height),
      );
      horizontalOffset.applyContentDimensions(
        0.0,
        math.max(0.0, child.size.width - viewportDimension.width),
      );
    }
  }
}

const _channel = MethodChannel('code_forge/haptics');
int _lastHandleMove = 0;

bool get _supported => Platform.isAndroid || Platform.isIOS;

Future<void> hapticHandleMove() async {
  if (!_supported) return;
  final now = DateTime.now().millisecondsSinceEpoch;
  if (now - _lastHandleMove < 50) return;
  _lastHandleMove = now;
  if (!Platform.isAndroid) return HapticFeedback.selectionClick();
  try {
    await _channel.invokeMethod('handleMove');
  } catch (_) {
    await HapticFeedback.selectionClick();
  }
}

Future<void> hapticLongPress() async {
  if (!_supported) return;
  if (!Platform.isAndroid) return HapticFeedback.mediumImpact();
  try {
    await _channel.invokeMethod('longPress');
  } catch (_) {
    await HapticFeedback.heavyImpact();
  }
}
