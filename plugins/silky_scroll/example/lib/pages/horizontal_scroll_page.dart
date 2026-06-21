import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:silky_scroll/silky_scroll.dart';

/// Horizontal mouse-wheel behavior lab.
///
/// Each tab isolates a different nested-scroll shape so mouse-wheel behavior
/// can be tested without changing code.
class HorizontalScrollPage extends StatefulWidget {
  const HorizontalScrollPage({super.key});

  @override
  State<HorizontalScrollPage> createState() => _HorizontalScrollPageState();
}

class _HorizontalScrollPageState extends State<HorizontalScrollPage> {
  bool _stretch = true;
  double _speed = 1.0;
  PointerDeviceKind? _deviceKind;

  static const _tabs = <Tab>[
    Tab(icon: Icon(Icons.crop_landscape), text: 'Standalone'),
    Tab(icon: Icon(Icons.vertical_align_center), text: 'Vertical parent'),
    Tab(icon: Icon(Icons.view_carousel), text: 'Horizontal parent'),
    Tab(icon: Icon(Icons.rule), text: 'Policies'),
  ];

  static const _policyCases = <_PolicyCase>[
    _PolicyCase(
      'Default',
      MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
      Icons.route,
      Colors.indigo,
    ),
    _PolicyCase(
      'Ancestor only',
      MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestor,
      Icons.call_split,
      Colors.teal,
    ),
    _PolicyCase(
      'Always self',
      MouseWheelVerticalDeltaBehavior.always,
      Icons.keyboard_double_arrow_right,
      Colors.deepOrange,
    ),
    _PolicyCase(
      'Shift only',
      MouseWheelVerticalDeltaBehavior.shiftOnly,
      Icons.keyboard,
      Colors.purple,
    ),
  ];

  void _setDeviceKind(PointerDeviceKind? deviceKind) {
    if (deviceKind == null || deviceKind == _deviceKind) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _deviceKind = deviceKind);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Horizontal Scroll'),
          actions: [
            if (_deviceKind != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  avatar: Icon(_deviceIcon(_deviceKind!), size: 16),
                  label: Text(_deviceKind!.name),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ActionChip(
                avatar: const Icon(Icons.speed, size: 18),
                label: Text('x${_speed.toStringAsFixed(1)}'),
                onPressed: () {
                  setState(() {
                    const speeds = [0.5, 1.0, 2.0, 3.0];
                    final idx = speeds.indexOf(_speed);
                    _speed = speeds[(idx + 1) % speeds.length];
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                avatar: Icon(
                  _stretch ? Icons.expand : Icons.compress,
                  size: 18,
                ),
                label: const Text('Stretch'),
                selected: _stretch,
                onSelected: (v) => setState(() => _stretch = v),
              ),
            ),
          ],
          bottom: const TabBar(isScrollable: true, tabs: _tabs),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StandaloneTab(
              stretch: _stretch,
              speed: _speed,
              onDeviceKind: _setDeviceKind,
            ),
            _VerticalParentTab(
              stretch: _stretch,
              speed: _speed,
              onDeviceKind: _setDeviceKind,
            ),
            _HorizontalParentTab(
              stretch: _stretch,
              speed: _speed,
              onDeviceKind: _setDeviceKind,
            ),
            _PoliciesTab(
              stretch: _stretch,
              speed: _speed,
              onDeviceKind: _setDeviceKind,
              policies: _policyCases,
            ),
          ],
        ),
      ),
    );
  }

  IconData _deviceIcon(PointerDeviceKind kind) {
    return switch (kind) {
      PointerDeviceKind.mouse => Icons.mouse,
      PointerDeviceKind.touch => Icons.touch_app,
      _ => Icons.gesture,
    };
  }
}

class _StandaloneTab extends StatelessWidget {
  const _StandaloneTab({
    required this.stretch,
    required this.speed,
    required this.onDeviceKind,
  });

  final bool stretch;
  final double speed;
  final ValueChanged<PointerDeviceKind?> onDeviceKind;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ScenarioHeader(
            icon: Icons.crop_landscape,
            title: 'Standalone horizontal scroll',
            subtitle:
                'No scrollable ancestor wraps this carousel. A vertical mouse wheel without Shift should move the carousel itself.',
          ),
          const SizedBox(height: 16),
          _HorizontalLab(
            title: 'Default behavior',
            subtitle: 'forwardToVerticalAncestorOrSelf',
            accent: Colors.indigo,
            stretch: stretch,
            speed: speed,
            onDeviceKind: onDeviceKind,
          ),
        ],
      ),
    );
  }
}

class _VerticalParentTab extends StatelessWidget {
  const _VerticalParentTab({
    required this.stretch,
    required this.speed,
    required this.onDeviceKind,
  });

  final bool stretch;
  final double speed;
  final ValueChanged<PointerDeviceKind?> onDeviceKind;

  @override
  Widget build(BuildContext context) {
    return SilkyScroll(
      key: ValueKey('vertical-parent-$stretch-$speed'),
      physics: const BouncingScrollPhysics(),
      enableStretchEffect: stretch,
      scrollSpeed: speed,
      builder: (context, controller, physics, deviceKind) {
        onDeviceKind(deviceKind);
        return ListView(
          controller: controller,
          physics: physics,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const _ScenarioHeader(
              icon: Icons.vertical_align_center,
              title: 'Vertical SilkyScroll parent',
              subtitle:
                  'Scroll over a horizontal carousel with a normal mouse wheel. The nearest vertical parent should receive the wheel smoothly.',
            ),
            const SizedBox(height: 16),
            for (final section in _DemoSection.values) ...[
              _HorizontalLab(
                title: section.label,
                subtitle: 'Default policy inside vertical page',
                accent: section.color,
                stretch: stretch,
                speed: speed,
                onDeviceKind: onDeviceKind,
              ),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 480, child: _TailMarker()),
          ],
        );
      },
    );
  }
}

class _HorizontalParentTab extends StatelessWidget {
  const _HorizontalParentTab({
    required this.stretch,
    required this.speed,
    required this.onDeviceKind,
  });

  final bool stretch;
  final double speed;
  final ValueChanged<PointerDeviceKind?> onDeviceKind;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _ScenarioHeader(
            icon: Icons.view_carousel,
            title: 'Horizontal inside horizontal',
            subtitle:
                'The parent is horizontal, so there is no vertical ancestor to forward to. The inner carousel should scroll itself.',
          ),
        ),
        Expanded(
          child: SilkyScroll(
            key: ValueKey('horizontal-parent-$stretch-$speed'),
            direction: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            enableStretchEffect: stretch,
            scrollSpeed: speed,
            builder: (context, controller, physics, deviceKind) {
              onDeviceKind(deviceKind);
              return ListView(
                controller: controller,
                physics: physics,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  for (final group in _DemoSection.values)
                    SizedBox(
                      width: 360,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _HorizontalLab(
                          title: '${group.label} lane',
                          subtitle: 'Nested horizontal child',
                          accent: group.color,
                          stretch: stretch,
                          speed: speed,
                          onDeviceKind: onDeviceKind,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PoliciesTab extends StatelessWidget {
  const _PoliciesTab({
    required this.stretch,
    required this.speed,
    required this.onDeviceKind,
    required this.policies,
  });

  final bool stretch;
  final double speed;
  final ValueChanged<PointerDeviceKind?> onDeviceKind;
  final List<_PolicyCase> policies;

  @override
  Widget build(BuildContext context) {
    return SilkyScroll(
      key: ValueKey('policies-$stretch-$speed'),
      physics: const BouncingScrollPhysics(),
      enableStretchEffect: stretch,
      scrollSpeed: speed,
      builder: (context, controller, physics, deviceKind) {
        onDeviceKind(deviceKind);
        return ListView(
          controller: controller,
          physics: physics,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const _ScenarioHeader(
              icon: Icons.rule,
              title: 'Policy comparison',
              subtitle:
                  'Each carousel uses a different mouseWheelVerticalDeltaBehavior. Test vertical wheel and Shift+wheel over each row.',
            ),
            const SizedBox(height: 16),
            for (final policy in policies) ...[
              _HorizontalLab(
                title: policy.label,
                subtitle: policy.behavior.name,
                icon: policy.icon,
                accent: policy.color,
                stretch: stretch,
                speed: speed,
                behavior: policy.behavior,
                onDeviceKind: onDeviceKind,
              ),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 420, child: _TailMarker()),
          ],
        );
      },
    );
  }
}

class _HorizontalLab extends StatelessWidget {
  const _HorizontalLab({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.stretch,
    required this.speed,
    required this.onDeviceKind,
    this.icon = Icons.tune,
    this.behavior =
        MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final MaterialColor accent;
  final bool stretch;
  final double speed;
  final MouseWheelVerticalDeltaBehavior behavior;
  final ValueChanged<PointerDeviceKind?> onDeviceKind;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: accent.shade100.withValues(alpha: 0.6),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(icon, color: accent.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 178,
            child: SilkyScroll(
              direction: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              enableStretchEffect: stretch,
              scrollSpeed: speed,
              mouseWheelVerticalDeltaBehavior: behavior,
              builder: (context, controller, physics, deviceKind) {
                onDeviceKind(deviceKind);
                return ListView.builder(
                  controller: controller,
                  physics: physics,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: 18,
                  itemBuilder: (context, index) {
                    return _CarouselCard(index: index, accent: accent);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.index, required this.accent});

  final int index;
  final MaterialColor accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.shade100, accent.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accent.shade50.withValues(alpha: 0.78),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: accent.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Card ${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: accent.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'horizontal',
            style: TextStyle(fontSize: 12, color: accent.shade700),
          ),
        ],
      ),
    );
  }
}

class _ScenarioHeader extends StatelessWidget {
  const _ScenarioHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TailMarker extends StatelessWidget {
  const _TailMarker();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            'vertical scroll tail',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _PolicyCase {
  const _PolicyCase(this.label, this.behavior, this.icon, this.color);

  final String label;
  final MouseWheelVerticalDeltaBehavior behavior;
  final IconData icon;
  final MaterialColor color;
}

enum _DemoSection {
  featured('Featured', Colors.amber),
  recent('Recent', Colors.blue),
  popular('Popular', Colors.deepOrange),
  saved('Saved', Colors.teal);

  const _DemoSection(this.label, this.color);

  final String label;
  final MaterialColor color;
}
