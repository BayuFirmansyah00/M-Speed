class DateFilterHelper {
  /// Melakukan parse string tanggal (biasanya format yyyy-MM-dd HH:mm:ss) ke DateTime.
  /// Mengembalikan null jika format tidak valid atau string null.
  static DateTime? parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Menghitung selisih hari antara waktu sekarang dengan waktu aktivitas.
  /// Perhitungan menggunakan tanggal saja (tanpa memperhitungkan jam, menit, detik)
  /// agar lebih akurat dalam mendefinisikan batas hari.
  static int getDifferenceInDays(DateTime? activityDate) {
    if (activityDate == null) return 999;
    final now = DateTime.now();
    final dateOnlyNow = DateTime(now.year, now.month, now.day);
    final dateOnlyActivity =
        DateTime(activityDate.year, activityDate.month, activityDate.day);
    return dateOnlyNow.difference(dateOnlyActivity).inDays;
  }

  /// Filter list data berdasarkan batas maksimal hari (daysLimit).
  static List<T> filterByDays<T>({
    required List<T>? data,
    required String? Function(T) getActivityAt,
    required int maxDays,
  }) {
    if (data == null) return [];
    return data.where((item) {
      final activityAtStr = getActivityAt(item);
      final activityDate = parseDateTime(activityAtStr);
      if (activityDate == null) return false;
      final diff = getDifferenceInDays(activityDate);
      return diff >= 0 && diff <= maxDays;
    }).toList();
  }

  /// Memeriksa apakah ada data dalam rentang hari tertentu (minDays sampai maxDays).
  static bool hasDataInRange<T>({
    required List<T>? data,
    required String? Function(T) getActivityAt,
    required int minDays,
    required int maxDays,
  }) {
    if (data == null) return false;
    return data.any((item) {
      final activityAtStr = getActivityAt(item);
      final activityDate = parseDateTime(activityAtStr);
      if (activityDate == null) return false;
      final diff = getDifferenceInDays(activityDate);
      return diff >= minDays && diff <= maxDays;
    });
  }
}
