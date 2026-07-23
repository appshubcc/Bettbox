import 'package:code_forge/src/rust/api/rope.dart';
import 'package:flutter/material.dart';

class Rope {
  final RopeBridge _rope;
  RopeBridge get core => _rope;

  Rope([String initialText = ''])
    : _rope = RopeBridge.create(initialText: initialText);

  Rope._fromBridge(this._rope);

  int get length => _rope.lenChars().toInt();

  /// Creates a new Rope with text inserted at position (immutable)
  Rope insertImmutable(int position, String text) {
    var ropeCopy = _rope.copy();
    ropeCopy.insert(charIdx: BigInt.from(position), text: text);
    return Rope._fromBridge(ropeCopy);
  }

  /// Creates a new Rope with text deleted between start and end (immutable)
  Rope deleteImmutable(int start, int end) {
    var ropeCopy = _rope.copy();
    ropeCopy.remove(start: BigInt.from(start), end: BigInt.from(end));
    return Rope._fromBridge(ropeCopy);
  }

  /// Creates a new Rope by concatenating another Rope (immutable)
  Rope concatImmutable(Rope other) {
    var ropeCopy = _rope.copy();
    ropeCopy.insert(charIdx: BigInt.from(length), text: other.getText());
    return Rope._fromBridge(ropeCopy);
  }

  /// Splits this rope at position, returning two new Ropes (immutable)
  (Rope, Rope) splitImmutable(int position) {
    if (position < 0 || position > length) {
      throw RangeError('Invalid position: $position for length $length');
    }
    if (position == 0) {
      return (Rope(''), Rope._fromBridge(_rope.copy()));
    }
    if (position == length) {
      return (Rope._fromBridge(_rope.copy()), Rope(''));
    }

    final leftText = _rope.slice(
      start: BigInt.zero,
      end: BigInt.from(position),
    );
    final rightText = _rope.slice(
      start: BigInt.from(position),
      end: BigInt.from(length),
    );
    return (Rope(leftText), Rope(rightText));
  }

  /// Creates a deep copy of this Rope
  Rope copy() => Rope._fromBridge(_rope.copy());

  TextSelection get selection {
    final currentSelection = _rope.selection();
    return TextSelection(
      baseOffset: currentSelection.baseOffset.toInt(),
      extentOffset: currentSelection.extentOffset.toInt(),
    );
  }

  void setSelection(TextSelection selection) {
    _rope.setSelection(
      baseOffset: BigInt.from(selection.baseOffset),
      extentOffset: BigInt.from(selection.extentOffset),
    );
  }

  /// Returns the overall text direction of this rope
  TextDirection get textDirection {
    return _rope.textDirection();
  }

  /// Returns true if this rope contains any RTL characters
  bool get containsRtl => textDirection != TextDirection.ltr;

  /// Returns true if this rope is primarily RTL
  bool get isRtl => textDirection == TextDirection.rtl;

  /// Returns true if this rope is primarily LTR
  bool get isLtr => textDirection == TextDirection.ltr;

  /// Returns true if this rope contains both RTL and LTR characters
  bool get isMixed => textDirection == TextDirection.mixed;

  /// Get BiDi segments for the entire rope
  List<BiDiSegment> get bidiSegments {
    return _rope.getBidiSegmentsInRange(
      start: BigInt.zero,
      end: BigInt.from(length),
    );
  }

  /// Get BiDi segments for a specific line
  List<BiDiSegment> getBiDiSegmentsForLine(int lineIndex) {
    return _rope.getBidiSegmentsForLine(lineIndex: BigInt.from(lineIndex));
  }

  /// Get BiDi segments within a character range
  List<BiDiSegment> getBiDiSegmentsInRange(int start, int end) {
    return _rope.getBidiSegmentsInRange(
      start: BigInt.from(start),
      end: BigInt.from(end),
    );
  }

  /// Get only RTL segments (useful for rendering)
  List<(int start, int end)> getRtlSegments() {
    return bidiSegments
        .where((s) => s.direction == TextDirection.rtl)
        .map((s) => (s.start.toInt(), s.end.toInt()))
        .toList();
  }

  /// Wrap text with appropriate BiDi control characters for rendering
  String toStringWithBiDiControls() {
    final text = getText();

    if (!containsRtl) return text;

    if (isRtl) {
      return String.fromCharCode(0x202B) + text + String.fromCharCode(0x202C);
    } else {
      return String.fromCharCode(0x202A) + text + String.fromCharCode(0x202C);
    }
  }

  /// Returns the primary direction based on character count
  /// For mixed text, returns the direction with more characters
  TextDirection get primaryDirection {
    return _rope.primaryDirection();
  }

  String getText() {
    return _rope.getText();
  }

  String substring(int start, [int? end]) {
    return _rope.slice(
      start: BigInt.from(start),
      end: BigInt.from(end ?? length),
    );
  }

  String charAt(int position) {
    return _rope.charAt(position: BigInt.from(position));
  }

  /// Mutable insert - modifies this rope in place
  /// For immutable version, use [insertImmutable]
  void insert(int position, String text) {
    _rope.insert(charIdx: BigInt.from(position), text: text);
  }

  /// Mutable delete - modifies this rope in place
  /// For immutable version, use [deleteImmutable]
  void delete(int start, int end) {
    _rope.remove(start: BigInt.from(start), end: BigInt.from(end));
  }

  List<String> get cachedLines {
    return _rope.cachedLines();
  }

  List<String> cachedLinesRange(int startLine, int endLine) {
    return _rope.cachedLinesRange(
      startLine: BigInt.from(startLine),
      endLine: BigInt.from(endLine),
    );
  }

  Iterable<String> get lines {
    return _rope.cachedLines();
  }

  int get lineCount => _rope.lenLines().toInt();

  String getLineText(int lineIndex) {
    return _rope.line(lineIdx: BigInt.from(lineIndex));
  }

  int getLineAtOffset(int charOffset) {
    return _rope.charToLine(charIdx: BigInt.from(charOffset)).toInt();
  }

  int getLineStartOffset(int lineIndex) {
    return _rope.lineToChar(lineIdx: BigInt.from(lineIndex)).toInt();
  }

  int findLineStart(int offset) {
    return _rope.findLineStart(offset: BigInt.from(offset)).toInt();
  }

  int findLineEnd(int offset) {
    return _rope.findLineEnd(offset: BigInt.from(offset)).toInt();
  }
}
