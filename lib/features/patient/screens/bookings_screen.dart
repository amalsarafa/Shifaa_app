// lib/features/patient/screens/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/screens/provider_profile_screen.dart';
import 'package:my_first_app/features/patient/services/appointment_model.dart';
import 'package:my_first_app/features/patient/services/appointment_repository.dart';
import 'package:my_first_app/widgets/app_button.dart';

class BookingsScreen extends StatefulWidget {
  final ValueChanged<int>? onGoToTab;

  const BookingsScreen({super.key, this.onGoToTab});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  static const Color _border = Color(0xFFDDEBEB);
  static const Color _star = Color(0xFFFFB400);
  static const Color _pendingBg = Color(0xFFFFF0CC);
  static const Color _pendingText = Color(0xFF6B4700);

  static const _tabs = <String>['الحالية', 'المكتملة', 'الملغاة'];

  // DateTime.weekday: 1 = الاثنين ... 7 = الأحد
  static const _dayNames = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const _monthNames = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  final _searchCtrl = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── مساعدات ─────────────────────────
  String _fmtTime(String t) {
    final h = int.parse(t.substring(0, 2));
    final m = t.substring(3);
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m ${h >= 12 ? 'م' : 'ص'}';
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'اليوم';
    }
    return '${_dayNames[d.weekday - 1]}، ${d.day} ${_monthNames[d.month - 1]}';
  }

  /// من "مدينة غزة، حي الرمال" نعرض "حي الرمال"
  String _shortAddress(String title) => title.split('،').last.trim();

  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  List<Appointment> _filtered(List<Appointment> all) {
    final allowed = switch (_tab) {
      0 => const {AppointmentStatus.pending, AppointmentStatus.confirmed},
      1 => const {AppointmentStatus.completed},
      _ => const {AppointmentStatus.canceled, AppointmentStatus.rejected},
    };
    final query = _searchCtrl.text.trim();

    final result = all.where((a) {
      if (!allowed.contains(a.status)) return false;
      if (query.isEmpty) return true;
      return a.provider.name.contains(query) ||
          a.service.title.contains(query) ||
          a.categoryTitle.contains(query);
    }).toList();

    // الحالية: الأقرب أولاً. الباقي: الأحدث أولاً.
    result.sort(
      (a, b) => _tab == 0
          ? a.startsAt.compareTo(b.startsAt)
          : b.startsAt.compareTo(a.startsAt),
    );
    return result;
  }

  // ───────────────────────── البحث والتبويبات ─────────────────────────
  Widget _searchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border),
    );

    return TextField(
      controller: _searchCtrl,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 13, color: AppColors.neutralDarkActive),
      decoration: InputDecoration(
        hintText: 'ابحث في حجوزاتك',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: AppColors.neutralDark,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary600),
        ),
      ),
    );
  }

  Widget _tabsBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _tab;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary600 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.white
                        : AppColors.neutralDarkActive,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────────── أجزاء البطاقة ─────────────────────────
  Widget _avatar(Appointment a) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Image.asset(
          a.provider.image,
          fit: BoxFit.cover,
          cacheWidth: 144,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primary50,
            alignment: Alignment.center,
            child: Text(
              _initial(a.provider.name),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(AppointmentStatus status) {
    final (label, bg, fg) = switch (status) {
      AppointmentStatus.confirmed => (
        'مؤكد',
        AppColors.primary800,
        AppColors.white,
      ),
      AppointmentStatus.pending => ('قيد الانتظار', _pendingBg, _pendingText),
      AppointmentStatus.completed => (
        'مكتمل',
        AppColors.primary50,
        AppColors.primary800,
      ),
      AppointmentStatus.canceled => (
        'ملغي',
        AppColors.neutralLight,
        AppColors.neutralDarkActive,
      ),
      AppointmentStatus.rejected => (
        'مرفوض',
        AppColors.error50,
        AppColors.error800,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _metaItem(IconData icon, String text, {bool flexible = false}) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary800,
      ),
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary600),
        const SizedBox(width: 4),
        flexible ? Flexible(child: label) : label,
      ],
    );

    return flexible ? Flexible(child: content) : content;
  }

  Widget _cardButton({
    required String label,
    required VoidCallback onPressed,
    Color background = AppColors.white,
    Color foreground = AppColors.primary800,
    Color? borderColor = AppColors.primary200,
  }) {
    return AppButton(
      height: 44,
      fontSize: 13,
      text: label,
      onPressed: onPressed,
      backgroundColor: background,
      foregroundColor: foreground,
      borderColor: borderColor,
    );
  }

  Widget _rebookButton(Appointment a) {
    return _cardButton(label: 'احجز مرة أخرى', onPressed: () => _rebook(a));
  }

  Widget _phoneBox(String phone) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'للتواصل:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            phone,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBox(double rating) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: _star),
          const SizedBox(width: 4),
          Text(
            'تقييمك: ${rating.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
    );
  }

  Widget? _actions(Appointment a) {
    switch (a.status) {
      case AppointmentStatus.confirmed:
        final phone = a.provider.phone.trim();
        return phone.isEmpty ? null : _phoneBox(phone);
      case AppointmentStatus.pending:
        return _cardButton(
          label: 'إلغاء الطلب',
          foreground: AppColors.error700,
          borderColor: AppColors.error100,
          onPressed: () => _confirmCancel(a),
        );
      case AppointmentStatus.completed:
        return Row(
          children: [
            Expanded(
              child: a.rating != null
                  ? _ratingBox(a.rating!)
                  : _cardButton(
                      label: 'قيّم الزيارة',
                      background: AppColors.primary600,
                      foreground: AppColors.white,
                      borderColor: null,
                      onPressed: () => _openRating(a),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _rebookButton(a)),
          ],
        );
      case AppointmentStatus.canceled:
        return Row(
          children: [
            Expanded(child: _reasonText('ألغيت هذا الطلب')),
            const SizedBox(width: 8),
            Expanded(child: _rebookButton(a)),
          ],
        );
      case AppointmentStatus.rejected:
        return Row(
          children: [
            Expanded(child: _reasonText('لم يتمكن مقدم الرعاية من قبول الطلب')),
            const SizedBox(width: 8),
            Expanded(child: _rebookButton(a)),
          ],
        );
    }
  }

  Widget _card(Appointment a) {
    final confirmed = a.status == AppointmentStatus.confirmed;
    final actions = _actions(a);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.primary100 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: confirmed ? null : Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(a),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      '${a.categoryTitle} · ${a.service.title}',
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
              _statusChip(a.status),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: confirmed ? AppColors.primary200 : _border,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metaItem(Icons.schedule_rounded, _fmtTime(a.time)),
              const SizedBox(width: 8),
              _metaItem(Icons.calendar_today_outlined, _fmtDate(a.date)),
              const SizedBox(width: 8),
              _metaItem(
                Icons.location_on_outlined,
                _shortAddress(a.address.title),
                flexible: true,
              ),
            ],
          ),
          if (actions != null) ...[const SizedBox(height: 16), actions],
        ],
      ),
    );
  }

  // ───────────────────────── الإجراءات ─────────────────────────
  void _rebook(Appointment a) {
    Navigator.pushNamed(
      context,
      'BookService',
      arguments: ProviderProfileArgs(
        provider: a.provider,
        service: a.service,
        categoryTitle: a.categoryTitle,
      ),
    );
  }

  Future<void> _confirmCancel(Appointment a) async {
    final confirmed = await showDialog<bool>(
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
              children: [
                const Text(
                  'هل أنت متأكد من إلغاء الطلب؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _cardButton(
                        label: 'تراجع',
                        background: AppColors.primary600,
                        foreground: AppColors.white,
                        borderColor: null,
                        onPressed: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _cardButton(
                        label: 'نعم، إلغاء الطلب',
                        foreground: AppColors.error700,
                        borderColor: AppColors.error100,
                        onPressed: () => Navigator.pop(dialogContext, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    AppointmentRepository.cancel(a.id);
    _showDone('تم إلغاء الطلب', 'انتقل طلبك إلى تبويب الملغاة.');
  }

  Future<void> _openRating(Appointment a) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _RateVisitSheet(appointment: a),
    );

    if (sent != true || !mounted) return;
    _showDone('تم إرسال تقييمك', 'شكراً لك على مشاركة رأيك.');
  }

  void _showDone(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 32,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  height: 44,
                  fontSize: 13,
                  text: 'حسناً',
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── القوائم ─────────────────────────
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  List<Widget> _currentSections(List<Appointment> list) {
    final confirmed = list
        .where((a) => a.status == AppointmentStatus.confirmed)
        .toList();
    final pending = list
        .where((a) => a.status == AppointmentStatus.pending)
        .toList();

    return [
      if (confirmed.isNotEmpty) ...[
        _sectionTitle('الحجوزات المؤكدة'),
        ...confirmed.map(_card),
      ],
      if (pending.isNotEmpty) ...[
        _sectionTitle('الحجوزات بانتظار الموافقة'),
        ...pending.map(_card),
      ],
    ];
  }

  Widget _emptyState() {
    final searching = _searchCtrl.text.trim().isNotEmpty;
    final (title, subtitle) = searching
        ? ('لا توجد نتائج', 'جرّب البحث بكلمة أخرى.')
        : switch (_tab) {
            0 => ('لا توجد حجوزات حالية', 'عند طلب خدمة ستظهر هنا.'),
            1 => ('لا توجد حجوزات مكتملة', 'ستظهر زياراتك المكتملة هنا.'),
            _ => (
              'لا توجد حجوزات ملغاة',
              'ستظهر الطلبات الملغاة والمرفوضة هنا.',
            ),
          };

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_note_outlined,
              size: 56,
              color: AppColors.primary300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutralDark,
              ),
            ),
            if (!searching && _tab == 0 && widget.onGoToTab != null) ...[
              const SizedBox(height: 16),
              AppButton(
                width: 160,
                height: 44,
                text: 'احجز الآن',
                onPressed: () => widget.onGoToTab!(1),
              ),
            ],
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
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'حجوزاتي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _searchField(),
              const SizedBox(height: 16),
              _tabsBar(),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<List<Appointment>>(
                  valueListenable: AppointmentRepository.appointments,
                  builder: (context, all, _) {
                    final list = _filtered(all);
                    if (list.isEmpty) return _emptyState();
                    return ListView(
                      children: _tab == 0
                          ? _currentSections(list)
                          : list.map(_card).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── نافذة التقييم ─────────────────────────
class _RateVisitSheet extends StatefulWidget {
  final Appointment appointment;

  const _RateVisitSheet({required this.appointment});

  @override
  State<_RateVisitSheet> createState() => _RateVisitSheetState();
}

class _RateVisitSheetState extends State<_RateVisitSheet> {
  static const Color _border = Color(0xFFDDEBEB);
  static const Color _star = Color(0xFFFFB400);

  final _commentCtrl = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    AppointmentRepository.rate(
      widget.appointment.id,
      _rating.toDouble(),
      _commentCtrl.text.trim(),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'كيف كانت زيارتك؟',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${a.provider.name} · ${a.service.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutralDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: List.generate(5, (i) {
                  final value = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = value),
                    tooltip: '$value من 5',
                    icon: Icon(
                      Icons.star_rounded,
                      size: 32,
                      color: value <= _rating ? _star : _border,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'أضف تعليقاً (اختياري)',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDark,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(color: AppColors.primary600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                height: 44,
                fontSize: 13,
                text: 'إرسال التقييم',
                onPressed: _rating == 0 ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}