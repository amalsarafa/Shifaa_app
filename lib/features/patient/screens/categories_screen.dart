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
    _CategoryItem(
      description: 'أطباء مؤهلون يزورونك في المنزل.',
      icon: 'assets/icons/doctor_visits.svg',
      category: ServiceCategory(
        title: 'زيارة طبيب',
        subtitle: 'اختر نوع الزيارة التي تحتاجها.',
        services: doctorServices,
      ),
    ),
  ];

  void _openCategory(BuildContext context, _CategoryItem item) {
    Navigator.pushNamed(context, 'Services', arguments: item.category);
  }

  Widget _header() {
    return Column(
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
        const SizedBox(height: 6),
        Text(
          'اختاري الخدمة الصحية المنزلية التي تحتاجينها.',
          style: TextStyle(fontSize: 14, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _categoryCard(BuildContext context, _CategoryItem item) {
    return GestureDetector(
      onTap: () => _openCategory(context, item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary500.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      item.icon,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary500,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: AppColors.primary500,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.neutralDark,
              ),
            ),
          ],
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
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 27),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 190,
                        ),
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