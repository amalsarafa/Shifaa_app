// lib/features/provider/screens/provider_appointment_details_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

class ProviderAppointmentDetailsScreen extends StatelessWidget {
  const ProviderAppointmentDetailsScreen({super.key});

  static const Color _border = AppColors.border;

  // ───────────────────────── الأفعال ─────────────────────────
  Future<void> _accept(BuildContext context, ProviderAppointment a) async {
    ProviderAppointmentRepository.accept(a.id);
    await showProviderDialog(
      context,
      title: 'تم قبول الطلب',
      message: 'ستجد الموعد ضمن المواعيد القادمة، ويظهر لك السجل الطبي للمريض.',
      confirmText: 'حسناً',
    );
  }

  Future<void> _decline(BuildContext context, ProviderAppointment a) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _DeclineSheet(),
    );
    if (reason == null) return;
    ProviderAppointmentRepository.decline(a.id, reason);
    if (context.mounted) Navigator.pop(context);
  }

  // ───────────────────────── مكونات ─────────────────────────
  Widget _header(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: AppColors.neutralDarkActive,
            ),
          ),
          const Expanded(
            child: Text(
              'تفاصيل الموعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
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

  Widget _statusChip(ProviderAppointment a) {
    switch (a.status) {
      case ProviderApptStatus.pending:
        return _chip(
          a.expires.isEmpty ? 'بانتظار الرد' : a.expires,
          AppColors.warningLight,
          AppColors.warningDark,
        );
      case ProviderApptStatus.confirmed:
        return _chip('مؤكد', AppColors.primary800, AppColors.white);
      case ProviderApptStatus.completed:
        return _chip('مكتمل', AppColors.primary50, AppColors.primary800);
      case ProviderApptStatus.declined:
        return _chip('مرفوض', AppColors.error50, AppColors.error800);
      case ProviderApptStatus.canceledByPatient:
        return _chip(
          'ألغاه المريض',
          AppColors.neutralLight,
          AppColors.neutralDarkActive,
        );
      case ProviderApptStatus.expired:
        return _chip(
          'انتهت المهلة',
          AppColors.neutralLight,
          AppColors.neutralDarkActive,
        );
    }
  }

  Widget _patientCard(ProviderAppointment a) {
    final green = a.status == ProviderApptStatus.confirmed;
    final n = a.patientName.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: green ? AppColors.primary100 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: green ? null : Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              n.isEmpty ? '?' : n[0],
              style: const TextStyle(
                fontSize: 18,
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
                  a.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                Text(
                  '${a.gender} · ${a.age} سنة',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusChip(a),
        ],
      ),
    );
  }

  Widget _title(String text, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
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

  /// صف معلومة: أيقونة، عنوان صغير، قيمة
  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool last = false,
    bool ltr = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary600),
          ),
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
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    value,
                    textDirection: ltr ? TextDirection.ltr : null,
                    textAlign: ltr ? TextAlign.right : null,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDarkActive,
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

  Widget _card(List<Widget> children) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(children: children),
    );
  }

  Widget _visitInfo(ProviderAppointment a) {
    final rows = <Widget>[
      _infoRow(Icons.medical_services_outlined, 'الخدمة', a.service),
      _infoRow(Icons.event_outlined, 'الموعد', '${a.date}، ${a.time}'),
      _infoRow(
        Icons.location_on_outlined,
        'العنوان',
        '${a.place} · ${a.address}',
      ),
      if (a.notes.isNotEmpty)
        _infoRow(Icons.notes_rounded, 'ملاحظات المريض', a.notes),
      if (a.status == ProviderApptStatus.declined && a.declineReason.isNotEmpty)
        _infoRow(Icons.block_outlined, 'سبب الرفض', a.declineReason),
    ];
    rows.add(
      _infoRow(
        Icons.payments_outlined,
        'الأجر',
        '${a.price} ₪ · دفع نقدي عند الزيارة',
        last: true,
      ),
    );
    return _card(rows);
  }

  Widget _lockedMedical() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: AppColors.neutralDark,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'السجل الطبي للمريض يظهر لك بعد قبول الطلب.',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.neutralDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── السجل الطبي
  Widget _mini(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg, {Color? border}) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _medicalRecord(PatientMedicalInfo m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('السجل الطبي'),
        Row(
          children: [
            _mini('فصيلة الدم', m.bloodType),
            const SizedBox(width: 8),
            _mini('الطول', '${m.heightCm} سم'),
            const SizedBox(width: 8),
            _mini('الوزن', '${m.weightKg} كغ'),
          ],
        ),
        const SizedBox(height: 16),
        _title('الحساسية', sub: 'مهم لسلامتك أثناء الزيارة'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final x in m.allergies)
              _pill(x, AppColors.error50, AppColors.error800),
          ],
        ),
        const SizedBox(height: 16),
        _title('الأمراض المزمنة'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final x in m.chronic)
              _pill(
                x,
                AppColors.primary50,
                AppColors.primary800,
                border: AppColors.primary600,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _title('الأدوية الحالية'),
        _card([
          for (var i = 0; i < m.medications.length; i++)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: i == m.medications.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: _border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.medications[i].name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                  Text(
                    m.medications[i].dose,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),
        ]),
        const SizedBox(height: 16),
        _title('جهة اتصال للطوارئ'),
        _card([
          _infoRow(
            Icons.person_outline_rounded,
            m.emergencyName,
            m.emergencyPhone,
            last: true,
            ltr: true,
          ),
        ]),
      ],
    );
  }

  // ───────────────────────── الشريط السفلي ─────────────────────────
  Widget? _bottomBar(BuildContext context, ProviderAppointment a) {
    Widget? child;

    switch (a.status) {
      case ProviderApptStatus.pending:
        child = Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'رفض',
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.neutralDarkActive,
                borderColor: AppColors.border,
                onPressed: () => _decline(context, a),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(text: 'قبول', onPressed: () => _accept(context, a)),
            ),
          ],
        );
        break;
      case ProviderApptStatus.confirmed:
        child = AppButton(
          text: 'إنهاء الزيارة وكتابة التقرير',
          onPressed: () => Navigator.pushNamed(
            context,
            'ProviderVisitReport',
            arguments: a.id,
          ),
        );
        break;
      case ProviderApptStatus.completed:
        child = AppButton(
          text: 'عرض تقرير الزيارة',
          onPressed: () => Navigator.pushNamed(
            context,
            'ProviderReportView',
            arguments: a.id,
          ),
        );
        break;
      default:
        child = null;
    }

    if (child == null) return null;
    return Padding(padding: const EdgeInsets.all(16), child: child);
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder<List<ProviderAppointment>>(
        valueListenable: ProviderAppointmentRepository.appointments,
        builder: (context, _, __) {
          final a = ProviderAppointmentRepository.byId(id);

          if (a == null) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: Text('الموعد غير موجود')),
            );
          }

          final showPhone = a.status == ProviderApptStatus.confirmed &&
              a.phone.isNotEmpty;
          final showMedical = a.status == ProviderApptStatus.confirmed;
          final showLocked = a.status == ProviderApptStatus.pending;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        _patientCard(a),
                        if (showPhone) ...[
                          const SizedBox(height: 16),
                          _card([
                            _infoRow(
                              Icons.phone_outlined,
                              'للتواصل مع المريض',
                              a.phone,
                              last: true,
                              ltr: true,
                            ),
                          ]),
                        ],
                        const SizedBox(height: 24),
                        _title('معلومات الزيارة'),
                        _visitInfo(a),
                        if (showLocked) ...[
                          const SizedBox(height: 24),
                          _lockedMedical(),
                        ],
                        if (showMedical) ...[
                          const SizedBox(height: 24),
                          _medicalRecord(a.medical),
                        ],
                      ],
                    ),
                  ),
                  if (_bottomBar(context, a) != null) _bottomBar(context, a)!,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── نافذة سبب الرفض ─────────────────────────
class _DeclineSheet extends StatefulWidget {
  const _DeclineSheet();

  @override
  State<_DeclineSheet> createState() => _DeclineSheetState();
}

class _DeclineSheetState extends State<_DeclineSheet> {
  static const List<String> _reasons = [
    'لدي موعد آخر في هذا الوقت',
    'الموقع بعيد عن منطقة عملي',
    'الخدمة خارج تخصصي',
    'سبب آخر',
  ];

  final _otherCtrl = TextEditingController();
  int? _selected;

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  bool get _isOther => _selected == _reasons.length - 1;

  String get _result {
    if (_isOther && _otherCtrl.text.trim().isNotEmpty) {
      return _otherCtrl.text.trim();
    }
    return _reasons[_selected!];
  }

  Widget _option(int i) {
    final on = _selected == i;
    final color = on ? AppColors.primary600 : AppColors.border;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = i),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: on ? AppColors.primary50 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: on
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary600,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _reasons[i],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 16 + inset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'سبب رفض الطلب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر السبب وسيصل إلى المريض مع إشعار الرفض.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.neutralDark,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < _reasons.length; i++) ...[
                _option(i),
                const SizedBox(height: 8),
              ],
              if (_isOther) ...[
                TextField(
                  controller: _otherCtrl,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDarkActive,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب السبب (اختياري)',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutralDark,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
                           Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'رفض الطلب',
                      backgroundColor: AppColors.error700,
                      onPressed: _selected == null
                          ? null
                          : () => Navigator.pop(context, _result),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      text: 'إلغاء',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.neutralDarkActive,
                      borderColor: AppColors.border,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}