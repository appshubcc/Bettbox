import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OnSelected = void Function(int index);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<int, FocusNode> _navFocusNodes = {};
  int _currentNavIndex = 0;

  FocusNode _getNavFocusNode(int index) {
    return _navFocusNodes.putIfAbsent(index, () => FocusNode());
  }

  void _requestNavFocus(int index) {
    if (!globalState.isAndroidTV) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getNavFocusNode(index).requestFocus();
      }
    });
  }

  bool get isNavFocused => _navFocusNodes.values.any((node) => node.hasFocus);

  void focusNav() {
    if (!globalState.isAndroidTV || !mounted) return;
    _getNavFocusNode(_currentNavIndex).requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (globalState.isAndroidTV) {
      _requestNavFocus(0);
    }
  }

  @override
  void dispose() {
    for (final node in _navFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackScope(
      onTvBack: () {
        final currentPage = globalState.appState.pageLabel;
        final isNav = isNavFocused;

        if (isNav) {
          if (currentPage == PageLabel.dashboard) {
            return false;
          }
          globalState.appController.toPage(PageLabel.dashboard);
          return true;
        }

        focusNav();
        return true;
      },
      child: Consumer(
        builder: (context, ref, child) {
          final (isMobile, navigationItems, currentIndex) = ref.watch(
            navigationStateProvider.select(
              (state) => (
                state.viewMode == ViewMode.mobile,
                state.navigationItems,
                state.currentIndex,
              ),
            ),
          );
          final bottomNavigationBar = globalState.isAndroidTV
              ? _buildTVBottomNavBar(
                  context,
                  navigationItems: navigationItems,
                  currentIndex: currentIndex,
                )
              : GoogleBottomNavBar(
                  navigationItems: navigationItems,
                  selectedIndex: currentIndex,
                  onTabChange: (index) {
                    globalState.appController.toPage(
                      navigationItems[index].label,
                    );
                  },
                  onTabReselect: (index) {
                    globalState.appController.reselectPage(
                      navigationItems[index].label,
                    );
                  },
                );
          if (child == null) {
            return const SizedBox();
          }
          Widget bodyWidget = child;
          if (isMobile && globalState.isAndroidTV) {
            bodyWidget = Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: MediaQuery.removePadding(
                      removeBottom: true,
                      removeLeft: true,
                      removeRight: true,
                      context: context,
                      child: child,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    removeLeft: true,
                    removeRight: true,
                    context: context,
                    child: bottomNavigationBar,
                  ),
                ),
              ],
            );
          } else if (isMobile) {
            final pageContent = MediaQuery.removePadding(
              removeTop: false,
              removeBottom: false,
              removeLeft: true,
              removeRight: true,
              context: context,
              child: FloatingBottomBarScope(child: child),
            );
            final navBar = MediaQuery.removePadding(
              removeTop: true,
              removeBottom: false,
              removeLeft: true,
              removeRight: true,
              context: context,
              child: bottomNavigationBar,
            );
            bodyWidget = Stack(
              children: [
                Positioned.fill(child: RepaintBoundary(child: pageContent)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RepaintBoundary(child: navBar),
                ),
              ],
            );
          }
          return Material(
            color: isMobile
                ? context.colorScheme.pageColor
                : Colors.transparent,
            child: bodyWidget,
          );
        },
        child: Consumer(
          builder: (_, ref, _) {
            final navigationItems = ref
                .watch(currentNavigationItemsStateProvider)
                .value;
            final isMobile = ref.watch(isMobileViewProvider);
            final keepAll =
                isMobile &&
                ref.watch(
                  appSettingProvider.select(
                    (state) => state.enableNavBarHapticFeedback,
                  ),
                );
            return _HomePageView(
              navigationItems: navigationItems,
              pageBuilder: (_, index) {
                final navigationItem = navigationItems[index];
                return _NavigationPage(
                  key: ValueKey(navigationItem.label),
                  item: navigationItem,
                  isMobile: isMobile,
                  keep: navigationItem.keep || keepAll,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTVBottomNavBar(
    BuildContext context, {
    required List<NavigationItem> navigationItems,
    required int currentIndex,
  }) {
    if (_currentNavIndex != currentIndex) {
      _currentNavIndex = currentIndex;
      _requestNavFocus(currentIndex);
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: SafeArea(
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              final focusedIndex = navigationItems.indexWhere(
                (item) =>
                    _navFocusNodes[navigationItems.indexOf(item)]?.hasFocus ==
                    true,
              );
              if (focusedIndex > 0) {
                _getNavFocusNode(focusedIndex - 1).requestFocus();
                return KeyEventResult.handled;
              } else if (focusedIndex == 0) {
                return KeyEventResult.handled;
              }
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              final focusedIndex = navigationItems.indexWhere(
                (item) =>
                    _navFocusNodes[navigationItems.indexOf(item)]?.hasFocus ==
                    true,
              );
              if (focusedIndex >= 0 &&
                  focusedIndex < navigationItems.length - 1) {
                _getNavFocusNode(focusedIndex + 1).requestFocus();
                return KeyEventResult.handled;
              } else if (focusedIndex == navigationItems.length - 1) {
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;
              final focusNode = _getNavFocusNode(index);
              return FocusTraversalOrder(
                order: NumericFocusOrder(index.toDouble()),
                child: AnimatedBuilder(
                  animation: focusNode,
                  builder: (context, child) {
                    final isFocused = focusNode.hasFocus;
                    return InkWell(
                      focusNode: focusNode,
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (isSelected) {
                          globalState.appController.reselectPage(item.label);
                          return;
                        }
                        globalState.appController.toPage(item.label);
                      },
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colorScheme.primary.withValues(
                                  alpha:
                                      context.colorScheme.brightness ==
                                          Brightness.light
                                      ? 0.20
                                      : 0.26,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isFocused
                              ? Border.all(
                                  color: context.colorScheme.primary,
                                  width: 2,
                                )
                              : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color: isSelected
                                    ? context.colorScheme.primary
                                    : context.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              child:
                                  context.resolveIconWidget(item.icon) ??
                                  item.icon,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label.localizedName,
                              style: TextStyle(
                                color: isSelected
                                    ? context.colorScheme.onSecondaryContainer
                                    : context.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavigationPage extends ConsumerStatefulWidget {
  final NavigationItem item;
  final bool isMobile;
  final bool keep;

  const _NavigationPage({
    super.key,
    required this.item,
    required this.isMobile,
    required this.keep,
  });

  @override
  ConsumerState<_NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<_NavigationPage>
    with WidgetsBindingObserver {
  Widget? _view;
  bool _released = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    final isActive =
        ref.read(navigationStateProvider).pageLabel == widget.item.label;
    if (isActive || _released) return;
    setState(() => _released = true);
  }

  @override
  Widget build(BuildContext context) {
    final view = _view ??= widget.item.builder(context);
    final isActive = ref.watch(
      navigationStateProvider.select(
        (state) => state.pageLabel == widget.item.label,
      ),
    );
    if (isActive) _released = false;
    return PageActivityScope(
      isActive: isActive,
      child: TickerMode(
        enabled: isActive,
        child: ExcludeFocus(
          excluding: !isActive,
          child: KeepScope(
            key: ValueKey(widget.item.label),
            keep: widget.keep && !_released,
            child: widget.isMobile
                ? view
                : Navigator(
                    key: ValueKey('${widget.item.label.name}_navigator'),
                    pages: [MaterialPage(child: view)],
                    onDidRemovePage: (_) {},
                  ),
          ),
        ),
      ),
    );
  }
}

class _HomePageView extends ConsumerStatefulWidget {
  final IndexedWidgetBuilder pageBuilder;
  final List<NavigationItem> navigationItems;

  const _HomePageView({
    required this.pageBuilder,
    required this.navigationItems,
  });

  @override
  ConsumerState createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<_HomePageView> {
  late PageController _pageController;
  late final ProviderSubscription<PageLabel> _pageLabelSubscription;
  List<int>? _order;
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex, keepPage: false);
    _pageLabelSubscription = ref.listenManual(currentPageLabelProvider, (
      prev,
      next,
    ) {
      if (prev == next) return;
      final transition = _toPage(next);
      if (next != PageLabel.dashboard || system.isDesktop) return;
      transition.whenComplete(() {
        if (!mounted ||
            ref.read(currentPageLabelProvider) != PageLabel.dashboard) {
          return;
        }
        dashboardRefreshManager.triggerImmediateTick();
        globalState.appController.updateTraffic();
      });
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(
      [for (final item in oldWidget.navigationItems) item.label],
      [for (final item in widget.navigationItems) item.label],
    )) {
      _order = null;
      _toPage(ref.read(currentPageLabelProvider), false);
    }
  }

  int get _pageIndex => _indexOf(globalState.appState.pageLabel);

  int _indexOf(PageLabel pageLabel) {
    final label = shownPageLabelOf(pageLabel, widget.navigationItems);
    return widget.navigationItems.indexWhere((item) => item.label == label);
  }

  Future<void> _toPage(PageLabel pageLabel, [bool animate = true]) async {
    FrameProbe.mark('tab:${pageLabel.name}');
    final index = _indexOf(pageLabel);
    if (index == -1) return;
    if (!globalState.isAndroidTV) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (!_pageController.hasClients) return;
    final slide = ++_slide;
    final page = _pageController.page?.round() ?? index;
    final current = _order?[page] ?? page;
    if (_order != null) {
      setState(() => _order = null);
      _pageController.jumpToPage(current);
    }
    if (!animate ||
        !ref.read(isMobileViewProvider) ||
        !ref.read(appSettingProvider).enableNavBarHapticFeedback ||
        MediaQuery.reduceMotionOf(context)) {
      _pageController.jumpToPage(index);
      return;
    }
    if ((index - current).abs() > 1) {
      final adjacent = index > current ? index - 1 : index + 1;
      setState(() {
        _order = List.generate(widget.navigationItems.length, (item) => item)
          ..[adjacent] = current
          ..[current] = adjacent;
      });
      _pageController.jumpToPage(adjacent);
    }
    await _pageController.animateToPage(
      index,
      duration: kTabScrollDuration,
      curve: Curves.easeOut,
    );
    if (mounted && slide == _slide && _order != null) {
      setState(() => _order = null);
    }
  }

  @override
  void dispose() {
    _pageLabelSubscription.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = _pageIndex < 0 ? 0 : _pageIndex;
    if (!_pageController.hasClients && _pageController.initialPage != index) {
      _order = null;
      _pageController.dispose();
      _pageController = PageController(initialPage: index, keepPage: false);
    }
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      scrollBehavior: ScrollConfiguration.of(context)
          .copyWith(scrollbars: false),
      itemCount: widget.navigationItems.length,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<PageLabel>) return null;
        final index = widget.navigationItems.indexWhere(
          (item) => item.label == key.value,
        );
        return index == -1 ? null : _order?.indexOf(index) ?? index;
      },
      itemBuilder: (context, index) {
        final page = widget.pageBuilder(context, _order?[index] ?? index);
        return SlideSnapshot(
          key: page.key,
          controller: _pageController,
          position: index,
          child: page,
        );
      },
    );
  }
}

class HomeBackScope extends ConsumerWidget {
  final Widget child;
  final bool Function()? onTvBack;

  const HomeBackScope({super.key, required this.child, this.onTvBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (system.isAndroid) {
      final backBlock = ref.watch(backBlockProvider);
      final currentPage = ref.watch(currentPageLabelProvider);
      final rootPageLabels = ref.watch(
        currentNavigationItemsStateProvider.select(
          (state) => state.value.map((item) => item.label).toSet(),
        ),
      );
      final morePageLabels = ref.watch(
        moreToolsSelectorStateProvider.select(
          (state) => state.navigationItems.map((item) => item.label).toSet(),
        ),
      );
      final isCurrentRootPage = rootPageLabels.contains(currentPage);

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop || backBlock) return;
          if (!routeIdleObserver.isSettled) {
            commonPrint.debug('Back ignored during transition');
            return;
          }
          final navigatorState = globalState.navigatorKey.currentState;

          if (globalState.isAndroidTV) {
            final tvBack = onTvBack;
            if (tvBack != null && tvBack()) return;
          }

          if (!isCurrentRootPage) {
            globalState.appController.toPage(
              morePageLabels.contains(currentPage)
                  ? PageLabel.tools
                  : PageLabel.dashboard,
            );
            return;
          }
          if (navigatorState != null && navigatorState.canPop()) {
            navigatorState.pop();
            return;
          }
          await globalState.appController.handleBackOrExit();
        },
        child: child,
      );
    }
    return child;
  }
}
