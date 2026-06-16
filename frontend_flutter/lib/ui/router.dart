import 'package:flutter/material.dart';
import 'admin_chat_screen.dart';
import 'auto_listen_screen.dart';

class AppRouter {
  // Hàm này chịu trách nhiệm phân luồng giao thông
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AdminChatScreen());
      case '/auto-listen':
        return MaterialPageRoute(builder: (_) => const AutoListenScreen());
      default:
        // Lỡ Pụt bấm nhầm link bậy bạ thì vứt ra màn hình báo lỗi
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Lỗi 404')),
            body: Center(child: Text('Không tìm thấy đường đi: ${settings.name}')),
          ),
        );
    }
  }
}