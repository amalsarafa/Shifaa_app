// lib/features/provider/screens/provider_patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/services/provider_patients_model.dart';

class ProviderPatientProfileScreen extends StatelessWidget {
  const ProviderPatientProfileScreen({super.key});

  static const Color _border = AppColors.border;

  Widget _header(BuildContext context) {
    return SizedBox(
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
              'ملف المريض',
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
    );
  }

  BoxDecoration get _cardBox => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      );

  Widget _title(String text, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          if (sub != null)
            Text(
              sub,
              style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
            ),
        ],
      ),
    );
  }

  Widget _patientCard(ProviderPatient p) {
    final n = p.name.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox,
      child: Row(
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
              n.isEmpty ? '?' : n[0],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                Text(
                  '${p.gender} · ${p.age} سنة',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: _cardBox,
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
      ),
    );
  }

  Widget _iconTile(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: AppColors.primary600),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool last = false,
    bool ltr = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          _iconTile(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    value,
                    textDirection: ltr ? TextDirection.ltr : null,
                    textAlign: ltr ? TextAlign.right : null,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitRow(
    BuildContext context,
    ProviderAppointment a, {
    bool last = false,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        'ProviderReportView',
        arguments: a.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            _iconTile(Icons.description_outlined),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${a.date} · ${a.time}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                  Text(
                    a.service,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.report?.summary ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: AppColors.neutralDark,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder<List<ProviderAppointment>>(
        valueListenable: ProviderAppointmentRepository.appointments,
        builder: (context, _, __) {
          final p = ProviderPatientsRepository.byId(id);

          if (p == null) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: Text('المريض غير موجود')),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        _patientCard(p),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _mini('عدد الزيارات', '${p.visits.length}'),
                            const SizedBox(width: 8),
                            _mini('آخر زيارة', p.lastVisit),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _title('معلومات التواصل'),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: _cardBox,
                          child: Column(
                            children: [
                              _infoRow(
                                Icons.phone_outlined,
                                'الجوال',
                                p.phone,
                                ltr: true,
                              ),
                              _infoRow(
                                Icons.location_on_outlined,
                                'العنوان',
                                '${p.place} · ${p.address}',
                              ),
                              _infoRow(
                                Icons.event_outlined,
                                'تاريخ الميلاد',
                                p.birthDate,
                                last: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _title('سجل الزيارات', sub: 'الأحدث أولاً'),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: _cardBox,
                          child: Column(
                            children: [
                              for (var i = 0; i < p.visits.length; i++)
                                _visitRow(
                                  context,
                                  p.visits[i],
                                  last: i == p.visits.length - 1,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}