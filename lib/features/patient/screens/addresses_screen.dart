// lib/features/patient/screens/addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  static const _names = ['العنوان الأول', 'العنوان الثاني'];

  /// اسم العنوان حسب ترتيبه
  static String nameFor(int index) =>
      index < _names.length ? _names[index] : 'العنوان ${index + 1}';

  void _openForm(BuildContext context, {int? index}) {
    Navigator.pushNamed(context, 'AddAddress', arguments: index);
  }

  // ───────────────────────── النوافذ ─────────────────────────
  Future<T?> _dialog<T>(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String message,
    required List<Widget> Function(BuildContext dialogContext) actions,
  }) {
    return showDialog<T>(
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
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 26, color: iconColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: actions(dialogContext)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Patient patient,
    int index,
  ) async {
    // لا نسمح بحذف العنوان الوحيد
    if (patient.addresses.length <= 1) {
      await _dialog<void>(
        context,
        icon: Icons.info_outline_rounded,
        iconBg: AppColors.primary50,
        iconColor: AppColors.primary700,
        title: 'لا يمكن حذف هذا العنوان',
        message: 'يجب أن يكون لديك عنوان واحد على الأقل لتتمكن من الحجز.',
        actions: (dialogContext) => [
          Expanded(
            child: AppButton(
              height: 44,
              fontSize: 13,
              text: 'حسناً',
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ),
        ],
      );
      return;
    }

    final confirmed = await _dialog<bool>(
      context,
      icon: Icons.delete_outline_rounded,
      iconBg: AppColors.error50,
      iconColor: AppColors.error700,
      title: 'حذف العنوان؟',
      message: 'سيتم حذف «${nameFor(index)}» من عناوينك المحفوظة.',
                actions: (dialogContext) => [
        Expanded(
          child: AppButton(
            height: 44,
            fontSize: 13,
            text: 'حذف',
            backgroundColor: AppColors.error700,
            foregroundColor: AppColors.white,
            onPressed: () => Navigator.pop(dialogContext, true),
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
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
        ),
      ],
    );

    if (confirmed == true) {
      await PatientRepository.deleteAddress(index);
    }
  }

  // ───────────────────────── بطاقة العنوان ─────────────────────────
  Widget _infoLine(String text, {bool strong = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: strong ? 13 : 12,
        height: 1.6,
        fontWeight: strong ? FontWeight.w600 : FontWeight.normal,
        color: strong ? AppColors.neutralDarkActive : AppColors.neutralDark,
      ),
    );
  }

  Widget _addressCard(BuildContext context, Patient patient, int index) {
    final a = patient.addresses[index];
    final isDefault = index == patient.defaultAddressIndex;
    final landmark = a.landmark?.trim() ?? '';
    final notes = a.notes?.trim() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? AppColors.primary500 : AppColors.border,
          width: isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nameFor(index),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary700,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'الافتراضي',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => PatientRepository.setDefaultAddress(index),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'تعيين كافتراضي',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _infoLine(a.title, strong: true),
          _infoLine(a.details),
          if (landmark.isNotEmpty) _infoLine('أقرب معلم: $landmark'),
          if (notes.isNotEmpty) _infoLine('ملاحظات: $notes'),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  height: 40,
                  fontSize: 13,
                  icon: Icons.edit_outlined,
                  text: 'تعديل',
                  backgroundColor: AppColors.primary50,
                  foregroundColor: AppColors.primary800,
                  onPressed: () => _openForm(context, index: index),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  height: 40,
                  fontSize: 13,
                  icon: Icons.delete_outline_rounded,
                  text: 'حذف',
                  backgroundColor: AppColors.error50,
                  foregroundColor: AppColors.error700,
                  onPressed: () => _confirmDelete(context, patient, index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── الأسفل ─────────────────────────
  Widget _bottom(BuildContext context, int count) {
    if (count < PatientRepository.maxAddresses) {
      return AppButton(
        fontSize: 15,
        icon: Icons.add_rounded,
        text: 'إضافة عنوان جديد',
        onPressed: () => _openForm(context),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primary700,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'يمكنك حفظ عنوانين كحد أقصى. احذف عنواناً لإضافة آخر.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary800,
              ),
            ),
          ),
        ],
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
            'العناوين المحفوظة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkActive,
            ),
          ),
        ),
        body: ValueListenableBuilder<Patient>(
          valueListenable: PatientRepository.current,
          builder: (context, patient, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              children: [
                for (int i = 0; i < patient.addresses.length; i++)
                  _addressCard(context, patient, i),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<Patient>(
              valueListenable: PatientRepository.current,
              builder: (context, patient, _) =>
                  _bottom(context, patient.addresses.length),
            ),
          ),
        ),
      ),
    );
  }
}
