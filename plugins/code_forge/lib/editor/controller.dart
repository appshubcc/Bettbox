import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:code_forge/src/rust/api/editor.dart';

import '../code_forge.dart';
import 'text.dart';

export 'text.dart' show DocumentSnapshot;

part 'input.dart';

typedef DocumentEditListener = void Function(
  int offset,
  int removed,
  int inserted,
);

/// What changed since the last [CodeForgeController.takeChange].
final class CodeForgeChange {
  CodeForgeChange._();

  bool _replaced = false, _selection = false, _composition = false;
  bool _searchHighlights = false, _typing = false;
  ({int line, int removed, int inserted})? _lines;

  bool get replaced => _replaced;

  bool get selection => _selection;

  bool get composition => _composition;

  bool get searchHighlights => _searchHighlights;

  /// Typing in the line buffer, which reaches [lines] once it flushes.
  bool get typing => _typing;

  /// From `line` on, `removed` line breaks gave way to `inserted`.
  ({int line, int removed, int inserted})? get lines => _lines;

  bool get isEmpty =>
      !_replaced &&
      !_selection &&
      !_composition &&
      !_searchHighlights &&
      !_typing &&
      _lines == null;
}

abstract interface class CodeForgeView {
  FocusNode get focusNode;

  /// Reopens the input connection so the platform drops its composition.
  void resetInput();

  Offset? caretOffset();

  int? textOffsetAt(Offset position);

  void toggleFold(int line);

  void scrollToLine(int line);
}

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
/// ```
class CodeForgeController implements DeltaTextInputClient {
  static const _flushDelay = Duration(milliseconds: 100);
  static const _imeProjectionLineRadius = 2, _imeProjectionMaxChars = 4096;
  static const _lineEditLogLimit = 256;
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final List<VoidCallback> _listeners = [];
  final List<DocumentEditListener> _editListeners = [];
  CodeForgeView? _view;
  Timer? _flushTimer, _debounceTimer;
  String? _cachedText, _bufferLineText;
  String _imeProjectionText = '';
  final List<TextSelection> _sentSelections = [];
  TextSelection _imeProjectionSelection = const TextSelection.collapsed(
    offset: 0,
  );
  bool _suppressImeSync = false;
  CompoundOperationHandle? _imeCompositionUndoGroup;
  ImeComposition? _imeComposition;
  TextEditingValue _imeMirror = TextEditingValue.empty;
  String _imeWindowCommitted = '';
  int _imeWindowStart = 0;
  TextSelection? _pendingSelectionReplacement;
  final Set<String> _supersededPlatformTexts = {};
  ({int start, int length})? _imeHeldWindow;
  ({int version, DateTime at})? _selectionRemoval;
  ({int start, int caret})? _imeShiftedWindow;
  String? _copiedLine;
  ({int start, String text})? _imeMirrorDeletion;
  String _rawTypedComposingText = '';
  String _lastComposingText = '';
  bool _bufferDirty = false;
  bool _imeProjectionDirty = true, _imeSelectionNeedsResync = false;
  bool _isTyping = false, _isDisposed = false;
  int _imeProjectionStartOffset = 0;
  int _cachedTextVersion = -1, _currentVersion = 0;
  final List<({int version, int line, int removed, int inserted})>
  _lineEditLog = [];
  int _lineEditLogStart = 0;
  int _bufferLineRopeStart = 0, _bufferLineOriginalLength = 0;
  int? _bufferLineIndex;
  var _change = CodeForgeChange._();
  List<TextRange>? _snippetStops;
  int _snippetStopIndex = 0;
  UndoRedoController? _undoController;
  Set<String> _wordCache = {};
  int _wordCacheVersion = -1;
  int _completionStart = 0;

  CodeForgeController() {
    suggestionsNotifier.addListener(() {
      selectedSuggestionNotifier.value =
          suggestionsNotifier.value == null || _isMobile ? null : 0;
    });
    _listeners.add(() async {
      if (!enableLocalSuggestions && completionSource == null) return;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        if (enableLocalSuggestions && _wordCacheVersion != _currentVersion) {
          _wordCacheVersion = _currentVersion;
          _wordCache = await _extractWords();
        }
        if (_isDisposed) return;
        final typing = _isTyping && (focusNode?.hasFocus ?? true);
        _showCompletion(typing ? _complete() : null);
      });
    });
  }

  /// The completion popup's entries, or null while it is closed.
  final ValueNotifier<List<CodeForgeSuggestion>?> suggestionsNotifier =
      ValueNotifier(null);

  /// The entry of [suggestionsNotifier] Enter accepts. Starts at the first
  /// entry on desktop; on mobile nothing is highlighted until the arrow keys
  /// move it, so the soft keyboard's Enter still inserts a newline.
  final ValueNotifier<int?> selectedSuggestionNotifier = ValueNotifier(null);

  /// Whether the suggestions/completions are enabled or not.
  bool enableLocalSuggestions = false;

  /// Replaces the popup's document-word matching when set.
  CodeForgeCompletionSource? completionSource;

  String? lineCommentPrefix;

  bool blockComments = false;

  FocusNode? get focusNode => _view?.focusNode;

  VoidCallback? onClipboardWriteFailed;

  List<CodeForgeSuggestion>? get suggestions => suggestionsNotifier.value;

  Rope _rope = Rope('');
  Rope get rope => _rope;
  TextSelection _selection = const TextSelection.collapsed(offset: 0);

  /// The text input connection to the platform.
  TextInputConnection? connection;

  void attachView(CodeForgeView view) => _view = view;

  void detachView(CodeForgeView view) {
    if (identical(_view, view)) _view = null;
  }

  /// The fold ranges the renderer has found, keyed by start line. The
  /// renderer publishes them when a fold is toggled, so this is empty until
  /// then.
  ///
  /// Use the setter to update this map — it rebuilds internal sorted caches
  /// used for O(log n) fold-region lookups.
  Map<int, FoldRange?> get foldings => _foldings;

  Map<int, FoldRange?> _foldings = {};
  List<({int start, int end})> _folded = const [];

  /// Set fold ranges in the editor
  set foldings(Map<int, FoldRange?> value) {
    _foldings = value;
    _rebuildFoldSortedCache();
  }

  List<SearchHighlight> get searchHighlights => _searchHighlights;
  List<SearchHighlight> _searchHighlights = const [];

  /// In document order.
  set searchHighlights(List<SearchHighlight> value) {
    _searchHighlights = value;
    _change._searchHighlights = true;
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

  CodeForgeChange takeChange() {
    final change = _change;
    _change = CodeForgeChange._();
    return change;
  }

  ({int line, int removed, int inserted})? get pendingLineEdit =>
      _change._lines;

  /// Sets the undo controller for this editor.
  ///
  /// The undo controller manages the undo/redo history for text operations.
  /// Pass null to disable undo/redo functionality.
  UndoRedoController? get undoController => _undoController;

  // One closure, so the history can tell this controller's from another's.
  late final void Function(EditOperation) _applyUndoRedo =
      _applyUndoRedoOperation;

  void setUndoController(UndoRedoController? controller) {
    if (identical(controller, _undoController)) return;
    _undoController?.releaseApplyEditCallback(_applyUndoRedo);
    _undoController = controller;
    controller?.setApplyEditCallback(
      _applyUndoRedo,
      settleInput: commitComposition,
    );
  }

  /// The complete text content of the editor.
  ///
  /// Getting this property returns the full document text.
  /// Setting this property replaces all content and moves the cursor to the end.
  String get text {
    if (_cachedText == null || _cachedTextVersion != _currentVersion) {
      if (_bufferLineIndex != null && _bufferDirty) {
        final before = _rope.substring(0, _bufferLineRopeStart);
        final after = _rope.substring(
          _bufferLineRopeStart + _bufferLineOriginalLength,
        );
        _cachedText = before + _bufferLineText! + after;
      } else {
        _cachedText = _rope.getText();
      }
      _cachedTextVersion = _currentVersion;
    }
    return _cachedText!;
  }

  /// The total length of the document in characters.
  int get length {
    if (_bufferLineIndex != null && _bufferDirty) {
      return _rope.length + (_bufferLineLength - _bufferLineOriginalLength);
    }
    return _rope.length;
  }

  /// The current text selection in the editor.
  ///
  /// For a cursor with no selection, [TextSelection.isCollapsed] will be true.
  TextSelection get selection => _selection;

  /// Returns a window of lines without allocating the full buffer.
  List<String> getLinesRange(int startLine, int endLine) {
    final lines = _rope.cachedLinesRange(startLine, endLine);
    final buffered = isBufferActive ? _bufferLineIndex! - startLine : -1;
    if (buffered >= 0 && buffered < lines.length) {
      lines[buffered] = _bufferLineText!;
    }
    return lines;
  }

  /// The total number of lines in the document.
  int get lineCount => _rope.lineCount;

  /// Gets the text content of a specific line.
  ///
  /// [lineIndex] is zero-based (0 for the first line).
  /// Returns the text of the line without the newline character.
  String getLineText(int lineIndex) {
    if (isBufferActive && lineIndex == _bufferLineIndex) {
      return _bufferLineText!;
    }
    return _rope.getLineText(lineIndex);
  }

  /// Gets the line number (zero-based) for a character offset.
  ///
  /// [charOffset] is the character position in the document.
  /// Returns the line index containing that character.
  int getLineAtOffset(int charOffset) {
    if (isBufferActive) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineLength;
      if (charOffset > bufferEnd) {
        return _rope.getLineAtOffset(
          charOffset - (_bufferLineLength - _bufferLineOriginalLength),
        );
      }
      if (charOffset >= _bufferLineRopeStart) return _bufferLineIndex!;
    }
    return _rope.getLineAtOffset(charOffset);
  }

  /// Gets the character offset where a line starts.
  ///
  /// [lineIndex] is zero-based (0 for the first line).
  /// Returns the character offset of the first character in that line.
  int getLineStartOffset(int lineIndex) {
    if (isBufferActive && lineIndex > _bufferLineIndex!) {
      return _rope.getLineStartOffset(lineIndex) +
          _bufferLineLength -
          _bufferLineOriginalLength;
    }
    return _rope.getLineStartOffset(lineIndex);
  }

  /// Lines break at LF alone, and a line's text leaves out the CR of a CRLF
  /// pair that its offsets still count, so CRLF and lone CR text comes in as LF.
  static String normalizeLineBreaks(String text) =>
      text.contains('\r') ? text.replaceAll(RegExp(r'\r\n?'), '\n') : text;

  ({int start, int end, String? text}) get _dirtyOverlay => isBufferActive
      ? (
          start: _bufferLineRopeStart,
          end: _bufferLineRopeStart + _bufferLineOriginalLength,
          text: _bufferLineText,
        )
      : (start: 0, end: 0, text: null);

  DocumentSnapshot saveSnapshot() {
    final dirty = _dirtyOverlay;
    return _rope.snapshot(
      dirtyStart: dirty.start,
      dirtyEnd: dirty.end,
      dirtyText: dirty.text,
    );
  }

  bool matchesSnapshot(DocumentSnapshot snapshot) {
    final dirty = _dirtyOverlay;
    return _rope.equalsSnapshot(
      snapshot,
      dirtyStart: dirty.start,
      dirtyEnd: dirty.end,
      dirtyText: dirty.text,
    );
  }

  Uint32List? findMatchesInRange(
    int startChar,
    int endChar, {
    required String pattern,
    required bool isRegex,
    required bool caseSensitive,
    required bool wholeWord,
  }) {
    final dirty = _dirtyOverlay;
    return searchFindRope(
      rope: _rope.core,
      startChar: BigInt.from(startChar),
      endChar: BigInt.from(endChar),
      dirtyStart: BigInt.from(dirty.start),
      dirtyEnd: BigInt.from(dirty.end),
      dirtyText: dirty.text,
      pattern: pattern,
      isRegex: isRegex,
      caseSensitive: caseSensitive,
      wholeWord: wholeWord,
    );
  }

  Future<void> loadFile(String path) async {
    final next = await Rope.fromFile(path);
    if (_isDisposed) {
      next.dispose();
      return;
    }
    _resetWithRope(next);
  }

  /// Keeps the undo history; a caller loading another file clears it.
  set text(String newText) {
    _resetWithRope(Rope(newText));
  }

  void _resetWithRope(Rope nextRope) {
    final previousLength = length;
    _flushTimer?.cancel();
    _debounceTimer?.cancel();
    suggestionsNotifier.value = null;
    _snippetStops = null;
    _bufferLineIndex = null;
    _bufferLineText = null;
    _bufferDirty = false;
    if (isComposingActive) {
      _dropImeComposition();
      _view?.resetInput();
    }
    _pendingSelectionReplacement = null;
    _rope.dispose();
    _rope = nextRope;
    _currentVersion++;
    _lineEditLog.clear();
    _lineEditLogStart = _currentVersion;
    _cachedText = null;
    _cachedTextVersion = -1;
    _selection = TextSelection.collapsed(offset: _rope.length);
    foldings = {};
    _change = CodeForgeChange._().._replaced = true;
    _isTyping = false;
    _invalidateImeSnapshotAndScheduleSync();
    _notifyEdit(0, previousLength, _rope.length);
    notifyListeners();
  }

  /// Clamped to the document; a composition in progress is committed first.
  set selection(TextSelection newSelection) {
    if (_selection == newSelection) return;
    final composing = isComposingActive;
    if (composing) {
      newSelection = _commitCompositionAndRemapSelection(newSelection);
    }
    _flushBuffer();
    _pendingSelectionReplacement = null;
    final end = length;
    _selection = newSelection.copyWith(
      baseOffset: newSelection.baseOffset.clamp(0, end),
      extentOffset: newSelection.extentOffset.clamp(0, end),
    );
    _change._selection = true;
    _isTyping = false;
    _imeProjectionDirty = true;
    if (composing) {
      _view?.resetInput();
    } else {
      _syncToConnection();
    }
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

  void addEditListener(DocumentEditListener listener) {
    _editListeners.add(listener);
  }

  void removeEditListener(DocumentEditListener listener) {
    _editListeners.remove(listener);
  }

  /// Notifies all registered listeners of a state change.
  void notifyListeners() {
    if (_isDisposed) return;
    for (final listener in _listeners) {
      listener();
    }
  }

  @protected
  @override
  void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
    if (readOnly) return;

    if (_editSupersededWindow(textEditingDeltas)) {
      _retypeSupersededInsertions(textEditingDeltas);
      return;
    }
    if (textEditingDeltas.isEmpty) {
      if (_imeComposition != null) _endCompositionAsShown();
      return;
    }
    _supersededPlatformTexts.clear();

    final selectionBefore = _selection;
    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    final involvesComposition =
        _imeComposition != null ||
        textEditingDeltas.any(
          (d) => _changesText(d) && _isComposing(d.composing),
        );
    var deltas = textEditingDeltas;
    if (involvesComposition) {
      // Deltas over a selection the platform still shows are not typing.
      final mirrorsDocument =
          _imeMirrorDeletion == null &&
          (_imeComposition != null || _selectionBeingReplaced() == null);
      final typing = mirrorsDocument ? _typingAfterComposition(deltas) : -1;
      if (typing < 0) {
        _imeShiftedWindow = null;
        _processCompositionDeltas(deltas);
        return;
      }
      _endCompositionBefore(deltas.sublist(0, typing), deltas[typing]);
      deltas = deltas.sublist(typing);
    }

    _ensureImeProjection();
    var windowStart = _imeProjectionStartOffset;
    var window = _buildCurrentImeEditingValue();
    if (_shiftedWindowEdited(deltas, window) case (
      :final start,
      :final caret,
    )) {
      windowStart = start;
      window = window.copyWith(
        selection: TextSelection.collapsed(offset: caret),
      );
    }
    _imeShiftedWindow = null;
    bool typingDetected = false, removedSelection = false;
    var removalUndoGroup = deltas.any(_changesText)
        ? _joinSelectionRemoval()
        : null;
    TextEditingValue? platform;

    _suppressImeSync = true;
    for (final delta in deltas) {
      final windowCaret = window.selection.extentOffset;
      int toGlobal(int local) =>
          _windowOffsetToGlobal(windowStart, delta.oldText, local);
      final removed = _changesText(delta) ? _removedRange(delta) : null;
      if (removed != null) {
        final windowEnd = toGlobal(delta.oldText.length);
        final range = TextRange(
          start: toGlobal(removed.start),
          end: toGlobal(removed.end),
        );
        final cutShort = _selectionCutShortByWindow(
          windowStart,
          windowEnd,
          range,
        );
        final pending = _pendingSelectionReplacement;
        final removesCollapsedSelection =
            _selection.isCollapsed &&
            pending != null &&
            (cutShort != null ||
                range.start == pending.start && range.end == pending.end);
        // Undoing the removal then gives the selection back.
        if (removesCollapsedSelection) {
          _selection = pending;
          removedSelection = true;
        }
        if (cutShort != null) {
          removalUndoGroup ??= _undoController?.beginCompoundOperation();
          if (delta is TextEditingDeltaDeletion &&
              !removesCollapsedSelection &&
              !_selection.isCollapsed) {
            unawaited(
              _widenPlatformCut(
                delta.textDeleted,
                _documentSubstring(cutShort.start, cutShort.end),
              ),
            );
          }
          windowStart = _deleteSelectionOutsideWindow(
            cutShort,
            windowStart,
            windowEnd,
          );
        }
      }
      window = delta.apply(window);
      final selectionAfter = _windowSelectionToGlobal(
        windowStart,
        window.text,
        delta.selection,
      );

      if (!_changesText(delta)) {
        final echo = _sentSelections.indexOf(delta.selection);
        if (echo > 0) _sentSelections.removeRange(0, echo);
        final isEcho = echo >= 0;
        if (!isEcho) {
          final selectsWindow =
              window.text.isNotEmpty &&
              delta.selection.start == 0 &&
              delta.selection.end >= window.text.length &&
              (selectionAfter.start > 0 || selectionAfter.end < length);
          final next = selectsWindow
              ? TextSelection(baseOffset: 0, extentOffset: length)
              : selectionAfter;
          if (next != _selection) _change._selection = true;
          _selection = next;
          _sentSelections.clear();
        }
        if (!isEcho || delta is! TextEditingDeltaNonTextUpdate) {
          platform = window;
        }
        _imeSelectionNeedsResync = false;
        continue;
      }

      _sentSelections.clear();
      platform = window;

      if (delta is TextEditingDeltaInsertion) {
        removedSelection = false;
        final mappedInsertionOffset = toGlobal(delta.insertionOffset);
        final staleMappedOffset =
            mappedInsertionOffset < _selection.extentOffset;
        bool useCurrentSelection =
            _imeSelectionNeedsResync ||
            delta.insertionOffset != windowCaret ||
            staleMappedOffset;
        if (isBufferActive) useCurrentSelection = true;
        _imeSelectionNeedsResync = false;

        if (delta.textInserted == '\n' &&
            (suggestionsNotifier.value?.isNotEmpty ?? false) &&
            selectedSuggestionNotifier.value != null) {
          acceptSuggestion();
          continue;
        }

        if (_startsWord(delta.textInserted)) {
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
            start: toGlobal(delta.deletedRange.start),
            end: toGlobal(delta.deletedRange.end),
          ),
          selectionAfter,
        );
      } else if (delta is TextEditingDeltaReplacement) {
        if (delta.replacementText.isNotEmpty &&
            _startsWord(delta.replacementText)) {
          typingDetected = true;
        }
        _handleReplacement(
          TextRange(
            start: toGlobal(delta.replacedRange.start),
            end: toGlobal(delta.replacedRange.end),
          ),
          delta.replacementText,
          selectionAfter,
        );
      }
    }
    removalUndoGroup?.end();
    _selectionRemoval = removedSelection
        ? (version: _currentVersion, at: DateTime.now())
        : null;
    _suppressImeSync = false;

    _isTyping = typingDetected;

    _imeProjectionDirty = true;

    _maybeAcquireFocusForInput();

    _keepPendingSelectionAtRest(
      selectionBefore,
      windowStart,
      _windowOffsetToGlobal(windowStart, window.text, window.text.length),
    );
    if (platform != null) _replacePlatformWindow(platform, windowStart);

    notifyListeners();
  }

  bool get isBufferActive => _bufferLineIndex != null && _bufferDirty;

  /// Whether an IME composition (e.g. CJK pinyin/kana) is currently in
  /// progress. While true, the platform input method owns the keyboard, so
  /// hardware-key handlers must defer to it and external selection changes
  /// must finalize the composition first.
  bool get isComposingActive => _imeComposition != null;

  /// Commits a composition in progress where it is shown, so positions read
  /// from the layout afterwards line up with the document.
  void commitComposition() {
    if (!isComposingActive) return;
    _commitCompositionInPlace();
    _imeProjectionDirty = true;
    _view?.resetInput();
    notifyListeners();
  }

  /// [later] puts the notification off for a caller inside a build or dispose.
  void commitCompositionOnClose({bool later = false}) {
    if (!isComposingActive) return;
    _commitCompositionInPlace();
    _imeProjectionDirty = true;
    later ? scheduleMicrotask(notifyListeners) : notifyListeners();
  }

  int? get bufferLineIndex => _bufferLineIndex;
  String? get bufferLineText => _bufferLineText;
  int get contentVersion => _currentVersion;

  int get bufferCursorColumn {
    if (!isBufferActive) return 0;
    return _selection.extentOffset - _bufferLineRopeStart;
  }

  /// The active IME composition overlay, or null when no composition is in
  /// progress. Read by the renderer to paint the composing string.
  ImeComposition? get imeComposition => _imeComposition;

  @protected
  @override
  void connectionClosed() {
    if (connection != null && connection!.attached) {
      connection?.connectionClosedReceived();
      connection = null;
      focusNode?.unfocus();
    }
    commitCompositionOnClose();
  }

  void _dropImeComposition() {
    _imeComposition = null;
    _pendingSelectionReplacement = null;
    _imeMirrorDeletion = null;
    _rawTypedComposingText = '';
    _lastComposingText = '';
    _change._composition = true;
    _imeCompositionUndoGroup?.end();
    _imeCompositionUndoGroup = null;
  }

  @protected
  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  TextEditingValue get currentTextEditingValue {
    final value = _buildCurrentImeEditingValue();
    _rememberSentSelection(value.selection);
    return value;
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

    final selectionBefore = _selection;
    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    _ensureImeProjection();
    final involvesComposition =
        _imeComposition != null ||
        (_isComposing(value.composing) &&
            _withoutCarriageReturns(value).text != _imeProjectionText);
    if (involvesComposition) {
      _processCompositionValue(value);
      return;
    }

    _suppressImeSync = true;
    var windowStart = _imeProjectionStartOffset;
    final next = _withoutCarriageReturns(value);

    final currentText = _imeProjectionText;
    final nextText = next.text;
    if (_changedSpan(currentText, nextText) case final change?) {
      final windowEnd = windowStart + currentText.runes.length;
      final cutShort = change.start < change.end
          ? _selectionCutShortByWindow(
              windowStart,
              windowEnd,
              TextRange(
                start: windowStart + currentText.toScalarOffset(change.start),
                end: windowStart + currentText.toScalarOffset(change.end),
              ),
            )
          : null;
      CompoundOperationHandle? removalUndoGroup;
      if (cutShort != null) {
        removalUndoGroup = _undoController?.beginCompoundOperation();
        windowStart = _deleteSelectionOutsideWindow(
          cutShort,
          windowStart,
          windowEnd,
        );
      }
      replaceRange(
        windowStart + currentText.toScalarOffset(change.start),
        windowStart + currentText.toScalarOffset(change.end),
        change.replacement,
      );
      removalUndoGroup?.end();
    }

    _selection = _windowSelectionToGlobal(
      windowStart,
      nextText,
      next.selection,
    );
    if (_selection != selectionBefore) _change._selection = true;
    _keepPendingSelectionAtRest(
      selectionBefore,
      windowStart,
      windowStart + nextText.runes.length,
    );
    _imeProjectionDirty = true;
    _suppressImeSync = false;
    _replacePlatformWindow(value, windowStart);
    _maybeAcquireFocusForInput();
    notifyListeners();
  }

  @protected
  @override
  bool onFocusReceived() {
    return true;
  }

  Offset? _floatingCursorStartPosition;

  @protected
  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    if (readOnly) return;

    switch (point.state) {
      case FloatingCursorDragState.Start:
        _floatingCursorStartPosition = _view?.caretOffset();
      case FloatingCursorDragState.Update:
        final start = _floatingCursorStartPosition;
        final moved = point.offset;
        if (start == null || moved == null) return;
        if (_view?.textOffsetAt(start + moved) case final offset?) {
          selection = TextSelection.collapsed(offset: offset);
        }
      case FloatingCursorDragState.End:
        _floatingCursorStartPosition = null;
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
    _listeners.clear();
    _editListeners.clear();
    connection?.close();
    setUndoController(null);
    suggestionsNotifier.dispose();
    selectedSuggestionNotifier.dispose();
    _rope.dispose();
  }
}

extension CodeForgeControllerNavigation on CodeForgeController {
  /// Moves the cursor one character to the left.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressLeftArrowKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    int newOffset;
    if (!isShiftPressed && selection.start != selection.end) {
      newOffset = selection.start;
    } else if (selection.extentOffset > 0) {
      newOffset = selection.extentOffset - 1;
    } else {
      newOffset = 0;
    }

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  void pressRightArrowKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    final int newOffset;
    if (!isShiftPressed && selection.start != selection.end) {
      newOffset = selection.end;
    } else {
      newOffset = min(selection.extentOffset + 1, length);
    }

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  /// Moves the caret to the start of the word before it, or over the line
  /// break when it is at a line start.
  void moveWordLeft({bool extend = false}) {
    final caret = selection.extentOffset;
    if (caret <= 0) return;

    final line = getLineAtOffset(caret);
    final lineStart = getLineStartOffset(line);
    if (caret == lineStart) {
      _moveCaret(caret - 1, extend: extend);
      return;
    }

    final before = getLineText(line).scalarSubstring(0, caret - lineStart);
    final lastWord = RegExp('[$wordCharClass]+|[^$wordCharClass\\s]+')
        .allMatches(before)
        .lastOrNull;
    _moveCaret(
      lineStart + before.toScalarOffset(lastWord?.start ?? 0),
      extend: extend,
    );
  }

  void moveWordRight({bool extend = false}) {
    final caret = selection.extentOffset;
    if (caret >= length) return;

    var line = getLineAtOffset(caret);
    final lineStart = getLineStartOffset(line);
    final lineText = getLineText(line);
    final column = lineText.toUtf16Offset(caret - lineStart);
    if (column >= lineText.length) {
      _moveCaret(caret + 1, extend: extend);
      return;
    }

    final rest = line + 1 < lineCount ? '$lineText\n' : lineText;
    final next = RegExp('[$wordCharClass]+|[^$wordCharClass\\s]+|\\s+')
        .allMatches(rest, column)
        .where((match) => match.start > column)
        .firstOrNull;
    if (next != null) {
      _moveCaret(
        lineStart + lineText.toScalarOffset(next.start),
        extend: extend,
      );
      return;
    }
    final nonSpace = RegExp(r'\S');
    while (++line < lineCount) {
      final text = getLineText(line);
      if (nonSpace.firstMatch(text) case final match?) {
        _moveCaret(
          getLineStartOffset(line) + text.toScalarOffset(match.start),
          extend: extend,
        );
        return;
      }
    }
    _moveCaret(length, extend: extend);
  }

  /// Moves the cursor up one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressUpArrowKey({bool isShiftPressed = false}) {
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (currentLine <= 0) {
      _moveCaret(0, extend: isShiftPressed);
      return;
    }

    var targetLine = currentLine - 1;
    while (targetLine > 0) {
      final hidden = _foldHiding(targetLine);
      if (hidden == null) break;
      targetLine = hidden.start;
    }

    final lineStart = getLineStartOffset(currentLine);
    final column = selection.extentOffset - lineStart;
    final prevLineStart = getLineStartOffset(targetLine);
    final prevLineText = getLineText(targetLine);
    final prevLineLength = prevLineText.runes.length;
    final newColumn = column.clamp(0, prevLineLength);
    final newOffset = (prevLineStart + newColumn).clamp(0, length);

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  /// Moves the cursor down one line, maintaining the column position.
  ///
  /// If [isShiftPressed] is true, extends the selection.
  void pressDownArrowKey({bool isShiftPressed = false}) {
    final currentLine = getLineAtOffset(selection.extentOffset);

    if (currentLine >= lineCount - 1) {
      _moveCaret(length, extend: isShiftPressed);
      return;
    }

    final foldAtCurrent = foldings[currentLine];
    var targetLine = foldAtCurrent != null && foldAtCurrent.isFolded
        ? foldAtCurrent.endIndex + 1
        : currentLine + 1;
    while (targetLine < lineCount) {
      final hidden = _foldHiding(targetLine);
      if (hidden == null) break;
      targetLine = hidden.end + 1;
    }

    if (targetLine >= lineCount) {
      final endOffset = length;
      _moveCaret(endOffset, extend: isShiftPressed);
      return;
    }

    final lineStart = getLineStartOffset(currentLine);
    final column = selection.extentOffset - lineStart;
    final nextLineStart = getLineStartOffset(targetLine);
    final nextLineText = getLineText(targetLine);
    final nextLineLength = nextLineText.runes.length;
    final newColumn = column.clamp(0, nextLineLength);
    final newOffset = (nextLineStart + newColumn).clamp(0, length);

    _moveCaret(newOffset, extend: isShiftPressed);
  }

  /// Moves the cursor to the beginning of the current line.
  ///
  /// If [isShiftPressed] is true, extends the selection to the line start.
  void pressHomeKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineStart = getLineStartOffset(currentLine);

    _moveCaret(lineStart, extend: isShiftPressed);
  }

  /// Moves the cursor to the end of the current line.
  ///
  /// If [isShiftPressed] is true, extends the selection to the line end.
  void pressEndKey({bool isShiftPressed = false}) {
    suggestionsNotifier.value = null;

    final currentLine = getLineAtOffset(selection.extentOffset);
    final lineText = getLineText(currentLine);
    final lineStart = getLineStartOffset(currentLine);
    final scalarLength = lineText.runes.length;
    final lineEnd = lineStart + scalarLength;

    _moveCaret(lineEnd, extend: isShiftPressed);
  }

  /// Moves the cursor to the beginning of the document.
  ///
  /// If [isShiftPressed] is true, extends the selection to the document start.
  void pressDocumentHomeKey({bool isShiftPressed = false}) {
    _moveCaret(0, extend: isShiftPressed);
  }

  /// Moves the cursor to the end of the document.
  ///
  /// If [isShiftPressed] is true, extends the selection to the document end.
  void pressDocumentEndKey({bool isShiftPressed = false}) {
    final endOffset = length;
    _moveCaret(endOffset, extend: isShiftPressed);
  }

  void _moveCaret(int target, {required bool extend}) {
    final offset = _outOfFold(target, forward: target > selection.extentOffset);
    selection = extend
        ? TextSelection(baseOffset: selection.baseOffset, extentOffset: offset)
        : TextSelection.collapsed(offset: offset);
  }

  /// [offset], or where the caret lands instead when a fold hides its line:
  /// past the fold going [forward], else on the line that heads the fold.
  int _outOfFold(int offset, {required bool forward}) {
    final hidden = _foldHiding(getLineAtOffset(offset.clamp(0, length)));
    if (hidden == null) return offset;
    return forward && hidden.end + 1 < lineCount
        ? getLineStartOffset(hidden.end + 1)
        : _lineEndOffset(hidden.start);
  }

  /// Selects all text in the editor.
  void selectAll() {
    selection = TextSelection(baseOffset: 0, extentOffset: length);
  }
}

extension CodeForgeControllerEditing on CodeForgeController {
  /// Moves the current line up by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the top or if the controller is read-only.
  void moveLineUp() {
    if (readOnly) return;
    final selection = this.selection;
    final (first, last) = _selectedLines(selection);
    if (first == 0) return;

    final prevLine = getLineText(first - 1);
    replaceRange(
      getLineStartOffset(first - 1),
      _lineEndOffset(last),
      '${_linesText(first, last)}\n$prevLine',
    );

    final offsetDelta = prevLine.runes.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset - offsetDelta,
      extentOffset: selection.extentOffset - offsetDelta,
    );
    this.selection = newSelection;
  }

  /// Moves the current line down by one line.
  ///
  /// If the selection spans multiple lines, all selected lines are moved.
  /// The selection is adjusted accordingly after the move.
  /// Does nothing if the line is already at the bottom or if the controller is read-only.
  void moveLineDown() {
    if (readOnly) return;
    final selection = this.selection;
    final (first, last) = _selectedLines(selection);
    if (last + 1 >= lineCount) return;

    final nextLine = getLineText(last + 1);
    replaceRange(
      getLineStartOffset(first),
      _lineEndOffset(last + 1),
      '$nextLine\n${_linesText(first, last)}',
    );

    final offsetDelta = nextLine.runes.length + 1;
    final newSelection = TextSelection(
      baseOffset: selection.baseOffset + offsetDelta,
      extentOffset: selection.extentOffset + offsetDelta,
    );
    this.selection = newSelection;
  }

  /// Duplicates the current line or selected text.
  ///
  /// If text is selected, duplicates the selected text.
  /// If no selection, duplicates the line at the cursor position.
  /// The cursor is moved to the end of the duplicated content.
  /// Does nothing if the controller is read-only.
  void duplicateLine() {
    if (readOnly) return;
    final selection = this.selection;

    if (selection.start != selection.end) {
      final selectedText = _documentSubstring(selection.start, selection.end);
      replaceRange(selection.end, selection.end, selectedText);
      this.selection = TextSelection.collapsed(
        offset: selection.end + selection.end - selection.start,
      );
    } else {
      final line = getLineAtOffset(selection.extentOffset);
      final lineText = getLineText(line);
      final lineEnd = _lineEndOffset(line);

      replaceRange(lineEnd, lineEnd, '\n$lineText');
      this.selection = TextSelection.collapsed(offset: lineEnd + 1);
    }
  }

  /// Copies the selection, or the caret's whole line when nothing is selected.
  Future<void> copy() async {
    final sel = selection;
    if (sel.isCollapsed) {
      await _copyLine(getLineAtOffset(sel.start));
      return;
    }
    await _writeClipboard(_documentSubstring(sel.start, sel.end));
  }

  /// Leaves the text when the clipboard refuses it, or when the document, the
  /// selection or read-only changes before the clipboard has it.
  Future<void> cut() async {
    if (readOnly) return;
    final sel = selection;
    final version = _currentVersion;
    bool stillCuts() =>
        !_isDisposed &&
        !readOnly &&
        version == _currentVersion &&
        sel == selection;
    if (!sel.isCollapsed) {
      final text = _documentSubstring(sel.start, sel.end);
      if (!await _writeClipboard(text) || !stillCuts()) return;
      _replaceRange(sel.start, sel.end, '', deleted: text);
      return;
    }
    final line = getLineAtOffset(sel.start);
    if (!await _copyLine(line) || !stillCuts()) return;
    var start = getLineStartOffset(line);
    var end = length;
    if (line < lineCount - 1) {
      end = getLineStartOffset(line + 1);
    } else if (line > 0) {
      start--;
    }
    replaceRange(start, end, '');
    selection = TextSelection.collapsed(
      offset: getLineStartOffset(min(line, lineCount - 1)),
    );
  }

  Future<bool> _copyLine(int line) =>
      _writeClipboard('${getLineText(line)}\n', wholeLine: true);

  Future<bool> _writeClipboard(String text, {bool wholeLine = false}) async {
    if (!await setClipboardText(text)) {
      onClipboardWriteFailed?.call();
      return false;
    }
    _copiedLine = wholeLine ? text : null;
    return true;
  }

  Future<String?> _readClipboard() async {
    try {
      return await getClipboardText();
    } on Exception {
      return null;
    }
  }

  /// Pastes over the selection; a whole line from [copy] goes above the caret's.
  Future<void> paste() async {
    if (readOnly) return;
    final clip = await _readClipboard();
    if (clip == null || clip.isEmpty || _isDisposed || readOnly) return;
    final pasted = CodeForgeController.normalizeLineBreaks(clip);
    final sel = selection;
    if (sel.isCollapsed && pasted == _copiedLine) {
      final lineStart = getLineStartOffset(getLineAtOffset(sel.start));
      _replaceRange(lineStart, lineStart, pasted);
      selection = TextSelection.collapsed(
        offset: sel.start + pasted.runes.length,
      );
      return;
    }
    _replaceRange(sel.start, sel.end, pasted);
  }

  (int, int) _selectedLines(TextSelection selection) =>
      (getLineAtOffset(selection.start), getLineAtOffset(selection.end));

  int _lineEndOffset(int line) =>
      line + 1 < lineCount ? getLineStartOffset(line + 1) - 1 : length;

  String _linesText(int first, int last) =>
      _documentSubstring(getLineStartOffset(first), _lineEndOffset(last));

  void insertAtCurrentCursor(String text) {
    if (readOnly) return;
    final caret = selection.extentOffset;
    replaceRange(caret, caret, text);
  }

  /// Remove the selection or last char if the selection is empty (backspace key)
  void backspace() {
    final sel = _selection;
    if (sel.isCollapsed) {
      _deleteRange(sel.start - 1, sel.start);
    } else {
      _deleteRange(sel.start, sel.end);
    }
  }

  /// Remove the selection or the char at cursor position (delete key)
  void delete() {
    final sel = _selection;
    if (sel.isCollapsed) {
      _deleteRange(sel.start, sel.start + 1);
    } else {
      _deleteRange(sel.start, sel.end);
    }
  }

  void _deleteRange(int start, int end) {
    if (readOnly) return;
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    if (start < 0 || end > length) return;
    _edit(start, end, '', TextSelection.collapsed(offset: start));
    notifyListeners();
  }

  /// Replace a range of text with new text.
  void replaceRange(int start, int end, String replacement) {
    _replaceRange(
      start,
      end,
      CodeForgeController.normalizeLineBreaks(replacement),
    );
  }

  void _replaceRange(int start, int end, String normalized, {String? deleted}) {
    if (_undoController?.isUndoRedoInProgress ?? false) return;
    _closeCompletion();
    _editRope(start, end, normalized, null, deleted: deleted);
    notifyListeners();
  }

  /// Rewrites the document as [text] in one edit over only what differs.
  void replaceText(String text) {
    final dirty = _dirtyOverlay;
    final edit = _rope.diffText(
      text,
      dirtyStart: dirty.start,
      dirtyEnd: dirty.end,
      dirtyText: dirty.text,
    );
    if (edit == null) return;
    _replaceRange(edit.startScalar, edit.endScalar, edit.replacement);
  }

  void replaceAllMatches({
    required String pattern,
    required bool isRegex,
    required bool caseSensitive,
    required bool wholeWord,
    required String replacement,
  }) {
    final dirty = _dirtyOverlay;
    final edit = searchReplaceAllRope(
      rope: _rope.core,
      dirtyStart: BigInt.from(dirty.start),
      dirtyEnd: BigInt.from(dirty.end),
      dirtyText: dirty.text,
      pattern: pattern,
      isRegex: isRegex,
      caseSensitive: caseSensitive,
      wholeWord: wholeWord,
      replacement: replacement,
    );
    if (edit == null) return;
    _replaceRange(edit.startScalar, edit.endScalar, edit.replacement);
  }

  void _closeCompletion() {
    _isTyping = false;
    suggestionsNotifier.value = null;
  }

  void indent() {
    if (readOnly) return;
    final selection = this.selection;
    if (selection.baseOffset != selection.extentOffset) {
      final (first, last) = _selectedLines(selection);
      final lines = getLinesRange(first, last + 1);
      final newSelection = _withEnds(
        selection,
        selection.start + tabSize,
        selection.end + tabSize * lines.length,
      );

      replaceRange(
        getLineStartOffset(first),
        _lineEndOffset(last),
        [for (final line in lines) '$tabSpace$line'].join('\n'),
      );
      this.selection = newSelection;
    } else {
      insertAtCurrentCursor(tabSpace);
    }
  }

  void unindent() {
    if (readOnly) return;
    final selection = this.selection;
    final (first, last) = _selectedLines(selection);
    final lines = getLinesRange(first, last + 1);
    final removed = [for (final line in lines) _outdentWidth(line)];
    final lineStart = getLineStartOffset(first);
    final TextSelection newSelection;
    if (selection.baseOffset != selection.extentOffset) {
      final removedChars = removed.fold(0, (sum, count) => sum + count);
      final lastLineStart =
          getLineStartOffset(last) - (removedChars - removed.last);
      newSelection = _withEnds(
        selection,
        max(selection.start - removed.first, lineStart),
        max(selection.end - removedChars, lastLineStart),
      );
    } else {
      newSelection = TextSelection.collapsed(
        offset: max(selection.start - removed.first, lineStart),
      );
    }

    replaceRange(
      lineStart,
      _lineEndOffset(last),
      [
        for (final (index, line) in lines.indexed)
          line.substring(removed[index]),
      ].join('\n'),
    );
    this.selection = newSelection;
  }

  int _outdentWidth(String line) => line.startsWith(tabSpace)
      ? tabSpace.length
      : line.startsWith('\t')
      ? 1
      : RegExp(r'^ +').stringMatch(line)?.length ?? 0;

  TextSelection _withEnds(TextSelection selection, int start, int end) =>
      selection.baseOffset <= selection.extentOffset
      ? TextSelection(baseOffset: start, extentOffset: end)
      : TextSelection(baseOffset: end, extentOffset: start);

  /// Also deletes the spaces between the word and the caret.
  void deleteWordBackward() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final caret = selection.extentOffset;
    if (caret <= 0) return;
    final line = getLineAtOffset(caret);
    final lineStart = getLineStartOffset(line);
    if (caret == lineStart) {
      replaceRange(caret - 1, caret, '');
      return;
    }
    final before = getLineText(line).scalarSubstring(0, caret - lineStart);
    final match = RegExp('([$wordCharClass]+|[^$wordCharClass\\s]+)\\s*\$')
        .firstMatch(before);
    replaceRange(
      match != null
          ? lineStart + before.toScalarOffset(match.start)
          : caret - 1,
      caret,
      '',
    );
  }

  void deleteWordForward() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final caret = selection.extentOffset;
    if (caret >= length) return;
    final word = RegExp('^\\s*([$wordCharClass]+|[^$wordCharClass\\s]+)');
    var line = getLineAtOffset(caret);
    var lineStart = getLineStartOffset(line);
    var text = getLineText(line).scalarSubstring(caret - lineStart);
    lineStart = caret;
    while (true) {
      if (word.firstMatch(text) case final match?) {
        replaceRange(caret, lineStart + text.toScalarOffset(match.end), '');
        return;
      }
      if (++line >= lineCount) break;
      lineStart = getLineStartOffset(line);
      text = getLineText(line);
    }
    replaceRange(caret, length, '');
  }

  /// At a line start, joins the line with the previous one.
  void deleteToLineStart() {
    if (readOnly) return;
    final selection = this.selection;
    if (!selection.isCollapsed) {
      replaceRange(selection.start, selection.end, '');
      return;
    }
    final caret = selection.extentOffset;
    if (caret <= 0) return;
    final lineStart = getLineStartOffset(getLineAtOffset(caret));
    replaceRange(caret == lineStart ? caret - 1 : lineStart, caret, '');
  }

  String get selectedText {
    final selection = this.selection;
    if (selection.isCollapsed) return '';
    return _documentSubstring(selection.start, selection.end);
  }

  void toggleLineComment() {
    final prefix = lineCommentPrefix;
    if (readOnly || prefix == null) return;
    final selection = this.selection;
    var (first, last) = _selectedLines(selection);
    if (!selection.isCollapsed &&
        last > first &&
        selection.end == getLineStartOffset(last)) {
      last--;
    }
    final lines = getLinesRange(first, last + 1);
    final marker = prefix.trimRight();
    final filled = [
      for (final line in lines)
        if (line.trim().isNotEmpty) line,
    ];
    final uncomment =
        filled.isNotEmpty &&
        filled.every((line) => line.trimLeft().startsWith(marker));
    final edits = <({int column, int removed, int inserted})>[];
    final result = <String>[];
    for (final line in lines) {
      final indent = line.length - line.trimLeft().length;
      if (filled.isNotEmpty && line.trim().isEmpty) {
        result.add(line);
        edits.add((column: 0, removed: 0, inserted: 0));
      } else if (uncomment) {
        final rest = line.substring(indent + marker.length);
        final removed = marker.length + (rest.startsWith(' ') ? 1 : 0);
        result.add(
          line.substring(0, indent) + line.substring(indent + removed),
        );
        edits.add((column: indent, removed: removed, inserted: 0));
      } else {
        result.add(
          '${line.substring(0, indent)}$prefix${line.substring(indent)}',
        );
        edits.add((column: indent, removed: 0, inserted: prefix.length));
      }
    }
    final starts = [for (var i = first; i <= last; i++) getLineStartOffset(i)];
    final blockEnd = _lineEndOffset(last);
    int shifted(int offset, bool sticky) {
      if (offset < starts.first) return offset;
      var shift = 0;
      for (final (index, edit) in edits.indexed) {
        final lineEnd = index + 1 < starts.length
            ? starts[index + 1] - 1
            : blockEnd;
        if (offset > lineEnd) {
          shift += edit.inserted - edit.removed;
          continue;
        }
        final at = starts[index] + edit.column;
        if (offset < at || (offset == at && !sticky)) return offset + shift;
        return offset + shift + edit.inserted - min(edit.removed, offset - at);
      }
      return offset + shift;
    }

    final collapsed = selection.isCollapsed;
    final base = shifted(
      selection.baseOffset,
      collapsed || selection.baseOffset > selection.extentOffset,
    );
    final extent = shifted(
      selection.extentOffset,
      collapsed || selection.extentOffset > selection.baseOffset,
    );
    replaceRange(starts.first, blockEnd, result.join('\n'));
    this.selection = TextSelection(baseOffset: base, extentOffset: extent);
  }

  void toggleBlockComment() {
    if (readOnly || !blockComments) return;
    final selection = this.selection;
    if (selection.isCollapsed) {
      final caret = selection.extentOffset;
      final line = getLineAtOffset(caret);
      final lineStart = getLineStartOffset(line);
      final text = getLineText(line);
      final unwrapped = _unwrapBlockComment(text);
      if (unwrapped == null) {
        replaceRange(caret, caret, '/*  */');
        this.selection = TextSelection.collapsed(offset: caret + 3);
        return;
      }
      replaceRange(lineStart, lineStart + text.runes.length, unwrapped.text);
      this.selection = TextSelection.collapsed(
        offset: (caret - unwrapped.leading).clamp(
          lineStart,
          lineStart + unwrapped.text.runes.length,
        ),
      );
      return;
    }
    final start = selection.start;
    final text = _documentSubstring(start, selection.end);
    final replacement = _unwrapBlockComment(text)?.text ?? '/* $text */';
    replaceRange(start, selection.end, replacement);
    this.selection = _withEnds(
      selection,
      start,
      start + replacement.runes.length,
    );
  }

  ({String text, int leading})? _unwrapBlockComment(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 4 ||
        !trimmed.startsWith('/*') ||
        !trimmed.endsWith('*/')) {
      return null;
    }
    final open = text.indexOf('/*');
    final close = text.lastIndexOf('*/');
    if (close < open + 2) return null;
    final markerLength = close > open + 2 && text.startsWith('/**', open)
        ? 3
        : 2;
    var innerStart = open + markerLength;
    if (innerStart < close && text[innerStart] == ' ') innerStart++;
    var innerEnd = close;
    if (innerEnd > innerStart && text[innerEnd - 1] == ' ') innerEnd--;
    return (
      text:
          text.substring(0, open) +
          text.substring(innerStart, innerEnd) +
          text.substring(close + 2),
      leading: innerStart - open,
    );
  }
}

extension CodeForgeControllerFolding on CodeForgeController {
  void _rebuildFoldSortedCache() {
    _folded = [
      for (final fold in _foldings.values)
        if (fold != null && fold.isFolded)
          (start: fold.startIndex, end: fold.endIndex),
    ]..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Toggles the fold state at the specified line number.
  ///
  /// [lineNumber] is zero-indexed (0 for the first line). A line that starts
  /// no fold region is ignored.
  ///
  /// Throws [StateError] if no editor is mounted on this controller.
  ///
  /// Example:
  /// ```dart
  /// controller.toggleFold(5); // Toggle fold at line 6
  /// ```
  void toggleFold(int lineNumber) => _mountedView.toggleFold(lineNumber);

  CodeForgeView get _mountedView =>
      _view ?? (throw StateError('No editor is mounted on this controller'));

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
    final view = _mountedView;
    if (line < 0 || line >= lineCount) {
      throw RangeError.range(line, 0, lineCount - 1, 'line');
    }
    view.scrollToLine(line);
  }

  /// Check whether the corresponding [lineIndex] is inside a folded code block or not.
  bool isLineInFoldedRegion(int lineIndex) => _foldHiding(lineIndex) != null;

  /// if the corresponding line is in a foldable region, this function returns the first line in that foldable block.
  int? getFoldStartForLine(int lineIndex) => _foldHiding(lineIndex)?.start;

  ({int start, int end})? _foldHiding(int lineIndex) {
    final folded = _folded;
    int lo = 0, hi = folded.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (folded[mid].start < lineIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    for (int i = hi; i >= 0; i--) {
      final fold = folded[i];
      if (fold.end >= lineIndex) return fold;
      if (lineIndex - fold.start > 100000) break;
    }
    return null;
  }
}

/// Lines [startIndex] + 1 to [endIndex] hide while [isFolded].
class FoldRange {
  final int startIndex;
  final int endIndex;
  bool isFolded = false;

  /// The nested folds that folding this one opened, to refold when it unfolds.
  List<FoldRange> originallyFoldedChildren = [];

  FoldRange(this.startIndex, this.endIndex);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoldRange &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode => startIndex.hashCode ^ endIndex.hashCode;
}

/// [column] counts UTF-16 code units into [lineText].
class CodeForgeCompletionRequest {
  final List<String> lines;
  final int version;

  /// Counted as [CodeForgeController.lineEdit] counts; null once forgotten.
  final ({int line, int removed, int inserted})? Function(int since)
  linesEditedSince;

  final int line;
  final String lineText;
  final int column;
  final Set<String> documentWords;

  const CodeForgeCompletionRequest({
    required this.lines,
    required this.version,
    this.linesEditedSince = _unknownEdits,
    required this.line,
    required this.lineText,
    required this.column,
    this.documentWords = const {},
  });

  String get textBeforeCaret => lineText.substring(0, column);

  static ({int line, int removed, int inserted})? _unknownEdits(int since) =>
      null;
}

/// Accepting a suggestion replaces [prefix], the text before the caret.
class CodeForgeCompletion {
  final String prefix;
  final List<CodeForgeSuggestion> suggestions;

  const CodeForgeCompletion({required this.prefix, required this.suggestions});
}

/// One entry of the completion popup, as [CodeForge.suggestionPopupBuilder]
/// sees it.
class CodeForgeSuggestion {
  final String label;

  final String? detail;
  final CodeForgeSnippet? snippet;

  const CodeForgeSuggestion({required this.label, this.detail, this.snippet});
}

typedef CodeForgeCompletionSource = CodeForgeCompletion? Function(
  CodeForgeCompletionRequest request,
);

extension CodeForgeControllerCompletion on CodeForgeController {
  /// Inserts the suggestion at [index], or the highlighted one, in place of
  /// the prefix it was matched against and closes the popup.
  void acceptSuggestion([int? index]) {
    final suggestions = suggestionsNotifier.value;
    if (suggestions == null || suggestions.isEmpty) return;
    final selected = (index ?? selectedSuggestionNotifier.value ?? 0).clamp(
      0,
      suggestions.length - 1,
    );
    final suggestion = suggestions[selected];
    commitComposition();
    final end = selection.extentOffset;
    final lineStart = getLineStartOffset(getLineAtOffset(end));
    final start = _completionStart.clamp(lineStart, end);
    if (suggestion.snippet case final snippet?) {
      insertSnippet(snippet, start: start);
    } else {
      replaceRange(start, end, suggestion.label);
      _isTyping = false;
    }
    suggestionsNotifier.value = null;
  }

  CodeForgeCompletion? _complete() {
    final current = selection;
    if (!current.isCollapsed) return null;
    final offset = current.extentOffset;
    final source = completionSource;
    if (source == null) {
      final prefix = getCurrentWordPrefixAt(offset);
      return CodeForgeCompletion(
        prefix: prefix,
        suggestions: _wordSuggestionsFor(prefix),
      );
    }
    final line = getLineAtOffset(offset);
    final lineText = getLineText(line);
    final version = _currentVersion;
    return source(
      CodeForgeCompletionRequest(
        lines: _DocumentLines(this),
        version: version,
        linesEditedSince: (since) => _linesEditedBetween(since, version),
        line: line,
        lineText: lineText,
        column: lineText.toUtf16Offset(offset - getLineStartOffset(line)),
        documentWords: enableLocalSuggestions ? _wordCache : const {},
      ),
    );
  }

  void _showCompletion(CodeForgeCompletion? completion) {
    if (completion == null || completion.suggestions.isEmpty) {
      suggestionsNotifier.value = null;
      return;
    }
    _completionStart = selection.extentOffset - completion.prefix.runes.length;
    suggestionsNotifier.value = completion.suggestions;
  }

  /// Moves the highlight [delta] entries, wrapping around the list.
  void moveSuggestionSelection(int delta) {
    final count = suggestionsNotifier.value?.length ?? 0;
    if (count == 0) return;
    final current = selectedSuggestionNotifier.value;
    selectedSuggestionNotifier.value = current == null
        ? (delta > 0 ? 0 : count - 1)
        : (current + delta) % count;
  }

  String getCurrentWordPrefixAt(int offset) {
    final safeOffset = offset.clamp(0, length);
    if (safeOffset == 0) return '';

    final lineIndex = getLineAtOffset(safeOffset);
    final lineStart = getLineStartOffset(lineIndex);
    final lineText = getLineText(lineIndex);

    final col = lineText.toUtf16Offset(safeOffset - lineStart);
    if (col <= 0) return '';

    int i = col - 1;
    while (i >= 0) {
      final code = lineText.codeUnitAt(i);
      if (!isWordChar(code)) break;
      i--;
    }

    final start = i + 1;
    if (start >= col) return '';
    final firstCode = lineText.codeUnitAt(start);
    if (!isWordStartChar(firstCode)) return '';
    return lineText.substring(start, col);
  }

  bool _startsWord(String s) =>
      s.isNotEmpty && isWordStartChar(s.codeUnitAt(0)) && !s.contains('\n');

  List<CodeForgeSuggestion> _wordSuggestionsFor(String prefix) {
    if (prefix.isEmpty || !enableLocalSuggestions) return const [];
    final words =
        [
          for (final word in _wordCache)
            if (word != prefix && word.startsWith(prefix)) word,
        ]..sort(
          (a, b) => a.length != b.length ? a.length - b.length : a.compareTo(b),
        );
    return [for (final word in words) CodeForgeSuggestion(label: word)];
  }

  Future<Set<String>> _extractWords() async {
    return (await wordsExtract(rope: _rope.core)).toSet();
  }
}

class _DocumentLines extends ListBase<String> {
  static const _blockSize = 256;

  final CodeForgeController _controller;
  final int _length;
  final Map<int, List<String>> _blocks = {};

  _DocumentLines(this._controller) : _length = _controller.lineCount;

  @override
  int get length => _length;

  @override
  set length(int value) => throw UnsupportedError('The lines are read-only');

  @override
  String operator [](int index) {
    RangeError.checkValidIndex(index, this);
    final block = index ~/ _blockSize;
    final start = block * _blockSize;
    final lines = _blocks[block] ??= _controller.getLinesRange(
      start,
      min(start + _blockSize, _length),
    );
    return lines[index - start];
  }

  @override
  void operator []=(int index, String value) =>
      throw UnsupportedError('The lines are read-only');
}

/// Text a suggestion inserts with Tab stops: `$1`, `${1:default}` and `$0`,
/// without nesting or mirrors. A tab is one indent level, and each later line
/// gains the indentation of the first.
class CodeForgeSnippet {
  final String body;

  const CodeForgeSnippet(this.body);
}

extension CodeForgeControllerSnippet on CodeForgeController {
  bool get isSnippetActive => _snippetStops != null;

  /// Replaces from [start] to the caret, or else the selection or the word
  /// before a collapsed caret.
  void insertSnippet(CodeForgeSnippet snippet, {int? start}) {
    if (readOnly) return;
    commitComposition();
    _flushBuffer();
    final current = selection;
    final end = current.end;
    final from =
        start ??
        (current.isCollapsed
            ? end - getCurrentWordPrefixAt(end).runes.length
            : current.start);
    final lineText = getLineText(getLineAtOffset(from));
    final expanded = _SnippetExpansion(
      snippet.body,
      RegExp(r'^[ \t]*').stringMatch(lineText)!,
      tabSpace,
    );
    replaceRange(from, end, expanded.text);
    _isTyping = false;
    final stops = [
      for (final stop in expanded.stops)
        TextRange(start: from + stop.start, end: from + stop.end),
    ];
    _snippetStops = stops.length > 1 ? stops : null;
    _snippetStopIndex = 0;
    _selectSnippetStop(stops.first);
  }

  /// False, ending the snippet, once the selection has left the current stop.
  bool nextSnippetStop() => _moveSnippetStop(1);

  bool previousSnippetStop() => _moveSnippetStop(-1);

  void endSnippet() => _snippetStops = null;

  bool _moveSnippetStop(int step) {
    final stops = _snippetStops;
    if (stops == null) return false;
    final active = stops[_snippetStopIndex];
    if (selection.start < active.start || selection.end > active.end) {
      _snippetStops = null;
      return false;
    }
    _snippetStopIndex = (_snippetStopIndex + step).clamp(0, stops.length - 1);
    if (_snippetStopIndex == stops.length - 1) _snippetStops = null;
    _selectSnippetStop(stops[_snippetStopIndex]);
    return true;
  }

  void _selectSnippetStop(TextRange stop) {
    selection = TextSelection(baseOffset: stop.start, extentOffset: stop.end);
  }

  /// An edit outside the current stop ends the snippet.
  void _trackSnippetEdit(int offset, int removed, int added) {
    final stops = _snippetStops;
    if (stops == null) return;
    final active = stops[_snippetStopIndex];
    if (offset < active.start || offset + removed > active.end) {
      _snippetStops = null;
      return;
    }
    final delta = added - removed;
    _snippetStops = [
      for (var i = 0; i < stops.length; i++)
        if (i == _snippetStopIndex)
          TextRange(start: active.start, end: active.end + delta)
        else if (stops[i].start >= active.end)
          TextRange(start: stops[i].start + delta, end: stops[i].end + delta)
        else
          stops[i],
    ];
  }
}

/// [stops] are scalar offsets in Tab order, the last where Tab leaves.
class _SnippetExpansion {
  _SnippetExpansion(this._body, this._indent, this._indentUnit) {
    _emitUntil(0);
    final numbers = _stops.keys.where((number) => number > 0).toList()..sort();
    stops = [
      for (final number in numbers) _stops[number]!,
      _stops[0] ?? TextRange.collapsed(_length),
    ];
  }

  final String _body, _indent, _indentUnit;
  final _out = StringBuffer();
  final _stops = <int, TextRange>{};
  var _length = 0;
  late final List<TextRange> stops;

  String get text => _out.toString();

  void _write(String text) {
    _out.write(text);
    _length += text.runes.length;
  }

  int _emitUntil(int from, {String? closer}) {
    var i = from;
    while (i < _body.length) {
      final char = _body[i];
      if (char == closer) return i;
      final stopEnd = char == r'$' ? _stopAt(i) : null;
      if (stopEnd != null) {
        i = stopEnd;
      } else if (char == r'\' &&
          i + 1 < _body.length &&
          r'$}\'.contains(_body[i + 1])) {
        _write(_body[i + 1]);
        i += 2;
      } else if (char == '\n') {
        _write('\n$_indent');
        i++;
      } else if (char == '\t') {
        _write(_indentUnit);
        i++;
      } else {
        final pair = char.codeUnitAt(0) & 0xFC00 == 0xD800;
        _write(_body.substring(i, pair ? i + 2 : i + 1));
        i += pair ? 2 : 1;
      }
    }
    return i;
  }

  int? _stopAt(int dollar) {
    final braced = dollar + 1 < _body.length && _body[dollar + 1] == '{';
    final digits = RegExp(r'\d+')
        .matchAsPrefix(_body, dollar + (braced ? 2 : 1));
    if (digits == null) return null;
    final number = int.parse(digits[0]!);
    final start = _length;
    int? end;
    if (!braced) {
      end = digits.end;
    } else if (digits.end < _body.length && _body[digits.end] == '}') {
      end = digits.end + 1;
    } else if (digits.end < _body.length && _body[digits.end] == ':') {
      end = _emitUntil(digits.end + 1, closer: '}') + 1;
    }
    if (end != null) {
      _stops.putIfAbsent(number, () => TextRange(start: start, end: _length));
    }
    return end;
  }
}

class BlockCommentStates {
  final List<bool> _starts = [false];

  void reset() => _starts.length = 1;

  void invalidateFrom(int line) {
    if (_starts.length > line + 1) _starts.length = max(1, line + 1);
  }

  bool startsInside(CodeForgeController controller, int line) {
    if (line <= 0) return false;
    while (_starts.length <= line) {
      final from = _starts.length - 1;
      final lines = controller.getLinesRange(from, min(line, from + 256));
      if (lines.isEmpty) return _starts.last;
      for (final text in lines) {
        _starts.add(stateAfter(text, _starts.last));
      }
    }
    return _starts[line];
  }

  static bool stateAfter(String line, bool inside) {
    final length = line.length;
    int? quote;
    var i = 0;
    while (i < length) {
      final unit = line.codeUnitAt(i);
      if (inside) {
        if (unit == 0x2A && i + 1 < length && line.codeUnitAt(i + 1) == 0x2F) {
          inside = false;
          i += 2;
        } else {
          i++;
        }
        continue;
      }
      if (quote != null) {
        if (unit == 0x5C) {
          i += 2;
          continue;
        }
        if (unit == quote) quote = null;
        i++;
        continue;
      }
      if (unit == 0x22 || unit == 0x27 || unit == 0x60) {
        quote = unit;
      } else if (unit == 0x2F && i + 1 < length) {
        final next = line.codeUnitAt(i + 1);
        if (next == 0x2F) return false;
        if (next == 0x2A) {
          inside = true;
          i += 2;
          continue;
        }
      }
      i++;
    }
    return inside;
  }
}
