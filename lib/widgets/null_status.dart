import 'package:material_ui/material_ui.dart';

import '../common/common.dart';

class NullStatus extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? description;
  final Widget? action;

  const NullStatus({
    super.key,
    required this.label,
    this.icon,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final description = this.description;
    final action = this.action;
    final colorScheme = context.colorScheme;
    final title = Text(
      label,
      textAlign: TextAlign.center,
      style: context.textTheme.titleMedium?.toBold,
    );
    if (icon == null && description == null && action == null) {
      return Center(child: title);
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: colorScheme.primary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 18),
            ],
            title,
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 22), action],
          ],
        ),
      ),
    );
  }
}
