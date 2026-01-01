import '../models/models.dart';

/// Predicts the optical reflectance of an E-Ink pixel based on voltage sequences.
/// This implements an Electrophoretic Particle Model (EPM).
class OpticalSimulator {
  /// Simulates a transition and returns a list of reflectance values (0.0 = Black, 1.0 = White)
  /// for each frame in the sequence.
  static List<double> simulate({
    required List<VoltageLevel> sequence,
    required int temperatureIndex,
    double initialReflectance = 0.5, // Start at mid-gray if unknown
  }) {
    if (sequence.isEmpty) return [];

    final List<double> results = [];
    double currentPosition =
        initialReflectance; // 0.0 (Black electrode) to 1.0 (White electrode)

    // Physical constants (simplified)
    // In a real device, these would be tuned per panel batch.
    const double baseMobility = 0.05; // How fast particles move at room temp

    // Viscosity adjustment based on temperature index
    // Higher index (usually higher temp) = lower viscosity = higher mobility.
    // Assuming temp index 0 is ~0°C and index 10 is ~50°C.
    final double mobility = baseMobility * (1.0 + (temperatureIndex * 0.15));

    for (var voltage in sequence) {
      double v = 0.0;
      if (voltage == VoltageLevel.positive) v = 1.0;
      if (voltage == VoltageLevel.negative) v = -1;

      // Calculate delta position
      // Particles move towards white (pos) or black (neg)
      double delta = v * mobility;

      // Non-linear boundary effects: movement slows down as particles hit "walls"
      if (delta > 0) {
        // Approaching White (1.0)
        delta *= (1.1 - currentPosition);
      } else {
        // Approaching Black (0.0)
        delta *= (currentPosition + 0.1);
      }

      currentPosition += delta;

      // Clamp to physical boundaries
      currentPosition = currentPosition.clamp(0.0, 1.0);
      results.add(currentPosition);
    }

    return results;
  }

  /// Maps a reflectance value (0.0-1.0) to a display Color (Grayscale)
  static int reflectanceToGray(double reflectance) {
    return (reflectance * 255).round().clamp(0, 255);
  }
}
