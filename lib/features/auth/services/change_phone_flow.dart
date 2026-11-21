// lib/features/auth/services/change_phone_flow.dart
// خطوات تغيير رقم الهاتف: فحص الدور، إعادة تحقق إن لزم، رمز للرقم الجديد، ثم حفظه
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/screens/verification_screen.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

Future<void> _info(BuildContext context, String title, String message) {
  return showProviderDialog(
    context,
    title: title,
    message: message,
    confirmText: 'حسنًا',
  );
}

/// Firebase يشترط دخولًا حديثًا (نفس شرط deleteAccount)
bool _needsRecentLogin(User user) {
  final last = user.metadata.lastSignInTime;
  return last == null || DateTime.now().difference(last).inMinutes >= 4;
}

/// إعادة التحقق بالرقم الحالي، ترجع true عند النجاح
Future<bool> _reauth(BuildContext context) async {
  final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
  final sent = await AuthRoleRepository.sendCode(phone);
  if (!context.mounted) return false;
  if (sent == null) {
    await _info(
      context,
      'تعذّر إرسال الرمز',
      'تحقق من الاتصال بالإنترنت ثم حاول مرة أخرى.',
    );
    return false;
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
  return ok == true;
}

/// يغيّر رقم الهاتف، ويرجع true عند النجاح
Future<bool> changePhoneFlow(BuildContext context, String newPhoneDigits) async {
  // نفس تنسيق شاشة الدخول: نشيل الصفر الأول
  var digits = newPhoneDigits.trim();
  if (digits.startsWith('0')) digits = digits.substring(1);
  final newPhone = '+970$digits';

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  if (newPhone == user.phoneNumber) {
    await _info(context, 'تغيير الرقم', 'هذا هو رقمك الحالي');
    return false;
  }

  // المريض فقط يغيّر رقمه من التطبيق
  final String? role;
  try {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    role = snap.data()?['role'] as String?;
  } catch (e) {
    debugPrint('changePhone role error: $e');
    if (!context.mounted) return false;
    await _info(
      context,
      'لا يوجد اتصال بالإنترنت',
      'تحقق من الاتصال بالإنترنت ثم حاول مرة أخرى.',
    );
    return false;
  }
  if (!context.mounted) return false;
  if (role != 'patient') {
    await _info(context, 'تغيير الرقم', 'لتغيير رقمك تواصل مع الدعم.');
    return false;
  }

  // دخول قديم: نتحقق من الرقم الحالي أولًا
  if (_needsRecentLogin(user)) {
    if (!await _reauth(context)) return false;
    if (!context.mounted) return false;
  }

  // رمز للرقم الجديد، ومرة إضافية واحدة فقط إن طلب Firebase دخولًا حديثًا
  var verified = false;
  for (var attempt = 0; attempt < 2 && !verified; attempt++) {
    final sent = await AuthRoleRepository.sendCode(newPhone);
    if (!context.mounted) return false;
    if (sent == null) {
      await _info(
        context,
        'تعذّر إرسال الرمز',
        'تحقق من الرقم والاتصال بالإنترنت ثم حاول مرة أخرى.',
      );
      return false;
    }

    final result = await Navigator.pushNamed(
      context,
      'Verification',
      arguments: VerificationArgs(
        newPhone,
        isChangePhone: true,
        verificationId: sent.verificationId,
        resendToken: sent.resendToken,
      ),
    );
    if (!context.mounted) return false;

    if (result == true) {
      verified = true;
    } else if (result == kNeedsRecentLogin && attempt == 0) {
      if (!await _reauth(context)) return false;
      if (!context.mounted) return false;
    } else {
      return false;
    }
  }
  if (!verified) return false;

  // حفظ الرقم الجديد في Firestore
  try {
    await FirebaseAuth.instance.currentUser!.getIdToken(true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'phone': newPhone});
  } catch (e) {
    debugPrint('changePhone save error: $e');
    if (!context.mounted) return false;
    await _info(
      context,
      'تعذّر حفظ الرقم',
      'تغيّر رقم الدخول، لكن تعذّر حفظه في حسابك. حاول مرة أخرى لاحقًا.',
    );
    return false;
  }
  return true;
}
