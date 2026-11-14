// lib/features/provider/screens/provider_report_view_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';

/// عرض التقرير للقراءة فقط 🔥 لاحقاً: يُعاد استخدامه عند المريض
class ProviderReportViewScreen extends StatelessWidget {
  const ProviderReportViewScreen({super.key});

  static const Color _border = AppColors.border;

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _text(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          height: 1.8,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final a = ProviderAppointmentRepository.byId(id);
    final r = a?.report;

    if (a == null || r == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد تقرير')));
    }

    final vitals = <Widget>[
      if (r.bloodPressure.isNotEmpty) _mini('ضغط الدم', r.bloodPressure),
      if (r.sugar.isNotEmpty) _mini('السكر', '${r.sugar} mg/dL'),
      if (r.temperature.isNotEmpty) _mini('الحرارة', '${r.temperature} °م'),
      if (r.pulse.isNotEmpty) _mini('النبض', '${r.pulse} نبضة/د'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'رجوع',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                        size: 28,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تقرير الزيارة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    // من كتب التقرير
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ProviderAppointmentRepository.providerName[0],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ProviderAppointmentRepository
                                          .providerName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neutralDarkActive,
                                      ),
                                    ),
                                    Text(
                                      ProviderAppointmentRepository
                                          .providerRole,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.neutralDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'مكتمل',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, thickness: 1, color: _border),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  a.service,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${a.date} · ${a.time}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _title('ملخص الزيارة'),
                    _text(r.summary),
                    if (r.procedures.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _title('الإجراءات المنفذة'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in r.procedures)
                            Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (vitals.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _title('القياسات الحيوية'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final v in vitals)
                            SizedBox(
                              width:
                                  (MediaQuery.sizeOf(context).width - 32 - 8) / 2,
                              child: v,
                            ),
                        ],
                      ),
                    ],
                    if (r.recommendations.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _title('توصيات وملاحظات'),
                      _text(r.recommendations),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}