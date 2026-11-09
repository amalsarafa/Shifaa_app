import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';
import 'package:my_first_app/features/patient/services/services_data.dart';

class _CategoryItem {
  final String description;
  final String icon;
  final ServiceCategory category;

  const _CategoryItem({
    required this.description,
    required this.icon,
    required this.category,
  });

  String get title => category.title;
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // تم حذف قسم "زيارة طبيب"
  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      description: 'رعاية تمريضية متخصصة في منزلك.',
      icon: 'assets/icons/nursing.svg',
      category: ServiceCategory(
        title: 'الرعاية التمريضية',
        subtitle: 'اختر خدمة التمريض التي تحتاجها.',
        services: nursingServices,
      ),
    ),
    _CategoryItem(
      description: 'تأهيل وعلاج طبيعي في المنزل.',
      icon: 'assets/icons/physiotherapy.svg',
      category: ServiceCategory(
        title: 'العلاج الطبيعي',
        subtitle: 'اختر خدمة العلاج الطبيعي التي تحتاجها.',
        services: physioServices,
      ),
    ),
    _CategoryItem(
      description: 'فحوصات وسحب عينات في منزلك.',
      icon: 'assets/icons/lab_tests.svg',
      category: ServiceCategory(
        title: 'الفحوصات المخبرية',
        subtitle: 'اختر الفحص الذي تحتاجه.',
        services: labServices,
      ),
    ),
  ];

  void _openCategory(BuildContext context, _CategoryItem item) {
    Navigator.pushNamed(context, 'Services', arguments: item.category);
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'اختاري الخدمة الصحية المنزلية التي تحتاجينها.',
          style: TextStyle(fontSize: 14, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _categoryCard(BuildContext context, _CategoryItem item) {
    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary500.withAlpha(77)),
      ),
      child: InkWell(
        onTap: () => _openCategory(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    item.icon,
                    width: 24,
                    height: 24,
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
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.4,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // chevron_left ثابت الاتجاه: يشير لليسار (اتجاه "التالي" في RTL)
              const Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: AppColors.primary500,
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
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) =>
                        _categoryCard(context, _categories[i]),
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