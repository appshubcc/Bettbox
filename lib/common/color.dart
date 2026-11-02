import 'dart:math';

import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';

extension ColorExtension on Color {
  Color get opacity80 {
    return withAlpha(204);
  }

  Color get opacity60 {
    return withAlpha(153);
  }

  Color get opacity50 {
    return withAlpha(128);
  }

  Color get opacity38 {
    return withAlpha(97);
  }

  Color get opacity30 {
    return withAlpha(77);
  }

  Color get opacity12 {
    return withAlpha(31);
  }

  Color get opacity15 {
    return withAlpha(38);
  }

  Color get opacity10 {
    return withAlpha(15);
  }

  Color get opacity3 {
    return withAlpha(76);
  }

  Color get opacity0 {
    return withAlpha(0);
  }

  int get value32bit {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  int get alpha8bit => (0xff000000 & value32bit) >> 24;

  int get red8bit => (0x00ff0000 & value32bit) >> 16;

  int get green8bit => (0x0000ff00 & value32bit) >> 8;

  int get blue8bit => (0x000000ff & value32bit) >> 0;

  int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  Color lighten([double amount = 10]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.white;
    final HSLColor hsl = this == const Color(0xFF000000)
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);
    return hsl
        .withLightness(min(1, max(0, hsl.lightness + amount / 100)))
        .toColor();
  }

  String get hex {
    final value = toARGB32();
    final red = (value >> 16) & 0xFF;
    final green = (value >> 8) & 0xFF;
    final blue = value & 0xFF;
    return '#${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color darken([final int amount = 10]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.black;
    final HSLColor hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(min(1, max(0, hsl.lightness - amount / 100)))
        .toColor();
  }

  Color blendDarken(BuildContext context, {double factor = 0.1}) {
    final brightness = Theme.of(context).brightness;
    return Color.lerp(
      this,
      brightness == Brightness.dark ? Colors.white : Colors.black,
      factor,
    )!;
  }

  Color blendLighten(BuildContext context, {double factor = 0.1}) {
    final brightness = Theme.of(context).brightness;
    return Color.lerp(
      this,
      brightness == Brightness.dark ? Colors.black : Colors.white,
      factor,
    )!;
  }
}

Color _capChroma(Color color, double maxChroma) {
  final hct = Hct.fromInt(color.toARGB32());
  if (hct.chroma <= maxChroma) return color;
  return Color(Hct.from(hct.hue, maxChroma, hct.tone).toInt());
}

extension ColorSchemeExtension on ColorScheme {
  Color get pageColor =>
      brightness == Brightness.dark ? surface : surfaceContainer;

  ColorScheme toNeutralSurfaces() {
    final paper = brightness == Brightness.light ? 1.5 : 3.0;
    return copyWith(
      surface: _capChroma(surface, paper),
      surfaceBright: _capChroma(surfaceBright, paper),
      surfaceDim: _capChroma(surfaceDim, 3),
      surfaceContainerLowest: _capChroma(surfaceContainerLowest, 3),
      surfaceContainerLow: _capChroma(surfaceContainerLow, 3),
      surfaceContainer: _capChroma(surfaceContainer, 3),
      surfaceContainerHigh: _capChroma(surfaceContainerHigh, 3),
      surfaceContainerHighest: _capChroma(surfaceContainerHighest, 3),
      outlineVariant: _capChroma(outlineVariant, 4),
    );
  }

  ColorScheme toPureBlack(bool isPrueBlack) => isPrueBlack
      ? copyWith(
          surface: Colors.black,
          surfaceContainerLowest: Colors.black,
          surfaceContainer: Colors.black,
          surfaceContainerLow: Color.lerp(
            Colors.black,
            surfaceContainerLow,
            0.6,
          )!,
          surfaceContainerHigh: Color.lerp(
            Colors.black,
            surfaceContainerHigh,
            0.8,
          )!,
        )
      : this;
}

extension DynamicSchemeExtension on DynamicScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: Color(MaterialDynamicColors.primary.getArgb(this)),
      onPrimary: Color(MaterialDynamicColors.onPrimary.getArgb(this)),
      primaryContainer: Color(
        MaterialDynamicColors.primaryContainer.getArgb(this),
      ),
      onPrimaryContainer: Color(
        MaterialDynamicColors.onPrimaryContainer.getArgb(this),
      ),
      primaryFixed: Color(MaterialDynamicColors.primaryFixed.getArgb(this)),
      primaryFixedDim: Color(
        MaterialDynamicColors.primaryFixedDim.getArgb(this),
      ),
      onPrimaryFixed: Color(MaterialDynamicColors.onPrimaryFixed.getArgb(this)),
      onPrimaryFixedVariant: Color(
        MaterialDynamicColors.onPrimaryFixedVariant.getArgb(this),
      ),
      secondary: Color(MaterialDynamicColors.secondary.getArgb(this)),
      onSecondary: Color(MaterialDynamicColors.onSecondary.getArgb(this)),
      secondaryContainer: Color(
        MaterialDynamicColors.secondaryContainer.getArgb(this),
      ),
      onSecondaryContainer: Color(
        MaterialDynamicColors.onSecondaryContainer.getArgb(this),
      ),
      secondaryFixed: Color(MaterialDynamicColors.secondaryFixed.getArgb(this)),
      secondaryFixedDim: Color(
        MaterialDynamicColors.secondaryFixedDim.getArgb(this),
      ),
      onSecondaryFixed: Color(
        MaterialDynamicColors.onSecondaryFixed.getArgb(this),
      ),
      onSecondaryFixedVariant: Color(
        MaterialDynamicColors.onSecondaryFixedVariant.getArgb(this),
      ),
      tertiary: Color(MaterialDynamicColors.tertiary.getArgb(this)),
      onTertiary: Color(MaterialDynamicColors.onTertiary.getArgb(this)),
      tertiaryContainer: Color(
        MaterialDynamicColors.tertiaryContainer.getArgb(this),
      ),
      onTertiaryContainer: Color(
        MaterialDynamicColors.onTertiaryContainer.getArgb(this),
      ),
      tertiaryFixed: Color(MaterialDynamicColors.tertiaryFixed.getArgb(this)),
      tertiaryFixedDim: Color(
        MaterialDynamicColors.tertiaryFixedDim.getArgb(this),
      ),
      onTertiaryFixed: Color(
        MaterialDynamicColors.onTertiaryFixed.getArgb(this),
      ),
      onTertiaryFixedVariant: Color(
        MaterialDynamicColors.onTertiaryFixedVariant.getArgb(this),
      ),
      error: Color(MaterialDynamicColors.error.getArgb(this)),
      onError: Color(MaterialDynamicColors.onError.getArgb(this)),
      errorContainer: Color(MaterialDynamicColors.errorContainer.getArgb(this)),
      onErrorContainer: Color(
        MaterialDynamicColors.onErrorContainer.getArgb(this),
      ),
      outline: Color(MaterialDynamicColors.outline.getArgb(this)),
      outlineVariant: Color(MaterialDynamicColors.outlineVariant.getArgb(this)),
      surface: Color(MaterialDynamicColors.surface.getArgb(this)),
      surfaceDim: Color(MaterialDynamicColors.surfaceDim.getArgb(this)),
      surfaceBright: Color(MaterialDynamicColors.surfaceBright.getArgb(this)),
      surfaceContainerLowest: Color(
        MaterialDynamicColors.surfaceContainerLowest.getArgb(this),
      ),
      surfaceContainerLow: Color(
        MaterialDynamicColors.surfaceContainerLow.getArgb(this),
      ),
      surfaceContainer: Color(
        MaterialDynamicColors.surfaceContainer.getArgb(this),
      ),
      surfaceContainerHigh: Color(
        MaterialDynamicColors.surfaceContainerHigh.getArgb(this),
      ),
      surfaceContainerHighest: Color(
        MaterialDynamicColors.surfaceContainerHighest.getArgb(this),
      ),
      onSurface: Color(MaterialDynamicColors.onSurface.getArgb(this)),
      onSurfaceVariant: Color(
        MaterialDynamicColors.onSurfaceVariant.getArgb(this),
      ),
      inverseSurface: Color(MaterialDynamicColors.inverseSurface.getArgb(this)),
      onInverseSurface: Color(
        MaterialDynamicColors.inverseOnSurface.getArgb(this),
      ),
      inversePrimary: Color(MaterialDynamicColors.inversePrimary.getArgb(this)),
      shadow: Color(MaterialDynamicColors.shadow.getArgb(this)),
      scrim: Color(MaterialDynamicColors.scrim.getArgb(this)),
      surfaceTint: Color(MaterialDynamicColors.primary.getArgb(this)),
    );
  }
}
