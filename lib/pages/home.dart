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
            return _HomePageView(
              navigationItems: navigationItems,
              pageBuilder: (_, index) {
                final navigationItem = navigationItems[index];
                return _NavigationPage(
                  key: ValueKey(navigationItem.label),
                  item: navigationItem,
                  isMobile: isMobile,
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

  const _NavigationPage({
    super.key,
    required this.item,
    required this.isMobile,
  });

  @override
  ConsumerState<_NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<_NavigationPage> {
  Widget? _view;

  @override
  Widget build(BuildContext context) {
    final view = _view ??= widget.item.builder(context);
    final isActive = ref.watch(
      navigationStateProvider.select(
        (state) => state.pageLabel == widget.item.label,
      ),
    );
    return PageActivityScope(
      isActive: isActive,
      child: TickerMode(
        enabled: isActive,
        child: ExcludeFocus(
          excluding: !isActive,
          child: KeepScope(
            key: ValueKey(widget.item.label),
            keep: widget.item.keep,
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

class _HomePageViewState extends ConsumerState<_HomePageView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late final ProviderSubscription<PageLabel> _pageLabelSubscription;
  late final _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );
  late final _fade = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex, keepPage: false);
    _pageLabelSubscription = ref.listenManual(currentPageLabelProvider, (
      prev,
      next,
    ) {
      if (prev == next) return;
      _toPage(next);
      if (next == PageLabel.dashboard && !system.isDesktop) {
        dashboardRefreshManager.triggerImmediateTick();
        globalState.appController.updateTraffic();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(
      [for (final item in oldWidget.navigationItems) item.label],
      [for (final item in widget.navigationItems) item.label],
    )) {
      _toPage(ref.read(currentPageLabelProvider));
    }
  }

  int get _pageIndex => _indexOf(globalState.appState.pageLabel);

  int _indexOf(PageLabel pageLabel) {
    final label = shownPageLabelOf(pageLabel, widget.navigationItems);
    return widget.navigationItems.indexWhere((item) => item.label == label);
  }

  void _toPage(PageLabel pageLabel) {
    FrameProbe.mark('tab:${pageLabel.name}');
    final index = _indexOf(pageLabel);
    if (index == -1) return;
    if (!globalState.isAndroidTV) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (!_pageController.hasClients || _pageController.page?.round() == index) {
      return;
    }
    _pageController.jumpToPage(index);
    if (ref.read(isMobileViewProvider) &&
        ref.read(appSettingProvider).enableNavBarHapticFeedback) {
      _fadeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pageLabelSubscription.close();
    _pageController.dispose();
    _fade.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = _pageIndex < 0 ? 0 : _pageIndex;
    if (!_pageController.hasClients && _pageController.initialPage != index) {
      _pageController.dispose();
      _pageController = PageController(initialPage: index, keepPage: false);
    }
    final pageView = PageView.builder(
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
        return index == -1 ? null : index;
      },
      itemBuilder: widget.pageBuilder,
    );
    return FadeTransition(opacity: _fade, child: pageView);
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
            commonPrint.log('Back ignored: route transition not settled');
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
