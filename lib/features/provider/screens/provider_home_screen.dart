// lib/features/provider/screens/provider_home_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';

/// طلب حجز وهمي (يُستبدل ببيانات Firebase لاحقاً)
/// طلب حجز وهمي (يُستبدل ببيانات Firebase لاحقاً)
class _MockRequest {
  final String name;
  final String service;
  final String time;
  final String date;
  final String place;
  final String expires;
  final int expiresInMinutes;

  const _MockRequest({
    required this.name,
    required this.service,
    required this.time,
    required this.date,
    required this.place,
    this.expires = '',
    this.expiresInMinutes = 0,
  });
}

class ProviderHomeScreen extends StatefulWidget {
  final ValueChanged<int>? onGoToTab;

  const ProviderHomeScreen({super.key, this.onGoToTab});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  static const Color _border = AppColors.border;

  // رقم تبويب المواعيد في الشريط السفلي
  static const int _appointmentsTab = 1;

  // بيانات وهمية 🔥 لاحقاً: من Firebase
  static const String _providerName = 'سارة';
  static const String _providerRole = 'ممرضة مسجلة';
  static const int _unreadCount = 2;
  static const int _visitsToday = 3;
  static const int _totalPatients = 12;

  bool _available = true;

  final List<_MockRequest> _requests = [
    const _MockRequest(
      name: 'أحمد سالم',
      service: 'التمريض · تغيير الضمادات',
      time: '5:00 م',
      date: 'اليوم',
      place: 'غزة، تل الهوى',
      expires: 'ينتهي خلال 9 دقائق',
      expiresInMinutes: 9,
    ),
    const _MockRequest(
      name: 'علي أحمد',
      service: 'التمريض · رعاية كبار السن',
      time: '3:30 م',
      date: 'اليوم',
      place: 'غزة، الرمال',
      expires: 'ينتهي خلال 4 دقائق',
      expiresInMinutes: 4,
    ),
  ];

  final List<_MockRequest> _upcoming = [
    const _MockRequest(
      name: 'فاطمة علي',
      service: 'الرعاية التمريضية · الحقن',
      time: '3:30 م',
      date: 'اليوم',
      place: 'غزة، الرمال',
    ),
  ];

  // ───────────────────────── مساعدات ─────────────────────────
  String get _greeting =>
      DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير';

  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  Future<void> _refresh() async {
    // 🔥 لاحقاً: جلب الطلبات والمواعيد من Firebase
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<bool?> _dialog({
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (cancelText != null) ...[
                      Expanded(
                        child: AppButton(
                          height: 44,
                          fontSize: 13,
                          text: cancelText,
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.neutralDarkActive,
                          borderColor: AppColors.border,
                          onPressed: () => Navigator.pop(ctx, false),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: confirmText,
                        backgroundColor: danger
                            ? AppColors.error700
                            : AppColors.primary600,
                        onPressed: () => Navigator.pop(ctx, true),
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
  }

  Future<void> _accept(_MockRequest r) async {
    // 🔥 لاحقاً: تحديث حالة الحجز إلى "مؤكد" في Firebase
    setState(() {
      _requests.remove(r);
      _upcoming.add(r);
    });
    await _dialog(
      title: 'تم قبول الطلب',
      message: 'ستجد الموعد ضمن مواعيدك القادمة.',
      confirmText: 'حسناً',
    );
  }

  Future<void> _decline(_MockRequest r) async {
    final ok = await _dialog(
      title: 'رفض الطلب',
      message: 'هل تريد رفض طلب ${r.name}؟',
      confirmText: 'رفض الطلب',
      cancelText: 'إلغاء',
      danger: true,
    );
    if (ok != true) return;
    // 🔥 لاحقاً: تحديث حالة الحجز إلى "مرفوض" مع سبب الرفض
    setState(() => _requests.remove(r));
  }

  void _showDetails() {
    // 🔥 لاحقاً: فتح شاشة تفاصيل الموعد
    _dialog(
      title: 'قريباً',
      message: 'شاشة تفاصيل الموعد قيد التجهيز.',
      confirmText: 'حسناً',
    );
  }

  // ───────────────────────── الهيدر والتوفر ─────────────────────────
  Widget _header() {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16 + 32),
      decoration: const BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
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
              _initial(_providerName),
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
                Text(
                  '$_greeting، $_providerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const Text(
                  _providerRole,
                  style: TextStyle(fontSize: 13, color: AppColors.primary100),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: AppColors.primary600,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'الإشعارات',
                  onPressed: () =>
                      Navigator.pushNamed(context, 'ProviderNotifications'),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IgnorePointer(
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.star,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _available ? AppColors.primary50 : AppColors.neutralLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _available ? Icons.check_rounded : Icons.close_rounded,
              size: 18,
              color: _available ? AppColors.primary600 : AppColors.neutralDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _available ? 'متاح للزيارات' : 'غير متاح حاليًا',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                if (!_available)
                  const Text(
                    'لن تصلك طلبات جديدة',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.neutralDark,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: _available,
            // 🔥 لاحقاً: حفظ حالة التوفر في Firebase
            onChanged: (v) => setState(() => _available = v),
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary600,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  // ───────────────────────── الإحصائيات ─────────────────────────
  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.primary700,
              ),
            ),
            Text(
              label,
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
    );
  }

  Widget _stats() {
    return Row(
      children: [
        _statCard(Icons.event, '$_visitsToday', 'زيارات اليوم'),
        const SizedBox(width: 8),
        _statCard(Icons.hourglass_empty, '${_requests.length}', 'بانتظار الرد'),
        const SizedBox(width: 8),
        _statCard(Icons.people, '$_totalPatients', 'إجمالي المرضى'),
      ],
    );
  }

  // ───────────────────────── مكونات مشتركة ─────────────────────────
  Widget _sectionHeader(
    String title, {
    String? action,
    VoidCallback? onAction,
    Widget? trailing,
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
          if (trailing != null) trailing,
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

  Widget _avatar(String name) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _initial(name),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary800,
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
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

  Widget _metaRow(_MockRequest r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _metaItem(Icons.schedule_rounded, r.time),
        const SizedBox(width: 8),
        _metaItem(Icons.calendar_today_outlined, r.date),
        const SizedBox(width: 8),
        _metaItem(Icons.location_on_outlined, r.place, flexible: true),
      ],
    );
  }

  Widget _nameAndService(_MockRequest r) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDarkActive,
            ),
          ),
          Text(
            r.service,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(IconData icon, String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24, color: AppColors.primary600),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDarkActive,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── الطلبات المعلقة ─────────────────────────
  Widget _requestCard(_MockRequest r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(r.name),
              const SizedBox(width: 8),
              _nameAndService(r),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showDetails,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary600,
                        ),
                      ),
                      // إذا ظهر السهم لليمين بدّليه بـ chevron_left_rounded
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primary600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: _border),
          const SizedBox(height: 16),
          _metaRow(r),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  height: 44,
                  fontSize: 13,
                  text: 'رفض',
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.neutralDarkActive,
                  borderColor: AppColors.border,
                  onPressed: () => _decline(r),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  height: 44,
                  fontSize: 13,
                  text: 'قبول',
                  onPressed: () => _accept(r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _requestsSection() {
    final hasRequests = _requests.isNotEmpty;

    // الأقرب للانتهاء أولاً
    final sorted = [..._requests]
      ..sort((a, b) => a.expiresInMinutes.compareTo(b.expiresInMinutes));
    final others = _requests.length - 1;

    return Column(
      children: [
        _sectionHeader(
          'طلب بانتظار الرد',
          trailing: hasRequests && sorted.first.expires.isNotEmpty
              ? _chip(
                  sorted.first.expires,
                  AppColors.warningLight,
                  AppColors.warningDark,
                )
              : null,
        ),
        if (!hasRequests)
          _emptyCard(
            Icons.inbox_outlined,
            'لا توجد طلبات الآن',
            'سيظهر هنا أي طلب حجز جديد فور وصوله',
          )
        else ...[
          _requestCard(sorted.first),
          if (others > 0) _moreRequests(others),
        ],
      ],
    );
  }

  Widget _moreRequests(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => widget.onGoToTab?.call(_appointmentsTab),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Text(
            count == 1
                ? 'طلب آخر بانتظار الرد'
                : '$count طلبات أخرى بانتظار الرد',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary600,
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── الموعد القادم ─────────────────────────
  Widget _upcomingCard(_MockRequest r) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onGoToTab?.call(_appointmentsTab),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _avatar(r.name),
                const SizedBox(width: 8),
                _nameAndService(r),
                const SizedBox(width: 8),
                _chip('مؤكد', AppColors.primary800, AppColors.white),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: AppColors.primary200),
            const SizedBox(height: 16),
            _metaRow(r),
          ],
        ),
      ),
    );
  }

  Widget _upcomingSection() {
    return Column(
      children: [
        _sectionHeader(
          'موعدك القادم',
          action: 'كل المواعيد',
          onAction: () => widget.onGoToTab?.call(_appointmentsTab),
        ),
        if (_upcoming.isEmpty)
          _emptyCard(
            Icons.event_outlined,
            'لا مواعيد قادمة',
            'فعّل التوفر لتصلك طلبات جديدة',
          )
        else
          _upcomingCard(_upcoming.first),
      ],
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          color: AppColors.primary600,
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // الهيدر، وبطاقة التوفر نصفها فوق الهيدر
              Stack(
                children: [
                  Column(children: [_header(), const SizedBox(height: 28)]),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 0,
                    child: _availabilityCard(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  children: [
                    _stats(),
                    const SizedBox(height: 24),
                    _requestsSection(),
                    const SizedBox(height: 24),
                    _upcomingSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
