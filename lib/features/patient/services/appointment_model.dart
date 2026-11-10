import 'package:my_first_app/features/patient/services/address_model.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';

enum AppointmentStatus { pending, confirmed, completed, canceled, rejected }

class Appointment {
  final String id;
  final CareProvider provider;
  final ServiceItem service;
  final String categoryTitle;
  final DateTime date;
  final String time; // "HH:mm"
  final Address address;
  final String notes;
  final AppointmentStatus status;
  final double? rating;
  final String? comment;

  const Appointment({
    required this.id,
    required this.provider,
    required this.service,
    required this.categoryTitle,
    required this.date,
    required this.time,
    required this.address,
    this.notes = '',
    required this.status,
    this.rating,
    this.comment,
  });

  /// التاريخ مع الوقت، نستخدمه للترتيب
  DateTime get startsAt {
    final h = int.parse(time.substring(0, 2));
    final m = int.parse(time.substring(3));
    return DateTime(date.year, date.month, date.day, h, m);
  }

  Appointment copyWith({
    AppointmentStatus? status,
    double? rating,
    String? comment,
  }) {
    return Appointment(
      id: id,
      provider: provider,
      service: service,
      categoryTitle: categoryTitle,
      date: date,
      time: time,
      address: address,
      notes: notes,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
    );
  }
}