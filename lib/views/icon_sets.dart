import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showIconSets(BuildContext context) => showSheet(
  context: context,
  builder: (_, type) => _IconSetsSheet(type: type),
);

Future<void> showIconPicker(
  BuildContext context, {
  String? selected,
  String suggest = '',
  List<IconPickerOption> options = const [],
  required ValueChanged<String?> onSelect,
}) => showSheet(
  context: context,
  builder: (_, type) => IconPickerSheet(
    type: type,
    selected: selected,
    suggest: suggest,
    options: options,
    onSelect: onSelect,
  ),
);

String _cover(IconSet iconSet) => iconSet.icons
    .firstWhere(
      (icon) => iconFileStem(icon.name).toLowerCase() == 'qure',
      orElse: () =>
          iconSet.icons.firstOrNull ?? const IconSetIcon(name: '', url: ''),
    )
    .url;

class _IconSetsSheet extends ConsumerStatefulWidget {
  final SheetType type;

  const _IconSetsSheet({required this.type});

  @override
  ConsumerState<_IconSetsSheet> createState() => _IconSetsSheetState();
}

class _IconSetsSheetState extends ConsumerState<_IconSetsSheet> {
  final Set<String> _updating = {};

  Future<void> _run(String key, Future<void> Function() task) async {
    setState(() => _updating.add(key));
    await globalState.appController.safeRun(task, silence: false);
    if (!mounted) return;
    setState(() => _updating.remove(key));
  }

  Future<void> _handleImportUrl() async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.importUrl,
        value: '',
        labelText: appLocalizations.url,
        keyboardType: TextInputType.url,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.url);
          }
          if (!text.isHttpUrl) return appLocalizations.checkUrlTip;
          return null;
        },
      ),
    );
    if (url == null || !mounted) return;
    await _run('', () async {
      await ref.read(iconSetsProvider.notifier).importUrl(url.trim());
    });
  }

  Future<void> _handleImportFile() async {
    final file = await globalState.appController.safeRun(
      () => picker.pickerFile(allowedExtensions: const ['json']),
    );
    if (file == null || !mounted) return;
    await _run('', () async {
      final bytes = await file.readAsBytes();
      await ref
          .read(iconSetsProvider.notifier)
          .importContent(file.name, utf8.decode(bytes, allowMalformed: true));
    });
  }

  Future<void> _handleDelete(IconSet iconSet) async {
    final res = await globalState.showMessage(
      title: appLocalizations.delete,
      message: TextSpan(text: appLocalizations.deleteTip(iconSet.name)),
    );
    if (res != true || !mounted) return;
    await ref.read(iconSetsProvider.notifier).delete(iconSet.id);
  }

  Widget _buildItem(
    IconSet iconSet, {
    required String subtitle,
    List<Widget> actions = const [],
    VoidCallback? onTap,
  }) {
    return ListItem(
      onTap: onTap,
      leading: SizedBox.square(
        dimension: 40,
        child: CommonTargetIcon(src: _cover(iconSet), size: 40),
      ),
      title: Text(iconSet.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions),
    );
  }

  Widget _buildImported(IconSet iconSet) {
    final updating = _updating.contains(iconSet.id);
    final time = iconSet.lastUpdateTime;
    return _buildItem(
      iconSet,
      subtitle: [
        appLocalizations.iconCount(iconSet.icons.length),
        if (time != null) time.lastUpdateTimeDesc,
        iconSet.url.isEmpty ? appLocalizations.localFile : iconSet.url,
      ].join(' · '),
      actions: [
        if (iconSet.url.isNotEmpty)
          IconButton(
            tooltip: appLocalizations.update,
            onPressed: updating
                ? null
                : () => _run(iconSet.id, () async {
                    await ref
                        .read(iconSetsProvider.notifier)
                        .importUrl(iconSet.url);
                  }),
            icon: updating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        IconButton(
          tooltip: appLocalizations.delete,
          onPressed: () => _handleDelete(iconSet),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final builtIn = ref.watch(builtInIconSetProvider).value;
    final imported = ref.watch(iconSetsProvider).value ?? const <IconSet>[];
    final importing = _updating.contains('');
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.iconSets,
      actions: [
        IconButton(
          tooltip: appLocalizations.importFile,
          onPressed: importing ? null : _handleImportFile,
          icon: const Icon(Icons.file_open_outlined),
        ),
        IconButton(
          tooltip: appLocalizations.importUrl,
          onPressed: importing ? null : _handleImportUrl,
          icon: importing
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_link),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (builtIn != null)
            _buildItem(
              builtIn,
              subtitle:
                  '${appLocalizations.builtIn} · '
                  '${appLocalizations.iconCount(builtIn.icons.length)} · '
                  '@aaANDkk',
              actions: const [Icon(Icons.open_in_new, size: 18)],
              onTap: () => globalState.openUrl(
                'https://github.com/appshubcc/Qure_Style_SVG',
              ),
            ),
          for (final iconSet in imported) _buildImported(iconSet),
        ],
      ),
    );
  }
}

class IconPickerOption {
  final Widget icon;
  final String label;
  final bool selected;
  final String? value;

  const IconPickerOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.value,
  });
}

class IconPickerSheet extends StatelessWidget {
  final SheetType type;
  final String? selected;
  final String suggest;
  final List<IconPickerOption> options;
  final ValueChanged<String?> onSelect;

  const IconPickerSheet({
    super.key,
    required this.type,
    this.selected,
    this.suggest = '',
    this.options = const [],
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.selectIcon,
      actions: const [IconSetsButton()],
      body: IconPickerBody(
        selected: selected,
        suggest: suggest,
        options: options,
        onSelect: (value) {
          onSelect(value);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class IconSetsButton extends StatelessWidget {
  const IconSetsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: appLocalizations.iconSets,
      onPressed: () => showIconSets(context),
      icon: const Icon(Icons.collections_outlined),
    );
  }
}

class IconPickerBody extends ConsumerStatefulWidget {
  final String? selected;
  final String suggest;
  final List<IconPickerOption> options;
  final ValueChanged<String?> onSelect;

  const IconPickerBody({
    super.key,
    this.selected,
    this.suggest = '',
    this.options = const [],
    required this.onSelect,
  });

  @override
  ConsumerState<IconPickerBody> createState() => _IconPickerBodyState();
}

class _IconPickerBodyState extends ConsumerState<IconPickerBody> {
  final _keys = Expando<List<String>>();
  String _query = '';
  String? _source;

  List<String> _keysOf(List<IconSetIcon> icons) => _keys[icons] ??= [
    for (final icon in icons) iconSearchKey(iconFileStem(icon.name)),
  ];

  List<IconSetIcon> _search(List<IconSetIcon> icons) {
    final query = iconSearchKey(_query);
    if (query.isNotEmpty) return _rank(icons, [query]);
    final suggested = [
      for (final token in widget.suggest.split('|'))
        if (iconSearchKey(token) case final key when key.length > 1) key,
    ];
    if (suggested.isEmpty) return icons;
    final matched = _rank(icons, suggested);
    if (matched.isEmpty) return icons;
    final first = matched.toSet();
    return [...matched, ...icons.where((icon) => !first.contains(icon))];
  }

  List<IconSetIcon> _rank(List<IconSetIcon> icons, List<String> queries) {
    final keys = _keysOf(icons);
    final ranked = <({int score, int index})>[];
    for (final (index, key) in keys.indexed) {
      var score = -1;
      for (final query in queries) {
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
    return [for (final entry in ranked) icons[entry.index]];
  }

  void _select(String? value) => widget.onSelect(value);

  Future<void> _handleCustomUrl() async {
    final current = widget.selected;
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.iconUrl,
        value: current != null && current.isHttpUrl ? current : '',
        hintText: 'https://example.com/icon.svg',
        keyboardType: TextInputType.url,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.iconUrl);
          }
          if (!text.isHttpUrl) return appLocalizations.checkUrlTip;
          return null;
        },
      ),
    );
    if (url == null || !mounted) return;
    _select(url.trim());
  }

  Widget _buildCell(BuildContext context, IconSetIcon icon) {
    final selected = widget.selected == icon.url;
    final colorScheme = context.colorScheme;
    return Material(
      color: selected ? colorScheme.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _select(icon.url),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
          child: Column(
            children: [
              CommonTargetIcon(
                key: ValueKey(icon.url),
                src: icon.url,
                size: 32,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  icon.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final builtIn = ref.watch(builtInIconSetProvider).value;
    final imported = ref.watch(iconSetsProvider).value ?? const <IconSet>[];
    final sets = [?builtIn, ...imported];
    final source =
        sets.firstWhereOrNull((item) => item.id == _source) ?? sets.firstOrNull;
    final icons = source == null
        ? const <IconSetIcon>[]
        : _search(source.icons);
    final current = widget.selected;
    final custom =
        current != null &&
        current.isHttpUrl &&
        !sets.any((item) => item.icons.any((icon) => icon.url == current));
    final groupOptions = [
      for (final (index, option) in widget.options.indexed)
        SegmentOption<int>(
          value: index,
          icon: option.icon,
          label: option.label,
        ),
      SegmentOption<int>(
        value: -1,
        icon: custom
            ? CommonTargetIcon(src: current, size: 16)
            : const Icon(Icons.link, size: 18),
        label: appLocalizations.customUrl,
      ),
    ];
    final selectedOptionIndex = widget.options.indexWhere(
      (opt) => opt.selected,
    );
    final selectedIndex = custom
        ? -1
        : (selectedOptionIndex >= 0 ? selectedOptionIndex : -999);
    const grid = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 140,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      mainAxisExtent: 92,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: appLocalizations.searchIcons,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        if (sets.length > 1)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final item in sets)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item.name),
                      selected: item.id == source?.id,
                      onSelected: (_) => setState(() => _source = item.id),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (groupOptions.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: SegmentButtonGroup<int>(
                      maxWidth: 480,
                      alignment: Alignment.center,
                      options: groupOptions,
                      selected: selectedIndex,
                      onSelected: (index) {
                        if (index == -1) {
                          _handleCustomUrl();
                        } else {
                          _select(widget.options[index].value);
                        }
                      },
                    ),
                  ),
                ),
              if (source == null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (icons.isEmpty)
                SliverToBoxAdapter(
                  child: _buildTip(context, appLocalizations.noData),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: grid,
                    itemCount: icons.length,
                    itemBuilder: (_, index) =>
                        _buildCell(context, icons[index]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
