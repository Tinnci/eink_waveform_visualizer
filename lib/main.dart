import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/providers.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaveformVisualizerApp());
}

class WaveformVisualizerApp extends StatelessWidget {
  const WaveformVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectionProvider()),
        ChangeNotifierProxyProvider<SelectionProvider, WaveformProvider>(
          create: (_) => WaveformProvider(),
          update: (_, selection, waveform) =>
              waveform!..updateSelection(selection),
        ),
      ],
      child: MaterialApp(
        title: 'E-Ink Waveform Visualizer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.darkTheme.textTheme),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
