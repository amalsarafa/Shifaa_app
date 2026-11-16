// lib/features/provider/screens/provider_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/constants/gaza_governorates.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_profile_repository.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

class ProviderScheduleScreen extends StatefulWidget {
  const ProviderScheduleScreen({super.key});

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  late final List<ProviderWorkDay> _days =
      ProviderProfileRepository.workDays.map((d) => d.copy()).toList();
  // فاضية إذا المحفوظ مش من المحافظات
  late String? _governorate =
      governorateName(ProviderProfileRepository.governorateId).isEmpty
          ? null
          : ProviderProfileRepository.governorateId;

  double _minutes(TimeOfDay t) => t.hour * 60.0 + t.minute;

  /// هل تغيّر يوم أو ساعة أو المحافظة عن المحفوظ؟
  bool get _hasChanges {
    final saved = ProviderProfileRepository.workDays;
    for (var i = 0; i < _days.length; i++) {
      final d = _days[i];
      final s = saved[i];
      if (d.enabled != s.enabled || d.from != s.from || d.to != s.to) {
        return true;
      }
    }
    return _governorate != ProviderProfileRepository.governorateId;
  }

    Future<void> _pickTime(ProviderWorkDay d, {required bool isFrom}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? d.from : d.to,
      initialEntryMode: TimePickerEntryMode.input,
      helpText: isFrom ? 'وقت البداية' : 'وقت النهاية',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      hourLabelText: 'الساعة',
      minuteLabelText: 'الدقيقة',
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        d.from = picked;
      } else {
        d.to = picked;
      }
    });
  }

  Future<void> _warn(String title, String message) {
    return showProviderDialog(
      context,
      title: title,
      message: message,
      confirmText: 'حسنًا',
    );
  }

  Future<void> _save() async {
    if (!_hasChanges) return; // ما في شي يتحفظ
    final active = _days.where((d) => d.enabled).toList();
    if (active.isEmpty) {
      await _warn('اختاري يومًا واحدًا', 'فعّلي يوم عمل واحد على الأقل.');
      return;
    }
    for (final d in active) {
      if (_minutes(d.to) <= _minutes(d.from)) {
        await _warn(
          'وقت غير صحيح',
          'في يوم ${d.day} يجب أن يكون وقت النهاية بعد وقت البداية.',
        );
        return;
      }
    }
    final governorate = _governorate;
    if (governorate == null) {
      await _warn('اختاري المحافظة', 'اختاري محافظة الخدمة قبل الحفظ.');
      return;
    }
    for (var i = 0; i < _days.length; i++) {
      final src = ProviderProfileRepository.workDays[i];
      src.enabled = _days[i].enabled;
      src.from = _days[i].from;
      src.to = _days[i].to;
    }
    ProviderProfileRepository.governorateId = governorate;
    if (!mounted) return;
    await showProviderDialog(
      context,
      title: 'تم الحفظ',
      message: 'تم تحديث أوقات العمل ومناطق الخدمة.',
      confirmText: 'حسنًا',
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _timeBox(String label, TimeOfDay t, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutralDark,
                ),
              ),
              const Spacer(),
              Text(
                formatProviderTime(t),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayCard(ProviderWorkDay d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: providerCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                d.day,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDarkActive,
                ),
              ),
              const Spacer(),
              ProviderSwitch(
                value: d.enabled,
                onChanged: (v) => setState(() => d.enabled = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: d.enabled ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !d.enabled,
              child: Row(
                children: [
                  _timeBox('من', d.from, () => _pickTime(d, isFrom: true)),
                  const SizedBox(width: 8),
                  _timeBox('إلى', d.to, () => _pickTime(d, isFrom: false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// قائمة المحافظات
  Widget _governorateDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _governorate,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: AppColors.white,
          hint: const Text(
            'اختاري المحافظة',
            style: TextStyle(fontSize: 13, color: AppColors.neutralNormal),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary600,
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDarkActive,
          ),
          items: [
            for (final g in gazaGovernorates)
              DropdownMenuItem(value: g.id, child: Text(g.name)),
          ],
          onChanged: (v) => setState(() => _governorate = v),
        ),
      ),
    );
  }

  /// صورة ثابتة للخريطة حالياً 🔥 لاحقاً: خريطة حقيقية لموقع العمل
  Widget _mapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'موقع عملك على الخريطة',
            children: [
              TextSpan(
                text: ' (اختياري)',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: AppColors.neutralDark,
                ),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDarkActive,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 176,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/patient/map_preview.png',
              width: double.infinity,
              height: 176,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppColors.primary50),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'يساعد المرضى على معرفة قربك منهم، ولا يرى المريض موقعك الدقيق.',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderSubScaffold(
      title: 'أوقات العمل ومناطق الخدمة',
      // معطّل لحد ما يصير تغيير
      bottom: IgnorePointer(
        ignoring: !_hasChanges,
        child: Opacity(
          opacity: _hasChanges ? 1 : 0.5,
          child: AppButton(text: 'حفظ التغييرات', onPressed: _save),
        ),
      ),
      children: [
        const ProviderSectionHeader(
          'أيام وساعات العمل',
          hint: 'اضغطي على الساعة لتغييرها',
        ),
        for (final d in _days) ...[
          _dayCard(d),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        const ProviderSectionHeader('منطقة الخدمة', hint: 'قطاع غزة'),
        const Text(
          'المحافظة',
          style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
        ),
        const SizedBox(height: 4),
        _governorateDropdown(),
        const SizedBox(height: 16),
        _mapPreview(),
        const SizedBox(height: 16),
        const Text(
          'تصلك طلبات المرضى في محافظتك فقط.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.neutralDark,
          ),
        ),
      ],
    );
  }
}