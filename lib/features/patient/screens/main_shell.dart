// lib/features/main/main_shell.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/features/patient/screens/bookings_screen.dart';
import 'package:my_first_app/features/patient/screens/categories_screen.dart';
import 'package:my_first_app/features/patient/screens/home_screen.dart';
import 'package:my_first_app/features/patient/screens/personal_profile.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/widgets/bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  
  late final List<Widget> _pages = [
    HomeScreen(onGoToTab: (i) => setState(() => _currentIndex = i)),
    const CategoriesScreen(),
    BookingsScreen(onGoToTab: (i) => setState(() => _currentIndex = i)),
    const PersonalProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
