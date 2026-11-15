// lib/features/patient/widgets/confirm_visit_sheet.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/core/widgets/success_check.dart';
import 'package:my_first_app/features/patient/services/appointment_model.dart';
import 'package:my_first_app/features/patient/services/appointment_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/patient/widgets/appointment_card.dart';

/// مراحل الحوار داخل نفس الـ sheet
enum _Step { question, rate, report, reported }

/// حوار "هل تمت زيارتك؟" بعد أن ينهي مقدم الرعاية الزيارة
class ConfirmVisitSheet extends StatefulWidget {
  final Appointment appointment;

  const ConfirmVisitSheet({super.key, required this.appointment});

  /// يفتح الحوار من أي شاشة.
  /// يُرجع الحالة الجديدة (completed أو notDone) إذا تغيّرت، وإلا null.
  static Future<AppointmentStatus?> show(
    BuildContext context,
    Appointment appointment,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ConfirmVisitSheet(appointment: appointment),
    );

    // نقرأ الحالة من المستودع، فتعمل حتى لو سُحب الحوار للأسفل
    final now = AppointmentRepository.appointments.value
        .where((a) => a.id == appointment.id)
        .firstOrNull;
    final status = now?.status;
    return status == appointment.status ? null : status;
  }

  @override
  State<ConfirmVisitSheet> createState() => _ConfirmVisitSheetState();
}

class _ConfirmVisitSheetState extends State<ConfirmVisitSheet> {
  static const List<String> _reasons = [
    'لم يحضر مقدم الرعاية',
    'حضر متأخراً جداً',
    'لم تُقدَّم الخدمة كاملة',
    'سبب آخر',
  ];

  final _commentCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();

  _Step _step = _Step.question;
  int _rating = 0;
  int? _reason;

  Appointment get _a => widget.appointment;
  bool get _isOther => _reason == _reasons.length - 1;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── الإجراءات ─────────────────────────
  void _yes() {
    AppointmentRepository.confirmVisit(_a.id);
    setState(() => _step = _Step.rate);
  }

  void _submitRating() {
    AppointmentRepository.rate(
      _a.id,
      _rating.toDouble(),
      _commentCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  void _submitReport() {
    final other = _otherCtrl.text.trim();
    final reason = _isOther && other.isNotEmpty ? other : _reasons[_reason!];
    AppointmentRepository.reportVisitNotDone(_a.id, reason);
    setState(() => _step = _Step.reported);
  }

  // ───────────────────────── مكونات مشتركة ─────────────────────────
  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.neutralLightActive,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _title(String text, {double size = 18}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: AppColors.primary800,
      ),
    );
  }

  Widget _message(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13,
        height: 1.6,
        color: AppColors.neutralDark,
      ),
    );
  }

  Widget _laterButton({VoidCallback? onPressed, String label = 'لاحقاً'}) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.neutralDark,
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );

  Widget _textField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      maxLines: 3,
      style: const TextStyle(fontSize: 13, color: AppColors.neutralDarkActive),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
        contentPadding: const EdgeInsets.all(16),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary600),
      ),
    );
  }

  // ───────────────────────── أ) السؤال ─────────────────────────
  Widget _providerCard() {
    final p = _a.provider;
    final n = p.name.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                p.image,
                fit: BoxFit.cover,
                cacheWidth: 144,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primary50,
                  alignment: Alignment.center,
                  child: Text(
                    n.isEmpty ? '?' : n[0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  '${_a.service.title} · ${AppointmentFormat.date(_a.date)}، '
                  '${AppointmentFormat.time(_a.time)}',
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
        ],
      ),
    );
  }

  Widget _questionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_available_outlined,
            size: 32,
            color: AppColors.primary700,
          ),
        ),
        const SizedBox(height: 16),
        _title('هل تمت زيارتك؟'),
        const SizedBox(height: 8),
        _message(
          'أنهت مقدمة الرعاية الزيارة من جهتها. تأكيدك يساعدنا نضمن جودة الخدمة.',
        ),
        const SizedBox(height: 16),
        _providerCard(),
        const SizedBox(height: 16),
        AppButton(
          height: 48,
          fontSize: 14,
          text: 'نعم، تمت الزيارة',
          onPressed: _yes,
        ),
        const SizedBox(height: 8),
        AppButton(
          height: 48,
          fontSize: 14,
          text: 'لا، لم تتم',
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.error700,
          borderColor: AppColors.error100,
          onPressed: () => setState(() => _step = _Step.report),
        ),
      ],
    );
  }

  // ───────────────────────── ب) تم التأكيد + التقييم ─────────────────────────
  Widget _rateView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SuccessCheck(size: 80),
        const SizedBox(height: 16),
        _title('تم تأكيد الزيارة!', size: 20),
        const SizedBox(height: 8),
        _message(
          'أُضيفت الزيارة إلى سجلك. كيف كانت تجربتك مع ${_a.provider.name}؟',
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
                size: 36,
                color: value <= _rating ? AppColors.star : AppColors.border,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        _textField(_commentCtrl, 'أضف تعليقاً (اختياري)'),
        const SizedBox(height: 16),
        AppButton(
          height: 48,
          fontSize: 14,
          text: 'إرسال التقييم',
          onPressed: _rating == 0 ? null : _submitRating,
        ),
        const SizedBox(height: 8),
        _laterButton(),
      ],
    );
  }

  // ───────────────────────── ج) لم تتم الزيارة ─────────────────────────
  Widget _option(int i) {
    final on = _reason == i;
    final color = on ? AppColors.primary500 : AppColors.border;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _reason = i),
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
                        color: AppColors.primary500,
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

  Widget _reportView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('ما الذي حدث؟'),
        const SizedBox(height: 8),
        _message('اختر السبب، وسيراجع فريق شفاء الطلب ويتواصل معك.'),
        const SizedBox(height: 16),
        for (var i = 0; i < _reasons.length; i++) ...[
          _option(i),
          const SizedBox(height: 8),
        ],
        if (_isOther) ...[
          _textField(_otherCtrl, 'اكتب ما حدث'),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        AppButton(
          height: 48,
          fontSize: 14,
          text: 'إرسال',
          backgroundColor: AppColors.error600,
          onPressed: _reason == null ? null : _submitReport,
        ),
        const SizedBox(height: 8),
        _laterButton(
          label: 'رجوع',
          onPressed: () => setState(() => _step = _Step.question),
        ),
      ],
    );
  }

  // ───────────────────────── د) تم إرسال البلاغ ─────────────────────────
  Widget _reportedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SuccessCheck(size: 80),
        const SizedBox(height: 16),
        _title('تم إرسال بلاغك', size: 20),
        const SizedBox(height: 8),
        _message(
          'سيراجع فريق شفاء ما حدث ويتواصل معك قريباً. لن يتم احتساب هذه الزيارة.',
        ),
        const SizedBox(height: 16),
        AppButton(
          height: 48,
          fontSize: 14,
          text: 'حسناً',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    final Widget body = switch (_step) {
      _Step.question => _questionView(),
      _Step.rate => _rateView(),
      _Step.report => _reportView(),
      _Step.reported => _reportedView(),
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + inset),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _handle(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: KeyedSubtree(key: ValueKey(_step), child: body),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
