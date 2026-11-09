// lib/features/patient/services/availability_repository.dart

class TimeSlot {
  final String time; // بصيغة "HH:mm" مثل "09:00" أو "16:00"
  final bool isBooked;

  const TimeSlot(this.time, {this.isBooked = false});
}

/// بيانات تجريبية. لاحقاً تُستبدل بقراءة من قاعدة البيانات بنفس الشكل
/// (الممرض هو اللي بيحدد جدوله من تطبيقه).
class AvailabilityRepository {
  AvailabilityRepository._();

  static const List<String> _daySlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  /// الجدول الأسبوعي (الجمعة غير موجودة = إجازة)
  static const Map<int, List<String>> _weekly = {
    DateTime.saturday: _daySlots,
    DateTime.sunday: _daySlots,
    DateTime.monday: _daySlots,
    DateTime.tuesday: _daySlots,
    DateTime.wednesday: _daySlots,
    DateTime.thursday: _daySlots,
  };

  /// أقل مدة بين الآن وبداية الموعد
  static const int _minHoursAhead = 2;

  static List<TimeSlot> slotsFor({
    required String providerKey,
    required DateTime date,
    DateTime? now,
  }) {
    final times = _weekly[date.weekday];
    if (times == null) return const [];

    final current = now ?? DateTime.now();
    final earliest = current.add(const Duration(hours: _minHoursAhead));

    final result = <TimeSlot>[];
    for (final t in times) {
      final h = int.parse(t.substring(0, 2));
      final m = int.parse(t.substring(3));
      final start = DateTime(date.year, date.month, date.day, h, m);
      if (start.isBefore(earliest)) continue; // وقت مضى أو قريب جداً
      result.add(TimeSlot(t, isBooked: _isBookedMock(providerKey, date, t)));
    }
    return result;
  }

  /// يحاكي أوقات محجوزة (ثابتة لنفس الممرض واليوم)
  static bool _isBookedMock(String key, DateTime date, String time) {
    var seed = date.day + date.month * 31;
    for (final c in '$key$time'.codeUnits) {
      seed += c;
    }
    return seed % 4 == 0;
  }
}