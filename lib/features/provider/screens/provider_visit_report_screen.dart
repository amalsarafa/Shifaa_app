// lib/features/provider/screens/provider_visit_report_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

class ProviderVisitReportScreen extends StatefulWidget {
  const ProviderVisitReportScreen({super.key});

  @override
  State<ProviderVisitReportScreen> createState() =>
      _ProviderVisitReportScreenState();
}

class _ProviderVisitReportScreenState extends State<ProviderVisitReportScreen> {
  static const Color _border = AppColors.border;

  final _summary = TextEditingController();
  final _bp = TextEditingController();
  final _sugar = TextEditingController();
  final _temp = TextEditingController();
  final _pulse = TextEditingController();
  final _reco = TextEditingController();

  final Set<String> _procedures = {};
  bool _followUp = false;
  bool _cash = false;

  @override
  void dispose() {
    _summary.dispose();
    _bp.dispose();
    _sugar.dispose();
    _temp.dispose();
    _pulse.dispose();
    _reco.dispose();
    super.dispose();
  }

  bool get _canSave => _summary.text.trim().isNotEmpty && _cash;

  List<String> _options(String service) {
    if (service.contains('علاج')) {
      return [
        'جلسة علاج طبيعي',
        'تمارين تأهيلية',
        'تدليك علاجي',
        'تقييم الحركة',
        'أخرى',
      ];
    }
    return ['حقن عضلي', 'قياس الضغط', 'تغيير ضمادة', 'قياس السكر', 'أخرى'];
  }

  Future<void> _save(String id) async {
    // 🔥 لاحقاً: رفع التقرير إلى Firebase (ومسودة تُحفظ تلقائياً)
    ProviderAppointmentRepository.saveReport(
      id,
      VisitReport(
        summary: _summary.text.trim(),
        procedures: _procedures.toList(),
        bloodPressure: _bp.text.trim(),
        sugar: _sugar.text.trim(),
        temperature: _temp.text.trim(),
        pulse: _pulse.text.trim(),
        recommendations: _reco.text.trim(),
        followUp: _followUp,
        cashReceived: _cash,
        writtenAt: 'اليوم',
      ),
    );

    await showProviderDialog(
      context,
      title: 'تم حفظ التقرير',
      message: 'انتهت الزيارة وأصبحت ضمن المواعيد المكتملة.',
      confirmText: 'حسناً',
    );

    if (mounted) Navigator.pop(context);
  }

  // ───────────────────────── مكونات ─────────────────────────
  InputDecoration _decoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary600),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error700),
              ),
          ],
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    bool required = false,
    int lines = 1,
    String hint = '',
    TextInputType? type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        TextField(
          controller: c,
          keyboardType: type,
          minLines: lines,
          maxLines: lines == 1 ? 1 : lines + 2,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.neutralDarkActive,
          ),
          decoration: _decoration(hint),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, {String? sub}) {
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

  Widget _procedureChip(String text) {
    final on = _procedures.contains(text);

    return GestureDetector(
      onTap: () => setState(() {
        on ? _procedures.remove(text) : _procedures.add(text);
      }),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppColors.primary50 : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: on ? AppColors.primary600 : AppColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: on ? AppColors.primary800 : AppColors.neutralDarkActive,
          ),
        ),
      ),
    );
  }

  Widget _vitals() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _field('ضغط الدم', _bp, hint: '120/80')),
            const SizedBox(width: 8),
            Expanded(
              child: _field(
                'السكر (mg/dL)',
                _sugar,
                hint: '110',
                type: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                'الحرارة (°م)',
                _temp,
                hint: '36.8',
                type: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _field(
                'النبض (نبضة/د)',
                _pulse,
                hint: '78',
                type: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _followUpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحديد موعد متابعة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                Text(
                  'اقتراح موعد زيارة قادمة للمريض',
                  style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
                ),
              ],
            ),
          ),
          Switch(
            value: _followUp,
            onChanged: (v) => setState(() => _followUp = v),
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary600,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _cashCard(int price) {
    return GestureDetector(
      onTap: () => setState(() => _cash = !_cash),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cash ? AppColors.primary50 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _cash ? AppColors.primary600 : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _cash ? AppColors.primary600 : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _cash ? AppColors.primary600 : AppColors.neutralNormal,
                  width: 2,
                ),
              ),
              child: _cash
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم استلام $price ₪ نقدًا من المريض',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary800,
                    ),
                  ),
                  const Text(
                    'مطلوب لإنهاء الزيارة',
                    style: TextStyle(fontSize: 12, color: AppColors.primary800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final a = ProviderAppointmentRepository.byId(id);

    if (a == null) {
      return const Scaffold(body: Center(child: Text('الموعد غير موجود')));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
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
                        'تقرير الزيارة',
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
              ),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    // بطاقة المريض المختصرة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
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
                              a.patientName.trim().isEmpty
                                  ? '?'
                                  : a.patientName.trim()[0],
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(
                      'ملخص الزيارة',
                      _summary,
                      required: true,
                      lines: 3,
                      hint: 'اكتب ما تم في الزيارة',
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('الإجراءات المنفذة'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in _options(a.service)) _procedureChip(o),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('القياسات الحيوية', sub: 'اختيارية'),
                    _vitals(),
                    const SizedBox(height: 24),
                    _field(
                      'توصيات وملاحظات',
                      _reco,
                      lines: 3,
                      hint: 'نصائح أو متابعة مطلوبة',
                    ),
                    const SizedBox(height: 16),
                    _followUpCard(),
                    const SizedBox(height: 24),
                    _sectionTitle('استلام المبلغ'),
                    _cashCard(a.price),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  text: 'حفظ التقرير وإنهاء الزيارة',
                  onPressed: _canSave ? () => _save(id) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}