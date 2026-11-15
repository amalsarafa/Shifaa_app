// lib/features/provider/screens/provider_shell.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/provider/screens/provider_appointments_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_home_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_patients_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_profile_screen.dart';
import 'package:my_first_app/features/provider/widgets/bottom_nav_bar.dart';

class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key});

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _currentIndex = 0;

  final _appointmentsTab = ValueNotifier<int>(0);

  // يفتح صفحة المواعيد على التبويب المطلوب
  void _openAppointments(int tab) {
    _appointmentsTab.value = tab;
    setState(() => _currentIndex = 1);
  }

  late final List<Widget> _pages = [
    ProviderHomeScreen(onOpenAppointments: _openAppointments),
    ProviderAppointmentsScreen(tabRequest: _appointmentsTab),
    const ProviderPatientsScreen(),
    const ProviderMyProfileScreen(),
  ];

  @override
  void dispose() {
    _appointmentsTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ProviderBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}