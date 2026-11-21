// lib/features/auth/services/auth_role_repository.dart
// تحديد دور المستخدم بعد التحقق من الرقم
// الدور وطلب الانضمام من Firestore
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ApplicationStatus { pending, approved, rejected }

/// نتيجة محاولة إرسال طلب الانضمام
enum SubmitResult { ok, patient, existing }

/// نتيجة حذف الحساب
enum DeleteResult { ok, needsRecentLogin, failed }

/// نتيجة إرسال رمز التحقق
class SentCode {
  final String verificationId;
  final int? resendToken;
  const SentCode(this.verificationId, this.resendToken);
}

/// طلب انضمام مقدم الرعاية
class ProviderApplication {
  final String phone;
  final String name;
  final ApplicationStatus status;
  final String? rejectionReason;
  final bool welcomeSeen;

  const ProviderApplication({
    required this.phone,
    required this.name,
    this.status = ApplicationStatus.pending,
    this.rejectionReason,
    this.welcomeSeen = false,
  });

  ProviderApplication copyWith({
    ApplicationStatus? status,
    String? rejectionReason,
    bool? welcomeSeen,
  }) {
    return ProviderApplication(
      phone: phone,
      name: name,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      welcomeSeen: welcomeSeen ?? this.welcomeSeen,
    );
  }
}

class AuthRoleRepository {
  AuthRoleRepository._();

  /// الطلب الحالي (يتحدّث تلقائيًا من Firestore)
  static final ValueNotifier<ProviderApplication?> application =
      ValueNotifier(null);

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _appSub;

  /// يوحّد شكل الرقم: يشيل +970 والصفر من البداية
  static String normalize(String phone) {
    var p = phone.replaceAll(' ', '');
    if (p.startsWith('+970')) p = p.substring(4);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  static ProviderApplication? _appFor(String phone) {
    final app = application.value;
    if (app == null || app.phone != normalize(phone)) return null;
    return app;
  }

  // ───────────────────────── إرسال رمز التحقق ─────────────────────────
  /// يرسل الرمز عبر Firebase ويرجع verificationId، أو null إن فشل
  static Future<SentCode?> sendCode(String fullPhone) {
    final c = Completer<SentCode?>();
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        debugPrint('sendCode error: ${e.code}');
        if (!c.isCompleted) c.complete(null);
      },
      codeSent: (id, token) {
        if (!c.isCompleted) c.complete(SentCode(id, token));
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return c.future;
  }

  // ───────────────────────── طلب الانضمام (Firestore) ─────────────────────────
  static ProviderApplication? _fromDoc(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data();
    if (!s.exists || d == null) return null;
    return ProviderApplication(
      phone: normalize((d['phone'] as String?) ?? ''),
      name: (d['name'] as String?) ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      rejectionReason: d['rejectionReason'] as String?,
      welcomeSeen: d['welcomeSeen'] == true,
    );
  }

  /// يقرأ طلب المستخدم ويبقى يستمع لتغيّر حالته
  static Future<void> _loadApplication(String uid) async {
    final ref = FirebaseFirestore.instance.collection('joinRequests').doc(uid);
    application.value = _fromDoc(await ref.get());
    await _appSub?.cancel();
    _appSub = ref.snapshots().listen(
      (s) => application.value = _fromDoc(s),
      onError: (e) => debugPrint('joinRequests listen error: $e'),
    );
  }

  /// عند تسجيل الخروج
  static Future<void> clear() async {
    await _appSub?.cancel();
    _appSub = null;
    application.value = null;
  }
    /// تسجيل الخروج الكامل: يوقف الاستماع ثم يخرج من Firebase
  static Future<void> signOut() async {
    await clear();
    await FirebaseAuth.instance.signOut();
  }

  /// يحذف بيانات المستخدم من Firestore ثم حسابه من Firebase Auth
  /// 🔥 لاحقًا: حذف العناوين والسجل الطبي، وإبقاء الاسم الأول والخدمة
  /// والتاريخ والتقرير في الحجوزات السابقة
  static Future<DeleteResult> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return DeleteResult.failed;

    try {
      await user.reload();
    } catch (_) {}

    // Firebase يشترط دخولًا حديثًا لحذف الحساب
    final last = FirebaseAuth.instance.currentUser?.metadata.lastSignInTime;
    if (last == null || DateTime.now().difference(last).inMinutes >= 4) {
      return DeleteResult.needsRecentLogin;
    }

    final db = FirebaseFirestore.instance;
    try {
      await clear();
      final batch = db.batch();
      batch.delete(db.collection('users').doc(user.uid));
      batch.delete(db.collection('joinRequests').doc(user.uid));
      await batch.commit();
      await user.delete();
      return DeleteResult.ok;
    } on FirebaseAuthException catch (e) {
      debugPrint('deleteAccount auth error: ${e.code}');
      return e.code == 'requires-recent-login'
          ? DeleteResult.needsRecentLogin
          : DeleteResult.failed;
    } catch (e) {
      debugPrint('deleteAccount error: $e');
      return DeleteResult.failed;
    }
  }

  /// ينشئ طلبًا بحالة pending (بعد التحقق من الرقم)
  static Future<SubmitResult> submitApplication({
    required String phone,
    required String name,
    Map<String, dynamic> extra = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('no signed-in user');

    final db = FirebaseFirestore.instance;

    // الرقم مسجّل كمريض ← ممنوع
    final userSnap = await db.collection('users').doc(user.uid).get();
    if (userSnap.exists) return SubmitResult.patient;

    // لديه طلب سابق ← لا نكتب فوقه
    final reqRef = db.collection('joinRequests').doc(user.uid);
    if ((await reqRef.get()).exists) {
      await _loadApplication(user.uid);
      return SubmitResult.existing;
    }

    await reqRef.set({
      ...extra,
      'name': name,
      'phone': user.phoneNumber ?? '+970${normalize(phone)}',
      'status': 'pending',
      'welcomeSeen': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _loadApplication(user.uid);
    return SubmitResult.ok;
  }

  static Future<void> _setFlag(String key) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('joinRequests')
          .doc(uid)
          .update({key: true});
    } catch (e) {
      debugPrint('setFlag($key) error: $e');
    }
  }

  static void markWelcomeSeen() {
    final app = application.value;
    if (app == null) return;
    application.value = app.copyWith(welcomeSeen: true);
    _setFlag('welcomeSeen');
  }

  // ───────────────────────── تحديد الشاشة بعد الدخول ─────────────────────────
  /// الترتيب: 1) طلب الانضمام  2) مستند المستخدم  3) إنشاء مريض جديد
  static Future<String> routeFor(String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    // أي خطأ (مثل انقطاع الإنترنت) يُرمى للمستدعي ليعرض شاشة "لا يوجد اتصال"
    if (user != null) {
      // 1) طلب الانضمام
      await _loadApplication(user.uid);
      final app = application.value;
      if (app != null) {
        switch (app.status) {
          case ApplicationStatus.pending:
            return 'ProviderPending';
          case ApplicationStatus.approved:
            return app.welcomeSeen ? 'ProviderHome' : 'ProviderApproved';
          case ApplicationStatus.rejected:
            return 'ProviderRejected'; // بدون إنشاء مستند users
        }
      }

      // 2) مستند المستخدم
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snap = await ref.get();

      // 3) جديد ← مريض
      if (!snap.exists) {
        await ref.set({
          'phone': user.phoneNumber ?? phone,
          'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return 'Home';
      }

      if (snap.data()?['role'] == 'provider') return 'ProviderHome';
      return 'Home';
    }

    // احتياطي (بدون مستخدم مسجّل)
    final app = _appFor(phone);
    if (app == null) return 'Home';
    switch (app.status) {
      case ApplicationStatus.pending:
        return 'ProviderPending';
      case ApplicationStatus.approved:
        return app.welcomeSeen ? 'ProviderHome' : 'ProviderApproved';
      case ApplicationStatus.rejected:
        return 'ProviderRejected';
    }
  }
}
