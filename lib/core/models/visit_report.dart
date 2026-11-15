// lib/core/models/visit_report.dart

/// تقرير الزيارة: يكتبه مقدم الرعاية، ويقرؤه الطرفان
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
