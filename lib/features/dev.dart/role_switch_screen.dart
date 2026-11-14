// lib/features/dev/role_switch_screen.dart
// شاشة مؤقتة للاختبار: تنقل بين تطبيق المريض وتطبيق المقدم
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
// تأكدي من هذا المسار حسب مكان ملف provider_shell.dart عندك
import 'package:my_first_app/features/provider/screens/provider_shell.dart';

class RoleSwitchScreen extends StatelessWidget {
  const RoleSwitchScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
            ],
          ),
        ),
      ),
    );
  }
}