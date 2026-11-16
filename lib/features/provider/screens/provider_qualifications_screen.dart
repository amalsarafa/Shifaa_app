// lib/features/provider/screens/provider_qualifications_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_profile_repository.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

class ProviderQualificationsScreen extends StatefulWidget {
  const ProviderQualificationsScreen({super.key});

  @override
  State<ProviderQualificationsScreen> createState() =>
      _ProviderQualificationsScreenState();
}

class _ProviderQualificationsScreenState
    extends State<ProviderQualificationsScreen> {
  late final TextEditingController _bio =
      TextEditingController(text: ProviderProfileRepository.bio);
  late final List<String> _allSkills = [...ProviderProfileRepository.allSkills];
  late final Set<String> _skills = {...ProviderProfileRepository.selectedSkills};
  late final List<String> _certs = [...ProviderProfileRepository.certificates];

  @override
  void initState() {
    super.initState();
    // نعيد البناء مع كل كتابة لتحديث زر الحفظ
    _bio.addListener(_onEdit);
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  void _onEdit() => setState(() {});

  static bool _sameList(List<String> a, List<String> b) =>
      a.length == b.length && a.join('\u0001') == b.join('\u0001');

  /// هل في تغيير حقيقي عن القيم المحفوظة؟
  bool get _hasChanges {
    final r = ProviderProfileRepository.selectedSkills;
    final sameSkills = _skills.length == r.length && _skills.containsAll(r);
    return _bio.text.trim() != ProviderProfileRepository.bio.trim() ||
        !sameSkills ||
        !_sameList(_allSkills, ProviderProfileRepository.allSkills) ||
        !_sameList(_certs, ProviderProfileRepository.certificates);
  }

  String _yearsText(int n) {
    if (n == 1) return 'سنة';
    if (n == 2) return 'سنتان';
    if (n <= 10) return '$n سنوات';
    return '$n سنة';
  }

  Future<void> _addSkill() async {
    final s = await showProviderTextDialog(
      context,
      title: 'إضافة مهارة',
      hint: 'مثال: قسطرة بولية',
    );
    if (s == null) return;
    setState(() {
      if (!_allSkills.contains(s)) _allSkills.add(s);
      _skills.add(s);
    });
  }

  Future<void> _addCert() async {
    final nameCtrl = TextEditingController();
    String? file;

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setD) {
            final ready = nameCtrl.text.trim().isNotEmpty && file != null;

            return Dialog(
              backgroundColor: AppColors.white,
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'إضافة شهادة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      onChanged: (_) => setD(() {}),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutralDarkActive,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اسم الشهادة',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutralDark,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                          borderSide:
                              const BorderSide(color: AppColors.primary600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      // 🔥 لاحقاً: اختيار ملف حقيقي (file_picker) ورفعه إلى Supabase
                      onTap: () => setD(() => file = 'شهادة.pdf'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: file == null
                              ? AppColors.white
                              : AppColors.primary50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: file == null
                                ? AppColors.border
                                : AppColors.primary600,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              file == null
                                  ? Icons.attach_file
                                  : Icons.check_circle_outline,
                              size: 20,
                              color: AppColors.primary700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              file ?? 'إرفاق صورة أو ملف',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'إضافة',
                            onPressed: ready
                                ? () => Navigator.pop(ctx, nameCtrl.text.trim())
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'إلغاء',
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.neutralDarkActive,
                            borderColor: AppColors.border,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (name == null) return;
    setState(() => _certs.add(name));
  }

  Future<void> _save() async {
    if (!_hasChanges) return; // ما في شي يتحفظ
    if (_bio.text.trim().isEmpty) {
      await showProviderDialog(
        context,
        title: 'النبذة فارغة',
        message: 'اكتبي نبذة قصيرة عنك تظهر للمرضى.',
        confirmText: 'حسنًا',
      );
      return;
    }
    if (_skills.isEmpty) {
      await showProviderDialog(
        context,
        title: 'اختاري مهارة',
        message: 'اختاري مهارة واحدة على الأقل.',
        confirmText: 'حسنًا',
      );
      return;
    }
    ProviderProfileRepository.bio = _bio.text.trim();
    ProviderProfileRepository.allSkills = [..._allSkills];
    ProviderProfileRepository.selectedSkills = {..._skills};
    ProviderProfileRepository.certificates = [..._certs];
    if (!mounted) return;
    await showProviderDialog(
      context,
      title: 'تم الحفظ',
      message: 'تم تحديث مؤهلاتك وخبرتك.',
      confirmText: 'حسنًا',
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _kv(String k, Widget v) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            k,
            style: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
          ),
          const Spacer(),
          v,
        ],
      ),
    );
  }

  Widget _docRow({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
  }) {
    return Padding(
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
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDark,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, color: AppColors.border);
    const verified = Icon(Icons.verified_outlined,
        size: 20, color: AppColors.successNormal);

    return ProviderSubScaffold(
      title: 'المؤهلات والخبرة',
      // معطّل لحد ما يصير تغيير
      bottom: IgnorePointer(
        ignoring: !_hasChanges,
        child: Opacity(
          opacity: _hasChanges ? 1 : 0.5,
          child: AppButton(text: 'حفظ التغييرات', onPressed: _save),
        ),
      ),
      children: [
        const ProviderSectionHeader('نبذة عني', hint: 'تظهر للمرضى'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: providerCardDecoration(),
          child: TextField(
            controller: _bio,
            maxLines: 4,
            maxLength: 200,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.neutralDarkActive,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'اكتبي نبذة قصيرة عنك',
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ProviderSectionHeader('الخبرة'),
        Container(
          decoration: providerCardDecoration(),
          child: Column(
            children: [
              _kv(
                'التخصص',
                const Text(
                  ProviderProfileRepository.specialty,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ),
              divider,
              _kv(
                'سنوات الخبرة',
                Text(
                  _yearsText(ProviderProfileRepository.years),
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
        const SizedBox(height: 8),
        const Text(
          'التخصص وسنوات الخبرة تُراجَع عند الانضمام، ولتغييرها تواصلي مع الدعم.',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
        ),
        const SizedBox(height: 16),
        const ProviderSectionHeader('المهارات', hint: 'اختاري ما تتقنينه'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _allSkills)
              ProviderChoiceChip(
                label: s,
                selected: _skills.contains(s),
                onTap: () => setState(() {
                  if (!_skills.remove(s)) _skills.add(s);
                }),
              ),
            ProviderChoiceChip(
              label: '+ إضافة',
              selected: false,
              dashed: true,
              onTap: _addSkill,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ProviderSectionHeader('المستندات والشهادات'),
        Container(
          decoration: providerCardDecoration(),
          child: Column(
            children: [
              _docRow(
                title: 'رخصة مزاولة المهنة',
                subtitle: 'معتمدة',
                icon: Icons.badge_outlined,
                trailing: verified,
              ),
              divider,
              _docRow(
                title: 'صورة الهوية',
                subtitle: 'معتمدة',
                icon: Icons.credit_card_outlined,
                trailing: verified,
              ),
              for (var i = 0; i < _certs.length; i++) ...[
                divider,
                _docRow(
                  title: _certs[i],
                  subtitle: 'شهادة مرفقة',
                  icon: Icons.workspace_premium_outlined,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.error600),
                    onPressed: () => setState(() => _certs.removeAt(i)),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'إضافة شهادة',
          icon: Icons.add,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary700,
          borderColor: AppColors.primary600,
          onPressed: _addCert,
        ),
      ],
    );
  }
}