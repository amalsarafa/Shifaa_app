// lib/features/patient/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class _PolicySection {
  final String title;
  final String? text;
  final List<String> bullets;

  const _PolicySection({
    required this.title,
    this.text,
    this.bullets = const [],
  });
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<_PolicySection> _sections = [
    _PolicySection(
      title: '1. مقدمة',
      text:
          'نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية والصحية. توضّح هذه السياسة أي بيانات نجمعها، وكيف نستخدمها ونحميها عند استخدامك تطبيق شفاء.',
    ),
    _PolicySection(
      title: '2. البيانات التي نجمعها',
      bullets: [
        'بياناتك الشخصية: الاسم ورقم الهاتف والبريد الإلكتروني وتاريخ الميلاد.',
        'عناوينك المحفوظة لتحديد مكان الزيارة المنزلية.',
        'سجلك الطبي الذي تدخلينه بنفسك، مثل فصيلة الدم والأمراض المزمنة والحساسية والأدوية.',
        'بيانات حجوزاتك وزياراتك السابقة.',
      ],
    ),
    _PolicySection(
      title: '3. كيف نستخدم بياناتك',
      bullets: [
        'لإنشاء حسابك وتأكيد هويتك.',
        'لتنسيق الحجوزات وإرسال الزيارات إلى عنوانك.',
        'لتمكين مقدم الرعاية من تقديم الخدمة المناسبة لحالتك.',
        'لإرسال تحديثات الحجوزات والتذكير بالمواعيد.',
      ],
    ),
    _PolicySection(
      title: '4. مشاركة البيانات',
      text:
          'لا نبيع بياناتك ولا نشاركها مع أي جهة إعلانية. تُشارَك بياناتك الضرورية فقط مع مقدم الرعاية المعيَّن لك بالقدر اللازم لتقديم الخدمة، أو عندما يطلب القانون ذلك.',
    ),
    _PolicySection(
      title: '5. حماية بياناتك',
      text:
          'نستخدم إجراءات تقنية وتنظيمية لحماية بياناتك من الوصول غير المصرّح به أو الفقدان. ومع ذلك لا توجد وسيلة حماية مطلقة، لذلك ننصحك بالحفاظ على سرية بيانات حسابك.',
    ),
    _PolicySection(
      title: '6. حقوقك',
      bullets: [
        'يمكنك الاطلاع على بياناتك وتعديلها في أي وقت من «حسابي».',
        'يمكنك حذف حسابك وبياناتك نهائياً من «الإعدادات».',
      ],
    ),
    _PolicySection(
      title: '7. تواصل معنا',
      text: 'إذا كانت لديك أي استفسارات بخصوص سياسة الخصوصية، يُرجى التواصل معنا على:',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 14,
      height: 1.7,
      color: AppColors.neutralDarkActive,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                    const Text(
                      'سياسة الخصوصية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                  children: [
                    for (final s in _sections) ...[
                      Text(
                        s.title,
                        style: bodyStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (s.text != null)
                        Text(
                          s.text!,
                          style: bodyStyle,
                          textAlign: TextAlign.justify,
                        ),
                      for (final b in s.bullets)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•  ', style: bodyStyle),
                              Expanded(
                                child: Text(
                                  b,
                                  style: bodyStyle,
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (s.title.startsWith('7.'))
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: support@shifaa.com',
                                    style: bodyStyle),
                                Text('Phone: +XXX-XXX-XXXX', style: bodyStyle),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}