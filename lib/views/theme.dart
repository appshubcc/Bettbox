import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class ThemeModeItem {
  final ThemeMode themeMode;
  final IconData iconData;
  final String label;

  const ThemeModeItem({
    required this.themeMode,
    required this.iconData,
    required this.label,
  });
}

class FontFamilyItem {
  final FontFamily fontFamily;
  final String label;

  const FontFamilyItem({required this.fontFamily, required this.label});
}

class ThemeView extends ConsumerWidget {
  const ThemeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowHarmonyFont = ref.watch(
      appSettingProvider.select(
        (state) => switch (state.locale) {
          final locale? => locale.startsWith('zh') || locale.startsWith('en'),
          null => false,
        },
      ),
    );

    final toggleItems = <Widget>[
      if (shouldShowHarmonyFont) const _HarmonyFontItem(),
      const _PhosphorIconsItem(),
      if (system.isWindows) const _TrayIconInvertItem(),
      const _TextScaleFactorItem(),
    ];

    final items = <Widget>[
      ...generateSection(
        title: appLocalizations.themeMode,
        items: [const _ThemeModeItem()],
      ),
      const SizedBox(child: _PrimaryColorItem()),
      if (toggleItems.isNotEmpty) ...generateSection(items: toggleItems),
    ];
    return generateListView(items);
  }
}

class _ThemeModeItem extends ConsumerWidget {
  const _ThemeModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final themeModeItems = <ThemeModeItem>[
      ThemeModeItem(
        iconData: Icons.auto_mode,
        label: appLocalizations.auto,
        themeMode: ThemeMode.system,
      ),
      ThemeModeItem(
        iconData: Icons.light_mode,
        label: appLocalizations.light,
        themeMode: ThemeMode.light,
      ),
      ThemeModeItem(
        iconData: Icons.dark_mode,
        label: appLocalizations.dark,
        themeMode: ThemeMode.dark,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentButtonGroup<ThemeMode>(
        maxWidth: 480,
        options: [
          for (final item in themeModeItems)
            SegmentOption(
              value: item.themeMode,
              icon: AppIcon(item.iconData),
              label: item.label,
            ),
        ],
        selected: themeMode,
        onSelected: (mode) {
          ref
              .read(themeSettingProvider.notifier)
              .updateState((state) => state.copyWith(themeMode: mode));
        },
      ),
    );
  }
}

class _PrimaryColorItem extends ConsumerStatefulWidget {
  const _PrimaryColorItem();

  @override
  ConsumerState<_PrimaryColorItem> createState() => _PrimaryColorItemState();
}

class _PrimaryColorItemState extends ConsumerState<_PrimaryColorItem> {
  int _calcColumns(double maxWidth) {
    return max((maxWidth / 96).ceil(), 3);
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState((state) {
      return state.copyWith(
        primaryColors: defaultPrimaryColors,
        primaryColor: null,
        schemeVariant: DynamicSchemeVariant.content,
      );
    });
  }

  Future<void> _handleDel(int color) async {
    final res = await globalState.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.colorSchemes),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState((state) {
      final newPrimaryColors = List<int>.from(state.primaryColors)
        ..remove(color);
      final int? newPrimaryColor = switch (state.primaryColor == color) {
        true when newPrimaryColors.contains(defaultPrimaryColor) =>
          defaultPrimaryColor,
        true => null,
        false => state.primaryColor,
      };
      return state.copyWith(
        primaryColors: newPrimaryColors,
        primaryColor: newPrimaryColor,
      );
    });
  }

  Future<void> _handleAdd() async {
    final res = await globalState.showCommonDialog<int>(
      child: const _PaletteDialog(),
    );
    if (res == null) {
      return;
    }
    final isExists = ref.read(
      themeSettingProvider.select((state) => state.primaryColors.contains(res)),
    );
    if (isExists && mounted) {
      unawaited(
        context.showNotifier(
          appLocalizations.existsTip(appLocalizations.colorSchemes),
        ),
      );
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState((state) {
      return state.copyWith(
        primaryColors: List<int>.from(state.primaryColors)..add(res),
      );
    });
  }

  Future<void> _handleChangeSchemeVariant() async {
    final schemeVariant = ref.read(
      themeSettingProvider.select((state) => state.schemeVariant),
    );
    final value = await globalState.showAdaptiveSheet<DynamicSchemeVariant>(
      child: OptionsDialog<DynamicSchemeVariant>(
        title: appLocalizations.colorSchemes,
        options: DynamicSchemeVariant.values,
        textBuilder: (item) => Intl.message('${item.name}Scheme'),
        value: schemeVariant,
      ),
    );
    if (value == null) {
      return;
    }
    ref.read(themeSettingProvider.notifier).updateState((state) {
      return state.copyWith(schemeVariant: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final (primaryColor, rawPrimaryColors, schemeVariant, isEquals) = ref.watch(
      themeSettingProvider.select(
        (state) => (
          state.primaryColor,
          state.primaryColors,
          state.schemeVariant,
          state.primaryColor == null &&
              intListEquality.equals(state.primaryColors, defaultPrimaryColors),
        ),
      ),
    );
    final primaryColors = <int?>[null, ...rawPrimaryColors];
    final isDynamic = primaryColor == null && globalState.corePalette != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListHeader(
          title: appLocalizations.themeColor,
          space: 8,
          actions: [
            FilledButton(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              onPressed: isDynamic ? null : _handleChangeSchemeVariant,
              child: Text(
                isDynamic
                    ? appLocalizations.dynamicColor
                    : Intl.message('${schemeVariant.name}Scheme'),
              ),
            ),
            if (!isEquals)
              IconButton.filledTonal(
                iconSize: 20,
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                onPressed: _handleReset,
                icon: Icon(context.resolveIcon(Icons.replay)),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: CommonCard(
            type: CommonCardType.filled,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final columns = _calcColumns(constraints.maxWidth);
                  final itemWidth =
                      (constraints.maxWidth - (columns - 1) * 16) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final color in primaryColors)
                        SizedBox(
                          width: itemWidth,
                          height: itemWidth,
                          child: EffectGestureDetector(
                            onLongPress: color != null
                                ? () {
                                    _handleDel(color);
                                  }
                                : null,
                            child: ColorSchemeBox(
                              isSelected: color == primaryColor,
                              primaryColor: color != null ? Color(color) : null,
                              onPressed: () {
                                ref
                                    .read(themeSettingProvider.notifier)
                                    .updateState(
                                      (state) =>
                                          state.copyWith(primaryColor: color),
                                    );
                              },
                            ),
                          ),
                        ),
                      Container(
                        width: itemWidth,
                        height: itemWidth,
                        padding: const EdgeInsets.all(4),
                        child: IconButton.filledTonal(
                          onPressed: _handleAdd,
                          iconSize: 32,
                          icon: AppIcon(
                            color: context.colorScheme.primary,
                            Icons.add,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HarmonyFontItem extends ConsumerWidget {
  const _HarmonyFontItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useHarmonyFont = ref.watch(
      themeSettingProvider.select((state) => state.useHarmonyFont),
    );
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = context.colorScheme.onSurfaceVariant;
    return ListItem.switchItem(
      leading: const AppIcon(Icons.font_download_outlined),
      horizontalTitleGap: 12,
      title: Text(
        appLocalizations.harmonyFont,
        style: textTheme.titleSmall?.copyWith(color: onSurfaceVariant),
      ),
      subtitle: Text(
        appLocalizations.harmonyFontDesc,
        style: textTheme.bodySmall?.copyWith(
          color: onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      delegate: SwitchDelegate(
        value: useHarmonyFont,
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .updateState((state) => state.copyWith(useHarmonyFont: value));
        },
      ),
    );
  }
}

class _PhosphorIconsItem extends ConsumerWidget {
  const _PhosphorIconsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usePhosphorIcons = ref.watch(
      themeSettingProvider.select((state) => state.usePhosphorIcons),
    );
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = context.colorScheme.onSurfaceVariant;
    return ListItem.switchItem(
      leading: const AppIcon(Icons.style_outlined),
      horizontalTitleGap: 12,
      title: Text(
        appLocalizations.phosphorIcons,
        style: textTheme.titleSmall?.copyWith(color: onSurfaceVariant),
      ),
      subtitle: Text(
        appLocalizations.phosphorIconsDesc,
        style: textTheme.bodySmall?.copyWith(
          color: onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      delegate: SwitchDelegate(
        value: usePhosphorIcons,
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .updateState((state) => state.copyWith(usePhosphorIcons: value));
        },
      ),
    );
  }
}

class _TrayIconInvertItem extends ConsumerWidget {
  const _TrayIconInvertItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invertTrayIcon = ref.watch(
      themeSettingProvider.select((state) => state.invertTrayIcon),
    );
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = context.colorScheme.onSurfaceVariant;
    return ListItem.switchItem(
      leading: const AppIcon(Icons.invert_colors),
      horizontalTitleGap: 12,
      title: Text(
        appLocalizations.trayIconInvert,
        style: textTheme.titleSmall?.copyWith(color: onSurfaceVariant),
      ),
      subtitle: Text(
        appLocalizations.trayIconInvertDesc,
        style: textTheme.bodySmall?.copyWith(
          color: onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      delegate: SwitchDelegate(
        value: invertTrayIcon,
        onChanged: (bool value) async {
          ref
              .read(themeSettingProvider.notifier)
              .updateState((state) => state.copyWith(invertTrayIcon: value));
          await globalState.appController.updateTray(true);
        },
      ),
    );
  }
}

class _TextScaleFactorItem extends ConsumerWidget {
  const _TextScaleFactorItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (enable, rawScale) = ref.watch(
      themeSettingProvider.select(
        (state) => (state.textScale.enable, state.textScale.scale),
      ),
    );
    final scale = rawScale.clamp(minTextScale, maxTextScale).toDouble();
    final String process = '${(scale * 100).round()}%';
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListItem.switchItem(
            leading: const AppIcon(Icons.text_fields),
            horizontalTitleGap: 12,
            title: Text(
              appLocalizations.textScale,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            delegate: SwitchDelegate(
              value: enable,
              onChanged: (value) {
                ref
                    .read(themeSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith.textScale(enable: value),
                    );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
          child: Row(
            spacing: 12,
            children: [
              Text(
                'A',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: DisabledMask(
                  status: !enable,
                  child: ActivateBox(
                    active: enable,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: colorScheme.primary,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                          elevation: 0,
                          pressedElevation: 0,
                        ),
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        padding: EdgeInsets.zero,
                        min: minTextScale,
                        max: maxTextScale,
                        divisions: ((maxTextScale - minTextScale) / 0.05)
                            .round(),
                        value: scale,
                        onChanged: (value) {
                          ref
                              .read(themeSettingProvider.notifier)
                              .updateState(
                                (state) =>
                                    state.copyWith.textScale(scale: value),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'A',
                style: context.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  process,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaletteDialog extends StatefulWidget {
  const _PaletteDialog();

  @override
  State<_PaletteDialog> createState() => _PaletteDialogState();
}

class _PaletteDialogState extends State<_PaletteDialog> {
  static final RegExp _hex6RegExp = RegExp(r'^#?[0-9a-f]{6}$');
  static final RegExp _hex8RegExp = RegExp(r'^#?[0-9a-f]{8}$');
  static final RegExp _rgbRegExp = RegExp(
    r'^rgba?\((\d+),(\d+),(\d+)(?:,([\d.]+))?\)$',
  );

  final _controller = ValueNotifier<ui.Color>(const Color(defaultPrimaryColor));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ui.Color? _parseColor(String input) {
    final cleanInput = input.trim().replaceAll(' ', '').toLowerCase();

    if (_hex6RegExp.hasMatch(cleanInput)) {
      final hexString = cleanInput.startsWith('#')
          ? cleanInput.substring(1)
          : cleanInput;
      final parsed = int.tryParse('FF$hexString', radix: 16);
      return parsed != null ? ui.Color(parsed) : null;
    }

    if (_hex8RegExp.hasMatch(cleanInput)) {
      final hexString = cleanInput.startsWith('#')
          ? cleanInput.substring(1)
          : cleanInput;
      final parsed = int.tryParse(hexString, radix: 16);
      return parsed != null ? ui.Color(parsed) : null;
    }

    if (_rgbRegExp.firstMatch(cleanInput) case final rgbMatch?) {
      if ((rgbMatch.group(1), rgbMatch.group(2), rgbMatch.group(3)) case (
        final rStr?,
        final gStr?,
        final bStr?,
      )) {
        final r = int.tryParse(rStr);
        final g = int.tryParse(gStr);
        final b = int.tryParse(bStr);
        if ((r, g, b) case (final rVal?, final gVal?, final bVal?)) {
          final aStr = rgbMatch.group(4);
          final a = aStr != null ? (double.tryParse(aStr) ?? 1.0) : 1.0;

          final alphaVal = (a * 255).round().clamp(0, 255);
          return ui.Color.fromARGB(
            alphaVal,
            rVal.clamp(0, 255),
            gVal.clamp(0, 255),
            bVal.clamp(0, 255),
          );
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.palette,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.value.toARGB32());
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        children: [
          const SizedBox(height: 8),
          RepaintBoundary(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Palette(controller: _controller),
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<ui.Color>(
            valueListenable: _controller,
            builder: (_, color, _) {
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
                onPressed: () async {
                  final customColorStr = await globalState
                      .showCommonDialog<String>(
                        child: InputDialog(
                          title: appLocalizations.color,
                          value: _controller.value.hex,
                          hintText: '#000000 / rgb(0,0,0)',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return appLocalizations.emptyTip(
                                appLocalizations.color,
                              );
                            }
                            if (_parseColor(value) == null) {
                              return appLocalizations.formatError;
                            }
                            return null;
                          },
                        ),
                      );
                  if (customColorStr != null) {
                    final newColor = _parseColor(customColorStr);
                    if (newColor != null) {
                      _controller.value = newColor;
                    }
                  }
                },
                child: Text(color.hex),
              );
            },
          ),
        ],
      ),
    );
  }
}
