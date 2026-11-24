import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:code_forge/src/rust/api/editor.dart';

class DocumentSnapshot {
  final RopeSnapshot _snapshot;

  DocumentSnapshot._(this._snapshot);

  factory DocumentSnapshot.fromText(String text) =>
      DocumentSnapshot._(RopeSnapshot.fromText(text: text));

  void dispose() => _snapshot.dispose();
}

class Rope {
  final RopeBridge _rope;
  RopeBridge get core => _rope;

  Rope([String initialText = ''])
    : _rope = RopeBridge.create(initialText: initialText);

  Rope._(this._rope);

  static Future<Rope> fromFile(String path) async =>
      Rope._(await RopeBridge.loadFile(path: path));

  int get length => _rope.lenChars().toInt();

  void dispose() => _rope.dispose();

  DocumentSnapshot snapshot({
    int dirtyStart = 0,
    int dirtyEnd = 0,
    String? dirtyText,
  }) => DocumentSnapshot._(
    _rope.snapshot(
      dirtyStart: BigInt.from(dirtyStart),
      dirtyEnd: BigInt.from(dirtyEnd),
      dirtyText: dirtyText,
    ),
  );

  bool equalsSnapshot(
    DocumentSnapshot snapshot, {
    int dirtyStart = 0,
    int dirtyEnd = 0,
    String? dirtyText,
  }) => _rope.equalsSnapshot(
    snapshot: snapshot._snapshot,
    dirtyStart: BigInt.from(dirtyStart),
    dirtyEnd: BigInt.from(dirtyEnd),
    dirtyText: dirtyText,
  );

  RopeTextEdit? diffText(
    String newText, {
    int dirtyStart = 0,
    int dirtyEnd = 0,
    String? dirtyText,
  }) => _rope.diffText(
    dirtyStart: BigInt.from(dirtyStart),
    dirtyEnd: BigInt.from(dirtyEnd),
    dirtyText: dirtyText,
    newText: newText,
  );

  String getText() {
    return _rope.getText();
  }

  String substring(int start, [int? end]) {
    return _rope.slice(
      start: BigInt.from(start),
      end: BigInt.from(end ?? length),
    );
  }

  void insert(int position, String text) {
    _rope.insert(charIdx: BigInt.from(position), text: text);
  }

  void delete(int start, int end) {
    _rope.remove(start: BigInt.from(start), end: BigInt.from(end));
  }

  List<String> cachedLinesRange(int startLine, int endLine) {
    return _rope.cachedLinesRange(
      startLine: BigInt.from(startLine),
      endLine: BigInt.from(endLine),
    );
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
}

/// The document and the rope count Unicode scalar values; Dart strings,
/// paragraphs and regex matches count UTF-16 code units.
extension TextOffsets on String {
  int toUtf16Offset(int scalarOffset) =>
      scalarOffset >= length ? length : utf16After(0, scalarOffset);

  /// The code unit [scalars] scalar values on from the code unit [utf16].
  int utf16After(int utf16, int scalars) {
    var index = utf16;
    for (var scalar = 0; scalar < scalars && index < length; scalar++) {
      index += _pairWidthAt(index);
    }
    return index;
  }

  int toScalarOffset(int utf16Offset) {
    var utf16 = 0;
    var scalar = 0;
    while (utf16 < utf16Offset && utf16 < length) {
      utf16 += _pairWidthAt(utf16);
      scalar++;
    }
    return scalar;
  }

  String scalarSubstring(int start, [int? end]) {
    final from = toUtf16Offset(start);
    return substring(from, end == null ? length : toUtf16Offset(end));
  }

  bool isLowSurrogateAt(int index) =>
      index > 0 && index < length && (codeUnitAt(index) & 0xFC00) == 0xDC00;

  int _pairWidthAt(int index) =>
      (codeUnitAt(index) & 0xFC00) == 0xD800 && isLowSurrogateAt(index + 1)
      ? 2
      : 1;
}

// Sorted for isWordChar's early exit, and all in the BMP so one code unit decides.
const _wordRanges = [
  (0x30, 0x39),
  (0x41, 0x5A),
  (0x5F, 0x5F),
  (0x61, 0x7A),
  (0x0590, 0x05FF),
  (0x0600, 0x06FF),
  (0x08A0, 0x08FF),
  (0x3040, 0x309F),
  (0x30A0, 0x30FF),
  (0x3400, 0x4DBF),
  (0x4E00, 0x9FFF),
  (0xAC00, 0xD7AF),
  (0xF900, 0xFAFF),
];

bool isWordChar(int codeUnit) {
  for (final (from, to) in _wordRanges) {
    if (codeUnit < from) return false;
    if (codeUnit <= to) return true;
  }
  return false;
}

bool isWordStartChar(int codeUnit) =>
    isWordChar(codeUnit) && (codeUnit < 0x30 || codeUnit > 0x39);

String _hex(int codeUnit) => '\\u${codeUnit.toRadixString(16).padLeft(4, '0')}';

final String wordCharClass = [
  for (final (from, to) in _wordRanges) '${_hex(from)}-${_hex(to)}',
].join();

/// Where each model line sits vertically, in fixed-height rows.
///
/// An unmeasured line holds an estimate until painting measures it, so the
/// scroll extent can shift while scrolling through a wrapped document.
class ViewLineLayout {
  ViewLineLayout({required this.rowHeight});

  double rowHeight;

  Float64List _rows = Float64List(0);
  Uint8List _flags = Uint8List(0);
  Float64List _tree = Float64List(1);
  bool _treeDirty = false;
  int _lineCount = 0;
  double _estimatedRows = 1;

  static const int _hidden = 1;
  static const int _measured = 2;

  int get lineCount => _lineCount;

  double get estimatedRows => _estimatedRows;

  bool get hasHiddenLines => _hiddenCount > 0;
  int _hiddenCount = 0;

  void reset(int lineCount) {
    _lineCount = lineCount;
    _rows = Float64List(lineCount)..fillRange(0, lineCount, _estimatedRows);
    _flags = Uint8List(lineCount);
    _hiddenCount = 0;
    _treeDirty = true;
  }

  void setEstimate(double rows) {
    if (rows <= 0 || rows == _estimatedRows) return;
    _estimatedRows = rows;
    for (var i = 0; i < _lineCount; i++) {
      if (_flags[i] & _measured == 0) _rows[i] = rows;
    }
    _treeDirty = true;
  }

  bool isMeasured(int line) => _flags[line] & _measured != 0;

  bool isHidden(int line) => _flags[line] & _hidden != 0;

  double rowsOf(int line) => _rows[line];

  bool setRows(int line, int rows) {
    _flags[line] |= _measured;
    final delta = rows - _rows[line];
    if (delta == 0) return false;
    _rows[line] = rows.toDouble();
    if (_flags[line] & _hidden == 0) _add(line, delta);
    return true;
  }

  void invalidate(int line) {
    if (line < 0 || line >= _lineCount) return;
    _flags[line] &= ~_measured;
    final delta = _estimatedRows - _rows[line];
    if (delta == 0) return;
    _rows[line] = _estimatedRows;
    if (_flags[line] & _hidden == 0) _add(line, delta);
  }

  void invalidateAll() {
    for (var i = 0; i < _lineCount; i++) {
      _flags[i] &= ~_measured;
    }
    _rows.fillRange(0, _lineCount, _estimatedRows);
    _treeDirty = true;
  }

  void splice(int start, int removed, int inserted) {
    final newCount = _lineCount - removed + inserted;
    for (var i = start; i < start + removed; i++) {
      if (_flags[i] & _hidden != 0) _hiddenCount--;
    }
    final rows = Float64List(newCount);
    final flags = Uint8List(newCount);
    rows.setRange(0, start, _rows);
    flags.setRange(0, start, _flags);
    rows.fillRange(start, start + inserted, _estimatedRows);
    rows.setRange(start + inserted, newCount, _rows, start + removed);
    flags.setRange(start + inserted, newCount, _flags, start + removed);
    _rows = rows;
    _flags = flags;
    _lineCount = newCount;
    _treeDirty = true;
  }

  void setHiddenRanges(Iterable<({int start, int end})> ranges) {
    if (_hiddenCount == 0 && ranges.isEmpty) return;
    for (var i = 0; i < _lineCount; i++) {
      _flags[i] &= ~_hidden;
    }
    _hiddenCount = 0;
    for (final range in ranges) {
      final end = range.end < _lineCount ? range.end : _lineCount;
      for (var i = range.start < 0 ? 0 : range.start; i < end; i++) {
        if (_flags[i] & _hidden == 0) {
          _flags[i] |= _hidden;
          _hiddenCount++;
        }
      }
    }
    _treeDirty = true;
  }

  double lineHeight(int line) =>
      _flags[line] & _hidden != 0 ? 0 : _rows[line] * rowHeight;

  double lineTop(int line) => _prefix(_clampBoundary(line)) * rowHeight;

  double get totalHeight => _prefix(_lineCount) * rowHeight;

  int lineAt(double y) => _lineAtRow(y / rowHeight);

  int nextVisible(int line) {
    final clamped = _clampLine(line);
    if (_lineCount == 0 || _flags[clamped] & _hidden == 0) return clamped;
    return _lineAtRow(_prefix(clamped) + 0.5);
  }

  int _clampBoundary(int line) =>
      line < 0 ? 0 : (line > _lineCount ? _lineCount : line);

  int _clampLine(int line) =>
      line < 0 ? 0 : (line >= _lineCount ? _lineCount - 1 : line);

  int _lineAtRow(double row) {
    if (_lineCount == 0) return 0;
    _ensureTree();
    final total = _prefix(_lineCount);
    // A visible line spans at least one row, so half a row is a safe margin
    // against the rounding of summed row counts.
    var remaining = row >= total ? total - 0.5 : (row < 0 ? 0.0 : row);
    final tree = _tree;
    var index = 0;
    var step = 1;
    while (step * 2 <= _lineCount) {
      step *= 2;
    }
    for (; step > 0; step >>= 1) {
      final next = index + step;
      if (next <= _lineCount && tree[next] <= remaining) {
        index = next;
        remaining -= tree[next];
      }
    }
    return index < _lineCount ? index : _lineCount - 1;
  }

  double _prefix(int line) {
    _ensureTree();
    var sum = 0.0;
    for (var i = line; i > 0; i -= i & -i) {
      sum += _tree[i];
    }
    return sum;
  }

  void _add(int line, double delta) {
    if (_treeDirty) return;
    for (var i = line + 1; i <= _lineCount; i += i & -i) {
      _tree[i] += delta;
    }
  }

  void _ensureTree() {
    if (!_treeDirty) return;
    final tree = Float64List(_lineCount + 1);
    for (var i = 0; i < _lineCount; i++) {
      if (_flags[i] & _hidden == 0) tree[i + 1] += _rows[i];
    }
    for (var i = 1; i <= _lineCount; i++) {
      final parent = i + (i & -i);
      if (parent <= _lineCount) tree[parent] += tree[i];
    }
    _tree = tree;
    _treeDirty = false;
  }
}

// [Clipboard] codes JSON on the UI isolate, tens of ms per megabyte.
const _inlineLimit = 1 << 16;
const _codec = JSONMethodCodec();

// One Binder call carries under 1 MiB and a clip takes a byte or more per
// UTF-16 unit, so Android is sure to refuse a clip this long.
const _androidLimit = 1 << 20;

// Reads and writes queue behind a large write still being coded.
Future<void>? _queue;

Future<bool> setClipboardText(String text) async {
  if (defaultTargetPlatform == TargetPlatform.android &&
      text.length >= _androidLimit) {
    return false;
  }
  try {
    await _setClipboardText(text);
    return true;
  } on Exception {
    return false;
  }
}

Future<void> _setClipboardText(String text) {
  final queue = _queue;
  if (queue == null && text.length < _inlineLimit) {
    return Clipboard.setData(ClipboardData(text: text));
  }
  final written = Completer<void>();
  _queue = written.future;
  return _write(queue, text).whenComplete(() {
    written.complete();
    if (identical(_queue, written.future)) _queue = null;
  });
}

Future<void> _write(Future<void>? after, String text) async {
  await after;
  if (text.length < _inlineLimit) {
    return Clipboard.setData(ClipboardData(text: text));
  }
  _decodeReply(await _send(await compute(_encodeSetData, text)));
}

Future<String?> getClipboardText() async {
  final queue = _queue;
  if (queue != null) await queue;
  final reply = await _send(
    _codec.encodeMethodCall(
      const MethodCall('Clipboard.getData', Clipboard.kTextPlain),
    ),
  );
  final result = reply != null && reply.lengthInBytes >= _inlineLimit
      ? await compute(_decodeReply, reply)
      : _decodeReply(reply);
  return (result as Map?)?['text'] as String?;
}

Future<ByteData?> _send(ByteData message) async {
  const channel = SystemChannels.platform;
  return await channel.binaryMessenger.send(channel.name, message);
}

ByteData _encodeSetData(String text) => _codec.encodeMethodCall(
  MethodCall('Clipboard.setData', <String, dynamic>{'text': text}),
);

Object? _decodeReply(ByteData? reply) {
  if (reply == null) {
    throw MissingPluginException(
      'No implementation found on channel ${SystemChannels.platform.name}',
    );
  }
  return _codec.decodeEnvelope(reply);
}
