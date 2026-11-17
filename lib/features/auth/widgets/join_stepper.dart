// lib/features/auth/widgets/join_stepper.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// شريط خطوات أفقي من 3 خطوات.
/// current: رقم الخطوة الحالية (1..3)، و4 تعني أن الكل منتهي.
class JoinStepper extends StatelessWidget {
  final List<String> labels;
  final int current;

  const JoinStepper({super.key, required this.labels, required this.current});

  Widget _node(int step) {
    final done = step < current;
    final active = step == current;

    final Color circleColor = (done || active)
        ? AppColors.primary500
        : AppColors.white;

    final Widget inner = done
        ? const Icon(Icons.check, size: 16, color: AppColors.white)
        : Text(
            '$step',
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? AppColors.white : AppColors.neutralNormal,
            ),
          );

    final TextStyle labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
      color: active
          ? AppColors.primary800
          : done
              ? AppColors.neutralDarkActive
              : AppColors.neutralNormal,
    );

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: (done || active)
                  ? null
                  : Border.all(color: AppColors.border, width: 2),
            ),
            child: inner,
          ),
          const SizedBox(height: 8),
          Text(
            labels[step - 1],
            textAlign: TextAlign.center,
            maxLines: 2,
            style: labelStyle,
          ),
        ],
      ),
    );
  }

  /// الخط بين خطوتين: ملوّن إذا الخطوة قبله منتهية
  Widget _line(int afterStep) {
    final done = afterStep < current;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(top: 15),
        color: done ? AppColors.primary500 : AppColors.border,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _node(1),
          _line(1),
          _node(2),
          _line(2),
          _node(3),
        ],
      ),
    );
  }
}
