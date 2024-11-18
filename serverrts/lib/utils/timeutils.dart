class TimeUtils {
  static int minutesBetween(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }
}
