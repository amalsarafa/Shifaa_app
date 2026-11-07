// lib/features/patient/screens/service_details_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/screens/provider_profile_screen.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';

class ServiceDetailsArgs {
  final ServiceItem service;
  final String categoryTitle;

  const ServiceDetailsArgs({
    required this.service,
    required this.categoryTitle,
  });
}

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  static const Color _star = Color(0xFFFFB400);
  static const Color _border = Color(0xFFDDEBEB);

  // الفلاتر: الكل / الأعلى تقييماً / الأقرب / متاح الآن
  static const _filters = <({String label, IconData? icon})>[
    (label: 'الكل', icon: null),
    (label: 'الأعلى تقييماً', icon: Icons.star_rounded),
    (label: 'الأقرب', icon: Icons.location_on_outlined),
    (label: 'متاح الآن', icon: null),
  ];
  int _selectedFilter = 0;

  // ───────────────────────── بطاقة الخدمة (الداكنة) ─────────────────────────
  Widget _serviceCard(ServiceDetailsArgs args) {
    final item = args.service;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary500,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              args.categoryTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(5, (i) {
                final filled = i < item.rating.round();
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 18,
                  color: _star,
                );
              }),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${item.rating}  (${item.reviewsCount} مستخدم)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.longDescription.isNotEmpty
                ? item.longDescription
                : item.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── بطاقة المعلومات ─────────────────────────
  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary500),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(ServiceItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoItem(Icons.schedule_rounded, 'المدة', item.duration),
            const VerticalDivider(width: 1, thickness: 1, color: _border),
            _infoItem(
              Icons.event_available_rounded,
              'التوفر',
              item.availability,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: _border),
            _infoItem(Icons.payments_outlined, 'السعر/الزيارة', item.price),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── الفلاتر ─────────────────────────
  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (i) {
          final f = _filters[i];
          final selected = i == _selectedFilter;
          final fg = selected ? AppColors.primary800 : AppColors.neutralDark;

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => setState(() => _selectedFilter = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary50 : AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: selected ? AppColors.primary500 : _border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.icon != null) ...[
                      Icon(f.icon, size: 14, color: fg),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────── صورة مقدم الرعاية (آمنة) ─────────────────────
  Widget _providerPhoto(CareProvider p) {
    final name = p.name.trim();
    final initial = name.isNotEmpty ? name[0] : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.asset(
          p.image,
          cacheWidth: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, error, __) {
            debugPrint('Provider image error: ${p.image} → $error');
            return Container(
              color: AppColors.primary50,
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary800,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ───────────────────── بطاقة مقدم الرعاية ─────────────────────
  Widget _providerCard(BuildContext context, CareProvider p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _providerPhoto(p),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                Text(
                  p.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: _star),
                    const SizedBox(width: 4),
                    Text(
                      '${p.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '• ${p.yearsExp} سنوات خبرة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as ServiceDetailsArgs;

                Navigator.pushNamed(
                  context,
                  'ProviderProfile',
                  arguments: ProviderProfileArgs(
                    provider: p,
                    service: args.service,
                    categoryTitle: args.categoryTitle,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary50,
                foregroundColor: AppColors.primary800,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.primary100),
                ),
              ),
              child: const Text(
                'عرض الملف',
                maxLines: 1,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ServiceDetailsArgs;
    final item = args.service;

    // "الكل" (0): بنفس ترتيب الداتا. "الأعلى تقييماً" (1) يرتّب فعلياً.
    // "الأقرب" و"متاح الآن" شكليان حالياً لأن CareProvider ما فيه حقل مسافة أو توفر.
    final providers = [...item.providers];
    if (_selectedFilter == 1) {
      providers.sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        return byRating != 0 ? byRating : b.yearsExp.compareTo(a.yearsExp);
      });
    }  

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
              'تفاصيل الخدمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              _serviceCard(args),
              const SizedBox(height: 16),
              _infoCard(item),
              const SizedBox(height: 16),
              const Text(
                'مقدمو الرعاية المتاحون',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'اختر مقدم الرعاية المناسب لاحتياجاتك.',
                style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
              ),
              const SizedBox(height: 16),
              _filterChips(),
              const SizedBox(height: 16),
              if (providers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'لا يوجد مقدمو رعاية متاحون حالياً.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ),
                )
              else
                ...providers.map((p) => _providerCard(context, p)),
            ],
          ),
        ),
      );
  }
}
