import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/icon_sets.dart';
import 'package:bett_box/views/profiles/scripts.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _rejectTarget = 'REJECT';
const _largeRuleSetCount = 10000;

final _searchKeyPattern = RegExp(r'[^\p{L}\p{N}]', unicode: true);

Future<void> showManagedOptions(BuildContext context) async {
  await showExtend(
    context,
    builder: (_, type) => ManagedOptionsSheet(type: type),
  );
}

Future<void> syncManagedScript(BuildContext context, WidgetRef ref) async {
  final res = await globalState.showMessage(
    title: appLocalizations.syncFromUpstream,
    message: TextSpan(text: appLocalizations.managedSyncTip),
  );
  if (res != true || !context.mounted) return;
  final props = ref.read(managedSettingProvider);
  final version = await globalState.appController.safeRun(
    () => ManagedScript.sync(props),
    needLoading: true,
    silence: false,
  );
  if (version == null || !context.mounted) return;
  if (version == ManagedScript.version(props)) {
    context.showNotifier(appLocalizations.managedUpToDate);
    return;
  }
  globalState.appController.updateManagedSetting(
    (state) => state.copyWith(syncedVersion: version),
  );
}

String _targetLabel(String target) =>
    target == _rejectTarget ? appLocalizations.reject : target;

String _searchKey(String value) =>
    value.toLowerCase().replaceAll(_searchKeyPattern, '');

String _iconName(String icon) {
  final name = icon.substring(icon.lastIndexOf('/') + 1);
  return name.endsWith('.svg') ? name.substring(0, name.length - 4) : name;
}

class _SearchIndex<T> {
  final List<T> items;
  final Iterable<String> Function(T item) _fields;
  late final _keys = [
    for (final item in items)
      [for (final value in _fields(item)) _searchKey(value)],
  ];
  String _query = '';
  late List<T> _result = items;

  _SearchIndex(this.items, this._fields);

  List<T> search(String input) {
    final query = _searchKey(input);
    if (query == _query) return _result;
    _query = query;
    return _result = query.isEmpty ? items : _rank(query);
  }

  List<T> _rank(String query) {
    final ranked = <({int score, int index})>[];
    for (final (index, keys) in _keys.indexed) {
      var score = -1;
      for (final key in keys) {
        final current = key == query
            ? 0
            : key.startsWith(query)
            ? 1
            : key.contains(query)
            ? 2
            : -1;
        if (current >= 0 && (score < 0 || current < score)) score = current;
      }
      if (score >= 0) ranked.add((score: score, index: index));
    }
    ranked.sort(
      (a, b) => a.score != b.score
          ? a.score.compareTo(b.score)
          : a.index.compareTo(b.index),
    );
    return [for (final entry in ranked) items[entry.index]];
  }
}

typedef _Preset = ({String name, String? icon, bool enabled, bool removed});

typedef _RouteChanges = ({
  List<CustomRoute> added,
  Set<String> removed,
  Map<String, bool> presets,
});

String _categoryLabel(RouteCategory category) => switch (category) {
  RouteCategory.ai => appLocalizations.routeCategoryAi,
  RouteCategory.streaming => appLocalizations.routeCategoryStreaming,
  RouteCategory.social => appLocalizations.routeCategorySocial,
  RouteCategory.gaming => appLocalizations.routeCategoryGaming,
  RouteCategory.developer => appLocalizations.routeCategoryDeveloper,
  RouteCategory.finance => appLocalizations.routeCategoryFinance,
  RouteCategory.tech => appLocalizations.routeCategoryTech,
  RouteCategory.other => appLocalizations.other,
};

int _ruleCount(RouteCatalogIndex catalog, List<String> keys) =>
    keys.fold(0, (sum, key) => sum + (catalog.sets[key]?.count ?? 0));

class _RouteIcon extends StatelessWidget {
  final String? url;
  final double size;

  const _RouteIcon({required this.url, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final src = url;
    if (src == null || src.isEmpty) return Icon(Icons.alt_route, size: size);
    return CommonTargetIcon(src: src, size: size);
  }
}

class _ServicePill extends StatelessWidget {
  final String? icon;
  final String label;
  final bool selected;
  final bool present;
  final bool removing;
  final bool enabled;
  final String? tag;
  final VoidCallback? onTap;

  const _ServicePill({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.present = false,
    this.removing = false,
    this.enabled = true,
    this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final tag = this.tag;
    final trailing = removing
        ? Icon(Icons.remove_circle, size: 16, color: colorScheme.error)
        : !enabled
        ? Text(appLocalizations.disabled, style: textTheme.labelSmall?.toLight)
        : present
        ? Icon(Icons.check_circle, size: 16, color: colorScheme.primary)
        : tag == null
        ? null
        : Text(
            tag,
            style: textTheme.labelSmall?.copyWith(color: colorScheme.tertiary),
          );
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: removing
            ? colorScheme.errorContainer.withValues(alpha: 0.5)
            : selected
            ? colorScheme.secondaryContainer
            : present
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : colorScheme.surfaceContainerLowest,
        shape: StadiumBorder(
          side: BorderSide(
            color: removing
                ? colorScheme.error
                : selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: removing || selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 8, trailing == null ? 14 : 12, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 7,
              children: [
                _RouteIcon(url: icon, size: 22),
                Text(label, style: textTheme.labelLarge),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  const _SearchField({
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final onSubmitted = this.onSubmitted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: onSubmitted == null
            ? TextInputAction.search
            : TextInputAction.done,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class ManagedOptionsSheet extends ConsumerStatefulWidget {
  final SheetType type;

  const ManagedOptionsSheet({super.key, required this.type});

  @override
  ConsumerState<ManagedOptionsSheet> createState() =>
      _ManagedOptionsSheetState();
}

class _ManagedOptionsSheetState extends ConsumerState<ManagedOptionsSheet> {
  RouteCatalogIndex? _catalog;
  Set<String> _groupNames = {};
  List<String> _others = [];
  Map<String, bool> _options = {};
  Map<String, String> _icons = {};
  Map<String, bool> _defaults = {};
  List<String> _presets = [];
  late Set<String> _removed;
  late List<CustomRoute> _routes;
  List<String> _order = [];
  bool _reordered = false;
  bool _sorting = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final props = ref.read(managedSettingProvider);
    _routes = props.routes;
    _removed = props.removed.toSet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_load);
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    final props = ref.read(managedSettingProvider);
    final data = await globalState.appController.safeRun(
      silence: false,
      () async {
        final script = await ManagedScript.script(
          props.copyWith(routes: const [], order: const []),
        );
        final catalog = await ManagedScript.catalog(props);
        final options = await JavaScriptRuntimeManager.extractScriptOptions(
          script,
        );
        return (catalog: catalog, script: script, options: options);
      },
    );
    if (!mounted) return;
    if (data == null) {
      Navigator.of(context).pop();
      return;
    }
    final (:options, :icons, :policyGroupOptions) = processScriptOptions(
      data.options,
      data.script,
    );
    final presets = [
      for (final name in policyGroupOptions)
        if (options.containsKey(name)) name,
    ];
    final defaults = data.options['options'];
    setState(() {
      _presets = presets;
      _defaults = {
        for (final name in presets)
          name: defaults is Map && defaults[name] is bool
              ? defaults[name] as bool
              : true,
      };
      _catalog = data.catalog;
      _groupNames = policyGroupOptions;
      _others = [
        for (final key in options.keys)
          if (!policyGroupOptions.contains(key)) key,
      ];
      _options = options;
      _icons = icons;
      _order = _arrange(props.order);
    });
  }

  List<String> _arrange(List<String> saved) => orderManagedGroups(
    presets: [
      for (final name in _presets)
        if (!_removed.contains(name)) name,
    ],
    customs: [for (final route in _routes) route.name],
    saved: saved,
  );

  void _change(VoidCallback callback) {
    setState(() {
      callback();
      _dirty = true;
    });
  }

  void _handleAdded(CustomRoute route) {
    _change(() {
      _routes = [..._routes, route];
      final order = List.of(_order);
      final anchor = order.indexOf(managedAnchorGroup);
      order.insert(anchor < 0 ? order.length : anchor, route.name);
      _order = order;
    });
  }

  void _handleApplied(_RouteChanges changes) {
    final removed = {
      for (final route in _routes)
        if (changes.removed.contains(route.id)) route.name,
    };
    _change(() {
      _routes = [
        for (final route in _routes)
          if (!changes.removed.contains(route.id)) route,
        ...changes.added,
      ];
      final order = [
        for (final name in _order)
          if (!removed.contains(name)) name,
      ];
      final anchor = order.indexOf(managedAnchorGroup);
      order.insertAll(anchor < 0 ? order.length : anchor, [
        for (final route in changes.added) route.name,
      ]);
      for (final MapEntry(key: name, value: kept) in changes.presets.entries) {
        if (kept) {
          _removed.remove(name);
        } else {
          _removed.add(name);
        }
        _options[name] = kept;
      }
      _order = _arrange(order);
    });
  }

  void _handleReset() {
    _change(() {
      _removed.clear();
      _options.addAll(_defaults);
      _order = _arrange(_order);
    });
  }

  void _handleUpdated(CustomRoute previous, CustomRoute route) {
    _change(() {
      _routes = [
        for (final item in _routes) item.id == route.id ? route : item,
      ];
      _order = [
        for (final name in _order) name == previous.name ? route.name : name,
      ];
    });
  }

  void _handleDeleted(CustomRoute route) {
    _change(() {
      _routes = [
        for (final item in _routes)
          if (item.id != route.id) item,
      ];
      _order = [
        for (final name in _order)
          if (name != route.name) name,
      ];
    });
  }

  void _persist() {
    final saved = ref.read(managedSettingProvider).order;
    final options = Map<String, bool>.from(_options);
    final routes = _routes;
    final removed = [..._removed];
    final order = _reordered || saved.isNotEmpty ? _order : const <String>[];
    globalState.appController.updateManagedSetting(
      (state) => state.copyWith(
        options: options,
        routes: routes,
        order: order,
        removed: removed,
      ),
    );
    _dirty = false;
  }

  Future<void> _handleSave() async {
    if (!_dirty) return;
    _persist();
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    if (_sorting) {
      setState(() => _sorting = false);
      return false;
    }
    if (!_dirty) return true;
    return showSaveChangesDialog(onSave: _handleSave);
  }

  Future<void> _handleOpenOtherOptions() async {
    await showScriptOtherOptions(
      context,
      values: {for (final key in _others) key: _options[key] ?? true},
      icons: _icons,
      onSave: (values) async {
        if (!mounted) return;
        setState(() {
          _options.addAll(values);
          _persist();
        });
      },
    );
  }

  Future<void> _handleEdit(
    RouteCatalogIndex catalog, [
    CustomRoute? route,
  ]) async {
    await showExtend(
      context,
      builder: (_, type) => _RouteSheet(
        type: type,
        catalog: catalog,
        route: route,
        presets: [
          for (final name in _order)
            if (_groupNames.contains(name))
              (
                name: name,
                icon: _icons[name],
                enabled: _options[name] ?? true,
                removed: false,
              ),
          for (final name in _presets)
            if (_removed.contains(name))
              (name: name, icon: _icons[name], enabled: false, removed: true),
        ],
        routes: [
          for (final item in _routes)
            if (item.id != route?.id) item,
        ],
        reserved: {
          ...catalog.catalog.reserved,
          ..._groupNames,
          for (final item in _routes)
            if (item.id != route?.id) item.name,
        },
        onSave: (value) =>
            route == null ? _handleAdded(value) : _handleUpdated(route, value),
        onApply: route == null ? _handleApplied : null,
        onReset: route == null ? _handleReset : null,
        onDelete: route == null ? null : () => _handleDeleted(route),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    RouteCatalogIndex catalog,
    Map<String, CustomRoute> routes,
    int index,
  ) {
    final name = _order[index];
    final route = routes[name];
    final tile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: _RouteIcon(
        url: route == null ? _icons[name] : catalog.iconUrlOf(route),
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _sorting
          ? ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.drag_handle,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Switch(
              value: route?.enabled ?? _options[name] ?? true,
              onChanged: (value) => route == null
                  ? _change(() => _options[name] = value)
                  : _handleUpdated(route, route.copyWith(enabled: value)),
            ),
      onTap: _sorting || route == null
          ? null
          : () => _handleEdit(catalog, route),
    );
    return Padding(
      key: ValueKey(name),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CommonCard(
        type: CommonCardType.filled,
        child: _sorting
            ? ReorderableDelayedDragStartListener(index: index, child: tile)
            : tile,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final catalog = _catalog;
    if (catalog == null) {
      return const Center(
        child: SyncedLoading(size: 40, child: CircularProgressIndicator()),
      );
    }
    final routes = {for (final route in _routes) route.name: route};
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      header: _sorting
          ? Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                appLocalizations.groupOrderTip,
                style: context.textTheme.labelSmall?.toLight,
              ),
            )
          : null,
      footer: _sorting || _others.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CommonCard(
                type: CommonCardType.filled,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(appLocalizations.scriptOtherOptions),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleOpenOtherOptions,
                ),
              ),
            ),
      itemCount: _order.length,
      onReorderItem: (oldIndex, newIndex) => _change(() {
        final order = List.of(_order);
        order.insert(newIndex, order.removeAt(oldIndex));
        _order = order;
        _reordered = true;
      }),
      itemBuilder: (context, index) =>
          _buildItem(context, catalog, routes, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    return CommonPopScope(
      onPop: _confirmDiscard,
      child: AdaptiveSheetScaffold(
        type: widget.type,
        title: appLocalizations.builtInManagedMode,
        actions: _sorting
            ? [
                IconButton(
                  onPressed: () => setState(() => _sorting = false),
                  icon: const Icon(Icons.check),
                  tooltip: appLocalizations.confirm,
                ),
              ]
            : [
                if (_dirty)
                  IconButton(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.save),
                    tooltip: appLocalizations.save,
                  ),
                IconButton(
                  onPressed: catalog == null
                      ? null
                      : () => _handleEdit(catalog),
                  icon: const Icon(Icons.add),
                  tooltip: appLocalizations.addRoute,
                ),
                IconButton(
                  onPressed: catalog == null
                      ? null
                      : () => setState(() => _sorting = true),
                  icon: const Icon(Icons.swap_vert),
                  tooltip: appLocalizations.ruleSort,
                ),
              ],
        body: FadeBox(alignment: Alignment.center, child: _buildBody(context)),
      ),
    );
  }
}

class _RouteSheet extends StatefulWidget {
  final SheetType type;
  final RouteCatalogIndex catalog;
  final CustomRoute? route;
  final List<_Preset> presets;
  final List<CustomRoute> routes;
  final Set<String> reserved;
  final ValueChanged<CustomRoute> onSave;
  final ValueChanged<_RouteChanges>? onApply;
  final VoidCallback? onReset;
  final VoidCallback? onDelete;

  const _RouteSheet({
    required this.type,
    required this.catalog,
    required this.route,
    required this.presets,
    required this.routes,
    required this.reserved,
    required this.onSave,
    this.onApply,
    this.onReset,
    this.onDelete,
  });

  @override
  State<_RouteSheet> createState() => _RouteSheetState();
}

class _RouteSheetState extends State<_RouteSheet> {
  late final _nameController = TextEditingController(
    text: widget.route?.name ?? '',
  );
  late bool _auto = widget.route == null;
  String _query = '';
  final List<RouteService> _added = [];
  final Set<String> _removed = {};
  final Map<String, bool> _toggles = {};
  late String? _icon = widget.route?.icon;
  late List<String> _sets = [...?widget.route?.sets];
  late String? _target = widget.route?.target;
  String? _error;
  bool _dirty = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  CustomRoute get _draft => CustomRoute(
    id: widget.route?.id ?? utils.uuidV4,
    name: _nameController.text.trim(),
    icon: _icon,
    sets: _sets,
    target: _target,
    enabled: widget.route?.enabled ?? true,
  );

  late final _routeOf = {for (final route in widget.routes) route.name: route};

  late final _serviceNames = {
    for (final service in widget.catalog.catalog.services) service.name,
  };

  bool _keptOf(_Preset preset) => _toggles[preset.name] ?? !preset.removed;

  List<String> get _enabledGroups => [
    for (final preset in widget.presets)
      if (_keptOf(preset) && (preset.removed || preset.enabled)) preset.name,
  ];

  bool get _hasChanges =>
      _added.isNotEmpty || _removed.isNotEmpty || _toggles.isNotEmpty;

  late final _serviceIndex = _SearchIndex<RouteService>(
    widget.catalog.catalog.services,
    (service) => [
      service.name,
      ...service.keywords,
      for (final key in service.sets) key.split(':').last,
    ],
  );

  List<RouteService> get _services => _serviceIndex.search(_query);

  bool _available(RouteService service) =>
      !widget.reserved.contains(service.name);

  List<RouteService> _pendingOf(List<RouteService> services) {
    if (_added.isNotEmpty) return _added;
    if (_hasChanges || _query.trim().isEmpty) return const [];
    final first = services.firstOrNull;
    return first != null && _available(first) ? [first] : const [];
  }

  void _togglePreset(_Preset preset) {
    setState(() {
      final next = !_keptOf(preset);
      if (next == !preset.removed) {
        _toggles.remove(preset.name);
      } else {
        _toggles[preset.name] = next;
      }
    });
  }

  void _toggleRemoved(CustomRoute route) {
    setState(() {
      if (!_removed.remove(route.id)) _removed.add(route.id);
    });
  }

  void _toggleAdded(RouteService service) {
    setState(() {
      if (!_added.remove(service)) _added.add(service);
    });
  }

  void _change(VoidCallback callback) {
    setState(() {
      callback();
      _dirty = true;
    });
  }

  void _switchMode(bool auto) {
    setState(() {
      _auto = auto;
      final service = _pendingOf(_services).firstOrNull;
      if (auto ||
          service == null ||
          _sets.isNotEmpty ||
          _nameController.text.trim().isNotEmpty) {
        return;
      }
      _nameController.text = service.name;
      _icon = service.icon;
      _sets = [...service.sets];
    });
  }

  String? _validate(String name) {
    if (name.isEmpty) return appLocalizations.emptyTip(appLocalizations.name);
    if (name.contains(RegExp(r'[,\r\n]'))) {
      return appLocalizations.routeNameInvalid;
    }
    if (widget.reserved.contains(name)) {
      return appLocalizations.existsTip(appLocalizations.name);
    }
    return null;
  }

  void _handleSaveAuto() {
    final pending = _pendingOf(_services);
    if (pending.isNotEmpty || _removed.isNotEmpty || _toggles.isNotEmpty) {
      widget.onApply?.call((
        added: [
          for (final service in pending)
            CustomRoute(
              id: utils.uuidV4,
              name: service.name,
              icon: service.icon,
              sets: service.sets,
              target: _target,
            ),
        ],
        removed: {..._removed},
        presets: {..._toggles},
      ));
    }
    _added.clear();
    _removed.clear();
    _toggles.clear();
    Navigator.of(context).pop();
  }

  Future<void> _handleSave() async {
    if (_auto) {
      _handleSaveAuto();
      return;
    }
    final draft = _draft;
    final error = _validate(draft.name);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (draft.sets.isEmpty) {
      context.showNotifier(
        appLocalizations.emptyTip(appLocalizations.ruleSets),
      );
      return;
    }
    widget.onSave(draft);
    _dirty = false;
    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    final res = await globalState.showMessage(
      title: appLocalizations.delete,
      message: TextSpan(
        text: appLocalizations.deleteTip(widget.route?.name ?? ''),
      ),
    );
    if (res != true || !mounted) return;
    widget.onDelete?.call();
    _dirty = false;
    Navigator.of(context).pop();
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      title: appLocalizations.reset,
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (res != true || !mounted) return;
    widget.onReset?.call();
    _added.clear();
    _removed.clear();
    _toggles.clear();
    _dirty = false;
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    if (!(_auto ? _hasChanges : _dirty)) return true;
    return showSaveChangesDialog(onSave: _handleSave);
  }

  Future<void> _handlePickSets() async {
    await showExtend(
      context,
      builder: (_, type) => _RuleSetPickerSheet(
        type: type,
        catalog: widget.catalog,
        selected: _sets,
        onSave: (sets) => _change(() {
          _sets = sets;
          final first = sets.firstOrNull;
          if (_nameController.text.trim().isEmpty && first != null) {
            _nameController.text = widget.catalog.sets[first]?.label ?? '';
            _error = null;
          }
        }),
      ),
    );
  }

  Future<void> _handleAddUrl() async {
    final key = await globalState.showCommonDialog<String>(
      child: _MrsUrlDialog(existing: _sets.toSet()),
    );
    if (key == null || !mounted) return;
    _change(() {
      _sets = [..._sets, key];
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = CustomRuleSet.parse(key)?.name ?? '';
        _error = null;
      }
    });
  }

  Future<void> _handlePickIcon() async {
    final draft = _draft;
    final icon = _icon;
    final autoIcon = widget.catalog.autoIcon(draft.name, draft.sets);
    await showIconPicker(
      context,
      selected: icon == null || icon.isHttpUrl ? icon : routeIconUrl(icon),
      options: [
        IconPickerOption(
          icon: autoIcon == null || autoIcon.isEmpty
              ? const Icon(Icons.auto_awesome_outlined, size: 28)
              : _RouteIcon(url: routeIconUrl(autoIcon), size: 28),
          label: appLocalizations.auto,
          selected: icon == null,
          value: null,
        ),
        IconPickerOption(
          icon: const Icon(Icons.hide_image_outlined, size: 28),
          label: appLocalizations.noIcon,
          selected: icon == '',
          value: '',
        ),
      ],
      onSelect: (value) => _change(
        () => _icon = value == null || value.isEmpty
            ? value
            : routeIconValue(value),
      ),
    );
  }

  Widget _header(String title) =>
      ListHeader(title: title, padding: const EdgeInsets.fromLTRB(4, 20, 4, 8));

  Widget _largeTip(BuildContext context, List<String> sets) {
    final large = sets.any(
      (key) => (widget.catalog.sets[key]?.count ?? 0) > _largeRuleSetCount,
    );
    if (!large) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Text(
        appLocalizations.largeRuleSetTip,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.error,
        ),
      ),
    );
  }

  Widget _targetChip(int index, String item, String? target) => ChoiceChip(
    label: Text(_targetLabel(item)),
    selected: item == target,
    onSelected: (_) => setState(() {
      _target = index == 0 ? null : item;
      if (!_auto) _dirty = true;
    }),
  );

  Widget _buildMode() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SegmentedButton<bool>(
        segments: [
          ButtonSegment(
            value: true,
            label: Text(appLocalizations.auto),
            icon: const Icon(Icons.auto_awesome),
          ),
          ButtonSegment(
            value: false,
            label: Text(appLocalizations.custom),
            icon: const Icon(Icons.tune),
          ),
        ],
        selected: {_auto},
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        onSelectionChanged: (selection) => _switchMode(selection.first),
      ),
    );
  }

  String? _includedIn(RouteService service) =>
      _enabledGroups.where(service.groups.contains).firstOrNull;

  Map<RouteCategory, List<Widget>> _sections(
    List<RouteService> services,
    List<RouteService> pending,
  ) {
    final categories = widget.catalog.catalog.groupCategories;
    final query = _searchKey(_query);
    final sections = <RouteCategory, List<Widget>>{};
    for (final preset in widget.presets) {
      final category = categories[preset.name];
      if (category == null) continue;
      if (!_searchKey(preset.name).contains(query)) continue;
      final kept = _keptOf(preset);
      (sections[category] ??= []).add(
        _ServicePill(
          key: ValueKey(preset.name),
          icon: preset.icon,
          label: preset.name,
          selected: preset.removed && kept,
          present: !preset.removed,
          removing: !preset.removed && !kept,
          enabled: preset.removed || preset.enabled,
          onTap: () => _togglePreset(preset),
        ),
      );
    }
    for (final service in services) {
      final available = _available(service);
      final route = _routeOf[service.name];
      final group = _includedIn(service);
      (sections[service.category] ??= []).add(
        _ServicePill(
          key: ValueKey(service.name),
          icon: routeIconUrl(service.icon),
          label: service.name,
          selected: pending.contains(service),
          present: !available,
          removing: route != null && _removed.contains(route.id),
          tag: categories[group] == service.category ? null : group,
          onTap: route != null
              ? () => _toggleRemoved(route)
              : available
              ? () => _toggleAdded(service)
              : null,
        ),
      );
    }
    return sections;
  }

  List<Widget> _customPills() {
    final query = _searchKey(_query);
    return [
      for (final route in widget.routes)
        if (!_serviceNames.contains(route.name) &&
            _searchKey(route.name).contains(query))
          _ServicePill(
            key: ValueKey(route.id),
            icon: widget.catalog.iconUrlOf(route),
            label: route.name,
            present: true,
            removing: _removed.contains(route.id),
            onTap: () => _toggleRemoved(route),
          ),
    ];
  }

  Widget _buildSummary(BuildContext context, int added, int removed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        [
          if (added > 0) appLocalizations.routeAddCount(added),
          if (removed > 0) appLocalizations.routeRemoveCount(removed),
        ].join(' · '),
        style: context.textTheme.titleSmall,
      ),
    );
  }

  Widget _pillSection(String title, List<Widget> pills) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListHeader(
        title: title,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 8, runSpacing: 8, children: pills),
      ),
    ],
  );

  Widget _buildSelected(BuildContext context, RouteService service) {
    final count = _ruleCount(widget.catalog, service.sets);
    final group = _includedIn(service);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        spacing: 12,
        children: [
          _RouteIcon(url: routeIconUrl(service.icon)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall,
                ),
                Text(
                  group == null
                      ? appLocalizations.ruleCount(count)
                      : appLocalizations.ruleCountIncluded(count, group),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.toLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuto(BuildContext context) {
    final targets = widget.catalog.catalog.targets;
    final target = _target ?? targets.firstOrNull;
    final services = _services;
    final pending = _pendingOf(services);
    final sections = _sections(services, pending);
    final customs = _customPills();
    final selected = pending.length == 1 ? pending.first : null;
    final restored = _toggles.values.where((kept) => kept).length;
    final added = pending.length + restored;
    final removed = _removed.length + _toggles.length - restored;
    return Column(
      children: [
        _buildMode(),
        _SearchField(
          hintText: appLocalizations.searchServices,
          onChanged: (value) => setState(() => _query = value),
          onSubmitted: (_) => _handleSaveAuto(),
        ),
        Expanded(
          child: sections.isEmpty && customs.isEmpty
              ? NullStatus(label: appLocalizations.noData)
              : ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    for (final category in RouteCategory.values)
                      if (sections[category] case final pills?)
                        _pillSection(_categoryLabel(category), pills),
                    if (customs.isNotEmpty)
                      _pillSection(appLocalizations.custom, customs),
                  ],
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (added > 1 || removed > 0)
                _buildSummary(context, added, removed),
              if (selected != null) _buildSelected(context, selected),
              Text(
                appLocalizations.routeTarget,
                style: context.textTheme.labelMedium?.toLight,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    for (final (index, item) in targets.indexed)
                      _targetChip(index, item, target),
                  ],
                ),
              ),
              _largeTip(context, [
                for (final service in pending) ...service.sets,
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustom(BuildContext context) {
    final catalog = widget.catalog;
    final draft = _draft;
    final targets = catalog.catalog.targets;
    final target = _target ?? targets.firstOrNull;
    final icon = _icon;
    final names = {
      for (final key in _sets)
        key:
            catalog.sets[key]?.label ??
            CustomRuleSet.parse(key)?.name ??
            key.split(':').last,
    };
    final labels = {
      for (final MapEntry(:key, :value) in names.entries)
        key:
            names.values
                    .where((name) => name.toLowerCase() == value.toLowerCase())
                    .length >
                1
            ? '$value · ${key.split(':').first}'
            : value,
    };
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (widget.route == null) _buildMode(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _change(() => _error = null),
                decoration: InputDecoration(
                  labelText: appLocalizations.name,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 12),
              CommonCard(
                type: CommonCardType.filled,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: _RouteIcon(url: catalog.iconUrlOf(draft)),
                  title: Text(appLocalizations.selectIcon),
                  subtitle: Text(
                    icon == null
                        ? appLocalizations.auto
                        : icon.isEmpty
                        ? appLocalizations.noIcon
                        : _iconName(icon),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handlePickIcon,
                ),
              ),
              _header(appLocalizations.ruleSets),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in _sets)
                    InputChip(
                      avatar: switch (CustomRuleSet.parse(key)) {
                        final custom? => Icon(
                          custom.ip ? Icons.lan_outlined : Icons.link,
                          size: 18,
                        ),
                        null => _RouteIcon(
                          url: routeIconUrl(catalog.sets[key]?.icon),
                          size: 18,
                        ),
                      },
                      label: Text(labels[key] ?? key),
                      onDeleted: () =>
                          _change(() => _sets = List.of(_sets)..remove(key)),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: Text(appLocalizations.addRuleSet),
                    onPressed: _handlePickSets,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.link),
                    label: Text(appLocalizations.customRuleSetUrl),
                    onPressed: _handleAddUrl,
                  ),
                ],
              ),
              _largeTip(context, draft.sets),
              _header(appLocalizations.routeTarget),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (index, item) in targets.indexed)
                    _targetChip(index, item, target),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonPopScope(
      onPop: _confirmDiscard,
      child: AdaptiveSheetScaffold(
        type: widget.type,
        title: widget.route == null
            ? appLocalizations.addRoute
            : appLocalizations.editRoute,
        actions: [
          if (widget.onDelete != null)
            IconButton(
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: appLocalizations.delete,
            ),
          if (widget.onReset != null)
            IconButton(
              onPressed: _handleReset,
              icon: const Icon(Icons.restart_alt),
              tooltip: appLocalizations.reset,
            ),
          IconButton(
            onPressed: _handleSave,
            icon: const Icon(Icons.check),
            tooltip: appLocalizations.confirm,
          ),
        ],
        body: _auto ? _buildAuto(context) : _buildCustom(context),
      ),
    );
  }
}

class _MrsUrlDialog extends StatefulWidget {
  final Set<String> existing;

  const _MrsUrlDialog({required this.existing});

  @override
  State<_MrsUrlDialog> createState() => _MrsUrlDialogState();
}

class _MrsUrlDialogState extends State<_MrsUrlDialog> with IdleAutofocusMixin {
  final _controller = TextEditingController();
  String? _behavior;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _selected =>
      _behavior ?? CustomRuleSet.guessBehavior(_controller.text);

  void _handleSubmit() {
    final url = _controller.text.trim();
    if (!CustomRuleSet.isValidUrl(url)) {
      setState(() => _error = appLocalizations.checkUrlTip);
      return;
    }
    final key = CustomRuleSet(behavior: _selected, url: url).key;
    if (widget.existing.contains(key)) {
      setState(() => _error = appLocalizations.existsTip(appLocalizations.url));
      return;
    }
    Navigator.of(context).pop(key);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return CommonDialog(
      title: appLocalizations.customRuleSetUrl,
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: autofocusNode,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _handleSubmit(),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: appLocalizations.url,
              errorText: _error,
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final behavior in CustomRuleSet.behaviors)
                ChoiceChip(
                  label: Text(
                    behavior == CustomRuleSet.ipcidr
                        ? appLocalizations.ipcidr
                        : appLocalizations.domain,
                  ),
                  selected: behavior == selected,
                  onSelected: (_) => setState(() => _behavior = behavior),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleSetPickerSheet extends StatefulWidget {
  final SheetType type;
  final RouteCatalogIndex catalog;
  final List<String> selected;
  final ValueChanged<List<String>> onSave;

  const _RuleSetPickerSheet({
    required this.type,
    required this.catalog,
    required this.selected,
    required this.onSave,
  });

  @override
  State<_RuleSetPickerSheet> createState() => _RuleSetPickerSheetState();
}

class _RuleSetPickerSheetState extends State<_RuleSetPickerSheet> {
  late final List<String> _selected = List.of(widget.selected);
  late final _index = _SearchIndex<RouteRuleSet>(
    widget.catalog.catalog.sets,
    (set) => [?set.name, set.tag],
  );
  String _query = '';
  bool _dirty = false;

  void _toggle(String key) {
    setState(() {
      if (!_selected.remove(key)) _selected.add(key);
      _dirty = true;
    });
  }

  Future<void> _handleSave() async {
    widget.onSave(List.of(_selected));
    _dirty = false;
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return showSaveChangesDialog(onSave: _handleSave);
  }

  @override
  Widget build(BuildContext context) {
    final sets = _index.search(_query);
    return CommonPopScope(
      onPop: _confirmDiscard,
      child: AdaptiveSheetScaffold(
        type: widget.type,
        title: appLocalizations.addRuleSet,
        actions: [
          IconButton(
            onPressed: _handleSave,
            icon: const Icon(Icons.check),
            tooltip: appLocalizations.confirm,
          ),
        ],
        body: Column(
          children: [
            _SearchField(
              hintText: appLocalizations.searchRuleSets,
              onChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: sets.isEmpty
                  ? NullStatus(label: appLocalizations.noData)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sets.length,
                      itemBuilder: (_, index) {
                        final set = sets[index];
                        final key = set.key;
                        final count = set.count;
                        return ListTile(
                          key: ValueKey(key),
                          contentPadding: const EdgeInsets.only(
                            left: 20,
                            right: 12,
                          ),
                          leading: _RouteIcon(url: routeIconUrl(set.icon)),
                          title: Text(
                            set.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            [
                              set.type,
                              if (set.label != set.tag) set.tag,
                              if (count != null)
                                appLocalizations.ruleCount(count),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Checkbox(
                            value: _selected.contains(key),
                            onChanged: (_) => _toggle(key),
                          ),
                          onTap: () => _toggle(key),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
