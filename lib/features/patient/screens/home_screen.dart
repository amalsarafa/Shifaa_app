import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
    final ValueChanged<int>? onGoToTab;

  const HomeScreen({super.key, this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('الشاشة الرئيسية'),

            const SizedBox(height: 50),

            MaterialButton(
              onPressed: () {
               onGoToTab?.call(1);
              },
              color: AppColors.primary500,
              textColor: Colors.white,

              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
