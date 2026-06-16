import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_chat_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Màn hình khởi điểm mặc định là Login
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      // Màn hình Chat cần bắt giá trị phân quyền
      case '/chat':
        // Hứng cục dữ liệu (arguments) truyền từ Login sang
        final userType = settings.arguments as String? ?? 'guest';
        return MaterialPageRoute(builder: (_) => AdminChatScreen(userType: userType));
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Lỗi: Không tìm thấy trang ${settings.name}')),
          ),
        );
    }
  }
}