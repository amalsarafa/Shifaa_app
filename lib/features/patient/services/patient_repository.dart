// lib/features/patient/services/patient_repository.dart
import 'package:flutter/foundation.dart';
import 'package:my_first_app/features/patient/services/address_model.dart';

class Patient {
  final String name;
  final String phone;
  final String? email;
  final String? gender; // 'ذكر' أو 'أنثى'
  final DateTime? birthDate;
  final List<Address> addresses;
  final int defaultAddressIndex;

  const Patient({
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.birthDate,
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
}

/// بيانات المريض الحالي. حالياً وهمية، ولاحقاً تأتي من Firebase بعد تسجيل الدخول.
class PatientRepository {
  PatientRepository._();

  static final ValueNotifier<Patient> current = ValueNotifier<Patient>(
    Patient(
      name: 'عمر خالد',
      phone: '+970 59 123 4567',
      email: 'omar@example.com',
      gender: 'ذكر',
      birthDate: DateTime(1990, 3, 12),
      addresses: const [
        Address(
          title: 'مدينة غزة، حي الرمال',
          details: 'شارع عمر المختار، بناية 12، الطابق الثالث',
          areaId: 'rimal',
        ),
        Address(
          title: 'مدينة غزة، تل الهوا',
          details: 'شارع الجامعة، بناية 5، الطابق الأول',
          areaId: 'tal_alhawa',
        ),
      ],
    ),
  );
}