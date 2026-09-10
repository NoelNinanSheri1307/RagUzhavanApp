import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTimestamp(DateTime dateTime, {String locale = 'en'}) {
    final format = DateFormat('yyyy-MM-dd HH:mm', locale);
    return format.format(dateTime);
  }

  static String formatDateOnly(DateTime dateTime, {String locale = 'en'}) {
    final format = DateFormat('dd MMM yyyy', locale);
    return format.format(dateTime);
  }

  static String formatDataAge(int days, {required String locale}) {
    if (locale == 'ta') {
      if (days == 0) return 'இன்றைய தரவு';
      if (days == 1) return '1 நாள் பழையது';
      return '$days நாட்கள் பழையது';
    } else {
      if (days == 0) return 'Updated today';
      if (days == 1) return 'Updated 1 day ago';
      return 'Updated $days days ago';
    }
  }

  static String formatConfidence(double score, {required String locale}) {
    final pct = (score * 100).round();
    if (locale == 'ta') {
      return 'நம்பகத்தன்மை: $pct%';
    } else {
      return 'Evidence Confidence: $pct%';
    }
  }
}
