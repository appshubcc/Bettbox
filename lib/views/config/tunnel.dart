import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/clash_config.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TunnelListWidget extends ConsumerWidget {
  const TunnelListWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final tunnels = ref.watch(
      patchClashConfigProvider.select((state) => state.tunnels),
    );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tunnels.length,
      itemBuilder: (context, index) {
        final tunnel = tunnels[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CommonCard(
            child: ListItem(
              title: Text(tunnel.displayValue),
              onTap: () => _showTunnelDialog(
                context,
                ref,
                tunnels,
                tunnel: tunnel,
                index: index,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteTunnel(ref, tunnels, index),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteTunnel(WidgetRef ref, List<TunnelEntry> tunnels, int index) {
    final newTunnels = List<TunnelEntry>.from(tunnels);
    newTunnels.removeAt(index);
    ref
        .read(patchClashConfigProvider.notifier)
        .updateState((state) => state.copyWith(tunnels: newTunnels));
  }

  void _showTunnelDialog(
    BuildContext context,
    WidgetRef ref,
    List<TunnelEntry> tunnels, {
    TunnelEntry? tunnel,
    int? index,
  }) {
    showDialog(
      context: context,
      builder: (context) => _TunnelDialog(
        tunnel: tunnel,
        onSave: (newTunnel) {
          final newTunnels = List<TunnelEntry>.from(tunnels);
          if (index != null) {
            newTunnels[index] = newTunnel;
          } else {
            newTunnels.add(newTunnel);
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(tunnels: newTunnels));
        },
      ),
    );
  }
}

class _TunnelDialog extends StatefulWidget {
  final TunnelEntry? tunnel;
  final Function(TunnelEntry) onSave;

  const _TunnelDialog({this.tunnel, required this.onSave});

  @override
  State<_TunnelDialog> createState() => _TunnelDialogState();
}

class _TunnelDialogState extends State<_TunnelDialog> {
  late TextEditingController _networkController;
  late TextEditingController _addressController;
  late TextEditingController _targetController;
  late TextEditingController _proxyController;

  @override
  void initState() {
    super.initState();
    _networkController = TextEditingController(
      text: widget.tunnel?.network?.join(', ') ?? '',
    );
    _addressController = TextEditingController(
      text: widget.tunnel?.address ?? '',
    );
    _targetController = TextEditingController(
      text: widget.tunnel?.target ?? '',
    );
    _proxyController = TextEditingController(
      text: widget.tunnel?.proxyName ?? '',
    );
  }

  @override
  void dispose() {
    _networkController.dispose();
    _addressController.dispose();
    _targetController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.tunnel == null
            ? appLocalizations.addTunnel
            : appLocalizations.editTunnel,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _networkController,
              decoration: InputDecoration(
                labelText: appLocalizations.tunnelNetwork,
                hintText: appLocalizations.tunnelNetworkHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: appLocalizations.tunnelAddress,
                hintText: appLocalizations.tunnelAddressHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: appLocalizations.tunnelTarget,
                hintText: appLocalizations.tunnelTargetHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _proxyController,
              decoration: InputDecoration(
                labelText: appLocalizations.tunnelProxy,
                hintText: appLocalizations.tunnelProxyHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            final network = _networkController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            final address = _addressController.text.trim();
            final target = _targetController.text.trim();
            final proxy = _proxyController.text.trim();

            if (address.isEmpty || target.isEmpty) {
              if (context.mounted) {
                context.showSnackBar(
                  appLocalizations.emptyTip(appLocalizations.tunnelAddress),
                );
              }
              return;
            }

            final newTunnel = TunnelEntry(
              id: widget.tunnel?.id ?? utils.uuidV4,
              network: network.isEmpty ? null : network,
              address: address.isEmpty ? null : address,
              target: target.isEmpty ? null : target,
              proxyName: proxy.isEmpty ? null : proxy,
            );

            widget.onSave(newTunnel);
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.save),
        ),
      ],
    );
  }
}

class TunnelListView extends ConsumerWidget {
  const TunnelListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final tunnels = ref.watch(
      patchClashConfigProvider.select((state) => state.tunnels),
    );

    return Scaffold(
      body: tunnels.isEmpty
          ? Center(child: NullStatus(label: appLocalizations.noData))
          : ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [const TunnelListWidget()],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTunnelDialog(context, ref, tunnels),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTunnelDialog(
    BuildContext context,
    WidgetRef ref,
    List<TunnelEntry> tunnels,
  ) {
    showDialog(
      context: context,
      builder: (context) => _TunnelDialog(
        tunnel: null,
        onSave: (newTunnel) {
          final newTunnels = List<TunnelEntry>.from(tunnels);
          newTunnels.add(newTunnel);
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(tunnels: newTunnels));
        },
      ),
    );
  }
}
