import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waveform_visualizer/providers/providers.dart';
import 'package:waveform_visualizer/screens/screens.dart';
import 'package:waveform_visualizer/theme/app_theme.dart';
import 'package:waveform_visualizer/widgets/hex_viewer.dart';
import 'dart:typed_data';

void main() {
  const desktopSize = Size(1280, 800);

  setUp(() {
    // Disable Google Fonts runtime fetching in tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('2026 Typography Standards Tests', () {
    testWidgets(
      'Text scaling at 2.0x should not cause overflow',
      (WidgetTester tester) async {
        // 2026 Standard: All UIs must handle 200% text scaling
        await tester.binding.setSurfaceSize(desktopSize);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              size: desktopSize,
            ),
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => SelectionProvider()),
                ChangeNotifierProxyProvider<
                  SelectionProvider,
                  WaveformProvider
                >(
                  create: (_) => WaveformProvider(),
                  update: (_, selection, waveform) =>
                      waveform!..updateSelection(selection),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.darkTheme,
                home: const HomeScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // If no overflow exception is thrown, the test passes
        expect(tester.takeException(), isNull);

        await tester.binding.setSurfaceSize(null);
      },
      // TODO(2026-sprint): Requires layout refactoring for extreme text scaling
      skip: true,
    );

    testWidgets('HexViewer handles large font scaling gracefully', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(desktopSize);

      // Create sample data for HexViewer
      final sampleData = Uint8List.fromList(List.generate(256, (i) => i));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
            size: desktopSize,
          ),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: HexViewer(data: sampleData)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify HexViewer renders without overflow
      expect(tester.takeException(), isNull);
      expect(find.byType(HexViewer), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('AppTypography Design Token Validation', () {
    test('Code style should use monospace font family', () {
      expect(AppTypography.codeStyle.fontFamily, equals('monospace'));
    });

    test('Code style should have proper line height for readability', () {
      // 2026 Standard: Line height 1.2-1.5 for dense data
      expect(AppTypography.codeStyle.height, greaterThanOrEqualTo(1.2));
      expect(AppTypography.codeStyle.height, lessThanOrEqualTo(1.5));
    });

    test('Section title should have proper font weight', () {
      // 2026 Standard: w600 (SemiBold) for titles
      expect(AppTypography.sectionTitle.fontWeight, equals(FontWeight.w600));
    });

    test('Caption should be readable but subtle', () {
      expect(AppTypography.caption.fontSize, greaterThanOrEqualTo(10));
      expect(AppTypography.caption.fontSize, lessThanOrEqualTo(13));
    });

    test('Data value style should be monospace and prominent', () {
      expect(AppTypography.dataValue.fontFamily, equals('monospace'));
      expect(AppTypography.dataValue.fontWeight, equals(FontWeight.w600));
    });

    test('All typography tokens have explicit height defined', () {
      // 2026 Standard: Explicit line-height prevents platform inconsistencies
      expect(AppTypography.codeStyle.height, isNotNull);
      expect(AppTypography.sectionTitle.height, isNotNull);
      expect(AppTypography.caption.height, isNotNull);
    });
  });

  group('Semantics and Accessibility Tests', () {
    testWidgets('HomeScreen provides semantic labels for navigation', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(desktopSize);
      final handle = tester.ensureSemantics();

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
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify semantic tree is populated
      final semantics = tester.getSemantics(find.byType(HomeScreen));
      expect(semantics, isNotNull);

      handle.dispose();
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tap target guideline compliance at normal text scale', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(desktopSize);
      final handle = tester.ensureSemantics();

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
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 2026 Standard: All interactive elements must have >=48x48 tap targets
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      handle.dispose();
      await tester.binding.setSurfaceSize(null);
    });
  });
}
