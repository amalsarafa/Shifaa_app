// lib/features/provider/services/provider_appointment_model.dart
import 'package:flutter/foundation.dart';

enum ProviderApptStatus {
  pending,
  confirmed,
  completed,
  declined,
  canceledByPatient,
  expired,
}

class MedItem {
  final String name;
  final String dose;
  const MedItem(this.name, this.dose);
}

/// السجل الطبي للمريض 🔥 لاحقاً: يُقرأ من ملف المريض نفسه
class PatientMedicalInfo {
  final String bloodType;
  final int heightCm;
  final int weightKg;
  final List<String> allergies;
  final List<String> chronic;
  final List<MedItem> medications;
  final String emergencyName;
  final String emergencyPhone;

  const PatientMedicalInfo({
    required this.bloodType,
    required this.heightCm,
    required this.weightKg,
    required this.allergies,
    required this.chronic,
    required this.medications,
    required this.emergencyName,
    required this.emergencyPhone,
  });
}

/// تقرير الزيارة، لا تصير الزيارة مكتملة إلا بعد حفظه
class VisitReport {
  final String summary;
  final List<String> procedures;
  final String bloodPressure;
  final String sugar;
  final String temperature;
  final String pulse;
  final String recommendations;
  final bool followUp;
  final bool cashReceived;
  final String writtenAt;

  const VisitReport({
    required this.summary,
    this.procedures = const [],
    this.bloodPressure = '',
    this.sugar = '',
    this.temperature = '',
    this.pulse = '',
    this.recommendations = '',
    this.followUp = false,
    this.cashReceived = true,
    this.writtenAt = '',
  });
}

class ProviderAppointment {
  final String id;
  final String patientId; // 🔥 لاحقاً: لقراءة بيانات المريض من ملفه
  final String patientName;
  final String gender;
  final int age;
  final String service;
  final String date;
  final String time;
  final String place;
  final String address;
  final String notes;
  final int price;
  final String phone;
  final String expires;
  final int expiresInMinutes;
  final ProviderApptStatus status;
  final String declineReason;
  final PatientMedicalInfo medical;
  final VisitReport? report;

  const ProviderAppointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.gender,
    required this.age,
    required this.service,
    required this.date,
    required this.time,
    required this.place,
    required this.address,
    required this.status,
    this.notes = '',
    this.price = 80,
    this.phone = '',
    this.expires = '',
    this.expiresInMinutes = 0,
    this.declineReason = '',
    this.medical = ProviderAppointmentRepository.defaultMedical,
    this.report,
  });

  ProviderAppointment copyWith({
    ProviderApptStatus? status,
    String? declineReason,
    VisitReport? report,
  }) {
    return ProviderAppointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      gender: gender,
      age: age,
      service: service,
      date: date,
      time: time,
      place: place,
      address: address,
      notes: notes,
      price: price,
      phone: phone,
      expires: expires,
      expiresInMinutes: expiresInMinutes,
      status: status ?? this.status,
      declineReason: declineReason ?? this.declineReason,
      medical: medical,
      report: report ?? this.report,
    );
  }
}

/// مصدر بيانات وهمي مشترك 🔥 لاحقاً: يُستبدل بـ Firebase
class ProviderAppointmentRepository {
  static const String providerName = 'سارة محمد';
  static const String providerRole = 'ممرضة مسجلة';

  static const PatientMedicalInfo defaultMedical = PatientMedicalInfo(
    bloodType: 'O+',
    heightCm: 175,
    weightKg: 72,
    allergies: ['البنسلين', 'المكسرات'],
    chronic: ['السكري', 'ضغط الدم'],
    medications: [
      MedItem('ميتفورمين 500 ملغ', 'مرتين يومياً بعد الأكل'),
      MedItem('أملوديبين 5 ملغ', 'مرة يومياً صباحاً'),
    ],
    emergencyName: 'سارة خالد · الأخت',
    emergencyPhone: '+970 59 765 4321',
  );

  static final ValueNotifier<List<ProviderAppointment>> appointments =
      ValueNotifier<List<ProviderAppointment>>(const [
    // ── معلقة
    ProviderAppointment(
      id: 'a1',
      patientId: 'p1',
      patientName: 'أحمد سالم',
      gender: 'ذكر',
      age: 41,
      service: 'التمريض · تغيير الضمادات',
      date: 'اليوم',
      time: '5:00 م',
      place: 'غزة، تل الهوى',
      address: 'شارع الوحدة، عمارة 4',
      notes: 'الجرح في القدم اليمنى.',
      expires: 'ينتهي خلال 9 دقائق',
      expiresInMinutes: 9,
      status: ProviderApptStatus.pending,
    ),
    ProviderAppointment(
      id: 'a2',
      patientId: 'p2',
      patientName: 'علي أحمد',
      gender: 'ذكر',
      age: 34,
      service: 'التمريض · رعاية كبار السن',
      date: 'اليوم',
      time: '3:30 م',
      place: 'غزة، الرمال',
      address: 'شارع الجلاء، عمارة 12',
      notes: 'يرجى الاتصال قبل الوصول بنصف ساعة.',
      expires: 'ينتهي خلال 4 دقائق',
      expiresInMinutes: 4,
      status: ProviderApptStatus.pending,
    ),
    // ── قادمة
    ProviderAppointment(
      id: 'a3',
      patientId: 'p3',
      patientName: 'فاطمة علي',
      gender: 'أنثى',
      age: 58,
      service: 'الرعاية التمريضية · الحقن',
      date: 'اليوم',
      time: '3:30 م',
      place: 'غزة، الرمال',
      address: 'شارع الثورة، عمارة 7',
      phone: '+970 59 000 0002',
      status: ProviderApptStatus.confirmed,
    ),
    ProviderAppointment(
      id: 'a4',
      patientId: 'p4',
      patientName: 'لينا صالح',
      gender: 'أنثى',
      age: 67,
      service: 'التمريض · رعاية كبار السن',
      date: 'السبت، 14 نوفمبر',
      time: '10:00 ص',
      place: 'غزة، الرمال',
      address: 'شارع الشهداء، عمارة 2',
      phone: '+970 59 000 0003',
      status: ProviderApptStatus.confirmed,
    ),
    // ── مكتملة
    ProviderAppointment(
      id: 'a5',
      patientId: 'p5',
      patientName: 'منى يوسف',
      gender: 'أنثى',
      age: 45,
      service: 'الرعاية التمريضية · الحقن',
      date: 'أمس',
      time: '1:00 م',
      place: 'غزة، الرمال',
      address: 'شارع الجلاء، عمارة 3',
      phone: '+970 59 000 0004',
      status: ProviderApptStatus.completed,
      report: VisitReport(
        summary: 'تم إعطاء حقنة عضلية وقياس الضغط. حالة المريضة مستقرة.',
        procedures: ['حقن عضلي', 'قياس الضغط'],
        bloodPressure: '120/80',
        sugar: '110',
        temperature: '36.8',
        pulse: '78',
        recommendations: 'يُنصح بالراحة وشرب الماء بكثرة.',
        writtenAt: 'أمس',
      ),
    ),
    ProviderAppointment(
      id: 'a6',
      patientId: 'p6',
      patientName: 'خالد نبيل',
      gender: 'ذكر',
      age: 29,
      service: 'العلاج الطبيعي · تأهيل الركبة',
      date: 'الأربعاء',
      time: '11:00 ص',
      place: 'غزة، الشجاعية',
      address: 'شارع المنصورة، عمارة 9',
      phone: '+970 59 000 0005',
      status: ProviderApptStatus.completed,
      report: VisitReport(
        summary: 'جلسة تأهيل للركبة، تحسّن ملحوظ في المدى الحركي.',
        procedures: ['جلسة علاج طبيعي', 'تمارين تأهيلية'],
        recommendations: 'الاستمرار على التمارين يومياً.',
        followUp: true,
        writtenAt: 'الأربعاء',
      ),
    ),
    // ── ملغاة
    ProviderAppointment(
      id: 'a7',
      patientId: 'p7',
      patientName: 'سمير ياسر',
      gender: 'ذكر',
      age: 52,
      service: 'التمريض · الحقن',
      date: 'اليوم',
      time: '2:00 م',
      place: 'غزة، الرمال',
      address: 'شارع الجلاء، عمارة 5',
      declineReason: 'الموقع بعيد عن منطقة عملي',
      status: ProviderApptStatus.declined,
    ),
    ProviderAppointment(
      id: 'a8',
      patientId: 'p8',
      patientName: 'نور خليل',
      gender: 'أنثى',
      age: 33,
      service: 'العلاج الطبيعي · تأهيل الظهر',
      date: 'أمس',
      time: '4:00 م',
      place: 'غزة، تل الهوى',
      address: 'شارع الوحدة، عمارة 8',
      status: ProviderApptStatus.canceledByPatient,
    ),
    ProviderAppointment(
      id: 'a9',
      patientId: 'p9',
      patientName: 'يوسف عادل',
      gender: 'ذكر',
      age: 60,
      service: 'التمريض · قياس السكر',
      date: 'الثلاثاء',
      time: '12:00 م',
      place: 'غزة، الرمال',
      address: 'شارع الثورة، عمارة 1',
      status: ProviderApptStatus.expired,
    ),
  ]);

  static ProviderAppointment? byId(String id) {
    for (final a in appointments.value) {
      if (a.id == id) return a;
    }
    return null;
  }

  static void _replace(ProviderAppointment updated) {
    appointments.value = [
      for (final a in appointments.value) a.id == updated.id ? updated : a,
    ];
  }

  static void accept(String id) {
    // 🔥 لاحقاً: تحديث الحالة إلى "مؤكد" في Firebase
    final a = byId(id);
    if (a == null) return;
    _replace(a.copyWith(status: ProviderApptStatus.confirmed));
  }

  static void decline(String id, String reason) {
    // 🔥 لاحقاً: تحديث الحالة إلى "مرفوض" مع السبب
    final a = byId(id);
    if (a == null) return;
    _replace(
      a.copyWith(status: ProviderApptStatus.declined, declineReason: reason),
    );
  }

    static void saveReport(String id, VisitReport report) {
    // 🔥 لاحقاً: رفع التقرير، وتصير الزيارة مكتملة
    final a = byId(id);
    if (a == null) return;
    final updated =
        a.copyWith(status: ProviderApptStatus.completed, report: report);
    // الأحدث أولاً
    appointments.value = [
      updated,
      ...appointments.value.where((x) => x.id != id),
    ];
  }
}