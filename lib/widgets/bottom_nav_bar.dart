import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class _NavItem {
  final String label;
  final String icon;
  final String activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'الرئيسية',
      icon: 'assets/icons/home.svg',
      activeIcon: 'assets/icons/home_filled.svg',
    ),
    _NavItem(
      label: 'الخدمات',
      icon: 'assets/icons/services.svg',
      activeIcon: 'assets/icons/services_filled.svg',
    ),
    _NavItem(
      label: 'حجوزاتي',
      icon: 'assets/icons/appointments.svg',
      activeIcon: 'assets/icons/appointments_filled.svg',
    ),
    _NavItem(
      label: 'حسابي',
      icon: 'assets/icons/profile.svg',
      activeIcon: 'assets/icons/profile_filled.svg',
    ),
  ];

  Widget _navItem(int index) {
    final item = _items[index];
    final bool selected = index == currentIndex;
    final Color color =
        selected ? AppColors.primary800 : AppColors.neutralDark;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 32,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary500.withOpacity(0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset(
                  selected ? item.activeIcon : item.icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.neutralNormal, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Row(
              children: List.generate(_items.length, _navItem),
            ),
          ),
        ),
      ),
    );
  }
}