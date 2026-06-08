import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors
//
// 다크/라이트 모드를 모두 고려한 중앙 집중식 색상 팔렛트.
//
// 사용법:
//   final colors = AppColors.of(context);
//   Text('hello', style: TextStyle(color: colors.textPrimary));
//
// 또는 ThemeData 통합 사용:
//   MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark)
// ─────────────────────────────────────────────────────────────────────────────

// ── 브랜드 시드 ──────────────────────────────────────────────────────────────
class AppPalette {
  AppPalette._();

  // Primary (Indigo 계열)
  static const Color primary50 = Color(0xFFE8EAF6);
  static const Color primary100 = Color(0xFFC5CAE9);
  static const Color primary200 = Color(0xFF9FA8DA);
  static const Color primary300 = Color(0xFF7986CB);
  static const Color primary400 = Color(0xFF5C6BC0);
  static const Color primary500 = Color(0xFF3F51B5); // 기본
  static const Color primary600 = Color(0xFF3949AB);
  static const Color primary700 = Color(0xFF303F9F);
  static const Color primary800 = Color(0xFF283593);
  static const Color primary900 = Color(0xFF1A237E);

  // Accent / Secondary (Cyan 계열)
  static const Color accent100 = Color(0xFFB2EBF2);
  static const Color accent200 = Color(0xFF80DEEA);
  static const Color accent400 = Color(0xFF26C6DA);
  static const Color accent700 = Color(0xFF0097A7);

  // Neutral (Gray scale)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral850 = Color(0xFF303030);
  static const Color neutral900 = Color(0xFF212121);
  static const Color neutral950 = Color(0xFF121212);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color successDark = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color warningDark = Color(0xFFE65100);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color errorDark = Color(0xFFB71C1C);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);
  static const Color infoDark = Color(0xFF0D47A1);

  // Transparent / Overlay
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppColors  – 모드(밝기)별 의미론적 색상 토큰
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  const AppColors._({
    // ── 브랜드 ──────────────────────────────────────────────────────────────
    required this.primary,
    required this.primaryVariant,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,

    // ── 배경 ─────────────────────────────────────────────────────────────
    required this.background,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceHighlight,

    // ── 텍스트 ───────────────────────────────────────────────────────────
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textLink,
    required this.textCode,

    // ── 아이콘 ───────────────────────────────────────────────────────────
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconDisabled,

    // ── 구분선 / 테두리 ───────────────────────────────────────────────────
    required this.divider,
    required this.border,
    required this.borderFocused,

    // ── 상태 ─────────────────────────────────────────────────────────────
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,

    // ── 오버레이 / 스크림 ─────────────────────────────────────────────────
    required this.scrim,
    required this.shadow,

    // ── 카드 / 패널 ───────────────────────────────────────────────────────
    required this.cardBackground,
    required this.chipBackground,
    required this.chipSelected,
    required this.onChipSelected,
  });

  // ── 브랜드 ────────────────────────────────────────────────────────────────
  final Color primary;
  final Color primaryVariant;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;

  // ── 배경 ──────────────────────────────────────────────────────────────────
  final Color background;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceHighlight;

  // ── 텍스트 ────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textLink;
  final Color textCode;

  // ── 아이콘 ────────────────────────────────────────────────────────────────
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconDisabled;

  // ── 구분선 / 테두리 ───────────────────────────────────────────────────────
  final Color divider;
  final Color border;
  final Color borderFocused;

  // ── 상태 ──────────────────────────────────────────────────────────────────
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;

  // ── 오버레이 ──────────────────────────────────────────────────────────────
  final Color scrim;
  final Color shadow;

  // ── 카드 / 패널 ───────────────────────────────────────────────────────────
  final Color cardBackground;
  final Color chipBackground;
  final Color chipSelected;
  final Color onChipSelected;

  // ── 팩토리 ────────────────────────────────────────────────────────────────
  static const AppColors light = AppColors._(
    // 브랜드
    primary: AppPalette.primary500,
    primaryVariant: AppPalette.primary700,
    onPrimary: AppPalette.white,
    accent: AppPalette.accent400,
    onAccent: AppPalette.white,

    // 배경
    background: AppPalette.neutral50,
    backgroundSecondary: AppPalette.neutral100,
    surface: AppPalette.white,
    surfaceVariant: AppPalette.neutral100,
    surfaceHighlight: AppPalette.primary50,

    // 텍스트
    textPrimary: AppPalette.neutral900,
    textSecondary: AppPalette.neutral700,
    textTertiary: AppPalette.neutral500,
    textDisabled: AppPalette.neutral400,
    textOnPrimary: AppPalette.white,
    textLink: AppPalette.primary600,
    textCode: AppPalette.primary800,

    // 아이콘
    iconPrimary: AppPalette.neutral800,
    iconSecondary: AppPalette.neutral600,
    iconDisabled: AppPalette.neutral400,

    // 구분선 / 테두리
    divider: AppPalette.neutral200,
    border: AppPalette.neutral300,
    borderFocused: AppPalette.primary500,

    // 상태
    success: AppPalette.success,
    onSuccess: AppPalette.white,
    successContainer: AppPalette.successLight,
    warning: AppPalette.warning,
    onWarning: AppPalette.white,
    warningContainer: AppPalette.warningLight,
    error: AppPalette.error,
    onError: AppPalette.white,
    errorContainer: AppPalette.errorLight,
    info: AppPalette.info,
    onInfo: AppPalette.white,
    infoContainer: AppPalette.infoLight,

    // 오버레이
    scrim: Color(0x99000000),
    shadow: Color(0x1F000000),

    // 카드 / 패널
    cardBackground: AppPalette.white,
    chipBackground: AppPalette.neutral200,
    chipSelected: AppPalette.primary500,
    onChipSelected: AppPalette.white,
  );

  static const AppColors dark = AppColors._(
    // 브랜드
    primary: AppPalette.primary300,
    primaryVariant: AppPalette.primary200,
    onPrimary: AppPalette.primary900,
    accent: AppPalette.accent200,
    onAccent: AppPalette.neutral900,

    // 배경
    background: AppPalette.neutral950,
    backgroundSecondary: AppPalette.neutral900,
    surface: Color(0xFF1E1E1E),
    surfaceVariant: AppPalette.neutral850,
    surfaceHighlight: Color(0xFF1A237E33), // primary900 @ 20%
    // 텍스트
    textPrimary: Color(0xFFE6E6E6),
    textSecondary: AppPalette.neutral400,
    textTertiary: AppPalette.neutral600,
    textDisabled: AppPalette.neutral700,
    textOnPrimary: AppPalette.primary900,
    textLink: AppPalette.primary200,
    textCode: AppPalette.accent200,

    // 아이콘
    iconPrimary: Color(0xFFE0E0E0),
    iconSecondary: AppPalette.neutral500,
    iconDisabled: AppPalette.neutral700,

    // 구분선 / 테두리
    divider: AppPalette.neutral800,
    border: AppPalette.neutral700,
    borderFocused: AppPalette.primary300,

    // 상태
    success: Color(0xFF81C784),
    onSuccess: AppPalette.neutral900,
    successContainer: AppPalette.successDark,
    warning: Color(0xFFFFB74D),
    onWarning: AppPalette.neutral900,
    warningContainer: AppPalette.warningDark,
    error: Color(0xFFEF9A9A),
    onError: AppPalette.neutral900,
    errorContainer: AppPalette.errorDark,
    info: Color(0xFF90CAF9),
    onInfo: AppPalette.neutral900,
    infoContainer: AppPalette.infoDark,

    // 오버레이
    scrim: Color(0xCC000000),
    shadow: Color(0x4D000000),

    // 카드 / 패널
    cardBackground: Color(0xFF1E1E1E),
    chipBackground: AppPalette.neutral800,
    chipSelected: AppPalette.primary300,
    onChipSelected: AppPalette.primary900,
  );

  // ── context 헬퍼 ──────────────────────────────────────────────────────────
  /// 현재 테마(밝기)에 맞는 [AppColors] 인스턴스를 반환합니다.
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme  – ThemeData 통합 헬퍼
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: brightness == Brightness.light
          ? AppPalette.primary100
          : AppPalette.primary900,
      onPrimaryContainer: brightness == Brightness.light
          ? AppPalette.primary900
          : AppPalette.primary100,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: brightness == Brightness.light
          ? AppPalette.accent100
          : AppPalette.accent700,
      onSecondaryContainer: brightness == Brightness.light
          ? AppPalette.neutral900
          : AppPalette.neutral100,
      surface: c.surface,
      onSurface: c.textPrimary,
      error: c.error,
      onError: c.onError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      cardColor: c.cardBackground,
      dividerColor: c.divider,
      textTheme: _textTheme(c),
      iconTheme: IconThemeData(color: c.iconPrimary),
      cardTheme: CardThemeData(
        color: c.cardBackground,
        shadowColor: c.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border, width: 0.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.chipBackground,
        selectedColor: c.chipSelected,
        labelStyle: TextStyle(color: c.textSecondary),
        secondaryLabelStyle: TextStyle(color: c.onChipSelected),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.borderFocused, width: 2),
        ),
        hintStyle: TextStyle(color: c.textTertiary),
      ),
    );
  }

  static TextTheme _textTheme(AppColors c) {
    return TextTheme(
      // Display
      displayLarge: TextStyle(
        color: c.textPrimary,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        color: c.textPrimary,
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        color: c.textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      // Headline
      headlineLarge: TextStyle(
        color: c.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: c.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: c.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      // Title
      titleLarge: TextStyle(
        color: c.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: c.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        color: c.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      // Body
      bodyLarge: TextStyle(
        color: c.textPrimary,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: c.textPrimary,
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        color: c.textSecondary,
        fontSize: 12,
        letterSpacing: 0.4,
      ),
      // Label
      labelLarge: TextStyle(
        color: c.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: c.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: c.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
