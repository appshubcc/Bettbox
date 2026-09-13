import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide context;

final geoUpdatingKeysProvider =
    StateProvider.autoDispose<Set<String>>((ref) => {});

@immutable
class GeoItem {
  final String label;
  final String key;
  final String fileName;

  const GeoItem({
    required this.label,
    required this.key,
    required this.fileName,
  });
}

class ResourcesView extends ConsumerWidget {
  const ResourcesView({super.key});

  static const geoItems = <GeoItem>[
    GeoItem(label: 'GeoSite', fileName: geoSiteFileName, key: 'geosite'),
    GeoItem(label: 'MMDB', fileName: mmdbFileName, key: 'mmdb'),
    GeoItem(label: 'ASN', fileName: asnFileName, key: 'asn'),
    GeoItem(label: 'MRS', fileName: bundleMRSFileName, key: 'mrs'),
  ];

  Future<void> _handleSyncAll(WidgetRef ref) async {
    final updatingKeysNotifier = ref.read(geoUpdatingKeysProvider.notifier);
    if (updatingKeysNotifier.state.isNotEmpty) return;

    final syncItems =
        geoItems.where((geoItem) => geoItem.key != 'mrs').toList();
    updatingKeysNotifier.state = syncItems.map((e) => e.key).toSet();

    final errors = <String>[];
    try {
      await Future.wait(
        syncItems.map(
          (geoItem) async {
            try {
              final message = await clashCore.updateGeoData(
                UpdateGeoDataParams(
                  geoName: geoItem.fileName,
                  geoType: geoItem.label,
                ),
              );
              if (message.isNotEmpty) {
                errors.add('${geoItem.label}: $message');
              }
            } catch (e) {
              errors.add('${geoItem.label}: $e');
            } finally {
              updatingKeysNotifier
                  .update((s) => Set.of(s)..remove(geoItem.key));
            }
          },
        ),
      );
      if (errors.isNotEmpty) {
        globalState.showMessage(
          title: appLocalizations.syncFailed,
          message: TextSpan(text: errors.join('\n')),
          cancelable: false,
        );
      }
    } finally {
      updatingKeysNotifier.state = {};
    }
  }

  Future<void> _handleResetAll(WidgetRef ref) async {
    final res = await globalState.showMessage(
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref.read(patchClashConfigProvider.notifier).updateState((state) {
      return state.copyWith(geoXUrl: defaultGeoXUrl);
    });
    await globalState.appController.setupClashConfig();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(
      geoUpdatingKeysProvider.select((keys) => keys.isNotEmpty),
    );

    return CommonScaffold(
      title: appLocalizations.resources,
      actions: [
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => _handleResetAll(ref),
          tooltip: appLocalizations.reset,
        ),
        IconButton(
          icon: isUpdating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          onPressed: isUpdating ? null : () => _handleSyncAll(ref),
          tooltip: appLocalizations.syncAll,
        ),
      ],
      body: ListView(
        padding: EdgeInsets.only(
          bottom: (globalState.isAndroidTV ? 48.0 : 16.0) +
              MediaQuery.of(context).padding.bottom,
          top: 8,
        ),
        children: [
          ...generateSection(
            items: geoItems.map((geoItem) => GeoDataListItem(geoItem: geoItem)),
          ),
        ],
      ),
    );
  }
}

class GeoDataListItem extends ConsumerStatefulWidget {
  final GeoItem geoItem;

  const GeoDataListItem({super.key, required this.geoItem});

  @override
  ConsumerState<GeoDataListItem> createState() => _GeoDataListItemState();
}

class _GeoDataListItemState extends ConsumerState<GeoDataListItem> {
  GeoItem get geoItem => widget.geoItem;

  Future<void> _updateUrl(String url) async {
    final defaultMap = defaultGeoXUrl.toJson();
    final newUrl = await globalState.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: geoItem.label,
        url: url,
        defaultValue: defaultMap[geoItem.key],
      ),
    );
    if (newUrl != null && newUrl != url && mounted) {
      try {
        if (!newUrl.isHttpUrl) {
          throw 'Invalid url';
        }
        ref.read(patchClashConfigProvider.notifier).updateState((state) {
          final map = state.geoXUrl.toJson();
          map[geoItem.key] = newUrl;
          return state.copyWith(geoXUrl: GeoXUrl.fromJson(map));
        });
        await globalState.appController.setupClashConfig();
      } catch (e) {
        globalState.showMessage(
          title: geoItem.label,
          message: TextSpan(text: e.toString()),
          cancelable: false,
        );
      }
    }
  }

  Future<FileInfo> _getGeoFileLastModified(String fileName) async {
    final homePath = await appPath.homeDirPath;
    final file = File(join(homePath, fileName));
    final lastModified = await file.lastModified();
    final size = await file.length();
    return FileInfo(size: size, lastModified: lastModified);
  }

  Future<void> _handleUpdateGeoDataItem() async {
    final updatingKeysNotifier = ref.read(geoUpdatingKeysProvider.notifier);
    if (ref.read(geoUpdatingKeysProvider).contains(geoItem.key)) return;

    await globalState.appController.safeRun<void>(
      () async {
        updatingKeysNotifier.update((s) => Set.of(s)..add(geoItem.key));
        try {
          final message = await clashCore.updateGeoData(
            UpdateGeoDataParams(
              geoName: geoItem.fileName,
              geoType: geoItem.label,
            ),
          );
          if (message.isNotEmpty) throw message;
        } finally {
          updatingKeysNotifier.update((s) => Set.of(s)..remove(geoItem.key));
        }
      },
      silence: false,
      needLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      geoUpdatingKeysProvider.select((s) => s.contains(geoItem.key)),
      (prev, next) {
        if (prev == true && next == false && mounted) {
          setState(() {});
        }
      },
    );

    final url = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.geoXUrl.toJson()[geoItem.key],
      ),
    );
    final isSyncing = ref.watch(
      geoUpdatingKeysProvider.select((s) => s.contains(geoItem.key)),
    );
    final isBundleMRS = geoItem.key == 'mrs';

    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(geoItem.label),
      subtitle: (url == null && !isBundleMRS)
          ? const SizedBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                FutureBuilder<FileInfo>(
                  future: _getGeoFileLastModified(geoItem.fileName),
                  builder: (_, snapshot) {
                    final height = globalState.measure.bodyMediumHeight;
                    return SizedBox(
                      height: height,
                      child: snapshot.data == null
                          ? SizedBox(width: height, height: height)
                          : Text(
                              isBundleMRS
                                  ? '${TrafficValue(value: snapshot.data!.size).show}  ·  Bundled'
                                  : snapshot.data!.desc,
                              style: context.textTheme.bodyMedium,
                            ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  isBundleMRS
                      ? 'https://github.com/appshubcc/bett-rules/releases/download/latest/BundleMRS.7z'
                      : url!,
                  style: context.textTheme.bodyMedium?.toLight,
                ),
                if (!isBundleMRS) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    runSpacing: 6,
                    spacing: 12,
                    runAlignment: WrapAlignment.center,
                    children: [
                      CommonChip(
                        avatar: const Icon(Icons.edit),
                        label: appLocalizations.edit,
                        onPressed: isSyncing ? null : () => _updateUrl(url),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isSyncing
                              ? const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Padding(
                                    padding: EdgeInsets.all(2),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : CommonChip(
                                  avatar: const Icon(Icons.sync),
                                  label: appLocalizations.sync,
                                  onPressed: _handleUpdateGeoDataItem,
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class UpdateGeoUrlFormDialog extends StatefulWidget {
  final String title;
  final String url;
  final String? defaultValue;

  const UpdateGeoUrlFormDialog({
    super.key,
    required this.title,
    required this.url,
    this.defaultValue,
  });

  @override
  State<UpdateGeoUrlFormDialog> createState() => _UpdateGeoUrlFormDialogState();
}

class _UpdateGeoUrlFormDialogState extends State<UpdateGeoUrlFormDialog> {
  late TextEditingController urlController;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: widget.url);
  }

  Future<void> _handleReset() async {
    if (widget.defaultValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.defaultValue);
  }

  Future<void> _handleUpdate() async {
    final url = urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        if (widget.defaultValue != null &&
            urlController.value.text != widget.defaultValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
          const SizedBox(width: 4),
        ],
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Wrap(
        runSpacing: 16,
        children: [
          TextField(
            maxLines: 5,
            minLines: 1,
            controller: urlController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
