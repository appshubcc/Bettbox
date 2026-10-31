import 'dart:convert';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';

enum _AgeTab { keys, encrypt, decrypt }

enum _AgeKeyType {
  x25519('X25519'),
  hybrid('MLKEM768-X25519');

  final String label;

  const _AgeKeyType(this.label);
}

const _maxAgeFileSize = 8 * 1024 * 1024;

class AgeToolPage extends ConsumerStatefulWidget {
  const AgeToolPage({super.key});

  @override
  ConsumerState<AgeToolPage> createState() => _AgeToolPageState();
}

class _AgeToolPageState extends ConsumerState<AgeToolPage> {
  _AgeTab _tab = _AgeTab.keys;
  _AgeKeyType _keyType = _AgeKeyType.x25519;
  final _secretController = TextEditingController();
  final _publicController = TextEditingController();
  final _encryptInput = TextEditingController();
  final _recipients = TextEditingController();
  final _decryptInput = TextEditingController();
  final _decryptKey = TextEditingController();
  String _encryptOutput = '';
  String _decryptOutput = '';
  String _error = '';
  bool _busy = false;
  bool _showSecret = false;

  @override
  void dispose() {
    for (final controller in [
      _secretController,
      _publicController,
      _encryptInput,
      _recipients,
      _decryptInput,
      _decryptKey,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    context.showNotifier(appLocalizations.copySuccess);
  }

  Future<void> _generate() async {
    final pair = await clashCore.generateAgeKeyPair(
      hybrid: _keyType == _AgeKeyType.hybrid,
    );
    if (!mounted) return;
    setState(() {
      _secretController.text = pair['secret-key'] ?? '';
      _publicController.text = pair['public-key'] ?? '';
      _error = '';
    });
  }

  Future<void> _derive() async {
    final secret = _secretController.text.trim();
    if (secret.isEmpty) {
      setState(() => _error = appLocalizations.agePrivateKeyRequired);
      return;
    }
    final result = await clashCore.convertAgeSecretKeyToPublicKey(secret);
    if (!mounted) return;
    setState(() {
      if (result.isError) {
        _error = appLocalizations.agePrivateKeyRequired;
      } else {
        _publicController.text = result.data ?? '';
        _keyType = secret.startsWith('AGE-SECRET-KEY-PQ-')
            ? _AgeKeyType.hybrid
            : _AgeKeyType.x25519;
        _error = '';
      }
    });
  }

  Future<void> _pickFile(TextEditingController controller) async {
    final file = await picker.pickerFile();
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    if (bytes.length > _maxAgeFileSize) {
      setState(() => _error = appLocalizations.ageFileTooLarge);
      return;
    }
    setState(() {
      controller.text = utf8.decode(bytes, allowMalformed: true);
      _error = '';
    });
  }

  Future<void> _save(String text, String name) async {
    if (text.isEmpty) return;
    await picker.saveFile(name, Uint8List.fromList(utf8.encode(text)));
  }

  Future<void> _run(bool encrypt) async {
    final data = (encrypt ? _encryptInput : _decryptInput).text;
    final keys = (encrypt ? _recipients : _decryptKey).text
        .split(RegExp(r'[\s,]+'))
        .where((key) => key.isNotEmpty)
        .toList();
    if (data.trim().isEmpty) {
      setState(() => _error = appLocalizations.ageInputRequired);
      return;
    }
    if (keys.isEmpty) {
      setState(
        () => _error = encrypt
            ? appLocalizations.ageRecipientRequired
            : appLocalizations.agePrivateKeyRequired,
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    final result = await clashCore.ageCrypt(
      encrypt: encrypt,
      data: data,
      keys: keys,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.error.isNotEmpty) {
        _error = result.error == 'not age encrypted'
            ? appLocalizations.ageNotEncrypted
            : '${encrypt ? appLocalizations.ageEncryptFailed : appLocalizations.ageDecryptFailed}: ${result.error}';
      } else if (encrypt) {
        _encryptOutput = result.data;
      } else {
        _decryptOutput = result.data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileKey =
        ref.watch(
          currentProfileProvider.select((state) => state?.ageSecretKey),
        ) ??
        '';
    return CommonScaffold(
      title: appLocalizations.ageTool,
      body: ToolPageBody(
        children: [
          ToolSegmented<_AgeTab>(
            values: _AgeTab.values,
            value: _tab,
            labelOf: (tab) => switch (tab) {
              _AgeTab.keys => appLocalizations.ageTabKeys,
              _AgeTab.encrypt => appLocalizations.ageTabEncrypt,
              _AgeTab.decrypt => appLocalizations.ageTabDecrypt,
            },
            onChanged: (tab) => setState(() {
              _tab = tab;
              _error = '';
            }),
          ),
          const SizedBox(height: 12),
          ...switch (_tab) {
            _AgeTab.keys => _buildKeys(),
            _AgeTab.encrypt => _buildEncrypt(),
            _AgeTab.decrypt => _buildDecrypt(profileKey),
          },
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            ToolNote(
              icon: ReIcons.alertCircle,
              text: _error,
              color: context.colorScheme.error,
            ),
          ],
          const SizedBox(height: 12),
          ToolNote(icon: ReIcons.shield, text: appLocalizations.ageToolTip),
        ],
      ),
    );
  }

  Widget _copyButton(String Function() text) => IconButton(
    tooltip: appLocalizations.copy,
    onPressed: () => _copy(text()),
    icon: const Icon(ReIcons.copy, size: 18),
  );

  List<Widget> _buildKeys() => [
    ToolSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appLocalizations.ageKeyType,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ToolSegmented<_AgeKeyType>(
            values: _AgeKeyType.values,
            value: _keyType,
            labelOf: (type) => type.label,
            onChanged: (type) => setState(() => _keyType = type),
          ),
          if (_keyType == _AgeKeyType.hybrid) ...[
            const SizedBox(height: 10),
            ToolNote(
              icon: ReIcons.infoCircle,
              text: appLocalizations.ageKeyHybridTip,
              color: context.colorScheme.tertiary,
            ),
          ],
          const SizedBox(height: 16),
          ToolTvField(
            controller: _secretController,
            child: TextField(
              controller: _secretController,
              obscureText: !_showSecret,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: appLocalizations.agePrivateKeyLabel,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _showSecret = !_showSecret),
                      icon: Icon(
                        _showSecret ? ReIcons.eyeSlash : ReIcons.eye,
                        size: 18,
                      ),
                    ),
                    _copyButton(() => _secretController.text),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ToolTvField(
            controller: _publicController,
            child: TextField(
              controller: _publicController,
              readOnly: true,
              minLines: 1,
              maxLines: 4,
              style: _keyType == _AgeKeyType.hybrid
                  ? context.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    )
                  : null,
              decoration: InputDecoration(
                labelText: appLocalizations.agePublicKeyLabel,
                suffixIcon: _copyButton(() => _publicController.text),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _generate,
                icon: const Icon(ReIcons.key, size: 18),
                label: Text(appLocalizations.ageGenerateKeyPair),
              ),
              OutlinedButton.icon(
                onPressed: _derive,
                icon: const Icon(ReIcons.transferH, size: 18),
                label: Text(appLocalizations.generateFromPrivateKey),
              ),
              if (_publicController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    _recipients.text = _publicController.text;
                    _decryptKey.text = _secretController.text;
                    setState(() => _tab = _AgeTab.encrypt);
                  },
                  icon: const Icon(ReIcons.arrowRight, size: 18),
                  label: Text(appLocalizations.ageUseForEncrypt),
                ),
            ],
          ),
        ],
      ),
    ),
  ];

  Widget _input(
    TextEditingController controller,
    String label, {
    int minLines = 5,
  }) => ToolTvField(
    controller: controller,
    child: TextField(
      controller: controller,
      minLines: minLines,
      maxLines: 10,
      autocorrect: false,
      style: context.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        suffixIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: appLocalizations.paste,
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text case final text?) controller.text = text;
              },
              icon: const Icon(ReIcons.clipboardText, size: 18),
            ),
            IconButton(
              tooltip: appLocalizations.file,
              onPressed: () => _pickFile(controller),
              icon: const Icon(ReIcons.folderOpen, size: 18),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _output(String text, String fileName) => ToolSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                appLocalizations.ageOutput,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _copyButton(() => text),
            IconButton(
              tooltip: appLocalizations.save,
              onPressed: () => _save(text, fileName),
              icon: const Icon(ReIcons.download, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _action(bool encrypt) => SizedBox(
    height: 48,
    child: FilledButton(
      onPressed: _busy ? null : () => _run(encrypt),
      child: Text(
        encrypt
            ? appLocalizations.ageTabEncrypt
            : appLocalizations.ageTabDecrypt,
      ),
    ),
  );

  List<Widget> _buildEncrypt() => [
    ToolSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _input(_encryptInput, appLocalizations.agePlainText),
          const SizedBox(height: 12),
          ToolTvField(
            controller: _recipients,
            child: TextField(
              controller: _recipients,
              minLines: 1,
              maxLines: 4,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: appLocalizations.ageRecipients,
                helperText: appLocalizations.ageRecipientsHint,
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    _action(true),
    if (_encryptOutput.isNotEmpty) ...[
      const SizedBox(height: 12),
      _output(_encryptOutput, 'encrypted.age'),
    ],
  ];

  List<Widget> _buildDecrypt(String profileKey) => [
    ToolSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _input(_decryptInput, appLocalizations.ageCipherText),
          const SizedBox(height: 12),
          ToolTvField(
            controller: _decryptKey,
            child: TextField(
              controller: _decryptKey,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: appLocalizations.agePrivateKeyLabel,
              ),
            ),
          ),
          if (profileKey.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _decryptKey.text = profileKey),
                icon: const Icon(ReIcons.key, size: 16),
                label: Text(appLocalizations.ageUseProfileKey),
              ),
            ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    _action(false),
    if (_decryptOutput.isNotEmpty) ...[
      const SizedBox(height: 12),
      _output(_decryptOutput, 'decrypted.txt'),
    ],
  ];
}
