import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/screens/verification_screen.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  late final TapGestureRecognizer _termsTap;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => Navigator.pushNamed(context, 'Terms');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    // نشيل الصفر من البداية إذا انكتب (مثال: 059... -> 59...)
    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);

    if (phone.length != 9) {
      setState(() => _error = 'أدخل رقم هاتف صحيح مكوّن من 9 أرقام');
      return;
    }
    setState(() => _error = null);

    // تأكيد الرقم قبل إرسال الرمز (‎ يضبط اتجاه الرقم من اليسار لليمين)
    final confirmed = await showProviderDialog(
      context,
      title: 'هل أنت متأكد من رقم الهاتف؟',
      message: 'سيتم إرسال رمز التحقق إلى الرقم:\n‎+970 $phone‎',
      confirmText: 'متأكد',
      cancelText: 'تعديل',
    );
    if (!mounted) return;
    if (confirmed != true) {
      // يرجع لحقل الهاتف والرقم كما هو
      _phoneFocus.requestFocus();
      return;
    }

    // إرسال رمز التحقق عبر Firebase
    final fullPhone = '+970$phone';
    setState(() {
      _error = null;
      _loading = true;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = switch (e.code) {
            'invalid-phone-number' => 'رقم الهاتف غير صحيح',
            'too-many-requests' => 'محاولات كثيرة، حاول لاحقًا',
                      _ => 'تعذّر إرسال الرمز، حاول مرة أخرى',
          };
        });
      },
      codeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.pushNamed(
          context,
          'Verification',
          arguments: VerificationArgs(
            fullPhone,
            verificationId: verificationId,
            resendToken: resendToken,
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, 'Home');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          // المحتوى بالوسط والشروط بالأسفل، ويتمرر لما تطلع الكيبورد
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 72,
                        height: 72,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'مرحباً بك في شفاء',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: AppColors.primary800,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'أدخل رقم هاتفك لاستلام رمز التحقق',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: AppColors.neutralDarkActive,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _error == null
                                  ? const Color(0xFFE0E0E0)
                                  : AppColors.error500,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: SvgPicture.asset(
                                  'assets/icons/Palestine_flag.svg',
                                  width: 24,
                                  height: 16,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+970',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutralDarkActive,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 24,
                                color: const Color(0xFFD0D0D0),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  keyboardType: TextInputType.phone,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  // الخطأ بيختفي أول ما تعدلي الرقم
                                  onChanged: (_) {
                                    if (_error != null) {
                                      setState(() => _error = null);
                                    }
                                  },
                                  style: const TextStyle(fontSize: 15),
                                  decoration: const InputDecoration(
                                    hintText: '59X XXX XXX',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.neutralNormal,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_error != null)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.error500,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: AppButton(
                          text: _loading ? 'جارٍ الإرسال...' : 'تسجيل الدخول',
                          onPressed: _loading ? null : _sendCode,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.neutralNormal),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'أو',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.neutralDark,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.neutralNormal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _continueAsGuest,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'استمر كضيف',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary500,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 6),

                      // رابط انضمام مقدم الرعاية
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, 'ProviderSignup'),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'هل أنت مقدم رعاية؟',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'انضم إلينا',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary500,
                                ),
                              ),
                             
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: AppColors.neutralDark,
                          ),
                          children: [
                            const TextSpan(text: 'باستمرارك، أنت توافق على '),
                            TextSpan(
                              text: 'الشروط وسياسة الخصوصية',
                              recognizer: _termsTap,
                              style: TextStyle(
                                color: AppColors.primary500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
