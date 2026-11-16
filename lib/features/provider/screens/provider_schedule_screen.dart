// lib/features/provider/screens/provider_schedule_screen.dart
import 'package:flutter/material.dart';
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
  late final Set<String> _areas = {...ProviderProfileRepository.areas};

  double _minutes(TimeOfDay t) => t.hour * 60.0 + t.minute;

  /// هل تغيّر يوم أو ساعة أو منطقة عن المحفوظ؟
  bool get _hasChanges {
    final saved = ProviderProfileRepository.workDays;
    for (var i = 0; i < _days.length; i++) {
      final d = _days[i];
      final s = saved[i];
      if (d.enabled != s.enabled || d.from != s.from || d.to != s.to) {
        return true;
      }
    }
    final areas = ProviderProfileRepository.areas;
    return _areas.length != areas.length || !_areas.containsAll(areas);
  }

  Future<void> _pickTime(ProviderWorkDay d, {required bool isFrom}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? d.from : d.to,
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
    if (_areas.isEmpty) {
      await _warn('اختاري منطقة', 'اختاري منطقة خدمة واحدة على الأقل.');
      return;
    }
    for (var i = 0; i < _days.length; i++) {
      final src = ProviderProfileRepository.workDays[i];
      src.enabled = _days[i].enabled;
      src.from = _days[i].from;
      src.to = _days[i].to;
    }
    ProviderProfileRepository.areas = {..._areas};
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
        const ProviderSectionHeader(
          'مناطق الخدمة',
          hint: 'اختاري منطقة أو أكثر',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in ProviderProfileRepository.allAreas)
              ProviderChoiceChip(
                label: a,
                selected: _areas.contains(a),
                onTap: () => setState(() {
                  if (!_areas.remove(a)) _areas.add(a);
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'يصلك طلبات المرضى في المناطق التي تختارينها فقط، ولا يظهر للمريض إلا اسم المنطقة.',
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