import 'package:bett_box/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'text.dart';

class SettingInfoCard extends StatelessWidget {
  final Info info;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingInfoCard(
    this.info, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      elevated: false,
      isSelected: isSelected,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(child: Icon(info.iconData)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(info.label, style: context.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingTextCard extends StatelessWidget {
  final String text;
  final bool? isSelected;
  final VoidCallback onPressed;

  const SettingTextCard(
    this.text, {
    super.key,
    this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      elevated: false,
      onPressed: onPressed,
      isSelected: isSelected,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: EmojiText(text, style: context.textTheme.bodyMedium),
      ),
    );
  }
}

class TitleSettingButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;

  const TitleSettingButton({
    super.key,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          radius: 16,
          highlightShape: BoxShape.circle,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              Icons.settings_outlined,
              size: 18,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
