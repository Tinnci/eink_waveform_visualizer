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
}
