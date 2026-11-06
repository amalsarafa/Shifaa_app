import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/widgets/app_button.dart';

enum _VerifyState { idle, error, success }

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _length = 4;
  static const int _resendSeconds = 45;
  static const String _testCode = '1234'; // الكود الثابت للتجربة

  static const String _shieldIcon = 'assets/icons/shield_check.svg';
  static const String _successIcon = 'assets/icons/success_check.svg';

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  _VerifyState _state = _VerifyState.idle;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focus.dispose();
    super.dispose();
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
  bool get _canConfirm => _isComplete && _state == _VerifyState.idle;

  void _resend() {
    // TODO: هون استدعي Firebase لإعادة إرسال الرمز
    _codeController.clear();
    setState(() => _state = _VerifyState.idle);
    _startTimer();
  }

  void _verify() {
    if (!_isComplete) return;

    // TODO: هون تحققي من الكود عبر Firebase بدل الكود الثابت
    if (_codeController.text == _testCode) {
      _timer?.cancel();
      _focus.unfocus();
      setState(() => _state = _VerifyState.success);
    } else {
      setState(() => _state = _VerifyState.error);
    }
  }

  void _continue() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      'Home', // غيّريه حسب الـ route عندك
      (route) => false,
    );
  }

  Color get _mainColor =>
      _state == _VerifyState.error ? AppColors.error500 : AppColors.primary500;

  Color get _haloColor => _state == _VerifyState.error
      ? AppColors.error500.withOpacity(0.08)
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
            ? SvgPicture.asset(_successIcon, width: 64, height: 64)
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
    return GestureDetector(
      onTap: success ? null : () => Navigator.pop(context),
      child: Container(
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
            const SizedBox(width: 6),
            Icon(
              success ? Icons.check_circle : Icons.edit_outlined,
              size: 14,
              color: AppColors.primary500,
            ),
          ],
        ),
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
      fill = AppColors.error500.withOpacity(0.06);
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
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: active ? 2 : 1.2),
      ),
      child: Text(
        filled ? text[index] : '',
        style: TextStyle(
          fontSize: 22,
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
          onTap: () => _focus.requestFocus(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(success ? Icons.check_circle : Icons.error,
              size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            success
                ? 'تم التحقق من الرمز بنجاح'
                : 'الرمز غير صحيح، حاول مرة أخرى',
            style: TextStyle(fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }

  Widget _resendRow() {
    if (_secondsLeft > 0) {
      return Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 14, color: AppColors.neutralDarkActive),
          children: [
            const TextSpan(text: 'إعادة إرسال الرمز خلال '),
            TextSpan(
              text: _timeText,
              style: TextStyle(color: AppColors.primary500),
            ),
          ],
        ),
      );
    }
    return TextButton(
      onPressed: _resend,
      child: Text(
        'إعادة إرسال الرمز',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String phone =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
    final bool success = _state == _VerifyState.success;

    return Directionality(
      textDirection: TextDirection.rtl,
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
                            ? 'تم التحقق من رقم هاتفك بنجاح'
                            : 'أدخل الرمز المكوّن من 4 أرقام المرسل إلى',
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
                            text: 'متابعة',
                            icon: Icons.arrow_back,
                            onPressed: _continue,
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
    );
  }
}