import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late final TapGestureRecognizer _termsTap;
  String? _error;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => Navigator.pushNamed(context, 'Terms');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  void _sendCode() {
    // نشيل الصفر من البداية إذا انكتب (مثال: 059... -> 59...)
    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);

    if (phone.length != 9) {
      setState(() => _error = 'أدخل رقم هاتف صحيح مكوّن من 9 أرقام');
      return;
    }
    setState(() => _error = null);

    // TODO: هون استدعي Firebase verifyPhoneNumber بالرقم '+970$phone'
    Navigator.pushNamed(
      context,
      'Verification', 
      arguments: '+970$phone',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            child: Column(
              children: [
                const SizedBox(height: 64),

                
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 72,
                  height: 72,
                ),
                const SizedBox(height: 16),

                Text(
                  'مرحباً بك في شِفاء',
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
                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: AppButton(text: 'أرسل الرمز', onPressed: _sendCode),
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
                const SizedBox(height: 32),

                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}