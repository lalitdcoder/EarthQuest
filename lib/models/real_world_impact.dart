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
  ///   - 10 XP → 1 Tree
  ///   - 1 XP → 50 Liters of water
  ///   - 5 XP → 1 kg Plastic
  ///   - 1000 XP → 1 Acre
  factory RealWorldImpact.fromXp(int xp) {
    return RealWorldImpact(
      treesPlanted: (xp / 10).floor(),
      waterSavedLiters: (xp * 50).toDouble(),
      plasticRecoveredKg: (xp / 5).toDouble(),
      habitatsProtectedAcres: (xp / 1000).floor(),
    );
  }
}
