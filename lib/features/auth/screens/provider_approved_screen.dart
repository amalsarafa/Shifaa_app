// lib/features/auth/screens/provider_approved_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/screens/provider_pending_screen.dart';
import 'package:my_first_app/features/auth/widgets/join_stepper.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

/// بعد موافقة الإدارة: الحساب مفعّل
class ProviderApprovedScreen extends StatelessWidget {
  const ProviderApprovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 16),
                  const JoinStepper(
                    labels: ['إرسال الطلب', 'مراجعة الإدارة', 'تفعيل الحساب'],
                    current: 4, // كل الخطوات منتهية
                  ),
                  const Spacer(),
                  const ProviderStatusMessage(
                    icon: Icons.check_rounded,
                    title: 'تم قبول طلبك',
                    message:
                        'مرحبًا بك في شفاء. حسابك مفعّل الآن ويمكنك البدء باستقبال طلبات المرضى.',
                  ),
                  const Spacer(),
                  AppButton(
                    text: 'ابدئي الآن',
                    fontSize: 15,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      'ProviderHome',
                      (r) => false,
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
