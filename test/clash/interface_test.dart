import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/clash/interface.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHandler extends ClashHandlerInterface {
  Object? channel = Object();
  bool disconnected = false;
  final sent = <String>[];

  @override
  Future<Object?> sendMessage(String message) async {
    if (disconnected) {
      throw const CoreDisconnectedException();
    }
    sent.add(json.decode(message)['id'] as String);
    return channel;
  }

  void reply(String id, dynamic data) {
    handleResult(
      ActionResult(method: ActionMethod.getMemory, data: data, id: id),
    );
  }

  @override
  Future<bool> preload() async => true;

  @override
  FutureOr<void> reStart() {}

  @override
  FutureOr<bool> destroy() => true;
}

String _frame(Map<String, Object?> header, String payload) =>
    '${json.encode(header)}\n$payload';

void main() {
  group('decodeActionResult', () {
    test('keeps raw payloads verbatim', () {
      const payload = '{"connections":[{"id":"a\\nb"}]}\nsecond line';
      final result = decodeActionResult(
        _frame({
          'id': 'getConnections#1',
          'method': 'getConnections',
          'code': 0,
          'raw': true,
        }, payload),
      );
      expect(result?.id, 'getConnections#1');
      expect(result?.method, ActionMethod.getConnections);
      expect(result?.data, payload);
    });

    test('decodes json payloads', () {
      final result = decodeActionResult(
        _frame({
          'id': 'getConfig#1',
          'method': 'getConfig',
          'code': -1,
        }, '{"k":[1,true]}'),
      );
      expect(result?.code, ResultType.error);
      expect(result?.data, {
        'k': [1, true],
      });
    });

    test('rejects frames without a header', () {
      expect(decodeActionResult('{"id":"x"}'), isNull);
    });
  });

  group('ClashHandlerInterface', () {
    test('completes requests from raw frames', () async {
      final handler = _FakeHandler();
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      await handler.handleResultMessage(
        _frame({
          'id': handler.sent.single,
          'method': 'getMemory',
          'code': 0,
          'raw': true,
        }, '42'),
      );
      expect(await future, '42');
    });

    test('decodes large json payloads off the caller', () async {
      final handler = _FakeHandler();
      final future = handler.invoke<dynamic>(method: ActionMethod.getProxies);
      await pumpEventQueue();
      final items = List.generate(20000, (index) => 'item-$index');
      await handler.handleResultMessage(
        _frame({
          'id': handler.sent.single,
          'method': 'getProxies',
          'code': 0,
        }, json.encode({'items': items})),
      );
      expect((await future)['items'], items);
    });

    test('ignores malformed frames', () async {
      final handler = _FakeHandler();
      await handler.handleResultMessage('not a frame');
      expect(handler.callbackCompleterMap, isEmpty);
    });

    test('returns the reply while the channel is alive', () async {
      final handler = _FakeHandler();
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      handler.reply(handler.sent.single, '42');
      expect(await future, '42');
    });

    test('completes string requests that receive non-string data', () async {
      final handler = _FakeHandler();
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      handler.reply(handler.sent.single, true);
      expect(await future.timeout(const Duration(seconds: 1)), 'true');
      expect(handler.callbackCompleterMap, isEmpty);
    });

    test('releases the completer as soon as the reply arrives', () async {
      final handler = _FakeHandler();
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      handler.reply(handler.sent.single, '42');
      expect(handler.callbackCompleterMap, isEmpty);
      expect(await future, '42');
    });

    test('falls back immediately when its channel is aborted', () async {
      final handler = _FakeHandler();
      final oldChannel = handler.channel!;
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      final stopwatch = Stopwatch()..start();
      handler.abortRequests(oldChannel);
      expect(await future, '');
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
      expect(handler.callbackCompleterMap, isEmpty);
    });

    test('uses the custom onTimeout as fallback', () async {
      final handler = _FakeHandler();
      final oldChannel = handler.channel!;
      final future = handler.invoke<String>(
        method: ActionMethod.getMemory,
        onTimeout: () => 'fallback',
      );
      await pumpEventQueue();
      handler.abortRequests(oldChannel);
      expect(await future, 'fallback');
    });

    test('keeps requests on other channels untouched', () async {
      final handler = _FakeHandler();
      final oldChannel = handler.channel!;
      final oldFuture = handler.invoke<bool>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      handler.channel = Object();
      final newFuture = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      handler.abortRequests(oldChannel);
      expect(await oldFuture, false);
      handler.reply(handler.sent.last, 'alive');
      expect(await newFuture, 'alive');
    });

    test('falls back immediately when the message cannot be sent', () async {
      final handler = _FakeHandler()..disconnected = true;
      final result = await handler.invoke<String>(
        method: ActionMethod.getMemory,
      );
      expect(result, '');
      expect(handler.callbackCompleterMap, isEmpty);
    });

    test('falls back when the peer of a real socket closes', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final client = await Socket.connect(
        InternetAddress.loopbackIPv4,
        server.port,
      );
      final socket = await server.first;
      final handler = _FakeHandler()..channel = socket;
      socket.listen((_) {}, onDone: () => handler.abortRequests(socket));
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      client.destroy();
      expect(await future.timeout(const Duration(seconds: 2)), '');
      socket.destroy();
      await server.close();
    });

    test('ignores channels for requests that already replied', () async {
      final handler = _FakeHandler();
      final oldChannel = handler.channel!;
      final future = handler.invoke<String>(method: ActionMethod.getMemory);
      await pumpEventQueue();
      handler.reply(handler.sent.single, 'done');
      handler.abortRequests(oldChannel);
      expect(await future, 'done');
    });
  });
}
