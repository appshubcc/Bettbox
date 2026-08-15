import '../src/rust/api/editor.dart';
import 'dart:async';
import 'dart:io';

import '../code_forge.dart';
import 'rope.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controller for the [CodeForge] code editor widget.
///
/// This controller manages the text content, selection state, and various
/// editing operations for the code editor. It implements [DeltaTextInputClient]
/// to handle text input from the platform.
///
/// The controller uses a rope data structure internally for efficient text
/// manipulation, especially for large documents.
///
/// Example:
/// ```dart
/// final controller = CodeForgeController();
/// controller.text = 'void main() {\n  print("Hello");\n}';
///
/// // Access selection
/// print(controller.selection);
///
/// // Get specific line
/// print(controller.getLineText(0)); // 'void main() {'
///
/// // Fold/unfold code
/// controller.foldAll();
/// controller.unfoldAll();
/// ```
class CodeForgeController implements DeltaTextInputClient {
  static const _flushDelay = Duration(milliseconds: 100);
  static const _documentColorDebounce = Duration(milliseconds: 50);
  static const _documentHighlightDebounce = Duration(milliseconds: 300);
  static const _cclsRefreshDebounce = Duration(milliseconds: 1000);
  static const _imeProjectionLineRadius = 2, _imeProjectionMaxChars = 4096;
  static const Duration _lspTypingDebounce = Duration(milliseconds: 300);
  static const Duration _lspDocumentSyncDebounce = Duration(milliseconds: 200);
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final List<VoidCallback> _listeners = [];
  final List<LineDecoration> _lineDecorations = [];
  final List<GutterDecoration> _gutterDecorations = [];
  final List<({int line, int character})> _multiCursors = [];
  final List<Map<String, dynamic>> _pendingLspContentChanges = [];
  final List<VirtualRemovedBlock> _virtualRemovedBlocks = [];
  void Function(int lineNumber)? _toggleFoldCallback;
  void Function(int line)? _scrollToLineCallback;
  Timer? _flushTimer, _codeActionTimer, _syncTimer;
  Timer? _documentColorTimer, _foldRangesTimer, _documentHighlightTimer;
  Timer? _cclsRefreshTimer, _debounceTimer;
  Timer? _lspTypingTimer, _lspDocumentSyncTimer;
  String? _cachedText, _bufferLineText, _openedFile;
  String Function()? _pendingLspFullText;
  String? _lastTypedCharacter;
  String _imeProjectionText = '', _previousValue = "";
  TextSelection? _lastSentSelection;
  TextSelection _prevSelection = const TextSelection.collapsed(offset: 0);
  TextSelection _imeProjectionSelection = const TextSelection.collapsed(
    offset: 0,
  );
  TextRange _imeComposingGlobal = TextRange.empty;
  TextRange _imeProjectionComposing = TextRange.empty;
  bool _suppressImeSync = false;
  CompoundOperationHandle? _imeCompositionUndoGroup;

  // --- IME composition overlay state ---------------------------------------
  // While a composition is active the composing text is NOT written to the
  // document; it lives in [_imeComposition] and is painted as an overlay by the
  // renderer (see [ImeComposition]). The fields below mirror the platform's
  // editing value so each delta can be reduced to a single committed document
  // edit on commit/cancel, leaving the document free of transient composing
  // glyphs.
  ImeComposition? _imeComposition;
  // Authoritative mirror of the platform's TextEditingValue (text including any
  // composing range, in projection-local coordinates).
  String _imeMirrorText = '';
  TextSelection _imeMirrorSelection = const TextSelection.collapsed(offset: 0);
  TextRange _imeMirrorComposing = TextRange.empty;
  // The committed projection-window content -- equals [_imeMirrorText] with the
  // composing range excised, and is kept identical to the document's projected
  // window. Diffed against the mirror's committed text to derive document edits.
  String _imeWindowCommitted = '';
  int _imeWindowStart = 0;
  // Repaint signal consumed by the renderer when the composition overlay
  // changes without a document edit (e.g. typing further pinyin letters).
  bool imeCompositionChanged = false;
  // The selection captured at the start of a platform input event, used to
  // replace it when a composition begins over it. Some platforms collapse the
  // selection in a separate event immediately before composing, so the live
  // selection cannot be relied on to still be non-collapsed at composition
  // start. Cleared on real caret moves and once consumed.
  TextSelection? _pendingSelectionReplacement;
  // When a composition replaces a selection that the platform keeps in its own
  // value (insertion-semantics platforms), the selection is deleted from the
  // document and the gap recorded here in mirror-local coordinates; the
  // committed-text reconciliation then excises this region so the document does
  // not re-grow it. Inactive when [_imeMirrorDeleteLen] is 0. [_imeMirrorDeletedText]
  // is the exact text removed: the excision stays active only while the platform
  // still holds that text at the recorded spot, and self-disables the moment the
  // platform drops the selection on its own (so we never excise live text).
  int _imeMirrorDeleteStart = -1;
  int _imeMirrorDeleteLen = 0;
  String _imeMirrorDeletedText = '';
  // Tracks the user's actual intended keystrokes and the previous composing text.
  // Used to distinguish between IME-generated separators (like a'a'a'a)
  // and explicit user-typed punctuation.
  String _rawTypedComposingText = '';
  String _lastComposingText = '';

  bool _bufferDirty = false, bufferNeedsRepaint = false, selectionOnly = false;
  bool _imeProjectionDirty = true, _imeSelectionNeedsResync = false;
  bool deleteFoldRangeOnDeletingFirstLine = false;
  bool _lspReady = false, _isTyping = false, _isDisposed = false;
  bool _usesCclsSemanticHighlight = false, _suppressLspFallbackSync = false;
  bool _cclsForcedRefreshAttempted = false;
  bool _lspFoldRangesAdjustedNotFetched = false;
  bool _inlayHintsVisible = false, documentHighlightsChanged = false;
  int _imeProjectionStartOffset = 0, _completionRequestId = 0;
  int _cachedTextVersion = -1, _currentVersion = 0, _semanticTokensVersion = 0;
  int _bufferLineRopeStart = 0, _bufferLineOriginalLength = 0;
  int? dirtyLine, _bufferLineIndex;
  List<String>? _cachedBufferLines;
  List<dynamic> _suggestions = [];
  List<InlayHint> _inlayHints = [];
  List<DocumentColor> _documentColors = [];
  List<DocumentHighlight> _documentHighlights = [];
  UndoRedoController? _undoController;
  VoidCallback? _foldAllCallback, _unfoldAllCallback;
  StreamSubscription? _lspResponsesSubscription;
  Set<String> _wordCache = {};
  GhostText? _ghostText;
  Map<int, FoldRange>? _lspFoldRanges;
  String? _activeCompletionKey;
  ({String filePath, String prefix, int line, int character})?
  _queuedCompletionRequest;

  CodeForgeController({this.lspConfig}) {
    if (lspConfig != null) {
      (() async {
        try {
          if (lspConfig is LspSocketConfig) {
            await (lspConfig! as LspSocketConfig).connect();
          }
          if (!lspConfig!.isInitialized) {
            await lspConfig!.initialize();
          }
          if (openedFile != null) {
            await _openDocumentInLsp();
          }
        } catch (e) {
          debugPrint('Error initializing LSP: $e');
        } finally {
          _listeners.add(_highlightListener);
        }
      })();

      _lspResponsesSubscription = lspConfig!.responses.listen((data) async {
        try {
          if (data['method'] == 'workspace/applyEdit') {
            final Map<String, dynamic>? params = data['params'];
            if (params != null && params.isNotEmpty) {
              if (params.containsKey('edit')) {
                await applyWorkspaceEdit(params);
              }
            }
          }

          if (data['method'] == 'workspace/configuration') {
            final id = data['id'];
            await lspConfig!.sendResponse(id, [
              lspConfig!.workspaceConfiguration,
            ]);
          }

          if (data['method'] == 'textDocument/publishDiagnostics') {
            final List<dynamic> rawDiagnostics =
                data['params']?['diagnostics'] ?? [];
            if (rawDiagnostics.isNotEmpty) {
              final List<LspErrors> errors = [];
              for (final item in rawDiagnostics) {
                if (item is! Map<String, dynamic>) continue;
                int severity = item['severity'] ?? 0;
                if (severity == 1 && lspConfig!.disableError) {
                  severity = 0;
                }
                if (severity == 2 && lspConfig!.disableWarning) {
                  severity = 0;
                }
                if (severity > 0) {
                  errors.add(
                    LspErrors(
                      severity: severity,
                      range: item['range'],
                      message: item['message'] ?? '',
                    ),
                  );
                }
              }
              if (!_isDisposed) diagnosticsNotifier.value = errors;

              _codeActionTimer?.cancel();
              _codeActionTimer = Timer(
                const Duration(milliseconds: 250),
                () async {
                  if (errors.isEmpty) {
                    if (!_isDisposed) codeActionsNotifier.value = null;
                    return;
                  }
                  int minStartLine = errors
                      .map((d) => d.range['start']?['line'] as int? ?? 0)
                      .reduce((a, b) => a < b ? a : b);
                  int minStartChar = errors
                      .map((d) => d.range['start']?['character'] as int? ?? 0)
                      .reduce((a, b) => a < b ? a : b);
                  int maxEndLine = errors
                      .map((d) => d.range['end']?['line'] as int? ?? 0)
                      .reduce((a, b) => a > b ? a : b);
                  int maxEndChar = errors
                      .map((d) => d.range['end']?['character'] as int? ?? 0)
                      .reduce((a, b) => a > b ? a : b);

                  try {
                    final actions = await lspConfig!.getCodeActions(
                      filePath: openedFile!,
                      startLine: minStartLine,
                      startCharacter: minStartChar,
                      endLine: maxEndLine,
                      endCharacter: maxEndChar,
                      diagnostics: rawDiagnostics.cast<Map<String, dynamic>>(),
                    );
                    if (!_isDisposed) codeActionsNotifier.value = actions;
                  } catch (e) {
                    debugPrint('Error fetching code actions: $e');
                  }
                },
              );
            } else {
              if (!_isDisposed) diagnosticsNotifier.value = [];
              if (!_isDisposed) codeActionsNotifier.value = null;
            }
          }

          if (data['method'] == r'$ccls/publishSemanticHighlight') {
            final params = data['params'] as Map<String, dynamic>?;
            if (params != null) {
              final uri = params['uri'] as String?;
              final symbols = params['symbols'] as List<dynamic>?;

              if (uri != null &&
                  openedFile != null &&
                  uri.endsWith(openedFile!.split('/').last) &&
                  symbols != null) {
                _usesCclsSemanticHighlight = true;
                final tokens = _convertCclsSymbolsToTokens(symbols);

                if (tokens.isEmpty &&
                    !_cclsForcedRefreshAttempted &&
                    lspConfig != null &&
                    openedFile != null) {
                  _cclsForcedRefreshAttempted = true;
                  unawaited(() async {
                    try {
                      await lspConfig!.updateDocument(openedFile!, text);
                      await lspConfig!.saveDocument(openedFile!, text);
                    } catch (_) {}
                  }());
                }

                if (!_isDisposed) {
                  semanticTokens.value = (tokens, _semanticTokensVersion++);
                }
              }
            }
          }
        } catch (e, st) {
          debugPrint('Error handling LSP response: $e\n$st');
        }
      });
    } else {
      _listeners.add(() async {
        if (!enableLocalSuggestions) return;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
          if (text != _previousValue) {
            _wordCache = await _extractWords();
          }
          _previousValue = text;
          _prevSelection = selection;

          final cursorPosition = selection.extentOffset;
          final prefix = getCurrentWordPrefix(text, cursorPosition);
          if (_isTyping && selection.extentOffset > 0) {
            String currentWord = '';
            if (text.isNotEmpty) {
              final match = RegExp(
                r'[\w\u0600-\u06FF\u08A0-\u08FF\u0590-\u05FF\-]+$',
              ).firstMatch(
                text.substring(0, scalarToUtf16Offset(text, cursorPosition)),
              );
              if (match != null) {
                currentWord = match.group(0)!;
              }
            }

            _suggestions.clear();

            for (final i in _wordCache) {
              if (!_suggestions.contains(i) && i != currentWord) {
                _suggestions.add(i);
              }
            }
            if (prefix.isNotEmpty) {
              _suggestions = _suggestions
                  .where((s) => s.startsWith(prefix))
                  .toList();
            }
            _sortSuggestions(prefix);
            final triggerChar = text[cursorPosition - 1];
            final isTriggerChar = _isCompletionTriggerChar(triggerChar);
            final isAlphaChar = _isAlpha(triggerChar);

            if (!isTriggerChar && !isAlphaChar) {
              if (!_isDisposed) suggestionsNotifier.value = null;
              return;
            }
            if (!_isDisposed) suggestionsNotifier.value = _suggestions;
          } else {
            if (!_isDisposed) suggestionsNotifier.value = null;
          }
        });
      });
    }
  }

  Future<void> _openDocumentInLsp({String? previousFile}) async {
    if (lspConfig == null || !lspConfig!.isInitialized || openedFile == null) {
      return;
    }

    try {
      if (previousFile != null && previousFile != openedFile) {
        await lspConfig!.closeDocument(previousFile);
      }
      await lspConfig!.openDocument(openedFile!);
      _lspReady = true;
      _cclsForcedRefreshAttempted = false;

      if (lspConfig!.capabilities.semanticHighlighting &&
          !lspConfig!.supportsSemanticTokensPull) {
        await lspConfig!.updateDocument(openedFile!, text);
        await lspConfig!.saveDocument(openedFile!, text);
      }

      await fetchDocumentColors();
      await fetchLSPFoldRanges();
    } catch (e) {
      debugPrint('Error opening LSP document: $e');
    }
  }

  Future<void> _highlightListener() async {
    if (text != _previousValue && _lspReady) {
      final currentText = text;
      final currentSelection = selection;
      final isTypingLenMatch =
          currentText.length == _previousValue.length + 1 &&
          currentSelection.extentOffset == _prevSelection.extentOffset + 1 &&
          _isTyping;

      _lspTypingTimer?.cancel();
      _lspTypingTimer = Timer(_lspTypingDebounce, () async {
        if (_isDisposed || !_lspReady || openedFile == null) return;

        if (!(lspConfig?.supportsSemanticTokensPull ?? true)) {
          await lspConfig!.updateDocument(openedFile!, currentText);
        }

        if (_usesCclsSemanticHighlight && !_isDisposed) {
          semanticTokens.value = (null, _semanticTokensVersion++);
          _scheduleCclsRefresh();
        }

        if ((lspConfig?.capabilities.semanticHighlighting ?? false) &&
            (lspConfig?.supportsSemanticTokensPull ?? false)) {
          semanticTokens.value = (null, _semanticTokensVersion++);
        }

        _scheduleDocumentColorRefresh();
        _scheduleFoldRangesRefresh();

        if (isTypingLenMatch) {
          final cursorPosition = currentSelection.extentOffset;
          final line = getLineAtOffset(cursorPosition);
          final lineStartOffset = getLineStartOffset(line);
          if (cursorPosition - 1 >= currentText.length) return;
          final lineText = getLineText(line);
          final character = scalarToStringIndex(
            lineText,
            cursorPosition - lineStartOffset,
          );
          final prefix = getCurrentWordPrefix(currentText, cursorPosition);
          final triggerIndex = scalarToStringIndex(
            currentText,
            cursorPosition - 1,
          );
          final triggerChar = currentText[triggerIndex];
          final isTriggerChar = _isCompletionTriggerChar(triggerChar);
          final isAlphaChar = _isAlpha(triggerChar);

          if ((isTriggerChar || isAlphaChar) && !_isDisposed) {
            _requestCompletions(
              prefix: prefix,
              line: line,
              character: character,
            );
          } else {
            if (!_isDisposed) suggestionsNotifier.value = null;
          }
        } else {
          if (!_isDisposed) suggestionsNotifier.value = null;
        }
      });
    }
    _previousValue = text;
    _prevSelection = selection;
  }

  void _scheduleDocumentColorRefresh() {
    _documentColorTimer?.cancel();
    _documentColorTimer = Timer(_documentColorDebounce, () {
      if (!_isDisposed && _lspReady) {
        fetchDocumentColors();
      }
    });
  }

  void _scheduleFoldRangesRefresh() {
    _foldRangesTimer?.cancel();
    _foldRangesTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isDisposed && _lspReady) {
        fetchLSPFoldRanges();
      }
    });
  }

  void _scheduleCclsRefresh() {
    _cclsRefreshTimer?.cancel();
    _cclsRefreshTimer = Timer(_cclsRefreshDebounce, () async {
      if (!_isDisposed &&
          _lspReady &&
          _usesCclsSemanticHighlight &&
          openedFile != null) {
        await lspConfig!.updateDocument(openedFile!, text);
        await lspConfig!.saveDocument(openedFile!, text);
      }
    });
  }

  void _requestCompletions({
    required String prefix,
    required int line,
    required int character,
  }) {
    final filePath = openedFile;
    if (!_lspReady || filePath == null) return;

    final completionKey = '$filePath|$line|$character|$prefix';
    if (_activeCompletionKey == completionKey) {
      return;
    }

    if (_completionRequestId > 0 &&
        _queuedCompletionRequest != null &&
        _completionRequestKey(_queuedCompletionRequest!) == completionKey) {
      return;
    }

    if (_activeCompletionKey != null) {
      _queuedCompletionRequest = (
        filePath: filePath,
        prefix: prefix,
        line: line,
        character: character,
      );
      return;
    }

    final requestId = ++_completionRequestId;
    _activeCompletionKey = completionKey;
    unawaited(_fetchCompletions(requestId, prefix, line, character));
  }

  Future<void> _fetchCompletions(
    int requestId,
    String prefix,
    int line,
    int character,
  ) async {
    if (_isDisposed || !_lspReady || openedFile == null) return;
    await Future<void>.delayed(Duration.zero);
    final completions = await lspConfig!.getCompletions(
      openedFile!,
      line,
      character,
    );
    if (_isDisposed || requestId != _completionRequestId) return;
    _suggestions = completions;
    _sortSuggestions(prefix);
    if (!_isDisposed) suggestionsNotifier.value = _suggestions;

    final pendingCompletion = _queuedCompletionRequest;
    _queuedCompletionRequest = null;
    _activeCompletionKey = null;

    if (pendingCompletion != null && !_isDisposed && _lspReady) {
      final nextKey = _completionRequestKey(pendingCompletion);
      if (openedFile == pendingCompletion.filePath) {
        _activeCompletionKey = nextKey;
        final nextRequestId = ++_completionRequestId;
        unawaited(
          _fetchCompletions(
            nextRequestId,
            pendingCompletion.prefix,
            pendingCompletion.line,
            pendingCompletion.character,
          ),
        );
      }
    }
  }

  String _completionRequestKey(
    ({String filePath, String prefix, int line, int character}) request,
  ) {
    return '${request.filePath}|${request.line}|${request.character}|${request.prefix}';
  }

  /// The semantic tokens generated by the LSP server.
  /// Used for LSP based syntax highlighting.
  final ValueNotifier<(List<LspSemanticToken>?, int)> semanticTokens =
      ValueNotifier((null, 0));

  int get documentVersion => _currentVersion;

  void publishSemanticTokens(List<LspSemanticToken> tokens) {
    semanticTokens.value = (tokens, _semanticTokensVersion++);
  }

  /// A [ValueNotifier] used to for showing code suggestions.
  /// returnd [null] if no suggestions are available.
  final ValueNotifier<List<dynamic>?> suggestionsNotifier = ValueNotifier(null);

  /// Returns the index of the selected suggestion from the [suggestionsNotifier]
  final ValueNotifier<int?> selectedSuggestionNotifier = ValueNotifier(null);

  /// A [ValueNotifier] that returns the error, warnings, info, etc from the LSP server.
  final ValueNotifier<List<LspErrors>> diagnosticsNotifier = ValueNotifier([]);

  /// A [ValueNotifier] that returns LSP code actions if available.
  final ValueNotifier<List<dynamic>?> codeActionsNotifier = ValueNotifier(null);

  /// A [ValueNotifier] that returns LSP signature help if available.
  final ValueNotifier<LspSignatureHelps?> signatureNotifier = ValueNotifier(
    null,
  );

  /// Whether the suggestions/completions are enabled or not.
  /// Includes both LSP and local word match suggestions.
  bool enableLocalSuggestions = false;

  /// The [FocusNode] instance, used to control editor focus
  FocusNode? focusNode;

  /// Configuration for Language Server Protocol integration.
  ///
  /// Enables advanced features like hover documentation, diagnostics,
  /// and semantic highlighting.
  LspConfig? lspConfig;

  /// Open a file using the controller API instead of passing `filePath` parameter to [CodeForge]
  set openedFile(String? file) {
    final previousFile = _openedFile;
    _openedFile = file;
    if (openedFile != null) {
      text = File(_openedFile!).readAsStringSync();
    }

    if (previousFile != openedFile &&
        lspConfig != null &&
        lspConfig!.isInitialized &&
        openedFile != null) {
      _lspDocumentSyncTimer?.cancel();
      _lspDocumentSyncTimer = null;
      _pendingLspContentChanges.clear();
      _pendingLspFullText = null;
      (() async {
        await _openDocumentInLsp(previousFile: previousFile);
      })();
    }
  }

  /// Returns the errors, warnings and info available in the editor as a [List<LspErrors>].
  /// Each [LspErrors] item holds the error severity, range and the message of each errors.
  List<LspErrors> get diagnostics => diagnosticsNotifier.value;

  /// The curent LSP suggestions shown in the editor.
  /// The vale is [List<dynamic>] because it can be either [String] or [LspCompletion].
  /// if the lspconfig is available and a valid server is configured, the [List<LspCompletion>] will be returned.
  /// else a [List<String>] with locally available words will be returned.
  List<dynamic>? get suggestions => suggestionsNotifier.value;

  /// The last character that was typed by the user.
  /// Returns an empty string if no character has been typed or if the last input was not a single character.
  String get lastTypedCharacter => _lastTypedCharacter ?? '';

  /// Currently opened file.
  String? get openedFile => _openedFile;

  VoidCallback? userCodeAction;

  Rope _rope = Rope('');
  Rope get rope => _rope;
  TextSelection _selectionCache = const TextSelection.collapsed(offset: 0);

  TextSelection get _selection {
    if (isBufferActive) {
      return _selectionCache;
    }
    final currentSelection = _rope.selection;
    if (_selectionCache != currentSelection) {
      _selectionCache = currentSelection;
    }
    return _selectionCache;
  }

  set _selection(TextSelection value) {
    _selectionCache = value;
    if (isBufferActive) {
      return;
    }
    _rope.setSelection(value);
  }

  /// The text input connection to the platform.
  TextInputConnection? connection;

  /// Set by the view layer. Invoked when the editor needs the platform input
  /// connection hard-reset (close + re-attach) -- e.g. to make the IME drop an
  /// in-progress composition and close its candidate window after the caret is
  /// moved by a click during composition.
  VoidCallback? requestImeReset;

  /// The range of text that has been modified and needs reprocessing.
  TextRange? dirtyRegion;

  String lastInsertedText = '';
  String lastDeletedText = '';

  /// Map of all fold ranges detected in the document, keyed by start line index.
  ///
  /// This map is automatically populated based on code structure
  /// (braces, indentation, etc.) when folding is enabled.
  ///
  /// Use the setter to update this map — it rebuilds internal sorted caches
  /// used for O(log n) fold-region lookups.
  Map<int, FoldRange?> get foldings => _foldings;

  Map<int, FoldRange?> _foldings = {};
  List<int> _foldedStartsSorted = [];
  List<int> _foldedEndsSorted = [];

  /// Set fold ranges in the editor
  set foldings(Map<int, FoldRange?> value) {
    _foldings = value;
    _rebuildFoldSortedCache();
  }

  /// List of search highlights to display in the editor.
  ///
  /// Add [SearchHighlight] objects to this list to highlight
  /// search results or other text ranges.
  List<SearchHighlight> searchHighlights = [];

  /// Whether the search highlights have changed and need repaint.
  bool searchHighlightsChanged = false;

  /// Whether multi-cursor positions have changed and the editor needs repaint.
  bool multiCursorsChanged = false;

  /// Returns an unmodifiable view of the secondary cursor positions.
  List<({int line, int character})> get multiCursors =>
      List.unmodifiable(_multiCursors);

  /// Whether there are active secondary cursors.
  bool get hasMultiCursors => _multiCursors.isNotEmpty;

  /// Whether inlay hints have changed and need repaint
  bool inlayHintsChanged = false;

  /// Whether document colors have changed and need repaint
  bool documentColorsChanged = false;

  /// Whether decorations have changed and need repaint
  bool decorationsChanged = false;

  /// Returns an unmodifiable view of line decorations
  List<LineDecoration> get lineDecorations =>
      List.unmodifiable(_lineDecorations);

  /// Returns an unmodifiable view of gutter decorations
  List<GutterDecoration> get gutterDecorations =>
      List.unmodifiable(_gutterDecorations);

  /// Returns the current ghost text, if any
  GhostText? get ghostText => _ghostText;

  /// Returns the current virtual removed blocks (git diff deleted lines)
  List<VirtualRemovedBlock> get virtualRemovedBlocks =>
      List.unmodifiable(_virtualRemovedBlocks);

  /// Returns the current inlay hints
  List<InlayHint> get inlayHints => List.unmodifiable(_inlayHints);

  /// Returns whether inlay hints are currently visible
  bool get inlayHintsVisible => _inlayHintsVisible;

  /// Returns the current document colors
  List<DocumentColor> get documentColors => List.unmodifiable(_documentColors);

  /// Returns the current document highlights
  List<DocumentHighlight> get documentHighlights =>
      List.unmodifiable(_documentHighlights);

  /// LSP-provided fold ranges, or null if not available.
  /// If available, these should be used instead of the built-in fold range algorithm.
  Map<int, FoldRange>? get lspFoldRanges => _lspFoldRanges;

  /// Returns true if LSP fold ranges were adjusted (not fetched fresh).
  /// When true, the render object should not clear its fold cache.
  bool get lspFoldRangesWereAdjusted => _lspFoldRangesAdjustedNotFetched;

  /// Returns the index of the currently selected seuggestion if an LSP/normal suggestion is available.
  ///
  /// Note: This will only work on mobile devices.
  int? get currentlySelectedSuggestion => selectedSuggestionNotifier.value;
  set currentlySelectedSuggestion(int? value) =>
      selectedSuggestionNotifier.value = value;

  /// Adds a secondary cursor at the given [line] and [character] position.
  ///
  /// The position is clamped to valid bounds. Duplicate positions
  /// (including the primary cursor) are ignored.
  void addMultiCursor(int line, int character) {
    if (_multiCursors.length >= 50) return;
    final clampedLine = line.clamp(0, lineCount - 1);
    final lineText = getLineText(clampedLine);
    final scalarLength = lineText.runes.length;
    final clampedChar = character.clamp(0, scalarLength);

    for (final c in _multiCursors) {
      if (c.line == clampedLine && c.character == clampedChar) return;
    }

    final primaryLine = getLineAtOffset(selection.extentOffset);
    final primaryChar =
        selection.extentOffset - getLineStartOffset(primaryLine);
    if (clampedLine == primaryLine && clampedChar == primaryChar) return;

    _multiCursors.add((line: clampedLine, character: clampedChar));
    multiCursorsChanged = true;
    notifyListeners();
  }

  /// Removes all secondary cursors, keeping only the primary cursor.
  void clearMultiCursors() {
    if (_multiCursors.isEmpty) return;
    _multiCursors.clear();
    multiCursorsChanged = true;
    notifyListeners();
  }

  void _deduplicateMultiCursors() {
    if (_multiCursors.isEmpty) return;
    final primaryLine = getLineAtOffset(selection.extentOffset);
    final primaryChar =
        selection.extentOffset - getLineStartOffset(primaryLine);

    final beforeCount = _multiCursors.length;
    _multiCursors.removeWhere(
      (c) => c.line == primaryLine && c.character == primaryChar,
    );
    if (_multiCursors.length != beforeCount) {
      multiCursorsChanged = true;
    }
  }

  /// Moves every secondary cursor one character to the left.
  ///
  /// When [isShiftPressed] is true the secondary cursors are cleared because
  /// extending a multi-cursor selection is not supported.
  void moveMultiCursorsLeft({bool isShiftPressed = false}) {
    if (_multiCursors.isEmpty) return;
    if (isShiftPressed) {
      clearMultiCursors();
      return;
    }
    final updated = <({int line, int character})>[];
    for (final cursor in _multiCursors) {
      final offset = _multiCursorToOffset(cursor);
      final newOffset = (offset - 1).clamp(0, _rope.length);
      final newLine = _rope.getLineAtOffset(newOffset);
      final newLineStart = _rope.getLineStartOffset(newLine);
      updated.add((line: newLine, character: newOffset - newLineStart));
    }
    _updateMultiCursorsFromList(updated);
  }

  /// Moves every secondary cursor one character to the right.
  ///
  /// When [isShiftPressed] is true the secondary cursors are cleared.
  void moveMultiCursorsRight({bool isShiftPressed = false}) {
    if (_multiCursors.isEmpty) return;
    if (isShiftPressed) {
      clearMultiCursors();
      return;
    }
    final updated = <({int line, int character})>[];
    for (final cursor in _multiCursors) {
      final offset = _multiCursorToOffset(cursor);
      final newOffset = (offset + 1).clamp(0, _rope.length);
      final newLine = _rope.getLineAtOffset(newOffset);
      final newLineStart = _rope.getLineStartOffset(newLine);
      updated.add((line: newLine, character: newOffset - newLineStart));
    }
    _updateMultiCursorsFromList(updated);
  }

  /// Moves every secondary cursor up one line, maintaining its column.
  ///
  /// Folded regions are skipped exactly as they are for the primary cursor.
  /// When [isShiftPressed] is true the secondary cursors are cleared.
  void moveMultiCursorsUp({bool isShiftPressed = false}) {
    if (_multiCursors.isEmpty) return;
    final isAltPressed = HardwareKeyboard.instance.isAltPressed;
    if (isShiftPressed && !isAltPressed) {
      clearMultiCursors();
      return;
    }
    final updated = <({int line, int character})>[];
    for (final cursor in _multiCursors) {
      final cursorLine = cursor.line.clamp(0, lineCount - 1);
      if (cursorLine <= 0) {
        updated.add((line: 0, character: 0));
        continue;
      }
      int targetLine = cursorLine - 1;
      while (targetLine > 0 && isLineInFoldedRegion(targetLine)) {
        targetLine--;
      }
      if (isLineInFoldedRegion(targetLine)) {
        targetLine = getFoldStartForLine(targetLine) ?? 0;
      }
      final prevLineText = getLineText(targetLine);
      final scalarLength = prevLineText.runes.length;
      final newChar = cursor.character.clamp(0, scalarLength);
      updated.add((line: targetLine, character: newChar));
    }
    _updateMultiCursorsFromList(updated);
  }

  /// Moves every secondary cursor down one line, maintaining its column.
  ///
  /// Folded regions are skipped exactly as they are for the primary cursor.
  /// When [isShiftPressed] is true the secondary cursors are cleared.
  void moveMultiCursorsDown({bool isShiftPressed = false}) {
    if (_multiCursors.isEmpty) return;
    final isAltPressed = HardwareKeyboard.instance.isAltPressed;
    if (isShiftPressed && !isAltPressed) {
      clearMultiCursors();
      return;
    }
    final updated = <({int line, int character})>[];
    for (final cursor in _multiCursors) {
      final cursorLine = cursor.line.clamp(0, lineCount - 1);
      if (cursorLine >= lineCount - 1) {
        final lastLineText = getLineText(lineCount - 1);
        updated.add((
          line: lineCount - 1,
          character: lastLineText.runes.length,
        ));
        continue;
      }
      final foldAtCurrent = getFoldRangeAtCurrentLine(cursorLine);
      int targetLine;
      if (foldAtCurrent != null && foldAtCurrent.isFolded) {
        targetLine = foldAtCurrent.endIndex + 1;
      } else {
        targetLine = cursorLine + 1;
      }
      while (targetLine < lineCount && isLineInFoldedRegion(targetLine)) {
        final foldStart = getFoldStartForLine(targetLine);
        if (foldStart != null) {
          final fold = foldings[foldStart] ?? FoldRange(targetLine, targetLine);
          targetLine = fold.endIndex + 1;
        } else {
          targetLine++;
        }
      }
      if (targetLine >= lineCount) {
        final lastLineText = getLineText(lineCount - 1);
        updated.add((
          line: lineCount - 1,
          character: lastLineText.runes.length,
        ));
        continue;
      }
      final nextLineText = getLineText(targetLine);
      final scalarLength = nextLineText.runes.length;
      final newChar = cursor.character.clamp(0, scalarLength);
      updated.add((line: targetLine, character: newChar));
    }
    _updateMultiCursorsFromList(updated);
  }

  void _updateMultiCursorsFromList(
    List<({int line, int character})> positions,
  ) {
    _multiCursors.clear();
    final primaryLine = getLineAtOffset(selection.extentOffset);
    final primaryChar =
        selection.extentOffset - getLineStartOffset(primaryLine);
    final seen = <({int line, int character})>{};
    for (final pos in positions) {
      if (pos.line == primaryLine && pos.character == primaryChar) continue;
      if (seen.contains(pos)) continue;
      seen.add(pos);
      _multiCursors.add(pos);
    }
    multiCursorsChanged = true;
    notifyListeners();
  }

  /// Performs backspace at all cursor positions (primary + secondary).
  void backspaceAtAllCursors() {
    if (readOnly || _multiCursors.isEmpty) return;

    _flushBuffer();

    final selectionBefore = _selection;
    final multiCursorsBeforeSnapshot = List<({int line, int character})>.from(
      _multiCursors,
    );
    final primaryOffset = selection.extentOffset.clamp(0, _rope.length);
    final offsets = <int>[primaryOffset];
    for (final c in _multiCursors) {
      offsets.add(_multiCursorToOffset(c).clamp(0, _rope.length));
    }

    final uniqueOffsets = offsets.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    final deletedLengths = List<int>.filled(uniqueOffsets.length, 0);
    final compound = _undoController?.beginCompoundOperation();

    for (int k = uniqueOffsets.length - 1; k >= 0; k--) {
      final offset = uniqueOffsets[k];
      if (offset > 0) {
        final deleteStart = (offset - 1).clamp(0, _rope.length);
        final deletedChar = _rope.substring(deleteStart, offset);
        deletedLengths[k] = deletedChar.runes.length;
        _rope.delete(deleteStart, offset);
        _currentVersion++;

        _recordDeletion(
          deleteStart,
          deletedChar,
          selectionBefore,
          TextSelection.collapsed(offset: deleteStart),
        );
      }
    }

    compound?.end();

    int cumulativeDeleted = 0;
    final newOffsets = List<int>.filled(uniqueOffsets.length, 0);
    for (int k = 0; k < uniqueOffsets.length; k++) {
      cumulativeDeleted += deletedLengths[k];
      newOffsets[k] = (uniqueOffsets[k] - cumulativeDeleted).clamp(
        0,
        _rope.length,
      );
    }

    final primaryIndex = uniqueOffsets.indexOf(primaryOffset);
    final primaryNewOffset = newOffsets[primaryIndex];
    _selection = TextSelection.collapsed(offset: primaryNewOffset);

    _multiCursors.clear();
    for (int k = 0; k < uniqueOffsets.length; k++) {
      final newOffset = newOffsets[k];
      if (newOffset == primaryNewOffset) continue;
      final newLine = _rope.getLineAtOffset(newOffset);
      final newLineStart = _rope.getLineStartOffset(newLine);
      _multiCursors.add((line: newLine, character: newOffset - newLineStart));
    }

    _patchLastCompoundMultiCursors(
      before: multiCursorsBeforeSnapshot,
      after: List<({int line, int character})>.from(_multiCursors),
    );

    dirtyRegion = TextRange(start: 0, end: _rope.length);
    _scheduleSyncToConnection();
    notifyListeners();
  }

  /// Performs deletion operation at all cursor positions.
  void deleteAtAllCursors() {
    if (readOnly || _multiCursors.isEmpty) return;

    _flushBuffer();

    final selectionBefore = _selection;
    final multiCursorsBeforeSnapshot = List<({int line, int character})>.from(
      _multiCursors,
    );
    final primaryOffset = selection.extentOffset.clamp(0, _rope.length);
    final offsets = <int>[primaryOffset];
    for (final c in _multiCursors) {
      offsets.add(_multiCursorToOffset(c).clamp(0, _rope.length));
    }

    final uniqueOffsets = offsets.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    final deletedLengths = List<int>.filled(uniqueOffsets.length, 0);
    final compound = _undoController?.beginCompoundOperation();

    for (int k = uniqueOffsets.length - 1; k >= 0; k--) {
      final offset = uniqueOffsets[k];
      if (offset < _rope.length) {
        final deletedChar = _rope.substring(offset, offset + 1);
        deletedLengths[k] = deletedChar.runes.length;
        _rope.delete(offset, offset + 1);
        _currentVersion++;

        _recordDeletion(
          offset,
          deletedChar,
          selectionBefore,
          TextSelection.collapsed(offset: offset),
        );
      } else {
        deletedLengths[k] = 0;
      }
    }

    compound?.end();

    int cumulativeDeleted = 0;
    final newOffsets = List<int>.filled(uniqueOffsets.length, 0);
    for (int k = 0; k < uniqueOffsets.length; k++) {
      newOffsets[k] = (uniqueOffsets[k] - cumulativeDeleted).clamp(
        0,
        _rope.length,
      );
      cumulativeDeleted += deletedLengths[k];
    }

    final primaryIndex = uniqueOffsets.indexOf(primaryOffset);
    final primaryNewOffset = newOffsets[primaryIndex];
    _selection = TextSelection.collapsed(offset: primaryNewOffset);

    _multiCursors.clear();
    for (int k = 0; k < uniqueOffsets.length; k++) {
      final newOffset = newOffsets[k];
      if (newOffset == primaryNewOffset) continue;
      final newLine = _rope.getLineAtOffset(newOffset);
      final newLineStart = _rope.getLineStartOffset(newLine);
      _multiCursors.add((line: newLine, character: newOffset - newLineStart));
    }

    _patchLastCompoundMultiCursors(
      before: multiCursorsBeforeSnapshot,
      after: List<({int line, int character})>.from(_multiCursors),
    );

    dirtyRegion = TextRange(start: 0, end: _rope.length);
    _imeProjectionDirty = true;
    _imeSelectionNeedsResync = true;
    _scheduleSyncToConnection();
    notifyListeners();
  }

  /// Inserts [textToInsert] at all cursor positions (primary + secondary).
  ///
  /// Insertions are performed from the last (highest-offset) cursor to the
  /// first so that earlier offsets are not invalidated by later insertions.
  /// After insertion, all cursor positions are updated to sit after the
  /// inserted text.
  void insertAtAllCursors(String textToInsert) {
    if (readOnly || _multiCursors.isEmpty) return;

    _flushBuffer();

    final selectionBefore = _selection;
    final multiCursorsBeforeSnapshot = List<({int line, int character})>.from(
      _multiCursors,
    );
    final primaryOffset = selection.extentOffset.clamp(0, _rope.length);
    final offsets = <int>[primaryOffset];
    for (final c in _multiCursors) {
      offsets.add(_multiCursorToOffset(c).clamp(0, _rope.length));
    }

    final uniqueOffsets = offsets.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    final insertedLengths = List<int>.filled(uniqueOffsets.length, 0);
    final compound = _undoController?.beginCompoundOperation();

    for (int k = uniqueOffsets.length - 1; k >= 0; k--) {
      final offset = uniqueOffsets[k];
      final safeOffset = offset.clamp(0, _rope.length);

      String toInsert = textToInsert;
      if (textToInsert.contains('\n')) {
        final lineIndex = _rope.getLineAtOffset(safeOffset);
        final lineStart = _rope.getLineStartOffset(lineIndex);
        final lineText = _rope.substring(lineStart, safeOffset);
        final indentMatch = RegExp(r'^\s*').firstMatch(lineText);
        final currentIndent = indentMatch?.group(0) ?? '';
        final shouldIncreaseIndent = RegExp(r'[:{[(]\s*$').hasMatch(lineText);
        final tabStr = useSpaceAsTab ? ' ' * tabSize : '\t';
        final extraIndent = shouldIncreaseIndent ? tabStr : '';
        toInsert = '\n$currentIndent$extraIndent';
      }

      insertedLengths[k] = toInsert.runes.length;
      _rope.insert(safeOffset, toInsert);
      _currentVersion++;

      _recordInsertion(
        safeOffset,
        toInsert,
        selectionBefore,
        TextSelection.collapsed(offset: safeOffset + toInsert.runes.length),
      );
    }

    compound?.end();

    int cumulativeInserted = 0;
    final newOffsets = List<int>.filled(uniqueOffsets.length, 0);
    for (int k = 0; k < uniqueOffsets.length; k++) {
      cumulativeInserted += insertedLengths[k];
      newOffsets[k] = (uniqueOffsets[k] + cumulativeInserted).clamp(
        0,
        _rope.length,
      );
    }

    final primaryIndex = uniqueOffsets.indexOf(primaryOffset);
    final primaryNewOffset = newOffsets[primaryIndex];
    _selection = TextSelection.collapsed(offset: primaryNewOffset);

    _multiCursors.clear();
    for (int k = 0; k < uniqueOffsets.length; k++) {
      final newOffset = newOffsets[k];
      if (newOffset == primaryNewOffset) continue;
      final newLine = _rope.getLineAtOffset(newOffset);
      final newLineStart = _rope.getLineStartOffset(newLine);
      _multiCursors.add((line: newLine, character: newOffset - newLineStart));
    }

    _patchLastCompoundMultiCursors(
      before: multiCursorsBeforeSnapshot,
      after: List<({int line, int character})>.from(_multiCursors),
    );

    dirtyRegion = TextRange(start: 0, end: _rope.length);
    _scheduleSyncToConnection();
    notifyListeners();
  }

  /// Clear LSP suggestions, hover info, code actions and signature help.
  void clearAllSuggestions() {
    suggestionsNotifier.value = null;
    selectedSuggestionNotifier.value = null;
    signatureNotifier.value = null;
    codeActionsNotifier.value = null;
  }

  /// Accepts the currently selected suggestion and inserts it at the cursor position.
  ///
  /// For mobile devices, uses [currentlySelectedSuggestion] to determine which
  /// suggestion to accept. For desktop/non-mobile, uses the provided [selectedIndex].
  ///
  /// The method handles different suggestion types:
  /// - [LspCompletion]: Uses the label property
  /// - [Map]: Uses 'insertText' or 'label' key
  /// - [String]: Uses the string directly
  ///
  /// After accepting, clears the suggestions and resets the selection index.
  ///
  /// Parameters:
  /// - [selectedIndex]: The index of the selected suggestion for desktop/non-mobile.
  ///   Defaults to 0 if not provided.
  void acceptSuggestion({int selectedIndex = 0}) {
    final suggestions = suggestionsNotifier.value;
    if (suggestions == null || suggestions.isEmpty) return;

    final isMobile = Platform.isAndroid || Platform.isIOS;
    final safeSelectedIndex = isMobile
        ? (currentlySelectedSuggestion ?? 0).clamp(0, suggestions.length - 1)
        : selectedIndex.clamp(0, suggestions.length - 1);
    final selected = suggestions[safeSelectedIndex];
    final insertText = _extractSuggestionText(selected);

    if (insertText.isNotEmpty) {
      insertAtCurrentCursor(insertText, replaceTypedChar: true);
    }

    suggestionsNotifier.value = null;
    currentlySelectedSuggestion = 0;
  }

  String _extractSuggestionText(dynamic suggestion) {
    if (suggestion is LspCompletion) {
      return suggestion.label;
    }
    if (suggestion is Map) {
      final dynamic insertText =
          suggestion['insertText'] ??
          suggestion['value'] ??
          suggestion['label'];
      return insertText is String ? insertText : '';
    }
    if (suggestion is String) {
      return suggestion;
    }

    final dynamic dynamicSuggestion = suggestion;
    try {
      final dynamic insertText = dynamicSuggestion.insertText;
      if (insertText is String && insertText.isNotEmpty) return insertText;
    } catch (_) {}
    try {
      final dynamic value = dynamicSuggestion.value;
      if (value is String && value.isNotEmpty) return value;
    } catch (_) {}
    try {
      final dynamic label = dynamicSuggestion.label;
      if (label is String) return label;
    } catch (_) {}
    return '';
  }

  /// Adds a line decoration to the editor.
  ///
  /// Line decorations can highlight code ranges with background colors,
  /// borders, or underlines. Useful for git diff, code coverage, etc.
  ///
  /// Example - Git diff added lines:
  /// ```dart
  /// controller.addLineDecoration(LineDecoration(
  ///   id: 'git-add-1',
  ///   startLine: 10,
  ///   endLine: 15,
  ///   type: LineDecorationType.background,
  ///   color: Colors.green.withOpacity(0.2),
  /// ));
  /// ```
  void addLineDecoration(LineDecoration decoration) {
    _lineDecorations.removeWhere((d) => d.id == decoration.id);
    _lineDecorations.add(decoration);
    _lineDecorations.sort((a, b) => a.priority.compareTo(b.priority));
    decorationsChanged = true;
    notifyListeners();
  }

  /// Adds multiple line decorations at once.
  ///
  /// More efficient than calling [addLineDecoration] multiple times.
  void addLineDecorations(List<LineDecoration> decorations) {
    for (final decoration in decorations) {
      _lineDecorations.removeWhere((d) => d.id == decoration.id);
      _lineDecorations.add(decoration);
    }
    _lineDecorations.sort((a, b) => a.priority.compareTo(b.priority));
    decorationsChanged = true;
    notifyListeners();
  }

  /// Removes a line decoration by its ID.
  void removeLineDecoration(String id) {
    _lineDecorations.removeWhere((d) => d.id == id);
    decorationsChanged = true;
    notifyListeners();
  }

  /// Removes all line decorations.
  void clearLineDecorations() {
    _lineDecorations.clear();
    decorationsChanged = true;
    notifyListeners();
  }

  /// Adds a gutter decoration to the editor.
  ///
  /// Gutter decorations appear in the line number area, useful for
  /// git diff indicators, breakpoints, bookmarks, etc.
  ///
  /// Example - Git diff indicator:
  /// ```dart
  /// controller.addGutterDecoration(GutterDecoration(
  ///   id: 'git-add-gutter-1',
  ///   startLine: 10,
  ///   endLine: 15,
  ///   type: GutterDecorationType.colorBar,
  ///   color: Colors.green,
  /// ));
  /// ```
  void addGutterDecoration(GutterDecoration decoration) {
    _gutterDecorations.removeWhere((d) => d.id == decoration.id);
    _gutterDecorations.add(decoration);
    _gutterDecorations.sort((a, b) => a.priority.compareTo(b.priority));
    decorationsChanged = true;
    notifyListeners();
  }

  /// Adds multiple gutter decorations at once.
  void addGutterDecorations(List<GutterDecoration> decorations) {
    for (final decoration in decorations) {
      _gutterDecorations.removeWhere((d) => d.id == decoration.id);
      _gutterDecorations.add(decoration);
    }
    _gutterDecorations.sort((a, b) => a.priority.compareTo(b.priority));
    decorationsChanged = true;
    notifyListeners();
  }

  /// Removes a gutter decoration by its ID.
  void removeGutterDecoration(String id) {
    _gutterDecorations.removeWhere((d) => d.id == id);
    decorationsChanged = true;
    notifyListeners();
  }

  /// Removes all gutter decorations.
  void clearGutterDecorations() {
    _gutterDecorations.clear();
    decorationsChanged = true;
    notifyListeners();
  }

  /// Sets the ghost text (inline suggestion) at a specific position.
  ///
  /// Ghost text appears as semi-transparent text, typically used for
  /// AI code completion suggestions. Only one ghost text can be active.
  ///
  /// Example:
  /// ```dart
  /// controller.setGhostText(GhostText(
  ///   line: 10,
  ///   column: 15,
  ///   text: 'print("Hello, World!");',
  ///   style: TextStyle(
  ///     color: Colors.grey.withOpacity(0.5),
  ///     fontStyle: FontStyle.italic,
  ///   ),
  /// ));
  /// ```
  ///
  /// Pass null to clear the ghost text.
  void setGhostText(GhostText? ghostText) {
    _ghostText = ghostText;
    decorationsChanged = true;
    notifyListeners();
  }

  /// Clears the ghost text.
  void clearGhostText() {
    _ghostText = null;
    decorationsChanged = true;
    notifyListeners();
  }

  /// Shows inlay hints in the editor.
  ///
  /// This fetches inlay hints from the LSP server for the visible range
  /// and displays them inline in the code. Sets readOnly to true while
  /// hints are visible to prevent user input.
  ///
  /// Inlay hints show type annotations (kind: 1) and parameter names (kind: 2).
  ///
  /// Example:
  /// ```dart
  /// // Call this when Ctrl+Alt is pressed
  /// await controller.showInlayHints();
  /// ```
  Future<void> showInlayHints() async {
    if (_inlayHintsVisible || lspConfig == null || openedFile == null) return;

    _inlayHintsVisible = true;
    readOnly = true;

    try {
      final endLine = lineCount > 500 ? 500 : lineCount;
      final response = await lspConfig!.getInlayHints(
        openedFile!,
        0,
        0,
        endLine,
        0,
      );

      final result = response['result'];
      if (result is List) {
        _inlayHints = result
            .whereType<Map<String, dynamic>>()
            .map((data) => InlayHint.fromLsp(data))
            .toList();
      } else {
        _inlayHints = [];
      }

      inlayHintsChanged = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching inlay hints: $e');
      _inlayHintsVisible = false;
      readOnly = false;
    }
  }

  /// Hides inlay hints from the editor.
  ///
  /// This clears all inlay hints and restores the editor to editable mode.
  ///
  /// Example:
  /// ```dart
  /// // Call this when Ctrl+Alt is released
  /// controller.hideInlayHints();
  /// ```
  void hideInlayHints() {
    if (!_inlayHintsVisible) return;

    _inlayHintsVisible = false;
    _inlayHints = [];
    readOnly = false;
    inlayHintsChanged = true;
    notifyListeners();
  }

  /// Sets inlay hints directly.
  ///
  /// Use this method if you want to provide custom inlay hints
  /// instead of fetching them from the LSP server.
  void setInlayHints(List<InlayHint> hints) {
    _inlayHints = hints;
    inlayHintsChanged = true;
    notifyListeners();
  }

  /// Clears all inlay hints.
  void clearInlayHints() {
    _inlayHints = [];
    inlayHintsChanged = true;
    notifyListeners();
  }

  /// Fetches and displays document colors from the LSP server.
  ///
  /// Document colors are displayed as small color boxes inline with
  /// color literals in the code (e.g., Colors.red, Color(0xFFFF0000)).
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchDocumentColors();
  /// ```
  Future<void> fetchDocumentColors() async {
    if (lspConfig == null || openedFile == null) return;
    final file = openedFile!;

    try {
      final response = await lspConfig!.getDocumentColor(file);
      if (_isDisposed || openedFile != file) return;
      final result = response['result'];

      if (result is List) {
        _documentColors = result
            .whereType<Map<String, dynamic>>()
            .map((data) => DocumentColor.fromLsp(data))
            .toList();
      } else {
        _documentColors = [];
      }

      documentColorsChanged = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching document colors: $e');
    }
  }

  /// Sets document colors directly.
  ///
  /// Use this method if you want to provide custom document colors
  /// instead of fetching them from the LSP server.
  void setDocumentColors(List<DocumentColor> colors) {
    _documentColors = colors;
    documentColorsChanged = true;
    notifyListeners();
  }

  /// Clears all document colors.
  void clearDocumentColors() {
    _documentColors = [];
    documentColorsChanged = true;
    notifyListeners();
  }

  /// Fetches document highlights for a symbol at the cursor position.
  ///
  /// This highlights all occurrences of the symbol at the given position.
  /// Should be called with a debounce delay to avoid frequent calls.
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchDocumentHighlights(10, 5);
  /// ```
  Future<void> fetchDocumentHighlights(int line, int character) async {
    if (lspConfig == null || openedFile == null) return;
    final file = openedFile!;

    try {
      final result = await lspConfig!.getDocumentHighlight(
        file,
        line,
        character,
      );
      if (_isDisposed || openedFile != file) return;

      if (result.isNotEmpty) {
        _documentHighlights = result
            .whereType<Map<String, dynamic>>()
            .map((data) => DocumentHighlight.fromLsp(data))
            .toList();
      } else {
        _documentHighlights = [];
      }

      documentHighlightsChanged = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching document highlights: $e');
      _documentHighlights = [];
      documentHighlightsChanged = true;
      notifyListeners();
    }
  }

  /// Schedules a document highlights refresh with debouncing.
  ///
  /// Cancels any pending refresh and schedules a new one.
  void scheduleDocumentHighlightsRefresh(int line, int character) {
    _documentHighlightTimer?.cancel();
    _documentHighlightTimer = Timer(_documentHighlightDebounce, () {
      fetchDocumentHighlights(line, character);
    });
  }

  /// Clears all document highlights.
  void clearDocumentHighlights() {
    _documentHighlights = [];
    documentHighlightsChanged = true;
    notifyListeners();
  }

  /// Fetches fold ranges from the LSP server.
  ///
  /// If successful, these fold ranges will be used instead of the
  /// built-in fold range detection algorithm.
  ///
  /// Example:
  /// ```dart
  /// await controller.fetchLSPFoldRanges();
  /// ```
  Future<void> fetchLSPFoldRanges() async {
    if (lspConfig == null || openedFile == null) return;
    final file = openedFile!;

    try {
      final response = await lspConfig!.getLSPFoldRanges(file);
      if (_isDisposed || openedFile != file) return;
      final result = response['result'];

      if (result is List && result.isNotEmpty) {
        final Map<int, FoldRange> foldMap = {};
        final oldRanges = _lspFoldRanges;
        for (final item in result) {
          if (item is Map<String, dynamic>) {
            final startLine = item['startLine'] as int?;
            final endLine = item['endLine'] as int?;
            if (startLine != null && endLine != null && endLine > startLine) {
              final newFold = FoldRange(startLine, endLine);

              FoldRange? existing =
                  oldRanges?[startLine] ?? foldings[startLine];
              if (existing == null) {
                for (
                  int offset = 1;
                  offset <= 3 && existing == null;
                  offset++
                ) {
                  existing =
                      oldRanges?[startLine - offset] ??
                      oldRanges?[startLine + offset] ??
                      foldings[startLine - offset] ??
                      foldings[startLine + offset];
                  if (existing != null) {
                    final oldSpan = existing.endIndex - existing.startIndex;
                    final newSpan = endLine - startLine;
                    if ((oldSpan - newSpan).abs() > (oldSpan * 0.3)) {
                      existing = null;
                    }
                  }
                }
              }
              if (existing != null) {
                newFold.isFolded = existing.isFolded;
                newFold.originallyFoldedChildren =
                    existing.originallyFoldedChildren;
              }

              foldMap[startLine] = newFold;
            }
          }
        }
        _lspFoldRanges = foldMap.isEmpty ? null : foldMap;
      } else {
        _lspFoldRanges = null;
      }
      _lspFoldRangesAdjustedNotFetched = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching LSP fold ranges: $e');
      _lspFoldRanges = null;
    }
  }

  /// Clears LSP fold ranges, forcing fallback to built-in algorithm.
  void clearLSPFoldRanges() {
    _lspFoldRanges = null;
    _lspFoldRangesAdjustedNotFetched = false;
    notifyListeners();
  }

  /// Adjusts LSP fold ranges after a line count change.
  ///
  /// [editLine] is the line where the edit occurred.
  /// [lineDelta] is the number of lines added (positive) or removed (negative).
  void adjustLspFoldRangesForLineChange(int editLine, int lineDelta) {
    if (_lspFoldRanges == null || lineDelta == 0) return;

    final adjustedLspFoldRanges = <int, FoldRange>{};

    for (final entry in _lspFoldRanges!.entries) {
      final oldStartIndex = entry.key;
      final fold = entry.value;

      if (fold.endIndex < editLine) {
        adjustedLspFoldRanges[oldStartIndex] = fold;
      } else if (fold.startIndex == editLine) {
        final newStartIndex = fold.startIndex + lineDelta;
        final newEndIndex = fold.endIndex + lineDelta;
        if (newStartIndex >= 0 && newEndIndex >= newStartIndex) {
          final newFold = FoldRange(newStartIndex, newEndIndex);
          newFold.isFolded = fold.isFolded;
          newFold.originallyFoldedChildren = fold.originallyFoldedChildren;
          adjustedLspFoldRanges[newStartIndex] = newFold;
        }
      } else if (fold.startIndex <= editLine && fold.endIndex >= editLine) {
        final newEndIndex = fold.endIndex + lineDelta;
        if (newEndIndex >= oldStartIndex) {
          final newFold = FoldRange(oldStartIndex, newEndIndex);
          newFold.isFolded = fold.isFolded;
          newFold.originallyFoldedChildren = fold.originallyFoldedChildren;
          adjustedLspFoldRanges[oldStartIndex] = newFold;
        }
      } else if (fold.startIndex > editLine) {
        final newStartIndex = fold.startIndex + lineDelta;
        final newEndIndex = fold.endIndex + lineDelta;
        if (newStartIndex >= 0 && newEndIndex >= newStartIndex) {
          final newFold = FoldRange(newStartIndex, newEndIndex);
          newFold.isFolded = fold.isFolded;
          newFold.originallyFoldedChildren = fold.originallyFoldedChildren;
          adjustedLspFoldRanges[newStartIndex] = newFold;
        }
      }
    }

    _lspFoldRanges = adjustedLspFoldRanges.isEmpty
        ? null
        : adjustedLspFoldRanges;
    _lspFoldRangesAdjustedNotFetched = true;
  }

  /// Convenience method to set git diff decorations for multiple line ranges.
  ///
  /// [addedRanges] - List of (startLine, endLine) for added lines (green)
  /// [removedRanges] - List of ({afterLine, content}) for removed lines displayed
  ///   virtually without line numbers, similar to ghost text. [afterLine] is the
  ///   0-based line after which the removed content appears, and [content] is the
  ///   deleted text (use `\n` for multiple lines).
  /// [modifiedRanges] - List of (startLine, endLine) for modified lines (blue)
  void setGitDiffDecorations({
    List<(int startLine, int endLine)>? addedRanges,
    List<({int afterLine, String content})>? removedRanges,
    List<(int startLine, int endLine)>? modifiedRanges,
    Color addedColor = const Color(0xFF4CAF50),
    Color removedColor = const Color(0xFFE53935),
    Color modifiedColor = const Color(0xFF2196F3),
  }) {
    _lineDecorations.removeWhere((d) => d.id.startsWith('git-'));
    _gutterDecorations.removeWhere((d) => d.id.startsWith('git-'));
    _virtualRemovedBlocks.clear();

    int idx = 0;

    if (addedRanges != null) {
      for (final range in addedRanges) {
        _lineDecorations.add(
          LineDecoration(
            id: 'git-add-line-$idx',
            startLine: range.$1,
            endLine: range.$2,
            type: LineDecorationType.background,
            color: addedColor.withValues(alpha: 0.15),
          ),
        );
        _gutterDecorations.add(
          GutterDecoration(
            id: 'git-add-gutter-$idx',
            startLine: range.$1,
            endLine: range.$2,
            type: GutterDecorationType.colorBar,
            color: addedColor,
          ),
        );
        idx++;
      }
    }

    if (removedRanges != null) {
      final sorted = removedRanges.toList()
        ..sort((a, b) => a.afterLine.compareTo(b.afterLine));
      for (final range in sorted) {
        _virtualRemovedBlocks.add(
          VirtualRemovedBlock(
            afterLine: range.afterLine,
            content: range.content,
            backgroundColor: removedColor.withValues(alpha: 0.15),
            textStyle: TextStyle(color: removedColor.withValues(alpha: 0.7)),
          ),
        );
      }
    }

    if (modifiedRanges != null) {
      for (final range in modifiedRanges) {
        _lineDecorations.add(
          LineDecoration(
            id: 'git-modify-line-$idx',
            startLine: range.$1,
            endLine: range.$2,
            type: LineDecorationType.background,
            color: modifiedColor.withValues(alpha: 0.15),
          ),
        );
        _gutterDecorations.add(
          GutterDecoration(
            id: 'git-modify-gutter-$idx',
            startLine: range.$1,
            endLine: range.$2,
            type: GutterDecorationType.colorBar,
            color: modifiedColor,
          ),
        );
        idx++;
      }
    }

    decorationsChanged = true;
    notifyListeners();
  }

  /// Clears all git diff decorations.
  void clearGitDiffDecorations() {
    _lineDecorations.removeWhere((d) => d.id.startsWith('git-'));
    _gutterDecorations.removeWhere((d) => d.id.startsWith('git-'));
    _virtualRemovedBlocks.clear();
    decorationsChanged = true;
    notifyListeners();
  }

  /// Whether the editor is in read-only mode.
  ///
  /// When true, the user cannot modify the text content.
  bool readOnly = false;

  /// Use space instead of the `\t` character for tab key press.
  bool useSpaceAsTab = false;

  /// Custom tabSize for the editor.
  int tabSize = 1;

  /// The tabspace inserted on tab key press.
  String get tabSpace {
    if (useSpaceAsTab) {
      return ' ' * tabSize;
    }
    return '\t' * tabSize;
  }

  /// Whether the line structure has changed (lines added or removed).
  bool lineStructureChanged = false;

  /// Callback to get the LSP code action at the current cursor position
  void getCodeAction() {
    userCodeAction?.call();
  }

  /// Sets the undo controller for this editor.
  ///
  /// The undo controller manages the undo/redo history for text operations.
  /// Pass null to disable undo/redo functionality.
  void setUndoController(UndoRedoController? controller) {
    _undoController = controller;
    if (controller != null) {
      controller.setApplyEditCallback(_applyUndoRedoOperation);
    }
  }

  /// Save the current content, [controller.text] to the opened file.
  void saveFile() {
    if (openedFile == null) {
      throw FlutterError(
        "No file found.\nPlease open a file by providing a valid filePath to the CodeForge widget",
      );
    }
    final file = File(openedFile!);
    if (!file.existsSync()) {
      throw FlutterError(
        "No file found.\nPlease open a file by providing a valid filePath to the CodeForge widget",
      );
    }
    file.writeAsStringSync(text);
  }

  /// Moves the cursor one character to the left.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressLetfArrowKey({bool isShiftPressed = false}) {
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

    int newOffset;
    if (!isShiftPressed && selection.start != selection.end) {
      newOffset = selection.start;
    } else if (selection.extentOffset > 0) {
      newOffset = selection.extentOffset - 1;
    } else {
      newOffset = 0;
    }

    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(
          baseOffset: selection.baseOffset,
          extentOffset: newOffset,
        ),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: newOffset));
    }
  }

  /// Moves the cursor one character to the right.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressRightArrowKey({bool isShiftPressed = false}) {
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

    int newOffset;
    if (!isShiftPressed && selection.start != selection.end) {
      newOffset = selection.end;
    } else if (selection.extentOffset < length) {
      newOffset = selection.extentOffset + 1;
    } else {
      newOffset = length;
    }

    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(
          baseOffset: selection.baseOffset,
          extentOffset: newOffset,
        ),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: newOffset));
    }
  }

  /// Moves the cursor up one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressUpArrowKey({bool isShiftPressed = false}) {
    if (HardwareKeyboard.instance.isAltPressed) return;
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (_isMobile &&
        suggestionsNotifier.value != null &&
        currentlySelectedSuggestion == null) {
      currentlySelectedSuggestion = 0;
      return;
    }

    if (_isMobile &&
        suggestionsNotifier.value != null &&
        currentlySelectedSuggestion != null) {
      currentlySelectedSuggestion =
          (currentlySelectedSuggestion! - 1) %
          suggestionsNotifier.value!.length;
      return;
    }

    if (currentLine <= 0) {
      if (isShiftPressed) {
        setSelectionSilently(
          TextSelection(baseOffset: selection.baseOffset, extentOffset: 0),
        );
      } else {
        setSelectionSilently(const TextSelection.collapsed(offset: 0));
      }
      return;
    }

    int targetLine = currentLine - 1;
    while (targetLine > 0 && isLineInFoldedRegion(targetLine)) {
      targetLine--;
    }

    if (isLineInFoldedRegion(targetLine)) {
      targetLine = getFoldStartForLine(targetLine) ?? 0;
    }

    final lineStart = getLineStartOffset(currentLine);
    final column = selection.extentOffset - lineStart;
    final prevLineStart = getLineStartOffset(targetLine);
    final prevLineText = getLineText(targetLine);
    final prevLineLength = prevLineText.runes.length;
    final newColumn = column.clamp(0, prevLineLength);
    final newOffset = (prevLineStart + newColumn).clamp(0, length);

    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(
          baseOffset: selection.baseOffset,
          extentOffset: newOffset,
        ),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: newOffset));
    }
  }

  /// Moves the cursor down one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressDownArrowKey({bool isShiftPressed = false}) {
    if (HardwareKeyboard.instance.isAltPressed) return;
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (_isMobile &&
        suggestionsNotifier.value != null &&
        currentlySelectedSuggestion == null) {
      currentlySelectedSuggestion = 0;
      return;
    }

    if (_isMobile &&
        suggestionsNotifier.value != null &&
        currentlySelectedSuggestion != null) {
      currentlySelectedSuggestion =
          (currentlySelectedSuggestion! + 1) %
          suggestionsNotifier.value!.length;
      return;
    }

    if (currentLine >= lineCount - 1) {
      if (isShiftPressed) {
        setSelectionSilently(
          TextSelection(baseOffset: selection.baseOffset, extentOffset: length),
        );
      } else {
        setSelectionSilently(TextSelection.collapsed(offset: length));
      }
      return;
    }

    final foldAtCurrent = getFoldRangeAtCurrentLine(currentLine);
    int targetLine;
    if (foldAtCurrent != null && foldAtCurrent.isFolded) {
      targetLine = foldAtCurrent.endIndex + 1;
    } else {
      targetLine = currentLine + 1;
    }

    while (targetLine < lineCount && isLineInFoldedRegion(targetLine)) {
      final foldStart = getFoldStartForLine(targetLine);
      if (foldStart != null) {
        final fold = foldings[foldStart] ?? FoldRange(targetLine, targetLine);
        targetLine = fold.endIndex + 1;
      } else {
        targetLine++;
      }
    }

    if (targetLine >= lineCount) {
      final endOffset = length;
      if (isShiftPressed) {
        setSelectionSilently(
          TextSelection(
            baseOffset: selection.baseOffset,
            extentOffset: endOffset,
          ),
        );
      } else {
        setSelectionSilently(TextSelection.collapsed(offset: endOffset));
      }
      return;
    }

    final lineStart = getLineStartOffset(currentLine);
    final column = selection.extentOffset - lineStart;
    final nextLineStart = getLineStartOffset(targetLine);
    final nextLineText = getLineText(targetLine);
    final nextLineLength = nextLineText.runes.length;
    final newColumn = column.clamp(0, nextLineLength);
    final newOffset = (nextLineStart + newColumn).clamp(0, length);

    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(
          baseOffset: selection.baseOffset,
          extentOffset: newOffset,
        ),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: newOffset));
    }
  }

  /// Moves the cursor to the beginning of the current line.
  ///
  /// If the cursor is not at the first non-whitespace character, moves it
  /// there. If it is already there, moves it to column 0 (Smart Home).
  /// If [isShiftPressed] is true, extends the selection instead of collapsing.
  void pressHomeKey({bool isShiftPressed = false}) {
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineStart = getLineStartOffset(currentLine);
    final lineText = getLineText(currentLine);
    final leadingWhitespace =
        RegExp(r'^\s*').firstMatch(lineText)?.group(0)?.length ?? 0;
    final firstNonWhitespace = lineStart + leadingWhitespace;

    final targetOffset = selection.extentOffset == firstNonWhitespace
        ? lineStart
        : firstNonWhitespace;

    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(
          baseOffset: selection.baseOffset,
          extentOffset: targetOffset,
        ),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: targetOffset));
    }
  }

  /// Moves the cursor to the end of the current line.
  ///
  /// If [isShiftPressed] is true, extends the selection to the line end.
  void pressEndKey({bool isShiftPressed = false}) {
    if (suggestionsNotifier.value != null) {
      suggestionsNotifier.value = null;
    }

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineText = getLineText(currentLine);
    final lineStart = getLineStartOffset(currentLine);
    final scalarLength = lineText.runes.length;
    final lineEnd = lineStart + scalarLength;

    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(baseOffset: selection.baseOffset, extentOffset: lineEnd),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: lineEnd));
    }
  }

  /// Moves the cursor to the beginning of the document.
  ///
  /// If [isShiftPressed] is true, extends the selection to the document start.
  void pressDocumentHomeKey({bool isShiftPressed = false}) {
    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(baseOffset: selection.baseOffset, extentOffset: 0),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: 0));
    }
  }

  /// Moves the cursor to the end of the document.
  ///
  /// If [isShiftPressed] is true, extends the selection to the document end.
  void pressDocumentEndKey({bool isShiftPressed = false}) {
    final endOffset = length;
    if (isShiftPressed) {
      setSelectionSilently(
        TextSelection(
          baseOffset: selection.baseOffset,
          extentOffset: endOffset,
        ),
      );
    } else {
      setSelectionSilently(TextSelection.collapsed(offset: endOffset));
    }
  }

  /// Copies the currently selected text to the clipboard.
  ///
  /// If no text is selected, copies the entire current line, including its
  /// trailing newline when present.
  void copy() {
    final sel = selection;
    _flushBuffer();
    late final String selectedText;
    if (sel.start == sel.end) {
      final currentLine = getLineAtOffset(sel.extentOffset);
      final lineStart = getLineStartOffset(currentLine);
      final lineEnd = currentLine + 1 < lineCount
          ? getLineStartOffset(currentLine + 1)
          : length;
      selectedText = _rope.substring(lineStart, lineEnd);
    } else {
      selectedText = _rope.substring(sel.start, sel.end);
    }
    Clipboard.setData(ClipboardData(text: selectedText));
  }

  /// Cuts the currently selected text to the clipboard.
  ///
  /// If no text is selected, cuts the entire current line, including its
  /// trailing newline when present.
  void cut() {
    if (readOnly) return;
    final sel = selection;
    _flushBuffer();
    late final String selectedText;
    late final int deleteStart;
    late final int deleteEnd;
    if (sel.start == sel.end) {
      final currentLine = getLineAtOffset(sel.extentOffset);
      deleteStart = getLineStartOffset(currentLine);
      deleteEnd = currentLine + 1 < lineCount
          ? getLineStartOffset(currentLine + 1)
          : length;
      selectedText = _rope.substring(deleteStart, deleteEnd);
    } else {
      deleteStart = sel.start;
      deleteEnd = sel.end;
      selectedText = _rope.substring(deleteStart, deleteEnd);
    }
    Clipboard.setData(ClipboardData(text: selectedText));
    replaceRange(deleteStart, deleteEnd, '');
  }

  /// Pastes text from the clipboard at the current cursor position.
  ///
  /// Replaces any selected text with the pasted content.
  Future<void> paste() async {
    if (readOnly) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) return;
    final sel = selection;
    replaceRange(sel.start, sel.end, data.text!);
  }

  /// Selects all text in the editor.
  void selectAll() {
    setSelectionImmediately(TextSelection(baseOffset: 0, extentOffset: length));
  }

  /// The complete text content of the editor.
  ///
  /// Getting this property returns the full document text.
  /// Setting this property replaces all content and moves the cursor to the end.
  String get text {
    if (_cachedText == null || _cachedTextVersion != _currentVersion) {
      if (_bufferLineIndex != null && _bufferDirty) {
        final ropeText = _rope.getText();
        final beforeIndex = scalarToStringIndex(ropeText, _bufferLineRopeStart);
        final afterIndex = scalarToStringIndex(
          ropeText,
          _bufferLineRopeStart + _bufferLineOriginalLength,
        );
        final before = ropeText.substring(0, beforeIndex);
        final after = ropeText.substring(afterIndex);
        _cachedText = before + _bufferLineText! + after;
      } else {
        _cachedText = _rope.getText();
      }
      _cachedTextVersion = _currentVersion;
    }
    return _cachedText!;
  }

  String substring(int start, [int? end]) {
    final textLength = length;
    final safeStart = start.clamp(0, textLength);
    final safeEnd = (end ?? textLength).clamp(safeStart, textLength);

    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferStart = _bufferLineRopeStart;
      final bufferEnd = bufferStart + _bufferLineText!.runes.length;
      if (safeStart >= bufferStart && safeEnd <= bufferEnd) {
        final utf16Start = scalarToStringIndex(
          _bufferLineText!,
          safeStart - bufferStart,
        );
        final utf16End = scalarToStringIndex(
          _bufferLineText!,
          safeEnd - bufferStart,
        );
        return _bufferLineText!.substring(utf16Start, utf16End);
      }
      if (safeEnd <= bufferStart || safeStart >= bufferEnd) {
        return _rope.substring(safeStart, safeEnd);
      }
    }
    return _rope.substring(safeStart, safeEnd);
  }

  /// The total length of the document in characters.
  int get length {
    if (_bufferLineIndex != null && _bufferDirty) {
      return _rope.length +
          (_bufferLineText!.runes.length - _bufferLineOriginalLength);
    }
    return _rope.length;
  }

  /// The current text selection in the editor.
  ///
  /// For a cursor with no selection, [TextSelection.isCollapsed] will be true.
  TextSelection get selection => _selection;

  /// List of all lines in the document.
  List<String> get lines => _rope.cachedLines;

  /// Returns a window of lines without allocating the full buffer.
  List<String> getLinesRange(int startLine, int endLine) {
    return _rope.cachedLinesRange(startLine, endLine);
  }

  /// The total number of lines in the document.
  int get lineCount {
    if (_bufferLineIndex != null && _bufferDirty) {
      _cachedBufferLines ??= _bufferLineText!.split('\n');
      final newLines = _cachedBufferLines!.length - 1;
      return _rope.lineCount + newLines;
    }
    return _rope.lineCount;
  }

  /// The visible text content with folded regions hidden.
  ///
  /// Returns the document text with lines inside collapsed fold ranges removed.
  String get visibleText {
    if (foldings.isEmpty) return text;
    final visLines = getLinesRange(0, lineCount);
    for (final fold
        in foldings.values.where((f) => f != null).toList().reversed) {
      if (!fold!.isFolded) continue;
      final start = fold.startIndex + 1;
      final end = fold.endIndex + 1;
      final safeStart = start.clamp(0, visLines.length);
      final safeEnd = end.clamp(safeStart, visLines.length);
      if (safeEnd > safeStart) {
        visLines.removeRange(safeStart, safeEnd);
      }
    }
    return visLines.join('\n');
  }

  /// Gets the text content of a specific line.
  ///
  /// [lineIndex] is zero-based (0 for the first line).
  /// Returns the text of the line without the newline character.
  String getLineText(int lineIndex) {
    if (_bufferLineIndex != null && _bufferDirty) {
      _cachedBufferLines ??= _bufferLineText!.split('\n');
      final newLines = _cachedBufferLines!.length - 1;
      if (newLines > 0) {
        if (lineIndex >= _bufferLineIndex! &&
            lineIndex <= _bufferLineIndex! + newLines) {
          return _cachedBufferLines![lineIndex - _bufferLineIndex!];
        } else if (lineIndex > _bufferLineIndex! + newLines) {
          return _rope.getLineText(lineIndex - newLines);
        } else {
          return _rope.getLineText(lineIndex);
        }
      } else {
        if (lineIndex == _bufferLineIndex) {
          return _bufferLineText!;
        }
      }
    }
    return _rope.getLineText(lineIndex);
  }

  /// Gets the line number (zero-based) for a character offset.
  ///
  /// [charOffset] is the character position in the document.
  /// Returns the line index containing that character.
  int getLineAtOffset(int charOffset) {
    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferStart = _bufferLineRopeStart;
      final bufferScalarLength = _bufferLineText!.runes.length;
      final bufferEnd = bufferStart + bufferScalarLength;
      if (charOffset >= bufferStart && charOffset <= bufferEnd) {
        final localOffset = charOffset - bufferStart;
        final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
        final sub = _bufferLineText!.substring(0, utf16Local);
        return _bufferLineIndex! + '\n'.allMatches(sub).length;
      } else if (charOffset > bufferEnd) {
        final delta = bufferScalarLength - _bufferLineOriginalLength;
        final newLines = '\n'.allMatches(_bufferLineText!).length;
        return _rope.getLineAtOffset(charOffset - delta) + newLines;
      }
    }
    return _rope.getLineAtOffset(charOffset);
  }

  /// Gets the character offset where a line starts.
  ///
  /// [lineIndex] is zero-based (0 for the first line).
  /// Returns the character offset of the first character in that line.
  int getLineStartOffset(int lineIndex) {
    if (_bufferLineIndex != null && _bufferDirty) {
      final newLines = '\n'.allMatches(_bufferLineText!).length;
      if (newLines > 0) {
        if (lineIndex == _bufferLineIndex!) {
          return _bufferLineRopeStart;
        } else if (lineIndex > _bufferLineIndex! &&
            lineIndex <= _bufferLineIndex! + newLines) {
          final lines = _bufferLineText!.split('\n');
          int offset = _bufferLineRopeStart;
          for (int i = 0; i < lineIndex - _bufferLineIndex!; i++) {
            offset += lines[i].runes.length + 1;
          }
          return offset;
        } else if (lineIndex > _bufferLineIndex! + newLines) {
          final delta =
              _bufferLineText!.runes.length - _bufferLineOriginalLength;
          return _rope.getLineStartOffset(lineIndex - newLines) + delta;
        }
      } else {
        if (lineIndex == _bufferLineIndex!) return _bufferLineRopeStart;
        if (lineIndex > _bufferLineIndex!) {
          final delta =
              _bufferLineText!.runes.length - _bufferLineOriginalLength;
          return _rope.getLineStartOffset(lineIndex) + delta;
        }
      }
    }
    return _rope.getLineStartOffset(lineIndex);
  }

  /// Finds the start of the line containing [offset].
  int findLineStart(int offset) => _rope.findLineStart(offset);

  /// Finds the end of the line containing [offset].
  int findLineEnd(int offset) => _rope.findLineEnd(offset);

  set text(String newText) {
    _rope = Rope(newText);
    _currentVersion++;
    _selection = TextSelection.collapsed(offset: newText.length);
    _lastSentSelection = _selection;
    _imeProjectionDirty = true;
    dirtyRegion = TextRange(start: 0, end: newText.length);
    lastInsertedText = newText;
    lastDeletedText = '';
    _isTyping = false;
    _scheduleLspFullSync(() => newText);
    notifyListeners();
  }

  /// Sets the current text selection.
  ///
  /// Setting this property will update the selection and notify listeners.
  /// For a collapsed cursor, use `TextSelection.collapsed(offset: pos)`.
  set selection(TextSelection newSelection) {
    if (_selection == newSelection) return;

    if (isComposingActive) {
      // An external caret move (e.g. a click) during composition force-commits
      // the composition into the document at its anchor as a single edit, moves
      // the caret to the requested location, and hard-resets the platform input
      // connection so the OS closes its candidate window and abandons the
      // session. (Pushing an empty composing range via setEditingState does not
      // close the candidate window on desktop; a connection reset is the only
      // reliable cross-platform mechanism.)
      _selection = _commitCompositionAndRemapSelection(newSelection);
      selectionOnly = true;
      _isTyping = false;
      _imeProjectionDirty = true;
      requestImeReset?.call();
      notifyListeners();
      return;
    }

    _flushBuffer();

    // A real caret move abandons any selection pending IME replacement.
    _pendingSelectionReplacement = null;
    _selection = newSelection;
    selectionOnly = true;
    _isTyping = false;
    _imeProjectionDirty = true;

    // Push the new projection to the platform synchronously instead of on a
    // 50ms debounce. The debounce left a window where the platform still held
    // the old projection (or the full document) while the user started typing,
    // so the next keystroke was diffed against a stale base and landed at the
    // wrong offset. _syncToConnection is internally guarded against active
    // compositions and suppressed regions, so this stays safe.
    _syncToConnection();
    _deduplicateMultiCursors();

    notifyListeners();
  }

  /// Updates selection and syncs to text input connection for keyboard navigation.
  ///
  /// This method flushes any pending buffer first to ensure IME state is consistent.
  /// Use this for programmatic selection changes that should sync with the platform.
  void setSelectionSilently(TextSelection newSelection) {
    if (_selection == newSelection) return;

    if (isComposingActive) {
      newSelection = _commitCompositionAndRemapSelection(newSelection);
      requestImeReset?.call();
    }
    _pendingSelectionReplacement = null;
    _flushBuffer();

    final textLength = length;
    final clampedBase = newSelection.baseOffset.clamp(0, textLength);
    final clampedExtent = newSelection.extentOffset.clamp(0, textLength);
    newSelection = newSelection.copyWith(
      baseOffset: clampedBase,
      extentOffset: clampedExtent,
    );

    _selection = newSelection;
    selectionOnly = true;
    _isTyping = false;
    _imeProjectionDirty = true;

    _syncToConnection();
    _deduplicateMultiCursors();
    notifyListeners();
  }

  void setSelectionImmediately(TextSelection newSelection) {
    if (_selection == newSelection) return;

    if (isComposingActive) {
      newSelection = _commitCompositionAndRemapSelection(newSelection);
      requestImeReset?.call();
    }
    _pendingSelectionReplacement = null;
    _flushBuffer();

    final textLength = length;
    final clampedBase = newSelection.baseOffset.clamp(0, textLength);
    final clampedExtent = newSelection.extentOffset.clamp(0, textLength);
    newSelection = newSelection.copyWith(
      baseOffset: clampedBase,
      extentOffset: clampedExtent,
    );

    _selection = newSelection;
    selectionOnly = true;
    _isTyping = false;
    _imeProjectionDirty = true;

    _syncToConnection();
    _deduplicateMultiCursors();

    notifyListeners();
  }

  /// Adds a listener that will be called when the controller state changes.
  ///
  /// Listeners are notified on text changes, selection changes, and other
  /// state updates.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a previously added listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners of a state change.
  void notifyListeners() {
    if (_isDisposed) return;
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Moves the current line up by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the top or if the controller is read-only.
  void moveLineUp() {
    if (readOnly) return;
    _flushBuffer();
    final selection = this.selection;
    final selStart = selection.start;
    final selEnd = selection.end;
    final lineStart = _rope.findLineStart(selStart);
    if (lineStart == 0) return;
    final lineEnd = _rope.findLineEnd(selEnd);

    final prevLineEnd = lineStart - 1;
    final prevLineStart = _rope.findLineStart(prevLineEnd);
    final prevLine = _rope.substring(prevLineStart, prevLineEnd);
    final currentLines = _rope.substring(lineStart, lineEnd);

    replaceRange(prevLineStart, lineEnd, '$currentLines\n$prevLine');

    final prevLineLen = prevLineEnd - prevLineStart;
    final offsetDelta = prevLineLen + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset - offsetDelta,
      extentOffset: selection.extentOffset - offsetDelta,
    );
    setSelectionSilently(newSelection);
  }

  /// Moves the current line down by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the bottom or if the controller is read-only.
  void moveLineDown() {
    if (readOnly) return;
    _flushBuffer();
    final selection = this.selection;
    final selStart = selection.start;
    final selEnd = selection.end;
    final lineStart = _rope.findLineStart(selStart);
    final lineEnd = _rope.findLineEnd(selEnd);
    final nextLineStart = lineEnd + 1;
    if (nextLineStart >= _rope.length) return;
    final nextLineEnd = _rope.findLineEnd(nextLineStart);

    final currentLines = _rope.substring(lineStart, lineEnd);
    final nextLine = _rope.substring(nextLineStart, nextLineEnd);

    replaceRange(lineStart, nextLineEnd, '$nextLine\n$currentLines');

    final offsetDelta = nextLine.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset + offsetDelta,
      extentOffset: selection.extentOffset + offsetDelta,
    );
    setSelectionSilently(newSelection);
  }

  /// Duplicates the current line or selected text.
  ///
  /// If text is selected, duplicates the selected text.
  /// If no selection, duplicates the line at the cursor position.
  /// The cursor is moved to the end of the duplicated content.
  /// Does nothing if the controller is read-only.
  void duplicateLine() {
    if (readOnly) return;
    _flushBuffer();
    final selection = this.selection;

    if (selection.start != selection.end) {
      final selectedText = _rope.substring(selection.start, selection.end);
      replaceRange(selection.end, selection.end, selectedText);
      setSelectionSilently(
        TextSelection.collapsed(offset: selection.end + selectedText.length),
      );
    } else {
      final caret = selection.extentOffset;
      final lineStart = _rope.findLineStart(caret);
      final lineEnd = _rope.findLineEnd(caret);
      final lineText = _rope.substring(lineStart, lineEnd);

      replaceRange(lineEnd, lineEnd, '\n$lineText');
      setSelectionSilently(TextSelection.collapsed(offset: lineEnd + 1));
    }
  }

  /// Toggles line comment on selected lines or current line (VS Code style Ctrl + /).
  ///
  /// Automatically adapts between `# ` (YAML) and `// ` (JS) based on language id or file extension.
  String? _languageId;
  set languageId(String? value) => _languageId = value;

  bool get _isJsLikeFile {
    final id = (_languageId ?? lspConfig?.languageId)?.toLowerCase().trim();
    if (id != null) {
      return id == 'javascript' ||
          id == 'js' ||
          id == 'typescript' ||
          id == 'ts' ||
          id == 'tsx' ||
          id == 'jsx';
    }
    final f = openedFile?.toLowerCase() ?? '';
    return f.endsWith('.js') ||
        f.endsWith('.mjs') ||
        f.endsWith('.cjs') ||
        f.endsWith('.ts') ||
        f.endsWith('.tsx') ||
        f.endsWith('.jsx');
  }

  void toggleComment({String? commentPrefix}) {
    if (readOnly) return;
    _flushBuffer();

    final compound = _undoController?.beginCompoundOperation();

    final targetLines = <int>{};

    final selStart = selection.start.clamp(0, _rope.length);
    final selEnd = selection.end.clamp(0, _rope.length);
    int pStartLine = getLineAtOffset(selStart);
    int pEndLine = getLineAtOffset(selEnd);
    if (selEnd > selStart &&
        pEndLine > pStartLine &&
        selEnd == getLineStartOffset(pEndLine)) {
      pEndLine--;
    }
    for (int l = pStartLine; l <= pEndLine; l++) {
      targetLines.add(l);
    }

    for (final cursor in _multiCursors) {
      final l = cursor.line.clamp(0, lineCount - 1);
      targetLines.add(l);
    }

    final sortedLines = targetLines.toList()..sort();
    if (sortedLines.isEmpty) {
      compound?.end();
      return;
    }

    final isJs = _isJsLikeFile;
    bool allCommented = true;
    int nonEmptyCount = 0;

    for (final lineIdx in sortedLines) {
      final lineText = getLineText(lineIdx);
      final trimmed = lineText.trimLeft();
      if (trimmed.isEmpty) continue;
      nonEmptyCount++;

      if (!trimmed.startsWith('#') && !trimmed.startsWith('//')) {
        allCommented = false;
      }
    }

    if (nonEmptyCount == 0) {
      allCommented = false;
    }

    final String effectivePrefix = commentPrefix ?? (isJs ? '// ' : '# ');

    int primaryStartShift = 0;
    int primaryEndShift = 0;

    final isReversedSelection = selection.extentOffset < selection.baseOffset;
    final primarySelMin = selStart;
    final primarySelMax = selEnd;

    for (final lineIdx in sortedLines.reversed) {
      final lineStart = getLineStartOffset(lineIdx);
      final lineText = getLineText(lineIdx);

      final leadingLen = lineText.length - lineText.trimLeft().length;

      if (allCommented) {
        final afterSpace = lineText.substring(leadingLen);
        String? prefixToRemove;
        if (afterSpace.startsWith('// ')) {
          prefixToRemove = '// ';
        } else if (afterSpace.startsWith('//')) {
          prefixToRemove = '//';
        } else if (afterSpace.startsWith('# ')) {
          prefixToRemove = '# ';
        } else if (afterSpace.startsWith('#')) {
          prefixToRemove = '#';
        }

        if (prefixToRemove != null) {
          final removeStart = lineStart + leadingLen;
          final removeEnd = removeStart + prefixToRemove.length;
          final pLen = prefixToRemove.length;
          replaceRange(removeStart, removeEnd, '', preserveOldCursor: true);

          if (lineIdx == pStartLine && primarySelMin > removeStart) {
            primaryStartShift -= pLen.clamp(0, primarySelMin - removeStart);
          } else if (lineIdx < pStartLine) {
            primaryStartShift -= pLen;
          }

          if (lineIdx == pEndLine && primarySelMax > removeStart) {
            primaryEndShift -= pLen.clamp(0, primarySelMax - removeStart);
          } else if (lineIdx < pEndLine) {
            primaryEndShift -= pLen;
          }
        }
      } else {
        final insertPos = lineStart + leadingLen;
        final pLen = effectivePrefix.length;
        replaceRange(
          insertPos,
          insertPos,
          effectivePrefix,
          preserveOldCursor: true,
        );

        if (lineIdx == pStartLine && primarySelMin >= insertPos) {
          primaryStartShift += pLen;
        } else if (lineIdx < pStartLine) {
          primaryStartShift += pLen;
        }

        if (lineIdx == pEndLine && primarySelMax >= insertPos) {
          primaryEndShift += pLen;
        } else if (lineIdx < pEndLine) {
          primaryEndShift += pLen;
        }
      }
    }

    final newStart = (primarySelMin + primaryStartShift).clamp(0, _rope.length);
    final newEnd = (primarySelMax + primaryEndShift).clamp(0, _rope.length);

    if (isReversedSelection) {
      _selection = TextSelection(baseOffset: newEnd, extentOffset: newStart);
    } else {
      _selection = TextSelection(baseOffset: newStart, extentOffset: newEnd);
    }

    compound?.end();
    notifyListeners();
  }

  /// Toggles block comment (`/* ... */` or `/** ... */`) on current selection or active line.
  void toggleBlockComment({String blockStart = '/*', String blockEnd = '*/'}) {
    if (readOnly) return;
    _flushBuffer();

    final compound = _undoController?.beginCompoundOperation();

    final selStart = selection.start.clamp(0, _rope.length);
    final selEnd = selection.end.clamp(0, _rope.length);

    if (selStart != selEnd) {
      final selectedText = _rope.substring(selStart, selEnd);
      final trimmed = selectedText.trim();

      if ((trimmed.startsWith('/*') || trimmed.startsWith('/**')) &&
          trimmed.endsWith('*/')) {
        final firstCommentIndex = selectedText.indexOf('/*');
        final lastCommentIndex = selectedText.lastIndexOf('*/');

        if (firstCommentIndex != -1 &&
            lastCommentIndex != -1 &&
            lastCommentIndex > firstCommentIndex) {
          final isDocComment = selectedText.startsWith(
            '/**',
            firstCommentIndex,
          );
          final startLen = isDocComment ? 3 : 2;

          final startHasSpace =
              firstCommentIndex + startLen < selectedText.length &&
              selectedText[firstCommentIndex + startLen] == ' ';
          final startDeleteLen = startLen + (startHasSpace ? 1 : 0);
          final endHasSpace =
              lastCommentIndex > 0 && selectedText[lastCommentIndex - 1] == ' ';
          final endDeleteStart = lastCommentIndex - (endHasSpace ? 1 : 0);
          final endDeleteLen = 2 + (endHasSpace ? 1 : 0);

          replaceRange(
            selStart + endDeleteStart,
            selStart + endDeleteStart + endDeleteLen,
            '',
            preserveOldCursor: true,
          );
          replaceRange(
            selStart + firstCommentIndex,
            selStart + firstCommentIndex + startDeleteLen,
            '',
            preserveOldCursor: true,
          );

          _selection = TextSelection(
            baseOffset: selStart,
            extentOffset: (selEnd - startDeleteLen - endDeleteLen).clamp(
              selStart,
              _rope.length,
            ),
          );
        }
      } else {
        final prefix = '$blockStart ';
        final suffix = ' $blockEnd';

        replaceRange(selEnd, selEnd, suffix, preserveOldCursor: true);
        replaceRange(selStart, selStart, prefix, preserveOldCursor: true);

        _selection = TextSelection(
          baseOffset: selStart,
          extentOffset: selEnd + prefix.length + suffix.length,
        );
      }
    } else {
      final caret = selStart;
      final lineIdx = getLineAtOffset(caret);
      final lineStart = getLineStartOffset(lineIdx);
      final lineText = getLineText(lineIdx);
      final trimmed = lineText.trim();

      if ((trimmed.startsWith('/*') || trimmed.startsWith('/**')) &&
          trimmed.endsWith('*/')) {
        final firstCommentIndex = lineText.indexOf('/*');
        final lastCommentIndex = lineText.lastIndexOf('*/');
        if (firstCommentIndex != -1 &&
            lastCommentIndex != -1 &&
            lastCommentIndex > firstCommentIndex) {
          final isDocComment = lineText.startsWith('/**', firstCommentIndex);
          final startLen = isDocComment ? 3 : 2;

          final startHasSpace =
              firstCommentIndex + startLen < lineText.length &&
              lineText[firstCommentIndex + startLen] == ' ';
          final startDeleteLen = startLen + (startHasSpace ? 1 : 0);
          final endHasSpace =
              lastCommentIndex > 0 && lineText[lastCommentIndex - 1] == ' ';
          final endDeleteStart = lastCommentIndex - (endHasSpace ? 1 : 0);
          final endDeleteLen = 2 + (endHasSpace ? 1 : 0);

          replaceRange(
            lineStart + endDeleteStart,
            lineStart + endDeleteStart + endDeleteLen,
            '',
            preserveOldCursor: true,
          );
          replaceRange(
            lineStart + firstCommentIndex,
            lineStart + firstCommentIndex + startDeleteLen,
            '',
            preserveOldCursor: true,
          );

          _selection = TextSelection.collapsed(
            offset: (caret - startDeleteLen).clamp(lineStart, _rope.length),
          );
        }
      } else {
        final prefix = '$blockStart ';
        final suffix = ' $blockEnd';
        replaceRange(caret, caret, '$prefix$suffix', preserveOldCursor: true);
        _selection = TextSelection.collapsed(offset: caret + prefix.length);
      }
    }

    compound?.end();
    notifyListeners();
  }

  void _maybeAcquireFocusForInput() {
    final node = focusNode;
    if (node != null && !node.hasFocus && !isComposingActive) {
      node.requestFocus();
    }
  }

  @protected
  @override
  void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
    if (readOnly) return;

    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    final involvesComposition =
        _imeComposition != null ||
        textEditingDeltas.any(
          (d) => d.composing.isValid && !d.composing.isCollapsed,
        );
    if (involvesComposition) {
      _processCompositionDeltas(textEditingDeltas);
      return;
    }

    final wasComposingAtStart = isComposingActive;

    _ensureImeProjection();
    final projectionBaseStart = _imeProjectionStartOffset;
    var platformBaseText = _imeProjectionText;

    int localToGlobal(int localUtf16Offset) {
      final scalarLocal = utf16ToScalarOffset(
        platformBaseText,
        localUtf16Offset,
      );
      return (projectionBaseStart + scalarLocal).clamp(0, length);
    }

    TextSelection localSelToGlobal(TextSelection sel) => TextSelection(
      baseOffset: localToGlobal(sel.baseOffset),
      extentOffset: localToGlobal(sel.extentOffset),
    );

    bool typingDetected = false;

    _suppressImeSync = true;
    _beginImeCompositionUndoGroup(
      textEditingDeltas.any(
        (d) => d.composing.isValid && !d.composing.isCollapsed,
      ),
    );
    for (final delta in textEditingDeltas) {
      if (delta is TextEditingDeltaNonTextUpdate) {
        final isEcho =
            _lastSentSelection != null && delta.selection == _lastSentSelection;
        if (!isEcho) {
          _selection = _localImeSelectionToGlobal(delta.selection);
          _lastSentSelection = null;
        }
        _imeSelectionNeedsResync = false;
        _trackImeComposing(
          delta.composing,
          delta.selection.isValid
              ? delta.selection.extentOffset
              : delta.composing.end,
        );
        continue;
      }

      _lastSentSelection = null;

      if (delta is TextEditingDeltaInsertion) {
        final mappedInsertionOffset = localToGlobal(delta.insertionOffset);
        final staleMappedOffset =
            mappedInsertionOffset < _selection.extentOffset;
        bool useCurrentSelection =
            _imeSelectionNeedsResync ||
            delta.insertionOffset != _imeProjectionSelection.extentOffset ||
            staleMappedOffset;
        if (isBufferActive) useCurrentSelection = true;
        _imeSelectionNeedsResync = false;

        if (delta.textInserted.length == 1) {
          _lastTypedCharacter = delta.textInserted;
        }
        if (delta.textInserted.isNotEmpty &&
            (_isAlpha(delta.textInserted) ||
                _isCompletionTriggerChar(delta.textInserted))) {
          typingDetected = true;
        }
        final insertionOffset = useCurrentSelection
            ? _selection.extentOffset
            : mappedInsertionOffset;
        final insertionSelection = TextSelection.collapsed(
          offset: insertionOffset + delta.textInserted.runes.length,
        );

        _handleInsertion(
          insertionOffset,
          delta.textInserted,
          insertionSelection,
        );
      } else if (delta is TextEditingDeltaDeletion) {
        _handleDeletion(
          TextRange(
            start: localToGlobal(delta.deletedRange.start),
            end: localToGlobal(delta.deletedRange.end),
          ),
          localSelToGlobal(delta.selection),
        );
      } else if (delta is TextEditingDeltaReplacement) {
        if (delta.replacementText.isNotEmpty &&
            _isAlpha(delta.replacementText)) {
          typingDetected = true;
        }
        _handleReplacement(
          TextRange(
            start: localToGlobal(delta.replacedRange.start),
            end: localToGlobal(delta.replacedRange.end),
          ),
          delta.replacementText,
          localSelToGlobal(delta.selection),
        );
      }

      platformBaseText = delta.apply(
        TextEditingValue(text: platformBaseText),
      ).text;

      _trackImeComposing(
        delta.composing,
        delta.selection.isValid
            ? delta.selection.extentOffset
            : delta.composing.end,
      );
    }
    _endImeCompositionUndoGroupIfIdle();
    _suppressImeSync = false;

    _isTyping = typingDetected;

    _imeProjectionDirty = true;

    _maybeAcquireFocusForInput();

    _ensureImeProjection();
    if (_platformValueDivergesFromProjection(textEditingDeltas)) {
      _syncToConnection();
    }

    if (wasComposingAtStart && !isComposingActive) {
      _flushBuffer();
      dirtyLine = _rope.getLineAtOffset(_selection.extentOffset);
    }

    notifyListeners();
  }

  bool get isBufferActive => _bufferLineIndex != null && _bufferDirty;

  /// Whether an IME composition (e.g. CJK pinyin/kana) is currently in
  /// progress. While true, the platform input method owns the keyboard, so
  /// hardware-key handlers must defer to it and external selection changes
  /// must finalize the composition first.
  bool get isComposingActive => _imeComposition != null;
  int? get bufferLineIndex => _bufferLineIndex;
  int get bufferLineRopeStart => _bufferLineRopeStart;
  String? get bufferLineText => _bufferLineText;
  int get contentVersion => _currentVersion;

  int get bufferCursorColumn {
    if (!isBufferActive) return 0;
    return _selection.extentOffset - _bufferLineRopeStart;
  }

  /// Insert text at the current cursor position (or replace selection).
  void insertAtCurrentCursor(
    String textToInsert, {
    bool replaceTypedChar = false,
  }) {
    if (readOnly) return;

    _flushBuffer();

    final cursorPosition = selection.extentOffset;
    final safePosition = cursorPosition.clamp(0, _rope.length);
    final currentLine = _rope.getLineAtOffset(safePosition);
    final isFolded = foldings.values.any(
      (fold) =>
          fold != null &&
          fold.isFolded &&
          currentLine > fold.startIndex &&
          currentLine <= fold.endIndex,
    );

    if (isFolded) {
      final newPosition = text.length;
      selection = TextSelection.collapsed(offset: newPosition);
      return;
    }

    if (replaceTypedChar) {
      final ropeText = _rope.getText();
      final prefix = getCurrentWordPrefix(ropeText, safePosition);
      final prefixStart = (safePosition - prefix.length).clamp(0, _rope.length);

      replaceRange(prefixStart, safePosition, textToInsert);
    } else {
      replaceRange(safePosition, safePosition, textToInsert);
    }
  }

  /// Inserts text at the specified line and character position.
  ///
  /// [line] is zero-based (0 for the first line).
  /// [character] is zero-based column position within the line.
  /// The character position will be clamped to the line's length.
  void insertText(String text, int line, int character) {
    if (readOnly) return;
    _flushBuffer();

    final clampedLine = line.clamp(0, lineCount - 1);
    final lineText = getLineText(clampedLine);
    final clampedChar = character.clamp(0, lineText.runes.length);
    final offset = getLineStartOffset(clampedLine) + clampedChar;

    replaceRange(offset, offset, text);
  }

  void _syncToConnection() {
    if (_suppressImeSync) return;
    if (_imeComposition != null) return;
    if (connection != null && connection!.attached) {
      _ensureImeProjection();

      final projText = _imeProjectionText;
      final scalarSel = _imeProjectionSelection;
      final utf16Base = scalarToUtf16Offset(projText, scalarSel.baseOffset);
      final utf16Extent = scalarToUtf16Offset(projText, scalarSel.extentOffset);
      // Store in UTF-16 units so the platform echo (also UTF-16) matches correctly.
      // Android fires multiple NonTextUpdate deltas per arrow key; we must absorb
      // all of them without overwriting _selection with a wrong platform value.
      _lastSentSelection = TextSelection(
        baseOffset: utf16Base,
        extentOffset: utf16Extent,
      );
      final utf16Composing =
          _imeProjectionComposing.isValid &&
              !_imeProjectionComposing.isCollapsed
          ? TextRange(
              start: scalarToUtf16Offset(
                projText,
                _imeProjectionComposing.start,
              ),
              end: scalarToUtf16Offset(projText, _imeProjectionComposing.end),
            )
          : _imeProjectionComposing;

      connection!.setEditingState(
        TextEditingValue(
          text: projText,
          selection: TextSelection(
            baseOffset: utf16Base,
            extentOffset: utf16Extent,
          ),
          composing: utf16Composing,
        ),
      );
    }
  }

  void _invalidateImeSnapshotAndScheduleSync() {
    _imeProjectionDirty = true;
    _syncToConnection();
  }

  bool _platformValueDivergesFromProjection(List<TextEditingDelta> deltas) {
    if (connection == null || !connection!.attached) return false;
    String? platformText;
    for (final delta in deltas) {
      if (delta is TextEditingDeltaNonTextUpdate) continue;
      platformText = delta.oldText;
      break;
    }
    if (platformText == null) return false;
    var value = TextEditingValue(text: platformText);
    for (final delta in deltas) {
      value = delta.apply(value);
    }
    return value.text != _imeProjectionText;
  }

  Map<String, dynamic> _lspPositionForOffset(int offset) {
    final safeOffset = offset.clamp(0, length);
    final line = getLineAtOffset(safeOffset);
    final lineStart = getLineStartOffset(line);
    final lineText = getLineText(line);
    final colScalar = (safeOffset - lineStart).clamp(0, lineText.runes.length);
    return {
      'line': line,
      'character': scalarToStringIndex(lineText, colScalar),
    };
  }

  Map<String, dynamic> _lspRangeForOffsets(int start, int end) {
    return {
      'start': _lspPositionForOffset(start),
      'end': _lspPositionForOffset(end),
    };
  }

  void _scheduleLspIncrementalSync(int start, int end, String replacement) {
    if (lspConfig == null || openedFile == null || !_lspReady) return;

    _pendingLspContentChanges.add({
      'range': _lspRangeForOffsets(start, end),
      'text': replacement,
    });
    _pendingLspFullText = null;
    _lspDocumentSyncTimer?.cancel();
    _lspDocumentSyncTimer = Timer(_lspDocumentSyncDebounce, () {
      unawaited(_flushLspDocumentSync());
    });
  }

  void _scheduleLspFullSync(String Function() contentBuilder) {
    if (lspConfig == null || openedFile == null || !_lspReady) return;

    _pendingLspContentChanges.clear();
    _pendingLspFullText = contentBuilder;
    _lspDocumentSyncTimer?.cancel();
    _lspDocumentSyncTimer = Timer(_lspDocumentSyncDebounce, () {
      unawaited(_flushLspDocumentSync());
    });
  }

  Future<void> _flushLspDocumentSync() async {
    final config = lspConfig;
    final file = openedFile;
    if (config == null || file == null || !_lspReady) {
      _pendingLspContentChanges.clear();
      _pendingLspFullText = null;
      return;
    }

    final fullText = _pendingLspFullText?.call();
    final changes = List<Map<String, dynamic>>.from(_pendingLspContentChanges);
    _pendingLspContentChanges.clear();
    _pendingLspFullText = null;

    if (fullText != null) {
      await config.updateDocument(file, fullText);
      return;
    }

    if (!config.supportsSemanticTokensPull) {
      await config.updateDocument(file, text);
      return;
    }

    if (changes.isEmpty) return;

    await config.updateDocument(file, text, contentChanges: changes);
  }

  void _ensureImeProjection() {
    if (!_imeProjectionDirty) return;

    final selection = _selection;
    final documentLength = _rope.length;
    if (documentLength == 0) {
      _imeProjectionStartOffset = 0;
      _imeProjectionText = '';
      _imeProjectionSelection = const TextSelection.collapsed(offset: 0);
      _imeProjectionComposing = TextRange.empty;
      _imeProjectionDirty = false;
      return;
    }

    final selectionStart = selection.start.clamp(0, documentLength);
    final selectionEnd = selection.end.clamp(selectionStart, documentLength);
    final caretOffset = selection.extentOffset.clamp(0, documentLength);
    final firstSelLine = getLineAtOffset(selectionStart);
    final lastSelLine = getLineAtOffset(selectionEnd);
    final caretLine = getLineAtOffset(caretOffset);
    final anchorLow = firstSelLine < caretLine ? firstSelLine : caretLine;
    final anchorHigh = lastSelLine > caretLine ? lastSelLine : caretLine;
    final lineStart = (anchorLow - _imeProjectionLineRadius).clamp(
      0,
      lineCount - 1,
    );
    final lineEnd = (anchorHigh + _imeProjectionLineRadius).clamp(
      0,
      lineCount - 1,
    );

    final parts = <String>[];
    for (int line = lineStart; line <= lineEnd; line++) {
      parts.add(getLineText(line));
    }

    var projectionText = parts.join('\n');
    var projectionStartOffset = getLineStartOffset(lineStart);

    if (projectionText.length > _imeProjectionMaxChars) {
      final halfWindow = _imeProjectionMaxChars ~/ 2;
      final desiredStart = caretOffset - halfWindow;
      projectionStartOffset = desiredStart < 0 ? 0 : desiredStart;
      if (selectionStart < projectionStartOffset) {
        projectionStartOffset = selectionStart;
      }
      final selectionTail = selectionEnd + halfWindow;
      final projectionEndOffset =
          (projectionStartOffset + _imeProjectionMaxChars).clamp(
            0,
            documentLength,
          );
      if (selectionTail > projectionEndOffset) {
        projectionStartOffset = (selectionTail - _imeProjectionMaxChars).clamp(
          0,
          documentLength,
        );
      }
      final projectionEnd = (projectionStartOffset + _imeProjectionMaxChars)
          .clamp(0, documentLength);
      projectionText = _rope.substring(projectionStartOffset, projectionEnd);
    }

    final localBase = (selection.baseOffset - projectionStartOffset).clamp(
      0,
      projectionText.length,
    );
    final localExtent = (selection.extentOffset - projectionStartOffset).clamp(
      0,
      projectionText.length,
    );

    _imeProjectionStartOffset = projectionStartOffset;
    _imeProjectionText = projectionText;
    _imeProjectionSelection = TextSelection(
      baseOffset: localBase,
      extentOffset: localExtent,
    );
    _imeProjectionComposing = _projectComposing(
      projectionStartOffset,
      projectionText.length,
    );
    _imeProjectionDirty = false;
  }

  int _localImeOffsetToGlobal(int localUtf16Offset) {
    _ensureImeProjection();
    final scalarLocal = utf16ToScalarOffset(
      _imeProjectionText,
      localUtf16Offset,
    );
    return (_imeProjectionStartOffset + scalarLocal).clamp(0, length);
  }

  TextSelection _localImeSelectionToGlobal(TextSelection localSelection) {
    return TextSelection(
      baseOffset: _localImeOffsetToGlobal(localSelection.baseOffset),
      extentOffset: _localImeOffsetToGlobal(localSelection.extentOffset),
    );
  }

  TextRange _projectComposing(int projectionStartOffset, int projectionLength) {
    final composing = _imeComposingGlobal;
    if (!composing.isValid || composing.isCollapsed) return TextRange.empty;
    final localStart = composing.start - projectionStartOffset;
    final localEnd = composing.end - projectionStartOffset;
    if (localEnd <= 0 || localStart >= projectionLength) return TextRange.empty;
    final clampedStart = localStart.clamp(0, projectionLength);
    final clampedEnd = localEnd.clamp(0, projectionLength);
    if (clampedStart >= clampedEnd) return TextRange.empty;
    return TextRange(start: clampedStart, end: clampedEnd);
  }

  void _trackImeComposing(TextRange imeComposing, int imeCaretLocal) {
    if (!imeComposing.isValid || imeComposing.isCollapsed) {
      _imeComposingGlobal = TextRange.empty;
      return;
    }
    final caretGlobal = _selection.extentOffset;
    final caretWithin = imeCaretLocal - imeComposing.start;
    final startGlobal = caretGlobal - caretWithin;
    final composingLength = imeComposing.end - imeComposing.start;
    final docLength = length;
    final start = startGlobal.clamp(0, docLength);
    final end = (startGlobal + composingLength).clamp(0, docLength);
    _imeComposingGlobal = start < end
        ? TextRange(start: start, end: end)
        : TextRange.empty;
  }

  void _beginImeCompositionUndoGroup(bool incomingHasComposing) {
    if (incomingHasComposing && _imeCompositionUndoGroup == null) {
      _imeCompositionUndoGroup = _undoController?.beginCompoundOperation();
    }
  }

  void _endImeCompositionUndoGroupIfIdle() {
    if (_imeCompositionUndoGroup != null && _imeComposition == null) {
      _imeCompositionUndoGroup!.end();
      _imeCompositionUndoGroup = null;
    }
  }

  /// The active IME composition overlay, or null when no composition is in
  /// progress. Read by the renderer to paint the composing string.
  ImeComposition? get imeComposition => _imeComposition;

  void _processCompositionDeltas(List<TextEditingDelta> deltas) {
    _suppressImeSync = true;
    final startingComposition = _imeComposition == null;
    final selectionToReplace = startingComposition
        ? _selectionToReplaceForComposition()
        : null;
    _seedImeMirrorIfIdle();
    final replacement = _captureSelectionReplacement(selectionToReplace);
    _beginImeCompositionUndoGroup(
      deltas.any((d) => d.composing.isValid && !d.composing.isCollapsed),
    );

    var value = TextEditingValue(
      text: _imeMirrorText,
      selection: _imeMirrorSelection,
      composing: _imeMirrorComposing,
    );
    for (final delta in deltas) {
      value = delta.apply(value);
      _reconcileCommittedToDocument(value);
    }

    _applyLingeringSelectionDeletion(replacement);
    _finishImeMirrorUpdate(value);
    _endImeCompositionUndoGroupIfIdle();
    final composingEnded = _imeComposition == null;
    _suppressImeSync = false;
    if (composingEnded) _syncToConnection();
    notifyListeners();
  }

  void _processCompositionValue(TextEditingValue value) {
    _suppressImeSync = true;
    final startingComposition = _imeComposition == null;
    final selectionToReplace = startingComposition
        ? _selectionToReplaceForComposition()
        : null;
    _seedImeMirrorIfIdle();
    final replacement = _captureSelectionReplacement(selectionToReplace);
    _beginImeCompositionUndoGroup(
      value.composing.isValid && !value.composing.isCollapsed,
    );
    _reconcileCommittedToDocument(value);
    _applyLingeringSelectionDeletion(replacement);
    _finishImeMirrorUpdate(value);
    _endImeCompositionUndoGroupIfIdle();
    final composingEnded = _imeComposition == null;
    _suppressImeSync = false;
    if (composingEnded) _syncToConnection();
    notifyListeners();
  }

  void _seedImeMirrorIfIdle() {
    if (_imeComposition != null) return;
    _flushBuffer();
    _ensureImeProjection();
    _imeMirrorText = _imeProjectionText;
    _imeMirrorSelection = TextSelection(
      baseOffset: scalarToUtf16Offset(
        _imeProjectionText,
        _imeProjectionSelection.baseOffset,
      ),
      extentOffset: scalarToUtf16Offset(
        _imeProjectionText,
        _imeProjectionSelection.extentOffset,
      ),
    );
    _imeMirrorComposing = TextRange.empty;
    _imeWindowStart = _imeProjectionStartOffset;
    _imeWindowCommitted = _imeProjectionText;
    _imeMirrorDeleteStart = -1;
    _imeMirrorDeleteLen = 0;
    _imeMirrorDeletedText = '';
    _rawTypedComposingText = '';
    _lastComposingText = '';
  }

  void _finishImeMirrorUpdate(TextEditingValue value) {
    _imeMirrorText = value.text;
    _imeMirrorSelection = value.selection;
    _imeMirrorComposing = value.composing;

    final composingActive =
        value.composing.isValid && !value.composing.isCollapsed;

    if (composingActive) {
      final newComposingText = value.text.substring(
        value.composing.start,
        value.composing.end,
      );

      final strippedOld = _lastComposingText
          .replaceAll("'", "")
          .replaceAll('\u2019', "");
      final strippedNew = newComposingText
          .replaceAll("'", "")
          .replaceAll('\u2019', "");

      if (strippedNew.length > strippedOld.length) {
        _rawTypedComposingText += strippedNew.substring(strippedOld.length);
      } else if (strippedNew.length < strippedOld.length) {
        final diff = strippedOld.length - strippedNew.length;
        if (_rawTypedComposingText.length >= diff) {
          _rawTypedComposingText = _rawTypedComposingText.substring(
            0,
            _rawTypedComposingText.length - diff,
          );
        } else {
          _rawTypedComposingText = "";
        }
      } else if (newComposingText.length > _lastComposingText.length) {
        _rawTypedComposingText += "'";
      } else if (newComposingText.length < _lastComposingText.length) {
        if (_rawTypedComposingText.endsWith("'") ||
            _rawTypedComposingText.endsWith('\u2019')) {
          _rawTypedComposingText = _rawTypedComposingText.substring(
            0,
            _rawTypedComposingText.length - 1,
          );
        }
      }

      _lastComposingText = newComposingText;
      _updateCompositionOverlayFromMirror();
    } else {
      _imeComposition = null;
      _pendingSelectionReplacement = null;
      _imeMirrorDeleteStart = -1;
      _imeMirrorDeleteLen = 0;
      _imeMirrorDeletedText = '';
      _rawTypedComposingText = '';
      _lastComposingText = '';
      _endImeCompositionUndoGroupIfIdle();
      _imeProjectionDirty = true;
    }

    _selection = _documentSelectionFromMirror(value.selection);
    imeCompositionChanged = true;
    _maybeAcquireFocusForInput();
  }

  void _reconcileCommittedToDocument(TextEditingValue value) {
    final composing = value.composing;
    String committedNew;
    if (composing.isValid && !composing.isCollapsed) {
      committedNew =
          value.text.substring(0, composing.start) +
          value.text.substring(composing.end);
    } else {
      committedNew = value.text;
    }

    if (_imeMirrorDeleteLen > 0 && _imeMirrorDeleteStart >= 0) {
      final end = _imeMirrorDeleteStart + _imeMirrorDeleteLen;
      if (end <= committedNew.length &&
          committedNew.substring(_imeMirrorDeleteStart, end) ==
              _imeMirrorDeletedText) {
        committedNew =
            committedNew.substring(0, _imeMirrorDeleteStart) +
            committedNew.substring(end);
      } else {
        _imeMirrorDeleteStart = -1;
        _imeMirrorDeleteLen = 0;
        _imeMirrorDeletedText = '';
      }
    }

    final committedOld = _imeWindowCommitted;
    if (committedNew == committedOld) return;

    final oldLen = committedOld.length;
    final newLen = committedNew.length;
    final maxPrefix = oldLen < newLen ? oldLen : newLen;
    int prefix = 0;
    while (prefix < maxPrefix &&
        committedOld.codeUnitAt(prefix) == committedNew.codeUnitAt(prefix)) {
      prefix++;
    }
    final oldTail = oldLen - prefix;
    final newTail = newLen - prefix;
    final maxSuffix = oldTail < newTail ? oldTail : newTail;
    int suffix = 0;
    while (suffix < maxSuffix &&
        committedOld.codeUnitAt(oldLen - 1 - suffix) ==
            committedNew.codeUnitAt(newLen - 1 - suffix)) {
      suffix++;
    }

    final globalStart =
        _imeWindowStart + utf16ToScalarOffset(committedOld, prefix);
    final globalEnd =
        _imeWindowStart + utf16ToScalarOffset(committedOld, oldLen - suffix);
    final replacement = committedNew.substring(prefix, newLen - suffix);

    replaceRange(globalStart, globalEnd, replacement);
    _imeWindowCommitted = committedNew;
  }

  void _updateCompositionOverlayFromMirror() {
    final comp = _imeMirrorComposing;
    final raw = _imeMirrorText.substring(comp.start, comp.end);
    var compStartLocal = comp.start;
    if (_imeMirrorDeleteLen > 0 &&
        compStartLocal >= _imeMirrorDeleteStart + _imeMirrorDeleteLen) {
      compStartLocal -= _imeMirrorDeleteLen;
    }
    final anchorGlobal = (_imeWindowStart +
            utf16ToScalarOffset(_imeMirrorText, compStartLocal))
        .clamp(0, length);
    final caretLocalRaw = (_imeMirrorSelection.extentOffset - comp.start).clamp(
      0,
      raw.length,
    );
    _imeComposition = ImeComposition(
      anchor: anchorGlobal,
      displayText: raw,
      displayCaret: caretLocalRaw,
      commitText: _rawTypedComposingText.isNotEmpty
          ? _rawTypedComposingText
          : raw,
    );
  }

  TextSelection _documentSelectionFromMirror(TextSelection localSelection) {
    final comp = _imeComposition;
    if (comp != null) {
      return TextSelection.collapsed(offset: comp.anchor);
    }
    final base = (_imeWindowStart +
            utf16ToScalarOffset(_imeMirrorText, localSelection.baseOffset))
        .clamp(0, length);
    final extent = (_imeWindowStart +
            utf16ToScalarOffset(_imeMirrorText, localSelection.extentOffset))
        .clamp(0, length);
    return TextSelection(baseOffset: base, extentOffset: extent);
  }

  void _commitCompositionInPlace() {
    final comp = _imeComposition;
    if (comp == null) return;
    _imeComposition = null;
    if (comp.commitText.isNotEmpty) {
      final wasSuppressed = _suppressImeSync;
      _suppressImeSync = true;
      replaceRange(comp.anchor, comp.anchor, comp.commitText);
      _suppressImeSync = wasSuppressed;
    }
    _endImeCompositionUndoGroupIfIdle();
    _imeMirrorText = '';
    _imeMirrorSelection = const TextSelection.collapsed(offset: 0);
    _imeMirrorComposing = TextRange.empty;
    _imeWindowCommitted = '';
    _pendingSelectionReplacement = null;
    _imeMirrorDeleteStart = -1;
    _imeMirrorDeleteLen = 0;
    _imeMirrorDeletedText = '';
    imeCompositionChanged = true;
  }

  TextSelection _commitCompositionAndRemapSelection(TextSelection requested) {
    final comp = _imeComposition;
    final anchor = comp?.anchor ?? -1;
    final insertedLength = comp?.commitText.length ?? 0;
    _commitCompositionInPlace();
    if (insertedLength <= 0 || anchor < 0) return requested;
    final base = requested.baseOffset > anchor
        ? requested.baseOffset + insertedLength
        : requested.baseOffset;
    final extent = requested.extentOffset > anchor
        ? requested.extentOffset + insertedLength
        : requested.extentOffset;
    if (base == requested.baseOffset && extent == requested.extentOffset) {
      return requested;
    }
    return requested.copyWith(baseOffset: base, extentOffset: extent);
  }

  TextSelection? _selectionToReplaceForComposition() {
    if (!_selection.isCollapsed) return _selection;
    final pending = _pendingSelectionReplacement;
    if (pending != null && !pending.isCollapsed) {
      final caret = _selection.extentOffset;
      if (caret >= pending.start && caret <= pending.end) return pending;
    }
    return null;
  }

  ({int localStart, String text}) _captureSelectionReplacement(
    TextSelection? sel,
  ) {
    if (sel == null || sel.isCollapsed) return (localStart: 0, text: '');
    final scalarStart = sel.start - _imeWindowStart;
    final scalarEnd = sel.end - _imeWindowStart;
    if (scalarStart < 0 ||
        scalarEnd > _imeWindowCommitted.runes.length ||
        scalarEnd <= scalarStart) {
      return (localStart: 0, text: '');
    }
    final localStart = scalarToUtf16Offset(_imeWindowCommitted, scalarStart);
    final localEnd = scalarToUtf16Offset(_imeWindowCommitted, scalarEnd);
    return (
      localStart: localStart,
      text: _imeWindowCommitted.substring(localStart, localEnd),
    );
  }

  void _applyLingeringSelectionDeletion(
    ({int localStart, String text}) capture,
  ) {
    if (capture.text.isEmpty) return;
    final localStart = capture.localStart;
    final localEnd = localStart + capture.text.length;
    if (localEnd > _imeWindowCommitted.length) return;
    if (_imeWindowCommitted.substring(localStart, localEnd) != capture.text) {
      return;
    }
    final globalStart =
        _imeWindowStart + utf16ToScalarOffset(_imeWindowCommitted, localStart);
    replaceRange(globalStart, globalStart + capture.text.runes.length, '');
    _imeWindowCommitted =
        _imeWindowCommitted.substring(0, localStart) +
        _imeWindowCommitted.substring(localEnd);
    _imeMirrorDeleteStart = localStart;
    _imeMirrorDeleteLen = capture.text.length;
    _imeMirrorDeletedText = capture.text;
  }

  /// Remove the selection or last char if the selection is empty (backspace key)
  void backspace() {
    if (readOnly) return;
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    final selectionBefore = _selection;
    final sel = _selection;
    String deletedText;

    if (sel.start < sel.end) {
      _flushBuffer();

      if (deleteFoldRangeOnDeletingFirstLine) {
        final startLine = _rope.getLineAtOffset(sel.start);
        final endLine = _rope.getLineAtOffset(sel.end);

        if (startLine == endLine ||
            (startLine + 1 == endLine &&
                sel.end == _rope.getLineStartOffset(endLine))) {
          final lineStart = _rope.getLineStartOffset(startLine);
          final lineText = _rope.getLineText(startLine);
          final lineEnd = lineStart + lineText.length;
          final selectsWholeLine = sel.start <= lineStart && sel.end >= lineEnd;

          if (selectsWholeLine) {
            FoldRange? foldToDelete;

            if (_isFirstLineOfFoldedRange(startLine)) {
              foldToDelete = foldings[startLine];
            } else {
              for (final fold in foldings.values) {
                if (fold != null && fold.isFolded) {
                  if (startLine > fold.startIndex &&
                      startLine <= fold.endIndex) {
                    for (final child in fold.originallyFoldedChildren) {
                      if (child.startIndex == startLine) {
                        foldToDelete = child;
                        break;
                      }
                    }
                    if (foldToDelete != null) break;
                  }
                }
              }
            }

            if (foldToDelete != null) {
              final foldStart = _rope.getLineStartOffset(
                foldToDelete.startIndex,
              );
              final foldEndLine = foldToDelete.endIndex;
              final foldEndLineText = _rope.getLineText(foldEndLine);
              final foldEnd =
                  _rope.getLineStartOffset(foldEndLine) +
                  foldEndLineText.length;

              deletedText = _rope.substring(foldStart, foldEnd);
              _rope.delete(foldStart, foldEnd);
              _currentVersion++;
              _selection = TextSelection.collapsed(offset: foldStart);
              dirtyLine = _rope.getLineAtOffset(
                foldStart.clamp(0, _rope.length),
              );
              lineStructureChanged = true;
              foldings.remove(foldToDelete.startIndex);
              _rebuildFoldSortedCache();

              for (final fold in foldings.values) {
                if (fold != null) {
                  fold.originallyFoldedChildren.remove(foldToDelete);
                }
              }

              _recordDeletion(
                foldStart,
                deletedText,
                selectionBefore,
                _selection,
              );
              dirtyRegion = TextRange(start: foldStart, end: foldStart);
              _imeSelectionNeedsResync = true;
              _invalidateImeSnapshotAndScheduleSync();
              notifyListeners();
              return;
            }
          }
        }
      }

      deletedText = _rope.substring(sel.start, sel.end);
      _rope.delete(sel.start, sel.end);
      _currentVersion++;
      _selection = TextSelection.collapsed(offset: sel.start);
      dirtyLine = _rope.getLineAtOffset(sel.start);

      _recordDeletion(sel.start, deletedText, selectionBefore, _selection);
      dirtyRegion = TextRange(start: sel.start, end: sel.start);
      if (deletedText.contains('\n')) {
        lineStructureChanged = true;
      }
      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();
      notifyListeners();
      return;
    }

    if (sel.start <= 0) return;

    final deleteOffset = sel.start - 1;

    String charToDelete;
    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;
      if (deleteOffset >= _bufferLineRopeStart && deleteOffset < bufferEnd) {
        charToDelete = _bufferLineText![deleteOffset - _bufferLineRopeStart];
      } else {
        charToDelete = _rope.charAt(deleteOffset);
      }
    } else {
      charToDelete = _rope.charAt(deleteOffset);
    }

    if (charToDelete == '\n') {
      _flushBuffer();
      _rope.delete(deleteOffset, sel.start);
      _currentVersion++;
      _selection = TextSelection.collapsed(offset: deleteOffset);
      dirtyLine = _rope.getLineAtOffset(deleteOffset);
      lineStructureChanged = true;
      dirtyRegion = TextRange(start: deleteOffset, end: deleteOffset);

      _recordDeletion(deleteOffset, '\n', selectionBefore, _selection);
      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();
      notifyListeners();
      return;
    }

    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;

      if (deleteOffset >= _bufferLineRopeStart && deleteOffset < bufferEnd) {
        final localOffset = deleteOffset - _bufferLineRopeStart;
        final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
        final cu = _bufferLineText!.codeUnitAt(utf16Local);
        final charLen = (cu >= 0xD800 && cu <= 0xDBFF) ? 2 : 1;
        final charToDelete = _bufferLineText!.substring(
          utf16Local,
          utf16Local + charLen,
        );
        final utf16End = utf16Local + charLen;
        deletedText = charToDelete;
        _bufferLineText =
            _bufferLineText!.substring(0, utf16Local) +
            _bufferLineText!.substring(utf16End);
        _selection = TextSelection.collapsed(offset: deleteOffset);
        _currentVersion++;
        bufferNeedsRepaint = true;
        dirtyRegion = TextRange(start: deleteOffset, end: deleteOffset);
        _recordDeletion(deleteOffset, deletedText, selectionBefore, _selection);
        _imeSelectionNeedsResync = true;
        _invalidateImeSnapshotAndScheduleSync();
        _scheduleFlush();
        notifyListeners();
        return;
      }
    }

    final lineIndex = _rope.getLineAtOffset(deleteOffset);
    _initBuffer(lineIndex);

    final localOffset = deleteOffset - _bufferLineRopeStart;
    if (localOffset >= 0 && localOffset < _bufferLineText!.length) {
      final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
      final charToDelete = _rope.charAt(deleteOffset);
      final utf16End = utf16Local + charToDelete.length;
      deletedText = charToDelete;
      _bufferLineText =
          _bufferLineText!.substring(0, utf16Local) +
          _bufferLineText!.substring(utf16End);
      _bufferDirty = true;
      _cachedBufferLines = null;
      _selection = TextSelection.collapsed(offset: deleteOffset);
      _currentVersion++;
      dirtyLine = lineIndex;
      bufferNeedsRepaint = true;
      dirtyRegion = TextRange(start: deleteOffset, end: deleteOffset);
      _recordDeletion(deleteOffset, deletedText, selectionBefore, _selection);
      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();
      _scheduleFlush();
      notifyListeners();
    }
  }

  /// Remove the selection or the char at cursor position (delete key)
  void delete() {
    if (readOnly) return;
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    final selectionBefore = _selection;
    final sel = _selection;
    String deletedText;

    if (sel.start < sel.end) {
      _flushBuffer();

      if (deleteFoldRangeOnDeletingFirstLine) {
        final startLine = _rope.getLineAtOffset(sel.start);
        final endLine = _rope.getLineAtOffset(sel.end);

        if (startLine == endLine ||
            (startLine + 1 == endLine &&
                sel.end == _rope.getLineStartOffset(endLine))) {
          final lineStart = _rope.getLineStartOffset(startLine);
          final lineText = _rope.getLineText(startLine);
          final lineEnd = lineStart + lineText.length;
          final selectsWholeLine = sel.start <= lineStart && sel.end >= lineEnd;

          if (selectsWholeLine) {
            FoldRange? foldToDelete;

            if (_isFirstLineOfFoldedRange(startLine)) {
              foldToDelete = foldings[startLine];
            } else {
              for (final fold in foldings.values) {
                if (fold != null && fold.isFolded) {
                  if (startLine > fold.startIndex &&
                      startLine <= fold.endIndex) {
                    for (final child in fold.originallyFoldedChildren) {
                      if (child.startIndex == startLine) {
                        foldToDelete = child;
                        break;
                      }
                    }
                    if (foldToDelete != null) break;
                  }
                }
              }
            }

            if (foldToDelete != null) {
              final foldStart = _rope.getLineStartOffset(
                foldToDelete.startIndex,
              );
              final foldEndLine = foldToDelete.endIndex;
              final foldEndLineText = _rope.getLineText(foldEndLine);
              final foldEnd =
                  _rope.getLineStartOffset(foldEndLine) +
                  foldEndLineText.length;

              deletedText = _rope.substring(foldStart, foldEnd);
              _rope.delete(foldStart, foldEnd);
              _currentVersion++;
              _selection = TextSelection.collapsed(offset: foldStart);
              dirtyLine = _rope.getLineAtOffset(
                foldStart.clamp(0, _rope.length),
              );
              lineStructureChanged = true;
              foldings.remove(foldToDelete.startIndex);
              _rebuildFoldSortedCache();

              for (final fold in foldings.values) {
                if (fold != null) {
                  fold.originallyFoldedChildren.remove(foldToDelete);
                }
              }

              _recordDeletion(
                foldStart,
                deletedText,
                selectionBefore,
                _selection,
              );
              dirtyRegion = TextRange(start: foldStart, end: foldStart);
              _invalidateImeSnapshotAndScheduleSync();
              notifyListeners();
              return;
            }
          }
        }
      }

      deletedText = _rope.substring(sel.start, sel.end);
      _rope.delete(sel.start, sel.end);
      _currentVersion++;
      _selection = TextSelection.collapsed(offset: sel.start);
      dirtyLine = _rope.getLineAtOffset(sel.start);

      _recordDeletion(sel.start, deletedText, selectionBefore, _selection);
      dirtyRegion = TextRange(start: sel.start, end: sel.start);
      if (deletedText.contains('\n')) {
        lineStructureChanged = true;
      }
      _invalidateImeSnapshotAndScheduleSync();
      notifyListeners();
      return;
    }

    final textLen = length;
    if (sel.start >= textLen) return;

    final deleteOffset = sel.start;

    String charToDelete;
    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;
      if (deleteOffset >= _bufferLineRopeStart && deleteOffset < bufferEnd) {
        charToDelete = _bufferLineText![deleteOffset - _bufferLineRopeStart];
      } else {
        charToDelete = _rope.charAt(deleteOffset);
      }
    } else {
      charToDelete = _rope.charAt(deleteOffset);
    }

    if (charToDelete == '\n') {
      _flushBuffer();
      _rope.delete(deleteOffset, deleteOffset + 1);
      _currentVersion++;
      dirtyLine = _rope.getLineAtOffset(deleteOffset);
      lineStructureChanged = true;
      dirtyRegion = TextRange(start: deleteOffset, end: deleteOffset);

      _recordDeletion(deleteOffset, '\n', selectionBefore, _selection);
      _invalidateImeSnapshotAndScheduleSync();
      notifyListeners();
      return;
    }

    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;

      if (deleteOffset >= _bufferLineRopeStart && deleteOffset < bufferEnd) {
        final localOffset = deleteOffset - _bufferLineRopeStart;
        final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
        final cu = _bufferLineText!.codeUnitAt(utf16Local);
        final charLen = (cu >= 0xD800 && cu <= 0xDBFF) ? 2 : 1;
        final charToDelete = _bufferLineText!.substring(
          utf16Local,
          utf16Local + charLen,
        );
        final utf16End = utf16Local + charLen;
        deletedText = charToDelete;
        _bufferLineText =
            _bufferLineText!.substring(0, utf16Local) +
            _bufferLineText!.substring(utf16End);
        _currentVersion++;

        bufferNeedsRepaint = true;
        dirtyRegion = TextRange(start: deleteOffset, end: deleteOffset);

        _recordDeletion(deleteOffset, deletedText, selectionBefore, _selection);
        _imeSelectionNeedsResync = true;
        _invalidateImeSnapshotAndScheduleSync();
        _scheduleFlush();
        notifyListeners();
        return;
      }
    }

    final lineIndex = _rope.getLineAtOffset(deleteOffset);
    _initBuffer(lineIndex);

    final localOffset = deleteOffset - _bufferLineRopeStart;
    if (localOffset >= 0 && localOffset < _bufferLineText!.length) {
      final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
      final charToDelete = _rope.charAt(deleteOffset);
      final utf16End = utf16Local + charToDelete.length;
      deletedText = charToDelete;
      _bufferLineText =
          _bufferLineText!.substring(0, utf16Local) +
          _bufferLineText!.substring(utf16End);
      _bufferDirty = true;
      _cachedBufferLines = null;
      _currentVersion++;
      dirtyLine = lineIndex;

      bufferNeedsRepaint = true;

      _recordDeletion(deleteOffset, deletedText, selectionBefore, _selection);
      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();
      _scheduleFlush();
      notifyListeners();
    }
  }

  void _rebuildFoldSortedCache() {
    final starts = <int>[];
    final ends = <int>[];
    for (final fold in _foldings.values) {
      if (fold != null && fold.isFolded) {
        starts.add(fold.startIndex);
        ends.add(fold.endIndex);
      }
    }

    if (starts.length > 1) {
      final indices = List.generate(starts.length, (i) => i);
      indices.sort((a, b) => starts[a].compareTo(starts[b]));
      _foldedStartsSorted = [for (final i in indices) starts[i]];
      _foldedEndsSorted = [for (final i in indices) ends[i]];
    } else {
      _foldedStartsSorted = starts;
      _foldedEndsSorted = ends;
    }
  }

  bool _isFirstLineOfFoldedRange(int lineIndex) {
    final fold = foldings[lineIndex];
    return fold != null && fold.isFolded;
  }

  @protected
  @override
  void connectionClosed() {
    if (connection != null && connection!.attached) {
      connection?.connectionClosedReceived();
      connection = null;
      focusNode?.unfocus();
    }
    _imeComposingGlobal = TextRange.empty;
    _imeComposition = null;
    _pendingSelectionReplacement = null;
    _imeMirrorDeleteStart = -1;
    _imeMirrorDeleteLen = 0;
    _imeMirrorDeletedText = '';
    _rawTypedComposingText = '';
    _lastComposingText = '';
    imeCompositionChanged = true;
    _imeCompositionUndoGroup?.end();
    _imeCompositionUndoGroup = null;
  }

  @protected
  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  TextEditingValue? get currentTextEditingValue =>
      _buildCurrentImeEditingValue();

  TextEditingValue _buildCurrentImeEditingValue() {
    _ensureImeProjection();
    final projText = _imeProjectionText;
    final scalarSel = _imeProjectionSelection;
    final utf16Base = scalarToUtf16Offset(projText, scalarSel.baseOffset);
    final utf16Extent = scalarToUtf16Offset(projText, scalarSel.extentOffset);
    return TextEditingValue(
      text: projText,
      selection: TextSelection(
        baseOffset: utf16Base,
        extentOffset: utf16Extent,
      ),
      composing: _imeProjectionComposing,
    );
  }

  @protected
  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {}

  @protected
  @override
  void insertContent(KeyboardInsertedContent content) {}

  @protected
  @override
  void insertTextPlaceholder(Size size) {}

  @protected
  @override
  void performAction(TextInputAction action) {}

  @protected
  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @protected
  @override
  void performSelector(String selectorName) {}

  @protected
  @override
  void removeTextPlaceholder() {}

  @protected
  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @protected
  @override
  void showToolbar() {}

  @protected
  @override
  void updateEditingValue(TextEditingValue value) {
    if (readOnly) return;

    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    final involvesComposition =
        _imeComposition != null ||
        (value.composing.isValid && !value.composing.isCollapsed);
    if (involvesComposition) {
      _processCompositionValue(value);
      return;
    }

    _suppressImeSync = true;
    _ensureImeProjection();
    _beginImeCompositionUndoGroup(
      value.composing.isValid && !value.composing.isCollapsed,
    );

    final currentText = _imeProjectionText;
    final nextText = value.text;

    if (currentText != nextText) {
      int prefixLength = 0;
      final maxPrefix = currentText.length < nextText.length
          ? currentText.length
          : nextText.length;
      while (prefixLength < maxPrefix &&
          currentText.codeUnitAt(prefixLength) ==
              nextText.codeUnitAt(prefixLength)) {
        prefixLength++;
      }

      int suffixLength = 0;
      final currentTail = currentText.length - prefixLength;
      final nextTail = nextText.length - prefixLength;
      while (suffixLength < currentTail &&
          suffixLength < nextTail &&
          currentText.codeUnitAt(currentText.length - suffixLength - 1) ==
              nextText.codeUnitAt(nextText.length - suffixLength - 1)) {
        suffixLength++;
      }

      final replaceStart =
          _imeProjectionStartOffset +
          utf16ToScalarOffset(currentText, prefixLength);
      final replaceEnd =
          _imeProjectionStartOffset +
          utf16ToScalarOffset(currentText, currentText.length - suffixLength);
      final replacement = nextText.substring(
        prefixLength,
        nextText.length - suffixLength,
      );

      replaceRange(replaceStart, replaceEnd, replacement);
    }

    _selection = _localImeSelectionToGlobal(value.selection);
    _imeProjectionDirty = true;
    dirtyRegion = TextRange(start: 0, end: _rope.length);
    dirtyLine = null;
    _trackImeComposing(
      value.composing,
      value.selection.isValid
          ? value.selection.extentOffset
          : value.composing.end,
    );
    _endImeCompositionUndoGroupIfIdle();
    _suppressImeSync = false;
    _maybeAcquireFocusForInput();
    notifyListeners();
  }

  @protected
  @override
  bool onFocusReceived() {
    return true;
  }

  Offset? Function()? getFloatingCursorStartPosition;
  int Function(Offset)? getTextOffsetForFloatingCursorPosition;
  Offset? _floatingCursorStartPosition;

  @protected
  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    if (readOnly) return;

    switch (point.state) {
      case FloatingCursorDragState.Start:
        _floatingCursorStartPosition = getFloatingCursorStartPosition?.call();
        break;
      case FloatingCursorDragState.Update:
        if (point.offset == null ||
            _floatingCursorStartPosition == null ||
            getTextOffsetForFloatingCursorPosition == null) {
          return;
        }
        final targetPosition = _floatingCursorStartPosition! + point.offset!;
        final newOffset = getTextOffsetForFloatingCursorPosition!(
          targetPosition,
        );
        setSelectionSilently(TextSelection.collapsed(offset: newOffset));
        break;
      case FloatingCursorDragState.End:
        _floatingCursorStartPosition = null;
        break;
    }
  }

  /// Replace a range of text with new text.
  /// Used for clipboard operations and text manipulation.
  void replaceRange(
    int start,
    int end,
    String replacement, {
    bool preserveOldCursor = false,
  }) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    if (!_suppressImeSync) _imeComposingGlobal = TextRange.empty;
    final selectionBefore = _selection;
    final multiCursorsBefore = List<({int line, int character})>.from(
      _multiCursors,
    );
    _flushBuffer();
    final safeStart = start.clamp(0, _rope.length);
    final safeEnd = end.clamp(safeStart, _rope.length);
    final deletedText = safeStart < safeEnd
        ? _rope.substring(safeStart, safeEnd)
        : '';
    final supportsPullSemanticSync =
        lspConfig?.supportsSemanticTokensPull ?? true;

    _suppressLspFallbackSync = true;
    try {
      if (supportsPullSemanticSync) {
        _scheduleLspIncrementalSync(safeStart, safeEnd, replacement);
      }

      final result = _rope.core.replaceRangeAndUpdateSelection(
        start: BigInt.from(safeStart),
        end: BigInt.from(safeEnd),
        replacement: replacement,
        preserveOldCursor: preserveOldCursor,
        oldBase: BigInt.from(selectionBefore.baseOffset),
        oldExtent: BigInt.from(selectionBefore.extentOffset),
      );
      _currentVersion++;
      final newSelection = TextSelection(
        baseOffset: result.baseOffset.toInt(),
        extentOffset: result.extentOffset.toInt(),
      );
      _selection = newSelection;
      _shiftMultiCursors(safeStart, safeEnd, replacement.length);
      final multiCursorsAfter = List<({int line, int character})>.from(
        _multiCursors,
      );
      dirtyLine = _rope.getLineAtOffset(safeStart);
      dirtyRegion = TextRange(
        start: safeStart,
        end: safeStart + replacement.length,
      );

      if (deletedText.isNotEmpty && replacement.isNotEmpty) {
        _recordReplacement(
          safeStart,
          deletedText,
          replacement,
          selectionBefore,
          _selection,
          multiCursorsBefore: multiCursorsBefore,
          multiCursorsAfter: multiCursorsAfter,
        );
      } else if (deletedText.isNotEmpty) {
        _recordDeletion(
          safeStart,
          deletedText,
          selectionBefore,
          _selection,
          multiCursorsBefore: multiCursorsBefore,
          multiCursorsAfter: multiCursorsAfter,
        );
      } else if (replacement.isNotEmpty) {
        _recordInsertion(
          safeStart,
          replacement,
          selectionBefore,
          _selection,
          multiCursorsBefore: multiCursorsBefore,
          multiCursorsAfter: multiCursorsAfter,
        );
      }

      if (!supportsPullSemanticSync) {
        _scheduleLspFullSync(() => text);
      }

      _invalidateImeSnapshotAndScheduleSync();
      notifyListeners();
    } finally {
      _suppressLspFallbackSync = false;
    }
  }

  void _shiftMultiCursors(
    int startOffset,
    int endOffset,
    int replacementLength,
  ) {
    if (_multiCursors.isEmpty) return;
    final deletedLength = endOffset - startOffset;
    final delta = replacementLength - deletedLength;

    final newCursors = <({int line, int character})>[];
    for (final c in _multiCursors) {
      final offset = _multiCursorToOffset(c);
      if (offset < startOffset) {
        newCursors.add(c);
      } else if (offset >= endOffset) {
        final newOffset = (offset + delta).clamp(0, _rope.length);
        final newLine = _rope.getLineAtOffset(newOffset);
        final newLineStart = _rope.getLineStartOffset(newLine);
        newCursors.add((line: newLine, character: newOffset - newLineStart));
      }
    }
    _multiCursors
      ..clear()
      ..addAll(newCursors);
    _deduplicateMultiCursors();
    multiCursorsChanged = true;
  }

  /// Search the document for occurrences of [word] and add highlight ranges.
  ///
  /// - `word`: The substring to search for. If empty, existing highlights
  ///   are cleared and listeners are notified.
  /// - `highlightStyle`: Optional style applied to each found match. If null,
  ///   a default amber background style is used.
  /// - `matchCase`: When true the search is case-sensitive; otherwise the
  ///   search is performed case-insensitively.
  /// - `matchWholeWord`: When true matches are considered valid only when the
  ///   matched substring is not adjacent to other word characters (letters,
  ///   digits, or underscore).
  ///
  /// Behavior:
  /// Clears existing `searchHighlights`, scans the document for matches
  /// according to the provided options, appends a `SearchHighlight` for each
  /// match, sets `searchHighlightsChanged = true` and calls
  /// `notifyListeners()` to request a repaint/update.
  void findWord(
    String word, {
    bool matchCase = false,
    bool matchWholeWord = false,
  }) {
    searchHighlights.clear();

    if (word.isEmpty) {
      searchHighlightsChanged = true;
      notifyListeners();
      return;
    }

    final searchText = text;
    final searchWord = matchCase ? word : word.toLowerCase();
    final textToSearch = matchCase ? searchText : searchText.toLowerCase();

    int offset = 0;
    while (offset < textToSearch.length) {
      final index = textToSearch.indexOf(searchWord, offset);
      if (index == -1) break;

      bool isMatch = true;

      if (matchWholeWord) {
        final before = index > 0 ? searchText[index - 1] : '';
        final after = index + word.length < searchText.length
            ? searchText[index + word.length]
            : '';

        final isWordChar = RegExp(r'\w');
        final beforeIsWord = before.isNotEmpty && isWordChar.hasMatch(before);
        final afterIsWord = after.isNotEmpty && isWordChar.hasMatch(after);

        if (beforeIsWord || afterIsWord) {
          isMatch = false;
        }
      }

      if (isMatch) {
        searchHighlights.add(
          SearchHighlight(
            start: index,
            end: index + word.length,
            isCurrentMatch: true,
          ),
        );
      }

      offset = index + 1;
    }

    searchHighlightsChanged = true;
    notifyListeners();
  }

  /// Search the document using a regular expression and add highlight ranges
  /// for each match.
  ///
  /// - `regex`: The regular expression used to find matches in the current
  ///   document text. All matches returned by `regex.allMatches` are added as
  ///   highlights.
  /// - `highlightStyle`: Optional `TextStyle` applied to each match. If null,
  ///   a default amber background style is used.
  ///
  /// Behavior:
  /// Clears existing `searchHighlights`, applies [regex] to the document
  /// text, appends a `SearchHighlight` for every match and then sets
  /// `searchHighlightsChanged = true` and calls `notifyListeners()`.
  void findRegex(RegExp regex) {
    searchHighlights.clear();

    final searchText = text;
    final matches = regex.allMatches(searchText);

    for (final match in matches) {
      searchHighlights.add(
        SearchHighlight(
          start: match.start,
          end: match.end,
          isCurrentMatch: true,
        ),
      );
    }

    searchHighlightsChanged = true;
    notifyListeners();
  }

  /// Indent the current selection or insert an indent at the caret.
  ///
  /// If a range is selected, each line in the selected block is prefixed
  /// with three spaces. The selection is adjusted to account for the added
  /// characters. If there is no selection (collapsed caret), three spaces
  /// are inserted at the caret position.
  ///
  /// The method uses `replaceRange` and `setSelectionSilently` to update the
  /// document and selection without triggering external selection side
  /// effects.
  void indent() {
    if (selection.baseOffset != selection.extentOffset) {
      _flushBuffer();
      final selStart = selection.start;
      final selEnd = selection.end;

      final lineStart = _rope.findLineStart(selStart);
      final lineEnd = _rope.findLineEnd(selEnd);

      final selectedBlock = _rope.substring(lineStart, lineEnd);
      final indentedBlock = selectedBlock
          .split('\n')
          .map((line) => '$tabSpace$line')
          .join('\n');

      final lines = selectedBlock.split('\n');
      final addedChars = tabSize * lines.length;
      final newSelection = TextSelection(
        baseOffset: selection.baseOffset + tabSize,
        extentOffset: selection.extentOffset + addedChars,
      );

      replaceRange(lineStart, lineEnd, indentedBlock);
      setSelectionSilently(newSelection);
    } else {
      final caret = selection.start;
      final lineStart = _rope.findLineStart(caret);
      final column = caret - lineStart;
      final spacesToInsert = tabSize - (column % tabSize);
      insertAtCurrentCursor(' ' * spacesToInsert);
    }
  }

  /// Remove indentation from the current selection or the current line.
  ///
  /// If a range is selected, the method attempts to remove up to three
  /// leading spaces from each line in the selection (or removes the leading
  /// contiguous spaces if fewer than three). The selection is adjusted to
  /// reflect the removed characters. If there is no selection, the current
  /// line is unindented and the caret is moved appropriately.
  ///
  /// Uses `replaceRange` and `setSelectionSilently` to update the document
  /// and selection without causing external selection side effects.
  void unindent() {
    if (selection.baseOffset != selection.extentOffset) {
      _flushBuffer();
      final selStart = selection.start;
      final selEnd = selection.end;

      final lineStart = _rope.findLineStart(selStart);
      final lineEnd = _rope.findLineEnd(selEnd);

      final selectedBlock = _rope.substring(lineStart, lineEnd);
      final lines = selectedBlock.split('\n');
      final unindentedBlock = lines
          .map(
            (line) => line.startsWith(tabSpace)
                ? line.substring(tabSize)
                : line.replaceFirst(RegExp(r'^ +'), ''),
          )
          .join('\n');

      int removedChars = 0;
      for (final line in lines) {
        if (line.startsWith(tabSpace)) {
          removedChars += tabSize;
        } else {
          removedChars += RegExp(r'^ +').stringMatch(line)?.length ?? 0;
        }
      }

      final newSelection = TextSelection(
        baseOffset:
            selection.baseOffset -
            (lines.first.startsWith(tabSpace)
                ? tabSize
                : (RegExp(r'^ +').stringMatch(lines.first)?.length ?? 0)),
        extentOffset: selection.extentOffset - removedChars,
      );

      replaceRange(lineStart, lineEnd, unindentedBlock);
      setSelectionSilently(newSelection);
    } else {
      _flushBuffer();
      final caret = selection.start;
      final lineStart = _rope.findLineStart(caret);
      final lineEnd = _rope.findLineEnd(caret);
      final line = _rope.substring(lineStart, lineEnd);

      int removeCount = 0;
      if (line.startsWith(tabSpace)) {
        removeCount = tabSize;
      } else {
        removeCount = RegExp(r'^ +').stringMatch(line)?.length ?? 0;
      }

      final newLine = line.substring(removeCount);
      final newOffset = caret - removeCount > lineStart
          ? caret - removeCount
          : lineStart;

      replaceRange(lineStart, lineEnd, newLine);
      setSelectionSilently(TextSelection.collapsed(offset: newOffset));
    }
  }

  /// Clear all search highlights
  void clearSearchHighlights() {
    searchHighlights.clear();
    searchHighlightsChanged = true;
    notifyListeners();
  }

  /// Set fold operation callbacks - called by the render object
  void setFoldCallbacks({
    void Function(int lineNumber)? toggleFold,
    VoidCallback? foldAll,
    VoidCallback? unfoldAll,
  }) {
    _toggleFoldCallback = toggleFold;
    _foldAllCallback = foldAll;
    _unfoldAllCallback = unfoldAll;
  }

  /// Toggles the fold state at the specified line number.
  ///
  /// [lineNumber] is zero-indexed (0 for the first line).
  /// If the line is at the start of a fold region, it will be toggled.
  ///
  /// Throws [StateError] if:
  /// - Folding is not enabled on the editor
  /// - The editor has not been initialized
  /// - No fold range exists at the specified line
  ///
  /// Example:
  /// ```dart
  /// controller.toggleFold(5); // Toggle fold at line 6
  /// ```
  void toggleFold(int lineNumber) {
    if (_toggleFoldCallback == null) {
      throw StateError('Folding is not enabled or editor is not initialized');
    }
    _toggleFoldCallback!(lineNumber);
  }

  /// Folds all foldable regions in the document.
  ///
  /// All detected fold ranges will be collapsed, hiding their contents.
  ///
  /// Throws [StateError] if folding is not enabled or editor is not initialized.
  ///
  /// Example:
  /// ```dart
  /// controller.foldAll();
  /// ```
  void foldAll() {
    if (_foldAllCallback == null) {
      throw StateError('Folding is not enabled or editor is not initialized');
    }
    _foldAllCallback!();
  }

  /// Unfolds all folded regions in the document.
  ///
  /// All collapsed fold ranges will be expanded, showing their contents.
  ///
  /// Throws [StateError] if folding is not enabled or editor is not initialized.
  ///
  /// Example:
  /// ```dart
  /// controller.unfoldAll();
  /// ```
  void unfoldAll() {
    if (_unfoldAllCallback == null) {
      throw StateError('Folding is not enabled or editor is not initialized');
    }
    _unfoldAllCallback!();
  }

  /// Sets the scroll callback - called by the render object.
  void setScrollCallback(void Function(int line)? scrollToLine) {
    _scrollToLineCallback = scrollToLine;
  }

  /// Scrolls the editor view to make the specified line visible.
  ///
  /// [line] is zero-indexed (0 for the first line). The editor will scroll
  /// vertically to bring the specified line into view, centering it if possible.
  ///
  /// If the line is within a folded region, the fold will be expanded first
  /// to make the line visible.
  ///
  /// Throws [StateError] if the editor has not been initialized.
  /// Throws [RangeError] if [line] is out of bounds.
  ///
  /// Example:
  /// ```dart
  /// // Scroll to line 50 (1-indexed line 51)
  /// controller.scrollToLine(50);
  ///
  /// // Scroll to the first line
  /// controller.scrollToLine(0);
  /// ```
  void scrollToLine(int line) {
    if (_scrollToLineCallback == null) {
      throw StateError('Editor is not initialized');
    }
    if (line < 0 || line >= lineCount) {
      throw RangeError.range(line, 0, lineCount - 1, 'line');
    }
    _scrollToLineCallback!(line);
  }

  bool _isIdentChar(int code) {
    return (code >= 48 && code <= 57) ||
        (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        code == 95 ||
        code == 45 ||
        (code >= 0x0600 && code <= 0x06FF) ||
        (code >= 0x08A0 && code <= 0x08FF) ||
        (code >= 0x0590 && code <= 0x05FF);
  }

  bool _isIdentStartChar(int code) {
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        code == 95 ||
        (code >= 0x0600 && code <= 0x06FF) ||
        (code >= 0x08A0 && code <= 0x08FF) ||
        (code >= 0x0590 && code <= 0x05FF);
  }

  String getCurrentWordPrefix(String text, int offset) {
    if (isBufferActive) {
      final lineText = bufferLineText ?? '';
      final colScalar = bufferCursorColumn;
      if (colScalar <= 0) return '';
      final col = scalarToStringIndex(lineText, colScalar);
      if (col > lineText.length) return '';
      int i = col - 1;
      while (i >= 0) {
        final code = lineText.codeUnitAt(i);
        if (!_isIdentChar(code)) break;
        i--;
      }
      final start = i + 1;
      if (start >= col) return '';
      final firstCode = lineText.codeUnitAt(start);
      if (!_isIdentStartChar(firstCode)) return '';
      return lineText.substring(start, col);
    }

    final safeOffsetScalar = offset.clamp(0, text.runes.length);
    if (safeOffsetScalar == 0) return '';
    final safeOffset = scalarToStringIndex(text, safeOffsetScalar);
    int i = safeOffset - 1;
    while (i >= 0) {
      final code = text.codeUnitAt(i);
      if (!_isIdentChar(code)) break;
      i--;
    }
    final start = i + 1;
    if (start >= safeOffset) return '';
    final firstCode = text.codeUnitAt(start);
    if (!_isIdentStartChar(firstCode)) return '';
    return text.substring(start, safeOffset);
  }

  String getCurrentWordPrefixAt(int offset) {
    final safeOffset = offset.clamp(0, length);
    if (safeOffset == 0) return '';

    final lineIndex = _rope.getLineAtOffset(safeOffset);
    final lineStart = _rope.getLineStartOffset(lineIndex);
    final lineText = _bufferLineIndex == lineIndex && _bufferDirty
        ? _bufferLineText!
        : _rope.getLineText(lineIndex);

    final colScalar = (safeOffset - lineStart).clamp(0, lineText.runes.length);
    if (colScalar <= 0) return '';
    final col = scalarToStringIndex(lineText, colScalar);

    int i = col - 1;
    while (i >= 0) {
      final code = lineText.codeUnitAt(i);
      if (!_isIdentChar(code)) break;
      i--;
    }

    final start = i + 1;
    if (start >= col) return '';
    final firstCode = lineText.codeUnitAt(start);
    if (!_isIdentStartChar(firstCode)) return '';
    return lineText.substring(start, col);
  }

  /// Refetch the current file to delflect text changes
  /// Only works if a valid file is provided via `filePath`.
  void refetchFile() {
    if (_openedFile != null) {
      text = File(_openedFile!).readAsStringSync();
    }
  }

  /// Disposes of the controller and releases resources.
  ///
  /// Call this method when the controller is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _flushTimer?.cancel();
    _syncTimer?.cancel();
    _codeActionTimer?.cancel();
    _documentColorTimer?.cancel();
    _foldRangesTimer?.cancel();
    _documentHighlightTimer?.cancel();
    _cclsRefreshTimer?.cancel();
    _lspTypingTimer?.cancel();
    _lspDocumentSyncTimer?.cancel();
    _lspResponsesSubscription?.cancel();
    _listeners.clear();
    connection?.close();
  }

  /// Applies a workspace edit or code action payload coming from the LSP.
  ///
  /// The method understands several forms: a map with an `edit` containing
  /// `changes`, `documentChanges`, a raw list of edits, or a command. It will
  /// apply text edits to the currently opened file and update the LSP server
  /// document afterwards.
  Future<void> applyWorkspaceEdit(dynamic action) async {
    if (openedFile == null) return;
    final fileUri = Uri.file(openedFile!).toString();

    if (action is Map && action.containsKey('command')) {
      final String command = action['command'];
      final List args = action['arguments'] ?? [];
      await lspConfig?.executeCommand(command, args);
      return;
    } else if (action is Map &&
        action.containsKey('edit') &&
        (action['edit'] as Map).containsKey('changes')) {
      final Map changes = action['edit']['changes'] as Map;
      if (changes.containsKey(fileUri)) {
        final List edits = List.from(changes[fileUri] as List);
        final converted = <Map<String, dynamic>>[];
        for (final e in edits) {
          try {
            final start = e['range']?['start'];
            final end = e['range']?['end'];
            if (start == null || end == null) continue;
            final startLine = start['line'] as int;
            final startChar = start['character'] as int;
            final endLine = end['line'] as int;
            final endChar = end['character'] as int;
            final startOffset =
                getLineStartOffset(startLine) +
                utf16ToScalarOffset(getLineText(startLine), startChar);
            final endOffset =
                getLineStartOffset(endLine) +
                utf16ToScalarOffset(getLineText(endLine), endChar);
            final newText = e['newText'] as String? ?? '';
            converted.add({
              'start': startOffset,
              'end': endOffset,
              'newText': newText,
            });
          } catch (_) {
            continue;
          }
        }
        converted.sort(
          (a, b) => (b['start'] as int).compareTo(a['start'] as int),
        );
        for (final ce in converted) {
          replaceRange(
            ce['start'] as int,
            ce['end'] as int,
            ce['newText'] as String,
            preserveOldCursor: true,
          );
        }
        if (lspConfig != null) {
          await lspConfig!.updateDocument(openedFile!, text);
        }
      }
      return;
    } else if (action is Map &&
        action.containsKey('documentChanges') &&
        action['documentChanges'] is List) {
      final List docChanges = List.from(action['documentChanges'] as List);
      for (final dc in docChanges) {
        if (dc is Map) {
          final td = dc['textDocument'];
          final uri = td != null ? td['uri'] as String? : null;
          if (uri == fileUri && dc.containsKey('edits')) {
            final List edits = List.from(dc['edits'] as List);
            final converted = <Map<String, dynamic>>[];
            for (final e in edits) {
              try {
                final start = e['range']?['start'];
                final end = e['range']?['end'];
                if (start == null || end == null) continue;
                final startLine = start['line'] as int;
                final startChar = start['character'] as int;
                final endLine = end['line'] as int;
                final endChar = end['character'] as int;
                final int startOffset =
                    getLineStartOffset(startLine) +
                    utf16ToScalarOffset(getLineText(startLine), startChar);
                final int endOffset =
                    getLineStartOffset(endLine) +
                    utf16ToScalarOffset(getLineText(endLine), endChar);
                final String newText = e['newText'] as String? ?? '';
                converted.add({
                  'start': startOffset,
                  'end': endOffset,
                  'newText': newText,
                });
              } catch (_) {
                continue;
              }
            }
            converted.sort(
              (a, b) => (b['start'] as int).compareTo(a['start'] as int),
            );
            for (final ce in converted) {
              replaceRange(
                ce['start'] as int,
                ce['end'] as int,
                ce['newText'] as String,
                preserveOldCursor: true,
              );
            }
            if (lspConfig != null) {
              await lspConfig!.updateDocument(openedFile!, text);
            }
          }
        }
      }
      return;
    } else if (action is List) {
      final converted = <Map<String, dynamic>>[];
      try {
        for (Map<String, dynamic> item in action) {
          if (!(item.containsKey('newText') && item.containsKey('range'))) {
            return;
          }
          final start = item['range']?['start'];
          final end = item['range']?['end'];
          if (start == null || end == null) return;
          final startLine = start['line'] as int;
          final startChar = start['character'] as int;
          final endLine = end['line'] as int;
          final endChar = end['character'] as int;
          final startOffset =
              getLineStartOffset(startLine) +
              utf16ToScalarOffset(getLineText(startLine), startChar);
          final endOffset =
              getLineStartOffset(endLine) +
              utf16ToScalarOffset(getLineText(endLine), endChar);
          final newText = item['newText'] as String? ?? '';
          converted.add({
            'start': startOffset,
            'end': endOffset,
            'newText': newText,
          });
        }
      } catch (_) {
        return;
      }
      converted.sort(
        (a, b) => (b['start'] as int).compareTo(a['start'] as int),
      );
      for (final ce in converted) {
        replaceRange(
          ce['start'] as int,
          ce['end'] as int,
          ce['newText'] as String,
          preserveOldCursor: true,
        );
      }
      if (lspConfig != null) {
        await lspConfig!.updateDocument(openedFile!, text);
      }
    }
  }

  /// Calls the [LSP signature help](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_signatureHelp) feature.
  ///
  /// This method requests signature help from the Language Server Protocol (LSP)
  /// for the current cursor position, displaying available parameters and
  /// highlighting the parameter in focus within function parentheses.
  Future<void> callSignatureHelp() async {
    if (lspConfig != null) {
      final cursorPosition = selection.extentOffset;
      final line = getLineAtOffset(cursorPosition);
      final lineStartOffset = getLineStartOffset(line);
      final lineText = getLineText(line);
      final character = scalarToStringIndex(
        lineText,
        cursorPosition - lineStartOffset,
      );
      signatureNotifier.value = await lspConfig!.getSignatureHelp(
        openedFile!,
        line,
        character,
        1,
      );
    }
  }

  int _multiCursorToOffset(({int line, int character}) cursor) {
    final clampedLine = cursor.line.clamp(0, lineCount - 1);
    final lineText = getLineText(clampedLine);
    final clampedChar = cursor.character.clamp(0, lineText.runes.length);
    return getLineStartOffset(clampedLine) + clampedChar;
  }

  bool _isAlpha(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        (code >= 0x0600 && code <= 0x06FF) ||
        (code >= 0x08A0 && code <= 0x08FF) ||
        (code >= 0x0590 && code <= 0x05FF);
  }

  bool _isCompletionTriggerChar(String s) {
    if (s.isEmpty) return false;
    return s == '.' || s == ':' || s == '>' || s == '/' || s == '@';
  }

  List<LspSemanticToken> _convertCclsSymbolsToTokens(List<dynamic> symbols) {
    final tokens = <LspSemanticToken>[];
    final maxLen = length;

    for (final symbol in symbols) {
      if (symbol is! Map<String, dynamic>) continue;

      final kind = symbol['kind'] as int? ?? 0;
      final storage = symbol['storage'] as int? ?? 0;
      final tokenTypeName = _cclsSymbolKindToTokenType(kind);
      final lsRanges = symbol['lsRanges'] as List<dynamic>?;
      final ranges = symbol['ranges'] as List<dynamic>?;

      if (lsRanges != null && lsRanges.isNotEmpty) {
        for (final range in lsRanges) {
          int? line;
          int? startChar;
          int? endChar;

          if (range is List<dynamic> && range.length >= 3) {
            line = range[0] as int?;
            startChar = range[1] as int?;
            endChar = range[2] as int?;
          } else if (range is Map<String, dynamic>) {
            final start = range['start'] as Map<String, dynamic>?;
            final end = range['end'] as Map<String, dynamic>?;
            final startLine = start?['line'] as int?;
            final endLine = end?['line'] as int?;
            final startCharacter = start?['character'] as int?;
            final endCharacter = end?['character'] as int?;

            if (startLine != null &&
                endLine != null &&
                startCharacter != null &&
                endCharacter != null &&
                startLine == endLine) {
              line = startLine;
              startChar = startCharacter;
              endChar = endCharacter;
            }
          }

          if (line == null || startChar == null || endChar == null) continue;
          if (endChar <= startChar) continue;

          tokens.add(
            LspSemanticToken(
              line: line,
              start: startChar,
              length: endChar - startChar,
              typeIndex: kind,
              modifierBitmask: storage,
              tokenTypeName: tokenTypeName,
            ),
          );
        }
      } else if (ranges != null && ranges.isNotEmpty) {
        for (final range in ranges) {
          if (range is! Map<String, dynamic>) continue;
          final startByte = range['L'] as int?;
          final endByte = range['R'] as int?;
          if (startByte == null ||
              endByte == null ||
              startByte < 0 ||
              endByte > maxLen) {
            continue;
          }

          final startLine = getLineAtOffset(startByte);
          final startChar = startByte - getLineStartOffset(startLine);

          final endLine = getLineAtOffset(endByte);
          final endChar = endByte - getLineStartOffset(endLine);

          if (startLine == endLine) {
            tokens.add(
              LspSemanticToken(
                line: startLine,
                start: startChar,
                length: endChar - startChar,
                typeIndex: kind,
                modifierBitmask: storage,
                tokenTypeName: tokenTypeName,
              ),
            );
          }
        }
      }
    }

    return tokens;
  }

  String _cclsSymbolKindToTokenType(int kind) {
    switch (kind) {
      case 0:
        return 'unknown';
      case 1:
        return 'file';
      case 2:
        return 'module';
      case 3:
        return 'namespace';
      case 4:
        return 'package';
      case 5:
        return 'class';
      case 6:
        return 'method';
      case 7:
        return 'property';
      case 8:
        return 'field';
      case 9:
        return 'constructor';
      case 10:
        return 'enum';
      case 11:
        return 'interface';
      case 12:
        return 'function';
      case 13:
        return 'variable';
      case 14:
        return 'constant';
      case 15:
        return 'string';
      case 16:
        return 'number';
      case 17:
        return 'boolean';
      case 18:
        return 'array';
      case 19:
        return 'object';
      case 20:
        return 'key';
      case 21:
        return 'null';
      case 22:
        return 'enumMember';
      case 23:
        return 'struct';
      case 24:
        return 'event';
      case 25:
        return 'operator';
      case 26:
        return 'typeParameter';
      case 252:
        return 'type';
      case 253:
        return 'parameter';
      case 254:
        return 'variable';
      case 255:
        return 'macro';
      default:
        return 'unknown';
    }
  }

  void _sortSuggestions(String prefix) {
    _suggestions.sort((a, b) {
      final aLabel = a is LspCompletion ? a.label : a.toString();
      final bLabel = b is LspCompletion ? b.label : b.toString();
      final aScore = _scoreMatch(aLabel, prefix);
      final bScore = _scoreMatch(bLabel, prefix);

      if (aScore != bScore) {
        return bScore.compareTo(aScore);
      }

      return aLabel.compareTo(bLabel);
    });
  }

  int _scoreMatch(String label, String prefix) {
    if (prefix.isEmpty) return 0;

    final lowerLabel = label.toLowerCase();
    final lowerPrefix = prefix.toLowerCase();

    if (!lowerLabel.contains(lowerPrefix)) return -1000000;

    int score = 0;

    if (label.startsWith(prefix)) {
      score += 100000;
    } else if (lowerLabel.startsWith(lowerPrefix)) {
      score += 50000;
    } else {
      score += 10000;
    }

    final matchIndex = lowerLabel.indexOf(lowerPrefix);
    score -= matchIndex * 100;

    if (matchIndex > 0) {
      final charBefore = label[matchIndex - 1];
      final matchChar = label[matchIndex];
      if (charBefore.toLowerCase() == charBefore &&
          matchChar.toUpperCase() == matchChar) {
        score += 5000;
      } else if (charBefore == '_' || charBefore == '-') {
        score += 5000;
      }
    }

    score -= label.length;

    return score;
  }

  void _patchLastCompoundMultiCursors({
    required List<({int line, int character})> before,
    required List<({int line, int character})> after,
  }) {
    if (_undoController == null) return;
    final stack = _undoController!;
    if (stack.undoStack.isEmpty) return;
    final last = stack.undoStack.last;
    if (last is! CompoundOperation) return;
    stack.undoStack[stack.undoStack.length - 1] = CompoundOperation(
      operations: last.operations,
      selectionBefore: last.selectionBefore,
      selectionAfter: last.selectionAfter,
      multiCursorsBefore: before,
      multiCursorsAfter: after,
    );
  }

  void _applyUndoRedoOperation(EditOperation operation) {
    _flushBuffer();

    switch (operation) {
      case InsertOperation(:final offset, :final text, :final selectionAfter):
        final safeOffset = offset.clamp(0, _rope.length);
        _rope.insert(safeOffset, text);
        _currentVersion++;
        _selection = selectionAfter;
        dirtyLine = _rope.getLineAtOffset(safeOffset);
        if (text.contains('\n')) {
          lineStructureChanged = true;
        }
        dirtyRegion = TextRange(
          start: safeOffset,
          end: safeOffset + text.length,
        );
        lastInsertedText = text;
        lastDeletedText = '';
        break;

      case DeleteOperation(:final offset, :final text, :final selectionAfter):
        final safeStart = offset.clamp(0, _rope.length);
        final safeEnd = (offset + text.length).clamp(safeStart, _rope.length);
        if (safeStart < safeEnd) {
          _rope.delete(safeStart, safeEnd);
        }
        _currentVersion++;
        _selection = selectionAfter;
        dirtyLine = _rope.getLineAtOffset(safeStart);
        if (text.contains('\n')) {
          lineStructureChanged = true;
        }
        dirtyRegion = TextRange(start: safeStart, end: safeStart);
        lastInsertedText = '';
        lastDeletedText = text;
        break;

      case ReplaceOperation(
        :final offset,
        :final deletedText,
        :final insertedText,
        :final selectionAfter,
      ):
        final safeStart = offset.clamp(0, _rope.length);
        if (deletedText.isNotEmpty) {
          final deleteEnd = (safeStart + deletedText.length).clamp(
            safeStart,
            _rope.length,
          );
          if (deleteEnd > safeStart) _rope.delete(safeStart, deleteEnd);
        }
        if (insertedText.isNotEmpty) {
          _rope.insert(safeStart, insertedText);
        }
        _currentVersion++;
        _selection = selectionAfter;
        dirtyLine = _rope.getLineAtOffset(safeStart);
        if (deletedText.contains('\n') || insertedText.contains('\n')) {
          lineStructureChanged = true;
        }
        dirtyRegion = TextRange(
          start: safeStart,
          end: safeStart + insertedText.length,
        );
        lastInsertedText = insertedText;
        lastDeletedText = deletedText;
        break;
      case CompoundOperation(:final operations):
        for (final op in operations) {
          _applyUndoRedoOperation(op);
        }
        _restoreMultiCursorsFromOperation(operation);
        return;
    }

    _restoreMultiCursorsFromOperation(operation);

    _scheduleLspFullSync(() => text);
    _invalidateImeSnapshotAndScheduleSync();
    notifyListeners();
  }

  void _restoreMultiCursorsFromOperation(EditOperation operation) {
    final cursors = operation.multiCursorsAfter;
    if (cursors.isEmpty && _multiCursors.isEmpty) return;
    _multiCursors
      ..clear()
      ..addAll(cursors);
    multiCursorsChanged = true;
  }

  void _recordEdit(EditOperation operation) {
    _undoController?.recordEdit(operation);
  }

  void _recordInsertion(
    int offset,
    String text,
    TextSelection selBefore,
    TextSelection selAfter, {
    List<({int line, int character})>? multiCursorsBefore,
    List<({int line, int character})>? multiCursorsAfter,
  }) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    lastInsertedText = text;
    lastDeletedText = '';
    _recordEdit(
      InsertOperation(
        offset: offset,
        text: text,
        selectionBefore: selBefore,
        selectionAfter: selAfter,
        multiCursorsBefore: multiCursorsBefore,
        multiCursorsAfter: multiCursorsAfter,
      ),
    );
    if (!_suppressLspFallbackSync) {
      _scheduleLspFullSync(() => this.text);
    }
  }

  void _recordDeletion(
    int offset,
    String text,
    TextSelection selBefore,
    TextSelection selAfter, {
    List<({int line, int character})>? multiCursorsBefore,
    List<({int line, int character})>? multiCursorsAfter,
  }) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    lastDeletedText = text;
    lastInsertedText = '';
    _recordEdit(
      DeleteOperation(
        offset: offset,
        text: text,
        selectionBefore: selBefore,
        selectionAfter: selAfter,
        multiCursorsBefore: multiCursorsBefore,
        multiCursorsAfter: multiCursorsAfter,
      ),
    );
    if (!_suppressLspFallbackSync) {
      _scheduleLspFullSync(() => this.text);
    }
  }

  void _recordReplacement(
    int offset,
    String deleted,
    String inserted,
    TextSelection selBefore,
    TextSelection selAfter, {
    List<({int line, int character})>? multiCursorsBefore,
    List<({int line, int character})>? multiCursorsAfter,
  }) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    lastInsertedText = inserted;
    lastDeletedText = deleted;
    _recordEdit(
      ReplaceOperation(
        offset: offset,
        deletedText: deleted,
        insertedText: inserted,
        selectionBefore: selBefore,
        selectionAfter: selAfter,
        multiCursorsBefore: multiCursorsBefore,
        multiCursorsAfter: multiCursorsAfter,
      ),
    );
    if (!_suppressLspFallbackSync) {
      _scheduleLspFullSync(() => text);
    }
  }

  void _scheduleSyncToConnection() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 50), () {
      _syncToConnection();
      _syncTimer = null;
    });
  }

  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushDelay, _flushBuffer);
  }

  void _flushBuffer() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_bufferLineIndex == null || !_bufferDirty) return;

    final lineToInvalidate = _bufferLineIndex!;

    final start = _bufferLineRopeStart;
    final end = start + _bufferLineOriginalLength;

    if (_bufferLineOriginalLength > 0) {
      _rope.delete(start, end);
    }
    if (_bufferLineText!.isNotEmpty) {
      _rope.insert(start, _bufferLineText!);
    }

    _rope.setSelection(_selectionCache);

    _bufferLineIndex = null;
    _bufferLineText = null;
    _bufferDirty = false;
    _cachedBufferLines = null;

    _invalidateImeSnapshotAndScheduleSync();

    dirtyLine = lineToInvalidate;
    notifyListeners();
  }

  void clearDirtyRegion() {
    dirtyRegion = null;
    dirtyLine = null;
    lineStructureChanged = false;
    searchHighlightsChanged = false;
    lastInsertedText = '';
    lastDeletedText = '';
  }

  void _handleInsertion(
    int offset,
    String insertedText,
    TextSelection newSelection,
  ) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    if (hasMultiCursors && insertedText.isNotEmpty) {
      insertAtAllCursors(insertedText);
      return;
    }

    final selectionBefore = _selection;
    final currentLength = length;
    if (offset < 0 || offset > currentLength) {
      return;
    }

    const wrapPairs = {
      '(': ('(', ')'),
      ')': ('(', ')'),
      '[': ('[', ']'),
      ']': ('[', ']'),
      '{': ('{', '}'),
      '}': ('{', '}'),
      '<': ('<', '>'),
      '>': ('<', '>'),
      '"': ('"', '"'),
      "'": ("'", "'"),
      '`': ('`', '`'),
    };

    if (selectionBefore.start < selectionBefore.end &&
        insertedText.length == 1 &&
        wrapPairs.containsKey(insertedText)) {
      final pair = wrapPairs[insertedText]!;
      final openChar = pair.$1;
      final closeChar = pair.$2;
      final start = selectionBefore.start;
      final end = selectionBefore.end;
      final selectedText = _rope.substring(start, end);
      final wrappedText = '$openChar$selectedText$closeChar';
      final wrappedSelection = TextSelection(
        baseOffset: start + 1,
        extentOffset: start + 1 + selectedText.runes.length,
      );

      _flushBuffer();
      _rope.delete(start, end);
      _rope.insert(start, wrappedText);
      _currentVersion++;
      _selection = wrappedSelection;
      dirtyLine = _rope.getLineAtOffset(start);
      dirtyRegion = TextRange(
        start: start,
        end: start + wrappedText.runes.length,
      );

      _recordReplacement(
        start,
        selectedText,
        wrappedText,
        selectionBefore,
        wrappedSelection,
      );
      _invalidateImeSnapshotAndScheduleSync();
      notifyListeners();
      return;
    }

    String actualInsertedText = insertedText;
    TextSelection actualSelection = newSelection;

    if (insertedText.length == 1) {
      final char = insertedText[0];
      const pairs = {'(': ')', '{': '}', '[': ']', '"': '"', "'": "'"};
      final openers = pairs.keys.toSet();
      final closers = pairs.values.toSet();

      if (openers.contains(char)) {
        final closing = pairs[char]!;
        actualInsertedText = '$char$closing';
        actualSelection = TextSelection.collapsed(offset: offset + 1);
      } else if (closers.contains(char)) {
        if (offset < _rope.length &&
            _rope.substring(offset, offset + 1) == char) {
          _selection = TextSelection.collapsed(offset: offset + 1);
          notifyListeners();
          return;
        }
      }
    }

    if (actualInsertedText.contains('\n')) {
      final isSingleNewline = actualInsertedText == '\n';

      if (isSingleNewline) {
        final String textBeforeCursor;
        final String textAfterCursor;
        if (_bufferLineIndex != null && _bufferDirty) {
          final bufferEnd =
              _bufferLineRopeStart + _bufferLineText!.runes.length;
          if (offset >= _bufferLineRopeStart && offset <= bufferEnd) {
            final localOffset = offset - _bufferLineRopeStart;
            final utf16Local = scalarToStringIndex(
              _bufferLineText!,
              localOffset,
            );
            final ropeBeforeLine = _rope.substring(0, _bufferLineRopeStart);
            textBeforeCursor =
                ropeBeforeLine + _bufferLineText!.substring(0, utf16Local);
            final ropeAfterLine = _rope.substring(
              (_bufferLineRopeStart + _bufferLineOriginalLength).clamp(
                0,
                _rope.length,
              ),
              _rope.length,
            );
            textAfterCursor =
                _bufferLineText!.substring(utf16Local) + ropeAfterLine;
          } else {
            final currentText = text;
            final utf16Offset = scalarToUtf16Offset(currentText, offset);
            textBeforeCursor = currentText.substring(0, utf16Offset);
            textAfterCursor = currentText.substring(utf16Offset);
          }
        } else {
          final currentText = text;
          final utf16Offset = scalarToUtf16Offset(currentText, offset);
          textBeforeCursor = currentText.substring(0, utf16Offset);
          textAfterCursor = currentText.substring(utf16Offset);
        }
        final lines = textBeforeCursor.split('\n');

        if (lines.isNotEmpty) {
          final prevLine = lines[lines.length - 1];
          final indentMatch = RegExp(r'^\s*').firstMatch(prevLine);
          final prevIndent = indentMatch?.group(0) ?? '';
          final shouldIndent = RegExp(r'[:{[(]\s*$').hasMatch(prevLine);
          final extraIndent = shouldIndent ? tabSpace : '';
          final indent = prevIndent + extraIndent;
          final openToClose = {'{': '}', '(': ')', '[': ']'};
          final trimmedPrev = prevLine.trimRight();
          final lastChar = trimmedPrev.isNotEmpty
              ? trimmedPrev[trimmedPrev.length - 1]
              : null;
          final trimmedNext = textAfterCursor.trimLeft();
          final nextChar = trimmedNext.isNotEmpty ? trimmedNext[0] : null;
          final isBracketOpen = openToClose.containsKey(lastChar);
          final isNextClosing =
              isBracketOpen && openToClose[lastChar] == nextChar;

          if (isBracketOpen && isNextClosing) {
            actualInsertedText = '\n$indent\n$prevIndent';
            actualSelection = TextSelection.collapsed(
              offset: offset + 1 + indent.length,
            );
          } else {
            actualInsertedText = '\n$indent';
            actualSelection = TextSelection.collapsed(
              offset: offset + actualInsertedText.length,
            );
          }
        }
      } else {
        actualSelection = TextSelection.collapsed(
          offset: offset + actualInsertedText.length,
        );
      }

      _flushBuffer();
      _rope.insert(offset, actualInsertedText);
      _currentVersion++;
      _selection = actualSelection;
      dirtyLine = _rope.getLineAtOffset(offset);
      lineStructureChanged = true;
      dirtyRegion = TextRange(
        start: offset,
        end: offset + actualInsertedText.length,
      );

      _recordInsertion(
        offset,
        actualInsertedText,
        selectionBefore,
        actualSelection,
      );

      _invalidateImeSnapshotAndScheduleSync();

      notifyListeners();
      return;
    }

    if (actualInsertedText.length == 2 &&
        actualInsertedText[0] != actualInsertedText[1]) {
      if (_bufferLineIndex != null && _bufferDirty) {
        final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;

        if (offset >= _bufferLineRopeStart && offset <= bufferEnd) {
          final localOffset = offset - _bufferLineRopeStart;
          if (localOffset >= 0 && localOffset <= _bufferLineText!.length) {
            final utf16Local = scalarToStringIndex(
              _bufferLineText!,
              localOffset,
            );
            _bufferLineText =
                _bufferLineText!.substring(0, utf16Local) +
                actualInsertedText +
                _bufferLineText!.substring(utf16Local);
            _selection = actualSelection;
            _currentVersion++;
            dirtyLine = _bufferLineIndex;

            bufferNeedsRepaint = true;

            _recordInsertion(
              offset,
              actualInsertedText,
              selectionBefore,
              actualSelection,
            );

            _invalidateImeSnapshotAndScheduleSync();

            _scheduleFlush();
            notifyListeners();
            return;
          }
        }
        _flushBuffer();
      }

      final lineIndex = _rope.getLineAtOffset(offset);
      _initBuffer(lineIndex);

      final localOffset = offset - _bufferLineRopeStart;
      if (localOffset >= 0 && localOffset <= _bufferLineText!.length) {
        final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
        _bufferLineText =
            _bufferLineText!.substring(0, utf16Local) +
            actualInsertedText +
            _bufferLineText!.substring(utf16Local);
        _bufferDirty = true;
        _cachedBufferLines = null;
        _selection = actualSelection;
        _currentVersion++;
        dirtyLine = lineIndex;

        bufferNeedsRepaint = true;

        _recordInsertion(
          offset,
          actualInsertedText,
          selectionBefore,
          actualSelection,
        );

        _invalidateImeSnapshotAndScheduleSync();

        _scheduleFlush();
        notifyListeners();
      }
      return;
    }

    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;

      if (offset >= _bufferLineRopeStart && offset <= bufferEnd) {
        final localOffset = offset - _bufferLineRopeStart;
        if (localOffset >= 0 && localOffset <= _bufferLineText!.length) {
          final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
          _bufferLineText =
              _bufferLineText!.substring(0, utf16Local) +
              actualInsertedText +
              _bufferLineText!.substring(utf16Local);
          _selection = actualSelection;
          _currentVersion++;
          dirtyLine = _bufferLineIndex;

          bufferNeedsRepaint = true;

          _recordInsertion(
            offset,
            actualInsertedText,
            selectionBefore,
            actualSelection,
          );

          _invalidateImeSnapshotAndScheduleSync();

          _scheduleFlush();
          notifyListeners();
          return;
        }
      }
      _flushBuffer();
    }

    final lineIndex = _rope.getLineAtOffset(offset);
    _initBuffer(lineIndex);

    final localOffset = offset - _bufferLineRopeStart;
    if (localOffset >= 0 && localOffset <= _bufferLineText!.length) {
      final utf16Local = scalarToStringIndex(_bufferLineText!, localOffset);
      _bufferLineText =
          _bufferLineText!.substring(0, utf16Local) +
          actualInsertedText +
          _bufferLineText!.substring(utf16Local);
      _bufferDirty = true;
      _cachedBufferLines = null;
      _selection = actualSelection;
      _currentVersion++;
      dirtyLine = lineIndex;

      bufferNeedsRepaint = true;

      _recordInsertion(
        offset,
        actualInsertedText,
        selectionBefore,
        actualSelection,
      );

      _invalidateImeSnapshotAndScheduleSync();

      _scheduleFlush();
    }
  }

  void _handleDeletion(TextRange range, TextSelection newSelection) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    if (hasMultiCursors &&
        range.end - range.start == 1 &&
        range.end == _selection.extentOffset) {
      backspaceAtAllCursors();
      return;
    }

    final selectionBefore = _selection;
    final currentLength = length;
    if (range.start < 0 ||
        range.end > currentLength ||
        range.start > range.end) {
      return;
    }

    final deleteLen = range.end - range.start;

    if (_bufferLineIndex != null && _bufferDirty) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineText!.runes.length;

      if (range.start >= _bufferLineRopeStart && range.end <= bufferEnd) {
        final localStart = range.start - _bufferLineRopeStart;
        final localEnd = range.end - _bufferLineRopeStart;

        if (localStart >= 0 && localEnd <= _bufferLineText!.length) {
          final utf16LocalStart = scalarToStringIndex(
            _bufferLineText!,
            localStart,
          );
          final utf16LocalEnd = scalarToStringIndex(_bufferLineText!, localEnd);
          final deletedText = _bufferLineText!.substring(
            utf16LocalStart,
            utf16LocalEnd,
          );
          if (deletedText.contains('\n')) {
            _flushBuffer();
            _rope.delete(range.start, range.end);
            _currentVersion++;
            _selection = newSelection;
            dirtyLine = _rope.getLineAtOffset(range.start);
            lineStructureChanged = true;
            dirtyRegion = TextRange(start: range.start, end: range.start);

            _recordDeletion(
              range.start,
              deletedText,
              selectionBefore,
              newSelection,
            );
            _imeSelectionNeedsResync = true;
            _invalidateImeSnapshotAndScheduleSync();
            return;
          }

          _bufferLineText =
              _bufferLineText!.substring(0, utf16LocalStart) +
              _bufferLineText!.substring(utf16LocalEnd);
          _selection = newSelection;
          _currentVersion++;

          bufferNeedsRepaint = true;

          _recordDeletion(
            range.start,
            deletedText,
            selectionBefore,
            newSelection,
          );

          _imeSelectionNeedsResync = true;
          _invalidateImeSnapshotAndScheduleSync();

          _scheduleFlush();
          return;
        }
      }
      _flushBuffer();
    }

    bool crossesNewline = false;
    String deletedText = '';
    if (deleteLen == 1) {
      if (range.start < _rope.length) {
        deletedText = _rope.charAt(range.start);
        if (deletedText == '\n') {
          crossesNewline = true;
        }
      }
    } else {
      crossesNewline = true;
      deletedText = _rope.substring(range.start, range.end);
    }

    if (crossesNewline) {
      if (deletedText.isEmpty) {
        deletedText = _rope.substring(range.start, range.end);
      }
      _rope.delete(range.start, range.end);
      _currentVersion++;
      _selection = newSelection;
      dirtyLine = _rope.getLineAtOffset(range.start);
      lineStructureChanged = true;
      dirtyRegion = TextRange(start: range.start, end: range.start);

      _recordDeletion(range.start, deletedText, selectionBefore, newSelection);
      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();
      return;
    }

    final lineIndex = _rope.getLineAtOffset(range.start);
    _initBuffer(lineIndex);

    final localStart = range.start - _bufferLineRopeStart;
    final localEnd = range.end - _bufferLineRopeStart;

    final utf16LocalStart = scalarToStringIndex(_bufferLineText!, localStart);
    final utf16LocalEnd = scalarToStringIndex(_bufferLineText!, localEnd);

    if (localStart >= 0 && localEnd <= _bufferLineText!.length) {
      deletedText = _bufferLineText!.substring(utf16LocalStart, utf16LocalEnd);
      _bufferLineText =
          _bufferLineText!.substring(0, utf16LocalStart) +
          _bufferLineText!.substring(utf16LocalEnd);
      _bufferDirty = true;
      _cachedBufferLines = null;
      _selection = newSelection;
      _currentVersion++;

      bufferNeedsRepaint = true;

      _recordDeletion(range.start, deletedText, selectionBefore, newSelection);

      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();

      _scheduleFlush();
    }
  }

  void _handleReplacement(
    TextRange range,
    String text,
    TextSelection newSelection,
  ) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;

    final selectionBefore = _selection;
    _flushBuffer();

    const wrapPairs = {
      '(': ('(', ')'),
      ')': ('(', ')'),
      '[': ('[', ']'),
      ']': ('[', ']'),
      '{': ('{', '}'),
      '}': ('{', '}'),
      '<': ('<', '>'),
      '>': ('<', '>'),
      '"': ('"', '"'),
      "'": ("'", "'"),
      '`': ('`', '`'),
    };

    if (range.start < range.end &&
        text.length == 1 &&
        wrapPairs.containsKey(text)) {
      final pair = wrapPairs[text]!;
      final openChar = pair.$1;
      final closeChar = pair.$2;
      final selectedText = _rope.substring(range.start, range.end);
      final wrappedText = '$openChar$selectedText$closeChar';
      final wrappedSelection = TextSelection(
        baseOffset: range.start + 1,
        extentOffset: range.start + 1 + selectedText.runes.length,
      );

      final deletedText = selectedText;

      _rope.delete(range.start, range.end);
      _rope.insert(range.start, wrappedText);
      _currentVersion++;
      _selection = wrappedSelection;
      dirtyLine = _rope.getLineAtOffset(range.start);
      dirtyRegion = TextRange(
        start: range.start,
        end: range.start + wrappedText.runes.length,
      );

      _recordReplacement(
        range.start,
        deletedText,
        wrappedText,
        selectionBefore,
        wrappedSelection,
      );
      _imeSelectionNeedsResync = true;
      _invalidateImeSnapshotAndScheduleSync();
      return;
    }

    final deletedText = range.start < range.end
        ? _rope.substring(range.start, range.end)
        : '';

    _rope.delete(range.start, range.end);
    _rope.insert(range.start, text);
    _currentVersion++;
    _selection = newSelection;
    dirtyLine = _rope.getLineAtOffset(range.start);
    dirtyRegion = TextRange(start: range.start, end: range.start + text.length);

    _recordReplacement(
      range.start,
      deletedText,
      text,
      selectionBefore,
      newSelection,
    );
    _imeSelectionNeedsResync = true;
    _invalidateImeSnapshotAndScheduleSync();
  }

  void _initBuffer(int lineIndex) {
    _bufferLineIndex = lineIndex;
    _bufferLineText = _rope.getLineText(lineIndex);
    _bufferLineRopeStart = _rope.getLineStartOffset(lineIndex);
    _bufferLineOriginalLength = _bufferLineText!.runes.length;
    _bufferDirty = false;
  }

  static int scalarToUtf16Offset(String text, int scalarOffset) {
    if (scalarOffset <= 0) return 0;
    final codeUnits = text.codeUnits;
    final len = codeUnits.length;
    if (scalarOffset >= len) return len;
    int utf16 = 0;
    int scalar = 0;
    while (utf16 < len && scalar < scalarOffset) {
      final u = codeUnits[utf16];
      if (u >= 0xD800 && u < 0xDC00 && utf16 + 1 < len) {
        final u2 = codeUnits[utf16 + 1];
        utf16 += (u2 >= 0xDC00 && u2 < 0xE000) ? 2 : 1;
      } else {
        utf16 += 1;
      }
      scalar++;
    }
    return utf16;
  }

  static int utf16ToScalarOffset(String text, int utf16Offset) {
    if (utf16Offset <= 0) return 0;
    final codeUnits = text.codeUnits;
    final len = codeUnits.length;
    int utf16 = 0;
    int scalar = 0;
    while (utf16 < len) {
      final u = codeUnits[utf16];
      int step;
      if (u >= 0xD800 && u < 0xDC00 && utf16 + 1 < len) {
        final u2 = codeUnits[utf16 + 1];
        step = (u2 >= 0xDC00 && u2 < 0xE000) ? 2 : 1;
      } else {
        step = 1;
      }
      final nextUtf16 = utf16 + step;
      // A UTF-16 offset between the two code units of a surrogate pair has no
      // corresponding Rope position. Snap it to the preceding scalar rather
      // than letting it split an emoji or drift one scalar to the right.
      if (utf16Offset < nextUtf16) return scalar;
      utf16 = nextUtf16;
      scalar++;
      if (utf16 == utf16Offset) return scalar;
    }
    return scalar;
  }

  static int scalarToStringIndex(String text, int scalarOffset) {
    if (scalarOffset <= 0) return 0;
    final codeUnits = text.codeUnits;
    final len = codeUnits.length;
    if (scalarOffset >= len) return len;
    int utf16 = 0;
    int scalar = 0;
    while (utf16 < len && scalar < scalarOffset) {
      final u = codeUnits[utf16];
      if (u >= 0xD800 && u < 0xDC00 && utf16 + 1 < len) {
        final u2 = codeUnits[utf16 + 1];
        utf16 += (u2 >= 0xDC00 && u2 < 0xE000) ? 2 : 1;
      } else {
        utf16 += 1;
      }
      scalar++;
    }
    return utf16;
  }

  /// Check whether the corresponding [lineIndex] is inside a folded code block or not.
  bool isLineInFoldedRegion(int lineIndex) {
    final starts = _foldedStartsSorted;
    final ends = _foldedEndsSorted;
    if (starts.isEmpty) return false;

    int lo = 0, hi = starts.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (starts[mid] < lineIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    for (int i = hi; i >= 0; i--) {
      if (starts[i] >= lineIndex) continue;
      if (ends[i] >= lineIndex) return true;
      if (lineIndex - starts[i] > 100000) break;
    }
    return false;
  }

  /// if the corresponding line is in a foldable region, this function returns the first line in that foldable block.
  int? getFoldStartForLine(int lineIndex) {
    final starts = _foldedStartsSorted;
    final ends = _foldedEndsSorted;
    if (starts.isEmpty) return null;
    int lo = 0, hi = starts.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (starts[mid] < lineIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    for (int i = hi; i >= 0; i--) {
      if (starts[i] >= lineIndex) continue;
      if (ends[i] >= lineIndex) return starts[i];
      if (lineIndex - starts[i] > 100000) break;
    }
    return null;
  }

  /// Get the [FoldRange] information if the corresponding line is included in a foldable block.
  FoldRange? getFoldRangeAtCurrentLine(int lineIndex) {
    return foldings[lineIndex];
  }

  Future<Set<String>> _extractWords() async {
    return (await wordsExtract(rope: _rope.core)).toSet();
  }
}
