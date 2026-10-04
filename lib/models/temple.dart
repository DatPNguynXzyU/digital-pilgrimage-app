class Temple {
  final String id;
  final String name;
  final String slug;

  final String description;
  final String history;

  final String street;
  final String ward;
  final String city;
  final String country;

  final String openingTime;
  final String closingTime;

  final String thumbnail;

  final List<String> images;

  final String tradition;

  final bool isFeatured;

  Temple({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.history,
    required this.street,
    required this.ward,
    required this.city,
    required this.country,
    required this.openingTime,
    required this.closingTime,
    required this.thumbnail,
    required this.images,
    required this.tradition,
    required this.isFeatured,
  });

  factory Temple.fromJson(
    Map<String, dynamic> json,
  ) {
    final address =
        json['address']
            as Map<String, dynamic>? ??
        {};

    final openingHours =
        json['openingHours']
            as Map<String, dynamic>? ??
        {};

    return Temple(
      id:
          json['_id']
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

      description:
          json['description']
              ?.toString() ??
          '',

      history:
          json['history']
              ?.toString() ??
          '',

      street:
          address['street']
              ?.toString() ??
          '',

      ward:
          address['ward']
              ?.toString() ??
          '',

      city:
          address['city']
              ?.toString() ??
          '',

      country:
          address['country']
              ?.toString() ??
          '',

      openingTime:
          openingHours['open']
              ?.toString() ??
          '',

      closingTime:
          openingHours['close']
              ?.toString() ??
          '',

      thumbnail:
          json['thumbnail']
              ?.toString() ??
          '',

      images:
          (json['images'] as List?)
                  ?.map(
                    (e) =>
                        e.toString(),
                  )
                  .toList() ??
              [],

      tradition:
          json['tradition']
              ?.toString() ??
          '',

      isFeatured:
          json['isFeatured']
                  as bool? ??
              false,
    );
  }

  String get fullAddress {
    return [
      street,
      ward,
      city,
      country,
    ]
        .where(
          (value) =>
              value.trim().isNotEmpty,
        )
        .join(', ');
  }

  String get openingHoursText {
    if (
        openingTime.isEmpty &&
        closingTime.isEmpty) {
      return 'Chưa cập nhật';
    }

    return '$openingTime - $closingTime';
  }
}