// lib/features/provider/screens/provider_report_view_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/screens/visit_report_view_screen.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';

/// غلاف لصفحة التقرير المشتركة: يقرأ الموعد بالـ id ويبني ReportViewArgs
class ProviderReportViewScreen extends StatelessWidget {
  const ProviderReportViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final a = ProviderAppointmentRepository.byId(id);

    if (a == null || a.report == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد تقرير')));
    }

    return VisitReportViewScreen(
      args: ReportViewArgs(
        report: a.report,
        providerName: ProviderAppointmentRepository.providerName,
        providerRole: ProviderAppointmentRepository.providerRole,
        service: a.service,
        date: a.date,
        time: a.time,
      ),
    );
  }
}
