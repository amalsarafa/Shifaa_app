import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/core/widgets/success_check.dart';
import 'package:my_first_app/features/auth/services/route_resolver.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

enum _VerifyState { idle, error, success }

/// ترجعها شاشة التحقق عند تغيير الرقم إذا طلب Firebase دخولًا حديثًا
const String kNeedsRecentLogin = 'requires-recent-login';

/// شو بنبعت لشاشة التحقق: الرقم + نوع العملية
class VerificationArgs {
  final String phone;
  final bool isChangePhone;
  final bool isProviderJoin; // طلب انضمام مقدم رعاية: يرجع true للمعالج
  final bool isReauth; // التحقق قبل حذف الحساب: يرجع true للمعالج
  final String? verificationId; // من Firebase بعد إرسال الرمز
  final int? resendToken; // لإعادة إرسال الرمز
  /// يُنفَّذ بعد نجاح التحقق والشاشة لسا ظاهرة (مثل حفظ طلب الانضمام)
  final Future<void> Function(BuildContext context)? onVerified;
  const VerificationArgs(
    this.phone, {
    this.isChangePhone = false,
    this.isProviderJoin = false,
    this.isReauth = false,
    this.verificationId,
    this.resendToken,
    this.onVerified,
  });
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _length = 6;
  static const int _resendSeconds = 45;

  static const String _shieldIcon = 'assets/icons/shield_check.svg';

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  _VerifyState _state = _VerifyState.idle;

  static const int _maxAttempts = 3;
  int _failedAttempts = 0; // عدد المحاولات الخاطئة

  bool _loading = false;
  String? _verificationId; // الجديد بعد إعادة الإرسال
  int? _resendToken;
  bool _networkError = false; // الخطأ سببه الاتصال وليس الرمز
  bool _busy = false; // أثناء تنفيذ onVerified (حفظ الطلب)

  @override
  void initState() {
    super.initState();
    _startTimer();
    // نفتح الكيبورد بعد ما تخلص حركة فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), _showKeyboard);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focus.dispose();
    super.dispose();
  }

  // يجبر الكيبورد على الظهور حتى لو كان الحقل مركّزًا أصلًا
  void _showKeyboard() {
    if (!mounted || _state == _VerifyState.success) return;
    _focus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  // تسجيل الدخول بيبعت String، وتغيير الرقم بيبعت VerificationArgs
  VerificationArgs get _args {
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is VerificationArgs) return a;
    return VerificationArgs((a as String?) ?? '');
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  String get _timeText {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isComplete => _codeController.text.length == _length;

  // الزر بيشتغل بس لما يكتمل الكود وما يكون في خطأ
  bool get _canConfirm =>
      _isComplete && _state == _VerifyState.idle && !_loading;

  /// الـ verificationId الحالي (الجديد بعد إعادة الإرسال أو اللي جاي من الدخول)
  String? get _currentVerificationId => _verificationId ?? _args.verificationId;

  Future<void> _resend() async {
    _codeController.clear();
    setState(() {
      _failedAttempts = 0;
      _networkError = false;
      _state = _VerifyState.idle;
    });
    _startTimer();
    _showKeyboard();

    // بدون verificationId (تغيير الرقم) ما في إرسال فعلي
    if (_currentVerificationId == null) return;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _args.phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken ?? _args.resendToken,
      verificationCompleted: (_) {},
      verificationFailed: (_) {
        if (!mounted) return;
        setState(() => _state = _VerifyState.error);
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _verify() async {
    if (!_isComplete) return;

    final verificationId = _currentVerificationId;
    if (verificationId != null) {
      // التحقق عبر Firebase
      setState(() => _loading = true);
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: _codeController.text,
        );
        if (_args.isChangePhone) {
          // تغيير الرقم: نربط الرقم الجديد بنفس الحساب
          await FirebaseAuth.instance.currentUser!.updatePhoneNumber(
            credential,
          );
        } else {
          await FirebaseAuth.instance.signInWithCredential(credential);
        }
        if (!mounted) return;
        _timer?.cancel();
        _focus.unfocus();
        setState(() {
          _state = _VerifyState.success;
          _loading = false;
        });
        return;
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        // انقطاع الإنترنت: رسالة اتصال، ولا تُحسب محاولة خاطئة
        if (e.code == 'network-request-failed') {
          setState(() {
            _loading = false;
            _networkError = true;
            _state = _VerifyState.error;
          });
          return;
        }
        setState(() => _loading = false);

        if (_args.isChangePhone) {
          // الرقم مربوط بحساب آخر
          if (e.code == 'credential-already-in-use' ||
              e.code == 'account-exists-with-different-credential') {
            await showProviderDialog(
              context,
              title: 'هذا الرقم مستخدم',
              message: 'هذا الرقم مسجّل لحساب آخر، جرّب رقمًا مختلفًا.',
              confirmText: 'حسنًا',
            );
            if (!mounted) return;
            Navigator.pop(context, false);
            return;
          }
          // دخول قديم: المنادي يعيد التحقق ثم يحاول مرة ثانية
          if (e.code == 'requires-recent-login') {
            Navigator.pop(context, kNeedsRecentLogin);
            return;
          }
        }
        // يكمل تحت كرمز خاطئ (خانات حمراء + عدّاد المحاولات)
      }
    }

    // رمز خاطئ: العدّاد يبقى شغال
    setState(() {
      _networkError = false;
      _failedAttempts++;
      _state = _VerifyState.error;
    });

    if (_failedAttempts >= _maxAttempts) {
      _timer?.cancel();
      _focus.unfocus();
      await showProviderDialog(
        context,
        title: 'تجاوزت عدد المحاولات',
        message: 'أعد إرسال الرمز وحاول مجددًا.',
        confirmText: 'حسنًا',
      );
      if (!mounted) return;
      Navigator.pop(context); // يرجع لشاشة الدخول
    }
  }

  /// زر "إعادة المحاولة": يمسح الخانات ويرجع للحالة الطبيعية
  void _retry() {
    // خطأ الاتصال: الرمز يبقى مكتوبًا ليضغط "تأكيد" مجددًا
    if (!_networkError) _codeController.clear();
    setState(() {
      _networkError = false;
      _state = _VerifyState.idle;
    });
    _showKeyboard();
  }

  String get _remainingText {
    final left = _maxAttempts - _failedAttempts;
    if (left == 1) return 'تبقى لك محاولة واحدة';
    if (left == 2) return 'تبقى لك محاولتان';
    return 'تبقى لك $left محاولات';
  }

  Future<void> _continue() async {
    // حالة طلب الانضمام: نحفظ الطلب والشاشة ظاهرة، وهي اللي بتنقل
    if (_args.isProviderJoin) {
      final onVerified = _args.onVerified;
      if (onVerified != null) {
        setState(() => _busy = true);
        try {
          await onVerified(context);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        return;
      }
      Navigator.pop(context, true);
      return;
    }

    // حالة التحقق قبل حذف الحساب: نرجع للمعالج بنجاح التحقق
    if (_args.isReauth) {
      Navigator.pop(context, true);
      return;
    }

    // حالة تغيير رقم الهاتف: نرجع للمنادي، وهو يحدّث Firestore
    if (_args.isChangePhone) {
      Navigator.pop(context, true);
      return;
    }

    // حالة تسجيل الدخول
    final phone = _args.phone;

    // الدور يُقرأ من Firestore. عند فشل الاتصال تظهر شاشة "لا يوجد اتصال"، والإلغاء يبقينا هنا
    final route = await resolveRouteWithRetry(context, phone);
    if (!mounted || route == null) return;
    // المرفوض: routeFor بترجع 'ProviderRejected' (بدل حوار الرفض القديم)
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  Color get _mainColor =>
      _state == _VerifyState.error ? AppColors.error500 : AppColors.primary500;

  Color get _haloColor => _state == _VerifyState.error
      ? AppColors.error500.withValues(alpha: 0.08)
      : AppColors.primary50;

  Widget _header() {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              // ما في رجوع أثناء حفظ الطلب
              onPressed: _busy ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const Text(
            'التحقق من الرمز',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _topIcon() {
    final bool success = _state == _VerifyState.success;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _haloColor),
      child: Center(
        child: success
            ? const SuccessCheck(size: 72)
            : Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    _shieldIcon,
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(_mainColor, BlendMode.srcIn),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _phoneChip(String phone) {
    final bool success = _state == _VerifyState.success;
    // عرض فقط، وعلامة الصح بالنجاح
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              phone,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          if (success) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.check_circle,
              size: 14,
              color: AppColors.primary500,
            ),
          ],
        ],
      ),
    );
  }

  Widget _otpBox(int index) {
    final String text = _codeController.text;
    final bool filled = index < text.length;
    final bool active =
        _state == _VerifyState.idle && index == text.length && _focus.hasFocus;

    Color border = AppColors.neutralNormal;
    Color fill = Colors.white;
    Color textColor = AppColors.neutralDarkActive;

    if (_state == _VerifyState.error) {
      border = AppColors.error500;
      fill = AppColors.error500.withValues(alpha: 0.06);
      textColor = AppColors.error500;
    } else if (_state == _VerifyState.success) {
      border = AppColors.primary500;
      textColor = AppColors.primary500;
    } else if (active) {
      border = AppColors.primary500;
      fill = AppColors.primary50;
    } else if (filled) {
      border = AppColors.primary500;
    }

    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: active ? 2 : 1.2),
      ),
      child: Text(
        filled ? text[index] : '',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _otpRow() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _showKeyboard,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _otpBox(i),
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _codeController,
              focusNode: _focus,
              autofocus: true,
              enabled: _state != _VerifyState.success,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_length),
              ],
              onChanged: (_) {
                setState(() {
                  if (_state == _VerifyState.error) {
                    _state = _VerifyState.idle;
                    _networkError = false;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusMessage() {
    if (_state == _VerifyState.idle) return const SizedBox.shrink();

    final bool success = _state == _VerifyState.success;
    final Color color = success ? AppColors.primary500 : AppColors.error500;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                success
                    ? 'تم التحقق من الرمز بنجاح'
                    : _networkError
                        ? 'تحقق من الاتصال بالإنترنت ثم حاول مرة أخرى.'
                        : 'الرمز غير صحيح',
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
          // عدد المحاولات المتبقية (مش لخطأ الاتصال)
          if (!success && !_networkError && _failedAttempts < _maxAttempts) ...[
            const SizedBox(height: 4),
            Text(
              _remainingText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// زر نصي دائمًا: معطل ورمادي أثناء العدّاد، ويتفعل بعد انتهائه
  Widget _resendRow() {
    final waiting = _secondsLeft > 0;
    return TextButton(
      onPressed: waiting ? null : _resend,
      child: Text(
        waiting ? 'إعادة إرسال الرمز ($_timeText)' : 'إعادة إرسال الرمز',
        style: TextStyle(
          fontSize: 14,
          fontWeight: waiting ? FontWeight.w400 : FontWeight.w600,
          color: waiting ? AppColors.neutralNormal : AppColors.primary500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String phone = _args.phone;
    final bool isChangePhone = _args.isChangePhone;
    final bool success = _state == _VerifyState.success;

    return Directionality(
      textDirection: TextDirection.rtl,
      // زر الرجوع في النظام ممنوع أثناء حفظ الطلب
      child: PopScope(
        canPop: !_busy,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                    child: Column(
                      children: [
                        _topIcon(),
                        const SizedBox(height: 16),

                        Text(
                          success ? 'تم التحقق من الرمز!' : 'رمز التحقق',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          success
                              ? (isChangePhone
                                    ? 'تم تغيير رقم هاتفك بنجاح'
                                    : 'تم التحقق من رقم هاتفك بنجاح')
                              : 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _phoneChip(phone),
                        const SizedBox(height: 32),

                        _otpRow(),
                        _statusMessage(),
                        const SizedBox(height: 24),

                        // الزر: "متابعة" بالنجاح، "تأكيد" غير ذلك
                        if (success)
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: AppButton(
                              text: _busy ? 'جارٍ الإرسال...' : 'متابعة',
                              icon: _busy ? null : Icons.arrow_back,
                              onPressed: _busy ? null : _continue,
                            ),
                          )
                        // بالخطأ (قبل الحد الأقصى): "إعادة المحاولة" بدل "تأكيد"
                        else if (_state == _VerifyState.error &&
                            _failedAttempts < _maxAttempts)
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: AppButton(
                              text: 'إعادة المحاولة',
                              onPressed: _retry,
                            ),
                          )
                        else
                          Opacity(
                            opacity: _canConfirm ? 1 : 0.5,
                            child: IgnorePointer(
                              ignoring: !_canConfirm,
                              child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: AppButton(
                                  text: 'تأكيد',
                                  onPressed: _verify,
                                ),
                              ),
                            ),
                          ),

                        if (!success) ...[
                          const SizedBox(height: 20),
                          _resendRow(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
