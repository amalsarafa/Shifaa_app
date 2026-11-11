// lib/features/patient/screens/personal_profile.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/routes/app_routes.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

class PersonalProfileScreen extends StatelessWidget {
  const PersonalProfileScreen({super.key});

  static const Color _border = Color(0xFFDDEBEB);

  // ───────────────────────── مساعدات ─────────────────────────
  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  /// يفتح الصفحة إذا كان مسارها موجوداً، وإلا يعرض رسالة مؤقتة
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
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary200, width: 2),
            ),
            child: Text(
              _initial(patient.name),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary700,
              ),
            ),
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
  Widget _row({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
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
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ),
              if (trailing != null) ...[trailing, const SizedBox(width: 8)],
              // chevron_left ثابت الاتجاه: يشير لليسار (اتجاه "التالي" في RTL)
              const Icon(
                Icons.chevron_left_rounded,
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

  Widget _countChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary800,
        ),
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
                  'يمكنك الدخول مرة أخرى في أي وقت برقم هاتفك.',
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
                        onPressed: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: 'تسجيل الخروج',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.error700,
                        borderColor: AppColors.error100,
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
            'حسابي',
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
                    label: 'عناويني',
                    trailing: _countChip(patient.addresses.length),
                    onTap: () => _open(context, 'Addresses'),
                  ),
                  _row(
                    icon: Icons.medical_information_outlined,
                    label: 'السجل الطبي',
                    onTap: () => _open(context, 'MedicalRecord'),
                  ),
                  _row(
                    icon: Icons.settings_outlined,
                    label: 'الإعدادات',
                    onTap: () => _open(context, 'Settings'),
                  ),
                  _row(
                    icon: Icons.help_outline_rounded,
                    label: 'المساعدة والتواصل',
                    onTap: () => _open(context, 'Help'),
                  ),
                ]),
                const SizedBox(height: 24),
                AppButton(
                  height: 52,
                  fontSize: 14,
                  icon: Icons.logout_rounded,
                  text: 'تسجيل الخروج',
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.error700,
                  borderColor: AppColors.error100,
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}