// lib/features/dev/role_switch_screen.dart
// شاشة مؤقتة للاختبار: تنقل بين تطبيق المريض وتطبيق المقدم
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';
// تأكدي من هذا المسار حسب مكان ملف provider_shell.dart عندك
import 'package:my_first_app/features/provider/screens/provider_shell.dart';

class RoleSwitchScreen extends StatelessWidget {
  const RoleSwitchScreen({super.key});

  /// ينفذ routeFor بآخر رقم تم التحقق منه
  Future<void> _enterByStatus(BuildContext context) async {
    final phone = AuthRoleRepository.lastPhone;
    if (phone == null) {
      await showProviderDialog(
        context,
        title: 'لا يوجد رقم',
        message: 'سجّلي الدخول برقمك أولًا من شاشة الدخول.',
        confirmText: 'حسنًا',
      );
      return;
    }
    final route = await AuthRoleRepository.routeFor(phone);
    if (!context.mounted) return;
    if (AuthRoleRepository.hasUnseenRejection) {
      await showRejectionDialog(context);
      if (!context.mounted) return;
    }
    Navigator.pushNamed(context, route);
  }

  /// ينفذ المحاكاة ثم يظهر حوار "تم"
  Future<void> _simulate(BuildContext context, VoidCallback action) async {
    action();
    await showProviderDialog(
      context,
      title: 'تم',
      message: 'تم تنفيذ المحاكاة.',
      confirmText: 'حسنًا',
    );
  }

  Widget _option({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: AppColors.primary600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                  const SizedBox(height: 4),
                
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralDark,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // تمرير لأن الخيارات صارت كثيرة
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'شفاء',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary800,
                ),
              ),
             
              const SizedBox(height: 32),
              _option(
                icon: Icons.person_outline_rounded,
                title: 'تطبيق المريض',
                onTap: () => Navigator.pushNamed(context, 'Home'),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.medical_services_outlined,
                title: 'تطبيق مقدم الرعاية',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProviderShell()),
                ),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.hourglass_top_rounded,
                title: 'معاينة: قيد المراجعة',
                onTap: () => Navigator.pushNamed(context, 'ProviderPending'),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.verified_outlined,
                title: 'معاينة: تم القبول',
                onTap: () => Navigator.pushNamed(context, 'ProviderApproved'),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.login_rounded,
                title: 'الدخول حسب حالة رقمي',
                onTap: () => _enterByStatus(context),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.check_circle_outline_rounded,
                title: 'محاكاة: قبول الطلب',
                onTap: () => _simulate(context, AuthRoleRepository.simulateApprove),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.cancel_outlined,
                title: 'محاكاة: رفض الطلب',
                onTap: () => _simulate(
                  context,
                  () => AuthRoleRepository.simulateReject(
                    'صورة الرخصة غير واضحة',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _option(
                icon: Icons.delete_outline_rounded,
                title: 'محاكاة: مسح الطلب',
                onTap: () => _simulate(context, AuthRoleRepository.simulateReset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}