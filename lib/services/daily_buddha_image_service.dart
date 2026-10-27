import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Selects one bundled Buddha image per Vietnam calendar day.
class DailyBuddhaImageService {
  DailyBuddhaImageService._();

  static const fallbackAsset = 'images/buddha-meditation.png';

  /// Keep this list in sync with `images/buddha_daily/` and pubspec assets.
  /// Order is intentional because it defines the deterministic daily rotation.
  static const imageAssets = <String>[
    fallbackAsset,
    'images/buddha_daily/buddha_01.jpg',
    'images/buddha_daily/buddha_02.jpg',
    'images/buddha_daily/buddha_03.jpg',
    'images/buddha_daily/buddha_04.jpg',
    'images/buddha_daily/buddha_05.jpg',
    'images/buddha_daily/buddha_06.jpeg',
    'images/buddha_daily/buddha_07.jpeg',
    'images/buddha_daily/buddha_08.jpeg',
    'images/buddha_daily/buddha_09.jpeg',
    'images/buddha_daily/buddha_10.jpg',
  ];

  static bool _timeZonesInitialized = false;

  static tz.Location get _vietnamLocation {
    if (!_timeZonesInitialized) {
      tzdata.initializeTimeZones();
      _timeZonesInitialized = true;
    }
    return tz.getLocation('Asia/Ho_Chi_Minh');
  }

  /// Converts an instant into the Vietnam timezone.
  static DateTime vietnamDateTime([DateTime? instant]) {
    final value = (instant ?? DateTime.now()).toUtc();
    return tz.TZDateTime.from(value, _vietnamLocation);
  }

  static String dayKey(DateTime vietnamDate) =>
      '${vietnamDate.year.toString().padLeft(4, '0')}-'
      '${vietnamDate.month.toString().padLeft(2, '0')}-'
      '${vietnamDate.day.toString().padLeft(2, '0')}';

  /// Returns a stable image for a date. Consecutive Vietnam dates advance to
  /// consecutive assets, so no image repeats on adjacent days when there are
  /// at least two assets. A custom list is accepted for tests and future sets.
  static String imageForDate(
    DateTime vietnamDate, {
    List<String> assets = imageAssets,
  }) {
    if (assets.isEmpty) return fallbackAsset;
    if (assets.length == 1) return assets.single;

    final dateIndex = DateTime.utc(
      vietnamDate.year,
      vietnamDate.month,
      vietnamDate.day,
    ).difference(DateTime.utc(2000, 1, 1)).inDays;
    final index = ((dateIndex % assets.length) + assets.length) % assets.length;
    return assets[index];
  }

  /// The next local midnight in Vietnam, used to refresh a page left open.
  static DateTime nextVietnamMidnight(DateTime vietnamDateTime) =>
      tz.TZDateTime(
        _vietnamLocation,
        vietnamDateTime.year,
        vietnamDateTime.month,
        vietnamDateTime.day + 1,
      );
}
