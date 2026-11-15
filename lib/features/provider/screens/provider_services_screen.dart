// lib/features/provider/screens/provider_services_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/services/provider_profile_repository.dart';
import 'package:my_first_app/features/provider/widgets/app_button.dart';
import 'package:my_first_app/features/provider/widgets/provider_dialog.dart';
import 'package:my_first_app/features/provider/widgets/provider_sub_scaffold.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  late final List<bool> _enabled = ProviderProfileRepository.services
      .map((s) => s.enabled)
      .toList();

  int get _count => _enabled.where((e) => e).length;

  Future<void> _save() async {
    if (_count == 0) {
      await showProviderDialog(
        context,
        title: 'فعّلي خدمة واحدة على الأقل',
        message: 'لا يمكن حفظ التغييرات بدون أي خدمة مفعّلة.',
        confirmText: 'حسنًا',
      );
      return;
    }
    for (var i = 0; i < _enabled.length; i++) {
      ProviderProfileRepository.services[i].enabled = _enabled[i];
    }
    await showProviderDialog(
      context,
      title: 'تم الحفظ',
      message: 'تم تحديث الخدمات التي تقدمينها.',
      confirmText: 'حسنًا',
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final services = ProviderProfileRepository.services;
    return ProviderSubScaffold(
      title: 'الخدمات التي أقدمها',
      bottom: AppButton(text: 'حفظ التغييرات', onPressed: _save),
      children: [
        ProviderSectionHeader(
          'الرعاية التمريضية',
          hint: '$_count من ${services.length} مفعّلة',
        ),
        Container(
          decoration: providerCardDecoration(),
          child: Column(
            children: [
              for (var i = 0; i < services.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(services[i].icon,
                            size: 20, color: AppColors.primary600),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              services[i].name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutralDarkActive,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              services[i].duration,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.neutralDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${services[i].price} ₪',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ProviderSwitch(
                        value: _enabled[i],
                        onChanged: (v) => setState(() => _enabled[i] = v),
                      ),
                    ],
                  ),
                ),
                if (i != services.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'فعّلي الخدمات التي تقدمينها فقط، فلا تصلك طلبات لغيرها. تظهر أقسام أخرى هنا عند إضافتها للتطبيق.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.neutralDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.primary700),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الأسعار تحددها المنصة وتظهر للمريض كما هي. الأجر يُدفع نقدًا عند الزيارة، وتؤكدين استلامه في تقرير الزيارة.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.primary800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}