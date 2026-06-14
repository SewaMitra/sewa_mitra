import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_container.dart';
import 'screens/notifications.dart';
import 'screens/forgot_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sewa Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF8A00),
          secondary: Color(0xFFFF8A00),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(nextScreen: LoginScreen()),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainContainer(),
        '/notifications': (context) => const NotificationsScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}