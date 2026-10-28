import 'dart:math' as math;

class LunarDate {
  final int day;
  final int month;
  final int year;
  final bool isLeapMonth;

  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.isLeapMonth,
  });
}

class LunarCalendar {
  static const double _timeZone = 7.0;

  static int _jdFromDate(int day, int month, int year) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    var jd = day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    if (jd < 2299161) {
      jd = day +
          ((153 * m + 2) / 5).floor() +
          365 * y +
          (y / 4).floor() -
          32083;
    }

    return jd;
  }

  static double _newMoon(int k) {
    const dr = math.pi / 180;

    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;

    var jd1 = 2415020.75933 +
        29.53058868 * k +
        0.0001178 * t2 -
        0.000000155 * t3;

    jd1 += 0.00033 *
        math.sin(
          (166.56 + 132.87 * t - 0.009173 * t2) * dr,
        );

    final m = 359.2242 +
        29.10535608 * k -
        0.0000333 * t2 -
        0.00000347 * t3;

    final mPrime = 306.0253 +
        385.81691806 * k +
        0.0107306 * t2 +
        0.00001236 * t3;

    final f = 21.2964 +
        390.67050646 * k -
        0.0016528 * t2 -
        0.00000239 * t3;

    final c1 = (0.1734 - 0.000393 * t) *
            math.sin(m * dr) +
        0.0021 * math.sin(2 * m * dr) -
        0.4068 * math.sin(mPrime * dr) +
        0.0161 * math.sin(2 * mPrime * dr) -
        0.0004 * math.sin(3 * mPrime * dr) +
        0.0104 * math.sin(2 * f * dr) -
        0.0051 * math.sin((m + mPrime) * dr) -
        0.0074 * math.sin((m - mPrime) * dr) +
        0.0004 * math.sin((2 * f + m) * dr) -
        0.0004 * math.sin((2 * f - m) * dr) -
        0.0006 * math.sin((2 * f + mPrime) * dr) +
        0.0010 * math.sin((2 * f - mPrime) * dr) +
        0.0005 * math.sin((2 * mPrime + m) * dr);

    double deltaT;

    if (t < -11) {
      deltaT = 0.001 +
          0.000839 * t +
          0.0002261 * t2 -
          0.00000845 * t3 -
          0.000000081 * t * t3;
    } else {
      deltaT = -0.000278 +
          0.000265 * t +
          0.000262 * t2;
    }

    return jd1 + c1 - deltaT;
  }

  static int _getNewMoonDay(int k) {
    return (_newMoon(k) + 0.5 + _timeZone / 24).floor();
  }

  static double _sunLongitude(double jdn) {
    const dr = math.pi / 180;

    final t = (jdn - 2451545.0) / 36525;
    final t2 = t * t;

    final m = 357.52910 +
        35999.05030 * t -
        0.0001559 * t2 -
        0.00000048 * t * t2;

    final l0 = 280.46645 +
        36000.76983 * t +
        0.0003032 * t2;

    var dl = (1.914600 -
            0.004817 * t -
            0.000014 * t2) *
        math.sin(dr * m);

    dl += (0.019993 - 0.000101 * t) *
        math.sin(dr * 2 * m);

    dl += 0.000290 * math.sin(dr * 3 * m);

    var l = l0 + dl;

    l *= dr;

    l -= math.pi * 2 *
        (l / (math.pi * 2)).floor();

    return l;
  }

  static int _getSunLongitude(int dayNumber) {
    return (_sunLongitude(
                  dayNumber - 0.5 - _timeZone / 24,
                ) /
                math.pi *
                6)
            .floor();
  }

  static int _getLunarMonth11(int year) {
    final off =
        _jdFromDate(31, 12, year) - 2415021;

    final k = (off / 29.530588853).floor();

    var newMoon = _getNewMoonDay(k);

    final sunLong =
        _getSunLongitude(newMoon);

    if (sunLong >= 9) {
      newMoon = _getNewMoonDay(k - 1);
    }

    return newMoon;
  }

  static int _getLeapMonthOffset(int a11) {
    final k = (0.5 +
            (a11 - 2415021.076998695) /
                29.530588853)
        .floor();

    var last = 0;
    var i = 1;

    var arc =
        _getSunLongitude(_getNewMoonDay(k + i));

    do {
      last = arc;

      i++;

      arc =
          _getSunLongitude(_getNewMoonDay(k + i));
    } while (arc != last && i < 14);

    return i - 1;
  }

  static LunarDate fromSolar(DateTime date) {
    final dayNumber = _jdFromDate(
      date.day,
      date.month,
      date.year,
    );

    final k = ((dayNumber - 2415021.076998695) /
            29.530588853)
        .floor();

    var monthStart =
        _getNewMoonDay(k + 1);

    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k);
    }

    var a11 =
        _getLunarMonth11(date.year);

    var b11 = a11;

    int lunarYear;

    if (a11 >= monthStart) {
      lunarYear = date.year;

      a11 =
          _getLunarMonth11(date.year - 1);
    } else {
      lunarYear = date.year + 1;

      b11 =
          _getLunarMonth11(date.year + 1);
    }

    final lunarDay =
        dayNumber - monthStart + 1;

    final diff =
        ((monthStart - a11) / 29).floor();

    var lunarMonth =
        diff + 11;

    var lunarLeap = false;

    if (b11 - a11 > 365) {
      final leapMonthDiff =
          _getLeapMonthOffset(a11);

      if (diff >= leapMonthDiff) {
        lunarMonth =
            diff + 10;

        if (diff == leapMonthDiff) {
          lunarLeap = true;
        }
      }
    }

    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }

    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }

    return LunarDate(
      day: lunarDay,
      month: lunarMonth,
      year: lunarYear,
      isLeapMonth: lunarLeap,
    );
  }
}