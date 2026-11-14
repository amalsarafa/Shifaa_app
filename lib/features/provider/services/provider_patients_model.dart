// lib/features/provider/services/provider_patients_model.dart
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';

class ProviderPatient {
  final String id;
  final String name;
  final String gender;
  final int age;
  final String phone;
  final String place;
  final String address;
  final String birthDate;

  /// الزيارات المكتملة، الأحدث أولاً
  final List<ProviderAppointment> visits;

  const ProviderPatient({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
    required this.place,
    required this.address,
    required this.birthDate,
    required this.visits,
  });

  String get lastVisit => visits.isEmpty ? '' : visits.first.date;
}

class ProviderPatientsRepository {
  // 🔥 لاحقاً: تُقرأ من ملف المريض نفسه في Firebase
  static const Map<String, String> _birthDates = {
    'p5': '12 / 03 / 1981',
    'p6': '04 / 09 / 1997',
  };

  /// المرضى الذين لهم زيارة مكتملة فقط، الأحدث زيارةً أولاً
  static List<ProviderPatient> fromAppointments(
    List<ProviderAppointment> all,
  ) {
    final order = <String>[];
    final groups = <String, List<ProviderAppointment>>{};

    for (final a in all) {
      if (a.status != ProviderApptStatus.completed) continue;
      groups.putIfAbsent(a.patientId, () {
        order.add(a.patientId);
        return [];
      }).add(a);
    }

    return [
      for (final id in order)
        () {
          final v = groups[id]!;
          final f = v.first;
          return ProviderPatient(
            id: id,
            name: f.patientName,
            gender: f.gender,
            age: f.age,
            phone: f.phone,
            place: f.place,
            address: f.address,
            birthDate: _birthDates[id] ?? '—',
            visits: v,
          );
        }(),
    ];
  }

  static ProviderPatient? byId(String id) {
    for (final p in fromAppointments(
      ProviderAppointmentRepository.appointments.value,
    )) {
      if (p.id == id) return p;
    }
    return null;
  }
}