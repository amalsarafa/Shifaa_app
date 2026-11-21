// lib/features/provider/screens/provider_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/routes/app_routes.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/patient/widgets/patient_avatar.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

class ProviderMyProfileScreen extends StatelessWidget {
  const ProviderMyProfileScreen({super.key});

  static const Color _border = AppColors.border;

  // بيانات وهمية 🔥 لاحقاً: من ملف مقدّم الرعاية في Firebase
  static const String _name = ProviderAppointmentRepository.providerName;
  static const String _role = ProviderAppointmentRepository.providerRole;
  static const String? _photo = null;

  // بيانات وهمية 🔥 لاحقاً: من Firebase (نفس أرقام شاشة التقييمات)
  static const String _rating = '4.9';
  static const int _ratingCount = 148;
  static const int _patientsCount = 12;
  static const int _visitsCount = 31;

  static const List<_ReviewPreview> _reviews = [
    _ReviewPreview(
      'س',
      'سارة م.',
      'قبل يومين',
      'كانت الممرضة لطيفة ومحترفة جداً مع والدتي بعد العملية. التزمت بالموعد وكانت مطمئنة ودقيقة.',
    ),
    _ReviewPreview(
      'أ',
      'أحمد ك.',
      'قبل أسبوع',
      'خدمة ممتازة، شرحت لي كل خطوة وكانت سريعة ومرتبة.',
    ),
  ];

  // ───────────────────────── مساعدات ─────────────────────────
  /// يفتح الشاشة إن كانت موجودة، وإلا يظهر حوار "قريباً"
  void _open(BuildContext context, String route) {
    if (AppRoutes.routes.containsKey(route)) {
      Navigator.pushNamed(context, route);
      return;
    }
    showProviderDialog(
      context,
      title: 'قريباً',
      message: 'هذه الشاشة قيد التجهيز.',
      confirmText: 'حسناً',
    );
  }

  // ───────────────────────── بطاقة الحساب ─────────────────────────
  Widget _profileCard(BuildContext context) {
    return Container(
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
              const PatientAvatar(name: _name, photo: _photo, size: 64),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary800,
                      ),
                    ),
                    Text(
                      _role,
                      style: TextStyle(
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
                  onPressed: () => _open(context, 'ProviderPersonalInfo'),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primary700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: _border),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(_rating, '$_ratingCount تقييم', star: true),
              _statDivider(),
              _stat('$_patientsCount', 'مريض'),
              _statDivider(),
              _stat('$_visitsCount', 'زيارة مكتملة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 32, color: _border);

  Widget _stat(String value, String label, {bool star = false}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              if (star) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.star,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDark,
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

  // ───────────────────────── تقييمات المرضى ─────────────────────────
  Widget _reviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تقييمات المرضى',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDarkActive,
          ),
        ),
        const SizedBox(height: 8),
        for (final r in _reviews) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        r.initial,
                        style: const TextStyle(
                          fontSize: 16,
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
                            r.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutralDarkActive,
                            ),
                          ),
                          Text(
                            r.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutralDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '5.0',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.star,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.8,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        AppButton(
          height: 44,
          fontSize: 13,
          text: 'عرض كل التقييمات',
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary800,
          borderColor: _border,
          onPressed: () => _open(context, 'ProviderReviews'),
        ),
      ],
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
                        text: 'تسجيل الخروج',
                        backgroundColor: AppColors.error700,
                        foregroundColor: AppColors.white,
                        onPressed: () => Navigator.pop(dialogContext, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: 'إلغاء',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.neutralDarkActive,
                        borderColor: AppColors.border,
                        onPressed: () => Navigator.pop(dialogContext, false),
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
    await AuthRoleRepository.signOut();
    if (!context.mounted) return;    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
  }

  // ───────────────────────── البناء ─────────────────────────
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
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _profileCard(context),
            const SizedBox(height: 24),
            _menuCard([
              _row(
                icon: Icons.person_outline_rounded,
                label: 'معلوماتي الشخصية',
                onTap: () => _open(context, 'ProviderPersonalInfo'),
              ),
              _row(
                icon: Icons.workspace_premium_outlined,
                label: 'المؤهلات والخبرة',
                onTap: () => _open(context, 'ProviderQualifications'),
              ),
              _row(
                icon: Icons.medical_services_outlined,
                label: 'الخدمات التي أقدمها',
                onTap: () => _open(context, 'ProviderServices'),
              ),
              _row(
                icon: Icons.schedule_rounded,
                label: 'أوقات العمل ومناطق الخدمة',
                onTap: () => _open(context, 'ProviderSchedule'),
              ),
              _row(
                icon: Icons.settings_outlined,
                label: 'الإعدادات',
                onTap: () => _open(context, 'ProviderSettings'),
              ),
              _row(
                icon: Icons.help_outline_rounded,
                label: 'الدعم والمساعدة',
                onTap: () => _open(context, 'ProviderHelp'),
              ),
            ]),
            const SizedBox(height: 24),
            _reviewsSection(context),
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
        ),
      ),
    );
  }
}

class _ReviewPreview {
  final String initial;
  final String name;
  final String time;
  final String text;
  const _ReviewPreview(this.initial, this.name, this.time, this.text);
}