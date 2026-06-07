import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> {
  late final ScrollController _scrollController;
  var _autoScrollToEnd = false;

  @override
  void initState() {
    super.initState();
    final logs = globalState.appState.logs.list;
    _scrollController = ScrollController(
      initialScrollOffset: logs.length * LogItem.height,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(logsSearchProvider.notifier).state = value;
  }

  void _onKeywordsUpdate(List<String> keywords) {
    ref.read(logsKeywordsProvider.notifier).state = keywords;
  }

  void _toggleAutoScroll() {
    setState(() {
      _autoScrollToEnd = !_autoScrollToEnd;
    });
  }

  void _cancelAutoScroll() {
    if (_autoScrollToEnd) {
      setState(() {
        _autoScrollToEnd = false;
      });
    }
  }

  Future<void> _handleLogLevelSettings() async {
    final currentLogLevel = ref.read(
      patchClashConfigProvider.select((state) => state.logLevel),
    );

    final selectedLogLevel = await globalState.showCommonDialog<LogLevel>(
      child: OptionsDialog<LogLevel>(
        title: appLocalizations.logLevel,
        options: LogLevel.values,
        value: currentLogLevel,
        textBuilder: (logLevel) => logLevel.name,
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
    );
  }

  void _handleClearLogs() {
    ref.read(logsProvider.notifier).clearLogs();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(filteredLogsProvider);
    final hasLogs = logs.isNotEmpty;

    return CommonScaffold(
      actions: [
        IconButton(
          onPressed: _handleLogLevelSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: appLocalizations.logLevel,
        ),
        IconButton(
          style: _autoScrollToEnd
              ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    context.colorScheme.secondaryContainer,
                  ),
                )
              : null,
          onPressed: _toggleAutoScroll,
          icon: const Icon(Icons.vertical_align_top_outlined),
        ),
        InkWell(
          onTap: _handleExport,
          onLongPress: _handleClearLogs,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.save_as_outlined, size: 24),
          ),
        ),
      ],
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      title: appLocalizations.logs,
      body: !hasLogs
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.logs),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: ScrollToEndBox(
                onCancelToEnd: _cancelAutoScroll,
                controller: _scrollController,
                enable: _autoScrollToEnd,
                dataSource: logs,
                child: CommonScrollBar(
                  controller: _scrollController,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentHeight = logs.length * LogItem.height;
                      final listViewHeight = contentHeight < constraints.maxHeight
                          ? contentHeight
                          : constraints.maxHeight;

                      return SizedBox(
                        height: listViewHeight,
                        child: ListView.builder(
                          physics: const NextClampingScrollPhysics(),
                          reverse: true,
                          controller: _scrollController,
                          itemBuilder: (_, index) {
                            if (index.isOdd) {
                              return const Divider(height: 0);
                            }
                            final itemIndex = index ~/ 2;
                            if (itemIndex >= logs.length) {
                              return const SizedBox.shrink();
                            }
                            final log = logs[itemIndex];
                            return LogItem(
                              key: ValueKey(log.dateTime),
                              log: log,
                              onClick: (value) {
                                context.commonScaffoldState?.addKeyword(value);
                              },
                            );
                          },
                          itemExtentBuilder: (index, _) {
                            if (index.isOdd) {
                              return 0;
                            }
                            return LogItem.height;
                          },
                          itemCount: logs.length * 2 - 1,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;
  final Function(String)? onClick;

  static double get height {
    final measure = globalState.measure;
    return measure.bodyLargeHeight * 2 +
        8 +
        24 +
        globalState.measure.labelMediumHeight +
        16 +
        16;
  }

  const LogItem({super.key, required this.log, this.onClick});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListItem(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
        globalState.showCommonDialog(child: LogDetailDialog(log: log));
      },
      title: SizedBox(
        height: globalState.measure.bodyLargeHeight * 2,
        child: Text(
          log.payload,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge?.copyWith(
            color: log.logLevel.color,
          ),
        ),
      ),
      subtitle: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonChip(
                onPressed: () {
                  onClick?.call(log.logLevel.name);
                },
                label: log.logLevel.name,
              ),
              Text(
                log.dateTime,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.opacity80,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class LogDetailDialog extends StatelessWidget {
  final Log log;

  const LogDetailDialog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.details(appLocalizations.log),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          SelectableText(
            log.payload,
            style: context.textTheme.bodyLarge?.copyWith(
              color: log.logLevel.color,
            ),
          ),
          SelectableText(
            log.dateTime,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
