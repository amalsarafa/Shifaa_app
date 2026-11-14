// lib/features/provider/screens/provider_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';

enum _Cancel { declined, byPatient, expired }

/// موعد وهمي (يُستبدل ببيانات Firebase لاحقاً)
class _MockAppt {
  final String name;
  final String service;
  final String time;
  final String date;
  final String place;
  final String phone;
  final String expires;
  final int expiresInMinutes;
  final _Cancel? cancel;

  const _MockAppt({
    required this.name,
    required this.service,
    required this.time,
    required this.date,
    required this.place,
    this.phone = '',
    this.expires = '',
    this.expiresInMinutes = 0,
    this.cancel,
  });
}

class ProviderAppointmentsScreen extends StatefulWidget {
  const ProviderAppointmentsScreen({super.key});

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

  // بيانات وهمية 🔥 لاحقاً: من Firebase
  final List<_MockAppt> _pending = [
    const _MockAppt(
      name: 'أحمد سالم',
      service: 'التمريض · تغيير الضمادات',
      time: '5:00 م',
      date: 'اليوم',
      place: 'غزة، تل الهوى',
      expires: 'ينتهي خلال 9 دقائق',
      expiresInMinutes: 9,
    ),
    const _MockAppt(
      name: 'علي أحمد',
      service: 'التمريض · رعاية كبار السن',
      time: '3:30 م',
      date: 'اليوم',
      place: 'غزة، الرمال',
      expires: 'ينتهي خلال 4 دقائق',
      expiresInMinutes: 4,
    ),
  ];

  final List<_MockAppt> _upcoming = [
    const _MockAppt(
      name: 'فاطمة علي',
      service: 'الرعاية التمريضية · الحقن',
      time: '3:30 م',
      date: 'اليوم',
      place: 'غزة، الرمال',
      phone: '+970 59 000 0002',
    ),
    const _MockAppt(
      name: 'لينا صالح',
      service: 'التمريض · رعاية كبار السن',
      time: '10:00 ص',
      date: 'السبت، 14 نوفمبر',
      place: 'غزة، الرمال',
      phone: '+970 59 000 0003',
    ),
  ];

  final List<_MockAppt> _done = [
    const _MockAppt(
      name: 'منى يوسف',
      service: 'الرعاية التمريضية · الحقن',
      time: '1:00 م',
      date: 'أمس',
      place: 'غزة، الرمال',
    ),
    const _MockAppt(
      name: 'خالد نبيل',
      service: 'العلاج الطبيعي · تأهيل الركبة',
      time: '11:00 ص',
      date: 'الأربعاء',
      place: 'غزة، الشجاعية',
    ),
    const _MockAppt(
      name: 'رنا حسن',
      service: 'التمريض · تغيير الضمادات',
      time: '9:30 ص',
      date: 'الاثنين',
      place: 'غزة، النصيرات',
    ),
  ];

  final List<_MockAppt> _canceled = [
    const _MockAppt(
      name: 'سمير ياسر',
      service: 'التمريض · الحقن',
      time: '2:00 م',
      date: 'اليوم',
      place: 'غزة، الرمال',
      cancel: _Cancel.declined,
    ),
    const _MockAppt(
      name: 'نور خليل',
      service: 'العلاج الطبيعي · تأهيل الظهر',
      time: '4:00 م',
      date: 'أمس',
      place: 'غزة، تل الهوى',
      cancel: _Cancel.byPatient,
    ),
    const _MockAppt(
      name: 'يوسف عادل',
      service: 'التمريض · قياس السكر',
      time: '12:00 م',
      date: 'الثلاثاء',
      place: 'غزة، الرمال',
      cancel: _Cancel.expired,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── مساعدات ─────────────────────────
  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  List<_MockAppt> _filter(List<_MockAppt> list) {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return list;
    return list.where((a) => a.name.contains(q)).toList();
  }

  Future<void> _refresh() async {
    // 🔥 لاحقاً: جلب المواعيد من Firebase
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
                        backgroundColor:
                            danger ? AppColors.error700 : AppColors.primary600,
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

  Future<void> _accept(_MockAppt a) async {
    // 🔥 لاحقاً: تحديث حالة الحجز إلى "مؤكد" في Firebase
    setState(() {
      _pending.remove(a);
      _upcoming.add(a);
    });
    await _dialog(
      title: 'تم قبول الطلب',
      message: 'ستجد الموعد ضمن المواعيد القادمة.',
      confirmText: 'حسناً',
    );
  }

  Future<void> _decline(_MockAppt a) async {
    final ok = await _dialog(
      title: 'رفض الطلب',
      message: 'هل تريد رفض طلب ${a.name}؟',
      confirmText: 'رفض الطلب',
      cancelText: 'إلغاء',
      danger: true,
    );
    if (ok != true) return;
    // 🔥 لاحقاً: تحديث الحالة إلى "مرفوض" مع سبب الرفض
    setState(() {
      _pending.remove(a);
      _canceled.insert(
        0,
        _MockAppt(
          name: a.name,
          service: a.service,
          time: a.time,
          date: a.date,
          place: a.place,
          cancel: _Cancel.declined,
        ),
      );
    });
  }

  void _showDetails() {
    // 🔥 لاحقاً: فتح شاشة تفاصيل الموعد
    _dialog(
      title: 'قريباً',
      message: 'شاشة تفاصيل الموعد قيد التجهيز.',
      confirmText: 'حسناً',
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

  /// بطاقة موعد واحدة. green = مؤكد، extra = زر أو رقم هاتف أسفلها
  Widget _card(
    _MockAppt a, {
    required Widget chip,
    bool green = false,
    Widget? extra,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showDetails,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: green ? AppColors.primary100 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: green ? null : Border.all(color: _border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _avatar(a.name),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                      Text(
                        a.service,
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
                chip,
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              thickness: 1,
              color: green ? AppColors.primary200 : _border,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metaItem(Icons.schedule_rounded, a.time),
                const SizedBox(width: 8),
                _metaItem(Icons.calendar_today_outlined, a.date),
                const SizedBox(width: 8),
                _metaItem(Icons.location_on_outlined, a.place, flexible: true),
              ],
            ),
            if (extra != null) ...[const SizedBox(height: 16), extra],
          ],
        ),
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
        _card(
          a,
          chip: _chip(
            a.expires,
            AppColors.warningLight,
            AppColors.warningDark,
          ),
          extra: Row(
            children: [
              Expanded(
                child: AppButton(
                  height: 44,
                  fontSize: 13,
                  text: 'رفض',
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.neutralDarkActive,
                  borderColor: AppColors.border,
                  onPressed: () => _decline(a),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  height: 44,
                  fontSize: 13,
                  text: 'قبول',
                  onPressed: () => _accept(a),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
          _card(
            a,
            green: true,
            chip: _chip('مؤكد', AppColors.primary800, AppColors.white),
            extra: a.phone.isEmpty ? null : _phoneBox(a.phone),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
      ],
    ];
  }

  List<Widget> _doneTab() {
    final list = _filter(_done);

    if (list.isEmpty) {
      return [
        _emptyCard(
          Icons.task_alt_outlined,
          'لا زيارات مكتملة',
          'الزيارات التي تنهيها ستظهر هنا',
        ),
      ];
    }

    return [
      _heading('الزيارات المكتملة'),
      for (final a in list) ...[
        _card(a, chip: _chip('مكتمل', AppColors.primary50, AppColors.primary800)),
        const SizedBox(height: 8),
      ],
    ];
  }

  Widget _cancelChip(_Cancel? c) {
    return switch (c) {
      _Cancel.declined => _chip('مرفوض', AppColors.error50, AppColors.error800),
      _Cancel.byPatient => _chip(
        'ألغاه المريض',
        AppColors.neutralLight,
        AppColors.neutralDarkActive,
      ),
      _Cancel.expired => _chip(
        'انتهت المهلة',
        AppColors.neutralLight,
        AppColors.neutralDarkActive,
      ),
      null => _chip('ملغي', AppColors.neutralLight, AppColors.neutralDarkActive),
    };
  }

  List<Widget> _canceledTab() {
    final list = _filter(_canceled);

    if (list.isEmpty) {
      return [
        _emptyCard(
          Icons.event_busy_outlined,
          'لا مواعيد ملغاة',
          'الطلبات المرفوضة أو الملغاة ستظهر هنا',
        ),
      ];
    }

    return [
      _heading('الملغاة والمرفوضة'),
      for (final a in list) ...[
        _card(a, chip: _cancelChip(a.cancel)),
        const SizedBox(height: 8),
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
      child: Scaffold(
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
      ),
    );
  }
}