import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_chat_screen.dart';
import 'auto_listen_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/chat':
        final userType = settings.arguments as String? ?? 'guest';
        return MaterialPageRoute(builder: (_) => AdminChatScreen(userType: userType));
      case '/auto-listen':
        final userType = settings.arguments as String? ?? 'guest';
        return MaterialPageRoute(builder: (_) => AutoListenScreen(userType: userType));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Lỗi: Không tìm thấy trang ${settings.name}')),
          ),
        );
    }
  }
}