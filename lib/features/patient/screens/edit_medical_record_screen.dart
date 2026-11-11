// lib/features/patient/screens/edit_medical_record_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/medical_record_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

// ───────────────────────── عناصر مشتركة بين الصفحة والنافذة ─────────────────────────
const TextStyle _inputStyle =
    TextStyle(fontSize: 13, color: AppColors.neutralDarkActive);

OutlineInputBorder _outline(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );

InputDecoration _decoration(String hint, {Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutralNormal),
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
      enabledBorder: _outline(AppColors.border),
      focusedBorder: _outline(AppColors.primary500),
      errorBorder: _outline(AppColors.error700),
      focusedErrorBorder: _outline(AppColors.error700),
      errorStyle: const TextStyle(fontSize: 11, color: AppColors.error700),
    );

Widget _label(String text, {String? hint}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      TextSpan(
        text: text,
        children: [
          if (hint != null)
            TextSpan(
              text: ' $hint',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: AppColors.neutralDark,
              ),
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

/// زر اختيار (فصيلة الدم، الأمراض، عدد المرات...)
Widget _choice(String text, bool selected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary50 : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.primary500 : AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary800 : AppColors.neutralDarkActive,
        ),
      ),
    ),
  );
}

// ───────────────────────── الصفحة ─────────────────────────
class EditMedicalRecordScreen extends StatefulWidget {
  const EditMedicalRecordScreen({super.key});

  @override
  State<EditMedicalRecordScreen> createState() =>
      _EditMedicalRecordScreenState();
}

class _EditMedicalRecordScreenState extends State<EditMedicalRecordScreen> {
  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  static const _chronicOptions = [
    'السكري',
    'ضغط الدم',
    'أمراض القلب',
    'الربو',
    'أمراض الكلى',
  ];

  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  final _ecNameCtrl = TextEditingController();
  final _ecRelationCtrl = TextEditingController();
  final _ecPhoneCtrl = TextEditingController();

  String? _bloodType;
  final Set<String> _chronic = {};
  bool _otherSelected = false;
  final List<String> _allergies = [];
  final List<Medication> _meds = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // نعبّي الحقول بالسجل الحالي
    final r = MedicalRecordRepository.current.value;
    _bloodType = r.bloodType;
    _heightCtrl.text = r.heightCm?.toString() ?? '';
    _weightCtrl.text = r.weightKg?.toString() ?? '';

    final others = <String>[];
    for (final d in r.chronicDiseases) {
      _chronicOptions.contains(d) ? _chronic.add(d) : others.add(d);
    }
    if (others.isNotEmpty) {
      _otherSelected = true;
      _otherCtrl.text = others.join('، ');
    }

    _allergies.addAll(r.allergies);
    _meds.addAll(r.medications);

    final c = r.emergencyContact;
    if (c != null) {
      _ecNameCtrl.text = c.name;
      _ecRelationCtrl.text = c.relation;
      _ecPhoneCtrl.text = c.phone;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _heightCtrl,
      _weightCtrl,
      _otherCtrl,
      _allergyCtrl,
      _ecNameCtrl,
      _ecRelationCtrl,
      _ecPhoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ───────────────────────── الأفعال ─────────────────────────
  void _addAllergy() {
    final text = _allergyCtrl.text.trim();
    if (text.isEmpty || _allergies.contains(text)) return;
    setState(() {
      _allergies.add(text);
      _allergyCtrl.clear();
    });
  }

  Future<void> _addMedication() async {
    final med = await showDialog<Medication>(
      context: context,
      builder: (_) => const _AddMedicationDialog(),
    );
    if (med != null) setState(() => _meds.add(med));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final chronic = [
      ..._chronic,
      if (_otherSelected && _otherCtrl.text.trim().isNotEmpty)
        _otherCtrl.text.trim(),
    ];
    final ecName = _ecNameCtrl.text.trim();
    final ecPhone = _ecPhoneCtrl.text.trim();

    setState(() => _saving = true);
    try {
      await MedicalRecordRepository.save(
        MedicalRecord(
          bloodType: _bloodType,
          heightCm: int.tryParse(_heightCtrl.text.trim()),
          weightKg: int.tryParse(_weightCtrl.text.trim()),
          chronicDiseases: chronic,
          allergies: List.of(_allergies),
          medications: List.of(_meds),
          emergencyContact: (ecName.isEmpty && ecPhone.isEmpty)
              ? null
              : EmergencyContact(
                  name: ecName,
                  relation: _ecRelationCtrl.text.trim(),
                  phone: ecPhone,
                ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;
    await _showSaved();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showSaved() {
    return showDialog<void>(
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
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 28,
                    color: AppColors.primary700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم حفظ السجل الطبي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم تحديث معلوماتك الطبية بنجاح.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
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

  // ───────────────────────── الأقسام ─────────────────────────
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _bloodTypeSection() {
    Widget row(List<String> types) => Row(
          children: [
            for (int i = 0; i < types.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _choice(
                  types[i],
                  _bloodType == types[i],
                  () => setState(() => _bloodType = types[i]),
                ),
              ),
            ],
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('فصيلة الدم'),
        row(_bloodTypes.sublist(0, 4)),
        const SizedBox(height: 8),
        row(_bloodTypes.sublist(4)),
      ],
    );
  }

  String? _numberValidator(String? v, int min, int max) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return null; // اختياري
    final n = int.tryParse(text);
    if (n == null || n < min || n > max) return 'رقم غير صحيح';
    return null;
  }

  Widget _heightWeight() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('الطول (سم)'),
              TextFormField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                style: _inputStyle,
                decoration: _decoration('مثال: 170'),
                validator: (v) => _numberValidator(v, 50, 250),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('الوزن (كغ)'),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                style: _inputStyle,
                decoration: _decoration('مثال: 70'),
                validator: (v) => _numberValidator(v, 2, 300),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chronicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('الأمراض المزمنة'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in _chronicOptions)
              _choice(
                d,
                _chronic.contains(d),
                () => setState(() {
                  _chronic.contains(d) ? _chronic.remove(d) : _chronic.add(d);
                }),
              ),
            _choice(
              'أخرى',
              _otherSelected,
              () => setState(() => _otherSelected = !_otherSelected),
            ),
          ],
        ),
        if (_otherSelected) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _otherCtrl,
            style: _inputStyle,
            decoration: _decoration('اكتب اسم المرض'),
          ),
        ],
      ],
    );
  }

    Widget _allergyChip(String text) {
    return Container(
      padding: const EdgeInsets.only(right: 12, left: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary800,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _allergies.remove(text)),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _allergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('الحساسية'),
        if (_allergies.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final a in _allergies) _allergyChip(a)],
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _allergyCtrl,
          style: _inputStyle,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addAllergy(),
          decoration: _decoration(
            'أضف حساسية، مثل: دواء أو طعام',
            suffix: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: AppColors.primary600,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _addAllergy,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _medicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('الأدوية الحالية'),
        if (_meds.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _meds.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medication_outlined,
                            size: 20,
                            color: AppColors.primary600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _meds[i].title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutralDarkActive,
                                ),
                              ),
                              Text(
                                _meds[i].schedule,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'حذف الدواء',
                          onPressed: () => setState(() => _meds.removeAt(i)),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppColors.error700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        AppButton(
          height: 44,
          fontSize: 13,
          icon: Icons.add_rounded,
          text: 'إضافة دواء',
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary800,
          borderColor: AppColors.primary200,
          onPressed: _addMedication,
        ),
      ],
    );
  }

  Widget _emergencySection() {
    String? requiredIfOther(String? v, TextEditingController other) {
      final text = v?.trim() ?? '';
      if (text.isEmpty && other.text.trim().isNotEmpty) return 'هذا الحقل مطلوب';
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('جهة اتصال للطوارئ'),
        _label('الاسم'),
        TextFormField(
          controller: _ecNameCtrl,
          textInputAction: TextInputAction.next,
          style: _inputStyle,
          decoration: _decoration('مثال: سارة خالد'),
          validator: (v) => requiredIfOther(v, _ecPhoneCtrl),
        ),
        const SizedBox(height: 16),
        _label('صلة القرابة'),
        TextFormField(
          controller: _ecRelationCtrl,
          textInputAction: TextInputAction.next,
          style: _inputStyle,
          decoration: _decoration('مثال: الأخت'),
        ),
        const SizedBox(height: 16),
        _label('رقم الهاتف'),
        TextFormField(
          controller: _ecPhoneCtrl,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: _inputStyle,
          decoration: _decoration('+970 59 000 0000'),
          validator: (v) => requiredIfOther(v, _ecNameCtrl),
        ),
      ],
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
          foregroundColor: AppColors.neutralDarkActive,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            'تعديل السجل الطبي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _bloodTypeSection(),
              const SizedBox(height: 24),
              _heightWeight(),
              const SizedBox(height: 24),
              _chronicSection(),
              const SizedBox(height: 24),
              _allergiesSection(),
              const SizedBox(height: 24),
              _medicationsSection(),
              const SizedBox(height: 24),
              _emergencySection(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              fontSize: 15,
              text: _saving ? 'جارٍ الحفظ...' : 'حفظ السجل الطبي',
              onPressed: _saving ? null : _save,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── نافذة إضافة دواء ─────────────────────────
class _AddMedicationDialog extends StatefulWidget {
  const _AddMedicationDialog();

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  static const _frequencies = [
    'مرة يومياً',
    'مرتين يومياً',
    '3 مرات يومياً',
    'عند الحاجة',
  ];
  static const _timings = ['قبل الأكل', 'بعد الأكل', 'صباحاً', 'مساءً'];

  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  String? _frequency;
  String? _timing;

  bool get _valid => _nameCtrl.text.trim().isNotEmpty && _frequency != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      Medication(
        name: _nameCtrl.text.trim(),
        dose: _doseCtrl.text.trim(),
        frequency: _frequency!,
        timing: _timing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    size: 26,
                    color: AppColors.primary700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'إضافة دواء',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _label('اسم الدواء'),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                style: _inputStyle,
                decoration: _decoration('مثال: ميتفورمين'),
              ),
              const SizedBox(height: 16),
              _label('الجرعة'),
              TextField(
                controller: _doseCtrl,
                style: _inputStyle,
                decoration: _decoration('مثال: 500 ملغ'),
              ),
              const SizedBox(height: 16),
              _label('عدد المرات'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in _frequencies)
                    _choice(
                      f,
                      _frequency == f,
                      () => setState(() => _frequency = f),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _label('التوقيت', hint: '(اختياري)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _timings)
                    _choice(
                      t,
                      _timing == t,
                      // الضغط مرة ثانية يلغي الاختيار
                      () => setState(() => _timing = _timing == t ? null : t),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      height: 44,
                      fontSize: 13,
                      text: 'إضافة',
                      onPressed: _valid ? _submit : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      height: 44,
                      fontSize: 13,
                      text: 'إلغاء',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary800,
                      borderColor: AppColors.primary200,
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