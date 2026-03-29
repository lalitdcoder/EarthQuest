// lib/models/real_world_impact.dart

/// Data model representing the tangible, real-world impact derived from user XP.
class RealWorldImpact {
  final int treesPlanted;
  final double waterSavedLiters;
  final double plasticRecoveredKg;
  final int habitatsProtectedAcres;

  const RealWorldImpact({
    this.treesPlanted = 0,
    this.waterSavedLiters = 0,
    this.plasticRecoveredKg = 0,
    this.habitatsProtectedAcres = 0,
  });

  /// The core translation algorithm.
  /// 
  /// Weights:
  ///   - 50 XP → 1 Tree
  ///   - 10 XP → 5 Liters of water (1 XP = 0.5 Liters)
  ///   - 5 XP → 1 kg Plastic
  ///   - 1000 XP → 1 Acre
  factory RealWorldImpact.fromXp(int xp) {
    return RealWorldImpact(
      treesPlanted: (xp / 50).floor(),
      waterSavedLiters: (xp * 0.5),
      plasticRecoveredKg: (xp / 5).toDouble(),
      habitatsProtectedAcres: (xp / 1000).floor(),
    );
  }
}
