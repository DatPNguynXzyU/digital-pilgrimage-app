class BuddhistFigure {
  final String id;
  final String name;
  final String slug;

  final String sanskritName;

  final List<String> otherNames;

  final String category;

  final String description;
  final String biography;
  final String symbolism;
  final String appearance;

  final String thumbnail;

  final List<String> images;

  BuddhistFigure({
    required this.id,
    required this.name,
    required this.slug,
    required this.sanskritName,
    required this.otherNames,
    required this.category,
    required this.description,
    required this.biography,
    required this.symbolism,
    required this.appearance,
    required this.thumbnail,
    required this.images,
  });

  factory BuddhistFigure.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuddhistFigure(
      id:
          json['_id']
                  ?.toString() ??
              json['id']
                  ?.toString() ??
              '',

      name:
          json['name']
                  ?.toString() ??
              '',

      slug:
          json['slug']
                  ?.toString() ??
              '',

      sanskritName:
          json['sanskritName']
                  ?.toString() ??
              '',

      otherNames:
          (json['otherNames']
                      as List<dynamic>? ??
                  [])
              .map(
                (item) =>
                    item.toString(),
              )
              .toList(),

      category:
          json['category']
                  ?.toString() ??
              '',

      description:
          json['description']
                  ?.toString() ??
              '',

      biography:
          json['biography']
                  ?.toString() ??
              '',

      symbolism:
          json['symbolism']
                  ?.toString() ??
              '',

      appearance:
          json['appearance']
                  ?.toString() ??
              '',

      thumbnail:
          json['thumbnail']
                  ?.toString() ??
              '',

      images:
          (json['images']
                      as List<dynamic>? ??
                  [])
              .map(
                (item) =>
                    item.toString(),
              )
              .toList(),
    );
  }
}