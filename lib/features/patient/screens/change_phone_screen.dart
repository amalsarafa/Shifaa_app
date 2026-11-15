import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/screens/verification_screen.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _sendCode() {
    var phone = _phoneCtrl.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);

    if (phone.length != 9) {
      setState(() => _error = 'أدخل رقم هاتف صحيح مكوّن من 9 أرقام');
      return;
    }

    // ما في داعي نغيّر لنفس الرقم
    final current = PatientRepository.current.value.phone.replaceAll(' ', '');
    if ('+970$phone' == current) {
      setState(() => _error = 'هذا هو رقمك الحالي');
      return;
    }

    setState(() => _error = null);
    FocusScope.of(context).unfocus();

    // TODO: لاحقاً Firebase verifyPhoneNumber للرقم الجديد
    Navigator.pushNamed(
      context,
      'Verification',
      arguments: VerificationArgs(
        PatientRepository.formatPhone(phone),
        isChangePhone: true,
      ),
    );
  }

  Widget _phoneInput() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _error == null ? AppColors.border : AppColors.error500,
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
            const Text(
              '+970',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDarkActive,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 1, height: 24, color: AppColors.border),
            Expanded(
              child: TextField(
                controller: _phoneCtrl,
                autofocus: true,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: '59X XXX XXX',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: AppColors.neutralNormal,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPhone = PatientRepository.current.value.phone;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.neutralDarkActive,
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تغيير رقم الهاتف',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // الرقم الحالي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 20, color: AppColors.primary500),
                  const SizedBox(width: 8),
                  const Text(
                    'الرقم الحالي',
                    style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
                  ),
                  const Spacer(),
                  Text(
                    currentPhone,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'الرقم الجديد',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDarkActive,
              ),
            ),
            const SizedBox(height: 8),
            _phoneInput(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error500),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'سنرسل رمز تحقق إلى الرقم الجديد، وبعد التأكيد ستستخدمه لتسجيل الدخول.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              fontSize: 15,
              text: 'أرسل الرمز',
              onPressed: _sendCode,
            ),
          ),
        ),
      ),
    );
  }
}