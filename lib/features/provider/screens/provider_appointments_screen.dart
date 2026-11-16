// lib/features/provider/screens/provider_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/screens/provider_appointment_details_screen.dart'
    show showProviderDeclineSheet;
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_appointment_card.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

class ProviderAppointmentsScreen extends StatefulWidget {
  // رقم التبويب المطلوب فتحه من خارج الصفحة (0 معلقة، 1 قادمة)
  final ValueNotifier<int>? tabRequest;

  const ProviderAppointmentsScreen({super.key, this.tabRequest});

  @override
  State<ProviderAppointmentsScreen> createState() =>
      _ProviderAppointmentsScreenState();
}

class _ProviderAppointmentsScreenState
    extends State<ProviderAppointmentsScreen> {
  static const Color _border = AppColors.border;
  static const List<String> _tabs = ['معلقة', 'قادمة', 'مكتملة', 'ملغاة'];

  final _searchCtrl = TextEditingController();
  int _tab = 0;

  // البيانات من المخزن المشترك 🔥 لاحقاً: من Firebase
  List<ProviderAppointment> get _all =>
      ProviderAppointmentRepository.appointments.value;

  List<ProviderAppointment> get _pending =>
      _all.where((a) => a.status == ProviderApptStatus.pending).toList();

  List<ProviderAppointment> get _upcoming =>
      _all.where((a) => a.status == ProviderApptStatus.confirmed).toList();

  List<ProviderAppointment> get _awaiting => _all
      .where((a) => a.status == ProviderApptStatus.awaitingPatientConfirmation)
      .toList();

  List<ProviderAppointment> get _done =>
      _all.where((a) => a.status == ProviderApptStatus.completed).toList();

  List<ProviderAppointment> get _disputed =>
      _all.where((a) => a.status == ProviderApptStatus.disputed).toList();

  List<ProviderAppointment> get _canceled => _all
      .where(
        (a) =>
            a.status == ProviderApptStatus.declined ||
            a.status == ProviderApptStatus.canceledByPatient ||
            a.status == ProviderApptStatus.expired,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    widget.tabRequest?.addListener(_onTabRequest);
  }

  void _onTabRequest() {
    setState(() => _tab = widget.tabRequest!.value);
  }

  @override
  void dispose() {
    widget.tabRequest?.removeListener(_onTabRequest);
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── مساعدات ─────────────────────────
  List<ProviderAppointment> _filter(List<ProviderAppointment> list) {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return list;
    return list.where((a) => a.patientName.contains(q)).toList();
  }

  Future<void> _refresh() async {
    // 🔥 لاحقاً: جلب المواعيد من Firebase
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _accept(ProviderAppointment a) async {
    ProviderAppointmentRepository.accept(a.id);
    await showProviderDialog(
      context,
      title: 'تم قبول الطلب',
      message: 'ستجد الموعد ضمن المواعيد القادمة.',
      confirmText: 'حسناً',
    );
  }

  Future<void> _decline(ProviderAppointment a) async {
    final reason = await showProviderDeclineSheet(context);
    if (reason == null) return;
    ProviderAppointmentRepository.decline(a.id, reason);
  }

  void _showDetails(ProviderAppointment a) {
    Navigator.pushNamed(
      context,
      'ProviderAppointmentDetails',
      arguments: a.id,
    );
  }

  // ───────────────────────── العناصر العامة ─────────────────────────
  Widget _searchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border),
    );
    final hasText = _searchCtrl.text.isNotEmpty;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.neutralDarkActive,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث باسم المريض',
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

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _tabButton(i)),
          ],
        ],
      ),
    );
  }

  Widget _tabButton(int i) {
    final selected = _tab == i;
    final showBadge = i == 0 && _pending.isNotEmpty;

    return Material(
      color: selected ? AppColors.primary600 : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _tab = i),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _tabs[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.white
                      : AppColors.neutralDarkActive,
                ),
              ),
              if (showBadge) ...[
                const SizedBox(width: 4),
                Container(
                  height: 16,
                  constraints: const BoxConstraints(minWidth: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.star,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_pending.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
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
          if (sub != null)
            Text(
              sub,
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

  // ───────────────────────── محتوى التبويبات ─────────────────────────
  List<Widget> _pendingTab() {
    final list = [..._filter(_pending)]
      ..sort((a, b) => a.expiresInMinutes.compareTo(b.expiresInMinutes));

    if (list.isEmpty) {
      return [
        _emptyCard(
          Icons.inbox_outlined,
          'لا توجد طلبات الآن',
          'سيظهر هنا أي طلب حجز جديد فور وصوله',
        ),
      ];
    }

    return [
      _heading('طلبات بانتظار الرد', sub: 'مرتبة بالأقرب انتهاءً'),
      for (final a in list) ...[
        // المهلة فوق البطاقة، مثل الرئيسية
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: providerExpiryChip(a.expires),
        ),
        const SizedBox(height: 8),
        ProviderAppointmentCard(
          appointment: a,
          onTap: () => _showDetails(a),
          footer: ProviderRequestActions(
            onAccept: () => _accept(a),
            onDecline: () => _decline(a),
          ),
        ),
        // مسافة أكبر عشان مهلة البطاقة الجاية تبين تابعة إلها
        const SizedBox(height: 16),
      ],
    ];
  }

  List<Widget> _upcomingTab() {
    final list = _filter(_upcoming);

    if (list.isEmpty) {
      return [
        _emptyCard(
          Icons.event_outlined,
          'لا مواعيد قادمة',
          'المواعيد التي تقبلها ستظهر هنا',
        ),
      ];
    }

    // تجميع حسب اليوم مع الحفاظ على الترتيب
    final days = <String>[];
    for (final a in list) {
      if (!days.contains(a.date)) days.add(a.date);
    }

    return [
      for (final day in days) ...[
        _heading(day),
        for (final a in list.where((x) => x.date == day)) ...[
          ProviderAppointmentCard(
            appointment: a,
            highlighted: true,
            chip: providerChip('مؤكد', AppColors.primary800, AppColors.white),
            onTap: () => _showDetails(a),
            footer: ProviderPhoneBox(phone: a.phone),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
      ],
    ];
  }

  Widget _footerNote(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
      ),
    );
  }

  List<Widget> _doneTab() {
    final awaiting = _filter(_awaiting);
    final list = _filter(_done);

    if (awaiting.isEmpty && list.isEmpty) {
      return [
        _emptyCard(
          Icons.task_alt_outlined,
          'لا زيارات مكتملة',
          'الزيارات التي تنهيها ستظهر هنا',
        ),
      ];
    }

    return [
      // حُفظ التقرير، والمريض لم يؤكد بعد
      if (awaiting.isNotEmpty) ...[
        _heading('بانتظار تأكيد المريض'),
        for (final a in awaiting) ...[
          ProviderAppointmentCard(
            appointment: a,
            chip: providerChip(
              'بانتظار تأكيد المريض',
              AppColors.infoLight,
              AppColors.infoDark,
            ),
            onTap: () => _showDetails(a),
            footer: _footerNote('بانتظار تأكيد المريض لإتمام الزيارة'),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
      ],
      if (list.isNotEmpty) ...[
        _heading('الزيارات المكتملة'),
        for (final a in list) ...[
          ProviderAppointmentCard(
            appointment: a,
            chip: providerChip(
              'مكتمل',
              AppColors.primary50,
              AppColors.primary800,
            ),
            onTap: () => _showDetails(a),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ];
  }

  Widget _cancelChip(ProviderApptStatus status) {
    return switch (status) {
      ProviderApptStatus.declined => providerChip(
        'مرفوض',
        AppColors.error50,
        AppColors.error800,
      ),
      ProviderApptStatus.canceledByPatient => providerChip(
        'ألغاه المريض',
        AppColors.neutralLight,
        AppColors.neutralDarkActive,
      ),
      ProviderApptStatus.expired => providerChip(
        'انتهت المهلة',
        AppColors.neutralLight,
        AppColors.neutralDarkActive,
      ),
      _ => providerChip(
        'ملغي',
        AppColors.neutralLight,
        AppColors.neutralDarkActive,
      ),
    };
  }

  /// footer البلاغ: السبب + زر الدعم
  Widget _disputeFooter(ProviderAppointment a) {
    final reason = a.disputeReason?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerNote(
          reason.isEmpty
              ? 'أبلغ المريض أن الزيارة لم تتم · قيد مراجعة فريق الدعم'
              : 'أبلغ المريض: $reason · قيد مراجعة فريق الدعم',
        ),
        const SizedBox(height: 8),
        AppButton(
          height: 44,
          fontSize: 13,
          text: 'تواصل مع الدعم',
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary800,
          borderColor: AppColors.primary200,
          onPressed: () => Navigator.pushNamed(context, 'ProviderHelp'),
        ),
      ],
    );
  }

  List<Widget> _canceledTab() {
    final disputed = _filter(_disputed);
    final list = _filter(_canceled);

    if (disputed.isEmpty && list.isEmpty) {
      return [
        _emptyCard(
          Icons.event_busy_outlined,
          'لا مواعيد ملغاة',
          'الطلبات المرفوضة أو الملغاة ستظهر هنا',
        ),
      ];
    }

    return [
      // المريض أبلغ أن الزيارة لم تتم
      if (disputed.isNotEmpty) ...[
        _heading('بلاغات قيد المراجعة'),
        for (final a in disputed) ...[
          ProviderAppointmentCard(
            appointment: a,
            chip: providerChip(
              'بلاغ قيد المراجعة',
              AppColors.error50,
              AppColors.error800,
            ),
            onTap: () => _showDetails(a),
            footer: _disputeFooter(a),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
      ],
      if (list.isNotEmpty) ...[
        _heading('الملغاة والمرفوضة'),
        for (final a in list) ...[
          ProviderAppointmentCard(
            appointment: a,
            chip: _cancelChip(a.status),
            onTap: () => _showDetails(a),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ];
  }

  List<Widget> _content() {
    switch (_tab) {
      case 0:
        return _pendingTab();
      case 1:
        return _upcomingTab();
      case 2:
        return _doneTab();
      default:
        return _canceledTab();
    }
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
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    const Text(
                      'المواعيد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _searchField(),
                    const SizedBox(height: 16),
                    _tabBar(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary600,
                        onRefresh: _refresh,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 16),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: _content(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}