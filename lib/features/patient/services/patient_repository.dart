// lib/features/patient/services/patient_repository.dart
import 'package:flutter/foundation.dart';
import 'package:my_first_app/features/patient/services/address_model.dart';

class Patient {
  final String id; // لاحقاً: uid من Firebase Auth
  final String name;
  final String phone;
  final String? email;
  final String? gender; // 'ذكر' أو 'أنثى'
  final DateTime? birthDate;
  final String? photo; // حالياً مسار صورة من الجهاز، ولاحقاً رابط من Supabase
  final List<Address> addresses;
  final int defaultAddressIndex;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.birthDate,
    this.photo,
    required this.addresses,
    this.defaultAddressIndex = 0,
  });

  /// الاسم الأول للترحيب: "عمر خالد" ← "عمر"
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isEmpty ? '' : parts.first;
  }

  /// العنوان الافتراضي، ويظهر في الرئيسية والحجز
  Address get address => addresses[defaultAddressIndex];

  static const _months = <String>[
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// "12 مارس 1990"
  static String formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  String? get birthDateText =>
      birthDate == null ? null : formatDate(birthDate!);

  // ───── للتحويل من وإلى قاعدة البيانات ─────
  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        'gender': gender,
        'birthDate': birthDate?.toIso8601String(),
        'photo': photo,
        'defaultAddressIndex': defaultAddressIndex,
      };

  factory Patient.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<Address> addresses = const [],
  }) {
    return Patient(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      gender: map['gender'],
      birthDate: map['birthDate'] == null
          ? null
          : DateTime.tryParse(map['birthDate']),
      photo: map['photo'],
      addresses: addresses,
      defaultAddressIndex: map['defaultAddressIndex'] ?? 0,
    );
  }
}

/// بيانات المريض الحالي. حالياً وهمية، ولاحقاً تأتي من Firebase بعد تسجيل الدخول.
class PatientRepository {
  PatientRepository._();

  /// أقصى عدد للعناوين المحفوظة
  static const int maxAddresses = 2;

  static final ValueNotifier<Patient> current = ValueNotifier<Patient>(
    Patient(
      id: 'demo_patient',
      name: 'عمر خالد',
      phone: '+970 59 123 4567',
      email: 'omar@example.com',
      gender: 'ذكر',
      birthDate: DateTime(1990, 3, 12),
      addresses: const [
        Address(
          id: 'addr_1',
          title: 'مدينة غزة، حي الرمال',
          details: 'شارع عمر المختار، بناية 12، الطابق الثالث',
          areaId: 'rimal',
          landmark: 'مقابل صيدلية الشفاء',
        ),
        Address(
          id: 'addr_2',
          title: 'مدينة غزة، تل الهوا',
          details: 'شارع الجامعة، بناية 5، الطابق الأول',
          areaId: 'tal_alhawa',
          landmark: 'بجانب مسجد الهدى',
        ),
      ],
    ),
  );

  // ───────────────────────── المعلومات الشخصية ─────────────────────────
  static Future<void> updateInfo({
    required String name,
    String? email,
    String? gender,
    DateTime? birthDate,
  }) async {
    final p = current.value;
    // 🔥 لاحقاً: حفظ في قاعدة البيانات
    current.value = Patient(
      id: p.id,
      name: name,
      phone: p.phone,
      email: email,
      gender: gender,
      birthDate: birthDate,
      photo: p.photo,
      addresses: p.addresses,
      defaultAddressIndex: p.defaultAddressIndex,
    );
  }

  /// تغيير الصورة الشخصية (null = حذف الصورة)
  static Future<void> updatePhoto(String? path) async {
    final p = current.value;
    // 🔥 لاحقاً: رفع الصورة إلى Supabase Storage وحفظ رابطها
    current.value = Patient(
      id: p.id,
      name: p.name,
      phone: p.phone,
      email: p.email,
      gender: p.gender,
      birthDate: p.birthDate,
      photo: path,
      addresses: p.addresses,
      defaultAddressIndex: p.defaultAddressIndex,
    );
  }

  // ───────────────────────── العناوين ─────────────────────────
  static void _setAddresses(List<Address> addresses, int defaultIndex) {
    final p = current.value;
    current.value = Patient(
      id: p.id,
      name: p.name,
      phone: p.phone,
      email: p.email,
      gender: p.gender,
      birthDate: p.birthDate,
      photo: p.photo,
      addresses: List.unmodifiable(addresses),
      defaultAddressIndex: defaultIndex,
    );
  }

  static Future<void> addAddress(
    Address address, {
    bool makeDefault = false,
  }) async {
    final p = current.value;
    if (p.addresses.length >= maxAddresses) return;
    // 🔥 لاحقاً: حفظ العنوان في قاعدة البيانات
    final list = [...p.addresses, address];
    final isFirst = list.length == 1;
    _setAddresses(
      list,
      (makeDefault || isFirst) ? list.length - 1 : p.defaultAddressIndex,
    );
  }

  static Future<void> updateAddress(
    int index,
    Address address, {
    bool makeDefault = false,
  }) async {
    final p = current.value;
    // 🔥 لاحقاً: تحديث العنوان في قاعدة البيانات
    final list = [...p.addresses];
    list[index] = address;
    _setAddresses(list, makeDefault ? index : p.defaultAddressIndex);
  }

  static Future<void> deleteAddress(int index) async {
    final p = current.value;
    if (p.addresses.length <= 1) return; // لا نحذف العنوان الوحيد
    // 🔥 لاحقاً: حذف العنوان من قاعدة البيانات
    final list = [...p.addresses]..removeAt(index);
    var def = p.defaultAddressIndex;
    if (index == def) {
      def = 0;
    } else if (index < def) {
      def--;
    }
    _setAddresses(list, def);
  }

  static Future<void> setDefaultAddress(int index) async {
    // 🔥 لاحقاً: حفظ في قاعدة البيانات
    _setAddresses([...current.value.addresses], index);
  }
}