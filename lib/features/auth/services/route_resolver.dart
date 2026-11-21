// lib/features/auth/services/route_resolver.dart
// يحدد الشاشة بعد الدخول، وعند فشل الاتصال يعرض شاشة "لا يوجد اتصال"
import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/screens/no_connection_screen.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';

/// يرجع اسم المسار، أو null إذا ألغى المستخدم (رجع من شاشة عدم الاتصال)
Future<String?> resolveRouteWithRetry(BuildContext context, String phone) async {
  while (true) {
    try {
      return await AuthRoleRepository.routeFor(phone);
    } catch (e) {
      debugPrint('resolveRoute error: $e');
      if (!context.mounted) return null;
      final retry = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const NoConnectionScreen()),
      );
      if (retry != true) return null;
    }
  }
}
