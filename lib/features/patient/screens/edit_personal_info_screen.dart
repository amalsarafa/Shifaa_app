// lib/features/patient/screens/edit_personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/patient/widgets/patient_avatar.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  static const Color _border = AppColors.border;
  static const TextStyle _inputStyle = TextStyle(
    fontSize: 13,
    color: AppColors.neutralDarkActive,
  );

  final _formKey = GlobalKey<FormState>();
  late final Patient _patient;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  String? _gender;
  DateTime? _birthDate;
  String? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // نعبّي الحقول بالمعلومات الحالية
    _patient = PatientRepository.current.value;
    _nameCtrl = TextEditingController(text: _patient.name);
    _emailCtrl = TextEditingController(text: _patient.email ?? '');
    _gender = _patient.gender;
    _birthDate = _patient.birthDate;
    _photo = _patient.photo;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── الأفعال ─────────────────────────
  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (picked == null) return; // أغلق المعرض بدون اختيار
    setState(() => _photo = picked.path);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'اختر تاريخ الميلاد',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary600,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.neutralDarkActive,
          ),
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return; // يوجد خطأ في الحقول

    setState(() => _saving = true);
    try {
      final email = _emailCtrl.text.trim();
      await PatientRepository.updateInfo(
        name: _nameCtrl.text.trim(),
        email: email.isEmpty ? null : email,
        gender: _gender,
        birthDate: _birthDate,
      );
      if (_photo != _patient.photo) {
        await PatientRepository.updatePhoto(_photo);
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
                  'تم حفظ التغييرات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم تحديث معلوماتك الشخصية بنجاح.',
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

  InputDecoration _decoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
    filled: true,
    fillColor: AppColors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: _outline(_border),
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

  Widget _avatar() {
    return Column(
      children: [
        PatientAvatar(
          name: _patient.name,
          photo: _photo,
          size: 96,
          onTap: _pickPhoto, // تظهر أيقونة الكاميرا هنا فقط
        ),
        TextButton(
          onPressed: _pickPhoto,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary600),
          child: const Text(
            'تغيير الصورة',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.neutralLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _patient.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralNormal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.neutralNormal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'رقم الهاتف مرتبط بتسجيل الدخول، ولا يمكن تغييره حالياً.',
          style: TextStyle(fontSize: 11, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _genderOption(String value) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary50 : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary500 : _border,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.primary800
                  : AppColors.neutralDarkActive,
            ),
          ),
        ),
      ),
    );
  }

  Widget _birthDateField() {
    final empty = _birthDate == null;
    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? 'اختر التاريخ' : Patient.formatDate(_birthDate!),
                style: TextStyle(
                  fontSize: 13,
                  color: empty
                      ? AppColors.neutralDark
                      : AppColors.neutralDarkActive,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.primary600,
            ),
          ],
        ),
      ),
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.neutralDarkActive,
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تعديل الملف الشخصي',
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
              _avatar(),
              const SizedBox(height: 16),
              _label('الاسم الكامل'),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                style: _inputStyle,
                decoration: _decoration(hint: 'اكتب اسمك الكامل'),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'اكتب الاسم الكامل'
                    : null,
              ),
              const SizedBox(height: 16),
              _label('رقم الهاتف'),
              _phoneField(),
              const SizedBox(height: 16),
              _label('البريد الإلكتروني', hint: '(اختياري)'),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: _inputStyle,
                decoration: _decoration(hint: 'example@email.com'),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return null; // اختياري
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(text);
                  return ok ? null : 'البريد الإلكتروني غير صحيح';
                },
              ),
              const SizedBox(height: 16),
              _label('الجنس'),
              Row(
                children: [
                  _genderOption('ذكر'),
                  const SizedBox(width: 8),
                  _genderOption('أنثى'),
                ],
              ),
              const SizedBox(height: 16),
              _label('تاريخ الميلاد'),
              _birthDateField(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              fontSize: 15,
              text: _saving ? 'جارٍ الحفظ...' : 'حفظ التغييرات',
              onPressed: _saving ? null : _save, // يتعطل أثناء الحفظ
            ),
          ),
        ),
      ),
    );
  }
}
