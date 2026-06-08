import 'package:flutter/material.dart';
import 'pages/basic_scroll_page.dart';
import 'pages/nested_scroll_page.dart';
import 'pages/horizontal_scroll_page.dart';
import 'pages/config_scroll_page.dart';
import 'pages/single_child_scroll_view_page.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const SilkyScrollExampleApp());
}

class SilkyScrollExampleApp extends StatelessWidget {
  const SilkyScrollExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silky Scroll Example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _buildCurrentPage() {
    return switch (_currentIndex) {
      0 => const BasicScrollPage(),
      1 => const NestedScrollPage(),
      2 => const HorizontalScrollPage(),
      3 => const ConfigScrollPage(),
      4 => const SingleChildScrollViewPage(),
      _ => const BasicScrollPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Basic',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Nested',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            selectedIcon: Icon(Icons.swap_horiz_rounded),
            label: 'Horizontal',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Config',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_agenda_outlined),
            selectedIcon: Icon(Icons.view_agenda),
            label: 'Single',
          ),
        ],
      ),
    );
  }
}
