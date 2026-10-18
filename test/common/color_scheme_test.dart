// ignore_for_file: deprecated_member_use

import 'package:bett_box/common/color_scheme.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppColorScheme spec2021', () {
    test('matches ColorScheme.fromSeed', () {
      const seeds = [
        Color(0xFF00897B),
        Color(0xFF93CAFF),
        Color(0xFFFFB4AB),
        Color(0xFF6750A4),
      ];
      for (final seed in seeds) {
        for (final brightness in Brightness.values) {
          for (final variant in ThemeSchemeVariant.values) {
            // ColorScheme.fromSeed has no CMF variant; CMF is 2026-only.
            if (variant == ThemeSchemeVariant.cmf) continue;
            final expected = ColorScheme.fromSeed(
              seedColor: seed,
              brightness: brightness,
              dynamicSchemeVariant: DynamicSchemeVariant.values.byName(
                variant.name,
              ),
            );
            final actual = AppColorScheme.generate(
              seedColor: seed,
              brightness: brightness,
              variant: variant,
              spec: ColorSpecVersion.spec2021,
            );
            final reason = 'seed=$seed brightness=$brightness variant=$variant';
            final roles = <String, (Color, Color)>{
              'primary': (actual.primary, expected.primary),
              'onPrimary': (actual.onPrimary, expected.onPrimary),
              'primaryContainer': (
                actual.primaryContainer,
                expected.primaryContainer,
              ),
              'onPrimaryContainer': (
                actual.onPrimaryContainer,
                expected.onPrimaryContainer,
              ),
              'primaryFixed': (actual.primaryFixed, expected.primaryFixed),
              'primaryFixedDim': (
                actual.primaryFixedDim,
                expected.primaryFixedDim,
              ),
              'onPrimaryFixed': (
                actual.onPrimaryFixed,
                expected.onPrimaryFixed,
              ),
              'onPrimaryFixedVariant': (
                actual.onPrimaryFixedVariant,
                expected.onPrimaryFixedVariant,
              ),
              'secondary': (actual.secondary, expected.secondary),
              'onSecondary': (actual.onSecondary, expected.onSecondary),
              'secondaryContainer': (
                actual.secondaryContainer,
                expected.secondaryContainer,
              ),
              'onSecondaryContainer': (
                actual.onSecondaryContainer,
                expected.onSecondaryContainer,
              ),
              'secondaryFixed': (
                actual.secondaryFixed,
                expected.secondaryFixed,
              ),
              'secondaryFixedDim': (
                actual.secondaryFixedDim,
                expected.secondaryFixedDim,
              ),
              'onSecondaryFixed': (
                actual.onSecondaryFixed,
                expected.onSecondaryFixed,
              ),
              'onSecondaryFixedVariant': (
                actual.onSecondaryFixedVariant,
                expected.onSecondaryFixedVariant,
              ),
              'tertiary': (actual.tertiary, expected.tertiary),
              'onTertiary': (actual.onTertiary, expected.onTertiary),
              'tertiaryContainer': (
                actual.tertiaryContainer,
                expected.tertiaryContainer,
              ),
              'onTertiaryContainer': (
                actual.onTertiaryContainer,
                expected.onTertiaryContainer,
              ),
              'tertiaryFixed': (actual.tertiaryFixed, expected.tertiaryFixed),
              'tertiaryFixedDim': (
                actual.tertiaryFixedDim,
                expected.tertiaryFixedDim,
              ),
              'onTertiaryFixed': (
                actual.onTertiaryFixed,
                expected.onTertiaryFixed,
              ),
              'onTertiaryFixedVariant': (
                actual.onTertiaryFixedVariant,
                expected.onTertiaryFixedVariant,
              ),
              'error': (actual.error, expected.error),
              'onError': (actual.onError, expected.onError),
              'errorContainer': (
                actual.errorContainer,
                expected.errorContainer,
              ),
              'onErrorContainer': (
                actual.onErrorContainer,
                expected.onErrorContainer,
              ),
              'surface': (actual.surface, expected.surface),
              'onSurface': (actual.onSurface, expected.onSurface),
              'surfaceDim': (actual.surfaceDim, expected.surfaceDim),
              'surfaceBright': (actual.surfaceBright, expected.surfaceBright),
              'surfaceContainerLowest': (
                actual.surfaceContainerLowest,
                expected.surfaceContainerLowest,
              ),
              'surfaceContainerLow': (
                actual.surfaceContainerLow,
                expected.surfaceContainerLow,
              ),
              'surfaceContainer': (
                actual.surfaceContainer,
                expected.surfaceContainer,
              ),
              'surfaceContainerHigh': (
                actual.surfaceContainerHigh,
                expected.surfaceContainerHigh,
              ),
              'surfaceContainerHighest': (
                actual.surfaceContainerHighest,
                expected.surfaceContainerHighest,
              ),
              'onSurfaceVariant': (
                actual.onSurfaceVariant,
                expected.onSurfaceVariant,
              ),
              'outline': (actual.outline, expected.outline),
              'outlineVariant': (
                actual.outlineVariant,
                expected.outlineVariant,
              ),
              'shadow': (actual.shadow, expected.shadow),
              'scrim': (actual.scrim, expected.scrim),
              'inverseSurface': (
                actual.inverseSurface,
                expected.inverseSurface,
              ),
              'onInverseSurface': (
                actual.onInverseSurface,
                expected.onInverseSurface,
              ),
              'inversePrimary': (
                actual.inversePrimary,
                expected.inversePrimary,
              ),
              'surfaceTint': (actual.surfaceTint, expected.surfaceTint),
              'background': (actual.background, expected.background),
              'onBackground': (actual.onBackground, expected.onBackground),
              'surfaceVariant': (
                actual.surfaceVariant,
                expected.surfaceVariant,
              ),
            };
            roles.forEach((name, colors) {
              expect(colors.$1, colors.$2, reason: '$reason role=$name');
            });
          }
        }
      }
    });
  });

  group('AppColorScheme spec2025/2026', () {
    test('vibrant palette matches Android 16 QPR1 system colors', () {
      final scheme = AppColorScheme.generate(
        seedColor: const Color(0xFF93CAFF),
        brightness: Brightness.dark,
        variant: ThemeSchemeVariant.vibrant,
        spec: ColorSpecVersion.spec2025,
      );
      // Reference values are the spec2025 Vibrant roles for this seed. The
      // system UI colors sampled from an Android 16 QPR1 device are #000F22
      // (surface) and #002D54 (surfaceBright), matching within rounding.
      expect(scheme.surface, const Color(0xFF000E22));
      expect(scheme.surfaceBright, const Color(0xFF002D56));
      expect(scheme.surfaceContainerLow, const Color(0xFF00142B));
      expect(scheme.primary, const Color(0xFF59B4FF));
    });

    test('every variant generates a complete scheme for every spec', () {
      for (final spec in ColorSpecVersion.values) {
        for (final variant in ThemeSchemeVariant.values) {
          for (final brightness in Brightness.values) {
            final scheme = AppColorScheme.generate(
              seedColor: const Color(0xFF93CAFF),
              brightness: brightness,
              variant: variant,
              spec: spec,
            );
            expect(scheme.brightness, brightness);
            expect(scheme.primary.a, 1.0);
            expect(scheme.surface.a, 1.0);
            expect(scheme.onSurface.a, 1.0);
          }
        }
      }
    });

    test('CMF always uses the 2026 spec', () {
      ColorScheme generate(ColorSpecVersion spec) => AppColorScheme.generate(
        seedColor: const Color(0xFF93CAFF),
        brightness: Brightness.dark,
        variant: ThemeSchemeVariant.cmf,
        spec: spec,
      );

      final scheme2021 = generate(ColorSpecVersion.spec2021);
      final scheme2025 = generate(ColorSpecVersion.spec2025);
      final scheme2026 = generate(ColorSpecVersion.spec2026);

      // libmonet/MaterialKolor force CMF to 2026 regardless of the switch.
      expect(scheme2021.surface, scheme2026.surface);
      expect(scheme2025.surface, scheme2026.surface);
      expect(scheme2026.brightness, Brightness.dark);
      expect(scheme2026.primary.a, 1.0);
      expect(scheme2026.surface.a, 1.0);
      expect(scheme2026.onSurface.a, 1.0);
    });

    test('differs from spec2021 for vibrant surfaces', () {
      final scheme2021 = AppColorScheme.generate(
        seedColor: const Color(0xFF93CAFF),
        brightness: Brightness.dark,
        variant: ThemeSchemeVariant.vibrant,
        spec: ColorSpecVersion.spec2021,
      );
      final scheme2025 = AppColorScheme.generate(
        seedColor: const Color(0xFF93CAFF),
        brightness: Brightness.dark,
        variant: ThemeSchemeVariant.vibrant,
        spec: ColorSpecVersion.spec2025,
      );
      expect(scheme2021.surface, const Color(0xFF0D141B));
      expect(scheme2021.surfaceContainerLow, const Color(0xFF151C24));
      expect(scheme2025.surface, isNot(scheme2021.surface));
    });
  });
}
