import 'package:flutter/material.dart';
import 'admin_chat_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Hàm chuyển hướng kèm theo "tên thẻ" của nhân vật
  void _goToChat(BuildContext context, String type) {
    Navigator.pushNamed(
      context, 
      '/chat', 
      arguments: type, // Ném cái tên phân quyền ('pot', 'put', 'mom') qua đây
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ai đang cầm máy đó?')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _goToChat(context, 'pot'),
              child: const Text('Tui là Đạt (Pột)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _goToChat(context, 'put'),
              child: const Text('Tui là Thảo (Pụt)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _goToChat(context, 'mom'),
              child: const Text('Cô Tuyền đây'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () => _goToChat(context, 'guest'),
              child: const Text('Người lạ / Khách'),
            ),
          ],
        ),
      ),
    );
  }
}