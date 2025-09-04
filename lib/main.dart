import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLogin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final bool isLoggedIn = snapshot.data!;

        final GoRouter router = GoRouter(
          initialLocation: isLoggedIn ? '/' : '/login',
          routes: [
            GoRoute(path: '/', builder: (_, __) => const MainScreen()),
            GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
            GoRoute(
              path: '/register',
              builder: (_, __) => const RegisterPage(),
            ),
            GoRoute(
              path: '/forgot',
              builder: (_, __) => const ForgotPasswordPage(),
            ),
          ],
        );

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Auth App',
          routerConfig: router,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(
              0xFF00AEEF,
            ), // ← nuevo fondo azul
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00AEEF), // ← también aquí
            ),
            useMaterial3: true,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
          ),
        );
      },
    );
  }
}
