// lib/features/patient/services/availability_repository.dart

class TimeSlot {
  final String time; // بداية الفترة "HH:mm" مثل "09:00"
  final String endTime; // نهاية الفترة "HH:mm" مثل "09:30"
  final bool isBooked;

  const TimeSlot(this.time, this.endTime, {this.isBooked = false});
}

/// فترة عمل بالدقائق من منتصف الليل: مثلاً 9:00 → 11:00 = (540, 660)
class WorkPeriod {
  final int from;
  final int to;

  const WorkPeriod(this.from, this.to);
}

/// بيانات تجريبية. لاحقاً تُستبدل بقراءة من قاعدة البيانات بنفس الشكل
/// (مقدم الرعاية هو اللي بيدخل أوقات عمله من تطبيقه).
class AvailabilityRepository {
  AvailabilityRepository._();

  /// أوقات عمل تجريبية لكل أيام الأسبوع (بما فيها الجمعة)
  static const List<WorkPeriod> _periods = [
    WorkPeriod(9 * 60, 11 * 60), // 9:00 → 11:00
    WorkPeriod(16 * 60, 18 * 60), // 4:00 → 6:00
  ];

  /// وقت التنقل بين الزيارات. يُحجز مع كل فترة ولا يظهر للمريض
  static const int _travelMinutes = 15;

  /// أقل مدة بين الآن وبداية الموعد
  static const int _minHoursAhead = 2;

  /// أوقات عمل مقدم الرعاية في هذا اليوم.
  /// لاحقاً: تُقرأ من أوقات العمل اللي دخلها المقدم (لكل يوم وقته).
  static List<WorkPeriod> _workPeriods(String providerKey, int weekday) {
    return _periods;
  }

  static String _fmt(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// يولّد الفترات من أوقات العمل، وطول كل فترة = مدة الخدمة بالدقائق
  static List<TimeSlot> slotsFor({
    required String providerKey,
    required DateTime date,
    required int minutes,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final earliest = current.add(const Duration(hours: _minHoursAhead));

    final result = <TimeSlot>[];
    for (final p in _workPeriods(providerKey, date.weekday)) {
      final block = minutes + _travelMinutes; // الكتلة = الخدمة + التنقل
      for (var s = p.from; s + minutes <= p.to; s += block) {
        final start = DateTime(
          date.year,
          date.month,
          date.day,
          s ~/ 60,
          s % 60,
        );
        if (start.isBefore(earliest)) continue; // وقت مضى أو قريب جداً

        final t = _fmt(s);
        result.add(
          TimeSlot(
            t,
            _fmt(s + minutes),
            isBooked: _isBookedMock(providerKey, date, t),
          ),
        );
      }
    }
    return result;
  }

  /// يحاكي أوقات محجوزة (ثابتة لنفس المقدم واليوم)
  static bool _isBookedMock(String key, DateTime date, String time) {
    var seed = date.day + date.month * 31;
    for (final c in '$key$time'.codeUnits) {
      seed += c;
    }
    return seed % 4 == 0;
  }
}
