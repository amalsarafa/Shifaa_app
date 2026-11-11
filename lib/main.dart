import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/core/routes/app_routes.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/splash/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قفل الشاشة على الوضع العمودي فقط
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
      ),
      home: SplashScreen(),
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