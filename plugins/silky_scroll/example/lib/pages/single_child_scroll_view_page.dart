import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:silky_scroll/silky_scroll.dart';

/// SingleChildScrollView preset demo.
///
/// Shows [SilkySingleChildScrollView] as a drop-in replacement for Flutter's
/// [SingleChildScrollView] when the page is a single composed child.
class SingleChildScrollViewPage extends StatefulWidget {
  const SingleChildScrollViewPage({super.key});

  @override
  State<SingleChildScrollViewPage> createState() =>
      _SingleChildScrollViewPageState();
}

class _SingleChildScrollViewPageState extends State<SingleChildScrollViewPage> {
  bool _stretch = true;
  double _speed = 1.0;
  double _edgeDelta = 0;
  PointerDeviceKind? _deviceKind;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Child'),
        actions: [
          if (_deviceKind != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                avatar: Icon(
                  _deviceKind == PointerDeviceKind.mouse
                      ? Icons.mouse
                      : _deviceKind == PointerDeviceKind.touch
                      ? Icons.touch_app
                      : Icons.gesture,
                  size: 16,
                ),
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
                  final index = speeds.indexOf(_speed);
                  _speed = speeds[(index + 1) % speeds.length];
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              avatar: Icon(_stretch ? Icons.expand : Icons.compress, size: 18),
              label: const Text('Stretch'),
              selected: _stretch,
              onSelected: (value) => setState(() => _stretch = value),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SilkySingleChildScrollView(
            key: ValueKey('single_child_${_stretch}_$_speed'),
            physics: const BouncingScrollPhysics(),
            enableStretchEffect: _stretch,
            scrollSpeed: _speed,
            onPointerDeviceKindChanged: (kind) {
              if (!mounted) return;
              if (kind != _deviceKind) {
                setState(() => _deviceKind = kind);
              }
            },
            onEdgeOverScroll: (delta) {
              if (!mounted) return;
              setState(() => _edgeDelta = delta);
              unawaited(
                Future<void>.delayed(const Duration(milliseconds: 600), () {
                  if (mounted) setState(() => _edgeDelta = 0);
                }),
              );
            },
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroPanel(color: cs.primary),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.view_agenda,
                  title: 'Composed page body',
                  body:
                      'Use one child tree with padding, sections, forms, and '
                      'mixed-height content while SilkyScroll handles the '
                      'scroll controller and physics.',
                  color: cs.secondary,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.swap_vert,
                  title: 'Same SingleChildScrollView shape',
                  body:
                      'The preset accepts familiar parameters like padding, '
                      'reverse, clip behavior, and keyboard dismiss behavior.',
                  color: cs.tertiary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Sections',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const _MetricGrid(),
                const SizedBox(height: 20),
                _FormPreview(color: cs.primary),
                const SizedBox(height: 20),
                _Timeline(color: cs.secondary),
                const SizedBox(height: 20),
                _GalleryRow(color: cs.tertiary),
              ],
            ),
          ),
          if (_edgeDelta != 0)
            Positioned(
              top: 12,
              left: 16,
              child: Chip(
                avatar: Icon(Icons.bolt, size: 16, color: cs.error),
                label: Text(
                  'edge: ${_edgeDelta.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: cs.error),
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            foregroundColor: cs.onPrimary,
            child: const Icon(Icons.article, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SilkySingleChildScrollView',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A smooth scroll preset for one composed child.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(body, style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();

  static const _items = <(IconData, String, String)>[
    (Icons.padding, 'Padding', 'Native parameter'),
    (Icons.speed, 'Speed', 'Preset config'),
    (Icons.touch_app, 'Input', 'Device callback'),
    (Icons.vertical_align_bottom, 'Edges', 'Overscroll callback'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 4 ? 1.45 : 1.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final (icon, label, value) = _items[index];
            return _MetricTile(icon: icon, label: label, value: value);
          },
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: cs.primary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                value,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormPreview extends StatelessWidget {
  const _FormPreview({required this.color});

  final Color color;

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
            color: color.withValues(alpha: 0.12),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Profile form',
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Project',
                    hintText: 'silky_scroll example',
                    prefixIcon: const Icon(Icons.folder),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Scroll with a mouse wheel or trackpad',
                    prefixIcon: const Icon(Icons.notes),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content stack',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < 6; index++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: index.isEven
                  ? cs.secondaryContainer
                  : cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                  foregroundColor: cs.onSecondary,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Single child section ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.drag_handle, color: cs.onSurfaceVariant),
              ],
            ),
          ),
      ],
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wide child content',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 120,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14 + index * 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  [Icons.widgets, Icons.dashboard, Icons.article][index],
                  size: 34,
                  color: cs.onSurfaceVariant,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
