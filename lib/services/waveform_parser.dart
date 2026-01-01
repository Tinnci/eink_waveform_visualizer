import 'dart:typed_data';
import '../models/models.dart';

/// Service for parsing E-Ink waveform files
class WaveformParser {
  /// Identify the format of a waveform file
  static WaveformFormat identifyFormat(Uint8List data) {
    if (data.length < 8) return WaveformFormat.unknown;

    // Check for RKF signature "rkf:v1.0" or "rkf:v2.0"
    // RKF format has "rkf" at the beginning
    final first3Bytes = String.fromCharCodes(data.sublist(0, 3));
    if (first3Bytes == 'rkf' || first3Bytes == 'RKf') {
      return WaveformFormat.rkf;
    }

    // Check for PVI format characteristics
    // PVI has version byte at offset 0x10 (16) in range 9-114
    if (data.length >= 17) {
      final versionByte = data[16];
      if (versionByte >= 9 && versionByte <= 114) {
        return WaveformFormat.pvi;
      }
    }

    // Try to validate as PVI by checking header structure
    if (_validatePviHeader(data)) {
      return WaveformFormat.pvi;
    }

    return WaveformFormat.unknown;
  }

  /// Validate PVI header structure
  static bool _validatePviHeader(Uint8List data) {
    if (data.length < 64) return false;

    // Check if temp segment count at offset 38 is reasonable
    final tempSegmentCount = data[38];
    if (tempSegmentCount > 0 && tempSegmentCount <= 20) {
      return true;
    }

    return false;
  }

  /// Parse a PVI format waveform file
  static WaveformFile parsePviWaveform(Uint8List data, String fileName) {
    final header = PviWaveformHeader.fromBytes(data);

    // Determine supported modes based on version
    final supportedModes = _getSupportedModes(header.versionId);

    return WaveformFile(
      fileName: fileName,
      format: WaveformFormat.pvi,
      rawData: data,
      pviHeader: header,
      supportedModes: supportedModes,
      loadedAt: DateTime.now(),
    );
  }

  /// Get supported modes based on waveform version
  static List<WaveformMode> _getSupportedModes(int versionId) {
    // Based on assembly analysis, different versions support different modes
    // This is a simplified mapping
    return [
      WaveformMode.reset,
      WaveformMode.gray2,
      WaveformMode.gc16,
      WaveformMode.gl16,
      WaveformMode.a2,
      if (versionId >= 18) WaveformMode.glr16,
      if (versionId >= 18) WaveformMode.gld16,
      if (versionId >= 22) WaveformMode.gcc16,
    ];
  }

  /// Decodes the transition sequence from the raw waveform data.
  ///
  /// This logic handles both legacy PVI formats and newer variants.
  static WaveformTransition? decodeTransition({
    required Uint8List data,
    required PviWaveformHeader header,
    required int fromGray,
    required int toGray,
    required int temperatureIndex,
    required WaveformMode mode,
  }) {
    try {
      // Get the waveform table offset
      final tableBase = header.tableOffset;

      // Calculate mode offset (4 bytes per mode entry)
      final modeOffset = tableBase + (mode.value * 4);
      if (modeOffset + 4 > data.length) {
        return null;
      }

      // Read the mode entry pointer
      final byteData = ByteData.sublistView(data);
      final modeEntry = byteData.getUint32(modeOffset, Endian.little);
      final modeDataOffset = modeEntry & 0xFFFFFF; // 3-byte address

      if (modeDataOffset + (temperatureIndex * 4) + 4 > data.length) {
        return null;
      }

      // Read temperature entry
      final tempOffset = modeDataOffset + (temperatureIndex * 4);
      final tempEntry = byteData.getUint32(tempOffset, Endian.little);
      final tempDataOffset = tempEntry & 0xFFFFFF;

      if (tempDataOffset >= data.length) return null;

      // Calculate the LUT position for this gray level transition
      // LUT is organized as [fromGray][toGray]
      final lutIndex = (fromGray * 16) + toGray;
      final lutOffset = tempDataOffset + lutIndex;

      if (lutOffset >= data.length) return null;

      // Decode the voltage sequence
      final voltageSequence = _decodeVoltageSequence(
        data,
        lutOffset,
        maxFrames: 256,
      );

      return WaveformTransition(
        fromGrayLevel: fromGray,
        toGrayLevel: toGray,
        temperature: temperatureIndex,
        mode: mode,
        voltageSequence: voltageSequence,
      );
    } catch (e) {
      return null;
    }
  }

  /// Decode voltage sequence from raw data
  /// Based on the bit packing in the assembly: 2 bits per voltage instruction
  static List<VoltageLevel> _decodeVoltageSequence(
    Uint8List data,
    int startOffset, {
    int maxFrames = 256,
  }) {
    final voltages = <VoltageLevel>[];
    var offset = startOffset;

    while (offset < data.length && voltages.length < maxFrames) {
      final byte = data[offset];

      // Check for end marker (0xFF)
      if (byte == 0xFF) break;

      // Check for repeat/skip marker (0xFC)
      if (byte == 0xFC) {
        offset++;
        if (offset < data.length) {
          // Next byte might contain repeat info
          offset++;
        }
        continue;
      }

      // Extract 4 voltage levels from one byte (2 bits each)
      voltages.add(VoltageLevel.fromCode((byte >> 0) & 0x03));
      voltages.add(VoltageLevel.fromCode((byte >> 2) & 0x03));
      voltages.add(VoltageLevel.fromCode((byte >> 4) & 0x03));
      voltages.add(VoltageLevel.fromCode((byte >> 6) & 0x03));

      offset++;
    }

    return voltages;
  }

  /// Generate a sample/demo voltage sequence for visualization
  static List<VoltageLevel> generateSampleSequence(int fromGray, int toGray) {
    final sequence = <VoltageLevel>[];
    final grayDiff = toGray - fromGray;

    // Simulate a realistic waveform pattern
    if (grayDiff == 0) {
      // No change - just a few hold frames
      for (var i = 0; i < 4; i++) {
        sequence.add(VoltageLevel.hold);
      }
    } else if (grayDiff > 0) {
      // Going darker (higher gray level)
      final steps = grayDiff.abs();
      for (var i = 0; i < steps; i++) {
        sequence.add(VoltageLevel.positive);
        sequence.add(VoltageLevel.positive);
        sequence.add(VoltageLevel.zero);
      }
      sequence.add(VoltageLevel.hold);
    } else {
      // Going lighter (lower gray level)
      final steps = grayDiff.abs();
      for (var i = 0; i < steps; i++) {
        sequence.add(VoltageLevel.negative);
        sequence.add(VoltageLevel.negative);
        sequence.add(VoltageLevel.zero);
      }
      sequence.add(VoltageLevel.hold);
    }

    return sequence;
  }
}
