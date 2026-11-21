// lib/features/provider/screens/provider_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/services/delete_account_flow.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  // 🔥 لاحقاً: تُقرأ وتُحفظ من Firebase / SharedPreferences
  bool _newRequestsOn = true;
  bool _remindersOn = true;

  static const String _appVersion = '1.0.0';

  // ───────────────────────── حذف الحساب ─────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (confirmed != true || !mounted) return;

    await deleteAccountFlow(context);
  }

  // ───────────────────────── مكونات مساعدة ─────────────────────────
  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: providerCardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.border);

  Widget _row({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool danger = false,
  }) {
    final iconBg = danger ? AppColors.error50 : AppColors.primary50;
    final iconColor = danger ? AppColors.error700 : AppColors.primary600;
    final titleColor = danger
        ? AppColors.error700
        : AppColors.neutralDarkActive;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
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
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }

  Widget get _chevron => const Icon(
    Icons.chevron_right_rounded,
    size: 20,
    color: AppColors.neutralDark,
  );

  // ───────────────────────── الشاشة ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return ProviderSubScaffold(
      title: 'الإعدادات',
      children: [
        const Text(
          'تحكّمي في الإشعارات والخصوصية وحسابك',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
        ),
        const SizedBox(height: 16),
        _section(
          'الإشعارات',
          Column(
            children: [
              _row(
                icon: Icons.notifications_none_rounded,
                title: 'طلبات الحجز الجديدة',
                subtitle: 'تنبيه فور وصول طلب من مريض',
                trailing: ProviderSwitch(
                  value: _newRequestsOn,
                  onChanged: (v) => setState(() => _newRequestsOn = v),
                ),
              ),
              _divider(),
              _row(
                icon: Icons.alarm_rounded,
                title: 'تذكير بالمواعيد القادمة',
                subtitle: 'قبل موعد الزيارة بساعة',
                trailing: ProviderSwitch(
                  value: _remindersOn,
                  onChanged: (v) => setState(() => _remindersOn = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _section(
          'عن التطبيق',
          Column(
            children: [
              _row(
                icon: Icons.description_outlined,
                title: 'الشروط والأحكام',
                subtitle: 'قواعد استخدام التطبيق',
                trailing: _chevron,
                onTap: () => Navigator.pushNamed(context, 'Terms'),
              ),
              _divider(),
              _row(
                icon: Icons.lock_outline_rounded,
                title: 'سياسة الخصوصية',
                subtitle: 'حقوقك وحماية بيانات مرضاك',
                trailing: _chevron,
                onTap: () => Navigator.pushNamed(context, 'PrivacyPolicy'),
              ),
              _divider(),
              _row(
                icon: Icons.info_outline_rounded,
                title: 'إصدار التطبيق',
                subtitle: 'الإصدار $_appVersion',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _section(
          'الحساب',
          _row(
            icon: Icons.delete_outline_rounded,
            title: 'حذف الحساب',
            subtitle: 'احذفي حسابك وبياناتك نهائيًا',
            danger: true,
            onTap: _confirmDelete,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── نافذة تأكيد حذف الحساب ─────────────────────────
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  static const String _confirmWord = 'حذف';

  final TextEditingController _controller = TextEditingController();

  bool get _canDelete => _controller.text.trim() == _confirmWord;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.error50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 28,
                  color: AppColors.error700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هل أنت متأكد من حذف الحساب؟\nاكتب كلمة "حذف" للتأكيد.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.neutralDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutralDarkActive,
                ),
                decoration: InputDecoration(
                  hintText: 'حذف',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutralDark,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: _border(AppColors.border),
                  enabledBorder: _border(AppColors.border),
                  focusedBorder: _border(AppColors.primary600),
                ),
              ),
              const SizedBox(height: 16),
              // RTL: زر التأكيد يميناً والإلغاء يساراً
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      height: 44,
                      fontSize: 13,
                      text: 'حذف الحساب',
                      backgroundColor: _canDelete
                          ? AppColors.error700
                          : AppColors.neutralLight,
                      foregroundColor: _canDelete
                          ? AppColors.white
                          : AppColors.neutralDark,
                      onPressed: () {
                        if (_canDelete) Navigator.pop(context, true);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      height: 44,
                      fontSize: 13,
                      text: 'إلغاء',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.neutralDarkActive,
                      borderColor: AppColors.border,
                      onPressed: () => Navigator.pop(context, false),
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
