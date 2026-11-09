// lib/features/patient/services/address_model.dart

class Address {
  final String title; // مدينة غزة، حي الرمال
  final String details; // الشارع، البناية
  final String areaId; // لفلتر "في منطقتي" حالياً
  final double? latitude; // تتعبأ لاحقاً من الخريطة
  final double? longitude;

  const Address({
    required this.title,
    required this.details,
    required this.areaId,
    this.latitude,
    this.longitude,
  });
}