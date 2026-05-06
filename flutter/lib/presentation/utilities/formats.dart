import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

class Formats {
  static const String _defaultValue = '';
  static const String dateFormatShort = "dd MMM";
  static final london = getLocation('Europe/London');


  static String formatNumberDecimal(double? number) {
    if (number != null) {
      final formatter = NumberFormat("#,##0.00");
      return formatter.format(number);
    } else {
      return _defaultValue;
    }
  }

  static String formatNumberDecimalFromString(String? numberStr) {
    if (numberStr != null) {
      final formatter = NumberFormat("#,##0.00");
      return formatter.format(double.parse(numberStr));
    } else {
      return _defaultValue;
    }
  }

  static int getTimestampFromDateTimeString(String? dateStr) {
    var values = dateStr?.split("/");
    values ??= ["2023", "1", "1"];
    if(values[0].length < 4) {
      values = [values[2], values[1], values[0]];
    }
    // setLocalLocation(london);
    var londonTime = TZDateTime(london, int.parse(values[0]), int.parse(values[1]), int.parse(values[2]));

    var timeStamp = londonTime.millisecondsSinceEpoch;
    return timeStamp;
  }

  static int getEoDTimestampFromDateTimeString(String? dateStr) {
    var values = dateStr?.split("/");
    values ??= ["2023", "1", "1"];
    if(values[0].length < 4) {
      values = [values[2], values[1], values[0]];
    }
    // setLocalLocation(london);
    var londonTime = TZDateTime(london, int.parse(values[0]), int.parse(values[1]), int.parse(values[2]), 23, 59, 59);

    var timeStamp = londonTime.millisecondsSinceEpoch;
    return timeStamp;
  }


  static DateTime getDateTimeInLondon(int year, int month, int day) => TZDateTime(london, year, month, day);

  // https://api.dart.dev/stable/3.1.5/dart-core/DateTime/weekday.html
  static DateTime mostRecentWeekday(DateTime date, int weekday) =>
      getDateTimeInLondon(date.year, date.month, date.day - (date.weekday - weekday));

  static DateTime get currentLondonTimeNow => TZDateTime.now(london);
  static DateTime currentLondonTimeFromTimeStamp(int timeStamp) => TZDateTime.fromMillisecondsSinceEpoch(london, timeStamp);

  static String getMostRecentWordByTimeDelta(DateTime currentTime, int pastTimeStamp) {
    final pastTimeInLondon = currentLondonTimeFromTimeStamp(pastTimeStamp);
    final duration = currentTime.difference(pastTimeInLondon);

    // within last 60min
    if (duration.inMinutes < 60) {
      return "Just Now";
    }

    // in hours
    if (duration.inHours < 24) {
      return "${duration.inHours} hour${duration.inHours == 1 ? "" : "s"} ago";
    }

    // in days
    if (duration.inDays < 30) {
      return "${duration.inDays} day${duration.inDays == 1 ? "" : "s"} ago";
    }

    return DateFormat("dd/MM/yyyy").format(pastTimeInLondon);
  }
}
