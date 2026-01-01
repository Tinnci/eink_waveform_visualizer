import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:waveform_visualizer/models/models.dart';
import 'package:waveform_visualizer/services/services.dart';

void main() {
  group('WaveformParser Tests', () {
    test('Should identify PVI format correctly', () {
      final data = Uint8List(64);
      data[16] = 0x19; // Version ID characteristic for PVI
      data[38] = 0x0A; // Temp segment count

      final format = WaveformParser.identifyFormat(data);
      expect(format, WaveformFormat.pvi);
    });

    test('Should identify RKF format correctly', () {
      final data = Uint8List.fromList(
        'rkf:v1.0'.codeUnits + List.filled(56, 0),
      );

      final format = WaveformParser.identifyFormat(data);
      expect(format, WaveformFormat.rkf);
    });

    test('Should identify unknown format correctly', () {
      final data = Uint8List.fromList(List.filled(64, 0xAA));

      final format = WaveformParser.identifyFormat(data);
      expect(format, WaveformFormat.unknown);
    });
  });

  group('VoltageLevel Tests', () {
    test('Should map codes to correct VoltageLevels', () {
      expect(VoltageLevel.fromCode(0x00), VoltageLevel.zero);
      expect(VoltageLevel.fromCode(0x01), VoltageLevel.positive);
      expect(VoltageLevel.fromCode(0x02), VoltageLevel.negative);
      expect(VoltageLevel.fromCode(0x03), VoltageLevel.hold);

      // Masking check
      expect(
        VoltageLevel.fromCode(0xFD),
        VoltageLevel.positive,
      ); // 0xFD & 0x03 = 0x01
    });
  });
}
