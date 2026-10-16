import 'package:flutter/material.dart';

class ThemeApp {
  // Configuración de elementos comunes en Material 3 Expressive
  static const double _cardRadius = 22.0;
  static const double _dialogRadius = 28.0;
  static const double _inputRadius = 18.0;

  static ThemeData lightTheme() {
    // Paleta estilo Google Pixel Mint / Teal
    const seedColor = Color(0xFF006A60);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF7FAF8),
      primary: const Color(0xFF006A60),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF70F7E4),
      onPrimaryContainer: const Color(0xFF00201C),
      secondary: const Color(0xFF4A635F),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCCE8E3),
      onSecondaryContainer: const Color(0xFF05201C),
      surfaceContainer: const Color(0xFFEAEFEA),
      surfaceContainerHigh: const Color(0xFFE4E9E4),
      surfaceContainerHighest: const Color(0xFFDEE4DF),
      outline: const Color(0xFF6F7977),
      outlineVariant: const Color(0xFFBFC9C6),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData darkTheme() {
    // Paleta estilo Google Pixel Charcoal / Jade Dark
    const seedColor = Color(0xFF53DBC9);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF111414),
      primary: const Color(0xFF53DBC9),
      onPrimary: const Color(0xFF003731),
      primaryContainer: const Color(0xFF005048),
      onPrimaryContainer: const Color(0xFF70F7E4),
      secondary: const Color(0xFFB1CCC7),
      onSecondary: const Color(0xFF1C3531),
      secondaryContainer: const Color(0xFF334B47),
      onSecondaryContainer: const Color(0xFFCCE8E3),
      surfaceContainer: const Color(0xFF1D2121),
      surfaceContainerHigh: const Color(0xFF282B2B),
      surfaceContainerHighest: const Color(0xFF333636),
      outline: const Color(0xFF899391),
      outlineVariant: const Color(0xFF3F4947),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData warmTheme() {
    // Paleta estilo Google Pixel Terracotta / Coral Warm
    const seedColor = Color(0xFF9C4318);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1714),
      primary: const Color(0xFFFFB59B),
      onPrimary: const Color(0xFF581D00),
      primaryContainer: const Color(0xFF7B2D02),
      onPrimaryContainer: const Color(0xFFFFDBCD),
      secondary: const Color(0xFFE7BDB0),
      onSecondary: const Color(0xFF442A21),
      secondaryContainer: const Color(0xFF5D4036),
      onSecondaryContainer: const Color(0xFFFFDBCD),
      surfaceContainer: const Color(0xFF2B211D),
      surfaceContainerHigh: const Color(0xFF362B27),
      surfaceContainerHighest: const Color(0xFF423631),
      outline: const Color(0xFFA08C84),
      outlineVariant: const Color(0xFF53433E),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainer,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.35),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 1,
        focusElevation: 2,
        hoverElevation: 2,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_dialogRadius),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        elevation: 4,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ),
    );
  }
}
