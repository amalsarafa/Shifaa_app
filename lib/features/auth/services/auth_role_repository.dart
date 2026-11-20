// lib/features/auth/services/auth_role_repository.dart
// تحديد دور المستخدم بعد التحقق من الرقم (بيانات وهمية الآن)
// 🔥 Firebase: كل هذا سيُستبدل بقراءة وكتابة من Firestore
import 'package:flutter/material.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

/// مؤقت: يفتح شاشة اختيار التطبيق للتجربة
const bool kDevMode = true;

enum ApplicationStatus { pending, approved, rejected }

/// طلب انضمام مقدم الرعاية
class ProviderApplication {
  final String phone;
  final String name;
  final ApplicationStatus status;
  final String? rejectionReason;
  final bool welcomeSeen;
  final bool rejectionSeen;

  const ProviderApplication({
    required this.phone,
    required this.name,
    this.status = ApplicationStatus.pending,
    this.rejectionReason,
    this.welcomeSeen = false,
    this.rejectionSeen = false,
  });

  ProviderApplication copyWith({
    ApplicationStatus? status,
    String? rejectionReason,
    bool? welcomeSeen,
    bool? rejectionSeen,
  }) {
    return ProviderApplication(
      phone: phone,
      name: name,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      welcomeSeen: welcomeSeen ?? this.welcomeSeen,
      rejectionSeen: rejectionSeen ?? this.rejectionSeen,
    );
  }
}

class AuthRoleRepository {
  AuthRoleRepository._();

  /// الطلب الحالي 🔥 Firebase: من Firestore
  static final ValueNotifier<ProviderApplication?> application =
      ValueNotifier(null);

  /// أرقام المرضى الوهمية 🔥 Firebase: من Firestore
  static final Set<String> patientPhones = {'591111111'};

  /// آخر رقم تم التحقق منه (لشاشة التجربة)
  static String? lastPhone;

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

  /// true إن كان الرقم لمريض وليس لديه طلب
  static bool isPhoneUsedAsPatient(String phone) {
    return patientPhones.contains(normalize(phone)) && _appFor(phone) == null;
  }

  /// true إن كان لدى الرقم طلب قائم (قيد المراجعة أو مقبول)
  static bool hasActiveApplication(String phone) {
    final app = _appFor(phone);
    return app != null && app.status != ApplicationStatus.rejected;
  }

  /// ينشئ طلبًا بحالة pending 🔥 Firebase: حفظ في Firestore
  static Future<void> submitApplication({
    required String phone,
    required String name,
  }) async {
    application.value = ProviderApplication(phone: normalize(phone), name: name);
  }

  // ── محاكاة قرارات الأدمن (مؤقتة للتجربة)
  // 🔥 Firebase: الأدمن سيفعلها من لوحة الويب
  static void simulateApprove() {
    final app = application.value;
    if (app == null) return;
    application.value = app.copyWith(status: ApplicationStatus.approved);
  }

  static void simulateReject([String? reason]) {
    final app = application.value;
    if (app == null) return;
    application.value = app.copyWith(
      status: ApplicationStatus.rejected,
      rejectionReason: reason,
    );
  }

  static void simulateReset() => application.value = null;

  static void markWelcomeSeen() {
    final app = application.value;
    if (app == null) return;
    application.value = app.copyWith(welcomeSeen: true);
  }

  static void markRejectionSeen() {
    final app = application.value;
    if (app == null) return;
    application.value = app.copyWith(rejectionSeen: true);
  }

  static bool get hasUnseenRejection {
    final app = application.value;
    return app != null &&
        app.status == ApplicationStatus.rejected &&
        !app.rejectionSeen;
  }

  /// 🔥 لاحقًا تُقرأ الحالة من Firestore بعد نجاح الرمز.
  static Future<String> routeFor(String phone) async {
    final app = _appFor(phone);
    if (app == null) return 'Home';
    switch (app.status) {
      case ApplicationStatus.pending:
        return 'ProviderPending';
      case ApplicationStatus.approved:
        return app.welcomeSeen ? 'ProviderHome' : 'ProviderApproved';
      case ApplicationStatus.rejected:
        // المرفوض يُعامل كمريض، والطلب يبقى محفوظًا
        return 'Home';
    }
  }
}

/// حوار الرفض المشترك، وعند الإغلاق يُعلَّم أنه شوهد
Future<void> showRejectionDialog(BuildContext context) async {
  final reason = AuthRoleRepository.application.value?.rejectionReason;
  final reasonLine =
      (reason != null && reason.isNotEmpty) ? 'السبب: $reason\n' : '';
  await showProviderDialog(
    context,
    title: 'لم يتم قبول طلب انضمامك',
    message:
        '$reasonLineيمكنك الآن استخدام التطبيق كمريضة، أو التواصل مع الدعم.',
    confirmText: 'فهمت',
  );
  AuthRoleRepository.markRejectionSeen();
}
