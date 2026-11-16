// lib/features/provider/services/provider_appointment_model.dart
import 'package:flutter/foundation.dart';
import 'package:my_first_app/core/models/visit_report.dart';

// تقرير الزيارة صار مشتركاً في core، نعيد تصديره لملفات مقدم الرعاية
export 'package:my_first_app/core/models/visit_report.dart';

enum ProviderApptStatus {
  pending,
  confirmed,
  // حُفظ التقرير، وننتظر تأكيد المريض أن الزيارة تمت
  awaitingPatientConfirmation,
  completed,
  // أبلغ المريض أن الزيارة لم تتم، والبلاغ قيد مراجعة الدعم
  disputed,
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

/// تنسيق تاريخ ووقت الموعد بالعربي
class ProviderApptFormat {
  ProviderApptFormat._();

  // DateTime.weekday: 1 = الاثنين ... 7 = الأحد
  static const _dayNames = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const _monthNames = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// "اليوم" / "أمس" / "غداً" / "السبت، 14 نوفمبر"
  static String date(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == -1) return 'أمس';
    if (diff == 1) return 'غداً';
    return '${_dayNames[d.weekday - 1]}، ${d.day} ${_monthNames[d.month - 1]}';
  }

  /// "5:00 م"
  static String time(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h12:$m ${d.hour >= 12 ? 'م' : 'ص'}';
  }
}

class ProviderAppointment {
  final String id;
  final String patientId; // 🔥 لاحقاً: لقراءة بيانات المريض من ملفه
  final String patientName;
  final String gender;
  final int age;
  final String service;

  /// بداية الموعد الحقيقية، ومدة الخدمة بالدقائق
  /// 🔥 لاحقاً: من Firestore، مع التعامل مع الزيارات المتأخرة أو المؤجلة
  final DateTime startsAt;
  final int durationMinutes;

  final String place;
  final String address;
  final String notes;
  final int price;
  final String phone;
  final String expires;
  final int expiresInMinutes;
  final ProviderApptStatus status;
  final String declineReason;
  final String? disputeReason;
  final PatientMedicalInfo medical;
  final VisitReport? report;

  const ProviderAppointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.gender,
    required this.age,
    required this.service,
    required this.startsAt,
    required this.durationMinutes,
    required this.place,
    required this.address,
    // المريض يسجّل دخوله برقمه، فهو موجود دائماً
    required this.phone,
    required this.status,
    this.notes = '',
    this.price = 80,
    this.expires = '',
    this.expiresInMinutes = 0,
    this.declineReason = '',
    this.disputeReason,
    this.medical = ProviderAppointmentRepository.defaultMedical,
    this.report,
  });

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  /// النصوص محسوبة من startsAt، فتبقى متطابقة معه دائماً
  String get date => ProviderApptFormat.date(startsAt);
  String get time => ProviderApptFormat.time(startsAt);

  ProviderAppointment copyWith({
    ProviderApptStatus? status,
    String? declineReason,
    String? disputeReason,
    VisitReport? report,
  }) {
    return ProviderAppointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      gender: gender,
      age: age,
      service: service,
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      place: place,
      address: address,
      notes: notes,
      price: price,
      phone: phone,
      expires: expires,
      expiresInMinutes: expiresInMinutes,
      status: status ?? this.status,
      declineReason: declineReason ?? this.declineReason,
      disputeReason: disputeReason ?? this.disputeReason,
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

  // مدة كل خدمة بالدقائق (الحد الأعلى من مدة الخدمة عند المريض)
  static const int _injections = 30;
  static const int _wounds = 45;
  static const int _elderly = 45;
  static const int _sugar = 30;
  static const int _physio = 60;

  static final ValueNotifier<List<ProviderAppointment>> appointments =
      ValueNotifier<List<ProviderAppointment>>(_mockData());

  /// الأوقات محسوبة من الآن، فتبقى الأمثلة صحيحة بأي يوم نجرّب فيه
  static List<ProviderAppointment> _mockData() {
    final now = DateTime.now();

    // يوم نسبي بساعة ثابتة، مثل: أمس 1:00 م
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

    // وقت نسبي من الآن، مقرّب لأقرب 5 دقائق
    DateTime fromNow(Duration d) {
      final t = now.add(d);
      return DateTime(t.year, t.month, t.day, t.hour, t.minute - t.minute % 5);
    }

    return [
      // ── معلقة
      ProviderAppointment(
        id: 'a1',
        patientId: 'p1',
        patientName: 'أحمد سالم',
        gender: 'ذكر',
        age: 41,
        service: 'الرعاية التمريضية · تغيير الضمادات',
        startsAt: fromNow(const Duration(hours: 4)),
        durationMinutes: _wounds,
        place: 'غزة، تل الهوى',
        address: 'شارع الوحدة، عمارة 4',
        notes: 'الجرح في القدم اليمنى.',
        phone: '+970 59 000 0006',
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
        service: 'الرعاية التمريضية · رعاية كبار السن',
        startsAt: fromNow(const Duration(hours: 3)),
        durationMinutes: _elderly,
        place: 'غزة، الرمال',
        address: 'شارع الجلاء، عمارة 12',
        notes: 'يرجى الاتصال قبل الوصول بنصف ساعة.',
        phone: '+970 59 000 0007',
        expires: 'ينتهي خلال 4 دقائق',
        expiresInMinutes: 4,
        status: ProviderApptStatus.pending,
      ),
      // ── قادمة
      // انتهى وقتها اليوم: زر "إنهاء الزيارة" مفعّل
      ProviderAppointment(
        id: 'a3',
        patientId: 'p3',
        patientName: 'فاطمة علي',
        gender: 'أنثى',
        age: 58,
        service: 'الرعاية التمريضية · الحقن',
        startsAt: fromNow(const Duration(hours: -2)),
        durationMinutes: _injections,
        place: 'غزة، الرمال',
        address: 'شارع الثورة، عمارة 7',
        phone: '+970 59 000 0002',
        status: ProviderApptStatus.confirmed,
      ),
      // جارية الآن وتنتهي بعد نحو نصف ساعة: الزر معطّل ثم يتفعّل وحده
      ProviderAppointment(
        id: 'a4',
        patientId: 'p4',
        patientName: 'لينا صالح',
        gender: 'أنثى',
        age: 67,
        service: 'الرعاية التمريضية · رعاية كبار السن',
        startsAt: fromNow(const Duration(minutes: -15)),
        durationMinutes: _elderly,
        place: 'غزة، الرمال',
        address: 'شارع الشهداء، عمارة 2',
        phone: '+970 59 000 0003',
        status: ProviderApptStatus.confirmed,
      ),
      // ── بانتظار تأكيد المريض
      ProviderAppointment(
        id: 'a10',
        patientId: 'p10',
        patientName: 'رنا حسن',
        gender: 'أنثى',
        age: 39,
        service: 'الرعاية التمريضية · العناية بالجروح',
        startsAt: at(-1, 10),
        durationMinutes: _wounds,
        place: 'غزة، النصر',
        address: 'شارع النصر، عمارة 6',
        phone: '+970 59 000 0011',
        status: ProviderApptStatus.awaitingPatientConfirmation,
        report: const VisitReport(
          summary: 'تم تنظيف الجرح وتغيير الضماد. الجرح يلتئم بشكل جيد.',
          procedures: ['تغيير ضمادة', 'قياس الضغط'],
          bloodPressure: '118/76',
          recommendations: 'الحفاظ على الضماد جافاً وتغييره بعد يومين.',
          writtenAt: 'أمس',
        ),
      ),
      // ── مكتملة
      ProviderAppointment(
        id: 'a5',
        patientId: 'p5',
        patientName: 'منى يوسف',
        gender: 'أنثى',
        age: 45,
        service: 'الرعاية التمريضية · الحقن',
        startsAt: at(-1, 13),
        durationMinutes: _injections,
        place: 'غزة، الرمال',
        address: 'شارع الجلاء، عمارة 3',
        phone: '+970 59 000 0004',
        status: ProviderApptStatus.completed,
        report: const VisitReport(
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
        startsAt: at(-4, 11),
        durationMinutes: _physio,
        place: 'غزة، الشجاعية',
        address: 'شارع المنصورة، عمارة 9',
        phone: '+970 59 000 0005',
        status: ProviderApptStatus.completed,
        report: const VisitReport(
          summary: 'جلسة تأهيل للركبة، تحسّن ملحوظ في المدى الحركي.',
          procedures: ['جلسة علاج طبيعي', 'تمارين تأهيلية'],
          recommendations: 'الاستمرار على التمارين يومياً.',
          followUp: true,
          writtenAt: 'قبل 4 أيام',
        ),
      ),
      // ── بلاغ قيد المراجعة
      ProviderAppointment(
        id: 'a11',
        patientId: 'p11',
        patientName: 'سامي عمر',
        gender: 'ذكر',
        age: 71,
        service: 'الرعاية التمريضية · الحقن',
        startsAt: at(-2, 16),
        durationMinutes: _injections,
        place: 'غزة، الزيتون',
        address: 'شارع صلاح الدين، عمارة 10',
        phone: '+970 59 000 0012',
        status: ProviderApptStatus.disputed,
        disputeReason: 'لم يحضر مقدم الرعاية',
        report: const VisitReport(
          summary: 'تم إعطاء الحقنة في موعدها وقياس السكر.',
          procedures: ['حقن عضلي', 'قياس السكر'],
          sugar: '135',
          writtenAt: 'قبل يومين',
        ),
      ),
      // ── ملغاة
      ProviderAppointment(
        id: 'a7',
        patientId: 'p7',
        patientName: 'سمير ياسر',
        gender: 'ذكر',
        age: 52,
        service: 'الرعاية التمريضية · الحقن',
        startsAt: at(0, 14),
        durationMinutes: _injections,
        place: 'غزة، الرمال',
        address: 'شارع الجلاء، عمارة 5',
        phone: '+970 59 000 0008',
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
        startsAt: at(-1, 16),
        durationMinutes: _physio,
        place: 'غزة، تل الهوى',
        address: 'شارع الوحدة، عمارة 8',
        phone: '+970 59 000 0009',
        status: ProviderApptStatus.canceledByPatient,
      ),
      ProviderAppointment(
        id: 'a9',
        patientId: 'p9',
        patientName: 'يوسف عادل',
        gender: 'ذكر',
        age: 60,
        service: 'الرعاية التمريضية · قياس السكر',
        startsAt: at(-5, 12),
        durationMinutes: _sugar,
        place: 'غزة، الرمال',
        address: 'شارع الثورة، عمارة 1',
        phone: '+970 59 000 0010',
        status: ProviderApptStatus.expired,
      ),
    ];
  }

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
    // 🔥 لاحقاً: رفع التقرير وإرسال طلب تأكيد للمريض.
    // يؤكد المريض ← completed، أو يبلّغ ← disputed
    final a = byId(id);
    if (a == null) return;
    final updated = a.copyWith(
      status: ProviderApptStatus.awaitingPatientConfirmation,
      report: report,
    );
    // الأحدث أولاً
    appointments.value = [
      updated,
      ...appointments.value.where((x) => x.id != id),
    ];
  }
}
