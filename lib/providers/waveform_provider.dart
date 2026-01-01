import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'selection_provider.dart';

/// Provider for managing waveform file state and processing logic.
/// It depends on [SelectionProvider] to know which transition to visualize.
class WaveformProvider extends ChangeNotifier {
  WaveformFile? _currentFile;
  bool _isLoading = false;
  String? _error;

  // Visualized sequence (Output)
  // Now uses the mutable WaveformSequence model
  WaveformSequence? _currentSequence;

  // Simulation output
  List<double> _simulationResult = [];

  // Dependency injected via ProxyProvider
  SelectionProvider? _selection;

  // Getters
  /// Currently loaded waveform file
  WaveformFile? get currentFile => _currentFile;

  /// Whether the provider is currently loading a file
  bool get isLoading => _isLoading;

  /// Last error message, if any
  String? get error => _error;

  /// Whether a file is currently loaded
  bool get hasFile => _currentFile != null;

  /// Current visualized voltage sequence
  WaveformSequence? get currentSequence => _currentSequence;

  /// Simulated optical reflectance result
  List<double> get simulationResult => _simulationResult;

  // Shortcuts accessors for UI convenience (read-only)
  // The UI should use SelectionProvider directly for writing.
  /// The starting gray level of the current transition
  int get selectedFromGray => _selection?.selectedFromGray ?? 0;

  /// The target gray level of the current transition
  int get selectedToGray => _selection?.selectedToGray ?? 0;

  /// Current temperature index selected in the UI
  int get selectedTemperature => _selection?.selectedTemperature ?? 0;

  /// Current waveform mode selected in the UI
  WaveformMode get selectedMode =>
      _selection?.selectedMode ?? WaveformMode.gc16;

  /// Current scroll offset for the hex viewer
  int get hexViewOffset => _selection?.hexViewOffset ?? 0;

  /// Number of bytes displayed per row in the hex viewer
  int get hexViewBytesPerRow => _selection?.hexViewBytesPerRow ?? 16;

  /// Called by ProxyProvider when SelectionProvider updates
  void updateSelection(SelectionProvider selection) {
    _selection = selection;
    // Re-calculate sequence because selection params changed
    _updateSequence();
  }

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
        _currentFile = WaveformFile(
          fileName: fileName,
          format: WaveformFormat.rkf,
          rawData: bytes,
          loadedAt: DateTime.now(),
        );
        _error = 'RKF format detected - full parsing not yet implemented';
      }

      // Reset selection via the injected provider if possible
      _selection?.reset();

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
    if (_currentFile == null || _selection == null) {
      _currentSequence = null;
      _simulationResult = [];
      notifyListeners();
      return;
    }

    var rawSequence = <VoltageLevel>[];

    // Try to decode the actual waveform data
    if (_currentFile!.format == WaveformFormat.pvi &&
        _currentFile!.pviHeader != null) {
      final transition = WaveformParser.decodeTransition(
        data: _currentFile!.rawData,
        header: _currentFile!.pviHeader!,
        fromGray: _selection!.selectedFromGray,
        toGray: _selection!.selectedToGray,
        temperatureIndex: _selection!.selectedTemperature,
        mode: _selection!.selectedMode,
      );

      if (transition != null && transition.voltageSequence.isNotEmpty) {
        rawSequence = transition.voltageSequence;
      }
    }

    // Fall back to sample sequence for visualization if empty
    if (rawSequence.isEmpty) {
      rawSequence = WaveformParser.generateSampleSequence(
        _selection!.selectedFromGray,
        _selection!.selectedToGray,
      );
    }

    // Wrap in mutable model
    _currentSequence = WaveformSequence(
      data: rawSequence,
      mode: _selection!.selectedMode,
      temperatureIndex: _selection!.selectedTemperature,
      fromGray: _selection!.selectedFromGray,
      toGray: _selection!.selectedToGray,
    );

    _runSimulation();
    notifyListeners();
  }

  /// Update voltage for a specific frame (Editor mode)
  void updateVoltageAt(int index, VoltageLevel newLevel) {
    if (_currentSequence == null ||
        index < 0 ||
        index >= _currentSequence!.length) {
      return;
    }

    _currentSequence!.updateVoltage(index, newLevel);

    // Re-run simulation since data changed
    _runSimulation();

    notifyListeners();
  }

  /// Run the optical simulation based on current sequence
  void _runSimulation() {
    if (_currentSequence == null || _selection == null) {
      _simulationResult = [];
      return;
    }

    // Assuming Gray 0 = Black, Gray 15 = White
    final initialReflectance = _selection!.selectedFromGray / 15.0;

    _simulationResult = OpticalSimulator.simulate(
      sequence: _currentSequence!.data,
      temperatureIndex: _selection!.selectedTemperature,
      initialReflectance: initialReflectance,
    );
  }

  /// Clear the current file
  void clearFile() {
    _currentFile = null;
    _error = null;
    _currentSequence = null;
    _simulationResult = [];
    notifyListeners();
  }

  /// Export current waveform sequence to CSV
  Future<String?> exportToCsv() async {
    if (_currentSequence == null || _currentSequence!.data.isEmpty) {
      _error = 'No waveform data to export';
      notifyListeners();
      return null;
    }

    try {
      final result = await CsvExporter.exportSequence(
        sequence: _currentSequence!.data,
        fromGray: _currentSequence!.fromGray,
        toGray: _currentSequence!.toGray,
        mode: _currentSequence!.mode,
        temperature: _currentSequence!.temperatureIndex,
        simulationData: _simulationResult,
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
