import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/scan.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'edit_profile.dart';
import 'tv_qr_import_dialog.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    globalState.appController.addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(
    String url, {
    String? ageSecretKey,
  }) async {
    final editKey = GlobalKey<EditProfileViewState>();
    final profile = Profile.normal(url: url, ageSecretKey: ageSecretKey);
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          actions: [
            IconButton(
              icon: const Icon(ReIcons.securitySafe),
              tooltip: appLocalizations.ageKeyGenerateTitle,
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
    if (globalState.isAndroidTV) {
      await showDialog(
        context: context,
        builder: (_) => const TvQrImportDialog(),
      );
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

  @override
  Widget build(context) {
    return ScrollEdgeRise(
      builder: (_, rise) => ListView(
        padding: EdgeInsets.fromLTRB(16, 12 + rise, 16, 12),
        children: [
          CommonCard(
            type: CommonCardType.filled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListItem(
                  leading: const Icon(ReIcons.qr),
                  title: Text(appLocalizations.qrcode),
                  subtitle: Text(appLocalizations.qrcodeDesc),
                  onTap: _toScan,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: context.colorScheme.brightness == Brightness.light
                        ? 0.6
                        : 0.45,
                  ),
                  indent: 16,
                  endIndent: 16,
                ),
                ListItem(
                  leading: const Icon(ReIcons.clipboardText),
                  title: Text(appLocalizations.clipboard),
                  subtitle: Text(appLocalizations.clipboardDesc),
                  onTap: _handleAddProfileFromClipboard,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: context.colorScheme.brightness == Brightness.light
                        ? 0.6
                        : 0.45,
                  ),
                  indent: 16,
                  endIndent: 16,
                ),
                ListItem(
                  leading: const Icon(ReIcons.documentUpload),
                  title: Text(appLocalizations.file),
                  subtitle: Text(appLocalizations.fileDesc),
                  onTap: _handleAddProfileFormFile,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: context.colorScheme.brightness == Brightness.light
                        ? 0.6
                        : 0.45,
                  ),
                  indent: 16,
                  endIndent: 16,
                ),
                ListItem(
                  leading: const Icon(ReIcons.cloudDownload),
                  title: Text(appLocalizations.url),
                  subtitle: Text(appLocalizations.urlDesc),
                  onTap: _toAdd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
