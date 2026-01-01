import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waveform_visualizer/providers/providers.dart';
import 'package:waveform_visualizer/screens/screens.dart';
import 'package:waveform_visualizer/theme/app_theme.dart';

void main() {
  const desktopSize = Size(1280, 800);

  testWidgets('Accessibility Compliance Test (WCAG 2.1 AA)', (
    WidgetTester tester,
  ) async {
    // Disable Google Fonts runtime fetching in tests
    GoogleFonts.config.allowRuntimeFetching = false;
    // 2026 Standards: Accessibility tests are mandatory for CI/CD
    final handle = tester.ensureSemantics();

    // Set desktop size for the test
    await tester.binding.setSurfaceSize(desktopSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SelectionProvider()),
          ChangeNotifierProxyProvider<SelectionProvider, WaveformProvider>(
            create: (_) => WaveformProvider(),
            update: (_, selection, waveform) =>
                waveform!..updateSelection(selection),
          ),
        ],
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Test color contrast guidelines
    // Note: This check reflects the guidelines for text contrast
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // 2. Test tap target guidelines (44x44 on iOS, 48x48 on Android)
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    // 3. Test labeled tap targets (Ensures interactive elements have semantic labels)
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
    await tester.binding.setSurfaceSize(null);
  });

  group('Theme Color Compliance Audit', () {
    test('Primary text contrast should meet WCAG AA (4.5:1)', () {
      final ratio = AppTheme.getContrastRatio(
        AppTheme.textPrimary,
        AppTheme.surfaceDark,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Primary text should be readable on dark surfaces',
      );
    });

    test('Secondary text contrast should meet WCAG AA (4.5:1)', () {
      final ratio = AppTheme.getContrastRatio(
        AppTheme.textSecondary,
        AppTheme.surfaceDark,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Secondary text must meet accessibility standards',
      );
    });

    test('Muted text contrast should meet WCAG AA (4.5:1)', () {
      final ratio = AppTheme.getContrastRatio(
        AppTheme.textMuted,
        AppTheme.surfaceDark,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Muted text (improved) should now pass contrast checks',
      );
    });

    test('Accent Green on Surface contrast (for UI components)', () {
      final ratio = AppTheme.getContrastRatio(
        AppTheme.accentGreen,
        AppTheme.surfaceDark,
      );
      // For UI components/non-text, 3:1 is acceptable (AA)
      expect(
        ratio,
        greaterThanOrEqualTo(3.0),
        reason: 'Accent green icons must be visible on dark surfaces',
      );
    });
  });
}
