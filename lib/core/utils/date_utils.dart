import 'package:intl/intl.dart';

/// Date utility functions for formatting and calculations
class AppDateUtils {
  AppDateUtils._();

  // Common date formats
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Format date as "dd MMM yyyy" (e.g., "15 Jan 2024")
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  /// Format date and time as "dd MMM yyyy, hh:mm a" (e.g., "15 Jan 2024, 02:30 PM")
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTimeFormat.format(date);
  }

  /// Format time only as "hh:mm a" (e.g., "02:30 PM")
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return _timeFormat.format(date);
  }

  /// Format date as "dd/MM/yyyy" (e.g., "15/01/2024")
  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return _shortDateFormat.format(date);
  }

  /// Format as "MMMM yyyy" (e.g., "January 2024")
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYearFormat.format(date);
  }

  /// Format as "dd MMM" (e.g., "15 Jan")
  static String formatDayMonth(DateTime? date) {
    if (date == null) return '';
    return _dayMonthFormat.format(date);
  }

  /// Format as ISO date "yyyy-MM-dd" (e.g., "2024-01-15")
  static String formatIsoDate(DateTime? date) {
    if (date == null) return '';
    return _isoFormat.format(date);
  }

  /// Format for API "yyyy-MM-dd'T'HH:mm:ss"
  static String formatForApi(DateTime? date) {
    if (date == null) return '';
    return _apiDateTimeFormat.format(date);
  }

  /// Parse ISO date string to DateTime
  static DateTime? parseIsoDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// Parse date string with format "dd/MM/yyyy"
  static DateTime? parseShortDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _shortDateFormat.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// Get relative time string (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return formatDate(date);
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }

    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  /// Get chat timestamp (Today shows time, otherwise shows date)
  static String getChatTimestamp(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return formatTime(date);
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (dateOnly == yesterday) {
      return 'Yesterday';
    }

    if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    }

    return formatShortDate(date);
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get date of birth from age (approximate - January 1st)
  static DateTime getDateOfBirthFromAge(int age) {
    final now = DateTime.now();
    return DateTime(now.year - age, 1, 1);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Get list of years for dropdown (for birth year selection)
  static List<int> getYearsList({int startYear = 1950, int? endYear}) {
    final end = endYear ?? DateTime.now().year;
    return List.generate(end - startYear + 1, (index) => end - index);
  }

  /// Get list of months
  static List<String> getMonthsList() {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
  }

  /// Get days in month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
