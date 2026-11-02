import 'dart:math';
import 'dart:ui' as ui;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/providers/state.dart';
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
    final brightness = ref.watch(currentBrightnessProvider);
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
      if (system.isAndroid) const _DarkIconItem(),
      if (system.isWindows) const _TrayIconInvertItem(),
      const _TextScaleFactorItem(),
    ];

    final items = <Widget>[
      const _ThemeModeItem(),
      const _PrimaryColorItem(),
      if (brightness == Brightness.dark) const _PrueBlackItem(),
      if (toggleItems.isNotEmpty) ...generateSection(items: toggleItems),
    ];
    return generateListView(items);
  }
}

class ItemCard extends StatelessWidget {
  final Widget child;
  final Info info;
  final List<Widget> actions;

  const ItemCard({
    super.key,
    required this.info,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoHeader(info: info, actions: actions),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
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
    return ItemCard(
      info: Info(
        label: appLocalizations.themeMode,
        iconData: Icons.brightness_high,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: [
            for (final item in themeModeItems)
              ButtonSegment(
                value: item.themeMode,
                icon: Icon(item.iconData),
                label: Text(item.label),
              ),
          ],
          selected: {themeMode},
          onSelectionChanged: (selection) {
            ref
                .read(themeSettingProvider.notifier)
                .updateState(
                  (state) => state.copyWith(themeMode: selection.first),
                );
          },
        ),
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
      context.showNotifier(
        appLocalizations.existsTip(appLocalizations.colorSchemes),
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

    return ItemCard(
      info: Info(label: appLocalizations.themeColor, iconData: Icons.palette),
      actions: genActions([
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
            icon: const Icon(Icons.replay),
          ),
      ], space: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                (state) => state.copyWith(primaryColor: color),
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
                    icon: Icon(color: context.colorScheme.primary, Icons.add),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrueBlackItem extends ConsumerWidget {
  const _PrueBlackItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prueBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.contrast),
      horizontalTitleGap: 12,
      title: Text(
        appLocalizations.pureBlackMode,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      delegate: SwitchDelegate(
        value: prueBlack,
        onChanged: (value) {
          ref
              .read(themeSettingProvider.notifier)
              .updateState((state) => state.copyWith(pureBlack: value));
        },
      ),
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
      leading: const Icon(Icons.font_download_outlined),
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

class _DarkIconItem extends ConsumerWidget {
  const _DarkIconItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useDarkIcon = ref.watch(
      themeSettingProvider.select((state) => state.useDarkIcon),
    );
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = context.colorScheme.onSurfaceVariant;
    return ListItem.switchItem(
      leading: const Icon(Icons.dark_mode_outlined),
      horizontalTitleGap: 12,
      title: Text(
        appLocalizations.darkIcon,
        style: textTheme.titleSmall?.copyWith(color: onSurfaceVariant),
      ),
      subtitle: Text(
        appLocalizations.darkIconDesc,
        style: textTheme.bodySmall?.copyWith(
          color: onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      delegate: SwitchDelegate(
        value: useDarkIcon,
        onChanged: (value) async {
          await app.setLauncherIcon(value);
          ref
              .read(themeSettingProvider.notifier)
              .updateState((state) => state.copyWith(useDarkIcon: value));
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
      leading: const Icon(Icons.invert_colors),
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
    final (enable, scale) = ref.watch(
      themeSettingProvider.select(
        (state) => (state.textScale.enable, state.textScale.scale),
      ),
    );
    final String process = '${(scale * 100).round()}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListItem.switchItem(
            leading: const Icon(Icons.text_fields),
            horizontalTitleGap: 12,
            title: Text(
              appLocalizations.textScale,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            spacing: 32,
            children: [
              Expanded(
                child: DisabledMask(
                  status: !enable,
                  child: ActivateBox(
                    active: enable,
                    child: SliderTheme(
                      data: _SliderDefaultsM3(context),
                      child: Slider(
                        padding: EdgeInsets.zero,
                        min: minTextScale,
                        max: maxTextScale,
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
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(process, style: context.textTheme.titleMedium),
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

class _SliderDefaultsM3 extends SliderThemeData {
  _SliderDefaultsM3(this.context) : super(trackHeight: 16.0);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  late final Color _overlayColor = WidgetStateColor.resolveWith((
    Set<WidgetState> states,
  ) {
    if (states.contains(WidgetState.dragged)) {
      return _colors.primary.withValues(alpha: 0.1);
    }
    if (states.contains(WidgetState.hovered)) {
      return _colors.primary.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return _colors.primary.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  });

  static final WidgetStateProperty<Size?> _thumbSize =
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return const Size(4.0, 44.0);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Size(4.0, 44.0);
        }
        if (states.contains(WidgetState.focused)) {
          return const Size(2.0, 44.0);
        }
        if (states.contains(WidgetState.pressed)) {
          return const Size(2.0, 44.0);
        }
        return const Size(4.0, 44.0);
      });

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.secondaryContainer;

  @override
  Color? get secondaryActiveTrackColor =>
      _colors.primary.withValues(alpha: 0.54);

  @override
  Color? get disabledActiveTrackColor =>
      _colors.onSurface.withValues(alpha: 0.38);

  @override
  Color? get disabledInactiveTrackColor =>
      _colors.onSurface.withValues(alpha: 0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor =>
      _colors.onSurface.withValues(alpha: 0.38);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withValues(alpha: 1.0);

  @override
  Color? get inactiveTickMarkColor =>
      _colors.onSecondaryContainer.withValues(alpha: 1.0);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onInverseSurface;

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface;

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor => _colors.onSurface.withValues(alpha: 0.38);

  @override
  Color? get overlayColor => _overlayColor;

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(
    context,
  ).textTheme.labelLarge?.copyWith(color: _colors.onInverseSurface);

  @override
  Color? get valueIndicatorColor => _colors.inverseSurface;

  @override
  SliderComponentShape? get valueIndicatorShape =>
      const RoundedRectSliderValueIndicatorShape();

  @override
  SliderComponentShape? get thumbShape => const HandleThumbShape();

  @override
  SliderTrackShape? get trackShape => const GappedSliderTrackShape();

  @override
  SliderComponentShape? get overlayShape => const RoundSliderOverlayShape();

  @override
  SliderTickMarkShape? get tickMarkShape =>
      const RoundSliderTickMarkShape(tickMarkRadius: 4.0 / 2);

  @override
  WidgetStateProperty<Size?>? get thumbSize => _thumbSize;

  @override
  double? get trackGap => 6.0;
}
