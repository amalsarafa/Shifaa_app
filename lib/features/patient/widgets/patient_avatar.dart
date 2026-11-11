// lib/features/patient/widgets/patient_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// صورة المريض الدائرية: تعرض الصورة إن وُجدت، وإلا الحرف الأول.
/// إذا أعطيناها onTap تظهر عليها أيقونة كاميرا لتغيير الصورة.
class PatientAvatar extends StatelessWidget {
  final String name;
  final String? photo;
  final double size;
  final VoidCallback? onTap;

  const PatientAvatar({
    super.key,
    required this.name,
    this.photo,
    this.size = 64,
    this.onTap,
  });

  Widget _initial() {
    final n = name.trim();
    return Center(
      child: Text(
        n.isEmpty ? '?' : n[0],
        style: TextStyle(
          fontSize: size * 0.375,
          fontWeight: FontWeight.bold,
          color: AppColors.primary600,
        ),
      ),
    );
  }

  Widget _image() {
    final p = photo;
    if (p == null || p.isEmpty) return _initial();
    final cache = (size * 3).round();

    // رابط من الإنترنت (بعد Firebase) أو ملف من الجهاز (حالياً)
    if (p.startsWith('http')) {
      return Image.network(
        p,
        fit: BoxFit.cover,
        cacheWidth: cache,
        errorBuilder: (_, __, ___) => _initial(),
      );
    }
    return Image.file(
      File(p),
      fit: BoxFit.cover,
      cacheWidth: cache,
      errorBuilder: (_, __, ___) => _initial(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary100,
          width: size >= 80 ? 3 : 2,
        ),
      ),
      child: ClipOval(child: SizedBox.expand(child: _image())),
    );

    if (onTap == null) return circle;

    final badge = size >= 80 ? 32.0 : 24.0;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            circle,
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: badge,
                height: badge,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: badge * 0.55,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}