// lib/features/auth/services/delete_account_flow.dart
// خطوات حذف الحساب كاملة: حذف، وإن لزم رمز تحقق جديد، ثم الانتقال لشاشة الدخول
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/screens/verification_screen.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

Future<void> deleteAccountFlow(BuildContext context) async {
  var result = await AuthRoleRepository.deleteAccount();

  // دخول قديم: نطلب رمزًا جديدًا ثم نعيد المحاولة
  if (result == DeleteResult.needsRecentLogin) {
    if (!context.mounted) return;
    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    final sent = await AuthRoleRepository.sendCode(phone);
    if (!context.mounted) return;

    if (sent == null) {
      await showProviderDialog(
        context,
        title: 'تعذّر إرسال الرمز',
        message: 'تحقق من الاتصال بالإنترنت ثم حاول مرة أخرى.',
        confirmText: 'حسنًا',
      );
      return;
    }

    final ok = await Navigator.pushNamed(
      context,
      'Verification',
      arguments: VerificationArgs(
        phone,
        isReauth: true,
        verificationId: sent.verificationId,
        resendToken: sent.resendToken,
      ),
    );
    if (ok != true || !context.mounted) return;

    result = await AuthRoleRepository.deleteAccount();
  }

  if (!context.mounted) return;

  if (result != DeleteResult.ok) {
    await showProviderDialog(
      context,
      title: 'تعذّر حذف الحساب',
      message: 'حدثت مشكلة أثناء الحذف، حاول مرة أخرى لاحقًا.',
      confirmText: 'حسنًا',
    );
    return;
  }
  await showProviderDialog(
    context,
    title: 'تم حذف الحساب',
    message: 'تم حذف حسابك بنجاح. شكرًا لوقتك معنا، ويسعدنا عودتك في أي وقت.',
    confirmText: 'حسنًا',
  );
  if (!context.mounted) return;

  Navigator.pushNamedAndRemoveUntil(context, 'Login', (route) => false);
}
