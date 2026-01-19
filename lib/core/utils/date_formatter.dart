import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _fullDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _dayMonth = DateFormat('d MMM', 'id_ID');
  static final DateFormat _time = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _firestoreDate = DateFormat('yyyy-MM-dd');

  static String formatFullDate(DateTime date) => _fullDate.format(date);
  static String formatShortDate(DateTime date) => _shortDate.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  static String formatTime(DateTime date) => _time.format(date);
  static String formatDateTime(DateTime date) => _dateTime.format(date);
  static String formatForFirestore(DateTime date) => _firestoreDate.format(date);

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return 'Hari Ini';
    if (difference == 1) return 'Besok';
    if (difference == -1) return 'Kemarin';
    if (difference > 1 && difference <= 7) return '$difference hari lagi';
    if (difference < -1 && difference >= -7) return '${-difference} hari lalu';
    
    return formatShortDate(date);
  }

  static String getDayName(int weekday) {
    const days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday];
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
