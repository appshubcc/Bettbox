part of 'lsp.dart';

/// This class provides a configuration for Language Server Protocol (LSP) using standard input/output communication.
/// Little bit complex compared to [LspSocketConfig].
///
/// /// Documenation available [here](https://github.com/heckmon/flutter_code_crafter/blob/main/docs/LSPClient.md).
///
/// Example:
///
/// Create an async method to initialize the LSP configuration.
///```dart
///Future<LspConfig?> _initLsp() async {
///    try {
///      final config = await LspStdioConfig.start(
///        executable: '/home/athul/.nvm/versions/node/v20.19.2/bin/pyright-langserver',
///        args: ['--stdio']
///        workspacePath: '/home/athul/Projects/lsp',
///        languageId: 'python',
///      );
///
///      return config;
///    } catch (e) {
///      debugPrint('LSP Initialization failed: $e');
///      return null;
///    }
///  }
///  ```
///  Then use a `FutureBuilder` to initialize the LSP configuration and pass it to the `CodeForge` widget:
///```dart
///  @override
///  Widget build(BuildContext context) {
///    return MaterialApp(
///      home: Scaffold(
///        body: SafeArea(
///          child: FutureBuilder(
///            future: _initLsp(), // Call the async method to get the LSP config
///            builder: (context, snapshot) {
///              if(snapshot.connectionState == ConnectionState.waiting) {
///                return Center(child: CircularProgressIndicator());
///              }
///              return CodeForge(
///                wrapLines: true,
///                editorTheme: anOldHopeTheme,
///                controller: controller,
///                filePath: '/home/athul/Projects/lsp/example.py',
///                textStyle: TextStyle(fontSize: 15, fontFamily: 'monospace'),
///                lspConfig: snapshot.data, // Pass the LSP config here
///              );
///            }
///          ),
///        )
///      ),
///    );
///  }
class LspStdioConfig extends LspConfig {
  /// location of the LSP executable, such as `pyright-langserver`, `rust-analyzer`, etc.
  ///
  /// To get the `executable` path, you can use the `which` command in the terminal. For example, to get the path of the `pyright-langserver`, you can use the following command:
  ///
  ///```bash
  ///which pyright-langserver
  ///```
  final String executable;

  @override
  bool get forceFullDocumentSync => executable.contains('ccls');

  /// Optional arguments for the executable.
  final List<String>? args;

  /// Optional environement variables for the executable.
  final Map<String, String>? environment;

  late Process _process;
  final _buffer = <int>[];
  Future<void> _sendTail = Future<void>.value();

  LspStdioConfig._({
    required this.executable,
    required super.workspacePath,
    required super.languageId,
    this.args,
    this.environment,
    super.capabilities,
    super.initializationOptions,
    super.workspaceConfiguration,
    super.disableWarning,
    super.disableError,
  });

  static Future<LspStdioConfig> start({
    required String executable,
    required String workspacePath,
    required String languageId,
    LspClientCapabilities capabilities = const LspClientCapabilities(),
    Map<String, dynamic> initializationOptions = const {},
    Map<String, dynamic> workspaceConfiguration = const {},
    List<String>? args,
    Map<String, String>? environment,
    bool disableWarning = false,
    bool disableError = false,
  }) async {
    final effectiveInitializationOptions = _withCclsInitializationDefaults(
      executable,
      initializationOptions,
    );

    final config = LspStdioConfig._(
      executable: executable,
      languageId: languageId,
      workspacePath: workspacePath,
      args: args,
      environment: environment,
      disableWarning: disableWarning,
      disableError: disableError,
      capabilities: capabilities,
      initializationOptions: effectiveInitializationOptions,
      workspaceConfiguration: workspaceConfiguration,
    );
    await config._startProcess();
    return config;
  }

  static Map<String, dynamic> _withCclsInitializationDefaults(
    String executable,
    Map<String, dynamic> initializationOptions,
  ) {
    if (!executable.toLowerCase().contains('ccls')) {
      return initializationOptions;
    }

    final defaults = <String, dynamic>{
      'highlight': {'enabled': true, 'lsRanges': true},
      'index': {'onChange': true},
    };

    return _deepMergeMaps(defaults, initializationOptions);
  }

  static Map<String, dynamic> _deepMergeMaps(
    Map<String, dynamic> base,
    Map<String, dynamic> overrides,
  ) {
    final merged = <String, dynamic>{};

    for (final entry in base.entries) {
      final value = entry.value;
      if (value is Map) {
        merged[entry.key] = Map<String, dynamic>.from(
          value.cast<dynamic, dynamic>(),
        );
      } else {
        merged[entry.key] = value;
      }
    }

    for (final entry in overrides.entries) {
      final existing = merged[entry.key];
      final incoming = entry.value;
      if (existing is Map && incoming is Map) {
        merged[entry.key] = _deepMergeMaps(
          Map<String, dynamic>.from(existing.cast<dynamic, dynamic>()),
          Map<String, dynamic>.from(incoming.cast<dynamic, dynamic>()),
        );
      } else {
        merged[entry.key] = incoming;
      }
    }

    return merged;
  }

  Future<void> _startProcess() async {
    _process = await Process.start(
      executable,
      args ?? [],
      environment: environment,
      workingDirectory: workspacePath,
    );
    _process.stdout.listen(_handleStdoutData);
    _process.stderr.listen((data) => debugPrint(utf8.decode(data)));
  }

  int get pid => _process.pid;
  Future<int> get exitCode => _process.exitCode;
  Process get process => _process;

  void _handleStdoutData(List<int> data) {
    _buffer.addAll(data);
    while (_buffer.isNotEmpty) {
      final headerEnd = _findHeaderEnd();
      if (headerEnd == -1) return;
      final header = utf8.decode(_buffer.sublist(0, headerEnd));
      final contentLength = int.parse(
        RegExp(r'Content-Length: (\d+)').firstMatch(header)?.group(1) ?? '0',
      );
      if (_buffer.length < headerEnd + 4 + contentLength) return;
      final messageStart = headerEnd + 4;
      final messageEnd = messageStart + contentLength;
      final messageBytes = _buffer.sublist(messageStart, messageEnd);
      _buffer.removeRange(0, messageEnd);
      try {
        final json = jsonDecode(utf8.decode(messageBytes));
        _responseController.add(json);
      } catch (e) {
        throw FormatException(
          'Invalid JSON message $e',
          utf8.decode(messageBytes),
        );
      }
    }
  }

  int _findHeaderEnd() {
    for (var i = 0; i <= _buffer.length - 4; i++) {
      if (_buffer[i] == 13 &&
          _buffer[i + 1] == 10 &&
          _buffer[i + 2] == 13 &&
          _buffer[i + 3] == 10) {
        return i;
      }
    }
    return -1;
  }

  @override
  Future<Map<String, dynamic>> sendRequest({
    required String method,
    required Map<String, dynamic> params,
  }) async {
    final id = _nextId++;
    final request = {
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    };

    final responseFuture = _responseController.stream.firstWhere(
      (response) => response['id'] == id,
      orElse: () => throw TimeoutException('No response for request $id'),
    );

    await _sendLspMessage(request);

    return await responseFuture;
  }

  @override
  Future<void> sendNotification({
    required String method,
    required Map<String, dynamic> params,
  }) async {
    await _sendLspMessage({
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
    });
  }

  @override
  Future<Map<String, dynamic>> sendResponse(
    int id,
    List<dynamic> result,
  ) async {
    final request = {'jsonrpc': '2.0', 'id': id, 'result': result};
    await _sendLspMessage(request);
    return request;
  }

  Future<void> _sendLspMessage(Map<String, dynamic> message) async {
    final completer = Completer<void>();
    _sendTail = _sendTail.catchError((_) {}).then((_) async {
      try {
        final body = utf8.encode(jsonEncode(message));
        final header = utf8.encode('Content-Length: ${body.length}\r\n\r\n');
        final combined = <int>[...header, ...body];
        _process.stdin.add(combined);
        await _process.stdin.flush();
        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (e, st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    _process.kill();
    _responseController.close();
  }
}
