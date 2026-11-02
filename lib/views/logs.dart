import 'dart:math';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

const _dnsModule = 'DNS';

class _LogColors {
  final Color time;
  final Color tag;
  final Color appTag;
  final Color text;
  final Color dim;
  final Color error;
  final Color warning;
  final Color expanded;
  final Color hover;
  final double tintAlpha;

  const _LogColors({
    required this.time,
    required this.tag,
    required this.appTag,
    required this.text,
    required this.dim,
    required this.error,
    required this.warning,
    required this.expanded,
    required this.hover,
    required this.tintAlpha,
  });

  factory _LogColors.of(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final warning = isDark ? const Color(0xFFFFD54F) : const Color(0xFFB26A00);
    return _LogColors(
      time: scheme.onSurfaceVariant.opacity80,
      tag: scheme.primary,
      appTag: scheme.tertiary,
      text: scheme.onSurface,
      dim: scheme.onSurfaceVariant,
      error: scheme.error,
      warning: warning.harmonizeWith(scheme.primary),
      expanded: scheme.onSurface.withValues(alpha: 0.06),
      hover: scheme.onSurface.withValues(alpha: 0.04),
      tintAlpha: 0.06,
    );
  }

  Color tagOf(Log log) => log.source == LogSource.app ? appTag : tag;

  Color? accent(LogLevel level) => switch (level) {
    LogLevel.error => error,
    LogLevel.warning => warning,
    _ => null,
  };

  Color payload(LogLevel level) => switch (level) {
    LogLevel.error => error,
    LogLevel.debug || LogLevel.silent => dim,
    _ => text,
  };
}

class _LogMetrics {
  static const stripeWidth = 3.0;
  static const margin = 16.0;
  static const dividerHeight = 1.0;
  static const metaGap = 4.0;
  static const actionsHeight = 40.0;

  final TextStyle style;
  final TextScaler textScaler;
  final Locale? locale;
  final TextHeightBehavior? textHeightBehavior;
  final double width;
  final bool compact;
  final bool relaxed;
  final double charWidth;
  final double lineHeight;

  const _LogMetrics({
    required this.style,
    required this.textScaler,
    required this.locale,
    required this.textHeightBehavior,
    required this.width,
    required this.compact,
    required this.relaxed,
    required this.charWidth,
    required this.lineHeight,
  });

  double get padding => 16;

  double get verticalPadding => relaxed ? 12 : 8;

  double get timeWidth => compact ? 0 : charWidth * (relaxed ? 11 : 14);

  double get tagWidth => compact ? 0 : charWidth * (relaxed ? 9 : 11);

  double get textWidth =>
      max(width - padding * 2 - timeWidth - tagWidth, charWidth * 8);

  int get maxLines => compact ? 3 : (relaxed ? 2 : 1);

  double get rowHeight => lineHeight + verticalPadding * 2;

  double get metaWidth => max(width - padding * 2, charWidth * 8);

  double get expandedExtra => verticalPadding * 2 + metaGap + actionsHeight;

  EdgeInsets get rowPadding => EdgeInsets.fromLTRB(
    padding - stripeWidth,
    verticalPadding,
    padding,
    verticalPadding,
  );

  bool sameFont(TextStyle style, TextScaler textScaler, Locale? locale) =>
      this.style == style &&
      this.textScaler == textScaler &&
      this.locale == locale;

  double measure(InlineSpan span, {double? maxWidth, int? maxLines}) {
    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
      locale: locale,
      textHeightBehavior: textHeightBehavior,
    )..layout(maxWidth: maxWidth ?? textWidth);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

TextSpan _logSpan(Log log, _LogMetrics metrics, _LogColors colors) {
  final style = metrics.style.copyWith(color: colors.payload(log.logLevel));
  final tag = log.tag;
  return TextSpan(
    style: style,
    children: [
      if (metrics.compact) ...[
        TextSpan(
          text: '${log.time.showFullMillis.substring(11, 19)} ',
          style: TextStyle(color: colors.time),
        ),
        TextSpan(
          text: '[$tag] ',
          style: TextStyle(color: colors.tagOf(log)),
        ),
      ],
      ...EmojiText.buildSpans(log.payload, style),
    ],
  );
}

TextSpan _metaSpan(Log log, _LogMetrics metrics, _LogColors colors) {
  return TextSpan(
    text: [
      log.time.showFullMillis,
      log.source == LogSource.app
          ? appLocalizations.app
          : appLocalizations.core,
      ?log.module,
      log.logLevel.label,
    ].join(' · '),
    style: metrics.style.copyWith(color: colors.dim),
  );
}

class _LogScrollPosition extends ScrollPositionWithSingleContext {
  _LogScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  void shiftBy(double delta) {
    final current = activity;
    if (current is DragScrollActivity) {
      correctBy(delta);
      return;
    }
    if (current is BallisticScrollActivity &&
        pixels + delta <= maxScrollExtent) {
      final velocity = current.velocity;
      correctBy(delta);
      goBallistic(velocity);
      return;
    }
    jumpTo(pixels + delta);
  }
}

class _LogScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _LogScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }

  void shiftBy(double delta) {
    final current = position;
    if (current is _LogScrollPosition) {
      current.shiftBy(delta);
      return;
    }
    jumpTo(offset + delta);
  }
}

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView>
    with WidgetsBindingObserver {
  var _autoScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_initLogs);
    });
  }

  void _initLogs() async {
    if (!mounted) return;
    clashCore.startLog();
    final history = await clashCore.getLogs();
    if (!mounted) return;
    if (history.isNotEmpty) {
      ref.read(logsProvider.notifier).mergeHistory(history);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      clashCore.stopLog();
    } else if (state == AppLifecycleState.resumed) {
      _initLogs();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clashCore.stopLog();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() {
      _autoScroll = !_autoScroll;
    });
  }

  void _cancelAutoScroll() {
    if (!_autoScroll) return;
    setState(() {
      _autoScroll = false;
    });
  }

  void _onSearch(String value) {
    ref.read(logsFilterProvider.notifier).setQuery(value);
  }

  Future<void> _handleLogLevelSettings() async {
    final currentLogLevel = ref.read(
      patchClashConfigProvider.select((state) => state.logLevel),
    );

    final selectedLogLevel = await globalState.showAdaptiveSheet<LogLevel>(
      child: OptionsDialog<LogLevel>(
        title: appLocalizations.logLevel,
        options: LogLevel.values,
        value: currentLogLevel,
        textBuilder: (logLevel) => logLevel.label,
      ),
    );

    if (selectedLogLevel != null && selectedLogLevel != currentLogLevel) {
      ref
          .read(patchClashConfigProvider.notifier)
          .updateState((state) => state.copyWith(logLevel: selectedLogLevel));
      globalState.appController.updateClashConfigDebounce();
    }
  }

  Future<void> _handleExport() async {
    final res = await globalState.appController.safeRun<bool>(
      () async {
        return await globalState.appController.exportLogs();
      },
      needLoading: true,
      title: appLocalizations.exportLogs,
    );
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.exportSuccess),
      cancelable: false,
    );
  }

  void _handleClearLogs() {
    ref.read(logsProvider.notifier).clearLogs();
    clashCore.clearLogs();
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(
      patchClashConfigProvider.select((state) => state.logLevel),
    );
    final aiSearch = ref.watch(
      appSettingProvider.select((state) => state.logAiSearch),
    );
    return CommonScaffold(
      actions: [
        IconButton(
          style: _autoScroll
              ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    context.colorScheme.secondaryContainer,
                  ),
                )
              : null,
          onPressed: _toggleAutoScroll,
          tooltip: appLocalizations.autoScroll,
          icon: const Icon(Icons.vertical_align_top_outlined),
        ),
        CommonPopupBox(
          targetBuilder: (open) {
            return IconButton(
              onPressed: () {
                open(offset: const Offset(0, 20));
              },
              tooltip: appLocalizations.more,
              icon: const Icon(Icons.more_vert),
            );
          },
          popup: CommonPopupMenu(
            items: [
              PopupMenuItemData(
                icon: Icons.tune,
                label: '${appLocalizations.logLevel} · ${level.label}',
                onPressed: _handleLogLevelSettings,
              ),
              PopupMenuItemData(
                icon: aiSearch
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                label: appLocalizations.logAiSearch,
                onPressed: () {
                  ref
                      .read(appSettingProvider.notifier)
                      .updateState(
                        (state) => state.copyWith(logAiSearch: !aiSearch),
                      );
                },
              ),
              PopupMenuItemData(
                icon: Icons.file_copy_outlined,
                label: appLocalizations.export,
                onPressed: _handleExport,
              ),
              PopupMenuItemData(
                icon: Icons.delete_sweep_outlined,
                label: appLocalizations.clear,
                onPressed: _handleClearLogs,
              ),
            ],
          ),
        ),
      ],
      searchState: AppBarSearchState(onSearch: _onSearch),
      title: appLocalizations.logs,
      body: LogsConsole(
        onAdjustLevel: _handleLogLevelSettings,
        autoScroll: _autoScroll,
        onCancelAutoScroll: _cancelAutoScroll,
      ),
    );
  }
}

class LogsConsole extends ConsumerStatefulWidget {
  final VoidCallback onAdjustLevel;
  final bool autoScroll;
  final VoidCallback? onCancelAutoScroll;

  const LogsConsole({
    super.key,
    required this.onAdjustLevel,
    this.autoScroll = false,
    this.onCancelAutoScroll,
  });

  @override
  ConsumerState<LogsConsole> createState() => _LogsConsoleState();
}

class _LogsConsoleState extends ConsumerState<LogsConsole> {
  late final _LogScrollController _scrollController;
  final _newCount = ValueNotifier<int>(0);
  var _heights = Expando<double>();
  var _rows = Expando<Widget>();
  ColorScheme? _colorScheme;
  var _filter = const LogsFilterState();
  Log? _expanded;
  var _aiSearch = true;
  _LogMetrics? _metrics;
  _LogColors? _colors;

  @override
  void initState() {
    super.initState();
    _scrollController = _LogScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newCount.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_newCount.value == 0 || !_scrollController.hasClients) return;
    if (_scrollController.offset > 0) return;
    _newCount.value = 0;
  }

  void _backToTop() {
    if (_expanded != null) {
      setState(() {
        _expanded = null;
      });
    }
    _newCount.value = 0;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _handleLogsChanged(FilteredLogs? prev, FilteredLogs next) {
    final filter = ref.read(logsFilterProvider);
    if (filter != _filter) {
      _filter = filter;
      _backToTop();
      return;
    }
    final expanded = _expanded;
    if (expanded != null && !next.logs.contains(expanded)) {
      setState(() {
        _expanded = null;
      });
    }
    if (next.logs.isEmpty || widget.autoScroll) {
      _newCount.value = 0;
      return;
    }
    final metrics = _metrics;
    final colors = _colors;
    if (prev == null || metrics == null || colors == null) return;
    if (prev.logs.isEmpty) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset <= 0 && _expanded == null) return;
    final prevLast = prev.logs.last;
    if (identical(next.logs.last, prevLast)) return;
    final index = next.logs.lastIndexOf(prevLast);
    if (index == -1) return;
    var delta = 0.0;
    for (var i = index + 1; i < next.logs.length; i++) {
      delta += _extentOf(next.logs[i], metrics, colors);
    }
    if (delta <= 0) return;
    _newCount.value += next.logs.length - 1 - index;
    _scrollController.shiftBy(delta);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleScroll();
    });
  }

  _LogMetrics _resolveMetrics(
    BuildContext context,
    double width,
    bool compact,
    bool relaxed,
  ) {
    final textTheme = context.textTheme;
    final base = relaxed
        ? (textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
            height: 1.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          )
        : (textTheme.bodySmall ?? const TextStyle(fontSize: 12)).toJetBrainsMono
              .copyWith(
                height: 1.5,
                letterSpacing: 0,
                fontFeatures: const [
                  FontFeature.disable('liga'),
                  FontFeature.disable('calt'),
                ],
              );
    final style = DefaultTextStyle.of(context).style.merge(base);
    final textScaler = MediaQuery.textScalerOf(context);
    final locale = Localizations.maybeLocaleOf(context);
    final prev = _metrics;
    if (prev != null &&
        prev.sameFont(style, textScaler, locale) &&
        prev.width == width &&
        prev.compact == compact) {
      return prev;
    }
    var charWidth = prev?.charWidth ?? 0;
    var lineHeight = prev?.lineHeight ?? 0;
    if (prev == null || !prev.sameFont(style, textScaler, locale)) {
      final painter = TextPainter(
        text: TextSpan(text: 'X', style: style),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        locale: locale,
      )..layout();
      charWidth = painter.width;
      lineHeight = painter.height;
      painter.dispose();
    }
    _heights = Expando<double>();
    _rows = Expando<Widget>();
    return _metrics = _LogMetrics(
      style: style,
      textScaler: textScaler,
      locale: locale,
      textHeightBehavior: DefaultTextHeightBehavior.maybeOf(context),
      width: width,
      compact: compact,
      relaxed: relaxed,
      charWidth: charWidth,
      lineHeight: lineHeight,
    );
  }

  double _extentOf(Log log, _LogMetrics metrics, _LogColors colors) {
    return _contentExtentOf(log, metrics, colors) + _LogMetrics.dividerHeight;
  }

  double _contentExtentOf(Log log, _LogMetrics metrics, _LogColors colors) {
    if (log == _expanded) {
      return metrics.measure(_logSpan(log, metrics, colors)) +
          metrics.measure(
            _metaSpan(log, metrics, colors),
            maxWidth: metrics.metaWidth,
          ) +
          metrics.expandedExtra;
    }
    if (!metrics.compact && !metrics.relaxed) return metrics.rowHeight;
    return _heights[log] ??=
        metrics.measure(
          _logSpan(log, metrics, colors),
          maxLines: metrics.maxLines,
        ) +
        metrics.verticalPadding * 2;
  }

  _LogColors _resolveColors(ColorScheme scheme) {
    final prev = _colors;
    if (prev != null && scheme == _colorScheme) {
      return prev;
    }
    _colorScheme = scheme;
    _rows = Expando<Widget>();
    return _colors = _LogColors.of(scheme);
  }

  Widget _rowOf(Log log, _LogMetrics metrics, _LogColors colors) {
    if (log == _expanded) return _buildRow(log, metrics, colors, true);
    return _rows[log] ??= _buildRow(log, metrics, colors, false);
  }

  Widget _buildRow(
    Log log,
    _LogMetrics metrics,
    _LogColors colors,
    bool expanded,
  ) {
    return _LogRow(
      log: log,
      metrics: metrics,
      colors: colors,
      expanded: expanded,
      onTap: () => _toggle(log),
      onCopy: () => _copy(log),
      onSearch: _aiSearch ? () => _search(log) : null,
      onFilter: () => _filterBy(log),
    );
  }

  void _toggle(Log log) {
    setState(() {
      _expanded = log == _expanded ? null : log;
    });
    _handleScroll();
  }

  Future<void> _copy(Log log) async {
    await Clipboard.setData(ClipboardData(text: log.raw));
    if (!mounted) return;
    context.showNotifier(appLocalizations.copySuccess);
  }

  void _search(Log log) {
    final uri = Uri.https('www.google.com', '/search', {
      'q': appLocalizations.analyzeLogPrompt(log.raw),
      'udm': '50',
    });
    globalState.openUrl(uri.toString());
  }

  void _filterBy(Log log) {
    final notifier = ref.read(logsFilterProvider.notifier);
    final module = log.module;
    if (module == null) {
      notifier.setSource(log.source);
      return;
    }
    notifier.setModule(module);
  }

  Widget _buildLevelHint(LogLevel level, {required bool centered}) {
    const marker = '\u0000';
    final parts = appLocalizations.logLevelDebugHint(marker).split(marker);
    final style = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              onTap: widget.onAdjustLevel,
              borderRadius: BorderRadius.circular(4),
              child: Text(
                '「 ${level.label} 」',
                style: style?.copyWith(color: context.colorScheme.primary),
              ),
            ),
          ),
          TextSpan(text: parts.last),
        ],
      ),
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: style,
    );
  }

  Widget _buildEmpty({
    required bool hasLogs,
    required bool hasFacet,
    required LogLevel level,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              width: 76,
              height: 76,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasLogs ? Icons.search_off_rounded : Icons.notes_rounded,
                size: 34,
                color: context.colorScheme.primary.withValues(alpha: 0.85),
              ),
            ),
            Text(
              hasLogs
                  ? appLocalizations.noMatchedLogs
                  : appLocalizations.nullTip(appLocalizations.logs),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.toBold,
            ),
            if (hasFacet)
              TextButton(
                onPressed: () =>
                    ref.read(logsFilterProvider.notifier).clearFacets(),
                child: Text(appLocalizations.clearFilter),
              )
            else if (level == LogLevel.debug)
              _buildLevelHint(level, centered: true),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required List<Log> logs,
    required bool compact,
    required LogLevel level,
  }) {
    final textDirection = Directionality.of(context);
    final indexByLog = Map<Log, int>.identity();
    for (var i = 0; i < logs.length; i++) {
      indexByLog[logs[i]] = logs.length - 1 - i;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _resolveMetrics(
          context,
          constraints.maxWidth - _LogMetrics.margin * 2,
          compact,
          level != LogLevel.debug,
        );
        final colors = _resolveColors(context.colorScheme);
        final extents = List<double?>.filled(logs.length, null);
        final slivers = [
          SliverPadding(
            padding: EdgeInsets.only(top: 8),
            sliver: SliverVariedExtentList(
              itemExtentBuilder: (index, _) {
                if (index >= logs.length) return null;
                return extents[index] ??= _extentOf(
                  logs[logs.length - 1 - index],
                  metrics,
                  colors,
                );
              },
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final log = logs[logs.length - 1 - index];
                  return ContinuousListItem(
                    key: ObjectKey(log),
                    index: index,
                    count: logs.length,
                    child: _rowOf(log, metrics, colors),
                  );
                },
                childCount: logs.length,
                addAutomaticKeepAlives: false,
                findChildIndexCallback: (key) =>
                    indexByLog[(key as ObjectKey).value],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: level == LogLevel.debug
                ? Directionality(
                    textDirection: textDirection,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                      child: _buildLevelHint(level, centered: false),
                    ),
                  )
                : const SizedBox(height: 16),
          ),
        ];
        return Stack(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: CommonScrollBar(
                controller: _scrollController,
                child: ScrollToEndBox<Log>(
                  controller: _scrollController,
                  dataSource: logs,
                  enable: widget.autoScroll,
                  onCancelToEnd: widget.onCancelAutoScroll,
                  child: RouteScrollCacheBuilder(
                    builder: (_, cacheExtent) => CustomScrollView(
                      controller: _scrollController,
                      physics: const NextClampingScrollPhysics(),
                      scrollCacheExtent: cacheExtent,
                      slivers: slivers,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _newCount,
                  builder: (_, count, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: count > 0
                        ? _NewLogsPill(count: count, onTap: _backToTop)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredLogsProvider);
    final hasLogs = ref.watch(logsProvider.select((state) => state.length > 0));
    final hasFacet = ref.watch(
      logsFilterProvider.select((state) => state.hasFacet),
    );
    final level = ref.watch(
      patchClashConfigProvider.select((state) => state.logLevel),
    );
    _aiSearch = ref.watch(
      appSettingProvider.select((state) => state.logAiSearch),
    );
    final compact = ref.watch(isMobileViewProvider);

    ref.listen<FilteredLogs>(filteredLogsProvider, _handleLogsChanged);

    return Column(
      children: [
        _LogsFilterBar(
          errors: filtered.errors,
          warnings: filtered.warnings,
          compact: compact,
        ),
        Expanded(
          child: filtered.logs.isEmpty
              ? _buildEmpty(hasLogs: hasLogs, hasFacet: hasFacet, level: level)
              : _buildList(
                  logs: filtered.logs,
                  compact: compact,
                  level: level,
                ),
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  final Log log;
  final _LogMetrics metrics;
  final _LogColors colors;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback? onSearch;
  final VoidCallback onFilter;

  const _LogRow({
    required this.log,
    required this.metrics,
    required this.colors,
    required this.expanded,
    required this.onTap,
    required this.onCopy,
    required this.onSearch,
    required this.onFilter,
  });

  Widget _buildLine() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!metrics.compact) ...[
          SizedBox(
            width: metrics.timeWidth,
            child: Text(
              log.time.showFullMillis.substring(11),
              maxLines: 1,
              softWrap: false,
              style: metrics.style.copyWith(color: colors.time),
            ),
          ),
          SizedBox(
            width: metrics.tagWidth,
            child: Padding(
              padding: EdgeInsets.only(right: metrics.charWidth),
              child: Text(
                '[${log.tag}]',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: metrics.style.copyWith(color: colors.tagOf(log)),
              ),
            ),
          ),
        ],
        SizedBox(
          width: metrics.textWidth,
          child: Text.rich(
            _logSpan(log, metrics, colors),
            maxLines: expanded ? null : metrics.maxLines,
            overflow: expanded ? TextOverflow.clip : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: metrics.rowPadding, child: _buildLine()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.padding - _LogMetrics.stripeWidth,
              _LogMetrics.metaGap,
              metrics.padding,
              0,
            ),
            child: SizedBox(
              width: metrics.metaWidth,
              child: Text.rich(_metaSpan(log, metrics, colors)),
            ),
          ),
          SizedBox(
            height: _LogMetrics.actionsHeight,
            child: Padding(
              padding: EdgeInsets.only(
                left: metrics.padding - _LogMetrics.stripeWidth - 8,
                right: metrics.padding - 8,
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onCopy,
                    style: buttonStyle,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(appLocalizations.copy),
                  ),
                  if (onSearch != null)
                    TextButton.icon(
                      onPressed: onSearch,
                      style: buttonStyle,
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: Text(appLocalizations.search),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Tooltip(
                        message: appLocalizations.onlyShow(log.tag),
                        child: TextButton.icon(
                          onPressed: onFilter,
                          style: buttonStyle,
                          icon: const Icon(Icons.filter_list_rounded, size: 16),
                          label: Text(
                            '[ ${log.tag} ]',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onTap,
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    tooltip: appLocalizations.collapse,
                    icon: const Icon(Icons.expand_less_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = colors.accent(log.logLevel);
    return Container(
      decoration: BoxDecoration(
        color: expanded
            ? colors.expanded
            : accent?.withValues(alpha: colors.tintAlpha),
        border: Border(
          left: BorderSide(
            color: accent ?? Colors.transparent,
            width: _LogMetrics.stripeWidth,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onCopy,
          onSecondaryTap: onCopy,
          hoverColor: colors.hover,
          child: expanded
              ? _buildDetails(context)
              : Padding(padding: metrics.rowPadding, child: _buildLine()),
        ),
      ),
    );
  }
}

class _LogsFilterBar extends ConsumerWidget {
  final int errors;
  final int warnings;
  final bool compact;

  const _LogsFilterBar({
    required this.errors,
    required this.warnings,
    required this.compact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (filterSource, filterLevels, filterModule) = ref.watch(
      logsFilterProvider.select(
        (state) => (state.source, state.levels, state.module),
      ),
    );
    final notifier = ref.read(logsFilterProvider.notifier);
    final colors = _LogColors.of(context.colorScheme);
    final debug = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.logLevel == LogLevel.debug,
      ),
    );
    final dnsSelected = debug && filterModule == _dnsModule;
    final module = dnsSelected ? null : filterModule;
    final tabs = [
      (null, null, appLocalizations.categoryAll),
      (LogSource.app, null, appLocalizations.app),
      (LogSource.core, null, appLocalizations.core),
      if (debug) (null, _dnsModule, _dnsModule),
    ];
    final selectedTab = dnsSelected
        ? tabs.length - 1
        : tabs.indexWhere((tab) => tab.$2 == null && tab.$1 == filterSource);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  Row(
                    spacing: 2,
                    children: [
                      for (final (index, (source, tabModule, label))
                          in tabs.indexed)
                        SegmentButton(
                          label: label,
                          selected: index == selectedTab,
                          first: index == 0,
                          last: index == tabs.length - 1,
                          onTap: () => notifier.setScope(
                            source: source,
                            module:
                                tabModule ??
                                (filterModule == _dnsModule
                                    ? null
                                    : filterModule),
                          ),
                        ),
                    ],
                  ),
                  for (final (level, count, color) in [
                    (LogLevel.error, errors, colors.error),
                    (LogLevel.warning, warnings, colors.warning),
                  ])
                    SegmentButton(
                      label: compact ? '$count' : '$count ${level.label}',
                      tooltip: level.label,
                      color: color,
                      selected: filterLevels.contains(level),
                      faded: count == 0,
                      leading: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: () => notifier.toggleLevel(level),
                    ),
                ],
              ),
            ),
          ),
          if (module != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: SegmentButton(
                  label: module,
                  tooltip: appLocalizations.clearFilter,
                  selected: true,
                  trailing: const Icon(Icons.close_rounded, size: 14),
                  onTap: () => notifier.setModule(null),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NewLogsPill extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NewLogsPill({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      elevation: 2,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: scheme.onSecondaryContainer,
              ),
              Text(
                appLocalizations.newLogsCount(count),
                style: context.textTheme.labelMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
