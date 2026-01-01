import 'package:flutter/material.dart';

/// App theme configuration for the waveform visualizer
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color palette - inspired by oscilloscope/technical instruments
  static const Color primaryDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color borderDark = Color(0xFF30363D);

  static const Color accentGreen = Color(0xFF3FB950);
  static const Color accentBlue = Color(0xFF58A6FF);
  static const Color accentPurple = Color(0xFFA371F7);
  static const Color accentOrange = Color(0xFFD29922);
  static const Color accentRed = Color(0xFFF85149);
  static const Color accentCyan = Color(0xFF39C5CF);

  // Voltage colors
  static const Color voltagePositive = Color(0xFFFF6B6B);
  static const Color voltageNegative = Color(0xFF4ECDC4);
  static const Color voltageZero = Color(0xFF45B7D1);
  static const Color voltageHold = Color(0xFF96CEB4);

  // Grid colors
  static const Color gridLine = Color(0xFF21262D);
  static const Color gridLineMajor = Color(0xFF30363D);

  // Text colors
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);

  /// Create the dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: accentBlue,
        surface: surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        space: 1,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentGreen,
        inactiveTrackColor: borderDark,
        thumbColor: accentGreen,
        overlayColor: accentGreen.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: accentGreen.withOpacity(0.2),
        labelStyle: const TextStyle(color: textPrimary),
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderDark),
        ),
        textStyle: const TextStyle(color: textPrimary, fontSize: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textMuted),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textMuted),
      ),
    );
  }
}

/// Extension for quick access to theme colors
extension ThemeColors on BuildContext {
  Color get primaryDark => AppTheme.primaryDark;
  Color get surfaceDark => AppTheme.surfaceDark;
  Color get cardDark => AppTheme.cardDark;
  Color get borderDark => AppTheme.borderDark;
  Color get accentGreen => AppTheme.accentGreen;
  Color get accentBlue => AppTheme.accentBlue;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
}
