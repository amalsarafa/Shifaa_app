// lib/features/provider/screens/provider_patients_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/services/provider_patients_model.dart';

class ProviderPatientsScreen extends StatefulWidget {
  const ProviderPatientsScreen({super.key});

  @override
  State<ProviderPatientsScreen> createState() => _ProviderPatientsScreenState();
}

class _ProviderPatientsScreenState extends State<ProviderPatientsScreen> {
  static const Color _border = AppColors.border;

  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _searchBox() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.neutralDark),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutralDarkActive,
              ),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم المريض',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.neutralDark),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'آخر المرضى',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        Text(
          'الأحدث زيارة أولاً',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary600),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary800,
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, ProviderPatient p) {
    final n = p.name.trim();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        'ProviderPatientProfile',
        arguments: p.id,
      ),
      child: Container(
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
                    color: AppColors.primary100,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                const Text(
                  'عرض الملف',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary700,
                  ),
                ),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: AppColors.neutralDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: _border),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metaItem(
                  Icons.calendar_today_outlined,
                  'آخر زيارة: ${p.lastVisit}',
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _metaItem(Icons.location_on_outlined, p.place),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${p.visits.length} زيارات',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 28,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.neutralDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ValueListenableBuilder<List<ProviderAppointment>>(
            valueListenable: ProviderAppointmentRepository.appointments,
            builder: (context, all, _) {
              final patients = ProviderPatientsRepository.fromAppointments(all);
              final shown = _query.isEmpty
                  ? patients
                  : patients.where((p) => p.name.contains(_query)).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  const Center(
                    child: Text(
                      'المرضى',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _searchBox(),
                  const SizedBox(height: 16),
                  _title(),
                  const SizedBox(height: 8),
                  if (patients.isEmpty)
                    _empty('لا يوجد مرضى بعد.\nيظهر المريض هنا بعد إنهاء أول زيارة له.')
                  else if (shown.isEmpty)
                    _empty('لا نتائج مطابقة للبحث.')
                  else
                    for (final p in shown) ...[
                      _card(context, p),
                      const SizedBox(height: 16),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}