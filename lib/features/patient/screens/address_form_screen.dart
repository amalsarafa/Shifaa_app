// lib/features/patient/screens/address_form_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/constants/gaza_governorates.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/core/widgets/success_check.dart';
import 'package:my_first_app/features/patient/services/address_model.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

/// إضافة عنوان جديد، أو تعديل عنوان (نرسل رقمه في arguments)
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  static const TextStyle _inputStyle =
      TextStyle(fontSize: 13, color: AppColors.neutralDarkActive);

  final _formKey = GlobalKey<FormState>();
  String? _governorate; // id المحافظة
  final _detailsCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int? _index; // null = عنوان جديد
  Address? _original;
  bool _makeDefault = false;
  bool _originalDefault = false;
  bool _defaultLocked = false;
  bool _ready = false;
  bool _saving = false;

  bool get _isEdit => _index != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;

    final patient = PatientRepository.current.value;
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg is int && arg < patient.addresses.length) {
      // تعديل: نعبّي الحقول بالعنوان الحالي
      _index = arg;
      _original = patient.addresses[arg];
      // بيانات قديمة بمنطقة مش من المحافظات: نتركها فاضية
      final areaId = _original!.areaId;
      _governorate = governorateName(areaId).isEmpty ? null : areaId;
      _detailsCtrl.text = _original!.details;
      _landmarkCtrl.text = _original!.landmark ?? '';
      _notesCtrl.text = _original!.notes ?? '';
      _makeDefault = arg == patient.defaultAddressIndex;
      _originalDefault = _makeDefault;
      _defaultLocked = _makeDefault; // الافتراضي يتغير من صفحة العناوين
      // نعيد البناء مع كل كتابة لتحديث زر الحفظ
      for (final c in [_detailsCtrl, _landmarkCtrl, _notesCtrl]) {
        c.addListener(_onEdit);
      }
    } else {
      // أول عنوان يكون افتراضياً دائماً
      _makeDefault = patient.addresses.isEmpty;
      _defaultLocked = patient.addresses.isEmpty;
    }
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _landmarkCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onEdit() => setState(() {});

  /// عند التعديل: هل في تغيير حقيقي؟ (الإضافة دايماً مسموحة)
  bool get _hasChanges {
    final o = _original;
    if (!_isEdit || o == null) return true;
    return _governorate != o.areaId ||
        _detailsCtrl.text.trim() != o.details.trim() ||
        _landmarkCtrl.text.trim() != (o.landmark ?? '').trim() ||
        _notesCtrl.text.trim() != (o.notes ?? '').trim() ||
        _makeDefault != _originalDefault;
  }

  // ───────────────────────── الحفظ ─────────────────────────
  Future<void> _save() async {
    if (!_hasChanges) return; // ما في شي يتحفظ
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final governorate = _governorate!; // التحقق يضمن إنها مختارة
      final notes = _notesCtrl.text.trim();
      final address = Address(
        id: _original?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: governorateName(governorate),
        details: _detailsCtrl.text.trim(),
        areaId: governorate,
        landmark: _landmarkCtrl.text.trim(),
        notes: notes.isEmpty ? null : notes,
        latitude: _original?.latitude,
        longitude: _original?.longitude,
      );

      if (_isEdit) {
        await PatientRepository.updateAddress(
          _index!,
          address,
          makeDefault: _makeDefault,
        );
      } else {
        await PatientRepository.addAddress(address, makeDefault: _makeDefault);
      }
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
                const SuccessCheck(size: 64),
                const SizedBox(height: 8),
                Text(
                  _isEdit ? 'تم حفظ التعديلات' : 'تمت إضافة العنوان',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يمكنك اختيار هذا العنوان عند حجز أي خدمة.',
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

  // ───────────────────────── عناصر الشكل ─────────────────────────
  OutlineInputBorder _outline(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: AppColors.neutralNormal),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, hint: optional ? '(اختياري)' : null),
          TextFormField(
            controller: controller,
            textInputAction: TextInputAction.next,
            style: _inputStyle,
            decoration: _decoration(hint),
            validator: optional
                ? null
                : (v) => (v == null || v.trim().isEmpty)
                    ? 'هذا الحقل مطلوب'
                    : null,
          ),
        ],
      ),
    );
  }

  /// قائمة المحافظات بنفس شكل باقي الحقول
  Widget _governorateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('المحافظة'),
          DropdownButtonFormField<String>(
            initialValue: _governorate,
            isExpanded: true,
            style: _inputStyle,
            borderRadius: BorderRadius.circular(16),
            dropdownColor: AppColors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary600,
            ),
            decoration: _decoration('اختر المحافظة'),
            items: [
              for (final g in gazaGovernorates)
                DropdownMenuItem(value: g.id, child: Text(g.name)),
            ],
            onChanged: (v) => setState(() => _governorate = v),
            validator: (v) => v == null ? 'هذا الحقل مطلوب' : null,
          ),
        ],
      ),
    );
  }

  /// صورة ثابتة للخريطة حالياً، ولاحقاً نستبدلها بخريطة حقيقية
  Widget _mapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('الموقع على الخريطة', hint: '(اختياري)'),
        Container(
          height: 176,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/patient/map_preview.png',
              width: double.infinity,
              height: 176,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: AppColors.primary50),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'يساعد مقدم الرعاية على الوصول إلى منزلك بسهولة.',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _defaultSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'تعيين كعنوان افتراضي',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ),
            Switch(
              value: _makeDefault,
              onChanged: _defaultLocked
                  ? null
                  : (v) => setState(() => _makeDefault = v),
              thumbColor: const WidgetStatePropertyAll(AppColors.white),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary600
                    : AppColors.neutralLightActive,
              ),
              trackOutlineColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),
        if (_defaultLocked)
          const Text(
            'هذا هو عنوانك الافتراضي حالياً.',
            style: TextStyle(fontSize: 11, color: AppColors.neutralDark),
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
          title: Text(
            _isEdit ? 'تعديل العنوان' : 'إضافة عنوان',
            style: const TextStyle(
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
              _mapPreview(),
              const SizedBox(height: 16),
              _governorateField(),
              _field(
                label: 'العنوان بالتفصيل',
                controller: _detailsCtrl,
                hint: 'الشارع، البناية، الطابق',
              ),
              _field(
                label: 'أقرب معلم',
                controller: _landmarkCtrl,
                hint: 'مثال: مقابل صيدلية، بجانب مسجد',
              ),
              _field(
                label: 'ملاحظات للوصول',
                controller: _notesCtrl,
                hint: 'مثال: اتصل عند الوصول',
                optional: true,
              ),
              _defaultSwitch(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            // عند التعديل: معطّل لحد ما يصير تغيير، وأثناء الحفظ
            child: IgnorePointer(
              ignoring: !_hasChanges || _saving,
              child: Opacity(
                opacity: _hasChanges ? 1 : 0.5,
                child: AppButton(
                  fontSize: 15,
                  text: _saving ? 'جارٍ الحفظ...' : 'حفظ العنوان',
                  onPressed: _save,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}