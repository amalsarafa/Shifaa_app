// lib/features/provider/screens/provider_reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_profile_repository.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({super.key});

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  static const List<String> _filters = ['الكل', '5 نجوم', '4 نجوم', '3 فأقل'];

  // عدد التقييمات في كل دفعة
  static const int _pageSize = 5;

  int _filter = 0;
  int _shown = _pageSize;

  List<ProviderReview> get _visible {
    const all = ProviderProfileRepository.reviews;
    switch (_filter) {
      case 1:
        return all.where((r) => r.rating == 5).toList();
      case 2:
        return all.where((r) => r.rating == 4).toList();
      case 3:
        return all.where((r) => r.rating <= 3).toList();
      default:
        return all;
    }
  }

  // ───────────────────────── الملخص ─────────────────────────
  Widget _stars(int count, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            Icons.star_rounded,
            size: size,
            color: i < count ? AppColors.star : AppColors.neutralLightActive,
          ),
      ],
    );
  }

  Widget _barRow(int stars, int count, int total) {
    final fraction = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: AppColors.primary50,
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  heightFactor: 1,
                  child: Container(color: AppColors.primary600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final total = ProviderProfileRepository.reviewsCount;
    final avg = ProviderProfileRepository.averageRating;
    const counts = ProviderProfileRepository.ratingCounts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: providerCardDecoration(),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary800,
                ),
              ),
              _stars(avg.round()),
              const SizedBox(height: 4),
              Text(
                '$total تقييم',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutralDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                for (var s = 5; s >= 1; s--)
                  _barRow(s, counts[s] ?? 0, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── الفلاتر ─────────────────────────
  Widget _filtersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            ProviderChoiceChip(
              label: _filters[i],
              selected: _filter == i,
              onTap: () => setState(() {
                _filter = i;
                _shown = _pageSize; // كل فلتر يبدأ من أول دفعة
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────── بطاقة التقييم ─────────────────────────
  Widget _reviewCard(ProviderReview r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: providerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  r.initial,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      '${r.when} · ${r.service}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                r.rating.toDouble().toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded, size: 18, color: AppColors.star),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.8,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: providerCardDecoration(),
      child: const Text(
        'لا توجد تقييمات بهذا التصنيف',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.primary600,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'يقيّمك المريض بعد كل زيارة مكتملة. تظهر أسماء المرضى مختصرة لحماية خصوصيتهم، ولا يمكن حذف التقييمات.',
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: AppColors.primary800,
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
    final all = _visible;
    final list = all.take(_shown).toList();
    final hasMore = all.length > _shown;

    return ProviderSubScaffold(
      title: 'تقييمات المرضى',
      children: [
        _summaryCard(),
        const SizedBox(height: 16),
        _filtersRow(),
        const SizedBox(height: 16),
        if (list.isEmpty)
          _emptyFilter()
        else
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _reviewCard(list[i]),
          ],
        // يظهر فقط إذا في تقييمات لسا ما انعرضت
        if (hasMore) ...[
          const SizedBox(height: 16),
          AppButton(
            height: 44,
            fontSize: 13,
            text: 'عرض المزيد',
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary700,
            borderColor: AppColors.border,
            // 🔥 لاحقاً: تحميل الصفحة التالية من Firebase
            onPressed: () => setState(() => _shown += _pageSize),
          ),
        ],
        const SizedBox(height: 16),
        _noteCard(),
      ],
    );
  }
}
