import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class _TermsSection {
  final String title;
  final String? subtitle; 
  final bool inlineSubtitle; 
  final String? text;
  final List<String> bullets;

  const _TermsSection({
    required this.title,
    this.subtitle,
    this.inlineSubtitle = false,
    this.text,
    this.bullets = const [],
  });
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. المقدمة ونظرة عامة',
      text:
          'مرحباً بك في شفاء. باستخدامك تطبيق شفاء أو تنزيله أو الوصول إليه، فإنك توافق على الالتزام بهذه الشروط والأحكام. يوفّر شفاء منصة إلكترونية تربط المستخدمين بمتخصصي الرعاية الصحية المنزلية المؤهلين، ومنهم الأطباء والممرضون والأخصائيون.',
    ),
    _TermsSection(
      title: '2. إخلاء المسؤولية الطبية',
      subtitle: 'إخلاء مسؤولية الرعاية الطارئة',
      inlineSubtitle: true,
      text:
          'شفاء مصمَّم لخدمات الرعاية الصحية المنزلية المجدولة والخدمات الطبية غير الطارئة. شفاء ليس خدمة استجابة للطوارئ. إذا كنت تمرّ بحالة طبية طارئة تهدّد حياتك، فيرجى الاتصال بخدمات الطوارئ المحلية فوراً أو التوجه إلى أقرب مستشفى.',
    ),
    _TermsSection(
      title: '3. حساب المستخدم والمسؤوليات',
      subtitle: 'أمان الحساب ودقة البيانات',
      bullets: [
        'يجب عليك تقديم معلومات صحية وشخصية دقيقة وكاملة ومحدّثة عند حجز أي خدمة.',
        'أنت مسؤول عن الحفاظ على سرية بيانات حسابك وعن جميع الأنشطة التي تتم من خلاله.',
      ],
    ),
    _TermsSection(
      title: '4. الخدمات الصحية ومقدمو الرعاية',
      subtitle: 'مقدمو خدمات مستقلون',
      bullets: [
        'مقدمو الرعاية (الأطباء والممرضون والأخصائيون) المدرجون في شفاء هم متخصصون صحيون مرخّصون.',
        'ورغم أن شفاء يدقّق في جميع مقدمي الرعاية الصحية بعناية، فإن العلاج والمشورة الطبية يقدّمهما مباشرةً المتخصص المعيَّن لك.',
      ],
    ),
    _TermsSection(
      title: '5. خصوصية المريض وحماية البيانات',
      subtitle: 'أمان بياناتك',
      inlineSubtitle: true,
      text:
          'نأخذ خصوصيتك الطبية على محمل الجد. جميع البيانات الشخصية والصحية المقدَّمة أثناء المواعيد أو التسجيل محمية وفقاً لسياسة الخصوصية والأنظمة المعمول بها لحماية البيانات الصحية.',
    ),
    _TermsSection(
      title: '6. تواصل معنا',
      text:
          'أسئلة أو دعم؟ إذا كانت لديك أي استفسارات بخصوص هذه الشروط والأحكام، يُرجى التواصل معنا على:',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 14,
      height: 1.7,
      color: AppColors.neutralDarkActive,
    );
    final boldStyle = bodyStyle.copyWith(fontWeight: FontWeight.w700);

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
                      'الشروط والأحكام',
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

                      if (s.subtitle != null && !s.inlineSubtitle)
                        Text(s.subtitle!, style: bodyStyle),

                      if (s.text != null)
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              if (s.subtitle != null && s.inlineSubtitle)
                                TextSpan(
                                  text: '${s.subtitle!}: ',
                                  style: boldStyle,
                                ),
                              TextSpan(text: s.text!),
                            ],
                          ),
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

                      if (s.title.startsWith('6.'))
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