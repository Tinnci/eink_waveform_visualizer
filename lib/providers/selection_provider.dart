import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Manages the user's current selection context (Focus)
/// Independent of the actual data loading mechanism.
class SelectionProvider extends ChangeNotifier {
  // Selection state
  int _selectedFromGray = 0;
  int _selectedToGray = 15;
  int _selectedTemperature = 0;
  WaveformMode _selectedMode = WaveformMode.gc16;

  // Hex viewer state (UI specific)
  int _hexViewOffset = 0;
  final int _hexViewBytesPerRow = 16;

  // Getters
  int get selectedFromGray => _selectedFromGray;
  int get selectedToGray => _selectedToGray;
  int get selectedTemperature => _selectedTemperature;
  WaveformMode get selectedMode => _selectedMode;

  int get hexViewOffset => _hexViewOffset;
  int get hexViewBytesPerRow => _hexViewBytesPerRow;

  // Setters
  void setFromGray(int value) {
    if (value == _selectedFromGray) return;
    _selectedFromGray = value.clamp(0, 15);
    notifyListeners();
  }

  void setToGray(int value) {
    if (value == _selectedToGray) return;
    _selectedToGray = value.clamp(0, 15);
    notifyListeners();
  }

  void setTemperature(int value) {
    if (value == _selectedTemperature) return;
    // Note: Max validation should be done by the UI or combined logic
    // as this provider doesn't know the file's max temperature segments.
    _selectedTemperature = value;
    notifyListeners();
  }

  void setMode(WaveformMode mode) {
    if (mode == _selectedMode) return;
    _selectedMode = mode;
    notifyListeners();
  }

  void setHexViewOffset(int offset) {
    _hexViewOffset =
        offset; // Clamping logic belongs to the consumer who knows the file size
    notifyListeners();
  }

  /// Reset to default state (e.g. when loading a new file)
  void reset() {
    _selectedFromGray = 0;
    _selectedToGray = 15;
    _selectedTemperature = 0;
    _hexViewOffset = 0;
    notifyListeners();
  }
}
