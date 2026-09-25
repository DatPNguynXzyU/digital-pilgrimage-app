class Scripture {
  final String id;
  final String title;
  final String slug;
  final String type;
  final String description;
  final String content;
  final String source;
  final String imageUrl;
  final int order;
  final bool featured;

  const Scripture({
    required this.id,
    required this.title,
    required this.slug,
    required this.type,
    required this.description,
    required this.content,
    required this.source,
    required this.imageUrl,
    required this.order,
    required this.featured,
  });

  factory Scripture.fromJson(
    Map<String, dynamic> json,
  ) {
    return Scripture(
      id:
          json['_id']?.toString() ??
          '',

      title:
          json['title'] ?? '',

      slug:
          json['slug'] ?? '',

      type:
          json['type'] ?? '',

      description:
          json['description'] ?? '',

      content:
          json['content'] ?? '',

      source:
          json['source'] ?? '',

      imageUrl:
          json['imageUrl'] ?? '',

      order:
          json['order'] ?? 0,

      featured:
          json['featured'] ?? false,
    );
  }
}