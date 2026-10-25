import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

const maxFrameLength = 256 * 1024 * 1024;

class FrameCodec {
  static Uint8List encode(String data) {
    final bytes = utf8.encode(data);
    final frame = Uint8List(4 + bytes.length);
    final buffer = ByteData.sublistView(frame);
    buffer.setUint32(0, bytes.length, Endian.little);
    frame.setRange(4, frame.length, bytes);
    return frame;
  }
}

class FrameDecoder {
  static const _initialCapacity = 64 * 1024;
  static const _retainedCapacity = 1024 * 1024;

  Uint8List _buffer = Uint8List(0);
  int _start = 0;
  int _end = 0;

  void _append(Uint8List data) {
    final pending = _end - _start;
    if (_end + data.length > _buffer.length) {
      final required = pending + data.length;
      final next = Uint8List(
        max(required, max(_buffer.length * 2, _initialCapacity)),
      );
      next.setRange(0, pending, _buffer, _start);
      _buffer = next;
      _start = 0;
      _end = pending;
    }
    _buffer.setRange(_end, _end + data.length, data);
    _end += data.length;
  }

  List<String> decode(Uint8List data) {
    final results = <String>[];
    if (data.isEmpty) return results;
    _append(data);
    try {
      while (_end - _start >= 4) {
        final length = ByteData.sublistView(
          _buffer,
          _start,
          _start + 4,
        ).getUint32(0, Endian.little);
        if (length > maxFrameLength) {
          throw FormatException('Invalid or too large frame length: $length');
        }
        if (_end - _start < 4 + length) {
          break;
        }
        results.add(
          utf8.decode(
            Uint8List.sublistView(_buffer, _start + 4, _start + 4 + length),
          ),
        );
        _start += 4 + length;
      }
    } catch (_) {
      reset();
      rethrow;
    }
    if (_start == _end) {
      _start = 0;
      _end = 0;
      if (_buffer.length > _retainedCapacity) {
        _buffer = Uint8List(0);
      }
    }
    return results;
  }

  void reset() {
    _buffer = Uint8List(0);
    _start = 0;
    _end = 0;
  }
}

class FrameDecoderTransformer extends StreamTransformerBase<Uint8List, String> {
  @override
  Stream<String> bind(Stream<Uint8List> stream) {
    final decoder = FrameDecoder();
    return stream.expand((data) => decoder.decode(data));
  }
}
