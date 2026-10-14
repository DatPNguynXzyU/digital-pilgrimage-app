class PilgrimageVisit {
  final String id;
  final String templeName;
  final String templeSlug;
  final String thumbnail;
  final DateTime? visitDate;
  final String note;

  const PilgrimageVisit({
    required this.id,
    required this.templeName,
    required this.templeSlug,
    required this.thumbnail,
    required this.visitDate,
    required this.note,
  });

  factory PilgrimageVisit.fromJson(Map<String, dynamic> json) {
    final temple = json['temple'] as Map<String, dynamic>? ?? {};
    final rawVisitDate = json['visitDate']?.toString();

    return PilgrimageVisit(
      id: json['id']?.toString() ?? '',
      templeName: temple['name']?.toString() ?? '',
      templeSlug: temple['slug']?.toString() ?? '',
      thumbnail: temple['thumbnail']?.toString() ?? '',
      visitDate: rawVisitDate == null ? null : DateTime.tryParse(rawVisitDate),
      note: json['note']?.toString() ?? '',
    );
  }
}
