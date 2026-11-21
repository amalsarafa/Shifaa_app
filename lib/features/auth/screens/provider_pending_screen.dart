// lib/features/auth/screens/provider_pending_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/auth/widgets/join_stepper.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

/// عنوان الشاشة في الوسط بدون سهم رجوع (مشترك مع شاشة القبول)
class ProviderStatusHeader extends StatelessWidget {
  const ProviderStatusHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 56,
      child: Center(
        child: Text(
          'حالة الطلب',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDarkActive,
          ),
        ),
      ),
    );
  }
}

/// بعد إرسال طلب الانضمام: بانتظار مراجعة الإدارة
class ProviderPendingScreen extends StatefulWidget {
  const ProviderPendingScreen({super.key});

  @override
  State<ProviderPendingScreen> createState() => _ProviderPendingScreenState();
}

class _ProviderPendingScreenState extends State<ProviderPendingScreen> {
  bool _handled = false; // حتى لا ننتقل مرتين

  @override
  void initState() {
    super.initState();
    // الاستماع لتغيّر حالة الطلب في Firestore
    AuthRoleRepository.application.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    AuthRoleRepository.application.removeListener(_onStatusChanged);
    super.dispose();
  }

  Future<void> _onStatusChanged() async {
    if (_handled || !mounted) return;
    final status = AuthRoleRepository.application.value?.status;
    if (status == ApplicationStatus.approved) {
      _handled = true;
      Navigator.pushReplacementNamed(context, 'ProviderApproved');
    } else if (status == ApplicationStatus.rejected) {
      _handled = true;
      Navigator.pushNamedAndRemoveUntil(context, 'ProviderRejected', (r) => false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showProviderDialog(
      context,
      title: 'هل تريد تسجيل الخروج؟',
      message: 'يمكنك تسجيل الدخول مرة أخرى لمتابعة حالة طلبك.',
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
      danger: true,
    );
    if (ok != true || !context.mounted) return;
    await AuthRoleRepository.signOut();
    if (!context.mounted) return;
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
                  const ProviderStatusHeader(),
                  const SizedBox(height: 8),
                  const JoinStepper(
                    labels: ['إرسال الطلب', 'مراجعة الإدارة', 'تفعيل الحساب'],
                    current: 2,
                  ),
                  const Spacer(),
                  const ProviderStatusMessage(
                    icon: Icons.schedule_outlined,
                    title: 'طلبك قيد المراجعة',
                    message:
                        'استلمنا بياناتك، وتراجعها الإدارة الآن. ستظهر النتيجة هنا فور صدورها.',
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'تواصل مع الدعم',
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
