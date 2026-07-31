import 'dart:async';

class CoreReadyTimeoutException implements Exception {
  final Duration timeout;

  const CoreReadyTimeoutException(this.timeout);

  @override
  String toString() =>
      'Core IPC did not become ready within ${timeout.inSeconds}s';
}

Future<T> waitForCoreReady<T>(
  Future<T> ready, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    return await ready.timeout(timeout);
  } on TimeoutException {
    throw CoreReadyTimeoutException(timeout);
  }
}

class CoreStartGuard {
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<T> run<T>(Future<T> Function() operation) async {
    if (_isRunning) {
      throw StateError('Core startup is already in progress');
    }
    _isRunning = true;
    try {
      return await operation();
    } finally {
      _isRunning = false;
    }
  }
}
