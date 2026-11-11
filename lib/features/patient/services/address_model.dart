// lib/features/patient/services/address_model.dart

class Address {
  final String id; // لاحقاً: رقم العنوان في قاعدة البيانات
  final String title; // المنطقة: مدينة غزة، حي الرمال
  final String details; // الشارع، البناية، الطابق
  final String areaId; // لفلتر "في منطقتي"
  final String? landmark; // أقرب معلم
  final String? notes; // ملاحظات للوصول
  final double? latitude; // تتعبأ لاحقاً من الخريطة
  final double? longitude;

  const Address({
    this.id = '',
    required this.title,
    required this.details,
    this.areaId = '',
    this.landmark,
    this.notes,
    this.latitude,
    this.longitude,
  });

  // ───── للتحويل من وإلى قاعدة البيانات ─────
  Map<String, dynamic> toMap() => {
        'title': title,
        'details': details,
        'areaId': areaId,
        'landmark': landmark,
        'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Address.fromMap(String id, Map<String, dynamic> map) {
    return Address(
      id: id,
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      areaId: map['areaId'] ?? '',
      landmark: map['landmark'],
      notes: map['notes'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}