import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:silky_scroll/silky_scroll.dart';

/// Basic vertical scrolling demo.
///
/// Shows a [ListView] wrapped in [SilkyScroll] with live scroll-event
/// feedback: offset, delta, and edge-overscroll indicators are all
/// displayed in real time so the user can observe the smooth animation
/// pipeline.
class BasicScrollPage extends StatefulWidget {
  const BasicScrollPage({super.key});

  @override
  State<BasicScrollPage> createState() => _BasicScrollPageState();
}

class _BasicScrollPageState extends State<BasicScrollPage> {
  late final ScrollController _controller;

  // ValueNotifiers for partial rebuilds — only the listening widget rebuilds.
  final _offset = ValueNotifier<double>(0);
  final _lastDelta = ValueNotifier<double>(0);
  final _edgeOverscrollDelta = ValueNotifier<double>(0);
  final _deviceKind = ValueNotifier<PointerDeviceKind?>(null);
  final _physicsLabel = ValueNotifier<String>('—');

  /// Rolling log of recent scroll events (newest first).
  final _log = ValueNotifier<List<_ScrollEvent>>([]);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      _offset.value = _controller.offset;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _offset.dispose();
    _lastDelta.dispose();
    _edgeOverscrollDelta.dispose();
    _deviceKind.dispose();
    _physicsLabel.dispose();
    _log.dispose();
    super.dispose();
  }

  void _onScroll(double delta) {
    _lastDelta.value = delta;
    _addLogEntry(_ScrollEvent('scroll', delta));
  }

  void _onEdgeOverScroll(double delta) {
    _edgeOverscrollDelta.value = delta;
    _addLogEntry(_ScrollEvent('edge', delta));
  }

  void _addLogEntry(_ScrollEvent event) {
    final list = List<_ScrollEvent>.of(_log.value);
    list.insert(0, event);
    if (list.length > 28) list.removeLast();
    _log.value = list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Scroll')),
      body: Column(
        children: [
          // ── Live indicators ──────────────────────────────────────────
          Material(
            color: cs.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: _offset,
                    builder: (_, v, __) => _Indicator(
                      icon: Icons.straighten,
                      label: 'offset',
                      value: v.toStringAsFixed(1),
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder<double>(
                    valueListenable: _lastDelta,
                    builder: (_, v, __) => _Indicator(
                      icon: Icons.speed,
                      label: 'delta',
                      value: v.toStringAsFixed(1),
                      color: cs.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder<double>(
                    valueListenable: _edgeOverscrollDelta,
                    builder: (_, v, __) => _Indicator(
                      icon: Icons.border_top,
                      label: 'edge',
                      value: v.toStringAsFixed(1),
                      color: v != 0 ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder<PointerDeviceKind?>(
                    valueListenable: _deviceKind,
                    builder: (_, dk, __) => _Indicator(
                      icon: dk == PointerDeviceKind.mouse
                          ? Icons.mouse
                          : dk == PointerDeviceKind.touch
                          ? Icons.touch_app
                          : Icons.gesture,
                      label: 'device',
                      value: dk?.name ?? '—',
                      color: cs.tertiary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: _physicsLabel,
                    builder: (_, label, __) {
                      final isBlocked = label == 'Blocked';
                      return _Indicator(
                        icon: isBlocked ? Icons.lock : Icons.lock_open,
                        label: 'physics',
                        value: label,
                        color: isBlocked ? cs.error : cs.primary,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // ── Scrollable content ───────────────────────────────────────
          Expanded(
            child: SilkyScroll(
              controller: _controller,
            //  physics: ClampingScrollPhysics(),
              enableStretchEffect: true,
              onScroll: _onScroll,
              onEdgeOverScroll: _onEdgeOverScroll,
              edgeLockingDelay: Duration(milliseconds: 3000),
              builder: (context, controller, physics, deviceKind) {
                if (deviceKind != _deviceKind.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _deviceKind.value = deviceKind;
                  });
                }
                final label = _physicsName(physics);
                if (label != _physicsLabel.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _physicsLabel.value = label;
                  });
                }
                return ListView.builder(
                  controller: controller,
                  physics: physics,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    return Card(
                      color: cs.surfaceContainerHighest,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          child: Text('${index + 1}'),
                        ),
                        title: Text('Item ${index + 1}'),
                        subtitle: const Text(
                          'Smooth scrolling with SilkyScroll',
                        ),
                        trailing: Icon(Icons.chevron_right, color: cs.outline),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Event log ────────────────────────────────────────────────
          Material(
            color: cs.surfaceContainerLowest,
            child: SizedBox(
              height: 100,
              child: ValueListenableBuilder<List<_ScrollEvent>>(
                valueListenable: _log,
                builder: (_, log, __) {
                  if (log.isEmpty) {
                    return Center(
                      child: Text(
                        'Scroll to see events…',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: log.length,
                    itemBuilder: (context, i) {
                      final e = log[i];
                      final isEdge = e.type == 'edge';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          '${isEdge ? "⚡" : "→"} ${e.type}  '
                          'delta: ${e.delta.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: isEdge ? cs.error : cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

String _physicsName(ScrollPhysics physics) {
  // Walk the chain to find the most descriptive type.
  ScrollPhysics? p = physics;
  while (p != null) {
    if (p is DynamicBlockingScrollPhysics) {
      return p.blockingState.isBlocked ? 'Blocked' : _parentName(p.parent);
    }
    final name = p.runtimeType.toString();
    if (name == 'BlockedScrollPhysics') return 'Blocked';
    if (name == 'ClampingScrollPhysics') return 'Clamping';
    if (name == 'BouncingScrollPhysics') return 'Bouncing';
    if (name == 'NeverScrollableScrollPhysics') return 'Never';
    if (name == 'AlwaysScrollableScrollPhysics') return 'Always';
    p = p.parent;
  }
  return physics.runtimeType.toString().replaceAll('ScrollPhysics', 'Default');
}

String _parentName(ScrollPhysics? p) {
  while (p != null) {
    final name = p.runtimeType.toString();
    if (name == 'ClampingScrollPhysics') return 'Clamping';
    if (name == 'BouncingScrollPhysics') return 'Bouncing';
    if (name == 'AlwaysScrollableScrollPhysics') return 'Always';
    p = p.parent;
  }
  return 'Default';
}

class _ScrollEvent {
  _ScrollEvent(this.type, this.delta);
  final String type;
  final double delta;
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$label: ', style: TextStyle(fontSize: 12, color: color)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
