// lib/features/patient/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🔥 لاحقاً: تُقرأ وتُحفظ من Firebase / SharedPreferences
  bool _notificationsOn = true;

  static const String _appVersion = '1.0.0';

  // ───────────────────────── حذف الحساب ─────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: AppColors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                    Icons.delete_outline_rounded,
                    size: 28,
                    color: AppColors.error700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'هل أنت متأكد من حذف الحساب؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: 'حذف الحساب',
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

    if (confirmed != true || !mounted) return;

    // 🔥 لاحقاً: حذف الحساب وبياناته من Firebase قبل الخروج
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
  }

  // ───────────────────────── مكونات مساعدة ─────────────────────────
  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }

  Widget _divider() => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border,
      );

  Widget _row({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool danger = false,
  }) {
    final iconBg = danger ? AppColors.error50 : AppColors.primary50;
    final iconColor = danger ? AppColors.error700 : AppColors.primary600;
    final titleColor =
        danger ? AppColors.error700 : AppColors.neutralDarkActive;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }

  Widget get _chevron => const Icon(
        Icons.chevron_left_rounded,
        size: 20,
        color: AppColors.neutralDark,
      );

  // ───────────────────────── الشاشة ─────────────────────────
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
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: AppColors.neutralDarkActive,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _section(
              'الإشعارات',
              _row(
                icon: Icons.notifications_none_rounded,
                title: 'الإشعارات',
                subtitle: 'تحديثات الحجوزات والتذكير قبل الموعد',
                trailing: Switch(
                  value: _notificationsOn,
                  activeColor: AppColors.white,
                  activeTrackColor: AppColors.primary600,
                  onChanged: (v) => setState(() => _notificationsOn = v),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _section(
              'عن التطبيق',
              Column(
                children: [
                  _row(
                    icon: Icons.description_outlined,
                    title: 'الشروط والأحكام',
                    subtitle: 'قواعد استخدام التطبيق',
                    trailing: _chevron,
                    onTap: () => Navigator.pushNamed(context, 'Terms'),
                  ),
                  _divider(),
                  _row(
                    icon: Icons.lock_outline_rounded,
                    title: 'سياسة الخصوصية',
                    subtitle: 'كيف نحمي بياناتك الصحية',
                    trailing: _chevron,
                    onTap: () =>
                        Navigator.pushNamed(context, 'PrivacyPolicy'),
                  ),
                  _divider(),
                  _row(
                    icon: Icons.info_outline_rounded,
                    title: 'إصدار التطبيق',
                    subtitle: 'الإصدار $_appVersion',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _section(
              'الحساب',
              _row(
                icon: Icons.delete_outline_rounded,
                title: 'حذف الحساب',
                danger: true,
                onTap: _confirmDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}