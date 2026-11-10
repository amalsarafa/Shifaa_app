// lib/features/patient/services/appointment_repository.dart
import 'package:flutter/foundation.dart';
import 'package:my_first_app/features/patient/services/address_model.dart';
import 'package:my_first_app/features/patient/services/appointment_model.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';
import 'package:my_first_app/features/patient/services/services_data.dart';

/// بيانات تجريبية في الذاكرة. لاحقاً تُستبدل بـ Firestore.
class AppointmentRepository {
  AppointmentRepository._();

  static int _nextId = 100;

  static final ValueNotifier<List<Appointment>> appointments =
      ValueNotifier<List<Appointment>>(_mockData());

  static List<Appointment> _mockData() {
    const category = 'الرعاية التمريضية';
    const address = Address(
      title: 'مدينة غزة، حي الرمال',
      details: 'الشارع الرئيسي، بناية 12',
      areaId: 'rimal',
    );

    final injections = nursingServices[0];
    final wounds = nursingServices[1];
    final elderly = nursingServices[2];
    final sarah = injections.providers[0];
    final ali = injections.providers[1];
    final lina = injections.providers[2];

    final now = DateTime.now();
    DateTime day(int offset) =>
        DateTime(now.year, now.month, now.day + offset);

    return [
      Appointment(
        id: '1',
        provider: ali,
        service: injections,
        categoryTitle: category,
        date: day(0),
        time: '16:00',
        address: address,
        status: AppointmentStatus.confirmed,
      ),
      Appointment(
        id: '2',
        provider: lina,
        service: elderly,
        categoryTitle: category,
        date: day(5),
        time: '10:00',
        address: address,
        status: AppointmentStatus.pending,
      ),
      Appointment(
        id: '3',
        provider: sarah,
        service: wounds,
        categoryTitle: category,
        date: day(-7),
        time: '11:00',
        address: address,
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: '4',
        provider: ali,
        service: injections,
        categoryTitle: category,
        date: day(-15),
        time: '16:00',
        address: address,
        status: AppointmentStatus.completed,
        rating: 5.0,
      ),
      Appointment(
        id: '5',
        provider: lina,
        service: elderly,
        categoryTitle: category,
        date: day(-4),
        time: '10:00',
        address: address,
        status: AppointmentStatus.canceled,
      ),
      Appointment(
        id: '6',
        provider: sarah,
        service: injections,
        categoryTitle: category,
        date: day(-11),
        time: '17:00',
        address: address,
        status: AppointmentStatus.rejected,
      ),
    ];
  }

  /// طلب جديد من شاشة التأكيد، يبدأ بانتظار الموافقة
  static void add({
    required CareProvider provider,
    required ServiceItem service,
    required String categoryTitle,
    required DateTime date,
    required String time,
    required Address address,
    required String notes,
  }) {
    appointments.value = [
      ...appointments.value,
      Appointment(
        id: '${_nextId++}',
        provider: provider,
        service: service,
        categoryTitle: categoryTitle,
        date: date,
        time: time,
        address: address,
        notes: notes,
        status: AppointmentStatus.pending,
      ),
    ];
  }

  static void cancel(String id) {
    _update(id, (a) => a.copyWith(status: AppointmentStatus.canceled));
  }

  static void rate(String id, double rating, String comment) {
    _update(id, (a) => a.copyWith(rating: rating, comment: comment));
  }

  static void _update(String id, Appointment Function(Appointment) change) {
    appointments.value = [
      for (final a in appointments.value) a.id == id ? change(a) : a,
    ];
  }
}