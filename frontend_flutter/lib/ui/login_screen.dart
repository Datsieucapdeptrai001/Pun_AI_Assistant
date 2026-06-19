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
          children: [
            ElevatedButton(
              onPressed: () => _handleLogin('admin'),
              child: const Text('Tui là Pột (Admin)', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () => _handleLogin('momi'),
              child: const Text('Mẹ của Pột (Momi)', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}