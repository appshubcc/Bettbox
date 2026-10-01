import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// 合并面板：选择成员（顺序即可靠性优先级）、按成员设置节点前缀、生成一份新的合并配置。
class MergeProfileView extends StatefulWidget {
  const MergeProfileView({super.key, this.bundle});

  /// 编辑已有合并配置时传入。
  final Profile? bundle;

  @override
  State<MergeProfileView> createState() => _MergeProfileViewState();
}

class _MergeProfileViewState extends State<MergeProfileView> {
  late List<String> _selected;

  /// 合并配置自己的名称；留空则用成员名自动生成。
  late final TextEditingController _labelController;

  /// 上次由成员名自动填进输入框的值。
  ///
  /// 用它判断用户有没有手动改过名称——不能靠 onChanged 标记：Flutter 在代码里改
  /// `controller.text` 时同样会回调 onChanged。
  String _lastSyncedLabel = '';

  /// 成员 id -> 该成员单独填的节点前缀；留空则用成员名称。
  late final Map<String, String> _memberPrefixes;

  @override
  void initState() {
    super.initState();
    final bundleConfig = widget.bundle?.bundle;
    _selected = List.of(bundleConfig?.members ?? const <String>[]);
    _labelController = TextEditingController(
      text: widget.bundle?.label ?? '',
    );
    _memberPrefixes = Map<String, String>.from(
      bundleConfig?.memberPrefixes ?? const <String, String>{},
    );
    _syncAutoLabel();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  /// 新建配置时名称跟着成员走；用户改过之后不再覆盖。
  void _syncAutoLabel() {
    final auto = _autoLabel;
    final current = _labelController.text;
    // 输入框里还是上次自动填的名字（或者是空的）才继续跟着成员走
    if (current.isNotEmpty && current != _lastSyncedLabel) return;
    _lastSyncedLabel = auto;
    if (current != auto) {
      _labelController.text = auto;
    }
  }

  List<Profile> get _profiles => globalState.config.profiles;

  /// 合并配置本身不能再作为成员。
  List<Profile> get _candidates =>
      _profiles.where((profile) => !profile.isBundle).toList();

  List<Profile> get _selectedProfiles => _selected
      .map((id) => _profiles.getProfile(id))
      .whereType<Profile>()
      .toList();

  List<Profile> get _unselectedProfiles => _candidates
      .where((profile) => !_selected.contains(profile.id))
      .toList();

  /// 成员自己填的前缀。
  String _ownPrefix(Profile member) => _memberPrefixes[member.id]?.trim() ?? '';

  /// 没填时用的默认前缀就是成员名称。
  String _defaultPrefix(Profile member) =>
      (member.label?.isNotEmpty ?? false) ? member.label! : member.id;

  /// 最终会生效的前缀，用于在成员行上展示。
  String _effectivePrefix(Profile member) {
    final own = _ownPrefix(member);
    return own.isNotEmpty ? own : _defaultPrefix(member);
  }

  /// 没填名称时自动生成的名字。
  String get _autoLabel =>
      bundleDefaultLabel(_selectedProfiles.map((e) => e.label ?? e.id));

  /// 最终会用的名称：填了就用填的，没填用自动生成的。
  String get _resolvedLabel {
    final typed = _labelController.text.trim();
    return typed.isEmpty ? _autoLabel : typed;
  }

  Future<void> _handleGenerate() async {
    if (_selected.isEmpty) {
      context.showSnackBar(appLocalizations.bundleNoMember);
      return;
    }
    final result = await globalState.appController.safeRun<Profile?>(
      () => globalState.appController.generateBundle(
        bundleId: widget.bundle?.id,
        // 留空时也用自动名称，界面上显示的就是最终会用的名字
        label: _resolvedLabel,
        memberIds: _selected,
        // 只把填了内容的带上，留空的用成员名称
        memberPrefixes: {
          for (final id in _selected)
            if ((_memberPrefixes[id] ?? '').trim().isNotEmpty)
              id: _memberPrefixes[id]!.trim(),
        },
      ),
      needLoading: true,
      title: appLocalizations.tip,
    );
    if (!mounted || result == null) return;
    globalState.showNotifier(appLocalizations.bundleGenerateSuccess);
    Navigator.of(context).pop();
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colorScheme.outlineVariant.withValues(
        alpha: context.colorScheme.brightness == Brightness.light ? 0.6 : 0.45,
      ),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(title, style: context.textTheme.titleSmall),
    );
  }

  /// 名称入口：与配置编辑页一致——方框里直接编辑，不弹窗、也不套卡片背景。
  Widget _buildName() {
    return ListItem(
      // 与下方卡片左右对齐
      padding: EdgeInsets.zero,
      title: TextFormField(
        controller: _labelController,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: appLocalizations.name,
          // 留空时用这个自动名称
          hintText: _autoLabel,
        ),
      ),
    );
  }

  Widget _buildMembers() {
    final members = _selectedProfiles;
    return CommonCard(
      type: CommonCardType.filled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Text(
                appLocalizations.bundleNoMember,
                style: context.textTheme.bodyMedium?.toLight,
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: members.length,
              // 拖动中的那一行保持圆角与底色（默认装饰器会换成白色直角矩形），
              // 只做和配置页排序一样的轻微放大。
              proxyDecorator: (child, index, animation) {
                final dragged = index >= 0 && index < members.length
                    ? members[index]
                    : null;
                return _buildDragProxy(
                  animation: animation,
                  child: dragged == null
                      ? child
                      : _buildMemberTile(
                          profile: dragged,
                          index: index,
                          showDivider: false,
                        ),
                );
              },
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  // 以显示顺序为准重建成员表，顺带丢掉已经失效的成员 id
                  final ids = members.map((item) => item.id).toList();
                  ids.insert(newIndex, ids.removeAt(oldIndex));
                  _selected = ids;
                  _syncAutoLabel();
                });
              },
              itemBuilder: (_, index) => _buildMemberTile(
                key: ValueKey(members[index].id),
                profile: members[index],
                index: index,
                showDivider: index > 0,
              ),
            ),
        ],
      ),
    );
  }

  /// 拖动中的行：圆角卡片 + 与列表一致的底色，只轻微放大。
  Widget _buildDragProxy({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, Widget? child) {
        final value = Curves.easeInOut.transform(animation.value);
        return Transform.scale(scale: 1 + 0.02 * value, child: child);
      },
      child: CommonCard(type: CommonCardType.filled, child: child),
    );
  }

  Widget _buildMemberTile({
    Key? key,
    required Profile profile,
    required int index,
    required bool showDivider,
  }) {
    final effectivePrefix = _effectivePrefix(profile);
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 成员之间用细线隔开（与「更多」页面一致）
        if (showDivider) _buildDivider(),
        // 这一行只是点开前缀编辑：去掉 hover 变色（连右侧按钮一起），否则拖动排序
        // 松手后鼠标正好停在这行上，hover 遮罩会突然淡入，看起来像闪一下
        Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(hoverColor: Colors.transparent),
            ),
          ),
          child: ListItem.input(
            leading: CircleAvatar(
              radius: 12,
              child: Text(
                '${index + 1}',
                style: context.textTheme.labelSmall,
              ),
            ),
            title: EmojiText(profile.label ?? profile.id),
            // 点这一行可以单独改这个成员的前缀；用高亮小块让它显眼
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 12,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appLocalizations.bundleMemberPrefixValue(
                          effectivePrefix,
                        ),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            delegate: InputDelegate(
              title: appLocalizations.bundleMemberPrefix,
              hintText: appLocalizations.bundleMemberPrefixHint(
                _defaultPrefix(profile),
              ),
              value: _ownPrefix(profile),
              resetValue: '',
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _memberPrefixes[profile.id] = value.trim();
                });
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: appLocalizations.delete,
                  onPressed: () {
                    setState(() {
                      _selected.remove(profile.id);
                      _syncAutoLabel();
                    });
                  },
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidates(List<Profile> candidates) {
    return CommonCard(
      type: CommonCardType.filled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < candidates.length; i++) ...[
            if (i > 0) _buildDivider(),
            ListItem(
              leading: const Icon(Icons.add),
              title: EmojiText(candidates[i].label ?? candidates[i].id),
              onTap: () {
                setState(() {
                  _selected.add(candidates[i].id);
                  _syncAutoLabel();
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarnings() {
    final warnings = widget.bundle?.bundle?.report?.warnings ?? const [];
    if (warnings.isEmpty) return const SizedBox.shrink();
    final lines = <String>[];
    for (final warning in warnings) {
      final label = warning.member ?? '';
      lines.add(switch (warning.code) {
        'scriptFailed' => appLocalizations.bundleWarningScriptFailed(label),
        'tunnels' => appLocalizations.bundleWarningTunnels(label),
        'hostConflict' => appLocalizations.bundleWarningHostConflict(
          warning.count,
        ),
        'policyConflict' => appLocalizations.bundleWarningPolicyConflict(
          warning.count,
        ),
        _ => '',
      });
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CommonCard(
        type: CommonCardType.filled,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in lines)
                if (line.isNotEmpty)
                  Text(
                    '· $line',
                    style: context.textTheme.bodySmall?.toLight,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _unselectedProfiles;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 名称在最上面（弹窗标题已经是「合并配置」，这里不再重复小标题）
        _buildName(),
        const SizedBox(height: 16),
        _buildSectionTitle(appLocalizations.bundleMembers),
        _buildMembers(),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4, bottom: 12),
          child: Text(
            appLocalizations.bundleMembersDesc,
            style: context.textTheme.labelSmall?.toLight,
          ),
        ),
        if (candidates.isNotEmpty) ...[
          _buildSectionTitle(appLocalizations.bundleAddMember),
          _buildCandidates(candidates),
          const SizedBox(height: 16),
        ],
        _buildWarnings(),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _handleGenerate,
          child: Text(appLocalizations.bundleGenerate),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
