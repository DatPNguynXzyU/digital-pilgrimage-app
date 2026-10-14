class TempleStamp {
  final String id;
  final String templeName;
  final String templeSlug;
  final String thumbnail;
  final DateTime? receivedAt;

  const TempleStamp({
    required this.id,
    required this.templeName,
    required this.templeSlug,
    required this.thumbnail,
    required this.receivedAt,
  });

  factory TempleStamp.fromJson(Map<String, dynamic> json) {
    final temple = json['temple'] as Map<String, dynamic>? ?? {};
    final rawReceivedAt = json['receivedAt']?.toString();

    return TempleStamp(
      id: json['id']?.toString() ?? '',
      templeName: temple['name']?.toString() ?? '',
      templeSlug: temple['slug']?.toString() ?? '',
      thumbnail: temple['thumbnail']?.toString() ?? '',
      receivedAt: rawReceivedAt == null
          ? null
          : DateTime.tryParse(rawReceivedAt),
    );
  }
}
