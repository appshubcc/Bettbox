import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/scan.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bulk_import_profiles.dart';
import 'edit_profile.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    globalState.appController.addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(String url, {String? ageSecretKey}) async {
    final editKey = GlobalKey<EditProfileViewState>();
    final profile = Profile.normal(
      url: url,
      ageSecretKey: ageSecretKey,
    );
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          actions: [
            IconButton(
              icon: const Icon(Icons.security),
              onPressed: () {
                editKey.currentState?.showAgeKeyGenerator();
              },
            ),
          ],
          body: EditProfileView(
            key: editKey,
            profile: profile,
            context: context,
            isNew: true,
          ),
          title: appLocalizations.importFromURL,
        );
      },
    );
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
    _handleAddProfileFormURL('');
  }

  void _handleBulkImport() {
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: SingleChildScrollView(
            child: BulkImportProfilesView(parentContext: context),
          ),
          title: appLocalizations.bulkImportTitle,
        );
      },
    );
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
        ListItem(
          leading: const Icon(Icons.playlist_add_rounded),
          title: Text(appLocalizations.bulkImport),
          subtitle: Text(appLocalizations.bulkImportDesc),
          onTap: _handleBulkImport,
        ),
      ],
    );
  }
}
