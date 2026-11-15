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
  late int _years = ProviderProfileRepository.years;
  late final List<String> _allSkills = [...ProviderProfileRepository.allSkills];
  late final Set<String> _skills = {...ProviderProfileRepository.selectedSkills};
  late final List<String> _certs = [...ProviderProfileRepository.certificates];

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
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
    final s = await showProviderTextDialog(
      context,
      title: 'إضافة شهادة',
      hint: 'اسم الشهادة',
    );
    if (s == null) return;
    setState(() => _certs.add(s));
  }

  Future<void> _save() async {
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
    ProviderProfileRepository.years = _years;
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

  Widget _roundBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary50,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary100),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary700),
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
      bottom: AppButton(text: 'حفظ التغييرات', onPressed: _save),
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
                Row(
                  children: [
                    _roundBtn(Icons.remove,
                        _years > 0 ? () => setState(() => _years--) : null),
                    SizedBox(
                      width: 72,
                      child: Text(
                        _yearsText(_years),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                    ),
                    _roundBtn(Icons.add,
                        _years < 50 ? () => setState(() => _years++) : null),
                  ],
                ),
              ),
            ],
          ),
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
                subtitle: 'معتمدة · لا تظهر للمرضى',
                icon: Icons.badge_outlined,
                trailing: verified,
              ),
              divider,
              _docRow(
                title: 'صورة الهوية',
                subtitle: 'معتمدة · لا تظهر للمرضى',
                icon: Icons.credit_card_outlined,
                trailing: verified,
              ),
              for (var i = 0; i < _certs.length; i++) ...[
                divider,
                _docRow(
                  title: _certs[i],
                  subtitle: 'يظهر اسمها للمرضى',
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
        const SizedBox(height: 8),
        const Text(
          'لتغيير الرخصة أو الهوية تواصلي مع الدعم.',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
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