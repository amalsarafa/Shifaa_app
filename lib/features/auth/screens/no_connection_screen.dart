// lib/features/auth/screens/no_connection_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/screens/provider_pending_screen.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

/// تظهر عند فشل تحديد الوجهة بسبب الاتصال، وترجع true عند "إعادة المحاولة"
class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Spacer(),
                const ProviderStatusMessage(
                  icon: Icons.wifi_off_outlined,
                  title: 'لا يوجد اتصال بالإنترنت',
                  message: 'تحقق من الاتصال بالإنترنت ثم حاول مرة أخرى.',
                ),
                const Spacer(),
                AppButton(
                  text: 'إعادة المحاولة',
                  fontSize: 15,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
