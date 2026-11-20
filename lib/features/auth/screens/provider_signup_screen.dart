// lib/features/auth/screens/provider_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_app/core/constants/gaza_governorates.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/screens/verification_screen.dart';
import 'package:my_first_app/features/auth/services/auth_role_repository.dart';
import 'package:my_first_app/features/auth/widgets/join_stepper.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';

/// خيارات الانضمام 🔥 Firebase/Supabase: تُقرأ من قاعدة البيانات لاحقًا
class ProviderJoinOptions {
  ProviderJoinOptions._();

  static const List<String> specialties = ['التمريض', 'العلاج الطبيعي'];

  static const List<String> services = [
    'الحقن',
    'العناية بالجروح',
    'رعاية كبار السن',
  ];
}

/// معالج انضمام مقدم الرعاية: 3 خطوات في شاشة واحدة
class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  static const List<String> _stepLabels = [
    'المعلومات الشخصية',
    'الخبرة والمهارات',
    'المستندات',
  ];

  int _step = 0; // 0..2

  // ── الخطوة 1
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _governorate;

  // ── الخطوة 2
  String? _specialty;
  final _bioCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final Set<String> _services = {};
  bool _otherService = false;
  final _otherCtrl = TextEditingController();

  // ── الخطوة 3: مسارات الصور من الجهاز
  String? _licensePath;
  String? _idPhotoPath;
  String? _photoPath;
  bool _agreed = false;

  /// رسائل الخطأ تحت كل حقل (المفتاح = اسم الحقل)
  final Map<String, String> _errors = {};

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _idCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _bioCtrl,
      _yearsCtrl,
      _otherCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ───────────────────────── التنقل والتحقق ─────────────────────────
  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _errors.clear();
      _step--;
    });
  }

  /// يشيل الصفر من البداية مثل شاشة الدخول (059... ← 59...)
  String get _phone {
    final p = _phoneCtrl.text.trim();
    return p.startsWith('0') ? p.substring(1) : p;
  }

  bool _validateStep1() {
    final e = <String, String>{};
    if (_nameCtrl.text.trim().isEmpty) e['name'] = 'اكتب الاسم الكامل';
    if (_idCtrl.text.trim().length != 9) {
      e['id'] = 'رقم الهوية يتكوّن من 9 أرقام';
    }
    if (_phone.length != 9) e['phone'] = 'أدخل رقم هاتف صحيح مكوّن من 9 أرقام';
    // البريد اختياري: نتحقق من الصيغة فقط إن كُتب
    final email = _emailCtrl.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      e['email'] = 'صيغة البريد الإلكتروني غير صحيحة';
    }
    if (_governorate == null) e['governorate'] = 'اختر المحافظة';
    if (_addressCtrl.text.trim().isEmpty) e['address'] = 'اكتب العنوان التفصيلي';
    setState(() => _errors
      ..clear()
      ..addAll(e));
    return e.isEmpty;
  }

  bool _validateStep2() {
    final e = <String, String>{};
    if (_specialty == null) e['specialty'] = 'اختر التخصص';
    if (_bioCtrl.text.trim().length < 20) {
      e['bio'] = 'اكتب نبذة من 20 حرفًا على الأقل';
    }
    if (_yearsCtrl.text.trim().isEmpty) e['years'] = 'اكتب سنوات الخبرة';
    final hasOther = _otherService && _otherCtrl.text.trim().isNotEmpty;
    if (_services.isEmpty && !hasOther) {
      e['services'] = _otherService
          ? 'اكتب اسم الخدمة الأخرى'
          : 'اختر خدمة واحدة على الأقل';
    }
    setState(() => _errors
      ..clear()
      ..addAll(e));
    return e.isEmpty;
  }

  void _next() {
    final ok = _step == 0 ? _validateStep1() : _validateStep2();
    if (ok) setState(() => _step++);
  }

  bool get _canSubmit =>
      _licensePath != null &&
      _idPhotoPath != null &&
      _photoPath != null &&
      _agreed;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    // الرقم مسجل كمريض ← نرجعها لخطوة 1 بدون إرسال رمز
    if (AuthRoleRepository.isPhoneUsedAsPatient(_phone)) {
      await showProviderDialog(
        context,
        title: 'رقم مستخدم',
        message: 'هذا الرقم مسجل كمريض، استخدم رقمًا آخر لتقديم الطلب.',
        confirmText: 'حسنًا',
      );
      if (!mounted) return;
      setState(() {
        _errors.clear();
        _step = 0;
      });
      return;
    }

    // عنده طلب قائم (قيد المراجعة أو مقبول)
    if (AuthRoleRepository.hasActiveApplication(_phone)) {
      await showProviderDialog(
        context,
        title: 'طلب قائم',
        message: 'لديك طلب انضمام قائم بهذا الرقم.',
        confirmText: 'حسنًا',
      );
      return;
    }

    // 🔥 Firebase: verifyPhoneNumber قبل حفظ الطلب
    // بدون <bool> لأن مسارات AppRoutes من نوع dynamic
    final ok = await Navigator.pushNamed(
      context,
      'Verification',
      arguments: VerificationArgs('+970$_phone', isProviderJoin: true),
    );
    if (ok != true || !mounted) return;

    // 🔥 Firebase: حفظ الطلب بحالة pending مع روابط المستندات
    await AuthRoleRepository.submitApplication(
      phone: _phone,
      name: _nameCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'ProviderPending', (r) => false);
  }

  /// يمسح خطأ الحقل أول ما تعدّل عليه
  void _clearError(String key) {
    if (_errors.containsKey(key)) setState(() => _errors.remove(key));
  }

  Future<String?> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    // 🔥 Firebase/Supabase: رفع الصورة إلى Supabase Storage وحفظ رابطها
    return picked?.path;
  }

  // ───────────────────────── مكونات مشتركة ─────────────────────────
  Widget _sectionTitle(String text, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
            ),
        ],
      ),
    );
  }

  /// hintText: نص صغير بجانب العنوان بدل "(اختياري)"
  Widget _label(String text, {bool optional = false, String? hintText}) {
    final side = hintText ?? (optional ? 'اختياري' : null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (side != null)
              TextSpan(
                text: ' ($side)',
                style: const TextStyle(color: AppColors.neutralNormal),
              ),
          ],
        ),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.neutralDark,
        ),
      ),
    );
  }

  Widget _note(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.neutralDark),
      ),
    );
  }

  Widget _errorText(String key) {
    final msg = _errors[key];
    if (msg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        msg,
        style: const TextStyle(fontSize: 12, color: AppColors.error500),
      ),
    );
  }

  BoxDecoration _box(String key) => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _errors.containsKey(key) ? AppColors.error500 : AppColors.border,
        ),
      );

  /// حقل نص بارتفاع 48 بنفس شكل حقول المشروع
  Widget _field({
    required String keyName,
    required String label,
    required TextEditingController controller,
    String? hint,
    bool optional = false,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    bool ltr = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, optional: optional),
        Container(
          height: 48,
          alignment: Alignment.center,
          decoration: _box(keyName),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textDirection: ltr ? TextDirection.ltr : null,
            textAlign: ltr ? TextAlign.right : TextAlign.start,
            onChanged: (_) => _clearError(keyName),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutralDarkActive,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.neutralNormal,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        _errorText(keyName),
      ],
    );
  }

  /// قائمة منسدلة بارتفاع 48
  Widget _dropdown({
    required String keyName,
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: _box(keyName),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: AppColors.white,
              hint: Text(
                hint,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutralNormal,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary600,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.neutralDarkActive,
              ),
              items: items,
              onChanged: (v) {
                _clearError(keyName);
                onChanged(v);
              },
            ),
          ),
        ),
        _errorText(keyName),
      ],
    );
  }

  /// حقل الهاتف بنفس شكل شاشة الدخول (+970)
  Widget _phoneField() {
    final hasError = _errors.containsKey('phone');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('رقم الهاتف'),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? AppColors.error500
                    : AppColors.neutralLightActive,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SvgPicture.asset(
                    'assets/icons/Palestine_flag.svg',
                    width: 24,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '+970',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: AppColors.border),
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) => _clearError('phone'),
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: '59X XXX XXX',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: AppColors.neutralNormal,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _errorText('phone'),
      ],
    );
  }

  // ───────────────────────── الخطوة 1 ─────────────────────────
  List<Widget> _step1() {
    return [
      const Text(
        'أكمل الخطوات الثلاث وأرسل الطلب. تراجع الإدارة المستندات قبل تفعيل حسابك، وتصلك النتيجة داخل التطبيق.',
        style: TextStyle(
          fontSize: 13,
          height: 1.6,
          color: AppColors.neutralDark,
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('المعلومات الشخصية'),
      _field(
        keyName: 'name',
        label: 'الاسم الكامل',
        controller: _nameCtrl,
        hint: 'الاسم الرباعي',
      ),
      const SizedBox(height: 16),
      _field(
        keyName: 'id',
        label: 'رقم الهوية',
        controller: _idCtrl,
        hint: '9 أرقام',
        keyboard: TextInputType.number,
        ltr: true,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
      ),
      _note('يُستخدم للتحقق من هويتك ولا يظهر للمرضى.'),
      const SizedBox(height: 16),
      _phoneField(),
      const SizedBox(height: 16),
      _field(
        keyName: 'email',
        label: 'البريد الإلكتروني',
        controller: _emailCtrl,
        hint: 'example@email.com',
        optional: true,
        keyboard: TextInputType.emailAddress,
        ltr: true,
      ),
      const SizedBox(height: 32),
      _sectionTitle('العنوان', trailing: 'قطاع غزة'),
      _dropdown(
        keyName: 'governorate',
        label: 'المحافظة',
        hint: 'اختر المحافظة',
        value: _governorate,
        items: [
          for (final g in gazaGovernorates)
            DropdownMenuItem(value: g.id, child: Text(g.name)),
        ],
        onChanged: (v) => setState(() => _governorate = v),
      ),
      const SizedBox(height: 16),
      _field(
        keyName: 'address',
        label: 'العنوان التفصيلي',
        controller: _addressCtrl,
        hint: 'الشارع، أقرب معلم',
      ),
    ];
  }

  // ───────────────────────── الخطوة 2 ─────────────────────────
  Widget _checkRow(String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.primary600,
              side: const BorderSide(color: AppColors.neutralNormal, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (v) => onChanged(v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
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

  List<Widget> _step2() {
    const divider = Divider(height: 1, thickness: 1, color: AppColors.border);
    final servicesError = _errors.containsKey('services');

    return [
      _dropdown(
        keyName: 'specialty',
        label: 'التخصص',
        hint: 'اختر التخصص',
        value: _specialty,
        items: [
          for (final s in ProviderJoinOptions.specialties)
            DropdownMenuItem(value: s, child: Text(s)),
        ],
        onChanged: (v) => setState(() => _specialty = v),
      ),
      const SizedBox(height: 16),
      _label('نبذة عني', hintText: '20 حرفًا على الأقل'),
      Container(
        constraints: const BoxConstraints(minHeight: 96),
        decoration: _box('bio'),
        child: TextField(
          controller: _bioCtrl,
          minLines: 4,
          maxLines: null,
          maxLength: 300,
          onChanged: (_) => _clearError('bio'),
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.neutralDarkActive,
          ),
          decoration: const InputDecoration(
            hintText: 'عرّف المرضى بنفسك وبخبرتك باختصار',
            hintStyle: TextStyle(fontSize: 13, color: AppColors.neutralNormal),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
      _errorText('bio'),
      const SizedBox(height: 16),
      _field(
        keyName: 'years',
        label: 'سنوات الخبرة',
        controller: _yearsCtrl,
        hint: 'مثال: 5',
        keyboard: TextInputType.number,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
      ),
      const SizedBox(height: 32),
      _sectionTitle('الخدمات التي أقدمها', trailing: 'اختر واحدة على الأقل'),
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: servicesError ? AppColors.error500 : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            for (final s in ProviderJoinOptions.services) ...[
              _checkRow(
                s,
                _services.contains(s),
                (v) => setState(() {
                  v ? _services.add(s) : _services.remove(s);
                  _errors.remove('services');
                }),
              ),
              divider,
            ],
            _checkRow(
              'أخرى',
              _otherService,
              (v) => setState(() {
                _otherService = v;
                _errors.remove('services');
              }),
            ),
            if (_otherService)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: _box('other'),
                      child: TextField(
                        controller: _otherCtrl,
                        onChanged: (_) => _clearError('services'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.neutralDarkActive,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'اكتب اسم الخدمة',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutralNormal,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      _errorText('services'),
    ];
  }

  // ───────────────────────── الخطوة 3 ─────────────────────────
  Widget _uploadCard({
    required String title,
    required String subtitle,
    required bool required,
    required String? path,
    required ValueChanged<String> onPicked,
  }) {
    final done = path != null;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.upload_file_outlined,
              size: 20,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: title,
                    children: [
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.error500),
                        ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done ? 'تم الرفع' : subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: done ? AppColors.primary700 : AppColors.neutralDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            done ? 'تغيير' : 'رفع',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary600,
            ),
          ),
        ],
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final p = await _pickImage();
        if (p != null && mounted) onPicked(p);
      },
      // قبل الرفع: إطار متقطع، بعده: إطار متصل
      child: done
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary500),
              ),
              child: content,
            )
          : CustomPaint(
              painter: _DashedBorderPainter(
                color: AppColors.primary300,
                radius: 12,
              ),
              child: content,
            ),
    );
  }

  List<Widget> _step3() {
    return [
      _sectionTitle('المستندات'),
      _uploadCard(
        title: 'رخصة مزاولة المهنة',
        subtitle: 'صورة واضحة للرخصة',
        required: true,
        path: _licensePath,
        onPicked: (p) => setState(() => _licensePath = p),
      ),
      const SizedBox(height: 8),
      _uploadCard(
        title: 'صورة الهوية',
        subtitle: 'وجه الهوية',
        required: true,
        path: _idPhotoPath,
        onPicked: (p) => setState(() => _idPhotoPath = p),
      ),
      const SizedBox(height: 8),
      _uploadCard(
        title: 'صورة شخصية',
        subtitle: 'تظهر للمرضى',
        required: true,
        path: _photoPath,
        onPicked: (p) => setState(() => _photoPath = p),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Checkbox(
            value: _agreed,
            activeColor: AppColors.primary600,
            side: const BorderSide(color: AppColors.neutralNormal, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (v) => setState(() => _agreed = v ?? false),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'أوافق على ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'Terms'),
                  child: const Text(
                    'الشروط وسياسة الخصوصية',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary500,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // ───────────────────────── الأزرار السفلية ─────────────────────────
  Widget _previousButton() {
    return AppButton(
      text: 'السابق',
      fontSize: 15,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.neutralDarkActive,
      borderColor: AppColors.border,
      onPressed: _back,
    );
  }

  Widget _bottomBar() {
    final Widget child;
    if (_step == 0) {
      child = AppButton(text: 'التالي', fontSize: 15, onPressed: _next);
    } else {
      final isLast = _step == 2;
      child = Row(
        children: [
          Expanded(
            flex: 2,
            child: AppButton(
              text: isLast ? 'إرسال الطلب' : 'التالي',
              fontSize: 15,
              // إرسال الطلب معطّل لحد ما تكتمل المستندات والموافقة
              onPressed: isLast ? (_canSubmit ? _submit : null) : _next,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _previousButton()),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final content = switch (_step) {
      0 => _step1(),
      1 => _step2(),
      _ => _step3(),
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      // زر الرجوع في النظام يرجع خطوة، ومن الخطوة الأولى يخرج
      child: PopScope(
        canPop: _step == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'رجوع',
                        onPressed: _back,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'الانضمام كمقدم رعاية',
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
                const SizedBox(height: 8),
                JoinStepper(labels: _stepLabels, current: _step + 1),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content,
                    ),
                  ),
                ),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// إطار متقطع لبطاقات الرفع قبل اختيار الصورة
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
