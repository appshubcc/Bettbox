import 'dart:io';

Future<bool> isLocalPortAvailable(int port, {bool allowLan = false}) async {
  if (port <= 0 || port > 65535) return false;

  ServerSocket? socket;
  try {
    socket = await ServerSocket.bind(
      allowLan ? InternetAddress.anyIPv4 : InternetAddress.loopbackIPv4,
      port,
      shared: false,
    );
    return true;
  } on SocketException {
    return false;
  } finally {
    await socket?.close();
  }
}

Future<int> findAvailableLocalPort(
  int preferred, {
  bool allowLan = false,
  int scanLimit = 20,
}) async {
  if (preferred <= 0) return preferred;

  for (var offset = 0; offset <= scanLimit; offset++) {
    final candidate = preferred + offset;
    if (candidate > 65535) break;
    if (await isLocalPortAvailable(candidate, allowLan: allowLan)) {
      return candidate;
    }
  }

  ServerSocket? socket;
  try {
    socket = await ServerSocket.bind(
      allowLan ? InternetAddress.anyIPv4 : InternetAddress.loopbackIPv4,
      0,
      shared: false,
    );
    return socket.port;
  } finally {
    await socket?.close();
  }
}
