// lib/features/patient/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/widgets/app_button.dart';
import 'package:my_first_app/features/patient/screens/book_service_screen.dart'; // BookingDraft
import 'package:my_first_app/features/patient/services/appointment_repository.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  static const String _font = 'Cairo';
  static const Color _border = Color(0xFFDDEBEB);

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

  bool _sending = false;

  String _fmtDate(DateTime d) =>
      '${_dayNames[d.weekday - 1]}، ${d.day} ${_monthNames[d.month - 1]} ${d.year}';

  String _fmtTime(String t) {
    final h = int.parse(t.substring(0, 2));
    final m = t.substring(3);
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m ${h >= 12 ? 'م' : 'ص'}';
  }

  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  /// ثيم بخط Cairo. بنستخدمه للشاشة وللنافذة المنبثقة
  /// (النافذة بتنفتح برا الشاشة، فلازم نلفها بنفس الثيم والاتجاه)
  ThemeData _cairoTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(textTheme: base.textTheme.apply(fontFamily: _font));
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('Home', (route) => false);
  }

  // ───────────────────────── الإرسال ─────────────────────────
    Future<void> _send(BookingDraft draft) async {
    setState(() => _sending = true);

    // TODO: هنا لاحقاً إنشاء الحجز في Firebase (مع Transaction).
    // حالياً انتظار وهمي لمحاكاة الإرسال.
    await Future.delayed(const Duration(seconds: 1));

    AppointmentRepository.add(
      provider: draft.provider,
      service: draft.service,
      categoryTitle: draft.categoryTitle,
      date: draft.date,
      time: draft.time,
      address: draft.address,
      notes: draft.notes,
    );

    if (!mounted) return;
    setState(() => _sending = false);
    await _showSuccess(draft);
  }
  Future<void> _showSuccess(BookingDraft draft) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false, // الضغط خارج النافذة ما بيسكرها
      enableDrag: false,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Theme(
        data: _cairoTheme(context),
        child: Directionality(
          textDirection: TextDirection.rtl,
          // زر الرجوع في الجهاز كمان بيودي للرئيسية
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _goHome();
            },
            child: _successSheet(draft),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── نافذة النجاح ─────────────────────────
  Widget _successSheet(BookingDraft draft) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: _goHome,
                tooltip: 'إغلاق',
                icon: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: AppColors.neutralDark,
                ),
              ),
            ),
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تم إرسال طلبك بنجاح!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDarkActive,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'بانتظار موافقة مقدم الرعاية على طلبك. سنُعلمك فور رده.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(text: 'العودة للرئيسية', onPressed: _goHome),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── صفوف التفاصيل ─────────────────────────
  Widget _iconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: AppColors.primary600),
    );
  }

  Widget _providerAvatar(BookingDraft d) {
    final p = d.provider;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.asset(
          p.image,
          fit: BoxFit.cover,
          cacheWidth: 120,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primary50,
            alignment: Alignment.center,
            child: Text(
              _initial(p.name),
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

  Widget _detailRow({
    required Widget leading,
    required String label,
    required String value,
    String? sub,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                if (sub != null && sub.isNotEmpty)
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralDark,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BookingDraft d) {
    final rows = <Widget>[
      _detailRow(
        leading: _iconBox(Icons.medical_services_outlined),
        label: 'الخدمة',
        value: d.service.title,
        sub: d.categoryTitle,
      ),
      _detailRow(
        leading: _providerAvatar(d),
        label: 'مقدم الرعاية',
        value: d.provider.name,
      ),
      _detailRow(
        leading: _iconBox(Icons.calendar_today_outlined),
        label: 'التاريخ',
        value: _fmtDate(d.date),
      ),
      _detailRow(
        leading: _iconBox(Icons.schedule_rounded),
        label: 'الوقت',
        value: _fmtTime(d.time),
        sub: d.service.duration,
      ),
      _detailRow(
        leading: _iconBox(Icons.location_on_outlined),
        label: 'العنوان',
        value: d.address.title,
        sub: d.address.details,
      ),
      _detailRow(
        leading: _iconBox(Icons.payments_outlined),
        label: 'السعر',
        value: d.service.price,
        sub: 'الدفع نقداً عند الزيارة',
      ),
      // الملاحظات بتظهر بس إذا المريض كتب شي
      if (d.notes.isNotEmpty)
        _detailRow(
          leading: _iconBox(Icons.notes_rounded),
          label: 'ملاحظات',
          value: d.notes,
        ),
    ];

    // فواصل بين الصفوف
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(const Divider(height: 1, thickness: 1, color: _border));
      }
      children.add(rows[i]);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل الحجز',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDarkActive,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary800),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'سيصل طلبك إلى مقدم الرعاية وينتظر موافقته. سنُعلمك فور رده.',
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

  // ───────────────────────── الشريط السفلي ─────────────────────────
  Widget _bottomBar(BookingDraft draft) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: _sending ? 'جارٍ الإرسال...' : 'إرسال الطلب',
                onPressed: _sending ? null : () => _send(draft),
              ),
              const SizedBox(height: 8),
              TextButton(
                // يرجع لشاشة الحجز بنفس الاختيارات
                onPressed: _sending ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary700,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text(
                  'تعديل الحجز',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final draft = ModalRoute.of(context)!.settings.arguments as BookingDraft;

    return Theme(
      data: _cairoTheme(context),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          canPop: !_sending, // ما نسمح بالرجوع أثناء الإرسال
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
                onPressed: _sending ? null : () => Navigator.pop(context),
              ),
              title: const Text(
                'تأكيد الحجز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Text(
                  'راجع تفاصيل حجزك قبل إرسال الطلب إلى مقدم الرعاية.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 8),
                _detailsCard(draft),
                const SizedBox(height: 8),
                _infoNote(),
              ],
            ),
            bottomNavigationBar: _bottomBar(draft),
          ),
        ),
      ),
    );
  }
}