import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  Future<void> _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('userType');
    if (savedUser != null && mounted) {
      Navigator.pushReplacementNamed(context, '/chat', arguments: savedUser);
    }
  }

  Future<void> _handleLogin(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', type);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/chat', arguments: type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ai đang xài Pủn vậy?')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // TÌM CHỖ `children: [` RỒI DÁN ĐÈ CỤC NÀY VÀO:
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(250, 50)),
              onPressed: () => _handleLogin('admin'),
              child: const Text('Tui là Pột (Admin)', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, minimumSize: const Size(250, 50)),
              onPressed: () => _handleLogin('momi'),
              child: const Text('Mẹ của Pột (Momi)', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, minimumSize: const Size(250, 50)),
              onPressed: () => _handleLogin('put'), // Quyền của Pụt
              child: const Text('Tui là Pụt', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(250, 50)),
              onPressed: () => _handleLogin('guest'),
              child: const Text('Khách lạ (Guest)', style: TextStyle(fontSize: 20, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}