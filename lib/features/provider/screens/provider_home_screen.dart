// lib/features/provider/screens/provider_home_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/screens/provider_appointment_details_screen.dart'
    show showProviderDeclineSheet;
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

class ProviderHomeScreen extends StatefulWidget {
  // يفتح صفحة المواعيد على تبويب معيّن (0 معلقة، 1 قادمة)
  final ValueChanged<int>? onOpenAppointments;

  const ProviderHomeScreen({super.key, this.onOpenAppointments});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  static const Color _border = AppColors.border;

  // بيانات وهمية 🔥 لاحقاً: من Firebase
  static const String _providerName = 'سارة';
  static const String _providerRole = 'ممرضة مسجلة';
  static const int _unreadCount = 2;
  static const int _visitsToday = 3;
  static const int _totalPatients = 12;

  bool _available = true;

  // الطلبات والمواعيد من المخزن المشترك 🔥 لاحقاً: من Firebase
  List<ProviderAppointment> get _requests => ProviderAppointmentRepository
      .appointments
      .value
      .where((a) => a.status == ProviderApptStatus.pending)
      .toList();

  List<ProviderAppointment> get _upcoming => ProviderAppointmentRepository
      .appointments
      .value
      .where((a) => a.status == ProviderApptStatus.confirmed)
      .toList();

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

  Future<void> _accept(ProviderAppointment r) async {
    ProviderAppointmentRepository.accept(r.id);
    await showProviderDialog(
      context,
      title: 'تم قبول الطلب',
      message: 'ستجد الموعد ضمن مواعيدك القادمة.',
      confirmText: 'حسناً',
    );
  }

  Future<void> _decline(ProviderAppointment r) async {
    final reason = await showProviderDeclineSheet(context);
    if (reason == null) return;
    ProviderAppointmentRepository.decline(r.id, reason);
  }

  void _showDetails(ProviderAppointment a) {
    Navigator.pushNamed(
      context,
      'ProviderAppointmentDetails',
      arguments: a.id,
    );
  }

  // ───────────────────────── الهيدر والتوفر ─────────────────────────
  Widget _header() {
    final topInset = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary600,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary100, width: 2),
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
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const Text(
                  _providerRole,
                  style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: AppColors.white,
                shape: const CircleBorder(side: BorderSide(color: _border)),
                child: IconButton(
                  tooltip: 'الإشعارات',
                  onPressed: () =>
                      Navigator.pushNamed(context, 'ProviderNotifications'),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
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
            activeThumbColor: AppColors.white,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                fontSize: 20,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.primary700,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutralDark,
                ),
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
          ?trailing,
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

  Widget _metaRow(ProviderAppointment r) {
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

  Widget _nameAndService(ProviderAppointment r) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.patientName,
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
  // عنصر معلومات (وقت/تاريخ/مكان) على خلفية غامقة
  Widget _darkMeta(IconData icon, String text, {bool flexible = false}) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary200),
        const SizedBox(width: 4),
        flexible ? Flexible(child: label) : label,
      ],
    );

    return flexible ? Flexible(child: content) : content;
  }

  Widget _requestCard(ProviderAppointment r) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDetails(r),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _initial(r.patientName),
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
                        r.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        r.service,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary100,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primary600,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _darkMeta(Icons.schedule_rounded, r.time),
                const SizedBox(width: 8),
                _darkMeta(Icons.calendar_today_outlined, r.date),
                const SizedBox(width: 8),
                _darkMeta(Icons.location_on_outlined, r.place, flexible: true),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    height: 44,
                    fontSize: 13,
                    text: 'قبول',
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary700,
                    onPressed: () => _accept(r),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => _decline(r),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(
                          color: AppColors.primary300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'رفض',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        onTap: () => widget.onOpenAppointments?.call(0),
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
  Widget _phoneBox(String phone) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary50,
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

  Widget _upcomingCard(ProviderAppointment r) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDetails(r),
      child: Container(
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
                _avatar(r.patientName),
                const SizedBox(width: 8),
                _nameAndService(r),
                const SizedBox(width: 8),
                _chip('مؤكد', AppColors.primary800, AppColors.white),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: _border),
            const SizedBox(height: 16),
            _metaRow(r),
            if (r.phone.isNotEmpty) ...[
              const SizedBox(height: 16),
              _phoneBox(r.phone),
            ],
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
          onAction: () => widget.onOpenAppointments?.call(1),
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
      child: ValueListenableBuilder<List<ProviderAppointment>>(
        valueListenable: ProviderAppointmentRepository.appointments,
        builder: (context, _, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: RefreshIndicator(
              color: AppColors.primary600,
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _header(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _availabilityCard(),
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
          );
        },
      ),
    );
  }
}