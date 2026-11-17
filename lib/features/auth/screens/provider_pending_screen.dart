// lib/features/auth/screens/provider_pending_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/widgets/join_stepper.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

/// بعد إرسال طلب الانضمام: بانتظار مراجعة الإدارة
class ProviderPendingScreen extends StatelessWidget {
  const ProviderPendingScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showProviderDialog(
      context,
      title: 'هل تريدين تسجيل الخروج؟',
      message: 'يمكنك تسجيل الدخول مرة أخرى لمتابعة حالة طلبك.',
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
      danger: true,
    );
    if (ok != true || !context.mounted) return;
    // 🔥 Firebase/Supabase: FirebaseAuth.instance.signOut()
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      // الطلب مُرسل، فلا رجوع لمعالج الانضمام
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const JoinStepper(
                    labels: ['إرسال الطلب', 'مراجعة الإدارة', 'تفعيل الحساب'],
                    current: 2,
                  ),
                  const Spacer(),
                  const ProviderStatusMessage(
                    icon: Icons.schedule_outlined,
                    title: 'طلبك قيد المراجعة',
                    message:
                        'استلمنا بياناتك ومستنداتك، وتراجعها الإدارة الآن. يمكنك إغلاق التطبيق، وسنواصل معك لاحقًا فور انتهاء المراجعة وسيصلك إشعار بالنتيجة.',
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'تواصلي مع الدعم',
                    fontSize: 15,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary700,
                    borderColor: AppColors.border,
                    onPressed: () => Navigator.pushNamed(context, 'ProviderHelp'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _logout(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error700,
                    ),
                    child: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// أيقونة في دائرة + عنوان + نص، مشتركة بين شاشتي المراجعة والقبول
class ProviderStatusMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const ProviderStatusMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.primary50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: AppColors.primary500),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.7,
            color: AppColors.neutralDark,
          ),
        ),
      ],
    );
  }
}
