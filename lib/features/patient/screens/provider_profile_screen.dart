import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/patient/screens/categories_screen.dart';

class ProviderProfileArgs {
  final CareProvider provider;
  final ServiceItem service;
  final String categoryTitle;

  final bool serviceSelected;

  const ProviderProfileArgs({
    required this.provider,
    required this.service,
    required this.categoryTitle,
    this.serviceSelected = true,
  });
}

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  static const Color _star = AppColors.star;
  static const Color _border = AppColors.border;

  /// عدد التقييمات الظاهرة قبل الضغط على "عرض الكل"
  static const int _previewReviews = 2;

  bool _aboutExpanded = false;
  bool _showAllReviews = false;

  // ───────────────────────── مساعدات ─────────────────────────
  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  /// صيغة عربية صحيحة للسنوات: سنة / سنتان / 3-10 سنوات / 11+ سنة
  String _yearsLabel(int y) {
    if (y <= 0) return '—';
    if (y == 1) return 'سنة';
    if (y == 2) return 'سنتان';
    if (y <= 10) return '$y سنوات';
    return '$y سنة';
  }

  // ───────────────────────── بطاقة المقدم (الداكنة) ─────────────────────────
  Widget _headerCard(CareProvider p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      p.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, __) {
                        debugPrint('Provider image error: ${p.image} → $error');
                        return Container(
                          color: AppColors.primary50,
                          alignment: Alignment.center,
                          child: Text(
                            _initial(p.name),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (p.isVerified)
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.white),
          ),
          // رقم هاتف مقدم الرعاية
          if (p.phone.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'للتواصل:',
                    style: TextStyle(fontSize: 13, color: AppColors.white),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p.phone,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────── بطاقة الأرقام ─────────────────────────
  Widget _statItem({
    required String value,
    required String label,
    bool withStar = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (withStar) ...[
                  const Icon(Icons.star_rounded, size: 18, color: _star),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
          ],
        ),
      ),
    );
  }

  Widget _statsCard(CareProvider p) {
    final reviewsLabel = p.reviewsCount > 0
        ? '${p.reviewsCount} تقييم'
        : 'لا تقييمات';

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
            _statItem(
              value: '${p.rating}',
              label: reviewsLabel,
              withStar: true,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: _border),
            _statItem(value: _yearsLabel(p.yearsExp), label: 'الخبرة'),
            const VerticalDivider(width: 1, thickness: 1, color: _border),
            _statItem(
              value: p.visitsDone > 0 ? '${p.visitsDone}' : '—',
              label: 'زيارات منجزة',
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── عن مقدم الرعاية ─────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.neutralDarkActive,
      ),
    );
  }

  Widget _linkButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary700,
          ),
        ),
      ),
    );
  }

  Widget _aboutCard(CareProvider p) {
    final about = p.about.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: about.isEmpty
          ? const Text(
              'لا توجد نبذة عن مقدم الرعاية بعد.',
              style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // نقيس هل النص أطول من 3 أسطر عشان نعرض "اقرأ المزيد" عند الحاجة فقط
                final style = DefaultTextStyle.of(context).style.merge(
                  const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.neutralDark,
                  ),
                );

                final painter = TextPainter(
                  text: TextSpan(text: about, style: style),
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  // نفس تكبير الخط اللي بيستخدمه Text الفعلي
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout(maxWidth: constraints.maxWidth);

                final overflows = painter.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      about,
                      style: style,
                      maxLines: _aboutExpanded ? null : 3,
                      overflow: _aboutExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (overflows) ...[
                      const SizedBox(height: 4),
                      _linkButton(
                        label: _aboutExpanded ? 'عرض أقل' : 'اقرأ المزيد',
                        onTap: () =>
                            setState(() => _aboutExpanded = !_aboutExpanded),
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }

  // ───────────────────────── التقييمات ─────────────────────────
  Widget _reviewCard(ProviderReview r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initial(r.name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      r.timeAgo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded, size: 16, color: _star),
              const SizedBox(width: 4),
              Text(
                '${r.rating}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '“${r.comment}”',
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.neutralDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewsSection(CareProvider p) {
    final reviews = p.reviews;
    final visible = _showAllReviews
        ? reviews
        : reviews.take(_previewReviews).toList();
    final total = p.reviewsCount > 0 ? p.reviewsCount : reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('تقييمات المرضى ($total)')),
            if (reviews.length > _previewReviews)
              _linkButton(
                label: _showAllReviews ? 'عرض أقل' : 'عرض الكل',
                onTap: () => setState(() => _showAllReviews = !_showAllReviews),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: const Text(
              'لا توجد تقييمات بعد.',
              style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
            ),
          )
        else
          ...visible.map(_reviewCard),
      ],
    );
  }

    Widget _bookBar(BuildContext context, ProviderProfileArgs args) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            text: 'احجز الآن',
            onPressed: () => args.serviceSelected
                ? Navigator.pushNamed(context, 'BookService', arguments: args)
                : _chooseService(context, args.provider),
          ),
        ),
      ),
    );
  }

  /// كل الخدمات التي يقدمها مقدم الرعاية، مع اسم القسم
  List<ProviderProfileArgs> _providerServices(CareProvider p) {
    final result = <ProviderProfileArgs>[];
    for (final c in CategoriesScreen.categories) {
      for (final s in c.category.services) {
        if (s.providers.any((x) => x.name == p.name)) {
          result.add(
            ProviderProfileArgs(provider: p, service: s, categoryTitle: c.title),
          );
        }
      }
    }
    return result;
  }

  Future<void> _chooseService(BuildContext context, CareProvider p) async {
    final options = _providerServices(p);

    final chosen = await showDialog<ProviderProfileArgs>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'اختر الخدمة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الخدمات التي يقدمها ${p.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: AppColors.white,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: _border),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.pop(dialogContext, o),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.service.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neutralDarkActive,
                                      ),
                                    ),
                                    Text(
                                      o.categoryTitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.neutralDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                o.service.price,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_left_rounded,
                                size: 20,
                                color: AppColors.primary600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (chosen == null || !context.mounted) return;
    Navigator.pushNamed(context, 'BookService', arguments: chosen);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ProviderProfileArgs;
    final p = args.provider;

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
            'ملف مقدم الرعاية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _headerCard(p),
            const SizedBox(height: 16),
            _statsCard(p),
            const SizedBox(height: 16),
            _sectionTitle('عن مقدم الرعاية'),
            const SizedBox(height: 8),
            _aboutCard(p),
            const SizedBox(height: 16),
            _reviewsSection(p),
          ],
        ),
        bottomNavigationBar: _bookBar(context, args),
      ),
    );
  }
}
