import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a foldable code region in the editor.
///
/// A fold range defines a region of code that can be collapsed (folded) to hide
/// its contents. This is typically used for code blocks like functions, classes,
/// or control structures.
///
/// Fold ranges are automatically detected based on code structure (braces,
/// indentation) when folding is enabled in the editor.
///
/// Example:
/// ```dart
/// // A fold range from line 5 to line 10
/// final foldRange = FoldRange(5, 10);
/// foldRange.isFolded = true; // Collapse the region
/// ```
class FoldRange {
  /// The starting line index (zero-based) of the fold range.
  ///
  /// This is the line where the fold indicator appears in the gutter.
  final int startIndex;

  /// The ending line index (zero-based) of the fold range.
  ///
  /// When folded, all lines from `startIndex + 1` to `endIndex` are hidden.
  final int endIndex;

  /// Whether this fold range is currently collapsed.
  ///
  /// When true, the contents of this range are hidden in the editor.
  bool isFolded = false;

  /// Child fold ranges that were originally folded when this range was unfolded.
  ///
  /// Used to restore the fold state of nested ranges when toggling folds.
  List<FoldRange> originallyFoldedChildren = [];

  /// Creates a [FoldRange] with the specified start and end line indices.
  FoldRange(this.startIndex, this.endIndex);

  /// Adds a child fold range that was originally folded.
  ///
  /// Used internally to track nested fold states.
  void addOriginallyFoldedChild(FoldRange child) {
    if (!originallyFoldedChildren.contains(child)) {
      originallyFoldedChildren.add(child);
    }
  }

  /// Clears the list of originally folded children.
  void clearOriginallyFoldedChildren() {
    originallyFoldedChildren.clear();
  }

  /// Checks if a line is contained within this fold range.
  ///
  /// Returns true if [line] is strictly greater than [startIndex] and
  /// less than or equal to [endIndex].
  bool containsLine(int line) {
    return line > startIndex && line <= endIndex;
  }

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

/// Custom scroll physics that reverses horizontal drag direction for RTL mode on mobile.
class RTLAwareScrollPhysics extends ClampingScrollPhysics {
  final bool isRTL;
  final bool isMobile;

  const RTLAwareScrollPhysics({
    super.parent,
    required this.isRTL,
    required this.isMobile,
  });

  @override
  RTLAwareScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RTLAwareScrollPhysics(
      parent: buildParent(ancestor),
      isRTL: isRTL,
      isMobile: isMobile,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (isRTL && isMobile && position.axis == Axis.horizontal) {
      return super.applyPhysicsToUserOffset(position, -offset);
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (isRTL && isMobile && position.axis == Axis.horizontal) {
      return super.createBallisticSimulation(position, -velocity);
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

/// Use the [GutterBuilder] to render custom content in the gutter.
/// eg:
/// ```dart
/// CodeForge(
///   gutterBuilder: GutterBuilder(
///     builder: (lineNumber, lineText) => if(lineNumber == 1) "[HEADER]" : null
///   )
/// )
/// ```
///
/// Result:
///
/// ```python
/// [HEADER]|   import os
///    2    |   import sys
///    3    |
///    4    |   def main():
///    5    |        pass
/// ```
/// -------------------------------------------------------------
///
/// To exclude the index from modified content. Set [includeReplacedIndex] to false.
/// <br> eg:
/// ```dart
/// CodeForge(
///   gutterBuilder: GutterBuilder(
///     includeReplacedIndex: false,
///     builder: (lineNumber, lineText) => if(lineNumber == 1) "[HEADER]" : null
///   )
/// )
/// ```
///
/// Result:
/// ```python
/// [HEADER]|   import os
///    1    |   import sys
///    2    |
///    3    |   def main():
///    4    |        pass
/// ```
class GutterBuilder {
  /// Builder that builds the custom gutter content.
  /// Takes the int lineNumber and String lineText parameters and returns the custom
  /// string content for the corresponding line.
  final String? Function(int, String) builder;

  /// To exclude the index from modified content. Set [includeReplacedIndex] to false.
  /// <br> eg:
  /// ```dart
  /// CodeForge(
  ///   gutterBuilder: GutterBuilder(
  ///     includeReplacedIndex: false,
  ///     builder: (lineNumber, lineText) => if(lineNumber == 1) "[HEADER]" : null
  ///   )
  /// )
  /// ```
  ///
  /// Result:
  /// ```python
  /// [HEADER]|   import os
  ///    1    |   import sys  # index `1` is included in the gutter.
  ///    2    |
  ///    3    |   def main():
  ///    4    |        pass
  /// ```
  final bool includeReplacedIndex;

  GutterBuilder({required this.builder, this.includeReplacedIndex = true});
}

/// Keyboard shortcuts used by the [CodeForge].
/// Ovrride to use your own custom shortcuts.
/// <br>
/// Defaults to:
/// ```dart
/// CodeForgeKeyboardShotcuts({
///   this.duplicate = const SingleActivator(LogicalKeyboardKey.keyD, control: true),
///   this.shiftLineUp = const SingleActivator(LogicalKeyboardKey.arrowUp, control: true, shift: true),
///   this.shiftLineDown= const SingleActivator(LogicalKeyboardKey.arrowDown, control: true),
///   this.deletWordBackward = const SingleActivator(LogicalKeyboardKey.backspace, control: true),
///   this.deletWordForward = const SingleActivator(LogicalKeyboardKey.delete, control: true),
///   this.moveCursorToNextWord = const SingleActivator(LogicalKeyboardKey.arrowRight, control: true),
///   this.moveCursorToPreviousWord = const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true),
///   this.moveSelectionToNextWord = const SingleActivator(LogicalKeyboardKey.arrowRight, control: true, shift: true),
///   this.moveSelectionToPreviousWord = const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true, shift: true),
///   this.lspCodeActions = const SingleActivator(LogicalKeyboardKey.period, control: true),
///   this.lspSignature = const SingleActivator(LogicalKeyboardKey.space, control: true, shift: true),
///   this.showFindBar = const SingleActivator(LogicalKeyboardKey.keyF, control: true),
///   this.showSearchAndReplaceBar = const SingleActivator(LogicalKeyboardKey.keyH, control: true),
/// });
/// ```
///
/// Note: The LSP inlay hints shortcut `(Ctrl + Alt)` is not modifiable.<br>
/// Also, core operations like cut, copy, paste, select all, undo, redo aren't modifiable.
class CodeForgeKeyboardShortcuts {
  /// Place the cursor at the starting position of the current line.
  /// Defaults to `Ctrl + home`
  final ShortcutActivator jumpToDocumentStart;

  /// Place the cursor at the starting position of the current line.
  /// Defaults to `Ctrl + end`
  final ShortcutActivator jumpToDocumentEnd;

  /// Similar to [jumpToDocumentStart], place the cursor at the starting position of the current line
  /// and selecting the text from the start position to the document start.
  /// Defaults to `Ctrl + Shift + home`.
  final ShortcutActivator jumpToDocumentStartAndSelectText;

  /// Similar to [jumpToDocumentEnd], place the cursor at the starting position of the current line
  /// and selecting the text from the start position to the document end.
  /// Defaults to `Ctrl + Shift + end`.
  final ShortcutActivator jumpToDocumentEndAndSelectText;

  /// Duplicate the selection, if no active selectio, current line gets duplicated.
  /// Defaults to `Ctrl + D`
  final ShortcutActivator duplicate;

  /// Moves the current line upwards.
  /// Defaults to `Ctrl + Shift + arrowUp`
  final ShortcutActivator shiftLineUp;

  /// Moves the current line downwards.
  /// Defaults to `Ctrl + Shift + arrowUp`
  final ShortcutActivator shiftLineDown;

  /// Delete an entire word and moves the cursor backward.
  /// Defaults to `Ctrl + backspace`
  final ShortcutActivator deletWordBackward;

  /// Delete an entore word and moves the cursor forward.
  /// Defaults to `Ctrl + delete`
  final ShortcutActivator deletWordForward;

  /// Cursor jumps to the previous word.
  /// Defaults to `Ctrl + arrowLeft`
  final ShortcutActivator moveCursorToPreviousWord;

  /// Cursor jumps to the next word.
  /// Defaults to `Ctrl + arrowRight`
  final ShortcutActivator moveCursorToNextWord;

  /// Similar to [moveCursorToPreviousWord], but selection also jumps with the cursor.
  /// Defaults to `Ctrl + Shift + arrowLeft`
  final ShortcutActivator moveSelectionToPreviousWord;

  /// Extends the selection forward by one character at a time.
  /// Defaults to `Shift + arrowRight`
  final ShortcutActivator moveSelectionForward;

  /// Extends the selection backward by one character at a time.
  /// Defaults to `Shift + arrowLeft
  final ShortcutActivator moveSelectionBackward;

  /// Extends the text selection to upward lines.
  /// Defaults tp `Shift + arrowUp`.
  final ShortcutActivator moveSelectionUpward;

  /// Extends the text selection to downward lines.
  /// Defaults tp `Shift + arrowDown`.
  final ShortcutActivator moveSelectionDownward;

  /// Similar to [moveCursorToNextWord], but selection also jumps with the cursor.
  /// Defaults to `Ctrl + Shift + arrowRight`
  final ShortcutActivator moveSelectionToNextWord;

  /// Shows the [LSP code actions](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_codeAction) if available.
  /// Defaults to `Ctrl + .`
  final ShortcutActivator lspCodeActions;

  /// Shows [LSP signature help](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_signatureHelp) if available.
  /// Defaults to `Ctrl + Shift + space`
  final ShortcutActivator lspSignatureHelp;

  /// Show the word finder bar if provided.
  /// Defaults to `Ctrl + F`
  final ShortcutActivator showFindBar;

  /// Show the finder bar along with the replace bar.
  /// Defaults to `Ctrl + H`
  final ShortcutActivator showFindAndReplaceBar;

  /// Jumps the cursor to the start of the current line by selecting the line text.
  /// Defaults to `Shift + home`.
  final ShortcutActivator selectToLineStart;

  /// Jumps the cursor to the end of the current line by selecting the line text.
  /// Defaults to `Shift + end`.
  final ShortcutActivator selectToLineEnd;

  /// Creates mutlicursor to the same column and downward rows/lines.
  final ShortcutActivator extendMutliCursorDownward;

  /// Creates mutlicursor to the same column and upward rows/lines.
  final ShortcutActivator extendMutliCursorUpward;

  const CodeForgeKeyboardShortcuts({
    this.duplicate = const SingleActivator(
      LogicalKeyboardKey.keyD,
      control: true,
    ),
    this.shiftLineUp = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      control: true,
      shift: true,
    ),
    this.shiftLineDown = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      control: true,
      shift: true,
    ),
    this.deletWordBackward = const SingleActivator(
      LogicalKeyboardKey.backspace,
      control: true,
    ),
    this.deletWordForward = const SingleActivator(
      LogicalKeyboardKey.delete,
      control: true,
    ),
    this.moveCursorToNextWord = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      control: true,
    ),
    this.moveCursorToPreviousWord = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      control: true,
    ),
    this.moveSelectionToNextWord = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      control: true,
      shift: true,
    ),
    this.moveSelectionToPreviousWord = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      control: true,
      shift: true,
    ),
    this.moveSelectionUpward = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      shift: true,
    ),
    this.moveSelectionDownward = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      shift: true,
    ),
    this.moveSelectionForward = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      shift: true,
    ),
    this.moveSelectionBackward = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      shift: true,
    ),
    this.lspCodeActions = const SingleActivator(
      LogicalKeyboardKey.period,
      control: true,
    ),
    this.lspSignatureHelp = const SingleActivator(
      LogicalKeyboardKey.space,
      control: true,
      shift: true,
    ),
    this.showFindBar = const SingleActivator(
      LogicalKeyboardKey.keyF,
      control: true,
    ),
    this.showFindAndReplaceBar = const SingleActivator(
      LogicalKeyboardKey.keyH,
      control: true,
    ),
    this.jumpToDocumentStart = const SingleActivator(
      LogicalKeyboardKey.home,
      control: true,
    ),
    this.jumpToDocumentEnd = const SingleActivator(
      LogicalKeyboardKey.end,
      control: true,
    ),
    this.jumpToDocumentStartAndSelectText = const SingleActivator(
      LogicalKeyboardKey.home,
      control: true,
      shift: true,
    ),
    this.jumpToDocumentEndAndSelectText = const SingleActivator(
      LogicalKeyboardKey.end,
      control: true,
      shift: true,
    ),
    this.selectToLineStart = const SingleActivator(
      LogicalKeyboardKey.home,
      shift: true,
    ),
    this.selectToLineEnd = const SingleActivator(
      LogicalKeyboardKey.end,
      shift: true,
    ),
    this.extendMutliCursorDownward = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      alt: true,
      shift: true,
    ),
    this.extendMutliCursorUpward = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      alt: true,
      shift: true,
    ),
  });
}
