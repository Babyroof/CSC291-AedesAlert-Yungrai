abstract class DateFormatter {
  static String toMonthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

  static String monthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  static String toDisplayDate(DateTime dt) =>
      '${dt.day} ${monthAbbreviation(dt.month)} ${dt.year}';
}
