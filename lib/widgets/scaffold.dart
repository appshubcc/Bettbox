import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'dart:async';

import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/widgets/fade_box.dart';
import 'package:bett_box/widgets/pop_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chip.dart';
import 'text.dart';

typedef OnKeywordsUpdateCallback = void Function(List<String> keywords);

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class CommonScaffold extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;
  final AppBarEditState? editState;
  final AppBarSearchState? searchState;
  final OnKeywordsUpdateCallback? onKeywordsUpdate;
  final List<String>? keywords;
  final bool scrollEdgeFade;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.leading,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle,
    this.editState,
    this.searchState,
    this.floatingActionButton,
    this.onKeywordsUpdate,
    this.keywords,
    this.scrollEdgeFade = true,
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
    _keywordsNotifier.value = widget.keywords ?? [];
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
          backgroundColor: Colors.transparent,
          iconTheme: theme.primaryIconTheme.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          titleTextStyle: theme.textTheme.titleLarge,
          toolbarTextStyle: theme.textTheme.bodyMedium,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: theme.inputDecorationTheme.hintStyle,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
      child: child,
    );
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keywords != null &&
        !listEquals(_keywordsNotifier.value, widget.keywords)) {
      _keywordsNotifier.value = widget.keywords!;
    }
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
    _keywordsNotifier.dispose();
    super.dispose();
  }

  void addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)..add(keyword);
    _keywordsNotifier.value = keywords;
    widget.onKeywordsUpdate?.call(keywords);
  }

  void _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)
      ..remove(keyword);
    _keywordsNotifier.value = keywords;
    widget.onKeywordsUpdate?.call(keywords);
  }

  Widget? _buildLeading() {
    if (_isEdit) {
      return IconButton(
        onPressed: _appBarState.value.editState?.onExit,
        icon: const Icon(Icons.close),
        tooltip: appLocalizations.cancel,
      );
    }
    if (_isSearch) {
      return IconButton(
        onPressed: _handleExitSearching,
        icon: const Icon(Icons.arrow_back),
        tooltip: appLocalizations.back,
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
        : !_isEdit && widget.titleWidget != null
        ? widget.titleWidget!
        : EmojiText(
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
        IconButton(
          onPressed: _handleClear,
          icon: const Icon(Icons.close),
          tooltip: appLocalizations.clear,
        ),
      ]);
    }
    return genActions([
      if (hasSearch)
        IconButton(
          onPressed: () {
            _updateSearchState((state) => state?.copyWith(query: ''));
            unawaited(_searchFocusNode.requestFocusWhenIdle());
          },
          icon: const Icon(Icons.search),
          tooltip: appLocalizations.search,
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
    assert(
      widget.appBar != null ||
          widget.title != null ||
          widget.titleWidget != null,
    );
    final body = SafeArea(
      top: false,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: _keywordsNotifier,
            builder: (_, keywords, _) {
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
          Expanded(
            child: widget.scrollEdgeFade
                ? _ScrollEdgeFade(
                    backgroundColor: widget.backgroundColor,
                    child: widget.body,
                  )
                : widget.body,
          ),
        ],
      ),
    );
    return DesktopBackShortcutWrapper(
      child: Consumer(
        builder: (context, ref, _) {
          final isMobileView = ref.watch(isMobileViewProvider);
          return Scaffold(
            appBar: _buildAppBar(),
            body: body,
            resizeToAvoidBottomInset: true,
            backgroundColor:
                widget.backgroundColor ??
                (isMobileView
                    ? context.colorScheme.surfaceContainer
                    : Colors.transparent),
            floatingActionButton:
                widget.floatingActionButton ??
                ValueListenableBuilder<Widget?>(
                  valueListenable: _floatingActionButton,
                  builder: (_, value, _) {
                    return IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: FadeScaleBox(child: value ?? const SizedBox()),
                      ),
                    );
                  },
                ),
          );
        },
      ),
    );
  }
}

class _ScrollEdgeFade extends ConsumerStatefulWidget {
  final Color? backgroundColor;
  final Widget child;

  const _ScrollEdgeFade({required this.backgroundColor, required this.child});

  @override
  ConsumerState<_ScrollEdgeFade> createState() => _ScrollEdgeFadeState();
}

class _ScrollEdgeFadeState extends ConsumerState<_ScrollEdgeFade> {
  static const _extent = 24.0;
  static final _stops = [for (var i = 0; i <= 8; i++) i / 8];
  static final _alphas = [
    for (final stop in _stops) (1 - stop) * (1 - stop) * (1 + stop),
  ];
  bool _scrolledUnder = false;
  double _rise = 0;

  double? get _bodyHeight {
    final box = context.findRenderObject();
    return box is RenderBox ? box.constraints.maxHeight : null;
  }

  bool _handleScroll(ScrollMetrics metrics, int depth, BuildContext? source) {
    if (depth != 0 || metrics.axis != Axis.vertical) return false;
    final viewport = source?.findRenderObject();
    final box = context.findRenderObject();
    if (viewport is! RenderBox || box is! RenderBox) return false;
    final top = viewport.localToGlobal(Offset.zero, ancestor: box).dy;
    final rise = (top + ScrollEdgeRise.extent).abs() < 1
        ? ScrollEdgeRise.extent
        : 0.0;
    final scrolledUnder = (top + rise).abs() < 1 && metrics.extentBefore > 0;
    if (scrolledUnder == _scrolledUnder && (!scrolledUnder || rise == _rise)) {
      return false;
    }
    void apply() {
      if (!mounted) return;
      setState(() {
        _scrolledUnder = scrolledUnder;
        if (scrolledUnder) _rise = rise;
      });
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.backgroundColor ??
        (ref.watch(isMobileViewProvider)
            ? context.colorScheme.surfaceContainer
            : null);
    final opaque = color != null && color.a == 1;
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) => _handleScroll(
        notification.metrics,
        notification.depth,
        notification.context,
      ),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) => _handleScroll(
          notification.metrics,
          notification.depth,
          notification.context,
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _scrolledUnder ? 1 : 0),
          duration: const Duration(milliseconds: 200),
          child: _ScrollEdgeScope(state: this, child: widget.child),
          builder: (_, value, child) {
            return Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              children: [
                _EdgeMask(
                  extent: _extent,
                  rise: _rise,
                  strength: opaque ? 0 : value,
                  stops: _stops,
                  alphas: _alphas,
                  child: child,
                ),
                if (opaque && value > 0)
                  Positioned(
                    top: -_rise,
                    left: 0,
                    right: 0,
                    height: _extent,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: _stops,
                            colors: [
                              for (final alpha in _alphas)
                                color.withValues(alpha: alpha * value),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScrollEdgeScope extends InheritedWidget {
  final _ScrollEdgeFadeState state;

  const _ScrollEdgeScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_ScrollEdgeScope oldWidget) => false;
}

class ScrollEdgeRise extends StatefulWidget {
  static const extent = 8.0;

  final Widget Function(BuildContext context, double rise) builder;

  const ScrollEdgeRise({super.key, required this.builder});

  @override
  State<ScrollEdgeRise> createState() => _ScrollEdgeRiseState();
}

class _ScrollEdgeRiseState extends State<ScrollEdgeRise> {
  Widget? _child;
  double? _rise;

  @override
  void didUpdateWidget(ScrollEdgeRise oldWidget) {
    super.didUpdateWidget(oldWidget);
    _child = null;
  }

  Widget _childOf(double rise) {
    final child = _child;
    if (child != null && rise == _rise) return child;
    _rise = rise;
    return _child = Builder(
      builder: (context) => widget.builder(context, rise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<_ScrollEdgeScope>()
        ?.state;
    if (state == null) return widget.builder(context, 0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final bodyHeight = state._bodyHeight;
        final risen =
            height.isFinite && bodyHeight != null && height >= bodyHeight;
        const extent = ScrollEdgeRise.extent;
        return OverflowBox(
          alignment: Alignment.bottomCenter,
          minHeight: risen ? height + extent : null,
          maxHeight: risen ? height + extent : null,
          fit: risen ? OverflowBoxFit.max : OverflowBoxFit.deferToChild,
          child: _childOf(risen ? extent : 0),
        );
      },
    );
  }
}

class _EdgeMask extends SingleChildRenderObjectWidget {
  final double extent;
  final double rise;
  final double strength;
  final List<double> stops;
  final List<double> alphas;

  const _EdgeMask({
    required this.extent,
    required this.rise,
    required this.strength,
    required this.stops,
    required this.alphas,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderEdgeMask(extent, rise, strength, stops, alphas);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderEdgeMask renderObject) {
    renderObject
      ..rise = rise
      ..strength = strength;
  }
}

class _RenderEdgeMask extends RenderProxyBox {
  final double extent;
  final List<double> stops;
  final List<double> alphas;
  double _rise;
  double _strength;

  _RenderEdgeMask(
    this.extent,
    this._rise,
    this._strength,
    this.stops,
    this.alphas,
  );

  set rise(double value) {
    if (value == _rise) return;
    _rise = value;
    markNeedsPaint();
  }

  set strength(double value) {
    if (value == _strength) return;
    final needed = alwaysNeedsCompositing;
    _strength = value;
    if (needed != alwaysNeedsCompositing) markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child != null && _strength > 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || _strength == 0 || size.height < extent) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    final rect = Rect.fromLTRB(0, -_rise, size.width, size.height);
    final mask = (layer as ShaderMaskLayer?) ?? ShaderMaskLayer();
    layer = mask
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [for (final stop in stops) stop * extent / rect.height],
        colors: [
          for (final alpha in alphas)
            Colors.black.withValues(alpha: 1 - alpha * _strength),
        ],
      ).createShader(Offset.zero & rect.size)
      ..maskRect = rect.shift(offset)
      ..blendMode = BlendMode.dstIn;
    context.pushLayer(mask, super.paint, offset);
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
