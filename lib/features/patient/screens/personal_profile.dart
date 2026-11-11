// lib/features/patient/screens/personal_profile.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/routes/app_routes.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/patient/widgets/patient_avatar.dart';

class PersonalProfileScreen extends StatelessWidget {
  const PersonalProfileScreen({super.key});

  static const Color _border = AppColors.border;

  // ───────────────────────── مساعدات ─────────────────────────
  void _open(BuildContext context, String route) {
    if (AppRoutes.routes.containsKey(route)) {
      Navigator.pushNamed(context, route);
      return;
    }
    // مؤقت: تختفي هذه الرسالة عندما نضيف كل الصفحات
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('سنضيف هذه الصفحة في الخطوة القادمة')),
      );
  }

  // ───────────────────────── بطاقة المريض ─────────────────────────
  Widget _patientCard(BuildContext context, Patient patient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          PatientAvatar(
            name: patient.name,
            photo: patient.photo,
            size: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary800,
                  ),
                ),
                Text(
                  patient.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary50,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'تعديل الملف الشخصي',
              onPressed: () => _open(context, 'EditPersonalInfo'),
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── القائمة ─────────────────────────
  /// danger: true ← صف أحمر بدون سهم (لتسجيل الخروج)
  Widget _row({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: danger ? AppColors.error50 : AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: danger ? AppColors.error700 : AppColors.primary600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: danger
                        ? AppColors.error700
                        : AppColors.neutralDarkActive,
                  ),
                ),
              ),
              if (trailing != null) ...[trailing, const SizedBox(width: 8)],
              // chevron_right ينقلب تلقائياً في RTL فيشير لليسار
              if (!danger)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.neutralDark,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(List<Widget> rows) {
    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: _border),
            rows[i],
          ],
        ],
      ),
    );
  }

  // ───────────────────────── تسجيل الخروج ─────────────────────────
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.error50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 26,
                    color: AppColors.error700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هل تريد تسجيل الخروج؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هل أنت متأكد من تسجيل الخروج من الحساب.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                                        Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: 'تراجع',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.neutralDarkActive,
                        borderColor: AppColors.border,
                        onPressed: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: 'تسجيل الخروج',
                        backgroundColor: AppColors.error700,
                        foregroundColor: AppColors.white,
                        onPressed: () => Navigator.pop(dialogContext, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;
    // TODO: لاحقاً FirebaseAuth.instance.signOut() قبل الانتقال
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
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
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'حسابي الشخصي',
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _patientCard(context, patient),
                const SizedBox(height: 24),
                _menuCard([
                  _row(
                    icon: Icons.person_outline_rounded,
                    label: 'معلوماتي الشخصية',
                    onTap: () => _open(context, 'PersonalInfo'),
                  ),
                  _row(
                    icon: Icons.location_on_outlined,
                    label: 'العناوين المحفوظة',
                    onTap: () => _open(context, 'Addresses'),
                  ),
                  _row(
                    icon: Icons.medical_information_outlined,
                    label: 'السجل الطبي',
                    onTap: () => _open(context, 'MedicalRecord'),
                  ),
                  _row(
                    icon: Icons.history_rounded,
                    label: 'سجل الزيارات',
                    onTap: () => _open(context, 'VisitHistory'),
                  ),
                  _row(
                    icon: Icons.settings_outlined,
                    label: 'الإعدادات',
                    onTap: () => _open(context, 'Settings'),
                  ),
                  _row(
                    icon: Icons.help_outline_rounded,
                    label: 'الدعم والمساعدة',
                    onTap: () => _open(context, 'Help'),
                  ),
                ]),
                const SizedBox(height: 24),
                _menuCard([
                  _row(
                    icon: Icons.logout_rounded,
                    label: 'تسجيل الخروج',
                    danger: true,
                    onTap: () => _confirmLogout(context),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}