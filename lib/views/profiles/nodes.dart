import 'dart:async';
import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/pages/scan.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'edit_node.dart';

final _plainScalar = RegExp(r'^[A-Za-z_./@][A-Za-z0-9_./@ -]*$');
const _reservedScalars = {'true', 'false', 'null', 'yes', 'no', 'on', 'off'};

String _yamlScalar(Object? value) {
  if (value is! String) return jsonEncode(value);
  final plain =
      _plainScalar.hasMatch(value) &&
      !value.endsWith(' ') &&
      !_reservedScalars.contains(value.toLowerCase());
  return plain ? value : jsonEncode(value);
}

void _writeYaml(StringBuffer buffer, Map<dynamic, dynamic> map, String indent) {
  for (final MapEntry(:key, :value) in map.entries) {
    final name = _yamlScalar(key.toString());
    if (value is Map && value.isNotEmpty) {
      buffer.writeln('$indent$name:');
      _writeYaml(buffer, value, '$indent  ');
      continue;
    }
    if (value is List && value.isNotEmpty) {
      buffer.writeln('$indent$name:');
      for (final item in value) {
        buffer.writeln(
          '$indent  - ${item is Map || item is List ? jsonEncode(item) : _yamlScalar(item)}',
        );
      }
      continue;
    }
    buffer.writeln(
      '$indent$name: ${value is Map || value is List ? jsonEncode(value) : _yamlScalar(value)}',
    );
  }
}

String nodeToYaml(Map<String, dynamic> proxy) {
  final buffer = StringBuffer();
  _writeYaml(buffer, proxy, '');
  return buffer.toString();
}

void showEditNode(BuildContext context, [ProxyNode? node]) {
  final editKey = GlobalKey<EditNodeViewState>();
  final ready = ValueNotifier(node != null);
  showExtend(
    context,
    builder: (_, type) {
      return AdaptiveSheetScaffold(
        type: type,
        actions: [
          ValueListenableBuilder(
            valueListenable: ready,
            builder: (_, value, _) => IconButton(
              icon: const AppIcon(Icons.check),
              tooltip: appLocalizations.save,
              onPressed: value
                  ? () => editKey.currentState?.handleSave()
                  : null,
            ),
          ),
        ],
        body: EditNodeView(key: editKey, node: node, ready: ready),
        title: node == null ? appLocalizations.addNode : appLocalizations.node,
      );
    },
  );
}

Future<ProxyNode?> showAddNodeSheet(BuildContext context) {
  return showSheet<ProxyNode>(
    context: context,
    builder: (_, type) => AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.addNode,
      body: const AddNodeView(),
    ),
  );
}

class AddNodeView extends StatelessWidget {
  const AddNodeView({super.key});

  Future<ProxyNode?> _parse(String text) {
    return globalState.appController.safeRun(
      () => globalState.appController.parseNode(text),
      needLoading: true,
      silence: false,
      title: appLocalizations.addNode,
    );
  }

  Future<void> _import(BuildContext context, String text) async {
    final node = await _parse(text);
    if (node == null || !context.mounted) return;
    Navigator.of(context).pop(node);
  }

  Future<void> _handleClipboard(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (!context.mounted) return;
    if (text == null || text.isEmpty) {
      context.showSnackBar(
        appLocalizations.emptyTip(appLocalizations.clipboard),
      );
      return;
    }
    await _import(context, text);
  }

  Future<void> _handleScan(BuildContext context) async {
    final text = await BaseNavigator.push<String>(
      context,
      ScanPage(accept: (_) => true),
    );
    if (text == null || !context.mounted) return;
    await _import(context, text);
  }

  Future<void> _handleFile(BuildContext context) async {
    final file = await globalState.appController.safeRun(picker.pickerFile);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    await _import(context, utf8.decode(bytes, allowMalformed: true));
  }

  void _handleManual(BuildContext context) {
    BaseNavigator.push(
      context,
      EditorPage(
        title: appLocalizations.addNode,
        content: '',
        languages: const [],
        onSave: (editorContext, _, content) async {
          final node = await _parse(content);
          if (node == null) return;
          if (editorContext.mounted) Navigator.of(editorContext).pop();
          if (context.mounted) Navigator.of(context).pop(node);
        },
      ),
      maintainState: false,
    );
  }

  Future<void> _handleWarp(BuildContext context) async {
    final title = appLocalizations.registerWarp;
    final terms = appLocalizations.cloudflareTerms;
    final [before, after] = appLocalizations
        .registerWarpTip(terms)
        .split(terms);
    final tap = TapGestureRecognizer()
      ..onTap = () =>
          globalState.openUrl('https://www.cloudflare.com/application/terms/');
    final res = await globalState.showMessage(
      title: title,
      message: TextSpan(
        children: [
          TextSpan(text: before),
          TextSpan(
            text: terms,
            style: TextStyle(
              color: context.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: tap,
          ),
          TextSpan(text: after),
        ],
      ),
    );
    tap.dispose();
    if (res != true) return;
    final node = await globalState.appController.safeRun(
      globalState.appController.registerWarp,
      needLoading: true,
      silence: false,
      title: title,
    );
    if (node == null || !context.mounted) return;
    Navigator.of(context).pop(node);
  }

  Widget _buildDivider(BuildContext context) {
    final scheme = context.colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: scheme.outlineVariant.withValues(
        alpha: scheme.brightness == Brightness.light ? 0.6 : 0.45,
      ),
      indent: 16,
      endIndent: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannable = system.isAndroid && !globalState.isAndroidTV;
    final divider = _buildDivider(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        CommonCard(
          type: CommonCardType.filled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListItem(
                leading: const AppIcon(Icons.content_paste),
                title: Text(appLocalizations.clipboard),
                subtitle: Text(appLocalizations.nodeClipboardDesc),
                onTap: () => _handleClipboard(context),
              ),
              if (scannable) ...[
                divider,
                ListItem(
                  leading: const AppIcon(Icons.qr_code_sharp),
                  title: Text(appLocalizations.qrcode),
                  subtitle: Text(appLocalizations.nodeQrcodeDesc),
                  onTap: () => _handleScan(context),
                ),
              ],
              divider,
              ListItem(
                leading: const AppIcon(Icons.upload_file_sharp),
                title: Text(appLocalizations.file),
                subtitle: Text(appLocalizations.nodeFileDesc),
                onTap: () => _handleFile(context),
              ),
              divider,
              ListItem(
                leading: const AppIcon(Icons.edit_outlined),
                title: Text(appLocalizations.manualInput),
                subtitle: Text(appLocalizations.nodeManualDesc),
                onTap: () => _handleManual(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CommonCard(
          type: CommonCardType.filled,
          child: ListItem(
            leading: const AppIcon(Icons.cloud_outlined),
            title: Text(appLocalizations.registerWarp),
            subtitle: Text(appLocalizations.registerWarpDesc),
            onTap: () => _handleWarp(context),
          ),
        ),
      ],
    );
  }
}

class _NodeTag extends StatelessWidget {
  final String label;
  final bool tonal;

  const _NodeTag({required this.label, this.tonal = false});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tonal
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.onSurfaceVariant.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: tonal ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class NodeItem extends ConsumerWidget {
  final ProxyNode node;

  const NodeItem({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (profileId, managed) = ref.watch(
      currentProfileProvider.select(
        (profile) => (profile?.id, profile?.isManaged ?? true),
      ),
    );
    final binding = node.bindingOf(profileId ?? '', managed: managed);
    final front = node.isLanding ? binding?.front : null;
    final missing =
        front != null &&
        ref.watch(
          groupsProvider.select(
            (groups) =>
                groups.isNotEmpty &&
                !groups.any(
                  (item) =>
                      item.name == front ||
                      item.all.any((proxy) => proxy.name == front),
                ),
          ),
        );
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final detail = switch (front) {
      final front? when missing => appLocalizations.frontMissing(front),
      final front? => '${appLocalizations.frontProxy}: $front',
      _ => null,
    };
    return CommonCard(
      onPressed: () => showEditNode(context, node),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: EmojiText(
                          node.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                      if (front != null && !missing) ...[
                        const SizedBox(width: 8),
                        _NodeTag(
                          label: appLocalizations.landingNode,
                          tonal: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _NodeTag(label: node.typeLabel),
                      if (detail != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: EmojiText(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: missing
                                ? muted?.copyWith(color: scheme.error)
                                : muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: node.enable,
              onChanged: (value) {
                ref
                    .read(nodesProvider.notifier)
                    .setNode(node.copyWith(enable: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NodesBody extends ConsumerWidget {
  const NodesBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(nodesProvider);
    final isMobileView = ref.watch(isMobileViewProvider);
    if (nodes.isEmpty) {
      return NullStatus(
        label: appLocalizations.nullNodeDesc,
        icon: Icons.device_hub,
      );
    }
    return ScrollEdgeRise(
      builder: (context, rise) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView.separated(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16 + rise,
              bottom:
                  88 +
                  (isMobileView
                      ? getFloatingBottomBarReserveHeight(context)
                      : 0),
            ),
            itemCount: nodes.length,
            itemBuilder: (_, index) =>
                NodeItem(key: ValueKey(nodes[index].id), node: nodes[index]),
            separatorBuilder: (_, _) => const SizedBox(height: 14),
          ),
        ),
      ),
    );
  }
}
