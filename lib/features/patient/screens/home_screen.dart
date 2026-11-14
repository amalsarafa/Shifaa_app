// lib/features/patient/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/screens/categories_screen.dart';
import 'package:my_first_app/features/patient/screens/provider_profile_screen.dart';
import 'package:my_first_app/features/patient/screens/service_details_screen.dart';
import 'package:my_first_app/features/patient/services/appointment_model.dart';
import 'package:my_first_app/features/patient/services/appointment_repository.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/patient/widgets/appointment_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onGoToTab;

  const HomeScreen({super.key, this.onGoToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const Color _border = AppColors.border;
  static const Color _star = AppColors.star;

  // أرقام التبويبات في الشريط السفلي
  static const int _servicesTab = 1;
  static const int _bookingsTab = 2;

  final _searchCtrl = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── البيانات ─────────────────────────
  void _goToTab(int index) => widget.onGoToTab?.call(index);

  String get _greeting =>
      DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير';

  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  /// كل مقدمي الرعاية بدون تكرار، مرتبين من الأعلى تقييماً
  List<ProviderProfileArgs> _providers() {
    final seen = <String>{};
    final result = <ProviderProfileArgs>[];
    for (final c in CategoriesScreen.categories) {
      for (final s in c.category.services) {
        for (final p in s.providers) {
          if (seen.add(p.name)) {
            result.add(
              ProviderProfileArgs(
                provider: p,
                service: s,
                categoryTitle: c.title,
                serviceSelected: false,
              ),
            );
          }
        }
      }
    }
    result.sort((a, b) => b.provider.rating.compareTo(a.provider.rating));
    return result;
  }

  /// أقرب حجز مؤكد أو بانتظار الموافقة
  Appointment? _upcoming(List<Appointment> all) {
    final list =
        all
            .where(
              (a) =>
                  a.status == AppointmentStatus.confirmed ||
                  a.status == AppointmentStatus.pending,
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list.isEmpty ? null : list.first;
  }

  // ───────────────────────── الهيدر والبحث ─────────────────────────
  Widget _header(Patient patient) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16 + 28),
      decoration: const BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary400, width: 2),
                ),
                child: Text(
                  _initial(patient.name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '$_greeting، ${patient.firstName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'كيف صحتك اليوم؟',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary100,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primary600,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'الإشعارات',
                  onPressed: () =>
                      Navigator.pushNamed(context, 'Notifications'),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    patient.address.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border),
    );
    final hasText = _searchCtrl.text.isNotEmpty;

    return SizedBox(
      height: 56,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.neutralDarkActive,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن خدمة أو مقدم رعاية',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.neutralDark,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.neutralDark,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'مسح',
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.neutralDark,
                  ),
                  onPressed: () => setState(_searchCtrl.clear),
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary600),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── الأقسام ─────────────────────────
  Widget _sectionHeader(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bookingSection() {
    return ValueListenableBuilder<List<Appointment>>(
      valueListenable: AppointmentRepository.appointments,
      builder: (context, all, _) {
        final next = _upcoming(all);
        return Column(
          children: [
            _sectionHeader(
              'حجزك القادم',
              action: 'كل الحجوزات',
              onAction: () => _goToTab(_bookingsTab),
            ),
            next == null
                ? _emptyBookingCard()
                : AppointmentCard(
                    appointment: next,
                    margin: EdgeInsets.zero,
                    onTap: () => _goToTab(_bookingsTab),
                  ),
          ],
        );
      },
    );
  }

  Widget _emptyBookingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  size: 24,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ليس لديك حجوزات قادمة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      "احجز خدمتك الآن، وسيصلك مقدم الرعاية إلى منزلك.",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            height: 44,
            fontSize: 13,
            text: 'احجز خدمة',
            onPressed: () => _goToTab(_servicesTab),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(CategoryItem item) {
    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, 'Services', arguments: item.category),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    item.icon,
                    width: 26,
                    height: 26,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
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
      ),
    );
  }

  Widget _servicesSection() {
    final items = CategoriesScreen.categories.take(6).toList();

    return Column(
      children: [
        _sectionHeader(
          'خدماتنا',
          action: 'عرض الكل',
          onAction: () => _goToTab(_servicesTab),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 128,
          ),
          itemBuilder: (context, i) => _categoryTile(items[i]),
        ),
      ],
    );
  }

  Widget _providerCard(ProviderProfileArgs args) {
    final p = args.provider;

    return SizedBox(
      width: 140,
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        child: InkWell(
          onTap: () =>
              Navigator.pushNamed(context, 'ProviderProfile', arguments: args),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    p.image,
                    width: double.infinity,
                    height: 112,
                    fit: BoxFit.cover,
                    cacheWidth: 420,
                    errorBuilder: (_, __, ___) => Container(
                      height: 112,
                      color: AppColors.primary50,
                      alignment: Alignment.center,
                      child: Text(
                        _initial(p.name),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.neutralDark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: _star,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${p.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutralDarkActive,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _providersSection() {
    final providers = _providers().take(5).toList();
    if (providers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _sectionHeader('مقدمو الرعاية الأعلى تقييماً'),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _providerCard(providers[i]),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── نتائج البحث ─────────────────────────
  Widget _resultTile({
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    cacheWidth: 144,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.primary50,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                      Text(
                        subtitle,
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
    );
  }

  Widget _searchResults(String query) {
    final services = <ServiceDetailsArgs>[];
    for (final c in CategoriesScreen.categories) {
      for (final s in c.category.services) {
        if (s.title.contains(query) || c.title.contains(query)) {
          services.add(ServiceDetailsArgs(service: s, categoryTitle: c.title));
        }
      }
    }
    final providers = _providers()
        .where(
          (a) =>
              a.provider.name.contains(query) ||
              a.provider.role.contains(query),
        )
        .toList();

    if (services.isEmpty && providers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.primary300,
            ),
            SizedBox(height: 8),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
            Text(
              'جرّب البحث بكلمة أخرى.',
              style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (services.isNotEmpty) ...[
          _sectionHeader('الخدمات'),
          ...services.map(
            (s) => _resultTile(
              image: s.service.image,
              title: s.service.title,
              subtitle: '${s.categoryTitle} · ${s.service.price}',
              onTap: () =>
                  Navigator.pushNamed(context, 'ServiceDetails', arguments: s),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (providers.isNotEmpty) ...[
          _sectionHeader('مقدمو الرعاية'),
          ...providers.map(
            (p) => _resultTile(
              image: p.provider.image,
              title: p.provider.name,
              subtitle: p.provider.role,
              onTap: () =>
                  Navigator.pushNamed(context, 'ProviderProfile', arguments: p),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ValueListenableBuilder<Patient>(
          valueListenable: PatientRepository.current,
          builder: (context, patient, _) {
            return ListView(
              padding: EdgeInsets.zero,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                // الهيدر، والبحث نصفه فوق الهيدر
                Stack(
                  children: [
                    Column(
                      children: [_header(patient), const SizedBox(height: 28)],
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 0,
                      child: _searchField(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: query.isNotEmpty
                      ? _searchResults(query)
                      : Column(
                          children: [
                            _bookingSection(),
                            const SizedBox(height: 24),
                            _servicesSection(),
                            const SizedBox(height: 24),
                            _providersSection(),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
