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

  static const Color accentGreen = Color(
    0xFF4ADE80,
  ); // Brightened from 0xFF3FB950 for >4.5:1 contrast
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
  static const Color textMuted = Color(
    0xFF8B949E,
  ); // Adjusted to 0xFF8B949E for WCAG 2.1 AA (4.5:1)

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
        overlayColor: accentGreen.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: accentGreen.withValues(alpha: 0.2),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: accentGreen.withValues(alpha: 0.1),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accentGreen);
          }
          return const IconThemeData(color: textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: accentGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(color: textSecondary, fontSize: 12);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: accentGreen.withValues(alpha: 0.1),
        selectedIconTheme: const IconThemeData(color: accentGreen),
        unselectedIconTheme: const IconThemeData(color: textSecondary),
        selectedLabelTextStyle: const TextStyle(
          color: accentGreen,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Calculates the contrast ratio between two colors.
  /// Returns a value between 1.0 and 21.0.
  static double getContrastRatio(Color color1, Color color2) {
    final l1 = color1.computeLuminance();
    final l2 = color2.computeLuminance();
    final brightest = l1 > l2 ? l1 : l2;
    final darkest = l1 > l2 ? l2 : l1;
    return (brightest + 0.05) / (darkest + 0.05);
  }

  /// Checks if the contrast ratio meets WCAG 2.1 AA standards for text (4.5:1).
  static bool isWCAGPass(Color text, Color background) {
    return getContrastRatio(text, background) >= 4.5;
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

/// 2026 Typography Design Tokens
/// Use these for consistent text styling across the application.
class AppTypography {
  AppTypography._();

  /// Monospace font family for code and hex data display.
  /// Uses system monospace as fallback for cross-platform compatibility.
  static const String monospaceFontFamily = 'monospace';

  /// Code/Hex data display style - optimized for dense data readability.
  /// Line height 1.4 prevents visual "sticking" in long hex dumps.
  static const TextStyle codeStyle = TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: 13,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppTheme.textPrimary,
  );

  /// Muted code style for secondary hex data (e.g., ASCII column).
  static const TextStyle codeMutedStyle = TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: 13,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppTheme.textSecondary,
  );

  /// Address/offset column style - slightly dimmer for visual hierarchy.
  static const TextStyle codeAddressStyle = TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppTheme.textMuted,
  );

  /// Section title style - for card headers and panel titles.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
    height: 1.3,
  );

  /// Subtitle/description style - for secondary information.
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textSecondary,
    height: 1.4,
  );

  /// Caption style - for timestamps, metadata, and small labels.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppTheme.textMuted,
    height: 1.3,
  );

  /// Button label style - for primary action buttons.
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
    letterSpacing: 0.2,
  );

  /// Navigation label style - compact for nav bar/rail.
  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );

  /// Data value style - for displaying numeric values prominently.
  static const TextStyle dataValue = TextStyle(
    fontFamily: monospaceFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.accentGreen,
    height: 1.2,
  );

  /// Data label style - for labeling data values.
  static const TextStyle dataLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppTheme.textMuted,
    letterSpacing: 0.5,
  );
}
