import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final double? width;
  final double height;
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double fontSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const AppButton({
    super.key,
    this.width,
    this.height = 50,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fontSize = 17,
    this.backgroundColor = AppColors.primary600,
    this.foregroundColor = AppColors.white,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: borderColor == null ? null : BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}