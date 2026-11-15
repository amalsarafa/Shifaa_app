// lib/core/widgets/success_check.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// علامة النجاح الموحّدة لكل رسائل "تم ..."
class SuccessCheck extends StatelessWidget {
  final double size;

  const SuccessCheck({super.key, this.size = 80});

  static const String _asset = 'assets/icons/success_check.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(_asset, width: size, height: size);
  }
}
