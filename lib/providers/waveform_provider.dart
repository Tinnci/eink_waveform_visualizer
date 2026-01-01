import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/services.dart';

/// Provider for managing waveform file state
class WaveformProvider extends ChangeNotifier {
  WaveformFile? _currentFile;
  bool _isLoading = false;
  String? _error;

  // Visualization state
  int _selectedFromGray = 0;
  int _selectedToGray = 15;
  int _selectedTemperature = 0;
  WaveformMode _selectedMode = WaveformMode.gc16;
  List<VoltageLevel> _currentSequence = [];

  // Hex viewer state
  int _hexViewOffset = 0;
  final int _hexViewBytesPerRow = 16;

  // Getters
  WaveformFile? get currentFile => _currentFile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFile => _currentFile != null;

  int get selectedFromGray => _selectedFromGray;
  int get selectedToGray => _selectedToGray;
  int get selectedTemperature => _selectedTemperature;
  WaveformMode get selectedMode => _selectedMode;
  List<VoltageLevel> get currentSequence => _currentSequence;

  int get hexViewOffset => _hexViewOffset;
  int get hexViewBytesPerRow => _hexViewBytesPerRow;

  /// Load a waveform file using file picker
  Future<void> loadFile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bin', 'wbf', 'waveform'],
        dialogTitle: 'Select Waveform File',
      );

      if (result == null || result.files.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final file = result.files.first;
      final path = file.path;

      if (path == null) {
        _error = 'Could not get file path';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final bytes = await File(path).readAsBytes();
      await _parseWaveformFile(bytes, file.name);
    } catch (e) {
      _error = 'Error loading file: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a waveform file from bytes (for drag-and-drop)
  Future<void> loadFromBytes(Uint8List bytes, String fileName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _parseWaveformFile(bytes, fileName);
  }

  /// Parse the waveform file
  Future<void> _parseWaveformFile(Uint8List bytes, String fileName) async {
    try {
      final format = WaveformParser.identifyFormat(bytes);

      if (format == WaveformFormat.unknown) {
        _error = 'Unknown waveform format';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (format == WaveformFormat.pvi) {
        _currentFile = WaveformParser.parsePviWaveform(bytes, fileName);
      } else if (format == WaveformFormat.rkf) {
        // For now, create a basic file object for RKF
        _currentFile = WaveformFile(
          fileName: fileName,
          format: WaveformFormat.rkf,
          rawData: bytes,
          loadedAt: DateTime.now(),
        );
        _error = 'RKF format detected - full parsing not yet implemented';
      }

      // Reset visualization state
      _selectedFromGray = 0;
      _selectedToGray = 15;
      _selectedTemperature = 0;
      _hexViewOffset = 0;

      // Update the voltage sequence
      _updateSequence();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error parsing file: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the current voltage sequence based on selected parameters
  void _updateSequence() {
    if (_currentFile == null) {
      _currentSequence = [];
      return;
    }

    // Try to decode the actual waveform data
    if (_currentFile!.format == WaveformFormat.pvi &&
        _currentFile!.pviHeader != null) {
      final transition = WaveformParser.decodeTransition(
        data: _currentFile!.rawData,
        header: _currentFile!.pviHeader!,
        fromGray: _selectedFromGray,
        toGray: _selectedToGray,
        temperatureIndex: _selectedTemperature,
        mode: _selectedMode,
      );

      if (transition != null && transition.voltageSequence.isNotEmpty) {
        _currentSequence = transition.voltageSequence;
        return;
      }
    }

    // Fall back to sample sequence for visualization
    _currentSequence = WaveformParser.generateSampleSequence(
      _selectedFromGray,
      _selectedToGray,
    );
  }

  /// Set the from gray level
  void setFromGray(int value) {
    if (value == _selectedFromGray) return;
    _selectedFromGray = value.clamp(0, 15);
    _updateSequence();
    notifyListeners();
  }

  /// Set the to gray level
  void setToGray(int value) {
    if (value == _selectedToGray) return;
    _selectedToGray = value.clamp(0, 15);
    _updateSequence();
    notifyListeners();
  }

  /// Set the temperature index
  void setTemperature(int value) {
    if (value == _selectedTemperature) return;
    _selectedTemperature = value;
    _updateSequence();
    notifyListeners();
  }

  /// Set the waveform mode
  void setMode(WaveformMode mode) {
    if (mode == _selectedMode) return;
    _selectedMode = mode;
    _updateSequence();
    notifyListeners();
  }

  /// Set hex view offset
  void setHexViewOffset(int offset) {
    if (_currentFile == null) return;
    _hexViewOffset = offset.clamp(0, _currentFile!.rawData.length);
    notifyListeners();
  }

  /// Clear the current file
  void clearFile() {
    _currentFile = null;
    _error = null;
    _currentSequence = [];
    _hexViewOffset = 0;
    notifyListeners();
  }

  /// Export current waveform sequence to CSV
  Future<String?> exportToCsv() async {
    if (_currentSequence.isEmpty) {
      _error = 'No waveform data to export';
      notifyListeners();
      return null;
    }

    try {
      final result = await CsvExporter.exportSequence(
        sequence: _currentSequence,
        fromGray: _selectedFromGray,
        toGray: _selectedToGray,
        mode: _selectedMode,
        temperature: _selectedTemperature,
      );

      if (result != null) {
        _error = null;
      }

      notifyListeners();
      return result;
    } catch (e) {
      _error = 'Export failed: $e';
      notifyListeners();
      return null;
    }
  }
}
