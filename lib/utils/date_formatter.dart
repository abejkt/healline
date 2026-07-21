class DateFormatterId {
  DateFormatterId._();

  static const _weekdayNamesId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const _monthNamesId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String formatDateId(DateTime date) {
    final month = _monthNamesId[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  static String formatFullDateId(DateTime date) {
    final dayName = _weekdayNamesId[date.weekday - 1];
    final monthName = _monthNamesId[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  static String formatDateWithWeekdayId(DateTime date) {
    final weekday = _weekdayNamesId[date.weekday - 1];
    return '$weekday, ${formatDateId(date)}';
  }
}
