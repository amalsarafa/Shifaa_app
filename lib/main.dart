import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/core/routes/app_routes.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_first_app/features/splash/splash_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarDividerColor: Colors.transparent, // يلغي الخط الفاصل
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false, // يلغي التعتيم التلقائي
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.cairo().fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        // بدونها Flutter بيستعمل البنفسجي الافتراضي بالساعة والمفاتيح...
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary600,
          primary: AppColors.primary600,
          onPrimary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.neutralDarkActive,
        ),
        // نافذة اختيار الوقت
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          dialHandColor: AppColors.primary600,
          dialBackgroundColor: AppColors.primary50,
          dialTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.white
                : AppColors.neutralDarkActive,
          ),
          hourMinuteColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary100
                : AppColors.primary50,
          ),
          hourMinuteTextColor: AppColors.primary800,
          dayPeriodColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary100
                : AppColors.white,
          ),
          dayPeriodTextColor: AppColors.primary800,
          dayPeriodBorderSide: const BorderSide(color: AppColors.primary100),
          entryModeIconColor: AppColors.primary600,
        ),
        // نافذة اختيار التاريخ
        datePickerTheme: const DatePickerThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const SplashScreen(),
      //const LoginScreen(),
      //const RoleSwitchScreen(),
      //const ProviderShell(),
      routes: AppRoutes.routes,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.1,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}