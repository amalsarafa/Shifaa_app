import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/patient/onboarding1.svg',
      'title': 'رعاية منزلية، بكل سهولة.',
      'body': 'احصل على خدمات رعاية صحية متخصصة وأنت في منزلك.',
    },
    {
      'image': 'assets/images/patient/onboarding2.svg',
      'title': 'اختر مقدم الرعاية الأنسب لك.',
      'body': 'تعرّف على مقدمي رعاية موثوقين واختر ما يناسب احتياجاتك.',
    },
    {
      'image': 'assets/images/patient/onboarding3.svg',
      'title': 'احجز رعايتك، وابقَ على تواصل.',
      'body': 'احجز زيارات الرعاية المنزلية وتابع مواعيدك بسهولة.',
    },
  ];

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, 'Login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentPage == _pages.length - 1;

    // MediaQuery: يحدّ من تكبير الخط بتأثير إعدادات الجوال (حتى لا يتجاوز الشاشة)
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1),
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Visibility(
                  visible: !isLast,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: PageView.builder(
                    controller: _controller,
                    reverse: false,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      // النص العربي داخل الصفحة RTL
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SvgPicture.asset(
                                    page['image']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // العنوان: ارتفاع ثابت
                              SizedBox(
                                height: 40,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    page['title']!,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                      color: AppColors.primary800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              SizedBox(
                                height: 66,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    page['body']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                      color: AppColors.neutralDarkActive,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final bool active = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary500
                            : AppColors.primary200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // ابدأ الآن
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: isLast
                      ? AppButton(
                          text: 'ابدأ الآن',
                          icon: Icons.arrow_back,
                          onPressed: _goToLogin,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}