import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';

class MrsLookupPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const MrsLookupPage({super.key, this.initialQuery});

  @override
  ConsumerState<MrsLookupPage> createState() => _MrsLookupPageState();
}

class _MrsLookupPageState extends ConsumerState<MrsLookupPage>
    with ToolHistoryMixin<MrsLookupPage> {
  @override
  String get historyKey => 'mrs';

  final _controller = TextEditingController();
  MrsPrepareResult? _prepare;
  MrsLookupResult? _result;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    loadHistory();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) _controller.text = initial;
    _load().then((_) {
      if (initial.isNotEmpty) _search(initial);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_searching) clashCore.cancelMrsLookup();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _prepare = null);
    final result = await clashCore.mrsPrepare();
    if (!mounted) return;
    setState(() => _prepare = result);
  }

  bool get _ready => _prepare?.error.isEmpty ?? false;

  Future<void> _search(String raw) async {
    final target = raw.trim();
    if (target.isEmpty || _searching || !_ready) return;
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    final resolve = ref.read(
      appSettingProvider.select((state) => state.mrsResolveDns),
    );
    final result = await clashCore.mrsLookup(target, resolve: resolve);
    if (!mounted) return;
    if (result.error.isEmpty) addHistory(target);
    setState(() {
      _searching = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prepare = _prepare;
    final result = _result;
    final colorScheme = context.colorScheme;
    return CommonScaffold(
      title: appLocalizations.mrsLookup,
      actions: [
        IconButton(
          tooltip: appLocalizations.settings,
          onPressed: () =>
              globalState.showCommonDialog(child: const _MrsSettingsDialog()),
          icon: const Icon(ReIcons.setting2),
        ),
      ],
      body: ToolPageBody(
        children: [
          ToolSearchField(
            controller: _controller,
            hintText: appLocalizations.mrsLookupHint,
            busy: _searching || prepare == null,
            onSubmitted: _search,
          ),
          ToolHistoryBar(
            items: history,
            onSelected: (value) {
              _controller.text = value;
              _search(value);
            },
            onClear: clearHistory,
          ),
          if (prepare != null && prepare.error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ToolNote(
                    icon: ReIcons.alertCircle,
                    text: prepare.error == 'missing'
                        ? appLocalizations.mrsMissing
                        : appLocalizations.mrsPrepareFailed,
                    color: colorScheme.error,
                  ),
                ),
                TextButton(
                  onPressed: _load,
                  child: Text(appLocalizations.retry),
                ),
              ],
            ),
          ],
          ToolLoadingSwitcher(
            loading: _searching || prepare == null,
            child: result == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: result.error.isNotEmpty
                        ? ToolNote(
                            icon: ReIcons.alertCircle,
                            text: result.error == 'invalid'
                                ? appLocalizations.ipLookupInvalid
                                : appLocalizations.mrsPrepareFailed,
                            color: colorScheme.error,
                          )
                        : _MrsResult(result: result),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MrsResult extends StatelessWidget {
  final MrsLookupResult result;

  const _MrsResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final geosite = result.matches.where((m) => m.kind == 'geosite').toList();
    final geoip = result.matches.where((m) => m.kind == 'geoip').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      result.host.isNotEmpty ? result.host : result.target,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${result.elapsed.toStringAsFixed(1)} ms',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (result.host.isNotEmpty && result.ips.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final ip in result.ips)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(ip, style: context.textTheme.labelSmall),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (result.matches.isEmpty) ...[
          const SizedBox(height: 12),
          ToolNote(
            icon: ReIcons.searchMinus,
            text: appLocalizations.mrsNoMatch,
          ),
        ],
        if (geosite.isNotEmpty) ...[
          ToolSectionHeader('GEOSITE · ${geosite.length}'),
          _MatchList(matches: geosite),
        ],
        if (geoip.isNotEmpty) ...[
          ToolSectionHeader('GEOIP · ${geoip.length}'),
          _MatchList(matches: geoip),
        ],
      ],
    );
  }
}

class _MrsSettingsDialog extends ConsumerWidget {
  const _MrsSettingsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (copyRaw, source, resolve) = ref.watch(
      appSettingProvider.select(
        (state) =>
            (state.mrsCopyRawLink, state.mrsRawSource, state.mrsResolveDns),
      ),
    );
    void update(AppSettingProps Function(AppSettingProps state) builder) =>
        ref.read(appSettingProvider.notifier).updateState(builder);
    return CommonDialog(
      title: appLocalizations.settings,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListItem.switchItem(
            title: Text(appLocalizations.mrsCopyRawLink),
            delegate: SwitchDelegate(
              value: copyRaw,
              onChanged: (value) =>
                  update((state) => state.copyWith(mrsCopyRawLink: value)),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: copyRaw
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                    child: ToolSegmented<MrsRawSource>(
                      values: MrsRawSource.values,
                      value: source,
                      labelOf: (item) => item.label,
                      onChanged: (value) => update(
                        (state) => state.copyWith(mrsRawSource: value),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          ListItem.switchItem(
            title: Text(appLocalizations.mrsResolveDns),
            subtitle: Text(appLocalizations.mrsResolveDnsDesc),
            delegate: SwitchDelegate(
              value: resolve,
              onChanged: (value) =>
                  update((state) => state.copyWith(mrsResolveDns: value)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchList extends ConsumerWidget {
  final List<MrsMatch> matches;

  const _MatchList({required this.matches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (copyRaw, source) = ref.watch(
      appSettingProvider.select(
        (state) => (state.mrsCopyRawLink, state.mrsRawSource),
      ),
    );
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return ToolSurface(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final (index, match) in matches.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            InkWell(
              focusColor: toolFocusColor(context),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text: copyRaw
                        ? '${source.baseUrl}${match.file}'
                        : '${match.kind.toUpperCase()},${match.name}',
                  ),
                );
                context.showNotifier(appLocalizations.copySuccess);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match.kind.toUpperCase()},${match.name}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'path-in-bundle: "${match.file}"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              appLocalizations.mrsRules(match.count),
                              if (match.kind == 'geoip')
                                appLocalizations.mrsVia(match.via),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (match.referenced)
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          appLocalizations.mrsReferenced,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@visibleForTesting
Widget buildMrsResultForTesting(MrsLookupResult result) =>
    _MrsResult(result: result);
