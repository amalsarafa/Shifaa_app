// lib/features/patient/services/provider_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  static const Color _star = Color(0xFFFFB400);
  static const Color _border = Color(0xFFDDEBEB);

  // ---------- الهيدر (صورة الممرض + الاسم) ----------
  Widget _header(BuildContext context, CareProvider p) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            p.image,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primary50,
              child: Icon(
                Icons.person_rounded,
                size: 80,
                color: AppColors.primary500,
              ),
            ),
          ),
          // تدرج داكن لتوضيح النص
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
          // زر الرجوع
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
          // الشارة + الاسم + الوظيفة والتقييم
          Positioned(
            right: 16,
            left: 16,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.primary500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'موثّق',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary800,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      p.role,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.star_rounded, size: 16, color: _star),
                    const SizedBox(width: 2),
                    Text(
                      '${p.rating} (${p.reviewsCount}+ تقييم)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- بطاقة الإحصائيات ----------
  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.neutralDark),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(CareProvider p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _statItem('${p.rating}', '${p.reviewsCount}+ تقييم'),
          Container(width: 1, height: 36, color: _border),
          _statItem('${p.yearsExp}+ سنوات', 'الخبرة'),
          Container(width: 1, height: 36, color: _border),
          _statItem('${p.visitsDone}+', 'زيارة منجزة'),
        ],
      ),
    );
  }

  // ---------- عنوان القسم ----------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.neutralDarkActive,
      ),
    );
  }

  // ---------- بطاقة تقييم ----------
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((w) => w[0]).join(' ');
  }

  Widget _reviewCard(ProviderReview r) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary50,
                child: Text(
                  _initials(r.name),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      r.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star_rounded, size: 16, color: _star),
              const SizedBox(width: 2),
              Text(
                r.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.comment,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.neutralDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ModalRoute.of(context)!.settings.arguments as CareProvider;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _header(context, p),
              // الجزء السفلي متداخل مع الصورة بزوايا دائرية
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
                      _statsCard(p),
                      if (p.about.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _AboutSection(text: p.about),
                      ],
                      const SizedBox(height: 20),
                      _sectionTitle('تقييمات المرضى'),
                      const SizedBox(height: 12),
                      if (p.reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'لا توجد تقييمات بعد.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.neutralDark,
                              ),
                            ),
                          ),
                        )
                      else
                        ...p.reviews.map(_reviewCard),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // زر الحجز ثابت أسفل الشاشة
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: AppColors.background,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, 'Booking', arguments: p);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'احجز الآن',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// قسم "عن مقدم الرعاية" مع زر "اقرأ المزيد"
/// StatefulWidget لأن حالته تتغير (موسّع / مختصر)
class _AboutSection extends StatefulWidget {
  final String text;

  const _AboutSection({required this.text});

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // نعرض زر "اقرأ المزيد" فقط إذا كان النص طويلاً
    final isLong = widget.text.length > 110;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عن مقدم الرعاية',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDarkActive,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.text,
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.neutralDark,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'عرض أقل' : 'اقرأ المزيد',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}