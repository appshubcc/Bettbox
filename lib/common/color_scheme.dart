// ignore_for_file: deprecated_member_use

import 'package:bett_box/enum/enum.dart';
import 'package:libmonet/material_color_utilities.dart' as monet;
import 'package:material_ui/material_ui.dart';

/// Material 3 color schemes generated from the same seed color.
///
/// `material_ui`'s `ColorScheme.fromSeed` is backed by
/// `material_color_utilities` 0.13.x, which only implements the 2021 spec.
/// Android 16 QPR1 and later (Material 3 Expressive) generate their Monet
/// colors with the 2025 spec, whose palettes and tone mapping are different
/// (most notably for the Vibrant variant). Generating the scheme with
/// [monet.SpecVersion.spec2025] keeps Bettbox in sync with the system UI.
/// [ThemeSchemeVariant.cmf] uses [monet.SpecVersion.spec2026].
typedef _SchemeKey = (int, Brightness, ThemeSchemeVariant, ColorSpecVersion);

class AppColorScheme {
  static final _cache = <_SchemeKey, ColorScheme>{};

  static const _cacheSize = 64;

  static monet.Variant _variant(ThemeSchemeVariant variant) {
    return switch (variant) {
      ThemeSchemeVariant.tonalSpot => monet.Variant.tonalSpot,
      ThemeSchemeVariant.fidelity => monet.Variant.fidelity,
      ThemeSchemeVariant.monochrome => monet.Variant.monochrome,
      ThemeSchemeVariant.neutral => monet.Variant.neutral,
      ThemeSchemeVariant.vibrant => monet.Variant.vibrant,
      ThemeSchemeVariant.expressive => monet.Variant.expressive,
      ThemeSchemeVariant.content => monet.Variant.content,
      ThemeSchemeVariant.rainbow => monet.Variant.rainbow,
      ThemeSchemeVariant.fruitSalad => monet.Variant.fruitSalad,
      ThemeSchemeVariant.cmf => monet.Variant.cmf,
    };
  }

  static monet.SpecVersion _spec(ColorSpecVersion spec) {
    return switch (spec) {
      ColorSpecVersion.spec2021 => monet.SpecVersion.spec2021,
      ColorSpecVersion.spec2025 => monet.SpecVersion.spec2025,
      ColorSpecVersion.spec2026 => monet.SpecVersion.spec2026,
    };
  }

  static ColorScheme generate({
    required Color seedColor,
    required Brightness brightness,
    required ThemeSchemeVariant variant,
    required ColorSpecVersion spec,
  }) {
    final seed = seedColor.toARGB32();
    final key = (seed, brightness, variant, spec);
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }
    final scheme = monet.DynamicScheme.withDefaults(
      sourceColor: monet.TonalPaletteSourceColor.fromArgb(seed),
      variant: _variant(variant),
      isDark: brightness == Brightness.dark,
      specVersion: _spec(spec),
    );
    final result = ColorScheme(
      brightness: brightness,
      primary: Color(scheme.primary),
      onPrimary: Color(scheme.onPrimary),
      primaryContainer: Color(scheme.primaryContainer),
      onPrimaryContainer: Color(scheme.onPrimaryContainer),
      primaryFixed: Color(scheme.primaryFixed),
      primaryFixedDim: Color(scheme.primaryFixedDim),
      onPrimaryFixed: Color(scheme.onPrimaryFixed),
      onPrimaryFixedVariant: Color(scheme.onPrimaryFixedVariant),
      secondary: Color(scheme.secondary),
      onSecondary: Color(scheme.onSecondary),
      secondaryContainer: Color(scheme.secondaryContainer),
      onSecondaryContainer: Color(scheme.onSecondaryContainer),
      secondaryFixed: Color(scheme.secondaryFixed),
      secondaryFixedDim: Color(scheme.secondaryFixedDim),
      onSecondaryFixed: Color(scheme.onSecondaryFixed),
      onSecondaryFixedVariant: Color(scheme.onSecondaryFixedVariant),
      tertiary: Color(scheme.tertiary),
      onTertiary: Color(scheme.onTertiary),
      tertiaryContainer: Color(scheme.tertiaryContainer),
      onTertiaryContainer: Color(scheme.onTertiaryContainer),
      tertiaryFixed: Color(scheme.tertiaryFixed),
      tertiaryFixedDim: Color(scheme.tertiaryFixedDim),
      onTertiaryFixed: Color(scheme.onTertiaryFixed),
      onTertiaryFixedVariant: Color(scheme.onTertiaryFixedVariant),
      error: Color(scheme.error),
      onError: Color(scheme.onError),
      errorContainer: Color(scheme.errorContainer),
      onErrorContainer: Color(scheme.onErrorContainer),
      surface: Color(scheme.surface),
      onSurface: Color(scheme.onSurface),
      surfaceDim: Color(scheme.surfaceDim),
      surfaceBright: Color(scheme.surfaceBright),
      surfaceContainerLowest: Color(scheme.surfaceContainerLowest),
      surfaceContainerLow: Color(scheme.surfaceContainerLow),
      surfaceContainer: Color(scheme.surfaceContainer),
      surfaceContainerHigh: Color(scheme.surfaceContainerHigh),
      surfaceContainerHighest: Color(scheme.surfaceContainerHighest),
      onSurfaceVariant: Color(scheme.onSurfaceVariant),
      outline: Color(scheme.outline),
      outlineVariant: Color(scheme.outlineVariant),
      shadow: Color(scheme.shadow),
      scrim: Color(scheme.scrim),
      inverseSurface: Color(scheme.inverseSurface),
      onInverseSurface: Color(scheme.inverseOnSurface),
      inversePrimary: Color(scheme.inversePrimary),
      // `ColorScheme.fromSeed` exposes the primary color here (not the
      // separate `surface_tint` role), keep the two implementations aligned.
      surfaceTint: Color(scheme.primary),
      background: Color(scheme.background),
      onBackground: Color(scheme.onBackground),
      surfaceVariant: Color(scheme.surfaceVariant),
    );
    if (_cache.length >= _cacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = result;
    return result;
  }
}
