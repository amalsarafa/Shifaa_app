// lib/features/provider/screens/provider_personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/widgets/patient_avatar.dart';
import 'package:my_first_app/features/provider/services/provider_profile_repository.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

class ProviderPersonalInfoScreen extends StatefulWidget {
  const ProviderPersonalInfoScreen({super.key});

  @override
  State<ProviderPersonalInfoScreen> createState() =>
      _ProviderPersonalInfoScreenState();
}

class _ProviderPersonalInfoScreenState
    extends State<ProviderPersonalInfoScreen> {
  bool _editing = false;
  late final TextEditingController _email =
      TextEditingController(text: ProviderProfileRepository.email);
  late String _gender = ProviderProfileRepository.gender;
  late DateTime _birth = ProviderProfileRepository.birth;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) setState(() => _birth = picked);
  }

  void _cancel() {
    setState(() {
      _email.text = ProviderProfileRepository.email;
      _gender = ProviderProfileRepository.gender;
      _birth = ProviderProfileRepository.birth;
      _editing = false;
    });
  }

  Future<void> _save() async {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
    if (!ok) {
      await showProviderDialog(
        context,
        title: 'البريد غير صحيح',
        message: 'يرجى إدخال بريد إلكتروني صحيح.',
        confirmText: 'حسنًا',
      );
      return;
    }
    ProviderProfileRepository.email = _email.text.trim();
    ProviderProfileRepository.gender = _gender;
    ProviderProfileRepository.birth = _birth;
    setState(() => _editing = false);
    if (!mounted) return;
    await showProviderDialog(
      context,
      title: 'تم الحفظ',
      message: 'تم تحديث معلوماتك الشخصية.',
      confirmText: 'حسنًا',
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    String? value,
    Widget? child,
    bool locked = false,
    bool ltr = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  const SizedBox(height: 4),
                  child ??
                      Text(
                        value ?? '',
                        textDirection: ltr ? TextDirection.ltr : null,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                ],
              ),
            ),
            if (locked)
              const Icon(Icons.lock_outline,
                  size: 18, color: AppColors.neutralNormal),
          ],
        ),
      ),
    );
  }

  static const _divider = Divider(height: 1, color: AppColors.border);

  @override
  Widget build(BuildContext context) {
    return ProviderSubScaffold(
      title: 'معلوماتي الشخصية',
      bottom: _editing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(text: 'حفظ التعديلات', onPressed: _save),
                const SizedBox(height: 8),
                AppButton(
                  text: 'إلغاء',
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.neutralDarkActive,
                  borderColor: AppColors.border,
                  onPressed: _cancel,
                ),
              ],
            )
          : AppButton(
              text: 'تعديل المعلومات',
              onPressed: () => setState(() => _editing = true),
            ),
      children: [
        Center(
          child: PatientAvatar(
            name: ProviderProfileRepository.name,
            size: 88,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: providerCardDecoration(),
          child: Column(
            children: [
              _row(
                icon: Icons.person_outline,
                label: 'الاسم الكامل',
                value: ProviderProfileRepository.name,
                locked: true,
              ),
              _divider,
              _row(
                icon: Icons.phone_outlined,
                label: 'رقم الهاتف',
                value: ProviderProfileRepository.phone,
                ltr: true,
                locked: true,
              ),
              _divider,
              _row(
                icon: Icons.mail_outline,
                label: 'البريد الإلكتروني',
                value: ProviderProfileRepository.email,
                ltr: true,
                child: _editing
                    ? TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralDarkActive,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary300),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary600),
                          ),
                        ),
                      )
                    : null,
              ),
              _divider,
              _row(
                icon: Icons.wc_outlined,
                label: 'الجنس',
                value: _gender,
                child: _editing
                    ? Row(
                        children: [
                          for (final g in const ['أنثى', 'ذكر']) ...[
                            ProviderChoiceChip(
                              label: g,
                              selected: _gender == g,
                              onTap: () => setState(() => _gender = g),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      )
                    : null,
              ),
              _divider,
              _row(
                icon: Icons.cake_outlined,
                label: 'تاريخ الميلاد',
                value: _fmtDate(_birth),
                onTap: _editing ? _pickDate : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.warningDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الاسم ورقم الهاتف مرتبطان بتوثيق حسابك، ولتغييرهما تواصلي مع الدعم.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.warningDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}