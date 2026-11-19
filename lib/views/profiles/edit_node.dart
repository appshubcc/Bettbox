import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/pages/speed_test.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'nodes.dart';
import 'scripts.dart';

const _udpTransportTypes = {
  'wireguard',
  'hysteria',
  'hysteria2',
  'tuic',
  'shadowquic',
};

const _unpickableGroups = {'自动选择', managedAnchorGroup};

class _Pick extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pick({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.14)
          : scheme.surfaceContainerHigh,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: EmojiText(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _BindingEditor extends StatelessWidget {
  final NodeBinding binding;
  final List<String> fronts;
  final List<String> groups;
  final String? tip;
  final String? warning;
  final bool landing;
  final Set<String>? defaults;
  final VoidCallback? onPickFront;
  final ValueChanged<NodeBinding> onChanged;

  const _BindingEditor({
    required this.binding,
    required this.fronts,
    required this.groups,
    required this.onChanged,
    this.tip,
    this.warning,
    this.landing = false,
    this.defaults,
    this.onPickFront,
  });

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  List<String> get _selected {
    final defaults = this.defaults;
    if (defaults == null || !binding.all) return binding.groups;
    return [
      for (final name in groups)
        if (defaults.contains(name)) name,
    ];
  }

  void _toggleGroup(String name) {
    final selected = _selected;
    final next = selected.contains(name)
        ? [
            for (final item in selected)
              if (item != name) item,
          ]
        : [...selected, name];
    onChanged(binding.copyWith(all: false, groups: next));
  }

  @override
  Widget build(BuildContext context) {
    final front = landing ? binding.front : null;
    final tip = this.tip;
    final warning = this.warning;
    final onPickFront = this.onPickFront;
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (landing) ...[
          _buildLabel(context, appLocalizations.frontProxy),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in {...fronts, ?front})
                _Pick(
                  label: name,
                  selected: front == name,
                  onTap: () => onChanged(
                    binding.copyWith(
                      front: name,
                      groups: [
                        for (final item in binding.groups)
                          if (item != name) item,
                      ],
                    ),
                  ),
                ),
              if (onPickFront != null)
                _Pick(
                  label: appLocalizations.chooseFront,
                  selected: false,
                  onTap: onPickFront,
                ),
            ],
          ),
          if (tip != null && front != null) _buildTip(context, tip),
          if (warning != null && front != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                warning,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        _buildLabel(context, appLocalizations.joinGroups),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in groups)
              if (name != front)
                _Pick(
                  label: name,
                  selected: selected.contains(name),
                  onTap: () => _toggleGroup(name),
                ),
          ],
        ),
      ],
    );
  }
}

class EditNodeView extends ConsumerStatefulWidget {
  final ProxyNode? node;
  final ValueNotifier<bool> ready;

  const EditNodeView({super.key, this.node, required this.ready});

  @override
  ConsumerState<EditNodeView> createState() => EditNodeViewState();
}

class EditNodeViewState extends ConsumerState<EditNodeView> {
  late ProxyNode? _node = widget.node;
  late final ProxyNode _initial =
      widget.node ?? const ProxyNode(id: '', proxy: {});
  late NodeRole _role = _initial.role;
  late bool _managedEnable = _initial.managedEnable;
  late NodeBinding _managed = _initial.managed;
  late NodeBinding? _binding;
  bool _managedExpanded = false;
  bool _frontUdp = true;
  String? _udpFront;
  List<String> _regions = const [];
  List<String> _routeGroups = const [];
  Set<String> _serviceGroups = const {};
  Set<String> _nodeRegions = const {};
  bool _testing = false;
  int? _delay;
  bool _tested = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider);
    final managed = profile == null || profile.isManaged;
    _binding = managed ? null : _initial.bindings[profile.id];
    unawaited(_loadManaged());
    unawaited(_syncFrontUdp());
    ref.listenManual(
      groupsProvider,
      (_, _) => unawaited(_syncFrontUdp(force: true)),
    );
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    unawaited(_syncFrontUdp());
  }

  NodeBinding? get _currentBinding {
    final profile = ref.read(currentProfileProvider);
    return profile == null || profile.isManaged ? _managed : _binding;
  }

  String? get _udpCheckFront {
    final node = _node;
    if (node == null ||
        _role != NodeRole.landing ||
        !_udpTransportTypes.contains(node.type.toLowerCase())) {
      return null;
    }
    return _currentBinding?.front;
  }

  Future<void> _syncFrontUdp({bool force = false}) async {
    final front = _udpCheckFront;
    if (!force && front == _udpFront) return;
    _udpFront = front;
    var supported = true;
    if (front != null) {
      try {
        supported = await clashCore.checkDialerUdp(front);
      } catch (_) {
        supported = true;
      }
    }
    if (!mounted || _udpFront != front || supported == _frontUdp) return;
    super.setState(() => _frontUdp = supported);
  }

  Future<void> _loadManaged() async {
    final name = _node?.name;
    final props = ref.read(managedSettingProvider);
    final catalog = (await ManagedScript.catalog()).catalog;
    final script = await ManagedScript.script(
      props.copyWith(routes: const [], order: const []),
      nodeNames: [?name],
    );
    final data = await JavaScriptRuntimeManager.extractScriptOptions(script);
    final (:options, icons: _, :policyGroupOptions) = processScriptOptions(
      data,
      script,
    );
    if (!mounted || _node?.name != name) return;
    final minimal = options['极简国内外分流模式'] == true;
    final regions = minimal
        ? const <String>[]
        : managedRegions(catalog, props.regions, props.customRegions);
    final nodeRegions = data['nodeRegions'];
    final matched = nodeRegions is Map && nodeRegions[name] is List
        ? (nodeRegions[name] as List).whereType<String>().toSet()
        : const <String>{};
    final services = minimal
        ? const <String>{}
        : {
            for (final name in policyGroupOptions)
              if (options[name] == true &&
                  !props.removed.contains(name) &&
                  !_unpickableGroups.contains(name))
                name,
            for (final route in props.routes)
              if (route.enabled &&
                  route.sets.isNotEmpty &&
                  route.target != 'REJECT')
                route.name,
          };
    final order = orderManagedGroups(
      presets: policyGroupOptions.toList(),
      customs: [for (final route in props.routes) route.name],
      saved: props.order,
      regions: regions,
    );
    setState(() {
      _regions = regions;
      _serviceGroups = services;
      _nodeRegions = matched.intersection(regions.toSet());
      _routeGroups = [
        for (final name in order)
          if (services.contains(name) || regions.contains(name)) name,
      ];
    });
  }

  void handleSave() {
    final node = _node;
    if (node == null) return;
    final profile = ref.read(currentProfileProvider);
    final nodes = ref.read(nodesProvider);
    final saved = nodes.any((item) => item.id == node.id);
    final latest = nodes.firstWhere(
      (item) => item.id == node.id,
      orElse: () => node,
    );
    final bindings = {...latest.bindings};
    if (profile != null && !profile.isManaged) {
      if (_binding case final binding?) {
        bindings[profile.id] = binding;
      } else {
        bindings.remove(profile.id);
      }
    }
    final updated = latest.copyWith(
      role: _role,
      managedEnable: _managedEnable,
      managed: _managed,
      bindings: bindings,
    );
    final notifier = ref.read(nodesProvider.notifier);
    if (saved) {
      notifier.setNode(updated);
    } else {
      notifier.add([updated]);
    }
    Navigator.of(context).pop();
  }

  Future<void> _handleAdd() async {
    final node = await showAddNodeSheet(context);
    if (node == null || !mounted) return;
    setState(() {
      _node = node;
      _tested = false;
      _delay = null;
    });
    unawaited(_loadManaged());
    widget.ready.value = true;
  }

  void _handleEdit(ProxyNode current) {
    BaseNavigator.push(
      context,
      EditorPage(
        title: current.name,
        content: nodeToYaml(current.proxy),
        onSave: (editorContext, _, content) async {
          final node = await globalState.appController.safeRun(
            () => globalState.appController.updateNodeProxy(current, content),
            needLoading: true,
            silence: false,
            title: appLocalizations.edit,
          );
          if (node == null) return;
          if (mounted) {
            setState(() => _node = node);
            unawaited(_loadManaged());
          }
          if (editorContext.mounted) Navigator.of(editorContext).pop();
        },
      ),
      maintainState: false,
    );
  }

  Future<void> _handleDelete(ProxyNode node) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.node),
      ),
    );
    if (res != true || !mounted) return;
    ref.read(nodesProvider.notifier).remove(node.id);
    Navigator.of(context).pop();
  }

  List<String> get _managedGroups => {
    managedDefaultGroup,
    managedManualGroup,
    ..._routeGroups,
    ..._managed.groups,
  }.toList();

  Set<String> get _managedDefaults => {
    managedDefaultGroup,
    managedManualGroup,
    ..._serviceGroups,
    if (_role != NodeRole.landing) ..._nodeRegions,
  };

  Future<void> _handlePickFront() async {
    final front = await showFrontPicker(
      selected: _binding?.front ?? '',
      groups: ref.read(currentGroupsStateProvider).value,
      excluded: {?_node?.name},
    );
    final binding = _binding;
    if (front == null || binding == null || !mounted) return;
    setState(() {
      _binding = binding.copyWith(
        front: front,
        groups: [
          for (final item in binding.groups)
            if (item != front) item,
        ],
      );
    });
  }

  Widget _buildCard(Widget child) {
    return CommonCard(
      type: CommonCardType.filled,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CommonCard(
      type: CommonCardType.filled,
      child: ListItem.switchItem(
        title: Text(title),
        subtitle: Text(subtitle),
        delegate: SwitchDelegate(value: value, onChanged: onChanged),
      ),
    );
  }

  Future<void> _handleTest(ProxyNode node) async {
    if (_testing) return;
    setState(() => _testing = true);
    final dialer = _role == NodeRole.landing ? _currentBinding?.front : null;
    final delay = await globalState.appController.safeRun(
      () => globalState.appController.testNode(node, dialer: dialer),
    );
    if (!mounted) return;
    setState(() {
      _testing = false;
      _tested = true;
      _delay = delay;
    });
  }

  Widget _buildBusy() => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  Widget _buildTestResult() {
    if (_testing) return _buildBusy();
    if (!_tested) return const AppIcon(Icons.network_check);
    final delay = _delay;
    final scheme = context.colorScheme;
    return Text(
      delay == null ? appLocalizations.nodeTestFailed : '$delay ms',
      style: context.textTheme.labelLarge?.copyWith(
        color: delay == null ? scheme.error : scheme.primary,
      ),
    );
  }

  Widget _buildDivider() {
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

  Widget _buildNode() {
    final node = _node;
    if (node == null) {
      return CommonCard(
        type: CommonCardType.filled,
        child: ListItem(
          leading: const AppIcon(Icons.add),
          title: Text(appLocalizations.addNode),
          subtitle: Text(appLocalizations.addNodeDesc),
          trailing: const AppIcon(Icons.chevron_right),
          onTap: _handleAdd,
        ),
      );
    }
    return CommonCard(
      type: CommonCardType.filled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListItem(
            title: EmojiText(node.name),
            subtitle: Text(node.typeLabel),
            trailing: const AppIcon(Icons.edit_outlined),
            onTap: () => _handleEdit(node),
          ),
          _buildDivider(),
          ListItem(
            title: Text(appLocalizations.connectivityTest),
            subtitle: Text(appLocalizations.connectivityTestDesc),
            trailing: _buildTestResult(),
            onTap: () => _handleTest(node),
          ),
        ],
      ),
    );
  }

  Widget _buildRole() {
    final landing = _role == NodeRole.landing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentButtonGroup<NodeRole>(
          options: [
            SegmentOption(
              value: NodeRole.landing,
              label: appLocalizations.landingNode,
            ),
            SegmentOption(
              value: NodeRole.regular,
              label: appLocalizations.regularNode,
            ),
          ],
          selected: _role,
          onSelected: (value) => setState(() => _role = value),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
          child: Text(
            landing
                ? appLocalizations.landingNodeDesc
                : appLocalizations.regularNodeDesc,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildManaged(bool managed) {
    final landing = _role == NodeRole.landing;
    return [
      _buildSwitch(
        title: appLocalizations.applyManaged,
        subtitle: appLocalizations.applyManagedDesc,
        value: _managedEnable,
        onChanged: (value) => setState(() => _managedEnable = value),
      ),
      if (_managedEnable) ...[
        const SizedBox(height: 12),
        _buildCard(
          _BindingEditor(
            binding: _managed,
            fronts: _regions,
            groups: _managedGroups,
            tip: appLocalizations.managedNodeTip,
            warning: managed && !_frontUdp
                ? appLocalizations.frontUdpUnsupported
                : null,
            landing: landing,
            defaults: _managedDefaults,
            onChanged: (value) => setState(() => _managed = value),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildProfile(Profile profile, List<Group> groups) {
    final binding = _binding;
    final landing = _role == NodeRole.landing;
    return [
      _buildSwitch(
        title: appLocalizations.injectNode,
        subtitle: appLocalizations.injectNodeDesc,
        value: binding != null,
        onChanged: (value) => setState(() {
          _binding = value ? const NodeBinding() : null;
        }),
      ),
      if (binding != null) ...[
        const SizedBox(height: 12),
        _buildCard(
          groups.isEmpty
              ? Text(
                  appLocalizations.injectNodeEmpty,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                )
              : _BindingEditor(
                  binding: binding,
                  fronts: const [],
                  warning: _frontUdp
                      ? null
                      : appLocalizations.frontUdpUnsupported,
                  landing: landing,
                  groups: [
                    for (final group in groups)
                      if (group.type == GroupType.Selector &&
                          group.name != GroupName.GLOBAL.name)
                        group.name,
                  ],
                  onPickFront: _handlePickFront,
                  onChanged: (value) => setState(() => _binding = value),
                ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final groups = ref.watch(groupsProvider);
    final managed = profile == null || profile.isManaged;
    final hasManaged =
        managed ||
        ref.watch(
          profilesProvider.select(
            (profiles) => profiles.any((item) => item.isManaged),
          ),
        );
    final expanded = managed || _managedExpanded;
    return ScrollEdgeRise(
      builder: (_, rise) => ListView(
        padding: EdgeInsets.fromLTRB(16, 12 + rise, 16, 24),
        children: [
          _buildNode(),
          ListHeader(
            title: appLocalizations.nodeRole,
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
          ),
          _buildRole(),
          if (profile != null && !profile.isManaged) ...[
            ListHeader(
              title: profile.label ?? profile.id,
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
            ),
            ..._buildProfile(profile, groups),
          ],
          if (hasManaged) ...[
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: managed
                  ? null
                  : () => setState(() => _managedExpanded = !_managedExpanded),
              child: ListHeader(
                title: appLocalizations.managedMode,
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                actions: [
                  if (!managed)
                    AppIcon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
            if (expanded) ..._buildManaged(managed),
          ],
          if (widget.node case final node?) ...[
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () => _handleDelete(node),
                icon: AppIcon(
                  Icons.delete_outlined,
                  color: context.colorScheme.error,
                ),
                label: Text(
                  appLocalizations.delete,
                  style: TextStyle(color: context.colorScheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
