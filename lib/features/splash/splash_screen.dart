import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_app/features/auth/services/route_resolver.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _border = AppColors.primary50;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;

      // مستخدم مسجّل من قبل: ننتقل مباشرة لشاشته
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final route = await resolveRouteWithRetry(
          context,
          user.phoneNumber ?? '',
        );
        if (!mounted) return;
        // إلغاء من شاشة عدم الاتصال ← الدخول، والجلسة باقية لمحاولة لاحقة
        Navigator.pushReplacementNamed(context, route ?? 'Login');
        return;
      }

      Navigator.pushReplacementNamed(context, 'Onboarding');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        // ظهور تدريجي خفيف للشعار والنص
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.9 + 0.1 * value, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _border),
                ),
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 56,
                  height: 56,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'شفاء',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'خدمات الرعاية الصحية المنزلية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
