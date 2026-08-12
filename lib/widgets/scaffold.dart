import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'dart:async';

import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/widgets/fade_box.dart';
import 'package:bett_box/widgets/pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chip.dart';

typedef OnKeywordsUpdateCallback = void Function(List<String> keywords);

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class CommonScaffold extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;
  final AppBarEditState? editState;
  final AppBarSearchState? searchState;
  final OnKeywordsUpdateCallback? onKeywordsUpdate;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.leading,
    this.title,
    this.actions,
    this.centerTitle,
    this.editState,
    this.searchState,
    this.floatingActionButton,
    this.onKeywordsUpdate,
  });

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<Widget?> _floatingActionButton = ValueNotifier(null);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final _textController = TextEditingController();
  final _searchFocusNode = FocusNode();

  bool get _isSearch {
    return _appBarState.value.searchState?.query != null;
  }

  bool get _isEdit {
    final editState = _appBarState.value.editState;
    if (editState == null) {
      return false;
    }
    return editState.editCount > 0;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(
      AppBarState(editState: widget.editState, searchState: widget.searchState),
    );
  }

  Future<void> _updateSearchState(AppBarSearchStateBuilder builder) async {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(_appBarState.value.searchState),
    );
  }

  set floatingActionButton(Widget? floatingActionButton) {
    if (_floatingActionButton.value != floatingActionButton) {
      _floatingActionButton.value = floatingActionButton;
    }
  }

  Widget _buildSearchingAppBarTheme(Widget child) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: colorScheme.brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
          titleTextStyle: theme.textTheme.titleLarge,
          toolbarTextStyle: theme.textTheme.bodyMedium,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: theme.inputDecorationTheme.hintStyle,
          border: InputBorder.none,
        ),
      ),
      child: child,
    );
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editState != widget.editState) {
      _appBarState.value = _appBarState.value.copyWith(
        editState: widget.editState,
      );
    }
    if (oldWidget.searchState != widget.searchState) {
      _appBarState.value = _appBarState.value.copyWith(
        searchState: widget.searchState,
      );
    }
  }

  void _handleClearInput() {
    _textController.text = '';
    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch('');
    }
  }

  void _handleClear() {
    if (_textController.text.isNotEmpty) {
      _handleClearInput();
      return;
    }
    _searchFocusNode.unfocus();
    _updateSearchState((state) => state?.copyWith(query: null));
  }

  void _handleExitSearching() {
    _searchFocusNode.unfocus();
    _handleClearInput();
    _updateSearchState((state) => state?.copyWith(query: null));
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _appBarState.dispose();
    _textController.dispose();
    _floatingActionButton.dispose();
    super.dispose();
  }

  void addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)..add(keyword);
    _keywordsNotifier.value = keywords;
  }

  void _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)
      ..remove(keyword);
    _keywordsNotifier.value = keywords;
  }

  Widget? _buildLeading() {
    if (_isEdit) {
      return IconButton(
        onPressed: _appBarState.value.editState?.onExit,
        icon: Icon(Icons.close),
      );
    }
    if (_isSearch) {
      return IconButton(
        onPressed: _handleExitSearching,
        icon: Icon(Icons.arrow_back),
      );
    }
    return widget.leading;
  }

  Widget _buildTitle(AppBarSearchState? startState) {
    return _isSearch
        ? TextField(
            focusNode: _searchFocusNode,
            controller: _textController,
            style: context.textTheme.titleLarge,
            onChanged: (value) {
              if (startState != null) {
                startState.onSearch(value);
              }
            },
            decoration: InputDecoration(hintText: appLocalizations.search),
          )
        : Text(
            !_isEdit
                ? widget.title!
                : appLocalizations.selectedCountTitle(
                    '${_appBarState.value.editState?.editCount ?? 0}',
                  ),
          );
  }

  List<Widget> _buildActions(bool hasSearch, List<Widget> actions) {
    if (_isSearch) {
      return genActions([
        IconButton(onPressed: _handleClear, icon: Icon(Icons.close)),
      ]);
    }
    return genActions([
      if (hasSearch)
        IconButton(
          onPressed: () {
            _updateSearchState((state) => state?.copyWith(query: ''));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!mounted || !_isSearch) return;
                _searchFocusNode.requestFocus();
              });
            });
          },
          icon: Icon(Icons.search),
        ),
      ...actions,
    ]);
  }

  Widget _buildAppBarWrap(Widget child) {
    final appBar = _isSearch ? _buildSearchingAppBarTheme(child) : child;
    if (_isEdit || _isSearch) {
      return SystemBackBlock(
        child: CommonPopScope(
          onPop: () {
            if (_isEdit || _isSearch) {
              _handleExitSearching();
              _appBarState.value.editState?.onExit();
              return false;
            }
            return true;
          },
          child: appBar,
        ),
      );
    }
    return appBar;
  }

  Widget _buildLoading() {
    return Consumer(
      builder: (_, ref, _) {
        final loading = ref.watch(loadingProvider);
        final isMobileView = ref.watch(isMobileViewProvider);
        return loading && isMobileView
            ? const LinearProgressIndicator()
            : Container();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          widget.appBar ??
              ValueListenableBuilder<AppBarState>(
                valueListenable: _appBarState,
                builder: (_, state, _) {
                  return _buildAppBarWrap(
                    AppBar(
                      centerTitle: widget.centerTitle ?? false,
                      leading: _buildLeading(),
                      title: _buildTitle(state.searchState),
                      actions: _buildActions(
                        state.searchState != null,
                        state.actions.isNotEmpty
                            ? state.actions
                            : widget.actions ?? [],
                      ),
                    ),
                  );
                },
              ),
          _buildLoading(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.appBar != null || widget.title != null);
    final body = SafeArea(
      top: false,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: _keywordsNotifier,
            builder: (_, keywords, _) {
              if (widget.onKeywordsUpdate != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onKeywordsUpdate!(keywords);
                });
              }
              if (keywords.isEmpty) {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final keyword in keywords)
                      CommonChip(
                        label: keyword,
                        type: ChipType.delete,
                        onPressed: () {
                          _deleteKeyword(keyword);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(child: widget.body),
        ],
      ),
    );
    return DesktopBackShortcutWrapper(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: body,
        resizeToAvoidBottomInset: true,
        backgroundColor: widget.backgroundColor,
        floatingActionButton:
            widget.floatingActionButton ??
            ValueListenableBuilder<Widget?>(
              valueListenable: _floatingActionButton,
              builder: (_, value, _) {
                return IntrinsicWidth(
                  child: IntrinsicHeight(
                    child: FadeScaleBox(child: value ?? SizedBox()),
                  ),
                );
              },
            ),
      ),
    );
  }
}

List<Widget> genActions(List<Widget> actions, {double? space}) {
  return <Widget>[
    ...actions.separated(SizedBox(width: space ?? 4)),
    SizedBox(width: 8),
  ];
}

class DesktopBackShortcutWrapper extends StatelessWidget {
  final Widget child;

  const DesktopBackShortcutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!system.isDesktop) return child;
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        if (!system.isMacOS)
          const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): () {
            Navigator.maybePop(context);
          },
        if (system.isMacOS)
          const SingleActivator(
            LogicalKeyboardKey.bracketLeft,
            meta: true,
          ): () {
            Navigator.maybePop(context);
          },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
