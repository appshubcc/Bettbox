import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
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

  bool get isNavFocused =>
      _navFocusNodes.values.any((node) => node.hasFocus);

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
      child: Material(
        color: context.colorScheme.surface,
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(navigationStateProvider);
            final isMobile = state.viewMode == ViewMode.mobile;
            final navigationItems = state.navigationItems;
            final currentIndex = state.currentIndex;
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
            if (isMobile) {
              final pageContent = MediaQuery.removePadding(
                removeTop: false,
                removeBottom: false,
                removeLeft: true,
                removeRight: true,
                context: context,
                child: child!,
              );
              final navBar = MediaQuery.removePadding(
                removeTop: true,
                removeBottom: false,
                removeLeft: true,
                removeRight: true,
                context: context,
                child: bottomNavigationBar,
              );
              return Stack(
                children: [
                  Positioned.fill(child: pageContent),
                  Positioned(left: 0, right: 0, bottom: 0, child: navBar),
                ],
              );
            }
            return child!;
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
                  final navigationView = navigationItem.builder(context);
                  return KeepScope(
                    key: ValueKey(navigationItem.label),
                    keep: navigationItem.keep,
                    child: isMobile
                        ? navigationView
                        : Navigator(
                            pages: [MaterialPage(child: navigationView)],
                            onDidRemovePage: (_) {},
                          ),
                  );
                },
              );
            },
          ),
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
                              child: item.icon,
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
  int _currentPageIndex = 0;

  @override
  initState() {
    super.initState();
    _currentPageIndex = _pageIndex;
    _pageController = PageController(initialPage: _currentPageIndex);
    _pageLabelSubscription = ref.listenManual(currentPageLabelProvider, (
      prev,
      next,
    ) {
      if (prev != next) {
        _toPage(next);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationItems.length != widget.navigationItems.length) {
      _updatePageController();
    }
  }

  int get _pageIndex {
    return widget.navigationItems.indexWhere(
      (item) => item.label == globalState.appState.pageLabel,
    );
  }

  Future<void> _toPage(
    PageLabel pageLabel, [
    bool ignoreAnimateTo = false,
  ]) async {
    if (!mounted) {
      return;
    }
    final index = widget.navigationItems.indexWhere(
      (item) => item.label == pageLabel,
    );
    if (index == -1) {
      return;
    }

    if (!globalState.isAndroidTV) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (ref.read(isMobileViewProvider)) {
      if (_currentPageIndex != index) {
        setState(() {
          _currentPageIndex = index;
        });
      }
      return;
    }

    _pageController.jumpToPage(index);
  }

  void _updatePageController() {
    final pageLabel = ref.read(currentPageLabelProvider);
    _toPage(pageLabel, true);
  }

  @override
  void dispose() {
    _pageLabelSubscription.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(isMobileViewProvider)) {
      final index = _pageIndex < 0 ? 0 : _pageIndex;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(widget.navigationItems[index].label),
          child: widget.pageBuilder(context, index),
        ),
      );
    }
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.navigationItems.length,
      itemBuilder: (context, index) {
        return widget.pageBuilder(context, index);
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
      final isCurrentRootPage = rootPageLabels.contains(currentPage);

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop || backBlock) return;
          final navigatorState = globalState.navigatorKey.currentState;
          if (navigatorState?.userGestureInProgress == true) return;

          if (globalState.isAndroidTV) {
            final tvBack = onTvBack;
            if (tvBack != null && tvBack()) return;
          }

          if (!isCurrentRootPage) {
            globalState.appController.toPage(PageLabel.dashboard);
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
