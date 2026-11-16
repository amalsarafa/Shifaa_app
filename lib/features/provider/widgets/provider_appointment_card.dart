// lib/features/provider/widgets/provider_appointment_card.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_appointment_model.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';

/// شارة حالة صغيرة (مؤكد، مكتمل، مرفوض...)
/// شارة حالة صغيرة (مؤكد، مكتمل، مرفوض...)
Widget providerChip(String label, Color bg, Color fg, {IconData? icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
        ),
      ],
    ),
  );
}

/// شارة مهلة الطلب، مثل "ينتهي خلال 4 دقائق"
Widget providerExpiryChip(String expires) {
  final text = expires.trim();
  if (text.isEmpty) {
    return providerChip(
      'بانتظار الرد',
      AppColors.warningLight,
      AppColors.warningDark,
    );
  }
  return providerChip(
    text,
    AppColors.warningLight,
    AppColors.warningDark,
    icon: Icons.schedule_rounded,
  );
}

/// زرّا الطلب المعلّق: قبول (يمين في RTL) ثم رفض
class ProviderRequestActions extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ProviderRequestActions({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            height: 44,
            fontSize: 13,
            text: 'قبول',
            onPressed: onAccept,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppButton(
            height: 44,
            fontSize: 13,
            text: 'رفض',
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.neutralDarkActive,
            borderColor: AppColors.border,
            onPressed: onDecline,
          ),
        ),
      ],
    );
  }
}

/// صندوق "للتواصل: [الرقم]" أسفل الموعد المؤكد
class ProviderPhoneBox extends StatelessWidget {
  final String phone;

  const ProviderPhoneBox({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.primary800,
    );

    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('للتواصل:', style: style),
          const SizedBox(width: 4),
          Text(phone, textDirection: TextDirection.ltr, style: style),
        ],
      ),
    );
  }
}

/// بطاقة الموعد الموحّدة: نفس الشكل في الرئيسية وشاشة المواعيد
class ProviderAppointmentCard extends StatelessWidget {
  final ProviderAppointment appointment;

  /// شارة الحالة (اختيارية، مثلاً بالرئيسية المهلة فوق البطاقة)
  final Widget? chip;

  /// true ← الموعد المؤكد: خلفية خضراء بدون إطار
  final bool highlighted;

  /// أزرار أو رقم هاتف أسفل البطاقة
  final Widget? footer;
  final VoidCallback? onTap;

  const ProviderAppointmentCard({
    super.key,
    required this.appointment,
    this.chip,
    this.highlighted = false,
    this.footer,
    this.onTap,
  });

  static const Color _border = AppColors.border;

  Widget _avatar(String name) {
    final n = name.trim();
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        n.isEmpty ? '?' : n[0],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary800,
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String text, {bool flexible = false}) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary800,
      ),
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary600),
        const SizedBox(width: 4),
        flexible ? Flexible(child: label) : label,
      ],
    );

    return flexible ? Flexible(child: content) : content;
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.primary100 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: highlighted ? null : Border.all(color: _border),
        ),
        child: Column(
          children: [
                       Row(
              children: [
                _avatar(a.patientName),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutralDarkActive,
                              ),
                            ),
                          ),
                          if (chip != null) ...[
                            const SizedBox(width: 8),
                            chip!,
                          ],
                        ],
                      ),
                      Text(
                        a.service,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              thickness: 1,
              color: highlighted ? AppColors.primary200 : _border,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metaItem(Icons.schedule_rounded, a.time),
                const SizedBox(width: 8),
                _metaItem(Icons.calendar_today_outlined, a.date),
                const SizedBox(width: 8),
                _metaItem(Icons.location_on_outlined, a.place, flexible: true),
              ],
            ),
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ],
        ),
      ),
    );
  }
}
