/// Waveform file format types
enum WaveformFormat {
  pvi,
  rkf,
  unknown,
}

/// E-Ink refresh mode types (from EPD LUT header)
enum WaveformMode {
  reset(0, 'RESET', 'Full Reset'),
  gray2(1, 'DU', 'Direct Update (2-level)'),
  gray4(2, 'DU4', 'Direct Update (4-level)'),
  gc16(3, 'GC16', 'Grayscale Clear 16'),
  gl16(4, 'GL16', 'Grayscale Light 16'),
  glr16(5, 'GLR16', 'GL16 with Regal'),
  gld16(6, 'GLD16', 'GL16 with Diff'),
  a2(7, 'A2', 'Animation 2-level'),
  gcc16(8, 'GCC16', 'GC16 with Collision'),
  auto_(10, 'AUTO', 'Auto Select');

  const WaveformMode(this.value, this.shortName, this.description);

  final int value;
  final String shortName;
  final String description;

  static WaveformMode? fromValue(int value) {
    for (final mode in WaveformMode.values) {
      if (mode.value == value) return mode;
    }
    return null;
  }
}

/// Voltage levels for E-Ink driving
enum VoltageLevel {
  zero(0x00, 0, '0V'),
  positive(0x01, 15, '+15V'),
  negative(0x02, -15, '-15V'),
  hold(0x03, null, 'HOLD');

  const VoltageLevel(this.code, this.voltage, this.label);

  final int code;
  final int? voltage;
  final String label;

  static VoltageLevel fromCode(int code) {
    switch (code & 0x03) {
      case 0x00:
        return VoltageLevel.zero;
      case 0x01:
        return VoltageLevel.positive;
      case 0x02:
        return VoltageLevel.negative;
      case 0x03:
        return VoltageLevel.hold;
      default:
        return VoltageLevel.zero;
    }
  }
}
