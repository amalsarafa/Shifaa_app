// lib/features/patient/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/appointment_model.dart';

/// تنسيق الوقت والتاريخ والعنوان، مشترك بين كل الشاشات
class AppointmentFormat {
  AppointmentFormat._();

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

  /// "16:00" ← "4:00 م"
  static String time(String t) {
    final h = int.parse(t.substring(0, 2));
    final m = t.substring(3);
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m ${h >= 12 ? 'م' : 'ص'}';
  }

  /// "اليوم" أو "السبت، 14 نوفمبر"
  static String date(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'اليوم';
    }
    return '${_dayNames[d.weekday - 1]}، ${d.day} ${_monthNames[d.month - 1]}';
  }

  /// من "مدينة غزة، حي الرمال" نعرض "حي الرمال"
  static String shortAddress(String title) => title.split('،').last.trim();
}

/// بطاقة الحجز: نفس الشكل في "حجوزاتي" و"الرئيسية"
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  /// أزرار أسفل البطاقة حسب الحالة. الحجز المؤكد يعرض رقم التواصل تلقائياً.
  final Widget? footer;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.footer,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.onTap,
  });

  static const Color _border = Color(0xFFDDEBEB);
  static const Color _pendingBg = Color(0xFFFFF0CC);
  static const Color _pendingText = Color(0xFF6B4700);

  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  Widget _avatar() {
    final p = appointment.provider;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Image.asset(
          p.image,
          fit: BoxFit.cover,
          cacheWidth: 144,
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

  Widget _statusChip() {
    final (label, bg, fg) = switch (appointment.status) {
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

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final confirmed = a.status == AppointmentStatus.confirmed;
    final phone = a.provider.phone.trim();
    final bottom = footer ??
        (confirmed && phone.isNotEmpty ? _phoneBox(phone) : null);

    final card = Container(
      margin: margin,
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
              _avatar(),
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
              _statusChip(),
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
              _metaItem(Icons.schedule_rounded, AppointmentFormat.time(a.time)),
              const SizedBox(width: 8),
              _metaItem(
                Icons.calendar_today_outlined,
                AppointmentFormat.date(a.date),
              ),
              const SizedBox(width: 8),
              _metaItem(
                Icons.location_on_outlined,
                AppointmentFormat.shortAddress(a.address.title),
                flexible: true,
              ),
            ],
          ),
          if (bottom != null) ...[const SizedBox(height: 16), bottom],
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}