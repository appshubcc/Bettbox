import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'edit_profile.dart';

/// Extracts all subscription-like URLs from arbitrary mixed text.
/// Matches http(s)/ftp as well as common proxy URI schemes.
List<String> extractProfileUrls(String text) {
  final pattern = RegExp(
    r'(?:https?|ftp|vmess|vless|ss|trojan|hysteria2?|tuic|wg|wireguard)://[^\s"\'>\]\)]+',
    caseSensitive: false,
  );
  return pattern
      .allMatches(text)
      .map((m) => m.group(0)!.trim())
      .where((u) => u.isNotEmpty)
      .toSet()
      .toList();
}

class BulkImportProfilesView extends StatefulWidget {
  final BuildContext parentContext;

  const BulkImportProfilesView({super.key, required this.parentContext});

  @override
  State<BulkImportProfilesView> createState() =>
      _BulkImportProfilesViewState();
}

class _BulkImportProfilesViewState extends State<BulkImportProfilesView> {
  final TextEditingController _textController = TextEditingController();
  List<String> _detectedUrls = [];
  final Set<int> _selectedIndices = {};

  // null = not started, true = success, false = fail
  final Map<int, bool?> _importStatus = {};
  bool _isImporting = false;
  bool _isDone = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _analyze() {
    final urls = extractProfileUrls(_textController.text);
    setState(() {
      _detectedUrls = urls;
      _selectedIndices
        ..clear()
        ..addAll(List.generate(urls.length, (i) => i));
      _importStatus.clear();
      _isDone = false;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isNotEmpty) {
      _textController.text = text;
      _analyze();
    }
  }

  Future<void> _startImport() async {
    if (_selectedIndices.isEmpty) return;
    setState(() {
      _isImporting = true;
      _isDone = false;
      _importStatus.clear();
    });

    for (final idx in _selectedIndices.toList()..sort()) {
      final url = _detectedUrls[idx];
      try {
        final profile = Profile.normal(url: url);
        await globalState.appController.addProfile(profile);
        if (mounted) setState(() => _importStatus[idx] = true);
      } catch (_) {
        if (mounted) setState(() => _importStatus[idx] = false);
      }
    }

    if (mounted) setState(() {
      _isImporting = false;
      _isDone = true;
    });
  }

  void _openEditForUrl(String url) {
    final editKey = GlobalKey<EditProfileViewState>();
    final profile = Profile.normal(url: url);
    showExtend(
      widget.parentContext,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          actions: [
            IconButton(
              icon: const Icon(Icons.security),
              onPressed: () => editKey.currentState?.showAgeKeyGenerator(),
            ),
          ],
          body: EditProfileView(
            key: editKey,
            profile: profile,
            context: widget.parentContext,
            isNew: true,
          ),
          title: appLocalizations.importFromURL,
        );
      },
    );
  }

  Widget _buildStatusIcon(int idx) {
    final status = _importStatus[idx];
    if (_isImporting && !_importStatus.containsKey(idx)) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (status == true) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    if (status == false) {
      return const Icon(Icons.error, color: Colors.red, size: 20);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final hasUrls = _detectedUrls.isNotEmpty;
    final canImport =
        hasUrls && _selectedIndices.isNotEmpty && !_isImporting;
    final successCount =
        _importStatus.values.where((v) => v == true).length;
    final failCount = _importStatus.values.where((v) => v == false).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Input area ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _textController,
            maxLines: 6,
            minLines: 4,
            onChanged: (_) => _analyze(),
            decoration: InputDecoration(
              hintText: appLocalizations.bulkImportPaste,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),

        // ── Action row ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isImporting ? null : _pasteFromClipboard,
                icon: const Icon(Icons.content_paste, size: 18),
                label: Text(appLocalizations.clipboard),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: canImport ? _startImport : null,
                icon: const Icon(Icons.download_for_offline_outlined, size: 18),
                label: Text(
                  _isImporting
                      ? appLocalizations.bulkImportAdding
                      : appLocalizations.bulkImportStart,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Result summary ───────────────────────────────────────────
        if (_isDone)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              appLocalizations.bulkImportResult(
                successCount.toString(),
                failCount.toString(),
              ),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),

        // ── URL list ────────────────────────────────────────────────
        if (!hasUrls)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _textController.text.isEmpty
                  ? appLocalizations.bulkImportDesc
                  : appLocalizations.bulkImportNoUrls,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: _detectedUrls.length,
            itemBuilder: (_, idx) {
              final url = _detectedUrls[idx];
              final isSelected = _selectedIndices.contains(idx);
              return CheckboxListTile(
                value: isSelected,
                onChanged: _isImporting
                    ? null
                    : (v) {
                        setState(() {
                          if (v == true) {
                            _selectedIndices.add(idx);
                          } else {
                            _selectedIndices.remove(idx);
                          }
                        });
                      },
                title: Text(
                  url,
                  style: context.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                secondary: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusIcon(idx),
                    if (_importStatus[idx] != true)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: appLocalizations.edit,
                        onPressed: _isImporting
                            ? null
                            : () => _openEditForUrl(url),
                      ),
                  ],
                ),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}
