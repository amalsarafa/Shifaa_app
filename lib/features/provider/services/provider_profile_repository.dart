// lib/features/provider/services/provider_profile_repository.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';

class ProviderServiceItem {
  final String name;
  final String duration;
  final int price;
  final IconData icon;
  bool enabled;

  ProviderServiceItem(
    this.name,
    this.duration,
    this.price,
    this.icon, {
    this.enabled = true,
  });
}

class ProviderWorkDay {
  final String day;
  bool enabled;
  TimeOfDay from;
  TimeOfDay to;

  ProviderWorkDay(this.day, this.from, this.to, {this.enabled = true});

  ProviderWorkDay copy() => ProviderWorkDay(day, from, to, enabled: enabled);
}

/// مثال: TimeOfDay(hour: 9, minute: 0) ← "9:00 ص"
String formatProviderTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.period == DayPeriod.am ? 'ص' : 'م'}';
}

/// تقييم مريض بعد زيارة مكتملة
class ProviderReview {
  final String name; // مختصر لحماية الخصوصية، مثل "سارة م."
  final String when;
  final String service;
  final int rating;
  final String comment;

  const ProviderReview({
    required this.name,
    required this.when,
    required this.service,
    required this.rating,
    required this.comment,
  });

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0];
}

/// بيانات وهمية حاليًا — تُستبدل ببيانات Firebase لاحقًا
class ProviderProfileRepository {
  ProviderProfileRepository._();

  // المعلومات الشخصية
  static String get name => ProviderAppointmentRepository.providerName;
  static const String phone = '+970 59 000 0099';
  static String email = 'sara@email.com';
  static String gender = 'أنثى';
  static DateTime birth = DateTime(1992, 6, 15);

  // المؤهلات والخبرة
  static String bio =
      'ممرضة مسجلة بخبرة في رعاية كبار السن والعناية بالجروح، أحرص على الالتزام بالموعد وشرح كل خطوة للمريض وأهله.';
  static const String specialty = 'التمريض';
  static int years = 5;
  static List<String> allSkills = [
    'حقن عضلي',
    'تغيير ضمادات',
    'رعاية كبار السن',
    'قياس السكر',
    'قياس الضغط',
  ];
  static Set<String> selectedSkills = {
    'حقن عضلي',
    'تغيير ضمادات',
    'رعاية كبار السن',
    'قياس السكر',
  };
  static List<String> certificates = ['شهادة الإنعاش القلبي'];

  // الخدمات
  static final List<ProviderServiceItem> services = [
    ProviderServiceItem('الحقن', '15-30 د', 25, Icons.vaccines_outlined),
    ProviderServiceItem('العناية بالجروح', '30-45 د', 40, Icons.healing_outlined),
    ProviderServiceItem('رعاية كبار السن', '30-45 د', 40, Icons.elderly_outlined),
  ];

  // أوقات العمل
  static final List<ProviderWorkDay> workDays = [
    ProviderWorkDay('السبت', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    ProviderWorkDay('الأحد', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    ProviderWorkDay('الاثنين', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    ProviderWorkDay('الثلاثاء', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 17, minute: 0)),
    ProviderWorkDay('الأربعاء', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 15, minute: 0)),
    ProviderWorkDay('الخميس', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 13, minute: 0)),
    ProviderWorkDay('الجمعة', const TimeOfDay(hour: 9, minute: 0), const TimeOfDay(hour: 17, minute: 0), enabled: false),
  ];

  // محافظة الخدمة (id من gazaGovernorates)
  static String governorateId = 'gaza';

  // التقييمات
  // عدد التقييمات لكل نجمة (5 ← 1). 🔥 لاحقاً: مجاميع محسوبة في Firebase
  static const Map<int, int> ratingCounts = {5: 135, 4: 10, 3: 2, 2: 1, 1: 0};

  static int get reviewsCount =>
      ratingCounts.values.fold(0, (sum, c) => sum + c);

  static double get averageRating {
    final total = reviewsCount;
    if (total == 0) return 0;
    final points = ratingCounts.entries.fold<int>(
      0,
      (sum, e) => sum + e.key * e.value,
    );
    return points / total;
  }

  /// آخر التقييمات (الأحدث أولاً)
  static const List<ProviderReview> reviews = [
    ProviderReview(
      name: 'سارة م.',
      when: 'قبل يومين',
      service: 'الحقن',
      rating: 5,
      comment:
          'كانت الممرضة لطيفة ومحترفة جدًا مع والدتي بعد العملية. التزمت بالموعد وكانت مطمئنة ودقيقة.',
    ),
    ProviderReview(
      name: 'أحمد ك.',
      when: 'قبل أسبوع',
      service: 'رعاية كبار السن',
      rating: 5,
      comment: 'خدمة ممتازة، شرحت لي كل خطوة وكانت سريعة ومرتبة.',
    ),
    ProviderReview(
      name: 'منى ي.',
      when: 'قبل أسبوعين',
      service: 'العناية بالجروح',
      rating: 5,
      comment: 'تعاملت مع الجرح بعناية كبيرة وأعطتنا تعليمات واضحة للمتابعة.',
    ),
    ProviderReview(
      name: 'خالد ع.',
      when: 'قبل 3 أسابيع',
      service: 'الحقن',
      rating: 4,
      comment: 'التزمت بالموعد والخدمة جيدة، تأخرت قليلًا في الوصول.',
    ),
    ProviderReview(
      name: 'ليلى ح.',
      when: 'قبل شهر',
      service: 'رعاية كبار السن',
      rating: 5,
      comment: 'صبورة جدًا مع جدي وتعاملت معه باحترام. أنصح بها.',
    ),
    ProviderReview(
      name: 'يوسف ن.',
      when: 'قبل شهرين',
      service: 'العناية بالجروح',
      rating: 5,
      comment: 'مهنية وهادئة، وتغيير الضماد كان بدون ألم يذكر.',
    ),
  ];
}