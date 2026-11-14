// lib/features/provider/widgets/provider_dialog.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';

/// نافذة تأكيد أو معلومة، تُرجع true عند الموافقة
Future<bool?> showProviderDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  String? cancelText,
  bool danger = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
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
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutralDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: AppButton(
                        height: 44,
                        fontSize: 13,
                        text: cancelText,
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.neutralDarkActive,
                        borderColor: AppColors.border,
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: AppButton(
                      height: 44,
                      fontSize: 13,
                      text: confirmText,
                      backgroundColor:
                          danger ? AppColors.error700 : AppColors.primary600,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}