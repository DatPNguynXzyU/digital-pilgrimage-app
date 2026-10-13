class VisitedTemple {
  final String id;
  final String name;
  final String slug;
  final String thumbnail;

  final int visitCount;

  final DateTime? firstVisitedAt;
  final DateTime? lastVisitedAt;

  VisitedTemple({
    required this.id,
    required this.name,
    required this.slug,
    required this.thumbnail,
    required this.visitCount,
    required this.firstVisitedAt,
    required this.lastVisitedAt,
  });

  factory VisitedTemple.fromJson(
    Map<String, dynamic> json,
  ) {
    final temple =
        json['temple']
            as Map<String, dynamic>? ??
        {};

    return VisitedTemple(
      id:
          temple['id']?.toString() ??
          '',

      name:
          temple['name']?.toString() ??
          '',

      slug:
          temple['slug']?.toString() ??
          '',

      thumbnail:
          temple['thumbnail']
                  ?.toString() ??
              '',

      visitCount:
          json['visitCount'] ?? 0,

      firstVisitedAt:
          json['firstVisitedAt'] != null
              ? DateTime.tryParse(
                  json['firstVisitedAt'],
                )
              : null,

      lastVisitedAt:
          json['lastVisitedAt'] != null
              ? DateTime.tryParse(
                  json['lastVisitedAt'],
                )
              : null,
    );
  }
}