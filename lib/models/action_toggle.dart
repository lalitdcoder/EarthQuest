// lib/models/action_toggle.dart

/// A single toggleable simulator action with its metric delta.
///
/// Deltas are applied/removed from the live [EarthMetrics] in-memory
/// — no Isar writes, purely reactive.
class ActionToggle {
  final String id;
  final String emoji;
  final String label;
  final String subtitle;

  // Signed deltas applied when the toggle is ON.
  final double dTemp;      // °C change (negative = cooler)
  final double dCo2;       // ppm change
  final double dIce;       // fraction change  (0‒1)
  final double dHealth;    // health-score points

  const ActionToggle({
    required this.id,
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.dTemp,
    required this.dCo2,
    required this.dIce,
    required this.dHealth,
  });
}

/// Master catalogue — all available simulator actions.
const kSimulatorActions = <ActionToggle>[
  ActionToggle(
    id: 'renewables',
    emoji: '☀️',
    label: 'Switch to Renewables',
    subtitle: '−8 ppm CO₂',
    dTemp:   -0.18,
    dCo2:    -8.0,
    dIce:     0.012,
    dHealth:  6.0,
  ),
  ActionToggle(
    id: 'trees',
    emoji: '🌳',
    label: 'Plant Trees',
    subtitle: '−5 ppm CO₂',
    dTemp:   -0.10,
    dCo2:    -5.0,
    dIce:     0.006,
    dHealth:  4.0,
  ),
  ActionToggle(
    id: 'meat',
    emoji: '🥦',
    label: 'Reduce Meat',
    subtitle: '−4 ppm CO₂',
    dTemp:   -0.08,
    dCo2:    -4.0,
    dIce:     0.004,
    dHealth:  3.5,
  ),
  ActionToggle(
    id: 'ev',
    emoji: '⚡',
    label: 'Drive Electric',
    subtitle: '−6 ppm CO₂',
    dTemp:   -0.14,
    dCo2:    -6.0,
    dIce:     0.008,
    dHealth:  5.0,
  ),
  ActionToggle(
    id: 'ocean',
    emoji: '🌊',
    label: 'Restore Oceans',
    subtitle: '+4% ice cover',
    dTemp:   -0.06,
    dCo2:    -3.0,
    dIce:     0.040,
    dHealth:  4.5,
  ),
  ActionToggle(
    id: 'insulation',
    emoji: '🏠',
    label: 'Insulate Homes',
    subtitle: '−3 ppm CO₂',
    dTemp:   -0.05,
    dCo2:    -3.0,
    dIce:     0.003,
    dHealth:  2.5,
  ),
  ActionToggle(
    id: 'carbon',
    emoji: '🔬',
    label: 'Carbon Capture',
    subtitle: '−10 ppm CO₂',
    dTemp:   -0.22,
    dCo2:   -10.0,
    dIce:     0.015,
    dHealth:  7.0,
  ),
];
