enum FestivalKind { observance, major, monthly }

class BuddhistFestival {
  final String id;
  final String name;
  final int lunarMonth;
  final int lunarDay;
  final bool everyLunarMonth;
  final String description;
  final FestivalKind kind;
  final String traditionNote;

  const BuddhistFestival({
    required this.id,
    required this.name,
    required this.lunarMonth,
    required this.lunarDay,
    required this.description,
    this.everyLunarMonth = false,
    this.kind = FestivalKind.observance,
    this.traditionNote = '',
  });
}

class FestivalOccurrence {
  final BuddhistFestival festival;
  final DateTime solarDate;
  final int lunarDay;
  final int lunarMonth;

  const FestivalOccurrence({
    required this.festival,
    required this.solarDate,
    required this.lunarDay,
    required this.lunarMonth,
  });
}
