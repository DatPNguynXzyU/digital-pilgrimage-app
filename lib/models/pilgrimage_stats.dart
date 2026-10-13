class PilgrimageStats {
  final int totalVisits;
  final int uniqueTemples;
  final int totalStamps;

  final String? mostVisitedTempleName;
  final int mostVisitedCount;

  PilgrimageStats({
    required this.totalVisits,
    required this.uniqueTemples,
    required this.totalStamps,
    this.mostVisitedTempleName,
    required this.mostVisitedCount,
  });

  factory PilgrimageStats.fromJson(
    Map<String, dynamic> json,
  ) {
    final mostVisited =
        json['mostVisitedTemple']
            as Map<String, dynamic>?;

    final temple =
        mostVisited?['temple']
            as Map<String, dynamic>?;

    return PilgrimageStats(
      totalVisits:
          json['totalVisits'] ?? 0,

      uniqueTemples:
          json['uniqueTemples'] ?? 0,

      totalStamps:
          json['totalStamps'] ?? 0,

      mostVisitedTempleName:
          temple?['name']?.toString(),

      mostVisitedCount:
          mostVisited?['visitCount'] ?? 0,
    );
  }
}