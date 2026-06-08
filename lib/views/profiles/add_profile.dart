import 'package:bett_box/common/common.dart';
import 'package:bett_box/pages/scan.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    globalState.appController.addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(String url, {String? ageSecretKey}) async {
    globalState.appController.addProfileFormURL(url, ageSecretKey: ageSecretKey);
  }

  Future<void> _handleAddProfileFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim();

      if (text == null || text.isEmpty) {
        if (context.mounted) {
          context.showSnackBar(
            appLocalizations.emptyTip(appLocalizations.clipboard),
          );
        }
        return;
      }

      if (!text.isUrl) {
        if (context.mounted) {
          context.showSnackBar(
            appLocalizations.urlTip(appLocalizations.clipboard),
          );
        }
        return;
      }

      _handleAddProfileFormURL(text);
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar(e.toString());
      }
    }
  }

  Future<void> _toScan() async {
    if (system.isDesktop) {
      globalState.appController.addProfileFormQrCode();
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFormURL(url);
      });
    }
  }

  Future<void> _toAdd() async {
    final result = await globalState.showCommonDialog<Map<String, String>>(
      child: const URLFormDialog(),
    );
    if (result != null && result.containsKey('url')) {
      _handleAddProfileFormURL(result['url']!, ageSecretKey: result['ageSecretKey']);
    }
  }

  @override
  Widget build(context) {
    return ListView(
      children: [
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: _toScan,
        ),
        ListItem(
          leading: const Icon(Icons.content_paste),
          title: Text(appLocalizations.clipboard),
          subtitle: Text(appLocalizations.clipboardDesc),
          onTap: _handleAddProfileFromClipboard,
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: _handleAddProfileFormFile,
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: _toAdd,
        ),
      ],
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final urlController = TextEditingController();
  final ageSecretKeyController = TextEditingController();
  bool _obscureAgeSecretKey = true;

  @override
  void dispose() {
    urlController.dispose();
    ageSecretKeyController.dispose();
    super.dispose();
  }

  Future<void> _handleAddProfileFormURL() async {
    final url = urlController.value.text.trim();
    if (url.isEmpty || !url.isUrl) {
      if (mounted) {
        context.showSnackBar(appLocalizations.urlTip(''));
      }
      return;
    }
    final ageKey = ageSecretKeyController.text.trim();
    if (ageKey.isNotEmpty && !ageKey.startsWith('AGE-SECRET-KEY-')) {
      if (mounted) {
        context.showSnackBar(appLocalizations.ageSecretKeyInvalidValidationDesc);
      }
      return;
    }

    Navigator.of(context).pop<Map<String, String>>({
      'url': url,
      if (ageKey.isNotEmpty) 'ageSecretKey': ageKey,
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              autofocus: true,
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
            ),
            TextField(
              textInputAction: TextInputAction.next,
              controller: ageSecretKeyController,
              obscureText: _obscureAgeSecretKey,
              maxLines: 1,
              minLines: 1,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.ageSecretKeyOptional,
                hintText: 'AGE-SECRET-KEY-...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureAgeSecretKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureAgeSecretKey = !_obscureAgeSecretKey;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
