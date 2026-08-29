import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import '../code_forge.dart';
import './syntax_highlighter.dart';
import '../src/rust/api/editor.dart';

import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/lightfair.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

const int kSemanticTokenViewportPaddingLines = 5800;
const double kFlingVelocityMultiplier = 0.5;
const int kExactWrappedHeightThreshold = 5800;
const int kWrappedHeightSampleSize = 64;
final List<String> kEmojiFontFallback =
    defaultTargetPlatform == TargetPlatform.windows
    ? const ['Twemoji', 'Segoe UI Emoji', 'Noto Color Emoji', 'Roboto']
    : defaultTargetPlatform == TargetPlatform.linux
    ? const ['Twemoji', 'Noto Color Emoji', 'Roboto']
    : defaultTargetPlatform == TargetPlatform.android
    ? const ['Noto Color Emoji', 'Twemoji', 'Roboto']
    : const ['Apple Color Emoji', 'Twemoji', 'Roboto'];
const double _kSelectionHandleHitPadding = 20.0;
const double _kCaretHandleHitPadding = 24.0;
const double _kMobileHandleDragSlop = 8.0;
const MethodChannel _hapticsChannel = MethodChannel('code_forge/haptics');
const String _wordCharPattern =
    r'[\w\u0600-\u06FF\u08A0-\u08FF\u0590-\u05FF'
    r'\u3040-\u309F\u30A0-\u30FF\u3400-\u4DBF\u4E00-\u9FFF\uAC00-\uD7AF\uF900-\uFAFF\-]';

/// A highly customizable code editor widget for Flutter.
///
/// [CodeForge] provides a feature-rich code editing experience with support for:
/// - Syntax highlighting for multiple languages
/// - Code folding
/// - Line numbers and gutter
/// - Auto-indentation and bracket matching
/// - LSP (Language Server Protocol) integration
/// - AI code completion
/// - Undo/redo functionality
/// - Search highlighting
///
/// Example:
/// ```dart
/// final controller = CodeForgeController();
///
/// CodeForge(
///   controller: controller,
///   language: langDart,
///   enableFolding: true,
///   enableGutter: true,
///   textStyle: TextStyle(
///     fontFamily: 'JetBrains Mono',
///     fontSize: 14,
///   ),
/// )
/// ```
class CodeForge extends StatefulWidget {
  /// The controller for managing the editor's text content and selection.
  ///
  /// If not provided, an internal controller will be created.
  final CodeForgeController? controller;

  /// The finder controller for managing search functionality.
  ///
  /// If not provided, an internal finder controller will be created.
  final FindController? findController;

  /// The controller for managing undo/redo operations.
  ///
  /// If provided, enables undo/redo functionality in the editor.
  final UndoRedoController? undoController;

  /// The syntax highlighting theme as a map of token types to [TextStyle].
  ///
  /// Uses VS2015 dark theme by default if not specified.
  final Map<String, TextStyle>? editorTheme;

  /// The programming language mode for syntax highlighting.
  ///
  /// Determines which language syntax rules to apply. Uses Python mode
  /// by default if not specified.
  final Mode? language;

  final String? languageId;

  final String? blockCommentLabel;

  /// Additional language modes registered in the same highlighter instance.
  ///
  /// Useful for languages that embed other grammars (for example, TSX using
  /// XML/HTML sub-languages).
  final List<Mode> extraLanguages;

  /// The focus node for managing keyboard focus.
  ///
  /// If not provided, an internal focus node will be created.
  final FocusNode? focusNode;

  /// The base text style for the editor content.
  ///
  /// Defines the font family, size, and other text properties.
  final TextStyle? textStyle;

  /// The text style for ghost text (inline suggestions).
  ///
  /// This style is applied to the semi-transparent suggestion text
  /// that appears inline. Ghost text is set via the controller's
  /// `setGhostText()` method. If not specified, defaults to the
  /// editor's base text style with reduced opacity.
  ///
  /// Example:
  /// ```dart
  /// CodeForge(
  ///   ghostTextStyle: TextStyle(
  ///     color: Colors.grey.withOpacity(0.5),
  ///     fontStyle: FontStyle.italic,
  ///   ),
  /// )
  /// ```
  final TextStyle? ghostTextStyle;

  /// Customize the scroll appearance.
  /// Currently included vertical scrollbar only.
  final ScrollbarDecoration? scrollbarDecoration;

  /// Padding inside the editor content area.
  final EdgeInsets? innerPadding;

  /// Custom scroll controller for vertical scrolling.
  final ScrollController? verticalScrollController;

  /// Custom scroll controller for horizontal scrolling.
  final ScrollController? horizontalScrollController;

  /// The scroll physics that can be used to modify the vertical scroll behaviour of the editor.<br>
  /// Defaults to [ClampingScrollPhysics].<br>
  /// The horizontal scroll physics cannot be modified because [CodeForge] internally uses a custom scroll physics for RTL support.
  final ScrollPhysics verticalScrollPhysics;

  /// Keyboard shortcuts used by the [CodeForge] editor.<br>
  /// Most of the keyboard shortcuts, except the core operations like cut, copy, paste, select all, undo, redo
  /// can be modified by editing the hardcoded shortcuts defined in the [CodeForgeKeyboardShotcuts] class.<br>
  /// <br>
  /// eg:
  ///
  /// ```dart
  /// // Here the line duplicate shortcut `Ctrl + D` has beeb overriden by `Ctrl + B`.
  /// CodeForge(
  ///   keyboardShotcuts: CodeForgeKeyboardShotcuts(
  ///     duplicate: SingleActivator(LogicalKeyboardKey.keyB, control: true)
  ///   ),
  /// )
  /// ```
  ///
  /// **Note: There is no exception handling implemented to prevent the usage of same shortcut keys on multiple operations.
  /// Using the same shortcut on multiple operations may causes undefined behaviour.**
  final CodeForgeKeyboardShortcuts keyboardShotcuts;

  /// Styling options for text selection and cursor.
  final CodeSelectionStyle? selectionStyle;

  /// Can be used to build gutter with custom content instead of line numbers.
  final GutterBuilder? gutterBuilder;

  /// Styling options for the gutter (line numbers and fold icons).
  final GutterStyle? gutterStyle;

  /// Styling options for the autocomplete suggestion popup.
  final SuggestionStyle? suggestionStyle;

  /// Styling options for hover documentation popup.
  final HoverDetailsStyle? hoverDetailsStyle;

  /// Styling options for search match highlighting.
  final MatchHighlightStyle? matchHighlightStyle;

  /// The file path for LSP features.
  ///
  /// Required when using LSP integration to identify the document.
  final String? filePath;

  /// Initial text content for the editor.
  ///
  /// Used only during initialization; subsequent changes should use
  /// the controller.
  final String? initialText;

  /// Whether the editor is in read-only mode.
  ///
  /// When true, the user cannot modify the text content.
  final bool readOnly;

  /// Whether to wrap long lines.
  ///
  /// When true, lines wrap at the editor boundary. When false,
  /// horizontal scrolling is enabled.
  final bool lineWrap;

  /// Whether to automatically focus the editor when mounted.
  final bool autoFocus;

  /// Whether to enable code folding functionality.
  ///
  /// When true, fold icons appear in the gutter and code blocks
  /// can be collapsed.
  final bool enableFolding;

  /// Whether to show indentation guide lines.
  ///
  /// Displays vertical lines at each indentation level to help
  /// visualize code structure.
  final bool enableGuideLines;

  /// Whether to show the gutter with line numbers.
  final bool enableGutter;

  /// Whether to show a divider line between gutter and content.
  final bool enableGutterDivider;

  /// Whether to show the magnifier when dragging selection handles.
  final bool enableMagnifier;

  /// Whether to enable local and non LSP autocomplete suggestions.
  /// To control LSP suggestions, use the [capabilities] field of the [LspConfig].
  /// [false] by default because, this may cause delay or jitter in large files.
  final bool enableLocalSuggestions;

  /// Whether to show auto completions in the OS virtual keyboard.
  ///
  /// Defaults to true.
  final bool enableKeyboardSuggestions;

  /// The type of the virtual keyboard that will used by the [CodeForge].
  ///
  /// Defaults to [TextInputType.multiline]
  final TextInputType keyboardType;

  /// The text direction for the editor's content.
  ///
  /// This determines the direction in which text is laid out and rendered.
  /// For left-to-right languages like English, use [TextDirection.ltr].
  /// For right-to-left languages like Arabic or Hebrew, use [TextDirection.rtl].
  ///
  /// Defaults to [TextDirection.ltr].
  final TextDirection textDirection;

  /// Custom tabSize for the editor.
  /// Defaults to 1 if using `\t`,
  /// or 2 if using space, by setting the [useSpaceAsTab] to `true`
  final int? tabSize;

  /// Use space instead of the `\t` character for tab key press.
  final bool useSpaceAsTab;

  /// A list of custom code snippets that appear in the suggestion popup.
  ///
  /// Each [CustomCodeSnippet] defines a label (shown in the popup), the code
  /// to insert, and optional cursor positions within the inserted code.
  /// When a snippet with [CustomCodeSnippet.cursorLocations] is accepted the
  /// primary cursor is placed at the first location and secondary cursors are
  /// added at the remaining locations.
  ///
  /// If `null` or empty, no custom snippets are shown.
  final List<CustomCodeSnippet>? customCodeSnippets;

  /// Include custom items in the context menu (The menu appearson right click).
  final List<CustomContextMenu>? customContextMenuItems;

  /// If set to true, deleting the first line of a folded block will delete the entire folded region,
  /// else only the first line gets deleted and the rest of the block stays safe.
  /// Defauts to false.
  final bool deleteFoldRangeOnDeletingFirstLine;

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

  final int _tabSize;

  /// Creates a [CodeForge] code editor widget.
  const CodeForge({
    super.key,
    this.controller,
    this.undoController,
    this.editorTheme,
    this.language,
    this.languageId,
    this.blockCommentLabel,
    this.filePath,
    this.initialText,
    this.focusNode,
    this.verticalScrollController,
    this.horizontalScrollController,
    this.verticalScrollPhysics = const ClampingScrollPhysics(),
    this.textStyle,
    this.innerPadding,
    this.keyboardShotcuts = const CodeForgeKeyboardShortcuts(),
    this.customCodeSnippets,
    this.customContextMenuItems,
    this.readOnly = false,
    this.autoFocus = false,
    this.lineWrap = false,
    this.enableFolding = true,
    this.enableGuideLines = true,
    this.enableLocalSuggestions = false,
    this.enableKeyboardSuggestions = true,
    this.keyboardType = TextInputType.multiline,
    this.textDirection = TextDirection.ltr,
    this.tabSize,
    this.useSpaceAsTab = false,
    this.enableGutter = true,
    this.enableGutterDivider = false,
    this.enableMagnifier = true,
    this.deleteFoldRangeOnDeletingFirstLine = false,
    this.selectionStyle,
    this.gutterStyle,
    this.gutterBuilder,
    this.scrollbarDecoration,
    this.ghostTextStyle,
    this.suggestionStyle,
    this.hoverDetailsStyle,
    this.matchHighlightStyle,
    this.extraLanguages = const [],
    this.finderBuilder,
    this.findController,
  }) : _tabSize = tabSize ?? (useSpaceAsTab ? 2 : 1);

  @override
  State<CodeForge> createState() => _CodeForgeState();
}

class _CodeForgeState extends State<CodeForge> with TickerProviderStateMixin {
  late final ScrollController _hscrollController, _vscrollController;
  late final CodeForgeController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _caretBlinkController;
  late final AnimationController _lineHighlightController;
  late final Map<String, TextStyle> _editorTheme;
  late final Mode? _language;
  late final CodeSelectionStyle _selectionStyle;
  late final GutterStyle _gutterStyle;
  late final SuggestionStyle _suggestionStyle;
  late final HoverDetailsStyle _hoverDetailsStyle;
  late final ScrollbarDecoration _scrollbarDecoration;
  late final ValueNotifier<List<dynamic>?> _suggestionNotifier;
  late final ValueNotifier<(Offset, Map<String, int>)?> _hoverNotifier;
  late final ValueNotifier<Map<String, dynamic>?> _hoverContentNotifier;
  late final ValueNotifier<List<LspErrors>> _diagnosticsNotifier;
  late final ValueNotifier<LspSignatureHelps?> _lspSignatureNotifier;
  late final ValueNotifier<String?> _aiNotifier;
  late final ValueNotifier<Offset?> _aiOffsetNotifier;
  late final ValueNotifier<Offset> _contextMenuOffsetNotifier;
  late final ValueNotifier<bool> _selectionActiveNotifier, _isHoveringPopup;
  late final ValueNotifier<List<dynamic>?> _lspActionNotifier;
  late final UndoRedoController _undoRedoController;
  late final String? _filePath;
  late final FindController _findController;
  late final VoidCallback _semanticTokensListener;
  late final VoidCallback _controllerListener;
  late final VoidCallback _scrollbarLineNumberListener;
  late final bool _deleteFoldRangeOnDeletingFirstLine;
  late final VoidCallback _signatureListener, _hoverListener;
  late final VoidCallback _isHoveringPopupListener, _selectedSuggestionListener;
  late final VoidCallback _snippetSuggestionsListener, _snippetNotifierListener;
  late bool _readOnly;
  late final bool _ownsController;
  late final bool _ownsFindController;
  late final bool _ownsUndoRedoController;
  late final bool _ownsHorizontalScrollController;
  late final bool _ownsVerticalScrollController;
  final ValueNotifier<Offset> _offsetNotifier = ValueNotifier(Offset(0, 0));
  final ValueNotifier<Offset?> _lspActionOffsetNotifier = ValueNotifier(null);
  final ValueNotifier<int> _scrollbarLineNumberIndicator = ValueNotifier(1);
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final _suggScrollController = ScrollController();
  final _actionScrollController = ScrollController();
  final Map<String, String> _suggestionDetailsCache = {};
  final _isMac = Platform.isMacOS;
  final GlobalKey _codeFieldKey = GlobalKey();
  TextInputConnection? _connection;
  StreamSubscription? _lspResponsesSubscription;
  bool _isHovering = false, _isSignatureInvoked = false;
  bool _isMobileSuggActive = false, _isInjectingSnippets = false;
  bool _snippetsActive = false, _hoverSetByTap = false;
  int _prevSnippetTextLength = 0, _semanticTokensVersion = 0;
  List<LspSemanticToken>? _semanticTokens;
  List<Map<String, dynamic>> _extraText = [];
  int _sugSelIndex = 0, _actionSelIndex = 0;
  String? _selectedSuggestionMd;
  Timer? _hoverTimer, _semanticTokenTimer, _hoverRequestTimer;
  ({String key, Map<String, int> lineChar})? _queuedHoverRequest;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? CodeForgeController();
    _controller.languageId = widget.languageId;

    _controller.getFloatingCursorStartPosition = () {
      final renderObject = _codeFieldKey.currentContext?.findRenderObject();
      if (renderObject is _CodeFieldRenderer) {
        return renderObject.getCaretOffset();
      }
      return null;
    };

    _controller.getTextOffsetForFloatingCursorPosition = (Offset position) {
      final renderObject = _codeFieldKey.currentContext?.findRenderObject();
      if (renderObject is _CodeFieldRenderer) {
        return renderObject.getTextOffsetForPosition(position);
      }
      return _controller.selection.baseOffset;
    };

    _findController = widget.findController ?? FindController(_controller);
    _ownsFindController = widget.findController == null;
    _controller.focusNode = widget.focusNode ?? FocusNode();
    _focusNode = _controller.focusNode!;
    _hscrollController =
        widget.horizontalScrollController ?? ScrollController();
    _vscrollController = widget.verticalScrollController ?? ScrollController();
    _ownsHorizontalScrollController = widget.horizontalScrollController == null;
    _ownsVerticalScrollController = widget.verticalScrollController == null;
    _editorTheme = widget.editorTheme ?? lightfairTheme;
    _language = widget.language ?? Mode();
    _suggestionNotifier = _controller.suggestionsNotifier;
    _prevSnippetTextLength = _controller.text.length;
    _diagnosticsNotifier = _controller.diagnosticsNotifier;
    _lspActionNotifier = _controller.codeActionsNotifier;
    _lspSignatureNotifier = _controller.signatureNotifier;
    _hoverNotifier = ValueNotifier(null);
    _hoverContentNotifier = ValueNotifier(null);
    _aiNotifier = ValueNotifier(null);
    _aiOffsetNotifier = ValueNotifier(null);
    _contextMenuOffsetNotifier = ValueNotifier(const Offset(-1, -1));
    _selectionActiveNotifier = ValueNotifier(false);
    _isHoveringPopup = ValueNotifier<bool>(false);
    _controller.userCodeAction = _fetchCodeActionsForCurrentPosition;
    _selectionStyle = widget.selectionStyle ?? CodeSelectionStyle();
    _undoRedoController = widget.undoController ?? UndoRedoController();
    _ownsUndoRedoController = widget.undoController == null;
    _filePath = widget.filePath;
    _readOnly = widget.readOnly;
    _deleteFoldRangeOnDeletingFirstLine =
        widget.deleteFoldRangeOnDeletingFirstLine;
    _controller.setUndoController(_undoRedoController);
    _controller.enableLocalSuggestions = widget.enableLocalSuggestions;
    _controller.deleteFoldRangeOnDeletingFirstLine =
        _deleteFoldRangeOnDeletingFirstLine;

    if (widget.readOnly && !_controller.readOnly) {
      _controller.readOnly = true;
    } else if (_controller.readOnly && !widget.readOnly) {
      _readOnly = true;
    }

    if (widget._tabSize != _controller.tabSize) {
      _controller.tabSize = widget._tabSize;
    }

    if (widget.useSpaceAsTab != _controller.useSpaceAsTab) {
      _controller.useSpaceAsTab = widget.useSpaceAsTab;
    }

    _scrollbarDecoration =
        widget.scrollbarDecoration ??
        ScrollbarDecoration(
          thumbColor: _editorTheme['root']?.color?.withAlpha(150),
          thickness: 15,
          lineNumberStyle: TextStyle(
            color: _editorTheme['root']?.backgroundColor ?? Colors.black,
            fontSize: widget.textStyle?.fontSize ?? 14,
            fontFamily: widget.textStyle?.fontFamily,
            fontWeight: widget.textStyle?.fontWeight ?? FontWeight.bold,
          ),
        );

    _gutterStyle =
        widget.gutterStyle ??
        GutterStyle(
          lineNumberStyle: null,
          foldedIconColor: _editorTheme['root']?.color,
          unfoldedIconColor: _editorTheme['root']?.color,
          backgroundColor: _editorTheme['root']?.backgroundColor,
        );

    _suggestionStyle =
        widget.suggestionStyle ??
        SuggestionStyle(
          elevation: 8,
          textStyle: (() {
            TextStyle style = widget.textStyle ?? TextStyle();
            if (style.color == null) {
              style = style.copyWith(color: _editorTheme['root']!.color);
            }
            return style;
          })(),
          backgroundColor: (() {
            final lightnessDelta = 0.03;
            final base = _editorTheme['root']!.backgroundColor!;
            final hsl = HSLColor.fromColor(base);
            final newLightness = (hsl.lightness + lightnessDelta).clamp(
              0.0,
              1.0,
            );
            return hsl.withLightness(newLightness).toColor();
          })(),
          focusColor: ui.Color.fromARGB(108, 2, 66, 129),
          hoverColor: Colors.grey.withAlpha(15),
          splashColor: Colors.blueAccent.withAlpha(50),
          selectedBackgroundColor: Color(0xFF094771),
          borderColor:
              _editorTheme['root']!.color?.withAlpha(50) ?? Colors.grey[400],
          borderWidth: 1.0,
          itemHeight: 24.0,
          iconSize: 16.0,
          methodIconColor: Color(0xFFDCDFE4),
          propertyIconColor: Color(0xFF98C379),
          classIconColor: Color(0xFFE06C75),
          variableIconColor: Color(0xFF61AFEF),
          keywordIconColor: Color(0xFFC678DD),
          labelTextStyle: TextStyle(
            fontSize: widget.textStyle?.fontSize ?? 14,
            fontWeight: FontWeight.w500,
            color: _editorTheme['root']!.color,
          ),
          detailTextStyle: TextStyle(
            fontSize: (widget.textStyle?.fontSize ?? 14) * 0.85,
            color: _editorTheme['root']!.color?.withAlpha(150),
          ),
          typeTextStyle: TextStyle(
            fontSize: (widget.textStyle?.fontSize ?? 14) * 0.9,
            fontStyle: FontStyle.italic,
            color: _editorTheme['root']!.color?.withAlpha(180),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color:
                  _editorTheme['root']!.color?.withAlpha(50) ??
                  Colors.grey[400]!,
              width: 1.0,
            ),
          ),
        );

    _hoverDetailsStyle =
        widget.hoverDetailsStyle ??
        HoverDetailsStyle(
          shape: BeveledRectangleBorder(
            side: BorderSide(
              color: _editorTheme['root']!.color ?? Colors.grey[400]!,
              width: 0.2,
            ),
          ),
          backgroundColor: (() {
            final lightnessDelta = 0.03;
            final base = _editorTheme['root']!.backgroundColor!;
            final hsl = HSLColor.fromColor(base);
            final newLightness = (hsl.lightness + lightnessDelta).clamp(
              0.0,
              1.0,
            );
            return hsl.withLightness(newLightness).toColor();
          })(),
          focusColor: Colors.blueAccent.withAlpha(50),
          hoverColor: Colors.grey.withAlpha(15),
          splashColor: Colors.blueAccent.withAlpha(50),
          textStyle: (() {
            TextStyle style = widget.textStyle ?? _editorTheme['root']!;
            if (style.color == null) {
              style = style.copyWith(color: _editorTheme['root']!.color);
            }
            return style;
          })(),
        );

    _caretBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _lineHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _semanticTokensListener = () {
      final tokens = _controller.semanticTokens.value;
      if (!mounted) return;
      setState(() {
        _semanticTokens = tokens.$1;
        _semanticTokensVersion = tokens.$2;
      });
    };
    _controller.semanticTokens.addListener(_semanticTokensListener);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_readOnly) {
        if (_connection == null || !_connection!.attached) {
          _connection = _attachImeConnection();

          _controller.connection = _connection;
        }
        if (!_isMobile) _connection!.show();
        _controller.clearMultiCursors();
        _connection!.setEditingState(
          _controller.currentTextEditingValue ??
              TextEditingValue(
                text: _controller.text,
                selection: _controller.selection,
              ),
        );
      } else if (!_focusNode.hasFocus) {
        if (mounted && !_readOnly) {
          _controller.clearMultiCursors();
        }
      }
    });

    _controller.requestImeReset = _resetImeConnection;

    if (_filePath == null && _controller.lspConfig != null) {
      throw ArgumentError(
        "The `filePath` parameter cannot be null inorder to use `LspConfig`."
        "A valid file path is required to use the LSP services.",
      );
    }

    if (_filePath != null) {
      if (widget.initialText != null) {
        throw ArgumentError(
          'Cannot provide both filePath and initialText to CodeForge.',
        );
      } else if (_filePath.isNotEmpty) {
        if (_controller.openedFile != _filePath) {
          _controller.openedFile = _filePath;
        }
      }
    } else if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _controller.text = widget.initialText!;
    }

    _controllerListener = () {
      _resetCursorBlink();
      _updateScrollbarLineNumberIndicator();

      _isMobileSuggActive = _controller.currentlySelectedSuggestion != null;

      if (_readOnly != _controller.readOnly) {
        setState(() {
          _readOnly = _controller.readOnly;
        });
      }

      if (_controller.lastTypedCharacter == '(') {
        _isSignatureInvoked = true;
      } else if (_controller.lastTypedCharacter == ')') {
        _isSignatureInvoked = false;
      }

      if (_isSignatureInvoked) {
        if (_controller.lspConfig != null) {
          (() async => await _controller.callSignatureHelp())();
        }
      } else if (_lspSignatureNotifier.value != null) {
        _lspSignatureNotifier.value = null;
      }

      if (_hoverNotifier.value != null && mounted && !_hoverSetByTap) {
        _hoverTimer?.cancel();
        _hoverNotifier.value = null;
      }

      if (_hoverSetByTap) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _hoverSetByTap = false;
        });
      }
    };

    _controller.addListener(_controllerListener);

    _scrollbarLineNumberListener = _updateScrollbarLineNumberIndicator;
    _vscrollController.addListener(_scrollbarLineNumberListener);

    _hoverListener = () {
      final hov = _hoverNotifier.value;
      if (hov != null && _controller.lspConfig != null) {
        _requestHoverContent(hov.$2);
      } else {
        _hoverContentNotifier.value = null;
      }
    };
    _hoverNotifier.addListener(_hoverListener);

    _signatureListener = () {
      if (!mounted) return;
      if (_lspSignatureNotifier.value != null) {
        if (_lspSignatureNotifier.value!.parameters.isEmpty) {
          _lspSignatureNotifier.value = null;
          setState(() {
            _isSignatureInvoked = false;
          });
          return;
        }
      }
    };
    _lspSignatureNotifier.addListener(_signatureListener);

    _isHoveringPopupListener = () {
      if (!_isHoveringPopup.value && _hoverNotifier.value != null) {
        _hoverNotifier.value = null;
      }
    };
    _isHoveringPopup.addListener(_isHoveringPopupListener);

    _selectedSuggestionListener = () {
      if (!mounted) return;
      final selected = _controller.selectedSuggestionNotifier.value;
      if (selected != null && _isMobile) {
        setState(() {
          _sugSelIndex = selected;
        });
        _scrollToSelectedSuggestion();
      }
    };
    _controller.selectedSuggestionNotifier.addListener(
      _selectedSuggestionListener,
    );

    void injectSnippets(List<CustomCodeSnippet> snippets) {
      final current = _suggestionNotifier.value;
      if (current != null && current.any((e) => e is _SnippetSuggestion)) {
        return;
      }

      final cursor = _controller.selection.extentOffset;
      final prefix = _controller.getCurrentWordPrefixAt(cursor);
      final matching = snippets
          .where(
            (e) =>
                prefix.isEmpty ||
                e.label.toLowerCase().startsWith(prefix.toLowerCase()),
          )
          .map(
            (e) => _SnippetSuggestion(
              label: e.label,
              value: e.value,
              cursorLocations: e.cursorLocations,
            ),
          )
          .toList();

      if (matching.isEmpty) return;

      _isInjectingSnippets = true;
      _suggestionNotifier.value = [...matching, ...?current];
      _isInjectingSnippets = false;
    }

    _snippetSuggestionsListener = () {
      if (_isInjectingSnippets) return;
      final snippets = widget.customCodeSnippets;
      if (snippets == null || snippets.isEmpty) return;

      final currentLength = _controller.length;
      final grew = currentLength == _prevSnippetTextLength + 1;
      _prevSnippetTextLength = currentLength;

      if (!grew) return;

      final lastChar = _controller.lastTypedCharacter;
      final isAlpha =
          lastChar.isNotEmpty && RegExp(_wordCharPattern).hasMatch(lastChar);
      _snippetsActive = isAlpha;
      if (isAlpha) injectSnippets(snippets);
    };
    _controller.addListener(_snippetSuggestionsListener);

    _snippetNotifierListener = () {
      if (_isInjectingSnippets) return;
      if (!_snippetsActive) return;
      final snippets = widget.customCodeSnippets;
      if (snippets == null || snippets.isEmpty) return;
      injectSnippets(snippets);
    };
    _suggestionNotifier.addListener(_snippetNotifierListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollbarLineNumberIndicator();
      if (widget.autoFocus) {
        _focusNode.requestFocus();
      } else if (!_isMobile) {
        _connection = _attachImeConnection();

        _connection!.setEditingState(
          _controller.currentTextEditingValue ??
              TextEditingValue(
                text: _controller.text,
                selection: _controller.selection,
              ),
        );

        _controller.connection = _connection;
      }
    });
  }

  TextInputConnection _attachImeConnection() {
    return TextInput.attach(
      _controller,
      TextInputConfiguration(
        readOnly: widget.readOnly,
        enableDeltaModel: true,
        enableSuggestions: widget.enableKeyboardSuggestions && !widget.readOnly,
        inputType: widget.keyboardType,
        inputAction: TextInputAction.newline,
        autocorrect: false,
        viewId: View.of(context).viewId,
      ),
    );
  }

  void _resetImeConnection() {
    if (_readOnly || !_focusNode.hasFocus) return;
    final previous = _connection;
    _connection = null;
    _controller.connection = null;
    try {
      previous?.close();
    } catch (_) {}
    final fresh = _attachImeConnection();
    _connection = fresh;
    _controller.connection = fresh;
    fresh.show();
    fresh.setEditingState(
      _controller.currentTextEditingValue ??
          TextEditingValue(
            text: _controller.text,
            selection: _controller.selection,
          ),
    );
  }

  void _updateScrollbarLineNumberIndicator() {
    final renderObject = _codeFieldKey.currentContext?.findRenderObject();
    if (renderObject is! _CodeFieldRenderer) return;

    final lineNumber = renderObject.getScrollbarLineNumberAtScrollOffset(
      _vscrollController.hasClients ? _vscrollController.offset : 0.0,
    );
    if (_scrollbarLineNumberIndicator.value != lineNumber) {
      _scrollbarLineNumberIndicator.value = lineNumber;
    }
  }

  void _scrollToSelectedSuggestion() {
    if (!_suggScrollController.hasClients) return;

    final itemExtent = _suggestionStyle.itemHeight ?? 24.0;
    final selectedOffset = _sugSelIndex * itemExtent;
    final currentScroll = _suggScrollController.offset;
    final viewportHeight = _suggScrollController.position.viewportDimension;

    double? targetOffset;

    if (selectedOffset < currentScroll) {
      targetOffset = selectedOffset;
    } else if (selectedOffset + itemExtent > currentScroll + viewportHeight) {
      targetOffset = selectedOffset - viewportHeight + itemExtent;
    }

    if (targetOffset != null) {
      _suggScrollController.jumpTo(
        targetOffset.clamp(
          _suggScrollController.position.minScrollExtent,
          _suggScrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  void _scrollToSelectedAction() {
    if (!_actionScrollController.hasClients) return;

    final itemExtent = _suggestionStyle.itemHeight ?? 24.0;
    final selectedOffset = _actionSelIndex * itemExtent;
    final currentScroll = _actionScrollController.offset;
    final viewportHeight = _actionScrollController.position.viewportDimension;

    double? targetOffset;

    if (selectedOffset < currentScroll) {
      targetOffset = selectedOffset;
    } else if (selectedOffset + itemExtent > currentScroll + viewportHeight) {
      targetOffset = selectedOffset - viewportHeight + itemExtent;
    }

    if (targetOffset != null) {
      _actionScrollController.jumpTo(
        targetOffset.clamp(
          _actionScrollController.position.minScrollExtent,
          _actionScrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  String _getSuggestionCacheKey(dynamic item) {
    if (item is LspCompletion) {
      final map = item.completionItem;
      final id = map['id']?.toString() ?? '';
      final sort = map['sortText']?.toString() ?? '';
      final source = map['source']?.toString() ?? '';
      final label = item.label;
      final importUri = (item.importUri != null && item.importUri!.isNotEmpty)
          ? item.importUri![0]
          : '';
      return 'lsp|$label|$id|$sort|$source|$importUri';
    }
    return 'str|${item.toString()}';
  }

  Future<void> _fetchCodeActionsForCurrentPosition() async {
    if (_controller.lspConfig == null) return;
    final sel = _controller.selection;
    final cursor = sel.extentOffset;
    final line = _controller.getLineAtOffset(cursor);
    final lineStart = _controller.getLineStartOffset(line);
    final character = cursor - lineStart;

    final actions = await _controller.lspConfig!.getCodeActions(
      filePath: _filePath!,
      startLine: line,
      startCharacter: character,
      endLine: line,
      endCharacter: character,
      diagnostics: _diagnosticsNotifier.value
          .map((item) => item.toJson())
          .toList(),
    );

    _suggestionNotifier.value = null;
    _lspActionNotifier.value = actions;
    _actionSelIndex = 0;
    _lspActionOffsetNotifier.value = _offsetNotifier.value;
  }

  void _requestHoverContent(Map<String, int> lineChar) {
    final line = lineChar['line']!;
    final character = lineChar['character']!;
    final cacheKey = '$line:$character';

    if (_queuedHoverRequest != null && _queuedHoverRequest!.key == cacheKey) {
      return;
    }

    _hoverRequestTimer?.cancel();
    _hoverRequestTimer = Timer(Duration.zero, () {
      unawaited(_fetchHoverContent(lineChar, cacheKey));
    });
  }

  Future<void> _fetchHoverContent(
    Map<String, int> lineChar,
    String cacheKey,
  ) async {
    final line = lineChar['line']!;
    final character = lineChar['character']!;

    try {
      String diagnosticMessage = '';
      int severity = 0;
      String hoverMessage = '';

      final diagnostic = _diagnosticsNotifier.value.firstWhere((diag) {
        final diagStartLine = diag.range['start']['line'] as int;
        final diagEndLine = diag.range['end']['line'] as int;
        final diagStartChar = diag.range['start']['character'] as int;
        final diagEndChar = diag.range['end']['character'] as int;

        if (line < diagStartLine || line > diagEndLine) {
          return false;
        }

        if (line == diagStartLine && line == diagEndLine) {
          return character >= diagStartChar && character < diagEndChar;
        } else if (line == diagStartLine) {
          return character >= diagStartChar;
        } else if (line == diagEndLine) {
          return character < diagEndChar;
        } else {
          return true;
        }
      }, orElse: () => LspErrors(severity: 0, range: {}, message: ''));

      if (diagnostic.message.isNotEmpty) {
        diagnosticMessage = diagnostic.message;
        severity = diagnostic.severity;
      }

      if (_controller.lspConfig != null) {
        hoverMessage = await _controller.lspConfig!.getHover(
          _filePath!,
          line,
          character,
        );
      }

      if (!mounted) return;

      if (diagnosticMessage.isEmpty && hoverMessage.isEmpty) {
        _hoverNotifier.value = null;
        _hoverContentNotifier.value = null;
        final pendingHover = _queuedHoverRequest;
        _queuedHoverRequest = null;
        if (pendingHover != null && mounted) {
          _requestHoverContent(pendingHover.lineChar);
        }
        return;
      }

      final result = {
        'diagnostic': diagnosticMessage,
        'severity': severity,
        'hover': hoverMessage,
      };

      if (_hoverNotifier.value != null &&
          _hoverNotifier.value!.$2['line'] == line &&
          _hoverNotifier.value!.$2['character'] == character) {
        _hoverContentNotifier.value = result;
      }

      final pendingHover = _queuedHoverRequest;
      _queuedHoverRequest = null;
      if (pendingHover != null && mounted) {
        _requestHoverContent(pendingHover.lineChar);
      }
    } catch (e) {
      debugPrint('Error fetching hover content: $e');
      _hoverContentNotifier.value = {};
      final pendingHover = _queuedHoverRequest;
      _queuedHoverRequest = null;
      if (pendingHover != null && mounted) {
        _requestHoverContent(pendingHover.lineChar);
      }
    }
  }

  void _resetCursorBlink() {
    if (!mounted) return;
    _caretBlinkController.value = 1.0;
    _caretBlinkController
      ..stop()
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.semanticTokens.removeListener(_semanticTokensListener);
    _vscrollController.removeListener(_scrollbarLineNumberListener);
    _lspSignatureNotifier.removeListener(_signatureListener);
    _hoverNotifier.removeListener(_hoverListener);
    _isHoveringPopup.removeListener(_isHoveringPopupListener);
    _controller.selectedSuggestionNotifier.removeListener(
      _selectedSuggestionListener,
    );
    _controller.removeListener(_snippetSuggestionsListener);
    _suggestionNotifier.removeListener(_snippetNotifierListener);
    _connection?.close();
    _lspResponsesSubscription?.cancel();
    _caretBlinkController.dispose();
    _lineHighlightController.dispose();
    _hoverNotifier.dispose();
    _hoverContentNotifier.dispose();
    _aiNotifier.dispose();
    _aiOffsetNotifier.dispose();
    _contextMenuOffsetNotifier.dispose();
    _selectionActiveNotifier.dispose();
    _isHoveringPopup.dispose();
    _offsetNotifier.dispose();
    _lspActionOffsetNotifier.dispose();
    _suggScrollController.dispose();
    _actionScrollController.dispose();
    _hoverTimer?.cancel();
    _hoverRequestTimer?.cancel();
    _semanticTokenTimer?.cancel();
    if (_ownsFindController) _findController.dispose();
    if (_ownsUndoRedoController) _undoRedoController.dispose();
    if (_ownsHorizontalScrollController) _hscrollController.dispose();
    if (_ownsVerticalScrollController) _vscrollController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleArrowRight(bool withShift) {
    final ghost = _controller.ghostText;
    if (ghost != null && !ghost.shouldPersist && !withShift) {
      _acceptControllerGhostText();
      return;
    }

    if (_aiNotifier.value != null) {
      _acceptGhostText();
      return;
    }

    if (_suggestionNotifier.value != null) {
      _suggestionNotifier.value = null;
    }

    if (widget.textDirection == TextDirection.rtl) {
      _controller.pressLetfArrowKey(isShiftPressed: withShift);
    } else {
      _moveSelectionRight(withShift);
    }

    if (_controller.hasMultiCursors) {
      _controller.moveMultiCursorsRight(isShiftPressed: withShift);
    }
  }

  void _handleArrowLeft(bool withShift) {
    if (_suggestionNotifier.value != null) {
      _suggestionNotifier.value = null;
    }

    if (widget.textDirection == TextDirection.rtl) {
      _moveSelectionRight(withShift);
    } else {
      _controller.pressLetfArrowKey(isShiftPressed: withShift);
    }

    if (_controller.hasMultiCursors) {
      _controller.moveMultiCursorsLeft(isShiftPressed: withShift);
    }
  }

  void _moveSelectionRight(bool withShift) {
    final sel = _controller.selection;
    final textLength = _controller.length;

    int newOffset;
    if (!withShift && sel.start != sel.end) {
      newOffset = sel.end;
    } else if (sel.extentOffset < textLength) {
      newOffset = sel.extentOffset + 1;
    } else {
      newOffset = textLength;
    }

    if (withShift) {
      _controller.setSelectionSilently(
        TextSelection(baseOffset: sel.baseOffset, extentOffset: newOffset),
      );
    } else {
      _controller.setSelectionSilently(
        TextSelection.collapsed(offset: newOffset),
      );
    }
  }

  void _handleHomeKey(bool withShift) {
    if (_suggestionNotifier.value != null) {
      _suggestionNotifier.value = null;
    }

    _controller.pressHomeKey(isShiftPressed: withShift);
  }

  void _handleEndKey(bool withShift) {
    if (_suggestionNotifier.value != null) {
      _suggestionNotifier.value = null;
    }

    _controller.pressEndKey(isShiftPressed: withShift);
  }

  void _triggerSearchWithSelection({bool isReplace = false}) {
    if (_controller.selection.start != _controller.selection.end) {
      final start = _controller.selection.start.clamp(0, _controller.length);
      final end = _controller.selection.end.clamp(0, _controller.length);
      if (start < end) {
        final selectedText = _controller.substring(start, end);
        if (selectedText.isNotEmpty && !selectedText.contains('\n')) {
          _findController.findInputController.text = selectedText;
          _findController.find(selectedText);
        }
      }
    }
    if (!_readOnly) {
      _findController.isReplaceMode = isReplace;
    } else {
      _findController.isReplaceMode = false;
    }
    _findController.isActive = true;
    _contextMenuOffsetNotifier.value = const Offset(-1, -1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _findController.findInputFocusNode.requestFocus();
      }
    });
  }

  Widget _buildContextMenu() {
    return ValueListenableBuilder<Offset>(
      valueListenable: _contextMenuOffsetNotifier,
      builder: (context, offset, _) {
        if (offset.dx < 0 || offset.dy < 0) return const SizedBox.shrink();

        final hasSelection =
            _controller.selection.start != _controller.selection.end;

        if (_isMobile) {
          Offset anchorAbove = offset;
          Offset anchorBelow = Offset(offset.dx, offset.dy + 40);
          if (hasSelection) {
            final renderObject = _codeFieldKey.currentContext
                ?.findRenderObject();
            if (renderObject is _CodeFieldRenderer) {
              final rects = renderObject.getSelectionHandleRects();
              final startRect = rects.startHandle;
              final endRect = rects.endHandle;
              final lineHeight = rects.lineHeight;
              if (startRect != null && endRect != null && lineHeight > 0) {
                final handleRadius = (lineHeight / 2).clamp(6.0, 12.0);
                final centerX = (startRect.center.dx + endRect.center.dx) / 2;
                final minY = startRect.center.dy < endRect.center.dy
                    ? startRect.center.dy
                    : endRect.center.dy;
                final maxY = startRect.center.dy > endRect.center.dy
                    ? startRect.center.dy
                    : endRect.center.dy;
                anchorAbove = Offset(centerX, minY - lineHeight - handleRadius);
                anchorBelow = Offset(centerX, maxY - handleRadius);
              }
            }
          }
          return TextSelectionToolbar(
            anchorAbove: anchorAbove,
            anchorBelow: anchorBelow,
            toolbarBuilder: (BuildContext context, Widget child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _hoverDetailsStyle.backgroundColor,
                ),
                child: child,
              );
            },
            children: [
              if (hasSelection) ...[
                if (!_controller.readOnly)
                  TextSelectionToolbarTextButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      _controller.cut();
                      _contextMenuOffsetNotifier.value = const Offset(-1, -1);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cut,
                          size: 16,
                          color: _editorTheme['root']?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          MaterialLocalizations.of(context).cutButtonLabel,
                          style: TextStyle(
                            color: _editorTheme['root']?.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                TextSelectionToolbarTextButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    _controller.copy();
                    _contextMenuOffsetNotifier.value = const Offset(-1, -1);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: _editorTheme['root']?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        MaterialLocalizations.of(context).copyButtonLabel,
                        style: TextStyle(
                          color: _editorTheme['root']?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!_controller.readOnly)
                TextSelectionToolbarTextButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () async {
                    await _controller.paste();
                    _contextMenuOffsetNotifier.value = const Offset(-1, -1);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.paste,
                        size: 16,
                        color: _editorTheme['root']?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        MaterialLocalizations.of(context).pasteButtonLabel,
                        style: TextStyle(
                          color: _editorTheme['root']?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              TextSelectionToolbarTextButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: () {
                  _triggerSearchWithSelection();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      size: 16,
                      color: _editorTheme['root']?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MaterialLocalizations.of(context).searchFieldLabel,
                      style: TextStyle(
                        color: _editorTheme['root']?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.blockCommentLabel != null && !_controller.readOnly)
                TextSelectionToolbarTextButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    _controller.toggleComment();
                    _contextMenuOffsetNotifier.value = const Offset(-1, -1);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.code,
                        size: 16,
                        color: _editorTheme['root']?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.blockCommentLabel!,
                        style: TextStyle(
                          color: _editorTheme['root']?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              TextSelectionToolbarTextButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onPressed: () {
                  _controller.selectAll();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.select_all,
                      size: 16,
                      color: _editorTheme['root']?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MaterialLocalizations.of(context).selectAllButtonLabel,
                      style: TextStyle(
                        color: _editorTheme['root']?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: _ContextMenuLayoutDelegate(position: offset),
              child: Card(
                elevation: 8,
                color:
                    _editorTheme['root']?.backgroundColor ?? Colors.grey[900],
                shape: _suggestionStyle.shape,
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasSelection) ...[
                        if (!_controller.readOnly)
                          _buildDesktopContextMenuItem(
                            MaterialLocalizations.of(context).cutButtonLabel,
                            'Ctrl+X',
                            () => _controller.cut(),
                          ),
                        _buildDesktopContextMenuItem(
                          MaterialLocalizations.of(context).copyButtonLabel,
                          'Ctrl+C',
                          () => _controller.copy(),
                        ),
                      ],
                      if (!_controller.readOnly)
                        _buildDesktopContextMenuItem(
                          MaterialLocalizations.of(context).pasteButtonLabel,
                          'Ctrl+V',
                          () => _controller.paste(),
                        ),
                      _buildDesktopContextMenuItem(
                        MaterialLocalizations.of(context).searchFieldLabel,
                        'Ctrl+F',
                        () => _triggerSearchWithSelection(),
                      ),
                      if (widget.blockCommentLabel != null &&
                          !_controller.readOnly)
                        _buildDesktopContextMenuItem(
                          widget.blockCommentLabel!,
                          'Ctrl+/',
                          () => _controller.toggleComment(),
                        ),
                      _buildDesktopContextMenuItem(
                        MaterialLocalizations.of(context).selectAllButtonLabel,
                        'Ctrl+A',
                        () => _controller.selectAll(),
                      ),
                      ...widget.customContextMenuItems?.map(
                            (item) => _buildDesktopContextMenuItem(
                              item.label,
                              item.description,
                              item.onPress,
                            ),
                          ) ??
                          [],
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDesktopContextMenuItem(
    String label,
    String shortcut,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        onTap();
        _contextMenuOffsetNotifier.value = const Offset(-1, -1);
      },
      hoverColor: _suggestionStyle.hoverColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _suggestionStyle.textStyle),
            const SizedBox(width: 24),
            Text(
              shortcut,
              style: _suggestionStyle.textStyle.copyWith(
                color: _suggestionStyle.textStyle.color!.withAlpha(150),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSnippetSuggestions() {
    _snippetsActive = false;
    final current = _suggestionNotifier.value;
    if (current == null) return;
    final withoutSnippets = current
        .where((e) => e is! _SnippetSuggestion)
        .toList();
    if (withoutSnippets.length == current.length) return;
    _isInjectingSnippets = true;
    _suggestionNotifier.value = withoutSnippets.isEmpty
        ? null
        : withoutSnippets;
    _isInjectingSnippets = false;
  }

  void _commonKeyFunctions() {
    if (_aiNotifier.value != null) {
      _aiNotifier.value = null;
    }

    final ghost = _controller.ghostText;
    if (ghost != null && !ghost.shouldPersist) {
      _controller.clearGhostText();
    }

    _clearSnippetSuggestions();
    _resetCursorBlink();
  }

  void _deleteWordBackward() {
    if (_readOnly) return;
    final selection = _controller.selection;
    final text = _controller.text;

    if (!selection.isCollapsed) {
      _controller.replaceRange(selection.start, selection.end, '');
      return;
    }

    int caret = selection.extentOffset;
    if (caret <= 0) return;

    final prevChar = text[caret - 1];
    if (prevChar == '\n') {
      _controller.replaceRange(caret - 1, caret, '');
      return;
    }

    final before = text.substring(0, caret);
    final lineStart = text.lastIndexOf('\n', caret - 1) + 1;
    final lineText = before.substring(lineStart);

    final match = RegExp(r'(\w+|[^\w\s]+)\s*$').firstMatch(lineText);
    int deleteFrom = caret;
    if (match != null) {
      deleteFrom = lineStart + match.start;
    } else {
      deleteFrom = caret - 1;
    }

    _controller.replaceRange(deleteFrom, caret, '');
  }

  void _deleteWordForward() {
    if (_readOnly) return;
    final selection = _controller.selection;
    final text = _controller.text;

    if (!selection.isCollapsed) {
      _controller.replaceRange(selection.start, selection.end, '');
      return;
    }

    int caret = selection.extentOffset;
    if (caret >= text.length) return;

    final after = text.substring(caret);
    final match = RegExp(r'^(\s*\w+|\s*[^\w\s]+)').firstMatch(after);
    int deleteTo = caret;
    if (match != null) {
      deleteTo = caret + match.end;
    } else {
      deleteTo = caret + 1;
    }

    _controller.replaceRange(caret, deleteTo, '');
  }

  void _moveWordLeft(bool withShift) {
    final selection = _controller.selection;
    int caret = selection.extentOffset;

    if (caret <= 0) return;

    final lineIndex = _controller.getLineAtOffset(caret);
    final lineStart = _controller.getLineStartOffset(lineIndex);
    if (caret == lineStart && lineStart > 0) {
      final newOffset = lineStart - 1;
      _controller.setSelectionSilently(
        withShift
            ? TextSelection(
                baseOffset: selection.baseOffset,
                extentOffset: newOffset,
              )
            : TextSelection.collapsed(offset: newOffset),
      );
      return;
    }

    final lineText = _controller.getLineText(lineIndex);
    final colScalar = caret - lineStart;
    final colUtf16 = CodeForgeController.scalarToStringIndex(
      lineText,
      colScalar,
    );
    final subLineText = lineText.substring(0, colUtf16);
    final wordMatches = RegExp(
      '$_wordCharPattern+|[^$_wordCharPattern\\s]+',
    ).allMatches(subLineText).toList();

    int newColUtf16 = 0;
    for (final match in wordMatches) {
      if (match.end >= subLineText.length) break;
      newColUtf16 = match.start;
    }
    final newColScalar = CodeForgeController.utf16ToScalarOffset(
      lineText,
      newColUtf16,
    );
    final newOffset = lineStart + newColScalar;

    _controller.setSelectionSilently(
      withShift
          ? TextSelection(
              baseOffset: selection.baseOffset,
              extentOffset: newOffset,
            )
          : TextSelection.collapsed(offset: newOffset),
    );
  }

  void _moveWordRight(bool withShift) {
    final selection = _controller.selection;
    final text = _controller.text;
    int caret = selection.extentOffset;

    if (caret >= _controller.length) return;

    final caretUtf16 = CodeForgeController.scalarToStringIndex(text, caret);

    if (caretUtf16 < text.length && text[caretUtf16] == '\n') {
      final newOffset = caret + 1;
      _controller.setSelectionSilently(
        withShift
            ? TextSelection(
                baseOffset: selection.baseOffset,
                extentOffset: newOffset,
              )
            : TextSelection.collapsed(offset: newOffset),
      );
      return;
    }

    final regex = RegExp('$_wordCharPattern+|[^$_wordCharPattern\\s]+|\\s+');
    final matches = regex.allMatches(text, caretUtf16);

    int newOffsetUtf16 = caretUtf16;
    for (final match in matches) {
      if (match.start > caretUtf16) {
        newOffsetUtf16 = match.start;
        break;
      }
    }
    if (newOffsetUtf16 == caretUtf16) newOffsetUtf16 = text.length;

    final newOffset = CodeForgeController.utf16ToScalarOffset(
      text,
      newOffsetUtf16,
    );

    _controller.setSelectionSilently(
      withShift
          ? TextSelection(
              baseOffset: selection.baseOffset,
              extentOffset: newOffset,
            )
          : TextSelection.collapsed(offset: newOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    return LayoutBuilder(
      builder: (_, constraints) {
        final editorHeight = constraints.maxHeight;
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
                children: [
                  Directionality(
                    textDirection: widget.textDirection,
                    child: CustomScrollbar(
                      controller: _vscrollController,
                      lineNumberNotifier: _scrollbarLineNumberIndicator,
                      textDirection: widget.textDirection,
                      borderRadius: _scrollbarDecoration.borderRadius,
                      showLineNumberIndicator:
                          _scrollbarDecoration.showLineNumberIndicator,
                      thickness: _scrollbarDecoration.thickness,
                      thumbColor: _scrollbarDecoration.thumbColor,
                      interactive: _scrollbarDecoration.interactive,
                      crossAxisMargin: _scrollbarDecoration.crossAxisMargin,
                      mainAxisMargin: _scrollbarDecoration.mainAxisMargin,
                      scrollbarOrientation:
                          _scrollbarDecoration.scrollbarOrientation,
                      trackBorderColor: _scrollbarDecoration.trackBorderColor,
                      fadeDuration: _scrollbarDecoration.fadeDuration,
                      timeToFade: _scrollbarDecoration.timeToFade,
                      trackRadius: _scrollbarDecoration.trackRadius,
                      trackVisibility: _scrollbarDecoration.trackVisibility,
                      minOverscrollLength:
                          _scrollbarDecoration.minOverscrollLength,
                      minThumbLength: _scrollbarDecoration.minThumbLength,
                      padding: _scrollbarDecoration.padding?.resolve(
                        widget.textDirection,
                      ),
                      pressDuration: _scrollbarDecoration.pressDuration,
                      trackColor: _scrollbarDecoration.trackColor,
                      notificationPredicate:
                          _scrollbarDecoration.notificationPredicate,
                      thumbVisibility: _isHovering,
                      lineNumberStyle:
                          _scrollbarDecoration.lineNumberStyle ??
                          TextStyle(
                            color:
                                _editorTheme['root']?.backgroundColor ??
                                Colors.black,
                            fontSize: widget.textStyle?.fontSize ?? 14,
                            fontFamily: widget.textStyle?.fontFamily,
                          ),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: widget.textDirection == TextDirection.rtl
                            ? (Matrix4.identity()
                                ..scaleByVector3(Vector3(-1.0, 1.0, 1.0)))
                            : Matrix4.identity(),
                        child: RawScrollbar(
                          thumbVisibility: _isHovering,
                          controller: _hscrollController,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: widget.textDirection == TextDirection.rtl
                                ? (Matrix4.identity()
                                    ..scaleByVector3(Vector3(-1.0, 1.0, 1.0)))
                                : Matrix4.identity(),
                            child: GestureDetector(
                              onTap: () {
                                if (_isMobile) return;
                                _focusNode.requestFocus();
                              },
                              onDoubleTapDown: (details) {
                                if (_controller.text.isNotEmpty) return;
                                _contextMenuOffsetNotifier.value =
                                    details.localPosition;
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
                                  builder: (context, selVal, child) {
                                    return TwoDimensionalScrollable(
                                      horizontalDetails:
                                          ScrollableDetails.horizontal(
                                            controller: _hscrollController,
                                            physics: selVal
                                                ? const NeverScrollableScrollPhysics()
                                                : RTLAwareScrollPhysics(
                                                    isRTL:
                                                        widget.textDirection ==
                                                        TextDirection.rtl,
                                                    isMobile: _isMobile,
                                                  ),
                                          ),
                                      verticalDetails: ScrollableDetails.vertical(
                                        controller: _vscrollController,
                                        physics: selVal
                                            ? const NeverScrollableScrollPhysics()
                                            : widget.verticalScrollPhysics,
                                      ),
                                      viewportBuilder: (_, voffset, hoffset) => CustomViewport(
                                        verticalOffset: voffset,
                                        verticalAxisDirection:
                                            AxisDirection.down,
                                        horizontalOffset: hoffset,
                                        horizontalAxisDirection:
                                            widget.textDirection ==
                                                TextDirection.rtl
                                            ? AxisDirection.left
                                            : AxisDirection.right,
                                        mainAxis: Axis.vertical,
                                        lineWrap: widget.lineWrap,
                                        delegate: TwoDimensionalChildBuilderDelegate(
                                          maxXIndex: 0,
                                          maxYIndex: 0,
                                          builder: (_, vic) {
                                            return Focus(
                                              focusNode: _focusNode,
                                              onKeyEvent: (node, event) {
                                                if (_controller
                                                    .isComposingActive) {
                                                  return KeyEventResult.ignored;
                                                }

                                                final shrtCt =
                                                    widget.keyboardShotcuts;

                                                if (shrtCt.showFindBar.accepts(
                                                  event,
                                                  HardwareKeyboard.instance,
                                                )) {
                                                  final isAlt = HardwareKeyboard
                                                      .instance
                                                      .isAltPressed;
                                                  _triggerSearchWithSelection(
                                                    isReplace: isAlt,
                                                  );
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.showFindAndReplaceBar
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (!HardwareKeyboard
                                                      .instance
                                                      .isMetaPressed) {
                                                    _triggerSearchWithSelection(
                                                      isReplace: true,
                                                    );

                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                }

                                                if (shrtCt.duplicate.accepts(
                                                  event,
                                                  HardwareKeyboard.instance,
                                                )) {
                                                  if (!_readOnly) {
                                                    _controller.duplicateLine();
                                                    _commonKeyFunctions();
                                                  }
                                                  return KeyEventResult.handled;
                                                }

                                                final isCmdOrCtrl =
                                                    HardwareKeyboard
                                                        .instance
                                                        .isControlPressed ||
                                                    HardwareKeyboard
                                                        .instance
                                                        .isMetaPressed;
                                                final isShiftPressed =
                                                    HardwareKeyboard
                                                        .instance
                                                        .isShiftPressed;

                                                if (shrtCt.toggleComment
                                                        .accepts(
                                                          event,
                                                          HardwareKeyboard
                                                              .instance,
                                                        ) ||
                                                    (event is KeyDownEvent &&
                                                        isCmdOrCtrl &&
                                                        !isShiftPressed &&
                                                        event.logicalKey ==
                                                            LogicalKeyboardKey
                                                                .slash)) {
                                                  if (!_readOnly) {
                                                    _controller.toggleComment();
                                                    _commonKeyFunctions();
                                                  }
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.toggleBlockComment
                                                        .accepts(
                                                          event,
                                                          HardwareKeyboard
                                                              .instance,
                                                        ) ||
                                                    (event is KeyDownEvent &&
                                                        isCmdOrCtrl &&
                                                        isShiftPressed &&
                                                        event.logicalKey ==
                                                            LogicalKeyboardKey
                                                                .slash)) {
                                                  if (!_readOnly) {
                                                    _controller
                                                        .toggleBlockComment();
                                                    _commonKeyFunctions();
                                                  }
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.deletWordBackward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (!_readOnly) {
                                                    _deleteWordBackward();
                                                    _commonKeyFunctions();
                                                  }
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.deletWordForward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (!_readOnly) {
                                                    _deleteWordForward();
                                                    _commonKeyFunctions();
                                                  }
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .moveCursorToPreviousWord
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (widget.textDirection ==
                                                      TextDirection.rtl) {
                                                    _moveWordRight(false);
                                                  } else {
                                                    _moveWordLeft(false);
                                                  }
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.moveCursorToNextWord
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (widget.textDirection ==
                                                      TextDirection.rtl) {
                                                    _moveWordLeft(false);
                                                  } else {
                                                    _moveWordRight(false);
                                                  }
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.lspCodeActions
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  (() async {
                                                    _suggestionNotifier.value =
                                                        null;
                                                    await _fetchCodeActionsForCurrentPosition();
                                                  })();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.jumpToDocumentStart
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller
                                                      .pressDocumentHomeKey(
                                                        isShiftPressed: false,
                                                      );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .jumpToDocumentStartAndSelectText
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller
                                                      .pressDocumentHomeKey(
                                                        isShiftPressed: true,
                                                      );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.jumpToDocumentEnd
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller
                                                      .pressDocumentEndKey(
                                                        isShiftPressed: false,
                                                      );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .jumpToDocumentEndAndSelectText
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller
                                                      .pressDocumentEndKey(
                                                        isShiftPressed: true,
                                                      );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.showFindBar.accepts(
                                                  event,
                                                  HardwareKeyboard.instance,
                                                )) {
                                                  final isAlt = HardwareKeyboard
                                                      .instance
                                                      .isAltPressed;
                                                  _findController.isActive =
                                                      true;
                                                  _findController
                                                          .isReplaceMode =
                                                      isAlt;
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.showFindAndReplaceBar
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (!HardwareKeyboard
                                                      .instance
                                                      .isMetaPressed) {
                                                    _findController.isActive =
                                                        true;
                                                    _findController
                                                            .isReplaceMode =
                                                        true;

                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                }

                                                if (shrtCt.lspSignatureHelp
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  setState(() {
                                                    _isSignatureInvoked = true;
                                                  });
                                                  (() async => await _controller
                                                      .callSignatureHelp())();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.shiftLineUp.accepts(
                                                  event,
                                                  HardwareKeyboard.instance,
                                                )) {
                                                  _controller.moveLineUp();
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.shiftLineDown
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller.moveLineDown();
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .moveSelectionToPreviousWord
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (widget.textDirection ==
                                                      TextDirection.rtl) {
                                                    _moveWordRight(true);
                                                  } else {
                                                    _moveWordLeft(true);
                                                  }
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .moveSelectionToNextWord
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  if (widget.textDirection ==
                                                      TextDirection.rtl) {
                                                    _moveWordLeft(true);
                                                  } else {
                                                    _moveWordRight(true);
                                                  }
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.moveSelectionForward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _handleArrowRight(true);
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.moveSelectionBackward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _handleArrowLeft(true);
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.moveSelectionUpward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller.pressUpArrowKey(
                                                    isShiftPressed: true,
                                                  );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.moveSelectionDownward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller.pressDownArrowKey(
                                                    isShiftPressed: true,
                                                  );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.selectToLineStart
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller.pressHomeKey(
                                                    isShiftPressed: true,
                                                  );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt.selectToLineEnd
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  _controller.pressEndKey(
                                                    isShiftPressed: true,
                                                  );
                                                  _commonKeyFunctions();
                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .extendMutliCursorDownward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  final selection =
                                                      _controller.selection;
                                                  final primaryLine =
                                                      _controller
                                                          .getLineAtOffset(
                                                            selection
                                                                .extentOffset,
                                                          );

                                                  final anchorLine =
                                                      _controller
                                                          .hasMultiCursors
                                                      ? _controller.multiCursors
                                                            .map((c) => c.line)
                                                            .reduce(
                                                              (a, b) =>
                                                                  a > b ? a : b,
                                                            )
                                                      : primaryLine;

                                                  final foldAtAnchor = _controller
                                                      .getFoldRangeAtCurrentLine(
                                                        anchorLine,
                                                      );
                                                  int targetLine =
                                                      (foldAtAnchor != null &&
                                                          foldAtAnchor.isFolded)
                                                      ? foldAtAnchor.endIndex +
                                                            1
                                                      : anchorLine + 1;

                                                  while (targetLine <
                                                          _controller
                                                              .lineCount &&
                                                      _controller
                                                          .isLineInFoldedRegion(
                                                            targetLine,
                                                          )) {
                                                    final foldStart = _controller
                                                        .getFoldStartForLine(
                                                          targetLine,
                                                        );
                                                    if (foldStart != null) {
                                                      final fold =
                                                          _controller
                                                              .foldings[foldStart] ??
                                                          FoldRange(
                                                            targetLine,
                                                            targetLine,
                                                          );
                                                      targetLine =
                                                          fold.endIndex + 1;
                                                    } else {
                                                      targetLine++;
                                                    }
                                                  }

                                                  if (targetLine <
                                                      _controller.lineCount) {
                                                    final lineStart =
                                                        _controller
                                                            .getLineStartOffset(
                                                              primaryLine,
                                                            );
                                                    final column =
                                                        selection.extentOffset -
                                                        lineStart;
                                                    final nextLineText =
                                                        _controller.getLineText(
                                                          targetLine,
                                                        );
                                                    final newColumn = column
                                                        .clamp(
                                                          0,
                                                          nextLineText
                                                              .runes
                                                              .length,
                                                        );
                                                    _controller.addMultiCursor(
                                                      targetLine,
                                                      newColumn,
                                                    );
                                                  }

                                                  return KeyEventResult.handled;
                                                }

                                                if (shrtCt
                                                    .extendMutliCursorUpward
                                                    .accepts(
                                                      event,
                                                      HardwareKeyboard.instance,
                                                    )) {
                                                  final selection =
                                                      _controller.selection;
                                                  final primaryLine =
                                                      _controller
                                                          .getLineAtOffset(
                                                            selection
                                                                .extentOffset,
                                                          );

                                                  final anchorLine =
                                                      _controller
                                                          .hasMultiCursors
                                                      ? _controller.multiCursors
                                                            .map((c) => c.line)
                                                            .reduce(
                                                              (a, b) =>
                                                                  a < b ? a : b,
                                                            )
                                                      : primaryLine;

                                                  int targetLine =
                                                      anchorLine - 1;
                                                  while (targetLine > 0 &&
                                                      _controller
                                                          .isLineInFoldedRegion(
                                                            targetLine,
                                                          )) {
                                                    targetLine--;
                                                  }
                                                  if (_controller
                                                      .isLineInFoldedRegion(
                                                        targetLine,
                                                      )) {
                                                    targetLine =
                                                        _controller
                                                            .getFoldStartForLine(
                                                              targetLine,
                                                            ) ??
                                                        0;
                                                  }

                                                  final lineStart = _controller
                                                      .getLineStartOffset(
                                                        primaryLine,
                                                      );
                                                  final column =
                                                      selection.extentOffset -
                                                      lineStart;
                                                  final prevLineText =
                                                      _controller.getLineText(
                                                        targetLine,
                                                      );
                                                  final newColumn = column
                                                      .clamp(
                                                        0,
                                                        prevLineText
                                                            .runes
                                                            .length,
                                                      );
                                                  _controller.addMultiCursor(
                                                    targetLine,
                                                    newColumn,
                                                  );

                                                  return KeyEventResult.handled;
                                                }

                                                final isCtrlAltPressed =
                                                    (HardwareKeyboard
                                                            .instance
                                                            .isControlPressed ||
                                                        HardwareKeyboard
                                                            .instance
                                                            .isMetaPressed) &&
                                                    HardwareKeyboard
                                                        .instance
                                                        .isAltPressed;

                                                if (event is KeyDownEvent &&
                                                    isCtrlAltPressed &&
                                                    !_controller
                                                        .inlayHintsVisible) {
                                                  _controller.showInlayHints();
                                                  return KeyEventResult.handled;
                                                }

                                                if (event is KeyUpEvent &&
                                                    _controller
                                                        .inlayHintsVisible) {
                                                  final isStillCtrlAlt =
                                                      (HardwareKeyboard
                                                              .instance
                                                              .isControlPressed ||
                                                          HardwareKeyboard
                                                              .instance
                                                              .isMetaPressed) &&
                                                      HardwareKeyboard
                                                          .instance
                                                          .isAltPressed;
                                                  if (!isStillCtrlAlt) {
                                                    _controller
                                                        .hideInlayHints();
                                                    return KeyEventResult
                                                        .handled;
                                                  }
                                                }

                                                if (event is KeyDownEvent ||
                                                    event is KeyRepeatEvent) {
                                                  final isAltPressed =
                                                      HardwareKeyboard
                                                          .instance
                                                          .isAltPressed;
                                                  final isShiftPressed =
                                                      HardwareKeyboard
                                                          .instance
                                                          .isShiftPressed;
                                                  final isCtrlPressed =
                                                      HardwareKeyboard
                                                          .instance
                                                          .isControlPressed ||
                                                      HardwareKeyboard
                                                          .instance
                                                          .isMetaPressed;
                                                  if (_suggestionNotifier
                                                              .value !=
                                                          null &&
                                                      _suggestionNotifier
                                                          .value!
                                                          .isNotEmpty) {
                                                    final suggestions =
                                                        _suggestionNotifier
                                                            .value!;
                                                    switch (event.logicalKey) {
                                                      case LogicalKeyboardKey
                                                          .arrowDown:
                                                        if (mounted) {
                                                          setState(() {
                                                            _sugSelIndex =
                                                                (_sugSelIndex +
                                                                    1) %
                                                                suggestions
                                                                    .length;
                                                            _scrollToSelectedSuggestion();
                                                          });
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .arrowUp:
                                                        if (mounted) {
                                                          setState(() {
                                                            _sugSelIndex =
                                                                (_sugSelIndex -
                                                                    1 +
                                                                    suggestions
                                                                        .length) %
                                                                suggestions
                                                                    .length;
                                                            _scrollToSelectedSuggestion();
                                                          });
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .tab:
                                                        _acceptSuggestion();
                                                        if (_extraText
                                                            .isNotEmpty) {
                                                          _controller
                                                              .applyWorkspaceEdit(
                                                                _extraText,
                                                              );
                                                        }
                                                        setState(() {
                                                          _isSignatureInvoked =
                                                              true;
                                                        });
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .escape:
                                                        _suggestionNotifier
                                                                .value =
                                                            null;
                                                        return KeyEventResult
                                                            .handled;
                                                      default:
                                                        break;
                                                    }
                                                  }

                                                  if (_lspActionNotifier
                                                              .value !=
                                                          null &&
                                                      _lspActionOffsetNotifier
                                                              .value !=
                                                          null &&
                                                      _lspActionNotifier
                                                          .value!
                                                          .isNotEmpty) {
                                                    final actions =
                                                        _lspActionNotifier
                                                            .value!;
                                                    switch (event.logicalKey) {
                                                      case LogicalKeyboardKey
                                                          .arrowDown:
                                                        if (mounted) {
                                                          setState(() {
                                                            _actionSelIndex =
                                                                (_actionSelIndex +
                                                                    1) %
                                                                actions.length;
                                                            _scrollToSelectedAction();
                                                          });
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .arrowUp:
                                                        if (mounted) {
                                                          setState(() {
                                                            _actionSelIndex =
                                                                (_actionSelIndex -
                                                                    1 +
                                                                    actions
                                                                        .length) %
                                                                actions.length;
                                                            _scrollToSelectedAction();
                                                          });
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .enter:
                                                      case LogicalKeyboardKey
                                                          .tab:
                                                        (() async {
                                                          await _controller
                                                              .applyWorkspaceEdit(
                                                                _lspActionNotifier
                                                                    .value![_actionSelIndex],
                                                              );
                                                        })();
                                                        _lspActionNotifier
                                                                .value =
                                                            null;
                                                        _lspActionOffsetNotifier
                                                                .value =
                                                            null;
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .escape:
                                                        _lspActionNotifier
                                                                .value =
                                                            null;
                                                        _lspActionOffsetNotifier
                                                                .value =
                                                            null;
                                                        return KeyEventResult
                                                            .handled;
                                                      default:
                                                        break;
                                                    }
                                                  }

                                                  if (isCtrlPressed) {
                                                    switch (event.logicalKey) {
                                                      case LogicalKeyboardKey
                                                          .keyC:
                                                        _controller.copy();
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .keyX:
                                                        if (_readOnly) {
                                                          return KeyEventResult
                                                              .handled;
                                                        }
                                                        _controller.cut();
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .keyV:
                                                        if (_readOnly) {
                                                          return KeyEventResult
                                                              .handled;
                                                        }
                                                        _controller.paste();
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .keyA:
                                                        _controller.selectAll();
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .keyZ:
                                                        if (_readOnly) {
                                                          return KeyEventResult
                                                              .handled;
                                                        }
                                                        if (isShiftPressed) {
                                                          if (_undoRedoController
                                                              .canRedo) {
                                                            _undoRedoController
                                                                .redo();
                                                            _commonKeyFunctions();
                                                          }
                                                        } else if (_undoRedoController
                                                            .canUndo) {
                                                          _undoRedoController
                                                              .undo();
                                                          _commonKeyFunctions();
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .keyY:
                                                        if (_readOnly) {
                                                          return KeyEventResult
                                                              .handled;
                                                        }
                                                        if (_undoRedoController
                                                            .canRedo) {
                                                          _undoRedoController
                                                              .redo();
                                                          _commonKeyFunctions();
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      default:
                                                        break;
                                                    }
                                                  }

                                                  if (isAltPressed &&
                                                      !isCtrlPressed &&
                                                      _isMac) {
                                                    switch (event.logicalKey) {
                                                      case LogicalKeyboardKey
                                                          .arrowLeft:
                                                        if (widget
                                                                .textDirection ==
                                                            TextDirection.rtl) {
                                                          _moveWordRight(
                                                            isShiftPressed,
                                                          );
                                                        } else {
                                                          _moveWordLeft(
                                                            isShiftPressed,
                                                          );
                                                        }
                                                        _commonKeyFunctions();
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .arrowRight:
                                                        if (widget
                                                                .textDirection ==
                                                            TextDirection.rtl) {
                                                          _moveWordLeft(
                                                            isShiftPressed,
                                                          );
                                                        } else {
                                                          _moveWordRight(
                                                            isShiftPressed,
                                                          );
                                                        }
                                                        _commonKeyFunctions();
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .backspace:
                                                        if (!_readOnly) {
                                                          _deleteWordBackward();
                                                          _commonKeyFunctions();
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      case LogicalKeyboardKey
                                                          .delete:
                                                        if (!_readOnly) {
                                                          _deleteWordForward();
                                                          _commonKeyFunctions();
                                                        }
                                                        return KeyEventResult
                                                            .handled;
                                                      default:
                                                        break;
                                                    }
                                                  }

                                                  if (isShiftPressed &&
                                                      !isCtrlPressed &&
                                                      event.logicalKey ==
                                                          LogicalKeyboardKey
                                                              .tab) {
                                                    if (!_readOnly) {
                                                      _controller.unindent();
                                                      _commonKeyFunctions();
                                                    }
                                                    return KeyEventResult
                                                        .handled;
                                                  }

                                                  switch (event.logicalKey) {
                                                    case LogicalKeyboardKey
                                                        .backspace:
                                                      if (_readOnly) {
                                                        return KeyEventResult
                                                            .handled;
                                                      }

                                                      if (_controller
                                                          .hasMultiCursors) {
                                                        _controller
                                                            .backspaceAtAllCursors();
                                                      } else {
                                                        _controller.backspace();
                                                      }

                                                      if (_suggestionNotifier
                                                              .value !=
                                                          null) {
                                                        _suggestionNotifier
                                                                .value =
                                                            null;
                                                      }
                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .delete:
                                                      if (_readOnly) {
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                      if (_controller
                                                          .hasMultiCursors) {
                                                        _controller
                                                            .deleteAtAllCursors();
                                                      } else {
                                                        _controller.delete();
                                                      }
                                                      if (_suggestionNotifier
                                                              .value !=
                                                          null) {
                                                        _suggestionNotifier
                                                                .value =
                                                            null;
                                                      }
                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .arrowDown:
                                                      _controller
                                                          .pressDownArrowKey(
                                                            isShiftPressed:
                                                                isShiftPressed,
                                                          );

                                                      if (_controller
                                                          .hasMultiCursors) {
                                                        _controller
                                                            .moveMultiCursorsDown(
                                                              isShiftPressed:
                                                                  isShiftPressed,
                                                            );
                                                      }

                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .arrowUp:
                                                      _controller
                                                          .pressUpArrowKey(
                                                            isShiftPressed:
                                                                isShiftPressed,
                                                          );

                                                      if (_controller
                                                          .hasMultiCursors) {
                                                        _controller
                                                            .moveMultiCursorsUp(
                                                              isShiftPressed:
                                                                  isShiftPressed,
                                                            );
                                                      }

                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .arrowRight:
                                                      _handleArrowRight(
                                                        isShiftPressed,
                                                      );
                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .arrowLeft:
                                                      _handleArrowLeft(
                                                        isShiftPressed,
                                                      );
                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .home:
                                                      _handleHomeKey(
                                                        isShiftPressed,
                                                      );
                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey.end:
                                                      _handleEndKey(
                                                        isShiftPressed,
                                                      );
                                                      _commonKeyFunctions();
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .escape:
                                                      _hoverTimer?.cancel();
                                                      _lspSignatureNotifier
                                                              .value =
                                                          null;
                                                      _contextMenuOffsetNotifier
                                                          .value = const Offset(
                                                        -1,
                                                        -1,
                                                      );
                                                      _findController.isActive =
                                                          false;
                                                      _findController
                                                              .isReplaceMode =
                                                          false;
                                                      _aiNotifier.value = null;
                                                      _suggestionNotifier
                                                              .value =
                                                          null;
                                                      _hoverNotifier.value =
                                                          null;
                                                      _controller
                                                          .clearMultiCursors();
                                                      setState(() {
                                                        _isSignatureInvoked =
                                                            false;
                                                      });
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey.tab:
                                                      if (_readOnly) {
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                      final ghost =
                                                          _controller.ghostText;
                                                      if (ghost != null &&
                                                          !ghost
                                                              .shouldPersist) {
                                                        _acceptControllerGhostText();
                                                        return KeyEventResult
                                                            .handled;
                                                      }
                                                      if (_aiNotifier.value !=
                                                          null) {
                                                        _acceptGhostText();
                                                      } else if (_suggestionNotifier
                                                              .value ==
                                                          null) {
                                                        _controller.indent();
                                                        _commonKeyFunctions();
                                                      }
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .pageUp:
                                                      _vscrollController
                                                          .animateTo(
                                                            _vscrollController
                                                                    .offset -
                                                                650,
                                                            duration: Duration(
                                                              milliseconds: 300,
                                                            ),
                                                            curve: Curves.ease,
                                                          );
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .pageDown:
                                                      _vscrollController
                                                          .animateTo(
                                                            _vscrollController
                                                                    .offset +
                                                                650,
                                                            duration: Duration(
                                                              milliseconds: 300,
                                                            ),
                                                            curve: Curves.ease,
                                                          );
                                                      return KeyEventResult
                                                          .handled;

                                                    case LogicalKeyboardKey
                                                        .enter:
                                                      if (_aiNotifier.value !=
                                                          null) {
                                                        _aiNotifier.value =
                                                            null;
                                                      }
                                                      break;
                                                    default:
                                                  }
                                                }
                                                return KeyEventResult.ignored;
                                              },
                                              child: _CodeField(
                                                key: _codeFieldKey,
                                                context: context,
                                                controller: _controller,
                                                editorTheme: _editorTheme,
                                                language: _language,
                                                extraLanguages:
                                                    widget.extraLanguages,
                                                languageId: _controller
                                                    .lspConfig
                                                    ?.languageId,
                                                lspConfig:
                                                    _controller.lspConfig,
                                                semanticTokens: _semanticTokens,
                                                semanticTokensVersion:
                                                    _semanticTokensVersion,
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
                                                textStyle: widget.textStyle,
                                                enableFolding:
                                                    widget.enableFolding,
                                                enableGuideLines:
                                                    widget.enableGuideLines,
                                                enableGutter:
                                                    widget.enableGutter,
                                                enableGutterDivider:
                                                    widget.enableGutterDivider,
                                                enableMagnifier:
                                                    widget.enableMagnifier,
                                                gutterStyle: _gutterStyle,
                                                selectionStyle: _selectionStyle,
                                                diagnostics:
                                                    _diagnosticsNotifier.value,
                                                isMobile: _isMobile,
                                                selectionActiveNotifier:
                                                    _selectionActiveNotifier,
                                                contextMenuOffsetNotifier:
                                                    _contextMenuOffsetNotifier,
                                                hoverNotifier: _hoverNotifier,
                                                hoverContentNotifier:
                                                    _hoverContentNotifier,
                                                lineWrap: widget.lineWrap,
                                                offsetNotifier: _offsetNotifier,
                                                aiNotifier: _aiNotifier,
                                                aiOffsetNotifier:
                                                    _aiOffsetNotifier,
                                                isHoveringPopup:
                                                    _isHoveringPopup,
                                                suggestionNotifier:
                                                    _suggestionNotifier,
                                                ghostTextStyle:
                                                    widget.ghostTextStyle,
                                                matchHighlightStyle:
                                                    widget.matchHighlightStyle,
                                                lspActionNotifier:
                                                    _lspActionNotifier,
                                                lspActionOffsetNotifier:
                                                    _lspActionOffsetNotifier,
                                                signatureNotifier:
                                                    _lspSignatureNotifier,
                                                filePath: _filePath,
                                                textDirection:
                                                    widget.textDirection,
                                                onHoverSetByTap: () {
                                                  _hoverSetByTap = true;
                                                },
                                                gutterBuilder:
                                                    widget.gutterBuilder,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildContextMenu(),
                  ValueListenableBuilder(
                    valueListenable: _offsetNotifier,
                    builder: (_, offset, _) {
                      return ValueListenableBuilder(
                        valueListenable: _lspSignatureNotifier,
                        builder: (_, signature, _) {
                          if (signature == null ||
                              signature.activeParameter < 0 ||
                              signature.parameters.isEmpty) {
                            return SizedBox.shrink();
                          }
                          final sigScrollCtrl = ScrollController();

                          final desiredWidth = screenWidth < 700
                              ? screenWidth * 0.63
                              : 420.0;
                          final maxBoxHeight = 400.0;
                          final fontSize = widget.textStyle?.fontSize ?? 14;

                          double adjustedLeft = offset.dx;
                          if (adjustedLeft + desiredWidth > screenWidth) {
                            adjustedLeft = screenWidth - desiredWidth;
                          }
                          if (adjustedLeft < 0) {
                            adjustedLeft = 0;
                          }

                          final spaceBelow =
                              editorHeight - offset.dy - fontSize - 10;
                          final spaceAbove = offset.dy - 10;
                          final shouldPositionAbove =
                              maxBoxHeight > spaceBelow &&
                              spaceAbove > maxBoxHeight;

                          double? adjustedTop;
                          double? adjustedBottom;

                          if (shouldPositionAbove) {
                            adjustedBottom = editorHeight - offset.dy + 10;
                          } else {
                            adjustedTop = offset.dy + fontSize + 10;
                          }

                          return Positioned(
                            width: desiredWidth,
                            top: adjustedTop,
                            bottom: adjustedBottom,
                            left: adjustedLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: desiredWidth,
                                maxHeight: maxBoxHeight,
                                minWidth: 70,
                              ),
                              child: Card(
                                color: _hoverDetailsStyle.backgroundColor,
                                shape: _hoverDetailsStyle.shape,
                                child: RawScrollbar(
                                  interactive: true,
                                  controller: sigScrollCtrl,
                                  thumbVisibility: true,
                                  thumbColor: _editorTheme['root']!.color!
                                      .withAlpha(100),
                                  child: SingleChildScrollView(
                                    controller: sigScrollCtrl,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 7,
                                            left: 6.5,
                                          ),
                                          child: RichText(
                                            text: (() {
                                              final label = signature.label;
                                              final activeParamIndex =
                                                  signature.activeParameter;

                                              if (activeParamIndex < 0 ||
                                                  activeParamIndex >=
                                                      signature
                                                          .parameters
                                                          .length) {
                                                return TextSpan(text: label);
                                              }

                                              final paramLabel = signature
                                                  .parameters[activeParamIndex]['label'];

                                              if (paramLabel is List &&
                                                  paramLabel.length >= 2) {
                                                final range = paramLabel
                                                    .cast<int>();
                                                final firstPart = label
                                                    .substring(0, range[0]);
                                                final highlightPart = label
                                                    .substring(
                                                      range[0],
                                                      range[1],
                                                    );
                                                final finalPart = label
                                                    .substring(range[1]);

                                                return TextSpan(
                                                  style: TextStyle(
                                                    fontSize:
                                                        (widget
                                                                .textStyle
                                                                ?.fontSize ??
                                                            15) +
                                                        1.75,
                                                    color: _editorTheme['root']
                                                        ?.color,
                                                  ),
                                                  children: [
                                                    TextSpan(text: firstPart),
                                                    TextSpan(
                                                      text: highlightPart,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    TextSpan(text: finalPart),
                                                  ],
                                                );
                                              } else if (paramLabel is String) {
                                                final paramText = paramLabel;
                                                final paramIndex = label
                                                    .indexOf(paramText);

                                                if (paramIndex >= 0) {
                                                  final firstPart = label
                                                      .substring(0, paramIndex);
                                                  final highlightPart =
                                                      paramText;
                                                  final finalPart = label
                                                      .substring(
                                                        paramIndex +
                                                            paramText.length,
                                                      );

                                                  return TextSpan(
                                                    style: TextStyle(
                                                      fontSize:
                                                          (widget
                                                                  .textStyle
                                                                  ?.fontSize ??
                                                              15) +
                                                          1.75,
                                                      color:
                                                          _editorTheme['root']
                                                              ?.color,
                                                    ),
                                                    children: [
                                                      TextSpan(text: firstPart),
                                                      TextSpan(
                                                        text: highlightPart,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                      TextSpan(text: finalPart),
                                                    ],
                                                  );
                                                }
                                              }

                                              return TextSpan(
                                                text: label,
                                                style: TextStyle(
                                                  fontSize:
                                                      (widget
                                                              .textStyle
                                                              ?.fontSize ??
                                                          15) +
                                                      1.75,
                                                  color: _editorTheme['root']
                                                      ?.color,
                                                ),
                                              );
                                            })(),
                                          ),
                                        ),
                                        Divider(
                                          color:
                                              signature.documentation.isNotEmpty
                                              ? _editorTheme['root']?.color
                                              : Colors.transparent,
                                          thickness: 0.5,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 6.5,
                                          ),
                                          child: MarkdownBlock(
                                            data: signature.documentation,
                                            config: MarkdownConfig.darkConfig.copy(
                                              configs: [
                                                PConfig(
                                                  textStyle: _hoverDetailsStyle
                                                      .textStyle,
                                                ),
                                                PreConfig(
                                                  language:
                                                      _controller
                                                          .lspConfig
                                                          ?.languageId
                                                          .toLowerCase() ??
                                                      'dart',
                                                  theme: _editorTheme,
                                                  textStyle: TextStyle(
                                                    fontSize: _hoverDetailsStyle
                                                        .textStyle
                                                        .fontSize,
                                                  ),
                                                  styleNotMatched: TextStyle(
                                                    color: _editorTheme['root']!
                                                        .color,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _editorTheme['root']!
                                                        .backgroundColor!,
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                    border: Border.all(
                                                      width: 0.2,
                                                      color:
                                                          _editorTheme['root']!
                                                              .color ??
                                                          Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
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
                  ValueListenableBuilder(
                    valueListenable: _offsetNotifier,
                    builder: (context, offset, child) {
                      if (offset.dy < 0 || offset.dx < 0) {
                        return SizedBox.shrink();
                      }
                      return ValueListenableBuilder(
                        valueListenable: _suggestionNotifier,
                        builder: (_, sugg, child) {
                          if (_aiNotifier.value != null) {
                            return SizedBox.shrink();
                          }
                          if (sugg == null || sugg.isEmpty) {
                            _sugSelIndex = 0;
                            _controller.currentlySelectedSuggestion = null;
                            return SizedBox.shrink();
                          }
                          final completionScrlCtrl = ScrollController();
                          final desiredWidth = screenWidth < 700
                              ? screenWidth * 0.63
                              : screenWidth * 0.3;
                          final suggestionWidth = min(desiredWidth, 400.0);
                          final itemExtent =
                              _suggestionStyle.itemHeight ?? 24.0;
                          final estimatedHeight = min(
                            sugg.length * itemExtent,
                            400.0,
                          );
                          double adjustedLeft = offset.dx;
                          if (adjustedLeft + suggestionWidth > screenWidth) {
                            adjustedLeft = screenWidth - suggestionWidth;
                          }
                          if (adjustedLeft < 0) {
                            adjustedLeft = 0;
                          }
                          final fontSize = widget.textStyle?.fontSize ?? 14;
                          final spaceBelow =
                              editorHeight - offset.dy - fontSize - 10;
                          final spaceAbove = offset.dy - 10;
                          final shouldPositionAbove =
                              estimatedHeight > spaceBelow &&
                              spaceAbove > estimatedHeight;

                          double? adjustedTop;
                          double? adjustedBottom;

                          if (shouldPositionAbove) {
                            adjustedBottom = editorHeight - offset.dy + 10;
                          } else {
                            adjustedTop = offset.dy + fontSize + 10;
                          }

                          return ValueListenableBuilder(
                            valueListenable:
                                _controller.selectedSuggestionNotifier,
                            builder: (context, selected, child) {
                              return Stack(
                                children: [
                                  Positioned(
                                    width: suggestionWidth,
                                    top: adjustedTop,
                                    bottom: adjustedBottom,
                                    left: adjustedLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 400,
                                        maxWidth: 400,
                                        minWidth: 70,
                                      ),
                                      child: Card(
                                        shape: _suggestionStyle.shape,
                                        elevation: _suggestionStyle.elevation,
                                        color: _suggestionStyle.backgroundColor,
                                        margin: EdgeInsets.zero,
                                        child: RawScrollbar(
                                          thumbVisibility: true,
                                          thumbColor: _editorTheme['root']!
                                              .color!
                                              .withAlpha(80),
                                          interactive: true,
                                          controller: _suggScrollController,
                                          child: ListView.builder(
                                            itemExtent:
                                                _suggestionStyle.itemHeight ??
                                                24.0,
                                            controller: _suggScrollController,
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: sugg.length,
                                            itemBuilder: (_, indx) {
                                              final item = sugg[indx];
                                              if ((item is LspCompletion) &&
                                                  (indx == _sugSelIndex ||
                                                      (_isMobile &&
                                                          _isMobileSuggActive))) {
                                                final key =
                                                    _getSuggestionCacheKey(
                                                      item,
                                                    );
                                                if (!_suggestionDetailsCache
                                                        .containsKey(key) &&
                                                    _controller.lspConfig !=
                                                        null) {
                                                  (() async {
                                                    try {
                                                      final data = await _controller
                                                          .lspConfig!
                                                          .resolveCompletionItem(
                                                            item.completionItem,
                                                          );
                                                      final mdText =
                                                          "${data['detail'] ?? ''}\n${(() {
                                                            final doc = data['documentation'];
                                                            if (doc == null) {
                                                              return '';
                                                            }

                                                            if (doc is Map<String, dynamic> && doc.containsKey('value')) {
                                                              return doc['value'];
                                                            }

                                                            return doc;
                                                          })()}";
                                                      if (!mounted) return;
                                                      setState(() {
                                                        final edits =
                                                            data['additionalTextEdits'];
                                                        if (edits is List) {
                                                          try {
                                                            _extraText = edits
                                                                .map(
                                                                  (e) =>
                                                                      Map<
                                                                        String,
                                                                        dynamic
                                                                      >.from(
                                                                        e as Map,
                                                                      ),
                                                                )
                                                                .toList();
                                                          } catch (_) {
                                                            _extraText = edits
                                                                .cast<
                                                                  Map<
                                                                    String,
                                                                    dynamic
                                                                  >
                                                                >();
                                                          }
                                                        } else {
                                                          _extraText = [];
                                                        }
                                                        _suggestionDetailsCache[key] =
                                                            mdText;
                                                        _selectedSuggestionMd =
                                                            mdText;
                                                      });
                                                    } catch (e) {
                                                      debugPrint(
                                                        "Completion Resolve failed: ${e.toString()}",
                                                      );
                                                    }
                                                  })();
                                                } else if (_suggestionDetailsCache
                                                    .containsKey(key)) {
                                                  final cached =
                                                      _suggestionDetailsCache[key];
                                                  if (_selectedSuggestionMd !=
                                                      cached) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          if (!mounted) return;
                                                          setState(() {
                                                            _selectedSuggestionMd =
                                                                cached;
                                                          });
                                                        });
                                                  }
                                                }
                                              } else if ((item
                                                          is! LspCompletion &&
                                                      widget
                                                          .enableLocalSuggestions) &&
                                                  (indx == _sugSelIndex ||
                                                      (_isMobile &&
                                                          _isMobileSuggActive))) {
                                                if (_selectedSuggestionMd !=
                                                    null) {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        if (!mounted) return;
                                                        setState(() {
                                                          _selectedSuggestionMd =
                                                              null;
                                                        });
                                                      });
                                                }
                                              }

                                              return Container(
                                                height:
                                                    _suggestionStyle.itemHeight,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      ((!_isMobile &&
                                                              (indx ==
                                                                  _sugSelIndex)) ||
                                                          _controller
                                                                  .currentlySelectedSuggestion ==
                                                              indx)
                                                      ? (_suggestionStyle
                                                                .selectedBackgroundColor ??
                                                            _suggestionStyle
                                                                .focusColor)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: InkWell(
                                                  canRequestFocus: false,
                                                  hoverColor: _suggestionStyle
                                                      .hoverColor,
                                                  focusColor: _suggestionStyle
                                                      .focusColor,
                                                  splashColor: _suggestionStyle
                                                      .splashColor,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  onTap: () {
                                                    if (mounted) {
                                                      setState(() {
                                                        if (_isMobileSuggActive) {
                                                          _controller
                                                                  .currentlySelectedSuggestion =
                                                              indx;
                                                        } else {
                                                          _sugSelIndex = indx;
                                                        }
                                                        if (item
                                                            is _SnippetSuggestion) {
                                                          _insertSnippetWithCursors(
                                                            item,
                                                          );
                                                          _isInjectingSnippets =
                                                              true;
                                                          _suggestionNotifier
                                                                  .value =
                                                              null;
                                                          _isInjectingSnippets =
                                                              false;
                                                        } else {
                                                          final text =
                                                              item
                                                                  is LspCompletion
                                                              ? item.label
                                                              : item as String;
                                                          _controller
                                                              .insertAtCurrentCursor(
                                                                text,
                                                                replaceTypedChar:
                                                                    true,
                                                              );
                                                          if (_extraText
                                                              .isNotEmpty) {
                                                            _controller
                                                                .applyWorkspaceEdit(
                                                                  _extraText,
                                                                );
                                                          }
                                                          _suggestionNotifier
                                                                  .value =
                                                              null;
                                                        }
                                                        _isSignatureInvoked =
                                                            true;
                                                        _controller
                                                            .callSignatureHelp();
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (item
                                                          is LspCompletion) ...[
                                                        item.icon,
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            item.label,
                                                            style:
                                                                _suggestionStyle.labelTextStyle?.copyWith(
                                                                  color:
                                                                      ((!_isMobile &&
                                                                              (indx ==
                                                                                  _sugSelIndex)) ||
                                                                          _controller.currentlySelectedSuggestion ==
                                                                              indx)
                                                                      ? Colors
                                                                            .white
                                                                      : _suggestionStyle
                                                                            .labelTextStyle
                                                                            ?.color,
                                                                ) ??
                                                                _suggestionStyle.textStyle.copyWith(
                                                                  color:
                                                                      ((!_isMobile &&
                                                                              (indx ==
                                                                                  _sugSelIndex)) ||
                                                                          _controller.currentlySelectedSuggestion ==
                                                                              indx)
                                                                      ? Colors
                                                                            .white
                                                                      : _suggestionStyle
                                                                            .textStyle
                                                                            .color,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        if (item.importUri?[0] !=
                                                            null) ...[
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              item.importUri![0],
                                                              style:
                                                                  _suggestionStyle
                                                                      .detailTextStyle ??
                                                                  _suggestionStyle
                                                                      .textStyle
                                                                      .copyWith(
                                                                        color: _suggestionStyle
                                                                            .textStyle
                                                                            .color
                                                                            ?.withAlpha(
                                                                              150,
                                                                            ),
                                                                      ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                      if (item
                                                          is _SnippetSuggestion) ...[
                                                        Icon(
                                                          completionItemIcons[CompletionItemType
                                                                  .snippet]!
                                                              .icon,
                                                          color:
                                                              completionItemIcons[CompletionItemType
                                                                      .snippet]!
                                                                  .color,
                                                          size:
                                                              _suggestionStyle
                                                                  .iconSize ??
                                                              16.0,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            item.label,
                                                            style:
                                                                (_suggestionStyle
                                                                            .labelTextStyle ??
                                                                        _suggestionStyle
                                                                            .textStyle)
                                                                    .copyWith(
                                                                      color:
                                                                          ((!_isMobile &&
                                                                                  (indx ==
                                                                                      _sugSelIndex)) ||
                                                                              _controller.currentlySelectedSuggestion ==
                                                                                  indx)
                                                                          ? Colors.white
                                                                          : (_suggestionStyle.labelTextStyle ??
                                                                                    _suggestionStyle.textStyle)
                                                                                .color,
                                                                    ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                      if (item is String)
                                                        Expanded(
                                                          child: Text(
                                                            item,
                                                            style:
                                                                _suggestionStyle
                                                                    .labelTextStyle ??
                                                                _suggestionStyle
                                                                    .textStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_selectedSuggestionMd != null &&
                                      _lspSignatureNotifier.value == null)
                                    Positioned(
                                      width: screenWidth < 700
                                          ? screenWidth * 0.63
                                          : null,
                                      top:
                                          offset.dy +
                                          (widget.textStyle?.fontSize ?? 14) +
                                          10 +
                                          (screenWidth < 700
                                              ? (offset.dy <
                                                            (screenWidth / 2) &&
                                                        400 < screenHeight)
                                                    ? (((widget.textStyle?.fontSize ??
                                                                      14) +
                                                                  6.5) *
                                                              (_suggestionNotifier
                                                                      .value
                                                                      ?.length ??
                                                                  0))
                                                          .clamp(0, 400)
                                                    : -100
                                              : 0),
                                      left: screenWidth < 700
                                          ? offset.dx
                                          : ((adjustedLeft +
                                                        suggestionWidth +
                                                        420) >
                                                    screenWidth
                                                ? adjustedLeft - 420 - 10
                                                : adjustedLeft +
                                                      suggestionWidth),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 420,
                                          maxHeight: 400,
                                          minWidth: 70,
                                        ),
                                        child: Card(
                                          color: _hoverDetailsStyle
                                              .backgroundColor,
                                          shape: _hoverDetailsStyle.shape,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              _selectedSuggestionMd!
                                                      .trim()
                                                      .isEmpty
                                                  ? 0
                                                  : 8.0,
                                            ),
                                            child: RawScrollbar(
                                              interactive: true,
                                              controller: completionScrlCtrl,
                                              thumbVisibility: true,
                                              thumbColor: _editorTheme['root']!
                                                  .color!
                                                  .withAlpha(100),
                                              child: SingleChildScrollView(
                                                controller: completionScrlCtrl,
                                                child: MarkdownBlock(
                                                  data: _selectedSuggestionMd!,
                                                  config: MarkdownConfig.darkConfig.copy(
                                                    configs: [
                                                      PConfig(
                                                        textStyle:
                                                            _hoverDetailsStyle
                                                                .textStyle,
                                                      ),
                                                      PreConfig(
                                                        language:
                                                            _controller
                                                                .lspConfig
                                                                ?.languageId
                                                                .toLowerCase() ??
                                                            'dart',
                                                        theme: _editorTheme,
                                                        textStyle: TextStyle(
                                                          fontSize:
                                                              _hoverDetailsStyle
                                                                  .textStyle
                                                                  .fontSize,
                                                        ),
                                                        styleNotMatched: TextStyle(
                                                          color:
                                                              _editorTheme['root']!
                                                                  .color,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _editorTheme['root']!
                                                              .backgroundColor!,
                                                          borderRadius:
                                                              BorderRadius.zero,
                                                          border: Border.all(
                                                            width: 0.2,
                                                            color:
                                                                _editorTheme['root']!
                                                                    .color ??
                                                                Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _hoverNotifier,
                    builder: (_, hov, c) {
                      if (hov == null || _controller.lspConfig == null) {
                        return SizedBox.shrink();
                      }
                      final Offset position = hov.$1;
                      final width = _isMobile
                          ? screenWidth * 0.63
                          : screenWidth * 0.3;
                      final maxHeight = _isMobile ? screenHeight * 0.4 : 550.0;

                      double adjustedLeft = position.dx;
                      if (adjustedLeft + width > screenWidth) {
                        adjustedLeft = screenWidth - width;
                      }
                      if (adjustedLeft < 0) {
                        adjustedLeft = 0;
                      }

                      final spaceBelow = editorHeight - position.dy;
                      final spaceAbove = position.dy - 10;
                      final shouldPositionAbove =
                          maxHeight > spaceBelow && spaceAbove > maxHeight;

                      double? adjustedTop;
                      double? adjustedBottom;

                      if (shouldPositionAbove) {
                        adjustedBottom = editorHeight - position.dy + 10;
                      } else {
                        adjustedTop = position.dy;
                      }

                      return Positioned(
                        top: adjustedTop,
                        bottom: adjustedBottom,
                        left: adjustedLeft,
                        width: width,
                        child: MouseRegion(
                          onEnter: (_) => _isHoveringPopup.value = true,
                          onExit: (_) => _isHoveringPopup.value = false,
                          child: ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: _hoverContentNotifier,
                            builder: (_, data, _) {
                              if (data == null) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width,
                                    maxHeight: maxHeight,
                                  ),
                                  child: Card(
                                    color: _hoverDetailsStyle.backgroundColor,
                                    shape: _hoverDetailsStyle.shape,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Loading...",
                                        style: _hoverDetailsStyle.textStyle,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final diagnosticMessage =
                                  data['diagnostic'] ?? '';
                              final severity = data['severity'] ?? 0;
                              final hoverMessage = data['hover'] ?? '';

                              if (diagnosticMessage.isEmpty &&
                                  hoverMessage.isEmpty) {
                                return SizedBox.shrink();
                              }

                              IconData diagnosticIcon;
                              Color diagnosticColor;

                              switch (severity) {
                                case 1:
                                  diagnosticIcon = Icons.error_outline;
                                  diagnosticColor = Colors.red;
                                  break;
                                case 2:
                                  diagnosticIcon = Icons.warning_amber_outlined;
                                  diagnosticColor = Colors.orange;
                                  break;
                                case 3:
                                  diagnosticIcon = Icons.info_outline;
                                  diagnosticColor = Colors.blue;
                                  break;
                                case 4:
                                  diagnosticIcon = Icons.lightbulb_outline;
                                  diagnosticColor = Colors.grey;
                                  break;
                                default:
                                  diagnosticIcon = Icons.info_outline;
                                  diagnosticColor = Colors.grey;
                              }

                              final hoverScrollController = ScrollController();
                              final errorSCrollController = ScrollController();

                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: width,
                                  maxHeight: maxHeight,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (diagnosticMessage.isNotEmpty)
                                      Card(
                                        surfaceTintColor: diagnosticColor,
                                        color:
                                            _hoverDetailsStyle.backgroundColor,
                                        shape: BeveledRectangleBorder(
                                          side: BorderSide(
                                            color: diagnosticColor,
                                            width: 0.2,
                                          ),
                                        ),
                                        margin: EdgeInsets.only(
                                          bottom: hoverMessage.isNotEmpty
                                              ? 4
                                              : 0,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RawScrollbar(
                                            controller: errorSCrollController,
                                            thumbVisibility: true,
                                            thumbColor: _editorTheme['root']!
                                                .color!
                                                .withAlpha(100),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              controller: errorSCrollController,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    diagnosticIcon,
                                                    color: diagnosticColor,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    diagnosticMessage,
                                                    style: _hoverDetailsStyle
                                                        .textStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    if (hoverMessage.isNotEmpty)
                                      Flexible(
                                        child: Card(
                                          color: _hoverDetailsStyle
                                              .backgroundColor,
                                          shape: _hoverDetailsStyle.shape,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RawScrollbar(
                                              controller: hoverScrollController,
                                              thumbVisibility: true,
                                              thumbColor: _editorTheme['root']!
                                                  .color!
                                                  .withAlpha(100),
                                              child: SingleChildScrollView(
                                                controller:
                                                    hoverScrollController,
                                                child: MarkdownBlock(
                                                  data: hoverMessage,
                                                  config: MarkdownConfig.darkConfig.copy(
                                                    configs: [
                                                      PConfig(
                                                        textStyle:
                                                            _hoverDetailsStyle
                                                                .textStyle,
                                                      ),
                                                      PreConfig(
                                                        language:
                                                            _controller
                                                                .lspConfig
                                                                ?.languageId
                                                                .toLowerCase() ??
                                                            "dart",
                                                        theme: _editorTheme,
                                                        textStyle: TextStyle(
                                                          fontSize:
                                                              _hoverDetailsStyle
                                                                  .textStyle
                                                                  .fontSize,
                                                        ),
                                                        styleNotMatched: TextStyle(
                                                          color:
                                                              _editorTheme['root']!
                                                                  .color,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _editorTheme['root']!
                                                              .backgroundColor!,
                                                          borderRadius:
                                                              BorderRadius.zero,
                                                          border: Border.all(
                                                            width: 0.2,
                                                            color:
                                                                _editorTheme['root']!
                                                                    .color ??
                                                                Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<Offset?>(
                    valueListenable: _aiOffsetNotifier,
                    builder: (context, offvalue, child) {
                      return _isMobile &&
                              _aiNotifier.value != null &&
                              offvalue != null &&
                              _aiNotifier.value!.isNotEmpty
                          ? Positioned(
                              top:
                                  offvalue.dy +
                                  (widget.textStyle?.fontSize ?? 14) *
                                      _aiNotifier.value!.split('\n').length +
                                  15,
                              left:
                                  offvalue.dx +
                                  (_aiNotifier.value!.split('\n')[0].length *
                                      (widget.textStyle?.fontSize ?? 14) /
                                      2),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (_aiNotifier.value == null) return;
                                      _controller.insertAtCurrentCursor(
                                        _aiNotifier.value!,
                                      );
                                      _aiNotifier.value = null;
                                      _aiOffsetNotifier.value = null;
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _editorTheme['root']
                                            ?.backgroundColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        border: BoxBorder.all(
                                          width: 1.5,
                                          color: Color(0xff64b5f6),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: _editorTheme['root']?.color,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  InkWell(
                                    onTap: () {
                                      _aiNotifier.value = null;
                                      _aiOffsetNotifier.value = null;
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _editorTheme['root']
                                            ?.backgroundColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        border: BoxBorder.all(
                                          width: 1.5,
                                          color: Colors.red,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: _editorTheme['root']?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _lspActionOffsetNotifier,
                    builder: (_, offset, child) {
                      if (offset == null ||
                          _lspActionNotifier.value == null ||
                          _controller.lspConfig == null) {
                        return SizedBox.shrink();
                      }

                      return Positioned(
                        width: screenWidth < 700
                            ? screenWidth * 0.63
                            : screenWidth * 0.3,
                        top:
                            offset.dy + (widget.textStyle?.fontSize ?? 14) + 10,
                        left: offset.dx,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 400,
                            maxWidth: 400,
                            minWidth: 70,
                          ),
                          child: Card(
                            shape: _suggestionStyle.shape,
                            elevation: _suggestionStyle.elevation,
                            color: _suggestionStyle.backgroundColor,
                            margin: EdgeInsets.zero,
                            child: RawScrollbar(
                              controller: _actionScrollController,
                              thumbVisibility: true,
                              thumbColor: _editorTheme['root']!.color!
                                  .withAlpha(80),
                              child: ListView.builder(
                                shrinkWrap: true,
                                controller: _actionScrollController,
                                itemExtent: _suggestionStyle.itemHeight ?? 24.0,
                                itemCount: _lspActionNotifier.value!.length,
                                itemBuilder: (_, indx) {
                                  final actionData = _lspActionNotifier.value!
                                      .cast<Map<String, dynamic>>();
                                  return Tooltip(
                                    message: actionData[indx]['title'],
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: indx == _actionSelIndex
                                            ? (_suggestionStyle
                                                      .selectedBackgroundColor ??
                                                  _suggestionStyle.focusColor)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      height: _suggestionStyle.itemHeight,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      child: InkWell(
                                        hoverColor: _suggestionStyle.hoverColor,
                                        splashColor:
                                            _suggestionStyle.splashColor,
                                        borderRadius: BorderRadius.circular(3),
                                        onTap: () {
                                          try {
                                            (() async {
                                              await _controller
                                                  .applyWorkspaceEdit(
                                                    actionData[indx],
                                                  );
                                            })();
                                          } catch (e, st) {
                                            debugPrint(
                                              'Code action failed: $e\n$st',
                                            );
                                          } finally {
                                            _lspActionNotifier.value = null;
                                            _lspActionOffsetNotifier.value =
                                                null;
                                          }
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width:
                                                  _suggestionStyle.iconSize ??
                                                  16,
                                              height:
                                                  _suggestionStyle.iconSize ??
                                                  16,
                                              child: Icon(
                                                Icons.lightbulb_outline,
                                                color: Colors.yellowAccent,
                                                size:
                                                    _suggestionStyle.iconSize ??
                                                    16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                actionData[indx]['title'],
                                                style:
                                                    _suggestionStyle
                                                        .labelTextStyle
                                                        ?.copyWith(
                                                          color:
                                                              indx ==
                                                                  _actionSelIndex
                                                              ? Colors.white
                                                              : _suggestionStyle
                                                                    .labelTextStyle
                                                                    ?.color,
                                                        ) ??
                                                    _suggestionStyle.textStyle
                                                        .copyWith(
                                                          color:
                                                              indx ==
                                                                  _actionSelIndex
                                                              ? Colors.white
                                                              : _suggestionStyle
                                                                    .textStyle
                                                                    .color,
                                                        ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _acceptSuggestion() {
    final suggestions = _suggestionNotifier.value;
    if (suggestions != null && _sugSelIndex < suggestions.length) {
      final selected = suggestions[_sugSelIndex];
      if (selected is _SnippetSuggestion) {
        _insertSnippetWithCursors(selected);
        _isInjectingSnippets = true;
        _suggestionNotifier.value = null;
        _isInjectingSnippets = false;
        _sugSelIndex = 0;
        return;
      }
    }
    _controller.acceptSuggestion(selectedIndex: _sugSelIndex);
    _sugSelIndex = 0;
  }

  void _insertSnippetWithCursors(_SnippetSuggestion snippet) {
    final cursorBefore = _controller.selection.extentOffset;
    final safePos = cursorBefore.clamp(0, _controller.length);
    final prefix = _controller.getCurrentWordPrefixAt(safePos);
    final insertStart = (cursorBefore - prefix.length).clamp(
      0,
      _controller.length,
    );

    final currentLine = _controller.getLineAtOffset(safePos);
    final lineText = _controller.getLineText(currentLine);
    final indentMatch = RegExp(r'^(\s*)').firstMatch(lineText);
    final indent = indentMatch?.group(1) ?? '';
    final String indentedValue;
    final List<int> adjustedLocations;

    if (indent.isEmpty || !snippet.value.contains('\n')) {
      indentedValue = snippet.value;
      adjustedLocations = snippet.cursorLocations.toList();
    } else {
      final buffer = StringBuffer();
      final addedBefore = List<int>.filled(snippet.value.length + 1, 0);
      int totalAdded = 0;

      for (int i = 0; i < snippet.value.length; i++) {
        addedBefore[i] = totalAdded;
        final ch = snippet.value[i];
        buffer.write(ch);
        if (ch == '\n') {
          buffer.write(indent);
          totalAdded += indent.length;
        }
      }
      addedBefore[snippet.value.length] = totalAdded;

      indentedValue = buffer.toString();
      adjustedLocations = snippet.cursorLocations.map((loc) {
        final clampedLoc = loc.clamp(0, snippet.value.length);
        return clampedLoc + addedBefore[clampedLoc];
      }).toList();
    }

    _controller.insertAtCurrentCursor(indentedValue, replaceTypedChar: true);

    if (adjustedLocations.isEmpty) return;

    final primaryOffset = (insertStart + adjustedLocations.first).clamp(
      0,
      _controller.length,
    );
    _controller.setSelectionSilently(
      TextSelection.collapsed(offset: primaryOffset),
    );

    _controller.clearMultiCursors();
    for (int i = 1; i < adjustedLocations.length; i++) {
      final offset = (insertStart + adjustedLocations[i]).clamp(
        0,
        _controller.length,
      );
      final line = _controller.getLineAtOffset(offset);
      final lineStart = _controller.getLineStartOffset(line);
      _controller.addMultiCursor(line, offset - lineStart);
    }
  }

  void _acceptGhostText() {
    final ghostText = _aiNotifier.value;
    if (ghostText == null || ghostText.isEmpty) return;
    _controller.insertAtCurrentCursor(ghostText);
    _aiNotifier.value = null;
    _aiOffsetNotifier.value = null;
  }

  void _acceptControllerGhostText() {
    final ghost = _controller.ghostText;
    if (ghost == null || ghost.text.isEmpty) return;
    _controller.insertAtCurrentCursor(ghost.text);
    _controller.clearGhostText();
  }
}

class _CodeField extends LeafRenderObjectWidget {
  final CodeForgeController controller;
  final Map<String, TextStyle> editorTheme;
  final Mode? language;
  final List<Mode> extraLanguages;
  final String? languageId;
  final LspConfig? lspConfig;
  final List<LspSemanticToken>? semanticTokens;
  final int semanticTokensVersion;
  final EdgeInsets? innerPadding;
  final ScrollController vscrollController, hscrollController;
  final FocusNode focusNode;
  final bool readOnly, isMobile, lineWrap;
  final AnimationController caretBlinkController;
  final AnimationController lineHighlightController;
  final TextStyle? textStyle;
  final bool enableFolding, enableGuideLines, enableGutter, enableGutterDivider;
  final bool enableMagnifier;
  final GutterStyle gutterStyle;
  final CodeSelectionStyle selectionStyle;
  final List<LspErrors> diagnostics;
  final ValueNotifier<bool> selectionActiveNotifier, isHoveringPopup;
  final ValueNotifier<Offset> contextMenuOffsetNotifier, offsetNotifier;
  final ValueNotifier<(Offset, Map<String, int>)?> hoverNotifier;
  final ValueNotifier<Map<String, dynamic>?> hoverContentNotifier;
  final ValueNotifier<List<dynamic>?> lspActionNotifier, suggestionNotifier;
  final ValueNotifier<String?> aiNotifier;
  final ValueNotifier<LspSignatureHelps?> signatureNotifier;
  final ValueNotifier<Offset?> aiOffsetNotifier, lspActionOffsetNotifier;
  final BuildContext context;
  final TextStyle? ghostTextStyle;
  final String? filePath;
  final MatchHighlightStyle? matchHighlightStyle;
  final VoidCallback? onHoverSetByTap;
  final TextDirection textDirection;
  final GutterBuilder? gutterBuilder;

  const _CodeField({
    super.key,
    required this.controller,
    required this.editorTheme,
    required this.language,
    required this.extraLanguages,
    required this.vscrollController,
    required this.hscrollController,
    required this.focusNode,
    required this.readOnly,
    required this.caretBlinkController,
    required this.lineHighlightController,
    required this.enableFolding,
    required this.enableGuideLines,
    required this.enableGutter,
    required this.enableGutterDivider,
    required this.enableMagnifier,
    required this.gutterStyle,
    required this.gutterBuilder,
    required this.selectionStyle,
    required this.diagnostics,
    required this.isMobile,
    required this.selectionActiveNotifier,
    required this.contextMenuOffsetNotifier,
    required this.offsetNotifier,
    required this.hoverNotifier,
    required this.hoverContentNotifier,
    required this.suggestionNotifier,
    required this.aiNotifier,
    required this.signatureNotifier,
    required this.aiOffsetNotifier,
    required this.lspActionNotifier,
    required this.lspActionOffsetNotifier,
    required this.isHoveringPopup,
    required this.context,
    required this.lineWrap,
    this.textDirection = TextDirection.ltr,
    this.filePath,
    this.textStyle,
    this.languageId,
    this.lspConfig,
    this.semanticTokens,
    this.semanticTokensVersion = 0,
    this.innerPadding,
    this.ghostTextStyle,
    this.matchHighlightStyle,
    this.onHoverSetByTap,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CodeFieldRenderer(
      context: context,
      controller: controller,
      editorTheme: editorTheme,
      language: language,
      extraLanguages: extraLanguages,
      languageId: languageId,
      lspConfig: lspConfig,
      innerPadding: innerPadding,
      vscrollController: vscrollController,
      hscrollController: hscrollController,
      focusNode: focusNode,
      readOnly: readOnly,
      caretBlinkController: caretBlinkController,
      lineHighlightController: lineHighlightController,
      textStyle: textStyle,
      matchHighlightStyle: matchHighlightStyle,
      enableFolding: enableFolding,
      enableGuideLines: enableGuideLines,
      enableGutter: enableGutter,
      enableGutterDivider: enableGutterDivider,
      enableMagnifier: enableMagnifier,
      gutterStyle: gutterStyle,
      gutterBuilder: gutterBuilder,
      selectionStyle: selectionStyle,
      diagnostics: diagnostics,
      isMobile: isMobile,
      selectionActiveNotifier: selectionActiveNotifier,
      contextMenuOffsetNotifier: contextMenuOffsetNotifier,
      hoverNotifier: hoverNotifier,
      hoverContentNotifier: hoverContentNotifier,
      lineWrap: lineWrap,
      offsetNotifier: offsetNotifier,
      aiNotifier: aiNotifier,
      aiOffsetNotifier: aiOffsetNotifier,
      isHoveringPopup: isHoveringPopup,
      suggestionNotifier: suggestionNotifier,
      lspActionNotifier: lspActionNotifier,
      lspActionOffsetNotifier: lspActionOffsetNotifier,
      signatureNotifier: signatureNotifier,
      ghostTextStyle: ghostTextStyle,
      filePath: filePath,
      onHoverSetByTap: onHoverSetByTap,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _CodeFieldRenderer renderObject,
  ) {
    if (semanticTokens != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        renderObject.updateSemanticTokens(
          semanticTokens!,
          semanticTokensVersion,
        );
      });
    }
    renderObject
      ..updateDiagnostics(diagnostics)
      ..editorTheme = editorTheme
      ..language = language
      ..extraLanguages = extraLanguages
      ..textStyle = textStyle
      ..innerPadding = innerPadding
      ..readOnly = readOnly
      ..lineWrap = lineWrap
      ..enableFolding = enableFolding
      ..enableGuideLines = enableGuideLines
      ..enableGutter = enableGutter
      ..enableGutterDivider = enableGutterDivider
      ..enableMagnifier = enableMagnifier
      ..gutterStyle = gutterStyle
      ..selectionStyle = selectionStyle
      ..ghostTextStyle = ghostTextStyle
      ..textDirection = textDirection;
  }
}

class _CodeFieldRenderer extends RenderBox implements MouseTrackerAnnotation {
  final CodeForgeController controller;
  final String? languageId, filePath;
  final ScrollController vscrollController, hscrollController;
  final FocusNode focusNode;
  final AnimationController caretBlinkController;
  final AnimationController lineHighlightController;
  final bool isMobile;
  final ValueNotifier<bool> selectionActiveNotifier, isHoveringPopup;
  final ValueNotifier<Offset> contextMenuOffsetNotifier, offsetNotifier;
  final ValueNotifier<(Offset, Map<String, int>)?> hoverNotifier;
  final ValueNotifier<Map<String, dynamic>?> hoverContentNotifier;
  final ValueNotifier<List<dynamic>?> lspActionNotifier, suggestionNotifier;
  final ValueNotifier<Offset?> aiOffsetNotifier, lspActionOffsetNotifier;
  final ValueNotifier<String?> aiNotifier;
  final ValueNotifier<LspSignatureHelps?> signatureNotifier;
  final BuildContext context;
  final LspConfig? lspConfig;
  final VoidCallback? onHoverSetByTap;
  final Map<int, double> _lineWidthCache = {};
  final Map<int, String> _lineTextCache = {};
  final Map<int, Rect> _actionBulbRects = {};
  final Map<Rect, DocumentColor> _colorBoxHitAreas = {};
  final Map<int, ui.Paragraph> _paragraphCache = {};
  final Map<int, double> _lineHeightCache = {};
  ui.Paragraph? _bufferParagraph;
  int? _bufferParagraphLine;
  int _bufferParagraphTextHash = 0;
  double? _bufferParagraphWidth;
  final Map<int, FoldRange?> _foldRanges = {};
  final Map<int, int?> _bracketCache = {};
  final Map<
    int,
    List<({int startLine, int endLine, int indentLevel, double guideX})>
  >
  _indentGuideCache = {};
  final Map<String, int> _indentEndLineCache = {};
  final Map<String, List<ui.TextBox>> _diagnosticPathCache = {};
  final Map<String, List<ui.TextBox>> _searchHighlightCache = {};
  final Map<String, double> _lineOffsetCache = {};
  List<double> _wrappedLineYPrefixSum = const [];
  int _wrappedPrefixSumVersion = 0;
  int _lastBuiltPrefixSumVersion = -1;
  List<double> _visibleLineYPrefixSum = const [];
  int _visiblePrefixSumVersion = 0;
  int _lastBuiltVisiblePrefixSumVersion = -1;
  final Map<
    int,
    ({int lineIndex, int columnIndex, Offset offset, double height})
  >
  _caretInfoCache = {};
  final Map<int, int> _lineIndentCache = {};
  final MatchHighlightStyle? _matchHighlightStyle;
  final MatchHighlightStyle? matchHighlightStyle;
  final _dtap = DoubleTapGestureRecognizer();
  final _onetap = TapGestureRecognizer();
  final GutterBuilder? gutterBuilder;
  late double _gutterPadding;
  late final Paint _caretPainter;
  late final Paint _bracketHighlightPainter;
  late final LayoutMap _layoutMap;
  late double _lineHeight;
  late ui.ParagraphStyle _paragraphStyle;
  late ui.TextStyle _uiTextStyle;
  late SyntaxHighlighter? _syntaxHighlighter;
  late double _gutterWidth;
  TextStyle? _ghostTextStyle;
  Map<String, TextStyle> _editorTheme;
  Mode? _language;
  List<Mode> _extraLanguages;
  EdgeInsets? _innerPadding;
  double _rightPaddingWidth = 0, _bottomPaddingHeight = 0;
  TextStyle? _textStyle;
  GutterStyle _gutterStyle;
  CodeSelectionStyle _selectionStyle;
  List<LspErrors> _diagnostics;
  int _cachedCaretOffset = -1, _cachedCaretLine = 0, _cachedCaretLineStart = 0;
  Rect? _lastImeCaretRect;
  Rect? _lastImeComposingRect;
  Size? _lastImeEditableSize;
  double _imeComposingCaretDx = 0.0;
  double _imeComposingWidth = 0.0;
  int? _dragStartOffset;
  Timer? _selectionTimer, _hoverTimer, _showBubbleTimer;
  Offset? _pointerDownPosition;
  Offset _currentPosition = Offset.zero;
  bool _enableFolding, _enableGuideLines, _enableGutter, _enableGutterDivider;
  bool _enableMagnifier;
  bool _isFoldToggleInProgress = false, _lineWrap;
  bool _foldRangesNeedsClear = false;
  Set<int> _foldedLineIndices = {};
  List<int> _sortedFoldedLines = [];
  bool _hasActiveFoldsCache = false;
  bool _foldedLineCacheDirty = true;
  bool _asyncFoldComputationPending = false;
  Timer? _foldComputeTimer;
  Timer? _semanticTokenTimer;
  bool _selectionActive = false, _isDragging = false;
  bool _shiftClickActive = false;
  int? _shiftBaseOffset;
  bool _longPressSelected = false;
  bool _draggingStartHandle = false, _draggingEndHandle = false;
  bool _showBubble = false, _draggingCHandle = false, _readOnly;
  int? _lastHandleHapticOffset;
  bool _openedLspActionFromBulbTap = false;
  bool _isGutterPointer = false;
  bool _isDeferringLayout = false, _hasCachedHeight = false;
  bool _isCachedHeightExact = false;
  bool _caretSyncAfterLayoutScheduled = false;
  bool _preHighlightInitialized = false;
  bool _indentGuideFirstFramePending = true;
  TextDirection _textDirection;
  Map<int, FoldRange>? _lastLspFoldRanges;
  Rect? _startHandleRect, _endHandleRect, _normalHandle;
  double _longLineWidth = 0.0, _wrapWidth = double.infinity;
  double _cachedRtlContentWidth = 0.0;
  Timer? _resizeTimer, _layoutDebounceTimer;
  Timer? _bracketHighlightResumeTimer;
  int _lastSemanticTokenRequestVersion = -1;
  int _lastSemanticTokenRequestStartLine = -1;
  int _lastSemanticTokenRequestEndLine = -1;
  int _semanticTokenRequestSerial = 0;
  double _cachedTotalHeight = 0.0;
  double _cachedWrapWidthForHeight = double.infinity;
  String? _aiResponse;
  int _lastProcessedLength = -1;
  int _lastProcessedContentVersion = -1;
  TextSelection? _lastSelectionForAi;
  ui.Paragraph? _cachedMagnifiedParagraph;
  int? _cachedMagnifiedLine, _cachedMagnifiedOffset;
  int? _ghostTextAnchorLine, _highlightedLine;
  int _lastAppliedSemanticVersion = -1, _lastDocumentVersion = -1;
  bool _suspendBracketHighlight = false;
  bool _lastCaretVisible = false;
  int _previousLineCount = 0;
  int _ghostTextLineCount = 0, _cachedLineCount = 0;
  int _virtualRemovedTotalLineCount = 0;
  Animation<double>? _lineHighlightAnimation;

  void _pauseBracketHighlightDuringTyping() {
    _suspendBracketHighlight = true;
    _bracketHighlightResumeTimer?.cancel();
    _bracketHighlightResumeTimer = Timer(const Duration(milliseconds: 500), () {
      _suspendBracketHighlight = false;
      markNeedsPaint();
    });
  }

  void updateSemanticTokens(List<LspSemanticToken> tokens, int version) {
    if (version < _lastAppliedSemanticVersion) return;
    _lastAppliedSemanticVersion = version;
    _syntaxHighlighter?.updateSemanticTokens(
      tokens,
      controller.getLineText,
      controller.lineCount,
    );
    _paragraphCache.clear();
    _bracketCache.clear();
    _indentGuideCache.clear();
    _indentEndLineCache.clear();
    _diagnosticPathCache.clear();
    _searchHighlightCache.clear();
    _invalidateWrappedLayoutCache();
    _caretInfoCache.clear();
    _lineIndentCache.clear();
  }

  void _invalidateFoldRanges([int startLine = 0]) {
    if (startLine <= 0) {
      _foldRanges.clear();
    } else {
      final maxFoldKey = _foldRanges.keys.isEmpty
          ? 0
          : _foldRanges.keys.reduce((a, b) => a > b ? a : b);
      for (int i = startLine; i <= maxFoldKey; i++) {
        _foldRanges.remove(i);
      }
    }
    _foldedLineCacheDirty = true;
    if (enableFolding && controller.lineCount > 10000) {
      _scheduleAsyncFoldComputation();
    }
  }

  bool _foldRangesStructurallyEqual(Map<int, FoldRange> newRanges) {
    if (newRanges.length != _foldRanges.length) return false;
    for (final entry in newRanges.entries) {
      final existing = _foldRanges[entry.key];
      if (existing == null) return false;
      if (existing.startIndex != entry.value.startIndex ||
          existing.endIndex != entry.value.endIndex ||
          existing.isFolded != entry.value.isFolded) {
        return false;
      }
    }
    return true;
  }

  void _rebuildFoldedLineCache() {
    _hasActiveFoldsCache = false;

    final lineCount = controller.lineCount;
    final sortedLines = <int>[];
    for (final fold in _foldRanges.values) {
      if (fold != null && fold.isFolded) {
        _hasActiveFoldsCache = true;
        final end = fold.endIndex < lineCount ? fold.endIndex : lineCount - 1;
        for (int i = fold.startIndex + 1; i <= end; i++) {
          sortedLines.add(i);
        }
      }
    }
    sortedLines.sort();
    _sortedFoldedLines = sortedLines;
    _foldedLineIndices = sortedLines.toSet();
    _foldedLineCacheDirty = false;
  }

  void _ensureFoldedLineCacheValid() {
    if (_foldedLineCacheDirty) {
      _rebuildFoldedLineCache();
    }
  }

  bool get _hasActiveFolds {
    _ensureFoldedLineCacheValid();
    return _hasActiveFoldsCache;
  }

  int _countFoldedLinesBefore(int line) {
    final list = _sortedFoldedLines;
    int lo = 0, hi = list.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (list[mid] < line) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  void _scheduleAsyncFoldComputation() {
    if (!enableFolding) return;
    if (controller.lspFoldRanges != null) return;

    _foldComputeTimer?.cancel();
    _foldComputeTimer = Timer(const Duration(milliseconds: 300), () {
      _runAsyncFoldComputation();
    });
  }

  Future<void> _runAsyncFoldComputation() async {
    if (!enableFolding) return;
    if (controller.lspFoldRanges != null) return;

    _asyncFoldComputationPending = true;

    try {
      final computed = await foldsComputeAll(rope: controller.rope.core);

      for (final rustFold in computed) {
        final startLine = rustFold.startLine.toInt();
        final endLine = rustFold.endLine.toInt();
        if (_foldRanges[startLine] == null) {
          final existing = controller.foldings[startLine];
          final fold = FoldRange(startLine, endLine);
          if (existing != null && existing.isFolded) {
            fold.isFolded = true;
            fold.originallyFoldedChildren = existing.originallyFoldedChildren;
          }
          _foldRanges[startLine] = fold;
        }
      }
      _asyncFoldComputationPending = false;
      markNeedsPaint();
    } catch (e) {
      _asyncFoldComputationPending = false;
      debugPrint('Error computing folds in isolate: $e');
    }
  }

  void _checkDocumentVersionAndClearCache() {
    final h = _syntaxHighlighter;
    if (h == null) return;
    final currentDocVersion = h.documentVersion;
    if (currentDocVersion != _lastDocumentVersion) {
      _lastDocumentVersion = currentDocVersion;
      // Line-keyed caches (_paragraphCache, _lineTextCache, _indentGuideCache,
      // _lineIndentCache, _lineHeightCache) are already invalidated by range in
      // _onControllerChange. Only clear caches that are NOT line-keyed or are
      // version-sensitive but cheap to rebuild.
      _lineWidthCache.clear();
      _bracketCache.clear();
      _indentEndLineCache.clear();
      _diagnosticPathCache.clear();
      _searchHighlightCache.clear();
      _invalidateWrappedLayoutCache();
      _caretInfoCache.clear();
    }
  }

  void _scheduleVisibleSemanticTokens(
    int firstVisibleLine,
    int lastVisibleLine,
  ) {
    final config = lspConfig;
    final currentFile = filePath;
    if (config == null || currentFile == null) return;
    if (!config.capabilities.semanticHighlighting) return;
    if (!config.isInitialized || controller.openedFile != currentFile) return;
    if (controller.lineCount <= 0) return;

    final currentVersion = controller.documentVersion;
    final buffer = kSemanticTokenViewportPaddingLines;
    final startLine = (firstVisibleLine - buffer)
        .clamp(0, controller.lineCount - 1)
        .toInt();
    final endLine = (lastVisibleLine + buffer)
        .clamp(0, controller.lineCount - 1)
        .toInt();

    if (_lastSemanticTokenRequestVersion == currentVersion &&
        _lastSemanticTokenRequestStartLine == startLine &&
        _lastSemanticTokenRequestEndLine == endLine) {
      return;
    }

    _lastSemanticTokenRequestVersion = currentVersion;
    _lastSemanticTokenRequestStartLine = startLine;
    _lastSemanticTokenRequestEndLine = endLine;

    _semanticTokenTimer?.cancel();
    final requestSerial = ++_semanticTokenRequestSerial;
    _semanticTokenTimer = Timer(const Duration(milliseconds: 180), () async {
      if (_semanticTokenRequestSerial != requestSerial) return;
      if (controller.documentVersion != currentVersion ||
          controller.openedFile != currentFile ||
          !config.isInitialized) {
        return;
      }

      final endLineText = controller.getLineText(endLine);

      try {
        final tokens = await config.getSemanticTokensRange(
          currentFile,
          startLine: startLine,
          startCharacter: 0,
          endLine: endLine,
          endCharacter: endLineText.length,
        );

        if (_semanticTokenRequestSerial != requestSerial) return;
        if (controller.documentVersion != currentVersion ||
            controller.openedFile != currentFile) {
          return;
        }

        controller.publishSemanticTokens(tokens);
      } catch (e) {
        debugPrint('Error fetching visible semantic tokens: $e');
      }
    });
  }

  void updateDiagnostics(List<LspErrors> diagnostics) {
    if (_diagnostics != diagnostics) {
      _diagnostics = diagnostics;
      markNeedsPaint();
    }
  }

  ui.Paragraph _buildParagraph(String text, {double? width}) {
    final builder = ui.ParagraphBuilder(_paragraphStyle)
      ..pushStyle(_uiTextStyle)
      ..addText(text.isEmpty ? ' ' : text);
    final p = builder.build();
    p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
    return p;
  }

  ui.Paragraph _buildHighlightedParagraph(
    int lineIndex,
    String text, {
    double? width,
  }) {
    final h = _syntaxHighlighter;
    if (h == null) return _buildParagraph(text, width: width);
    final fontSize = textStyle?.fontSize ?? 14.0;
    final fontFamily = textStyle?.fontFamily;
    return h.buildHighlightedParagraph(
      lineIndex,
      text,
      _paragraphStyle,
      fontSize,
      fontFamily,
      width: width,
    );
  }

  _CodeFieldRenderer({
    required this.controller,
    required this.vscrollController,
    required this.hscrollController,
    required this.focusNode,
    required this.caretBlinkController,
    required this.lineHighlightController,
    required this.isMobile,
    required this.selectionActiveNotifier,
    required this.contextMenuOffsetNotifier,
    required this.offsetNotifier,
    required this.hoverNotifier,
    required this.hoverContentNotifier,
    required this.suggestionNotifier,
    required this.lspActionNotifier,
    required this.lspActionOffsetNotifier,
    required this.aiNotifier,
    required this.aiOffsetNotifier,
    required this.signatureNotifier,
    required this.isHoveringPopup,
    required this.context,
    required bool lineWrap,
    required Map<String, TextStyle> editorTheme,
    required Mode? language,
    required List<Mode> extraLanguages,
    required bool readOnly,
    required bool enableFolding,
    required bool enableGuideLines,
    required bool enableGutter,
    required bool enableGutterDivider,
    required bool enableMagnifier,
    required GutterStyle gutterStyle,
    required this.gutterBuilder,
    required CodeSelectionStyle selectionStyle,
    required List<LspErrors> diagnostics,
    this.languageId,
    this.lspConfig,
    this.filePath,
    this.matchHighlightStyle,
    this.onHoverSetByTap,
    EdgeInsets? innerPadding,
    TextStyle? textStyle,
    TextStyle? ghostTextStyle,
    TextDirection textDirection = TextDirection.ltr,
  }) : _editorTheme = editorTheme,
       _language = language,
       _extraLanguages = extraLanguages,
       _readOnly = readOnly,
       _enableGuideLines = enableGuideLines,
       _enableGutter = enableGutter,
       _enableGutterDivider = enableGutterDivider,
       _enableMagnifier = enableMagnifier,
       _selectionStyle = selectionStyle,
       _diagnostics = diagnostics,
       _textStyle = textStyle,
       _ghostTextStyle = ghostTextStyle,
       _textDirection = textDirection,
       _enableFolding = enableFolding,
       _gutterStyle = gutterStyle,
       _lineWrap = lineWrap,
       _innerPadding = innerPadding,
       _matchHighlightStyle = matchHighlightStyle {
    final fontSize = _textStyle?.fontSize ?? 14.0;
    final fontFamily = _textStyle?.fontFamily;
    final color =
        _textStyle?.color ?? _editorTheme['root']?.color ?? Colors.black;
    final lineHeightMultiplier = _textStyle?.height ?? 1.2;

    _lineHeight = fontSize * lineHeightMultiplier;

    _syntaxHighlighter = _language == null
        ? null
        : SyntaxHighlighter(
            language: _language!,
            extraLanguages: _extraLanguages,
            editorTheme: _editorTheme,
            baseTextStyle: _textStyle,
            languageId: languageId,
            getLineText: controller.getLineText,
          );
    _layoutMap = LayoutMap();
    _rebuildLayoutMap();

    _gutterPadding = fontSize;
    if (_enableGutter) {
      if (_gutterStyle.gutterWidth != null) {
        _gutterWidth = gutterStyle.gutterWidth!;
      } else {
        final digits = controller.lineCount.toString().length;
        final digitWidth = digits * _gutterPadding * 0.6;
        final foldIconSpace = enableFolding ? fontSize + 4 : 0;
        _gutterWidth = digitWidth + foldIconSpace + _gutterPadding;
      }
    } else {
      _gutterWidth = 0;
    }
    _cachedLineCount = controller.lineCount;

    _caretPainter = Paint()
      ..color = _selectionStyle.cursorColor ?? color
      ..style = PaintingStyle.fill;

    _bracketHighlightPainter = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    _paragraphStyle = ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeightMultiplier,
      textDirection: _textDirection,
      textAlign: ui.TextAlign.start,
    );
    _uiTextStyle = ui.TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontFamilyFallback: kEmojiFontFallback,
    );

    vscrollController.addListener(() {
      if (suggestionNotifier.value != null && offsetNotifier.value.dy >= 0) {
        offsetNotifier.value = Offset(
          offsetNotifier.value.dx,
          _getCaretInfo().offset.dy - vscrollController.offset,
        );
      }

      if (lspActionOffsetNotifier.value != null) {
        lspActionOffsetNotifier.value = Offset(
          lspActionOffsetNotifier.value!.dx,
          _getCaretInfo().offset.dy - vscrollController.offset,
        );
      }

      if (hoverNotifier.value != null) {
        final lineChar = hoverNotifier.value!.$2;
        final line = lineChar['line']!;
        final hasActiveFolds = _hasActiveFolds;
        final hoveredY = _getLineYOffset(line, hasActiveFolds);
        final screenY =
            hoveredY + (innerPadding?.top ?? 0) - vscrollController.offset;

        hoverNotifier.value = (
          Offset(hoverNotifier.value!.$1.dx, screenY),
          hoverNotifier.value!.$2,
        );
      }

      markNeedsPaint();
    });

    hscrollController.addListener(() {
      if (suggestionNotifier.value != null && offsetNotifier.value.dx >= 0) {
        offsetNotifier.value = Offset(
          _getCaretInfo().offset.dx - _effectiveHScroll,
          offsetNotifier.value.dy,
        );
      }

      if (lspActionOffsetNotifier.value != null) {
        lspActionOffsetNotifier.value = Offset(
          _getCaretInfo().offset.dx - _effectiveHScroll,
          lspActionOffsetNotifier.value!.dy,
        );
      }

      if (hoverNotifier.value != null) {
        final lineChar = hoverNotifier.value!.$2;
        final line = lineChar['line']!;
        final char = lineChar['character']!;
        final lineText = controller.getLineText(line);
        final para =
            _paragraphCache.containsKey(line) &&
                _lineTextCache[line] == lineText
            ? _paragraphCache[line]!
            : _buildParagraph(lineText, width: lineWrap ? _wrapWidth : null);

        double hoveredX = 0.0;
        if (lineText.isNotEmpty) {
          final clampedCol = char.clamp(0, lineText.length);
          final contentWidth =
              size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
          final paragraphWidth = lineWrap
              ? _wrapWidth
              : (isRTL ? max(contentWidth * 3, 10000.0) : null);
          final paragraphOffset = isRTL
              ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
              : 0.0;

          final pos = _getCaretPositionForColumn(
            para,
            lineText,
            clampedCol,
            paragraphOffset,
            contentWidth,
          );
          hoveredX = pos.x;
        }

        final screenX = isRTL
            ? size.width -
                  _gutterWidth -
                  (innerPadding?.right ?? 0) -
                  hoveredX +
                  (lineWrap ? 0 : _effectiveHScroll)
            : hoveredX +
                  _gutterWidth +
                  (innerPadding?.left ?? 0) -
                  (lineWrap ? 0 : _effectiveHScroll);

        hoverNotifier.value = (
          Offset(screenX, hoverNotifier.value!.$1.dy),
          hoverNotifier.value!.$2,
        );
      }

      markNeedsPaint();
    });

    caretBlinkController.addListener(_onCaretBlink);
    controller.addListener(_onControllerChange);

    _lineHighlightAnimation = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: lineHighlightController, curve: Curves.easeOut),
    )..addListener(markNeedsPaint);

    if (enableFolding) {
      controller.setFoldCallbacks(
        toggleFold: _toggleFoldAtLine,
        foldAll: _foldAllRanges,
        unfoldAll: _unfoldAllRanges,
      );
      if (controller.lineCount > 10000 && controller.lspFoldRanges == null) {
        _scheduleAsyncFoldComputation();
      }
    }

    controller.setScrollCallback(_scrollToLine);

    hoverNotifier.addListener(() {
      if (hoverNotifier.value == null) {
        _hoverTimer?.cancel();
      }
    });

    aiNotifier.addListener(() {
      final previousAiResponse = _aiResponse;
      _aiResponse = aiNotifier.value;
      aiOffsetNotifier.value = _getCaretInfo().offset;

      if (_aiResponse != null && _aiResponse!.isNotEmpty) {
        final aiLines = _aiResponse!.split('\n');
        _ghostTextAnchorLine = controller.getLineAtOffset(
          controller.selection.extentOffset.clamp(0, controller.length),
        );
        _ghostTextLineCount = aiLines.length - 1;
      } else if (_aiResponse == null && previousAiResponse != null) {
        _ghostTextAnchorLine = null;
        _ghostTextLineCount = 0;
      }

      markNeedsLayout();
      markNeedsPaint();
    });

    _preHighlightInitialized = false;
    _indentGuideFirstFramePending = true;
  }

  Map<String, TextStyle> get editorTheme => _editorTheme;
  Mode? get language => _language;
  TextStyle? get textStyle => _textStyle;
  EdgeInsets? get innerPadding => _innerPadding;
  bool get readOnly => _readOnly;
  bool get lineWrap => _lineWrap;
  bool get enableFolding => _enableFolding;
  bool get enableGuideLines => _enableGuideLines;
  bool get enableGutter => _enableGutter;
  bool get enableGutterDivider => _enableGutterDivider;
  GutterStyle get gutterStyle => _gutterStyle;
  TextStyle? get ghostTextStyle => _ghostTextStyle;
  set ghostTextStyle(TextStyle? value) {
    if (_ghostTextStyle == value) return;
    _ghostTextStyle = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    final fontSize = _textStyle?.fontSize ?? 14.0;
    final fontFamily = _textStyle?.fontFamily;
    final lineHeightMultiplier = _textStyle?.height ?? 1.2;
    _paragraphStyle = ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeightMultiplier,
      textDirection: _textDirection,
      textAlign: ui.TextAlign.start,
    );
    _paragraphCache.clear();
    _caretInfoCache.clear();
    markNeedsLayout();
    markNeedsPaint();
  }

  bool get isRTL => _textDirection == TextDirection.rtl;

  double get _effectiveHScroll {
    if (!isRTL || lineWrap) return hscrollController.offset;
    if (!hscrollController.hasClients) return 0;
    return -hscrollController.offset;
  }

  CodeSelectionStyle get selectionStyle => _selectionStyle;

  set editorTheme(Map<String, TextStyle> theme) {
    if (identical(theme, _editorTheme)) return;
    _editorTheme = theme;
    try {
      _syntaxHighlighter?.dispose();
    } catch (e) {
      //
    }
    _syntaxHighlighter = _language == null
        ? null
        : SyntaxHighlighter(
            language: _language!,
            extraLanguages: _extraLanguages,
            editorTheme: theme,
            baseTextStyle: textStyle,
            languageId: languageId,
            getLineText: controller.getLineText,
          );
    _preHighlightInitialized = false;
    _paragraphCache.clear();
    _bracketCache.clear();
    markNeedsLayout();
    markNeedsPaint();
  }

  set language(Mode? lang) {
    if (identical(lang, _language)) return;
    _language = lang;
    try {
      _syntaxHighlighter?.dispose();
    } catch (_) {}
    _syntaxHighlighter = lang == null
        ? null
        : SyntaxHighlighter(
            language: lang,
            extraLanguages: _extraLanguages,
            editorTheme: editorTheme,
            baseTextStyle: textStyle,
            languageId: languageId,
            getLineText: controller.getLineText,
          );
    _preHighlightInitialized = false;
    _paragraphCache.clear();
    _bracketCache.clear();
    markNeedsLayout();
    markNeedsPaint();
  }

  set textStyle(TextStyle? style) {
    if (identical(style, _textStyle)) return;
    _textStyle = style;

    final fontSize = style?.fontSize ?? 14.0;
    final fontFamily = style?.fontFamily;
    final color = style?.color ?? _editorTheme['root']?.color ?? Colors.black;
    final lineHeightMultiplier = style?.height ?? 1.2;

    _lineHeight = fontSize * lineHeightMultiplier;
    _paragraphStyle = ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeightMultiplier,
      textDirection: _textDirection,
      textAlign: ui.TextAlign.start,
    );
    _uiTextStyle = ui.TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontFamilyFallback: kEmojiFontFallback,
    );

    _gutterPadding = fontSize;
    if (_enableGutter) {
      if (_gutterStyle.gutterWidth != null) {
        _gutterWidth = _gutterStyle.gutterWidth!;
      } else {
        final digits = controller.lineCount.toString().length;
        final digitWidth = digits * _gutterPadding * 0.6;
        final foldIconSpace = _enableFolding ? fontSize + 4 : 0;
        _gutterWidth = digitWidth + foldIconSpace + _gutterPadding;
      }
    } else {
      _gutterWidth = 0;
    }

    if (_selectionStyle.cursorColor == null) {
      _caretPainter.color = color;
    }
    _bracketHighlightPainter.color = color;

    try {
      _syntaxHighlighter?.dispose();
    } catch (_) {}
    _syntaxHighlighter = _language == null
        ? null
        : SyntaxHighlighter(
            language: _language!,
            extraLanguages: _extraLanguages,
            editorTheme: editorTheme,
            baseTextStyle: style,
            languageId: languageId,
            getLineText: controller.getLineText,
          );
    _preHighlightInitialized = false;

    _paragraphCache.clear();
    _lineWidthCache.clear();
    _lineTextCache.clear();
    _lineHeightCache.clear();
    _bracketCache.clear();
    _indentGuideCache.clear();
    _indentEndLineCache.clear();
    _diagnosticPathCache.clear();
    _searchHighlightCache.clear();
    _invalidateWrappedLayoutCache();
    _caretInfoCache.clear();
    _lineIndentCache.clear();
    _longLineWidth = 0.0;
    _cachedRtlContentWidth = 0.0;
    _hasCachedHeight = false;
    _isCachedHeightExact = false;
    _rebuildLayoutMap();

    markNeedsLayout();
    markNeedsPaint();
  }

  set innerPadding(EdgeInsets? padding) {
    if (identical(padding, _innerPadding)) return;
    _innerPadding = padding;
    _rightPaddingWidth = padding?.right ?? 0;
    _bottomPaddingHeight = padding?.bottom ?? 0;
    markNeedsLayout();
    markNeedsPaint();
  }

  set extraLanguages(List<Mode> value) {
    if (listEquals(value, _extraLanguages)) return;
    _extraLanguages = value;
    try {
      _syntaxHighlighter?.dispose();
    } catch (_) {}
    _syntaxHighlighter = _language == null
        ? null
        : SyntaxHighlighter(
            language: _language!,
            extraLanguages: _extraLanguages,
            editorTheme: editorTheme,
            baseTextStyle: textStyle,
            languageId: languageId,
            getLineText: controller.getLineText,
          );
    _preHighlightInitialized = false;
    _paragraphCache.clear();
    _bracketCache.clear();
    markNeedsLayout();
    markNeedsPaint();
  }

  set readOnly(bool value) {
    if (_readOnly == value) return;
    _readOnly = value;
    markNeedsPaint();
  }

  set lineWrap(bool value) {
    if (_lineWrap == value) return;
    _lineWrap = value;
    _paragraphCache.clear();
    _lineHeightCache.clear();
    _bracketCache.clear();
    _indentGuideCache.clear();
    _indentEndLineCache.clear();
    _diagnosticPathCache.clear();
    _searchHighlightCache.clear();
    _invalidateWrappedLayoutCache();
    _caretInfoCache.clear();
    _lineIndentCache.clear();
    _hasCachedHeight = false;
    _isCachedHeightExact = false;
    _cachedWrapWidthForHeight = double.infinity;
    if (!_lineWrap) {
      _rebuildLayoutMap();
    }
    markNeedsLayout();
    markNeedsPaint();
  }

  set enableFolding(bool value) {
    if (_enableFolding == value) return;
    _enableFolding = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  set enableGuideLines(bool value) {
    if (_enableGuideLines == value) return;
    _enableGuideLines = value;
    markNeedsPaint();
  }

  set enableGutter(bool value) {
    if (_enableGutter == value) return;
    _enableGutter = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  set enableGutterDivider(bool value) {
    if (_enableGutterDivider == value) return;
    _enableGutterDivider = value;
    markNeedsPaint();
  }

  set enableMagnifier(bool value) {
    if (_enableMagnifier == value) return;
    _enableMagnifier = value;
    markNeedsPaint();
  }

  set gutterStyle(GutterStyle style) {
    if (identical(style, _gutterStyle)) return;
    _gutterStyle = style;
    markNeedsPaint();
  }

  set selectionStyle(CodeSelectionStyle style) {
    if (identical(style, _selectionStyle)) return;
    _selectionStyle = style;
    _caretPainter.color = style.cursorColor ?? _editorTheme['root']!.color!;
    markNeedsPaint();
  }

  void _ensureCaretVisible() {
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;

    final caretInfo = _getCaretInfo();
    final caretX = isRTL
        ? size.width -
              _gutterWidth -
              (innerPadding?.right ?? 0) -
              caretInfo.offset.dx
        : caretInfo.offset.dx + _gutterWidth + (innerPadding?.left ?? 0);
    final caretY = caretInfo.offset.dy + (innerPadding?.top ?? 0);
    final caretHeight = caretInfo.height;
    final vScrollOffset = vscrollController.offset;
    final hScrollOffset = _effectiveHScroll;
    final viewportHeight =
        vscrollController.position.viewportDimension - _bottomPaddingHeight;
    final viewportWidth =
        hscrollController.position.viewportDimension - _rightPaddingWidth;
    final relX = isRTL
        ? (viewportWidth - caretX + hScrollOffset).clamp(0.0, viewportWidth)
        : (caretX - hScrollOffset).clamp(0.0, viewportWidth);
    final relY = (caretY - vScrollOffset).clamp(0.0, viewportHeight);

    offsetNotifier.value = Offset(relX, relY);

    if (caretY >= 0 && caretY <= vScrollOffset + (innerPadding?.top ?? 0)) {
      final targetOffset = caretY - (innerPadding?.top ?? 0);
      vscrollController.jumpTo(
        targetOffset.clamp(0, vscrollController.position.maxScrollExtent),
      );
    } else if (caretY + caretHeight > vScrollOffset + viewportHeight) {
      final targetOffset = caretY + caretHeight - viewportHeight;
      vscrollController.jumpTo(
        targetOffset.clamp(0, vscrollController.position.maxScrollExtent),
      );
    }

    if (isRTL) {
      final maxScroll = hscrollController.position.maxScrollExtent;
      final effectiveScroll = _effectiveHScroll * (isRTL ? -1 : 1);

      if (caretX > effectiveScroll + viewportWidth - _gutterWidth) {
        final targetEffective = caretX - viewportWidth + _gutterWidth;
        final rawOffset = -targetEffective;
        hscrollController.jumpTo(rawOffset.clamp(0, maxScroll));
      } else if (caretX - 1.5 < effectiveScroll) {
        final targetEffective = caretX - 1.5;
        final rawOffset = -targetEffective;
        hscrollController.jumpTo(rawOffset.clamp(0, maxScroll));
      }
    } else {
      if (caretX < hScrollOffset + (innerPadding?.left ?? 0) + _gutterWidth) {
        final targetOffset = caretX - (innerPadding?.left ?? 0) - _gutterWidth;
        hscrollController.jumpTo(
          targetOffset.clamp(0, hscrollController.position.maxScrollExtent),
        );
      } else if (caretX + 1.5 > hScrollOffset + viewportWidth) {
        final targetOffset = caretX + 1.5 - viewportWidth;
        hscrollController.jumpTo(
          targetOffset.clamp(0, hscrollController.position.maxScrollExtent),
        );
      }
    }
  }

  void _deferLayout({required int lineDelta}) {
    _layoutDebounceTimer?.cancel();

    if (lineDelta.abs() <= 4) {
      _isDeferringLayout = false;
      markNeedsLayout();
      markNeedsPaint();
      _scheduleCaretSyncAfterLayout();
      return;
    }

    _isDeferringLayout = true;

    if (_hasCachedHeight) {
      if (_lineWrap) {
        _hasCachedHeight = false;
        _isCachedHeightExact = false;
      } else {
        final lineDelta = _cachedLineCount - _previousLineCount;
        _cachedTotalHeight += lineDelta * _lineHeight;
        _isCachedHeightExact = false;
      }
    }
    _previousLineCount = _cachedLineCount;

    if (!_isFoldToggleInProgress) {
      _ensureCaretVisible();
    }
    markNeedsPaint();

    _layoutDebounceTimer = Timer(const Duration(milliseconds: 24), () {
      _isDeferringLayout = false;
      markNeedsLayout();
      _scheduleCaretSyncAfterLayout();
    });
  }

  void _scheduleCaretSyncAfterLayout() {
    if (_caretSyncAfterLayoutScheduled || _isFoldToggleInProgress) return;
    _caretSyncAfterLayoutScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caretSyncAfterLayoutScheduled = false;
      if (!attached) return;
      if (!vscrollController.hasClients || !hscrollController.hasClients) {
        return;
      }
      _ensureCaretVisible();
    });
  }

  void _onCaretBlink() {
    final caretVisible = focusNode.hasFocus && caretBlinkController.value > 0.5;
    if (caretVisible != _lastCaretVisible) {
      _lastCaretVisible = caretVisible;
      markNeedsPaint();
    }
  }

  void _onControllerChange() {
    if (controller.lspFoldRanges != _lastLspFoldRanges) {
      _lastLspFoldRanges = controller.lspFoldRanges;

      if (controller.lspFoldRanges != null) {
        final newLspRanges = controller.lspFoldRanges!;

        if (_foldRangesStructurallyEqual(newLspRanges)) {
          //
        } else {
          final preservedFoldRanges = <int, FoldRange>{};

          for (final entry in newLspRanges.entries) {
            final lineIndex = entry.key;
            final newFold = entry.value;

            if (!newFold.isFolded) {
              FoldRange? existingFold =
                  _foldRanges[lineIndex] ?? controller.foldings[lineIndex];

              if (existingFold != null && existingFold.isFolded) {
                newFold.isFolded = true;
                newFold.originallyFoldedChildren =
                    existingFold.originallyFoldedChildren;
              } else {
                for (
                  int offset = 1;
                  offset <= 3 && existingFold == null;
                  offset++
                ) {
                  existingFold =
                      _foldRanges[lineIndex - offset] ??
                      _foldRanges[lineIndex + offset] ??
                      controller.foldings[lineIndex - offset] ??
                      controller.foldings[lineIndex + offset];
                  if (existingFold != null && existingFold.isFolded) {
                    final oldRange =
                        existingFold.endIndex - existingFold.startIndex;
                    final newRange = newFold.endIndex - newFold.startIndex;
                    final diff = (oldRange - newRange).abs();
                    if (diff <= (oldRange * 0.3)) {
                      newFold.isFolded = true;
                      newFold.originallyFoldedChildren =
                          existingFold.originallyFoldedChildren;
                    } else {
                      existingFold = null;
                    }
                  } else {
                    existingFold = null;
                  }
                }
              }
            }

            preservedFoldRanges[lineIndex] = newFold;
          }

          _foldRanges.clear();
          _foldRanges.addAll(preservedFoldRanges);

          controller.foldings = {
            for (var f in _foldRanges.values.where(
              (f) => f != null && f.isFolded,
            ))
              f!.startIndex: f,
          };
          _foldedLineCacheDirty = true;
          _invalidateWrappedLayoutCache();
          _hasCachedHeight = false;
          markNeedsLayout();
          markNeedsPaint();
        }
      } else if (!controller.lspFoldRangesWereAdjusted) {
        _invalidateFoldRanges();
      }
    }

    if (controller.searchHighlightsChanged) {
      controller.searchHighlightsChanged = false;
      markNeedsPaint();
      return;
    }

    if (controller.multiCursorsChanged) {
      controller.multiCursorsChanged = false;
      markNeedsPaint();
      return;
    }

    if (controller.inlayHintsChanged) {
      controller.inlayHintsChanged = false;
      markNeedsPaint();
      return;
    }

    if (controller.documentColorsChanged) {
      controller.documentColorsChanged = false;
      _caretInfoCache.clear();
      markNeedsPaint();
      return;
    }

    if (controller.documentHighlightsChanged) {
      controller.documentHighlightsChanged = false;
      markNeedsPaint();
      return;
    }

    if (controller.decorationsChanged) {
      controller.decorationsChanged = false;
      final ghost = controller.ghostText;
      if (ghost != null && ghost.text.isNotEmpty) {
        _ghostTextAnchorLine = ghost.line;
        final ghostLines = ghost.text.split('\n');
        _ghostTextLineCount = ghostLines.length - 1;
      } else if (_aiResponse == null) {
        _ghostTextAnchorLine = null;
        _ghostTextLineCount = 0;
      }
      _virtualRemovedTotalLineCount = 0;
      for (final block in controller.virtualRemovedBlocks) {
        _virtualRemovedTotalLineCount += block.lineCount;
      }
      markNeedsLayout();
      markNeedsPaint();
      return;
    }

    if (controller.imeCompositionChanged) {
      controller.imeCompositionChanged = false;
      _caretInfoCache.clear();
      if (!_isFoldToggleInProgress) {
        _ensureCaretVisible();
      }
      if (controller.contentVersion == _lastProcessedContentVersion) {
        markNeedsPaint();
        return;
      }
      controller.selectionOnly = false;
      controller.bufferNeedsRepaint = false;
    }

    if (controller.selectionOnly) {
      controller.selectionOnly = false;
      if (!_isFoldToggleInProgress) {
        _ensureCaretVisible();
      }

      if (isMobile && controller.selection.isCollapsed) {
        _showBubble = true;
      }

      if (controller.selection.isCollapsed && controller.lspConfig != null) {
        final offset = controller.selection.baseOffset;
        if (_isOffsetOverWord(offset)) {
          final lineChar = _offsetToLineChar(offset);
          controller.scheduleDocumentHighlightsRefresh(
            lineChar['line']!,
            lineChar['character']!,
          );
        } else {
          controller.clearDocumentHighlights();
        }
      }

      markNeedsPaint();
      return;
    }

    if (controller.bufferNeedsRepaint) {
      controller.bufferNeedsRepaint = false;
      if (!_isFoldToggleInProgress) {
        _ensureCaretVisible();
      }
      markNeedsPaint();
      return;
    }

    final currentContentVersion = controller.contentVersion;
    if (currentContentVersion == _lastProcessedContentVersion) {
      return;
    }

    if (_showBubble && isMobile) {
      _showBubble = false;
    }

    final isFirstCall = _lastProcessedLength < 0;
    final textChanged = !isFirstCall;

    if (textChanged) {
      _caretInfoCache.clear();
      _cachedCaretOffset = -1;
      _pauseBracketHighlightDuringTyping();
    }

    final newTextLength = controller.length;
    final dirtyRange = controller.dirtyRegion;
    String insertedText = '';
    String deletedText = '';
    int editLine = 0;

    if (dirtyRange != null) {
      final safeEnd = dirtyRange.end.clamp(dirtyRange.start, newTextLength);
      insertedText = controller.substring(dirtyRange.start, safeEnd);
      final delta = newTextLength - _lastProcessedLength;
      final removedLength = max(insertedText.length - delta, 0);
      final oldEnd = dirtyRange.start + removedLength;
      deletedText = controller.lastDeletedText;
      editLine = controller.getLineAtOffset(dirtyRange.start);

      _syntaxHighlighter?.applyDocumentEdit(
        editLine,
        dirtyRange.start,
        oldEnd,
        insertedText,
        deletedText,
      );

      _bracketCache.removeWhere((pos, _) => pos >= dirtyRange.start);
      _indentEndLineCache.clear();
      _diagnosticPathCache.clear();
      _searchHighlightCache.clear();
      _caretInfoCache.clear();
    }

    final newLineCount = controller.lineCount;
    final lineCountChanged = newLineCount != _cachedLineCount;

    final affectedLine = controller.dirtyLine;
    if (affectedLine != null) {
      _lineWidthCache.remove(affectedLine);
      _lineTextCache.remove(affectedLine);
      _paragraphCache.remove(affectedLine);
      _lineHeightCache.remove(affectedLine);
      _lineIndentCache.remove(affectedLine);
    }
    controller.clearDirtyRegion();

    if (lineCountChanged) {
      final lineDelta = newLineCount - _cachedLineCount;
      final insertionLine =
          affectedLine ??
          controller.getLineAtOffset(
            controller.selection.extentOffset.clamp(0, controller.length),
          );

      _cachedLineCount = newLineCount;
      _invalidateWrappedLayoutCache();
      _caretInfoCache.clear();
      _cachedCaretOffset = -1;

      final startInvalidation = insertionLine > 0 ? insertionLine - 1 : 0;

      final insertedLineBreaks = '\n'.allMatches(insertedText).length;
      final deletedLineBreaks = '\n'.allMatches(deletedText).length;
      final affectedLines = max(
        max(insertedLineBreaks, deletedLineBreaks),
        lineDelta.abs(),
      );
      final invalidateEnd = insertionLine + affectedLines;
      for (int i = insertionLine; i <= invalidateEnd; i++) {
        _lineTextCache.remove(i);
        _lineWidthCache.remove(i);
        _paragraphCache.remove(i);
        _lineHeightCache.remove(i);
        _lineIndentCache.remove(i);
      }

      final shiftStart = invalidateEnd + 1;
      _shiftLineKeyedCache(_lineTextCache, shiftStart, lineDelta);
      _shiftLineKeyedCache(_lineWidthCache, shiftStart, lineDelta);
      _shiftLineKeyedCache(_paragraphCache, shiftStart, lineDelta);
      _shiftLineKeyedCache(_lineHeightCache, shiftStart, lineDelta);
      _shiftLineKeyedCache(_lineIndentCache, shiftStart, lineDelta);

      _indentGuideCache.clear();
      _indentEndLineCache.clear();
      _diagnosticPathCache.clear();
      _searchHighlightCache.clear();
      _bracketCache.clear();

      if (enableGutter && gutterStyle.gutterWidth == null) {
        final fontSize = textStyle?.fontSize ?? 14.0;
        final digits = newLineCount.toString().length;
        final digitWidth = digits * _gutterPadding * 0.6;
        final foldIconSpace = enableFolding ? fontSize + 4 : 0;
        _gutterWidth = digitWidth + foldIconSpace + _gutterPadding;
      }

      if (enableFolding) {
        final editLine = insertionLine;
        final sourceFoldRanges = controller.lineStructureChanged
            ? controller.foldings
            : _foldRanges;

        final adjustedFoldRanges = <int, FoldRange?>{};
        final adjustedControllerFoldings = <int, FoldRange?>{};

        for (final entry in sourceFoldRanges.entries) {
          final oldStartIndex = entry.key;
          final fold = entry.value;
          if (fold == null) continue;

          if (fold.endIndex < editLine) {
            adjustedFoldRanges[oldStartIndex] = fold;
            if (fold.isFolded) {
              adjustedControllerFoldings[oldStartIndex] = fold;
            }
          } else if (fold.startIndex == editLine) {
            final newStartIndex = fold.startIndex + lineDelta;
            final newEndIndex = fold.endIndex + lineDelta;
            if (newStartIndex >= 0 && newEndIndex >= newStartIndex) {
              final newFold = FoldRange(newStartIndex, newEndIndex);
              newFold.isFolded = fold.isFolded;
              newFold.originallyFoldedChildren = fold.originallyFoldedChildren;
              adjustedFoldRanges[newStartIndex] = newFold;
              if (newFold.isFolded) {
                adjustedControllerFoldings[newStartIndex] = newFold;
              }
            }
          } else if (fold.startIndex < editLine && fold.endIndex >= editLine) {
            final newEndIndex = fold.endIndex + lineDelta;
            if (newEndIndex >= oldStartIndex) {
              final newFold = FoldRange(oldStartIndex, newEndIndex);
              newFold.isFolded = fold.isFolded;
              newFold.originallyFoldedChildren = fold.originallyFoldedChildren;
              adjustedFoldRanges[oldStartIndex] = newFold;
              if (newFold.isFolded) {
                adjustedControllerFoldings[oldStartIndex] = newFold;
              }
            }
          } else if (fold.startIndex > editLine) {
            final newStartIndex = fold.startIndex + lineDelta;
            final newEndIndex = fold.endIndex + lineDelta;
            if (newStartIndex >= 0 && newEndIndex >= newStartIndex) {
              final newFold = FoldRange(newStartIndex, newEndIndex);
              newFold.isFolded = fold.isFolded;
              newFold.originallyFoldedChildren = fold.originallyFoldedChildren;
              adjustedFoldRanges[newStartIndex] = newFold;
              if (newFold.isFolded) {
                adjustedControllerFoldings[newStartIndex] = newFold;
              }
            }
          }
        }

        _foldRanges.clear();
        _foldRanges.addAll(adjustedFoldRanges);
        _foldRangesNeedsClear = false;
        _foldedLineCacheDirty = true;
        _invalidateWrappedLayoutCache();
        controller.foldings = adjustedControllerFoldings;
        controller.adjustLspFoldRangesForLineChange(editLine, lineDelta);
      } else {
        _invalidateFoldRanges(startInvalidation);
      }

      _deferLayout(lineDelta: lineDelta);

      if (lineDelta.abs() > 500) {
        _rebuildLayoutMap();
      } else {
        if (lineDelta > 0) {
          _updateLayoutMapLine(insertionLine);
          for (int i = 1; i <= lineDelta; i++) {
            final lineIdx = insertionLine + i;
            final isFolded = controller.foldings.values.any(
              (f) =>
                  f != null &&
                  f.isFolded &&
                  lineIdx > f.startIndex &&
                  lineIdx <= f.endIndex,
            );
            _layoutMap.insertLine(
              lineIdx: BigInt.from(lineIdx),
              lenChars: BigInt.from(controller.getLineText(lineIdx).length),
              height: _lineHeight,
              isFolded: isFolded,
            );
          }
        } else if (lineDelta < 0) {
          for (int i = 0; i < -lineDelta; i++) {
            _layoutMap.removeLine(lineIdx: BigInt.from(insertionLine + 1));
          }
          _updateLayoutMapLine(insertionLine);
        }
      }
    } else if (affectedLine != null) {
      _foldRanges.remove(affectedLine);
      _foldedLineCacheDirty = true;

      final newLineWidth = _getLineWidth(affectedLine);
      final currentContentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      if (newLineWidth > currentContentWidth || newLineWidth > _longLineWidth) {
        _longLineWidth = newLineWidth;
        markNeedsLayout();
      } else {
        markNeedsPaint();
      }
      _updateLayoutMapLine(affectedLine);
    } else {
      markNeedsPaint();
    }

    final cursorPosition = controller.selection.extentOffset.clamp(
      0,
      controller.length,
    );

    final selectionChanged = _lastSelectionForAi != controller.selection;

    if (!textChanged &&
        _aiResponse != null &&
        _aiResponse!.isNotEmpty &&
        selectionChanged) {
      aiNotifier.value = null;
      aiOffsetNotifier.value = null;
      _ghostTextAnchorLine = null;
      _ghostTextLineCount = 0;
    }

    final ghost = controller.ghostText;
    if (!textChanged &&
        ghost != null &&
        !ghost.shouldPersist &&
        selectionChanged) {
      controller.clearGhostText();
    }
    _lastSelectionForAi = controller.selection;

    if (_aiResponse != null && _aiResponse!.isNotEmpty) {
      final textLengthDiff = newTextLength - _lastProcessedLength;

      if (textLengthDiff > 0 && cursorPosition >= textLengthDiff) {
        final newlyTypedChars = controller.substring(
          cursorPosition - textLengthDiff,
          cursorPosition,
        );

        if (_aiResponse!.startsWith(newlyTypedChars)) {
          _aiResponse = _aiResponse!.substring(newlyTypedChars.length);
          if (_aiResponse!.isEmpty) {
            aiNotifier.value = null;
            aiOffsetNotifier.value = null;
            _ghostTextAnchorLine = null;
            _ghostTextLineCount = 0;
          } else {
            aiNotifier.value = _aiResponse;
            final aiLines = _aiResponse!.split('\n');
            _ghostTextLineCount = aiLines.length - 1;
          }
        } else {
          _aiResponse = null;
          aiNotifier.value = null;
          aiOffsetNotifier.value = null;
          _ghostTextAnchorLine = null;
          _ghostTextLineCount = 0;
        }
      } else if (textLengthDiff < 0) {
        _aiResponse = null;
        aiNotifier.value = null;
        aiOffsetNotifier.value = null;
        _ghostTextAnchorLine = null;
        _ghostTextLineCount = 0;
      }
    }

    final ctrlGhost = controller.ghostText;
    if (ctrlGhost != null && !ctrlGhost.shouldPersist) {
      final textLengthDiff = newTextLength - _lastProcessedLength;

      if (textLengthDiff > 0 && cursorPosition >= textLengthDiff) {
        final newlyTypedChars = controller.substring(
          cursorPosition - textLengthDiff,
          cursorPosition,
        );

        if (ctrlGhost.text.startsWith(newlyTypedChars)) {
          final remainingText = ctrlGhost.text.substring(
            newlyTypedChars.length,
          );
          if (remainingText.isEmpty) {
            controller.clearGhostText();
          } else {
            controller.setGhostText(
              GhostText(
                line: ctrlGhost.line,
                column: ctrlGhost.column + newlyTypedChars.length,
                text: remainingText,
                style: ctrlGhost.style,
                shouldPersist: false,
              ),
            );
          }
        } else {
          controller.clearGhostText();
        }
      } else if (textLengthDiff < 0) {
        controller.clearGhostText();
      }
    }

    if (focusNode.hasFocus &&
        !_isFoldToggleInProgress &&
        (textChanged || selectionChanged)) {
      _ensureCaretVisible();
    }

    _lastProcessedLength = newTextLength;
    _lastProcessedContentVersion = currentContentVersion;
  }

  void _rebuildLayoutMap() {
    _layoutMap.clear();
    final lineCount = controller.lineCount;
    final Set<int> foldedLines = {};
    for (final f in controller.foldings.values) {
      if (f != null && f.isFolded) {
        final end = f.endIndex < lineCount ? f.endIndex : lineCount - 1;
        for (int j = f.startIndex + 1; j <= end; j++) {
          foldedLines.add(j);
        }
      }
    }

    if (lineCount == 0) return;

    final lines = controller.getLinesRange(0, lineCount - 1);
    for (int i = 0; i < lines.length; i++) {
      _layoutMap.pushLine(
        lenChars: BigInt.from(lines[i].length),
        height: _lineHeight,
        isFolded: foldedLines.contains(i),
      );
    }
  }

  void _updateLayoutMapLine(int line) {
    if (line < 0) return;
    final lineCount = controller.lineCount;
    if (line >= lineCount) return;
    final isFolded = controller.foldings.values.any(
      (f) =>
          f != null && f.isFolded && line > f.startIndex && line <= f.endIndex,
    );
    _layoutMap.updateLine(
      lineIdx: BigInt.from(line),
      lenChars: BigInt.from(controller.getLineText(line).length),
      height: _lineHeight,
      isFolded: isFolded,
    );
  }

  FoldRange? _computeFoldRangeForLine(int lineIndex) {
    const openers = {'{', '[', '('};
    const closerToOpener = {'}': '{', ']': '[', ')': '('};
    if (!enableFolding) return null;

    final line = controller.getLineText(lineIndex);

    if (!openers.any(line.contains) && !line.trim().endsWith(':')) {
      return null;
    }

    final Map<String, List<_BracketEntry>> stacks = {'{': [], '[': [], '(': []};
    bool foundForLineIndex = false;

    final maxScan = controller.lineCount <= 10000
        ? controller.lineCount
        : min(lineIndex + 10000, controller.lineCount);
    for (int i = lineIndex; i < maxScan; i++) {
      final checkLine = controller.getLineText(i);
      for (int c = 0; c < checkLine.length; c++) {
        final ch = checkLine[c];
        if (openers.contains(ch)) {
          stacks[ch]!.add(_BracketEntry(ch, i));
        } else if (closerToOpener.containsKey(ch)) {
          final opener = closerToOpener[ch]!;
          final stack = stacks[opener]!;
          if (stack.isNotEmpty) {
            final entry = stack.removeLast();
            final start = entry.line;
            final end = i;
            if (end > start) {
              _foldRanges.putIfAbsent(start, () => FoldRange(start, end));
              if (start == lineIndex) {
                foundForLineIndex = true;
              }
            }
          }
        }
      }

      if (foundForLineIndex &&
          !stacks.values.any((s) => s.any((e) => e.line == lineIndex))) {
        return _foldRanges[lineIndex];
      }
    }

    if (_foldRanges.containsKey(lineIndex)) {
      final cachedFold = _foldRanges[lineIndex];
      if (cachedFold != null && line.trim().endsWith(':')) {
        final exactFold = _computeIndentFoldRangeForLine(lineIndex, line);
        if (exactFold != null && exactFold.endIndex < cachedFold.endIndex) {
          _foldRanges[lineIndex] = exactFold;
          return exactFold;
        }
      }
      return _foldRanges[lineIndex];
    }

    final colonFold = _computeIndentFoldRangeForLine(lineIndex, line);
    if (colonFold != null) {
      return colonFold;
    }

    final openingTagName = _extractOpeningTagName(line);
    if (openingTagName != null) {
      final matchLine = _findMatchingClosingTagLine(openingTagName, lineIndex);
      if (matchLine != null && matchLine > lineIndex) {
        return FoldRange(lineIndex, matchLine);
      }
    }

    return null;
  }

  int _measureLeadingIndentColumns(String lineText) {
    final tabSize = controller.tabSize;
    int columns = 0;

    for (int i = 0; i < lineText.length; i++) {
      final ch = lineText[i];
      if (ch == ' ') {
        columns += 1;
      } else if (ch == '\t') {
        final nextStop = tabSize <= 0
            ? columns + 1
            : columns + (tabSize - (columns % tabSize));
        columns = nextStop;
      } else {
        break;
      }
    }

    return columns;
  }

  FoldRange? _computeIndentFoldRangeForLine(int lineIndex, String line) {
    if (!line.trim().endsWith(':')) return null;

    final startIndent = _measureLeadingIndentColumns(line);
    int endLine = lineIndex;

    final maxIndentScan = min(lineIndex + 5000, controller.lineCount);
    for (int j = lineIndex + 1; j < maxIndentScan; j++) {
      final next = controller.getLineText(j);
      if (next.trim().isEmpty) continue;
      final nextIndent = _measureLeadingIndentColumns(next);

      if (nextIndent < startIndent) {
        break;
      }

      if (nextIndent == startIndent) {
        break;
      }
      endLine = j;
    }

    if (endLine > lineIndex) {
      final fold = FoldRange(lineIndex, endLine);
      _foldRanges[lineIndex] = fold;
      return fold;
    }

    return null;
  }

  FoldRange? _getOrComputeFoldRange(int lineIndex) {
    if (_foldRangesNeedsClear) {
      _invalidateFoldRanges();
      _foldRangesNeedsClear = false;
    }

    if (_foldRanges.containsKey(lineIndex)) {
      return _foldRanges[lineIndex];
    }

    final lspFoldRanges = controller.lspFoldRanges;
    if (lspFoldRanges != null && lspFoldRanges.containsKey(lineIndex)) {
      final fold = lspFoldRanges[lineIndex];
      _foldRanges[lineIndex] = fold;
      return fold;
    }

    if (controller.lineCount <= 10000) {
      final fold = _computeFoldRangeForLine(lineIndex);
      _foldRanges[lineIndex] = fold;
      return fold;
    }

    if (!_asyncFoldComputationPending) {
      _scheduleAsyncFoldComputation();
    }
    return null;
  }

  void _toggleFold(FoldRange fold) {
    try {
      _isFoldToggleInProgress = true;
      if (fold.isFolded) {
        _unfoldWithChildren(fold);
      } else {
        _foldWithChildren(fold);
      }

      controller.foldings = {
        for (var f in _foldRanges.values.where((f) => f != null))
          f!.startIndex: f,
      };
      _rebuildLayoutMap();
      _foldedLineCacheDirty = true;
      _invalidateWrappedLayoutCache();
      _caretInfoCache.clear();
      _cachedCaretOffset = -1;
      _paragraphCache.clear();
      _lineTextCache.clear();
      _hasCachedHeight = false;
      markNeedsLayout();
      markNeedsPaint();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isFoldToggleInProgress = false;
        _clampScrollAfterFold();
      });
    } catch (e) {
      debugPrint('Error toggling fold: $e');
      _isFoldToggleInProgress = false;
    }
  }

  void _toggleFoldAtLine(int lineNumber) {
    if (!enableFolding) return;
    if (lineNumber < 0 || lineNumber >= controller.lineCount) return;

    final foldRange = _getFoldRangeAtLine(lineNumber);
    if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
      _toggleFold(foldRange);
    }
  }

  void _foldAllRanges() {
    if (!enableFolding) return;
    _isFoldToggleInProgress = true;

    if (controller.lineCount <= 10000) {
      for (int i = 0; i < controller.lineCount; i++) {
        _getOrComputeFoldRange(i);
      }
    } else if (_foldRanges.isEmpty && controller.lspFoldRanges == null) {
      _isFoldToggleInProgress = false;
      _runAsyncFoldComputation().then((_) {
        if (!enableFolding) return;
        _isFoldToggleInProgress = true;
        _applyFoldAll();
      });
      return;
    }

    _applyFoldAll();
  }

  void _applyFoldAll() {
    for (final fold in _foldRanges.values.where((f) => f != null)) {
      if (!fold!.isFolded) {
        final isNested = _foldRanges.values.any(
          (other) =>
              other != fold &&
              other!.startIndex < fold.startIndex &&
              other.endIndex >= fold.endIndex,
        );
        if (!isNested) {
          _foldWithChildren(fold);
        }
      }
    }

    controller.foldings = {
      for (var f in _foldRanges.values.where((f) => f != null))
        f!.startIndex: f,
    };
    _rebuildLayoutMap();
    _foldedLineCacheDirty = true;
    _invalidateWrappedLayoutCache();
    _caretInfoCache.clear();
    _cachedCaretOffset = -1;
    _paragraphCache.clear();
    _lineTextCache.clear();
    _hasCachedHeight = false;
    markNeedsLayout();
    markNeedsPaint();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isFoldToggleInProgress = false;
      _clampScrollAfterFold();
    });
  }

  void _unfoldAllRanges() {
    if (!enableFolding) return;
    _isFoldToggleInProgress = true;

    for (final fold in _foldRanges.values.where((f) => f != null)) {
      if (fold!.isFolded) {
        fold.isFolded = false;
        fold.clearOriginallyFoldedChildren();
      }
    }

    controller.foldings = {
      for (var f in _foldRanges.values.where((f) => f != null))
        f!.startIndex: f,
    };
    _rebuildLayoutMap();
    _foldedLineCacheDirty = true;
    _invalidateWrappedLayoutCache();
    _caretInfoCache.clear();
    _cachedCaretOffset = -1;
    _paragraphCache.clear();
    _lineTextCache.clear();
    _hasCachedHeight = false;
    markNeedsLayout();
    markNeedsPaint();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isFoldToggleInProgress = false;
      _clampScrollAfterFold();
    });
  }

  void _clampScrollAfterFold() {
    if (!vscrollController.hasClients) return;
    final maxExtent = vscrollController.position.maxScrollExtent;
    if (vscrollController.offset > maxExtent) {
      vscrollController.jumpTo(maxExtent.clamp(0.0, double.infinity));
    }
  }

  void _scrollToLine(int line) {
    if (line < 0 || line >= controller.lineCount) return;

    for (final fold in _foldRanges.values.where((f) => f != null)) {
      if (fold!.isFolded && line > fold.startIndex && line <= fold.endIndex) {
        _unfoldWithChildren(fold);
        controller.foldings = {
          for (var f in _foldRanges.values.where((f) => f != null))
            f!.startIndex: f,
        };
        _rebuildLayoutMap();
        _foldedLineCacheDirty = true;
        _invalidateWrappedLayoutCache();
        _hasCachedHeight = false;
        markNeedsLayout();
        break;
      }
    }

    final hasActiveFolds = _hasActiveFolds;
    final targetY = _getLineYOffset(line, hasActiveFolds);
    final targetLineHeight = lineWrap
        ? _getWrappedLineHeight(line)
        : _lineHeight;
    final topPadding = innerPadding?.top ?? 0;
    final bottomPadding = innerPadding?.bottom ?? 0;
    final viewportHeight = vscrollController.position.viewportDimension;
    final visibleHeight = max(0.0, viewportHeight - topPadding - bottomPadding);
    final centerHeight = visibleHeight > 0 ? visibleHeight : viewportHeight;
    final maxScroll = vscrollController.position.maxScrollExtent;
    double scrollTarget = targetY + (targetLineHeight / 2) - (centerHeight / 2);

    scrollTarget = scrollTarget.clamp(0.0, maxScroll);

    vscrollController
        .animateTo(
          scrollTarget,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _highlightedLine = line;
          lineHighlightController.forward(from: 0.0);
        });
  }

  void _foldWithChildren(FoldRange parentFold) {
    parentFold.clearOriginallyFoldedChildren();

    for (final childFold in _foldRanges.values.where((f) => f != null)) {
      if (childFold!.isFolded &&
          childFold != parentFold &&
          childFold.startIndex > parentFold.startIndex &&
          childFold.endIndex <= parentFold.endIndex) {
        parentFold.addOriginallyFoldedChild(childFold);
        childFold.isFolded = false;
      }
    }

    parentFold.isFolded = true;
  }

  void _unfoldWithChildren(FoldRange parentFold) {
    parentFold.isFolded = false;
    for (final childFold in parentFold.originallyFoldedChildren) {
      if (childFold.startIndex > parentFold.startIndex &&
          childFold.endIndex <= parentFold.endIndex) {
        childFold.isFolded = true;
      }
    }
    parentFold.clearOriginallyFoldedChildren();
  }

  bool _isLineFolded(int lineIndex) {
    _ensureFoldedLineCacheValid();
    return _foldedLineIndices.contains(lineIndex);
  }

  int? _findMatchingBracket(int pos) {
    if (_bracketCache.containsKey(pos)) {
      return _bracketCache[pos];
    }

    if (pos < 0 || pos >= controller.rope.length) {
      _bracketCache[pos] = null;
      return null;
    }

    final match = foldsFindMatchingBracket(
      rope: controller.rope.core,
      targetOffset: pos,
    );

    final result = match == -1 ? null : match;

    _bracketCache[pos] = result;
    return result;
  }

  String? _extractOpeningTagName(String lineText) {
    final trimmed = lineText.trimRight();
    final openTagMatch = RegExp(
      r'<([A-Za-z][A-Za-z0-9:_-]*)(?:\s[^>]*)?>$',
    ).firstMatch(trimmed);
    if (openTagMatch != null) {
      final tagName = openTagMatch.group(1);
      if (!trimmed.endsWith('/>') && !trimmed.endsWith('-->')) {
        return tagName;
      }
    }
    return null;
  }

  bool _shouldShortenGuideToPreviousLine(String lineText) {
    final trimmed = lineText.trimRight();
    if (trimmed.endsWith('{') ||
        trimmed.endsWith('(') ||
        trimmed.endsWith('[')) {
      return true;
    }

    return _extractOpeningTagName(trimmed) != null;
  }

  int? _findMatchingClosingTagLine(String tagName, int startLine) {
    final closeTagPattern = RegExp(r'</' + RegExp.escape(tagName) + r'\s*>');
    int depth = 1;

    final maxScan = controller.lineCount <= 10000
        ? controller.lineCount
        : min(startLine + 10000, controller.lineCount);
    for (int i = startLine + 1; i < maxScan; i++) {
      String lineText;
      if (_lineTextCache.containsKey(i)) {
        lineText = _lineTextCache[i]!;
      } else {
        lineText = controller.getLineText(i);
        _lineTextCache[i] = lineText;
      }

      final openMatches = RegExp(
        r'<' + RegExp.escape(tagName) + r'(?:\s[^>]*)?>',
      ).allMatches(lineText);
      for (final match in openMatches) {
        final fullMatch = match.group(0)!;
        if (!fullMatch.endsWith('/>')) {
          depth++;
        }
      }

      final closeMatches = closeTagPattern.allMatches(lineText);
      for (final _ in closeMatches) {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }

    return null;
  }

  (int?, int?) _getBracketPairAtCursor() {
    if (_suspendBracketHighlight) return (null, null);

    final cursorOffset = controller.selection.extentOffset;
    final textLength = controller.length;
    const bracketChars = '{}[]()';
    const openingBracketChars = '{[(';

    if (cursorOffset < 0 || textLength == 0) return (null, null);

    if (cursorOffset > 0 && cursorOffset <= textLength) {
      final before = controller.rope.substring(cursorOffset - 1, cursorOffset);
      if (bracketChars.contains(before)) {
        final match = _findMatchingBracket(cursorOffset - 1);
        if (match != null) {
          return (cursorOffset - 1, match);
        }
      }
    }

    if (cursorOffset >= 0 && cursorOffset < textLength) {
      final after = controller.rope.substring(cursorOffset, cursorOffset + 1);
      if (openingBracketChars.contains(after)) {
        final match = _findMatchingBracket(cursorOffset);
        if (match != null) {
          return (cursorOffset, match);
        }
      }
    }

    return (null, null);
  }

  FoldRange? _getFoldRangeAtLine(int lineIndex) {
    if (!enableFolding) return null;
    return _getOrComputeFoldRange(lineIndex);
  }

  int _findVisibleLineByYPosition(double y) {
    final lineCount = controller.lineCount;
    if (lineCount == 0) return 0;

    final hasActiveFolds = _hasActiveFolds;
    final hasVirtualBlocks = _virtualRemovedTotalLineCount > 0;

    if (!lineWrap && !hasActiveFolds && !hasVirtualBlocks) {
      return (y / _lineHeight).floor().clamp(0, lineCount - 1);
    }

    _ensureVisibleLinePrefixSum();
    final sum = _visibleLineYPrefixSum;
    if (sum.length <= 1) return 0;

    int lo = 0, hi = sum.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sum[mid] <= y) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return (lo - 1).clamp(0, lineCount - 1);
  }

  ({double x, double yInLine}) _getCaretPositionForColumn(
    ui.Paragraph para,
    String lineText,
    int clampedCol,
    double paragraphOffset,
    double contentWidth,
  ) {
    if (lineText.isEmpty) {
      return (x: isRTL ? contentWidth : 0.0, yInLine: 0.0);
    }

    ui.GlyphInfo? glyphInfo;
    if (clampedCol < lineText.length) {
      glyphInfo = para.getGlyphInfoAt(clampedCol);
    } else if (clampedCol > 0) {
      glyphInfo = para.getGlyphInfoAt(clampedCol - 1);
    }

    if (glyphInfo != null) {
      final range = glyphInfo.graphemeClusterCodeUnitRange;
      final start = range.start.clamp(0, lineText.length).toInt();
      final end = range.end.clamp(start, lineText.length).toInt();
      final useTrailingEdge =
          clampedCol >= end ||
          (clampedCol > start && (clampedCol - start) * 2 >= end - start);
      final bounds = glyphInfo.graphemeClusterLayoutBounds;
      final x = glyphInfo.writingDirection == TextDirection.rtl
          ? (useTrailingEdge ? bounds.left : bounds.right)
          : (useTrailingEdge ? bounds.right : bounds.left);
      return (x: x + paragraphOffset, yInLine: bounds.top);
    }

    if (isRTL) {
      if (clampedCol < lineText.length) {
        final boxes = para.getBoxesForRange(clampedCol, clampedCol + 1);
        if (boxes.isNotEmpty) {
          return (
            x: boxes.first.right + paragraphOffset,
            yInLine: _rowTopForBox(boxes.first),
          );
        }
      } else {
        final boxes = para.getBoxesForRange(clampedCol - 1, clampedCol);
        if (boxes.isNotEmpty) {
          return (
            x: boxes.last.left + paragraphOffset,
            yInLine: _rowTopForBox(boxes.last),
          );
        }
      }
    }

    if (!isRTL && clampedCol < lineText.length) {
      final boxes = para.getBoxesForRange(clampedCol, clampedCol + 1);
      if (boxes.isNotEmpty) {
        return (x: boxes.first.left, yInLine: _rowTopForBox(boxes.first));
      }
    } else if (!isRTL) {
      final boxes = para.getBoxesForRange(clampedCol - 1, clampedCol);
      if (boxes.isNotEmpty) {
        return (x: boxes.last.right, yInLine: _rowTopForBox(boxes.last));
      }
    }

    return (x: 0.0, yInLine: 0.0);
  }

  /// Snaps a raw UTF-16 index to a valid Grapheme Cluster boundary in [s].
  ///
  /// If [index] falls inside a Grapheme Cluster (such as a flag emoji,
  /// ZWJ sequence, or combined character), this snaps to the start
  /// of the cluster if [snapBack] is true, or to the end of the cluster
  /// if [snapBack] is false.
  static int _safeUtf16Bound(String s, int index, {bool snapBack = true}) {
    final len = s.length;
    if (index <= 0) return 0;
    if (index >= len) return len;

    int currentUtf16Offset = 0;
    for (final char in s.characters) {
      final charLen = char.length;
      final clusterStart = currentUtf16Offset;
      final clusterEnd = currentUtf16Offset + charLen;

      if (index > clusterStart && index < clusterEnd) {
        return snapBack ? clusterStart : clusterEnd;
      }

      if (clusterEnd >= index) break;
      currentUtf16Offset = clusterEnd;
    }
    return index;
  }

  int _snapUtf16PositionToGraphemeBoundary(
    ui.Paragraph para,
    Offset position,
    int utf16Offset,
    int textLength,
  ) {
    final glyphInfo = para.getClosestGlyphInfoForOffset(position);
    if (glyphInfo == null) return utf16Offset;

    final range = glyphInfo.graphemeClusterCodeUnitRange;
    final start = range.start.clamp(0, textLength).toInt();
    final end = range.end.clamp(start, textLength).toInt();
    if (utf16Offset <= start || utf16Offset >= end || start == end) {
      return utf16Offset;
    }

    final bounds = glyphInfo.graphemeClusterLayoutBounds;
    final midpoint = (bounds.left + bounds.right) / 2;
    final useTrailingEdge = glyphInfo.writingDirection == TextDirection.rtl
        ? position.dx <= midpoint
        : position.dx >= midpoint;
    return useTrailingEdge ? end : start;
  }

  String _effectiveLineText(int line) {
    final buffered = controller.bufferLineText;
    if (controller.isBufferActive &&
        line == controller.bufferLineIndex &&
        buffered != null) {
      return buffered;
    }
    return controller.getLineText(line);
  }

  ({int lineIndex, int columnIndex, Offset offset, double height})
  _getCaretInfo() {
    final cursorOffset = controller.selection.extentOffset;

    final lineCount = controller.lineCount;
    if (lineCount == 0) {
      final result = (
        lineIndex: 0,
        columnIndex: 0,
        offset: Offset.zero,
        height: _lineHeight,
      );
      _caretInfoCache[cursorOffset] = result;
      return result;
    }

    final hasActiveFolds = _hasActiveFolds;

    if (!isRTL && _caretInfoCache.containsKey(cursorOffset)) {
      return _caretInfoCache[cursorOffset]!;
    }

    int lineIndex;
    int lineStartOffset;
    if (cursorOffset == _cachedCaretOffset) {
      lineIndex = _cachedCaretLine;
      lineStartOffset = _cachedCaretLineStart;
    } else {
      lineIndex = controller.getLineAtOffset(cursorOffset);
      lineStartOffset = controller.getLineStartOffset(lineIndex);
      if (lineIndex > 0) {
        final prevChar = cursorOffset > 0
            ? controller.rope.charAt(cursorOffset - 1)
            : '';
        final shouldMoveUp =
            cursorOffset < lineStartOffset ||
            (cursorOffset == lineStartOffset &&
                prevChar != '\n' &&
                controller.findLineEnd(cursorOffset - 1) == cursorOffset - 1);
        if (shouldMoveUp) {
          lineIndex -= 1;
          lineStartOffset = controller.getLineStartOffset(lineIndex);
        }
      }
      _cachedCaretOffset = cursorOffset;
      _cachedCaretLine = lineIndex;
      _cachedCaretLineStart = lineStartOffset;
    }

    final columnIndex = cursorOffset - lineStartOffset;
    final lineY = _getLineYOffset(lineIndex, hasActiveFolds);
    final lineText = _effectiveLineText(lineIndex);
    final contentWidth =
        size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    final paragraphWidth = lineWrap
        ? _wrapWidth
        : (isRTL ? max(contentWidth * 3, 10000.0) : null);

    ui.Paragraph para;
    if (_bufferParagraphLine == lineIndex &&
        _bufferParagraphTextHash == lineText.hashCode &&
        _bufferParagraphWidth == paragraphWidth) {
      para = _bufferParagraph!;
    } else if (_paragraphCache.containsKey(lineIndex) &&
        _lineTextCache[lineIndex] == lineText &&
        !isRTL) {
      para = _paragraphCache[lineIndex]!;
    } else {
      para = _buildHighlightedParagraph(
        lineIndex,
        lineText,
        width: paragraphWidth,
      );
    }

    final utf16Col = CodeForgeController.scalarToStringIndex(
      lineText,
      columnIndex,
    );
    final clampedCol = utf16Col.clamp(0, lineText.length);
    final paragraphOffset = isRTL
        ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
        : 0.0;

    final pos = _getCaretPositionForColumn(
      para,
      lineText,
      clampedCol,
      paragraphOffset,
      contentWidth,
    );
    double caretX = pos.x;
    double caretYInLine = pos.yInLine;

    final colorBoxOffset = _getColorBoxOffsetForLine(lineIndex, clampedCol);
    caretX += colorBoxOffset;

    final ghostOffset = _getTotalVirtualOffset(lineIndex);

    final result = (
      lineIndex: lineIndex,
      columnIndex: columnIndex,
      offset: Offset(caretX, lineY + caretYInLine + ghostOffset),
      height: _lineHeight,
    );
    _caretInfoCache[cursorOffset] = result;
    return result;
  }

  ({int lineIndex, int columnIndex, Offset offset, double height})
  _getCaretInfoAtOffset(int cursorOffset) {
    if (_caretInfoCache.containsKey(cursorOffset)) {
      return _caretInfoCache[cursorOffset]!;
    }

    final lineCount = controller.lineCount;
    if (lineCount == 0) {
      return (
        lineIndex: 0,
        columnIndex: 0,
        offset: Offset.zero,
        height: _lineHeight,
      );
    }

    final hasActiveFolds = _hasActiveFolds;
    var lineIndex = controller.getLineAtOffset(cursorOffset);
    var lineStartOffset = controller.getLineStartOffset(lineIndex);
    if (lineIndex > 0) {
      final prevChar = cursorOffset > 0
          ? controller.rope.charAt(cursorOffset - 1)
          : '';
      final shouldMoveUp =
          cursorOffset < lineStartOffset ||
          (cursorOffset == lineStartOffset &&
              prevChar != '\n' &&
              controller.findLineEnd(cursorOffset - 1) == cursorOffset - 1);
      if (shouldMoveUp) {
        lineIndex -= 1;
        lineStartOffset = controller.getLineStartOffset(lineIndex);
      }
    }
    final columnIndex = cursorOffset - lineStartOffset;
    final lineY = _getLineYOffset(lineIndex, hasActiveFolds);
    final lineText = _effectiveLineText(lineIndex);
    final contentWidth =
        size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    final paragraphWidth = lineWrap
        ? _wrapWidth
        : (isRTL ? max(contentWidth * 3, 10000.0) : null);

    ui.Paragraph para;
    if (_bufferParagraphLine == lineIndex &&
        _bufferParagraphTextHash == lineText.hashCode &&
        _bufferParagraphWidth == paragraphWidth) {
      para = _bufferParagraph!;
    } else if (_paragraphCache.containsKey(lineIndex) &&
        _lineTextCache[lineIndex] == lineText &&
        !isRTL) {
      para = _paragraphCache[lineIndex]!;
    } else {
      para = _buildHighlightedParagraph(
        lineIndex,
        lineText,
        width: paragraphWidth,
      );
    }

    final utf16Col = CodeForgeController.scalarToUtf16Offset(
      lineText,
      columnIndex,
    );
    final clampedCol = utf16Col.clamp(0, lineText.length);
    final paragraphOffset = isRTL
        ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
        : 0.0;

    final pos = _getCaretPositionForColumn(
      para,
      lineText,
      clampedCol,
      paragraphOffset,
      contentWidth,
    );
    double caretX = pos.x;
    double caretYInLine = pos.yInLine;

    final colorBoxOffset = _getColorBoxOffsetForLine(lineIndex, clampedCol);
    caretX += colorBoxOffset;

    final ghostOffset = _getTotalVirtualOffset(lineIndex);

    final result = (
      lineIndex: lineIndex,
      columnIndex: columnIndex,
      offset: Offset(caretX, lineY + caretYInLine + ghostOffset),
      height: _lineHeight,
    );
    _caretInfoCache[cursorOffset] = result;
    return result;
  }

  double _getColorBoxOffsetForLine(int line, int column) {
    final colors = controller.documentColors;
    if (colors.isEmpty) return 0;

    final fontSize = textStyle?.fontSize ?? 14.0;
    final colorBoxSize = fontSize * 0.85;
    final colorBoxSpacing = 4.0;
    final totalColorWidth = colorBoxSize + colorBoxSpacing;

    double offset = 0;
    for (final docColor in colors) {
      if (docColor.line == line && docColor.startColumn < column) {
        offset += totalColorWidth;
      }
    }
    return offset;
  }

  int _getTextOffsetFromPosition(Offset position) {
    final lineCount = controller.lineCount;
    if (lineCount == 0) return 0;

    final tappedLineIndex = _findVisibleLineByYPosition(position.dy);

    final lineText = controller.getLineText(tappedLineIndex);

    final contentWidth =
        size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    final paragraphWidth = lineWrap
        ? _wrapWidth
        : (isRTL ? max(contentWidth * 3, 10000.0) : null);

    ui.Paragraph para;
    if (_paragraphCache.containsKey(tappedLineIndex) &&
        _lineTextCache[tappedLineIndex] == lineText &&
        !isRTL) {
      para = _paragraphCache[tappedLineIndex]!;
    } else {
      para = _buildHighlightedParagraph(
        tappedLineIndex,
        lineText,
        width: paragraphWidth,
      );
      if (!isRTL) {
        _lineTextCache[tappedLineIndex] = lineText;
        _paragraphCache[tappedLineIndex] = para;
      }
    }

    double localX = position.dx.clamp(0.0, double.infinity);

    if (isRTL && !lineWrap && paragraphWidth != null) {
      final contentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final paragraphOffset = contentWidth - paragraphWidth;
      localX = localX - paragraphOffset;
    }

    final colors =
        controller.documentColors
            .where((c) => c.line == tappedLineIndex)
            .toList()
          ..sort((a, b) => a.startColumn.compareTo(b.startColumn));

    if (colors.isNotEmpty) {
      final fontSize = textStyle?.fontSize ?? 14.0;
      final colorBoxSize = fontSize * 0.85;
      final colorBoxSpacing = 4.0;
      final totalColorWidth = colorBoxSize + colorBoxSpacing;

      double totalAdjustment = 0;
      for (final docColor in colors) {
        final textX =
            para
                .getBoxesForRange(
                  0,
                  docColor.startColumn.clamp(0, lineText.length),
                )
                .lastOrNull
                ?.right ??
            0;

        final colorBoxStartX = textX + totalAdjustment;
        final colorBoxEndX = colorBoxStartX + totalColorWidth;

        if (localX > colorBoxEndX) {
          totalAdjustment += totalColorWidth;
        } else if (localX > colorBoxStartX && localX <= colorBoxEndX) {
          localX = textX + totalAdjustment;
          break;
        } else {
          break;
        }
      }
      localX -= totalAdjustment;
    }

    final hasActiveFolds = _hasActiveFolds;
    // In lineWrap mode, _getLineYOffset already returns the prefix-sum value
    // which includes virtual removed block heights. Adding _getTotalVirtualOffset
    // would double-count them. Only ghost text offset (not in prefix sum) needs
    // to be added separately.
    final double lineStartY;
    if (lineWrap) {
      lineStartY =
          _getLineYOffset(tappedLineIndex, hasActiveFolds) +
          _getGhostTextVisualOffset(tappedLineIndex);
    } else {
      lineStartY =
          _getLineYOffset(tappedLineIndex, hasActiveFolds) +
          _getTotalVirtualOffset(tappedLineIndex);
    }
    final localY = position.dy - lineStartY;

    final double safeLocalY = para.height <= 0
        ? 0.0
        : localY.clamp(0.0, max<double>(0.0, para.height - 0.001)).toDouble();
    final paragraphPosition = Offset(localX, safeLocalY);
    final textPosition = para.getPositionForOffset(paragraphPosition);
    final rawUtf16Column = textPosition.offset
        .clamp(0, lineText.length)
        .toInt();
    final utf16Column = _snapUtf16PositionToGraphemeBoundary(
      para,
      paragraphPosition,
      rawUtf16Column,
      lineText.length,
    );
    final scalarColumn = CodeForgeController.utf16ToScalarOffset(
      lineText,
      utf16Column,
    );

    final lineStartOffset = controller.getLineStartOffset(tappedLineIndex);
    var absoluteOffset = lineStartOffset + scalarColumn;

    final nextLineIndex = tappedLineIndex + 1;
    if (nextLineIndex < controller.lineCount) {
      final nextLineStart = controller.getLineStartOffset(nextLineIndex);
      if (absoluteOffset >= nextLineStart) {
        absoluteOffset = nextLineStart - 1;
      }
    }

    return absoluteOffset.clamp(0, controller.length);
  }

  Offset getCaretOffset() => _getCaretInfo().offset;

  ({Rect? startHandle, Rect? endHandle, double lineHeight})
  getSelectionHandleRects() => (
    startHandle: _startHandleRect,
    endHandle: _endHandleRect,
    lineHeight: _lineHeight,
  );

  void _updateImeGeometry() {
    final conn = controller.connection;
    if (conn == null || !conn.attached) return;
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;

    final caretInfo = _getCaretInfo();
    final hScroll = _effectiveHScroll;
    final vScroll = vscrollController.offset;
    final composing = controller.imeComposition != null;

    double contentX(double dxInLine) => isRTL
        ? size.width - _gutterWidth - (innerPadding?.right ?? 0) - dxInLine
        : dxInLine + _gutterWidth + (innerPadding?.left ?? 0);

    final caretY = caretInfo.offset.dy + (innerPadding?.top ?? 0);

    final caretInLine =
        caretInfo.offset.dx + (composing ? _imeComposingCaretDx : 0.0);
    final caretRect = Rect.fromLTWH(
      contentX(caretInLine) - hScroll,
      caretY - vScroll,
      2.0,
      caretInfo.height,
    );

    final composingRect = composing
        ? Rect.fromLTWH(
            contentX(caretInfo.offset.dx) - hScroll,
            caretY - vScroll,
            _imeComposingWidth > 0 ? _imeComposingWidth : 2.0,
            caretInfo.height,
          )
        : caretRect;

    final editableSize = size;

    if (caretRect == _lastImeCaretRect &&
        composingRect == _lastImeComposingRect &&
        editableSize == _lastImeEditableSize) {
      return;
    }
    _lastImeCaretRect = caretRect;
    _lastImeComposingRect = composingRect;
    _lastImeEditableSize = editableSize;

    conn.setEditableSizeAndTransform(editableSize, getTransformTo(null));
    conn.setCaretRect(caretRect);
    conn.setComposingRect(composingRect);
  }

  void _drawImeComposition(Canvas canvas, Offset offset, bool hasActiveFolds) {
    _imeComposingCaretDx = 0.0;
    _imeComposingWidth = 0.0;

    final comp = controller.imeComposition;
    if (comp == null || comp.displayText.isEmpty) return;

    final anchorLine = controller.getLineAtOffset(comp.anchor);
    if (hasActiveFolds && _isLineFolded(anchorLine)) return;

    final lineY = _getLineYOffset(anchorLine, hasActiveFolds);
    final virtualYOffset = _getTotalVirtualOffset(anchorLine);
    final viewportHeight = vscrollController.position.viewportDimension;
    final screenYBase =
        offset.dy +
        (innerPadding?.top ?? 0) +
        lineY +
        virtualYOffset -
        vscrollController.offset;
    if (screenYBase + _lineHeight < offset.dy ||
        screenYBase > offset.dy + viewportHeight) {
      return;
    }

    final lineStartOffset = controller.getLineStartOffset(anchorLine);
    final anchorCol = comp.anchor - lineStartOffset;
    final lineText =
        _lineTextCache[anchorLine] ?? controller.getLineText(anchorLine);
    final scalarCol = anchorCol.clamp(0, lineText.runes.length);
    final utf16Col = CodeForgeController.scalarToUtf16Offset(
      lineText,
      scalarCol,
    );

    final paragraphWidth = lineWrap ? _wrapWidth : null;
    final linePara =
        _paragraphCache[anchorLine] ??
        _buildHighlightedParagraph(anchorLine, lineText, width: paragraphWidth);

    double anchorX = 0;
    double rowTop = 0;
    if (lineText.isNotEmpty && scalarCol > 0) {
      final boxes = linePara.getBoxesForRange(
        0,
        utf16Col,
        boxHeightStyle: ui.BoxHeightStyle.max,
      );
      if (boxes.isNotEmpty) {
        final lastBox = boxes.last;
        anchorX = lastBox.right;
        rowTop = _rowTopForBox(lastBox);
      }
    }

    final scroll = lineWrap ? 0.0 : _effectiveHScroll;
    final screenX =
        offset.dx + _gutterWidth + (innerPadding?.left ?? 0) + anchorX - scroll;
    final screenY = screenYBase + rowTop;

    final baseColor =
        textStyle?.color ?? editorTheme['root']?.color ?? Colors.white;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
    final fontSize = textStyle?.fontSize ?? 14.0;
    final fontFamily = textStyle?.fontFamily;
    final lineHeightMultiplier = textStyle?.height ?? 1.2;

    final overlayParagraphStyle = ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: lineHeightMultiplier,
      textDirection: textDirection,
      textAlign: ui.TextAlign.start,
    );

    final composingStyle = ui.TextStyle(
      color: baseColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      decoration: TextDecoration.underline,
      decorationColor: baseColor.withAlpha(150),
    );
    final composingBuilder = ui.ParagraphBuilder(overlayParagraphStyle)
      ..pushStyle(composingStyle)
      ..addText(comp.displayText);
    final composingPara = composingBuilder.build();
    composingPara.layout(const ui.ParagraphConstraints(width: double.infinity));
    final composingWidth = composingPara.longestLine;

    final remainderWidth = (linePara.longestLine - anchorX).clamp(
      0.0,
      double.infinity,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        screenX,
        screenY,
        composingWidth + remainderWidth + 2,
        _lineHeight,
      ),
      Paint()..color = bgColor,
    );

    canvas.drawParagraph(composingPara, Offset(screenX, screenY));

    if (scalarCol < lineText.runes.length) {
      final remainingText = lineText.substring(utf16Col);
      final remainingStyle = ui.TextStyle(
        color: baseColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: textStyle?.fontWeight,
      );
      final remainingBuilder = ui.ParagraphBuilder(overlayParagraphStyle)
        ..pushStyle(remainingStyle)
        ..addText(remainingText);
      final remainingPara = remainingBuilder.build();
      remainingPara.layout(
        const ui.ParagraphConstraints(width: double.infinity),
      );
      canvas.drawParagraph(
        remainingPara,
        Offset(screenX + composingWidth, screenY),
      );
    }

    double caretDx = 0;
    if (comp.displayCaret > 0) {
      final caretBoxes = composingPara.getBoxesForRange(
        0,
        comp.displayCaret.clamp(0, comp.displayText.length),
      );
      if (caretBoxes.isNotEmpty) caretDx = caretBoxes.last.right;
    }

    _imeComposingCaretDx = caretDx;
    _imeComposingWidth = composingWidth;

    if (focusNode.hasFocus && caretBlinkController.value > 0.5) {
      canvas.drawRect(
        Rect.fromLTWH(screenX + caretDx, screenY, 1.5, _lineHeight),
        _caretPainter,
      );
    }
  }

  int getScrollbarLineNumberAtScrollOffset(double scrollOffset) {
    if (!vscrollController.hasClients || controller.lineCount == 0) {
      return 1;
    }

    final lineIndex = _findVisibleLineByYPosition(
      scrollOffset,
    ).clamp(0, controller.lineCount - 1);
    return lineIndex + 1;
  }

  int getTextOffsetForPosition(Offset position) {
    return _getTextOffsetFromPosition(position);
  }

  double _getLineWidth(int lineIndex) {
    final lineText = controller.getLineText(lineIndex);
    final cachedText = _lineTextCache[lineIndex];

    if (cachedText == lineText && _lineWidthCache.containsKey(lineIndex)) {
      return _lineWidthCache[lineIndex]!;
    }

    final para = _buildParagraph(lineText);
    final width = para.maxIntrinsicWidth;
    _lineTextCache[lineIndex] = lineText;
    _lineWidthCache[lineIndex] = width;
    return width;
  }

  @override
  void detach() {
    _bracketHighlightResumeTimer?.cancel();
    _resizeTimer?.cancel();
    _layoutDebounceTimer?.cancel();
    _foldComputeTimer?.cancel();
    super.detach();
  }

  double get _ghostTextExtraHeight => _ghostTextLineCount * _lineHeight;
  double get _virtualRemovedExtraHeight =>
      _virtualRemovedTotalLineCount * _lineHeight;
  double get _totalVirtualExtraHeight =>
      _ghostTextExtraHeight + _virtualRemovedExtraHeight;
  double _extraBottomPadding = 80.0;

  double _getGhostTextVisualOffset(int lineIndex) {
    if (_ghostTextAnchorLine == null || _ghostTextLineCount <= 0) return 0;
    if (lineIndex <= _ghostTextAnchorLine!) return 0;
    return _ghostTextExtraHeight;
  }

  double _getVirtualRemovedVisualOffset(int lineIndex) {
    if (_virtualRemovedTotalLineCount <= 0) return 0;
    final blocks = controller.virtualRemovedBlocks;
    double offset = 0;
    for (final block in blocks) {
      if (lineIndex > block.afterLine) {
        offset += block.lineCount * _lineHeight;
      }
    }
    return offset;
  }

  double _getTotalVirtualOffset(int lineIndex) {
    return _getGhostTextVisualOffset(lineIndex) +
        _getVirtualRemovedVisualOffset(lineIndex);
  }

  @override
  void performLayout() {
    final lineCount = controller.lineCount;

    if (lineCount != _cachedLineCount) {
      final maxKey = _lineTextCache.keys.isEmpty
          ? 0
          : _lineTextCache.keys.reduce((a, b) => a > b ? a : b);
      for (int i = lineCount; i <= maxKey; i++) {
        _lineWidthCache.remove(i);
        _lineTextCache.remove(i);
        _lineHeightCache.remove(i);
      }
    }

    if (isRTL && !lineWrap) {
      final viewportWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final newContentWidth =
          viewportWidth - _gutterWidth - (innerPadding?.horizontal ?? 0);
      if ((_cachedRtlContentWidth - newContentWidth).abs() > 1) {
        _cachedRtlContentWidth = newContentWidth;
        _paragraphCache.clear();
        _bracketCache.clear();
        _indentGuideCache.clear();
        _diagnosticPathCache.clear();
        _searchHighlightCache.clear();
        _invalidateWrappedLayoutCache();
        _caretInfoCache.clear();
        _lineIndentCache.clear();
      }
    }

    if (_isDeferringLayout && _hasCachedHeight) {
      final computedContentHeight =
          _cachedTotalHeight +
          (innerPadding?.top ?? 0) +
          _totalVirtualExtraHeight +
          _extraBottomPadding;
      final contentHeight = computedContentHeight;
      final computedWidth = lineWrap
          ? (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width)
          : _longLineWidth + (innerPadding?.left ?? 0) + _gutterWidth;
      final minWidth = lineWrap ? 0.0 : MediaQuery.of(context).size.width;
      final contentWidth = max(computedWidth, minWidth);
      size = constraints.constrain(
        Size(
          contentWidth + (innerPadding?.right ?? 0),
          contentHeight + (innerPadding?.bottom ?? 0),
        ),
      );
      return;
    }

    final hasActiveFolds = _hasActiveFolds;
    double visibleHeight = 0;
    double maxLineWidth = _longLineWidth;

    if (lineWrap) {
      final viewportWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final newWrapWidth =
          viewportWidth - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final clampedWrapWidth = newWrapWidth < 100 ? 100.0 : newWrapWidth;

      if (_wrapWidth == double.infinity &&
          constraints.maxWidth.isFinite &&
          constraints.maxWidth > 0) {
        _wrapWidth = clampedWrapWidth;
        _paragraphCache.clear();
        _lineHeightCache.clear();
        _bracketCache.clear();
        _indentGuideCache.clear();
        _diagnosticPathCache.clear();
        _searchHighlightCache.clear();
        _invalidateWrappedLayoutCache();
        _caretInfoCache.clear();
        _lineIndentCache.clear();
      } else if ((_wrapWidth - clampedWrapWidth).abs() > 1) {
        _resizeTimer?.cancel();
        _resizeTimer = Timer(const Duration(milliseconds: 150), () {
          _wrapWidth = clampedWrapWidth;
          _paragraphCache.clear();
          _lineHeightCache.clear();
          _bracketCache.clear();
          _indentGuideCache.clear();
          _diagnosticPathCache.clear();
          _searchHighlightCache.clear();
          _invalidateWrappedLayoutCache();
          _caretInfoCache.clear();
          _lineIndentCache.clear();
          markNeedsLayout();
        });
      }

      if (hasActiveFolds) {
        final foldedCount = _countFoldedLinesBefore(lineCount);
        final visibleLineCount = (lineCount - foldedCount).clamp(0, lineCount);

        if (lineCount > kExactWrappedHeightThreshold) {
          visibleHeight = _estimateWrappedHeight(visibleLineCount);
        } else {
          for (int i = 0; i < lineCount; i++) {
            if (_isLineFolded(i)) continue;
            visibleHeight += _getWrappedLineHeight(i);
          }
        }
      } else {
        final canReuseExactWrappedHeight =
            _hasCachedHeight &&
            _isCachedHeightExact &&
            _previousLineCount == lineCount &&
            _lineHeightCache.length >= lineCount &&
            _cachedWrapWidthForHeight == _wrapWidth;

        if (canReuseExactWrappedHeight) {
          visibleHeight = _cachedTotalHeight;
        } else if (lineCount > kExactWrappedHeightThreshold) {
          visibleHeight = _estimateWrappedHeight(lineCount);
          _isCachedHeightExact = false;
        } else {
          for (int i = 0; i < lineCount; i++) {
            visibleHeight += _getWrappedLineHeight(i);
          }
        }
      }
    } else {
      _wrapWidth = double.infinity;

      if (hasActiveFolds) {
        _ensureFoldedLineCacheValid();
        final foldedCount = _countFoldedLinesBefore(lineCount);
        visibleHeight = (lineCount - foldedCount) * _lineHeight;
      } else {
        visibleHeight = lineCount * _lineHeight;
      }

      if (_longLineWidth == 0 && lineCount > 0) {
        final viewTop = vscrollController.hasClients
            ? vscrollController.offset
            : 0.0;
        final viewBottom =
            viewTop +
            (vscrollController.hasClients
                ? vscrollController.position.viewportDimension
                : MediaQuery.of(context).size.height);
        final firstVisible = (viewTop / _lineHeight).floor().clamp(
          0,
          lineCount - 1,
        );
        final lastVisible = (viewBottom / _lineHeight).ceil().clamp(
          0,
          lineCount - 1,
        );
        final buffer = 50;
        final start = (firstVisible - buffer).clamp(0, lineCount - 1);
        final end = (lastVisible + buffer).clamp(0, lineCount - 1);

        for (int i = start; i <= end; i++) {
          final width = _getLineWidth(i);
          if (width > maxLineWidth) {
            maxLineWidth = width;
          }
        }
      }
    }

    _longLineWidth = maxLineWidth;
    _cachedTotalHeight = visibleHeight;
    _hasCachedHeight = true;
    if (lineCount <= kExactWrappedHeightThreshold) {
      _isCachedHeightExact = true;
    }
    _previousLineCount = lineCount;
    _cachedWrapWidthForHeight = _wrapWidth;

    if (lineWrap && lineCount > 0) {
      final lastLineHeight = _getWrappedLineHeight(lineCount - 1);
      _extraBottomPadding = max(
        lastLineHeight + _lineHeight * 2,
        _lineHeight * 3.5,
      );
    } else {
      _extraBottomPadding = max(_lineHeight * 3.5, 80.0);
    }

    final computedContentHeight =
        visibleHeight +
        (innerPadding?.top ?? 0) +
        _totalVirtualExtraHeight +
        _extraBottomPadding;
    final contentHeight = computedContentHeight;
    final computedWidth = lineWrap
        ? (constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width)
        : maxLineWidth + (innerPadding?.left ?? 0) + _gutterWidth;

    final minWidth = lineWrap ? 0.0 : MediaQuery.of(context).size.width;
    final contentWidth = max(computedWidth, minWidth);

    size = constraints.constrain(
      Size(
        contentWidth + (innerPadding?.right ?? 0),
        contentHeight + (innerPadding?.bottom ?? 0),
      ),
    );
  }

  double _getWrappedLineHeight(int lineIndex) {
    if (_lineHeightCache.containsKey(lineIndex)) {
      return _lineHeightCache[lineIndex]!;
    }

    final lineText = controller.getLineText(lineIndex);

    final builder = ui.ParagraphBuilder(_paragraphStyle);
    builder.pushStyle(_uiTextStyle);
    final textToMeasure = lineText.isEmpty ? ' ' : lineText;
    builder.addText(textToMeasure);

    final para = builder.build();
    para.layout(ui.ParagraphConstraints(width: _wrapWidth));
    final height = para.height;

    _lineHeightCache[lineIndex] = height;
    _lineTextCache[lineIndex] = lineText;

    return height;
  }

  double _estimateWrappedHeight(int visibleLineCount) {
    if (visibleLineCount <= 0) return 0.0;

    final sampleCount = visibleLineCount < kWrappedHeightSampleSize
        ? visibleLineCount
        : kWrappedHeightSampleSize;

    if (sampleCount <= 0) {
      return visibleLineCount * _lineHeight;
    }

    final step = (visibleLineCount / sampleCount).ceil().clamp(
      1,
      visibleLineCount,
    );
    double sampledHeight = 0.0;
    int measured = 0;
    final sampledLines = <int>{};

    for (
      int i = 0;
      i < controller.lineCount && measured < sampleCount;
      i += step
    ) {
      if (_hasActiveFolds && _isLineFolded(i)) continue;
      sampledHeight += _getWrappedLineHeight(i);
      sampledLines.add(i);
      measured++;
    }

    final tailStart = controller.lineCount - 10;
    for (int i = tailStart < 0 ? 0 : tailStart; i < controller.lineCount; i++) {
      if (sampledLines.contains(i)) continue;
      if (_hasActiveFolds && _isLineFolded(i)) continue;
      sampledHeight += _getWrappedLineHeight(i);
      measured++;
    }

    if (measured == 0) {
      return visibleLineCount * _lineHeight;
    }

    final averageHeight = sampledHeight / measured;
    return averageHeight * visibleLineCount;
  }

  double _rowTopForBox(ui.TextBox box) {
    final center = (box.top + box.bottom) / 2.0;
    final rowIndex = (center / _lineHeight).floor();
    return (rowIndex < 0 ? 0 : rowIndex) * _lineHeight;
  }

  void _invalidateWrappedLayoutCache() {
    _wrappedPrefixSumVersion++;
    _visiblePrefixSumVersion++;
    _lineOffsetCache.clear();
  }

  void _ensureWrappedPrefixSum() {
    if (_lastBuiltPrefixSumVersion == _wrappedPrefixSumVersion) return;
    _lastBuiltPrefixSumVersion = _wrappedPrefixSumVersion;

    final lineCount = controller.lineCount;
    final sum = List<double>.filled(lineCount + 1, 0.0);
    double acc = 0.0;
    for (int i = 0; i < lineCount; i++) {
      sum[i] = acc;
      acc += _getWrappedLineHeight(i);
    }
    sum[lineCount] = acc;
    _wrappedLineYPrefixSum = sum;
  }

  void _ensureVisibleLinePrefixSum() {
    if (_lastBuiltVisiblePrefixSumVersion == _visiblePrefixSumVersion) return;
    _lastBuiltVisiblePrefixSumVersion = _visiblePrefixSumVersion;

    final lineCount = controller.lineCount;
    final sum = List<double>.filled(lineCount + 1, 0.0);
    if (lineCount == 0) {
      _visibleLineYPrefixSum = sum;
      return;
    }

    final hasActiveFolds = _hasActiveFolds;
    final hasVirtualBlocks = _virtualRemovedTotalLineCount > 0;

    if (!hasActiveFolds && !hasVirtualBlocks) {
      _ensureWrappedPrefixSum();
      _visibleLineYPrefixSum = _wrappedLineYPrefixSum;
      return;
    }

    final blocks = controller.virtualRemovedBlocks;
    int blockIdx = 0;
    double acc = 0.0;

    for (int i = 0; i < lineCount; i++) {
      sum[i] = acc;
      if (hasActiveFolds && _isLineFolded(i)) continue;
      if (hasVirtualBlocks) {
        while (blockIdx < blocks.length &&
            blocks[blockIdx].afterLine == i - 1) {
          acc += blocks[blockIdx].lineCount * _lineHeight;
          blockIdx++;
        }
      }
      acc += lineWrap ? _getWrappedLineHeight(i) : _lineHeight;
    }
    sum[lineCount] = acc;
    _visibleLineYPrefixSum = sum;
  }

  int _findFirstVisibleWrappedLine(double viewTop) {
    _ensureWrappedPrefixSum();
    final sum = _wrappedLineYPrefixSum;
    if (sum.length <= 1) return 0;

    int lo = 0, hi = sum.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sum[mid] < viewTop) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo > 0) lo--;
    return lo.clamp(0, sum.length - 2);
  }

  double _getLineYOffset(int targetLine, bool hasActiveFolds) {
    if (lineWrap) {
      _ensureVisibleLinePrefixSum();
      final sum = _visibleLineYPrefixSum;
      if (targetLine >= 0 && targetLine < sum.length) {
        return sum[targetLine];
      }
      return sum.isEmpty ? 0.0 : sum.last;
    }

    final cacheKey = '${targetLine}_$hasActiveFolds';
    if (_lineOffsetCache.containsKey(cacheKey)) {
      return _lineOffsetCache[cacheKey]!;
    }

    double y;
    if (!hasActiveFolds) {
      y = targetLine * _lineHeight;
    } else {
      _ensureFoldedLineCacheValid();
      final foldedBefore = _countFoldedLinesBefore(targetLine);
      y = (targetLine - foldedBefore) * _lineHeight;
    }
    _lineOffsetCache[cacheKey] = y;
    return y;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _checkDocumentVersionAndClearCache();

    final canvas = context.canvas;
    final viewTop = vscrollController.offset;
    final viewBottom = viewTop + vscrollController.position.viewportDimension;
    final lineCount = controller.lineCount;
    final bufferActive = controller.isBufferActive;
    final bufferLineIndex = controller.bufferLineIndex;
    final bufferLineText = controller.bufferLineText;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.white;
    final textColor = textStyle?.color ?? editorTheme['root']!.color!;

    canvas.save();

    canvas.drawPaint(
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );

    final hasActiveFolds = _hasActiveFolds;

    int firstVisibleLine;
    int lastVisibleLine;
    double firstVisibleLineY;

    if (!lineWrap && !hasActiveFolds) {
      if (_virtualRemovedTotalLineCount > 0) {
        firstVisibleLine = _findVisibleLineByYPosition(
          viewTop,
        ).clamp(0, lineCount - 1);
        lastVisibleLine = _findVisibleLineByYPosition(
          viewBottom,
        ).clamp(0, lineCount - 1);
        firstVisibleLineY = firstVisibleLine * _lineHeight;
      } else {
        final frame = _layoutMap.buildViewportFrame(
          viewTop: viewTop,
          viewBottom: viewBottom,
          fallbackLineHeight: _lineHeight,
        );
        firstVisibleLine = frame.firstLine;
        lastVisibleLine = frame.lastLine;
        firstVisibleLineY = frame.firstLineY;
        for (int i = 0; i < frame.lines.length; i++) {
          final lineIndex = frame.firstLine + i;
          _lineHeightCache[lineIndex] = frame.lines[i].height;
        }
      }
    } else if (!lineWrap && hasActiveFolds) {
      _ensureFoldedLineCacheValid();
      int lo = 0, hi = lineCount - 1;
      while (lo < hi) {
        final mid = (lo + hi) >> 1;
        final foldedBefore = _countFoldedLinesBefore(mid + 1);
        final midYEnd = ((mid + 1) - foldedBefore) * _lineHeight;
        if (midYEnd <= viewTop) {
          lo = mid + 1;
        } else {
          hi = mid;
        }
      }
      while (lo < lineCount && _foldedLineIndices.contains(lo)) {
        lo++;
      }
      firstVisibleLine = lo.clamp(0, lineCount - 1);
      firstVisibleLineY = _getLineYOffset(firstVisibleLine, true);

      lo = firstVisibleLine;
      hi = lineCount - 1;
      while (lo < hi) {
        final mid = (lo + hi + 1) >> 1;
        final midY = _getLineYOffset(mid, true);
        if (midY < viewBottom) {
          lo = mid;
        } else {
          hi = mid - 1;
        }
      }
      lastVisibleLine = lo.clamp(0, lineCount - 1);
    } else if (!hasActiveFolds) {
      _ensureWrappedPrefixSum();
      final sum = _wrappedLineYPrefixSum;
      if (sum.length <= 1 || lineCount == 0) {
        firstVisibleLine = 0;
        lastVisibleLine = 0;
        firstVisibleLineY = 0;
      } else {
        firstVisibleLine = _findFirstVisibleWrappedLine(viewTop);
        firstVisibleLineY = sum[firstVisibleLine];

        lastVisibleLine = firstVisibleLine;
        for (int i = firstVisibleLine; i < lineCount; i++) {
          if (sum[i + 1] >= viewBottom) {
            lastVisibleLine = i;
            break;
          }
          lastVisibleLine = i;
        }
        lastVisibleLine = lastVisibleLine.clamp(0, lineCount - 1);
      }
    } else {
      _ensureVisibleLinePrefixSum();
      final sum = _visibleLineYPrefixSum;
      if (sum.length <= 1 || lineCount == 0) {
        firstVisibleLine = 0;
        lastVisibleLine = 0;
        firstVisibleLineY = 0;
      } else {
        firstVisibleLine = _findVisibleLineByYPosition(
          viewTop,
        ).clamp(0, lineCount - 1);
        firstVisibleLineY = sum[firstVisibleLine];

        lastVisibleLine = firstVisibleLine;
        for (int i = firstVisibleLine; i < lineCount; i++) {
          if (hasActiveFolds && _isLineFolded(i)) continue;
          if (sum[i + 1] >= viewBottom) {
            lastVisibleLine = i;
            break;
          }
          lastVisibleLine = i;
        }
        lastVisibleLine = lastVisibleLine.clamp(0, lineCount - 1);
      }
    }

    _pruneViewportCaches(firstVisibleLine, lastVisibleLine);
    _scheduleVisibleSemanticTokens(firstVisibleLine, lastVisibleLine);
    final h = _syntaxHighlighter;
    if (h != null) {
      final forceIsolate = !_preHighlightInitialized;
      _preHighlightInitialized = true;
      unawaited(
        h.preHighlightLines(
          firstVisibleLine,
          lastVisibleLine,
          controller.getLineText,
          forceIsolate: forceIsolate,
        ),
      );
    }

    _drawSearchHighlights(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      firstVisibleLineY,
      hasActiveFolds,
    );

    _drawLineDecorations(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      firstVisibleLineY,
      hasActiveFolds,
    );

    _drawLineHighlight(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      firstVisibleLineY,
      hasActiveFolds,
    );

    _drawFoldedLineHighlights(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      firstVisibleLineY,
      hasActiveFolds,
    );

    if (controller.documentHighlights.isNotEmpty) {
      _drawDocumentHighlights(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
      );
    }

    _drawSelection(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      firstVisibleLineY,
      hasActiveFolds,
    );

    if (enableGuideLines && (lastVisibleLine - firstVisibleLine) < 200) {
      if (_indentGuideFirstFramePending) {
        _indentGuideFirstFramePending = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          markNeedsPaint();
        });
      } else {
        _drawIndentGuides(
          canvas,
          offset,
          firstVisibleLine,
          lastVisibleLine,
          firstVisibleLineY,
          hasActiveFolds,
          textColor,
        );
      }
    }

    double currentY = firstVisibleLineY;
    for (int i = firstVisibleLine; i <= lastVisibleLine && i < lineCount; i++) {
      if (hasActiveFolds && _isLineFolded(i)) continue;

      final contentTop = currentY;
      double lineHeight = lineWrap ? _getWrappedLineHeight(i) : _lineHeight;
      final visualYOffset = _getTotalVirtualOffset(i);

      ui.Paragraph paragraph;
      String lineText;

      final contentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final paragraphWidth = lineWrap
          ? _wrapWidth
          : (isRTL ? max(contentWidth * 3, 10000.0) : null);

      if (bufferActive && i == bufferLineIndex && bufferLineText != null) {
        lineText = bufferLineText;
        final textHash = bufferLineText.hashCode;
        final pw = paragraphWidth;
        if (_bufferParagraphLine != i ||
            _bufferParagraphTextHash != textHash ||
            _bufferParagraphWidth != pw) {
          _bufferParagraph?.dispose();
          _bufferParagraph = _buildHighlightedParagraph(
            i,
            bufferLineText,
            width: pw,
          );
          _bufferParagraphLine = i;
          _bufferParagraphTextHash = textHash;
          _bufferParagraphWidth = pw;
        }
        paragraph = _bufferParagraph!;
        if (isRTL && lineWrap) {
          lineHeight = paragraph.height;
        }
      } else {
        if (_lineTextCache.containsKey(i)) {
          lineText = _lineTextCache[i]!;
        } else {
          lineText = controller.getLineText(i);
          _lineTextCache[i] = lineText;
        }

        if (_paragraphCache.containsKey(i)) {
          paragraph = _paragraphCache[i]!;
        } else {
          paragraph = _buildHighlightedParagraph(
            i,
            lineText,
            width: paragraphWidth,
          );
          _paragraphCache[i] = paragraph;

          if (lineWrap) {
            if (_lineHeightCache[i] != paragraph.height) {
              _lineHeightCache[i] = paragraph.height;
              _invalidateWrappedLayoutCache();
            }
            if (isRTL) {
              lineHeight = paragraph.height;
            }
          } else {
            final w = paragraph.maxIntrinsicWidth;
            if (w > _longLineWidth) {
              _longLineWidth = w;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (attached) {
                  markNeedsLayout();
                }
              });
            }
          }
        }
      }

      final foldRange = _getFoldRangeAtLine(i);
      final isFoldStart =
          foldRange != null && foldRange.endIndex > foldRange.startIndex;

      final textX = isRTL
          ? (lineWrap
                ? (innerPadding?.left ?? 0)
                : (innerPadding?.left ?? 0) +
                      contentWidth -
                      (paragraphWidth ?? 0) -
                      _effectiveHScroll)
          : _gutterWidth +
                (innerPadding?.left ?? 0) -
                (lineWrap ? 0 : _effectiveHScroll);

      canvas.drawParagraph(
        paragraph,
        offset +
            Offset(
              textX,
              (innerPadding?.top ?? 0) +
                  contentTop +
                  visualYOffset -
                  vscrollController.offset,
            ),
      );

      if (isFoldStart && foldRange.isFolded) {
        final foldIndicator = _buildParagraph(' ...');
        final paraWidth = paragraph.longestLine;
        final foldX = isRTL
            ? (innerPadding?.left ?? 0) +
                  contentWidth -
                  paraWidth -
                  foldIndicator.longestLine -
                  (lineWrap ? 0 : _effectiveHScroll)
            : _gutterWidth +
                  (innerPadding?.left ?? 0) +
                  paraWidth -
                  (lineWrap ? 0 : _effectiveHScroll);
        canvas.drawParagraph(
          foldIndicator,
          offset +
              Offset(
                foldX,
                (innerPadding?.top ?? 0) +
                    contentTop +
                    visualYOffset -
                    vscrollController.offset,
              ),
        );
      }

      currentY += lineHeight;
    }

    _drawDiagnostics(
      canvas,
      offset,
      firstVisibleLine,
      lastVisibleLine,
      firstVisibleLineY,
      hasActiveFolds,
    );

    _colorBoxHitAreas.clear();
    if (controller.documentColors.isNotEmpty) {
      _drawDocumentColors(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
      );
    }

    if (controller.inlayHintsVisible && controller.inlayHints.isNotEmpty) {
      _drawInlayHints(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
      );
    }

    if (controller.ghostText != null) {
      _drawGhostText(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
      );
    } else if (_aiResponse != null && _aiResponse!.isNotEmpty) {
      _drawAiGhostText(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
      );
    }

    if (controller.virtualRemovedBlocks.isNotEmpty) {
      _drawVirtualRemovedLines(
        canvas,
        offset,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
      );
    }

    if (enableGutter) {
      _drawGutter(
        canvas,
        offset,
        viewTop,
        viewBottom,
        lineCount,
        bgColor,
        textStyle,
      );
    }

    if (_rightPaddingWidth > 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx + size.width - _rightPaddingWidth,
          offset.dy,
          _rightPaddingWidth,
          size.height,
        ),
        Paint()..color = Colors.transparent,
      );
    }

    if (_bottomPaddingHeight > 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx,
          offset.dy + size.height - _bottomPaddingHeight,
          size.width,
          _bottomPaddingHeight,
        ),
        Paint()..color = Colors.transparent,
      );
    }

    if (focusNode.hasFocus) {
      _drawBracketHighlight(
        canvas,
        offset,
        viewTop,
        viewBottom,
        firstVisibleLine,
        lastVisibleLine,
        firstVisibleLineY,
        hasActiveFolds,
        textColor,
      );
    }

    _drawImeComposition(canvas, offset, hasActiveFolds);

    if (focusNode.hasFocus &&
        caretBlinkController.value > 0.5 &&
        controller.imeComposition == null) {
      final caretInfo = _getCaretInfo();

      final scroll = lineWrap ? 0.0 : _effectiveHScroll;
      final textX = isRTL
          ? (innerPadding?.left ?? 0) - scroll
          : _gutterWidth + (innerPadding?.left ?? 0) - scroll;
      final caretScreenX = offset.dx + textX + caretInfo.offset.dx;
      final caretScreenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          caretInfo.offset.dy -
          vscrollController.offset;

      canvas.drawRect(
        Rect.fromLTWH(caretScreenX, caretScreenY, 1.5, caretInfo.height),
        _caretPainter,
      );

      if (controller.hasMultiCursors) {
        for (final cursor in controller.multiCursors) {
          final cursorOffset =
              controller.getLineStartOffset(
                cursor.line.clamp(0, controller.lineCount - 1),
              ) +
              cursor.character;
          final safeOffset = cursorOffset.clamp(0, controller.text.length);
          final info = _getCaretInfoAtOffset(safeOffset);
          final cx = offset.dx + textX + info.offset.dx;
          final cy =
              offset.dy +
              (innerPadding?.top ?? 0) +
              info.offset.dy -
              vscrollController.offset;
          canvas.drawRect(
            Rect.fromLTWH(cx, cy, 1.5, info.height),
            _caretPainter,
          );
        }
      }
    }

    if (isMobile) {
      final selection = controller.selection;
      final handleColor = selectionStyle.cursorBubbleColor;
      final handleRadius = (_lineHeight / 2).clamp(6.0, 12.0);

      final handlePaint = Paint()
        ..color = handleColor
        ..style = PaintingStyle.fill;

      if (selection.isCollapsed) {
        if (_showBubble || _selectionActive) {
          final caretInfo = _getCaretInfo();
          final handleSize = caretInfo.height;

          final scroll = lineWrap ? 0.0 : _effectiveHScroll;
          final textX = isRTL
              ? (innerPadding?.left ?? 0) - scroll
              : _gutterWidth + (innerPadding?.left ?? 0) - scroll;
          final handleX = offset.dx + textX + caretInfo.offset.dx;
          final handleY =
              offset.dy +
              (innerPadding?.top ?? 0) +
              caretInfo.offset.dy +
              _lineHeight -
              vscrollController.offset;

          canvas.save();
          canvas.translate(handleX, handleY);
          canvas.rotate(pi / 4);
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromCenter(
                center: Offset((handleSize / 1.5), (handleSize / 1.5)),
                width: handleSize * 1.3,
                height: handleSize * 1.3,
              ),
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            handlePaint,
          );
          canvas.restore();

          _normalHandle = Rect.fromCenter(
            center: Offset(handleX, handleY + handleRadius),
            width: handleRadius * 2,
            height: handleRadius * 2,
          );

          if (_enableMagnifier && _draggingCHandle) {
            _selectionActive = selectionActiveNotifier.value = true;
            final caretLineIndex = controller.getLineAtOffset(
              controller.selection.baseOffset,
            );
            final lineText = _effectiveLineText(caretLineIndex);
            final lineStartOffset = controller.getLineStartOffset(
              caretLineIndex,
            );
            final caretInLine =
                controller.selection.baseOffset - lineStartOffset;
            final utf16Caret = CodeForgeController.scalarToUtf16Offset(
              lineText,
              caretInLine,
            );

            final previewStart = utf16Caret.clamp(0, lineText.length);
            final previewEnd = (utf16Caret + 10).clamp(0, lineText.length);
            final rawPreviewStart = max(0, previewStart - 10);
            final rawPreviewEnd = min(lineText.length, previewEnd);
            final safeStart = _safeUtf16Bound(
              lineText,
              rawPreviewStart,
              snapBack: true,
            );
            final safeEnd = _safeUtf16Bound(
              lineText,
              rawPreviewEnd,
              snapBack: false,
            );
            final previewText = lineText.substring(safeStart, safeEnd);

            ui.Paragraph zoomParagraph;
            if (_cachedMagnifiedParagraph != null &&
                _cachedMagnifiedLine == caretLineIndex &&
                _cachedMagnifiedOffset == caretInLine) {
              zoomParagraph = _cachedMagnifiedParagraph!;
            } else {
              final zoomFontSize = (textStyle?.fontSize ?? 14) * 1.5;
              final fontFamily = textStyle?.fontFamily;
              final h = _syntaxHighlighter;
              zoomParagraph = h == null
                  ? _buildParagraph(previewText, width: isRTL ? 10000.0 : null)
                  : h.buildHighlightedParagraph(
                      caretLineIndex,
                      previewText,
                      _paragraphStyle,
                      zoomFontSize,
                      fontFamily,
                      width: isRTL ? 10000.0 : null,
                    );
              _cachedMagnifiedParagraph = zoomParagraph;
              _cachedMagnifiedLine = caretLineIndex;
              _cachedMagnifiedOffset = caretInLine;
            }

            final zoomBoxWidth = min(
              zoomParagraph.longestLine + 16,
              size.width * 0.6,
            );
            final zoomBoxHeight = zoomParagraph.height + 12;
            final localCaretIndex = (utf16Caret - safeStart).clamp(
              0,
              previewText.length,
            );

            double caretDx = 0.0;
            if (previewText.isNotEmpty) {
              if (localCaretIndex < previewText.length) {
                final glyphInfo = zoomParagraph.getGlyphInfoAt(localCaretIndex);
                if (glyphInfo != null) {
                  final range = glyphInfo.graphemeClusterCodeUnitRange;
                  final start = range.start
                      .clamp(0, previewText.length)
                      .toInt();
                  final end = range.end
                      .clamp(start, previewText.length)
                      .toInt();
                  final useTrailing =
                      localCaretIndex >= end ||
                      (localCaretIndex > start &&
                          (localCaretIndex - start) * 2 >= (end - start));
                  final bounds = glyphInfo.graphemeClusterLayoutBounds;
                  caretDx = isRTL
                      ? (useTrailing ? bounds.left : bounds.right)
                      : (useTrailing ? bounds.right : bounds.left);
                } else {
                  final boxes = zoomParagraph.getBoxesForRange(
                    localCaretIndex,
                    localCaretIndex + 1,
                  );
                  if (boxes.isNotEmpty) {
                    caretDx = isRTL ? boxes.first.right : boxes.first.left;
                  }
                }
              } else if (localCaretIndex > 0) {
                final glyphInfo = zoomParagraph.getGlyphInfoAt(
                  localCaretIndex - 1,
                );
                if (glyphInfo != null) {
                  final bounds = glyphInfo.graphemeClusterLayoutBounds;
                  caretDx = isRTL ? bounds.left : bounds.right;
                } else {
                  final boxes = zoomParagraph.getBoxesForRange(
                    localCaretIndex - 1,
                    localCaretIndex,
                  );
                  if (boxes.isNotEmpty) {
                    caretDx = isRTL ? boxes.last.left : boxes.last.right;
                  }
                }
              }
              if (caretDx == 0.0 && localCaretIndex > 0) {
                final prevBoxes = zoomParagraph.getBoxesForRange(
                  localCaretIndex - 1,
                  localCaretIndex,
                );
                if (prevBoxes.isNotEmpty) {
                  caretDx = isRTL ? prevBoxes.last.left : prevBoxes.last.right;
                }
              }
            }

            final double paragraphX = handleX - caretDx;
            final double idealZoomBoxX = isRTL
                ? paragraphX + 10000.0 + 8.0 - zoomBoxWidth
                : paragraphX - 8.0;

            final double zoomBoxX = idealZoomBoxX.clamp(
              0.0,
              max(0.0, size.width - zoomBoxWidth),
            );

            double zoomBoxY = handleY - zoomBoxHeight - (caretInfo.height * 2);
            final viewportTop = 0.0;
            final viewportBottom = size.height;

            if (zoomBoxY < viewportTop + 4) {
              zoomBoxY = handleY + caretInfo.height;
              if (zoomBoxY + zoomBoxHeight > viewportBottom - 4) {
                zoomBoxY = viewportBottom - zoomBoxHeight - 4;
              }
            }
            zoomBoxY = zoomBoxY.clamp(
              viewportTop + 4,
              max(viewportTop + 4, viewportBottom - zoomBoxHeight - 4),
            );

            final rrect = RRect.fromRectAndRadius(
              Rect.fromLTWH(zoomBoxX, zoomBoxY, zoomBoxWidth, zoomBoxHeight),
              Radius.circular(12),
            );

            canvas.drawRRect(
              rrect,
              Paint()
                ..color = editorTheme['root']?.backgroundColor ?? Colors.black
                ..style = PaintingStyle.fill,
            );

            canvas.drawRRect(
              rrect,
              Paint()
                ..color = editorTheme['root']?.color ?? Colors.grey
                ..strokeWidth = 0.5
                ..style = PaintingStyle.stroke,
            );

            canvas.save();
            canvas.clipRect(rrect.outerRect);

            canvas.drawParagraph(
              zoomParagraph,
              Offset(paragraphX, zoomBoxY + 6),
            );
            canvas.drawLine(
              Offset(handleX, zoomBoxY + 6),
              Offset(handleX, zoomBoxY + 6 + zoomParagraph.height),
              Paint()
                ..color = selectionStyle.cursorColor ?? Colors.blue
                ..strokeWidth = 2.0,
            );
            canvas.restore();
          }
        }
      } else {
        final rightRect = RRect.fromRectAndCorners(
          _endHandleRect!,
          topRight: isRTL ? Radius.zero : Radius.circular(25),
          topLeft: isRTL ? Radius.circular(25) : Radius.zero,
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        );

        final leftRect = RRect.fromRectAndCorners(
          _startHandleRect!,
          topLeft: isRTL ? Radius.zero : Radius.circular(25),
          topRight: isRTL ? Radius.circular(25) : Radius.zero,
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        );

        if (_startHandleRect != null) {
          canvas.drawRRect(leftRect, handlePaint);
        }

        if (_endHandleRect != null) {
          canvas.drawRRect(rightRect, handlePaint);
        }
      }
    }

    canvas.restore();

    _updateImeGeometry();
  }

  void _drawGutter(
    Canvas canvas,
    Offset offset,
    double viewTop,
    double viewBottom,
    int lineCount,
    Color bgColor,
    TextStyle? gutterTextStyle,
  ) {
    final viewportHeight = vscrollController.position.viewportDimension;

    final gutterBgColor = gutterStyle.backgroundColor ?? bgColor;
    final gutterX = isRTL ? offset.dx + size.width - _gutterWidth : offset.dx;
    canvas.drawRect(
      Rect.fromLTWH(gutterX, offset.dy, _gutterWidth, viewportHeight),
      Paint()..color = gutterBgColor,
    );

    if (enableGutterDivider) {
      final dividerPaint = Paint()
        ..color = (editorTheme['root']?.color ?? Colors.grey).withAlpha(150)
        ..strokeWidth = 1;
      final dividerX = isRTL ? gutterX : gutterX + _gutterWidth - 1;
      canvas.drawLine(
        Offset(dividerX, offset.dy),
        Offset(dividerX, offset.dy + viewportHeight),
        dividerPaint,
      );
    }

    final baseLineNumberStyle = (() {
      if (gutterStyle.lineNumberStyle != null) {
        if (gutterStyle.lineNumberStyle!.fontSize == null) {
          return gutterStyle.lineNumberStyle!.copyWith(
            fontSize: gutterTextStyle?.fontSize,
          );
        }
        return gutterStyle.lineNumberStyle;
      } else {
        if (gutterTextStyle == null) {
          return editorTheme['root'];
        } else if (gutterTextStyle.color == null) {
          return gutterTextStyle.copyWith(color: editorTheme['root']?.color);
        } else {
          return gutterTextStyle;
        }
      }
    })();

    final cursorOffset = controller.selection.extentOffset;
    final currentLine = controller.getLineAtOffset(cursorOffset);
    final selection = controller.selection;
    int? selectionStartLine;
    int? selectionEndLine;
    if (selection.start != selection.end) {
      selectionStartLine = controller.getLineAtOffset(selection.start);
      selectionEndLine = controller.getLineAtOffset(selection.end);

      if (selectionStartLine > selectionEndLine) {
        final temp = selectionStartLine;
        selectionStartLine = selectionEndLine;
        selectionEndLine = temp;
      }
    }

    final Map<int, int> lineSeverityMap = {};
    for (final diagnostic in _diagnostics) {
      final startLine = diagnostic.range['start']?['line'] as int?;
      final endLine = diagnostic.range['end']?['line'] as int?;
      if (startLine != null) {
        final severity = diagnostic.severity;
        if (severity == 1 || severity == 2) {
          final rangeEnd = endLine ?? startLine;
          for (int line = startLine; line <= rangeEnd; line++) {
            final existing = lineSeverityMap[line];
            if (existing == null || severity < existing) {
              lineSeverityMap[line] = severity;
            }
          }
        }
      }
    }

    final activeLineColor =
        gutterStyle.activeLineNumberColor ??
        (baseLineNumberStyle?.color ?? Colors.white);
    final inactiveLineColor =
        gutterStyle.inactiveLineNumberColor ??
        (baseLineNumberStyle?.color?.withAlpha(120) ?? Colors.grey);
    final errorColor = gutterStyle.errorLineNumberColor;
    final warningColor = gutterStyle.warningLineNumberColor;

    final firstVisibleLine = _findVisibleLineByYPosition(
      viewTop,
    ).clamp(0, lineCount - 1);
    final firstVisibleLineY = _getLineYOffset(
      firstVisibleLine,
      _hasActiveFolds,
    );

    _actionBulbRects.clear();

    double currentY = firstVisibleLineY;
    int indexTracker = firstVisibleLine + 1;

    for (int i = firstVisibleLine; i < lineCount; i++) {
      if (_hasActiveFolds && _isLineFolded(i)) continue;

      final contentTop = currentY;
      final lineHeight = lineWrap ? _getWrappedLineHeight(i) : _lineHeight;

      final visualYOffset = _getTotalVirtualOffset(i);

      if (contentTop + visualYOffset > viewBottom) break;

      if (contentTop + visualYOffset + lineHeight >= viewTop) {
        _drawGutterDecorations(
          canvas,
          offset,
          i,
          contentTop + visualYOffset,
          lineHeight,
        );

        Color lineNumberColor;
        final severity = lineSeverityMap[i];
        if (severity == 1) {
          lineNumberColor = errorColor;
        } else if (severity == 2) {
          lineNumberColor = warningColor;
        } else if (i == currentLine) {
          lineNumberColor = activeLineColor;
        } else if (selectionStartLine != null &&
            selectionEndLine != null &&
            i >= selectionStartLine &&
            i <= selectionEndLine) {
          lineNumberColor = activeLineColor;
        } else {
          lineNumberColor = inactiveLineColor;
        }

        final lineNumberStyle = baseLineNumberStyle!.copyWith(
          color: lineNumberColor,
        );

        String gutterText;

        final builderText = gutterBuilder?.builder.call(
          i + 1,
          controller.getLineText(i),
        );
        final builderWidth = (builderText?.length ?? 0) * 0.6 * _gutterPadding;

        if (builderText == null) {
          gutterText = indexTracker.toString();
          indexTracker++;
        } else {
          if (gutterBuilder?.includeReplacedIndex ?? false) {
            gutterText = builderText;
            indexTracker++;
          } else {
            gutterText = builderText;
          }

          if (builderWidth >= _gutterWidth) {
            _gutterWidth =
                (enableFolding ? (_textStyle?.fontSize ?? 14.0) + 4 : 0) +
                _gutterPadding +
                builderWidth;
          }
        }

        final lineNumPara = _buildLineNumberParagraph(
          gutterText,
          lineNumberStyle,
        );
        final numWidth = lineNumPara.longestLine;

        canvas.drawParagraph(
          lineNumPara,
          offset +
              Offset(
                (isRTL ? size.width - _gutterWidth : 0) +
                    (_gutterWidth - numWidth) / 2 -
                    (enableFolding ? (lineNumberStyle.fontSize ?? 14) / 2 : 0),
                (innerPadding?.top ?? 0) +
                    contentTop +
                    visualYOffset -
                    vscrollController.offset,
              ),
        );

        if (lspConfig != null && lspActionNotifier.value != null) {
          final actions = lspActionNotifier.value!.cast<Map<String, dynamic>>();
          if (actions.any((item) {
            try {
              return (item['arguments'][0]['range']['start']['line'] as int) ==
                  i;
            } on NoSuchMethodError {
              try {
                final fileUri = Uri.file(filePath!).toString();
                return (item['edit']['changes'][fileUri][0]['range']['start']['line']
                        as int) ==
                    i;
              } catch (e) {
                return false;
              }
            } catch (e) {
              return false;
            }
          })) {
            final lineText = controller.getLineText(i);
            final hasLeadingIndent = _measureLeadingIndentColumns(lineText) > 0;
            final icon = Icons.lightbulb_outline;
            final actionBulbPainter = TextPainter(
              text: TextSpan(
                text: String.fromCharCode(icon.codePoint),
                style: TextStyle(
                  fontSize: textStyle?.fontSize ?? 14,
                  color: Colors.yellowAccent,
                  fontFamily: icon.fontFamily,
                  package: icon.fontPackage,
                ),
              ),
              textDirection: _textDirection,
            );
            actionBulbPainter.layout();

            final contentStartX = isRTL
                ? offset.dx +
                      size.width -
                      _gutterWidth -
                      (innerPadding?.right ?? 0) -
                      _effectiveHScroll
                : offset.dx +
                      _gutterWidth +
                      (innerPadding?.left ?? 0) -
                      (lineWrap ? 0 : _effectiveHScroll);

            final bulbX = hasLeadingIndent
                ? (isRTL
                      ? contentStartX - actionBulbPainter.width - 4
                      : contentStartX + 4)
                : (isRTL
                      ? (isMobile
                            ? offset.dx +
                                  size.width -
                                  actionBulbPainter.width -
                                  4
                            : offset.dx + size.width - _gutterWidth + 4)
                      : (isMobile
                            ? offset.dx +
                                  _gutterWidth -
                                  actionBulbPainter.width -
                                  (baseLineNumberStyle.fontSize ?? 14) +
                                  4
                            : offset.dx + 4));
            final bulbY =
                offset.dy +
                (innerPadding?.top ?? 0) +
                contentTop +
                visualYOffset -
                vscrollController.offset +
                (_lineHeight - actionBulbPainter.height) / 2;

            _actionBulbRects[i] = Rect.fromLTWH(
              bulbX,
              bulbY,
              actionBulbPainter.width,
              actionBulbPainter.height,
            );

            actionBulbPainter.paint(canvas, Offset(bulbX, bulbY));
          }
        }

        if (enableFolding) {
          final foldRange = _getFoldRangeAtLine(i);
          if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
            final isInsideFoldedParent = _isLineFolded(i);

            if (!isInsideFoldedParent) {
              final icon = foldRange.isFolded
                  ? (isRTL
                        ? Icons.chevron_left_outlined
                        : gutterStyle.foldedIcon)
                  : gutterStyle.unfoldedIcon;
              final iconColor = foldRange.isFolded
                  ? (gutterStyle.foldedIconColor ?? lineNumberStyle.color)
                  : (gutterStyle.unfoldedIconColor ?? lineNumberStyle.color);

              _drawFoldIcon(
                canvas,
                offset,
                icon,
                iconColor!,
                lineNumberStyle.fontSize ?? 14,
                contentTop + visualYOffset - vscrollController.offset,
              );
            }
          }
        }
      }

      currentY += lineHeight;
    }
  }

  ui.Paragraph _buildLineNumberParagraph(String text, TextStyle style) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
            ),
          )
          ..pushStyle(
            ui.TextStyle(
              color: style.color,
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
            ),
          )
          ..addText(text);
    final p = builder.build();
    p.layout(const ui.ParagraphConstraints(width: double.infinity));
    return p;
  }

  void _drawFoldIcon(
    Canvas canvas,
    Offset offset,
    IconData icon,
    Color color,
    double fontSize,
    double y,
  ) {
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: _textDirection,
    );
    iconPainter.layout();
    final iconX = isRTL
        ? offset.dx + size.width - iconPainter.width - 2
        : offset.dx + _gutterWidth - iconPainter.width - 2;
    iconPainter.paint(
      canvas,
      Offset(
        iconX,
        offset.dy +
            (innerPadding?.top ?? 0) +
            y +
            (_lineHeight - iconPainter.height) / 2,
      ),
    );
  }

  void _drawIndentGuides(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
    Color textColor,
  ) {
    if (!enableGuideLines) return;

    final viewTop = vscrollController.offset;
    final viewBottom = viewTop + vscrollController.position.viewportDimension;
    final tabSize = controller.tabSize;
    final cursorOffset = controller.selection.extentOffset;
    final currentLine = controller.getLineAtOffset(cursorOffset);
    List<({int startLine, int endLine, int indentLevel, double guideX})>
    blocks = [];

    final scanStart = (firstVisibleLine - 500).clamp(0, firstVisibleLine);
    final visibleLineTexts = controller.getLinesRange(
      scanStart,
      lastVisibleLine + 1,
    );

    String lineTextAt(int lineIndex) {
      final visibleIndex = lineIndex - scanStart;
      if (visibleIndex < 0 || visibleIndex >= visibleLineTexts.length) {
        return controller.getLineText(lineIndex);
      }
      return visibleLineTexts[visibleIndex];
    }

    double measureLeadingIndentWidth(String lineText, int leadingColumns) {
      if (leadingColumns <= 0 || lineText.isEmpty) return 0;

      int consumedColumns = 0;
      int endIndex = 0;

      while (endIndex < lineText.length && consumedColumns < leadingColumns) {
        final ch = lineText[endIndex];
        if (ch == ' ') {
          consumedColumns += 1;
        } else if (ch == '\t') {
          consumedColumns = tabSize <= 0
              ? consumedColumns + 1
              : consumedColumns + (tabSize - (consumedColumns % tabSize));
        } else {
          break;
        }
        endIndex++;
      }

      if (endIndex == 0) return 0;

      final indentString = lineText.substring(0, endIndex);
      final builder = ui.ParagraphBuilder(_paragraphStyle)
        ..pushStyle(_uiTextStyle)
        ..addText(indentString);
      final spacePara = builder.build();
      spacePara.layout(const ui.ParagraphConstraints(width: double.infinity));
      return spacePara.maxIntrinsicWidth;
    }

    void addBlock({
      required int startLine,
      required int endLine,
      required int leadingColumns,
      required int indentLevel,
      required String lineText,
    }) {
      if (endLine <= startLine) return;

      final cachedBlocks = _indentGuideCache[startLine];
      if (cachedBlocks != null && cachedBlocks.isNotEmpty) {
        blocks.addAll(cachedBlocks);
        return;
      }

      final renderEndLine = max(
        _shouldShortenGuideToPreviousLine(lineText)
            ? (endLine - 1).clamp(startLine + 1, endLine)
            : endLine,
        startLine + 2,
      );

      double guideX = 0;
      if (leadingColumns > 0) {
        guideX = measureLeadingIndentWidth(lineText, leadingColumns);
      }

      final block = (
        startLine: startLine,
        endLine: renderEndLine,
        indentLevel: indentLevel,
        guideX: guideX,
      );

      _indentGuideCache[startLine] = [block];
      if (renderEndLine >= firstVisibleLine) {
        blocks.add(block);
      }
    }

    final foldedGuideCandidates = <int, FoldRange>{};
    for (
      int i = scanStart;
      i <= lastVisibleLine && i < controller.lineCount;
      i++
    ) {
      final fold = _foldRanges[i];
      if (fold != null) {
        foldedGuideCandidates[i] = fold;
      }
    }

    final rustBlocks = guidesComputeViewport(
      rope: controller.rope.core,
      firstVisible: BigInt.from(firstVisibleLine),
      lastVisible: BigInt.from(lastVisibleLine),
      tabSize: BigInt.from(tabSize),
    );

    for (final b in rustBlocks) {
      final lineText = _lineTextCache[b.startLine] ?? lineTextAt(b.startLine);
      _lineTextCache[b.startLine] = lineText;

      addBlock(
        startLine: b.startLine,
        endLine: b.endLine,
        leadingColumns: b.leadingSpaces,
        indentLevel: b.indentLevel,
        lineText: lineText,
      );
    }

    if (foldedGuideCandidates.isNotEmpty) {
      for (final entry in foldedGuideCandidates.entries) {
        final lineIndex = entry.key;
        final fold = entry.value;

        final lineText = _lineTextCache[lineIndex] ?? lineTextAt(lineIndex);
        _lineTextCache[lineIndex] = lineText;

        final alreadyAdded = blocks.any(
          (block) => block.startLine == lineIndex,
        );
        if (alreadyAdded) {
          continue;
        }

        final leadingColumns = _measureLeadingIndentColumns(lineText);
        final indentLevel = _lineIndentCache.containsKey(lineIndex)
            ? _lineIndentCache[lineIndex]!
            : (tabSize > 0 ? leadingColumns ~/ tabSize : leadingColumns);
        if (!_lineIndentCache.containsKey(lineIndex)) {
          _lineIndentCache[lineIndex] = indentLevel;
        }

        addBlock(
          startLine: lineIndex,
          endLine: fold.endIndex + 1,
          leadingColumns: leadingColumns,
          indentLevel: indentLevel,
          lineText: lineText,
        );
      }
    }

    int? selectedBlockIndex;
    int minBlockSize = 999999;

    for (int idx = 0; idx < blocks.length; idx++) {
      final block = blocks[idx];
      if (currentLine >= block.startLine && currentLine < block.endLine) {
        final blockSize = block.endLine - block.startLine;
        if (blockSize < minBlockSize) {
          minBlockSize = blockSize;
          selectedBlockIndex = idx;
        }
      }
    }

    for (int idx = 0; idx < blocks.length; idx++) {
      final block = blocks[idx];
      final isSelected = selectedBlockIndex == idx;

      final guidePaint = Paint()
        ..color = isSelected ? textColor : textColor.withAlpha(100)
        ..strokeWidth = isSelected ? 1.0 : 0.5
        ..style = PaintingStyle.stroke;

      double yTop;
      if (!lineWrap && !hasActiveFolds) {
        yTop = (block.startLine + 1) * _lineHeight;
      } else {
        yTop = _getLineYOffset(block.startLine + 1, hasActiveFolds);
      }

      double yBottom;
      if (!lineWrap && !hasActiveFolds) {
        yBottom = (block.endLine - 1) * _lineHeight + _lineHeight;
      } else {
        yBottom = _getLineYOffset(block.endLine, hasActiveFolds);
      }

      final screenYTop =
          offset.dy +
          (innerPadding?.top ?? 0) +
          yTop -
          vscrollController.offset;
      final screenYBottom =
          offset.dy +
          (innerPadding?.top ?? 0) +
          yBottom -
          vscrollController.offset;

      if (screenYBottom < 0 || screenYTop > viewBottom - viewTop) continue;

      final screenGuideX = isRTL
          ? offset.dx +
                size.width -
                _gutterWidth -
                (innerPadding?.right ?? 0) -
                block.guideX -
                (lineWrap ? 0 : _effectiveHScroll)
          : offset.dx +
                _gutterWidth +
                (innerPadding?.left ?? 0) +
                block.guideX -
                (lineWrap ? 0 : _effectiveHScroll);

      if (isRTL) {
        if (screenGuideX > offset.dx + size.width - _gutterWidth ||
            screenGuideX < offset.dx) {
          continue;
        }
      } else {
        if (screenGuideX < offset.dx + _gutterWidth ||
            screenGuideX > offset.dx + size.width) {
          continue;
        }
      }

      final clampedYTop = screenYTop.clamp(0.0, viewBottom - viewTop);
      final clampedYBottom = screenYBottom.clamp(0.0, viewBottom - viewTop);

      canvas.drawLine(
        Offset(screenGuideX, clampedYTop),
        Offset(screenGuideX, clampedYBottom),
        guidePaint,
      );
    }
  }

  void _shiftLineKeyedCache<T>(Map<int, T> cache, int shiftStart, int delta) {
    if (delta == 0) return;
    final entries = cache.entries.toList();
    cache.clear();
    for (final entry in entries) {
      if (entry.key >= shiftStart) {
        final newKey = entry.key + delta;
        if (newKey >= 0) cache[newKey] = entry.value;
      } else {
        cache[entry.key] = entry.value;
      }
    }
  }

  void _pruneViewportCaches(int firstVisibleLine, int lastVisibleLine) {
    const int keepMargin = 400;
    const int maxLineBoundedCacheEntries = 3000;

    final minKeep = max(0, firstVisibleLine - keepMargin);
    final maxKeep = min(controller.lineCount - 1, lastVisibleLine + keepMargin);

    bool shouldPrune(Map<int, dynamic> cache) {
      return cache.length > maxLineBoundedCacheEntries;
    }

    void pruneIntKeyed(Map<int, dynamic> cache) {
      if (!shouldPrune(cache)) return;
      cache.removeWhere((line, _) => line < minKeep || line > maxKeep);
    }

    pruneIntKeyed(_lineTextCache);
    pruneIntKeyed(_lineWidthCache);
    pruneIntKeyed(_lineHeightCache);
    pruneIntKeyed(_paragraphCache);
    pruneIntKeyed(_lineIndentCache);
    pruneIntKeyed(_bracketCache);
    pruneIntKeyed(_caretInfoCache);

    if (_indentGuideCache.length > maxLineBoundedCacheEntries) {
      _indentGuideCache.removeWhere(
        (line, _) => line < minKeep || line > maxKeep,
      );
    }
  }

  void _drawBracketHighlight(
    Canvas canvas,
    Offset offset,
    double viewTop,
    double viewBottom,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
    Color textColor,
  ) {
    if (!controller.selection.isValid || !controller.selection.isCollapsed) {
      return;
    }

    if (_suspendBracketHighlight) {
      return;
    }

    if (controller.dirtyRegion != null) {
      return;
    }

    final (bracket1, bracket2) = _getBracketPairAtCursor();
    if (bracket1 == null || bracket2 == null) return;

    final line1 = controller.getLineAtOffset(bracket1);
    final line2 = controller.getLineAtOffset(bracket2);

    if (line1 >= firstVisibleLine &&
        line1 <= lastVisibleLine &&
        (!hasActiveFolds || !_isLineFolded(line1))) {
      _drawBracketBox(
        canvas,
        offset,
        bracket1,
        line1,
        hasActiveFolds,
        textColor,
      );
    }

    if (line2 >= firstVisibleLine &&
        line2 <= lastVisibleLine &&
        (!hasActiveFolds || !_isLineFolded(line2))) {
      _drawBracketBox(
        canvas,
        offset,
        bracket2,
        line2,
        hasActiveFolds,
        textColor,
      );
    }
  }

  void _drawBracketBox(
    Canvas canvas,
    Offset offset,
    int bracketOffset,
    int lineIndex,
    bool hasActiveFolds,
    Color textColor,
  ) {
    final lineStartOffset = controller.getLineStartOffset(lineIndex);
    final columnIndex = bracketOffset - lineStartOffset;

    String lineText;
    if (_lineTextCache.containsKey(lineIndex)) {
      lineText = _lineTextCache[lineIndex]!;
    } else {
      lineText = controller.getLineText(lineIndex);
      _lineTextCache[lineIndex] = lineText;
    }

    if (columnIndex < 0 || columnIndex >= lineText.length) return;

    final contentWidth =
        size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    final paragraphWidth = lineWrap
        ? _wrapWidth
        : (isRTL ? contentWidth : null);

    ui.Paragraph para;
    if (_paragraphCache.containsKey(lineIndex)) {
      para = _paragraphCache[lineIndex]!;
    } else {
      para = _buildHighlightedParagraph(
        lineIndex,
        lineText,
        width: paragraphWidth,
      );
      _paragraphCache[lineIndex] = para;
    }

    final utf16Col = CodeForgeController.scalarToUtf16Offset(
      lineText,
      columnIndex,
    );
    final boxes = para.getBoxesForRange(utf16Col, utf16Col + 1);
    if (boxes.isEmpty) return;

    final box = boxes.first;

    final lineY = _getLineYOffset(lineIndex, hasActiveFolds);
    final boxY = lineY + box.top;
    final colorBoxOffset = _getColorBoxOffsetForLine(lineIndex, columnIndex);

    final scroll = lineWrap ? 0.0 : _effectiveHScroll;
    final textX = isRTL
        ? (innerPadding?.left ?? 0) - scroll
        : _gutterWidth + (innerPadding?.left ?? 0) - scroll;
    final screenX = offset.dx + textX + box.left + colorBoxOffset;
    final screenY =
        offset.dy + (innerPadding?.top ?? 0) + boxY - vscrollController.offset;

    final bracketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        screenX - 1.5,
        screenY - 1,
        box.right - box.left + 3,
        _lineHeight + 2.5,
      ),
      Radius.circular(2),
    );

    _bracketHighlightPainter.color = textColor;
    canvas.drawRRect(bracketRect, _bracketHighlightPainter);
  }

  void _drawDiagnostics(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    if (_diagnostics.isEmpty) return;

    final sortedDiagnostics = List<LspErrors>.from(_diagnostics)
      ..sort((a, b) => (b.severity).compareTo(a.severity));

    for (final diagnostic in sortedDiagnostics) {
      final range = diagnostic.range;
      final startPos = range['start'] as Map<String, dynamic>;
      final endPos = range['end'] as Map<String, dynamic>;
      final startLine = startPos['line'] as int;
      final startChar = startPos['character'] as int;
      final endLine = endPos['line'] as int;
      final endChar = endPos['character'] as int;

      if (endLine < firstVisibleLine || startLine > lastVisibleLine) continue;

      final Color underlineColor;
      switch (diagnostic.severity) {
        case 1:
          underlineColor = Colors.red;
          break;
        case 2:
          underlineColor = Colors.yellow.shade700;
          break;
        case 3:
          underlineColor = Colors.blue;
          break;
        case 4:
          underlineColor = Colors.grey;
          break;
        default:
          underlineColor = Colors.red;
      }

      final paint = Paint()
        ..color = underlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int lineIndex = startLine; lineIndex <= endLine; lineIndex++) {
        if (lineIndex < firstVisibleLine || lineIndex > lastVisibleLine) {
          continue;
        }
        if (hasActiveFolds && _isLineFolded(lineIndex)) continue;

        String lineText;
        if (_lineTextCache.containsKey(lineIndex)) {
          lineText = _lineTextCache[lineIndex]!;
        } else {
          lineText = controller.getLineText(lineIndex);
          _lineTextCache[lineIndex] = lineText;
        }

        if (lineText.isEmpty) continue;

        ui.Paragraph para;
        if (_paragraphCache.containsKey(lineIndex)) {
          para = _paragraphCache[lineIndex]!;
        } else {
          para = _buildHighlightedParagraph(
            lineIndex,
            lineText,
            width: lineWrap ? _wrapWidth : null,
          );
          _paragraphCache[lineIndex] = para;
        }

        final lineStartChar = ((lineIndex == startLine) ? startChar : 0).clamp(
          0,
          lineText.length,
        );
        int lineEndChar = ((lineIndex == endLine) ? endChar : lineText.length)
            .clamp(0, lineText.length);

        if (lineStartChar >= lineText.length) {
          continue;
        }

        if (lineStartChar >= lineEndChar) {
          lineEndChar = (lineStartChar + 1).clamp(0, lineText.length);
          if (lineStartChar >= lineEndChar) {
            continue;
          }
        }

        final boxKey = '$lineIndex-$lineStartChar-$lineEndChar';
        final utf16Start = CodeForgeController.scalarToUtf16Offset(
          lineText,
          lineStartChar,
        );
        final utf16End = CodeForgeController.scalarToUtf16Offset(
          lineText,
          lineEndChar,
        );
        final boxes = _diagnosticPathCache.containsKey(boxKey)
            ? _diagnosticPathCache[boxKey] as List<ui.TextBox>
            : para.getBoxesForRange(utf16Start, utf16End);
        if (!_diagnosticPathCache.containsKey(boxKey)) {
          _diagnosticPathCache[boxKey] = boxes;
        }

        if (boxes.isEmpty) continue;

        final lineY = _getLineYOffset(lineIndex, hasActiveFolds);

        for (final box in boxes) {
          final screenX = isRTL
              ? offset.dx +
                    size.width -
                    _gutterWidth -
                    (innerPadding?.right ?? 0) -
                    box.right +
                    (lineWrap ? 0 : _effectiveHScroll)
              : offset.dx +
                    _gutterWidth +
                    (innerPadding?.left ?? 0) +
                    box.left -
                    (lineWrap ? 0 : _effectiveHScroll);
          final screenY =
              offset.dy +
              (innerPadding?.top ?? 0) +
              lineY +
              box.top +
              _lineHeight -
              vscrollController.offset;

          final width = box.right - box.left;
          _drawSquigglyLine(canvas, screenX, screenY, width, paint);
        }
      }
    }
  }

  void _drawSquigglyLine(
    Canvas canvas,
    double x,
    double y,
    double width,
    Paint paint,
  ) {
    if (width <= 0) return;

    final path = Path();
    const waveHeight = 2.0;
    const waveWidth = 4.0;

    path.moveTo(x, y);

    double currentX = x;
    bool up = true;

    while (currentX < x + width) {
      final nextX = (currentX + waveWidth).clamp(x, x + width);
      final controlY = up ? y - waveHeight : y + waveHeight;

      path.quadraticBezierTo((currentX + nextX) / 2, controlY, nextX, y);

      currentX = nextX;
      up = !up;
    }

    canvas.drawPath(path, paint);
  }

  void _drawSearchHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final highlights = controller.searchHighlights;
    if (highlights.isEmpty) return;

    for (final highlight in highlights) {
      final start = highlight.start;
      final end = highlight.end;

      int startLine = controller.getLineAtOffset(start);
      int endLine = controller.getLineAtOffset(end);

      if (endLine < firstVisibleLine || startLine > lastVisibleLine) continue;

      final highlightStyle = highlight.isCurrentMatch
          ? (_matchHighlightStyle?.currentMatchStyle ??
                const TextStyle(backgroundColor: Color(0xFF01A2FF)))
          : (_matchHighlightStyle?.otherMatchStyle ??
                const TextStyle(
                  backgroundColor: Color.fromARGB(163, 72, 215, 255),
                ));

      final highlightPaint = Paint()
        ..color = highlightStyle.backgroundColor ?? Colors.amberAccent
        ..style = PaintingStyle.fill;

      for (int lineIndex = startLine; lineIndex <= endLine; lineIndex++) {
        if (lineIndex < firstVisibleLine || lineIndex > lastVisibleLine) {
          continue;
        }
        if (hasActiveFolds && _isLineFolded(lineIndex)) continue;

        final lineStartOffset = controller.getLineStartOffset(lineIndex);
        final lineText = controller.getLineText(lineIndex);
        final lineLength = lineText.length;

        int lineSelStart = 0;
        int lineSelEnd = lineLength;

        if (lineIndex == startLine) {
          lineSelStart = start - lineStartOffset;
        }
        if (lineIndex == endLine) {
          lineSelEnd = end - lineStartOffset;
        }

        lineSelStart = lineSelStart.clamp(0, lineLength);
        lineSelEnd = lineSelEnd.clamp(0, lineLength);

        if (lineSelStart >= lineSelEnd) continue;

        final contentWidth =
            size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
        final paragraphWidth = lineWrap
            ? _wrapWidth
            : (isRTL ? contentWidth : null);

        ui.Paragraph para;
        if (_paragraphCache.containsKey(lineIndex) &&
            _lineTextCache[lineIndex] == lineText &&
            !isRTL) {
          para = _paragraphCache[lineIndex]!;
        } else {
          para = _buildHighlightedParagraph(
            lineIndex,
            lineText,
            width: paragraphWidth,
          );
          if (!isRTL) {
            _lineTextCache[lineIndex] = lineText;
            _paragraphCache[lineIndex] = para;
          }
        }

        final lineY = _getLineYOffset(lineIndex, hasActiveFolds);

        final scroll = lineWrap ? 0.0 : _effectiveHScroll;
        final textX = isRTL
            ? (innerPadding?.left ?? 0) - scroll
            : _gutterWidth + (innerPadding?.left ?? 0) - scroll;

        if (lineText.isNotEmpty) {
          final boxKey = '$lineIndex-$lineSelStart-$lineSelEnd';
          final utf16Start = CodeForgeController.scalarToUtf16Offset(
            lineText,
            lineSelStart,
          );
          final utf16End = CodeForgeController.scalarToUtf16Offset(
            lineText,
            lineSelEnd,
          );
          final boxes = para.getBoxesForRange(utf16Start, utf16End);
          if (!_searchHighlightCache.containsKey(boxKey)) {
            _searchHighlightCache[boxKey] = boxes;
          }

          for (final box in boxes) {
            final screenX = offset.dx + textX + box.left;
            final screenY =
                offset.dy +
                (innerPadding?.top ?? 0) +
                lineY +
                box.top -
                vscrollController.offset;

            canvas.drawRect(
              Rect.fromLTWH(
                screenX,
                screenY,
                box.right - box.left,
                _lineHeight,
              ),
              highlightPaint,
            );
          }
        }
      }
    }
  }

  void _drawFoldedLineHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    if (!hasActiveFolds) return;

    final highlightColor =
        gutterStyle.foldedLineHighlightColor ??
        selectionStyle.selectionColor.withAlpha(60);

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    for (final foldRange in controller.foldings.values.where(
      (f) => f != null,
    )) {
      if (!foldRange!.isFolded) continue;

      final foldStartLine = foldRange.startIndex;

      if (foldStartLine < firstVisibleLine || foldStartLine > lastVisibleLine) {
        continue;
      }

      final lineY = _getLineYOffset(foldStartLine, hasActiveFolds);
      final lineHeight = lineWrap
          ? _getWrappedLineHeight(foldStartLine)
          : _lineHeight;

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          lineY -
          vscrollController.offset;

      final highlightX = isRTL ? offset.dx : offset.dx + _gutterWidth;
      final highlightWidth = size.width - _gutterWidth;

      canvas.drawRect(
        Rect.fromLTWH(highlightX, screenY, highlightWidth, lineHeight),
        highlightPaint,
      );
    }
  }

  void _drawSelection(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final selection = controller.selection;
    if (selection.isCollapsed) return;

    final start = selection.start;
    final end = selection.end;

    final selectionPaint = Paint()
      ..color = selectionStyle.selectionColor
      ..style = PaintingStyle.fill;

    int startLine = controller.getLineAtOffset(start);
    int endLine = controller.getLineAtOffset(end);

    if (endLine < firstVisibleLine || startLine > lastVisibleLine) return;

    for (int lineIndex = startLine; lineIndex <= endLine; lineIndex++) {
      if (lineIndex < firstVisibleLine || lineIndex > lastVisibleLine) continue;
      if (hasActiveFolds && _isLineFolded(lineIndex)) continue;

      final lineStartOffset = controller.getLineStartOffset(lineIndex);
      final lineText =
          _lineTextCache[lineIndex] ?? controller.getLineText(lineIndex);
      final lineLength = lineText.length;

      int lineSelStart = 0;
      int lineSelEnd = lineLength;

      if (lineIndex == startLine) {
        lineSelStart = start - lineStartOffset;
      }
      if (lineIndex == endLine) {
        lineSelEnd = end - lineStartOffset;
      }

      lineSelStart = lineSelStart.clamp(0, lineLength);
      lineSelEnd = lineSelEnd.clamp(0, lineLength);

      if (lineSelStart >= lineSelEnd && lineIndex != endLine) {
        lineSelEnd = lineLength;
      }

      final contentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final paragraphWidth = lineWrap
          ? _wrapWidth
          : (isRTL ? contentWidth : null);

      ui.Paragraph para;
      if (_paragraphCache.containsKey(lineIndex)) {
        para = _paragraphCache[lineIndex]!;
      } else {
        para = _buildHighlightedParagraph(
          lineIndex,
          lineText,
          width: paragraphWidth,
        );
        _paragraphCache[lineIndex] = para;
      }

      final lineY = _getLineYOffset(lineIndex, hasActiveFolds);
      final visualYOffset = _getTotalVirtualOffset(lineIndex);

      final colorBoxOffsetStart = _getColorBoxOffsetForLine(
        lineIndex,
        lineSelStart,
      );
      final colorBoxOffsetEnd = _getColorBoxOffsetForLine(
        lineIndex,
        lineSelEnd,
      );

      final scroll = lineWrap ? 0.0 : _effectiveHScroll;
      final textX = isRTL
          ? (innerPadding?.left ?? 0) - scroll
          : _gutterWidth + (innerPadding?.left ?? 0) - scroll;

      if (lineSelStart < lineSelEnd && lineText.isNotEmpty) {
        final utf16Start = CodeForgeController.scalarToUtf16Offset(
          lineText,
          lineSelStart,
        );
        final utf16End = CodeForgeController.scalarToUtf16Offset(
          lineText,
          lineSelEnd,
        );
        final boxes = para.getBoxesForRange(utf16Start, utf16End);

        for (int i = 0; i < boxes.length; i++) {
          final box = boxes[i];
          final adjustedLeft = box.left + colorBoxOffsetStart;
          final adjustedRight = box.right + colorBoxOffsetEnd;

          final screenX = offset.dx + textX + adjustedLeft;
          final screenY =
              offset.dy +
              (innerPadding?.top ?? 0) +
              lineY +
              visualYOffset +
              box.top -
              vscrollController.offset;

          canvas.drawRect(
            Rect.fromLTWH(
              screenX,
              screenY,
              adjustedRight - adjustedLeft,
              _lineHeight,
            ),
            selectionPaint,
          );
        }
      } else if (lineIndex < endLine) {
        final screenX = isRTL
            ? offset.dx + textX + contentWidth - 8
            : offset.dx + textX;
        final screenY =
            offset.dy +
            (innerPadding?.top ?? 0) +
            lineY -
            visualYOffset -
            vscrollController.offset;

        canvas.drawRect(
          Rect.fromLTWH(screenX, screenY, 8, _lineHeight),
          selectionPaint,
        );
      }
    }

    _updateSelectionHandleRects(
      offset,
      start,
      end,
      startLine,
      endLine,
      hasActiveFolds,
    );
  }

  void _drawDocumentHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final highlights = controller.documentHighlights;
    if (highlights.isEmpty) return;

    final highlightPaint = Paint()
      ..color = (editorTheme['root']?.color ?? Colors.white).withValues(
        alpha: 0.2,
      )
      ..style = PaintingStyle.fill;

    for (final highlight in highlights) {
      final startLine = highlight.startLine;
      final endLine = highlight.endLine;

      if (endLine < firstVisibleLine || startLine > lastVisibleLine) continue;

      for (int lineIndex = startLine; lineIndex <= endLine; lineIndex++) {
        if (lineIndex < firstVisibleLine || lineIndex > lastVisibleLine) {
          continue;
        }
        if (hasActiveFolds && _isLineFolded(lineIndex)) continue;

        final lineText =
            _lineTextCache[lineIndex] ?? controller.getLineText(lineIndex);
        final lineLength = lineText.length;

        int lineHighStart = 0;
        int lineHighEnd = lineLength;

        if (lineIndex == startLine) {
          lineHighStart = highlight.startColumn;
        }
        if (lineIndex == endLine) {
          lineHighEnd = highlight.endColumn;
        }

        lineHighStart = lineHighStart.clamp(0, lineLength);
        lineHighEnd = lineHighEnd.clamp(0, lineLength);

        if (lineHighStart >= lineHighEnd) continue;

        final contentWidth =
            size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
        final paragraphWidth = lineWrap
            ? _wrapWidth
            : (isRTL ? contentWidth : null);

        ui.Paragraph para;
        if (_paragraphCache.containsKey(lineIndex)) {
          para = _paragraphCache[lineIndex]!;
        } else {
          para = _buildHighlightedParagraph(
            lineIndex,
            lineText,
            width: paragraphWidth,
          );
        }

        final lineY = _getLineYOffset(lineIndex, hasActiveFolds);
        final colorBoxOffset = _getColorBoxOffsetForLine(
          lineIndex,
          lineHighStart,
        );
        final utf16Start = CodeForgeController.scalarToUtf16Offset(
          lineText,
          lineHighStart,
        );
        final utf16End = CodeForgeController.scalarToUtf16Offset(
          lineText,
          lineHighEnd,
        );
        final boxes = para.getBoxesForRange(utf16Start, utf16End);

        final scroll = lineWrap ? 0.0 : _effectiveHScroll;
        final textX = isRTL
            ? (innerPadding?.left ?? 0) - scroll
            : _gutterWidth + (innerPadding?.left ?? 0) - scroll;

        for (final box in boxes) {
          final adjustedLeft = box.left + colorBoxOffset;
          final adjustedRight = box.right + colorBoxOffset;

          final screenX = offset.dx + textX + adjustedLeft;
          final screenY =
              offset.dy +
              (innerPadding?.top ?? 0) +
              lineY +
              box.top -
              vscrollController.offset;

          canvas.drawRect(
            Rect.fromLTWH(
              screenX,
              screenY,
              adjustedRight - adjustedLeft,
              box.bottom - box.top,
            ),
            highlightPaint,
          );
        }
      }
    }
  }

  void _updateSelectionHandleRects(
    Offset offset,
    int start,
    int end,
    int startLine,
    int endLine,
    bool hasActiveFolds,
  ) {
    final handleRadius = (_lineHeight / 2).clamp(6.0, 12.0);
    final contentWidth =
        size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    final paragraphWidth = lineWrap
        ? _wrapWidth
        : (isRTL ? contentWidth : null);
    final scroll = lineWrap ? 0.0 : _effectiveHScroll;
    final textX = isRTL
        ? (innerPadding?.left ?? 0) - scroll
        : _gutterWidth + (innerPadding?.left ?? 0) - scroll;

    final startLineOffset = controller.getLineStartOffset(startLine);
    final startLineText =
        _lineTextCache[startLine] ?? controller.getLineText(startLine);
    final startCol = start - startLineOffset;

    final startY = _getLineYOffset(startLine, hasActiveFolds);
    final startVisualYOffset = _getTotalVirtualOffset(startLine);

    double startX;
    double startYInLine = 0;
    if (startLineText.isNotEmpty) {
      final para =
          _paragraphCache[startLine] ??
          _buildHighlightedParagraph(
            startLine,
            startLineText,
            width: paragraphWidth,
          );
      final utf16Col = CodeForgeController.scalarToUtf16Offset(
        startLineText,
        startCol,
      );
      final clampedCol = utf16Col.clamp(0, startLineText.length);
      final paragraphOffset = isRTL
          ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
          : 0.0;

      final pos = _getCaretPositionForColumn(
        para,
        startLineText,
        clampedCol,
        paragraphOffset,
        contentWidth,
      );
      startX = pos.x;
      startYInLine = pos.yInLine;
    } else {
      startX = isRTL ? contentWidth : 0.0;
    }

    startX += _getColorBoxOffsetForLine(startLine, startCol);

    final startScreenX = offset.dx + textX + startX;
    final startScreenY =
        offset.dy +
        (innerPadding?.top ?? 0) +
        startY +
        startVisualYOffset +
        startYInLine -
        vscrollController.offset;

    _startHandleRect = Rect.fromCenter(
      center: Offset(
        isRTL
            ? startScreenX + (textStyle?.fontSize ?? 14) / 2
            : startScreenX - (textStyle?.fontSize ?? 14) / 2,
        startScreenY + _lineHeight + handleRadius,
      ),
      width: handleRadius * 2 * 1.2,
      height: handleRadius * 2 * 1.2,
    );

    final endLineOffset = controller.getLineStartOffset(endLine);
    final endLineText =
        _lineTextCache[endLine] ?? controller.getLineText(endLine);
    final endCol = end - endLineOffset;

    final endY = _getLineYOffset(endLine, hasActiveFolds);
    final endVisualYOffset = _getTotalVirtualOffset(endLine);

    double endX;
    double endYInLine = 0;
    if (endLineText.isNotEmpty) {
      final para =
          _paragraphCache[endLine] ??
          _buildHighlightedParagraph(
            endLine,
            endLineText,
            width: paragraphWidth,
          );
      final utf16Col = CodeForgeController.scalarToUtf16Offset(
        endLineText,
        endCol,
      );
      final clampedCol = utf16Col.clamp(0, endLineText.length);
      final paragraphOffset = isRTL
          ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
          : 0.0;

      final pos = _getCaretPositionForColumn(
        para,
        endLineText,
        clampedCol,
        paragraphOffset,
        contentWidth,
      );
      endX = pos.x;
      endYInLine = pos.yInLine;
    } else {
      endX = isRTL ? contentWidth : 0.0;
    }

    endX += _getColorBoxOffsetForLine(endLine, endCol);

    final endScreenX = offset.dx + textX + endX;
    final endScreenY =
        offset.dy +
        (innerPadding?.top ?? 0) +
        endY +
        endVisualYOffset +
        endYInLine -
        vscrollController.offset;

    _endHandleRect = Rect.fromCenter(
      center: Offset(
        isRTL
            ? endScreenX - (textStyle?.fontSize ?? 14) / 2
            : endScreenX + (textStyle?.fontSize ?? 14) / 2,
        endScreenY + _lineHeight + handleRadius,
      ),
      width: handleRadius * 2 * 1.2,
      height: handleRadius * 2 * 1.2,
    );
  }

  void _drawAiGhostText(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    if (_aiResponse == null || _aiResponse!.isEmpty) return;
    if (_ghostTextAnchorLine == null) return;
    if (!controller.selection.isValid || !controller.selection.isCollapsed) {
      return;
    }

    final cursorOffset = controller.selection.extentOffset;
    final cursorLine = _ghostTextAnchorLine!;

    if (hasActiveFolds && _isLineFolded(cursorLine)) return;

    final lineStartOffset = controller.getLineStartOffset(cursorLine);
    final cursorCol = cursorOffset - lineStartOffset;

    final lineText =
        _lineTextCache[cursorLine] ?? controller.getLineText(cursorLine);

    double cursorX;
    double cursorYInLine = 0;
    if (lineText.isNotEmpty) {
      final para =
          _paragraphCache[cursorLine] ??
          _buildHighlightedParagraph(
            cursorLine,
            lineText,
            width: lineWrap ? _wrapWidth : null,
          );
      final utf16CursorCol = CodeForgeController.scalarToUtf16Offset(
        lineText,
        cursorCol,
      );
      final clampedCol = utf16CursorCol.clamp(0, lineText.length);

      final contentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final paragraphWidth = lineWrap
          ? _wrapWidth
          : (isRTL ? max(contentWidth * 3, 10000.0) : null);
      final paragraphOffset = isRTL
          ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
          : 0.0;

      final pos = _getCaretPositionForColumn(
        para,
        lineText,
        clampedCol,
        paragraphOffset,
        contentWidth,
      );
      cursorX = pos.x;
      cursorYInLine = pos.yInLine;
    } else {
      cursorX = 0;
    }

    final cursorY = _getLineYOffset(cursorLine, hasActiveFolds) + cursorYInLine;

    final defaultGhostColor =
        (textStyle?.color ?? editorTheme['root']?.color ?? Colors.white)
            .withAlpha(100);
    final ghostStyle = ui.TextStyle(
      color: _ghostTextStyle?.color ?? defaultGhostColor,
      fontSize: _ghostTextStyle?.fontSize ?? textStyle?.fontSize ?? 14.0,
      fontFamily: _ghostTextStyle?.fontFamily ?? textStyle?.fontFamily,
      fontStyle: _ghostTextStyle?.fontStyle ?? FontStyle.italic,
      fontWeight: _ghostTextStyle?.fontWeight,
      letterSpacing: _ghostTextStyle?.letterSpacing,
      wordSpacing: _ghostTextStyle?.wordSpacing,
      decoration: _ghostTextStyle?.decoration,
      decorationColor: _ghostTextStyle?.decorationColor,
    );

    final aiLines = _aiResponse?.split('\n') ?? [];
    final isSingleLineGhost = aiLines.length == 1;
    final utf16CursorCol = CodeForgeController.scalarToUtf16Offset(
      lineText,
      cursorCol,
    );
    final clampedCol = utf16CursorCol.clamp(0, lineText.length);

    if (isSingleLineGhost && aiLines.isNotEmpty && aiLines[0].isNotEmpty) {
      final ghostBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontFamily: textStyle?.fontFamily,
                fontSize: textStyle?.fontSize ?? 14.0,
                height: textStyle?.height ?? 1.2,
                textDirection: textDirection,
              ),
            )
            ..pushStyle(ghostStyle)
            ..addText(aiLines[0]);
      final ghostPara = ghostBuilder.build();
      ghostPara.layout(const ui.ParagraphConstraints(width: double.infinity));
      final firstLineGhostWidth = ghostPara.longestLine;

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          cursorY -
          vscrollController.offset;

      final screenX = isRTL
          ? offset.dx +
                size.width -
                _gutterWidth -
                (innerPadding?.right ?? 0) -
                cursorX +
                (lineWrap ? 0 : _effectiveHScroll) -
                firstLineGhostWidth
          : offset.dx +
                _gutterWidth +
                (innerPadding?.left ?? 0) +
                cursorX -
                (lineWrap ? 0 : _effectiveHScroll);

      final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
      final originalPara = _paragraphCache[cursorLine];
      if (originalPara != null && clampedCol < lineText.length) {
        final remainingWidth = originalPara.longestLine - cursorX;
        if (remainingWidth > 0) {
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, remainingWidth + 2, _lineHeight),
            Paint()..color = bgColor,
          );
        }
      }

      canvas.drawParagraph(ghostPara, Offset(screenX, screenY));

      if (clampedCol < lineText.length) {
        final remainingText = lineText.substring(clampedCol);

        final normalStyle = ui.TextStyle(
          color: textStyle?.color ?? editorTheme['root']?.color ?? Colors.white,
          fontSize: textStyle?.fontSize ?? 14.0,
          fontFamily: textStyle?.fontFamily,
          fontWeight: textStyle?.fontWeight,
        );

        final remainingBuilder =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  fontFamily: textStyle?.fontFamily,
                  fontSize: textStyle?.fontSize ?? 14.0,
                  height: textStyle?.height ?? 1.2,
                ),
              )
              ..pushStyle(normalStyle)
              ..addText(remainingText);

        final remainingPara = remainingBuilder.build();
        remainingPara.layout(
          const ui.ParagraphConstraints(width: double.infinity),
        );

        canvas.drawParagraph(
          remainingPara,
          Offset(screenX + firstLineGhostWidth, screenY),
        );
      }
      return;
    }

    if (aiLines.isNotEmpty && aiLines[0].isNotEmpty) {
      final ghostBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontFamily: textStyle?.fontFamily,
                fontSize: textStyle?.fontSize ?? 14.0,
                height: textStyle?.height ?? 1.2,
                textDirection: textDirection,
              ),
            )
            ..pushStyle(ghostStyle)
            ..addText(aiLines[0]);
      final ghostPara = ghostBuilder.build();
      ghostPara.layout(const ui.ParagraphConstraints(width: double.infinity));
      final firstGhostWidth = ghostPara.longestLine;

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          cursorY -
          vscrollController.offset;

      final screenX = isRTL
          ? offset.dx +
                size.width -
                _gutterWidth -
                (innerPadding?.right ?? 0) -
                cursorX +
                (lineWrap ? 0 : _effectiveHScroll) -
                firstGhostWidth
          : offset.dx +
                _gutterWidth +
                (innerPadding?.left ?? 0) +
                cursorX -
                (lineWrap ? 0 : _effectiveHScroll);

      final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
      final originalPara = _paragraphCache[cursorLine];
      if (originalPara != null && clampedCol < lineText.length) {
        final remainingWidth = originalPara.longestLine - cursorX;
        if (remainingWidth > 0) {
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, remainingWidth + 2, _lineHeight),
            Paint()..color = bgColor,
          );
        }
      }

      canvas.drawParagraph(ghostPara, Offset(screenX, screenY));
    }

    double lastGhostLineWidth = 0;
    double lastGhostLineScreenY = 0;
    double lastGhostLineScreenX = 0;

    for (int i = 1; i < aiLines.length; i++) {
      final aiLineText = aiLines[i];
      final isLastLine = i == aiLines.length - 1;

      final lineY = cursorY + (i * _lineHeight);

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          lineY -
          vscrollController.offset;

      ui.Paragraph? para;
      double paraWidth = 0;
      if (aiLineText.isNotEmpty || isLastLine) {
        final builder =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  fontFamily: textStyle?.fontFamily,
                  fontSize: textStyle?.fontSize ?? 14.0,
                  height: textStyle?.height ?? 1.2,
                  textDirection: textDirection,
                ),
              )
              ..pushStyle(ghostStyle)
              ..addText(aiLineText);

        para = builder.build();
        para.layout(const ui.ParagraphConstraints(width: double.infinity));
        paraWidth = para.longestLine;
      }

      final screenX = isRTL
          ? offset.dx +
                size.width -
                _gutterWidth -
                (innerPadding?.right ?? 0) +
                (lineWrap ? 0 : _effectiveHScroll) -
                paraWidth
          : offset.dx +
                _gutterWidth +
                (innerPadding?.left ?? 0) -
                (lineWrap ? 0 : _effectiveHScroll);

      if (screenY + _lineHeight < offset.dy ||
          screenY > offset.dy + vscrollController.position.viewportDimension) {
        if (isLastLine) {
          lastGhostLineScreenY = screenY;
          lastGhostLineScreenX = screenX;
          lastGhostLineWidth = paraWidth;
        }
        continue;
      }

      if (para != null) {
        canvas.drawParagraph(para, Offset(screenX, screenY));

        if (isLastLine) {
          lastGhostLineWidth = paraWidth;
          lastGhostLineScreenY = screenY;
          lastGhostLineScreenX = screenX;
        }
      }
    }

    if (clampedCol < lineText.length && aiLines.length > 1) {
      final remainingText = lineText.substring(clampedCol);

      final normalStyle = ui.TextStyle(
        color: textStyle?.color ?? editorTheme['root']?.color ?? Colors.white,
        fontSize: textStyle?.fontSize ?? 14.0,
        fontFamily: textStyle?.fontFamily,
        fontWeight: textStyle?.fontWeight,
      );

      final remainingBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontFamily: textStyle?.fontFamily,
                fontSize: textStyle?.fontSize ?? 14.0,
                height: textStyle?.height ?? 1.2,
              ),
            )
            ..pushStyle(normalStyle)
            ..addText(remainingText);

      final remainingPara = remainingBuilder.build();
      remainingPara.layout(
        const ui.ParagraphConstraints(width: double.infinity),
      );

      canvas.drawParagraph(
        remainingPara,
        Offset(lastGhostLineScreenX + lastGhostLineWidth, lastGhostLineScreenY),
      );
    }
  }

  void _drawLineDecorations(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final decorations = controller.lineDecorations;
    if (decorations.isEmpty) return;

    for (final decoration in decorations) {
      if (decoration.endLine < firstVisibleLine ||
          decoration.startLine > lastVisibleLine) {
        continue;
      }

      final paint = Paint()
        ..color = decoration.color
        ..style = PaintingStyle.fill;

      double currentY = firstVisibleLineY;
      for (
        int i = firstVisibleLine;
        i <= lastVisibleLine && i < controller.lineCount;
        i++
      ) {
        if (hasActiveFolds && _isLineFolded(i)) continue;

        final lineHeight = lineWrap ? _getWrappedLineHeight(i) : _lineHeight;
        final visualYOffset = _getTotalVirtualOffset(i);

        if (i >= decoration.startLine && i <= decoration.endLine) {
          final screenY =
              offset.dy +
              (innerPadding?.top ?? 0) +
              currentY +
              visualYOffset -
              vscrollController.offset;
          final screenX =
              offset.dx +
              _gutterWidth +
              (innerPadding?.left ?? 0) -
              (lineWrap ? 0 : _effectiveHScroll);

          switch (decoration.type) {
            case LineDecorationType.background:
              final width =
                  size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
              canvas.drawRect(
                Rect.fromLTWH(screenX, screenY, width, lineHeight),
                paint,
              );
              break;

            case LineDecorationType.leftBorder:
              paint.style = PaintingStyle.fill;
              canvas.drawRect(
                Rect.fromLTWH(
                  offset.dx + _gutterWidth,
                  screenY,
                  decoration.thickness,
                  lineHeight,
                ),
                paint,
              );
              break;

            case LineDecorationType.underline:
              paint.style = PaintingStyle.stroke;
              paint.strokeWidth = decoration.thickness;
              final width =
                  size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
              canvas.drawLine(
                Offset(screenX, screenY + lineHeight - decoration.thickness),
                Offset(
                  screenX + width,
                  screenY + lineHeight - decoration.thickness,
                ),
                paint,
              );
              break;

            case LineDecorationType.wavyUnderline:
              paint.style = PaintingStyle.stroke;
              paint.strokeWidth = decoration.thickness;
              final width =
                  size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
              final path = Path();
              final waveHeight = decoration.thickness * 2;
              final waveWidth = waveHeight * 2;
              double x = screenX;
              final y = screenY + lineHeight - decoration.thickness;
              path.moveTo(x, y);
              while (x < screenX + width) {
                path.quadraticBezierTo(
                  x + waveWidth / 4,
                  y - waveHeight,
                  x + waveWidth / 2,
                  y,
                );
                path.quadraticBezierTo(
                  x + waveWidth * 3 / 4,
                  y + waveHeight,
                  x + waveWidth,
                  y,
                );
                x += waveWidth;
              }
              canvas.drawPath(path, paint);
              break;
          }
        }

        currentY += lineHeight;
      }
    }
  }

  void _drawLineHighlight(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    if (_highlightedLine == null || _lineHighlightAnimation == null) return;

    final highlightLine = _highlightedLine!;

    if (highlightLine < firstVisibleLine || highlightLine > lastVisibleLine) {
      return;
    }

    if (hasActiveFolds && _isLineFolded(highlightLine)) return;

    final opacity = _lineHighlightAnimation!.value;
    if (opacity <= 0.0) {
      _highlightedLine = null;
      return;
    }

    final lineY = _getLineYOffset(highlightLine, hasActiveFolds);
    final lineHeight = lineWrap
        ? _getWrappedLineHeight(highlightLine)
        : _lineHeight;

    final screenY =
        offset.dy + (innerPadding?.top ?? 0) + lineY - vscrollController.offset;
    final screenX =
        offset.dx +
        _gutterWidth +
        (innerPadding?.left ?? 0) -
        (lineWrap ? 0 : _effectiveHScroll);

    final highlightColor =
        (textStyle?.color ?? editorTheme['root']?.color ?? Colors.yellow)
            .withValues(alpha: opacity);

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    final width = size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    canvas.drawRect(Rect.fromLTWH(screenX, screenY, width, lineHeight), paint);
  }

  void _drawGutterDecorations(
    Canvas canvas,
    Offset offset,
    int lineIndex,
    double contentTop,
    double lineHeight,
  ) {
    final decorations = controller.gutterDecorations;
    if (decorations.isEmpty) return;

    for (final decoration in decorations) {
      if (lineIndex < decoration.startLine || lineIndex > decoration.endLine) {
        continue;
      }

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          contentTop -
          vscrollController.offset;

      switch (decoration.type) {
        case GutterDecorationType.colorBar:
          final paint = Paint()
            ..color = decoration.color
            ..style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromLTWH(offset.dx, screenY, decoration.width, lineHeight),
            paint,
          );
          break;

        case GutterDecorationType.icon:
          if (decoration.icon != null) {
            final iconPainter = TextPainter(
              text: TextSpan(
                text: String.fromCharCode(decoration.icon!.codePoint),
                style: TextStyle(
                  fontSize: textStyle?.fontSize ?? 14,
                  color: decoration.color,
                  fontFamily: decoration.icon!.fontFamily,
                  package: decoration.icon!.fontPackage,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            iconPainter.layout();
            iconPainter.paint(
              canvas,
              Offset(
                offset.dx + 2,
                screenY + (lineHeight - iconPainter.height) / 2,
              ),
            );
          }
          break;

        case GutterDecorationType.dot:
          final paint = Paint()
            ..color = decoration.color
            ..style = PaintingStyle.fill;
          final radius = (textStyle?.fontSize ?? 14) / 4;
          canvas.drawCircle(
            Offset(
              offset.dx + decoration.width / 2 + 2,
              screenY + lineHeight / 2,
            ),
            radius,
            paint,
          );
          break;
      }
    }
  }

  void _drawGhostText(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final ghost = controller.ghostText;
    if (ghost == null || ghost.text.isEmpty) return;

    final cursorLine = ghost.line;
    final cursorCol = ghost.column;

    if (hasActiveFolds && _isLineFolded(cursorLine)) return;

    final lineText =
        _lineTextCache[cursorLine] ?? controller.getLineText(cursorLine);

    double cursorX;
    double cursorYInLine = 0;
    if (lineText.isNotEmpty) {
      final para =
          _paragraphCache[cursorLine] ??
          _buildHighlightedParagraph(
            cursorLine,
            lineText,
            width: lineWrap ? _wrapWidth : null,
          );
      final utf16CursorCol = CodeForgeController.scalarToUtf16Offset(
        lineText,
        cursorCol,
      );
      final clampedCol = utf16CursorCol.clamp(0, lineText.length);

      final contentWidth =
          size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
      final paragraphWidth = lineWrap
          ? _wrapWidth
          : (isRTL ? max(contentWidth * 3, 10000.0) : null);
      final paragraphOffset = isRTL
          ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
          : 0.0;

      final pos = _getCaretPositionForColumn(
        para,
        lineText,
        clampedCol,
        paragraphOffset,
        contentWidth,
      );
      cursorX = pos.x;
      cursorYInLine = pos.yInLine;
    } else {
      cursorX = 0;
    }

    final cursorY = _getLineYOffset(cursorLine, hasActiveFolds) + cursorYInLine;

    final defaultGhostColor =
        (textStyle?.color ?? editorTheme['root']?.color ?? Colors.white)
            .withAlpha(100);
    final customStyle = ghost.style;
    final ghostStyle = ui.TextStyle(
      color: customStyle?.color ?? defaultGhostColor,
      fontSize: customStyle?.fontSize ?? textStyle?.fontSize ?? 14.0,
      fontFamily: customStyle?.fontFamily ?? textStyle?.fontFamily,
      fontStyle: customStyle?.fontStyle ?? FontStyle.italic,
      fontWeight: customStyle?.fontWeight,
      letterSpacing: customStyle?.letterSpacing,
      wordSpacing: customStyle?.wordSpacing,
      decoration: customStyle?.decoration,
      decorationColor: customStyle?.decorationColor,
    );

    final ghostLines = ghost.text.split('\n');
    final isSingleLineGhost = ghostLines.length == 1;

    double firstLineGhostWidth = 0;
    if (isSingleLineGhost && ghostLines[0].isNotEmpty) {
      final ghostBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontFamily: textStyle?.fontFamily,
                fontSize: textStyle?.fontSize ?? 14.0,
                height: textStyle?.height ?? 1.2,
              ),
            )
            ..pushStyle(ghostStyle)
            ..addText(ghostLines[0]);
      final ghostPara = ghostBuilder.build();
      ghostPara.layout(const ui.ParagraphConstraints(width: double.infinity));
      firstLineGhostWidth = ghostPara.longestLine;

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          cursorY -
          vscrollController.offset;

      final screenX =
          offset.dx +
          _gutterWidth +
          (innerPadding?.left ?? 0) +
          cursorX -
          (lineWrap ? 0 : _effectiveHScroll);

      final clampedCol = cursorCol.clamp(0, lineText.length);
      final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
      final originalPara = _paragraphCache[cursorLine];
      if (originalPara != null && clampedCol < lineText.length) {
        final remainingWidth = originalPara.longestLine - cursorX;
        if (remainingWidth > 0) {
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, remainingWidth + 2, _lineHeight),
            Paint()..color = bgColor,
          );
        }
      }

      canvas.drawParagraph(ghostPara, Offset(screenX, screenY));

      if (clampedCol < lineText.length) {
        final remainingText = lineText.substring(clampedCol);

        final normalStyle = ui.TextStyle(
          color: textStyle?.color ?? editorTheme['root']?.color ?? Colors.white,
          fontSize: textStyle?.fontSize ?? 14.0,
          fontFamily: textStyle?.fontFamily,
          fontWeight: textStyle?.fontWeight,
        );

        final remainingBuilder =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  fontFamily: textStyle?.fontFamily,
                  fontSize: textStyle?.fontSize ?? 14.0,
                  height: textStyle?.height ?? 1.2,
                ),
              )
              ..pushStyle(normalStyle)
              ..addText(remainingText);

        final remainingPara = remainingBuilder.build();
        remainingPara.layout(
          const ui.ParagraphConstraints(width: double.infinity),
        );

        canvas.drawParagraph(
          remainingPara,
          Offset(screenX + firstLineGhostWidth, screenY),
        );
      }
      return;
    }

    final multiClampedCol = cursorCol.clamp(0, lineText.length);

    if (ghostLines.isNotEmpty && ghostLines[0].isNotEmpty) {
      final ghostBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontFamily: textStyle?.fontFamily,
                fontSize: textStyle?.fontSize ?? 14.0,
                height: textStyle?.height ?? 1.2,
              ),
            )
            ..pushStyle(ghostStyle)
            ..addText(ghostLines[0]);
      final ghostPara = ghostBuilder.build();
      ghostPara.layout(const ui.ParagraphConstraints(width: double.infinity));

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          cursorY -
          vscrollController.offset;

      final screenX =
          offset.dx +
          _gutterWidth +
          (innerPadding?.left ?? 0) +
          cursorX -
          (lineWrap ? 0 : _effectiveHScroll);

      final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
      final originalPara = _paragraphCache[cursorLine];
      if (originalPara != null && multiClampedCol < lineText.length) {
        final remainingWidth = originalPara.longestLine - cursorX;
        if (remainingWidth > 0) {
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, remainingWidth + 2, _lineHeight),
            Paint()..color = bgColor,
          );
        }
      }

      canvas.drawParagraph(ghostPara, Offset(screenX, screenY));
    }

    double lastGhostLineWidth = 0;
    double lastGhostLineScreenY = 0;
    double lastGhostLineScreenX = 0;

    for (int i = 1; i < ghostLines.length; i++) {
      final ghostLineText = ghostLines[i];
      final isLastLine = i == ghostLines.length - 1;

      final lineY = cursorY + (i * _lineHeight);

      final screenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          lineY -
          vscrollController.offset;

      final screenX =
          offset.dx +
          _gutterWidth +
          (innerPadding?.left ?? 0) -
          (lineWrap ? 0 : _effectiveHScroll);

      if (screenY + _lineHeight < offset.dy ||
          screenY > offset.dy + vscrollController.position.viewportDimension) {
        if (isLastLine) {
          lastGhostLineScreenY = screenY;
          lastGhostLineScreenX = screenX;
        }
        continue;
      }

      if (ghostLineText.isNotEmpty || isLastLine) {
        final builder =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  fontFamily: textStyle?.fontFamily,
                  fontSize: textStyle?.fontSize ?? 14.0,
                  height: textStyle?.height ?? 1.2,
                ),
              )
              ..pushStyle(ghostStyle)
              ..addText(ghostLineText);

        final para = builder.build();
        para.layout(const ui.ParagraphConstraints(width: double.infinity));

        canvas.drawParagraph(para, Offset(screenX, screenY));

        if (isLastLine) {
          lastGhostLineWidth = para.longestLine;
          lastGhostLineScreenY = screenY;
          lastGhostLineScreenX = screenX;
        }
      }
    }

    if (multiClampedCol < lineText.length && ghostLines.length > 1) {
      final remainingText = lineText.substring(multiClampedCol);

      final normalStyle = ui.TextStyle(
        color: textStyle?.color ?? editorTheme['root']?.color ?? Colors.white,
        fontSize: textStyle?.fontSize ?? 14.0,
        fontFamily: textStyle?.fontFamily,
        fontWeight: textStyle?.fontWeight,
      );

      final remainingBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                fontFamily: textStyle?.fontFamily,
                fontSize: textStyle?.fontSize ?? 14.0,
                height: textStyle?.height ?? 1.2,
              ),
            )
            ..pushStyle(normalStyle)
            ..addText(remainingText);

      final remainingPara = remainingBuilder.build();
      remainingPara.layout(
        const ui.ParagraphConstraints(width: double.infinity),
      );

      canvas.drawParagraph(
        remainingPara,
        Offset(lastGhostLineScreenX + lastGhostLineWidth, lastGhostLineScreenY),
      );
    }
  }

  void _drawVirtualRemovedLines(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final blocks = controller.virtualRemovedBlocks;
    if (blocks.isEmpty) return;

    final viewTop = vscrollController.offset;
    final viewBottom = viewTop + vscrollController.position.viewportDimension;

    for (int blockIdx = 0; blockIdx < blocks.length; blockIdx++) {
      final block = blocks[blockIdx];
      final anchorLine = block.afterLine;

      final baseY = _getLineYOffset(
        (anchorLine + 1).clamp(0, controller.lineCount),
        hasActiveFolds,
      );

      double extraOffset = 0;
      if (_ghostTextAnchorLine != null &&
          _ghostTextLineCount > 0 &&
          (anchorLine + 1) > _ghostTextAnchorLine!) {
        extraOffset += _ghostTextLineCount * _lineHeight;
      }

      for (int j = 0; j < blockIdx; j++) {
        if ((anchorLine + 1) > blocks[j].afterLine) {
          extraOffset += blocks[j].lineCount * _lineHeight;
        }
      }

      final blockLines = block.lines;
      final blockBgColor = block.backgroundColor;
      final blockTextStyle = block.textStyle;
      final textColor = blockTextStyle?.color ?? const Color(0xAAE53935);
      final fontSize = blockTextStyle?.fontSize ?? textStyle?.fontSize ?? 14.0;
      final fontFamily = blockTextStyle?.fontFamily ?? textStyle?.fontFamily;

      for (int i = 0; i < blockLines.length; i++) {
        final lineY = baseY + extraOffset + (i * _lineHeight);

        final screenY = offset.dy + (innerPadding?.top ?? 0) + lineY - viewTop;

        if (screenY + _lineHeight < offset.dy) continue;
        if (screenY > offset.dy + (viewBottom - viewTop)) break;

        final contentX =
            offset.dx +
            _gutterWidth +
            (innerPadding?.left ?? 0) -
            (lineWrap ? 0 : _effectiveHScroll);

        canvas.drawRect(
          Rect.fromLTWH(offset.dx, screenY, size.width, _lineHeight),
          Paint()..color = blockBgColor,
        );

        canvas.drawRect(
          Rect.fromLTWH(
            offset.dx + (isRTL ? size.width - _gutterWidth : _gutterWidth) - 3,
            screenY,
            3,
            _lineHeight,
          ),
          Paint()..color = textColor,
        );

        if (blockLines[i].isNotEmpty) {
          final style = ui.TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontFamily: fontFamily,
            fontStyle: blockTextStyle?.fontStyle,
            fontWeight: blockTextStyle?.fontWeight,
          );

          final builder =
              ui.ParagraphBuilder(
                  ui.ParagraphStyle(
                    fontFamily: fontFamily,
                    fontSize: fontSize,
                    height: textStyle?.height ?? 1.2,
                  ),
                )
                ..pushStyle(style)
                ..addText(blockLines[i]);

          final para = builder.build();
          para.layout(
            ui.ParagraphConstraints(
              width: lineWrap ? _wrapWidth : double.infinity,
            ),
          );

          canvas.drawParagraph(para, Offset(contentX, screenY));
        }
      }
    }
  }

  void _drawInlayHints(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final hints = controller.inlayHints;
    if (hints.isEmpty) return;

    final fontSize = textStyle?.fontSize ?? 14.0;
    final fontFamily = textStyle?.fontFamily;
    final baseColor =
        textStyle?.color ?? editorTheme['root']?.color ?? Colors.white;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;

    final typeHintStyle = ui.TextStyle(
      color: baseColor.withAlpha(150),
      fontSize: fontSize * 0.9,
      fontFamily: fontFamily,
      fontStyle: FontStyle.italic,
    );

    final paramHintStyle = ui.TextStyle(
      color: baseColor.withAlpha(180),
      fontSize: fontSize * 0.9,
      fontFamily: fontFamily,
    );

    final hintBgColor = bgColor.withAlpha(200);
    final hintBorderColor = baseColor.withAlpha(50);

    final hintsByLine = <int, List<InlayHint>>{};
    for (final hint in hints) {
      if (hint.line >= firstVisibleLine && hint.line <= lastVisibleLine) {
        if (!hasActiveFolds || !_isLineFolded(hint.line)) {
          hintsByLine.putIfAbsent(hint.line, () => []).add(hint);
        }
      }
    }

    hintsByLine.forEach((line, lineHints) {
      lineHints.sort((a, b) => a.column.compareTo(b.column));
    });

    for (final entry in hintsByLine.entries) {
      final line = entry.key;
      final lineHints = entry.value;
      final lineText = _lineTextCache[line] ?? controller.getLineText(line);
      final lineY = _getLineYOffset(line, hasActiveFolds);
      final para =
          _paragraphCache[line] ??
          _buildHighlightedParagraph(
            line,
            lineText,
            width: lineWrap ? _wrapWidth : null,
          );

      final baseScreenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          lineY -
          vscrollController.offset;

      final baseScreenX =
          offset.dx +
          _gutterWidth +
          (innerPadding?.left ?? 0) -
          (lineWrap ? 0 : _effectiveHScroll);

      final firstHint = lineHints.first;
      double firstHintX = 0;
      if (firstHint.column > 0 && lineText.isNotEmpty) {
        final clampedCol = firstHint.column.clamp(0, lineText.length);
        final contentWidth =
            size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
        final paragraphWidth = lineWrap
            ? _wrapWidth
            : (isRTL ? max(contentWidth * 3, 10000.0) : null);
        final paragraphOffset = isRTL
            ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
            : 0.0;

        firstHintX = _getCaretPositionForColumn(
          para,
          lineText,
          clampedCol,
          paragraphOffset,
          contentWidth,
        ).x;
      }

      double totalHintWidth = 0;
      for (final hint in lineHints) {
        final hintText = hint.paddingLeft ? ' ${hint.text}' : hint.text;
        final displayText = hint.paddingRight ? '$hintText ' : hintText;
        final builder =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSize * 0.9,
                  height: textStyle?.height ?? 1.2,
                ),
              )
              ..pushStyle(
                hint.kind == InlayHintKind.type
                    ? typeHintStyle
                    : paramHintStyle,
              )
              ..addText(displayText);
        final tempPara = builder.build();
        tempPara.layout(const ui.ParagraphConstraints(width: double.infinity));
        totalHintWidth += tempPara.longestLine + 4;
      }

      final remainingWidth = para.longestLine - firstHintX + totalHintWidth;
      canvas.drawRect(
        Rect.fromLTWH(
          baseScreenX + firstHintX,
          baseScreenY,
          remainingWidth + 20,
          _lineHeight,
        ),
        Paint()..color = bgColor,
      );

      double currentX = firstHintX;
      int lastColumn = firstHint.column;

      for (int i = 0; i < lineHints.length; i++) {
        final hint = lineHints[i];
        final column = hint.column;

        if (i > 0 && column > lastColumn && lastColumn < lineText.length) {
          final endCol = column.clamp(lastColumn, lineText.length);
          final contentWidth =
              size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
          final paragraphWidth = lineWrap
              ? _wrapWidth
              : (isRTL ? max(contentWidth * 3, 10000.0) : null);
          final paragraphOffset = isRTL
              ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
              : 0.0;

          final segmentStartX = _getCaretPositionForColumn(
            para,
            lineText,
            lastColumn,
            paragraphOffset,
            contentWidth,
          ).x;
          final segmentEndX = _getCaretPositionForColumn(
            para,
            lineText,
            endCol,
            paragraphOffset,
            contentWidth,
          ).x;
          final segmentWidth = segmentEndX - segmentStartX;

          canvas.save();
          canvas.clipRect(
            Rect.fromLTWH(
              baseScreenX + currentX,
              baseScreenY,
              segmentWidth,
              _lineHeight,
            ),
          );

          canvas.drawParagraph(
            para,
            Offset(baseScreenX + currentX - segmentStartX, baseScreenY),
          );
          canvas.restore();

          currentX += segmentWidth;
        }

        final style = hint.kind == InlayHintKind.type
            ? typeHintStyle
            : paramHintStyle;
        final hintText = hint.paddingLeft ? ' ${hint.text}' : hint.text;
        final displayText = hint.paddingRight ? '$hintText ' : hintText;

        final builder =
            ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSize * 0.9,
                  height: textStyle?.height ?? 1.2,
                ),
              )
              ..pushStyle(style)
              ..addText(displayText);

        final hintPara = builder.build();
        hintPara.layout(const ui.ParagraphConstraints(width: double.infinity));
        final hintWidth = hintPara.longestLine;
        final hintHeight = hintPara.height;
        final bgRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            baseScreenX + currentX - 2,
            baseScreenY + 1,
            hintWidth + 4,
            hintHeight - 2,
          ),
          const Radius.circular(3),
        );

        canvas.drawRRect(bgRect, Paint()..color = hintBgColor);
        canvas.drawRRect(
          bgRect,
          Paint()
            ..color = hintBorderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );

        canvas.drawParagraph(
          hintPara,
          Offset(baseScreenX + currentX, baseScreenY),
        );
        currentX += hintWidth + 4;
        lastColumn = column;
      }

      if (lastColumn < lineText.length) {
        final contentWidth =
            size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
        final paragraphWidth = lineWrap
            ? _wrapWidth
            : (isRTL ? max(contentWidth * 3, 10000.0) : null);
        final paragraphOffset = isRTL
            ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
            : 0.0;
        final remainingStartX = _getCaretPositionForColumn(
          para,
          lineText,
          lastColumn,
          paragraphOffset,
          contentWidth,
        ).x;
        final remainingWidth = para.longestLine - remainingStartX;

        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(
            baseScreenX + currentX,
            baseScreenY,
            remainingWidth + 10,
            _lineHeight,
          ),
        );

        canvas.drawParagraph(
          para,
          Offset(baseScreenX + currentX - remainingStartX, baseScreenY),
        );
        canvas.restore();
      }
    }
  }

  void _drawDocumentColors(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    double firstVisibleLineY,
    bool hasActiveFolds,
  ) {
    final colors = controller.documentColors;
    if (colors.isEmpty) return;

    final fontSize = textStyle?.fontSize ?? 14.0;
    final colorBoxSize = fontSize * 0.85;
    final colorBoxSpacing = 4.0;
    final totalColorWidth = colorBoxSize + colorBoxSpacing;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
    final colorsByLine = <int, List<DocumentColor>>{};

    for (final docColor in colors) {
      if (docColor.line >= firstVisibleLine &&
          docColor.line <= lastVisibleLine) {
        if (!hasActiveFolds || !_isLineFolded(docColor.line)) {
          colorsByLine.putIfAbsent(docColor.line, () => []).add(docColor);
        }
      }
    }

    colorsByLine.forEach((line, lineColors) {
      lineColors.sort((a, b) => a.startColumn.compareTo(b.startColumn));
    });

    for (final entry in colorsByLine.entries) {
      final line = entry.key;
      final lineColors = entry.value;
      final lineText = _lineTextCache[line] ?? controller.getLineText(line);
      final lineY = _getLineYOffset(line, hasActiveFolds);
      final para =
          _paragraphCache[line] ??
          _buildHighlightedParagraph(
            line,
            lineText,
            width: lineWrap ? _wrapWidth : null,
          );

      final baseScreenY =
          offset.dy +
          (innerPadding?.top ?? 0) +
          lineY -
          vscrollController.offset;

      final baseScreenX =
          offset.dx +
          _gutterWidth +
          (innerPadding?.left ?? 0) -
          (lineWrap ? 0 : _effectiveHScroll);

      final firstColor = lineColors.first;
      double firstColorX = 0;
      if (firstColor.startColumn > 0 && lineText.isNotEmpty) {
        final utf16Column = CodeForgeController.scalarToUtf16Offset(
          lineText,
          firstColor.startColumn,
        );
        final clampedCol = utf16Column.clamp(0, lineText.length);
        final contentWidth =
            size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
        final paragraphWidth = lineWrap
            ? _wrapWidth
            : (isRTL ? max(contentWidth * 3, 10000.0) : null);
        final paragraphOffset = isRTL
            ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
            : 0.0;

        firstColorX = _getCaretPositionForColumn(
          para,
          lineText,
          clampedCol,
          paragraphOffset,
          contentWidth,
        ).x;
      }

      final totalColorBoxWidth = lineColors.length * totalColorWidth;
      final remainingWidth =
          para.longestLine - firstColorX + totalColorBoxWidth;

      canvas.drawRect(
        Rect.fromLTWH(
          baseScreenX + firstColorX,
          baseScreenY,
          remainingWidth + 20,
          _lineHeight,
        ),
        Paint()..color = bgColor,
      );

      double currentX = firstColorX;
      int lastColumn = firstColor.startColumn;

      for (int i = 0; i < lineColors.length; i++) {
        final docColor = lineColors[i];
        final startColumn = docColor.startColumn;

        if (i > 0 && startColumn > lastColumn && lastColumn < lineText.length) {
          final endCol = startColumn.clamp(lastColumn, lineText.length);
          final contentWidth =
              size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
          final paragraphWidth = lineWrap
              ? _wrapWidth
              : (isRTL ? max(contentWidth * 3, 10000.0) : null);
          final paragraphOffset = isRTL
              ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
              : 0.0;

          final segmentStartX = _getCaretPositionForColumn(
            para,
            lineText,
            lastColumn,
            paragraphOffset,
            contentWidth,
          ).x;
          final segmentEndX = _getCaretPositionForColumn(
            para,
            lineText,
            endCol,
            paragraphOffset,
            contentWidth,
          ).x;
          final segmentWidth = segmentEndX - segmentStartX;

          canvas.save();
          canvas.clipRect(
            Rect.fromLTWH(
              baseScreenX + currentX,
              baseScreenY,
              segmentWidth,
              _lineHeight,
            ),
          );

          canvas.drawParagraph(
            para,
            Offset(baseScreenX + currentX - segmentStartX, baseScreenY),
          );
          canvas.restore();

          currentX += segmentWidth;
        }

        final colorBoxY = baseScreenY + (_lineHeight - colorBoxSize) / 2;
        final colorRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            baseScreenX + currentX,
            colorBoxY,
            colorBoxSize,
            colorBoxSize,
          ),
          const Radius.circular(2),
        );

        if ((docColor.color.a * 255).round() < 255) {
          canvas.save();
          canvas.clipRRect(colorRect);
          final checkerSize = colorBoxSize / 4;
          final checkerPaint = Paint()..color = Colors.grey.shade300;
          for (int row = 0; row < 4; row++) {
            for (int col = 0; col < 4; col++) {
              if ((row + col) % 2 == 0) {
                canvas.drawRect(
                  Rect.fromLTWH(
                    baseScreenX + currentX + col * checkerSize,
                    colorBoxY + row * checkerSize,
                    checkerSize,
                    checkerSize,
                  ),
                  checkerPaint,
                );
              }
            }
          }
          canvas.restore();
        }

        canvas.drawRRect(colorRect, Paint()..color = docColor.color);

        final borderColor = editorTheme['root']?.color ?? Colors.white;
        canvas.drawRRect(
          colorRect,
          Paint()
            ..color = borderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );

        _colorBoxHitAreas[colorRect.outerRect] = docColor;

        currentX += totalColorWidth;
        lastColumn = startColumn;
      }

      if (lastColumn < lineText.length) {
        final contentWidth =
            size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
        final paragraphWidth = lineWrap
            ? _wrapWidth
            : (isRTL ? max(contentWidth * 3, 10000.0) : null);
        final paragraphOffset = isRTL
            ? (lineWrap ? 0.0 : (contentWidth - (paragraphWidth ?? 0)))
            : 0.0;

        final remainingStartX = _getCaretPositionForColumn(
          para,
          lineText,
          lastColumn,
          paragraphOffset,
          contentWidth,
        ).x;
        final remainingWidth = para.longestLine - remainingStartX;

        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(
            baseScreenX + currentX,
            baseScreenY,
            remainingWidth + 10,
            _lineHeight,
          ),
        );

        canvas.drawParagraph(
          para,
          Offset(baseScreenX + currentX - remainingStartX, baseScreenY),
        );
        canvas.restore();
      }
    }
  }

  void _showColorPicker(DocumentColor docColor) {
    final lsp = lspConfig;
    final file = filePath;
    if (lsp == null || file == null) return;

    Color pickerColor = docColor.color;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              enableAlpha: true,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _applyColorChange(docColor, pickerColor);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyColorChange(DocumentColor docColor, Color newColor) async {
    final lsp = lspConfig;
    final file = filePath;
    if (lsp == null || file == null) return;

    try {
      final range = {
        'start': {'line': docColor.line, 'character': docColor.startColumn},
        'end': {'line': docColor.line, 'character': docColor.endColumn},
      };

      final response = await lsp.getColorPresentation(
        file,
        red: newColor.r,
        green: newColor.g,
        blue: newColor.b,
        alpha: newColor.a,
        range: range,
      );

      final result = response['result'];
      if (result is List && result.isNotEmpty) {
        final presentation = result[0];
        final textEdit = presentation['textEdit'];

        if (textEdit != null) {
          final newText = textEdit['newText'] as String?;
          final editRange = textEdit['range'];

          if (newText != null && editRange != null) {
            final startLine = editRange['start']['line'] as int;
            final startChar = editRange['start']['character'] as int;
            final endLine = editRange['end']['line'] as int;
            final endChar = editRange['end']['character'] as int;

            final startOffset =
                controller.getLineStartOffset(startLine) +
                CodeForgeController.utf16ToScalarOffset(
                  controller.getLineText(startLine),
                  startChar,
                );
            final endOffset =
                controller.getLineStartOffset(endLine) +
                CodeForgeController.utf16ToScalarOffset(
                  controller.getLineText(endLine),
                  endChar,
                );

            controller.replaceRange(startOffset, endOffset, newText);
          }
        } else {
          final label = presentation['label'] as String?;
          if (label != null) {
            final lineText = controller.getLineText(docColor.line);
            final startOffset =
                controller.getLineStartOffset(docColor.line) +
                CodeForgeController.utf16ToScalarOffset(
                  lineText,
                  docColor.startColumn,
                );
            final endOffset =
                controller.getLineStartOffset(docColor.line) +
                CodeForgeController.utf16ToScalarOffset(
                  lineText,
                  docColor.endColumn,
                );

            controller.replaceRange(startOffset, endOffset, label);
          }
        }
      }
    } catch (e) {
      debugPrint('Error applying color change: $e');
    }
  }

  @override
  void dispose() {
    _selectionTimer?.cancel();
    _hoverTimer?.cancel();
    _showBubbleTimer?.cancel();
    _foldComputeTimer?.cancel();
    _semanticTokenTimer?.cancel();
    _resizeTimer?.cancel();
    _layoutDebounceTimer?.cancel();
    _bracketHighlightResumeTimer?.cancel();
    _bufferParagraph?.dispose();
    controller.removeListener(_onControllerChange);
    controller.setScrollCallback(null);
    _syntaxHighlighter?.dispose();
    super.dispose();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool isHit = false;
    if (size.contains(position)) {
      isHit = true;
    } else {
      if (_startHandleRect?.contains(position) == true) {
        isHit = true;
      } else if (_endHandleRect?.contains(position) == true) {
        isHit = true;
      } else if (_normalHandle != null) {
        if (_normalHandle!
            .inflate(_kCaretHandleHitPadding)
            .contains(position)) {
          isHit = true;
        }
      }
    }

    if (isHit) {
      if (hitTestChildren(result, position: position) ||
          hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  Future<void> _hapticHandleMove() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (Platform.isAndroid) {
      try {
        await _hapticsChannel.invokeMethod('handleMove');
      } catch (_) {
        HapticFeedback.selectionClick();
      }
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _hapticLongPress() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (Platform.isAndroid) {
      try {
        await _hapticsChannel.invokeMethod('longPress');
      } catch (_) {
        HapticFeedback.heavyImpact();
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    final localPosition = event.localPosition;
    final clickY =
        localPosition.dy + vscrollController.offset - (innerPadding?.top ?? 0);
    _currentPosition = localPosition;

    final contentX =
        localPosition.dx -
        (isRTL ? 0 : _gutterWidth) -
        (innerPadding?.left ?? 0) +
        (lineWrap ? 0 : _effectiveHScroll);
    final contentPosition = Offset(
      contentX,
      localPosition.dy - (innerPadding?.top ?? 0) + vscrollController.offset,
    );
    final textOffset = _getTextOffsetFromPosition(contentPosition);

    if (event is PointerHoverEvent) {
      if (hoverNotifier.value == null) {
        _hoverTimer?.cancel();
      }
      if (!(hoverNotifier.value != null && isHoveringPopup.value)) {
        hoverNotifier.value = null;
      }

      if ((hoverNotifier.value == null || !isHoveringPopup.value) &&
          _isOffsetOverWord(textOffset)) {
        _hoverTimer?.cancel();
        _hoverTimer = Timer(Duration(milliseconds: 600), () {
          final lineChar = _offsetToLineChar(textOffset);
          hoverNotifier.value = (event.localPosition, lineChar);
        });
      } else {
        _hoverTimer?.cancel();
        hoverNotifier.value = null;
      }
    }

    if ((event is PointerDownEvent && event.buttons == kSecondaryButton) ||
        (event is PointerUpEvent &&
            isMobile &&
            _selectionActive &&
            controller.selection.start != controller.selection.end)) {
      _draggingStartHandle = false;
      _draggingEndHandle = false;
      _draggingCHandle = false;
      _lastHandleHapticOffset = null;
      _isDragging = false;
      _longPressSelected = false;
      _cachedMagnifiedParagraph = null;
      _cachedMagnifiedLine = null;
      _cachedMagnifiedOffset = null;

      markNeedsPaint();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        contextMenuOffsetNotifier.value = localPosition;
      });
      return;
    }

    if (event is PointerDownEvent && event.buttons == kPrimaryButton) {
      final extraPadding = isMobile ? 12.0 : 0.0;
      final effectiveGutterWidth = _gutterWidth + extraPadding;
      final gutterClickArea = isRTL
          ? localPosition.dx > size.width - effectiveGutterWidth
          : localPosition.dx < effectiveGutterWidth;

      if (enableGutter && gutterClickArea) {
        _isGutterPointer = true;
        _selectionTimer?.cancel();
        if (clickY >= 0 && enableFolding) {
          final clickedLine = _findVisibleLineByYPosition(clickY);
          final foldRange = _getFoldRangeAtLine(clickedLine);
          if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
            _toggleFold(foldRange);
          }
        }
        return;
      }
      _isGutterPointer = false;

      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
      } else if (controller.connection == null ||
          !controller.connection!.attached) {
        controller.requestImeReset?.call();
      }
      _openedLspActionFromBulbTap = false;
      _onetap.addPointer(event);
      try {
        suggestionNotifier.value = null;
        signatureNotifier.value = null;
      } catch (e) {
        debugPrint(e.toString());
      }
      if (contextMenuOffsetNotifier.value.dx >= 0) {
        contextMenuOffsetNotifier.value = const Offset(-1, -1);
      }

      if (lspActionNotifier.value != null && _actionBulbRects.isNotEmpty) {
        for (final entry in _actionBulbRects.entries) {
          if (entry.value.contains(localPosition)) {
            _openedLspActionFromBulbTap = true;
            suggestionNotifier.value = null;
            lspActionOffsetNotifier.value = event.localPosition;
            return;
          }
        }
      }

      if (_colorBoxHitAreas.isNotEmpty) {
        for (final entry in _colorBoxHitAreas.entries) {
          if (entry.key.contains(localPosition)) {
            _showColorPicker(entry.value);
            return;
          }
        }
      }

      if (isMobile) {
        _dtap.addPointer(event);
        _draggingCHandle = false;
        _draggingStartHandle = false;
        _draggingEndHandle = false;
        _lastHandleHapticOffset = null;

        _dtap.onDoubleTap = () {
          final freshOffset = _getTextOffsetFromPosition(contentPosition);
          _selectWordAtOffset(freshOffset);
          _longPressSelected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            contextMenuOffsetNotifier.value = localPosition;
          });
        };

        _onetap.onTap = () {
          if (_openedLspActionFromBulbTap) {
            _openedLspActionFromBulbTap = false;
            return;
          }

          if (hoverNotifier.value != null && !isHoveringPopup.value) {
            hoverNotifier.value = null;
            hoverContentNotifier.value = null;
          } else if (_isOffsetOverWord(textOffset)) {
            final lineChar = _offsetToLineChar(textOffset);
            hoverNotifier.value = (localPosition, lineChar);
            onHoverSetByTap?.call();
          }

          if (lspActionNotifier.value != null ||
              lspActionOffsetNotifier.value != null) {
            lspActionNotifier.value = null;
            lspActionOffsetNotifier.value = null;
          }
        };

        if (controller.selection.start != controller.selection.end) {
          final startHit = _startHandleRect?.inflate(
            _kSelectionHandleHitPadding,
          );
          final endHit = _endHandleRect?.inflate(_kSelectionHandleHitPadding);
          if (startHit?.contains(localPosition) ?? false) {
            _draggingStartHandle = true;
            _selectionActive = selectionActiveNotifier.value = true;
            _pointerDownPosition = localPosition;
            _dragStartOffset = controller.selection.end;
            _onetap.onTap = null;
            markNeedsPaint();
            return;
          }
          if (endHit?.contains(localPosition) ?? false) {
            _draggingEndHandle = true;
            _selectionActive = selectionActiveNotifier.value = true;
            _pointerDownPosition = localPosition;
            _dragStartOffset = controller.selection.start;
            _onetap.onTap = null;
            markNeedsPaint();
            return;
          }
        } else if (controller.selection.isCollapsed && _normalHandle != null) {
          final expandedHandle = _normalHandle!.inflate(24.0);
          if (expandedHandle.contains(localPosition)) {
            _draggingCHandle = true;
            _selectionActive = selectionActiveNotifier.value = true;
            _dragStartOffset = controller.selection.extentOffset;
            _pointerDownPosition = localPosition;
            _onetap.onTap = null;
            return;
          }
        }

        _dragStartOffset = textOffset;
        _isDragging = false;
        _pointerDownPosition = localPosition;
        _selectionActive = false;
        selectionActiveNotifier.value = false;
        _showBubble = false;
        _showBubbleTimer?.cancel();

        _selectionTimer?.cancel();
        _selectionTimer = Timer(const Duration(milliseconds: 500), () {
          final freshPos = contentPosition;
          final freshOffset = _getTextOffsetFromPosition(freshPos);
          _selectWordAtOffset(freshOffset);
          unawaited(_hapticLongPress());
          _longPressSelected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            contextMenuOffsetNotifier.value = localPosition;
          });
        });
      } else {
        controller.focusNode?.requestFocus();
        final isAltClickNow =
            HardwareKeyboard.instance.isAltPressed &&
            !HardwareKeyboard.instance.isControlPressed &&
            !HardwareKeyboard.instance.isMetaPressed;
        if (!isAltClickNow) {
          controller.clearMultiCursors();
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
          if (isShiftPressed) {
            _shiftBaseOffset ??= controller.selection.baseOffset;
            controller.selection = TextSelection(
              baseOffset: _shiftBaseOffset!,
              extentOffset: textOffset,
            );
            _shiftClickActive = true;
          } else {
            _shiftBaseOffset = null;
            controller.selection = TextSelection.collapsed(offset: textOffset);
            _shiftClickActive = false;
          }
        }
        _dtap.addPointer(event);
        _dtap.onDoubleTap = () {
          final freshOffset = _getTextOffsetFromPosition(contentPosition);
          _selectWordAtOffset(freshOffset);
        };

        _dragStartOffset = textOffset;
        _pointerDownPosition = localPosition;
        _isDragging = false;
        _selectionActive = false;
        selectionActiveNotifier.value = false;
        _onetap.onTap = () {
          if (_openedLspActionFromBulbTap) {
            _openedLspActionFromBulbTap = false;
            return;
          }

          if (suggestionNotifier.value != null) {
            suggestionNotifier.value = null;
          }
          if (signatureNotifier.value != null) {
            signatureNotifier.value = null;
          }
          if (lspActionNotifier.value != null) {
            lspActionNotifier.value = null;
            lspActionOffsetNotifier.value = null;
          }

          final isAltClickNow =
              HardwareKeyboard.instance.isAltPressed &&
              !HardwareKeyboard.instance.isControlPressed &&
              !HardwareKeyboard.instance.isMetaPressed;
          final isShiftClickNow =
              HardwareKeyboard.instance.isShiftPressed || _shiftClickActive;
          if (isAltClickNow) {
            final line = controller.getLineAtOffset(textOffset);
            final lineStart = controller.getLineStartOffset(line);
            final character = textOffset - lineStart;
            controller.addMultiCursor(line, character);
          } else if (isShiftClickNow) {
            controller.clearMultiCursors();
            final base = _shiftBaseOffset ?? controller.selection.baseOffset;
            controller.selection = TextSelection(
              baseOffset: base,
              extentOffset: textOffset,
            );
          } else {
            _shiftBaseOffset = null;
            _shiftClickActive = false;
            controller.clearMultiCursors();
            controller.selection = TextSelection.collapsed(offset: textOffset);
          }
        };
      }
    }

    if (event is PointerMoveEvent && _dragStartOffset != null) {
      if (_isGutterPointer) return;
      if (isMobile) {
        if (_draggingCHandle) {
          final handleRadius = (_lineHeight / 2).clamp(6.0, 12.0);
          final handleOffset = _lineHeight + handleRadius;
          if ((localPosition - (_pointerDownPosition ?? localPosition))
                  .distance <
              _kMobileHandleDragSlop) {
            return;
          }
          final adjustedContentPosition = Offset(
            contentPosition.dx,
            contentPosition.dy - handleOffset,
          );
          final adjustedTextOffset = _getTextOffsetFromPosition(
            adjustedContentPosition,
          );
          controller.selection = TextSelection.collapsed(
            offset: adjustedTextOffset,
          );
          _showBubble = true;
          if (adjustedTextOffset != _lastHandleHapticOffset) {
            _lastHandleHapticOffset = adjustedTextOffset;
            unawaited(_hapticHandleMove());
          }
          markNeedsPaint();
          return;
        }

        if (_draggingStartHandle || _draggingEndHandle) {
          final handleRadius = (_lineHeight / 2).clamp(6.0, 12.0);
          final handleOffset = _lineHeight + handleRadius;
          if ((localPosition - (_pointerDownPosition ?? localPosition))
                  .distance <
              _kMobileHandleDragSlop) {
            return;
          }
          final adjustedContentPosition = Offset(
            contentPosition.dx,
            contentPosition.dy - handleOffset,
          );
          final adjustedTextOffset = _getTextOffsetFromPosition(
            adjustedContentPosition,
          );
          final anchor = _dragStartOffset!;

          if (_draggingStartHandle) {
            controller.selection = TextSelection(
              baseOffset: adjustedTextOffset,
              extentOffset: anchor,
            );
            if (adjustedTextOffset > anchor) {
              _draggingStartHandle = false;
              _draggingEndHandle = true;
            }
          } else {
            controller.selection = TextSelection(
              baseOffset: anchor,
              extentOffset: adjustedTextOffset,
            );
            if (adjustedTextOffset < anchor) {
              _draggingEndHandle = false;
              _draggingStartHandle = true;
            }
          }
          if (adjustedTextOffset != _lastHandleHapticOffset) {
            _lastHandleHapticOffset = adjustedTextOffset;
            unawaited(_hapticHandleMove());
          }
          markNeedsPaint();
          return;
        }

        if ((localPosition - (_pointerDownPosition ?? localPosition)).distance >
            10) {
          _isDragging = true;
          suggestionNotifier.value = null;

          _selectionTimer?.cancel();
        }

        if (_longPressSelected) {
          return;
        }

        if (_isDragging && !_selectionActive) {
          return;
        }

        if (_selectionActive) {
          controller.selection = TextSelection(
            baseOffset: _dragStartOffset!,
            extentOffset: textOffset,
          );
          markNeedsPaint();
        }
      } else {
        if (_shiftClickActive) {
          final newSel = TextSelection(
            baseOffset: _shiftBaseOffset!,
            extentOffset: textOffset,
          );
          if (newSel != controller.selection) {
            controller.selection = newSel;
            markNeedsPaint();
          }
          return;
        }
        final delta = localPosition - (_pointerDownPosition ?? localPosition);
        if (!_isDragging && delta.distance > 2) {
          _isDragging = true;
          _selectionActive = selectionActiveNotifier.value = true;
        }

        if (_selectionActive) {
          final newSel = TextSelection(
            baseOffset: _dragStartOffset!,
            extentOffset: textOffset,
          );
          if (newSel != controller.selection) {
            controller.selection = newSel;
            markNeedsPaint();
          }
        }
      }
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (_isGutterPointer) {
        _isGutterPointer = false;
        _selectionTimer?.cancel();
        _draggingStartHandle = false;
        _draggingEndHandle = false;
        _draggingCHandle = false;
        _lastHandleHapticOffset = null;
        _pointerDownPosition = null;
        _dragStartOffset = null;
        _isDragging = false;
        _selectionActive = selectionActiveNotifier.value = false;
        _longPressSelected = false;
        markNeedsPaint();
        return;
      }

      if (event is PointerUpEvent &&
          !_isDragging &&
          isMobile &&
          !_selectionActive &&
          !readOnly) {
        controller.selection = TextSelection.collapsed(offset: textOffset);
        if (controller.connection?.attached ?? false) {
          controller.connection?.show();
        }
      }

      if (event is PointerUpEvent &&
          _draggingCHandle &&
          !_isDragging &&
          isMobile &&
          !readOnly) {
        if (!focusNode.hasFocus) {
          focusNode.requestFocus();
        } else if (controller.connection == null ||
            !controller.connection!.attached) {
          controller.requestImeReset?.call();
        } else {
          controller.connection!.show();
        }
      }

      _draggingStartHandle = false;
      _draggingEndHandle = false;
      _draggingCHandle = false;
      _lastHandleHapticOffset = null;
      _pointerDownPosition = null;
      _dragStartOffset = null;
      _selectionTimer?.cancel();

      _cachedMagnifiedParagraph = null;
      _cachedMagnifiedLine = null;
      _cachedMagnifiedOffset = null;

      final wasDragging = _isDragging;
      _isDragging = false;
      _selectionActive = selectionActiveNotifier.value = false;
      _longPressSelected = false;

      markNeedsPaint();

      if (readOnly) return;
      if (!wasDragging && !_shiftClickActive) {
        controller.notifyListeners();
      }

      if (isMobile && controller.selection.isCollapsed) {
        _showBubble = true;
      }
    }
  }

  void _selectWordAtOffset(int offset) {
    if (isMobile) {
      _selectionActive = selectionActiveNotifier.value = true;
    }

    final text = controller.text;
    if (text.isEmpty) return;

    final runes = text.runes.toList(growable: false);
    final scalarLength = runes.length;
    if (scalarLength == 0) return;

    int target = offset.clamp(0, scalarLength - 1);
    bool isBoundary(int scalar) => _isWordBoundary(String.fromCharCode(scalar));

    if (isBoundary(runes[target])) {
      if (target > 0 && !isBoundary(runes[target - 1])) {
        target = target - 1;
      } else if (target < scalarLength - 1 && !isBoundary(runes[target + 1])) {
        target = target + 1;
      }
    }

    int start = target, end = target;

    while (start > 0 && !isBoundary(runes[start - 1])) {
      start--;
    }
    while (end < scalarLength && !isBoundary(runes[end])) {
      end++;
    }

    start = start.clamp(0, scalarLength);
    end = end.clamp(start, scalarLength);

    controller.selection = TextSelection(baseOffset: start, extentOffset: end);
    markNeedsPaint();
  }

  bool _isWordBoundary(String char) {
    return char.trim().isEmpty || !RegExp(_wordCharPattern).hasMatch(char);
  }

  bool _isOffsetOverWord(int offset) {
    final text = controller.text;
    if (offset < 0 || offset >= controller.length) return false;
    final utf16Index = CodeForgeController.scalarToStringIndex(text, offset);
    if (utf16Index < 0 || utf16Index >= text.length) return false;
    return RegExp(_wordCharPattern).hasMatch(text[utf16Index]);
  }

  Map<String, int> _offsetToLineChar(int offset) {
    if (offset < 0) return {'line': 0, 'character': 0};
    if (offset >= controller.length) {
      final last = controller.lineCount - 1;
      final lastLineText = controller.getLineText(last);
      return {'line': last, 'character': lastLineText.length};
    }
    final line = controller.getLineAtOffset(offset);
    final startOffset = controller.getLineStartOffset(line);
    final lineText = controller.getLineText(line);
    final colScalar = (offset - startOffset).clamp(0, lineText.runes.length);
    return {
      'line': line,
      'character': CodeForgeController.scalarToStringIndex(lineText, colScalar),
    };
  }

  @override
  MouseCursor get cursor {
    if (_actionBulbRects.isNotEmpty) {
      for (final rect in _actionBulbRects.values) {
        if (rect.contains(_currentPosition)) {
          return SystemMouseCursors.click;
        }
      }
    }

    final isInGutter = isRTL
        ? _currentPosition.dx > size.width - _gutterWidth
        : _currentPosition.dx >= 0 && _currentPosition.dx < _gutterWidth;

    if (isInGutter) {
      if (_foldRanges.isEmpty && !enableFolding) {
        return MouseCursor.defer;
      }

      final clickY =
          _currentPosition.dy +
          vscrollController.offset -
          (innerPadding?.top ?? 0);
      final hasActiveFolds = _hasActiveFolds;

      int hoveredLine;
      if (!hasActiveFolds && !lineWrap && _virtualRemovedTotalLineCount == 0) {
        hoveredLine = (clickY / _lineHeight).floor().clamp(
          0,
          controller.lineCount - 1,
        );
      } else {
        hoveredLine = _findVisibleLineByYPosition(clickY);
      }

      final foldRange = _getFoldRangeAtLine(hoveredLine);
      if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
        return SystemMouseCursors.click;
      }

      return MouseCursor.defer;
    }

    if (_colorBoxHitAreas.isNotEmpty) {
      for (final rect in _colorBoxHitAreas.keys) {
        if (rect.contains(_currentPosition)) {
          return SystemMouseCursors.click;
        }
      }
    }

    return SystemMouseCursors.text;
  }

  @override
  PointerEnterEventListener? get onEnter => null;

  @override
  PointerExitEventListener? get onExit => (event) {
    _hoverTimer?.cancel();
  };

  @override
  bool get validForMouseTracker => true;
}

class _BracketEntry {
  final String char;
  final int line;
  _BracketEntry(this.char, this.line);
}

class _SnippetSuggestion {
  final String label;
  final String value;
  final Set<int> cursorLocations;
  const _SnippetSuggestion({
    required this.label,
    required this.value,
    this.cursorLocations = const {},
  });
}

class _ContextMenuLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset position;

  _ContextMenuLayoutDelegate({required this.position});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double dx = position.dx;
    double dy = position.dy;

    if (dx + childSize.width > size.width) {
      dx = size.width - childSize.width;
    }
    if (dx < 0) dx = 0;

    if (dy + childSize.height > size.height) {
      dy = size.height - childSize.height;
    }
    if (dy < 0) dy = 0;

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_ContextMenuLayoutDelegate oldDelegate) {
    return position != oldDelegate.position;
  }
}
