import 'waveform_format.dart';

/// Represents a mutable usage session of a waveform file.
/// This acts as the "source of truth" for the editor.
class WaveformSequence {
  final List<VoltageLevel> _data;
  final WaveformMode mode;
  final int temperatureIndex;
  final int fromGray;
  final int toGray;

  // Track if modified for future "Save" prompting
  bool _isModified = false;

  WaveformSequence({
    required List<VoltageLevel> data,
    required this.mode,
    required this.temperatureIndex,
    required this.fromGray,
    required this.toGray,
  }) : _data = List.from(data); // Create a mutable copy

  /// Get a read-only view of the data
  List<VoltageLevel> get data => List.unmodifiable(_data);

  bool get isModified => _isModified;
  int get length => _data.length;

  /// Update voltage at specific frame index
  void updateVoltage(int index, VoltageLevel newLevel) {
    if (index < 0 || index >= _data.length) return;

    if (_data[index] != newLevel) {
      _data[index] = newLevel;
      _isModified = true;
    }
  }

  /// Insert frames (e.g. extending duration)
  void insertFrames(int index, int count, VoltageLevel level) {
    if (index < 0 || index > _data.length) return;

    _data.insertAll(index, List.filled(count, level));
    _isModified = true;
  }

  /// Remove frames
  void removeFrames(int index, int count) {
    if (index < 0 || index + count > _data.length) return;

    _data.removeRange(index, index + count);
    _isModified = true;
  }
}
