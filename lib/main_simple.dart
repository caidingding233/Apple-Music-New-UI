import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer/services/auth_service.dart';
import 'package:musicplayer/pages/login_page.dart';
import 'package:musicplayer/pages/simple_demo_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          scaffoldBackgroundColor: const Color.fromARGB(255, 33, 33, 36),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/demo': (context) => const SimpleDemoPage(),
        },
      ),
    );
  }
}

/// 认证包装器 - 根据登录状态显示不同页面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoggedIn) {
          // 已登录，显示简化的音乐演示页面
          return const SimpleDemoPage();
        } else {
          // 未登录，显示登录页面
          return const LoginPage();
        }
      },
    );
  }
} 