import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/views/proxies/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path/path.dart' hide context;

final geoUpdatingKeysProvider = StateProvider.autoDispose<Set<String>>(
  (ref) => {},
);

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

class ResourcesView extends ConsumerStatefulWidget {
  const ResourcesView({super.key});

  @override
  ConsumerState<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends ConsumerState<ResourcesView> {
  bool? _showProviders;

  static const geoItems = <GeoItem>[
    GeoItem(label: 'GeoSite', fileName: geoSiteFileName, key: 'geosite'),
    GeoItem(label: 'MMDB', fileName: mmdbFileName, key: 'mmdb'),
    GeoItem(label: 'ASN', fileName: asnFileName, key: 'asn'),
    GeoItem(label: 'MRS', fileName: bundleMRSFileName, key: 'mrs'),
  ];

  Future<void> _handleSyncAll() async {
    final updatingKeysNotifier = ref.read(geoUpdatingKeysProvider.notifier);
    if (updatingKeysNotifier.state.isNotEmpty) return;

    final syncItems = geoItems
        .where((geoItem) => geoItem.key != 'mrs')
        .toList();
    updatingKeysNotifier.state = syncItems.map((e) => e.key).toSet();

    final errors = <String>[];
    try {
      await Future.wait(
        syncItems.map((geoItem) async {
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
            if (mounted) {
              updatingKeysNotifier.update(
                (s) => Set.of(s)..remove(geoItem.key),
              );
            }
          }
        }),
      );
      if (errors.isNotEmpty) {
        globalState.showMessage(
          title: appLocalizations.syncFailed,
          message: TextSpan(text: errors.join('\n')),
          cancelable: false,
        );
      }
    } finally {
      if (mounted) {
        updatingKeysNotifier.state = {};
      }
    }
  }

  Future<void> _handleResetAll() async {
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

  Widget _buildTitleItem(String label, bool showProviders) {
    final isCurrent = _showProviders == showProviders;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isCurrent
          ? null
          : () {
              setState(() {
                _showProviders = showProviders;
              });
            },
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isCurrent
            ? null
            : TextStyle(
                color: context.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: _buildTitleItem(appLocalizations.providers, true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '|',
            style: TextStyle(
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.5,
              ),
            ),
          ),
        ),
        Flexible(child: _buildTitleItem(appLocalizations.resources, false)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = ref.watch(
      geoUpdatingKeysProvider.select((keys) => keys.isNotEmpty),
    );
    final hasProviders = ref.watch(
      providersProvider.select((state) => state.isNotEmpty),
    );
    final showProviders = hasProviders && (_showProviders ??= true);

    if (showProviders) {
      return CommonScaffold(
        titleWidget: _buildTitle(),
        actions: [
          IconButton(
            onPressed: () => updateExternalProviders(ref, context),
            tooltip: appLocalizations.update,
            icon: const Icon(Icons.sync),
          ),
        ],
        body: const ProvidersBody(),
      );
    }

    return CommonScaffold(
      title: hasProviders ? null : appLocalizations.resources,
      titleWidget: hasProviders ? _buildTitle() : null,
      actions: hasProviders
          ? [
              CommonPopupBox(
                targetBuilder: (open) {
                  return IconButton(
                    onPressed: () {
                      open(offset: const Offset(0, 20));
                    },
                    tooltip: appLocalizations.more,
                    icon: isUpdating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: SyncedLoading(
                              size: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.more_vert),
                  );
                },
                popup: CommonPopupMenu(
                  items: [
                    PopupMenuItemData(
                      icon: Icons.sync,
                      label: appLocalizations.syncAll,
                      onPressed: isUpdating ? null : _handleSyncAll,
                    ),
                    PopupMenuItemData(
                      icon: Icons.replay,
                      label: appLocalizations.reset,
                      onPressed: _handleResetAll,
                    ),
                  ],
                ),
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: _handleResetAll,
                tooltip: appLocalizations.reset,
              ),
              IconButton(
                icon: isUpdating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: SyncedLoading(
                          size: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.sync),
                onPressed: isUpdating ? null : _handleSyncAll,
                tooltip: appLocalizations.syncAll,
              ),
            ],
      body: ScrollEdgeRise(
        builder: (context, rise) => ListView(
          padding: EdgeInsets.only(
            bottom: 16.0 + MediaQuery.paddingOf(context).bottom,
            top: 8 + rise,
          ),
          children: [
            ListHeader(
              title: appLocalizations.geoBuiltInResources,
              padding: const EdgeInsets.only(
                left: 16,
                right: 8,
                top: 4,
                bottom: 8,
              ),
              actions: [
                if (Theme.of(context).materialTapTargetSize ==
                    MaterialTapTargetSize.padded)
                  const SizedBox(height: kMinInteractiveDimension),
              ],
            ),
            ...generateSection(
              items: geoItems.map(
                (geoItem) => GeoDataListItem(geoItem: geoItem),
              ),
            ),
          ],
        ),
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
    final defaultValue = switch (geoItem.key) {
      'mmdb' => defaultGeoXUrl.mmdb,
      'asn' => defaultGeoXUrl.asn,
      'geosite' => defaultGeoXUrl.geosite,
      _ => null,
    };
    final newUrl = await globalState.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: geoItem.label,
        url: url,
        defaultValue: defaultValue,
      ),
    );
    if (newUrl != null && newUrl != url && mounted) {
      try {
        if (!newUrl.isHttpUrl) {
          throw 'Invalid url';
        }
        ref.read(patchClashConfigProvider.notifier).updateState((state) {
          final geoXUrl = switch (geoItem.key) {
            'mmdb' => state.geoXUrl.copyWith(mmdb: newUrl),
            'asn' => state.geoXUrl.copyWith(asn: newUrl),
            'geosite' => state.geoXUrl.copyWith(geosite: newUrl),
            _ => state.geoXUrl,
          };
          return state.copyWith(geoXUrl: geoXUrl);
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
          if (mounted) {
            updatingKeysNotifier.update((s) => Set.of(s)..remove(geoItem.key));
          }
        }
      },
      silence: false,
      needLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(geoUpdatingKeysProvider.select((s) => s.contains(geoItem.key)), (
      prev,
      next,
    ) {
      if (prev == true && next == false && mounted) {
        setState(() {});
      }
    });

    final url = ref.watch(
      patchClashConfigProvider.select(
        (state) => switch (geoItem.key) {
          'mmdb' => state.geoXUrl.mmdb,
          'asn' => state.geoXUrl.asn,
          'geosite' => state.geoXUrl.geosite,
          _ => null,
        },
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
                        onPressed: isSyncing || url == null
                            ? null
                            : () => _updateUrl(url),
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
                                    child: SyncedLoading(
                                      size: 26,
                                      child: CircularProgressIndicator(),
                                    ),
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

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
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
