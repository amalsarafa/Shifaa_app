// lib/features/provider/screens/provider_help_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

/// بيانات التواصل (وهمية حالياً، غيّريها لأرقام الدعم الحقيقية)
class _Contact {
  final IconData icon;
  final String label;
  final String dialogTitle;
  final String value;

  const _Contact({
    required this.icon,
    required this.label,
    required this.dialogTitle,
    required this.value,
  });
}

/// سؤال وجواب. لاحقاً يمكن جلبها من قاعدة البيانات.
class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

class ProviderHelpScreen extends StatefulWidget {
  const ProviderHelpScreen({super.key});

  @override
  State<ProviderHelpScreen> createState() => _ProviderHelpScreenState();
}

class _ProviderHelpScreenState extends State<ProviderHelpScreen> {
  static const List<_Contact> _contacts = [
    _Contact(
      icon: Icons.phone_outlined,
      label: 'اتصال',
      dialogTitle: 'اتصل بنا',
      value: '+970 59 000 0000',
    ),
    _Contact(
      icon: Icons.chat_outlined,
      label: 'واتساب',
      dialogTitle: 'تواصل عبر واتساب',
      value: '+970 59 000 0000',
    ),
    _Contact(
      icon: Icons.mail_outline_rounded,
      label: 'البريد',
      dialogTitle: 'راسلنا عبر البريد',
      value: 'support@shifaa.ps',
    ),
  ];

  static const List<_Faq> _faqs = [
    _Faq(
      'كيف أقبل أو أرفض طلبًا؟',
      'من الرئيسية أو تبويب «معلقة» اضغطي قبول أو رفض. عند الرفض تختارين السبب، وعند القبول ينتقل الموعد إلى «قادمة» ويظهر لك رقم المريض للتواصل.',
    ),
    _Faq(
      'كم المهلة المتاحة للرد على الطلب؟',
      'يظهر على كل طلب الوقت المتبقي للرد. إذا انتهى الوقت تتحول حالة الطلب إلى «انتهت المهلة» ولا يمكن قبوله.',
    ),
    _Faq(
      'كيف أكتب تقرير الزيارة؟',
      'بعد انتهاء الزيارة افتحي الموعد واضغطي زر كتابة تقرير الزيارة، ثم أكدي فيه استلام الأجر.',
    ),
    _Faq(
      'كيف أستلم أجر الزيارة؟',
      'يدفع المريض نقدًا عند الزيارة بالسعر الظاهر في الطلب بالشيكل (₪)، وتؤكدين استلامه في تقرير الزيارة.',
    ),
    _Faq(
      'كيف أغيّر أوقات عملي أو مناطق خدمتي؟',
      'من حسابي ثم «أوقات العمل ومناطق الخدمة»، حيث تفعّلين الأيام وتغيّرين الساعات وتختارين المناطق.',
    ),
  ];

  /// رقم السؤال المفتوح (null = كلها مغلقة)
  int? _openIndex = 0;

  // ───────────────────────── نافذة التواصل ─────────────────────────
  Future<void> _showContact(_Contact c) {
    bool copied = false;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(c.icon, size: 26, color: AppColors.primary700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.dialogTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.value,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          height: 44,
                          fontSize: 13,
                          icon: copied
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          text: copied ? 'تم النسخ' : 'نسخ',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: c.value),
                            );
                            setDialogState(() => copied = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton(
                          height: 44,
                          fontSize: 13,
                          text: 'إغلاق',
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primary700,
                          borderColor: AppColors.border,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── عناصر الشكل ─────────────────────────
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _contactCard(_Contact c) {
    return Expanded(
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showContact(c),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(c.icon, size: 22, color: AppColors.primary600),
                ),
                const SizedBox(height: 8),
                Text(
                  c.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _faqItem(int index) {
    final faq = _faqs[index];
    final open = _openIndex == index;

    return InkWell(
      onTap: () => setState(() => _openIndex = open ? null : index),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: AppColors.primary600,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        faq.answer,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderSubScaffold(
      title: 'الدعم والمساعدة',
      children: [
        _sectionTitle('تواصل معنا'),
        Row(
          children: [
            for (int i = 0; i < _contacts.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _contactCard(_contacts[i]),
            ],
          ],
        ),
        const SizedBox(height: 32),
        _sectionTitle('الأسئلة الشائعة'),
        Material(
          color: AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _faqs.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                _faqItem(i),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
