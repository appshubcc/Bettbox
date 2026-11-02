import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/profiles/managed_options.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _maxBundleMembers = 6;

class MergeProfileView extends ConsumerStatefulWidget {
  final Profile? profile;
  final BuildContext context;

  const MergeProfileView({super.key, this.profile, required this.context});

  @override
  ConsumerState<MergeProfileView> createState() => _MergeProfileViewState();
}

class _MergeProfileViewState extends ConsumerState<MergeProfileView> {
  final _labelController = TextEditingController();
  late List<BundleMember> _members;
  final Map<String, String> _pending = {};
  int _pendingSeq = 0;
  late bool _collapsed = widget.profile?.bundle?.collapsed ?? true;
  late ProfileUsageStyle _usageStyle =
      widget.profile?.usageStyle ?? ProfileUsageStyle.ring;
  Map<String, bool>? _defaults;

  String? get _id => widget.profile?.id;

  @override
  void initState() {
    super.initState();
    final profiles = ref.read(profilesProvider);
    _members = [
      for (final member
          in widget.profile?.bundle?.members ?? const <BundleMember>[])
        if (profiles.getProfile(member.id) != null) member,
    ];
    _labelController.text = widget.profile?.label ?? _defaultLabel(profiles);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_loadOptions);
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    if (!mounted) return;
    final props = ref.read(managedSettingProvider);
    final data = await globalState.appController.safeRun(() async {
      final script = await ManagedScript.script(
        props.copyWith(routes: const [], order: const []),
      );
      return JavaScriptRuntimeManager.extractScriptOptions(script);
    });
    final options = data?['options'];
    if (!mounted) return;
    setState(() {
      _defaults = {
        if (options is Map)
          for (final MapEntry(:key, :value) in options.entries)
            key.toString(): value is bool ? value : true,
      };
    });
  }

  String _labelOf(List<Profile> profiles, String id) =>
      profiles.getProfile(id)?.label ?? id;

  String _defaultLabel(List<Profile> profiles) {
    final labels = {for (final profile in profiles) profile.label};
    var index = 1;
    while (labels.contains(appLocalizations.mergedSubscriptionName(index))) {
      index++;
    }
    return appLocalizations.mergedSubscriptionName(index);
  }

  void _setMembers(List<BundleMember> members) {
    setState(() {
      _members = members;
      _pending.removeWhere(
        (id, _) => !members.any((member) => member.id == id),
      );
    });
  }

  bool _reachedLimit() {
    if (_members.length < _maxBundleMembers) return false;
    context.showNotifier(appLocalizations.bundleMemberLimit(_maxBundleMembers));
    return true;
  }

  String _hostOf(String url) => switch (Uri.tryParse(url)?.host) {
    final host? when host.isNotEmpty => host,
    _ => url,
  };

  Future<void> _handleAddUrl([BundleMember? member]) async {
    if (member == null && _reachedLimit()) return;
    final value = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.bundleAddUrl,
        value: _pending[member?.id] ?? '',
        hintText: 'https://',
        keyboardType: TextInputType.url,
        autofocus: true,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) {
            return appLocalizations.profileUrlNullValidationDesc;
          }
          if (!text.isUrl) {
            return appLocalizations.profileUrlInvalidValidationDesc;
          }
          return null;
        },
      ),
    );
    if (value == null || !mounted) return;
    final url = value.trim();
    final existing = ref
        .read(profilesProvider)
        .where((profile) => profile.bundle == null && profile.url == url)
        .firstOrNull;
    final entry = BundleMember(
      id: existing?.id ?? member?.id ?? 'pending-${++_pendingSeq}',
    );
    final duplicate = _members.any(
      (item) =>
          item.id != member?.id &&
          (item.id == entry.id || _pending[item.id] == url),
    );
    if (existing == null && !duplicate) {
      _pending[entry.id] = url;
    }
    _setMembers([
      for (final item in _members)
        if (item.id != member?.id) item else if (!duplicate) entry,
      if (member == null && !duplicate) entry,
    ]);
  }

  Future<void> _importPending() async {
    final appController = globalState.appController;
    for (final member in List.of(_members)) {
      final url = _pending[member.id];
      if (url == null) continue;
      final Profile imported;
      try {
        imported = await Profile.normal(url: url).update();
      } on Object catch (e) {
        throw '$url\n${e.formatError}';
      }
      final profile = imported.label == imported.id
          ? imported.copyWith(label: _hostOf(url))
          : imported;
      await appController.addProfile(profile);
      if (!mounted) return;
      _setMembers([
        for (final item in _members)
          item.id == member.id ? item.copyWith(id: profile.id) : item,
      ]);
    }
  }

  Future<void> _handleEditPrefix(BundleMember member, String label) async {
    final fallback = bundlePrefixOf(label);
    final value = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.nodePrefix,
        value: member.prefix ?? fallback,
        resetValue: fallback,
        hintText: appLocalizations.noNodePrefix,
      ),
    );
    if (value == null || !mounted) return;
    final prefix = value.trim();
    _setMembers([
      for (final item in _members)
        item.id == member.id
            ? item.copyWith(prefix: prefix == fallback ? null : prefix)
            : item,
    ]);
  }

  Future<void> _handleSettings() async {
    await globalState.showAdaptiveSheet<void>(
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          void update(VoidCallback fn) {
            setState(fn);
            setDialogState(() {});
          }

          return CommonDialog(
            title: appLocalizations.settings,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.usageStyle,
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<ProfileUsageStyle>(
                  segments: [
                    for (final style in ProfileUsageStyle.values)
                      ButtonSegment(
                        value: style,
                        label: Text(style.localizedName),
                      ),
                  ],
                  selected: {_usageStyle},
                  showSelectedIcon: false,
                  expandedInsets: EdgeInsets.zero,
                  onSelectionChanged: (selection) =>
                      update(() => _usageStyle = selection.first),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLocalizations.bundleCollapse,
                            style: context.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appLocalizations.bundleCollapseDesc,
                            style: context.textTheme.bodySmall?.toLight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _collapsed,
                      onChanged: (value) => update(() => _collapsed = value),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRegenerate(String id) async {
    final appController = globalState.appController;
    await appController.safeRun(
      () => appController.generateBundle(id, refresh: true),
      silence: false,
    );
  }

  Future<void> _handleSyncScript() => syncManagedScript(context, ref);

  Future<void> _handleRestoreScript() async {
    final res = await globalState.showMessage(
      title: appLocalizations.restoreBundled,
      message: TextSpan(text: appLocalizations.managedRestoreTip),
    );
    if (res != true) return;
    final restored = await globalState.appController.safeRun<bool>(() async {
      await ManagedScript.restore();
      return true;
    }, silence: false);
    if (restored != true || !mounted) return;
    globalState.appController.updateManagedSetting(
      (state) => state.copyWith(syncedVersion: null),
    );
  }

  Future<void> _handleConfirm() async {
    if (_members.isEmpty) {
      context.showNotifier(appLocalizations.bundleNoMembers);
      return;
    }
    final appController = globalState.appController;
    if (_pending.isNotEmpty) {
      final imported = await appController.safeRun<bool>(
        () async {
          await _importPending();
          return true;
        },
        needLoading: true,
        silence: false,
      );
      if (imported != true || !mounted) return;
    }
    final profiles = ref.read(profilesProvider);
    final text = _labelController.text.trim();
    final label = text.isNotEmpty
        ? text
        : widget.profile?.label ?? _defaultLabel(profiles);
    final members = List<BundleMember>.of(_members);
    final id = _id;
    if (id == null) {
      final created = await appController.safeRun<bool>(
        () async {
          await appController.createBundle(
            label: label,
            members: members,
            collapsed: _collapsed,
            usageStyle: _usageStyle,
          );
          return true;
        },
        needLoading: true,
        silence: false,
      );
      if (created != true || !mounted) return;
      Navigator.of(context).pop();
      if (widget.context.mounted) {
        Navigator.of(widget.context).pop();
      }
      return;
    }
    final latest = profiles.getProfile(id);
    final bundle = latest?.bundle;
    if (latest == null || bundle == null) return;
    final changed = !listEquals(bundle.members, members);
    appController.setProfile(
      latest.copyWith(
        label: label,
        usageStyle: _usageStyle,
        bundle: bundle.copyWith(members: members, collapsed: _collapsed),
      ),
    );
    Navigator.of(context).pop();
    if (!changed) return;
    appController.safeRun(
      () => appController.generateBundle(id),
      silence: false,
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: context.colorScheme.outlineVariant.withValues(
      alpha: context.colorScheme.brightness == Brightness.light ? 0.6 : 0.45,
    ),
    indent: 16,
    endIndent: 16,
  );

  Widget _card(BuildContext context, List<Widget> rows) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: CommonCard(
      type: CommonCardType.filled,
      radius: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) _divider(context),
            row,
          ],
        ],
      ),
    ),
  );

  Widget _header(String title, {String? subTitle, List<Widget>? actions}) =>
      ListHeader(
        title: title,
        subTitle: subTitle,
        actions: actions,
        padding: EdgeInsets.fromLTRB(20, 0, actions == null ? 16 : 8, 6),
      );

  Widget _buildReport(BuildContext context, Profile profile) {
    final report = profile.bundle?.report ?? const BundleReport();
    return _card(context, [
      ListItem(
        title: Text(appLocalizations.lastGenerated),
        subtitle: Text(
          appLocalizations.bundleReportDesc(
            report.proxies,
            report.duplicates,
            profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
          ),
        ),
        trailing: SizedBox.square(
          dimension: 48,
          child: profile.isUpdating
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  onPressed: () => _handleRegenerate(profile.id),
                  tooltip: appLocalizations.regenerate,
                  icon: const Icon(Icons.refresh),
                ),
        ),
      ),
    ]);
  }

  Widget _buildMember(
    BuildContext context,
    int index,
    List<Profile> profiles,
    Map<String, String> failures,
  ) {
    final member = _members[index];
    final url = _pending[member.id];
    final label = url != null ? _hostOf(url) : _labelOf(profiles, member.id);
    final failure = failures[member.id];
    final prefix = member.prefix ?? bundlePrefixOf(label);
    final error = context.colorScheme.error;
    return Column(
      key: ValueKey(member.id),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (index > 0) _divider(context),
        ListItem(
          padding: const EdgeInsets.only(left: 8, right: 4),
          horizontalTitleGap: 4,
          leading: ReorderableDragStartListener(
            index: index,
            child: SizedBox.square(
              dimension: 32,
              child: Icon(
                Icons.drag_indicator,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          title: EmojiText(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            url != null
                ? appLocalizations.bundlePendingImport
                : failure != null
                ? appLocalizations.bundleMemberFailed(failure)
                : prefix.isEmpty
                ? appLocalizations.noNodePrefix
                : appLocalizations.nodePrefixValue(prefix),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: failure != null ? TextStyle(color: error) : null,
          ),
          trailing: IconButton(
            onPressed: () => _setMembers(List.of(_members)..removeAt(index)),
            tooltip: appLocalizations.delete,
            icon: const Icon(Icons.remove_circle_outline, size: 20),
          ),
          onTap: () => url != null
              ? _handleAddUrl(member)
              : _handleEditPrefix(member, label),
        ),
      ],
    );
  }

  Widget _buildMembers(BuildContext context, List<Profile> profiles) {
    final failures =
        profiles.getProfile(_id)?.bundle?.failures ?? const <String, String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          appLocalizations.bundleMembers,
          subTitle: appLocalizations.bundleMembersDesc,
          actions: [
            IconButton(
              onPressed: _handleSettings,
              tooltip: appLocalizations.settings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        if (_members.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CommonCard(
              type: CommonCardType.filled,
              radius: 16,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                padding: EdgeInsets.zero,
                itemCount: _members.length,
                onReorderItem: (oldIndex, newIndex) {
                  final members = List.of(_members);
                  members.insert(newIndex, members.removeAt(oldIndex));
                  _setMembers(members);
                },
                itemBuilder: (context, index) =>
                    _buildMember(context, index, profiles, failures),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 0),
            child: Text(
              appLocalizations.bundleDedupTip,
              style: context.textTheme.labelSmall?.toLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCandidate(BuildContext context, Profile profile) {
    return ListItem(
      leading: const Icon(Icons.add_circle_outline),
      title: EmojiText(
        profile.label ?? profile.id,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        if (_reachedLimit()) return;
        _setMembers([..._members, BundleMember(id: profile.id)]);
      },
    );
  }

  Widget _buildCandidates(BuildContext context, List<Profile> candidates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(appLocalizations.addBundleMember),
        _card(context, [
          ListItem(
            leading: const Icon(Icons.add_link),
            title: Text(appLocalizations.bundleAddUrl),
            subtitle: Text(appLocalizations.bundleAddUrlDesc),
            onTap: _handleAddUrl,
          ),
          for (final profile in candidates) _buildCandidate(context, profile),
        ]),
      ],
    );
  }

  Widget _buildManaged(BuildContext context) {
    final props = ref.watch(managedSettingProvider);
    final defaults = _defaults;
    final syncedVersion = ManagedScript.syncedVersion(props);
    final enabled = defaults?.entries
        .where((entry) => props.options[entry.key] ?? entry.value)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(appLocalizations.managedMode),
        _card(context, [
          ListItem(
            title: Text(appLocalizations.managedOptions),
            subtitle: defaults == null || defaults.isEmpty || enabled == null
                ? null
                : Text(
                    appLocalizations.managedOptionsDesc(
                      enabled,
                      defaults.length,
                    ),
                  ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showManagedOptions(context),
          ),
          ListItem(
            title: Text(appLocalizations.managedVersion),
            subtitle: Text(
              syncedVersion == null
                  ? appLocalizations.managedBundled(ManagedScript.bundledVersion)
                  : appLocalizations.managedSynced(syncedVersion),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (syncedVersion != null)
                  IconButton(
                    onPressed: _handleRestoreScript,
                    tooltip: appLocalizations.restoreBundled,
                    icon: const Icon(Icons.restore),
                  ),
                TextButton(
                  onPressed: _handleSyncScript,
                  child: Text(appLocalizations.syncFromUpstream),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      managedSettingProvider.select((state) => state.syncedVersion),
      (_, _) => _loadOptions(),
    );
    final profiles = ref.watch(profilesProvider);
    final current = profiles.getProfile(_id);
    final candidates = [
      for (final profile in profiles)
        if (profile.bundle == null &&
            !_members.any((member) => member.id == profile.id))
          profile,
    ];
    final items = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: _labelController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: appLocalizations.name),
        ),
      ),
      if (current != null) _buildReport(context, current),
      _buildMembers(context, profiles),
      _buildCandidates(context, candidates),
      _buildManaged(context),
    ];
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: _handleConfirm,
          label: Text(
            _id == null ? appLocalizations.generate : appLocalizations.save,
          ),
          icon: Icon(_id == null ? Icons.merge_type : Icons.save),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.separated(
          padding: kMaterialListPadding.copyWith(
            bottom: 72 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          itemBuilder: (_, index) => items[index],
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemCount: items.length,
        ),
      ),
    );
  }
}
