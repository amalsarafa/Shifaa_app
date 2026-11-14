// lib/features/patient/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/patient/widgets/patient_avatar.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  static const Color _border = AppColors.border;
  static const Widget _divider = Divider(
    height: 1,
    thickness: 1,
    color: _border,
  );

  Widget _infoRow({
    required IconData icon,
    required String label,
    String? value,
    bool ltr = false,
  }) {
    final empty = value == null || value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary600),
          ),
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
                Text(
                  empty ? 'غير محدد' : value!,
                  textDirection: (ltr && !empty) ? TextDirection.ltr : null,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: empty ? FontWeight.normal : FontWeight.w600,
                    color: empty
                        ? AppColors.neutralDark
                        : AppColors.neutralDarkActive,
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
            'معلوماتي الشخصية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: ValueListenableBuilder<Patient>(
          valueListenable: PatientRepository.current,
          builder: (context, patient, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Center(
                  child: PatientAvatar(
                    name: patient.name,
                    photo: patient.photo,
                    size: 96,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  patient.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary800,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'الاسم الكامل',
                        value: patient.name,
                      ),
                      _divider,
                      _infoRow(
                        icon: Icons.phone_outlined,
                        label: 'رقم الهاتف',
                        value: patient.phone,
                        ltr: true,
                      ),
                      _divider,
                      _infoRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'البريد الإلكتروني',
                        value: patient.email,
                        ltr: true,
                      ),
                      _divider,
                      _infoRow(
                        icon: Icons.wc_rounded,
                        label: 'الجنس',
                        value: patient.gender,
                      ),
                      _divider,
                      _infoRow(
                        icon: Icons.cake_outlined,
                        label: 'تاريخ الميلاد',
                        value: patient.birthDateText,
                      ),
                    ],
                  ),
                ),
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
              text: 'تعديل المعلومات',
              onPressed: () => Navigator.pushNamed(context, 'EditPersonalInfo'),
            ),
          ),
        ),
      ),
    );
  }
}
