// lib/features/services/services_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/screens/service_details_screen.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category =
        ModalRoute.of(context)!.settings.arguments as ServiceCategory;

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
          title: Text(
            category.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: category.services.isEmpty
            ? Center(
                child: Text(
                  'لا توجد خدمات متاحة حالياً.',
                  style: TextStyle(fontSize: 14, color: AppColors.neutralDark),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  Text(
                    category.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...category.services.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceCard(
                        item: s,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            'ServiceDetails',
                            arguments: ServiceDetailsArgs(
                              service: s,
                              categoryTitle: category.title,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onTap;

  const _ServiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDDEBEB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.image,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 84,
                    height: 84,
                    color: const Color(0xFFE8EFEF),
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // حد أدنى للارتفاع بدل ارتفاع ثابت لتجنب الـ overflow
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 84),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutralDarkActive,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.price,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutralDarkActive,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/time.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              AppColors.neutralDark,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutralDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'عرض التفاصيل',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const SizedBox(width: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
