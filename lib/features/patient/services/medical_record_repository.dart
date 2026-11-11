// lib/features/patient/services/medical_record_repository.dart
import 'package:flutter/foundation.dart';

class Medication {
  final String name; // ميتفورمين
  final String dose; // 500 ملغ
  final String frequency; // مرتين يومياً
  final String? timing; // بعد الأكل (اختياري)

  const Medication({
    required this.name,
    required this.dose,
    required this.frequency,
    this.timing,
  });

  /// "ميتفورمين 500 ملغ"
  String get title => dose.trim().isEmpty ? name : '$name $dose';

  /// "مرتين يومياً بعد الأكل"
  String get schedule =>
      (timing == null || timing!.isEmpty) ? frequency : '$frequency $timing';

  Map<String, dynamic> toMap() => {
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'timing': timing,
      };

  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
        name: map['name'] ?? '',
        dose: map['dose'] ?? '',
        frequency: map['frequency'] ?? '',
        timing: map['timing'],
      );
}

class EmergencyContact {
  final String name;
  final String relation;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'relation': relation,
        'phone': phone,
      };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact(
        name: map['name'] ?? '',
        relation: map['relation'] ?? '',
        phone: map['phone'] ?? '',
      );
}

class MedicalRecord {
  final String? bloodType;
  final int? heightCm;
  final int? weightKg;
  final List<String> chronicDiseases;
  final List<String> allergies;
  final List<Medication> medications;
  final EmergencyContact? emergencyContact;

  const MedicalRecord({
    this.bloodType,
    this.heightCm,
    this.weightKg,
    this.chronicDiseases = const [],
    this.allergies = const [],
    this.medications = const [],
    this.emergencyContact,
  });

  Map<String, dynamic> toMap() => {
        'bloodType': bloodType,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'chronicDiseases': chronicDiseases,
        'allergies': allergies,
        'medications': medications.map((m) => m.toMap()).toList(),
        'emergencyContact': emergencyContact?.toMap(),
      };

  factory MedicalRecord.fromMap(Map<String, dynamic> map) => MedicalRecord(
        bloodType: map['bloodType'],
        heightCm: map['heightCm'],
        weightKg: map['weightKg'],
        chronicDiseases: List<String>.from(map['chronicDiseases'] ?? []),
        allergies: List<String>.from(map['allergies'] ?? []),
        medications: (map['medications'] as List? ?? [])
            .map((m) => Medication.fromMap(Map<String, dynamic>.from(m)))
            .toList(),
        emergencyContact: map['emergencyContact'] == null
            ? null
            : EmergencyContact.fromMap(
                Map<String, dynamic>.from(map['emergencyContact']),
              ),
      );
}

/// السجل الطبي للمريض الحالي. حالياً وهمي، ولاحقاً من قاعدة البيانات.
class MedicalRecordRepository {
  MedicalRecordRepository._();

  static final ValueNotifier<MedicalRecord> current =
      ValueNotifier<MedicalRecord>(
    const MedicalRecord(
      bloodType: 'O+',
      heightCm: 175,
      weightKg: 72,
      chronicDiseases: ['السكري', 'ضغط الدم'],
      allergies: ['البنسلين', 'المكسرات'],
      medications: [
        Medication(
          name: 'ميتفورمين',
          dose: '500 ملغ',
          frequency: 'مرتين يومياً',
          timing: 'بعد الأكل',
        ),
        Medication(
          name: 'أملوديبين',
          dose: '5 ملغ',
          frequency: 'مرة يومياً',
          timing: 'صباحاً',
        ),
      ],
      emergencyContact: EmergencyContact(
        name: 'سارة خالد',
        relation: 'الأخت',
        phone: '+970 59 765 4321',
      ),
    ),
  );

  static Future<void> save(MedicalRecord record) async {
    // 🔥 لاحقاً: حفظ في قاعدة البيانات
    // await FirebaseFirestore.instance
    //     .collection('patients').doc(patientId)
    //     .collection('private').doc('medical').set(record.toMap());
    current.value = record;
  }
}