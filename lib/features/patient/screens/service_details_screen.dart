// lib/features/patient/services/service_details_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';

class ServiceDetailsArgs {
  final ServiceItem service;
  final String categoryTitle;

  const ServiceDetailsArgs({
    required this.service,
    required this.categoryTitle,
  });
}

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  static const Color _star = Color(0xFFFFB400);
  static const Color _border = Color(0xFFDDEBEB);

  Widget _header(BuildContext context, ServiceDetailsArgs args) {
    final item = args.service;

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            item.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFE8EFEF),
              child: const Icon(Icons.image_outlined, size: 40),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.transparent,
                  Colors.black.withOpacity(0.55),
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: AppColors.white,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            left: 16,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    args.categoryTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rating(ServiceItem item) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final filled = i < item.rating.round();
          return Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: _star,
          );
        }),
        const SizedBox(width: 6),
        Text(
          '${item.rating} (${item.reviewsCount} مستخدم)',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary500),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.neutralDark),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 56, color: _border);

  Widget _infoCard(ServiceItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _infoItem(Icons.schedule_rounded, 'المدة', item.duration),
          _divider(),
          _infoItem(Icons.event_available_rounded, 'التوفر', item.availability),
          _divider(),
          _infoItem(Icons.payments_outlined, 'السعر/الزيارة', item.price),
        ],
      ),
    );
  }

  Widget _providerCard(BuildContext context, CareProvider p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary50,
            backgroundImage: AssetImage(p.image),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.role,
                  style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: _star),
                    const SizedBox(width: 2),
                    Text(
                      '${p.rating}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      '  •  ${p.yearsExp} سنوات خبرة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: () {
               
               Navigator.pushNamed(context, 'ProviderProfile', arguments: p);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary50,
                foregroundColor: AppColors.primary800,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'عرض الملف',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ServiceDetailsArgs;
    final item = args.service;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _header(context, args),
              // الجزء الأبيض بزوايا دائرية متداخل مع الصورة
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rating(item),
                      const SizedBox(height: 10),
                      Text(
                        item.longDescription.isNotEmpty
                            ? item.longDescription
                            : item.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _infoCard(item),
                      const SizedBox(height: 20),
                      Text(
                        'مقدمو الرعاية المتاحون',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اختر مقدم الرعاية المناسب لاحتياجاتك.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (item.providers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
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
                        ...item.providers.map((p) => _providerCard(context, p)),
                      const SizedBox(height: 24),
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