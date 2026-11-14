// lib/features/patient/screens/medical_record_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/medical_record_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

class MedicalRecordScreen extends StatelessWidget {
  const MedicalRecordScreen({super.key});

  static const Widget _divider = Divider(
    height: 1,
    thickness: 1,
    color: AppColors.border,
  );

  // ───────────────────────── عناصر مشتركة ─────────────────────────
  Widget _sectionTitle(String text) {
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

  BoxDecoration _card({Color border = AppColors.border}) => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border),
  );

  /// يظهر بدل القسم إذا كان فارغاً
  Widget _empty(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
      ),
    );
  }

  Widget _iconTile(IconData icon, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: AppColors.primary600),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary800,
        ),
      ),
    );
  }

  // ───────────────────────── الأقسام ─────────────────────────
  Widget _statCard(IconData icon, String label, String? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: _card(),
        child: Column(
          children: [
            _iconTile(icon, size: 36),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDark,
              ),
            ),
            Text(
              value ?? '—',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicInfo(MedicalRecord r) {
    return Row(
      children: [
        _statCard(Icons.water_drop_outlined, 'فصيلة الدم', r.bloodType),
        const SizedBox(width: 8),
        _statCard(
          Icons.height_rounded,
          'الطول',
          r.heightCm == null ? null : '${r.heightCm} سم',
        ),
        const SizedBox(width: 8),
        _statCard(
          Icons.monitor_weight_outlined,
          'الوزن',
          r.weightKg == null ? null : '${r.weightKg} كغ',
        ),
      ],
    );
  }

  Widget _allergies(MedicalRecord r) {
    if (r.allergies.isEmpty) return _empty('لا توجد حساسية مسجلة.');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.error700,
              ),
              SizedBox(width: 8),
              Text(
                'مهم لسلامتك أثناء الزيارة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final a in r.allergies) _chip(a)],
          ),
        ],
      ),
    );
  }

  Widget _chronic(MedicalRecord r) {
    if (r.chronicDiseases.isEmpty) return _empty('لا توجد أمراض مزمنة مسجلة.');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final d in r.chronicDiseases) _chip(d)],
      ),
    );
  }

  Widget _medications(MedicalRecord r) {
    if (r.medications.isEmpty) return _empty('لا توجد أدوية مسجلة.');
    return Container(
      decoration: _card(),
      child: Column(
        children: [
          for (int i = 0; i < r.medications.length; i++) ...[
            if (i > 0) _divider,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _iconTile(Icons.medication_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.medications[i].title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutralDarkActive,
                          ),
                        ),
                        Text(
                          r.medications[i].schedule,
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _emergency(MedicalRecord r) {
    final c = r.emergencyContact;
    if (c == null) return _empty('لم تتم إضافة جهة اتصال للطوارئ.');
    final subtitle = c.relation.trim().isEmpty
        ? c.name
        : '${c.name} · ${c.relation}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        children: [
          _iconTile(Icons.contact_phone_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
                Text(
                  c.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ],
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
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.neutralDarkActive,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.neutralDarkActive,
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'السجل الطبي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: ValueListenableBuilder<MedicalRecord>(
          valueListenable: MedicalRecordRepository.current,
          builder: (context, record, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _sectionTitle('معلومات أساسية'),
                _basicInfo(record),
                const SizedBox(height: 24),
                _sectionTitle('الحساسية'),
                _allergies(record),
                const SizedBox(height: 24),
                _sectionTitle('الأمراض المزمنة'),
                _chronic(record),
                const SizedBox(height: 24),
                _sectionTitle('الأدوية الحالية'),
                _medications(record),
                const SizedBox(height: 24),
                _sectionTitle('جهة اتصال للطوارئ'),
                _emergency(record),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              fontSize: 15,
              icon: Icons.edit_outlined,
              text: 'تعديل السجل الطبي',
              onPressed: () =>
                  Navigator.pushNamed(context, 'EditMedicalRecord'),
            ),
          ),
        ),
      ),
    );
  }
}
