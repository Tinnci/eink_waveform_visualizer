import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waveform_visualizer/main.dart';

void main() {
  // Define a desktop-like size for tests to prevent overflows
  const desktopSize = Size(1280, 800);

  testWidgets('App should load and show main screen components', (
    WidgetTester tester,
  ) async {
    // Set surface size
    await tester.binding.setSurfaceSize(desktopSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const WaveformVisualizerApp());

    // Verify app title exists
    expect(find.text('E-Ink Waveform Visualizer'), findsOneWidget);

    // Verify Sidebar exists
    expect(find.text('Load Waveform File'), findsOneWidget);

    // Verify Tabs exist
    expect(find.text('Waveform'), findsOneWidget);
    expect(find.text('Hex View'), findsOneWidget);

    // Reset surface size
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Switching tabs should work', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(desktopSize);

    await tester.pumpWidget(const WaveformVisualizerApp());

    // Tap on Hex View
    await tester.tap(find.text('Hex View'));
    await tester.pumpAndSettle();

    // Verify we are on hex view (look for file status)
    expect(find.text('No file loaded'), findsAtLeastNWidgets(1));

    await tester.binding.setSurfaceSize(null);
  });
}
