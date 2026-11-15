// lib/features/provider/widgets/provider_sub_scaffold.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';

BoxDecoration providerCardDecoration() => BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    );

/// هيكل مشترك للشاشات الفرعية داخل حسابي
class ProviderSubScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  /// الزر السفلي (اختياري، null = بدون شريط سفلي)
  final Widget? bottom;

  const ProviderSubScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          toolbarHeight: 90,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.neutralDarkActive,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: children,
              ),
            ),
            if (bottom != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(top: false, child: bottom!),
              ),
          ],
        ),
      ),
    );
  }
}

/// عنوان قسم + ملاحظة صغيرة بجانبه
class ProviderSectionHeader extends StatelessWidget {
  final String title;
  final String? hint;
  const ProviderSectionHeader(this.title, {super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
          const Spacer(),
          if (hint != null)
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDark,
              ),
            ),
        ],
      ),
    );
  }
}

/// مفتاح التفعيل
class ProviderSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const ProviderSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary600
            : AppColors.neutralLightActive,
      ),
    );
  }
}

/// شريحة قابلة للاختيار (مهارة، منطقة، جنس...)
class ProviderChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dashed;

  const ProviderChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary50 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary600 : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.primary800
                : (dashed ? AppColors.primary700 : AppColors.neutralDark),
          ),
        ),
      ),
    );
  }
}

/// نافذة إدخال نص، تُرجع النص أو null
Future<String?> showProviderTextDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String confirmText = 'إضافة',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextDialog(title: title, hint: hint, confirmText: confirmText),
  );
}

class _TextDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmText;
  const _TextDialog({
    required this.title,
    required this.hint,
    required this.confirmText,
  });

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 40,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutralNormal,
                  ),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      height: 44,
                      fontSize: 13,
                      text: widget.confirmText,
                      onPressed: () {
                        final t = _controller.text.trim();
                        Navigator.pop(context, t.isEmpty ? null : t);
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