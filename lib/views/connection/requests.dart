import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'item.dart';

class RequestsView extends ConsumerStatefulWidget {
  const RequestsView({super.key});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView> {
  late final ScrollController _scrollController;
  var _autoScrollToEnd = false;

  @override
  void initState() {
    super.initState();
    final requests = globalState.appState.requests.list;
    _scrollController = ScrollController(
      initialScrollOffset: requests.length * TrackerInfoItem.height,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(requestsSearchProvider.notifier).state = value;
  }

  void _onKeywordsUpdate(List<String> keywords) {
    ref.read(requestsKeywordsProvider.notifier).state = keywords;
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

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(filteredRequestsProvider);
    final hasRequests = requests.isNotEmpty;

    return CommonScaffold(
      title: appLocalizations.requests,
      actions: [
        IconButton(
          onPressed: () {
            ref.read(requestsProvider.notifier).clearRequests();
          },
          icon: const Icon(Icons.delete_sweep_outlined),
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
      ],
      searchState: AppBarSearchState(onSearch: _onSearch),
      onKeywordsUpdate: _onKeywordsUpdate,
      body: !hasRequests
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.requests),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: CommonScrollBar(
                trackVisibility: false,
                controller: _scrollController,
                child: ScrollToEndBox(
                  controller: _scrollController,
                  dataSource: requests,
                  enable: _autoScrollToEnd,
                  onCancelToEnd: _cancelAutoScroll,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentHeight = requests.length * TrackerInfoItem.height;
                      final listViewHeight = contentHeight < constraints.maxHeight
                          ? contentHeight
                          : constraints.maxHeight;

                      return SizedBox(
                        height: listViewHeight,
                        child: ListView.builder(
                          reverse: true,
                          physics: const NextClampingScrollPhysics(),
                          controller: _scrollController,
                          itemBuilder: (_, index) {
                            if (index.isOdd) {
                              return const Divider(height: 0);
                            }
                            final itemIndex = index ~/ 2;
                            if (itemIndex >= requests.length) {
                              return const SizedBox.shrink();
                            }
                            final trackerInfo = requests[itemIndex];
                            return TrackerInfoItem(
                              key: ValueKey(trackerInfo.id),
                              trackerInfo: trackerInfo,
                              onClickKeyword: (value) {
                                context.commonScaffoldState?.addKeyword(value);
                              },
                              detailTitle: appLocalizations.details(
                                appLocalizations.request,
                              ),
                            );
                          },
                          itemExtentBuilder: (index, _) {
                            if (index.isOdd) {
                              return 0;
                            }
                            return TrackerInfoItem.height;
                          },
                          itemCount: requests.length * 2 - 1,
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
