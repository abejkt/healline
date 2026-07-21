import 'dart:io';
import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ambil_antrian_screen.dart';
import 'screens/tiket_antrian_screen.dart';
import 'screens/status_antrian_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/profile_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const HealLineApp());
}

class HealLineApp extends StatelessWidget {
  const HealLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealLine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        OtpScreen.routeName: (_) => const OtpScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        RiwayatScreen.routeName: (_) => const RiwayatScreen(),
        AmbilAntrianScreen.routeName: (_) => const AmbilAntrianScreen(),
        TiketAntrianScreen.routeName: (_) => const TiketAntrianScreen(),
        StatusAntrianScreen.routeName: (_) => const StatusAntrianScreen(),
      },
    );
  }
}
