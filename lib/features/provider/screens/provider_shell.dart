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

  static const List<Widget> _pages = [
    ProviderHomeScreen(),
    ProviderAppointmentsScreen(),
    ProviderPatientsScreen(),
    ProviderMyProfileScreen(),
  ];

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