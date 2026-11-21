// lib/features/auth/screens/provider_rejected_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/screens/provider_pending_screen.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/auth/widgets/join_stepper.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

/// بعد رفض الإدارة لطلب الانضمام: السبب + التواصل مع الدعم
class ProviderRejectedScreen extends StatefulWidget {
  const ProviderRejectedScreen({super.key});

  @override
  State<ProviderRejectedScreen> createState() => _ProviderRejectedScreenState();
}

class _ProviderRejectedScreenState extends State<ProviderRejectedScreen> {
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
    final app = AuthRoleRepository.application.value;

    // الأدمن قبل الطلب
    if (app?.status == ApplicationStatus.approved) {
      _handled = true;
      Navigator.pushNamedAndRemoveUntil(context, 'ProviderApproved', (r) => false);
      return;
    }

    // الطلب انحذف ← خروج
    if (app == null) {
      _handled = true;
      await AuthRoleRepository.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, 'Login', (r) => false);
      return;
    }

    // تغيّر السبب مثلًا ← نحدّث العرض
    setState(() {});
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
    _handled = true; // signOut يمسح الطلب، فما نريد انتقال المستمع
    await AuthRoleRepository.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'Login', (r) => false);
  }

  Widget _reasonCard(String reason) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شريط على جهة البداية (يمين في RTL)
            Container(width: 4, color: AppColors.error700),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: AppColors.error700,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'سبب الرفض',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.7,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reason =
        AuthRoleRepository.application.value?.rejectionReason?.trim() ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
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
                  // الوسط يتمرر إذا كان السبب طويلًا
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.error50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                size: 40,
                                color: AppColors.error700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لم نتمكن من قبول طلبك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'راجعت الإدارة طلبك ولم نتمكن من قبوله حاليًا. للاستفسار أو لتصحيح بيانات الطلب، تواصل مع الدعم.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.7,
                                color: AppColors.neutralDark,
                              ),
                            ),
                            if (reason.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _reasonCard(reason),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppButton(
                    text: 'تواصل مع الدعم',
                    fontSize: 15,
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
