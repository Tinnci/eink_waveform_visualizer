import 'dart:typed_data';
import 'waveform_format.dart';

/// PVI Waveform file header structure
class PviWaveformHeader {
  final int checksum;
  final int fileSize;
  final int versionId;
  final int tempSegmentCount;
  final int tableOffset;
  final List<int> temperatureTable;

  PviWaveformHeader({
    required this.checksum,
    required this.fileSize,
    required this.versionId,
    required this.tempSegmentCount,
    required this.tableOffset,
    required this.temperatureTable,
  });

  factory PviWaveformHeader.fromBytes(Uint8List data) {
    if (data.length < 64) {
      throw ArgumentError('Data too short for PVI header');
    }

    final byteData = ByteData.sublistView(data);

    // Read header fields (little-endian)
    final checksum = byteData.getUint32(0, Endian.little);
    final fileSize = byteData.getUint32(4, Endian.little);
    final versionId = data[16]; // Offset 0x10

    // Read temp segment count from offset 38 as per assembly code
    final actualTempSegmentCount = data[38];
    final tableOffset = data[32];

    // Read temperature table starting at offset 48
    final temperatureTable = <int>[];
    for (var i = 0; i < actualTempSegmentCount && (48 + i) < data.length; i++) {
      temperatureTable.add(data[48 + i]);
    }

    return PviWaveformHeader(
      checksum: checksum,
      fileSize: fileSize,
      versionId: versionId,
      tempSegmentCount: actualTempSegmentCount,
      tableOffset: tableOffset,
      temperatureTable: temperatureTable,
    );
  }

  String get versionString =>
      '0x${versionId.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  @override
  String toString() {
    return 'PviWaveformHeader(checksum: 0x${checksum.toRadixString(16)}, '
        'fileSize: $fileSize, version: $versionString, '
        'tempSegments: $tempSegmentCount, tableOffset: $tableOffset)';
  }
}

/// Represents a complete waveform file
class WaveformFile {
  final String fileName;
  final WaveformFormat format;
  final Uint8List rawData;
  final PviWaveformHeader? pviHeader;
  final List<WaveformMode> supportedModes;
  final DateTime? loadedAt;

  WaveformFile({
    required this.fileName,
    required this.format,
    required this.rawData,
    this.pviHeader,
    this.supportedModes = const [],
    this.loadedAt,
  });

  int get fileSize => rawData.length;

  /// Get temperature range from header
  (int min, int max)? get temperatureRange {
    if (pviHeader == null || pviHeader!.temperatureTable.isEmpty) return null;
    return (
      pviHeader!.temperatureTable.first - 10, // Approximate offset
      pviHeader!.temperatureTable.last + 10,
    );
  }
}

/// Represents decoded waveform data for a specific transition
class WaveformTransition {
  final int fromGrayLevel;
  final int toGrayLevel;
  final int temperature;
  final WaveformMode mode;
  final List<VoltageLevel> voltageSequence;

  WaveformTransition({
    required this.fromGrayLevel,
    required this.toGrayLevel,
    required this.temperature,
    required this.mode,
    required this.voltageSequence,
  });

  int get frameCount => voltageSequence.length;
}
