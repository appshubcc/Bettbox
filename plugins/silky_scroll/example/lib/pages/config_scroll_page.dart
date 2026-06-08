import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:silky_scroll/silky_scroll.dart';

const int _demoItemCount = 80;
const double _tileHeight = 56;
const double _tileVerticalMargin = 3;
const double _tileExtent = _tileHeight + (_tileVerticalMargin * 2);
const ScrollCacheExtent _demoListCacheExtent = ScrollCacheExtent.pixels(
  _demoItemCount * _tileExtent,
);

/// Config-driven scrolling demo — **side-by-side comparison**.
///
/// The left column uses [SilkyScroll] with the user-tweaked config,
/// while the right column uses Flutter's default scrolling.
/// This makes the difference immediately visible.
class ConfigScrollPage extends StatefulWidget {
  const ConfigScrollPage({super.key});

  @override
  State<ConfigScrollPage> createState() => _ConfigScrollPageState();
}

class _ConfigScrollPageState extends State<ConfigScrollPage> {
  double _speed = 1.0;
  double _durationMs = 1600;
  double _edgeLockMs = 650;
  bool _stretch = true;
  Curve _curve = Curves.easeOutCirc;
  bool _panelOpen = true;
  PointerDeviceKind? _deviceKind;

  static const _curveOptions = <String, Curve>{
    'easeOutCirc': Curves.easeOutCirc,
    'easeOutQuart': Curves.easeOutQuart,
    'easeOutCubic': Curves.easeOutCubic,
    'easeInOut': Curves.easeInOut,
    'decelerate': Curves.decelerate,
    'linear': Curves.linear,
    'bounceOut': Curves.bounceOut,
  };

  String get _curveName => _curveOptions.entries
      .firstWhere(
        (e) => e.value == _curve,
        orElse: () => _curveOptions.entries.first,
      )
      .key;

  SilkyScrollConfig get _config => SilkyScrollConfig(
    scrollSpeed: _speed,
    silkyScrollDuration: Duration(milliseconds: _durationMs.round()),
    animationCurve: _curve,
    edgeLockingDelay: Duration(milliseconds: _edgeLockMs.round()),
    enableStretchEffect: _stretch,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Config Playground'),
        actions: [
          if (_deviceKind != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
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
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: _ComparisonPane(
                  label: 'SilkyScroll',
                  accent: cs.primary,
                  config: _config,
                  onDeviceKindChanged: (kind) {
                    if (kind != _deviceKind) {
                      setState(() => _deviceKind = kind);
                    }
                  },
                ),
              ),
              VerticalDivider(width: 1, color: cs.outlineVariant),
              Expanded(
                child: _DefaultScrollPane(
                  label: 'Default',
                  accent: cs.tertiary,
                ),
              ),
            ],
          ),
          Positioned(top: 12, left: 12, child: _buildConfigPanel(cs)),
        ],
      ),
    );
  }

  Widget _buildConfigPanel(ColorScheme cs) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerLow.withValues(alpha: 0.96),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _panelOpen
              ? SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PanelHeader(
                        color: cs.primary,
                        onClose: () => setState(() => _panelOpen = false),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                        child: Column(
                          children: [
                            _SliderRow(
                              label: 'Speed',
                              value: _speed,
                              min: 0.2,
                              max: 5.0,
                              display: '×${_speed.toStringAsFixed(1)}',
                              onChanged: (v) => setState(() => _speed = v),
                            ),
                            _SliderRow(
                              label: 'Duration',
                              value: _durationMs,
                              min: 100,
                              max: 3000,
                              display: '${_durationMs.round()} ms',
                              onChanged: (v) => setState(() => _durationMs = v),
                            ),
                            _SliderRow(
                              label: 'Edge Lock',
                              value: _edgeLockMs,
                              min: 0,
                              max: 2000,
                              display: '${_edgeLockMs.round()} ms',
                              onChanged: (v) => setState(() => _edgeLockMs = v),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilterChip(
                                  label: const Text('Stretch'),
                                  selected: _stretch,
                                  onSelected: (v) =>
                                      setState(() => _stretch = v),
                                  visualDensity: VisualDensity.compact,
                                  avatar: Icon(
                                    _stretch ? Icons.expand : Icons.compress,
                                    size: 17,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _CurveDropdown(
                                    value: _curveName,
                                    options: _curveOptions.keys,
                                    onChanged: (name) {
                                      if (name != null) {
                                        setState(
                                          () => _curve = _curveOptions[name]!,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: () => setState(() => _panelOpen = true),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox.square(
                    dimension: 44,
                    child: Icon(Icons.tune, color: cs.primary, size: 22),
                  ),
                ),
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.color, required this.onClose});

  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 2),
      child: Row(
        children: [
          Icon(Icons.tune, size: 18, color: color),
          const SizedBox(width: 7),
          Text(
            'Config',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            tooltip: 'Collapse',
          ),
        ],
      ),
    );
  }
}

class _CurveDropdown extends StatelessWidget {
  const _CurveDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final Iterable<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: options
              .map(
                (name) => DropdownMenuItem(
                  value: name,
                  child: Text(name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SilkyScroll side
// ──────────────────────────────────────────────────────────────────────────────

class _ComparisonPane extends StatelessWidget {
  const _ComparisonPane({
    required this.label,
    required this.accent,
    required this.config,
    this.onDeviceKindChanged,
  });

  final String label;
  final Color accent;
  final SilkyScrollConfig config;
  final ValueChanged<PointerDeviceKind?>? onDeviceKindChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaneHeader(label: label, accent: accent, icon: Icons.auto_awesome),
        Expanded(
          child: SilkyScroll.fromConfig(
            config: config,
            builder: (context, controller, physics, deviceKind) {
              if (onDeviceKindChanged != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    onDeviceKindChanged!(deviceKind);
                  }
                });
              }
              return ListView.builder(
                controller: controller,
                physics: physics,
                scrollCacheExtent: _demoListCacheExtent,
                itemExtent: _tileExtent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _demoItemCount,
                semanticChildCount: _demoItemCount,
                itemBuilder: (context, index) =>
                    _ColorTile(index: index, accent: accent),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Default Flutter scroll side
// ──────────────────────────────────────────────────────────────────────────────

class _DefaultScrollPane extends StatelessWidget {
  const _DefaultScrollPane({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaneHeader(label: label, accent: accent, icon: Icons.compare_arrows),
        Expanded(
          child: ListView.builder(
            scrollCacheExtent: _demoListCacheExtent,
            itemExtent: _tileExtent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: _demoItemCount,
            semanticChildCount: _demoItemCount,
            itemBuilder: (context, index) =>
                _ColorTile(index: index, accent: accent),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────────────────────────────────────────

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({
    required this.label,
    required this.accent,
    required this.icon,
  });

  final String label;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: accent.withValues(alpha: 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.index, required this.accent});

  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hue = (index * 7) % 360;
    final color = HSLColor.fromAHSL(1, hue.toDouble(), .55, .8).toColor();
    return Container(
      height: _tileHeight,
      margin: const EdgeInsets.symmetric(vertical: _tileVerticalMargin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Item ${index + 1}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color.computeLuminance() > 0.35
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFF5F5F5),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable slider row
// ──────────────────────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                display,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 3),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
