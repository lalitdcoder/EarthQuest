// lib/models/earth_metrics.dart

/// Immutable snapshot of the Earth's simulated health.
///
/// All fields are expressed as normalised values unless noted otherwise:
///   • [temp]        — global temperature anomaly in °C (0.0 – 4.0)
///   • [co2]         — atmospheric CO₂ level in ppm (280 – 500)
///   • [ice]         — Arctic sea-ice extent as a fraction (0.0 – 1.0)
///   • [healthScore] — composite 0 – 100 score (higher = healthier)
class EarthMetrics {
  final double temp;
  final double co2;
  final double ice;
  final double healthScore;

  const EarthMetrics({
    required this.temp,
    required this.co2,
    required this.ice,
    required this.healthScore,
  });

  /// Baseline "healthy planet" state shipped as the app default.
  static const initial = EarthMetrics(
    temp: 1.1,
    co2: 415.0,
    ice: 0.72,
    healthScore: 62.0,
  );

  /// Returns a copy with any provided fields overridden.
  EarthMetrics copyWith({
    double? temp,
    double? co2,
    double? ice,
    double? healthScore,
  }) {
    return EarthMetrics(
      temp: temp ?? this.temp,
      co2: co2 ?? this.co2,
      ice: ice ?? this.ice,
      healthScore: healthScore ?? this.healthScore,
    );
  }

  @override
  String toString() =>
      'EarthMetrics(temp: $temp, co2: $co2, ice: $ice, health: $healthScore)';
}
