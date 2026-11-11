import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';
import 'package:my_first_app/features/patient/services/services_data.dart';

class CategoryItem {
  final String description;
  final String icon;
  final ServiceCategory category;

  const CategoryItem({
    required this.description,
    required this.icon,
    required this.category,
  });

  String get title => category.title;
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const Color _border = AppColors.border;

  // تم حذف قسم "زيارة طبيب"
  static const List<CategoryItem> categories = [
    CategoryItem(
      description: 'رعاية تمريضية متخصصة في منزلك.',
      icon: 'assets/icons/nursing.svg',
      category: ServiceCategory(
        title: 'الرعاية التمريضية',
        subtitle: 'اختر خدمة التمريض التي تحتاجها.',
        services: nursingServices,
      ),
    ),
    CategoryItem(
      description: 'تأهيل وعلاج طبيعي في المنزل.',
      icon: 'assets/icons/physiotherapy.svg',
      category: ServiceCategory(
        title: 'العلاج الطبيعي',
        subtitle: 'اختر خدمة العلاج الطبيعي التي تحتاجها.',
        services: physioServices,
      ),
    ),
    CategoryItem(
      description: 'فحوصات وسحب عينات في منزلك.',
      icon: 'assets/icons/lab_tests.svg',
      category: ServiceCategory(
        title: 'الفحوصات المخبرية',
        subtitle: 'اختر الفحص الذي تحتاجه.',
        services: labServices,
      ),
    ),
  ];

  void _openCategory(BuildContext context, CategoryItem item) {
    Navigator.pushNamed(context, 'Services', arguments: item.category);
  }

  /// صيغة عربية صحيحة للعدد: خدمة واحدة / خدمتان / 3-10 خدمات / 11+ خدمة
  String _countLabel(int n) {
    if (n == 1) return 'خدمة واحدة';
    if (n == 2) return 'خدمتان';
    if (n <= 10) return '$n خدمات';
    return '$n خدمة';
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'اختر القسم المناسب، وسيصلك مقدم الرعاية إلى منزلك.',
          style: TextStyle(fontSize: 14, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _countChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _countLabel(count),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary800,
        ),
      ),
    );
  }

   Widget _browseLink() {
    return const Text(
      'تصفح الخدمات',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary600,
      ),
    );
  }

   Widget _categoryCard(BuildContext context, CategoryItem item) {
    final count = item.category.services.length;

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        onTap: () => _openCategory(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        item.icon,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutralDarkActive,
                                ),
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 8),
                              _countChip(count),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.neutralDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _browseLink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) =>
                        _categoryCard(context, categories[i]),
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